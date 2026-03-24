unit View.DM;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.SvcMgr,
  Service.WorkerThread;

type
  TDMServico = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
  private
    FWorker: TWorkerThread;
    procedure PararWorker;
  public
    function GetServiceController: TServiceController; override;
    constructor Create(AOwner: TComponent); override;
  end;

var
  DMServico: TDMServico;

implementation

uses
  System.Win.Registry;

{$R *.dfm}

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
  Name        := 'ServicoEnvioNFs';
  DisplayName := 'Servico Envio NFs - SEFIN Fortaleza';
  AllowPause  := False;
  AllowStop   := True;
  OnStart     := ServiceStart;
  OnStop      := ServiceStop;
  OnExecute   := ServiceExecute;
  OnShutdown  := ServiceShutdown;
  AfterInstall := ServiceAfterInstall;
end;

procedure TDMServico.PararWorker;
begin
  case Assigned(FWorker) of
    True:
    begin
      FWorker.Parar;
      FWorker.WaitFor;
      FreeAndNil(FWorker);
    end;
  end;
end;

procedure TDMServico.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  try
    FWorker := TWorkerThread.Criar(ParamStr(0));
    FWorker.Start;
    Started := True;
  except
    on E: Exception do
      LogMessage('ERRO ao iniciar: ' + E.Message, EVENTLOG_ERROR_TYPE, 0, 1);
  end;
end;

procedure TDMServico.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  PararWorker;
  Stopped := True;
end;

procedure TDMServico.ServiceShutdown(Sender: TService);
begin
  PararWorker;
end;

procedure TDMServico.ServiceExecute(Sender: TService);
begin
  while not Terminated do
    ServiceThread.ProcessRequests(False);
end;

procedure TDMServico.ServiceAfterInstall(Sender: TService);
var
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
          'Gera e envia XMLs de NFS-e para SEFIN Fortaleza automaticamente.');
        LReg.CloseKey;
      end;
    end;
  finally
    LReg.Free;
  end;
end;

end.
