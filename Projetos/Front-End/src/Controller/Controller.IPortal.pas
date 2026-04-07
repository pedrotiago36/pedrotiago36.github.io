unit Controller.IPortal;

interface

uses
  Model.IAgendamento;

type
  IPortalController = interface
    ['{B2C3D4E5-F6A1-1234-BCDE-F567890A1234}']
    function ValidarCPF(const ACPF: string): Boolean;
    procedure RegistrarPreMatricula(const AAgendamento: IAgendamento);
    procedure PrepararPastaPai(const ACPF: string);
  end;

implementation

end.
