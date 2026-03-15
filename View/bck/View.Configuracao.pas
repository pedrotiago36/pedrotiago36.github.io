unit View.Configuracao;
// Claude Code esteve aqui

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
  Model.IConfiguracaoSistema,
  Model.IGravarArquivos,
  Model.IRecuperarArquivos,
  Model.TConfiguracaoSistema,
  Model.TGravarArquivos,
  Model.TRecuperarArquivos;

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

    { Diretórios }
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

    { Thread }
    pnlThread        : TPanel;
    pnlThreadTopo    : TPanel;
    lblGrpThread     : TLabel;
    chbLigDesl_Thread: TCheckBox;

    { Separador }
    pnlSeparador     : TPanel;

    { Ações }
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
    FConfiguracao  : IConfiguracaoSistema;
    FGravarArquivos: IGravarArquivos;
    FRecuperar     : IRecuperarArquivos;

    procedure CarregarConfiguracao;
    procedure PreencherTelaComConfiguracao;
    procedure PreencherConfiguracaoComTela;
    procedure ExibirMensagemStatus(const AMensagem: string; const ACor: TColor);
    procedure SelecionarDiretorio(const AEdit: TEdit);
    procedure AtualizarCaptionThread;
    procedure AplicarEstiloVisual;
    procedure ConfigurarComponentes;
  public
  end;

var
  FrmConfiguracao: TFrmConfiguracao;

implementation

uses
  System.IOUtils,
  Winapi.UxTheme,
  Vcl.FileCtrl;

{$R *.dfm}

const
  COR_FUNDO_TOPO  : TColor = $00C87533;  { bronze escuro elegante }
  COR_FUNDO_FORM  : TColor = $00F5F5F5;  { cinza clarissimo       }
  COR_FUNDO_GRUPO : TColor = $00FFFFFF;
  COR_DESTAQUE    : TColor = $00B05820;  { laranja queimado        }
  COR_TEXTO_TOPO  : TColor = clWhite;
  COR_STATUS_OK   : TColor = $00007700;
  COR_STATUS_ERRO : TColor = clRed;

  CAPTION_THREAD_LIGADA   = '  ● Thread Ligada';
  CAPTION_THREAD_DESLIGADA= '  ○ Thread Desligada';

{ TFrmConfiguracao }

procedure TFrmConfiguracao.FormCreate(Sender: TObject);
begin
  FConfiguracao   := TConfiguracaoSistema.Criar;
  FGravarArquivos := TGravarArquivos.Criar;
  FRecuperar      := TRecuperarArquivos.Criar;

  AplicarEstiloVisual;
  ConfigurarComponentes;
  CarregarConfiguracao;
end;

procedure TFrmConfiguracao.AplicarEstiloVisual;

  procedure DesativarTema(const ACtrl: TWinControl);
  begin
    SetWindowTheme(ACtrl.Handle, '', '');
  end;

begin
  Self.Font.Name   := 'Segoe UI';
  Self.Font.Size   := 9;

  { Desativar tema nos painéis coloridos }
  DesativarTema(pnlTopo);
  DesativarTema(pnlConteudo);
  DesativarTema(pnlRodape);
  DesativarTema(pnlStatusBar);
  DesativarTema(pnlWebService);
  DesativarTema(pnlWebServiceTopo);
  DesativarTema(pnlDiretorios);
  DesativarTema(pnlDiretoiriosTopo);
  DesativarTema(pnlModoEnvio);
  DesativarTema(pnlModoEnvioTopo);
  DesativarTema(pnlThread);
  DesativarTema(pnlThreadTopo);

  lblStatus.Caption := 'Pronto.';
end;

procedure TFrmConfiguracao.ConfigurarComponentes;
begin
  btnDirEnviados.Hint := 'Selecionar diretório';
  btnDirEnviados.ShowHint := True;
  btnDirErro.Hint    := 'Selecionar diretório';
  btnDirErro.ShowHint := True;
  btnDirIni.Hint     := 'Selecionar diretório';
  btnDirIni.ShowHint := True;

  btnSalvar.Default  := True;
  AtualizarCaptionThread;
