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
  Model.IPerfil              in '..\src\Model\Interface\Model.IPerfil.pas',
  Model.TPerfil              in '..\src\Model\Classe\Model.TPerfil.pas',
  Controller.IPerfilController in '..\src\Controller\Interface\Controller.IPerfilController.pas',
  Controller.TPerfilController in '..\src\Controller\Classe\Controller.TPerfilController.pas',
  Model.IUsuario               in '..\src\Model\Interface\Model.IUsuario.pas',
  Model.TUsuario               in '..\src\Model\Classe\Model.TUsuario.pas',
  Controller.IUsuarioController in '..\src\Controller\Interface\Controller.IUsuarioController.pas',
  Controller.TUsuarioController in '..\src\Controller\Classe\Controller.TUsuarioController.pas',
  Model.IPermissoes              in '..\src\Model\Interface\Model.IPermissoes.pas',
  Model.TPermissoes              in '..\src\Model\Classe\Model.TPermissoes.pas',
  Controller.IPermissoesController in '..\src\Controller\Interface\Controller.IPermissoesController.pas',
  Controller.TPermissoesController in '..\src\Controller\Classe\Controller.TPermissoesController.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
