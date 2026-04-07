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
    // Retorna 'original|nome.pdf', 'pendente|nome.pdf', 'validado|nome.pdf' ou 'sem_contrato|'
    function ConsultarContrato(const ACPF: string): string;
  end;

implementation

end.
