unit Shared.Tipos;

{
  Tipos compartilhados entre todas as camadas do servico de emissao NFSe.
}

interface

type
  { Modo de envio configurado no .ini }
  TModoEnvio = (meIndividual, meLote);

  { Dados de um RPS lidos do banco }
  TDadosRps = record
    NumeroLote               : string;
    Rps                      : string;
    Serie                    : string;
    DataEmissao              : TDateTime;
    ValorServicos            : Currency;
    IssRetido                : Currency;
    ItemListaServico         : string;
    CodigoCnaeNovo           : string;
    CodigoTributacaoMunicipio: string;
    Discriminacao            : string;
    CodigoMunicipioGerador   : string;
    NBS                      : string;
    CpfTomador               : string;
    Tomador                  : string;
    EnderecoTomador          : string;
    BairroTomador            : string;
    CepTomador               : string;
    CodigoIndicadorOperacao  : string;
    CST                      : string;
    cClassTrib               : string;
  end;

  TListaDadosRps = TArray<TDadosRps>;

  { Resultado da montagem de um XML }
  TResultadoXml = record
    Sucesso        : Boolean;
    CaminhoArquivo : string;
    MensagemErro   : string;
    QuantidadeRps  : Integer;
  end;

implementation

end.
