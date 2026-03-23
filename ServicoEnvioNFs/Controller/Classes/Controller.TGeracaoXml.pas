unit Controller.TGeracaoXml;

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
    FRepositorio: IRepositorioRps;
    FMontador   : IMontadorXml;
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
  LConfig    : TDadosConfiguracaoEnvio;
  LLista     : TListaDadosRps;
  LResultados: TArray<TResultadoXml>;
  LIdx       : Integer;
begin
  LConfig                    := AConfig;
  LConfig.CnpjUnidade        := CNPJ_UNIDADE[AUnidade];
  LConfig.InscricaoMunicipal := IM_UNIDADE[AUnidade];

  ACallbackLog(Format('>>> Processando unidade: %s (CNPJ: %s)',
    [NOME_UNIDADE[AUnidade], CNPJ_UNIDADE[AUnidade]]), False);

  ACallbackLog(Format('Buscando RPS — %s — %d/%d...',
    [NOME_UNIDADE[AUnidade], LConfig.Mes, LConfig.Ano]), False);

  FRepositorio.BuscarRps(
    AConexao,
    LConfig.Mes,
    LConfig.Ano,
    LConfig.CnpjUnidade,
    ACallbackLog,
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

  FMontador.Montar(LLista, LConfig, ACallbackLog, LResultados);

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
  LUnidade: TUnidade;
begin
  AResultados := [];
  ACallbackLog('========================================', False);

  for LUnidade := Low(TUnidade) to High(TUnidade) do
    ProcessarUnidade(LUnidade, AConexao, AConfig, ACallbackLog, AResultados);

  ACallbackLog(Format('Ciclo completo. Total: %d XML(s) gerado(s).',
    [Length(AResultados)]), False);
  ACallbackLog('========================================', False);
end;

end.
