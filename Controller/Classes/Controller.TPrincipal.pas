unit Controller.TPrincipal;

interface

uses
  Model.IConfiguracaoSistema,
  Model.IRecuperarArquivos,
  Model.ILeituraArquivos,
  Model.IEstatisticasUnidade,
  Model.TConfiguracaoSistema,
  Model.TRecuperarArquivos,
  Model.TLeituraArquivos,
  Model.TEstatisticasUnidade,
  Controller.IPrincipal,
  FireDAC.Comp.Client,
  System.DateUtils;

type
  TControllerPrincipal = class(TInterfacedObject)
  private
    FConfiguracao : IConfiguracaoSistema;
    FRecuperar    : IRecuperarArquivos;
    FLeitura      : ILeituraArquivos;
    FEstatisticas : IEstatisticasUnidade;
    FAnoAtual     : Word;
    FMesAtual     : Word;
    procedure CarregarConfiguracao;
    function DiretorioUnidade(const AUnidade: TNomeUnidade;
      const ATipo: string): string;
  public
    constructor Create;
    procedure Inicializar;
    procedure AtualizarCards;
    procedure ObterEstatisticas(out AEstatisticas: TArrayEstatisticas);
    procedure PreencherMemTable(const AMemTable: TFDMemTable;
      const AUnidade: TNomeUnidade; const ASituacao: string);
    procedure RecarregarConfiguracao;
    procedure ExecutarCancelarRps(const ANumeroRps, ANomeUnidade: string);
    procedure ExecutarBaixarDANFSe(const ANumeroRps: string);
    class function Criar: TControllerPrincipal;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Vcl.Forms,
  Vcl.Dialogs;

const
  SUBPASTAS: array[TNomeUnidade] of string = (
    'SEDE', 'UEQ', 'Varjota', 'SeisBocas');

  TIPOS_ARQUIVO: array[Boolean] of string = ('erro', 'enviados');

class function TControllerPrincipal.Criar: TControllerPrincipal;
begin
  Result := TControllerPrincipal.Create;
end;

constructor TControllerPrincipal.Create;
begin
  inherited Create;
  FAnoAtual     := YearOf(Now);
  FMesAtual     := MonthOf(Now);
  FConfiguracao := TConfiguracaoSistema.Criar;
  FRecuperar    := TRecuperarArquivos.Criar;
  FLeitura      := TLeituraArquivos.Criar;
  FEstatisticas := TEstatisticasUnidade.Criar(FConfiguracao, FLeitura);
end;

procedure TControllerPrincipal.CarregarConfiguracao;
var
  LBase, LTentativa, LConfig: string;
  I: Integer;
begin
  LConfig := '';
  LBase   := ExtractFilePath(ParamStr(0));

  for I := 0 to 5 do
  begin
    LTentativa := TPath.Combine(TPath.Combine(LBase, 'exe'), 'Config');
    case TFile.Exists(TPath.Combine(LTentativa, 'NFSe_Servico.ini')) of
      True: begin LConfig := LTentativa; Break; end;
    end;

    LTentativa := TPath.Combine(LBase, 'Config');
    case TFile.Exists(TPath.Combine(LTentativa, 'NFSe_Servico.ini')) of
      True: begin LConfig := LTentativa; Break; end;
    end;

    LBase := TPath.GetFullPath(TPath.Combine(LBase, '..'));
  end;

  case LConfig.IsEmpty of
    True: LConfig := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Config');
  end;

  FRecuperar.RecuperarIni(FConfiguracao, LConfig);
end;

procedure TControllerPrincipal.Inicializar;
begin
  CarregarConfiguracao;
end;

procedure TControllerPrincipal.RecarregarConfiguracao;
begin
  CarregarConfiguracao;
end;

procedure TControllerPrincipal.AtualizarCards;
begin
  FEstatisticas.Calcular(FAnoAtual, FMesAtual);
end;

procedure TControllerPrincipal.ObterEstatisticas(
  out AEstatisticas: TArrayEstatisticas);
begin
  FEstatisticas.PreencherEstatisticas(AEstatisticas);
end;

function TControllerPrincipal.DiretorioUnidade(const AUnidade: TNomeUnidade;
  const ATipo: string): string;
var
  LDados: TDadosConfiguracao;
  LBase : string;
begin
  FConfiguracao.PreencherDados(LDados);
  LBase := LDados.DiretorioRpsEnviados;
  case ATipo = 'erro' of
    True: LBase := LDados.DiretorioRpsErro;
  end;
  Result := TPath.Combine(LBase, SUBPASTAS[AUnidade]);
end;

procedure TControllerPrincipal.PreencherMemTable(
  const AMemTable: TFDMemTable;
  const AUnidade: TNomeUnidade; const ASituacao: string);
var
  LLista  : TListaRps;
  LReg    : TRegistroRps;
  LEhEnvio: Boolean;
begin
  LLista   := TListaRps.Create;
  LEhEnvio := ASituacao = 'ENVIADA';
  try
    case LEhEnvio of
      True : FLeitura.CarregarRpsEnviadas(
               DiretorioUnidade(AUnidade, TIPOS_ARQUIVO[True]),
               FAnoAtual, FMesAtual, LLista);
      False: FLeitura.CarregarRpsCanceladas(
               DiretorioUnidade(AUnidade, TIPOS_ARQUIVO[False]),
               FAnoAtual, FMesAtual, LLista);
    end;

    AMemTable.DisableControls;
    try
      AMemTable.EmptyDataSet;
      for LReg in LLista do
      begin
        AMemTable.Append;
        AMemTable.FieldByName('NumeroRps').AsString      := LReg.NumeroRps;
        AMemTable.FieldByName('SerieRps').AsString       := LReg.SerieRps;
        AMemTable.FieldByName('DataEmissao').AsString    := LReg.DataEmissao;
        AMemTable.FieldByName('Tomador').AsString        := LReg.Tomador;
        AMemTable.FieldByName('ValorServico').AsString   := LReg.ValorServico;
        AMemTable.FieldByName('NumeroNFSe').AsString     := LReg.NumeroNFSe;
        AMemTable.FieldByName('CodVerificacao').AsString := LReg.CodigoVerificacao;
        AMemTable.FieldByName('Situacao').AsString       := LReg.Situacao;
        case LEhEnvio of
          True: begin
            AMemTable.FieldByName('AcaoCancelar').AsString := 'Cancelar';
            AMemTable.FieldByName('AcaoDANFSe').AsString   := 'Baixar';
          end;
        end;
        AMemTable.Post;
      end;
    finally
      AMemTable.EnableControls;
    end;
  finally
    LLista.Free;
  end;
end;

procedure TControllerPrincipal.ExecutarCancelarRps(
  const ANumeroRps, ANomeUnidade: string);
begin
  ShowMessage('Cancelar RPS ' + ANumeroRps + ' | Unidade: ' + ANomeUnidade);
end;

procedure TControllerPrincipal.ExecutarBaixarDANFSe(const ANumeroRps: string);
begin
  ShowMessage('Baixando DANFE da RPS ' + ANumeroRps);
end;

end.
