unit Model.IAgendamentoPainel;

interface

type
  IAgendamentoPainel = interface
    ['{F2A3B4C5-D6E7-8901-BCDE-F12345678901}']
    function CPF: string;
    function DataAgendamento: string;
    function DataAtualizacao: string;
    function DataAssinatura: string;
    function Status: string;
    function ContratoStatus: string;
    function ToJSON: string;
  end;

implementation

end.
