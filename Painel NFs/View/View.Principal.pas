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
  { EhLib }
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
  Controller.TPrincipal,
  { Model }
  Model.IEstatisticasUnidade,
  Model.IMonitorNotificacao,
  Model.TMonitorNotificacao,
  { Utils }
  View.Utils.Principal,
  DBGridEhGrouping, DBGridEhToolCtrls, DynVarsEh,
  System.ImageList, Vcl.ImgList;

type
  TFrmPrincipal = class(TForm)

    { Topo }
    pnlTopo           : TPanel;
    lblTitulo         : TLabel;
    lblMesAno         : TLabel;
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
    pgcTipoEnvio     : TPageControl;
    tabLoteSede      : TTabSheet;
    tabIndividualSede: TTabSheet;

    { PageControl 3 - Situacao Lote - SEDE }
    pgcSituacao     : TPageControl;
    tabEnvLoteSede  : TTabSheet;
    tabCancLoteSede : TTabSheet;

    { PageControl 3 - Situacao Individual - SEDE }
    pgcSitIndivSede  : TPageControl;
    tabEnvIndivSede  : TTabSheet;
    tabCancIndivSede : TTabSheet;

    { PageControl 2 - Tipo - UEQ }
    pgcTipoUEQ      : TPageControl;
    tabLoteUEQ      : TTabSheet;
    tabIndividualUEQ: TTabSheet;

    { PageControl 3 - Situacao Lote - UEQ }
    pgcSitLoteUEQ  : TPageControl;
    tabEnvLoteUEQ  : TTabSheet;
    tabCancLoteUEQ : TTabSheet;

    { PageControl 3 - Situacao Individual - UEQ }
    pgcSitIndivUEQ  : TPageControl;
    tabEnvIndivUEQ  : TTabSheet;
    tabCancIndivUEQ : TTabSheet;

    { PageControl 2 - Tipo - Varjota }
    pgcTipoVarjota      : TPageControl;
    tabLoteVarjota      : TTabSheet;
    tabIndividualVarjota: TTabSheet;

    { PageControl 3 - Situacao Lote - Varjota }
    pgcSitLoteVarjota  : TPageControl;
    tabEnvLoteVarjota  : TTabSheet;
    tabCancLoteVarjota : TTabSheet;

    { PageControl 3 - Situacao Individual - Varjota }
    pgcSitIndivVarjota  : TPageControl;
    tabEnvIndivVarjota  : TTabSheet;
    tabCancIndivVarjota : TTabSheet;

    { PageControl 2 - Tipo - SeisBocas }
    pgcTipoSeisBocas      : TPageControl;
    tabLoteSeisBocas      : TTabSheet;
    tabIndividualSeisBocas: TTabSheet;

    { PageControl 3 - Situacao Lote - SeisBocas }
    pgcSitLoteSeisBocas  : TPageControl;
    tabEnvLoteSeisBocas  : TTabSheet;
    tabCancLoteSeisBocas : TTabSheet;

    { PageControl 3 - Situacao Individual - SeisBocas }
    pgcSitIndivSeisBocas  : TPageControl;
    tabEnvIndivSeisBocas  : TTabSheet;
    tabCancIndivSeisBocas : TTabSheet;

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
    pnlStatus      : TPanel;
    lblStatus      : TLabel;
    imgl_BotoesGrid: TImageList;

    { Eventos de form }
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);

    { Eventos de tab }
    procedure pgcUnidadesDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure pgcTipoEnvioDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure pgcSituacaoDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);

    { Eventos de menu }
    procedure lblMenuConfigClick(Sender: TObject);
    procedure lblMenuSairClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);

    { Eventos de cards }
    procedure lblCardQtdEnvSedeClick(Sender: TObject);
    procedure lblCardQtdCancSedeClick(Sender: TObject);
    procedure lblCardQtdEnvUEQClick(Sender: TObject);
    procedure lblCardQtdCancUEQClick(Sender: TObject);
    procedure lblCardQtdEnvVarjotaClick(Sender: TObject);
    procedure lblCardQtdCancVarjotaClick(Sender: TObject);
    procedure lblCardQtdEnvSeisBocasClick(Sender: TObject);
    procedure lblCardQtdCancSeisBocasClick(Sender: TObject);

    { Eventos de grid }
    procedure grdEnvLoteSedeCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
    procedure grdEnvLoteUEQCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
    procedure grdEnvLoteVarjotaCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
    procedure grdEnvLoteSeisBocasCellButtonClick(Grid: TCustomDBGridEh; Column: TColumnEh; CellButton: TDBGridCellButtonEh; MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint; ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);

    { Eventos de sidebar }
    procedure SidebarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SidebarMouseLeave(Sender: TObject);

  private
    FController: TControllerPrincipal;
    FMonitor   : IMonitorNotificacao;
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
  COR_OK: TColor = $00007700;

  NOMES_UNIDADE: array[TNomeUnidade] of string = (
    'SEDE', 'UEQ', 'Varjota', 'Seis Bocas');

