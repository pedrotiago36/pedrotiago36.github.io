unit Model.TNotificadorModel;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  Model.INotificadorModel,
  Shared.Tipos;

const
  PASTA_SINAIS = 'C:\ProgramData\ServicoEnvioNFs\';
  ARQ_SINAL    = PASTA_SINAIS + 'notificacao_pendente.json';
  ARQ_RESPOSTA = PASTA_SINAIS + 'resposta_notificacao.json';

type

  TNotificadorModel = class(TInterfacedObject, INotificadorModel)
  strict private
    procedure GarantirPasta;
    function  MontarSinalJSON(Resultado: TResultadoAgendamento): String;
    function  ExtrairIntDoJSON(Conteudo, Chave: String): Integer;
    procedure GravarSinal(Resultado: TResultadoAgendamento);
  public
    procedure Disparar(
      Resultado  : TResultadoAgendamento;
      OnResposta : TOnRespostaNotificacao
    );
    function RespostaPendente(OnResposta: TOnRespostaNotificacao): Boolean;
  end;

implementation

{ TNotificadorModel }

procedure TNotificadorModel.GarantirPasta;
begin
  TDirectory.CreateDirectory(PASTA_SINAIS);
end;

function TNotificadorModel.MontarSinalJSON(Resultado: TResultadoAgendamento): String;
begin
  Result := Format(
    '{' +
      '"dia_envio":%d,'      +
      '"mes":%d,'            +
      '"ano":%d,'            +
      '"dias_restantes":%d,' +
      '"mensagem":"As notas fiscais para este mes serao geradas no dia %d, confirma o Envio?"' +
    '}',
    [
      Resultado.DiaEnvio,
      Resultado.MesReferencia,
      Resultado.AnoReferencia,
      Resultado.DiasRestantes,
      Resultado.DiaEnvio
    ]
  );
end;

function TNotificadorModel.ExtrairIntDoJSON(Conteudo, Chave: String): Integer;
var
  Marcador  : String;
  PosInicio : Integer;
  PosFim    : Integer;
begin
  Marcador  := '"' + Chave + '":';
  PosInicio := Pos(Marcador, Conteudo) + Length(Marcador);
  PosFim    := PosInicio;

  while (PosFim <= Length(Conteudo)) and
        (Conteudo[PosFim] in ['0'..'9']) do
    Inc(PosFim);

  Result := StrToIntDef(Copy(Conteudo, PosInicio, PosFim - PosInicio), 0);
end;

procedure TNotificadorModel.GravarSinal(Resultado: TResultadoAgendamento);
begin
  TFile.WriteAllText(ARQ_SINAL, MontarSinalJSON(Resultado), TEncoding.UTF8);
end;

procedure TNotificadorModel.Disparar(
  Resultado  : TResultadoAgendamento;
  OnResposta : TOnRespostaNotificacao
);
begin
  GarantirPasta;

  case TFile.Exists(ARQ_SINAL) of
    False: GravarSinal(Resultado);
    True : ;  // ja existe sinal pendente, usuario ainda nao respondeu
  end;
end;

function TNotificadorModel.RespostaPendente(OnResposta: TOnRespostaNotificacao): Boolean;
var
  Conteudo  : String;
  Confirmou : Boolean;
  NovoDia   : Integer;
begin
  Result := TFile.Exists(ARQ_RESPOSTA);

  case Result of
    False: ;
    True :
    begin
      try
        Conteudo  := TFile.ReadAllText(ARQ_RESPOSTA, TEncoding.UTF8);
        Confirmou := Pos('"confirmou":true', Conteudo) > 0;
        NovoDia   := ExtrairIntDoJSON(Conteudo, 'novo_dia') * Ord(not Confirmou);

        TFile.Delete(ARQ_RESPOSTA);
        TFile.Delete(ARQ_SINAL);

        OnResposta(Confirmou, NovoDia);
      except
        on E: Exception do
          Result := False;
      end;
    end;
  end;
end;

end.
