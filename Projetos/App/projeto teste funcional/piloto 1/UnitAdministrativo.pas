unit UnitAdministrativo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects, FMX.Layouts,
  FMX.Filter.Effects, System.IOUtils, System.Math;

type
  TFormAdministrativo = class(TForm)
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
    ScrollBoxMenu: TVertScrollBox;
    RectMenuFooter: TRectangle;
    RectBtnSair: TRectangle;
    ImgBtnSair: TImage;
    LblBtnSair: TLabel;
    LblVersao: TLabel;
    ScrollBoxConteudo: TVertScrollBox;
    RectConteudoHeader: TRectangle;
    LblConteudoTitulo: TLabel;
    LblConteudoSubtitulo: TLabel;
    RectDetalhe: TRectangle;
    RectDetalheHeader: TRectangle;
    LblDetalheTitulo: TLabel;
    RectBtnFecharDetalhe: TRectangle;
    LblBtnFecharDetalhe: TLabel;
    RectDetalheConteudo: TRectangle;
    ScrollBoxDetalhe: TVertScrollBox;
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
    procedure CardMouseEnter(Sender: TObject);
    procedure CardMouseLeave(Sender: TObject);
    procedure CardClick(Sender: TObject);
    procedure RectBtnFecharDetalheClick(Sender: TObject);
    procedure TimerDecorTimer(Sender: TObject);
    procedure TimerLogoMenuTimer(Sender: TObject);
  private
    FMenuAberto: Boolean;
    FDecorItems: array[0..14] of TImage;
    FDecorSpeeds: array[0..14] of Single;
    FDecorRotations: array[0..14] of Single;
    FLogoScale: Single;
    FLogoGrow: Boolean;
    FCards: array[1..12] of TRectangle;
    FMenuItems: array[1..12] of TRectangle;
    procedure CriarItensDecorativos;
    procedure CriarCards;
    procedure CriarMenuItems;
    procedure AnimarDecorItems;
    procedure AbrirMenu;
    procedure FecharMenu;
    procedure MostrarDetalhe(CardIndex: Integer);
    procedure LimparScrollBox(SB: TVertScrollBox);
    // Gráficos
    procedure CriarGraficoBarras(Parent: TFmxObject; Titulo: string; Labels: array of string; Valores: array of Double; Cor: TAlphaColor);
    procedure CriarGraficoPizza(Parent: TFmxObject; Titulo: string; Labels: array of string; Valores: array of Double; Cores: array of TAlphaColor);
    procedure CriarGraficoLinhas(Parent: TFmxObject; Titulo: string; Labels: array of string; Valores: array of Double; Cor: TAlphaColor);
    procedure CriarCardResumo(Parent: TFmxObject; Titulo, Valor, Subtitulo: string; Cor: TAlphaColor; PosY: Single);
    // Conteúdos
    procedure CarregarMatriculasAnuais;
    procedure CarregarEvasoesMes;
    procedure CarregarEvasoesSerie;
    procedure CarregarMatriculasMes;
    procedure CarregarMatriculasSerie;
    procedure CarregarEvasoesMatriculasRS;
    procedure CarregarDespesasGerais;
    procedure CarregarAguaLuz;
    procedure CarregarOutrosGastos;
    procedure CarregarPerdasEvasoes;
    procedure CarregarGanhosMatriculas;
    procedure CarregarContasReceberPagar;
  public
    NomeUsuario: string;
  end;

var
  FormAdministrativo: TFormAdministrativo;

const
  COR_VERMELHO = $FFD33327;
  COR_VERMELHO_ESCURO = $FF7D2728;
  COR_DOURADO = $FFFDCD62;
  COR_DOURADO_CLARO = $FFFFEABB;
  COR_CARD = $20FFFFFF;
  COR_CARD_HOVER = $35FFFFFF;
  COR_BORDA = $4DFDCD62;
  COR_VERDE = $FF4CAF50;
  COR_AZUL = $FF2196F3;
  COR_LARANJA = $FFFF9800;
  COR_ROXO = $FF9C27B0;
  COR_CYAN = $FF00BCD4;
  COR_PINK = $FFE91E63;
  
  // Paleta de 12 cores para gráficos de pizza
  CORES_PIZZA: array[0..11] of TAlphaColor = (
    $FFD33327,  // Vermelho
    $FFFF9800,  // Laranja
    $FFFDCD62,  // Dourado
    $FF4CAF50,  // Verde
    $FF2196F3,  // Azul
    $FF9C27B0,  // Roxo
    $FF00BCD4,  // Cyan
    $FFE91E63,  // Pink
    $FFFF5722,  // Deep Orange
    $FF795548,  // Brown
    $FF607D8B,  // Blue Grey
    $FF9E9E9E   // Grey
  );

  CARD_TITULOS: array[1..12] of string = (
    'Matrículas Anuais',
    'Evasões por Mês',
    'Evasões por Série',
    'Matrículas por Mês',
    'Matrículas por Série',
    'R$ Evasões x Matrículas',
    'Despesas Gerais',
    'Água e Luz',
    'Outros Gastos',
    'Perdas com Evasões',
    'Ganhos com Matrículas',
    'Contas Receber/Pagar'
  );

  CARD_DESCRICOES: array[1..12] of string = (
    'Comparativo últimos 5 anos',
    'Evasões mês a mês',
    'Evasões por série escolar',
    'Novas matrículas mês a mês',
    'Matrículas por série',
    'Valores monetários',
    'Despesas mensais gerais',
    'Consumo de água e energia',
    'Demais despesas',
    'Total perdido com evasões',
    'Total recebido em matrículas',
    'Balanço últimos 10 anos'
  );

  CARD_ICONES: array[1..12] of string = (
    '📊', '📉', '🎓', '📈', '👥', '💰', '💸', '💡', '📋', '❌', '✅', '📑'
  );

