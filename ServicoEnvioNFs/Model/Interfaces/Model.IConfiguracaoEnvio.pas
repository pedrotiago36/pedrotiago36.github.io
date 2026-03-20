unit Model.IConfiguracaoEnvio;

{
  Interface de configuracao do envio NFSe.
  Lida do NFSe_Servico.ini pelo servico.
}

interface

uses
  Shared.Tipos;

type
  TDadosConfiguracaoEnvio = record
    CnpjUnidade          : string;
    InscricaoMunicipal   : string;
    DiretorioBase        : string;
    ModoEnvio            : TModoEnvio;
    MaxRpsPorLote        : Integer;
    StringConexaoBD      : string;
    Mes                  : Integer;
    Ano                  : Integer;
  end;

  IConfiguracaoEnvio = interface
    ['{A1B2C3D4-E5F6-0001-ABCD-EF1234567890}']
    procedure Atualizar(const ADados: TDadosConfiguracaoEnvio);
    procedure PreencherDados(out ADados: TDadosConfiguracaoEnvio);
  end;

implementation

end.
