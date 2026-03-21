unit Model.IMontadorXml;

interface

uses
  Shared.Tipos;

type
  IMontadorXml = interface
    ['{C3D4E5F6-A7B8-0003-CDEF-345678901234}']
    procedure Montar(
      const ALista        : TListaDadosRps;
      const AConfiguracoes: TDadosConfiguracaoEnvio;
      const ACallbackLog  : TCallbackProgresso;
      out   AResultados   : TArray<TResultadoXml>);
  end;

implementation

end.
