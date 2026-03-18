unit Model.TMonitorNotificacao;

{ Monitora C:\ProgramData\ServicoEnvioNFs\notificacao_pendente.json
  Quando encontrar, exibe um dialogo VCL (thread-safe via TThread.Queue)
  perguntando ao usuario se confirma o envio ou deseja alterar o dia.
  Grava a resposta em resposta_notificacao.json para o servico ler. }

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Model.IMonitorNotificacao;

type
  TMonitorNotificacao = class(TInterfacedObject, IMonitorNotificacao)
  private
    FThread: TThread;
    FStop  : TEvent;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Iniciar;
    procedure   Parar;
    class function Criar: IMonitorNotificacao;
  end;

implementation

uses
  System.IOUtils,
  System.IniFiles,
  Winapi.Windows,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics;

const
  PASTA_SINAIS  = 'C:\ProgramData\ServicoEnvioNFs\';
  ARQ_SINAL     = 'notificacao_pendente.json';
  ARQ_RESPOSTA  = 'resposta_notificacao.json';
  INTERVALO_MS  = 30000; { verifica a cada 30 segundos }

{ -- Helpers de JSON simples (sem dependencia de biblioteca) ----------- }

function LerCampoStr(const AJSON, ACampo: string): string;
var
  LPos, LFim: Integer;
  LChave     : string;
begin
  Result := '';
  LChave := '"' + ACampo + '"';
  LPos   := Pos(LChave, AJSON);
  case LPos = 0 of
    True: Exit;
  end;
  LPos := Pos(':', AJSON, LPos + Length(LChave));
  case LPos = 0 of
    True: Exit;
  end;
  Inc(LPos);
  while (LPos <= Length(AJSON)) and (AJSON[LPos] = ' ') do Inc(LPos);
  case AJSON[LPos] = '"' of
    True:
    begin
      Inc(LPos);
      LFim := Pos('"', AJSON, LPos);
      case LFim = 0 of
        True: Exit;
      end;
      Result := Copy(AJSON, LPos, LFim - LPos);
    end;
    False:
    begin
      LFim := LPos;
      while (LFim <= Length(AJSON)) and
            (AJSON[LFim] in ['0'..'9', '-']) do
        Inc(LFim);
      Result := Copy(AJSON, LPos, LFim - LPos);
    end;
  end;
end;

function LerCampoInt(const AJSON, ACampo: string): Integer;
begin
  Result := StrToIntDef(LerCampoStr(AJSON, ACampo), 0);
end;

procedure GravarResposta(const AConfirmou: Boolean; const ANovoDia: Integer);
var
  LArquivo: string;
  LWriter : TStreamWriter;
  LConfStr: string;
begin
  LArquivo := TPath.Combine(PASTA_SINAIS, ARQ_RESPOSTA);
  ForceDirectories(PASTA_SINAIS);
  case AConfirmou of
    True : LConfStr := 'true';
    False: LConfStr := 'false';
  end;
  LWriter := TStreamWriter.Create(LArquivo, False, TEncoding.UTF8);
  try
    LWriter.WriteLine(
      Format('{"confirmou":%s,"novo_dia":%d}', [LConfStr, ANovoDia]));
  finally
    LWriter.Free;
  end;
end;

{ -- Dialogo de confirmacao (VCL, rodado na thread principal) ---------- }

procedure ExibirDialogo(
  const ADiaEnvio    : Integer;
  const AMes         : Integer;
  const AAno         : Integer;
  const ADiasRestantes: Integer);
var
  LFrm        : TForm;
  LPnlTopo    : TPanel;
  LPnlRodape  : TPanel;
  LLblTitulo  : TLabel;
  LLblMensagem: TLabel;
  LLblNovoDia : TLabel;
  LEdtNovoDia : TEdit;
  LBtnSim     : TButton;
  LBtnNao     : TButton;
  LMeses      : array[1..12] of string;
  LMensagem   : string;
  LConfirmou  : Boolean;
  LNovoDia    : Integer;
