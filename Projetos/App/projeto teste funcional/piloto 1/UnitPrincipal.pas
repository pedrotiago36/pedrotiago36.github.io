unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects,
  FMX.Filter.Effects, System.IOUtils, FMX.Layouts;

type
  TFormPrincipal = class(TForm)
    RectFundo: TRectangle;
    RectHeader: TRectangle;
    ShadowHeader: TShadowEffect;
    ImgLogoHeader: TImage;
    LblTituloHeader: TLabel;
    LblSubtituloHeader: TLabel;
    RectBtnMenu: TRectangle;
    LblBtnMenu: TLabel;
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
    RectMenuFooter: TRectangle;
    RectBtnSair: TRectangle;
    ImgBtnSair: TImage;
    LblBtnSair: TLabel;
    LblVersao: TLabel;
    RectConteudo: TRectangle;
    RectConteudoHeader: TRectangle;
    LblConteudoTitulo: TLabel;
    LblConteudoSubtitulo: TLabel;
    RectCard1: TRectangle;
    ShadowCard1: TShadowEffect;
    ImgCard1: TImage;
    LblCard1Titulo: TLabel;
    LblCard1Valor: TLabel;
    RectCard2: TRectangle;
    ShadowCard2: TShadowEffect;
    ImgCard2: TImage;
    LblCard2Titulo: TLabel;
    LblCard2Valor: TLabel;
    RectCard3: TRectangle;
    ShadowCard3: TShadowEffect;
    ImgCard3: TImage;
    LblCard3Titulo: TLabel;
    LblCard3Valor: TLabel;
    RectCard4: TRectangle;
    ShadowCard4: TShadowEffect;
    ImgCard4: TImage;
    LblCard4Titulo: TLabel;
    LblCard4Valor: TLabel;
    LayoutDecor: TLayout;
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
    procedure RectMenuOverlayClick(Sender: TObject);
    procedure RectBtnSairClick(Sender: TObject);
    procedure MenuItemMouseEnter(Sender: TObject);
    procedure MenuItemMouseLeave(Sender: TObject);
    procedure MenuItemClick(Sender: TObject);
    procedure CardMouseEnter(Sender: TObject);
    procedure CardMouseLeave(Sender: TObject);
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
    procedure SelecionarMenuItem(Index: Integer);
  public
    NomeUsuario: string;
    TipoUsuario: string;
  end;

var
  FormPrincipal: TFormPrincipal;

const
  COR_VERMELHO = $FFD33327;
  COR_VERMELHO_ESCURO = $FF7D2728;
  COR_DOURADO = $FFFDCD62;
  COR_DOURADO_CLARO = $FFFFEABB;
  COR_CARD = $20FFFFFF;
  COR_CARD_HOVER = $35FFFFFF;
  COR_MENU_BG = $E8501818;
  COR_BORDA = $4DFDCD62;

implementation

{$R *.fmx}

