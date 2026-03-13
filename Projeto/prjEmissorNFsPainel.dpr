program prjEmissorNFsPainel;

uses
  Vcl.Forms,
  Model.IConfiguracaoSistema in '..\Model\Interfaces\Model.IConfiguracaoSistema.pas',
  Model.IGravarArquivos in '..\Model\Interfaces\Model.IGravarArquivos.pas',
  Model.IRecuperarArquivos in '..\Model\Interfaces\Model.IRecuperarArquivos.pas',
  Model.TConfiguracaoSistema in '..\Model\Classes\Model.TConfiguracaoSistema.pas',
  Model.TGravarArquivos in '..\Model\Classes\Model.TGravarArquivos.pas',
  Model.TRecuperarArquivos in '..\Model\Classes\Model.TRecuperarArquivos.pas',
  View.Configuracao in '..\View\View.Configuracao.pas' {FrmConfiguracao};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmConfiguracao, FrmConfiguracao);
  Application.Run;
end.