begin
  LMeses[1]  := 'Janeiro';   LMeses[2]  := 'Fevereiro';
  LMeses[3]  := 'Março';     LMeses[4]  := 'Abril';
  LMeses[5]  := 'Maio';      LMeses[6]  := 'Junho';
  LMeses[7]  := 'Julho';     LMeses[8]  := 'Agosto';
  LMeses[9]  := 'Setembro';  LMeses[10] := 'Outubro';
  LMeses[11] := 'Novembro';  LMeses[12] := 'Dezembro';

  LMensagem :=
    'O envio das Notas Fiscais de ' +
    LMeses[AMes] + '/' + IntToStr(AAno) +
    ' está programado para o dia ' + IntToStr(ADiaEnvio) + '.' + #13#10 +
    '(Falta ' + IntToStr(ADiasRestantes) + ' dia para o envio)' + #13#10#13#10 +
    'Deseja confirmar o envio nesta data?';

  LFrm := TForm.CreateNew(Application);
  try
    LFrm.Caption      := 'Monitor NFSe — Confirmação de Envio';
    LFrm.Position     := poScreenCenter;
    LFrm.BorderStyle  := bsDialog;
    LFrm.Width        := 420;
    LFrm.Height       := 240;
    LFrm.Font.Name    := 'Segoe UI';
    LFrm.Font.Size    := 9;

    { Topo colorido }
    LPnlTopo             := TPanel.Create(LFrm);
    LPnlTopo.Parent      := LFrm;
    LPnlTopo.Align       := alTop;
    LPnlTopo.Height      := 4;
    LPnlTopo.BevelOuter  := bvNone;
    LPnlTopo.Color       := $00CC5500;
    LPnlTopo.ParentColor := False;

    { Titulo }
    LLblTitulo            := TLabel.Create(LFrm);
    LLblTitulo.Parent     := LFrm;
    LLblTitulo.Caption    := '  📅  Lembrete de Envio de NFS-e';
    LLblTitulo.Font.Style := [fsBold];
    LLblTitulo.Font.Size  := 10;
    LLblTitulo.Top        := 16;
    LLblTitulo.Left       := 12;

    { Mensagem }
    LLblMensagem          := TLabel.Create(LFrm);
    LLblMensagem.Parent   := LFrm;
    LLblMensagem.Caption  := LMensagem;
    LLblMensagem.WordWrap := True;
    LLblMensagem.Top      := 46;
    LLblMensagem.Left     := 16;
    LLblMensagem.Width    := 384;

    { Novo dia }
    LLblNovoDia          := TLabel.Create(LFrm);
    LLblNovoDia.Parent   := LFrm;
    LLblNovoDia.Caption  := 'Se NÃO, informe o novo dia de envio:';
    LLblNovoDia.Top      := 152;
    LLblNovoDia.Left     := 16;

    LEdtNovoDia               := TEdit.Create(LFrm);
    LEdtNovoDia.Parent        := LFrm;
    LEdtNovoDia.Top           := 148;
    LEdtNovoDia.Left          := 270;
    LEdtNovoDia.Width         := 50;
    LEdtNovoDia.Text          := IntToStr(ADiaEnvio);
    LEdtNovoDia.MaxLength     := 2;

    { Rodape com botoes }
    LPnlRodape             := TPanel.Create(LFrm);
    LPnlRodape.Parent      := LFrm;
    LPnlRodape.Align       := alBottom;
    LPnlRodape.Height      := 44;
    LPnlRodape.BevelOuter  := bvNone;
    LPnlRodape.Color       := $00F5F5F5;
    LPnlRodape.ParentColor := False;

    LBtnSim             := TButton.Create(LFrm);
    LBtnSim.Parent      := LPnlRodape;
    LBtnSim.Caption     := '✔  Sim, confirmo o envio no dia ' + IntToStr(ADiaEnvio);
    LBtnSim.ModalResult := mrYes;
    LBtnSim.Width       := 230;
    LBtnSim.Height      := 28;
    LBtnSim.Top         := 8;
    LBtnSim.Left        := 12;
    LBtnSim.Font.Style  := [fsBold];

    LBtnNao             := TButton.Create(LFrm);
    LBtnNao.Parent      := LPnlRodape;
    LBtnNao.Caption     := '✘  Não, alterar dia';
    LBtnNao.ModalResult := mrNo;
    LBtnNao.Width       := 130;
    LBtnNao.Height      := 28;
    LBtnNao.Top         := 8;
    LBtnNao.Left        := 254;

    { Traz ao frente piscando na barra de tarefas }
    FlashWindow(LFrm.Handle, True);

    case LFrm.ShowModal of
      mrYes:
      begin
        LConfirmou := True;
        LNovoDia   := 0;
      end;
      else
      begin
        LConfirmou := False;
        LNovoDia   := StrToIntDef(LEdtNovoDia.Text, ADiaEnvio);
        case (LNovoDia < 1) or (LNovoDia > 31) of
          True: LNovoDia := ADiaEnvio;
        end;
      end;
    end;

    GravarResposta(LConfirmou, LNovoDia);
  finally
    LFrm.Free;
  end;
