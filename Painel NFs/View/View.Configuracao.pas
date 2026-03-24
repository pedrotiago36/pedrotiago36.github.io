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
    rbHomologacao    : TRadioButton;
    pnlBordaHomolog  : TPanel;
    edtUrlHomologacao: TEdit;
    lblProducao      : TLabel;
    rbProducao       : TRadioButton;
    pnlBordaProducao : TPanel;
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
    lblDirCancelados   : TLabel;
    edtDirCancelados   : TEdit;
    btnDirCancelados   : TSpeedButton;
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
    procedure btnDirCanceladosClick(Sender: TObject);
    procedure btnDirIniClick(Sender: TObject);
    procedure chbLigDesl_ThreadClick(Sender: TObject);
    procedure rbHomologacaoClick(Sender: TObject);
    procedure rbProducaoClick(Sender: TObject);

  private
    FController: IControllerConfiguracaoView;
  public
  end;

var
  FrmConfiguracao: TFrmConfiguracao;

implementation

uses
  System.IOUtils,
  //System.SysUtils,
  Winapi.UxTheme;

{$R *.dfm}

const
  COR_STATUS_OK  : TColor = $00007700;
  COR_STATUS_ERRO: TColor = clRed;

procedure TFrmConfiguracao.FormCreate(Sender: TObject);
var
  LCaminhoConfig: string;

  function EncontrarConfig: string;
  var
    LBase, LTentativa: string;
    I: Integer;
  begin
    Result := '';
    LBase  := ExtractFilePath(ParamStr(0));

    { Tenta subindo até 5 níveis }
    for I := 0 to 5 do
    begin
      { 1o — mesma pasta do exe }
      LTentativa := LBase;
      case TFile.Exists(TPath.Combine(LTentativa, 'NFSe_Servico.ini')) of
        True: begin Result := LTentativa; Exit; end;
      end;

      { 2o — subpasta exe\Config (IDE) }
      LTentativa := TPath.Combine(TPath.Combine(LBase, 'exe'), 'Config');
      case TFile.Exists(TPath.Combine(LTentativa, 'NFSe_Servico.ini')) of
        True: begin Result := LTentativa; Exit; end;
      end;

      LBase := TPath.GetFullPath(TPath.Combine(LBase, '..'));
    end;

    { Fallback: mesma pasta do exe }
    Result := ExtractFilePath(ParamStr(0));
  end;

begin
  LCaminhoConfig := EncontrarConfig;
  FController := TControllerConfiguracaoView.Criar(LCaminhoConfig);
  FController.Inicializar;
  FController.PreencherTela(
    edtUrlHomologacao, edtUrlProducao,
    edtDirEnviados, edtDirErro, edtDirCancelados, edtDirIni, edtDataEnvio,
    chbLigDesl_Thread,
    rbHomologacao, rbProducao,
    pnlBordaHomolog, pnlBordaProducao,
    rbEnviarLote, rbEnviarIndividual);
  case TFile.Exists(TPath.Combine(LCaminhoConfig, 'NFSe_Servico.ini')) of
    True : FController.ExibirMensagemStatus(lblStatus,
             'Configura' + #231 + #227 + 'o carregada com sucesso.', COR_STATUS_OK);
    False: FController.ExibirMensagemStatus(lblStatus,
             'INI NAO ENCONTRADO em: ' + LCaminhoConfig, COR_STATUS_ERRO);
  end;
end;

procedure TFrmConfiguracao.btnSalvarClick(Sender: TObject);
begin
  FController.ColetarTela(
    edtUrlHomologacao, edtUrlProducao,
    edtDirEnviados, edtDirErro, edtDirCancelados, edtDirIni, edtDataEnvio,
    chbLigDesl_Thread, rbHomologacao, rbEnviarLote);
  FController.Salvar;
  FController.ExibirMensagemStatus(lblStatus,
    'Configura' + #231 + #227 + 'o salva com sucesso!', COR_STATUS_OK);
end;

procedure TFrmConfiguracao.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfiguracao.rbHomologacaoClick(Sender: TObject);
begin
  FController.AtualizarAmbiente(rbHomologacao, rbProducao,
    pnlBordaHomolog, pnlBordaProducao);
end;

procedure TFrmConfiguracao.rbProducaoClick(Sender: TObject);
begin
  FController.AtualizarAmbiente(rbHomologacao, rbProducao,
    pnlBordaHomolog, pnlBordaProducao);
end;

procedure TFrmConfiguracao.btnDirEnviadosClick(Sender: TObject);
begin
  FController.SelecionarDiretorio(edtDirEnviados);
end;

procedure TFrmConfiguracao.btnDirErroClick(Sender: TObject);
begin
  FController.SelecionarDiretorio(edtDirErro);
end;

procedure TFrmConfiguracao.btnDirCanceladosClick(Sender: TObject);
begin
  FController.SelecionarDiretorio(edtDirCancelados);
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
