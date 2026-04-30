unit UnitResponsavel;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects, FMX.Layouts,
  FMX.Filter.Effects, System.IOUtils, FMX.ListBox;

type
  TFormResponsavel = class(TForm)
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
    RectDetalhe: TRectangle;
    RectDetalheHeader: TRectangle;
    LblDetalheTitulo: TLabel;
    RectBtnFecharDetalhe: TRectangle;
    LblBtnFecharDetalhe: TLabel;
    RectDetalheConteudo: TRectangle;
    VertScrollBox: TVertScrollBox;
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
    procedure CriarItensDecorativos;
    procedure AnimarDecorItems;
    procedure AbrirMenu;
    procedure FecharMenu;
    procedure MostrarCards;
    procedure MostrarDetalhe(Titulo: string; Tipo: Integer);
    procedure CriarItemLista(Parent: TFmxObject; Titulo, Subtitulo, Info: string; Cor: TAlphaColor);
    procedure CriarItemBoletim(Parent: TFmxObject; Materia: string; N1, N2, N3, N4, Media: Double; Situacao: string);
    procedure CriarItemFatura(Parent: TFmxObject; Mes: string; Valor: Double; Vencimento, Status: string; CorStatus: TAlphaColor);
    procedure LimparScrollBox;
    function FormatarMoedaBR(Valor: Double): string;
    // Conteúdos fictícios
    procedure CarregarBoletim;
    procedure CarregarFaturas;
    procedure CarregarNotificacoes;
  public
    NomeUsuario: string;
    NomeAluno: string;
  end;

var
  FormResponsavel: TFormResponsavel;

const
  COR_VERMELHO = $FFD33327;
  COR_VERMELHO_ESCURO = $FF7D2728;
  COR_DOURADO = $FFFDCD62;
  COR_DOURADO_CLARO = $FFFFEABB;
  COR_CARD = $20FFFFFF;
  COR_CARD_HOVER = $35FFFFFF;
  COR_BORDA = $4DFDCD62;
  COR_VERDE = $FF4CAF50;
  COR_LARANJA = $FFFF9800;

implementation

{$R *.fmx}

uses UnitLogin;

procedure TFormResponsavel.FormCreate(Sender: TObject);
begin
  FMenuAberto := False;
  FLogoScale := 1.0;
  FLogoGrow := True;
  NomeAluno := 'João Pedro Silva';
  
  // Menu começa fechado
  RectMenuLateral.Position.X := -280;
  RectMenuOverlay.Visible := False;
  RectMenuOverlay.Opacity := 0;
  
  // Detalhe começa escondido
  RectDetalhe.Visible := False;
  RectDetalhe.Opacity := 0;
  
  // Cria objetos escolares decorativos
  CriarItensDecorativos;
end;

procedure TFormResponsavel.FormShow(Sender: TObject);
begin
  // Atualiza informações do usuário
  if NomeUsuario <> '' then
    LblNomeUsuario.Text := NomeUsuario
  else
    LblNomeUsuario.Text := 'Responsável';
    
  LblTipoUsuario.Text := 'Área do Responsável';
  LblSubtituloHeader.Text := 'Olá, ' + LblNomeUsuario.Text + '!';
  
  // Mostra cards
  MostrarCards;
  
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

procedure TFormResponsavel.CriarItensDecorativos;
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

procedure TFormResponsavel.TimerDecorTimer(Sender: TObject);
begin
  AnimarDecorItems;
end;

procedure TFormResponsavel.AnimarDecorItems;
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

procedure TFormResponsavel.TimerLogoMenuTimer(Sender: TObject);
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

procedure TFormResponsavel.RectBtnMenuClick(Sender: TObject);
begin
  if FMenuAberto then
    FecharMenu
  else
    AbrirMenu;
end;

procedure TFormResponsavel.AbrirMenu;
begin
  FMenuAberto := True;
  RectMenuOverlay.Visible := True;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0.6, 0.3);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', 0, 0.3, TAnimationType.Out, TInterpolationType.Quadratic);
  LblBtnMenu.Text := '✕';
