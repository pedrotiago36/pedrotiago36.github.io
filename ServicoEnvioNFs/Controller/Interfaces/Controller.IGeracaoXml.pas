unit Controller.IGeracaoXml;

interface

uses
  Shared.Tipos,
  Model.IConfiguracaoEnvio,
  Model.IMontadorXml;

type
  IGeracaoXml = interface
    ['{D4E5F6A7-B8C9-0004-DEFA-456789012345}']
    procedure Executar(
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      out   AResultados : TArray<TResultadoXml>);
  end;

implementation

end.
