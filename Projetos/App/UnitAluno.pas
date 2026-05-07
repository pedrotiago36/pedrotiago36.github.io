unit UnitAluno;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects, FMX.Layouts,
  FMX.Filter.Effects, System.IOUtils, FMX.ListBox;

type
  TFormAluno = class(TForm)
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
    RectCard4: TRectangle;
    ShadowCard4: TShadowEffect;
    ImgCard4: TImage;
    LblCard4Titulo: TLabel;
    LblCard4Desc: TLabel;
    RectCard5: TRectangle;
    ShadowCard5: TShadowEffect;
    LblCard5Icone: TLabel;
    LblCard5Titulo: TLabel;
    LblCard5Desc: TLabel;
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
    procedure FormResize(Sender: TObject);
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
    procedure LimparScrollBox;
    // Conteúdos fictícios
    procedure CarregarTDs;
    procedure CarregarNotasProvas;
    procedure CarregarNotasTrabalhos;
    procedure CarregarConteudos;
  public
    NomeUsuario: string;
  end;

var
  FormAluno: TFormAluno;

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

uses UnitLogin, UnitChatAluno;

procedure TFormAluno.FormCreate(Sender: TObject);
begin
  FMenuAberto := False;
  FLogoScale := 1.0;
  FLogoGrow := True;
  
  // Menu começa fechado
  RectMenuLateral.Position.X := -280;
  RectMenuOverlay.Visible := False;
  RectMenuOverlay.Opacity := 0;
  
  // Detalhe começa escondido
  RectDetalhe.Visible := False;
  RectDetalhe.Opacity := 0;
end;

procedure TFormAluno.FormShow(Sender: TObject);
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
    LblNomeUsuario.Text := 'Aluno';
    
  LblTipoUsuario.Text := 'Área do Aluno';
  LblSubtituloHeader.Text := 'Olá, ' + LblNomeUsuario.Text + '!';
  
  // Mostra cards
  MostrarCards;

  FormResize(nil);

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

procedure TFormAluno.CriarItensDecorativos;
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
  
  FDecorSpeeds[0] := 0.30; FDecorSpeeds[1] := 0.45; FDecorSpeeds[2] := 0.35;
  FDecorSpeeds[3] := 0.50; FDecorSpeeds[4] := 0.32; FDecorSpeeds[5] := 0.42;
  FDecorSpeeds[6] := 0.35; FDecorSpeeds[7] := 0.55; FDecorSpeeds[8] := 0.40;
  FDecorSpeeds[9] := 0.48; FDecorSpeeds[10] := 0.28; FDecorSpeeds[11] := 0.52;
  FDecorSpeeds[12] := 0.35; FDecorSpeeds[13] := 0.45; FDecorSpeeds[14] := 0.38;
  
  FDecorRotations[0] := 0.38; FDecorRotations[1] := -0.30; FDecorRotations[2] := 0.50;
  FDecorRotations[3] := -0.45; FDecorRotations[4] := 0.32; FDecorRotations[5] := -0.55;
  FDecorRotations[6] := 0.42; FDecorRotations[7] := -0.35; FDecorRotations[8] := 0.52;
  FDecorRotations[9] := -0.40; FDecorRotations[10] := 0.48; FDecorRotations[11] := -0.28;
  FDecorRotations[12] := 0.57; FDecorRotations[13] := -0.38; FDecorRotations[14] := 0.45;

  var sBase: string := TPath.Combine(ExtractFilePath(ParamStr(0)), 'img');
  {$IFDEF ANDROID}
  sBase := TPath.GetDocumentsPath;
  {$ENDIF}
  var sArq: string := TPath.Combine(sBase, 'books.png');
  if not FileExists(sArq) then sArq := TPath.Combine(sBase, 'book.png');
  if FileExists(sArq) then
  begin
    ImgModeloBook.Bitmap.LoadFromFile(sArq);
    ImgModeloPencil.Bitmap.Assign(ImgModeloBook.Bitmap);
    ImgModeloEraser.Bitmap.Assign(ImgModeloBook.Bitmap);
    ImgModeloNotebook.Bitmap.Assign(ImgModeloBook.Bitmap);
    ImgModeloRuler.Bitmap.Assign(ImgModeloBook.Bitmap);
  end;
  sArq := TPath.Combine(sBase, 'pencil.png');
  if FileExists(sArq) then ImgModeloPencil.Bitmap.LoadFromFile(sArq);
  sArq := TPath.Combine(sBase, 'eraser.png');
  if FileExists(sArq) then ImgModeloEraser.Bitmap.LoadFromFile(sArq);
  sArq := TPath.Combine(sBase, 'notebook.png');
  if FileExists(sArq) then ImgModeloNotebook.Bitmap.LoadFromFile(sArq);
  sArq := TPath.Combine(sBase, 'ruler.png');
  if FileExists(sArq) then ImgModeloRuler.Bitmap.LoadFromFile(sArq);

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

