unit View.DM;

{
  ============================================================
  View.DM — Entry point do Windows Service
  ============================================================
  Responsabilidade UNICA: gerenciar o ciclo de vida do servico
  Windows e da TWorkerThread.

  Eventos tratados:
    OnStart    : cria e inicia o WorkerThread
    OnStop     : para a thread de forma limpa (Parar + WaitFor)
    OnShutdown : idem ao OnStop (chamado no shutdown do Windows)
    OnExecute  : loop ProcessRequests — mantem o SCM respondendo
    AfterInstall: grava descricao do servico no registro

  Constante INTERVALO_MS:
    Define o intervalo entre ciclos do WorkerThread.
    Padrao: 3.600.000 ms = 1 hora.
    Alterar aqui para mudar a frequencia sem mexer na logica.
  ============================================================
}

interface

uses
  Winapi.Windows,      { EVENTLOG_ERROR_TYPE, KEY_READ, KEY_WRITE, HKEY_LOCAL_MACHINE }
  System.SysUtils,     { FreeAndNil, Exception }
  System.Classes,      { TComponent }
  Vcl.SvcMgr,          { TService, TServiceController }
  Service.WorkerThread;{ TWorkerThread }

type
  TDMServico = class(TService)
    procedure ServiceStart   (Sender: TService; var Started: Boolean);
    procedure ServiceStop    (Sender: TService; var Stopped: Boolean);
    procedure ServiceExecute (Sender: TService);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
  private
    { Thread responsavel pelo ciclo de geracao de XMLs }
    FWorker: TWorkerThread;

    {
      PararWorker — encerra a thread de forma limpa.
      Sequencia obrigatoria: Parar -> WaitFor -> FreeAndNil.
      Sem WaitFor o servico pode ser destruido antes da thread terminar.
    }
    procedure PararWorker;
  public
    { GetServiceController — obrigatorio pelo VCL.SvcMgr }
    function GetServiceController: TServiceController; override;
    { Create — configura propriedades do servico }
    constructor Create(AOwner: TComponent); override;
  end;

var
  { Variavel global exigida pelo VCL.SvcMgr para o dispatcher }
  DMServico: TDMServico;

implementation

uses
  System.Win.Registry; { TRegistry — para gravar descricao no registro }

{$R *.dfm}

const
  { Intervalo entre ciclos do WorkerThread: 1 hora em milissegundos }
  INTERVALO_MS = 60 * 60 * 1000;

{ Procedimento de controle exigido pelo SCM do Windows }
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  DMServico.Controller(CtrlCode);
end;

function TDMServico.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

constructor TDMServico.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { Nome interno do servico — deve coincidir com o sc create }
  Name        := 'ServicoEnvioNFs';
  DisplayName := 'Servico Envio NFs - SEFIN Fortaleza';
  AllowPause  := False; { Pausa nao suportada }
  AllowStop   := True;
  OnStart      := ServiceStart;
  OnStop       := ServiceStop;
  OnExecute    := ServiceExecute;
  OnShutdown   := ServiceShutdown;
  AfterInstall := ServiceAfterInstall;
end;

procedure TDMServico.PararWorker;
begin
  case Assigned(FWorker) of
    True:
    begin
      { 1. Sinaliza para a thread encerrar o loop }
      FWorker.Parar;
      { 2. Aguarda a thread finalizar completamente }
      FWorker.WaitFor;
      { 3. Destroi e nulifica }
      FreeAndNil(FWorker);
    end;
  end;
end;

procedure TDMServico.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  try
    { Cria a thread com o caminho do exe e o intervalo de 1 hora }
    FWorker := TWorkerThread.Criar(ParamStr(0), INTERVALO_MS);
    { Start inicia a thread (foi criada suspended no constructor) }
    FWorker.Start;
    Started := True;
  except
    on E: Exception do
      { Registra o erro no Event Viewer do Windows }
      LogMessage('ERRO ao iniciar o WorkerThread: ' + E.Message,
        EVENTLOG_ERROR_TYPE, 0, 1);
  end;
end;

procedure TDMServico.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  PararWorker;
  Stopped := True;
end;

procedure TDMServico.ServiceShutdown(Sender: TService);
begin
  { Mesmo comportamento do Stop — chamado no shutdown do Windows }
  PararWorker;
end;

procedure TDMServico.ServiceExecute(Sender: TService);
begin
  {
    Loop obrigatorio para manter o SCM respondendo.
    ProcessRequests(False) = nao bloqueante — retorna imediatamente
    se nao houver requisicao pendente do SCM.
    O trabalho real e feito pelo WorkerThread.
  }
  while not Terminated do
    ServiceThread.ProcessRequests(False);
end;

procedure TDMServico.ServiceAfterInstall(Sender: TService);
var
  { Registro do Windows para gravar a descricao do servico }
  LReg: TRegistry;
begin
  LReg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    LReg.RootKey := HKEY_LOCAL_MACHINE;
    case LReg.OpenKey(
      'SYSTEM\CurrentControlSet\Services\ServicoEnvioNFs', False) of
      True:
      begin
        LReg.WriteString('Description',
          'Gera e envia XMLs de NFS-e para a SEFIN Fortaleza automaticamente.');
        LReg.CloseKey;
      end;
    end;
  finally
    LReg.Free;
  end;
end;

end.
