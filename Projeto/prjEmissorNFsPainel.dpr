program prjEmissorNFsPainel;

uses
  Vcl.Forms,
  Model.IConfiguracaoSistema in '..\Model\Interfaces\Model.IConfiguracaoSistema.pas',
  Model.IGravarArquivos in '..\Model\Interfaces\Model.IGravarArquivos.pas',
  Model.IRecuperarArquivos in '..\Model\Interfaces\Model.IRecuperarArquivos.pas',
  Model.TConfiguracaoSistema in '..\Model\Classes\Model.TConfiguracaoSistema.pas',
  Model.TGravarArquivos in '..\Model\Classes\Model.TGravarArquivos.pas',
  Model.TRecuperarArquivos in '..\Model\Classes\Model.TRecuperarArquivos.pas',
  View.Configuracao in '..\View\View.Configuracao.pas' {FrmConfiguracao},
  Model.IEstatisticasUnidade in '..\Model\Interfaces\Model.IEstatisticasUnidade.pas',
  Model.ILeituraArquivos in '..\Model\Interfaces\Model.ILeituraArquivos.pas',
  Model.TEstatisticasUnidade in '..\Model\Classes\Model.TEstatisticasUnidade.pas',
  Model.TLeituraArquivos in '..\Model\Classes\Model.TLeituraArquivos.pas',
  View.Principal in '..\View\View.Principal.pas' {FrmPrincipal},
  Controller.IPrincipal in '..\Controller\Classes\Controller.IPrincipal.pas',
  Controller.TPrincipal in '..\Controller\Interfaces\Controller.TPrincipal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmConfiguracao, FrmConfiguracao);
  Application.Run;
end.
