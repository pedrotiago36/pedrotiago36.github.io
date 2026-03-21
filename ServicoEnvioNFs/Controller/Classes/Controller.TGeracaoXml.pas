unit Controller.TGeracaoXml;

interface

uses
  Controller.IGeracaoXml,
  Model.IConexaoDB,
  Model.IRepositorioRps,
  Model.IMontadorXml,
  Model.TRepositorioRps,
  Model.TMontadorXml,
  Shared.Tipos;

type
  TGeracaoXml = class(TInterfacedObject, IGeracaoXml)
  private
    FRepositorio: IRepositorioRps;
    FMontador   : IMontadorXml;
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
  System.SysUtils;

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

procedure TGeracaoXml.Executar(
  const AConexao    : IConexaoDB;
  const AConfig     : TDadosConfiguracaoEnvio;
  const ACallbackLog: TCallbackProgresso;
  out   AResultados : TArray<TResultadoXml>);
var
  LLista: TListaDadosRps;
begin
  AResultados := [];

  ACallbackLog(Format('Buscando RPS no banco — %d/%d...', [AConfig.Mes, AConfig.Ano]), False);

  FRepositorio.BuscarRps(
    AConexao,
    AConfig.Mes,
    AConfig.Ano,
    AConfig.CnpjUnidade,
    LLista);

  ACallbackLog(Format('%d RPS encontrados.', [Length(LLista)]), False);

  FMontador.Montar(LLista, AConfig, ACallbackLog, AResultados);
end;

end.