end;

procedure TFormResponsavel.FecharMenu;
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

procedure TFormResponsavel.RectMenuOverlayClick(Sender: TObject);
begin
  FecharMenu;
end;

procedure TFormResponsavel.RectBtnVoltarClick(Sender: TObject);
begin
  TimerDecor.Enabled := False;
  TimerLogoMenu.Enabled := False;
  FormLogin.Show;
  Self.Hide;
end;

procedure TFormResponsavel.RectBtnSairClick(Sender: TObject);
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

procedure TFormResponsavel.MenuItemMouseEnter(Sender: TObject);
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

procedure TFormResponsavel.MenuItemMouseLeave(Sender: TObject);
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

procedure TFormResponsavel.MenuItemClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := 0;
  
  if Sender = RectMenuItem1 then Index := 1
  else if Sender = RectMenuItem2 then Index := 2
  else if Sender = RectMenuItem3 then Index := 3;
  
  if Index > 0 then
  begin
    FecharMenu;
    case Index of
      1: MostrarDetalhe('Boletim Escolar', 1);
      2: MostrarDetalhe('Faturas', 2);
      3: MostrarDetalhe('Notificações', 3);
    end;
  end;
end;

procedure TFormResponsavel.CardMouseEnter(Sender: TObject);
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

procedure TFormResponsavel.CardMouseLeave(Sender: TObject);
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

procedure TFormResponsavel.CardClick(Sender: TObject);
begin
  if Sender = RectCard1 then
    MostrarDetalhe('Boletim Escolar', 1)
  else if Sender = RectCard2 then
    MostrarDetalhe('Faturas', 2)
  else if Sender = RectCard3 then
    MostrarDetalhe('Notificações', 3);
end;

procedure TFormResponsavel.MostrarCards;
begin
  RectConteudo.Visible := True;
  RectDetalhe.Visible := False;
  LblConteudoTitulo.Text := 'Área do Responsável';
  LblConteudoSubtitulo.Text := 'Acompanhe a vida escolar de ' + NomeAluno;
end;

procedure TFormResponsavel.MostrarDetalhe(Titulo: string; Tipo: Integer);
begin
  LblDetalheTitulo.Text := Titulo;
  LimparScrollBox;
  
  case Tipo of
    1: CarregarBoletim;
    2: CarregarFaturas;
    3: CarregarNotificacoes;
  end;
  
  // Esconde os cards
  RectConteudo.Visible := False;
  
  RectDetalhe.Visible := True;
  RectDetalhe.Opacity := 0;
  RectDetalhe.Scale.X := 0.95;
  RectDetalhe.Scale.Y := 0.95;
  
  TAnimator.AnimateFloat(RectDetalhe, 'Opacity', 1, 0.3);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.X', 1, 0.3, TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.Y', 1, 0.3, TAnimationType.Out, TInterpolationType.Back);
end;

procedure TFormResponsavel.RectBtnFecharDetalheClick(Sender: TObject);
begin
  TAnimator.AnimateFloat(RectDetalhe, 'Opacity', 0, 0.2);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.X', 0.95, 0.2);
  TAnimator.AnimateFloat(RectDetalhe, 'Scale.Y', 0.95, 0.2);
  
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(220);
      TThread.Synchronize(nil,
        procedure
        begin
          RectDetalhe.Visible := False;
          RectConteudo.Visible := True;
        end);
    end).Start;
end;

function TFormResponsavel.FormatarMoedaBR(Valor: Double): string;
var
  ParteInteira: Int64;
  ParteDecimal: Integer;
  StrInteira, StrDecimal, Resultado: string;
  I, Cont: Integer;
