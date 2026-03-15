unit View.Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.Menus,
  Data.DB,
  { EHLib }
  GridsEh,
  DBGridEh,
  ToolCtrlsEh,
  DBAxisGridsEh,
  EhLibVCL,
  { FireDAC }
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  { Controller }
  Controller.IPrincipal,
  Controller.TPrincipal,
  { Model }
  Model.IEstatisticasUnidade, DBGridEhGrouping, DBGridEhToolCtrls, DynVarsEh;

type
  TFrmPrincipal = class(TForm)
    { Menu principal }
    mnuPrincipal    : TMainMenu;
    mnuSistema      : TMenuItem;
    mnuConfiguracoes: TMenuItem;
    mnuSeparador1   : TMenuItem;
    mnuSair         : TMenuItem;
    mnuFerramentas  : TMenuItem;
    mnuAtualizar    : TMenuItem;

    { Topo }
    pnlTopo           : TPanel;
    lblTitulo         : TLabel;
    lblMesAno         : TLabel;
    pnlModoEnvio      : TPanel;
    rbEnviarLote      : TRadioButton;
    rbEnviarIndividual: TRadioButton;
    btnAtualizar      : TSpeedButton;

    { Cards }
    pnlCards             : TPanel;
    pnlCardSede          : TPanel;
    lblCardNomeSede      : TLabel;
    lblCardEnvSede       : TLabel;
    lblCardQtdEnvSede    : TLabel;
    lblCardCancSede      : TLabel;
    lblCardQtdCancSede   : TLabel;

    pnlCardUEQ           : TPanel;
    lblCardNomeUEQ       : TLabel;
    lblCardEnvUEQ        : TLabel;
    lblCardQtdEnvUEQ     : TLabel;
    lblCardCancUEQ       : TLabel;
    lblCardQtdCancUEQ    : TLabel;

    pnlCardVarjota         : TPanel;
    lblCardNomeVarjota     : TLabel;
    lblCardEnvVarjota      : TLabel;
    lblCardQtdEnvVarjota   : TLabel;
    lblCardCancVarjota     : TLabel;
    lblCardQtdCancVarjota  : TLabel;

    pnlCardSeisBocas        : TPanel;
    lblCardNomeSeisBocas    : TLabel;
    lblCardEnvSeisBocas     : TLabel;
    lblCardQtdEnvSeisBocas  : TLabel;
    lblCardCancSeisBocas    : TLabel;
    lblCardQtdCancSeisBocas : TLabel;

    { PageControl 1 - Unidades }
    pgcUnidades : TPageControl;
    tabSede     : TTabSheet;
    tabUEQ      : TTabSheet;
    tabVarjota  : TTabSheet;
    tabSeisBocas: TTabSheet;

    { PageControl 2 - Tipo - SEDE }
    pgcTipoSede      : TPageControl;
    tabLoteSede      : TTabSheet;
    tabIndividualSede: TTabSheet;

    { PageControl 3 - Situacao Lote - SEDE }
    pgcSitLoteSede : TPageControl;
    tabEnvLoteSede : TTabSheet;
    tabCancLoteSede: TTabSheet;

    { PageControl 3 - Situacao Individual - SEDE }
    pgcSitIndivSede : TPageControl;
    tabEnvIndivSede : TTabSheet;
    tabCancIndivSede: TTabSheet;

    { PageControl 2 - Tipo - UEQ }
    pgcTipoUEQ      : TPageControl;
    tabLoteUEQ      : TTabSheet;
    tabIndividualUEQ: TTabSheet;

    { PageControl 3 - Situacao Lote - UEQ }
    pgcSitLoteUEQ : TPageControl;
    tabEnvLoteUEQ : TTabSheet;
    tabCancLoteUEQ: TTabSheet;

    { PageControl 3 - Situacao Individual - UEQ }
    pgcSitIndivUEQ : TPageControl;
    tabEnvIndivUEQ : TTabSheet;
    tabCancIndivUEQ: TTabSheet;

    { PageControl 2 - Tipo - Varjota }
    pgcTipoVarjota      : TPageControl;
    tabLoteVarjota      : TTabSheet;
    tabIndividualVarjota: TTabSheet;

    { PageControl 3 - Situacao Lote - Varjota }
    pgcSitLoteVarjota : TPageControl;
    tabEnvLoteVarjota : TTabSheet;
    tabCancLoteVarjota: TTabSheet;

    { PageControl 3 - Situacao Individual - Varjota }
    pgcSitIndivVarjota : TPageControl;
    tabEnvIndivVarjota : TTabSheet;
    tabCancIndivVarjota: TTabSheet;

    { PageControl 2 - Tipo - SeisBocas }
    pgcTipoSeisBocas      : TPageControl;
    tabLoteSeisBocas      : TTabSheet;
    tabIndividualSeisBocas: TTabSheet;

    { PageControl 3 - Situacao Lote - SeisBocas }
    pgcSitLoteSeisBocas : TPageControl;
    tabEnvLoteSeisBocas : TTabSheet;
    tabCancLoteSeisBocas: TTabSheet;

    { PageControl 3 - Situacao Individual - SeisBocas }
    pgcSitIndivSeisBocas : TPageControl;
    tabEnvIndivSeisBocas : TTabSheet;
    tabCancIndivSeisBocas: TTabSheet;

    { Grids }
    grdEnvLoteSede      : TDBGridEh;
    grdCancLoteSede     : TDBGridEh;
    grdEnvIndivSede     : TDBGridEh;
    grdEnvLoteUEQ       : TDBGridEh;
    grdCancLoteUEQ      : TDBGridEh;
    grdEnvIndivUEQ      : TDBGridEh;
    grdEnvLoteVarjota   : TDBGridEh;
    grdCancLoteVarjota  : TDBGridEh;
    grdEnvIndivVarjota  : TDBGridEh;
    grdEnvLoteSeisBocas : TDBGridEh;
    grdCancLoteSeisBocas: TDBGridEh;
    grdEnvIndivSeisBocas: TDBGridEh;

    { MemTables }
    mtEnvLoteSede      : TFDMemTable;
    mtCancLoteSede     : TFDMemTable;
    mtEnvIndivSede     : TFDMemTable;
    mtEnvLoteUEQ       : TFDMemTable;
    mtCancLoteUEQ      : TFDMemTable;
    mtEnvIndivUEQ      : TFDMemTable;
    mtEnvLoteVarjota   : TFDMemTable;
    mtCancLoteVarjota  : TFDMemTable;
    mtEnvIndivVarjota  : TFDMemTable;
    mtEnvLoteSeisBocas : TFDMemTable;
    mtCancLoteSeisBocas: TFDMemTable;
    mtEnvIndivSeisBocas: TFDMemTable;

    { DataSources }
    dsEnvLoteSede      : TDataSource;
    dsCancLoteSede     : TDataSource;
    dsEnvIndivSede     : TDataSource;
    dsEnvLoteUEQ       : TDataSource;
    dsCancLoteUEQ      : TDataSource;
    dsEnvIndivUEQ      : TDataSource;
    dsEnvLoteVarjota   : TDataSource;
    dsCancLoteVarjota  : TDataSource;
    dsEnvIndivVarjota  : TDataSource;
    dsEnvLoteSeisBocas : TDataSource;
    dsCancLoteSeisBocas: TDataSource;
    dsEnvIndivSeisBocas: TDataSource;

    { Sidebar }
    pnlSidebar      : TPanel;
    pnlSidebarTopo  : TPanel;
    pnlSidebarMenu  : TPanel;
    pnlSidebarRodape: TPanel;
    lblSideLogo     : TLabel;
    lblSideRodape   : TLabel;
    lblMenuSecao1   : TLabel;
    lblMenuSecao2   : TLabel;
    lblMenuSede     : TLabel;
    lblMenuUEQ      : TLabel;
    lblMenuVarjota  : TLabel;
    lblMenuSeisBocas: TLabel;
    lblMenuConfig   : TLabel;
    lblMenuSair     : TLabel;

    { StatusBar }
    pnlStatus: TPanel;
    lblStatus: TLabel;

    { Eventos }
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lblMenuConfigClick(Sender: TObject);
    procedure lblMenuSairClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure lblCardQtdEnvSedeClick(Sender: TObject);
    procedure lblCardQtdCancSedeClick(Sender: TObject);
    procedure lblCardQtdEnvUEQClick(Sender: TObject);
    procedure lblCardQtdCancUEQClick(Sender: TObject);
    procedure lblCardQtdEnvVarjotaClick(Sender: TObject);
    procedure lblCardQtdCancVarjotaClick(Sender: TObject);
    procedure lblCardQtdEnvSeisBocasClick(Sender: TObject);
    procedure lblCardQtdCancSeisBocasClick(Sender: TObject);
    procedure grdEnvLoteSedeCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
    procedure grdEnvLoteUEQCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
    procedure grdEnvLoteVarjotaCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
    procedure grdEnvLoteSeisBocasCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);

  private
    FController: IControllerPrincipal;

    procedure ConfigurarVisual;
    procedure ConfigurarCards;
    procedure ConfigurarMemTables;
    procedure ConfigurarGrids;
    procedure AtualizarCards;
    procedure AtualizarTodasAsGrids;
    procedure ExibirStatus(const AMensagem: string; const ACor: TColor);
    procedure AbrirUnidadeESituacao(const AUnidade: TNomeUnidade;
      const ASituacao: string);
    procedure AcionarCelula(const AGrid: TDBGridEh;
      const AUnidade: TNomeUnidade; const AColuna: TColumnEh);
    procedure AbrirTelaConfiguracoes;
    procedure InicializarMemTable(const AMt: TFDMemTable;
      const AComBotoes: Boolean);
    procedure VincularGrid(const AGrid: TDBGridEh; const ADs: TDataSource;
      const AMt: TFDMemTable; const AComBotoes: Boolean);
    procedure AplicarHoverMenu(const ALbl: TLabel; const AAtivo: Boolean);
    procedure SidebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SidebarMouseLeave(Sender: TObject);
    procedure CentralizarCards;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  System.IOUtils,
  Winapi.UxTheme,
  View.Configuracao;

