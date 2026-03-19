unit Model.TAgendamentoNotificacao;

{
  Responsabilidade:
    - Le [Config] DiaEnvio do NFSe_Servico.ini a cada 1 segundo
    - Calcula quantos dias faltam para o proximo DiaEnvio
    - Quando DiasRestantes = 1, dispara o callback UMA vez por dia
    - Nao exibe nada diretamente — apenas notifica via callback (MVC puro)
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Model.IAgendamentoNotificacao;

type
  TAgendamentoNotificacao = class(TInterfacedObject, IAgendamentoNotificacao)
  private
    FThread       : TThread;
    FStop         : TEvent;
    FCaminhoIni   : string;
    FCallback     : TCallbackAgendamento;
    FDiaNotificado: Integer;  { evita repetir no mesmo dia }
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Iniciar(const ACaminhoIni: string;
                  const ACallback: TCallbackAgendamento);
    procedure   Parar;
    class function Criar: IAgendamentoNotificacao;
  end;

implementation

uses
  System.IniFiles,
  System.DateUtils;

{ ── Helpers de calculo ────────────────────────────────────────────────── }

function EhBissexto(const AAno: Integer): Boolean;
begin
  Result := (AAno mod 4 = 0) and
            ((AAno mod 100 <> 0) or (AAno mod 400 = 0));
end;

function DiasNoMes(const AMes, AAno: Integer): Integer;
const
  DIAS: array[1..12] of Integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  Result := DIAS[AMes];
  case (AMes = 2) and EhBissexto(AAno) of
    True: Result := 29;
  end;
end;

function DiasRestantes(const ADiaEnvio, ADiaAtual, AMesAtual,
  AAnoAtual: Integer): Integer;
var
  LDiasNoMes: Integer;
begin
  { DiaEnvio ainda nao chegou neste mes }
  case ADiaEnvio > ADiaAtual of
    True:
    begin
      Result := ADiaEnvio - ADiaAtual;
      Exit;
    end;
  end;

  { DiaEnvio ja passou ou e hoje — calcula para o proximo mes }
  LDiasNoMes := DiasNoMes(AMesAtual, AAnoAtual);
  Result := (LDiasNoMes - ADiaAtual) + ADiaEnvio;
end;

function ProximaDataEnvio(const ADiaEnvio, AMesAtual,
  AAnoAtual: Integer): TDateTime;
var
  LMes: Integer;
  LAno: Integer;
begin
  case ADiaEnvio > DayOf(Now) of
    True:
    begin
      LMes := AMesAtual;
      LAno := AAnoAtual;
    end;
    False:
    begin
      LMes := AMesAtual + 1;
      LAno := AAnoAtual;
      case LMes > 12 of
        True:
        begin
          LMes := 1;
          LAno := AAnoAtual + 1;
        end;
      end;
    end;
  end;
  Result := EncodeDate(LAno, LMes, ADiaEnvio);
end;

{ ── TAgendamentoNotificacao ─────────────────────────────────────────── }

class function TAgendamentoNotificacao.Criar: IAgendamentoNotificacao;
begin
  Result := TAgendamentoNotificacao.Create;
end;

constructor TAgendamentoNotificacao.Create;
begin
  inherited Create;
  FStop         := TEvent.Create(nil, True, False, '');
  FDiaNotificado := -1;
end;

destructor TAgendamentoNotificacao.Destroy;
begin
  Parar;
  FStop.Free;
  inherited;
end;

procedure TAgendamentoNotificacao.Parar;
begin
  case Assigned(FThread) of
    True:
    begin
      FStop.SetEvent;
      FThread.Terminate;
      FThread.WaitFor;
      FreeAndNil(FThread);
      FStop.ResetEvent;
    end;
  end;
end;

procedure TAgendamentoNotificacao.Iniciar(const ACaminhoIni: string;
  const ACallback: TCallbackAgendamento);
var
  LStop         : TEvent;
  LCaminhoIni   : string;
  LCallback     : TCallbackAgendamento;
  LDiaNotificado: PInteger;
begin
  FCaminhoIni := ACaminhoIni;
  FCallback   := ACallback;
  LStop       := FStop;
  LCaminhoIni := FCaminhoIni;
  LCallback   := FCallback;
  LDiaNotificado := @FDiaNotificado;

  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      LIni        : TMemIniFile;
      LDiaEnvio   : Integer;
      LDiaAtual   : Integer;
      LMesAtual   : Integer;
      LAnoAtual   : Integer;
      LDiasRest   : Integer;
      LProxData   : TDateTime;
      LDataFmt    : string;
    begin
      while LStop.WaitFor(1000) = wrTimeout do
      begin
        try
          LIni := TMemIniFile.Create(LCaminhoIni);
          try
            LDiaEnvio := LIni.ReadInteger('Config', 'DiaEnvio', 0);
          finally
            LIni.Free;
          end;

          case LDiaEnvio <= 0 of
            True: Continue;
          end;

          LDiaAtual := DayOf(Now);
          LMesAtual := MonthOf(Now);
          LAnoAtual := YearOf(Now);

          LDiasRest := DiasRestantes(LDiaEnvio, LDiaAtual,
                         LMesAtual, LAnoAtual);

          { Dispara apenas quando falta 1 dia e ainda nao notificou hoje }
          case (LDiasRest = 1) and (LDiaNotificado^ <> LDiaAtual) of
            True:
            begin
              LDiaNotificado^ := LDiaAtual;

              LProxData := ProximaDataEnvio(LDiaEnvio, LMesAtual, LAnoAtual);
              LDataFmt  := FormatDateTime('dd/mm/yyyy', LProxData);

              TThread.Queue(nil,
                procedure
                begin
                  LCallback(LDiaEnvio,
                    MonthOf(LProxData),
                    YearOf(LProxData),
                    LDataFmt);
                end);
            end;
          end;

        except
          { Ignora erros de leitura — tenta novamente no proximo ciclo }
        end;
      end;
    end);

  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

end.
