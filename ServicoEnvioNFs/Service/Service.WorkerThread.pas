unit Service.WorkerThread;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.DateUtils,
  System.IOUtils,
  Winapi.ActiveX,
  Shared.Tipos,
  Service.IWorkerThread;

type
  TWorkerThread = class(TThread)
  private
    FStop   : TEvent;
    FExePath: string;

    procedure Executar;
    procedure GravarLog(const AMensagem: string; const AErro: Boolean);
    function  DeveExecutarAgora(const AConfig: TDadosConfiguracaoEnvio): Boolean;
    function  IntervaloMs(const AConfig: TDadosConfiguracaoEnvio): Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Criar(const AExePath: string);
    destructor Destroy; override;
    procedure Parar;
  end;

implementation

uses
  Model.ILeituraIni,
  Model.TLeituraIni,
  Model.IConexaoDB,
  Model.TConexaoDB,
  Controller.IGeracaoXml,
  Controller.TGeracaoXml;

const
  { Homologacao: executa a cada 1 minuto }
  INTERVALO_HOMOLOGACAO_MS = 60000;

  { Producao: verifica a cada 1 hora se e o dia certo }
  INTERVALO_PRODUCAO_MS    = 3600000;

constructor TWorkerThread.Criar(const AExePath: string);
begin
  inherited Create(True);
  FExePath        := AExePath;
  FStop           := TEvent.Create(nil, True, False, '');
  FreeOnTerminate := False;
end;

destructor TWorkerThread.Destroy;
begin
  FStop.Free;
  inherited;
end;

procedure TWorkerThread.Parar;
begin
  FStop.SetEvent;
  Terminate;
end;

procedure TWorkerThread.GravarLog(const AMensagem: string; const AErro: Boolean);
var
  LPasta : string;
  LArq   : string;
  LWriter: TStreamWriter;
  LPrefix: string;
begin
  try
    LPasta := TPath.Combine(ExtractFilePath(FExePath), 'Logs');
    ForceDirectories(LPasta);
    LArq   := TPath.Combine(LPasta, FormatDateTime('yyyy-mm-dd', Now) + '.log');

    case AErro of
      True : LPrefix := '[ERRO] ';
      False: LPrefix := '[INFO] ';
    end;

    LWriter := TStreamWriter.Create(LArq, True, TEncoding.UTF8);
    try
      LWriter.WriteLine(FormatDateTime('hh:nn:ss', Now) + ' ' + LPrefix + AMensagem);
    finally
      LWriter.Free;
    end;
  except
    { ignora erro de log para nao derrubar o servico }
  end;
end;

function TWorkerThread.IntervaloMs(const AConfig: TDadosConfiguracaoEnvio): Cardinal;
begin
  { Homologacao — 1 minuto | Producao — 1 hora }
  case AConfig.Ambiente of
    amHomologacao: Result := INTERVALO_HOMOLOGACAO_MS;
    amProducao   : Result := INTERVALO_PRODUCAO_MS;
  else
    Result := INTERVALO_PRODUCAO_MS;
  end;
end;

function TWorkerThread.DeveExecutarAgora(const AConfig: TDadosConfiguracaoEnvio): Boolean;
begin
  case AConfig.Ambiente of

    { Homologacao — executa sempre }
    amHomologacao:
      Result := True;

    { Producao — executa somente no dia configurado em [Config] DiaEnvio }
    amProducao:
      Result := DayOf(Now) = AConfig.DiaEnvio;

  else
    Result := False;
  end;
end;

procedure TWorkerThread.Executar;
var
  LLeituraIni: ILeituraIni;
  LConfig    : TDadosConfiguracaoEnvio;
  LConexao   : IConexaoDB;
  LController: IGeracaoXml;
  LResultados: TArray<TResultadoXml>;
  LIdx       : Integer;
begin
  try
    { Carrega configuracoes a cada ciclo — reflete mudancas no .ini sem reiniciar }
    LLeituraIni := TLeituraIni.Criar;
    LConfig     := LLeituraIni.Carregar(FExePath, MonthOf(Now), YearOf(Now));

    { [Thread] Ativa=0 — paralisa o servico sem derrubar }
    case LConfig.ThreadAtiva of
      False:
      begin
        GravarLog('[Thread] Ativa=0 no .ini — ciclo suspenso.', False);
        Exit;
      end;
    end;

    { Verifica se deve executar agora conforme ambiente e dia }
    case DeveExecutarAgora(LConfig) of
      False:
      begin
        GravarLog(Format('[Producao] Aguardando dia %d. Hoje e dia %d.',
          [LConfig.DiaEnvio, DayOf(Now)]), False);
        Exit;
      end;
    end;

    GravarLog('Iniciando ciclo de geracao de XML...', False);

    GravarLog(Format('Ambiente: %s | Modo: %s | %d/%d | Banco: %s/%s', [
      BoolToStr(LConfig.Ambiente = amHomologacao, True) + ' (Homologacao/Producao)',
      BoolToStr(LConfig.ModoEnvio = meLote, True),
      LConfig.Mes, LConfig.Ano,
      LConfig.Servidor, LConfig.Banco]), False);

    LConexao := TConexaoDB.Criar(
      LConfig.Servidor,
      LConfig.Banco,
      LConfig.Login,
      LConfig.Senha);

    LController := TGeracaoXml.Criar;
    LController.Executar(
      LConexao,
      LConfig,
      procedure(const AMensagem: string; const AErro: Boolean)
      begin
        GravarLog(AMensagem, AErro);
      end,
      LResultados);

    for LIdx := 0 to Length(LResultados) - 1 do
      case LResultados[LIdx].Sucesso of
        True:
          GravarLog(Format('XML gerado: %s (%d RPS)',
            [LResultados[LIdx].CaminhoArquivo,
             LResultados[LIdx].QuantidadeRps]), False);
        False:
          GravarLog('Erro: ' + LResultados[LIdx].MensagemErro, True);
      end;

    GravarLog('Ciclo concluido.', False);

  except
    on E: Exception do
      GravarLog('EXCECAO no ciclo: ' + E.ClassName + ' — ' + E.Message, True);
  end;
end;

procedure TWorkerThread.Execute;
var
  LLeituraIni: ILeituraIni;
  LConfig    : TDadosConfiguracaoEnvio;
  LIntervalo : Cardinal;
begin
  CoInitialize(nil);
  try
    GravarLog('WorkerThread iniciado.', False);

    { Executa imediatamente na primeira vez }
    Executar;

    { Loop — intervalo depende do ambiente lido do .ini }
    while FStop.WaitFor(0) = wrTimeout do
    begin
      case Terminated of
        True: Break;
      end;

      { Rele o ini para pegar intervalo atualizado }
      try
        LLeituraIni := TLeituraIni.Criar;
        LConfig     := LLeituraIni.Carregar(FExePath, MonthOf(Now), YearOf(Now));
        LIntervalo  := IntervaloMs(LConfig);
      except
        LIntervalo := INTERVALO_PRODUCAO_MS;
      end;

      { Aguarda o intervalo correto }
      case FStop.WaitFor(LIntervalo) of
        wrSignaled: Break;
      end;

      case Terminated of
        True: Break;
      end;

      Executar;
    end;

    GravarLog('WorkerThread encerrado.', False);
  finally
    CoUninitialize;
  end;
end;

end.
