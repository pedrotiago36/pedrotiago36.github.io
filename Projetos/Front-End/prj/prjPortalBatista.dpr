program prjPortalBatista;    //Porta desse projeto : 8070

uses
  Forms,
  ServerModule in '..\src\Service\ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in '..\src\Service\MainModule.pas' {UniMainModule: TUniGUIMainModule},
  uPortaBatista in '..\src\View\uPortaBatista.pas' {MainForm: TUniForm},
  Model.IAgendamento in '..\src\Model\Model.IAgendamento.pas',
  Model.TAgendamento in '..\src\Model\Model.TAgendamento.pas',
  Controller.IPortal in '..\src\Controller\Controller.IPortal.pas',
  Controller.TPortal in '..\src\Controller\Controller.TPortal.pas',
  UnitEnviaEmail in '..\src\Service\UnitEnviaEmail.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
