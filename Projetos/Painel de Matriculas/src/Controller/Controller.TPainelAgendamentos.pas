unit Controller.TPainelAgendamentos;

interface

uses
  Controller.IPainelAgendamentos,
  Model.IAgendamentoPainel,
  Model.TAgendamentoPainel,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.SyncObjs,
  System.Generics.Collections,
  System.RegularExpressions,
  Winapi.Windows;

type
  TPainelController = class;

  TMonitorThread = class(TThread)
  private
    FController: TPainelController;
    FEvento    : TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(const AController: TPainelController);
    destructor Destroy; override;
    procedure Sinalizar;
  end;

  TPainelController = class(TInterfacedObject, IPainelController)
  private
    FPastaAgendamentos: string;
    FPastaBase        : string;
    FArquivoJSON      : string;
    FThread           : TMonitorThread;
    function ExtrairCampo(const AConteudo, APadrao: string): string;
    function ChaveDataISO(const AConteudo: string): string;
    function LimparCPF(const ACPF: string): string;
    function ConsultarStatusContrato(const ACPFLimpo: string): string;
    function ArquivoParaAgendamento(const AConteudo: string;
                                    const AContratoStatus: string): IAgendamentoPainel;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ScanearEGravar;
    procedure IniciarMonitoramento(const APastaAgendamentos: string;
                                   const AArquivoJSON      : string);
    procedure PararMonitoramento;
    procedure ValidarContrato(const ACPF: string);
    function  PastaBase: string;
    function  ObterNovatosJSON: string;
  end;

implementation

{ TMonitorThread }

constructor TMonitorThread.Create(const AController: TPainelController);
begin
  inherited Create(True);
  FController     := AController;
  FEvento         := TEvent.Create(nil, True, False, '');
  FreeOnTerminate := False;
end;

destructor TMonitorThread.Destroy;
begin
  FEvento.Free;
  inherited;
end;

procedure TMonitorThread.Sinalizar;
begin
  FEvento.SetEvent;
end;

procedure TMonitorThread.Execute;
begin
  repeat
    FEvento.WaitFor(3000);
    FEvento.ResetEvent;
    case Ord(not Terminated) of
      1: FController.ScanearEGravar;
    end;
  until Terminated;
end;

{ TPainelController }

constructor TPainelController.Create;
begin
  inherited Create;
  FThread := nil;
end;

destructor TPainelController.Destroy;
begin
  PararMonitoramento;
  inherited;
end;

function TPainelController.ExtrairCampo(const AConteudo, APadrao: string): string;
var
  LMatch : TMatch;
  LCands : array[0..1] of string;
begin
  LMatch    := TRegEx.Match(AConteudo, APadrao);
  LCands[0] := '';
  LCands[1] := LMatch.Groups[1].Value;
  Result    := LCands[Ord(LMatch.Success)];
end;

function TPainelController.ChaveDataISO(const AConteudo: string): string;
var
  LMatch : TMatch;
  LCands : array[0..1] of string;
begin
  LMatch    := TRegEx.Match(AConteudo,
    'Data para Assinatura\s*:\s*(\d{2})\/(\d{2})\/(\d{4})');
  LCands[0] := '';
  LCands[1] := LMatch.Groups[3].Value + '-' +
               LMatch.Groups[2].Value + '-' +
               LMatch.Groups[1].Value;
  Result    := LCands[Ord(LMatch.Success)];
end;

function TPainelController.LimparCPF(const ACPF: string): string;
begin
  Result := StringReplace(
    StringReplace(ACPF, '.', '', [rfReplaceAll]),
    '-', '', [rfReplaceAll]);
end;

function TPainelController.ConsultarStatusContrato(const ACPFLimpo: string): string;
var
  LPastaAss  : string;
  LPastaOrig : string;
  LArqAss    : string;
  LArqOrig   : string;
  LArqValid  : string;
begin
  Result    := 'sem_contrato';
  LPastaAss := TPath.Combine(TPath.Combine(FPastaBase, ACPFLimpo), 'ContratoAssinado');
  LPastaOrig := TPath.Combine(TPath.Combine(FPastaBase, ACPFLimpo), 'ContratoOriginal');

  LArqAss := TPath.Combine(LPastaAss, 'ContratoMatricula.pdf');
  if TFile.Exists(LArqAss) then
  begin
    LArqValid := TPath.Combine(LPastaAss, '_VALIDADO');
    if TFile.Exists(LArqValid) then
      Result := 'validado'
    else
      Result := 'pendente';
    Exit;
  end;

  LArqOrig := TPath.Combine(LPastaOrig, 'ContratoMatricula.pdf');
  if TFile.Exists(LArqOrig) then
    Result := 'original';
