unit Model.IMonitorNotificacao;

interface

type
  { Callback chamado quando o usuario responde ao Toast }
  TCallbackRespostaNotificacao = reference to procedure(
    const AConfirmou: Boolean;
    const ANovoDia  : Integer);

  IMonitorNotificacao = interface
    ['{FA120001-B3C4-4D5E-8F90-ABCDEF012345}']
    procedure Iniciar;
    procedure Parar;
  end;

implementation

end.
