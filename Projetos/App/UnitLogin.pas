unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Ani, FMX.Effects,
  FMX.Edit, FMX.Filter.Effects, System.IOUtils;

type
  TFormLogin = class(TForm)
    RectFundo: TRectangle;
    LayoutCentral: TLayout;
    RectCard: TRectangle;
    ShadowCard: TShadowEffect;
    CircleLogo: TCircle;
    ShadowLogo: TShadowEffect;
    ImgCapelo: TImage;
    LblTitulo: TLabel;
    LblSubtitulo: TLabel;
    RectBadge: TRectangle;
    LblBadge: TLabel;
    LayoutAreas: TLayout;
    RectAreaAluno: TRectangle;
    ImgAreaAluno: TImage;
    LblAreaAluno: TLabel;
    RectAreaProfessor: TRectangle;
    ImgAreaProfessor: TImage;
    LblAreaProfessor: TLabel;
    RectAreaAdmin: TRectangle;
    ImgAreaAdmin: TImage;
    LblAreaAdmin: TLabel;
    RectAreaUniv: TRectangle;
    ImgAreaUniv: TImage;
    LblAreaUniv: TLabel;
    RectAreaInfantil: TRectangle;
    ImgAreaInfantil: TImage;
    LblAreaInfantil: TLabel;
    RectAreaUniversidade: TRectangle;
    ImgAreaUniversidade: TImage;
    LblAreaUniversidade: TLabel;
    RectUsuario: TRectangle;
    ImgIconUser: TImage;
    EdtUsuario: TEdit;
    RectSenha: TRectangle;
    ImgIconSenha: TImage;
    EdtSenha: TEdit;
    BtnEntrar: TRectangle;
    LblBtnEntrar: TLabel;
    ShadowBtn: TShadowEffect;
    LblEsqueceuSenha: TLabel;
    LblFooter: TLabel;
    RectLogoBorder: TRectangle;
    TimerPulse: TTimer;
    TimerDecor: TTimer;
    LayoutDecor: TLayout;
    ImgModeloBook: TImage;
    ImgModeloPencil: TImage;
    ImgModeloEraser: TImage;
    ImgModeloNotebook: TImage;
    ImgModeloRuler: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnEntrarClick(Sender: TObject);
    procedure BtnEntrarMouseEnter(Sender: TObject);
    procedure BtnEntrarMouseLeave(Sender: TObject);
    procedure RectAreaAlunoClick(Sender: TObject);
    procedure RectAreaProfessorClick(Sender: TObject);
    procedure RectAreaAdminClick(Sender: TObject);
    procedure RectAreaUnivClick(Sender: TObject);
    procedure RectAreaInfantilClick(Sender: TObject);
    procedure RectAreaUniversidadeClick(Sender: TObject);
    procedure AreaMouseEnter(Sender: TObject);
    procedure AreaMouseLeave(Sender: TObject);
    procedure EdtSenhaKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure TimerPulseTimer(Sender: TObject);
    procedure TimerDecorTimer(Sender: TObject);
  private
    FAreaSelecionada: Integer;
    FPulseGrow: Boolean;
    FDecorItems: array[0..14] of TImage;
    FDecorSpeeds: array[0..14] of Single;
    FDecorRotations: array[0..14] of Single;
    procedure SelecionarArea(Area: Integer);
    procedure ResetarAreas;
    procedure ValidarLogin;
    procedure AnimarShake;
    procedure AnimarDecorItems;
    procedure CriarItensDecorativos;
  public
  end;

var
  FormLogin: TFormLogin;

const
  COR_VERMELHO = $FFD33327;
  COR_VERMELHO_ESCURO = $FF7D2728;
  COR_DOURADO = $FFFDCD62;
  COR_DOURADO_CLARO = $FFFFEABB;
  COR_BORDA_AREA = $4DFDCD62;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitAluno, UnitResponsavel, UnitProfessor, UnitAdministrativo, UnitEducInfantil;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  FAreaSelecionada := 0;
  FPulseGrow := True;
  RectCard.Opacity := 0;
  
  // Cria os itens decorativos (livros, lápis, etc.)
  CriarItensDecorativos;
