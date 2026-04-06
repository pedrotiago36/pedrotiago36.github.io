unit Model.TAgendamento;

interface

uses
  Model.IAgendamento,
  System.SysUtils;

type
  TAgendamento = class(TInterfacedObject, IAgendamento)
  private
    FCPF: string;
    FDataAgendamento: TDate;
  public
    constructor Create(const ACPF: string; const ADataAgendamento: TDate);
    function CPF: string;
    function DataAgendamento: TDate;
    function ToJSON: string;
  end;

implementation

constructor TAgendamento.Create(const ACPF: string; const ADataAgendamento: TDate);
begin
  inherited Create;
  FCPF := ACPF;
  FDataAgendamento := ADataAgendamento;
end;

function TAgendamento.CPF: string;
begin
  Result := FCPF;
end;

function TAgendamento.DataAgendamento: TDate;
begin
  Result := FDataAgendamento;
end;

function TAgendamento.ToJSON: string;
begin
  Result := Format(
    '{"cpf":"%s","data":"%s","timestamp":"%s","status":"pendente"}',
    [
      FCPF,
      FormatDateTime('dd/MM/yyyy', FDataAgendamento),
      FormatDateTime('dd/MM/yyyy HH:nn:ss', Now)
    ]
  );
end;

end.
