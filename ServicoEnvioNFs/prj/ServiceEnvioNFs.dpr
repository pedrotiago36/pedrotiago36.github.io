program ServiceEnvioNFs;

uses
  Vcl.SvcMgr,
  View.DM in '..\View\View.DM.pas' {Service1: TService},
  Shared.Tipos in '..\Shared\Shared.Tipos.pas',
  Model.TConfiguracaoEnvio in '..\Model\Classes\Model.TConfiguracaoEnvio.pas',
  Model.TMontadorXml in '..\Model\Classes\Model.TMontadorXml.pas',
  Model.TRepositorioRps in '..\Model\Classes\Model.TRepositorioRps.pas',
  Model.IConfiguracaoEnvio in '..\Model\Interfaces\Model.IConfiguracaoEnvio.pas',
  Model.IMontadorXml in '..\Model\Interfaces\Model.IMontadorXml.pas',
  Model.IRepositorioRps in '..\Model\Interfaces\Model.IRepositorioRps.pas',
  Controller.TGeracaoXml in '..\Controller\Classes\Controller.TGeracaoXml.pas',
  Controller.IGeracaoXml in '..\Controller\Interfaces\Controller.IGeracaoXml.pas';

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
  Application.CreateForm(TService1, Service1);
  Application.Run;
end.
