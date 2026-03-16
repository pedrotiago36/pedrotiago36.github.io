program ServiceEnvioNFs;

uses
  Vcl.SvcMgr,
  View.TServiceEnvioNFs in '..\View\View.TServiceEnvioNFs.pas',
  Shared.Tipos in '..\Shared\Shared.Tipos.pas',
  Service in '..\Service\Service.pas' {Service1: TService},
  Service.TWorkerThread in '..\Service\Service.TWorkerThread.pas',
  Model.TConfiguracaoModel in '..\Model\Classes\Model.TConfiguracaoModel.pas',
  Model.TNotificadorModel in '..\Model\Classes\Model.TNotificadorModel.pas',
  Model.IConfiguracaoModel in '..\Model\Interfaces\Model.IConfiguracaoModel.pas',
  Model.INotificadorModel in '..\Model\Interfaces\Model.INotificadorModel.pas',
  Controller.TAgendamento in '..\Controller\Classes\Controller.TAgendamento.pas',
  Controller.IAgendamento in '..\Controller\Interfaces\Controller.IAgendamento.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TService1, Service1);
  Application.Run;
end.