{$R *.dfm}

const
  COR_TOPO    : TColor = $00B05820;
  COR_FUNDO   : TColor = $00F0F2F5;
  COR_CARD    : TColor = $00FFFFFF;
  COR_VERDE   : TColor = $002E7D32;
  COR_VERM    : TColor = $00C62828;
  COR_GRID_ODD: TColor = $00F8FAFC;
  COR_GRID_HDR: TColor = $00EEF2FF;
  COR_OK      : TColor = $00007700;

  NOMES_UNIDADE: array[TNomeUnidade] of string = (
    'SEDE', 'UEQ', 'Varjota', 'Seis Bocas');

  IDX_UNIDADE: array[TNomeUnidade] of Integer = (0, 1, 2, 3);

{ TFrmPrincipal }

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FController := TControllerPrincipal.Criar;
  FController.Inicializar;
  ConfigurarVisual;
  ConfigurarCards;
  ConfigurarMemTables;
  ConfigurarGrids;
  AtualizarCards;
  AtualizarTodasAsGrids;
  Self.OnResize := FormResize;
  ExibirStatus('Sistema iniciado. ' +
    FormatDateTime('dd/mm/yyyy hh:nn', Now), COR_OK);
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  FController := nil;
end;

{ ── Visual ──────────────────────────────────────────────────── }