begin
  // Separa parte inteira e decimal
  ParteInteira := Trunc(Abs(Valor));
  ParteDecimal := Round(Frac(Abs(Valor)) * 100);
  
  // Formata parte decimal com 2 dígitos
  StrDecimal := Format('%.2d', [ParteDecimal]);
  
  // Converte parte inteira para string
  StrInteira := IntToStr(ParteInteira);
  
  // Adiciona pontos de milhar (da direita para esquerda)
  Resultado := '';
  Cont := 0;
  for I := Length(StrInteira) downto 1 do
  begin
    if (Cont > 0) and (Cont mod 3 = 0) then
      Resultado := '.' + Resultado;
    Resultado := StrInteira[I] + Resultado;
    Inc(Cont);
  end;
  
  // Junta com vírgula decimal
  Result := 'R$ ' + Resultado + ',' + StrDecimal;
end;

procedure TFormResponsavel.LimparScrollBox;
var
  I: Integer;
begin
  for I := VertScrollBox.Content.ChildrenCount - 1 downto 0 do
    VertScrollBox.Content.Children[I].Free;
end;

procedure TFormResponsavel.CriarItemLista(Parent: TFmxObject; Titulo, Subtitulo, Info: string; Cor: TAlphaColor);
var
  RectItem: TRectangle;
  LblTitulo, LblSubtitulo, LblInfo: TLabel;
  RectBadge: TRectangle;
  PosY: Single;
begin
  PosY := Parent.ChildrenCount * 95;
  
  RectItem := TRectangle.Create(Self);
  RectItem.Parent := Parent;
  RectItem.Position.X := 0;
  RectItem.Position.Y := PosY;
  RectItem.Width := VertScrollBox.Width - 10;
  RectItem.Height := 85;
  RectItem.Fill.Color := $18FFFFFF;
  RectItem.Stroke.Color := COR_BORDA;
  RectItem.Stroke.Thickness := 1;
  RectItem.XRadius := 12;
  RectItem.YRadius := 12;
  RectItem.HitTest := False;
  
  RectBadge := TRectangle.Create(Self);
  RectBadge.Parent := RectItem;
  RectBadge.Position.X := 10;
  RectBadge.Position.Y := 10;
  RectBadge.Width := 5;
  RectBadge.Height := 65;
  RectBadge.Fill.Color := Cor;
  RectBadge.Stroke.Kind := TBrushKind.None;
  RectBadge.XRadius := 3;
  RectBadge.YRadius := 3;
  
  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RectItem;
  LblTitulo.Position.X := 25;
  LblTitulo.Position.Y := 8;
  LblTitulo.Width := RectItem.Width - 100;
  LblTitulo.Height := 22;
  LblTitulo.StyledSettings := [];
  LblTitulo.TextSettings.Font.Size := 14;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor := TAlphaColors.White;
  LblTitulo.Text := Titulo;
  
  LblSubtitulo := TLabel.Create(Self);
  LblSubtitulo.Parent := RectItem;
  LblSubtitulo.Position.X := 25;
  LblSubtitulo.Position.Y := 30;
  LblSubtitulo.Width := RectItem.Width - 100;
  LblSubtitulo.Height := 18;
  LblSubtitulo.StyledSettings := [];
  LblSubtitulo.TextSettings.Font.Size := 11;
  LblSubtitulo.TextSettings.FontColor := $CCFFFFFF;
  LblSubtitulo.Text := Subtitulo;
  
  LblInfo := TLabel.Create(Self);
  LblInfo.Parent := RectItem;
  LblInfo.Position.X := 25;
  LblInfo.Position.Y := 48;
  LblInfo.Width := RectItem.Width - 40;
  LblInfo.Height := 32;
  LblInfo.StyledSettings := [];
  LblInfo.TextSettings.Font.Size := 10;
  LblInfo.TextSettings.FontColor := COR_DOURADO;
  LblInfo.TextSettings.WordWrap := True;
  LblInfo.Text := Info;
end;

procedure TFormResponsavel.CriarItemBoletim(Parent: TFmxObject; Materia: string; N1, N2, N3, N4, Media: Double; Situacao: string);
var
  RectItem: TRectangle;
  LblMateria, LblNotas, LblMedia, LblSituacao: TLabel;
  RectSituacao: TRectangle;
  PosY: Single;
  CorSituacao: TAlphaColor;