implementation

{$R *.fmx}

uses UnitLogin;

procedure TFormAdministrativo.FormCreate(Sender: TObject);
begin
  FMenuAberto := False;
  FLogoScale := 1.0;
  FLogoGrow := True;
  
  RectMenuLateral.Position.X := -280;
  RectMenuOverlay.Visible := False;
  RectMenuOverlay.Opacity := 0;
  
  RectDetalhe.Visible := False;
  RectDetalhe.Opacity := 0;
end;

procedure TFormAdministrativo.FormShow(Sender: TObject);
var
  PrimeiraVez: Boolean;
begin
  PrimeiraVez := (FDecorItems[0] = nil);
  
  if PrimeiraVez then
  begin
    CriarItensDecorativos;
    CriarCards;
    CriarMenuItems;
  end;
  
  if NomeUsuario <> '' then
    LblNomeUsuario.Text := NomeUsuario
  else
    LblNomeUsuario.Text := 'Administrador';
    
  LblTipoUsuario.Text := 'Área Administrativa';
  LblSubtituloHeader.Text := 'Olá, ' + LblNomeUsuario.Text + '!';
  
  ScrollBoxConteudo.Opacity := 0;
  ScrollBoxConteudo.Scale.X := 0.95;
  ScrollBoxConteudo.Scale.Y := 0.95;
  
  TAnimator.AnimateFloat(ScrollBoxConteudo, 'Opacity', 1, 0.4, TAnimationType.Out, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(ScrollBoxConteudo, 'Scale.X', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(ScrollBoxConteudo, 'Scale.Y', 1, 0.4, TAnimationType.Out, TInterpolationType.Back);
  
  TimerDecor.Enabled := True;
  TimerLogoMenu.Enabled := True;
end;

procedure TFormAdministrativo.CriarCards;
var
  I, Col, Row: Integer;
  Card: TRectangle;
  Shadow: TShadowEffect;
  LblIcone, LblTitulo, LblDesc: TLabel;
  CardW, CardH, MarginX, MarginY, PosX, PosY: Single;
begin
  CardW := 195;
  CardH := 110;
  MarginX := 20;
  MarginY := 10;
  
  for I := 1 to 12 do
  begin
    Col := (I - 1) mod 2;
    Row := (I - 1) div 2;
    PosX := Col * (CardW + MarginX);
    PosY := 70 + Row * (CardH + MarginY);
    
    Card := TRectangle.Create(Self);
    Card.Parent := ScrollBoxConteudo;
    Card.Position.X := PosX;
    Card.Position.Y := PosY;
    Card.Width := CardW;
    Card.Height := CardH;
    Card.Fill.Color := COR_CARD;
    Card.Stroke.Color := COR_BORDA;
    Card.Stroke.Thickness := 1.5;
    Card.XRadius := 12;
    Card.YRadius := 12;
    Card.Cursor := crHandPoint;
    Card.Tag := I;
    Card.OnClick := CardClick;
    Card.OnMouseEnter := CardMouseEnter;
    Card.OnMouseLeave := CardMouseLeave;
    
    Shadow := TShadowEffect.Create(Card);
    Shadow.Parent := Card;
    Shadow.Distance := 4;
    Shadow.Direction := 45;
    Shadow.Softness := 0.3;
    Shadow.Opacity := 0.25;
    Shadow.ShadowColor := TAlphaColors.Black;
    
    LblIcone := TLabel.Create(Card);
    LblIcone.Parent := Card;
    LblIcone.Position.X := 12;
    LblIcone.Position.Y := 12;
    LblIcone.Width := 35;
    LblIcone.Height := 35;
    LblIcone.StyledSettings := [];
    LblIcone.TextSettings.Font.Size := 24;
    LblIcone.TextSettings.HorzAlign := TTextAlign.Center;
    LblIcone.Text := CARD_ICONES[I];
    LblIcone.HitTest := False;
    
    LblTitulo := TLabel.Create(Card);
    LblTitulo.Parent := Card;
    LblTitulo.Position.X := 12;
    LblTitulo.Position.Y := 50;
    LblTitulo.Width := CardW - 24;
    LblTitulo.Height := 22;
    LblTitulo.StyledSettings := [];
    LblTitulo.TextSettings.Font.Size := 12;
    LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblTitulo.TextSettings.FontColor := TAlphaColors.White;
    LblTitulo.Text := CARD_TITULOS[I];
    LblTitulo.HitTest := False;
    
    LblDesc := TLabel.Create(Card);
    LblDesc.Parent := Card;
    LblDesc.Position.X := 12;
    LblDesc.Position.Y := 72;
    LblDesc.Width := CardW - 24;
    LblDesc.Height := 30;
    LblDesc.StyledSettings := [];
    LblDesc.TextSettings.Font.Size := 10;
    LblDesc.TextSettings.FontColor := COR_DOURADO;
    LblDesc.TextSettings.WordWrap := True;
    LblDesc.Text := CARD_DESCRICOES[I];
    LblDesc.HitTest := False;
    
    FCards[I] := Card;
  end;
end;

procedure TFormAdministrativo.CriarMenuItems;
var
  I: Integer;
  MenuItem: TRectangle;
  LblIcone, LblTitulo: TLabel;
begin
  for I := 1 to 12 do
  begin
    MenuItem := TRectangle.Create(Self);
    MenuItem.Parent := ScrollBoxMenu;
    MenuItem.Position.X := 5;
    MenuItem.Position.Y := (I - 1) * 45;
    MenuItem.Width := 250;
    MenuItem.Height := 42;
    MenuItem.Fill.Color := $10FFFFFF;
    MenuItem.Stroke.Kind := TBrushKind.None;
    MenuItem.XRadius := 8;
    MenuItem.YRadius := 8;
    MenuItem.Cursor := crHandPoint;
    MenuItem.Tag := I;
    MenuItem.OnClick := CardClick;
    MenuItem.OnMouseEnter := MenuItemMouseEnter;
    MenuItem.OnMouseLeave := MenuItemMouseLeave;
    
    LblIcone := TLabel.Create(MenuItem);
    LblIcone.Parent := MenuItem;
    LblIcone.Position.X := 10;
    LblIcone.Position.Y := 0;
    LblIcone.Width := 30;
    LblIcone.Height := 42;
    LblIcone.StyledSettings := [];
    LblIcone.TextSettings.Font.Size := 18;
    LblIcone.TextSettings.VertAlign := TTextAlign.Center;
    LblIcone.Text := CARD_ICONES[I];
    LblIcone.HitTest := False;
    
    LblTitulo := TLabel.Create(MenuItem);
    LblTitulo.Parent := MenuItem;
    LblTitulo.Position.X := 45;
    LblTitulo.Position.Y := 0;
    LblTitulo.Width := 195;
    LblTitulo.Height := 42;
    LblTitulo.StyledSettings := [];
    LblTitulo.TextSettings.Font.Size := 12;
    LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblTitulo.TextSettings.FontColor := TAlphaColors.White;
    LblTitulo.TextSettings.VertAlign := TTextAlign.Center;
    LblTitulo.Text := CARD_TITULOS[I];
    LblTitulo.HitTest := False;
    
    FMenuItems[I] := MenuItem;
  end;
end;

procedure TFormAdministrativo.CriarItensDecorativos;
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

procedure TFormAdministrativo.TimerDecorTimer(Sender: TObject);
begin
  AnimarDecorItems;
end;

procedure TFormAdministrativo.AnimarDecorItems;
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

procedure TFormAdministrativo.TimerLogoMenuTimer(Sender: TObject);
begin
  if FMenuAberto then
  begin
    if FLogoGrow then
    begin
      FLogoScale := FLogoScale + 0.01;
      if FLogoScale >= 1.1 then FLogoGrow := False;
    end
    else
    begin
      FLogoScale := FLogoScale - 0.01;
      if FLogoScale <= 1.0 then FLogoGrow := True;
    end;
    CircleLogoMenu.Scale.X := FLogoScale;
    CircleLogoMenu.Scale.Y := FLogoScale;
  end;
end;

procedure TFormAdministrativo.RectBtnMenuClick(Sender: TObject);
begin
  if FMenuAberto then FecharMenu else AbrirMenu;
end;

procedure TFormAdministrativo.AbrirMenu;
begin
  FMenuAberto := True;
  RectMenuOverlay.Visible := True;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0.6, 0.3);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', 0, 0.3, TAnimationType.Out, TInterpolationType.Quadratic);
  LblBtnMenu.Text := '✕';
end;

procedure TFormAdministrativo.FecharMenu;
begin
  FMenuAberto := False;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0, 0.25);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', -280, 0.25, TAnimationType.In, TInterpolationType.Quadratic);
  LblBtnMenu.Text := '☰';
  TThread.CreateAnonymousThread(procedure begin
    Sleep(260);
    TThread.Synchronize(nil, procedure begin
      if not FMenuAberto then RectMenuOverlay.Visible := False;
    end);
  end).Start;
