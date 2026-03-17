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
    FConfiguracao : IConfiguracaoSistema;
    FGravar       : IGravarArquivos;
    FRecuperar    : IRecuperarArquivos;
    FCaminhoIni   : string;
  public
    constructor Create(const ACaminhoIni: string);
    procedure Inicializar;
    procedure Salvar;
    procedure SelecionarDiretorio(const AEdit: TEdit);
    procedure AtualizarCaptionThread(const ACheck: TCheckBox);
    procedure AtualizarAmbiente(const ARbHomologacao, ARbProducao: TRadioButton;
      const APnlHomologacao, APnlProducao: TPanel);
    procedure PreencherTela(const AEdtUrlHomologacao, AEdtUrlProducao,
      AEdtDirEnviados, AEdtDirErro, AEdtDirCancelados,
      AEdtDirIni, AEdtDataEnvio: TEdit;
      const AChbThread: TCheckBox;
      const ARbHomologacao, ARbProducao: TRadioButton;
      const APnlHomologacao, APnlProducao: TPanel;
      const ARbEnviarLote, ARbEnviarIndividual: TRadioButton);
    procedure ColetarTela(const AEdtUrlHomologacao, AEdtUrlProducao,
      AEdtDirEnviados, AEdtDirErro, AEdtDirCancelados,
      AEdtDirIni, AEdtDataEnvio: TEdit;
      const AChbThread: TCheckBox;
      const ARbHomologacao, ARbEnviarLote: TRadioButton);
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
  CAPTIONS_THREAD: array[Boolean] of string = (CAPTION_THREAD_DESLIGADA, CAPTION_THREAD_LIGADA);
  CORES_THREAD   : array[Boolean] of TColor = (clGray, $00007700);
  COR_ATIVO      = $0000CC00;
  COR_INATIVO    = $000000CC;

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
var
  LDados: TDadosConfiguracao;
begin
  FConfiguracao.PreencherDados(LDados);
  { Sempre usa o caminho resolvido pelo EncontrarConfig }
  LDados.DiretorioArquivoIni := FCaminhoIni;
  FConfiguracao.Atualizar(LDados);
  ForceDirectories(FCaminhoIni);
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

procedure TControllerConfiguracaoView.AtualizarAmbiente(
  const ARbHomologacao, ARbProducao: TRadioButton;
  const APnlHomologacao, APnlProducao: TPanel);
begin
  case ARbHomologacao.Checked of
    True: begin
      APnlHomologacao.Color := COR_ATIVO;
      APnlProducao.Color    := COR_INATIVO;
    end;
    False: begin
      APnlHomologacao.Color := COR_INATIVO;
      APnlProducao.Color    := COR_ATIVO;
    end;
  end;
end;

procedure TControllerConfiguracaoView.PreencherTela(
  const AEdtUrlHomologacao, AEdtUrlProducao,
  AEdtDirEnviados, AEdtDirErro, AEdtDirCancelados,
  AEdtDirIni, AEdtDataEnvio: TEdit;
  const AChbThread: TCheckBox;
  const ARbHomologacao, ARbProducao: TRadioButton;
  const APnlHomologacao, APnlProducao: TPanel;
  const ARbEnviarLote, ARbEnviarIndividual: TRadioButton);
var
  LDados: TDadosConfiguracao;
begin
  FConfiguracao.PreencherDados(LDados);

  AEdtUrlHomologacao.Text := LDados.UrlHomologacao;
  AEdtUrlProducao.Text    := LDados.UrlProducao;
  AEdtDirEnviados.Text    := LDados.DiretorioRpsEnviados;
  AEdtDirErro.Text        := LDados.DiretorioRpsErro;
  AEdtDirCancelados.Text  := LDados.DiretorioRpsCancelados;
  AEdtDirIni.Text         := LDados.DiretorioArquivoIni;
  AEdtDataEnvio.Text      := LDados.DataEnvio;
  AChbThread.Checked      := LDados.ThreadAtiva;

  ARbEnviarLote.Checked       := LDados.EnviarEmLote;
  ARbEnviarIndividual.Checked := not LDados.EnviarEmLote;

  ARbHomologacao.Checked := LDados.AmbienteAtivo <> 'Producao';
  ARbProducao.Checked    := LDados.AmbienteAtivo =  'Producao';

  AtualizarCaptionThread(AChbThread);
  AtualizarAmbiente(ARbHomologacao, ARbProducao, APnlHomologacao, APnlProducao);
end;

procedure TControllerConfiguracaoView.ColetarTela(
  const AEdtUrlHomologacao, AEdtUrlProducao,
  AEdtDirEnviados, AEdtDirErro, AEdtDirCancelados,
  AEdtDirIni, AEdtDataEnvio: TEdit;
  const AChbThread: TCheckBox;
  const ARbHomologacao, ARbEnviarLote: TRadioButton);
var
  LDados: TDadosConfiguracao;
begin
  case ARbHomologacao.Checked of
    True : LDados.AmbienteAtivo := 'Homologacao';
    False: LDados.AmbienteAtivo := 'Producao';
  end;
  LDados.UrlHomologacao         := AEdtUrlHomologacao.Text;
  LDados.UrlProducao            := AEdtUrlProducao.Text;
  LDados.DiretorioRpsEnviados   := AEdtDirEnviados.Text;
  LDados.DiretorioRpsErro       := AEdtDirErro.Text;
  LDados.DiretorioRpsCancelados := AEdtDirCancelados.Text;
  LDados.DiretorioArquivoIni    := AEdtDirIni.Text;
  LDados.ThreadAtiva            := AChbThread.Checked;
  LDados.EnviarEmLote           := ARbEnviarLote.Checked;
  LDados.DataEnvio              := AEdtDataEnvio.Text;

  FConfiguracao.Atualizar(LDados);
end;

procedure TControllerConfiguracaoView.ExibirMensagemStatus(
  const ALbl: TLabel; const AMensagem: string; const ACor: TColor);
begin
  ALbl.Caption    := '  ' + AMensagem;
  ALbl.Font.Color := ACor;
end;

end.