end;

procedure TFormLogin.CriarItensDecorativos;
var
  I: Integer;
  Sizes: array[0..14] of Integer;
  PosX: array[0..14] of Single;
  Modelos: array[0..4] of TImage;
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
    FDecorItems[I].Parent := LayoutDecor;
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

procedure TFormLogin.FormShow(Sender: TObject);
begin
  // Animação de entrada do card
  TAnimator.AnimateFloat(RectCard, 'Opacity', 1, 0.6, TAnimationType.Out, TInterpolationType.Quadratic);
  
  // Inicia timers
  TimerPulse.Enabled := True;
  TimerDecor.Enabled := True;
  
  EdtUsuario.SetFocus;
end;

procedure TFormLogin.TimerPulseTimer(Sender: TObject);
begin
  // Animação de pulso no logo
  if FPulseGrow then
  begin
    TAnimator.AnimateFloat(CircleLogo, 'Scale.X', 1.08, 0.5);
    TAnimator.AnimateFloat(CircleLogo, 'Scale.Y', 1.08, 0.5);
    TAnimator.AnimateFloat(RectLogoBorder, 'RotationAngle', RectLogoBorder.RotationAngle + 90, 0.5);
  end
  else
  begin
    TAnimator.AnimateFloat(CircleLogo, 'Scale.X', 1, 0.5);
    TAnimator.AnimateFloat(CircleLogo, 'Scale.Y', 1, 0.5);
  end;
  FPulseGrow := not FPulseGrow;
end;

procedure TFormLogin.TimerDecorTimer(Sender: TObject);
begin
  AnimarDecorItems;
end;

procedure TFormLogin.AnimarDecorItems;
var
  I: Integer;
  MaxY: Single;
begin
  MaxY := RectFundo.Height + 60;
  
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

procedure TFormLogin.SelecionarArea(Area: Integer);
var
  RectArea: TRectangle;
begin
  ResetarAreas;
  FAreaSelecionada := Area;

  case Area of
    1: RectArea := RectAreaAluno;
    2: RectArea := RectAreaProfessor;
    3: RectArea := RectAreaAdmin;
    4: RectArea := RectAreaUniv;
    5: RectArea := RectAreaInfantil;
    6: RectArea := RectAreaUniversidade;
  else
    Exit;
  end;

  // Visual do botão selecionado
  RectArea.Fill.Color := COR_VERMELHO;
  RectArea.Stroke.Color := COR_DOURADO;
  RectArea.Stroke.Thickness := 2;

  // Animação de escala
  TAnimator.AnimateFloat(RectArea, 'Scale.X', 1.05, 0.15, TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(RectArea, 'Scale.Y', 1.05, 0.15, TAnimationType.Out, TInterpolationType.Back);

  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(150);
      TThread.Synchronize(nil,
        procedure
        begin
          TAnimator.AnimateFloat(RectArea, 'Scale.X', 1, 0.1);
          TAnimator.AnimateFloat(RectArea, 'Scale.Y', 1, 0.1);
        end);
    end).Start;
end;

procedure TFormLogin.ResetarAreas;
begin
  // Aluno
  RectAreaAluno.Fill.Color := $15FFFFFF;
  RectAreaAluno.Stroke.Color := COR_BORDA_AREA;
  RectAreaAluno.Stroke.Thickness := 1.5;

  // Professor
  RectAreaProfessor.Fill.Color := $15FFFFFF;
  RectAreaProfessor.Stroke.Color := COR_BORDA_AREA;
  RectAreaProfessor.Stroke.Thickness := 1.5;

  // Admin
  RectAreaAdmin.Fill.Color := $15FFFFFF;
  RectAreaAdmin.Stroke.Color := COR_BORDA_AREA;
  RectAreaAdmin.Stroke.Thickness := 1.5;

  // Administrativo (antigo Univ)
  RectAreaUniv.Fill.Color := $15FFFFFF;
  RectAreaUniv.Stroke.Color := COR_BORDA_AREA;
  RectAreaUniv.Stroke.Thickness := 1.5;

  // Educ.Infantil
  RectAreaInfantil.Fill.Color := $15FFFFFF;
  RectAreaInfantil.Stroke.Color := COR_BORDA_AREA;
  RectAreaInfantil.Stroke.Thickness := 1.5;

  // Universidade
  RectAreaUniversidade.Fill.Color := $15FFFFFF;
  RectAreaUniversidade.Stroke.Color := COR_BORDA_AREA;
  RectAreaUniversidade.Stroke.Thickness := 1.5;