end;

procedure TFormAdministrativo.RectMenuOverlayClick(Sender: TObject);
begin
  FecharMenu;
end;

procedure TFormAdministrativo.RectBtnVoltarClick(Sender: TObject);
begin
  TimerDecor.Enabled := False;
  TimerLogoMenu.Enabled := False;
  FormLogin.Show;
  Self.Hide;
end;

procedure TFormAdministrativo.RectBtnSairClick(Sender: TObject);
begin
  FecharMenu;
  TThread.CreateAnonymousThread(procedure begin
    Sleep(300);
    TThread.Synchronize(nil, procedure begin RectBtnVoltarClick(nil); end);
  end).Start;
end;

procedure TFormAdministrativo.MenuItemMouseEnter(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    Rect.Fill.Color := $25FFFFFF;
  end;
end;

procedure TFormAdministrativo.MenuItemMouseLeave(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    Rect.Fill.Color := $10FFFFFF;
  end;
end;

procedure TFormAdministrativo.CardMouseEnter(Sender: TObject);
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

procedure TFormAdministrativo.CardMouseLeave(Sender: TObject);
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

procedure TFormAdministrativo.CardClick(Sender: TObject);
var
  CardIndex: Integer;
begin
  if Sender is TRectangle then
  begin
    CardIndex := TRectangle(Sender).Tag;
    if FMenuAberto then FecharMenu;
    TThread.CreateAnonymousThread(procedure begin
      if FMenuAberto then Sleep(300);
      TThread.Synchronize(nil, procedure begin MostrarDetalhe(CardIndex); end);
    end).Start;
  end;
end;

procedure TFormAdministrativo.MostrarDetalhe(CardIndex: Integer);
begin
  LblDetalheTitulo.Text := CARD_TITULOS[CardIndex];
  LimparScrollBox(ScrollBoxDetalhe);
  
  case CardIndex of
    1: CarregarMatriculasAnuais;
    2: CarregarEvasoesMes;
    3: CarregarEvasoesSerie;
    4: CarregarMatriculasMes;
    5: CarregarMatriculasSerie;
    6: CarregarEvasoesMatriculasRS;
    7: CarregarDespesasGerais;
    8: CarregarAguaLuz;
    9: CarregarOutrosGastos;
    10: CarregarPerdasEvasoes;
    11: CarregarGanhosMatriculas;
    12: CarregarContasReceberPagar;
  end;
  
  ScrollBoxConteudo.Visible := False;
  RectDetalhe.Visible := True;
  RectDetalhe.Opacity := 0;
  RectDetalhe.Scale.X := 0.95;
  RectDetalhe.Scale.Y := 0.95;
  
  TAnimator.AnimateFloat(RectDetalhe, 'Opacity', 1, 0.3);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.X', 1, 0.3, TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.Y', 1, 0.3, TAnimationType.Out, TInterpolationType.Back);
end;

procedure TFormAdministrativo.RectBtnFecharDetalheClick(Sender: TObject);
begin
  TAnimator.AnimateFloat(RectDetalhe, 'Opacity', 0, 0.2);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.X', 0.95, 0.2);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.Y', 0.95, 0.2);
  TThread.CreateAnonymousThread(procedure begin
    Sleep(220);
    TThread.Synchronize(nil, procedure begin
      RectDetalhe.Visible := False;
      ScrollBoxConteudo.Visible := True;
    end);
  end).Start;
