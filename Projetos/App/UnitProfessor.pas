unit UnitProfessor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects, FMX.Layouts,
  FMX.Filter.Effects, System.IOUtils;

type
  TFormProfessor = class(TForm)
    RectFundo: TRectangle;
    LayoutDecor: TLayout;
    RectHeader: TRectangle;
    ShadowHeader: TShadowEffect;
    RectBtnMenu: TRectangle;
    LblBtnMenu: TLabel;
    RectBtnVoltar: TRectangle;
    LblBtnVoltar: TLabel;
    ImgLogoHeader: TImage;
    LblTituloHeader: TLabel;
    LblSubtituloHeader: TLabel;
    RectMenuOverlay: TRectangle;
    RectMenuLateral: TRectangle;
    ShadowMenu: TShadowEffect;
    RectMenuHeader: TRectangle;
    CircleLogoMenu: TCircle;
    ImgLogoMenu: TImage;
    LblNomeUsuario: TLabel;
    LblTipoUsuario: TLabel;
    RectMenuDivider: TRectangle;
    RectMenuItem1: TRectangle;
    ImgMenuItem1: TImage;
    LblMenuItem1: TLabel;
    RectMenuItem2: TRectangle;
    ImgMenuItem2: TImage;
    LblMenuItem2: TLabel;
    RectMenuItem3: TRectangle;
    ImgMenuItem3: TImage;
    LblMenuItem3: TLabel;
    RectMenuItem4: TRectangle;
    ImgMenuItem4: TImage;
    LblMenuItem4: TLabel;
    RectMenuItem5: TRectangle;
    ImgMenuItem5: TImage;
    LblMenuItem5: TLabel;
    RectMenuItem6: TRectangle;
    ImgMenuItem6: TImage;
    LblMenuItem6: TLabel;
    RectMenuFooter: TRectangle;
    RectBtnSair: TRectangle;
    ImgBtnSair: TImage;
    LblBtnSair: TLabel;
    LblVersao: TLabel;
    ScrollBoxConteudo: TVertScrollBox;
    RectConteudoHeader: TRectangle;
    LblConteudoTitulo: TLabel;
    LblConteudoSubtitulo: TLabel;
    RectCard1: TRectangle;
    ShadowCard1: TShadowEffect;
    ImgCard1: TImage;
    LblCard1Titulo: TLabel;
    LblCard1Desc: TLabel;
    RectCard2: TRectangle;
    ShadowCard2: TShadowEffect;
    ImgCard2: TImage;
    LblCard2Titulo: TLabel;
    LblCard2Desc: TLabel;
    RectCard3: TRectangle;
    ShadowCard3: TShadowEffect;
    ImgCard3: TImage;
    LblCard3Titulo: TLabel;
    LblCard3Desc: TLabel;
    RectCard4: TRectangle;
    ShadowCard4: TShadowEffect;
    ImgCard4: TImage;
    LblCard4Titulo: TLabel;
    LblCard4Desc: TLabel;
    RectCard5: TRectangle;
    ShadowCard5: TShadowEffect;
    ImgCard5: TImage;
    LblCard5Titulo: TLabel;
    LblCard5Desc: TLabel;
    RectCard6: TRectangle;
    ShadowCard6: TShadowEffect;
    ImgCard6: TImage;
    LblCard6Titulo: TLabel;
    LblCard6Desc: TLabel;
    LinhaEducInfantil: TLine;
    LblEducInfantil: TLabel;
    RectCard7: TRectangle;
    ShadowCard7: TShadowEffect;
    ImgCard7: TImage;
    LblCard7Titulo: TLabel;
    LblCard7Desc: TLabel;
    RectCard8: TRectangle;
    ShadowCard8: TShadowEffect;
    ImgCard8: TImage;
    LblCard8Titulo: TLabel;
    LblCard8Desc: TLabel;
    TimerDecor: TTimer;
    TimerLogoMenu: TTimer;
    ImgModeloBook: TImage;
    ImgModeloPencil: TImage;
    ImgModeloEraser: TImage;
    ImgModeloNotebook: TImage;
    ImgModeloRuler: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RectBtnMenuClick(Sender: TObject);
    procedure RectBtnVoltarClick(Sender: TObject);
    procedure RectMenuOverlayClick(Sender: TObject);
    procedure RectBtnSairClick(Sender: TObject);
    procedure MenuItemMouseEnter(Sender: TObject);
    procedure MenuItemMouseLeave(Sender: TObject);
    procedure MenuItemClick(Sender: TObject);
    procedure CardMouseEnter(Sender: TObject);
    procedure CardMouseLeave(Sender: TObject);
    procedure CardClick(Sender: TObject);
    procedure TimerDecorTimer(Sender: TObject);
    procedure TimerLogoMenuTimer(Sender: TObject);
  private
    FMenuAberto: Boolean;
    FDecorItems: array[0..14] of TImage;
    FDecorSpeeds: array[0..14] of Single;
    FDecorRotations: array[0..14] of Single;
    FLogoScale: Single;
    FLogoGrow: Boolean;
    procedure CriarItensDecorativos;
    procedure AnimarDecorItems;
    procedure AbrirMenu;
    procedure FecharMenu;
    procedure MostrarMensagemCard(Titulo: string);
  public
    NomeUsuario: string;
  end;