end;

procedure TFormLogin.RectAreaAlunoClick(Sender: TObject);
begin
  SelecionarArea(1);
end;

procedure TFormLogin.RectAreaProfessorClick(Sender: TObject);
begin
  SelecionarArea(2);
end;

procedure TFormLogin.RectAreaAdminClick(Sender: TObject);
begin
  SelecionarArea(3);
end;

procedure TFormLogin.RectAreaUnivClick(Sender: TObject);
begin
  SelecionarArea(4);
end;

procedure TFormLogin.RectAreaInfantilClick(Sender: TObject);
begin
  SelecionarArea(5);
end;

procedure TFormLogin.RectAreaUniversidadeClick(Sender: TObject);
begin
  SelecionarArea(6);
end;

procedure TFormLogin.AreaMouseEnter(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    if ((Rect = RectAreaAluno) and (FAreaSelecionada <> 1)) or
       ((Rect = RectAreaProfessor) and (FAreaSelecionada <> 2)) or
       ((Rect = RectAreaAdmin) and (FAreaSelecionada <> 3)) or
       ((Rect = RectAreaUniv) and (FAreaSelecionada <> 4)) or
       ((Rect = RectAreaInfantil) and (FAreaSelecionada <> 5)) or
       ((Rect = RectAreaUniversidade) and (FAreaSelecionada <> 6)) then
    begin
      TAnimator.AnimateFloat(Rect, 'Scale.X', 1.03, 0.15);
      TAnimator.AnimateFloat(Rect, 'Scale.Y', 1.03, 0.15);
      Rect.Stroke.Color := COR_DOURADO;
    end;
  end;
end;

procedure TFormLogin.AreaMouseLeave(Sender: TObject);
var
  Rect: TRectangle;
begin
  if Sender is TRectangle then
  begin
    Rect := TRectangle(Sender);
    if ((Rect = RectAreaAluno) and (FAreaSelecionada <> 1)) or
       ((Rect = RectAreaProfessor) and (FAreaSelecionada <> 2)) or
       ((Rect = RectAreaAdmin) and (FAreaSelecionada <> 3)) or
       ((Rect = RectAreaUniv) and (FAreaSelecionada <> 4)) or
       ((Rect = RectAreaInfantil) and (FAreaSelecionada <> 5)) or
       ((Rect = RectAreaUniversidade) and (FAreaSelecionada <> 6)) then
    begin
      TAnimator.AnimateFloat(Rect, 'Scale.X', 1, 0.15);
      TAnimator.AnimateFloat(Rect, 'Scale.Y', 1, 0.15);
      Rect.Stroke.Color := COR_BORDA_AREA;
    end;
  end;
end;

procedure TFormLogin.BtnEntrarClick(Sender: TObject);
begin
  ValidarLogin;
end;

procedure TFormLogin.BtnEntrarMouseEnter(Sender: TObject);
begin
  TAnimator.AnimateFloat(BtnEntrar, 'Scale.X', 1.02, 0.15);
  TAnimator.AnimateFloat(BtnEntrar, 'Scale.Y', 1.02, 0.15);
  ShadowBtn.Distance := 10;
end;

procedure TFormLogin.BtnEntrarMouseLeave(Sender: TObject);
begin
  TAnimator.AnimateFloat(BtnEntrar, 'Scale.X', 1, 0.15);
  TAnimator.AnimateFloat(BtnEntrar, 'Scale.Y', 1, 0.15);
  ShadowBtn.Distance := 6;
end;

procedure TFormLogin.EdtSenhaKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    ValidarLogin;
end;

procedure TFormLogin.AnimarShake;
var
  PosOriginal: Single;
begin
  PosOriginal := RectCard.Position.X;
  TAnimator.AnimateFloat(RectCard, 'Position.X', PosOriginal + 15, 0.05);
  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(50);
      TThread.Synchronize(nil, procedure begin TAnimator.AnimateFloat(RectCard, 'Position.X', PosOriginal - 15, 0.05); end);
      Sleep(50);
      TThread.Synchronize(nil, procedure begin TAnimator.AnimateFloat(RectCard, 'Position.X', PosOriginal + 10, 0.05); end);
      Sleep(50);
      TThread.Synchronize(nil, procedure begin TAnimator.AnimateFloat(RectCard, 'Position.X', PosOriginal - 10, 0.05); end);
      Sleep(50);
      TThread.Synchronize(nil, procedure begin TAnimator.AnimateFloat(RectCard, 'Position.X', PosOriginal, 0.05); end);
    end).Start;