procedure TFrmPrincipal.ConfigurarVisual;

  procedure DesativarTema(const ACtrl: TWinControl);
  begin
    SetWindowTheme(ACtrl.Handle, '', '');
  end;

begin
  { Cores definidas no DFM - nao sobrescrever aqui }
  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 9;

  { Desativar tema do Windows nos panels coloridos para as cores aparecerem }
  DesativarTema(pnlSidebar);
  DesativarTema(pnlSidebarTopo);
  DesativarTema(pnlSidebarMenu);
  DesativarTema(pnlSidebarRodape);
  DesativarTema(pnlTopo);
  DesativarTema(pnlCards);
  DesativarTema(pnlCardSede);
  DesativarTema(pnlCardUEQ);
  DesativarTema(pnlCardVarjota);
  DesativarTema(pnlCardSeisBocas);
  DesativarTema(pnlStatus);
  DesativarTema(pnlModoEnvio);

  pnlTopo.BevelOuter      := bvNone;
  pnlModoEnvio.BevelOuter := bvNone;
  pnlCards.BevelOuter     := bvNone;
  pnlStatus.BevelOuter    := bvNone;

  lblTitulo.Caption  := 'Monitor de Emissão de RPS';
  lblMesAno.Caption  := FormatDateTime('MMMM/YYYY', Now);

  rbEnviarLote.Caption       := '  Enviar em Lote';
  rbEnviarLote.Checked       := True;
  rbEnviarIndividual.Caption := '  Enviar Individual';

  btnAtualizar.Caption    := #$2635 + '  Atualizar';
  btnAtualizar.Flat       := True;
  btnAtualizar.Font.Color := clWhite;
  btnAtualizar.Font.Style := [fsBold];

  lblStatus.Caption      := 'Pronto.';
  pgcUnidades.Font.Style := [fsBold];

  { Hover: atribuir em cada label pois labels consomem evento do panel }
  lblMenuSede.OnMouseMove       := SidebarMouseMove;
  lblMenuSede.OnMouseLeave      := SidebarMouseLeave;
  lblMenuUEQ.OnMouseMove        := SidebarMouseMove;
  lblMenuUEQ.OnMouseLeave       := SidebarMouseLeave;
  lblMenuVarjota.OnMouseMove    := SidebarMouseMove;
  lblMenuVarjota.OnMouseLeave   := SidebarMouseLeave;
  lblMenuSeisBocas.OnMouseMove  := SidebarMouseMove;
  lblMenuSeisBocas.OnMouseLeave := SidebarMouseLeave;
  lblMenuConfig.OnMouseMove     := SidebarMouseMove;
  lblMenuConfig.OnMouseLeave    := SidebarMouseLeave;
  lblMenuSair.OnMouseMove       := SidebarMouseMove;
  lblMenuSair.OnMouseLeave      := SidebarMouseLeave;