begin
  PosY := Parent.ChildrenCount * 95;
  
  RectItem := TRectangle.Create(Self);
  RectItem.Parent := Parent;
  RectItem.Position.X := 0;
  RectItem.Position.Y := PosY;
  RectItem.Width := VertScrollBox.Width - 10;
  RectItem.Height := 85;
  RectItem.Fill.Color := $18FFFFFF;
  RectItem.Stroke.Color := COR_BORDA;
  RectItem.Stroke.Thickness := 1;
  RectItem.XRadius := 12;
  RectItem.YRadius := 12;
  RectItem.HitTest := False;
  
  // Matéria
  LblMateria := TLabel.Create(Self);
  LblMateria.Parent := RectItem;
  LblMateria.Position.X := 15;
  LblMateria.Position.Y := 10;
  LblMateria.Width := 200;
  LblMateria.Height := 22;
  LblMateria.StyledSettings := [];
  LblMateria.TextSettings.Font.Size := 14;
  LblMateria.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblMateria.TextSettings.FontColor := TAlphaColors.White;
  LblMateria.Text := Materia;
  
  // Notas por bimestre
  LblNotas := TLabel.Create(Self);
  LblNotas.Parent := RectItem;
  LblNotas.Position.X := 15;
  LblNotas.Position.Y := 35;
  LblNotas.Width := 280;
  LblNotas.Height := 18;
  LblNotas.StyledSettings := [];
  LblNotas.TextSettings.Font.Size := 11;
  LblNotas.TextSettings.FontColor := $CCFFFFFF;
  LblNotas.Text := Format('1ºBim: %.1f | 2ºBim: %.1f | 3ºBim: %.1f | 4ºBim: %.1f', [N1, N2, N3, N4]);
  
  // Média
  LblMedia := TLabel.Create(Self);
  LblMedia.Parent := RectItem;
  LblMedia.Position.X := 15;
  LblMedia.Position.Y := 55;
  LblMedia.Width := 150;
  LblMedia.Height := 22;
  LblMedia.StyledSettings := [];
  LblMedia.TextSettings.Font.Size := 14;
  LblMedia.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblMedia.TextSettings.FontColor := COR_DOURADO;
  LblMedia.Text := Format('Média: %.1f', [Media]);
  
  // Situação
  if Situacao = 'Aprovado' then
    CorSituacao := COR_VERDE
  else if Situacao = 'Recuperação' then
    CorSituacao := COR_LARANJA
  else
    CorSituacao := COR_VERMELHO;
  
  RectSituacao := TRectangle.Create(Self);
  RectSituacao.Parent := RectItem;
  RectSituacao.Position.X := RectItem.Width - 110;
  RectSituacao.Position.Y := 28;
  RectSituacao.Width := 95;
  RectSituacao.Height := 28;
  RectSituacao.Fill.Color := CorSituacao;
  RectSituacao.Stroke.Kind := TBrushKind.None;
  RectSituacao.XRadius := 8;
  RectSituacao.YRadius := 8;
  
  LblSituacao := TLabel.Create(Self);
  LblSituacao.Parent := RectSituacao;
  LblSituacao.Align := TAlignLayout.Client;
  LblSituacao.StyledSettings := [];
  LblSituacao.TextSettings.Font.Size := 11;
  LblSituacao.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblSituacao.TextSettings.FontColor := TAlphaColors.White;
  LblSituacao.TextSettings.HorzAlign := TTextAlign.Center;
  LblSituacao.Text := Situacao;
end;

procedure TFormResponsavel.CriarItemFatura(Parent: TFmxObject; Mes: string; Valor: Double; Vencimento, Status: string; CorStatus: TAlphaColor);
var
  RectItem: TRectangle;
  LblMes, LblValor, LblVencimento, LblStatus: TLabel;
  RectStatus: TRectangle;
  PosY: Single;
