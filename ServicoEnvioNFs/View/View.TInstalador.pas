unit View.TInstalador;

{
  Form VCL minimalista para o ciclo de reinstalacao do servico.
  Sem DFM - tudo criado por codigo.
  Roda o Controller em TThread para nao travar a UI durante o processo.
}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Controller.TInstalador;

type
  TFrmInstalador = class(TForm)
  private
    FPnlTopo   : TPanel;
    FPnlRodape : TPanel;
    FMemo      : TMemo;
    FBtn       : TButton;
    FLabel     : TLabel;
    FInstalador: TControllerInstalador;
    FConcluido : Boolean;

    procedure CriarComponentes;
    procedure BtnClick(Sender: TObject);
    procedure AdicionarLog(const AMensagem: string; const AErro: Boolean);
    procedure IniciarReinstalar;
    procedure AtualizarConcluido;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

implementation

const
  NOME_SERVICO = 'ServicoEnvioNFs';

  COR_TOPO   : TColor = $001A2B4A;
  COR_RODAPE : TColor = $00F5F5F5;
  COR_FUNDO  : TColor = $00FFFFFF;

constructor TFrmInstalador.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  FConcluido := False;
  CriarComponentes;
  IniciarReinstalar;
end;

destructor TFrmInstalador.Destroy;
begin
  FreeAndNil(FInstalador);
  inherited;
end;

procedure TFrmInstalador.CriarComponentes;
begin
  Caption      := 'Servico de Envio NFs-e - Instalador';
  Position     := poScreenCenter;
  BorderStyle  := bsDialog;
  Width        := 520;
  Height       := 360;
  Color        := COR_FUNDO;
  Font.Name    := 'Segoe UI';
  Font.Size    := 9;

  { Topo }
  FPnlTopo             := TPanel.Create(Self);
  FPnlTopo.Parent      := Self;
  FPnlTopo.Align       := alTop;
  FPnlTopo.Height      := 52;
  FPnlTopo.BevelOuter  := bvNone;
  FPnlTopo.Color       := COR_TOPO;
  FPnlTopo.ParentColor := False;

  FLabel             := TLabel.Create(Self);
  FLabel.Parent      := FPnlTopo;
  FLabel.Caption     := '  Reinstalando Servico...';
  FLabel.Font.Name   := 'Segoe UI';
  FLabel.Font.Size   := 11;
  FLabel.Font.Style  := [fsBold];
  FLabel.Font.Color  := clWhite;
  FLabel.Layout      := tlCenter;
  FLabel.Top         := 14;
  FLabel.Left        := 8;

  { Memo de log }
  FMemo              := TMemo.Create(Self);
  FMemo.Parent       := Self;
  FMemo.Align        := alClient;
  FMemo.ReadOnly     := True;
  FMemo.ScrollBars   := ssVertical;
  FMemo.BorderStyle  := bsNone;
  FMemo.Color        := $00F8F9FC;
  FMemo.Font.Name    := 'Consolas';
  FMemo.Font.Size    := 9;
  FMemo.Font.Color   := $001C2B3A;
  FMemo.Lines.Clear;

  { Rodape }
  FPnlRodape             := TPanel.Create(Self);
  FPnlRodape.Parent      := Self;
  FPnlRodape.Align       := alBottom;
  FPnlRodape.Height      := 48;
  FPnlRodape.BevelOuter  := bvNone;
  FPnlRodape.Color       := COR_RODAPE;
  FPnlRodape.ParentColor := False;

  FBtn            := TButton.Create(Self);
  FBtn.Parent     := FPnlRodape;
  FBtn.Caption    := 'Aguarde...';
  FBtn.Width      := 120;
  FBtn.Height     := 30;
  FBtn.Top        := 9;
  FBtn.Left       := (FPnlRodape.Width - FBtn.Width) div 2;
  FBtn.Anchors    := [akTop, akLeft, akRight];
  FBtn.Enabled    := False;
  FBtn.Font.Style := [fsBold];
  FBtn.OnClick    := BtnClick;
end;

procedure TFrmInstalador.AdicionarLog(const AMensagem: string;
  const AErro: Boolean);
var
  LMemo : TMemo;
begin
  LMemo := FMemo;
  TThread.Synchronize(nil,
    procedure
    begin
      LMemo.Lines.Add('  ' + AMensagem);
      LMemo.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    end);
end;

procedure TFrmInstalador.AtualizarConcluido;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FConcluido     := True;
      FLabel.Caption := '  Concluido com sucesso!';
      FBtn.Caption   := 'Fechar';
      FBtn.Enabled   := True;
    end);
end;

procedure TFrmInstalador.IniciarReinstalar;
begin
  FInstalador := TControllerInstalador.Criar(
    ParamStr(0),
    NOME_SERVICO,
    procedure(const AMensagem: string; const AErro: Boolean)
    begin
      AdicionarLog(AMensagem, AErro);
    end);

  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        FInstalador.Reinstalar;
      except
        on E: Exception do
          AdicionarLog('ERRO: ' + E.Message, True);
      end;
      AtualizarConcluido;
    end).Start;
end;

procedure TFrmInstalador.BtnClick(Sender: TObject);
begin
  case FConcluido of
    True: Close;
  end;
end;

end.