{ ── Helpers internos de arquivo ────────────────────────────────── }

procedure AtualizarTudo(const AController: TControllerPrincipal;
  const AForm: TFrmPrincipal);
begin
  TViewUtilsPrincipal.AtualizarCards(AController,
    AForm.lblCardQtdEnvSede,      AForm.lblCardQtdCancSede,
    AForm.lblCardQtdEnvUEQ,       AForm.lblCardQtdCancUEQ,
    AForm.lblCardQtdEnvVarjota,   AForm.lblCardQtdCancVarjota,
    AForm.lblCardQtdEnvSeisBocas, AForm.lblCardQtdCancSeisBocas);

  TViewUtilsPrincipal.AtualizarTodasAsGrids(AController,
    [AForm.mtEnvLoteSede,    AForm.mtCancLoteSede,    AForm.mtEnvIndivSede,
     AForm.mtEnvLoteUEQ,     AForm.mtCancLoteUEQ,     AForm.mtEnvIndivUEQ,
     AForm.mtEnvLoteVarjota, AForm.mtCancLoteVarjota, AForm.mtEnvIndivVarjota,
     AForm.mtEnvLoteSeisBocas, AForm.mtCancLoteSeisBocas, AForm.mtEnvIndivSeisBocas],
    [nuSede,    nuSede,    nuSede,
     nuUEQ,     nuUEQ,     nuUEQ,
     nuVarjota, nuVarjota, nuVarjota,
     nuSeisBocas, nuSeisBocas, nuSeisBocas],
    ['ENVIADA', 'CANCELADA', 'ENVIADA',
     'ENVIADA', 'CANCELADA', 'ENVIADA',
     'ENVIADA', 'CANCELADA', 'ENVIADA',
     'ENVIADA', 'CANCELADA', 'ENVIADA']);
end;

procedure Navegar(const AUnidade: TNomeUnidade; const ASituacao: string;
  const AForm: TFrmPrincipal);
begin
  TViewUtilsPrincipal.AbrirUnidadeESituacao(AUnidade, ASituacao,
    AForm.pgcUnidades,
    AForm.pgcSituacao,    AForm.pgcSitLoteUEQ,
    AForm.pgcSitLoteVarjota, AForm.pgcSitLoteSeisBocas);
end;

