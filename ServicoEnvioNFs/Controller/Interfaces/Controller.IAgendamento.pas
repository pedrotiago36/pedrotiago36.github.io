unit Controller.IAgendamento;

interface

uses
  Shared.Tipos;

type

  IAgendamentoController = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function  VerificarNecessidadeNotificacao: TResultadoAgendamento;
    procedure ConfirmarEnvio;
    procedure AlterarDiaEnvio(NovoDia: Integer);
  end;

implementation

end.
