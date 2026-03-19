unit View.ToastAgendamento;

interface

procedure ExibirToastAgendamento(
  const ADiaEnvio  : Integer;
  const AMes       : Integer;
  const AAno       : Integer;
  const ADataFmt   : string;
  const ACaminhoIni: string);

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  System.IniFiles,
  System.SyncObjs,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Winapi.MultiMon;

const
  TOAST_W      = 380;
  TOAST_H      = 180;
  MARGEM       = 20;
  COR_FUNDO    = $00252525;
  COR_TOPO     = $00C45000;
  COR_TITULO   = $00FFFFFF;
  COR_TEXTO    = $00D0D0D0;
  COR_DESTAQUE = $0055DDFF;
  COR_SEP      = $00404040;
  COR_CAMPO    = $00303030;
  COR_BTN_SIM  = $00226622;
  COR_BTN_NAO  = $00884400;

function EhBissexto(const AAno: Integer): Boolean;
begin
  Result := (AAno mod 4 = 0) and
            ((AAno mod 100 <> 0) or (AAno mod 400 = 0));
end;

function MaxDiaMes(const AMes, AAno: Integer): Integer;
const
  DIAS: array[1..12] of Integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  Result := DIAS[AMes];
  case (AMes = 2) and EhBissexto(AAno) of
    True: Result := 29;
  end;
end;

procedure GravarNovoDia(const ACaminhoIni: string; const ANovoDia: Integer);
var
  LIni: TMemIniFile;
begin
  LIni := TMemIniFile.Create(ACaminhoIni);
  try
    LIni.WriteString('Config', 'DiaEnvio', IntToStr(ANovoDia));
    LIni.UpdateFile;
  finally
    LIni.Free;
  end;
end;

procedure AnimarSubida(const AForm: TForm;
  const AXFinal, AYFinal: Integer);
var
  LY: Integer;
begin
  LY := AYFinal + TOAST_H + 20;
  AForm.SetBounds(AXFinal, LY, TOAST_W, TOAST_H);
  AForm.Visible := True;
  while LY > AYFinal do
  begin
    Dec(LY, 8);
    case LY < AYFinal of
      True: LY := AYFinal;
    end;
    AForm.Top := LY;
    AForm.Update;
    Sleep(6);
  end;
end;

{ ── Controlador ────────────────────────────────────────────────────── }

type
  TToastCtrl = class
  private
    FDiaEnvio  : Integer;
    FMes       : Integer;
    FAno       : Integer;
    FCaminho   : string;
    FMax       : Integer;
    FFechado   : TEvent;
    FPnlCampo  : TPanel;
    FEdtDia    : TEdit;
    FBtnSim    : TButton;
    FBtnNao    : TButton;
  public
    constructor Create(
      const ADia, AMes, AAno: Integer;
      const ACaminho: string;
      const AMax: Integer;
      const AFechado: TEvent;
      const APnlCampo: TPanel;
      const AEdtDia: TEdit;
      const ABtnSim, ABtnNao: TButton);
    procedure SimClick(Sender: TObject);
    procedure NaoClick(Sender: TObject);
  end;

constructor TToastCtrl.Create(
  const ADia, AMes, AAno: Integer;
  const ACaminho: string;
  const AMax: Integer;
  const AFechado: TEvent;
  const APnlCampo: TPanel;
  const AEdtDia: TEdit;
  const ABtnSim, ABtnNao: TButton);
begin
  inherited Create;
  FDiaEnvio := ADia;   FMes := AMes;  FAno := AAno;
  FCaminho  := ACaminho; FMax := AMax;
  FFechado  := AFechado;
  FPnlCampo := APnlCampo;
  FEdtDia   := AEdtDia;
  FBtnSim   := ABtnSim;
  FBtnNao   := ABtnNao;
end;

procedure TToastCtrl.SimClick(Sender: TObject);
var
  LDia: Integer;
begin
  case FPnlCampo.Visible of
    True:
    begin
      LDia := StrToIntDef(FEdtDia.Text, 0);
      case (LDia >= 1) and (LDia <= FMax) of
        True : GravarNovoDia(FCaminho, LDia);
        False: GravarNovoDia(FCaminho, FDiaEnvio);
      end;
    end;
  end;
  FFechado.SetEvent;
end;

