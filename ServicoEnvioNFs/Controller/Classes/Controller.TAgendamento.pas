unit Controller.TAgendamento;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Math,
  Controller.IAgendamento,
  Model.IConfiguracaoModel,
  Shared.Tipos;

type

  TAgendamentoController = class(TInterfacedObject, IAgendamentoController)
  strict private
    FConfigModel : IConfiguracaoModel;
    function DiasRestantesParaEnvio(Hoje: TDate; DiaEnvio: Integer): Integer;
  public
    constructor Create(ConfigModel: IConfiguracaoModel);
    function  VerificarNecessidadeNotificacao: TResultadoAgendamento;
    procedure ConfirmarEnvio;
    procedure AlterarDiaEnvio(NovoDia: Integer);
  end;

implementation

constructor TAgendamentoController.Create(ConfigModel: IConfiguracaoModel);
begin
  inherited Create;
  FConfigModel := ConfigModel;
end;

function TAgendamentoController.DiasRestantesParaEnvio(Hoje: TDate; DiaEnvio: Integer): Integer;
var
  Ano, Mes, Dia        : Word;
  DataEnvioMesAtual    : TDate;
  DataEnvioProximoMes  : TDate;
  UltimoDiaMes         : Integer;
  DataBase             : TDate;
begin
  DecodeDate(Hoje, Ano, Mes, Dia);

  // Garante que DiaEnvio nao ultrapassa o ultimo dia do mes atual
  UltimoDiaMes      := DaysInMonth(Hoje);
  DataEnvioMesAtual := EncodeDate(Ano, Mes, Min(DiaEnvio, UltimoDiaMes));

  // Data de envio do proximo mes
  DataEnvioProximoMes := IncMonth(EncodeDate(Ano, Mes, 1));
  UltimoDiaMes        := DaysInMonth(DataEnvioProximoMes);
  DataEnvioProximoMes := EncodeDate(
    YearOf(DataEnvioProximoMes),
    MonthOf(DataEnvioProximoMes),
    Min(DiaEnvio, UltimoDiaMes)
  );

  // Se data deste mes ainda nao passou, usa ela; senao usa proximo mes
  // Sem IF: IfThen retorna a data correta por comparacao
  DataBase := IfThen(DataEnvioMesAtual >= Hoje,
                     Double(DataEnvioMesAtual),
                     Double(DataEnvioProximoMes));

  Result := DaysBetween(DataBase, Hoje);
end;

function TAgendamentoController.VerificarNecessidadeNotificacao: TResultadoAgendamento;
var
  Config        : TConfigAgendamento;
  Hoje          : TDate;
  Ano, Mes, Dia : Word;
begin
  FConfigModel.Carregar;
  Config := FConfigModel.Agendamento;
  Hoje   := Date;

  DecodeDate(Hoje, Ano, Mes, Dia);

  Result.DiasRestantes  := DiasRestantesParaEnvio(Hoje, Config.DiaEnvio);
  Result.DiaEnvio       := Config.DiaEnvio;
  Result.MesReferencia  := Mes;
  Result.AnoReferencia  := Ano;
  Result.DeveNotificar  := (Result.DiasRestantes = Config.DiasAviso);
end;

procedure TAgendamentoController.ConfirmarEnvio;
begin
  // Usuario confirmou: servico mantem o dia cadastrado, nada a alterar
end;

procedure TAgendamentoController.AlterarDiaEnvio(NovoDia: Integer);
begin
  FConfigModel.AtualizarDiaEnvio(NovoDia);
end;

end.
