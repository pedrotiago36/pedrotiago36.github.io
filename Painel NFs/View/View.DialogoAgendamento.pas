unit View.DialogoAgendamento;

{
  Responsabilidade:
    Exibe o dialogo de confirmacao de agendamento de envio.
    Retorna se confirmou e qual o novo dia (caso NAO).
    Chamado pela View.Principal via TThread.Queue (thread principal).
}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  System.IniFiles,
  System.IOUtils;

procedure ExibirDialogoAgendamento(
  const ADiaEnvio: Integer;
  const AMes     : Integer;
  const AAno     : Integer;
  const ADataFmt : string;
  const ACaminhoIni: string);

implementation

uses
  System.DateUtils;

{ ── Validacao do novo dia ─────────────────────────────────────────────── }

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

function ValidarDia(const ATexto: string; const AMes, AAno: Integer;
  out ANovoDia: Integer): Boolean;
var
  LMax: Integer;
begin
  ANovoDia := StrToIntDef(ATexto, 0);
  LMax     := MaxDiaMes(AMes, AAno);
  Result   := (ANovoDia >= 1) and (ANovoDia <= LMax);
end;

{ ── Gravar novo dia no ini ────────────────────────────────────────────── }

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

{ ── Dialogo principal ─────────────────────────────────────────────────── }

procedure ExibirDialogoAgendamento(
  const ADiaEnvio: Integer;
  const AMes     : Integer;
  const AAno     : Integer;
  const ADataFmt : string;
  const ACaminhoIni: string);
var
  LFrm         : TForm;
  LPnlTopo     : TPanel;
  LPnlRodape   : TPanel;
  LPnlCampo    : TPanel;
  LLblTitulo   : TLabel;
  LLblMensagem : TLabel;
  LLblNovoDia  : TLabel;
  LLblDica     : TLabel;
  LEdtNovoDia  : TEdit;
  LBtnSim      : TButton;
  LBtnNao      : TButton;
  LMeses       : array[1..12] of string;
  LMensagem    : string;
  LNovoDia     : Integer;
  LMax         : Integer;
