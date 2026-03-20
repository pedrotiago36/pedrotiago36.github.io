unit Model.IMontadorXml;

{
  Interface do montador de XML NFSe.
  Recebe lista de RPS e configuracao.
  Produz arquivos XML assinados nas pastas corretas.
}

interface

uses
  Shared.Tipos,
  Model.IConfiguracaoEnvio;

type
  TCallbackProgresso = reference to procedure(
    const AMensagem: string;
    const AErro    : Boolean);

  IMontadorXml = interface
    ['{C3D4E5F6-A7B8-0003-CDEF-345678901234}']
    procedure Montar(
      const ALista         : TListaDadosRps;
      const AConfiguracoes : TDadosConfiguracaoEnvio;
      const ACallbackLog   : TCallbackProgresso;
      out   AResultados    : TArray<TResultadoXml>);
  end;

implementation

end.