end;

{ ── Cards ───────────────────────────────────────────────────── }

procedure TFrmPrincipal.ConfigurarCards;

  procedure Montar(const APnl: TPanel;
    const ANome, AEnvLbl, AEnvQtd, ACancLbl, ACancQtd: TLabel;
    const ATit: string);
  begin
    { Cor dos cards vem do DFM - nao sobrescrever }
    APnl.BevelOuter := bvNone;
    APnl.BevelInner := bvNone;
    ANome.Caption    := ATit;
    AEnvLbl.Caption  := 'Enviadas';
    AEnvQtd.Caption  := '0';
    AEnvQtd.Cursor   := crHandPoint;
    ACancLbl.Caption := 'Canceladas';
    ACancQtd.Caption := '0';
    ACancQtd.Cursor  := crHandPoint;
  end;

begin
  Montar(pnlCardSede,
    lblCardNomeSede,      lblCardEnvSede,      lblCardQtdEnvSede,
    lblCardCancSede,      lblCardQtdCancSede,      'SEDE');
  Montar(pnlCardUEQ,
    lblCardNomeUEQ,       lblCardEnvUEQ,       lblCardQtdEnvUEQ,
    lblCardCancUEQ,       lblCardQtdCancUEQ,       'UEQ');
  Montar(pnlCardVarjota,
    lblCardNomeVarjota,   lblCardEnvVarjota,   lblCardQtdEnvVarjota,
    lblCardCancVarjota,   lblCardQtdCancVarjota,   'Varjota');
  Montar(pnlCardSeisBocas,
    lblCardNomeSeisBocas, lblCardEnvSeisBocas, lblCardQtdEnvSeisBocas,
    lblCardCancSeisBocas, lblCardQtdCancSeisBocas, 'Seis Bocas');
end;

procedure TFrmPrincipal.AtualizarCards;
var
  LEst: TArrayEstatisticas;
begin
  FController.AtualizarCards;
  FController.ObterEstatisticas(LEst);
  lblCardQtdEnvSede.Caption       := LEst[nuSede].TotalEnviadas.ToString;
  lblCardQtdCancSede.Caption      := LEst[nuSede].TotalCanceladas.ToString;
  lblCardQtdEnvUEQ.Caption        := LEst[nuUEQ].TotalEnviadas.ToString;
  lblCardQtdCancUEQ.Caption       := LEst[nuUEQ].TotalCanceladas.ToString;
  lblCardQtdEnvVarjota.Caption    := LEst[nuVarjota].TotalEnviadas.ToString;
  lblCardQtdCancVarjota.Caption   := LEst[nuVarjota].TotalCanceladas.ToString;
  lblCardQtdEnvSeisBocas.Caption  := LEst[nuSeisBocas].TotalEnviadas.ToString;
  lblCardQtdCancSeisBocas.Caption := LEst[nuSeisBocas].TotalCanceladas.ToString;
end;

{ ── MemTables ───────────────────────────────────────────────── }

procedure TFrmPrincipal.InicializarMemTable(const AMt: TFDMemTable;
  const AComBotoes: Boolean);
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