begin
  PosY := Parent.ChildrenCount * 95;
  
  RectItem := TRectangle.Create(Self);
  RectItem.Parent := Parent;
  RectItem.Position.X := 0;
  RectItem.Position.Y := PosY;
  RectItem.Width := VertScrollBox.Width - 10;
  RectItem.Height := 85;
  RectItem.Fill.Color := $18FFFFFF;
  RectItem.Stroke.Color := COR_BORDA;
  RectItem.Stroke.Thickness := 1;
  RectItem.XRadius := 12;
  RectItem.YRadius := 12;
  RectItem.HitTest := False;
  
  // Mês com data de vencimento
  LblMes := TLabel.Create(Self);
  LblMes.Parent := RectItem;
  LblMes.Position.X := 15;
  LblMes.Position.Y := 10;
  LblMes.Width := 280;
  LblMes.Height := 22;
  LblMes.StyledSettings := [];
  LblMes.TextSettings.Font.Size := 14;
  LblMes.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblMes.TextSettings.FontColor := TAlphaColors.White;
  LblMes.Text := 'Mensalidade ' + Mes + ' - Venc: ' + Vencimento;
  
  // Vencimento (mantém para compatibilidade)
  LblVencimento := TLabel.Create(Self);
  LblVencimento.Parent := RectItem;
  LblVencimento.Position.X := 15;
  LblVencimento.Position.Y := 35;
  LblVencimento.Width := 200;
  LblVencimento.Height := 18;
  LblVencimento.StyledSettings := [];
  LblVencimento.TextSettings.Font.Size := 11;
  LblVencimento.TextSettings.FontColor := $CCFFFFFF;
  LblVencimento.Text := 'Referência: ' + Mes;
  
  LblValor := TLabel.Create(Self);
  LblValor.Parent := RectItem;
  LblValor.Position.X := 15;
  LblValor.Position.Y := 55;
  LblValor.Width := 150;
  LblValor.Height := 22;
  LblValor.StyledSettings := [];
  LblValor.TextSettings.Font.Size := 16;
  LblValor.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblValor.TextSettings.FontColor := COR_DOURADO;
  LblValor.Text := FormatarMoedaBR(Valor);
  
  // Status
  RectStatus := TRectangle.Create(Self);
  RectStatus.Parent := RectItem;
  RectStatus.Position.X := RectItem.Width - 95;
  RectStatus.Position.Y := 28;
  RectStatus.Width := 80;
  RectStatus.Height := 28;
  RectStatus.Fill.Color := CorStatus;
  RectStatus.Stroke.Kind := TBrushKind.None;
  RectStatus.XRadius := 8;
  RectStatus.YRadius := 8;
  
  LblStatus := TLabel.Create(Self);
  LblStatus.Parent := RectStatus;
  LblStatus.Align := TAlignLayout.Client;
  LblStatus.StyledSettings := [];
  LblStatus.TextSettings.Font.Size := 11;
  LblStatus.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblStatus.TextSettings.FontColor := TAlphaColors.White;
  LblStatus.TextSettings.HorzAlign := TTextAlign.Center;
  LblStatus.Text := Status;
end;

// ==================== CONTEÚDOS FICTÍCIOS ====================

procedure TFormResponsavel.CarregarBoletim;
var
  LblHeader: TLabel;
