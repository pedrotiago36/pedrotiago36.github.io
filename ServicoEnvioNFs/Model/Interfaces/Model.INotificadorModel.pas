unit Model.INotificadorModel;

interface

uses
  Shared.Tipos;

type

  TOnRespostaNotificacao = reference to procedure(
    Confirmou : Boolean;
    NovoDia   : Integer
  );

  INotificadorModel = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    procedure Disparar(
      Resultado  : TResultadoAgendamento;
      OnResposta : TOnRespostaNotificacao
    );
  end;

implementation

end.