begin
  LMeses[1]  := 'Janeiro';   LMeses[2]  := 'Fevereiro';
  LMeses[3]  := 'Mar' + #231 + 'o';
  LMeses[4]  := 'Abril';     LMeses[5]  := 'Maio';
  LMeses[6]  := 'Junho';     LMeses[7]  := 'Julho';
  LMeses[8]  := 'Agosto';    LMeses[9]  := 'Setembro';
  LMeses[10] := 'Outubro';   LMeses[11] := 'Novembro';
  LMeses[12] := 'Dezembro';

  LMax := MaxDiaMes(AMes, AAno);

  LMensagem :=
    'Faltam 1 dia pros envios das notas fiscais pra SEFIN.' + #13#10 +
    'Deseja que o envio ocorra nesta data?' + #13#10#13#10 +
    '     ' + ADataFmt + '  (' + LMeses[AMes] + '/' + IntToStr(AAno) + ')';

  LFrm := TForm.CreateNew(Application);
  try
    LFrm.Caption     := 'Agendamento de Envio NFS-e';
    LFrm.Position    := poScreenCenter;
    LFrm.BorderStyle := bsDialog;
    LFrm.Width       := 440;
    LFrm.Height      := 270;
    LFrm.Font.Name   := 'Segoe UI';
    LFrm.Font.Size   := 9;
    LFrm.Color       := clWhite;

    { Faixa topo colorida }
    LPnlTopo            := TPanel.Create(LFrm);
    LPnlTopo.Parent     := LFrm;
    LPnlTopo.Align      := alTop;
    LPnlTopo.Height     := 5;
    LPnlTopo.BevelOuter := bvNone;
    LPnlTopo.Color      := $00CC5500;
    LPnlTopo.ParentColor := False;

    { Titulo }
    LLblTitulo           := TLabel.Create(LFrm);
    LLblTitulo.Parent    := LFrm;
    LLblTitulo.Caption   := #$1F4C5 + '  Lembrete de Envio de NFS-e';
    LLblTitulo.Font.Style := [fsBold];
    LLblTitulo.Font.Size  := 10;
    LLblTitulo.Font.Color := $00993300;
    LLblTitulo.Top        := 16;
    LLblTitulo.Left       := 16;

    { Mensagem }
    LLblMensagem          := TLabel.Create(LFrm);
    LLblMensagem.Parent   := LFrm;
    LLblMensagem.Caption  := LMensagem;
    LLblMensagem.WordWrap := True;
    LLblMensagem.Top      := 48;
    LLblMensagem.Left     := 16;
    LLblMensagem.Width    := 400;

    { Painel campo novo dia (inicialmente oculto) }
    LPnlCampo            := TPanel.Create(LFrm);
    LPnlCampo.Parent     := LFrm;
    LPnlCampo.BevelOuter := bvNone;
    LPnlCampo.Color      := $00FFF8F0;
    LPnlCampo.ParentColor := False;
    LPnlCampo.Top        := 148;
    LPnlCampo.Left       := 0;
    LPnlCampo.Width      := 440;
    LPnlCampo.Height     := 48;
    LPnlCampo.Visible    := False;

    LLblNovoDia          := TLabel.Create(LFrm);
    LLblNovoDia.Parent   := LPnlCampo;
    LLblNovoDia.Caption  := 'Novo dia de envio (1 a ' + IntToStr(LMax) + '):';
    LLblNovoDia.Top      := 14;
    LLblNovoDia.Left     := 16;

    LEdtNovoDia              := TEdit.Create(LFrm);
    LEdtNovoDia.Parent       := LPnlCampo;
    LEdtNovoDia.Top          := 10;
    LEdtNovoDia.Left         := 230;
    LEdtNovoDia.Width        := 50;
    LEdtNovoDia.MaxLength    := 2;
    LEdtNovoDia.Text         := IntToStr(ADiaEnvio);
    LEdtNovoDia.Font.Size    := 11;
    LEdtNovoDia.Font.Style   := [fsBold];

    LLblDica             := TLabel.Create(LFrm);
    LLblDica.Parent      := LPnlCampo;
    LLblDica.Caption     := 'e pressione SIM para salvar';
    LLblDica.Top         := 14;
    LLblDica.Left        := 290;
    LLblDica.Font.Size   := 8;
    LLblDica.Font.Color  := clGray;

    { Rodape com botoes }
    LPnlRodape            := TPanel.Create(LFrm);
    LPnlRodape.Parent     := LFrm;
    LPnlRodape.Align      := alBottom;
    LPnlRodape.Height     := 52;
    LPnlRodape.BevelOuter := bvNone;
    LPnlRodape.Color      := $00F5F5F5;
    LPnlRodape.ParentColor := False;

    LBtnSim              := TButton.Create(LFrm);
    LBtnSim.Parent       := LPnlRodape;
    LBtnSim.Caption      := #$2714 + '  Sim, enviar em ' + ADataFmt;
    LBtnSim.ModalResult  := mrYes;
    LBtnSim.Width        := 210;
    LBtnSim.Height       := 32;
    LBtnSim.Top          := 10;
    LBtnSim.Left         := 12;
    LBtnSim.Font.Style   := [fsBold];
    LBtnSim.Font.Color   := clWhite;

    LBtnNao              := TButton.Create(LFrm);
    LBtnNao.Parent       := LPnlRodape;
    LBtnNao.Caption      := #$2718 + '  N' + #227 + 'o, alterar dia';
    LBtnNao.ModalResult  := mrNone; { nao fecha automaticamente }
    LBtnNao.Width        := 160;
    LBtnNao.Height       := 32;
    LBtnNao.Top          := 10;
    LBtnNao.Left         := 236;
    LBtnNao.Font.Color   := $00CC5500;

    { NAO usa ModalResult mrNo para mostrar campo }
    LBtnNao.ModalResult := mrNo;

    FlashWindow(LFrm.Handle, True);
    LFrm.BringToFront;

    case LFrm.ShowModal of
      mrYes:
      begin
        { Usuario clicou SIM direto — nao faz nada }
      end;
      mrNo:
      begin
        { Usuario clicou NAO — mostra campo e aguarda novo dia }
        LPnlCampo.Visible   := True;
        LBtnSim.Caption     := #$2714 + '  Salvar novo dia';
        LBtnSim.ModalResult := mrYes;
        LBtnNao.ModalResult := mrCancel;
        LEdtNovoDia.SetFocus;
        LEdtNovoDia.SelectAll;
        case LFrm.ShowModal of
          mrYes:
          begin
            case ValidarDia(LEdtNovoDia.Text, AMes, AAno, LNovoDia) of
              True : GravarNovoDia(ACaminhoIni, LNovoDia);
              False: GravarNovoDia(ACaminhoIni, ADiaEnvio);
            end;
          end;
        end;
      end;
    end;

  finally
    LFrm.Free;
  end;
end;

end.
