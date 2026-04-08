unit Controller.IPainelAgendamentos;

interface

uses
  System.Classes;

type
  IPainelController = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF0123456789}']
    procedure IniciarMonitoramento(const APastaAgendamentos: string;
                                   const AArquivoJSON      : string);
    procedure PararMonitoramento;
    procedure ValidarContrato(const ACPF: string);
    function  PastaBase: string;
  end;

implementation

end.
