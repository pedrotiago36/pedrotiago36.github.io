unit View.Configuracao;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  { Controller }
  Controller.IConfiguracaoView,
  Controller.TConfiguracaoView;

type
  TFrmConfiguracao = class(TForm)
    pnlTopo          : TPanel;
    pnlRodape        : TPanel;
    pnlConteudo      : TPanel;
    lblTitulo        : TLabel;
    lblVersao        : TLabel;

    { Grupos ocultos - mantidos para compatibilidade DFM }
    grpWebService    : TGroupBox;
    grpDiretorios    : TGroupBox;
    grpThread        : TGroupBox;

    { WebService }
    pnlWebService    : TPanel;
    pnlWebServiceTopo: TPanel;
    lblGrpWebService : TLabel;
    lblHomologacao   : TLabel;
    edtUrlHomologacao: TEdit;
    lblProducao      : TLabel;
    edtUrlProducao   : TEdit;

    { Diret�rios }
    pnlDiretorios      : TPanel;
    pnlDiretoiriosTopo : TPanel;
    lblGrpDiretorios   : TLabel;
    lblDirEnviados     : TLabel;
    edtDirEnviados     : TEdit;
    btnDirEnviados     : TSpeedButton;
    lblDirErro         : TLabel;
    edtDirErro         : TEdit;
    btnDirErro         : TSpeedButton;
    lblDirIni          : TLabel;
    edtDirIni          : TEdit;
    btnDirIni          : TSpeedButton;

    { Modo de Envio }
    pnlModoEnvio     : TPanel;
    pnlModoEnvioTopo : TPanel;
    lblGrpModoEnvio  : TLabel;
    rbEnviarLote     : TRadioButton;
    rbEnviarIndividual: TRadioButton;
    lblDataEnvio     : TLabel;
    edtDataEnvio     : TEdit;

    { Thread }
    pnlThread        : TPanel;
    pnlThreadTopo    : TPanel;
    lblGrpThread     : TLabel;
    chbLigDesl_Thread: TCheckBox;

    { Separador }
    pnlSeparador     : TPanel;

    { A��es }
    btnSalvar        : TBitBtn;
    btnCancelar      : TBitBtn;

    pnlStatusBar     : TPanel;
    lblStatus        : TLabel;

    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnDirEnviadosClick(Sender: TObject);
    procedure btnDirErroClick(Sender: TObject);
    procedure btnDirIniClick(Sender: TObject);
    procedure chbLigDesl_ThreadClick(Sender: TObject);

  private
    FController: IControllerConfiguracaoView;
  public
  end;

var
  FrmConfiguracao: TFrmConfiguracao;

implementation

uses
  System.IOUtils,
  Winapi.UxTheme;

{$R *.dfm}

const
  COR_STATUS_OK  : TColor = $00007700;
  COR_STATUS_ERRO: TColor = clRed;

{ TFrmConfiguracao }

procedure TFrmConfiguracao.FormCreate(Sender: TObject);
begin
  FController := TControllerConfiguracaoView.Criar(
    TPath.Combine(ExtractFilePath(ParamStr(0)), 'Config'));
  FController.Inicializar;
  FController.PreencherTela(
    edtUrlHomologacao, edtUrlProducao,
    edtDirEnviados, edtDirErro, edtDirIni, edtDataEnvio,
    chbLigDesl_Thread);
  FController.ExibirMensagemStatus(lblStatus,
    'Configura' + #231 + #227 + 'o carregada com sucesso.', COR_STATUS_OK);
end;

procedure TFrmConfiguracao.btnSalvarClick(Sender: TObject);
begin
  FController.ColetarTela(
    edtUrlHomologacao, edtUrlProducao,
    edtDirEnviados, edtDirErro, edtDirIni, edtDataEnvio,
    chbLigDesl_Thread);
  FController.Salvar;
  FController.ExibirMensagemStatus(lblStatus,
    'Configura' + #231 + #227 + 'o salva com sucesso!', COR_STATUS_OK);
end;

procedure TFrmConfiguracao.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfiguracao.btnDirEnviadosClick(Sender: TObject);
begin
  FController.SelecionarDiretorio(edtDirEnviados);
end;

procedure TFrmConfiguracao.btnDirErroClick(Sender: TObject);
begin
  FController.SelecionarDiretorio(edtDirErro);
end;

procedure TFrmConfiguracao.btnDirIniClick(Sender: TObject);
begin
  FController.SelecionarDiretorio(edtDirIni);
end;

procedure TFrmConfiguracao.chbLigDesl_ThreadClick(Sender: TObject);
begin
  FController.AtualizarCaptionThread(chbLigDesl_Thread);
end;

end.