end;

procedure TFormAdministrativo.LimparScrollBox(SB: TVertScrollBox);
var
  I: Integer;
begin
  for I := SB.Content.ChildrenCount - 1 downto 0 do
    SB.Content.Children[I].Free;
end;

// ==================== GRÁFICOS ====================

procedure TFormAdministrativo.CriarGraficoBarras(Parent: TFmxObject; Titulo: string; Labels: array of string; Valores: array of Double; Cor: TAlphaColor);
var
  I, N: Integer;
  MaxVal, BarW, BarH, PosX, PosY, Scale: Single;
  RectContainer, RectBar: TRectangle;
  LblTitulo, LblLabel, LblValor: TLabel;
  MaxY: Single;
  Ctrl: TControl;
begin
  N := Length(Valores);
  if N = 0 then Exit;
  
  MaxVal := 0;
  for I := 0 to N - 1 do
    if Valores[I] > MaxVal then MaxVal := Valores[I];
  if MaxVal = 0 then MaxVal := 1;
  
  // Calcula posição Y baseado nos filhos existentes
  MaxY := 0;
  if Parent is TContent then
  begin
    for I := 0 to TContent(Parent).ChildrenCount - 1 do
    begin
      if TContent(Parent).Children[I] is TControl then
      begin
        Ctrl := TControl(TContent(Parent).Children[I]);
        if (Ctrl.Position.Y + Ctrl.Height) > MaxY then
          MaxY := Ctrl.Position.Y + Ctrl.Height;
      end;
    end;
  end;
  
  RectContainer := TRectangle.Create(Self);
  RectContainer.Parent := Parent;
  RectContainer.Position.X := 0;
  RectContainer.Position.Y := MaxY + 10;
  RectContainer.Width := 395;
  RectContainer.Height := 220;
  RectContainer.Fill.Color := $15FFFFFF;
  RectContainer.Stroke.Color := COR_BORDA;
  RectContainer.Stroke.Thickness := 1;
  RectContainer.XRadius := 10;
  RectContainer.YRadius := 10;
  
  LblTitulo := TLabel.Create(RectContainer);
  LblTitulo.Parent := RectContainer;
  LblTitulo.Position.X := 10;
  LblTitulo.Position.Y := 8;
  LblTitulo.Width := 360;
  LblTitulo.Height := 22;
  LblTitulo.StyledSettings := [];
  LblTitulo.TextSettings.Font.Size := 13;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor := TAlphaColors.White;
  LblTitulo.Text := Titulo;
  
  BarW := (360 - (N + 1) * 8) / N;
  if BarW > 50 then BarW := 50;
  
  for I := 0 to N - 1 do
  begin
    Scale := Valores[I] / MaxVal;
    BarH := Scale * 120;
    if BarH < 5 then BarH := 5;
    
    PosX := 15 + I * (BarW + 8);
    PosY := 160 - BarH;
    
    RectBar := TRectangle.Create(RectContainer);
    RectBar.Parent := RectContainer;
    RectBar.Position.X := PosX;
    RectBar.Position.Y := PosY;
    RectBar.Width := BarW;
    RectBar.Height := BarH;
    RectBar.Fill.Color := Cor;
    RectBar.Stroke.Kind := TBrushKind.None;
    RectBar.XRadius := 4;
    RectBar.YRadius := 4;
    
    LblValor := TLabel.Create(RectContainer);
    LblValor.Parent := RectContainer;
    LblValor.Position.X := PosX - 5;
    LblValor.Position.Y := PosY - 18;
    LblValor.Width := BarW + 10;
    LblValor.Height := 16;
    LblValor.StyledSettings := [];
    LblValor.TextSettings.Font.Size := 9;
    LblValor.TextSettings.FontColor := COR_DOURADO;
    LblValor.TextSettings.HorzAlign := TTextAlign.Center;
    LblValor.Text := FormatFloat('#,##0', Valores[I]);
    
    if I < Length(Labels) then
    begin
      LblLabel := TLabel.Create(RectContainer);
      LblLabel.Parent := RectContainer;
      LblLabel.Position.X := PosX - 5;
      LblLabel.Position.Y := 170;
      LblLabel.Width := BarW + 10;
      LblLabel.Height := 40;
      LblLabel.StyledSettings := [];
      LblLabel.TextSettings.Font.Size := 8;
      LblLabel.TextSettings.FontColor := $CCFFFFFF;
      LblLabel.TextSettings.HorzAlign := TTextAlign.Center;
      LblLabel.TextSettings.WordWrap := True;
      LblLabel.Text := Labels[I];
    end;
  end;
end;

procedure TFormAdministrativo.CriarGraficoPizza(Parent: TFmxObject; Titulo: string; Labels: array of string; Valores: array of Double; Cores: array of TAlphaColor);
var
  I, N: Integer;
  Total, Percent, CurrentAngle, SweepAngle: Single;
  RectContainer: TRectangle;
  LblTitulo, LblLegenda: TLabel;
  PieFatia: TPie;
  RectLegendaItem: TRectangle;
  CoresLocais: array[0..11] of TAlphaColor;
  MaxY: Single;
  Ctrl: TControl;
