unit UnitEducInfantil;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects, FMX.Layouts,
  System.DateUtils;

type
  TFormEducInfantil = class(TForm)
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
    RectConteudo: TRectangle;
    LblConteudoTitulo: TLabel;
    LblConteudoSubtitulo: TLabel;
    LblNomeAluno: TLabel;
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
    RectDetalhe: TRectangle;
    RectDetalheHeader: TRectangle;
    LblDetalheTitulo: TLabel;
    RectBtnFecharDetalhe: TRectangle;
    LblBtnFecharDetalhe: TLabel;
    ScrollBoxDetalhe: TVertScrollBox;
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
    RectMenuFooter: TRectangle;
    RectBtnSair: TRectangle;
    ImgBtnSair: TImage;
    LblBtnSair: TLabel;
    LblVersao: TLabel;
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
    FDecorCriado: Boolean;
    procedure CriarItensDecorativos;
    procedure AnimarDecorItems;
    procedure AbrirMenu;
    procedure FecharMenu;
    procedure MostrarDetalhe(Titulo: string; Tipo: Integer);
    procedure FecharDetalhe;
    procedure LimparScrollBox;
    procedure CarregarCardapio;
    procedure CarregarOcorrencias;
    procedure CriarItemCardapio(PosY: Single; Data: TDate; Refeicao, Bebida, Lanche: string);
    procedure CriarItemOcorrencia(PosY: Single; DataHora: TDateTime; Descricao: string; Tipo: Integer);
  public
    NomeUsuario: string;
    NomeAluno: string;
  end;

var
  FormEducInfantil: TFormEducInfantil;

const
  COR_VERMELHO = $FFD33327;
  COR_VERMELHO_ESCURO = $FF7D2728;
  COR_DOURADO = $FFFDCD62;
  COR_DOURADO_CLARO = $FFFFEABB;
  COR_VERDE = $FF4CAF50;
  COR_AZUL = $FF2196F3;
  COR_LARANJA = $FFFF9800;

implementation

{$R *.fmx}

uses UnitLogin;

procedure TFormEducInfantil.FormCreate(Sender: TObject);
begin
  FMenuAberto := False;
  FLogoScale := 1.0;
  FLogoGrow := True;
  FDecorCriado := False;
  NomeAluno := 'Maria Luiza Santos';
  
  RectMenuLateral.Position.X := -280;
  RectMenuOverlay.Visible := False;
  RectMenuOverlay.Opacity := 0;
  
  RectDetalhe.Visible := False;
end;

procedure TFormEducInfantil.FormShow(Sender: TObject);
begin
  if NomeUsuario <> '' then
    LblNomeUsuario.Text := NomeUsuario
  else
    LblNomeUsuario.Text := 'Responsável';
    
  LblTipoUsuario.Text := 'Educação Infantil';
  LblSubtituloHeader.Text := 'Olá, ' + LblNomeUsuario.Text + '!';
  LblNomeAluno.Text := 'Aluno(a): ' + NomeAluno;
  
  // Cria itens decorativos apenas uma vez
  if not FDecorCriado then
  begin
    CriarItensDecorativos;
    FDecorCriado := True;
  end;
  
  // Garante que cards estao visiveis e detalhe escondido
  RectConteudo.Visible := True;
  RectDetalhe.Visible := False;
  
  // Animacao de entrada
  RectConteudo.Opacity := 0;
  TAnimator.AnimateFloat(RectConteudo, 'Opacity', 1, 0.4);
  
  TimerDecor.Enabled := True;
  TimerLogoMenu.Enabled := True;
end;

procedure TFormEducInfantil.CriarItensDecorativos;
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

procedure TFormEducInfantil.TimerDecorTimer(Sender: TObject);
begin
  if FDecorCriado then
    AnimarDecorItems;
end;

procedure TFormEducInfantil.AnimarDecorItems;
var
  I: Integer;
  MaxY: Single;
begin
  MaxY := LayoutDecor.Height + 50;
  
  for I := 0 to 14 do
  begin
    if FDecorItems[I] <> nil then
    begin
      if FDecorItems[I].Position.Y > MaxY then
        FDecorItems[I].Position.Y := -50 - Random(100)
      else
        FDecorItems[I].Position.Y := FDecorItems[I].Position.Y + FDecorSpeeds[I];
      
      FDecorItems[I].RotationAngle := FDecorItems[I].RotationAngle + FDecorRotations[I];
    end;
  end;