var
  FormProfessor: TFormProfessor;

const
  COR_VERMELHO = $FFD33327;
  COR_VERMELHO_ESCURO = $FF7D2728;
  COR_DOURADO = $FFFDCD62;
  COR_DOURADO_CLARO = $FFFFEABB;
  COR_CARD = $20FFFFFF;
  COR_CARD_HOVER = $35FFFFFF;
  COR_BORDA = $4DFDCD62;

implementation

{$R *.fmx}

uses UnitLogin;

procedure TFormProfessor.FormCreate(Sender: TObject);
begin
  FMenuAberto := False;
  FLogoScale := 1.0;
  FLogoGrow := True;
  
  // Menu começa fechado
  RectMenuLateral.Position.X := -280;
  RectMenuOverlay.Visible := False;
  RectMenuOverlay.Opacity := 0;
end;

procedure TFormProfessor.FormShow(Sender: TObject);
var
  PrimeiraVez: Boolean;
begin
  // Verifica se é a primeira vez que mostra o form
  PrimeiraVez := (FDecorItems[0] = nil);
  
  if PrimeiraVez then
  begin
    // Cria objetos escolares decorativos
    CriarItensDecorativos;
  end;
  
  // Atualiza informações do usuário
  if NomeUsuario <> '' then
    LblNomeUsuario.Text := NomeUsuario
  else
    LblNomeUsuario.Text := 'Professor';
    
  LblTipoUsuario.Text := 'Área do Professor';
  LblSubtituloHeader.Text := 'Olá, ' + LblNomeUsuario.Text + '!';
  
  // Animação de entrada
  ScrollBoxConteudo.Opacity := 0;
  ScrollBoxConteudo.Scale.X := 0.95;
  ScrollBoxConteudo.Scale.Y := 0.95;
  
  TAnimator.AnimateFloat(ScrollBoxConteudo, 'Opacity', 1, 0.4, TAnimationType.Out, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(ScrollBoxConteudo, 'Scale.X', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(ScrollBoxConteudo, 'Scale.Y', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  
  // Inicia timers
  TimerDecor.Enabled := True;
  TimerLogoMenu.Enabled := True;
end;

procedure TFormProfessor.CriarItensDecorativos;
var
  I: Integer;
  Modelos: array[0..4] of TImage;
  Sizes: array[0..14] of Integer;
  PosX: array[0..14] of Single;
begin
  // Array de modelos para copiar as imagens
  Modelos[0] := ImgModeloBook;
  Modelos[1] := ImgModeloPencil;
  Modelos[2] := ImgModeloEraser;
  Modelos[3] := ImgModeloNotebook;
  Modelos[4] := ImgModeloRuler;

  Sizes[0] := 35; Sizes[1] := 28; Sizes[2] := 40; Sizes[3] := 32; Sizes[4] := 38;
  Sizes[5] := 30; Sizes[6] := 42; Sizes[7] := 26; Sizes[8] := 36; Sizes[9] := 34;
  Sizes[10] := 28; Sizes[11] := 40; Sizes[12] := 32; Sizes[13] := 38; Sizes[14] := 30;
  
  PosX[0] := 15; PosX[1] := 55; PosX[2] := 95; PosX[3] := 140; PosX[4] := 185;
  PosX[5] := 230; PosX[6] := 275; PosX[7] := 320; PosX[8] := 365; PosX[9] := 405;
  PosX[10] := 35; PosX[11] := 120; PosX[12] := 205; PosX[13] := 290; PosX[14] := 375;
  
  FDecorSpeeds[0] := 1.2; FDecorSpeeds[1] := 1.8; FDecorSpeeds[2] := 1.5;
  FDecorSpeeds[3] := 2.0; FDecorSpeeds[4] := 1.3; FDecorSpeeds[5] := 1.7;
  FDecorSpeeds[6] := 1.4; FDecorSpeeds[7] := 2.2; FDecorSpeeds[8] := 1.6;
  FDecorSpeeds[9] := 1.9; FDecorSpeeds[10] := 1.1; FDecorSpeeds[11] := 2.1;
  FDecorSpeeds[12] := 1.4; FDecorSpeeds[13] := 1.8; FDecorSpeeds[14] := 1.5;
  
  FDecorRotations[0] := 1.5; FDecorRotations[1] := -1.2; FDecorRotations[2] := 2.0;
  FDecorRotations[3] := -1.8; FDecorRotations[4] := 1.3; FDecorRotations[5] := -2.2;
  FDecorRotations[6] := 1.7; FDecorRotations[7] := -1.4; FDecorRotations[8] := 2.1;
  FDecorRotations[9] := -1.6; FDecorRotations[10] := 1.9; FDecorRotations[11] := -1.1;
  FDecorRotations[12] := 2.3; FDecorRotations[13] := -1.5; FDecorRotations[14] := 1.8;
  
  for I := 0 to 14 do
  begin
    FDecorItems[I] := TImage.Create(Self);
    FDecorItems[I].Parent := LayoutDecor;
    FDecorItems[I].Position.X := PosX[I];
    FDecorItems[I].Position.Y := -50 - Random(150);
    FDecorItems[I].Width := Sizes[I];
    FDecorItems[I].Height := Sizes[I];
    FDecorItems[I].WrapMode := TImageWrapMode.Fit;
    FDecorItems[I].HitTest := False;
    FDecorItems[I].Opacity := 0.6;
    // Copia a imagem do modelo (cicla entre os 5 modelos)
    if (Modelos[I mod 5] <> nil) and (not Modelos[I mod 5].Bitmap.IsEmpty) then
      FDecorItems[I].Bitmap.Assign(Modelos[I mod 5].Bitmap);
  end;
end;

procedure TFormProfessor.TimerDecorTimer(Sender: TObject);
begin
  AnimarDecorItems;
end;

procedure TFormProfessor.AnimarDecorItems;
var
  I: Integer;
  MaxY: Single;
begin
  MaxY := LayoutDecor.Height + 50;
  
  for I := 0 to 14 do
  begin
    if FDecorItems[I].Position.Y > MaxY then
      FDecorItems[I].Position.Y := -50 - Random(100)
    else
      FDecorItems[I].Position.Y := FDecorItems[I].Position.Y + FDecorSpeeds[I];
    
    FDecorItems[I].RotationAngle := FDecorItems[I].RotationAngle + FDecorRotations[I];
  end;
end;

procedure TFormProfessor.TimerLogoMenuTimer(Sender: TObject);
begin
  if FMenuAberto then
  begin
    if FLogoGrow then
    begin
      FLogoScale := FLogoScale + 0.01;
      if FLogoScale >= 1.1 then
        FLogoGrow := False;
    end
    else
    begin
      FLogoScale := FLogoScale - 0.01;
      if FLogoScale <= 1.0 then
        FLogoGrow := True;
    end;
    
    CircleLogoMenu.Scale.X := FLogoScale;
    CircleLogoMenu.Scale.Y := FLogoScale;
  end;
end;

procedure TFormProfessor.RectBtnMenuClick(Sender: TObject);
begin
  if FMenuAberto then
    FecharMenu
  else
    AbrirMenu;
end;

procedure TFormProfessor.AbrirMenu;
begin
  FMenuAberto := True;
  RectMenuOverlay.Visible := True;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0.6, 0.3);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', 0, 0.3, TAnimationType.Out, TInterpolationType.Quadratic);
  LblBtnMenu.Text := '✕';
end;

procedure TFormProfessor.FecharMenu;
begin
  FMenuAberto := False;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0, 0.25);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', -280, 0.25, TAnimationType.In, TInterpolationType.Quadratic);
  LblBtnMenu.Text := '☰';
  
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(260);
      TThread.Synchronize(nil,
        procedure
        begin
          if not FMenuAberto then
            RectMenuOverlay.Visible := False;
        end);
    end).Start;
