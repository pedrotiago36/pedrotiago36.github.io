unit Service.TWorkerThread;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Controller.IAgendamento,
  Model.INotificadorModel,
  Model.TNotificadorModel,
  Shared.Tipos;

type

  TWorkerThread = class(TThread)
  strict private
    FStopEvent             : TEvent;
    FIntervaloMs           : Cardinal;
    FAgendamentoController : IAgendamentoController;
    FNotificadorModel      : INotificadorModel;

    procedure ProcessarCiclo;
    procedure AplicarResposta(Confirmou: Boolean; NovoDia: Integer);
  protected
    procedure Execute; override;
  public
    constructor Create(
      IntervaloMs            : Cardinal;
      AgendamentoController  : IAgendamentoController;
      NotificadorModel       : INotificadorModel
    );
    destructor Destroy; override;
    procedure Parar;
  end;

implementation

constructor TWorkerThread.Create(
  IntervaloMs            : Cardinal;
  AgendamentoController  : IAgendamentoController;
  NotificadorModel       : INotificadorModel
);
begin
  inherited Create(True);          // criado suspenso
  FreeOnTerminate        := False; // OBRIGATORIO — TService faz WaitFor
  FStopEvent             := TEvent.Create(nil, True, False, '');
  FIntervaloMs           := IntervaloMs;
  FAgendamentoController := AgendamentoController;
  FNotificadorModel      := NotificadorModel;
end;

destructor TWorkerThread.Destroy;
begin
  FStopEvent.Free;
  inherited;
end;

procedure TWorkerThread.Parar;
begin
  FStopEvent.SetEvent;
  Terminate;
end;

procedure TWorkerThread.AplicarResposta(Confirmou: Boolean; NovoDia: Integer);
begin
  case Confirmou of
    True : FAgendamentoController.ConfirmarEnvio;
    False: FAgendamentoController.AlterarDiaEnvio(NovoDia);
  end;
end;

procedure TWorkerThread.ProcessarCiclo;
var
  Resultado           : TResultadoAgendamento;
  NotificadorConcreto : TNotificadorModel;
begin
  NotificadorConcreto := FNotificadorModel as TNotificadorModel;

  // 1. Processa resposta pendente do usuario (se houver)
  NotificadorConcreto.RespostaPendente(
    procedure(Confirmou: Boolean; NovoDia: Integer)
    begin
      AplicarResposta(Confirmou, NovoDia);
    end
  );

  // 2. Verifica se deve notificar hoje
  Resultado := FAgendamentoController.VerificarNecessidadeNotificacao;

  // 3. Dispara notificacao se necessario
  case Resultado.DeveNotificar of
    True:
      FNotificadorModel.Disparar(
        Resultado,
        procedure(Confirmou: Boolean; NovoDia: Integer)
        begin
          AplicarResposta(Confirmou, NovoDia);
        end
      );
    False: ;
  end;
end;

procedure TWorkerThread.Execute;
var
  WaitResult: TWaitResult;
begin
  repeat
    WaitResult := FStopEvent.WaitFor(FIntervaloMs);

    case WaitResult of
      wrTimeout : ProcessarCiclo;
      wrSignaled: ;
    end;

  until (WaitResult = wrSignaled) or Terminated;
end;

end.