begin
  N := Length(Valores);
  if N = 0 then Exit;
  
  // Cores para cada fatia
  CoresLocais[0] := $FFD33327;   // Vermelho
  CoresLocais[1] := $FFFF9800;   // Laranja
  CoresLocais[2] := $FFFDCD62;   // Dourado
  CoresLocais[3] := $FF4CAF50;   // Verde
  CoresLocais[4] := $FF2196F3;   // Azul
  CoresLocais[5] := $FF9C27B0;   // Roxo
  CoresLocais[6] := $FF00BCD4;   // Cyan
  CoresLocais[7] := $FFE91E63;   // Pink
  CoresLocais[8] := $FFFF5722;   // Deep Orange
  CoresLocais[9] := $FF795548;   // Brown
  CoresLocais[10] := $FF607D8B;  // Blue Grey
  CoresLocais[11] := $FF9E9E9E;  // Grey
  
  Total := 0;
  for I := 0 to N - 1 do
    Total := Total + Valores[I];
  if Total = 0 then Total := 1;
  
  // Calcula posição Y baseado nos filhos existentes
  MaxY := 0;
  if Parent is TContent then
  begin
    for I := 0 to TContent(Parent).ChildrenCount - 1 do
    begin
      if TContent(Parent).Children[I] is TControl then
      begin
        Ctrl := TControl(TContent(Parent).Children[I]);
        if (Ctrl.Position.Y + Ctrl.Height) > MaxY then
          MaxY := Ctrl.Position.Y + Ctrl.Height;
      end;
    end;
  end;
  
  RectContainer := TRectangle.Create(Self);
  RectContainer.Parent := Parent;
  RectContainer.Position.X := 0;
  RectContainer.Position.Y := MaxY + 10;
  RectContainer.Width := 395;
  RectContainer.Height := 280;
  RectContainer.Fill.Color := $15FFFFFF;
  RectContainer.Stroke.Color := COR_BORDA;
  RectContainer.Stroke.Thickness := 1;
  RectContainer.XRadius := 10;
  RectContainer.YRadius := 10;
  
  LblTitulo := TLabel.Create(RectContainer);
  LblTitulo.Parent := RectContainer;
  LblTitulo.Position.X := 10;
  LblTitulo.Position.Y := 8;
  LblTitulo.Width := 360;
  LblTitulo.Height := 22;
  LblTitulo.StyledSettings := [];
  LblTitulo.TextSettings.Font.Size := 13;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor := TAlphaColors.White;
  LblTitulo.Text := Titulo;
  
  CurrentAngle := 0;
  for I := 0 to N - 1 do
  begin
    Percent := Valores[I] / Total;
    SweepAngle := Percent * 360;
    
    // Usa TPie para desenhar fatia preenchida
    PieFatia := TPie.Create(RectContainer);
    PieFatia.Parent := RectContainer;
    PieFatia.Position.X := 30;
    PieFatia.Position.Y := 40;
    PieFatia.Width := 140;
    PieFatia.Height := 140;
    PieFatia.StartAngle := CurrentAngle;
    PieFatia.EndAngle := CurrentAngle + SweepAngle;
    PieFatia.Fill.Color := CoresLocais[I mod 12];
    PieFatia.Stroke.Color := $40000000;
    PieFatia.Stroke.Thickness := 1;
    
    CurrentAngle := CurrentAngle + SweepAngle;
    
    // Legenda
    if I < Length(Labels) then
    begin
      RectLegendaItem := TRectangle.Create(RectContainer);
      RectLegendaItem.Parent := RectContainer;
      RectLegendaItem.Position.X := 190;
      RectLegendaItem.Position.Y := 32 + I * 19;
      RectLegendaItem.Width := 12;
      RectLegendaItem.Height := 12;
      RectLegendaItem.Fill.Color := CoresLocais[I mod 12];
      RectLegendaItem.Stroke.Kind := TBrushKind.None;
      RectLegendaItem.XRadius := 3;
      RectLegendaItem.YRadius := 3;
      
      LblLegenda := TLabel.Create(RectContainer);
      LblLegenda.Parent := RectContainer;
      LblLegenda.Position.X := 208;
      LblLegenda.Position.Y := 29 + I * 19;
      LblLegenda.Width := 165;
      LblLegenda.Height := 18;
      LblLegenda.StyledSettings := [];
      LblLegenda.TextSettings.Font.Size := 9;
      LblLegenda.TextSettings.FontColor := $CCFFFFFF;
      LblLegenda.Text := Labels[I] + ': ' + FormatFloat('#,##0', Valores[I]) + ' (' + FormatFloat('0.0', Percent * 100) + '%)';
    end;
  end;
end;

procedure TFormAdministrativo.CriarGraficoLinhas(Parent: TFmxObject; Titulo: string; Labels: array of string; Valores: array of Double; Cor: TAlphaColor);
var
  I, N, NumGridLines: Integer;
  MaxVal, MinVal, PrevX, PrevY, Scale, GridY, GridVal: Single;
  StepX, ChartLeft, ChartRight, ChartTop, ChartBottom, ChartWidth, ChartHeight: Single;
  RectContainer, RectAreaFill: TRectangle;
  LblTitulo, LblLabel, LblGridVal: TLabel;
  LinhaGrid, LinhaConexao: TLine;
  CirclePoint: TCircle;
  Pontos: array of TPointF;
  MaxY: Single;
  Ctrl: TControl;
