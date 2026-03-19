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
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics;

const
  TOAST_W   = 340;
  TOAST_H   = 160;
  MARGEM    = 12;
  COR_FUNDO = $00FFFFFF;
  COR_TOPO  = $00C45000;
  COR_LINHA = $0064D747;
  COR_TIT   = $003F3F3F;
  COR_TEXTO = $00616161;
  COR_DEST  = $00C45000;
  COR_CAMPO = $00F5F5F5;

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

{ Posiciona acima do relogio — usa GetMonitorInfo do monitor da taskbar }
procedure ObterPosicaoRelogio(out AX, AY: Integer);
var
  LTray    : HWND;
  LTrayRect: TRect;
begin
  LTray := FindWindow('Shell_TrayWnd', nil);
  GetWindowRect(LTray, LTrayRect);
  { A taskbar ocupa toda a largura inferior — Right e o limite direito da tela }
  { X: posiciona pelo Right da taskbar menos a largura do toast                }
  { Y: posiciona acima do topo da taskbar                                      }
  AX := LTrayRect.Right - TOAST_W - MARGEM;
  AY := LTrayRect.Top   - TOAST_H - MARGEM;
end;

{ ── Form customizado com posicao forcada via CreateParams ───────────── }

type
  TFormToast = class(TForm)
  private
    FX: Integer;
    FY: Integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor CriarNaPosicao(const AX, AY, AW, AH: Integer);
  end;

constructor TFormToast.CriarNaPosicao(const AX, AY, AW, AH: Integer);
begin
  FX := AX;
  FY := AY;
  inherited CreateNew(nil);
  Width  := AW;
  Height := AH;
end;

procedure TFormToast.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.X      := FX;
  Params.Y      := FY;
  Params.Style  := WS_POPUP or WS_VISIBLE;
  Params.ExStyle := WS_EX_TOPMOST or WS_EX_TOOLWINDOW;
end;

{ ── Controlador ─────────────────────────────────────────────────────── }

type
  TToastCtrl = class
  private
    FDiaEnvio : Integer;
    FMes      : Integer;
    FAno      : Integer;
    FCaminho  : string;
    FMax      : Integer;
    FFechado  : TEvent;
    FPnlCampo : TPanel;
    FEdtDia   : TEdit;
    FBtnSim   : TButton;
    FBtnNao   : TButton;
  public
    constructor Create(
      const ADia, AMes, AAno : Integer;
      const ACaminho         : string;
      const AMax             : Integer;
      const AFechado         : TEvent;
      const APnlCampo        : TPanel;
      const AEdtDia          : TEdit;
      const ABtnSim, ABtnNao : TButton);
    procedure SimClick(Sender: TObject);
    procedure NaoClick(Sender: TObject);
  end;

constructor TToastCtrl.Create(
  const ADia, AMes, AAno : Integer;
  const ACaminho         : string;
  const AMax             : Integer;
  const AFechado         : TEvent;
  const APnlCampo        : TPanel;
  const AEdtDia          : TEdit;
  const ABtnSim, ABtnNao : TButton);
begin
  inherited Create;
  FDiaEnvio := ADia;  FMes := AMes;  FAno := AAno;
  FCaminho  := ACaminho;  FMax := AMax;
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
  LPnlBox    : TPanel;   { painel principal igual ao exemplo }
  LPnlLinha  : TPanel;   { linha colorida lateral esquerda   }
  LPnlMsg    : TPanel;   { area da mensagem                  }
  LPnlCampo  : TPanel;   { campo novo dia                    }
  LPnlBotoes : TPanel;   { botoes                            }
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
  LXFinal    : Integer;
  LYFinal    : Integer;
