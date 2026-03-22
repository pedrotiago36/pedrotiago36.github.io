unit Controller.TGeracaoXml;

{
  ============================================================
  Controller.TGeracaoXml — Orquestrador de geracao de XML
  ============================================================
  Responsabilidade UNICA: orquestrar o fluxo entre repositorio
  e montador, sem conter logica de negocio propria.

  Fluxo do metodo Executar:
    1. Repassa o callback de log para rastrear cada passo
    2. Chama FRepositorio.BuscarRps para obter a lista de RPS
    3. Chama FMontador.Montar para gerar os arquivos XML
    4. Retorna os resultados ao WorkerThread via out AResultados

  Composicao:
    FRepositorio : IRepositorioRps — criado via TRepositorioRps.Criar
    FMontador    : IMontadorXml    — criado via TMontadorXml.Criar
  ============================================================
}

interface

uses
  Controller.IGeracaoXml, { IGeracaoXml }
  Model.IConexaoDB,       { IConexaoDB }
  Model.IRepositorioRps,  { IRepositorioRps }
  Model.IMontadorXml,     { IMontadorXml }
  Shared.Tipos;           { TDadosConfiguracaoEnvio, TResultadoXml, TCallbackProgresso }

type
  TGeracaoXml = class(TInterfacedObject, IGeracaoXml)
  private
    { Repositorio responsavel por buscar os RPS no SQL Server }
    FRepositorio: IRepositorioRps;
    { Montador responsavel por gerar e salvar os arquivos XML }
    FMontador   : IMontadorXml;
  public
    { Create — inicializa repositorio e montador via suas factories }
    constructor Create;
    {
      Executar — orquestra busca de RPS e geracao de XMLs.
      Ver documentacao completa em Controller.IGeracaoXml.
    }
    procedure Executar(
      const AConexao    : IConexaoDB;
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      out   AResultados : TArray<TResultadoXml>);
    { Criar — factory que retorna a interface IGeracaoXml }
    class function Criar: IGeracaoXml;
  end;

implementation

uses
  System.SysUtils,        { Format }
  Model.TRepositorioRps,  { TRepositorioRps.Criar }
  Model.TMontadorXml;     { TMontadorXml.Criar }

class function TGeracaoXml.Criar: IGeracaoXml;
begin
  Result := TGeracaoXml.Create;
end;

constructor TGeracaoXml.Create;
begin
  inherited Create;
  { Composicao via interfaces — sem acoplamento a implementacoes }
  FRepositorio := TRepositorioRps.Criar;
  FMontador    := TMontadorXml.Criar;
end;

procedure TGeracaoXml.Executar(
  const AConexao    : IConexaoDB;
  const AConfig     : TDadosConfiguracaoEnvio;
  const ACallbackLog: TCallbackProgresso;
  out   AResultados : TArray<TResultadoXml>);
var
  { Lista de RPS retornada pelo repositorio }
  LLista: TListaDadosRps;
begin
  AResultados := [];

  { Passo 1: buscar RPS no banco para o mes/ano configurado }
  ACallbackLog(Format('Buscando RPS no banco — %d/%d...',
    [AConfig.Mes, AConfig.Ano]), False);

  FRepositorio.BuscarRps(
    AConexao,
    AConfig.Mes,
    AConfig.Ano,
    AConfig.CnpjUnidade,
    LLista);

  ACallbackLog(Format('%d RPS encontrados.', [Length(LLista)]), False);

  { Passo 2: montar e salvar os XMLs no diretorio configurado }
  FMontador.Montar(LLista, AConfig, ACallbackLog, AResultados);
end;

end.
