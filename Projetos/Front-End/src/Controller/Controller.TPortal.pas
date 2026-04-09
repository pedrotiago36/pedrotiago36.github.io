unit Controller.TPortal;

interface

uses
  Controller.IPortal,
  Model.IAgendamento,
  System.SysUtils,
  System.Classes,
  System.IOUtils;

type
  TPortalController = class(TInterfacedObject, IPortalController)
  private
    FPastaAgendamentos: string;
    function ObterPastaAgendamentos: string;
    function ObterDataCriacaoOriginal(const AArquivo: string): string;
    function LimparCPF(const ACPF: string): string;
  public
    constructor Create;
    function ValidarCPF(const ACPF: string): Boolean;
    procedure RegistrarPreMatricula(const AAgendamento: IAgendamento);
    procedure PrepararPastaPai(const ACPF: string);
    function ConsultarContrato(const ACPF: string): string;
  end;

implementation

constructor TPortalController.Create;
begin
  inherited Create;
  FPastaAgendamentos := ObterPastaAgendamentos;
end;

function TPortalController.ObterPastaAgendamentos: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'agendamentos');
  TDirectory.CreateDirectory(Result);
end;

function TPortalController.ObterDataCriacaoOriginal(const AArquivo: string): string;
var
  LLinhas: TStringList;
  LPrefixo: string;
  LCands: array[0..1] of string;
  I: Integer;
begin
  Result := '';
  LPrefixo := 'Data do Agendamento : ';
  LLinhas := TStringList.Create;
  try
    case Ord(TFile.Exists(AArquivo)) of
      1:
        begin
          LLinhas.LoadFromFile(AArquivo, TEncoding.UTF8);
          for I := 0 to LLinhas.Count - 1 do
          begin
            LCands[0] := Result;
            LCands[1] := Copy(LLinhas[I], Length(LPrefixo) + 1, MaxInt);
            Result := LCands[Ord(Pos(LPrefixo, LLinhas[I]) = 1)];
          end;
        end;
    end;
  finally
    LLinhas.Free;
  end;
end;

function TPortalController.ValidarCPF(const ACPF: string): Boolean;
var
  LDigitos: string;
  LSoma, LResto, LDigito1, LDigito2, I: Integer;
  C: Char;
begin
  Result := False;
  try
    LDigitos := '';
    for C in ACPF do
      case C of
        '0'..'9': LDigitos := LDigitos + C;
      end;

    LSoma := 0;
    for I := 1 to 9 do
      LSoma := LSoma + (Ord(LDigitos[I]) - Ord('0')) * (11 - I);
    LResto := 11 - (LSoma mod 11);
    LDigito1 := LResto * Ord(LResto <= 9);

    LSoma := 0;
    for I := 1 to 10 do
      LSoma := LSoma + (Ord(LDigitos[I]) - Ord('0')) * (12 - I);
    LResto := 11 - (LSoma mod 11);
    LDigito2 := LResto * Ord(LResto <= 9);

    Result := (Length(LDigitos) = 11) and
              (LDigito1 = (Ord(LDigitos[10]) - Ord('0'))) and
              (LDigito2 = (Ord(LDigitos[11]) - Ord('0')));
  except
    Result := False;
  end;
end;

function TPortalController.LimparCPF(const ACPF: string): string;
begin
  Result := StringReplace(
    StringReplace(ACPF, '.', '', [rfReplaceAll]),
    '-', '', [rfReplaceAll]);
end;

procedure TPortalController.PrepararPastaPai(const ACPF: string);
var
  LCPFLimpo       : string;
  LPastaPai       : string;
  LPastaOriginal  : string;
  LPastaAssinado  : string;
  LOrigemContrato : string;
  LDestinoContrato: string;