begin
  // Header do boletim
  LblHeader := TLabel.Create(Self);
  LblHeader.Parent := VertScrollBox.Content;
  LblHeader.Position.X := 0;
  LblHeader.Position.Y := 0;
  LblHeader.Width := VertScrollBox.Width - 10;
  LblHeader.Height := 50;
  LblHeader.StyledSettings := [];
  LblHeader.TextSettings.Font.Size := 13;
  LblHeader.TextSettings.FontColor := $CCFFFFFF;
  LblHeader.Text := 'Aluno: ' + NomeAluno + #13#10 + 'Turma: 9º Ano A | Ano Letivo: 2024';
  
  // Matérias com notas fictícias
  CriarItemBoletim(VertScrollBox.Content, 'Matemática', 8.5, 7.5, 9.0, 8.0, 8.3, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'Português', 9.0, 8.5, 8.0, 9.0, 8.6, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'História', 7.0, 6.5, 7.5, 8.0, 7.3, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'Geografia', 8.0, 7.0, 7.5, 8.5, 7.8, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'Ciências', 6.0, 5.5, 6.5, 7.0, 6.3, 'Recuperação');
  CriarItemBoletim(VertScrollBox.Content, 'Física', 7.5, 8.0, 7.0, 8.5, 7.8, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'Química', 5.0, 5.5, 6.0, 6.5, 5.8, 'Recuperação');
  CriarItemBoletim(VertScrollBox.Content, 'Inglês', 9.5, 9.0, 9.5, 10.0, 9.5, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'Ed. Física', 10.0, 10.0, 9.5, 10.0, 9.9, 'Aprovado');
  CriarItemBoletim(VertScrollBox.Content, 'Artes', 8.5, 9.0, 8.5, 9.0, 8.8, 'Aprovado');
end;

procedure TFormResponsavel.CarregarFaturas;
begin
  // Faturas ordenadas da mais nova para mais antiga
  CriarItemFatura(VertScrollBox.Content, 'Janeiro/2025', 1350.00, '10/01/2025', 'Aberto', COR_LARANJA);
  CriarItemFatura(VertScrollBox.Content, 'Dezembro/2024', 1250.00, '10/12/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Novembro/2024', 1250.00, '10/11/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Outubro/2024', 1250.00, '10/10/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Setembro/2024', 1250.00, '10/09/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Agosto/2024', 1250.00, '10/08/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Julho/2024', 1250.00, '10/07/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Junho/2024', 1250.00, '10/06/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Maio/2024', 1250.00, '10/05/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Abril/2024', 1250.00, '10/04/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Março/2024', 1250.00, '10/03/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Fevereiro/2024', 1250.00, '10/02/2024', 'Pago', COR_VERDE);
  CriarItemFatura(VertScrollBox.Content, 'Janeiro/2024', 1250.00, '10/01/2024', 'Pago', COR_VERDE);
end;

procedure TFormResponsavel.CarregarNotificacoes;
begin
  // Notificações ordenadas da mais recente para mais antiga
  CriarItemLista(VertScrollBox.Content,
    'Pagamento via PIX Disponível',
    'Agora você pode pagar suas mensalidades via PIX',
    'Publicado em: 28/12/2024 às 10:30 | Chave: cnpj@colegiosge.com.br',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content,
    'Promoção Rematrícula 2025',
    'Garanta 15% de desconto na primeira parcela!',
    'Publicado em: 20/12/2024 às 09:00 | Válido até 15/01/2025',
    COR_VERDE);
    
  CriarItemLista(VertScrollBox.Content,
    'Período de Rematrícula Aberto',
    'Renove a matrícula para o ano letivo 2025',
    'Publicado em: 15/12/2024 às 08:00 | Prazo: 01/01 a 31/01/2025',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content,
    'Reunião de Pais - 1º Bimestre',
    'Compareça à reunião para acompanhar o desempenho',
    'Publicado em: 10/12/2024 às 14:00 | Data: 15/02/2025 às 19h',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content,
    'Festa Junina 2025',
    'Participe da nossa tradicional festa junina',
    'Publicado em: 01/12/2024 às 11:30 | Data: 21/06/2025',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content,
    'Calendário de Provas - 1º Bim',
    'Confira as datas das avaliações do 1º bimestre',
    'Publicado em: 25/11/2024 às 16:00 | Período: 10/03 a 21/03/2025',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content,
    'Novo Uniforme Escolar',
    'Conheça o novo modelo de uniforme para 2025',
    'Publicado em: 15/11/2024 às 09:30 | Disponível a partir de 01/02',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content,
    'Aulas de Reforço Gratuitas',
    'Matemática e Português - Vagas limitadas',
    'Publicado em: 01/11/2024 às 08:00 | Terças e Quintas às 14h',
    COR_VERDE);
end;

end.