procedure TToastCtrl.NaoClick(Sender: TObject);
begin
  case FPnlCampo.Visible of
    False:
    begin
      FPnlCampo.Visible := True;
      FBtnSim.Caption   := #$2714 + ' SALVAR';
      FBtnNao.Caption   := 'CANCELAR';
      FEdtDia.SetFocus;
      FEdtDia.SelectAll;
    end;
    True: FFechado.SetEvent;
  end;
end;

{ ── Toast ──────────────────────────────────────────────────────────── }

procedure ExibirToastAgendamento(
  const ADiaEnvio  : Integer;
  const AMes       : Integer;
  const AAno       : Integer;
  const ADataFmt   : string;
  const ACaminhoIni: string);
var
  LFrm       : TForm;
  LPnlTopo   : TPanel;
  LPnlCorpo  : TPanel;
  LPnlCampo  : TPanel;
  LPnlBotoes : TPanel;
  LLblIcon   : TLabel;
  LLblTitulo : TLabel;
  LLblMsg1   : TLabel;
  LLblMsg2   : TLabel;
  LLblNovoDia: TLabel;
  LLblDica   : TLabel;
  LEdtDia    : TEdit;
  LBtnSim    : TButton;
  LBtnNao    : TButton;
  LFechado   : TEvent;
  LCtrl      : TToastCtrl;
  LMax       : Integer;
  LX, LY     : Integer;
  LTaskbar   : HWND;
  LTaskRect  : TRect;
  LMonitor   : HMONITOR;
  LMonInfo   : TMonitorInfo;