end;

procedure TFormEducInfantil.TimerLogoMenuTimer(Sender: TObject);
begin
  if FLogoGrow then
  begin
    FLogoScale := FLogoScale + 0.008;
    if FLogoScale >= 1.08 then FLogoGrow := False;
  end
  else
  begin
    FLogoScale := FLogoScale - 0.008;
    if FLogoScale <= 0.95 then FLogoGrow := True;
  end;
  
  CircleLogoMenu.Scale.X := FLogoScale;
  CircleLogoMenu.Scale.Y := FLogoScale;
end;

procedure TFormEducInfantil.AbrirMenu;
begin
  FMenuAberto := True;
  RectMenuOverlay.Visible := True;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 1, 0.25);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', 0, 0.25);
end;

procedure TFormEducInfantil.FecharMenu;
begin
  FMenuAberto := False;
  TAnimator.AnimateFloat(RectMenuOverlay, 'Opacity', 0, 0.25);
  TAnimator.AnimateFloat(RectMenuLateral, 'Position.X', -280, 0.25);
end;

procedure TFormEducInfantil.RectBtnMenuClick(Sender: TObject);
begin
  if FMenuAberto then
    FecharMenu
  else
    AbrirMenu;
end;

procedure TFormEducInfantil.RectMenuOverlayClick(Sender: TObject);
begin
  FecharMenu;
end;

procedure TFormEducInfantil.RectBtnVoltarClick(Sender: TObject);
begin
  TimerDecor.Enabled := False;
  TimerLogoMenu.Enabled := False;
  FormLogin.Show;
  Self.Hide;
end;

procedure TFormEducInfantil.RectBtnSairClick(Sender: TObject);
begin
  FecharMenu;
  TimerDecor.Enabled := False;
  TimerLogoMenu.Enabled := False;
  FormLogin.Show;
  Self.Hide;
end;

procedure TFormEducInfantil.MenuItemMouseEnter(Sender: TObject);
begin
  if Sender is TRectangle then
    TAnimator.AnimateFloat(TRectangle(Sender), 'Opacity', 0.8, 0.15);
end;

procedure TFormEducInfantil.MenuItemMouseLeave(Sender: TObject);
begin
  if Sender is TRectangle then
    TAnimator.AnimateFloat(TRectangle(Sender), 'Opacity', 1, 0.15);
end;

procedure TFormEducInfantil.MenuItemClick(Sender: TObject);
var
  MenuItem: string;
begin
  if not (Sender is TRectangle) then Exit;
  
  MenuItem := TRectangle(Sender).Name;
  FecharMenu;
  
  if MenuItem = 'RectMenuItem1' then
    MostrarDetalhe('Cardapio Semanal', 1)
  else if MenuItem = 'RectMenuItem2' then
    MostrarDetalhe('Ocorrencias', 2);
end;

procedure TFormEducInfantil.CardMouseEnter(Sender: TObject);
begin
  if Sender is TRectangle then
  begin
    TAnimator.AnimateFloat(TRectangle(Sender), 'Scale.X', 1.03, 0.15);
    TAnimator.AnimateFloat(TRectangle(Sender), 'Scale.Y', 1.03, 0.15);
  end;
end;

procedure TFormEducInfantil.CardMouseLeave(Sender: TObject);
begin
  if Sender is TRectangle then
  begin
    TAnimator.AnimateFloat(TRectangle(Sender), 'Scale.X', 1, 0.15);
    TAnimator.AnimateFloat(TRectangle(Sender), 'Scale.Y', 1, 0.15);
  end;
end;

procedure TFormEducInfantil.CardClick(Sender: TObject);
var
  CardName: string;
begin
  if not (Sender is TRectangle) then Exit;
  
  CardName := TRectangle(Sender).Name;
  
  if CardName = 'RectCard1' then
    MostrarDetalhe('Cardapio Semanal', 1)
  else if CardName = 'RectCard2' then
    MostrarDetalhe('Ocorrencias', 2);
end;