end;

function TPainelController.ArquivoParaAgendamento(const AConteudo: string;
                                                   const AContratoStatus: string): IAgendamentoPainel;
var
  LCPF, LDataAg, LDataAt, LDataAs, LStatus: string;
begin
  LCPF    := ExtrairCampo(AConteudo, 'CPF do Responsavel\s*:\s*(\S+)');
  LDataAg := ExtrairCampo(AConteudo, 'Data do Agendamento\s*:\s*(\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}:\d{2})');
  LDataAt := ExtrairCampo(AConteudo, 'Data da Atualizacao\s*:\s*(\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}:\d{2})');
  LDataAs := ExtrairCampo(AConteudo, 'Data para Assinatura\s*:\s*(\d{2}\/\d{2}\/\d{4})');
  LStatus := ExtrairCampo(AConteudo, 'Status\s*:\s*(\w+)');
  Result  := TAgendamentoPainel.Create(LCPF, LDataAg, LDataAt, LDataAs, LStatus, AContratoStatus);
end;

procedure TPainelController.ScanearEGravar;
var
  LArquivos      : TArray<string>;
  LArquivo       : string;
  LConteudo      : string;
  LChave         : string;
  LNomeArq       : string;
  LCPFLimpo      : string;
  LContratoStatus: string;
  LReader        : TStreamReader;
  LDatas         : TDictionary<string, TList<IAgendamentoPainel>>;
  LPartesDatas   : TArray<string>;
  LItensData     : TArray<string>;
  LPar           : TPair<string, TList<IAgendamentoPainel>>;
  LJSON          : string;
  LWriter        : TStreamWriter;
  I, LIdx        : Integer;
  // varredura de contratos independente de agendamento
  LPastas        : TArray<string>;
  LPasta         : string;
  LArqAss        : string;
  LArqValid      : string;
  LContratosItens: TArray<string>;
  LContratoIdx   : Integer;
begin
  LDatas := TDictionary<string, TList<IAgendamentoPainel>>.Create;
  try
    // --- 1. Agendamentos (para o calendário) ---
    LArquivos := TDirectory.GetFiles(FPastaAgendamentos, '*_agendamento.txt',
                   TSearchOption.soTopDirectoryOnly);

    for LArquivo in LArquivos do
    begin
      LReader := TStreamReader.Create(LArquivo, TEncoding.UTF8);
      try
        LConteudo := LReader.ReadToEnd;
      finally
        LReader.Free;
      end;
      LChave := ChaveDataISO(LConteudo);
      case Ord(LChave <> '') of
        1:
          begin
            LNomeArq  := TPath.GetFileNameWithoutExtension(LArquivo);
            LCPFLimpo := StringReplace(LNomeArq, '_agendamento', '', []);
            LContratoStatus := ConsultarStatusContrato(LCPFLimpo);

            case Ord(not LDatas.ContainsKey(LChave)) of
              1: LDatas.Add(LChave, TList<IAgendamentoPainel>.Create);
            end;
            LDatas[LChave].Add(ArquivoParaAgendamento(LConteudo, LContratoStatus));
          end;
      end;
    end;

    SetLength(LPartesDatas, LDatas.Count);
    LIdx := 0;
    for LPar in LDatas do
    begin
      SetLength(LItensData, LPar.Value.Count);
      for I := 0 to LPar.Value.Count - 1 do
        LItensData[I] := LPar.Value[I].ToJSON;
      LPartesDatas[LIdx] := '"' + LPar.Key + '":[' +
                             string.Join(',', LItensData) + ']';
      Inc(LIdx);
    end;

    // --- 2. Contratos — varre TODAS as pastas CPF em FPastaBase ---
    SetLength(LContratosItens, 0);
    LContratoIdx := 0;
    if TDirectory.Exists(FPastaBase) then
    begin
      LPastas := TDirectory.GetDirectories(FPastaBase, '*',
                   TSearchOption.soTopDirectoryOnly);
      SetLength(LContratosItens, Length(LPastas));
      for LPasta in LPastas do
      begin
        LArqAss := TPath.Combine(TPath.Combine(LPasta, 'ContratoAssinado'), 'ContratoMatricula.pdf');
        if TFile.Exists(LArqAss) then
        begin
          LArqValid := TPath.Combine(TPath.Combine(LPasta, 'ContratoAssinado'), '_VALIDADO');
          LCPFLimpo := TPath.GetFileName(LPasta);
          if TFile.Exists(LArqValid) then
            LContratosItens[LContratoIdx] := '{"cpf":"' + LCPFLimpo + '","contratoStatus":"validado"}'
          else
            LContratosItens[LContratoIdx] := '{"cpf":"' + LCPFLimpo + '","contratoStatus":"pendente"}';
          Inc(LContratoIdx);
        end;
      end;
    end;
    SetLength(LContratosItens, LContratoIdx);

    LJSON :=
      '{"agendamentos":{' + string.Join(',', LPartesDatas) + '},' +
      '"contratos":[' + string.Join(',', LContratosItens) + '],' +
      '"novatos":' + ObterNovatosJSON + ',' +
      '"totalArquivos":' + IntToStr(Length(LArquivos)) + ',' +
      '"ultimaAtualizacao":"' + FormatDateTime('dd\/MM\/yyyy HH:nn:ss', Now) + '"}';

    // Grava em .tmp e usa MoveFileEx MOVEFILE_REPLACE_EXISTING (atômico no Windows)
    // Evita EFOpenError quando o browser tem o JSON aberto durante o XHR
    LWriter := TStreamWriter.Create(FArquivoJSON + '.tmp', False, TEncoding.UTF8);
    try
      LWriter.Write(LJSON);
    finally
      LWriter.Free;
    end;
    MoveFileEx(PChar(FArquivoJSON + '.tmp'), PChar(FArquivoJSON),
               MOVEFILE_REPLACE_EXISTING);

  finally
    for LPar in LDatas do
      LPar.Value.Free;
    LDatas.Free;
  end;