end;

{ -- TMonitorNotificacao ----------------------------------------------- }

class function TMonitorNotificacao.Criar: IMonitorNotificacao;
begin
  Result := TMonitorNotificacao.Create;
end;

constructor TMonitorNotificacao.Create;
begin
  inherited Create;
  FStop := TEvent.Create(nil, True, False, '');
end;

destructor TMonitorNotificacao.Destroy;
begin
  Parar;
  FStop.Free;
  inherited;
end;

procedure TMonitorNotificacao.Iniciar;
var
  LStop: TEvent;
begin
  LStop := FStop;

  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      LArqSinal : string;
      LConteudo : string;
      LDiaEnvio : Integer;
      LMes      : Integer;
      LAno      : Integer;
      LDiasRest : Integer;
      LLinhas   : TStringList;
      LWait     : TWaitResult;
    begin
      LArqSinal := TPath.Combine(PASTA_SINAIS, ARQ_SINAL);
      repeat
        LWait := LStop.WaitFor(INTERVALO_MS);

        case LWait of
          wrTimeout:
          begin
            case TFile.Exists(LArqSinal) of
              True:
              begin
                { Le o JSON do sinal }
                LConteudo := '';
                LLinhas   := TStringList.Create;
                try
                  LLinhas.LoadFromFile(LArqSinal, TEncoding.UTF8);
                  LConteudo := LLinhas.Text;
                finally
                  LLinhas.Free;
                end;

                LDiaEnvio := LerCampoInt(LConteudo, 'dia_envio');
                LMes      := LerCampoInt(LConteudo, 'mes');
                LAno      := LerCampoInt(LConteudo, 'ano');
                LDiasRest := LerCampoInt(LConteudo, 'dias_restantes');

                case (LDiaEnvio > 0) and (LMes > 0) and (LAno > 0) of
                  True:
                  begin
                    { Remove o sinal antes de mostrar para nao reaparecer
                      se o usuario demorar a responder }
                    TFile.Delete(LArqSinal);

                    { Exibe o dialogo na thread principal (obrigatorio VCL) }
                    TThread.Queue(nil,
                      procedure
                      begin
                        ExibirDialogo(LDiaEnvio, LMes, LAno, LDiasRest);
                      end);
                  end;
                end;
              end;
            end;
          end;
        end;

      until (LWait = wrSignaled) or TThread.CurrentThread.CheckTerminated;
    end);

  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

procedure TMonitorNotificacao.Parar;
begin
  case Assigned(FThread) of
    True:
    begin
      FStop.SetEvent;
      FThread.Terminate;
      FThread.WaitFor;
      FreeAndNil(FThread);
      FStop.ResetEvent;
    end;
  end;
end;

end.
