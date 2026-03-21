unit Model.ILeituraIni;

interface

uses
  Shared.Tipos, Model.IConfiguracaoEnvio;

type
  ILeituraIni = interface
    ['{E5F6A7B8-C9D0-0005-EFA1-567890123456}']
    function ResolverCaminhoIni(const AExePath: string): string;
    function Carregar(
      const AExePath: string;
      const AMes    : Integer;
      const AAno    : Integer): TDadosConfiguracaoEnvio;
  end;

implementation

end.