procedure TFormAluno.TimerDecorTimer(Sender: TObject);
begin
  AnimarDecorItems;
end;

procedure TFormAluno.AnimarDecorItems;
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

procedure TFormAluno.TimerLogoMenuTimer(Sender: TObject);
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

procedure TFormAluno.RectBtnMenuClick(Sender: TObject);
begin
  if FMenuAberto then
    FecharMenu
  else
    AbrirMenu;
end;

procedure TFormAluno.AbrirMenu;
begin
  FMenuAberto := True;
  RectMenuOverlay.Visible := True;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0.6, 0.3);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', 0, 0.3, TAnimationType.Out, TInterpolationType.Quadratic);
  LblBtnMenu.Text := '✕';
end;

procedure TFormAluno.FecharMenu;
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

procedure TFormAluno.RectMenuOverlayClick(Sender: TObject);
begin
  FecharMenu;
end;

procedure TFormAluno.RectBtnVoltarClick(Sender: TObject);
begin
  TimerDecor.Enabled := False;
  TimerLogoMenu.Enabled := False;
  FormLogin.Show;
  Self.Hide;
end;

procedure TFormAluno.RectBtnSairClick(Sender: TObject);
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

procedure TFormAluno.MenuItemMouseEnter(Sender: TObject);
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

procedure TFormAluno.MenuItemMouseLeave(Sender: TObject);
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

procedure TFormAluno.MenuItemClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := 0;
  
  if Sender = RectMenuItem1 then Index := 1
  else if Sender = RectMenuItem2 then Index := 2
  else if Sender = RectMenuItem3 then Index := 3
  else if Sender = RectMenuItem4 then Index := 4;
  
  if Index > 0 then
  begin
    FecharMenu;
    case Index of
      1: MostrarDetalhe('TDs para Prova', 1);
      2: MostrarDetalhe('Notas de Provas', 2);
      3: MostrarDetalhe('Notas de Trabalhos', 3);
      4: MostrarDetalhe('Conteúdos', 4);
    end;
  end;
end;

procedure TFormAluno.CardMouseEnter(Sender: TObject);
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

procedure TFormAluno.CardMouseLeave(Sender: TObject);
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

procedure TFormAluno.CardClick(Sender: TObject);
begin
  if Sender = RectCard1 then
    MostrarDetalhe('TDs para Prova', 1)
  else if Sender = RectCard2 then
    MostrarDetalhe('Notas de Provas', 2)
  else if Sender = RectCard3 then
    MostrarDetalhe('Notas de Trabalhos', 3)
  else if Sender = RectCard4 then
    MostrarDetalhe('Conteúdos', 4)
  else if Sender = RectCard5 then
  begin
    FormChatAluno.Matricula := NomeUsuario;
    FormChatAluno.NomeAluno := LblNomeUsuario.Text;
    FormChatAluno.Show;
  end;
end;

procedure TFormAluno.MostrarCards;
begin
  RectConteudo.Visible := True;
  RectDetalhe.Visible := False;
  LblConteudoTitulo.Text := 'Área do Aluno';
  LblConteudoSubtitulo.Text := 'Selecione uma opção abaixo';
end;

procedure TFormAluno.MostrarDetalhe(Titulo: string; Tipo: Integer);
begin
  LblDetalheTitulo.Text := Titulo;
  LimparScrollBox;
  
  case Tipo of
    1: CarregarTDs;
    2: CarregarNotasProvas;
    3: CarregarNotasTrabalhos;
    4: CarregarConteudos;
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

procedure TFormAluno.RectBtnFecharDetalheClick(Sender: TObject);
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

procedure TFormAluno.LimparScrollBox;
var
  I: Integer;
begin
  for I := VertScrollBox.Content.ChildrenCount - 1 downto 0 do
    VertScrollBox.Content.Children[I].Free;
end;

procedure TFormAluno.CriarItemLista(Parent: TFmxObject; Titulo, Subtitulo, Info: string; Cor: TAlphaColor);
var
  RectItem: TRectangle;
  LblTitulo, LblSubtitulo, LblInfo: TLabel;
  RectBadge: TRectangle;
  PosY: Single;