procedure TFormEducInfantil.MostrarDetalhe(Titulo: string; Tipo: Integer);
begin
  LblDetalheTitulo.Text := Titulo;
  LimparScrollBox;
  
  case Tipo of
    1: CarregarCardapio;
    2: CarregarOcorrencias;
  end;
  
  // IMPORTANTE: Esconde os cards e mostra o detalhe
  RectConteudo.Visible := False;
  RectDetalhe.Visible := True;
  RectDetalhe.Opacity := 0;
  TAnimator.AnimateFloat(RectDetalhe, 'Opacity', 1, 0.3);
end;

procedure TFormEducInfantil.FecharDetalhe;
begin
  // IMPORTANTE: Esconde detalhe e mostra os cards
  RectDetalhe.Visible := False;
  RectConteudo.Visible := True;
  RectConteudo.Opacity := 0;
  TAnimator.AnimateFloat(RectConteudo, 'Opacity', 1, 0.3);
end;

procedure TFormEducInfantil.RectBtnFecharDetalheClick(Sender: TObject);
begin
  FecharDetalhe;
end;

procedure TFormEducInfantil.LimparScrollBox;
var
  I: Integer;
begin
  for I := ScrollBoxDetalhe.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxDetalhe.Content.Children[I].Free;
end;

// ==================== CARDAPIO ====================

procedure TFormEducInfantil.CriarItemCardapio(PosY: Single; Data: TDate; Refeicao, Bebida, Lanche: string);
var
  RectItem: TRectangle;
  LblData, LblDia, LblRefeicao, LblBebida, LblLanche: TLabel;
  LinhaDiv: TLine;
  DiaSemana: string;
begin
  case DayOfWeek(Data) of
    1: DiaSemana := 'Domingo';
    2: DiaSemana := 'Segunda-feira';
    3: DiaSemana := 'Terça-feira';
    4: DiaSemana := 'Quarta-feira';
    5: DiaSemana := 'Quinta-feira';
    6: DiaSemana := 'Sexta-feira';
    7: DiaSemana := 'Sábado';
  end;
  
  RectItem := TRectangle.Create(Self);
  RectItem.Parent := ScrollBoxDetalhe;
  RectItem.Position.X := 5;
  RectItem.Position.Y := PosY;
  RectItem.Width := 390;
  RectItem.Height := 130;
  RectItem.Fill.Color := $15FFFFFF;
  RectItem.Stroke.Color := $4DFDCD62;
  RectItem.Stroke.Thickness := 1;
  RectItem.XRadius := 12;
  RectItem.YRadius := 12;
  
  LblData := TLabel.Create(RectItem);
  LblData.Parent := RectItem;
  LblData.Position.X := 15;
  LblData.Position.Y := 10;
  LblData.Width := 100;
  LblData.Height := 22;
  LblData.StyledSettings := [];
  LblData.TextSettings.Font.Size := 14;
  LblData.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblData.TextSettings.FontColor := COR_DOURADO;
  LblData.Text := FormatDateTime('dd/mm/yyyy', Data);
  
  LblDia := TLabel.Create(RectItem);
  LblDia.Parent := RectItem;
  LblDia.Position.X := 120;
  LblDia.Position.Y := 10;
  LblDia.Width := 150;
  LblDia.Height := 22;
  LblDia.StyledSettings := [];
  LblDia.TextSettings.Font.Size := 13;
  LblDia.TextSettings.FontColor := TAlphaColors.White;
  LblDia.Text := DiaSemana;
  
  LinhaDiv := TLine.Create(RectItem);
  LinhaDiv.Parent := RectItem;
  LinhaDiv.Position.X := 15;
  LinhaDiv.Position.Y := 36;
  LinhaDiv.Width := 360;
  LinhaDiv.Height := 1;
  LinhaDiv.Stroke.Color := $30FFFFFF;
  
  LblRefeicao := TLabel.Create(RectItem);
  LblRefeicao.Parent := RectItem;
  LblRefeicao.Position.X := 15;
  LblRefeicao.Position.Y := 45;
  LblRefeicao.Width := 360;
  LblRefeicao.Height := 22;
  LblRefeicao.StyledSettings := [];
  LblRefeicao.TextSettings.Font.Size := 12;
  LblRefeicao.TextSettings.FontColor := TAlphaColors.White;
  LblRefeicao.Text := 'Refeicao: ' + Refeicao;
  
  LblBebida := TLabel.Create(RectItem);
  LblBebida.Parent := RectItem;
  LblBebida.Position.X := 15;
  LblBebida.Position.Y := 70;
  LblBebida.Width := 360;
  LblBebida.Height := 22;
  LblBebida.StyledSettings := [];
  LblBebida.TextSettings.Font.Size := 12;
  LblBebida.TextSettings.FontColor := $CCFFFFFF;
  LblBebida.Text := 'Bebida: ' + Bebida;
  
  LblLanche := TLabel.Create(RectItem);
  LblLanche.Parent := RectItem;
  LblLanche.Position.X := 15;
  LblLanche.Position.Y := 95;
  LblLanche.Width := 360;
  LblLanche.Height := 22;
  LblLanche.StyledSettings := [];
  LblLanche.TextSettings.Font.Size := 12;
  LblLanche.TextSettings.FontColor := $CCFFFFFF;
  LblLanche.Text := 'Lanche: ' + Lanche;
