unit Controller.IPrincipal;

interface

uses
  Model.IEstatisticasUnidade,
  FireDAC.Comp.Client;

type
  IControllerPrincipal = interface
    ['{F1A2B3C4-D5E6-7890-ABCD-123456789ABC}']
    procedure Inicializar;
    procedure AtualizarCards;
    procedure ObterEstatisticas(out AEstatisticas: TArrayEstatisticas);
    procedure PreencherMemTable(const AMemTable: TFDMemTable;
      const AUnidade: TNomeUnidade; const ASituacao: string);
    procedure RecarregarConfiguracao;
    procedure ExecutarCancelarRps(const ANumeroRps, ANomeUnidade: string);
    procedure ExecutarBaixarDANFSe(const ANumeroRps: string);
  end;

implementation

end.