begin
  N := Length(Valores);
  if N = 0 then Exit;
  
  // Encontra min/max
  MaxVal := Valores[0];
  MinVal := Valores[0];
  for I := 1 to N - 1 do
  begin
    if Valores[I] > MaxVal then MaxVal := Valores[I];
    if Valores[I] < MinVal then MinVal := Valores[I];
  end;
  // Adiciona margem de 10%
  MinVal := MinVal * 0.9;
  MaxVal := MaxVal * 1.1;
  if MaxVal = MinVal then MaxVal := MinVal + 1;
  
  // Dimensões do gráfico
  ChartLeft := 55;
  ChartRight := 370;
  ChartTop := 45;
  ChartBottom := 175;
  ChartWidth := ChartRight - ChartLeft;
  ChartHeight := ChartBottom - ChartTop;
  NumGridLines := 5;
  
  // Calcula posição Y baseado nos filhos existentes
  MaxY := 0;
  if Parent is TContent then
  begin
    for I := 0 to TContent(Parent).ChildrenCount - 1 do
    begin
      if TContent(Parent).Children[I] is TControl then
      begin
        Ctrl := TControl(TContent(Parent).Children[I]);
        if (Ctrl.Position.Y + Ctrl.Height) > MaxY then
          MaxY := Ctrl.Position.Y + Ctrl.Height;
      end;
    end;
  end;
  
  // Container principal
  RectContainer := TRectangle.Create(Self);
  RectContainer.Parent := Parent;
  RectContainer.Position.X := 0;
  RectContainer.Position.Y := MaxY + 10;
  RectContainer.Width := 395;
  RectContainer.Height := 230;
  RectContainer.Fill.Color := $15FFFFFF;
  RectContainer.Stroke.Color := COR_BORDA;
  RectContainer.Stroke.Thickness := 1;
  RectContainer.XRadius := 10;
  RectContainer.YRadius := 10;
  
  // Título
  LblTitulo := TLabel.Create(RectContainer);
  LblTitulo.Parent := RectContainer;
  LblTitulo.Position.X := 10;
  LblTitulo.Position.Y := 8;
  LblTitulo.Width := 365;
  LblTitulo.Height := 22;
  LblTitulo.StyledSettings := [];
  LblTitulo.TextSettings.Font.Size := 13;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor := TAlphaColors.White;
  LblTitulo.Text := Titulo;
  
  // Linhas de grade horizontais + valores do eixo Y
  for I := 0 to NumGridLines do
  begin
    GridY := ChartBottom - (I / NumGridLines) * ChartHeight;
    GridVal := MinVal + (I / NumGridLines) * (MaxVal - MinVal);
    
    // Linha de grade
    LinhaGrid := TLine.Create(RectContainer);
    LinhaGrid.Parent := RectContainer;
    LinhaGrid.Position.X := ChartLeft;
    LinhaGrid.Position.Y := GridY;
    LinhaGrid.Width := ChartWidth;
    LinhaGrid.Height := 1;
    LinhaGrid.Stroke.Color := $20FFFFFF;
    LinhaGrid.Stroke.Thickness := 1;
    if I = 0 then
      LinhaGrid.Stroke.Color := $40FFFFFF; // Linha base mais visível
    
    // Valor do eixo Y
    LblGridVal := TLabel.Create(RectContainer);
    LblGridVal.Parent := RectContainer;
    LblGridVal.Position.X := 5;
    LblGridVal.Position.Y := GridY - 8;
    LblGridVal.Width := 48;
    LblGridVal.Height := 16;
    LblGridVal.StyledSettings := [];
    LblGridVal.TextSettings.Font.Size := 8;
    LblGridVal.TextSettings.FontColor := $99FFFFFF;
    LblGridVal.TextSettings.HorzAlign := TTextAlign.Trailing;
    LblGridVal.Text := FormatFloat('#,##0', GridVal);
  end;
  
  // Calcula pontos
  SetLength(Pontos, N);
  if N > 1 then
    StepX := ChartWidth / (N - 1)
  else
    StepX := ChartWidth;
    
  for I := 0 to N - 1 do
  begin
    Scale := (Valores[I] - MinVal) / (MaxVal - MinVal);
    Pontos[I].X := ChartLeft + I * StepX;
    Pontos[I].Y := ChartBottom - Scale * ChartHeight;
  end;
  
  // Área preenchida abaixo da linha (efeito gradiente)
  for I := 0 to N - 2 do
  begin
    RectAreaFill := TRectangle.Create(RectContainer);
    RectAreaFill.Parent := RectContainer;
    RectAreaFill.Position.X := Pontos[I].X;
    RectAreaFill.Position.Y := Min(Pontos[I].Y, Pontos[I+1].Y);
    RectAreaFill.Width := StepX;
    RectAreaFill.Height := ChartBottom - Min(Pontos[I].Y, Pontos[I+1].Y);
    RectAreaFill.Fill.Kind := TBrushKind.Gradient;
    RectAreaFill.Fill.Gradient.Color := Cor;
    RectAreaFill.Fill.Gradient.Color1 := $00000000;
    RectAreaFill.Fill.Gradient.StartPosition.Y := 0;
    RectAreaFill.Fill.Gradient.StopPosition.Y := 1;
    RectAreaFill.Stroke.Kind := TBrushKind.None;
    RectAreaFill.Opacity := 0.3;
  end;
  
  // Linhas conectando os pontos
  PrevX := Pontos[0].X;
  PrevY := Pontos[0].Y;
  for I := 1 to N - 1 do
  begin
    LinhaConexao := TLine.Create(RectContainer);
    LinhaConexao.Parent := RectContainer;
    LinhaConexao.Position.X := PrevX;
    LinhaConexao.Position.Y := PrevY;
    LinhaConexao.Width := Pontos[I].X - PrevX;
    LinhaConexao.Height := Pontos[I].Y - PrevY;
    LinhaConexao.Stroke.Color := Cor;
    LinhaConexao.Stroke.Thickness := 3;
    LinhaConexao.LineType := TLineType.Diagonal;
    
    PrevX := Pontos[I].X;
    PrevY := Pontos[I].Y;
  end;
  
  // Pontos e labels
  for I := 0 to N - 1 do
  begin
    // Círculo do ponto
    CirclePoint := TCircle.Create(RectContainer);
    CirclePoint.Parent := RectContainer;
    CirclePoint.Position.X := Pontos[I].X - 6;
    CirclePoint.Position.Y := Pontos[I].Y - 6;
    CirclePoint.Width := 12;
    CirclePoint.Height := 12;
    CirclePoint.Fill.Color := Cor;
    CirclePoint.Stroke.Color := TAlphaColors.White;
    CirclePoint.Stroke.Thickness := 2;
    
    // Label do mês (eixo X)
    if I < Length(Labels) then
    begin
      LblLabel := TLabel.Create(RectContainer);
      LblLabel.Parent := RectContainer;
      LblLabel.Position.X := Pontos[I].X - 18;
      LblLabel.Position.Y := ChartBottom + 5;
      LblLabel.Width := 36;
      LblLabel.Height := 20;
      LblLabel.StyledSettings := [];
      LblLabel.TextSettings.Font.Size := 9;
      LblLabel.TextSettings.FontColor := $CCFFFFFF;
      LblLabel.TextSettings.HorzAlign := TTextAlign.Center;
      LblLabel.Text := Labels[I];
    end;
  end;
