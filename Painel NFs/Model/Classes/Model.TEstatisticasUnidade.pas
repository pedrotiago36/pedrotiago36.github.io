unit Model.TEstatisticasUnidade;

interface

uses
  Model.IEstatisticasUnidade,
  Model.ILeituraArquivos,
  Model.IConfiguracaoSistema;

type
  TEstatisticasUnidade = class(TInterfacedObject, IEstatisticasUnidade)
  private
    FConfiguracao: IConfiguracaoSistema;
    FLeitura     : ILeituraArquivos;
    FDados       : TArrayEstatisticas;
    procedure InicializarNomes;
  public
    constructor Create(const AConfiguracao: IConfiguracaoSistema;
      const ALeitura: ILeituraArquivos);
    procedure Calcular(const AAno, AMes: Word);
    procedure PreencherEstatisticas(out AEstatisticas: TArrayEstatisticas);
    class function Criar(const AConfiguracao: IConfiguracaoSistema;
      const ALeitura: ILeituraArquivos): IEstatisticasUnidade;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils;

const
  NOMES: array[TNomeUnidade] of string = (
    'SEDE', 'UEQ', 'Varjota', 'Seis Bocas');

  SUBPASTAS: array[TNomeUnidade] of string = (
    'SEDE', 'UEQ', 'Varjota', 'SeisBocas');

class function TEstatisticasUnidade.Criar(
  const AConfiguracao: IConfiguracaoSistema;
  const ALeitura: ILeituraArquivos): IEstatisticasUnidade;
begin
  Result := TEstatisticasUnidade.Create(AConfiguracao, ALeitura);
end;

constructor TEstatisticasUnidade.Create(
  const AConfiguracao: IConfiguracaoSistema;
  const ALeitura: ILeituraArquivos);
begin
  inherited Create;
  FConfiguracao := AConfiguracao;
  FLeitura      := ALeitura;
  InicializarNomes;
end;

procedure TEstatisticasUnidade.InicializarNomes;
var
  U: TNomeUnidade;
begin
  for U := Low(TNomeUnidade) to High(TNomeUnidade) do
  begin
    FDados[U].NomeUnidade     := NOMES[U];
    FDados[U].TotalEnviadas   := 0;
    FDados[U].TotalCanceladas := 0;
  end;
end;

procedure TEstatisticasUnidade.Calcular(const AAno, AMes: Word);
var
  U     : TNomeUnidade;
  LDados: TDadosConfiguracao;
  LDirEnv, LDirErr: string;
begin
  FConfiguracao.PreencherDados(LDados);
  for U := Low(TNomeUnidade) to High(TNomeUnidade) do
  begin
    LDirEnv := TPath.Combine(LDados.DiretorioRpsEnviados, SUBPASTAS[U]);
    LDirErr := TPath.Combine(LDados.DiretorioRpsErro,     SUBPASTAS[U]);
    FDados[U].DiretorioBase   := LDirEnv;
    FDados[U].TotalEnviadas   := FLeitura.ContarRegistros(LDirEnv, AAno, AMes, 'ENVIADA');
    FDados[U].TotalCanceladas := FLeitura.ContarRegistros(LDirErr, AAno, AMes, 'CANCELADA');
  end;
end;

procedure TEstatisticasUnidade.PreencherEstatisticas(
  out AEstatisticas: TArrayEstatisticas);
begin
  AEstatisticas := FDados;
end;

end.