end;

procedure TFormProfessor.RectMenuOverlayClick(Sender: TObject);
begin
  FecharMenu;
end;

procedure TFormProfessor.RectBtnVoltarClick(Sender: TObject);
begin
  TimerDecor.Enabled := False;
  TimerLogoMenu.Enabled := False;
  FormLogin.Show;
  Self.Hide;
end;

procedure TFormProfessor.RectBtnSairClick(Sender: TObject);
begin
  FecharMenu;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(300);
      TThread.Synchronize(nil,
        procedure
        begin
          RectBtnVoltarClick(nil);
        end);
    end).Start;
end;

procedure TFormProfessor.MenuItemMouseEnter(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    TAnimator.AnimateFloat(Rect, 'Opacity', 1, 0.15);
    Rect.Fill.Color := $25FFFFFF;
  end;
end;

procedure TFormProfessor.MenuItemMouseLeave(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    TAnimator.AnimateFloat(Rect, 'Opacity', 0.9, 0.15);
    Rect.Fill.Color := $10FFFFFF;
  end;
end;

procedure TFormProfessor.MenuItemClick(Sender: TObject);
var
  Titulo: string;
begin
  Titulo := '';
  
  if Sender = RectMenuItem1 then Titulo := 'Notas de Prova'
  else if Sender = RectMenuItem2 then Titulo := 'Faltas'
  else if Sender = RectMenuItem3 then Titulo := 'TDs'
  else if Sender = RectMenuItem4 then Titulo := 'Notas de Trabalho'
  else if Sender = RectMenuItem5 then Titulo := 'Nota de Comportamento'
  else if Sender = RectMenuItem6 then Titulo := 'Avaliação do Aluno';
  
  if Titulo <> '' then
  begin
    FecharMenu;
    TThread.CreateAnonymousThread(
      procedure
      begin
        Sleep(300);
        TThread.Synchronize(nil,
          procedure
          begin
            MostrarMensagemCard(Titulo);
          end);
      end).Start;
  end;
end;

procedure TFormProfessor.CardMouseEnter(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    TAnimator.AnimateFloat(Rect, 'Scale.X', 1.03, 0.15, TAnimationType.Out, TInterpolationType.Back);
    TAnimator.AnimateFloat(Rect, 'Scale.Y', 1.03, 0.15, TAnimationType.Out, TInterpolationType.Back);
    Rect.Fill.Color := COR_CARD_HOVER;
  end;
end;

procedure TFormProfessor.CardMouseLeave(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    TAnimator.AnimateFloat(Rect, 'Scale.X', 1, 0.15);
    TAnimator.AnimateFloat(Rect, 'Scale.Y', 1, 0.15);
    Rect.Fill.Color := COR_CARD;
  end;
end;

procedure TFormProfessor.CardClick(Sender: TObject);
var
  Titulo: string;
begin
  Titulo := '';
  
  if Sender = RectCard1 then Titulo := 'Notas de Prova'
  else if Sender = RectCard2 then Titulo := 'Faltas'
  else if Sender = RectCard3 then Titulo := 'TDs'
  else if Sender = RectCard4 then Titulo := 'Notas de Trabalho'
  else if Sender = RectCard5 then Titulo := 'Nota de Comportamento'
  else if Sender = RectCard6 then Titulo := 'Avaliação do Aluno';
  
  if Titulo <> '' then
    MostrarMensagemCard(Titulo);
end;

procedure TFormProfessor.MostrarMensagemCard(Titulo: string);
begin
  ShowMessage('Funcionalidade "' + Titulo + '" em desenvolvimento!' + sLineBreak + sLineBreak +
              'Esta área permitirá ao professor gerenciar ' + LowerCase(Titulo) + ' dos alunos.');
end;

end.
