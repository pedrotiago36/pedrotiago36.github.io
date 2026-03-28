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
  Controller.TLoginController in '..\src\Controller\Classe\Controller.TLoginController.pas',
  Model.IMenuItem in '..\src\Model\Interface\Model.IMenuItem.pas',
  Model.TMenuTree in '..\src\Model\Classe\Model.TMenuTree.pas',
  Controller.IMainController in '..\src\Controller\Interface\Controller.IMainController.pas',
  Controller.TMainController in '..\src\Controller\Classe\Controller.TMainController.pas',
  View.IFrmPrincipal in '..\src\View\View.IFrmPrincipal.pas',
  View.FrmPrincipal in '..\src\View\View.FrmPrincipal.pas' {FrmPrincipal: TUniForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
