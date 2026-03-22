unit Service.WorkerThread;

{
  ============================================================
  Service.WorkerThread — Thread principal do servico Windows
  ============================================================
  Responsabilidade UNICA: controlar o ciclo de execucao.
    1. Ao iniciar: executa imediatamente o primeiro ciclo
    2. Aguarda INTERVALO_MS via TEvent (nao bloqueia o SCM)
    3. Ao acordar: executa novo ciclo
    4. Para de forma limpa via Parar + WaitFor no TService

  Nota sobre interface:
    TThread nao herda de TInterfacedObject, portanto nao
    implementa IWorkerThread diretamente. O View.DM usa
    TWorkerThread concreto — correto pois e o unico ponto
    de criacao e destruicao da thread no servico.

  Dependencias (apenas no implementation, sem acoplamento
  na interface da unit):
    - Model.TLeituraIni  : le o .ini e monta TDadosConfiguracaoEnvio
    - Model.TConexaoDB   : abre conexao FireDAC com SQL Server
    - Controller.TGeracaoXml : orquestra busca + montagem dos XMLs
  ============================================================
}

interface

uses
  System.SysUtils,   { FormatDateTime, ExtractFilePath, Format }
  System.Classes,    { TThread }
  System.SyncObjs,   { TEvent, TWaitResult }
  System.DateUtils,  { MonthOf, YearOf }
  System.IOUtils,    { TPath, TStreamWriter }
  Shared.Tipos;      { TDadosConfiguracaoEnvio, TResultadoXml, TCallbackProgresso }

type
  {
    TWorkerThread — thread de ciclo do servico.
    Criada suspended, iniciada via Start pelo TService.
    FreeOnTerminate = False — destruicao controlada pelo TService.
  }
  TWorkerThread = class(TThread)
  private
    { Evento de parada — SetEvent acorda o WaitFor e encerra o loop }
    FStop       : TEvent;
    { Caminho do executavel — usado para resolver pastas de Log e Config }
    FExePath    : string;
    { Intervalo entre ciclos em milissegundos }
    FIntervaloMs: Integer;

    {
      Executar — corpo de um ciclo completo:
        1. Le .ini
        2. Conecta no banco
        3. Chama controller para buscar RPS e gerar XMLs
        4. Grava resultado no log
      Qualquer excecao e capturada e gravada no log sem derrubar o servico.
    }
    procedure Executar;

    {
      GravarLog — persiste uma linha no arquivo de log diario.
      Formato: hh:nn:ss [INFO|ERRO] mensagem
      Arquivo: <ExePath>\Logs\yyyy-mm-dd.log
      Erros de escrita sao silenciados para nao derrubar o servico.
    }
    procedure GravarLog(const AMensagem: string; const AErro: Boolean);

  protected
    {
      Execute — loop principal da thread.
      Executa um ciclo imediatamente ao iniciar, depois aguarda
      FIntervaloMs antes de cada ciclo seguinte.
      Encerra quando FStop.SetEvent for chamado.
    }
    procedure Execute; override;

  public
    {
      Criar — factory da thread.
      AExePath    : caminho do executavel do servico (ParamStr(0))
      AIntervaloMs: intervalo entre ciclos em ms (ex: 3.600.000 = 1h)
      Retorna a thread criada em modo suspended (nao iniciada).
    }
    constructor Criar(
      const AExePath    : string;
      const AIntervaloMs: Integer);

    { Destroy — libera o TEvent antes de destruir a thread }
    destructor Destroy; override;

    {
      Parar — sinaliza a thread para encerrar no proximo WaitFor.
      Chamar sempre antes de WaitFor + Free no TService.
    }
    procedure Parar;
  end;

implementation

uses
  Model.ILeituraIni,      { interface do leitor de .ini }
  Model.TLeituraIni,      { implementacao do leitor de .ini }
  Model.IConexaoDB,       { interface da conexao FireDAC }
  Model.TConexaoDB,       { implementacao da conexao FireDAC }
  Controller.IGeracaoXml, { interface do controller de geracao }
  Controller.TGeracaoXml; { implementacao do controller de geracao }

{ ── TWorkerThread ─────────────────────────────────────────────────── }

constructor TWorkerThread.Criar(
  const AExePath    : string;
  const AIntervaloMs: Integer);
begin
  { Cria suspended — o TService chama Start apos configurar }
  inherited Create(True);
  FExePath        := AExePath;
  FIntervaloMs    := AIntervaloMs;
  { ManualReset=True, InitialState=False — exige SetEvent explicito }
  FStop           := TEvent.Create(nil, True, False, '');
  { False = TService gerencia o ciclo de vida via WaitFor + Free }
  FreeOnTerminate := False;
