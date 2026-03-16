unit View.TServiceEnvioNFs;

{
  TService descendente - entry point do Windows Service.
  Sem DFM: todas as propriedades configuradas no constructor via codigo.

  Regras criticas:
  - OnCreate/OnDestroy -> thread principal da aplicacao
  - OnStart/OnStop     -> thread DO SERVICO (thread diferente!)
  - FreeOnTerminate := False + WaitFor obrigatorio em PararServico
  - OnStop e OnShutdown -> ambos chamam PararServico
  - OnExecute -> apenas ProcessRequests, trabalho real no TWorkerThread
  - AllowPause := False

  Estrutura esperada:
    <pasta_do_exe>\ServiceEnvioNFs.exe
    <pasta_do_exe>\Config\NFSe_Servico.ini
}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Win.Registry,
  Vcl.SvcMgr,
  Service.TWorkerThread,
  Controller.TAgendamento,
  Controller.IAgendamento,
  Model.TConfiguracaoModel,
  Model.IConfiguracaoModel,
  Model.TNotificadorModel,
  Model.INotificadorModel,
  Shared.Tipos;

const
  SUBPASTA_CONFIG     = 'Config\';
  NOME_INI_SERVICO    = 'NFSe_Servico.ini';
  INTERVALO_NORMAL_MS = 60 * 60 * 1000;  // 1 hora
  INTERVALO_DEBUG_MS  = 30 * 1000;        // 30 segundos

type

  TServiceEnvioNFs = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
  private
    FWorker                : TWorkerThread;
    FConfigModel           : IConfiguracaoModel;
    FNotificadorModel      : INotificadorModel;
    FAgendamentoController : IAgendamentoController;
    FIniPath               : String;
    FIntervaloMs           : Cardinal;

    procedure IniciarServico;
    procedure PararServico;
    procedure GravarDescricaoRegistry;
  public
    // Usa Create normal (nao CreateNew) para o Application.CreateForm funcionar
    constructor Create(AOwner: TComponent); override;
    function GetServiceController: TServiceController; override;
  end;

var
  ServiceEnvioNFs: TServiceEnvioNFs;

implementation

// Sem {$R *.dfm} - servico nao tem form, nao tem DFM

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceEnvioNFs.Controller(CtrlCode);
end;

function TServiceEnvioNFs.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

constructor TServiceEnvioNFs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Propriedades do servico - sem DFM, tudo aqui
  Name        := 'ServicoEnvioNFs';
  DisplayName := 'Servico Envio NFs - SEFIN Fortaleza';
  AllowPause  := False;
  AllowStop   := True;

  // Eventos conectados por codigo
  OnStart      := ServiceStart;
  OnStop       := ServiceStop;
  OnShutdown   := ServiceShutdown;
  OnExecute    := ServiceExecute;
  AfterInstall := ServiceAfterInstall;

  // Generico: <pasta_do_exe>\Config\NFSe_Servico.ini
  // Calculado no Create (thread principal) - seguro para ParamStr
  FIniPath := ExtractFilePath(ParamStr(0)) + SUBPASTA_CONFIG + NOME_INI_SERVICO;

  case FindCmdLineSwitch('DEBUG') of
    True : FIntervaloMs := INTERVALO_DEBUG_MS;
    False: FIntervaloMs := INTERVALO_NORMAL_MS;
  end;
end;

procedure TServiceEnvioNFs.GravarDescricaoRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    case Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, False) of
      True:
      begin
        Reg.WriteString('Description',
          'Servico de envio automatico de Notas Fiscais de Servico ' +
          'para SEFIN Fortaleza (GINFES v04).');
        Reg.CloseKey;
      end;
      False: ;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TServiceEnvioNFs.IniciarServico;
begin
  // Composition Root - tudo criado aqui no OnStart (thread do servico)
  FConfigModel           := TConfiguracaoModel.Create(FIniPath);
  FNotificadorModel      := TNotificadorModel.Create;
  FAgendamentoController := TAgendamentoController.Create(FConfigModel);

  FWorker := TWorkerThread.Create(
    FIntervaloMs,
    FAgendamentoController,
    FNotificadorModel
  );
  FWorker.Start;
end;

procedure TServiceEnvioNFs.PararServico;
begin
  case Assigned(FWorker) of
    True:
    begin
      FWorker.Parar;
      FWorker.WaitFor;      // FreeOnTerminate=False -> obrigatorio WaitFor
      FreeAndNil(FWorker);

      FAgendamentoController := nil;
      FNotificadorModel      := nil;
      FConfigModel           := nil;
    end;
    False: ;
  end;
end;

procedure TServiceEnvioNFs.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  try
    IniciarServico;
    Started := True;
  except
    on E: Exception do
      LogMessage('ERRO ao iniciar: ' + E.Message, EVENTLOG_ERROR_TYPE, 0, 1);
  end;
end;

procedure TServiceEnvioNFs.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  PararServico;
  Stopped := True;
end;

procedure TServiceEnvioNFs.ServiceShutdown(Sender: TService);
begin
  PararServico;
end;

procedure TServiceEnvioNFs.ServiceExecute(Sender: TService);
begin
  while not Terminated do
    ServiceThread.ProcessRequests(False);
end;

procedure TServiceEnvioNFs.ServiceAfterInstall(Sender: TService);
begin
  GravarDescricaoRegistry;
end;

end.
