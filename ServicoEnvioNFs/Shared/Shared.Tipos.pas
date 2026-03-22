unit Shared.Tipos;

{
  ============================================================
  Shared.Tipos — Tipos compartilhados do ServicoEnvioNFs
  ============================================================
  Centraliza todos os records, enums e delegates usados pelas
  camadas Model, Controller, Service e View.

  Regra: nenhuma outra unit redefine tipos aqui declarados.
  ============================================================
}

interface

type

  { Modo de geracao dos XMLs, lido da secao [ModoEnvio] do .ini }
  TModoEnvio = (
    meIndividual,  { 1 RPS por arquivo XML }
    meLote         { Ate 50 RPS por arquivo XML }
  );

  { Dados de um RPS lidos da view vw_NFSe_GeracaoXML no SQL Server }
  TDadosRps = record
    NumeroLote               : string;   { Numero do lote de envio }
    Rps                      : string;   { Numero do RPS }
    Serie                    : string;   { Serie do RPS }
    DataEmissao              : TDateTime;{ Data de emissao }
    ValorServicos            : Currency; { Valor total dos servicos }
    IssRetido                : Currency; { Valor do ISS retido }
    ItemListaServico         : string;   { Codigo do item da lista de servicos }
    CodigoCnaeNovo           : string;   { Codigo CNAE (7 digitos) }
    CodigoTributacaoMunicipio: string;   { Codigo tributacao municipal (9 digitos) }
    Discriminacao            : string;   { Descricao do servico prestado }
    CodigoMunicipioGerador   : string;   { Codigo IBGE do municipio gerador }
    NBS                      : string;   { Nomenclatura Brasileira de Servicos }
    CpfTomador               : string;   { CPF do tomador }
    Tomador                  : string;   { Nome / Razao Social do tomador }
    EnderecoTomador          : string;   { Logradouro do tomador }
    BairroTomador            : string;   { Bairro do tomador }
    CepTomador               : string;   { CEP do tomador }
    CodigoIndicadorOperacao  : string;   { Indicador operacao IBS/CBS (6 digitos) }
    CST                      : string;   { Codigo de Situacao Tributaria }
    cClassTrib               : string;   { Codigo de Classificacao Tributaria }
  end;

  { Lista dinamica de TDadosRps retornada pelo repositorio }
  TListaDadosRps = TArray<TDadosRps>;

  { Resultado da geracao de um arquivo XML pelo montador }
  TResultadoXml = record
    Sucesso        : Boolean; { True se gerado com sucesso }
    CaminhoArquivo : string;  { Caminho completo do arquivo gerado }
    MensagemErro   : string;  { Descricao do erro quando Sucesso = False }
    QuantidadeRps  : Integer; { Quantidade de RPS no arquivo }
  end;

  { Configuracoes de envio lidas do NFSe_Servico.ini }
  TDadosConfiguracaoEnvio = record
    { [Banco] }
    Servidor          : string;     { IP ou hostname do SQL Server }
    Banco             : string;     { Nome do banco de dados }
    Login             : string;     { Usuario do banco }
    Senha             : string;     { Senha do banco }
    { [Emitente] }
    CnpjUnidade       : string;     { CNPJ da unidade emissora }
    InscricaoMunicipal: string;     { Inscricao Municipal }
    { [Diretorios] }
    DiretorioBase     : string;     { Pasta raiz para salvar os XMLs }
    { [ModoEnvio] }
    ModoEnvio         : TModoEnvio; { Individual (1 RPS/XML) ou Lote (50 RPS/XML) }
    { Calculado em runtime }
    Mes               : Integer;    { Mes de referencia }
    Ano               : Integer;    { Ano de referencia }
  end;

  {
    Delegate de progresso — reporta cada passo do processamento
    sem acoplamento entre camadas.
    AMensagem : descricao do passo executado
    AErro     : True indica mensagem de erro
  }
  TCallbackProgresso = reference to procedure(
    const AMensagem: string;
    const AErro    : Boolean);

implementation

end.