end;

procedure TFormEducInfantil.CarregarCardapio;
var
  DataCardapio: TDate;
  PosY: Single;
  DiasAdicionados: Integer;
  
  function ProximoDiaUtil(D: TDate): TDate;
  begin
    Result := D;
    // Se for sábado (7), pula para segunda (+2)
    // Se for domingo (1), pula para segunda (+1)
    while (DayOfWeek(Result) = 1) or (DayOfWeek(Result) = 7) do
      Result := Result + 1;
  end;
  
begin
  DataCardapio := ProximoDiaUtil(Date);
  PosY := 5;
  DiasAdicionados := 0;
  
  // Segunda-feira
  CriarItemCardapio(PosY, DataCardapio,
    'Arroz, feijão, frango grelhado e salada',
    'Suco de laranja natural',
    'Biscoito integral com banana');
  PosY := PosY + 140;
  DataCardapio := ProximoDiaUtil(DataCardapio + 1);
  Inc(DiasAdicionados);
  
  // Terça-feira
  CriarItemCardapio(PosY, DataCardapio,
    'Macarrão ao molho de tomate com carne moída',
    'Suco de uva',
    'Fruta picada (maçã e melão)');
  PosY := PosY + 140;
  DataCardapio := ProximoDiaUtil(DataCardapio + 1);
  Inc(DiasAdicionados);
  
  // Quarta-feira
  CriarItemCardapio(PosY, DataCardapio,
    'Arroz, feijão, peixe assado e legumes',
    'Água de coco',
    'Iogurte natural com mel');
  PosY := PosY + 140;
  DataCardapio := ProximoDiaUtil(DataCardapio + 1);
  Inc(DiasAdicionados);
  
  // Quinta-feira
  CriarItemCardapio(PosY, DataCardapio,
    'Sopa de legumes com frango desfiado',
    'Suco de manga',
    'Bolo de cenoura');
  PosY := PosY + 140;
  DataCardapio := ProximoDiaUtil(DataCardapio + 1);
  Inc(DiasAdicionados);
  
  // Sexta-feira
  CriarItemCardapio(PosY, DataCardapio,
    'Arroz, feijão, carne assada e purê de batata',
    'Suco de acerola',
    'Gelatina colorida');
end;

// ==================== OCORRENCIAS ====================

procedure TFormEducInfantil.CriarItemOcorrencia(PosY: Single; DataHora: TDateTime; Descricao: string; Tipo: Integer);
var
  RectItem: TRectangle;
  LblDataHora, LblDescricao, LblTipo: TLabel;
  Cor: TAlphaColor;
  TipoTexto: string;
