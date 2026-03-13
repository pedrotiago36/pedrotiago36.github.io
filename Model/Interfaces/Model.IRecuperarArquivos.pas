unit Model.IRecuperarArquivos;

interface

uses
  Model.IConfiguracaoSistema;

type
  IRecuperarArquivos = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    procedure RecuperarIni(const AConfiguracao: IConfiguracaoSistema;
      const ACaminhoIni: string);
  end;

implementation

end.
