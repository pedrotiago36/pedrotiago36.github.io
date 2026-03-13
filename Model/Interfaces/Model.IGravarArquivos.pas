unit Model.IGravarArquivos;

interface

uses
  Model.IConfiguracaoSistema;

type
  IGravarArquivos = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    procedure GravarIni(const AConfiguracao: IConfiguracaoSistema);
    procedure GravarRpsEnviado(const AConteudo: string; const AAno, AMes: Word);
    procedure GravarRpsErro(const AConteudo: string; const AAno, AMes: Word);
  end;

implementation

end.