{ ── Form ───────────────────────────────────────────────────────── }

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FController := TControllerPrincipal.Criar;
  FController.Inicializar;

  Self.Font.Name := 'Segoe UI';
  Self.Font.Size := 9;

  TViewUtilsPrincipal.DesativarTemasGerais(Self, [
    pnlSidebar, pnlSidebarTopo, pnlSidebarMenu, pnlSidebarRodape,
    pnlTopo, pnlCards,
    pnlCardSede, pnlCardUEQ, pnlCardVarjota, pnlCardSeisBocas,
    pnlStatus
  ]);

  pnlTopo.BevelOuter   := bvNone;
  pnlCards.BevelOuter  := bvNone;
  pnlStatus.BevelOuter := bvNone;

  lblTitulo.Caption       := 'Monitor de Emiss' + #227 + 'o de RPS';
  lblMesAno.Caption       := FormatDateTime('MMMM/YYYY', Now);
  btnAtualizar.Caption    := #$2635 + '  Atualizar';
  btnAtualizar.Flat       := True;
  btnAtualizar.Font.Style := [fsBold];
  lblStatus.Caption       := 'Pronto.';
  pgcUnidades.Font.Style  := [fsBold];

  TViewUtilsPrincipal.MontarCard(pnlCardSede,
    lblCardNomeSede, lblCardEnvSede, lblCardQtdEnvSede,
    lblCardCancSede, lblCardQtdCancSede, 'SEDE');
  TViewUtilsPrincipal.MontarCard(pnlCardUEQ,
    lblCardNomeUEQ, lblCardEnvUEQ, lblCardQtdEnvUEQ,
    lblCardCancUEQ, lblCardQtdCancUEQ, 'UEQ');
  TViewUtilsPrincipal.MontarCard(pnlCardVarjota,
    lblCardNomeVarjota, lblCardEnvVarjota, lblCardQtdEnvVarjota,
    lblCardCancVarjota, lblCardQtdCancVarjota, 'Varjota');
  TViewUtilsPrincipal.MontarCard(pnlCardSeisBocas,
    lblCardNomeSeisBocas, lblCardEnvSeisBocas, lblCardQtdEnvSeisBocas,
    lblCardCancSeisBocas, lblCardQtdCancSeisBocas, 'Seis Bocas');

  TViewUtilsPrincipal.InicializarMemTable(mtEnvLoteSede,       True);
  TViewUtilsPrincipal.InicializarMemTable(mtCancLoteSede,      False);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvIndivSede,      True);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvLoteUEQ,        True);
  TViewUtilsPrincipal.InicializarMemTable(mtCancLoteUEQ,       False);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvIndivUEQ,       True);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvLoteVarjota,    True);
  TViewUtilsPrincipal.InicializarMemTable(mtCancLoteVarjota,   False);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvIndivVarjota,   True);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvLoteSeisBocas,  True);
  TViewUtilsPrincipal.InicializarMemTable(mtCancLoteSeisBocas, False);
  TViewUtilsPrincipal.InicializarMemTable(mtEnvIndivSeisBocas, True);

  TViewUtilsPrincipal.VincularGrid(grdEnvLoteSede,      dsEnvLoteSede,      mtEnvLoteSede,      True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdCancLoteSede,     dsCancLoteSede,     mtCancLoteSede,     False, imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvIndivSede,     dsEnvIndivSede,     mtEnvIndivSede,     True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvLoteUEQ,       dsEnvLoteUEQ,       mtEnvLoteUEQ,       True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdCancLoteUEQ,      dsCancLoteUEQ,      mtCancLoteUEQ,      False, imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvIndivUEQ,      dsEnvIndivUEQ,      mtEnvIndivUEQ,      True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvLoteVarjota,   dsEnvLoteVarjota,   mtEnvLoteVarjota,   True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdCancLoteVarjota,  dsCancLoteVarjota,  mtCancLoteVarjota,  False, imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvIndivVarjota,  dsEnvIndivVarjota,  mtEnvIndivVarjota,  True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvLoteSeisBocas,  dsEnvLoteSeisBocas,  mtEnvLoteSeisBocas,  True,  imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdCancLoteSeisBocas, dsCancLoteSeisBocas, mtCancLoteSeisBocas, False, imgl_BotoesGrid);
  TViewUtilsPrincipal.VincularGrid(grdEnvIndivSeisBocas, dsEnvIndivSeisBocas, mtEnvIndivSeisBocas, True,  imgl_BotoesGrid);

  grdEnvLoteSede.Columns[6].CellButtons[0].OnMouseClick      := grdEnvLoteSedeCellButtonClick;
  grdEnvLoteSede.Columns[6].CellButtons[1].OnMouseClick      := grdEnvLoteSedeCellButtonClick;
  grdEnvIndivSede.Columns[6].CellButtons[0].OnMouseClick     := grdEnvLoteSedeCellButtonClick;
  grdEnvIndivSede.Columns[6].CellButtons[1].OnMouseClick     := grdEnvLoteSedeCellButtonClick;
  grdEnvLoteUEQ.Columns[6].CellButtons[0].OnMouseClick       := grdEnvLoteUEQCellButtonClick;
  grdEnvLoteUEQ.Columns[6].CellButtons[1].OnMouseClick       := grdEnvLoteUEQCellButtonClick;
  grdEnvIndivUEQ.Columns[6].CellButtons[0].OnMouseClick      := grdEnvLoteUEQCellButtonClick;
  grdEnvIndivUEQ.Columns[6].CellButtons[1].OnMouseClick      := grdEnvLoteUEQCellButtonClick;
  grdEnvLoteVarjota.Columns[6].CellButtons[0].OnMouseClick   := grdEnvLoteVarjotaCellButtonClick;
  grdEnvLoteVarjota.Columns[6].CellButtons[1].OnMouseClick   := grdEnvLoteVarjotaCellButtonClick;
  grdEnvIndivVarjota.Columns[6].CellButtons[0].OnMouseClick  := grdEnvLoteVarjotaCellButtonClick;
  grdEnvIndivVarjota.Columns[6].CellButtons[1].OnMouseClick  := grdEnvLoteVarjotaCellButtonClick;
  grdEnvLoteSeisBocas.Columns[6].CellButtons[0].OnMouseClick  := grdEnvLoteSeisBocasCellButtonClick;
  grdEnvLoteSeisBocas.Columns[6].CellButtons[1].OnMouseClick  := grdEnvLoteSeisBocasCellButtonClick;
  grdEnvIndivSeisBocas.Columns[6].CellButtons[0].OnMouseClick := grdEnvLoteSeisBocasCellButtonClick;
  grdEnvIndivSeisBocas.Columns[6].CellButtons[1].OnMouseClick := grdEnvLoteSeisBocasCellButtonClick;

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

  TViewUtilsPrincipal.CentralizarCards(pnlCards,
    [pnlCardSede, pnlCardUEQ, pnlCardVarjota, pnlCardSeisBocas]);

  AtualizarTudo(FController, Self);

  { Inicia monitor de notificacao do servico de envio }
  FMonitor := TMonitorNotificacao.Criar;
  FMonitor.Iniciar;

  Self.OnResize := FormResize;
  TViewUtilsPrincipal.ExibirStatus(lblStatus,
    'Sistema iniciado. ' + FormatDateTime('dd/mm/yyyy hh:nn', Now), COR_OK);
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  FMonitor.Parar;
  FMonitor   := nil;
  FController := nil;
