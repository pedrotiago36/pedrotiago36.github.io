unit Controller.TConfiguracaoView;

interface

uses
  Controller.IConfiguracaoView,
  Model.IConfiguracaoSistema,
  Model.IGravarArquivos,
  Model.IRecuperarArquivos,
  Model.TConfiguracaoSistema,
  Model.TGravarArquivos,
  Model.TRecuperarArquivos,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics;

type
  TControllerConfiguracaoView = class(TInterfacedObject, IControllerConfiguracaoView)
  private
    FConfiguracao  : IConfiguracaoSistema;
    FGravar        : IGravarArquivos;
    FRecuperar     : IRecuperarArquivos;
    FCaminhoIni    : string;
  public
    constructor Create(const ACaminhoIni: string);
    procedure Inicializar;
    procedure Salvar;
    procedure SelecionarDiretorio(const AEdit: TEdit);
    procedure AtualizarCaptionThread(const ACheck: TCheckBox);
    procedure PreencherTela(const AEdtUrlHomologacao, AEdtUrlProducao,
      AEdtDirEnviados, AEdtDirErro, AEdtDirIni, AEdtDataEnvio: TEdit;
      const AChbThread: TCheckBox);
    procedure ColetarTela(const AEdtUrlHomologacao, AEdtUrlProducao,
      AEdtDirEnviados, AEdtDirErro, AEdtDirIni, AEdtDataEnvio: TEdit;
      const AChbThread: TCheckBox);
    procedure ExibirMensagemStatus(const ALbl: TLabel;
      const AMensagem: string; const ACor: TColor);
    class function Criar(const ACaminhoIni: string): IControllerConfiguracaoView;
  end;

implementation

uses
  System.SysUtils,
  Vcl.FileCtrl;

const
  CAPTION_THREAD_LIGADA    = '  ' + #9679 + ' Thread Ligada';
  CAPTION_THREAD_DESLIGADA = '  ' + #9675 + ' Thread Desligada';

  CAPTIONS_THREAD: array[Boolean] of string = (
    CAPTION_THREAD_DESLIGADA,
    CAPTION_THREAD_LIGADA
  );
  CORES_THREAD: array[Boolean] of TColor = (
    clGray,
    $00007700
  );

class function TControllerConfiguracaoView.Criar(
  const ACaminhoIni: string): IControllerConfiguracaoView;
begin
  Result := TControllerConfiguracaoView.Create(ACaminhoIni);
end;

constructor TControllerConfiguracaoView.Create(const ACaminhoIni: string);
begin
  inherited Create;
  FCaminhoIni   := ACaminhoIni;
  FConfiguracao := TConfiguracaoSistema.Criar;
  FGravar       := TGravarArquivos.Criar;
  FRecuperar    := TRecuperarArquivos.Criar;
end;

procedure TControllerConfiguracaoView.Inicializar;
begin
  FRecuperar.RecuperarIni(FConfiguracao, FCaminhoIni);
end;

procedure TControllerConfiguracaoView.Salvar;
begin
  FGravar.GravarIni(FConfiguracao);
end;

procedure TControllerConfiguracaoView.SelecionarDiretorio(const AEdit: TEdit);
var
  LDiretorio: string;
begin
  LDiretorio := AEdit.Text;
  SelectDirectory('Selecione o diret' + #243 + 'rio', '', LDiretorio,
    [sdNewFolder, sdShowShares, sdNewUI]);
  AEdit.Text := LDiretorio;
end;

procedure TControllerConfiguracaoView.AtualizarCaptionThread(
  const ACheck: TCheckBox);
begin
  ACheck.Caption    := CAPTIONS_THREAD[ACheck.Checked];
  ACheck.Font.Color := CORES_THREAD[ACheck.Checked];
end;

procedure TControllerConfiguracaoView.PreencherTela(
  const AEdtUrlHomologacao, AEdtUrlProducao, AEdtDirEnviados, AEdtDirErro,
  AEdtDirIni, AEdtDataEnvio: TEdit; const AChbThread: TCheckBox);
var
  LDados: TDadosConfiguracao;
begin
  FConfiguracao.PreencherDados(LDados);
  AEdtUrlHomologacao.Text := LDados.UrlHomologacao;
  AEdtUrlProducao.Text    := LDados.UrlProducao;
  AEdtDirEnviados.Text    := LDados.DiretorioRpsEnviados;
  AEdtDirErro.Text        := LDados.DiretorioRpsErro;
  AEdtDirIni.Text         := LDados.DiretorioArquivoIni;
  AChbThread.Checked      := LDados.ThreadAtiva;
  AEdtDataEnvio.Text      := LDados.DataEnvio;
  AtualizarCaptionThread(AChbThread);
end;

procedure TControllerConfiguracaoView.ColetarTela(
  const AEdtUrlHomologacao, AEdtUrlProducao, AEdtDirEnviados, AEdtDirErro,
  AEdtDirIni, AEdtDataEnvio: TEdit; const AChbThread: TCheckBox);
var
  LDados: TDadosConfiguracao;
begin
  LDados.UrlHomologacao       := AEdtUrlHomologacao.Text;
  LDados.UrlProducao          := AEdtUrlProducao.Text;
  LDados.DiretorioRpsEnviados := AEdtDirEnviados.Text;
  LDados.DiretorioRpsErro     := AEdtDirErro.Text;
  LDados.DiretorioArquivoIni  := AEdtDirIni.Text;
  LDados.ThreadAtiva          := AChbThread.Checked;
  LDados.DataEnvio            := AEdtDataEnvio.Text;
  FConfiguracao.Atualizar(LDados);
end;

procedure TControllerConfiguracaoView.ExibirMensagemStatus(const ALbl: TLabel;
  const AMensagem: string; const ACor: TColor);
begin
  ALbl.Caption    := '  ' + AMensagem;
  ALbl.Font.Color := ACor;
end;

end.
