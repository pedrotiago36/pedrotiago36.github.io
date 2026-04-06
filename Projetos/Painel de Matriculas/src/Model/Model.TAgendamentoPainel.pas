unit Model.TAgendamentoPainel;

interface

uses
  Model.IAgendamentoPainel;

type
  TAgendamentoPainel = class(TInterfacedObject, IAgendamentoPainel)
  private
    FCPF: string;
    FDataAgendamento: string;
    FDataAtualizacao: string;
    FDataAssinatura: string;
    FStatus: string;
  public
    constructor Create(
      const ACPF         : string;
      const ADataAgendamento : string;
      const ADataAtualizacao : string;
      const ADataAssinatura  : string;
      const AStatus          : string
    );
    function CPF: string;
    function DataAgendamento: string;
    function DataAtualizacao: string;
    function DataAssinatura: string;
    function Status: string;
    function ToJSON: string;
  end;

implementation

constructor TAgendamentoPainel.Create(
  const ACPF             : string;
  const ADataAgendamento : string;
  const ADataAtualizacao : string;
  const ADataAssinatura  : string;
  const AStatus          : string
);
begin
  inherited Create;
  FCPF              := ACPF;
  FDataAgendamento  := ADataAgendamento;
  FDataAtualizacao  := ADataAtualizacao;
  FDataAssinatura   := ADataAssinatura;
  FStatus           := AStatus;
end;

function TAgendamentoPainel.CPF: string;
begin
  Result := FCPF;
end;

function TAgendamentoPainel.DataAgendamento: string;
begin
  Result := FDataAgendamento;
end;

function TAgendamentoPainel.DataAtualizacao: string;
begin
  Result := FDataAtualizacao;
end;

function TAgendamentoPainel.DataAssinatura: string;
begin
  Result := FDataAssinatura;
end;

function TAgendamentoPainel.Status: string;
begin
  Result := FStatus;
end;

function TAgendamentoPainel.ToJSON: string;
begin
  Result :=
    '{"cpf":"'              + FCPF             + '",' +
    '"dataAgendamento":"'   + FDataAgendamento  + '",' +
    '"dataAtualizacao":"'   + FDataAtualizacao  + '",' +
    '"dataAssinatura":"'    + FDataAssinatura   + '",' +
    '"status":"'            + FStatus           + '",' +
    '"titulo":"PRE-MATRICULA"}';
end;

end.