end;

procedure TFormLogin.ValidarLogin;
var
  Areas: array[1..6] of string;
begin
  Areas[1] := 'Aluno';
  Areas[2] := 'Responsáveis';
  Areas[3] := 'Professor';
  Areas[4] := 'Administrativo';
  Areas[5] := 'Educ.Infantil';
  Areas[6] := 'Universidade';
  
  // Validar área selecionada
  if FAreaSelecionada = 0 then
  begin
    ShowMessage('Por favor, selecione uma área de acesso!');
    AnimarShake;
    Exit;
  end;

  // Validar campos
  if (Trim(EdtUsuario.Text) = '') or (Trim(EdtSenha.Text) = '') then
  begin
    ShowMessage('Por favor, preencha usuário e senha!');
    AnimarShake;
    Exit;
  end;

  // Validar credenciais (admin/123)
  if (EdtUsuario.Text = 'admin') and (EdtSenha.Text = '123') then
  begin
    // Animação de saída
    TAnimator.AnimateFloat(RectCard, 'Opacity', 0, 0.4);
    TAnimator.AnimateFloat(RectCard, 'Scale.X', 0.9, 0.4);
    TAnimator.AnimateFloat(RectCard, 'Scale.Y', 0.9, 0.4);

    TThread.CreateAnonymousThread(
      procedure
      var
        AreaSel: Integer;
        NomeUsr: string;
      begin
        AreaSel := FAreaSelecionada;
        NomeUsr := EdtUsuario.Text;
        
        Sleep(450);
        TThread.Synchronize(nil,
          procedure
          begin
            // Para os timers
            TimerPulse.Enabled := False;
            TimerDecor.Enabled := False;
            
            // Abre a tela conforme a área selecionada
            case AreaSel of
              1: begin // Aluno
                   FormAluno.NomeUsuario := NomeUsr;
                   FormAluno.Show;
                 end;
              2: begin // Responsáveis
                   FormResponsavel.NomeUsuario := NomeUsr;
                   FormResponsavel.Show;
                 end;
              3: begin // Professor
                   FormProfessor.NomeUsuario := NomeUsr;
                   FormProfessor.Show;
                 end;
              4: begin // Administrativo
                   FormAdministrativo.NomeUsuario := NomeUsr;
                   FormAdministrativo.Show;
                 end;
              5: begin // Educ.Infantil
                   FormEducInfantil.NomeUsuario := NomeUsr;
                   FormEducInfantil.Show;
                 end;
              6: begin // Universidade
                   FormPrincipal.NomeUsuario := NomeUsr;
                   FormPrincipal.TipoUsuario := Areas[AreaSel];
                   FormPrincipal.Show;
                 end;
            end;
            
            Self.Hide;
            
            // Reset do login para próximo uso
            RectCard.Opacity := 1;
            RectCard.Scale.X := 1;
            RectCard.Scale.Y := 1;
            EdtUsuario.Text := '';
            EdtSenha.Text := '';
            FAreaSelecionada := 0;
            ResetarAreas;
          end);
      end).Start;
  end
  else
  begin
    ShowMessage('Usuário ou senha inválidos!');
    AnimarShake;
    EdtSenha.Text := '';
    EdtSenha.SetFocus;
  end;
end;

end.
