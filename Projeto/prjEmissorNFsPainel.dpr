program prjEmissorNFsPainel;

uses
  Vcl.Forms,
  View.Principal in '..\View\View.Principal.pas' {FrmPrincipal},
  View.Configuracao in '..\View\View.Configuracao.pas' {FrmConfiguracao},
  Model.TConfiguracaoSistema in '..\Model\Classes\Model.TConfiguracaoSistema.pas',
  Model.TEstatisticasUnidade in '..\Model\Classes\Model.TEstatisticasUnidade.pas',
  Model.TGravarArquivos in '..\Model\Classes\Model.TGravarArquivos.pas',
  Model.TLeituraArquivos in '..\Model\Classes\Model.TLeituraArquivos.pas',
  Model.TRecuperarArquivos in '..\Model\Classes\Model.TRecuperarArquivos.pas',
  Model.IConfiguracaoSistema in '..\Model\Interfaces\Model.IConfiguracaoSistema.pas',
  Model.IEstatisticasUnidade in '..\Model\Interfaces\Model.IEstatisticasUnidade.pas',
  Model.IGravarArquivos in '..\Model\Interfaces\Model.IGravarArquivos.pas',
  Model.ILeituraArquivos in '..\Model\Interfaces\Model.ILeituraArquivos.pas',
  Model.IRecuperarArquivos in '..\Model\Interfaces\Model.IRecuperarArquivos.pas',
  Model.IMonitorNotificacao in '..\Model\Interfaces\Model.IMonitorNotificacao.pas',
  Model.TMonitorNotificacao in '..\Model\Classes\Model.TMonitorNotificacao.pas',
  Controller.TConfiguracaoView in '..\Controller\Classes\Controller.TConfiguracaoView.pas',
  Controller.TPrincipal in '..\Controller\Classes\Controller.TPrincipal.pas',
  Controller.IConfiguracaoView in '..\Controller\Interfaces\Controller.IConfiguracaoView.pas',
  Controller.IPrincipal in '..\Controller\Interfaces\Controller.IPrincipal.pas',
  View.Utils.Principal in '..\View\Utils\View.Utils.Principal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmConfiguracao, FrmConfiguracao);
  Application.Run;
end.
