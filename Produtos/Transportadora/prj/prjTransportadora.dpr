program prjTransportadora;

uses
  Forms,
  ServerModule in '..\Service\ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule   in '..\Service\MainModule.pas'   {UniMainModule: TUniGUIMainModule},
  View.FrmLogin in '..\src\View\View.FrmLogin.pas' {FrmLogin: TUniForm},
  View.ILoginView in '..\src\View\View.ILoginView.pas',
  Model.ILogin in '..\src\Model\Interface\Model.ILogin.pas',
  Model.TLogin in '..\src\Model\Classe\Model.TLogin.pas',
  Controller.ILoginController in '..\src\Controller\Interface\Controller.ILoginController.pas',
  Controller.TLoginController in '..\src\Controller\Classe\Controller.TLoginController.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