begin
  case Tipo of
    1: begin TipoTexto := 'FEBRE/DOENÇA'; Cor := COR_VERMELHO; end;
    2: begin TipoTexto := 'ALIMENTAÇÃO'; Cor := COR_VERDE; end;
    3: begin TipoTexto := 'MACHUCADO'; Cor := COR_LARANJA; end;
    4: begin TipoTexto := 'SONECA'; Cor := COR_AZUL; end;
    5: begin TipoTexto := 'BOM COMPORTAMENTO'; Cor := COR_DOURADO; end;
    6: begin TipoTexto := 'CHOROU'; Cor := $FF9C27B0; end;
  else
    begin TipoTexto := 'GERAL'; Cor := COR_DOURADO; end;
  end;
  
  RectItem := TRectangle.Create(Self);
  RectItem.Parent := ScrollBoxDetalhe;
  RectItem.Position.X := 5;
  RectItem.Position.Y := PosY;
  RectItem.Width := 390;
  RectItem.Height := 100;
  RectItem.Fill.Color := $15FFFFFF;
  RectItem.Stroke.Color := Cor;
  RectItem.Stroke.Thickness := 1.5;
  RectItem.XRadius := 12;
  RectItem.YRadius := 12;
  
  LblTipo := TLabel.Create(RectItem);
  LblTipo.Parent := RectItem;
  LblTipo.Position.X := 15;
  LblTipo.Position.Y := 10;
  LblTipo.Width := 200;
  LblTipo.Height := 20;
  LblTipo.StyledSettings := [];
  LblTipo.TextSettings.Font.Size := 11;
  LblTipo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTipo.TextSettings.FontColor := Cor;
  LblTipo.Text := TipoTexto;
  
  LblDataHora := TLabel.Create(RectItem);
  LblDataHora.Parent := RectItem;
  LblDataHora.Position.X := 15;
  LblDataHora.Position.Y := 32;
  LblDataHora.Width := 360;
  LblDataHora.Height := 20;
  LblDataHora.StyledSettings := [];
  LblDataHora.TextSettings.Font.Size := 12;
  LblDataHora.TextSettings.FontColor := TAlphaColors.White;
  LblDataHora.Text := FormatDateTime('dd/mm/yyyy', DataHora) + ' as ' + FormatDateTime('hh:nn', DataHora);
  
  LblDescricao := TLabel.Create(RectItem);
  LblDescricao.Parent := RectItem;
  LblDescricao.Position.X := 15;
  LblDescricao.Position.Y := 55;
  LblDescricao.Width := 360;
  LblDescricao.Height := 40;
  LblDescricao.StyledSettings := [];
  LblDescricao.TextSettings.Font.Size := 11;
  LblDescricao.TextSettings.FontColor := $CCFFFFFF;
  LblDescricao.TextSettings.WordWrap := True;
  LblDescricao.Text := Descricao;
end;

procedure TFormEducInfantil.CarregarOcorrencias;
var
  Hoje: TDate;
  PosY: Single;
begin
  Hoje := Date;
  PosY := 5;
  
  // Ocorrências ordenadas da mais recente para mais antiga
  // Horário de expediente: 07:00 às 17:30
  
  CriarItemOcorrencia(PosY, Hoje + EncodeTime(16, 45, 0, 0),
    'Maria Luiza brincou bem com os coleguinhas e participou de todas as atividades com alegria!', 5);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje + EncodeTime(12, 30, 0, 0),
    'Almoçou tudo! Comeu arroz, feijão, frango e salada. Repetiu o suco de laranja.', 2);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje - 1 + EncodeTime(14, 15, 0, 0),
    'Dormiu bem durante a soneca da tarde, aproximadamente 1h30.', 4);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje - 1 + EncodeTime(10, 20, 0, 0),
    'Pequeno arranhão no joelho ao brincar no parquinho. Foi feito curativo e ela ficou bem.', 3);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje - 2 + EncodeTime(7, 30, 0, 0),
    'Chorou um pouquinho na hora da entrada, mas logo se acalmou ao ver os amigos.', 6);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje - 2 + EncodeTime(15, 45, 0, 0),
    'Apresentou febre baixa (37.8°C) no período da tarde. Responsável foi notificado.', 1);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje - 3 + EncodeTime(12, 15, 0, 0),
    'Não quis comer a sopa no almoço, comeu apenas o arroz e a carne.', 2);
  PosY := PosY + 110;
    
  CriarItemOcorrencia(PosY, Hoje - 4 + EncodeTime(9, 30, 0, 0),
    'Participou da aula de música com muito entusiasmo! Cantou todas as músicas.', 5);
end;

end.