end;

procedure TFrmConfiguracao.AtualizarCaptionThread;
const
  ACaptions: array[Boolean] of string = (
    CAPTION_THREAD_DESLIGADA,
    CAPTION_THREAD_LIGADA
  );
  ACores: array[Boolean] of TColor = (
    clGray,
    $00007700
  );
begin
  chbLigDesl_Thread.Caption    := ACaptions[chbLigDesl_Thread.Checked];
  chbLigDesl_Thread.Font.Color := ACores[chbLigDesl_Thread.Checked];
end;

procedure TFrmConfiguracao.CarregarConfiguracao;
var
  LCaminhoIni: string;
begin
  LCaminhoIni := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Config');

  FRecuperar.RecuperarIni(FConfiguracao, LCaminhoIni);
  PreencherTelaComConfiguracao;
  ExibirMensagemStatus('Configuração carregada com sucesso.', COR_STATUS_OK);
end;

procedure TFrmConfiguracao.PreencherTelaComConfiguracao;
var
  LDados: TDadosConfiguracao;
begin
  FConfiguracao.PreencherDados(LDados);
  edtUrlHomologacao.Text     := LDados.UrlHomologacao;
  edtUrlProducao.Text        := LDados.UrlProducao;
  edtDirEnviados.Text        := LDados.DiretorioRpsEnviados;
  edtDirErro.Text            := LDados.DiretorioRpsErro;
  edtDirIni.Text             := LDados.DiretorioArquivoIni;
  chbLigDesl_Thread.Checked  := LDados.ThreadAtiva;
  AtualizarCaptionThread;
end;

procedure TFrmConfiguracao.PreencherConfiguracaoComTela;
var
  LDados: TDadosConfiguracao;
begin
  LDados.UrlHomologacao       := edtUrlHomologacao.Text;
  LDados.UrlProducao          := edtUrlProducao.Text;
  LDados.DiretorioRpsEnviados := edtDirEnviados.Text;
  LDados.DiretorioRpsErro     := edtDirErro.Text;
  LDados.DiretorioArquivoIni  := edtDirIni.Text;
  LDados.ThreadAtiva          := chbLigDesl_Thread.Checked;
  FConfiguracao.Atualizar(LDados);
end;

procedure TFrmConfiguracao.ExibirMensagemStatus(const AMensagem: string;
  const ACor: TColor);
begin
  lblStatus.Caption    := '  ' + AMensagem;
  lblStatus.Font.Color := ACor;
end;

procedure TFrmConfiguracao.SelecionarDiretorio(const AEdit: TEdit);
var
  LDiretorio: string;
begin
  LDiretorio := AEdit.Text;
  SelectDirectory('Selecione o diretório', '', LDiretorio,
    [sdNewFolder, sdShowShares, sdNewUI]);
  AEdit.Text := LDiretorio;
end;

{ Eventos }

procedure TFrmConfiguracao.btnSalvarClick(Sender: TObject);
begin
  PreencherConfiguracaoComTela;
  FGravarArquivos.GravarIni(FConfiguracao);
  ExibirMensagemStatus('Configuração salva com sucesso!', COR_STATUS_OK);
end;

procedure TFrmConfiguracao.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfiguracao.btnDirEnviadosClick(Sender: TObject);
begin
  SelecionarDiretorio(edtDirEnviados);
end;

procedure TFrmConfiguracao.btnDirErroClick(Sender: TObject);
begin
  SelecionarDiretorio(edtDirErro);
end;

procedure TFrmConfiguracao.btnDirIniClick(Sender: TObject);
begin
  SelecionarDiretorio(edtDirIni);
end;

procedure TFrmConfiguracao.chbLigDesl_ThreadClick(Sender: TObject);
begin
  AtualizarCaptionThread;
end;

end.
