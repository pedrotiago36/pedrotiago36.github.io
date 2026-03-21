unit Model.IConfiguracaoEnvio;

interface

uses
  Shared.Tipos;

type
  IConfiguracaoEnvio = interface
    ['{A1B2C3D4-E5F6-0001-ABCD-EF1234567890}']
    procedure Atualizar(const ADados: TDadosConfiguracaoEnvio);
    procedure PreencherDados(out ADados: TDadosConfiguracaoEnvio);
  end;

implementation

end.