end;

procedure TPainelController.IniciarMonitoramento(const APastaAgendamentos: string;
                                                  const AArquivoJSON      : string);
begin
  FPastaAgendamentos := APastaAgendamentos;
  FPastaBase         := TPath.GetDirectoryName(APastaAgendamentos);
  FArquivoJSON       := AArquivoJSON;
  ScanearEGravar;
  FThread := TMonitorThread.Create(Self);
  FThread.Start;
end;

function TPainelController.PastaBase: string;
begin
  Result := FPastaBase;
end;

function TPainelController.ObterNovatosJSON: string;
var
  LArquivo: string;
  LLista  : TStringList;
  LLinhas : TArray<string>;
  I       : Integer;
begin
  Result   := '[]';
  // novatos.json fica em files\ dentro do exe do portal (mesmo Debug\)
  LArquivo := TPath.Combine(FPastaBase, 'files' + PathDelim + 'novatos.json');
  if not TFile.Exists(LArquivo) then Exit;
  LLista := TStringList.Create;
  try
    LLista.LoadFromFile(LArquivo, TEncoding.UTF8);
    SetLength(LLinhas, LLista.Count);
    for I := 0 to LLista.Count - 1 do
      LLinhas[I] := LLista[I];
    Result := '[' + string.Join(',', LLinhas) + ']';
  finally
    LLista.Free;
  end;
end;

procedure TPainelController.ValidarContrato(const ACPF: string);
var
  LCPFLimpo: string;
  LPastaAss: string;
  LArqAss  : string;
  LArqValid: string;
begin
  LCPFLimpo := LimparCPF(ACPF);
  LPastaAss := TPath.Combine(TPath.Combine(FPastaBase, LCPFLimpo), 'ContratoAssinado');
  LArqAss   := TPath.Combine(LPastaAss, 'ContratoMatricula.pdf');
  case Ord(TFile.Exists(LArqAss)) of
    1:
      begin
        LArqValid := TPath.Combine(LPastaAss, '_VALIDADO');
        TFile.WriteAllText(LArqValid, '');
        ScanearEGravar;
      end;
  end;
end;

procedure TPainelController.PararMonitoramento;
begin
  case Ord(FThread <> nil) of
    1:
      begin
        FThread.Terminate;
        FThread.Sinalizar;
        FThread.WaitFor;
        FreeAndNil(FThread);
      end;
  end;
end;

end.