begin
  LMax     := MaxDiaMes(AMes, AAno);
  LFechado := TEvent.Create(nil, True, False, '');
  LCtrl    := nil;
  LFrm     := TForm.CreateNew(nil);
  try
    { ── Form base ── }
    LFrm.BorderStyle     := bsNone;
    LFrm.Width           := TOAST_W;
    LFrm.Height          := TOAST_H;
    LFrm.Font.Name       := 'Segoe UI';
    LFrm.Font.Size       := 9;
    LFrm.Color           := COR_FUNDO;
    LFrm.AlphaBlend      := True;
    LFrm.AlphaBlendValue := 248;
    LFrm.FormStyle       := fsStayOnTop;

    { ── Faixa topo colorida ── }
    LPnlTopo             := TPanel.Create(LFrm);
    LPnlTopo.Parent      := LFrm;
    LPnlTopo.Align       := alTop;
    LPnlTopo.Height      := 36;
    LPnlTopo.BevelOuter  := bvNone;
    LPnlTopo.Color       := COR_TOPO;
    LPnlTopo.ParentColor := False;

    LLblIcon             := TLabel.Create(LFrm);
    LLblIcon.Parent      := LPnlTopo;
    LLblIcon.Caption     := #$1F4C5;
    LLblIcon.Font.Size   := 14;
    LLblIcon.Top         := 6;
    LLblIcon.Left        := 10;

    LLblTitulo            := TLabel.Create(LFrm);
    LLblTitulo.Parent     := LPnlTopo;
    LLblTitulo.Caption    := 'Lembrete  —  Envio de NFS-e';
    LLblTitulo.Font.Style := [fsBold];
    LLblTitulo.Font.Size  := 10;
    LLblTitulo.Font.Color := COR_TITULO;
    LLblTitulo.Top        := 9;
    LLblTitulo.Left       := 38;

    { ── Corpo ── }
    LPnlCorpo            := TPanel.Create(LFrm);
    LPnlCorpo.Parent     := LFrm;
    LPnlCorpo.Align      := alClient;
    LPnlCorpo.BevelOuter := bvNone;
    LPnlCorpo.Color      := COR_FUNDO;
    LPnlCorpo.ParentColor := False;

    LLblMsg1             := TLabel.Create(LFrm);
    LLblMsg1.Parent      := LPnlCorpo;
    LLblMsg1.Caption     := 'Faltam 1 dia pros envios das notas fiscais pra SEFIN.';
    LLblMsg1.Font.Color  := COR_TEXTO;
    LLblMsg1.Font.Size   := 9;
    LLblMsg1.Top         := 12;
    LLblMsg1.Left        := 14;
    LLblMsg1.Width       := TOAST_W - 28;
    LLblMsg1.WordWrap    := True;

    LLblMsg2             := TLabel.Create(LFrm);
    LLblMsg2.Parent      := LPnlCorpo;
    LLblMsg2.Caption     := 'Deseja que o envio ocorra em  ' + ADataFmt + '?';
    LLblMsg2.Font.Color  := COR_DESTAQUE;
    LLblMsg2.Font.Style  := [fsBold];
    LLblMsg2.Font.Size   := 10;
    LLblMsg2.Top         := 34;
    LLblMsg2.Left        := 14;

    { ── Painel campo novo dia ── }
    LPnlCampo            := TPanel.Create(LFrm);
    LPnlCampo.Parent     := LPnlCorpo;
    LPnlCampo.BevelOuter := bvNone;
    LPnlCampo.Color      := COR_CAMPO;
    LPnlCampo.ParentColor := False;
    LPnlCampo.Top        := 62;
    LPnlCampo.Left       := 0;
    LPnlCampo.Width      := TOAST_W;
    LPnlCampo.Height     := 32;
    LPnlCampo.Visible    := False;

    LLblNovoDia          := TLabel.Create(LFrm);
    LLblNovoDia.Parent   := LPnlCampo;
    LLblNovoDia.Caption  := 'Novo dia de envio  (1 – ' + IntToStr(LMax) + '):';
    LLblNovoDia.Font.Color := COR_TEXTO;
    LLblNovoDia.Top      := 8;
    LLblNovoDia.Left     := 14;

    LEdtDia              := TEdit.Create(LFrm);
    LEdtDia.Parent       := LPnlCampo;
    LEdtDia.Top          := 4;
    LEdtDia.Left         := 200;
    LEdtDia.Width        := 40;
    LEdtDia.MaxLength    := 2;
    LEdtDia.Text         := IntToStr(ADiaEnvio);
    LEdtDia.Font.Size    := 11;
    LEdtDia.Font.Style   := [fsBold];

    LLblDica             := TLabel.Create(LFrm);
    LLblDica.Parent      := LPnlCampo;
    LLblDica.Caption     := '  e clique  SALVAR';
    LLblDica.Font.Color  := $00888888;
    LLblDica.Font.Size   := 8;
    LLblDica.Top         := 9;
    LLblDica.Left        := 246;

    { ── Botoes ── }
    LPnlBotoes            := TPanel.Create(LFrm);
    LPnlBotoes.Parent     := LFrm;
    LPnlBotoes.Align      := alBottom;
    LPnlBotoes.Height     := 46;
    LPnlBotoes.BevelOuter := bvNone;
    LPnlBotoes.Color      := $001E1E1E;
    LPnlBotoes.ParentColor := False;

    LBtnSim              := TButton.Create(LFrm);
    LBtnSim.Parent       := LPnlBotoes;
    LBtnSim.Caption      := #$2714 + '  SIM';
    LBtnSim.Width        := 110;
    LBtnSim.Height       := 30;
    LBtnSim.Top          := 8;
    LBtnSim.Left         := 14;
    LBtnSim.Font.Style   := [fsBold];
    LBtnSim.Font.Size    := 9;

    LBtnNao              := TButton.Create(LFrm);
    LBtnNao.Parent       := LPnlBotoes;
    LBtnNao.Caption      := #$2718 + '  N' + #195 + 'O';
    LBtnNao.Width        := 110;
    LBtnNao.Height       := 30;
    LBtnNao.Top          := 8;
    LBtnNao.Left         := 134;
    LBtnNao.Font.Size    := 9;

    LCtrl := TToastCtrl.Create(
      ADiaEnvio, AMes, AAno, ACaminhoIni, LMax,
      LFechado, LPnlCampo, LEdtDia, LBtnSim, LBtnNao);

    LBtnSim.OnClick := LCtrl.SimClick;
    LBtnNao.OnClick := LCtrl.NaoClick;

    { ── Posiciona no monitor onde esta a taskbar (lado do relogio) ── }
    LTaskbar := FindWindow('Shell_TrayWnd', nil);
    GetWindowRect(LTaskbar, LTaskRect);
    LMonitor := MonitorFromWindow(LTaskbar, MONITOR_DEFAULTTONEAREST);
    FillChar(LMonInfo, SizeOf(LMonInfo), 0);
    LMonInfo.cbSize := SizeOf(LMonInfo);
    GetMonitorInfo(LMonitor, @LMonInfo);
    LX := LMonInfo.rcWork.Right  - TOAST_W - MARGEM;
    LY := LMonInfo.rcWork.Bottom - TOAST_H - MARGEM;

    AnimarSubida(LFrm, LX, LY);

    while LFechado.WaitFor(50) = wrTimeout do
      Application.ProcessMessages;

  finally
    LCtrl.Free;
    LFrm.Free;
    LFechado.Free;
  end;
end;

end.