end;

procedure TFormAdministrativo.CriarCardResumo(Parent: TFmxObject; Titulo, Valor, Subtitulo: string; Cor: TAlphaColor; PosY: Single);
var
  RectCard: TRectangle;
  LblTitulo, LblValor, LblSubtitulo: TLabel;
  I: Integer;
  MaxY: Single;
  Ctrl: TControl;
begin
  // Calcula posição Y automaticamente baseado nos filhos existentes
  MaxY := 0;
  if Parent is TContent then
  begin
    for I := 0 to TContent(Parent).ChildrenCount - 1 do
    begin
      if TContent(Parent).Children[I] is TControl then
      begin
        Ctrl := TControl(TContent(Parent).Children[I]);
        if (Ctrl.Position.Y + Ctrl.Height) > MaxY then
          MaxY := Ctrl.Position.Y + Ctrl.Height;
      end;
    end;
  end;
  
  RectCard := TRectangle.Create(Self);
  RectCard.Parent := Parent;
  RectCard.Position.X := 0;
  RectCard.Position.Y := MaxY + 10; // 10px de margem
  RectCard.Width := 395;
  RectCard.Height := 100;
  RectCard.Fill.Color := $20FFFFFF;
  RectCard.Stroke.Color := Cor;
  RectCard.Stroke.Thickness := 2;
  RectCard.XRadius := 12;
  RectCard.YRadius := 12;
  
  LblTitulo := TLabel.Create(RectCard);
  LblTitulo.Parent := RectCard;
  LblTitulo.Position.X := 15;
  LblTitulo.Position.Y := 12;
  LblTitulo.Width := 350;
  LblTitulo.Height := 20;
  LblTitulo.StyledSettings := [];
  LblTitulo.TextSettings.Font.Size := 13;
  LblTitulo.TextSettings.FontColor := $CCFFFFFF;
  LblTitulo.Text := Titulo;
  
  LblValor := TLabel.Create(RectCard);
  LblValor.Parent := RectCard;
  LblValor.Position.X := 15;
  LblValor.Position.Y := 35;
  LblValor.Width := 350;
  LblValor.Height := 35;
  LblValor.StyledSettings := [];
  LblValor.TextSettings.Font.Size := 26;
  LblValor.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblValor.TextSettings.FontColor := Cor;
  LblValor.Text := Valor;
  
  LblSubtitulo := TLabel.Create(RectCard);
  LblSubtitulo.Parent := RectCard;
  LblSubtitulo.Position.X := 15;
  LblSubtitulo.Position.Y := 72;
  LblSubtitulo.Width := 350;
  LblSubtitulo.Height := 18;
  LblSubtitulo.StyledSettings := [];
  LblSubtitulo.TextSettings.Font.Size := 11;
  LblSubtitulo.TextSettings.FontColor := $99FFFFFF;
  LblSubtitulo.Text := Subtitulo;
end;

// ==================== CONTEÚDOS FICTÍCIOS ====================

procedure TFormAdministrativo.CarregarMatriculasAnuais;
begin
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Matrículas Realizadas por Ano',
    ['2020', '2021', '2022', '2023', '2024'],
    [420, 385, 510, 545, 580],
    COR_AZUL);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Total de Matrículas em 2024', '580 alunos',
    'Aumento de 6.4% em relação a 2023', COR_VERDE, 240);
end;

procedure TFormAdministrativo.CarregarEvasoesMes;
begin
  CriarGraficoPizza(ScrollBoxDetalhe.Content,
    'Evasões por Mês - 2024',
    ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
    [3, 2, 5, 4, 6, 3, 8, 2, 4, 3, 2, 1],
    [COR_DOURADO, COR_LARANJA, COR_DOURADO_CLARO, COR_VERDE, COR_AZUL, COR_ROXO,
     COR_CYAN, COR_PINK, $FFFF5722, $FF795548, $FF607D8B, $FF9E9E9E]);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Total de Evasões em 2024', '43 alunos',
    'Representa 7.4% do total de matrículas', COR_DOURADO, 300);
end;