begin
  LMax     := MaxDiaMes(AMes, AAno);
  LFechado := TEvent.Create(nil, True, False, '');
  LCtrl    := nil;

  ObterPosicaoRelogio(LXFinal, LYFinal);

  { Form invisivel apenas como container TOPMOST }
  LFrm := TForm.CreateNew(nil);
  try
    LFrm.BorderStyle     := bsNone;
    LFrm.Width           := TOAST_W;
    LFrm.Height          := TOAST_H;
    LFrm.Color           := clNone;
    LFrm.FormStyle       := fsStayOnTop;
    LFrm.Font.Name       := 'Segoe UI';
    LFrm.Font.Size       := 9;
    LFrm.AlphaBlend      := True;
    LFrm.AlphaBlendValue := 252;

    { PanelBox — igual ao TToastMessage do exemplo }
    LPnlBox              := TPanel.Create(LFrm);
    LPnlBox.Parent       := LFrm;
    LPnlBox.Align        := alClient;
    LPnlBox.BevelOuter   := bvNone;
    LPnlBox.BevelInner   := bvNone;
    LPnlBox.BevelKind    := bkNone;
    LPnlBox.Color        := COR_FUNDO;
    LPnlBox.ParentColor  := False;
    LPnlBox.Ctl3D        := False;

    { Linha colorida lateral esquerda — igual ao exemplo }
    LPnlLinha              := TPanel.Create(LFrm);
    LPnlLinha.Parent       := LPnlBox;
    LPnlLinha.Align        := alLeft;
    LPnlLinha.Width        := 5;
    LPnlLinha.BevelOuter   := bvNone;
    LPnlLinha.BevelInner   := bvNone;
    LPnlLinha.BevelKind    := bkNone;
    LPnlLinha.Color        := COR_TOPO;
    LPnlLinha.ParentColor  := False;
    LPnlLinha.Ctl3D        := False;

    { Area da mensagem }
    LPnlMsg              := TPanel.Create(LFrm);
    LPnlMsg.Parent       := LPnlBox;
    LPnlMsg.Align        := alClient;
    LPnlMsg.BevelOuter   := bvNone;
    LPnlMsg.BevelInner   := bvNone;
    LPnlMsg.BevelKind    := bkNone;
    LPnlMsg.Color        := COR_FUNDO;
    LPnlMsg.ParentColor  := False;
    LPnlMsg.Ctl3D        := False;

    { Titulo }
    LLblTitulo            := TLabel.Create(LFrm);
    LLblTitulo.Parent     := LPnlMsg;
    LLblTitulo.Caption    := 'Lembrete de Envio NFS-e';
    LLblTitulo.Font.Style := [fsBold];
    LLblTitulo.Font.Size  := 11;
    LLblTitulo.Font.Color := COR_TIT;
    LLblTitulo.Font.Name  := 'Segoe UI';
    LLblTitulo.Align      := alTop;
    LLblTitulo.Alignment  := taCenter;
    LLblTitulo.Layout     := tlCenter;
    LLblTitulo.Top        := 0;
    LLblTitulo.AutoSize   := False;
    LLblTitulo.Height     := 30;

    { Mensagem linha 1 }
    LLblMsg1              := TLabel.Create(LFrm);
    LLblMsg1.Parent       := LPnlMsg;
    LLblMsg1.Caption      := 'Faltam 1 dia pros envios das notas fiscais pra SEFIN.';
    LLblMsg1.Font.Color   := COR_TEXTO;
    LLblMsg1.Font.Size    := 9;
    LLblMsg1.Font.Name    := 'Segoe UI';
    LLblMsg1.WordWrap     := True;
    LLblMsg1.AutoSize     := False;
    LLblMsg1.Width        := TOAST_W - 30;
    LLblMsg1.Alignment    := taCenter;
    LLblMsg1.Top          := 34;
    LLblMsg1.Left         := 4;
    LLblMsg1.Height       := 32;

    { Mensagem linha 2 — data destacada }
    LLblMsg2              := TLabel.Create(LFrm);
    LLblMsg2.Parent       := LPnlMsg;
    LLblMsg2.Caption      := 'Deseja que o envio ocorra em ' + ADataFmt + '?';
    LLblMsg2.Font.Color   := COR_DEST;
    LLblMsg2.Font.Style   := [fsBold];
    LLblMsg2.Font.Size    := 10;
    LLblMsg2.Font.Name    := 'Segoe UI';
    LLblMsg2.AutoSize     := False;
    LLblMsg2.Width        := TOAST_W - 30;
    LLblMsg2.Alignment    := taCenter;
    LLblMsg2.Top          := 66;
    LLblMsg2.Left         := 4;
    LLblMsg2.Height       := 22;

    { Campo novo dia }
    LPnlCampo             := TPanel.Create(LFrm);
    LPnlCampo.Parent      := LPnlMsg;
    LPnlCampo.BevelOuter  := bvNone;
    LPnlCampo.Color       := COR_CAMPO;
    LPnlCampo.ParentColor := False;
    LPnlCampo.Top         := 92;
    LPnlCampo.Left        := 4;
    LPnlCampo.Width       := TOAST_W - 30;
    LPnlCampo.Height      := 28;
    LPnlCampo.Visible     := False;

    LLblNovoDia           := TLabel.Create(LFrm);
    LLblNovoDia.Parent    := LPnlCampo;
    LLblNovoDia.Caption   := 'Novo dia (1-' + IntToStr(LMax) + '):';
    LLblNovoDia.Font.Color:= COR_TEXTO;
    LLblNovoDia.Top       := 7;
    LLblNovoDia.Left      := 8;

    LEdtDia               := TEdit.Create(LFrm);
    LEdtDia.Parent        := LPnlCampo;
    LEdtDia.Top           := 3;
    LEdtDia.Left          := 110;
    LEdtDia.Width         := 40;
    LEdtDia.MaxLength     := 2;
    LEdtDia.Text          := IntToStr(ADiaEnvio);
    LEdtDia.Font.Style    := [fsBold];
    LEdtDia.Font.Size     := 10;

    LLblDica              := TLabel.Create(LFrm);
    LLblDica.Parent       := LPnlCampo;
    LLblDica.Caption      := 'e clique SALVAR';
    LLblDica.Font.Color   := clGray;
    LLblDica.Font.Size    := 8;
    LLblDica.Top          := 7;
    LLblDica.Left         := 158;

    { Botoes }
    LPnlBotoes             := TPanel.Create(LFrm);
    LPnlBotoes.Parent      := LPnlMsg;
    LPnlBotoes.Align       := alBottom;
    LPnlBotoes.Height      := 38;
    LPnlBotoes.BevelOuter  := bvNone;
    LPnlBotoes.Color       := COR_FUNDO;
    LPnlBotoes.ParentColor := False;

    { Botoes centralizados: total 2x110 + gap 10 = 230, centro em (TOAST_W-5)/2 }
    LBtnSim               := TButton.Create(LFrm);
    LBtnSim.Parent        := LPnlBotoes;
    LBtnSim.Caption       := #$2714 + '  SIM';
    LBtnSim.Width         := 110;
    LBtnSim.Height        := 26;
    LBtnSim.Top           := 3;
    LBtnSim.Left          := ((TOAST_W - 5) div 2) - 115;
    LBtnSim.Font.Style    := [fsBold];
    LBtnSim.Font.Size     := 9;

    LBtnNao               := TButton.Create(LFrm);
    LBtnNao.Parent        := LPnlBotoes;
    LBtnNao.Caption       := #$2718 + '  N' + #195 + 'O';
    LBtnNao.Width         := 110;
    LBtnNao.Height        := 26;
    LBtnNao.Top           := 3;
    LBtnNao.Left          := ((TOAST_W - 5) div 2) + 5;
    LBtnNao.Font.Size     := 9;

    LCtrl := TToastCtrl.Create(
      ADiaEnvio, AMes, AAno, ACaminhoIni, LMax,
      LFechado, LPnlCampo, LEdtDia, LBtnSim, LBtnNao);

    LBtnSim.OnClick := LCtrl.SimClick;
    LBtnNao.OnClick := LCtrl.NaoClick;

    { Exibe abaixo da tela e anima subindo }
    LFrm.Show;
    MoveWindow(LFrm.Handle, LXFinal, LYFinal + TOAST_H + 10, TOAST_W, TOAST_H, False);

    TThread.CreateAnonymousThread(
      procedure
      var
        LY   : Integer;
        LHwnd: HWND;
      begin
        LHwnd := LFrm.Handle;
        LY    := LYFinal + TOAST_H + 10;
        while LY > LYFinal do
        begin
          Dec(LY, 7);
          case LY < LYFinal of
            True: LY := LYFinal;
          end;
          TThread.Synchronize(nil,
            procedure
            begin
              MoveWindow(LHwnd, LXFinal, LY, TOAST_W, TOAST_H, False);
            end);
          Sleep(5);
        end;
      end).Start;

    while LFechado.WaitFor(50) = wrTimeout do
      Application.ProcessMessages;

  finally
    LCtrl.Free;
    LFrm.Free;
    LFechado.Free;
  end;
end;

end.
