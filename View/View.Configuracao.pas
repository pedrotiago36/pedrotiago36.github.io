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

    { Grupo WebService }
    grpWebService    : TGroupBox;
    lblHomologacao   : TLabel;
    edtUrlHomologacao: TEdit;
    lblProducao      : TLabel;
    edtUrlProducao   : TEdit;

    { Grupo Diretórios }
    grpDiretorios    : TGroupBox;
    lblDirEnviados   : TLabel;
    edtDirEnviados   : TEdit;
    btnDirEnviados   : TSpeedButton;
    lblDirErro       : TLabel;
    edtDirErro       : TEdit;
    btnDirErro       : TSpeedButton;
    lblDirIni        : TLabel;
    edtDirIni        : TEdit;
    btnDirIni        : TSpeedButton;

    { Thread }
    grpThread        : TGroupBox;
    chbLigDesl_Thread: TCheckBox;

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
begin
  Self.Color       := COR_FUNDO_FORM;
  Self.Font.Name   := 'Segoe UI';
  Self.Font.Size   := 9;
  Self.BorderStyle := bsSingle;
  Self.Position    := poScreenCenter;
  Self.Caption     := 'NFSe Serviço — Configuração';

  pnlTopo.Color      := COR_DESTAQUE;
  pnlTopo.Height     := 56;
  pnlTopo.Align      := alTop;
  pnlTopo.BevelOuter := bvNone;

  lblTitulo.Font.Color := COR_TEXTO_TOPO;
  lblTitulo.Font.Size  := 13;
  lblTitulo.Font.Style := [fsBold];
  lblTitulo.Caption    := '  NFSe — Configuração do Serviço';
  lblTitulo.Transparent := True;

  lblVersao.Font.Color := $00FFE0C0;
  lblVersao.Font.Size  := 8;
  lblVersao.Caption    := '  v1.0.0';
  lblVersao.Transparent := True;

  pnlRodape.Color      := $00E8E8E8;
  pnlRodape.Height     := 44;
  pnlRodape.Align      := alBottom;
  pnlRodape.BevelOuter := bvNone;

  pnlStatusBar.Color      := $00E0E0E0;
  pnlStatusBar.Height     := 24;
  pnlStatusBar.Align      := alBottom;
  pnlStatusBar.BevelOuter := bvNone;

  lblStatus.Font.Size  := 8;
  lblStatus.Caption    := 'Pronto.';
  lblStatus.Transparent := True;

  pnlConteudo.Color      := COR_FUNDO_FORM;
  pnlConteudo.BevelOuter := bvNone;
  pnlConteudo.Align      := alClient;
end;

procedure TFrmConfiguracao.ConfigurarComponentes;
begin
  { Grupos }
  grpWebService.Caption := ' Endereços dos WebServices ';
  grpWebService.Color   := COR_FUNDO_GRUPO;
  grpWebService.Font.Style := [fsBold];

  grpDiretorios.Caption := ' Diretórios de Armazenamento ';
  grpDiretorios.Color   := COR_FUNDO_GRUPO;
  grpDiretorios.Font.Style := [fsBold];

  grpThread.Caption := ' Controle de Thread ';
  grpThread.Color   := COR_FUNDO_GRUPO;
  grpThread.Font.Style := [fsBold];

  { Labels }
  lblHomologacao.Caption := 'URL Homologação:';
  lblProducao.Caption    := 'URL Produção:';
  lblDirEnviados.Caption := 'RPS Enviados:';
  lblDirErro.Caption     := 'RPS com Erro:';
  lblDirIni.Caption      := 'Arquivo .ini:';

  { Botões de diretório }
  btnDirEnviados.Caption := '...';
  btnDirEnviados.Hint    := 'Selecionar diretório';
  btnDirEnviados.ShowHint := True;

  btnDirErro.Caption := '...';
  btnDirErro.Hint    := 'Selecionar diretório';
  btnDirErro.ShowHint := True;

  btnDirIni.Caption := '...';
  btnDirIni.Hint    := 'Selecionar diretório';
  btnDirIni.ShowHint := True;

  { Checkbox thread }
  chbLigDesl_Thread.Font.Size  := 10;
  chbLigDesl_Thread.Font.Style := [fsBold];
  AtualizarCaptionThread;

  { Botões principais }
  btnSalvar.Caption  := '  Salvar';
  btnSalvar.Kind     := bkOK;
  btnSalvar.Default  := True;

  btnCancelar.Caption := '  Fechar';
  btnCancelar.Kind    := bkClose;
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
begin
  edtUrlHomologacao.Text := FConfiguracao.UrlHomologacao;
  edtUrlProducao.Text    := FConfiguracao.UrlProducao;
  edtDirEnviados.Text    := FConfiguracao.DiretorioRpsEnviados;
  edtDirErro.Text        := FConfiguracao.DiretorioRpsErro;
  edtDirIni.Text         := FConfiguracao.DiretorioArquivoIni;
  chbLigDesl_Thread.Checked := FConfiguracao.ThreadAtiva;
  AtualizarCaptionThread;
end;

procedure TFrmConfiguracao.PreencherConfiguracaoComTela;
begin
  FConfiguracao.AtualizarUrlHomologacao(edtUrlHomologacao.Text);
  FConfiguracao.AtualizarUrlProducao(edtUrlProducao.Text);
  FConfiguracao.AtualizarDiretorioRpsEnviados(edtDirEnviados.Text);
  FConfiguracao.AtualizarDiretorioRpsErro(edtDirErro.Text);
  FConfiguracao.AtualizarDiretorioArquivoIni(edtDirIni.Text);
  FConfiguracao.AtualizarThreadAtiva(chbLigDesl_Thread.Checked);
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
