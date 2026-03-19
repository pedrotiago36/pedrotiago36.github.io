unit Model.IAgendamentoNotificacao;

interface

type
  { Callback disparado quando falta 1 dia para o DiaEnvio }
  TCallbackAgendamento = reference to procedure(
    const ADiaEnvio: Integer;
    const AMes     : Integer;
    const AAno     : Integer;
    const ADataFmt : string);  { data formatada dd/mm/yyyy }

  IAgendamentoNotificacao = interface
    ['{D4E5F6A7-B8C9-0123-DEFA-456789012345}']
    procedure Iniciar(const ACaminhoIni: string;
      const ACallback: TCallbackAgendamento);
    procedure Parar;
  end;

implementation

end.