begin
  // Calcula posição Y
  PosY := Parent.ChildrenCount * 85;
  
  RectItem := TRectangle.Create(Self);
  RectItem.Parent := Parent;
  RectItem.Position.X := 0;
  RectItem.Position.Y := PosY;
  RectItem.Width := VertScrollBox.Width - 10;
  RectItem.Height := 75;
  RectItem.Fill.Color := $18FFFFFF;
  RectItem.Stroke.Color := COR_BORDA;
  RectItem.Stroke.Thickness := 1;
  RectItem.XRadius := 12;
  RectItem.YRadius := 12;
  RectItem.HitTest := False;
  
  // Badge colorido
  RectBadge := TRectangle.Create(Self);
  RectBadge.Parent := RectItem;
  RectBadge.Position.X := 10;
  RectBadge.Position.Y := 10;
  RectBadge.Width := 5;
  RectBadge.Height := 55;
  RectBadge.Fill.Color := Cor;
  RectBadge.Stroke.Kind := TBrushKind.None;
  RectBadge.XRadius := 3;
  RectBadge.YRadius := 3;
  
  // Título
  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RectItem;
  LblTitulo.Position.X := 25;
  LblTitulo.Position.Y := 10;
  LblTitulo.Width := RectItem.Width - 100;
  LblTitulo.Height := 22;
  LblTitulo.StyledSettings := [];
  LblTitulo.TextSettings.Font.Size := 14;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor := TAlphaColors.White;
  LblTitulo.Text := Titulo;
  
  // Subtítulo
  LblSubtitulo := TLabel.Create(Self);
  LblSubtitulo.Parent := RectItem;
  LblSubtitulo.Position.X := 25;
  LblSubtitulo.Position.Y := 32;
  LblSubtitulo.Width := RectItem.Width - 100;
  LblSubtitulo.Height := 18;
  LblSubtitulo.StyledSettings := [];
  LblSubtitulo.TextSettings.Font.Size := 11;
  LblSubtitulo.TextSettings.FontColor := $CCFFFFFF;
  LblSubtitulo.Text := Subtitulo;
  
  // Info (nota ou status)
  LblInfo := TLabel.Create(Self);
  LblInfo.Parent := RectItem;
  LblInfo.Position.X := 25;
  LblInfo.Position.Y := 52;
  LblInfo.Width := RectItem.Width - 40;
  LblInfo.Height := 18;
  LblInfo.StyledSettings := [];
  LblInfo.TextSettings.Font.Size := 12;
  LblInfo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblInfo.TextSettings.FontColor := COR_DOURADO;
  LblInfo.Text := Info;
end;

// ==================== CONTEÚDOS FICTÍCIOS ====================

procedure TFormAluno.CarregarTDs;
begin
  CriarItemLista(VertScrollBox.Content, 
    'TD 01 - Matemática', 
    'Equações do 2º Grau e Funções',
    '15 questões | Prazo: 10/01/2025',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    'TD 02 - Português', 
    'Análise Sintática e Morfológica',
    '20 questões | Prazo: 12/01/2025',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'TD 03 - História', 
    'Brasil República e Era Vargas',
    '18 questões | Prazo: 15/01/2025',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    'TD 04 - Física', 
    'Cinemática e Dinâmica',
    '12 questões | Prazo: 18/01/2025',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'TD 05 - Química', 
    'Ligações Químicas e Reações',
    '16 questões | Prazo: 20/01/2025',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    'TD 06 - Biologia', 
    'Citologia e Genética Básica',
    '14 questões | Prazo: 22/01/2025',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'TD 07 - Geografia', 
    'Geopolítica e Globalização',
    '10 questões | Prazo: 25/01/2025',
    COR_VERMELHO);
end;

procedure TFormAluno.CarregarNotasProvas;
begin
  CriarItemLista(VertScrollBox.Content, 
    'Prova Matemática - 1º Bimestre', 
    'Realizada em 15/03/2024',
    'Nota: 8.5 | Média da turma: 7.2',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Prova Português - 1º Bimestre', 
    'Realizada em 18/03/2024',
    'Nota: 9.0 | Média da turma: 7.8',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Prova História - 1º Bimestre', 
    'Realizada em 20/03/2024',
    'Nota: 7.5 | Média da turma: 6.9',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Prova Física - 1º Bimestre', 
    'Realizada em 22/03/2024',
    'Nota: 8.0 | Média da turma: 6.5',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Prova Química - 1º Bimestre', 
    'Realizada em 25/03/2024',
    'Nota: 6.5 | Média da turma: 6.0',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Prova Biologia - 1º Bimestre', 
    'Realizada em 27/03/2024',
    'Nota: 9.5 | Média da turma: 7.5',
    COR_DOURADO);
