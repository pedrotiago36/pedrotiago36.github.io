unit Service.TWorkerThread;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Controller.IAgendamento,
  Model.IConfiguracaoModel,
  Model.INotificadorModel,
  Model.TNotificadorModel,
  Shared.Tipos;

type

  TWorkerThread = class(TThread)
  strict private
    FStopEvent             : TEvent;
    FIntervaloMs           : Cardinal;
    FAgendamentoController : IAgendamentoController;
    FConfigModel           : IConfiguracaoModel;
    FNotificadorModel      : INotificadorModel;

    function  ThreadAtiva: Boolean;
    procedure ProcessarCiclo;
    procedure AplicarResposta(Confirmou: Boolean; NovoDia: Integer);
  protected
    procedure Execute; override;
  public
    constructor Create(
      IntervaloMs            : Cardinal;
      AgendamentoController  : IAgendamentoController;
      ConfigModel            : IConfiguracaoModel;
      NotificadorModel       : INotificadorModel
    );
    destructor Destroy; override;
    procedure Parar;
  end;

implementation

constructor TWorkerThread.Create(
  IntervaloMs            : Cardinal;
  AgendamentoController  : IAgendamentoController;
  ConfigModel            : IConfiguracaoModel;
  NotificadorModel       : INotificadorModel
);
begin
  inherited Create(True);
  FreeOnTerminate        := False;
  FStopEvent             := TEvent.Create(nil, True, False, '');
  FIntervaloMs           := IntervaloMs;
  FAgendamentoController := AgendamentoController;
  FConfigModel           := ConfigModel;
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

function TWorkerThread.ThreadAtiva: Boolean;
begin
  // Relê o .ini a cada ciclo — alteração em [Thread] Ativa
  // tem efeito imediato sem precisar reiniciar o serviço
  FConfigModel.Carregar;
  Result := FConfigModel.Thread.Ativa;
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
  // Verifica [Thread] Ativa antes de qualquer coisa
  // Ativa=0 -> ignora o ciclo inteiro
  case ThreadAtiva of
    False: Exit;
    True :
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
