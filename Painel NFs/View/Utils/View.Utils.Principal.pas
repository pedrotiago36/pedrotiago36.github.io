unit View.Utils.Principal;

interface

uses
  Winapi.Windows,
  Winapi.UxTheme,
  System.SysUtils,
  System.DateUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Data.DB,
  FireDAC.Comp.Client,
  { EhLib }
  GridsEh,
  DBGridEh,
  ToolCtrlsEh,
  DBAxisGridsEh,
  EhLibVCL,
  { Model }
  Model.IEstatisticasUnidade,
  Model.TEstatisticasUnidade,
  Controller.TPrincipal,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Forms,
  Vcl.Buttons;

type
  TViewUtilsPrincipal = class
  private
    class procedure DesenharAba(const ACanvas: TCanvas; const ARect: TRect;
      const AAtivo: Boolean; const ACor: TColor; const ANome: string);
  public
    { Tema }
    class procedure DesativarTema(const ACtrl: TWinControl);
    class procedure DesativarTemasGerais(const AForm: TCustomForm;
      const AControles: array of TWinControl);

    { Hover sidebar }
    class procedure AplicarHoverMenu(const ALbl: TLabel; const AAtivo: Boolean);
    class procedure SidebarAtivarLabel(const ASender: TObject;
      const AMenus: array of TLabel);
    class procedure SidebarDesativarTodos(const AMenus: array of TLabel);

    { Status bar }
    class procedure ExibirStatus(const ALbl: TLabel; const AMensagem: string;
      const ACor: TColor);

    { Cards }
    class procedure MontarCard(const APnl: TPanel;
      const ANome, AEnvLbl, AEnvQtd, ACancLbl, ACancQtd: TLabel;
      const ATitulo: string);
    class procedure CentralizarCards(const APnlCards: TPanel;
      const ACards: array of TPanel);

    { MemTable }
    class procedure InicializarMemTable(const AMt: TFDMemTable;
      const AComBotoes: Boolean);

    { Grid }
    class procedure VincularGrid(const AGrid: TDBGridEh;
      const ADs: TDataSource; const AMt: TFDMemTable;
      const AComBotoes: Boolean; const AImageList: TImageList);

    { DrawTab }
    class procedure DrawTabUnidades(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    class procedure DrawTabTipoEnvio(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    class procedure DrawTabSituacao(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);

    { Orquestração da View }
    class procedure Configurar(const AForm: TForm;
      const AController: TControllerPrincipal);
    class procedure AtualizarCards(const AController: TControllerPrincipal;
      const AQtdEnvSede, AQtdCancSede, AQtdEnvUEQ, AQtdCancUEQ,
      AQtdEnvVarjota, AQtdCancVarjota, AQtdEnvSeisBocas,
      AQtdCancSeisBocas: TLabel);
    class procedure AtualizarTodasAsGrids(const AController: TControllerPrincipal;
      const AMts: array of TFDMemTable;
      const AUnidades: array of TNomeUnidade;
      const ASituacoes: array of string);
    class procedure AbrirUnidadeESituacao(const AUnidade: TNomeUnidade;
      const ASituacao: string;
      const APgcUnidades: TPageControl;
      const APgcSede, APgcUEQ, APgcVarjota, APgcSeisBocas: TPageControl);
    class procedure AbrirTelaConfiguracoes(const AOwner: TComponent;
      const AController: TControllerPrincipal;
      const AOnAtualizar: TProc);
    class function MenuLabels(const ASede, AUEQ, AVarjota, ASeisBocas,
      AConfig, ASair: TLabel): TArray<TLabel>;
  end;

implementation

const
  COR_CARD     : TColor = $00FFFFFF;
  COR_GRID_ODD : TColor = $00F8FAFC;
  COR_GRID_HDR : TColor = $00EEF2FF;

  CARD_W = 278;
  CARD_H = 116;
  CARD_GAP = 16;
  CARD_N   = 4;

{ ── Tema ──────────────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.DesativarTema(const ACtrl: TWinControl);
begin
  SetWindowTheme(ACtrl.Handle, '', '');
end;

class procedure TViewUtilsPrincipal.DesativarTemasGerais(
  const AForm: TCustomForm; const AControles: array of TWinControl);
var
  LCtrl: TWinControl;
begin
  for LCtrl in AControles do
    DesativarTema(LCtrl);
end;

{ ── Hover sidebar ──────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.AplicarHoverMenu(const ALbl: TLabel;
  const AAtivo: Boolean);
const
  COR_SIDEBAR = 3359061;
begin
  case AAtivo of
    True: begin
      ALbl.Transparent := False;
      ALbl.Color       := clWhite;
      ALbl.Font.Color  := COR_SIDEBAR;
    end;
    False: begin
      ALbl.Transparent := True;
      ALbl.Font.Color  := clWhite;
    end;
  end;
end;

class procedure TViewUtilsPrincipal.SidebarAtivarLabel(const ASender: TObject;
  const AMenus: array of TLabel);
var
  I: Integer;
begin
  for I := Low(AMenus) to High(AMenus) do
    AplicarHoverMenu(AMenus[I], AMenus[I] = ASender);
end;

class procedure TViewUtilsPrincipal.SidebarDesativarTodos(
  const AMenus: array of TLabel);
var
  I: Integer;
begin
  for I := Low(AMenus) to High(AMenus) do
    AplicarHoverMenu(AMenus[I], False);
end;

{ ── Status ─────────────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.ExibirStatus(const ALbl: TLabel;
  const AMensagem: string; const ACor: TColor);
begin
  ALbl.Caption    := '  ' + AMensagem;
  ALbl.Font.Color := ACor;
end;

{ ── Cards ───────────────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.MontarCard(const APnl: TPanel;
  const ANome, AEnvLbl, AEnvQtd, ACancLbl, ACancQtd: TLabel;
  const ATitulo: string);
begin
  APnl.BevelOuter  := bvNone;
  APnl.BevelInner  := bvNone;
  ANome.Caption    := ATitulo;
  AEnvLbl.Caption  := 'Enviadas';
  AEnvQtd.Caption  := '0';
  AEnvQtd.Cursor   := crHandPoint;
  ACancLbl.Caption := 'Canceladas';
  ACancQtd.Caption := '0';
  ACancQtd.Cursor  := crHandPoint;
end;

class procedure TViewUtilsPrincipal.CentralizarCards(const APnlCards: TPanel;
  const ACards: array of TPanel);
var
  LTotalW, LMargemLeft, LTop, I: Integer;
begin
  LTotalW     := CARD_N * CARD_W + (CARD_N - 1) * CARD_GAP;
  LMargemLeft := (APnlCards.Width - LTotalW) div 2;
  LTop        := (APnlCards.Height - CARD_H) div 2;

  for I := Low(ACards) to High(ACards) do
    ACards[I].SetBounds(LMargemLeft + I * (CARD_W + CARD_GAP), LTop, CARD_W, CARD_H);
end;

{ ── MemTable ────────────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.InicializarMemTable(
  const AMt: TFDMemTable; const AComBotoes: Boolean);
begin
  AMt.Close;
  AMt.FieldDefs.Clear;
  AMt.FieldDefs.Add('NumeroRps',      ftString, 20);
  AMt.FieldDefs.Add('SerieRps',       ftString,  5);
  AMt.FieldDefs.Add('DataEmissao',    ftString, 20);
  AMt.FieldDefs.Add('Tomador',        ftString, 80);
  AMt.FieldDefs.Add('ValorServico',   ftString, 20);
  AMt.FieldDefs.Add('NumeroNFSe',     ftString, 20);
  AMt.FieldDefs.Add('CodVerificacao', ftString, 20);
  AMt.FieldDefs.Add('Situacao',       ftString, 15);
  case AComBotoes of
    True: begin
      AMt.FieldDefs.Add('AcaoCancelar', ftString, 15);
      AMt.FieldDefs.Add('AcaoDANFSe',   ftString, 15);
    end;
  end;
  AMt.CreateDataSet;
end;

{ ── Grid ────────────────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.VincularGrid(const AGrid: TDBGridEh;
  const ADs: TDataSource; const AMt: TFDMemTable; const AComBotoes: Boolean;
  const AImageList: TImageList);
var
  LCol: TColumnEh;
begin
  AGrid.Align        := alClient;
  AGrid.Font.Name    := 'Segoe UI';
  AGrid.Font.Size    := 9;
  AGrid.RowHeight    := 26;
  AGrid.TitleHeight  := 28;
  AGrid.OddRowColor  := COR_GRID_ODD;
  AGrid.EvenRowColor := COR_CARD;
  AGrid.FixedColor   := COR_GRID_HDR;
  AGrid.ReadOnly     := True;
  AGrid.OptionsEh    := AGrid.OptionsEh + [dghHighlightFocus];
  ADs.DataSet        := AMt;
  AGrid.DataSource   := ADs;
  AGrid.Columns.Clear;

  LCol := AGrid.Columns.Add;
  LCol.FieldName := 'NumeroRps';    LCol.Title.Caption := 'N. RPS';     LCol.Width := 80;
  LCol := AGrid.Columns.Add;
  LCol.FieldName := 'DataEmissao';  LCol.Title.Caption := 'Data';       LCol.Width := 90;
  LCol := AGrid.Columns.Add;
  LCol.FieldName := 'Tomador';      LCol.Title.Caption := 'Tomador';    LCol.Width := 220;
  LCol := AGrid.Columns.Add;
  LCol.FieldName := 'ValorServico'; LCol.Title.Caption := 'Valor (R$)'; LCol.Width := 100;
  LCol.Alignment := taRightJustify;
  LCol := AGrid.Columns.Add;
  LCol.FieldName := 'NumeroNFSe';   LCol.Title.Caption := 'N. NFSe';    LCol.Width := 90;

  case AComBotoes of
    True: begin
      LCol := AGrid.Columns.Add;
      LCol.FieldName     := 'CodVerificacao';
      LCol.Title.Caption := 'Cod. Verif.';
      LCol.Width         := 110;

      LCol := AGrid.Columns.Add;
      LCol.FieldName     := '';
      LCol.Title.Caption := 'A' + #231 + #245 + 'es';
      LCol.Width         := 64;
      LCol.ReadOnly      := True;
      LCol.TextEditing   := False;

      with LCol.CellButtons.Add do
      begin
        Style               := ebsGlyphEh;
        Hint                := 'Cancelar NFSe';
        Width               := 28;
        HorzPlacement       := ebhpLeftEh;
        Images.NormalImages := AImageList;
        Images.NormalIndex  := 0;
      end;
      with LCol.CellButtons.Add do
      begin
        Style               := ebsGlyphEh;
        Hint                := 'Imprimir DANFE';
        Width               := 28;
        HorzPlacement       := ebhpLeftEh;
        Images.NormalImages := AImageList;
        Images.NormalIndex  := 1;
      end;
    end;
    False: begin
      LCol := AGrid.Columns.Add;
      LCol.FieldName     := 'Situacao';
      LCol.Title.Caption := 'Situa' + #231 + #227 + 'o';
      LCol.Width         := 110;
    end;
  end;
end;

{ ── DrawTab ─────────────────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.DesenharAba(const ACanvas: TCanvas;
  const ARect: TRect; const AAtivo: Boolean; const ACor: TColor;
  const ANome: string);
const
  BARRA = 4;
var
  RBarra, RTexto: TRect;
begin
  case AAtivo of
    True : ACanvas.Brush.Color := clWhite;
    False: ACanvas.Brush.Color := 15921906;
  end;
  ACanvas.FillRect(ARect);

  RBarra        := ARect;
  RBarra.Bottom := RBarra.Top + BARRA;
  ACanvas.Brush.Color := ACor;
  ACanvas.FillRect(RBarra);

  RTexto := ARect;
  Inc(RTexto.Top, BARRA);
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Name   := 'Segoe UI';
  ACanvas.Font.Size   := 9;
  ACanvas.Font.Style  := [fsBold];
  case AAtivo of
    True : ACanvas.Font.Color := ACor;
    False: ACanvas.Font.Color := 9868950;
  end;
  DrawText(ACanvas.Handle, PChar(ANome), -1, RTexto,
    DT_SINGLELINE or DT_VCENTER or DT_CENTER);
end;

class procedure TViewUtilsPrincipal.DrawTabUnidades(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
const
  CORES: array[0..3] of TColor = (6382321, 961001, 1096065, 16498468);
  NOMES: array[0..3] of string = ('SEDE', 'UEQ', 'Varjota', 'Seis Bocas');
begin
  DesenharAba(Control.Canvas, Rect, Active, CORES[TabIndex mod 4], NOMES[TabIndex mod 4]);
end;

class procedure TViewUtilsPrincipal.DrawTabTipoEnvio(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
const
  CORES: array[0..1] of TColor = (7040122, 14120960);
  NOMES: array[0..1] of string = ('Lotes', 'Individual');
begin
  DesenharAba(Control.Canvas, Rect, Active, CORES[TabIndex mod 2], NOMES[TabIndex mod 2]);
end;

class procedure TViewUtilsPrincipal.DrawTabSituacao(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
const
  CORES: array[0..1] of TColor = (961001, 13382400);
  NOMES: array[0..1] of string = ('Enviadas', 'Canceladas');
begin
  DesenharAba(Control.Canvas, Rect, Active, CORES[TabIndex mod 2], NOMES[TabIndex mod 2]);
end;

{ ── Orquestração da View ─────────────────────────────────────────── }

class procedure TViewUtilsPrincipal.Configurar(const AForm: TForm;
  const AController: TControllerPrincipal);
begin
  { Nenhuma lógica aqui - Configurar permanece na View pois acessa
    diretamente os componentes visuais pelo nome. Este método existe
    para compatibilidade futura caso a View precise ser trocada. }
end;

class procedure TViewUtilsPrincipal.AtualizarCards(
  const AController: TControllerPrincipal;
  const AQtdEnvSede, AQtdCancSede, AQtdEnvUEQ, AQtdCancUEQ,
  AQtdEnvVarjota, AQtdCancVarjota, AQtdEnvSeisBocas,
  AQtdCancSeisBocas: TLabel);
var
  LEst: TArrayEstatisticas;
begin
  AController.AtualizarCards;
  AController.ObterEstatisticas(LEst);
  AQtdEnvSede.Caption       := LEst[nuSede].TotalEnviadas.ToString;
  AQtdCancSede.Caption      := LEst[nuSede].TotalCanceladas.ToString;
  AQtdEnvUEQ.Caption        := LEst[nuUEQ].TotalEnviadas.ToString;
  AQtdCancUEQ.Caption       := LEst[nuUEQ].TotalCanceladas.ToString;
  AQtdEnvVarjota.Caption    := LEst[nuVarjota].TotalEnviadas.ToString;
  AQtdCancVarjota.Caption   := LEst[nuVarjota].TotalCanceladas.ToString;
  AQtdEnvSeisBocas.Caption  := LEst[nuSeisBocas].TotalEnviadas.ToString;
  AQtdCancSeisBocas.Caption := LEst[nuSeisBocas].TotalCanceladas.ToString;
end;

class procedure TViewUtilsPrincipal.AtualizarTodasAsGrids(
  const AController: TControllerPrincipal;
  const AMts: array of TFDMemTable;
  const AUnidades: array of TNomeUnidade;
  const ASituacoes: array of string);
var
  I: Integer;
begin
  for I := Low(AMts) to High(AMts) do
    AController.PreencherMemTable(AMts[I], AUnidades[I], ASituacoes[I]);
end;

class procedure TViewUtilsPrincipal.AbrirUnidadeESituacao(
  const AUnidade: TNomeUnidade; const ASituacao: string;
  const APgcUnidades: TPageControl;
  const APgcSede, APgcUEQ, APgcVarjota, APgcSeisBocas: TPageControl);
const
  IDX_UNIDADE: array[TNomeUnidade] of Integer = (0, 1, 2, 3);
var
  LPgcSit: array[TNomeUnidade] of TPageControl;
begin
  LPgcSit[nuSede]      := APgcSede;
  LPgcSit[nuUEQ]       := APgcUEQ;
  LPgcSit[nuVarjota]   := APgcVarjota;
  LPgcSit[nuSeisBocas] := APgcSeisBocas;

  APgcUnidades.ActivePageIndex       := IDX_UNIDADE[AUnidade];
  LPgcSit[AUnidade].ActivePageIndex  := Ord(not (ASituacao = 'ENVIADA'));
end;

class procedure TViewUtilsPrincipal.AbrirTelaConfiguracoes(
  const AOwner: TComponent; const AController: TControllerPrincipal;
  const AOnAtualizar: TProc);
begin
  { Importado via uses na implementation da View — evita dependência circular }
  AController.RecarregarConfiguracao;
  case Assigned(AOnAtualizar) of
    True: AOnAtualizar;
  end;
end;

class function TViewUtilsPrincipal.MenuLabels(const ASede, AUEQ, AVarjota,
  ASeisBocas, AConfig, ASair: TLabel): TArray<TLabel>;
begin
  Result := [ASede, AUEQ, AVarjota, ASeisBocas, AConfig, ASair];
end;

end.