end;

{ ── Cards ──────────────────────────────────────────────────────── }

procedure TFrmPrincipal.lblCardQtdEnvSedeClick(Sender: TObject);
begin Navegar(nuSede,      'ENVIADA',   Self); end;
procedure TFrmPrincipal.lblCardQtdCancSedeClick(Sender: TObject);
begin Navegar(nuSede,      'CANCELADA', Self); end;
procedure TFrmPrincipal.lblCardQtdEnvUEQClick(Sender: TObject);
begin Navegar(nuUEQ,       'ENVIADA',   Self); end;
procedure TFrmPrincipal.lblCardQtdCancUEQClick(Sender: TObject);
begin Navegar(nuUEQ,       'CANCELADA', Self); end;
procedure TFrmPrincipal.lblCardQtdEnvVarjotaClick(Sender: TObject);
begin Navegar(nuVarjota,   'ENVIADA',   Self); end;
procedure TFrmPrincipal.lblCardQtdCancVarjotaClick(Sender: TObject);
begin Navegar(nuVarjota,   'CANCELADA', Self); end;
procedure TFrmPrincipal.lblCardQtdEnvSeisBocasClick(Sender: TObject);
begin Navegar(nuSeisBocas, 'ENVIADA',   Self); end;
procedure TFrmPrincipal.lblCardQtdCancSeisBocasClick(Sender: TObject);
begin Navegar(nuSeisBocas, 'CANCELADA', Self); end;

{ ── CellButtons ─────────────────────────────────────────────────── }

procedure TFrmPrincipal.grdEnvLoteSedeCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
var
  LNumRps: string;
begin
  LNumRps := Grid.DataSource.DataSet.FieldByName('NumeroRps').AsString;
  case CellButton.Index of
    0: FController.ExecutarCancelarRps(LNumRps, NOMES_UNIDADE[nuSede]);
    1: FController.ExecutarBaixarDANFSe(LNumRps);
  end;
  Handled := True;
