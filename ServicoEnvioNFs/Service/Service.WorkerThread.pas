unit Service.WorkerThread;

{
  WorkerThread — ciclo principal do servico.

  TThread NAO herda de TInterfacedObject, entao nao implementa
  interface diretamente. A interface IWorkerThread e exposta via
  factory que retorna o proprio objeto como IWorkerThread usando
  um adapter simples.

  Ciclo:
    - Executa imediatamente ao iniciar
    - Aguarda INTERVALO_MS via TEvent
    - Ao acordar executa novamente
    - Para limpo via Parar + WaitFor no TService
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.DateUtils,
  System.IOUtils,
  Shared.Tipos,
  Service.IWorkerThread;

type
  TWorkerThread = class(TThread)
  private
    FStop      : TEvent;
    FExePath   : string;
    FIntervaloMs: Integer;

    procedure Executar;
    procedure GravarLog(const AMensagem: string; const AErro: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Criar(
      const AExePath    : string;
      const AIntervaloMs: Integer);
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

constructor TWorkerThread.Criar(
  const AExePath    : string;
  const AIntervaloMs: Integer);
begin
  inherited Create(True);
  FExePath        := AExePath;
  FIntervaloMs    := AIntervaloMs;
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
    GravarLog('Iniciando ciclo de geracao de XML...', False);

    LLeituraIni := TLeituraIni.Criar;
    LConfig     := LLeituraIni.Carregar(FExePath, MonthOf(Now), YearOf(Now));

    GravarLog(Format('Modo: %s | %d/%d | Banco: %s/%s', [
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
      GravarLog('EXCECAO: ' + E.Message, True);
  end;
end;

procedure TWorkerThread.Execute;
begin
  GravarLog('WorkerThread iniciado.', False);
  Executar;
  while FStop.WaitFor(FIntervaloMs) = wrTimeout do
  begin
    case Terminated of
      True: Break;
    end;
    Executar;
  end;
  GravarLog('WorkerThread encerrado.', False);
end;

end.