end;

destructor TWorkerThread.Destroy;
begin
  FStop.Free;
  inherited;
end;

procedure TWorkerThread.Parar;
begin
  { Acorda o WaitFor imediatamente }
  FStop.SetEvent;
  { Sinaliza o loop interno para nao iniciar novo ciclo }
  Terminate;
end;

procedure TWorkerThread.GravarLog(const AMensagem: string; const AErro: Boolean);
var
  LPasta : string;  { Pasta de destino dos logs }
  LArq   : string;  { Caminho completo do arquivo de log do dia }
  LWriter: TStreamWriter; { Escritor UTF-8 em modo append }
  LPrefix: string;  { Prefixo [INFO] ou [ERRO] }
begin
  try
    LPasta := TPath.Combine(ExtractFilePath(FExePath), 'Logs');
    ForceDirectories(LPasta);
    LArq   := TPath.Combine(LPasta, FormatDateTime('yyyy-mm-dd', Now) + '.log');

    case AErro of
      True : LPrefix := '[ERRO] ';
      False: LPrefix := '[INFO] ';
    end;

    { Append=True garante acumulacao no mesmo arquivo durante o dia }
    LWriter := TStreamWriter.Create(LArq, True, TEncoding.UTF8);
    try
      LWriter.WriteLine(FormatDateTime('hh:nn:ss', Now) + ' ' + LPrefix + AMensagem);
    finally
      LWriter.Free;
    end;
  except
    { Silencia qualquer erro de I/O para nao derrubar o servico }
  end;
end;

procedure TWorkerThread.Executar;
var
  LLeituraIni: ILeituraIni;             { Leitor do .ini }
  LConfig    : TDadosConfiguracaoEnvio; { Configuracoes carregadas }
  LConexao   : IConexaoDB;             { Conexao com o SQL Server }
  LController: IGeracaoXml;            { Controller de geracao de XML }
  LResultados: TArray<TResultadoXml>;  { Resultados de cada XML gerado }
  LIdx       : Integer;                { Indice para percorrer LResultados }
  LModo      : string;                 { Descricao textual do modo de envio }
begin
  try
    GravarLog('Iniciando ciclo de geracao de XML...', False);

    { 1. Le configuracoes do NFSe_Servico.ini }
    LLeituraIni := TLeituraIni.Criar;
    LConfig     := LLeituraIni.Carregar(FExePath, MonthOf(Now), YearOf(Now));

    { Descricao textual do modo para o log }
    case LConfig.ModoEnvio of
      meLote      : LModo := 'Lote';
      meIndividual: LModo := 'Individual';
    end;

    GravarLog(Format('Modo: %s | %d/%d | Banco: %s/%s',
      [LModo, LConfig.Mes, LConfig.Ano,
       LConfig.Servidor, LConfig.Banco]), False);

    { 2. Abre conexao com o SQL Server }
    LConexao := TConexaoDB.Criar(
      LConfig.Servidor,
      LConfig.Banco,
      LConfig.Login,
      LConfig.Senha);

    { 3. Executa busca no banco + geracao dos XMLs }
    LController := TGeracaoXml.Criar;
    LController.Executar(
      LConexao,
      LConfig,
      procedure(const AMensagem: string; const AErro: Boolean)
      begin
        { Repassa cada mensagem do controller direto para o log }
        GravarLog(AMensagem, AErro);
      end,
      LResultados);

    { 4. Grava resultado de cada XML no log }
    for LIdx := 0 to Length(LResultados) - 1 do
      case LResultados[LIdx].Sucesso of
        True:
          GravarLog(Format('XML gerado: %s (%d RPS)',
            [LResultados[LIdx].CaminhoArquivo,
             LResultados[LIdx].QuantidadeRps]), False);
        False:
          GravarLog('Erro ao gerar XML: ' + LResultados[LIdx].MensagemErro, True);
      end;

    GravarLog('Ciclo concluido.', False);

  except
    on E: Exception do
      GravarLog('EXCECAO no ciclo: ' + E.ClassName + ' — ' + E.Message, True);
  end;
end;

procedure TWorkerThread.Execute;
begin
  GravarLog('WorkerThread iniciado.', False);

  { Executa imediatamente na primeira vez sem aguardar o intervalo }
  Executar;

  {
    Loop: aguarda FIntervaloMs milissegundos.
    wrTimeout = intervalo expirou normalmente, executa novo ciclo.
    Qualquer outro resultado (wrSignaled = Parar foi chamado) encerra.
  }
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