procedure TFrmPrincipal.ConfigurarMemTables;
begin
  InicializarMemTable(mtEnvLoteSede,       True);
  InicializarMemTable(mtCancLoteSede,      False);
  InicializarMemTable(mtEnvIndivSede,      True);
  InicializarMemTable(mtEnvLoteUEQ,        True);
  InicializarMemTable(mtCancLoteUEQ,       False);
  InicializarMemTable(mtEnvIndivUEQ,       True);
  InicializarMemTable(mtEnvLoteVarjota,    True);
  InicializarMemTable(mtCancLoteVarjota,   False);
  InicializarMemTable(mtEnvIndivVarjota,   True);
  InicializarMemTable(mtEnvLoteSeisBocas,  True);
  InicializarMemTable(mtCancLoteSeisBocas, False);
  InicializarMemTable(mtEnvIndivSeisBocas, True);
end;

{ ── Grids ───────────────────────────────────────────────────── }

procedure TFrmPrincipal.VincularGrid(const AGrid: TDBGridEh;
  const ADs: TDataSource; const AMt: TFDMemTable; const AComBotoes: Boolean);
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
      LCol.FieldName := 'CodVerificacao'; LCol.Title.Caption := 'Cod. Verif.'; LCol.Width := 110;
      LCol := AGrid.Columns.Add;
      LCol.FieldName := 'AcaoCancelar';   LCol.Title.Caption := 'Cancelar';    LCol.Width := 90;
      LCol.CellButtons.Add;
      LCol := AGrid.Columns.Add;
      LCol.FieldName := 'AcaoDANFSe';     LCol.Title.Caption := 'DANFE';       LCol.Width := 90;
      LCol.CellButtons.Add;
    end;
    False: begin
      LCol := AGrid.Columns.Add;
      LCol.FieldName := 'Situacao'; LCol.Title.Caption := 'Situacao'; LCol.Width := 110;
    end;
  end;
end;

procedure TFrmPrincipal.ConfigurarGrids;
begin
  VincularGrid(grdEnvLoteSede,      dsEnvLoteSede,      mtEnvLoteSede,      True);
  grdEnvLoteSede.Columns[6].CellButtons[0].OnMouseClick := grdEnvLoteSedeCellButtonClick;
  grdEnvLoteSede.Columns[7].CellButtons[0].OnMouseClick := grdEnvLoteSedeCellButtonClick;

  VincularGrid(grdCancLoteSede,     dsCancLoteSede,     mtCancLoteSede,     False);
  VincularGrid(grdEnvIndivSede,     dsEnvIndivSede,     mtEnvIndivSede,     True);

  VincularGrid(grdEnvLoteUEQ,       dsEnvLoteUEQ,       mtEnvLoteUEQ,       True);
  grdEnvLoteUEQ.Columns[6].CellButtons[0].OnMouseClick := grdEnvLoteUEQCellButtonClick;
  grdEnvLoteUEQ.Columns[7].CellButtons[0].OnMouseClick := grdEnvLoteUEQCellButtonClick;

  VincularGrid(grdCancLoteUEQ,      dsCancLoteUEQ,      mtCancLoteUEQ,      False);
  VincularGrid(grdEnvIndivUEQ,      dsEnvIndivUEQ,      mtEnvIndivUEQ,      True);

  VincularGrid(grdEnvLoteVarjota,   dsEnvLoteVarjota,   mtEnvLoteVarjota,   True);
  grdEnvLoteVarjota.Columns[6].CellButtons[0].OnMouseClick := grdEnvLoteVarjotaCellButtonClick;
  grdEnvLoteVarjota.Columns[7].CellButtons[0].OnMouseClick := grdEnvLoteVarjotaCellButtonClick;

  VincularGrid(grdCancLoteVarjota,  dsCancLoteVarjota,  mtCancLoteVarjota,  False);
  VincularGrid(grdEnvIndivVarjota,  dsEnvIndivVarjota,  mtEnvIndivVarjota,  True);

  VincularGrid(grdEnvLoteSeisBocas,  dsEnvLoteSeisBocas,  mtEnvLoteSeisBocas,  True);
  grdEnvLoteSeisBocas.Columns[6].CellButtons[0].OnMouseClick := grdEnvLoteSeisBocasCellButtonClick;
  grdEnvLoteSeisBocas.Columns[7].CellButtons[0].OnMouseClick := grdEnvLoteSeisBocasCellButtonClick;

  VincularGrid(grdCancLoteSeisBocas, dsCancLoteSeisBocas, mtCancLoteSeisBocas, False);
  VincularGrid(grdEnvIndivSeisBocas, dsEnvIndivSeisBocas, mtEnvIndivSeisBocas, True);
