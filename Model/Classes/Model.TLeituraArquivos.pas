unit Model.TLeituraArquivos;

interface

uses
  Model.ILeituraArquivos,
  System.Generics.Collections;

type
  TLeituraArquivos = class(TInterfacedObject, ILeituraArquivos)
  private
    function MontarCaminho(const ABase: string;
      const AAno, AMes: Word; const ATipo: string): string;
    function ParsearLinha(const ALinha: string): TRegistroRps;
    procedure CarregarDeArquivo(const ACaminho, ASituacao: string;
      const ALista: TListaRps);
  public
    procedure CarregarRpsEnviadas(const ACaminhoBase: string;
      const AAno, AMes: Word; const ALista: TListaRps);
    procedure CarregarRpsCanceladas(const ACaminhoBase: string;
      const AAno, AMes: Word; const ALista: TListaRps);
    function ContarRegistros(const ACaminhoBase: string;
      const AAno, AMes: Word; const ASituacao: string): Integer;
    class function Criar: ILeituraArquivos;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes;

const
  SIT_ENVIADA   = 'ENVIADA';
  SIT_CANCELADA = 'CANCELADA';
  ARQ_ENVIADOS  = 'enviados';
  ARQ_ERRO      = 'erro';

  SITUACOES: array[Boolean] of string = (SIT_CANCELADA, SIT_ENVIADA);
  ARQUIVOS  : array[Boolean] of string = (ARQ_ERRO,     ARQ_ENVIADOS);

class function TLeituraArquivos.Criar: ILeituraArquivos;
begin
  Result := TLeituraArquivos.Create;
end;

function TLeituraArquivos.MontarCaminho(const ABase: string;
  const AAno, AMes: Word; const ATipo: string): string;
begin
  Result := TPath.Combine(
    TPath.Combine(ABase,
      Format('%d\%s', [AAno, FormatFloat('00', AMes)])),
    Format('rps_%s_%s_%s.txt',
      [ATipo, FormatFloat('0000', AAno), FormatFloat('00', AMes)]));
end;

function TLeituraArquivos.ParsearLinha(const ALinha: string): TRegistroRps;
var
  P: TArray<string>;
  N: Integer;
begin
  Result           := Default(TRegistroRps);
  Result.LinhaOriginal := ALinha;
  P := ALinha.Split(['|']);
  N := Length(P);

  case N > 0 of True: Result.NumeroRps         := P[0]; end;
  case N > 1 of True: Result.SerieRps           := P[1]; end;
  case N > 2 of True: Result.DataEmissao        := P[2]; end;
  case N > 3 of True: Result.Tomador            := P[3]; end;
  case N > 4 of True: Result.ValorServico       := P[4]; end;
  case N > 5 of True: Result.NumeroNFSe         := P[5]; end;
  case N > 6 of True: Result.CodigoVerificacao  := P[6]; end;
  case N > 7 of True: Result.Situacao           := P[7]; end;
  case N > 8 of True: Result.MotivoCancel       := P[8]; end;
end;

procedure TLeituraArquivos.CarregarDeArquivo(
  const ACaminho, ASituacao: string; const ALista: TListaRps);
var
  LLinhas: TStringList;
  LLinha : string;
  LReg   : TRegistroRps;
begin
  case TFile.Exists(ACaminho) of
    False: Exit;
  end;

  LLinhas := TStringList.Create;
  try
    LLinhas.LoadFromFile(ACaminho, TEncoding.UTF8);
    for LLinha in LLinhas do
      case LLinha.Trim.IsEmpty of
        False: begin
          LReg          := ParsearLinha(LLinha.Trim);
          LReg.Situacao := ASituacao;
          ALista.Add(LReg);
        end;
      end;
  finally
    LLinhas.Free;
  end;
end;

procedure TLeituraArquivos.CarregarRpsEnviadas(const ACaminhoBase: string;
  const AAno, AMes: Word; const ALista: TListaRps);
begin
  CarregarDeArquivo(
    MontarCaminho(ACaminhoBase, AAno, AMes, ARQ_ENVIADOS),
    SIT_ENVIADA, ALista);
end;

procedure TLeituraArquivos.CarregarRpsCanceladas(const ACaminhoBase: string;
  const AAno, AMes: Word; const ALista: TListaRps);
begin
  CarregarDeArquivo(
    MontarCaminho(ACaminhoBase, AAno, AMes, ARQ_ERRO),
    SIT_CANCELADA, ALista);
end;

function TLeituraArquivos.ContarRegistros(const ACaminhoBase: string;
  const AAno, AMes: Word; const ASituacao: string): Integer;
var
  LLista  : TListaRps;
  LEhEnvio: Boolean;
begin
  LLista   := TListaRps.Create;
  LEhEnvio := ASituacao = SIT_ENVIADA;
  try
    CarregarDeArquivo(
      MontarCaminho(ACaminhoBase, AAno, AMes, ARQUIVOS[LEhEnvio]),
      SITUACOES[LEhEnvio], LLista);
    Result := LLista.Count;
  finally
    LLista.Free;
  end;
end;

end.
