unit Shared.Tipos;

{
  ============================================================
  Shared.Tipos — Tipos compartilhados do ServicoEnvioNFs
  ============================================================
  Centraliza records, enums, constantes e delegates.
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

  {
    Unidades emissoras do Colegio Batista Santos Dumont.
    CNPJs, IMs e bancos sao fixos — nunca mudam.
  }
  TUnidade = (
    unSede,       { SEDE       — ConAcd  — 07199060000124 — IM 007108 }
    unUEQ,        { UEQ        — Anexo1  — 07199060000396 — IM 158734 }
    unVarjota,    { Varjota    — Anexo3  — 07199060001015 — IM 213598 }
    unSeisBocas   { Seis Bocas — Anexo5  — 07199060001287 — IM 289767 }
  );

  { Dados de um RPS retornados pela procedure GravaXML }
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

  { Lista dinamica de TDadosRps retornada pelo repositorio }
  TListaDadosRps = TArray<TDadosRps>;

  { Resultado da geracao de um arquivo XML }
  TResultadoXml = record
    Sucesso        : Boolean;  { True se gerado com sucesso }
    CaminhoArquivo : string;   { Caminho completo do arquivo gerado }
    MensagemErro   : string;   { Descricao do erro quando Sucesso = False }
    QuantidadeRps  : Integer;  { Quantidade de RPS no arquivo }
    Unidade        : TUnidade; { Unidade a que pertence este XML }
  end;

  { Ambiente de envio — Homologacao ou Producao }
  TAmbiente = (amHomologacao, amProducao);

  { Configuracoes de envio lidas do NFSe_Servico.ini }
  TDadosConfiguracaoEnvio = record
    Servidor          : string;     { [Banco] IP ou hostname }
    Banco             : string;     { [Banco] Nome do banco — preenchido por unidade }
    Login             : string;     { [Banco] Usuario }
    Senha             : string;     { [Banco] Senha }
    CnpjUnidade       : string;     { Preenchido por unidade em runtime }
    InscricaoMunicipal: string;     { Preenchido por unidade em runtime }
    NomeUnidade       : string;     { Preenchido por unidade em runtime }
    DiretorioBase     : string;     { [Diretorios] Pasta raiz dos XMLs }
    ModoEnvio         : TModoEnvio; { [ModoEnvio] Individual ou Lote }
    Ambiente          : TAmbiente;  { [Ambiente] Homologacao ou Producao }
    ThreadAtiva       : Boolean;    { [Thread] Ativa=1 — FALSE para o servico }
    DiaEnvio          : Integer;    { [Config] DiaEnvio — dia do mes para Producao }
    Mes               : Integer;    { Mes de referencia (runtime) }
    Ano               : Integer;    { Ano de referencia (runtime) }
  end;

  { Delegate de progresso sem acoplamento entre camadas }
  TCallbackProgresso = reference to procedure(
    const AMensagem: string;
    const AErro    : Boolean);

const
  { Nomes das unidades — usados para criar as pastas }
  NOME_UNIDADE: array[TUnidade] of string = (
    'SEDE',        { unSede }
    'UEQ',         { unUEQ }
    'Varjota',     { unVarjota }
    'Seis Bocas'   { unSeisBocas }
  );

  { CNPJs fixos das 4 unidades }
  CNPJ_UNIDADE: array[TUnidade] of string = (
    '07199060000124',  { SEDE }
    '07199060000396',  { UEQ }
    '07199060001015',  { Varjota }
    '07199060001287'   { Seis Bocas }
  );

  { Inscricoes Municipais fixas das 4 unidades }
  IM_UNIDADE: array[TUnidade] of string = (
    '007108',  { SEDE }
    '158734',  { UEQ }
    '213598',  { Varjota }
    '289767'   { Seis Bocas }
  );

  {
    Nomes dos bancos de cada unidade no SQL Server.
    Usados na chamada: exec <Banco>.dbo.GravaXML ...
  }
  BANCO_UNIDADE: array[TUnidade] of string = (
    'ConAcd',  { SEDE }
    'Anexo1',  { UEQ }
    'Anexo3',  { Varjota }
    'Anexo5'   { Seis Bocas }
  );

  { Subpastas criadas dentro de cada pasta de dia/unidade }
  PASTA_ENVIADAS   = 'Enviadas';   { DANFEs dos arquivos enviados com sucesso }
  PASTA_CANCELADAS = 'Canceladas'; { Comprovantes de cancelamento }
  PASTA_ERRO       = 'Erro';       { XMLs que retornaram erro do servidor SEFIN }

implementation

end.
