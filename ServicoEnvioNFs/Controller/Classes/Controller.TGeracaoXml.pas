unit Controller.TGeracaoXml;

{
  ============================================================
  Controller.TGeracaoXml — Orquestrador das 4 unidades
  ============================================================
  Responsabilidade: iterar pelas 4 unidades do colegio,
  para cada uma buscar os RPS no banco e gerar os XMLs.

  Hierarquia de pastas gerada:
    <DiretorioBase>\<Unidade>\<Mes>\<Dia>\Enviadas\
    <DiretorioBase>\<Unidade>\<Mes>\<Dia>\Canceladas\
    <DiretorioBase>\<Unidade>\<Mes>\<Dia>\Erro\

  Exemplo:
    C:\Monitor NFs-e - SEFIN\XML\SEDE\03\22\Enviadas\NFSe_001_001.xml
    C:\Monitor NFs-e - SEFIN\XML\UEQ\03\22\Enviadas\NFSe_001_001.xml
  ============================================================
}

interface

uses
  Controller.IGeracaoXml,
  Model.IConexaoDB,
  Model.IRepositorioRps,
  Model.IMontadorXml,
  Shared.Tipos;

type
  TGeracaoXml = class(TInterfacedObject, IGeracaoXml)
  private
    { Repositorio: busca RPS no SQL Server }
    FRepositorio: IRepositorioRps;
    { Montador: gera e salva os arquivos XML }
    FMontador   : IMontadorXml;

    {
      ProcessarUnidade — executa o ciclo completo de uma unidade.
      Preenche CnpjUnidade e InscricaoMunicipal na config,
      busca os RPS, monta os XMLs e acumula os resultados.
    }
    procedure ProcessarUnidade(
      const AUnidade    : TUnidade;
      const AConexao    : IConexaoDB;
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      var   AResultados : TArray<TResultadoXml>);

  public
    constructor Create;
    procedure Executar(
      const AConexao    : IConexaoDB;
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      out   AResultados : TArray<TResultadoXml>);
    class function Criar: IGeracaoXml;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Model.TRepositorioRps,
  Model.TMontadorXml;

class function TGeracaoXml.Criar: IGeracaoXml;
begin
  Result := TGeracaoXml.Create;
end;

constructor TGeracaoXml.Create;
begin
  inherited Create;
  FRepositorio := TRepositorioRps.Criar;
  FMontador    := TMontadorXml.Criar;
end;

procedure TGeracaoXml.ProcessarUnidade(
  const AUnidade    : TUnidade;
  const AConexao    : IConexaoDB;
  const AConfig     : TDadosConfiguracaoEnvio;
  const ACallbackLog: TCallbackProgresso;
  var   AResultados : TArray<TResultadoXml>);
var
  LConfig    : TDadosConfiguracaoEnvio; { Config especifica desta unidade }
  LLista     : TListaDadosRps;          { RPS encontrados no banco }
  LResultados: TArray<TResultadoXml>;   { XMLs gerados para esta unidade }
  LIdx       : Integer;                 { Indice para marcar a unidade }
begin
  { Copia a config base e preenche os dados desta unidade }
  LConfig                   := AConfig;
  LConfig.CnpjUnidade       := CNPJ_UNIDADE[AUnidade];
  LConfig.InscricaoMunicipal := IM_UNIDADE[AUnidade];

  ACallbackLog(Format('>>> Processando unidade: %s (CNPJ: %s)',
    [NOME_UNIDADE[AUnidade], CNPJ_UNIDADE[AUnidade]]), False);

  { Busca RPS no banco para esta unidade }
  ACallbackLog(Format('Buscando RPS — %s — %d/%d...',
    [NOME_UNIDADE[AUnidade], LConfig.Mes, LConfig.Ano]), False);

  FRepositorio.BuscarRps(
    AConexao,
    LConfig.Mes,
    LConfig.Ano,
    LConfig.CnpjUnidade,
    LLista);

  ACallbackLog(Format('%d RPS encontrados para %s.',
    [Length(LLista), NOME_UNIDADE[AUnidade]]), False);

  case Length(LLista) = 0 of
    True:
    begin
      ACallbackLog(Format('Nenhum RPS para %s — pulando.',
        [NOME_UNIDADE[AUnidade]]), False);
      Exit;
    end;
  end;

  { Monta os XMLs para esta unidade }
  FMontador.Montar(LLista, LConfig, ACallbackLog, LResultados);

  { Marca a unidade em cada resultado e acumula }
  for LIdx := 0 to Length(LResultados) - 1 do
    LResultados[LIdx].Unidade := AUnidade;

  AResultados := AResultados + LResultados;

  ACallbackLog(Format('<<< Unidade %s concluida. %d XML(s) gerado(s).',
    [NOME_UNIDADE[AUnidade], Length(LResultados)]), False);
end;

procedure TGeracaoXml.Executar(
  const AConexao    : IConexaoDB;
  const AConfig     : TDadosConfiguracaoEnvio;
  const ACallbackLog: TCallbackProgresso;
  out   AResultados : TArray<TResultadoXml>);
var
  LUnidade: TUnidade; { Iterador pelas 4 unidades }
begin
  AResultados := [];

  ACallbackLog('========================================', False);
  ACallbackLog(Format('Iniciando ciclo — %d/%d — Modo: %s',
    [AConfig.Mes, AConfig.Ano,
     NOME_UNIDADE[unSede]{ apenas para log do modo abaixo }]), False);

  { Itera pelas 4 unidades: SEDE, UEQ, Varjota, Seis Bocas }
  for LUnidade := Low(TUnidade) to High(TUnidade) do
    ProcessarUnidade(LUnidade, AConexao, AConfig, ACallbackLog, AResultados);

  ACallbackLog(Format('Ciclo completo. Total: %d XML(s) gerado(s).',
    [Length(AResultados)]), False);
  ACallbackLog('========================================', False);
end;

end.