end;

procedure TFormAluno.CarregarNotasTrabalhos;
begin
  CriarItemLista(VertScrollBox.Content, 
    'Trabalho em Grupo - Matemática', 
    'Aplicações de Funções no Cotidiano',
    'Nota: 9.0 | Entregue em 10/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Redação - Português', 
    'Tema: Tecnologia e Sociedade',
    'Nota: 8.5 | Entregue em 12/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Seminário - História', 
    'Revolução Industrial',
    'Nota: 8.0 | Apresentado em 14/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Relatório - Física', 
    'Experimento: Queda Livre',
    'Nota: 7.5 | Entregue em 16/03/2024',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Projeto - Química', 
    'Indicadores de pH Naturais',
    'Nota: 10.0 | Entregue em 18/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    'Pesquisa - Biologia', 
    'Biodiversidade Brasileira',
    'PENDENTE | Prazo: 30/01/2025',
    COR_VERMELHO);
end;

procedure TFormAluno.CarregarConteudos;
begin
  CriarItemLista(VertScrollBox.Content, 
    '[OK] Matemática - Funções', 
    'Função Afim, Quadrática e Exponencial',
    'Concluído em 05/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    '[OK] Português - Morfologia', 
    'Classes Gramaticais e Formação de Palavras',
    'Concluído em 08/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    '[OK] História - Brasil Colônia', 
    'Descobrimento até Independência',
    'Concluído em 12/03/2024',
    COR_DOURADO);
    
  CriarItemLista(VertScrollBox.Content, 
    '[EM CURSO] Física - Termodinâmica', 
    'Leis da Termodinâmica e Aplicações',
    'Em andamento | Previsão: 15/01/2025',
    COR_VERMELHO);
    
  CriarItemLista(VertScrollBox.Content, 
    '[PRÓXIMO] Química Orgânica', 
    'Hidrocarbonetos e Funções Orgânicas',
    'Próximo | Início: 20/01/2025',
    $FF888888);
    
  CriarItemLista(VertScrollBox.Content, 
    '[PRÓXIMO] Biologia - Ecologia', 
    'Ecossistemas e Cadeias Alimentares',
    'Próximo | Início: 01/02/2025',
    $FF888888);
    
  CriarItemLista(VertScrollBox.Content, 
    '[PRÓXIMO] Geografia - Clima', 
    'Fenômenos Climáticos e Mudanças Globais',
    'Próximo | Início: 10/02/2025',
    $FF888888);
end;

procedure TFormAluno.FormResize(Sender: TObject);
var CardW: Single;
begin
  if RectConteudo.Width < 30 then Exit;
  RectBtnMenu.Position.X := Width - 60;
  LblTituloHeader.Width := Width - 145;
  LblSubtituloHeader.Width := Width - 145;
  RectConteudoHeader.Width := RectConteudo.Width;
  LblConteudoTitulo.Width := RectConteudo.Width;
  LblConteudoSubtitulo.Width := RectConteudo.Width;
  CardW := (RectConteudo.Width - 15) / 2;
  RectCard1.Width := CardW;
  LblCard1Titulo.Width := CardW - 20;
  LblCard1Desc.Width := CardW - 20;
  RectCard2.Position.X := CardW + 15;
  RectCard2.Width := CardW;
  LblCard2Titulo.Width := CardW - 20;
  LblCard2Desc.Width := CardW - 20;
  RectCard3.Width := CardW;
  LblCard3Titulo.Width := CardW - 20;
  LblCard3Desc.Width := CardW - 20;
  RectCard4.Position.X := CardW + 15;
  RectCard4.Width := CardW;
  LblCard4Titulo.Width := CardW - 20;
  LblCard4Desc.Width := CardW - 20;
  RectCard5.Width := RectConteudo.Width;
  LblCard5Titulo.Width := RectConteudo.Width - 90;
  LblCard5Desc.Width := RectConteudo.Width - 90;
  RectDetalhe.Position.X := RectConteudo.Position.X;
  RectDetalhe.Position.Y := RectConteudo.Position.Y;
  RectDetalhe.Width := RectConteudo.Width;
  RectDetalhe.Height := RectConteudo.Height;
  RectDetalheHeader.Width := RectDetalhe.Width;
  RectBtnFecharDetalhe.Position.X := RectDetalhe.Width - 65;
  LblDetalheTitulo.Width := RectDetalhe.Width - 80;
  RectDetalheConteudo.Width := RectDetalhe.Width - 20;
  RectDetalheConteudo.Height := RectDetalhe.Height - 70;
  RectMenuLateral.Height := Height;
end;

end.