end;

{ ── Atualizar ───────────────────────────────────────────────── }

procedure TFrmPrincipal.AtualizarTodasAsGrids;
begin
  FController.PreencherMemTable(mtEnvLoteSede,       nuSede,      'ENVIADA');
  FController.PreencherMemTable(mtCancLoteSede,      nuSede,      'CANCELADA');
  FController.PreencherMemTable(mtEnvIndivSede,      nuSede,      'ENVIADA');
  FController.PreencherMemTable(mtEnvLoteUEQ,        nuUEQ,       'ENVIADA');
  FController.PreencherMemTable(mtCancLoteUEQ,       nuUEQ,       'CANCELADA');
  FController.PreencherMemTable(mtEnvIndivUEQ,       nuUEQ,       'ENVIADA');
  FController.PreencherMemTable(mtEnvLoteVarjota,    nuVarjota,   'ENVIADA');
  FController.PreencherMemTable(mtCancLoteVarjota,   nuVarjota,   'CANCELADA');
  FController.PreencherMemTable(mtEnvIndivVarjota,   nuVarjota,   'ENVIADA');
  FController.PreencherMemTable(mtEnvLoteSeisBocas,  nuSeisBocas, 'ENVIADA');
  FController.PreencherMemTable(mtCancLoteSeisBocas, nuSeisBocas, 'CANCELADA');
  FController.PreencherMemTable(mtEnvIndivSeisBocas, nuSeisBocas, 'ENVIADA');
end;

{ ── Navegacao ───────────────────────────────────────────────── }

procedure TFrmPrincipal.AbrirUnidadeESituacao(const AUnidade: TNomeUnidade;
  const ASituacao: string);
var
  LPgcSit: array[TNomeUnidade] of TPageControl;
begin
  LPgcSit[nuSede]      := pgcSitLoteSede;
  LPgcSit[nuUEQ]       := pgcSitLoteUEQ;
  LPgcSit[nuVarjota]   := pgcSitLoteVarjota;
  LPgcSit[nuSeisBocas] := pgcSitLoteSeisBocas;

  pgcUnidades.ActivePageIndex          := IDX_UNIDADE[AUnidade];
  LPgcSit[AUnidade].ActivePageIndex    := Ord(not (ASituacao = 'ENVIADA'));
end;

procedure TFrmPrincipal.lblCardQtdEnvSedeClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuSede,      'ENVIADA');   end;
procedure TFrmPrincipal.lblCardQtdCancSedeClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuSede,      'CANCELADA'); end;
procedure TFrmPrincipal.lblCardQtdEnvUEQClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuUEQ,       'ENVIADA');   end;
procedure TFrmPrincipal.lblCardQtdCancUEQClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuUEQ,       'CANCELADA'); end;
procedure TFrmPrincipal.lblCardQtdEnvVarjotaClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuVarjota,   'ENVIADA');   end;
procedure TFrmPrincipal.lblCardQtdCancVarjotaClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuVarjota,   'CANCELADA'); end;
procedure TFrmPrincipal.lblCardQtdEnvSeisBocasClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuSeisBocas, 'ENVIADA');   end;
procedure TFrmPrincipal.lblCardQtdCancSeisBocasClick(Sender: TObject);
begin AbrirUnidadeESituacao(nuSeisBocas, 'CANCELADA'); end;

{ ── CellButtons ─────────────────────────────────────────────── }

procedure TFrmPrincipal.AcionarCelula(const AGrid: TDBGridEh;
  const AUnidade: TNomeUnidade; const AColuna: TColumnEh);
var
  LNumRps: string;
begin
  LNumRps := AGrid.DataSource.DataSet.FieldByName('NumeroRps').AsString;
  case AColuna.FieldName = 'AcaoCancelar' of
    True: FController.ExecutarCancelarRps(LNumRps, NOMES_UNIDADE[AUnidade]);
  end;
  case AColuna.FieldName = 'AcaoDANFSe' of
    True: FController.ExecutarBaixarDANFSe(LNumRps);
  end;
end;

procedure TFrmPrincipal.grdEnvLoteSedeCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
begin
  AcionarCelula(grdEnvLoteSede, nuSede, Column);
  Handled := True;
end;