end;

procedure TFrmPrincipal.grdEnvLoteUEQCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
var
  LNumRps: string;
begin
  LNumRps := Grid.DataSource.DataSet.FieldByName('NumeroRps').AsString;
  case CellButton.Index of
    0: FController.ExecutarCancelarRps(LNumRps, NOMES_UNIDADE[nuUEQ]);
    1: FController.ExecutarBaixarDANFSe(LNumRps);
  end;
  Handled := True;
end;

procedure TFrmPrincipal.grdEnvLoteVarjotaCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
var
  LNumRps: string;
begin
  LNumRps := Grid.DataSource.DataSet.FieldByName('NumeroRps').AsString;
  case CellButton.Index of
    0: FController.ExecutarCancelarRps(LNumRps, NOMES_UNIDADE[nuVarjota]);
    1: FController.ExecutarBaixarDANFSe(LNumRps);
  end;
  Handled := True;
end;

procedure TFrmPrincipal.grdEnvLoteSeisBocasCellButtonClick(Grid: TCustomDBGridEh;
  Column: TColumnEh; CellButton: TDBGridCellButtonEh;
  MouseButton: TMouseButton; Shift: TShiftState; InButtonPos: TPoint;
  ButtonMouseParams: TCellButtonMouseParamsEh; var Handled: Boolean);
var
  LNumRps: string;
begin
  LNumRps := Grid.DataSource.DataSet.FieldByName('NumeroRps').AsString;
  case CellButton.Index of
    0: FController.ExecutarCancelarRps(LNumRps, NOMES_UNIDADE[nuSeisBocas]);
    1: FController.ExecutarBaixarDANFSe(LNumRps);
  end;
  Handled := True;
end;

{ ── Menu ────────────────────────────────────────────────────────── }

procedure TFrmPrincipal.lblMenuConfigClick(Sender: TObject);
var
  LFrm: TFrmConfiguracao;
begin
  LFrm := TFrmConfiguracao.Create(Self);
  try
    LFrm.ShowModal;
    FController.RecarregarConfiguracao;
    AtualizarTudo(FController, Self);
  finally
    LFrm.Free;
  end;
end;

procedure TFrmPrincipal.lblMenuSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.btnAtualizarClick(Sender: TObject);
begin
  AtualizarTudo(FController, Self);
  TViewUtilsPrincipal.ExibirStatus(lblStatus,
    'Atualizado em ' + TimeToStr(Now), COR_OK);
end;

{ ── Sidebar ─────────────────────────────────────────────────────── }

procedure TFrmPrincipal.SidebarMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  TViewUtilsPrincipal.SidebarAtivarLabel(Sender,
    TViewUtilsPrincipal.MenuLabels(
      lblMenuSede, lblMenuUEQ, lblMenuVarjota,
      lblMenuSeisBocas, lblMenuConfig, lblMenuSair));
end;

procedure TFrmPrincipal.SidebarMouseLeave(Sender: TObject);
begin
  TViewUtilsPrincipal.SidebarDesativarTodos(
    TViewUtilsPrincipal.MenuLabels(
      lblMenuSede, lblMenuUEQ, lblMenuVarjota,
      lblMenuSeisBocas, lblMenuConfig, lblMenuSair));
end;

{ ── Resize ──────────────────────────────────────────────────────── }

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
  TViewUtilsPrincipal.CentralizarCards(pnlCards,
    [pnlCardSede, pnlCardUEQ, pnlCardVarjota, pnlCardSeisBocas]);
end;

{ ── DrawTab ─────────────────────────────────────────────────────── }

procedure TFrmPrincipal.pgcUnidadesDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
begin
  TViewUtilsPrincipal.DrawTabUnidades(Control, TabIndex, Rect, Active);
end;

procedure TFrmPrincipal.pgcTipoEnvioDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
begin
  TViewUtilsPrincipal.DrawTabTipoEnvio(Control, TabIndex, Rect, Active);
end;

procedure TFrmPrincipal.pgcSituacaoDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
begin
  TViewUtilsPrincipal.DrawTabSituacao(Control, TabIndex, Rect, Active);
end;

end.