procedure TFormAdministrativo.CarregarEvasoesSerie;
begin
  CriarGraficoPizza(ScrollBoxDetalhe.Content,
    'Evasões por Série - 2024',
    ['Ed.Inf', '1ºAno', '2ºAno', '3ºAno', '4ºAno', '5ºAno', '6ºAno', '7ºAno', '8ºAno', '9ºAno', 'EM'],
    [2, 3, 4, 3, 5, 4, 6, 5, 4, 4, 3],
    [COR_PINK, COR_ROXO, COR_AZUL, COR_CYAN, COR_VERDE, COR_DOURADO,
     COR_LARANJA, COR_DOURADO_CLARO, $FFFF5722, $FF795548, $FF607D8B]);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Série com Maior Evasão', '6º Ano - 6 alunos',
    'Recomenda-se ações de retenção nesta série', COR_DOURADO, 300);
end;

procedure TFormAdministrativo.CarregarMatriculasMes;
begin
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Novas Matrículas por Mês - 2024',
    ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
    [180, 120, 45, 32, 28, 15, 42, 35, 25, 22, 18, 18],
    COR_VERDE);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Pico de Matrículas', 'Janeiro - 180 matrículas',
    'Período de maior captação de novos alunos', COR_VERDE, 240);
end;

procedure TFormAdministrativo.CarregarMatriculasSerie;
begin
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Matrículas por Série - 2024',
    ['Ed.Inf', '1ºAno', '2ºAno', '3ºAno', '4ºAno', '5ºAno', '6ºAno', '7ºAno', '8ºAno', '9ºAno', 'EM'],
    [45, 52, 55, 48, 58, 62, 55, 52, 48, 45, 60],
    COR_AZUL);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Série com Mais Alunos', '5º Ano - 62 alunos',
    'Distribuição equilibrada entre as séries', COR_AZUL, 240);
end;

procedure TFormAdministrativo.CarregarEvasoesMatriculasRS;
begin
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Comparativo Financeiro - 2024 (em R$ mil)',
    ['Matrículas', 'Evasões'],
    [870, 64.5],
    COR_DOURADO);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Receita com Matrículas', 'R$ 870.000,00',
    '580 alunos x R$ 1.500,00 (média anual)', COR_VERDE, 240);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Perda com Evasões', 'R$ 64.500,00',
    '43 alunos x R$ 1.500,00 (proporcional)', COR_DOURADO, 350);
end;

procedure TFormAdministrativo.CarregarDespesasGerais;
begin
  CriarGraficoLinhas(ScrollBoxDetalhe.Content,
    'Despesas Gerais Mensais - 2024 (em R$ mil)',
    ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
    [85, 78, 82, 79, 84, 88, 75, 80, 83, 86, 89, 92],
    COR_LARANJA);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Total de Despesas em 2024', 'R$ 1.001.000,00',
    'Média mensal de R$ 83.416,67', COR_LARANJA, 240);
end;

procedure TFormAdministrativo.CarregarAguaLuz;
begin
  CriarGraficoLinhas(ScrollBoxDetalhe.Content,
    'Consumo de Água e Luz - 2024 (em R$)',
    ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
    [4500, 4800, 4200, 3900, 3500, 3200, 2800, 3100, 3600, 4100, 4400, 4700],
    COR_CYAN);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Total Água e Luz em 2024', 'R$ 46.800,00',
    'Economia de 8% em relação a 2023', COR_CYAN, 240);
end;

procedure TFormAdministrativo.CarregarOutrosGastos;
begin
  CriarGraficoLinhas(ScrollBoxDetalhe.Content,
    'Outros Gastos Mensais - 2024 (em R$)',
    ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
    [12000, 8500, 9200, 7800, 11500, 14000, 6500, 8900, 10200, 9800, 15000, 18500],
    COR_ROXO);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Total Outros Gastos 2024', 'R$ 131.900,00',
    'Inclui manutenção, material didático e eventos', COR_ROXO, 240);
end;

procedure TFormAdministrativo.CarregarPerdasEvasoes;
begin
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Perda Total com Evasões - 2024', 'R$ 64.500,00',
    '43 alunos evadidos até dezembro', COR_DOURADO, 0);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Média de Perda por Evasão', 'R$ 1.500,00',
    'Valor médio de mensalidade anual', COR_DOURADO, 120);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Impacto no Faturamento', '-6.9%',
    'Percentual de perda sobre receita prevista', COR_DOURADO_CLARO, 240);
    
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Perdas com Evasões - Últimos 5 Anos (em R$ mil)',
    ['2020', '2021', '2022', '2023', '2024'],
    [42, 55, 38, 51, 64.5],
    COR_DOURADO);
end;

procedure TFormAdministrativo.CarregarGanhosMatriculas;
begin
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Receita com Matrículas - 2024', 'R$ 870.000,00',
    '580 alunos matriculados', COR_VERDE, 0);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Receita Líquida', 'R$ 805.500,00',
    'Após desconto das evasões', COR_VERDE, 120);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Crescimento Anual', '+8.2%',
    'Em relação ao ano anterior', COR_DOURADO, 240);
    
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Receita com Matrículas - Últimos 5 Anos (em R$ mil)',
    ['2020', '2021', '2022', '2023', '2024'],
    [630, 578, 765, 817, 870],
    COR_VERDE);
end;

procedure TFormAdministrativo.CarregarContasReceberPagar;
begin
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Contas a Receber - Últimos 10 Anos (em R$ mil)',
    ['2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024'],
    [520, 545, 580, 610, 595, 630, 578, 765, 817, 870],
    COR_VERDE);
    
  CriarGraficoBarras(ScrollBoxDetalhe.Content,
    'Contas a Pagar - Últimos 10 Anos (em R$ mil)',
    ['2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024'],
    [480, 510, 535, 565, 550, 590, 545, 720, 780, 850],
    COR_DOURADO);
    
  CriarCardResumo(ScrollBoxDetalhe.Content,
    'Saldo Atual (Receber - Pagar)', 'R$ 20.000,00',
    'Situação financeira equilibrada', COR_DOURADO_CLARO, 490);
end;

end.
