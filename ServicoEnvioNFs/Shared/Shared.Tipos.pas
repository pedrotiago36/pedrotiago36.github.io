unit Shared.Tipos;

interface

type
  TModoEnvio = (meIndividual, meLote);

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

  TResultadoXml = record
    Sucesso        : Boolean;
    CaminhoArquivo : string;
    MensagemErro   : string;
    QuantidadeRps  : Integer;
  end;

  TDadosConfiguracaoEnvio = record
    Servidor          : string;
    Banco             : string;
    Login             : string;
    Senha             : string;
    CnpjUnidade       : string;
    InscricaoMunicipal: string;
    DiretorioBase     : string;
    ModoEnvio         : TModoEnvio;
    Mes               : Integer;
    Ano               : Integer;
  end;

  TCallbackProgresso = reference to procedure(
    const AMensagem: string;
    const AErro    : Boolean);

implementation

end.