procedure TFrmPrincipal.grdEnvLoteUEQCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
begin
  AcionarCelula(grdEnvLoteUEQ, nuUEQ, Column);
  Handled := True;
end;

procedure TFrmPrincipal.grdEnvLoteVarjotaCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
begin
  AcionarCelula(grdEnvLoteVarjota, nuVarjota, Column);
  Handled := True;
end;

procedure TFrmPrincipal.grdEnvLoteSeisBocasCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
begin
  AcionarCelula(grdEnvLoteSeisBocas, nuSeisBocas, Column);
  Handled := True;
end;

{ ── Menu ─────────────────────────────────────────────────────── }

procedure TFrmPrincipal.AbrirTelaConfiguracoes;
var
  LFrm: TFrmConfiguracao;
begin
  LFrm := TFrmConfiguracao.Create(Self);
  try
    LFrm.ShowModal;
    FController.RecarregarConfiguracao;
    AtualizarCards;
    AtualizarTodasAsGrids;
  finally
    LFrm.Free;
  end;
end;

procedure TFrmPrincipal.lblMenuConfigClick(Sender: TObject);
begin AbrirTelaConfiguracoes; end;

procedure TFrmPrincipal.lblMenuSairClick(Sender: TObject);
begin Close; end;


procedure TFrmPrincipal.btnAtualizarClick(Sender: TObject);
begin
  AtualizarCards;
  AtualizarTodasAsGrids;
  ExibirStatus('Atualizado em ' + TimeToStr(Now), COR_OK);
end;

procedure TFrmPrincipal.ExibirStatus(const AMensagem: string;
  const ACor: TColor);
begin
  lblStatus.Caption    := '  ' + AMensagem;
  lblStatus.Font.Color := ACor;
end;

{ ── Hover menus laterais ─────────────────────────────────────── }

procedure TFrmPrincipal.AplicarHoverMenu(const ALbl: TLabel;
  const AAtivo: Boolean);
const
  COR_SIDEBAR = 3359061; { slate-700 }
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

procedure TFrmPrincipal.SidebarMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LMenus: array[0..5] of TLabel;
  I: Integer;
begin
  { Sender É o label sob o mouse - ativar ele, desativar os outros }
  LMenus[0] := lblMenuSede;
  LMenus[1] := lblMenuUEQ;
  LMenus[2] := lblMenuVarjota;
  LMenus[3] := lblMenuSeisBocas;
  LMenus[4] := lblMenuConfig;
  LMenus[5] := lblMenuSair;
  for I := 0 to 5 do
    AplicarHoverMenu(LMenus[I], LMenus[I] = Sender);
end;

procedure TFrmPrincipal.SidebarMouseLeave(Sender: TObject);
var
  LMenus: array[0..5] of TLabel;
  I: Integer;
begin
  LMenus[0] := lblMenuSede;
  LMenus[1] := lblMenuUEQ;
  LMenus[2] := lblMenuVarjota;
  LMenus[3] := lblMenuSeisBocas;
  LMenus[4] := lblMenuConfig;
  LMenus[5] := lblMenuSair;
  for I := 0 to 5 do
    AplicarHoverMenu(LMenus[I], False);
end;

{ ── Centralizar Cards ───────────────────────────────────────── }

procedure TFrmPrincipal.CentralizarCards;
const
  CARD_W = 278;
  CARD_H = 116;
  GAP    = 16;
  N      = 4;
var
  LTotalW, LMargemLeft, LTop: Integer;
begin
  LTotalW     := N * CARD_W + (N - 1) * GAP;
  LMargemLeft := (pnlCards.Width - LTotalW) div 2;
  LTop        := (pnlCards.Height - CARD_H) div 2;

  pnlCardSede.SetBounds(LMargemLeft,                            LTop, CARD_W, CARD_H);
  pnlCardUEQ.SetBounds(LMargemLeft + (CARD_W + GAP),           LTop, CARD_W, CARD_H);
  pnlCardVarjota.SetBounds(LMargemLeft + 2 * (CARD_W + GAP),   LTop, CARD_W, CARD_H);
  pnlCardSeisBocas.SetBounds(LMargemLeft + 3 * (CARD_W + GAP), LTop, CARD_W, CARD_H);

  { Centralizar pnlModoEnvio no topo igual aos cards }
  pnlModoEnvio.Left := (pnlTopo.Width - pnlModoEnvio.Width) div 2;
end;

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
  CentralizarCards;
end;

end.