begin
  LCPFLimpo := LimparCPF(ACPF);

  LPastaPai := TPath.Combine(ExtractFilePath(ParamStr(0)), LCPFLimpo);
  TDirectory.CreateDirectory(LPastaPai);

  LPastaOriginal := TPath.Combine(LPastaPai, 'ContratoOriginal');
  LPastaAssinado := TPath.Combine(LPastaPai, 'ContratoAssinado');
  TDirectory.CreateDirectory(LPastaOriginal);
  TDirectory.CreateDirectory(LPastaAssinado);

  // Copia o template da raiz do EXE — só se destino ainda não existe (CPF novo)
  LOrigemContrato  := TPath.Combine(ExtractFilePath(ParamStr(0)), 'ContratoMatricula.pdf');
  LDestinoContrato := TPath.Combine(LPastaOriginal, 'ContratoMatricula.pdf');

  if TFile.Exists(LOrigemContrato) and not TFile.Exists(LDestinoContrato) then
    TFile.Copy(LOrigemContrato, LDestinoContrato);
end;

function TPortalController.ConsultarContrato(const ACPF: string): string;
var
  LCPFLimpo  : string;
  LPastaPai  : string;
  LPastaAss  : string;
  LPastaOrig : string;
  LArqAss    : string;
  LArqOrig   : string;
  LArqValid  : string;
begin
  Result    := 'sem_contrato|';
  LCPFLimpo := LimparCPF(ACPF);
  LPastaPai  := TPath.Combine(ExtractFilePath(ParamStr(0)), LCPFLimpo);
  LPastaAss  := TPath.Combine(LPastaPai, 'ContratoAssinado');
  LPastaOrig := TPath.Combine(LPastaPai, 'ContratoOriginal');

  // 1) ContratoAssinado tem PDF?
  LArqAss := TPath.Combine(LPastaAss, 'ContratoMatricula.pdf');
  if TFile.Exists(LArqAss) then
  begin
    LArqValid := TPath.Combine(LPastaAss, '_VALIDADO');
    if TFile.Exists(LArqValid) then
      Result := 'validado|ContratoMatricula.pdf'
    else
      Result := 'pendente|ContratoMatricula.pdf';
    Exit;
  end;

  // 2) ContratoOriginal tem PDF?
  LArqOrig := TPath.Combine(LPastaOrig, 'ContratoMatricula.pdf');
  if TFile.Exists(LArqOrig) then
  begin
    Result := 'original|ContratoMatricula.pdf';
    Exit;
  end;
end;

procedure TPortalController.RegistrarPreMatricula(const AAgendamento: IAgendamento);
var
  LArquivo: string;
  LWriter: TStreamWriter;
  LDataCriacao, LDataCriacaoArq: string;
  LCPFLimpo: string;
  LDatas: array[0..1] of string;
begin
  LCPFLimpo := LimparCPF(AAgendamento.CPF);

  LArquivo := TPath.Combine(FPastaAgendamentos, LCPFLimpo + '_agendamento.txt');

  LDataCriacao := FormatDateTime('dd/MM/yyyy HH:nn:ss', Now);

  LDataCriacaoArq := ObterDataCriacaoOriginal(LArquivo);
  LDatas[0] := LDataCriacao;
  LDatas[1] := LDataCriacaoArq;
  LDataCriacao := LDatas[Ord(Length(LDataCriacaoArq) > 0)];

  LWriter := TStreamWriter.Create(LArquivo, False, TEncoding.UTF8);
  try
    LWriter.WriteLine('============================================');
    LWriter.WriteLine('  AGENDAMENTO DE PRE-MATRICULA');
    LWriter.WriteLine('  Colegio Batista Santos Dumont');
    LWriter.WriteLine('============================================');
    LWriter.WriteLine('Data do Agendamento : ' + LDataCriacao);
    LWriter.WriteLine('Data da Atualizacao : ' + FormatDateTime('dd/MM/yyyy HH:nn:ss', Now));
    LWriter.WriteLine('CPF do Responsavel  : ' + AAgendamento.CPF);
    LWriter.WriteLine('Data para Assinatura: ' + FormatDateTime('dd/MM/yyyy', AAgendamento.DataAgendamento));
    LWriter.WriteLine('Status              : PENDENTE');
    LWriter.WriteLine('============================================');
  finally
    LWriter.Free;
  end;
end;

end.