uses UnitLogin;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  FMenuAberto := False;
  FLogoScale := 1.0;
  FLogoGrow := True;
  
  // Menu começa fechado
  RectMenuLateral.Position.X := -280;
  RectMenuOverlay.Visible := False;
  RectMenuOverlay.Opacity := 0;
  
  // Cria objetos escolares decorativos (igual ao Login!)
  CriarItensDecorativos;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  // Atualiza informações do usuário
  if NomeUsuario <> '' then
    LblNomeUsuario.Text := NomeUsuario
  else
    LblNomeUsuario.Text := 'Usuário';
    
  if TipoUsuario <> '' then
    LblTipoUsuario.Text := TipoUsuario
  else
    LblTipoUsuario.Text := 'Aluno';
  
  LblSubtituloHeader.Text := 'Olá, ' + LblNomeUsuario.Text + '!';
  
  // Animação de entrada
  RectConteudo.Opacity := 0;
  RectConteudo.Scale.X := 0.95;
  RectConteudo.Scale.Y := 0.95;
  
  TAnimator.AnimateFloat(RectConteudo, 'Opacity', 1, 0.4, TAnimationType.Out, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(RectConteudo, 'Scale.X', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(RectConteudo, 'Scale.Y', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  
  // Inicia timers
  TimerDecor.Enabled := True;
  TimerLogoMenu.Enabled := True;
end;

procedure TFormPrincipal.CriarItensDecorativos;
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

  // Tamanhos variados para os objetos
  Sizes[0] := 35; Sizes[1] := 28; Sizes[2] := 40; Sizes[3] := 32; Sizes[4] := 38;
  Sizes[5] := 30; Sizes[6] := 42; Sizes[7] := 26; Sizes[8] := 36; Sizes[9] := 34;
  Sizes[10] := 28; Sizes[11] := 40; Sizes[12] := 32; Sizes[13] := 38; Sizes[14] := 30;
  
  // Posições X distribuídas pela tela
  PosX[0] := 15; PosX[1] := 55; PosX[2] := 95; PosX[3] := 140; PosX[4] := 185;
  PosX[5] := 230; PosX[6] := 275; PosX[7] := 320; PosX[8] := 365; PosX[9] := 405;
  PosX[10] := 35; PosX[11] := 120; PosX[12] := 205; PosX[13] := 290; PosX[14] := 375;
  
  // Velocidades diferentes para cada objeto
  FDecorSpeeds[0] := 1.2; FDecorSpeeds[1] := 1.8; FDecorSpeeds[2] := 1.5;
  FDecorSpeeds[3] := 2.0; FDecorSpeeds[4] := 1.3; FDecorSpeeds[5] := 1.7;
  FDecorSpeeds[6] := 1.4; FDecorSpeeds[7] := 2.2; FDecorSpeeds[8] := 1.6;
  FDecorSpeeds[9] := 1.9; FDecorSpeeds[10] := 1.1; FDecorSpeeds[11] := 2.1;
  FDecorSpeeds[12] := 1.4; FDecorSpeeds[13] := 1.8; FDecorSpeeds[14] := 1.5;
  
  // Velocidades de rotação
  FDecorRotations[0] := 1.5; FDecorRotations[1] := -1.2; FDecorRotations[2] := 2.0;
  FDecorRotations[3] := -1.8; FDecorRotations[4] := 1.3; FDecorRotations[5] := -2.2;
  FDecorRotations[6] := 1.7; FDecorRotations[7] := -1.4; FDecorRotations[8] := 2.1;
  FDecorRotations[9] := -1.6; FDecorRotations[10] := 1.9; FDecorRotations[11] := -1.1;
  FDecorRotations[12] := 2.3; FDecorRotations[13] := -1.5; FDecorRotations[14] := 1.8;
  
  for I := 0 to 14 do
  begin
    FDecorItems[I] := TImage.Create(Self);
    FDecorItems[I].Parent := LayoutDecor; // Igual ao Login!
    FDecorItems[I].Position.X := PosX[I];
    FDecorItems[I].Position.Y := -50 - Random(150); // Começam fora da tela
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

procedure TFormPrincipal.TimerDecorTimer(Sender: TObject);
begin
  AnimarDecorItems;
end;

procedure TFormPrincipal.AnimarDecorItems;
var
  I: Integer;
  MaxY: Single;
begin
  MaxY := LayoutDecor.Height + 50;
  
  for I := 0 to 14 do
  begin
    // Move para baixo
    if FDecorItems[I].Position.Y > MaxY then
      FDecorItems[I].Position.Y := -50 - Random(100)
    else
      FDecorItems[I].Position.Y := FDecorItems[I].Position.Y + FDecorSpeeds[I];
    
    // Rotaciona suavemente
    FDecorItems[I].RotationAngle := FDecorItems[I].RotationAngle + FDecorRotations[I];
  end;
end;

procedure TFormPrincipal.TimerLogoMenuTimer(Sender: TObject);
begin
  // Pulso no logo do menu quando aberto
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

procedure TFormPrincipal.RectBtnMenuClick(Sender: TObject);
begin
  if FMenuAberto then
    FecharMenu
  else
    AbrirMenu;
end;

procedure TFormPrincipal.AbrirMenu;
begin
  FMenuAberto := True;
  
  // Mostra overlay
  RectMenuOverlay.Visible := True;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0.6, 0.3);
  
  // Desliza menu para dentro
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', 0, 0.3, TAnimationType.Out, TInterpolationType.Quadratic);
  
  // Ícone do menu muda
  LblBtnMenu.Text := '✕';
end;

procedure TFormPrincipal.FecharMenu;
begin
  FMenuAberto := False;
  
  // Esconde overlay
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0, 0.25);
  
  // Desliza menu para fora
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', -280, 0.25, TAnimationType.In, TInterpolationType.Quadratic);
  
  // Ícone do menu volta
  LblBtnMenu.Text := '☰';
  
  // Esconde overlay após animação
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

procedure TFormPrincipal.RectMenuOverlayClick(Sender: TObject);
begin
  FecharMenu;
end;

procedure TFormPrincipal.MenuItemMouseEnter(Sender: TObject);
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

procedure TFormPrincipal.MenuItemMouseLeave(Sender: TObject);
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

procedure TFormPrincipal.MenuItemClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := 0;
  
  if Sender = RectMenuItem1 then Index := 1
  else if Sender = RectMenuItem2 then Index := 2
  else if Sender = RectMenuItem3 then Index := 3
  else if Sender = RectMenuItem4 then Index := 4
  else if Sender = RectMenuItem5 then Index := 5;
  
  if Index > 0 then
    SelecionarMenuItem(Index);
end;

procedure TFormPrincipal.SelecionarMenuItem(Index: Integer);
var
  Titulos: array[1..5] of string;
begin
  Titulos[1] := 'Início';
  Titulos[2] := 'Calendário';
  Titulos[3] := 'Notas';
  Titulos[4] := 'Financeiro';
  Titulos[5] := 'Configurações';
  
  // Animação de feedback
  TAnimator.AnimateFloat(RectConteudo, 'Opacity', 0.7, 0.1);
  
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(100);
      TThread.Synchronize(nil,
        procedure
        begin
          LblConteudoTitulo.Text := Titulos[Index];
          TAnimator.AnimateFloat(RectConteudo, 'Opacity', 1, 0.2);
        end);
    end).Start;
  
  // Fecha menu
  FecharMenu;
end;

procedure TFormPrincipal.CardMouseEnter(Sender: TObject);
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

procedure TFormPrincipal.CardMouseLeave(Sender: TObject);
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

procedure TFormPrincipal.RectBtnSairClick(Sender: TObject);
begin
  // Animação de saída
  TAnimator.AnimateFloat(RectMenuLateral, 'Opacity', 0, 0.2);
  TAnimator.AnimateFloat(RectConteudo, 'Opacity', 0, 0.3);
  
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(350);
      TThread.Synchronize(nil,
        procedure
        begin
          TimerDecor.Enabled := False;
          TimerLogoMenu.Enabled := False;
          FormLogin.Show;
          Self.Hide;
          // Reset
          RectMenuLateral.Opacity := 1;
          RectConteudo.Opacity := 1;
          FMenuAberto := False;
          RectMenuLateral.Position.X := -280;
          RectMenuOverlay.Visible := False;
          LblBtnMenu.Text := '☰';
        end);
    end).Start;
end;

end.
