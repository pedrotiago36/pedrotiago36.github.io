unit UnitChatAluno;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Ani, FMX.Effects,
  FMX.Layouts, FMX.ScrollBox, System.JSON, UnitHTTPClient;

type
  TFormChatAluno = class(TForm)
    RectFundo: TRectangle;
    RectHeader: TRectangle;
    ShadowHeader: TShadowEffect;
    RectBtnVoltar: TRectangle;
    LblBtnVoltar: TLabel;
    LblTituloHeader: TLabel;
    LblSubtituloHeader: TLabel;
    RectPanelProfessores: TRectangle;
    LblProfStatus: TLabel;
    ScrollBoxProfessores: TVertScrollBox;
    RectPanelChat: TRectangle;
    RectChatSubHeader: TRectangle;
    RectBtnVoltarLista: TRectangle;
    LblBtnVoltarLista: TLabel;
    LblProfNome: TLabel;
    LblProfInfo: TLabel;
    RectInputBar: TRectangle;
    EditMensagem: TEdit;
    RectBtnEnviar: TRectangle;
    LblBtnEnviar: TLabel;
    ScrollBoxMensagens: TVertScrollBox;
    TimerRefresh: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RectBtnVoltarClick(Sender: TObject);
    procedure RectBtnVoltarListaClick(Sender: TObject);
    procedure RectBtnEnviarClick(Sender: TObject);
    procedure TimerRefreshTimer(Sender: TObject);
  private
    FProfessorId: Integer;
    FProfessorNome: string;
    FProfessorInfo: string;
    FMsgY: Single;
    procedure CarregarProfessores;
    procedure LimparPainelProfessores;
    procedure CriarItemProfessor(const Nome, Serie, Turma: string; Id: Integer; NaoLidas: Integer);
    procedure ProfessorClick(Sender: TObject);
    procedure AbrirChat(ProfId: Integer; const ProfNome, ProfInfo: string);
    procedure CarregarConversa;
    procedure LimparMensagens;
    procedure CriarBolha(const Texto, Remetente, DtEnvio: string);
    procedure RolarParaBaixo;
    function CalcBubbleHeight(const Texto: string; BubbleW: Single): Single;
  public
    Matricula: string;
    NomeAluno: string;
  end;

var
  FormChatAluno: TFormChatAluno;

implementation

{$R *.fmx}

procedure TFormChatAluno.FormShow(Sender: TObject);
begin
  TimerRefresh.Enabled := False;
  LblSubtituloHeader.Text := NomeAluno;
  FormResize(nil);
  RectPanelChat.Visible := False;
  RectPanelProfessores.Visible := True;
  CarregarProfessores;
end;

procedure TFormChatAluno.FormResize(Sender: TObject);
var PanelH: Single;
begin
  LblTituloHeader.Width := Width - 90;
  LblSubtituloHeader.Width := Width - 90;
  PanelH := Height - 80;
  RectPanelProfessores.Position.Y := 80;
  RectPanelProfessores.Width  := Width;
  RectPanelProfessores.Height := PanelH;
  RectPanelChat.Position.Y := 80;
  RectPanelChat.Width  := Width;
  RectPanelChat.Height := PanelH;
  EditMensagem.Width := Width - 85;
  RectBtnEnviar.Position.X := Width - 75;
end;

procedure TFormChatAluno.RectBtnVoltarClick(Sender: TObject);
begin
  TimerRefresh.Enabled := False;
  Close;
end;

procedure TFormChatAluno.RectBtnVoltarListaClick(Sender: TObject);
begin
  TimerRefresh.Enabled := False;
  RectPanelChat.Visible := False;
  RectPanelProfessores.Visible := True;
  CarregarProfessores;
end;

procedure TFormChatAluno.LimparPainelProfessores;
var I: Integer;
begin
  for I := ScrollBoxProfessores.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxProfessores.Content.Children[I].Free;
end;

procedure TFormChatAluno.CriarItemProfessor(const Nome, Serie, Turma: string;
  Id, NaoLidas: Integer);
var
  Item: TRectangle;
  LblNome, LblInfo, LblBadge: TLabel;
  PosY: Single;
  I: Integer;
  MaxY: Single;
begin
  MaxY := 5;
  for I := 0 to ScrollBoxProfessores.Content.ChildrenCount - 1 do
    if ScrollBoxProfessores.Content.Children[I] is TControl then
      MaxY := Max(MaxY, TControl(ScrollBoxProfessores.Content.Children[I]).Position.Y +
                        TControl(ScrollBoxProfessores.Content.Children[I]).Height + 5);
  PosY := MaxY;

  Item := TRectangle.Create(ScrollBoxProfessores);
  Item.Parent := ScrollBoxProfessores.Content;
  Item.Position.X := 0;
  Item.Position.Y := PosY;
  Item.Width := ScrollBoxProfessores.Width;
  Item.Height := 72;
  Item.Fill.Color := $20FFFFFF;
  Item.Stroke.Color := $4DFDCD62;
  Item.Stroke.Thickness := 1;
  Item.XRadius := 10;
  Item.YRadius := 10;
  Item.Cursor := crHandPoint;
  Item.Tag := Id;
  Item.TagString := Format('%d|%s|%s|%s', [Id, Nome, Serie, Turma]);
  Item.OnClick := ProfessorClick;

  LblNome := TLabel.Create(Item);
  LblNome.Parent := Item;
  LblNome.Position.X := 15;
  LblNome.Position.Y := 10;
  LblNome.Width := Item.Width - 80;
  LblNome.Height := 26;
  LblNome.StyledSettings := [];
  LblNome.TextSettings.Font.Size := 14;
  LblNome.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblNome.TextSettings.FontColor := TAlphaColors.White;
  LblNome.Text := Nome;
  LblNome.HitTest := False;

  LblInfo := TLabel.Create(Item);
  LblInfo.Parent := Item;
  LblInfo.Position.X := 15;
  LblInfo.Position.Y := 38;
  LblInfo.Width := Item.Width - 80;
  LblInfo.Height := 22;
  LblInfo.StyledSettings := [];
  LblInfo.TextSettings.Font.Size := 11;
  LblInfo.TextSettings.FontColor := $FFFDCD62;
  LblInfo.Text := Serie + '  |  Turma ' + Turma;
  LblInfo.HitTest := False;

  if NaoLidas > 0 then
  begin
    LblBadge := TLabel.Create(Item);
    LblBadge.Parent := Item;
    LblBadge.Position.X := Item.Width - 45;
    LblBadge.Position.Y := 22;
    LblBadge.Width := 30;
    LblBadge.Height := 26;
    LblBadge.StyledSettings := [];
    LblBadge.TextSettings.Font.Size := 11;
    LblBadge.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblBadge.TextSettings.FontColor := $FFFDCD62;
    LblBadge.TextSettings.HorzAlign := TTextAlign.Center;
    LblBadge.Text := IntToStr(NaoLidas);
    LblBadge.HitTest := False;
  end;
end;

procedure TFormChatAluno.CarregarProfessores;
begin
  LblProfStatus.Text := 'Carregando professores...';
  LblProfStatus.Visible := True;
  LimparPainelProfessores;

  APIGet('/professores',
    procedure(const ABody, AError: string)
    var
      JVal: TJSONValue;
      Arr: TJSONArray;
      Obj: TJSONObject;
      I, Id, NaoLidas: Integer;
      Nome, Serie, Turma: string;
    begin
      if AError <> '' then
      begin
        LblProfStatus.Text := 'Erro: ' + AError;
        Exit;
      end;
      JVal := TJSONObject.ParseJSONValue(ABody);
      if not Assigned(JVal) then
      begin
        LblProfStatus.Text := 'Nenhum professor disponível.';
        Exit;
      end;
      try
        if not (JVal is TJSONArray) then
        begin
          LblProfStatus.Text := 'Nenhum professor disponível.';
          Exit;
        end;
        Arr := TJSONArray(JVal);
        if Arr.Count = 0 then
        begin
          LblProfStatus.Text := 'Nenhum professor cadastrado.';
          Exit;
        end;
        LblProfStatus.Visible := False;
        NaoLidas := 0;
        for I := 0 to Arr.Count - 1 do
        begin
          Obj   := Arr.Items[I] as TJSONObject;
          Id    := StrToIntDef(Obj.GetValue('id').Value, 0);
          Nome  := Obj.GetValue('nome').Value;
          Serie := Obj.GetValue('serie').Value;
          Turma := Obj.GetValue('turma').Value;
          CriarItemProfessor(Nome, Serie, Turma, Id, NaoLidas);
        end;
      finally
        JVal.Free;
      end;
    end
  );
end;

procedure TFormChatAluno.ProfessorClick(Sender: TObject);
var
  Parts: TArray<string>;
  Item: TRectangle;
begin
  Item := TRectangle(Sender);
  Parts := Item.TagString.Split(['|'], 4);
  if Length(Parts) < 4 then Exit;
  AbrirChat(
    StrToIntDef(Parts[0], 0),
    Parts[1],
    Parts[2] + '  |  Turma ' + Parts[3]
  );
end;

procedure TFormChatAluno.AbrirChat(ProfId: Integer; const ProfNome, ProfInfo: string);
begin
  FProfessorId   := ProfId;
  FProfessorNome := ProfNome;
  FProfessorInfo := ProfInfo;
  LblProfNome.Text := ProfNome;
  LblProfInfo.Text := ProfInfo;
  RectPanelProfessores.Visible := False;
  RectPanelChat.Visible := True;

  APIPut('/mensagens/lida/aluno/' + IntToStr(ProfId) + '/' + Matricula, '{}',
    procedure(const ABody, AError: string) begin end);

  CarregarConversa;
  TimerRefresh.Enabled := True;
end;

procedure TFormChatAluno.LimparMensagens;
var I: Integer;
begin
  for I := ScrollBoxMensagens.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxMensagens.Content.Children[I].Free;
  FMsgY := 8;
end;

function TFormChatAluno.CalcBubbleHeight(const Texto: string; BubbleW: Single): Single;
var CharsPerLine, Lines: Integer;
begin
  CharsPerLine := Max(1, Round((BubbleW - 24) / 7.5));
  Lines := Max(1, Ceil(Length(Texto) / CharsPerLine));
  Result := Max(50, Lines * 22 + 38);
end;

procedure TFormChatAluno.CriarBolha(const Texto, Remetente, DtEnvio: string);
var
  Bubble: TRectangle;
  LblTexto, LblTempo: TLabel;
  BubbleW, BubbleH, BubbleX: Single;
  IsAluno: Boolean;
begin
  IsAluno := Remetente = 'aluno';
  BubbleW := ScrollBoxMensagens.Width * 0.78;
  BubbleH := CalcBubbleHeight(Texto, BubbleW);

  if IsAluno then
    BubbleX := ScrollBoxMensagens.Width - BubbleW - 8
  else
    BubbleX := 8;

  Bubble := TRectangle.Create(ScrollBoxMensagens);
  Bubble.Parent := ScrollBoxMensagens.Content;
  Bubble.Position.X := BubbleX;
  Bubble.Position.Y := FMsgY;
  Bubble.Width := BubbleW;
  Bubble.Height := BubbleH;
  if IsAluno then
    Bubble.Fill.Color := $60FDCD62
  else
    Bubble.Fill.Color := $28FFFFFF;
  Bubble.Stroke.Kind := TBrushKind.None;
  Bubble.XRadius := 12;
  Bubble.YRadius := 12;
  Bubble.HitTest := False;

  LblTexto := TLabel.Create(Bubble);
  LblTexto.Parent := Bubble;
  LblTexto.Position.X := 10;
  LblTexto.Position.Y := 8;
  LblTexto.Width := BubbleW - 20;
  LblTexto.Height := BubbleH - 28;
  LblTexto.StyledSettings := [];
  LblTexto.TextSettings.Font.Size := 13;
  if IsAluno then
    LblTexto.TextSettings.FontColor := $FF7D2728
  else
    LblTexto.TextSettings.FontColor := TAlphaColors.White;
  LblTexto.TextSettings.WordWrap := True;
  LblTexto.Text := Texto;
  LblTexto.HitTest := False;

  LblTempo := TLabel.Create(Bubble);
  LblTempo.Parent := Bubble;
  LblTempo.Position.X := BubbleW - 72;
  LblTempo.Position.Y := BubbleH - 20;
  LblTempo.Width := 64;
  LblTempo.Height := 16;
  LblTempo.StyledSettings := [];
  LblTempo.TextSettings.Font.Size := 9;
  if IsAluno then
    LblTempo.TextSettings.FontColor := $88501818
  else
    LblTempo.TextSettings.FontColor := $88FFFFFF;
  LblTempo.TextSettings.HorzAlign := TTextAlign.Trailing;
  LblTempo.Text := DtEnvio;
  LblTempo.HitTest := False;

  FMsgY := FMsgY + BubbleH + 6;
end;

procedure TFormChatAluno.RolarParaBaixo;
begin
  ScrollBoxMensagens.ScrollBy(0, ScrollBoxMensagens.ContentBounds.Height);
end;

procedure TFormChatAluno.CarregarConversa;
begin
  LimparMensagens;
  APIGet('/mensagens/conversa/' + IntToStr(FProfessorId) + '/' + Matricula,
    procedure(const ABody, AError: string)
    var
      JVal: TJSONValue;
      Arr: TJSONArray;
      Obj: TJSONObject;
      I: Integer;
    begin
      if AError <> '' then Exit;
      JVal := TJSONObject.ParseJSONValue(ABody);
      if not Assigned(JVal) then Exit;
      try
        if not (JVal is TJSONArray) then Exit;
        Arr := TJSONArray(JVal);
        for I := 0 to Arr.Count - 1 do
        begin
          Obj := Arr.Items[I] as TJSONObject;
          CriarBolha(
            Obj.GetValue('texto').Value,
            Obj.GetValue('remetente').Value,
            Obj.GetValue('dt_envio').Value
          );
        end;
        RolarParaBaixo;
      finally
        JVal.Free;
      end;
    end
  );
end;

procedure TFormChatAluno.RectBtnEnviarClick(Sender: TObject);
var
  Texto: string;
  JBody: TJSONObject;
  Body: string;
begin
  Texto := EditMensagem.Text.Trim;
  if Texto = '' then Exit;
  EditMensagem.Text := '';

  JBody := TJSONObject.Create;
  try
    JBody.AddPair('aluno_matricula', Matricula);
    JBody.AddPair('aluno_nome',      NomeAluno);
    JBody.AddPair('professor_id',    TJSONNumber.Create(FProfessorId));
    JBody.AddPair('texto',           Texto);
    JBody.AddPair('remetente',       'aluno');
    Body := JBody.ToJSON;
  finally
    JBody.Free;
  end;

  APIPost('/mensagens', Body,
    procedure(const ABody, AError: string)
    begin
      if AError = '' then CarregarConversa;
    end
  );
end;

procedure TFormChatAluno.TimerRefreshTimer(Sender: TObject);
begin
  if RectPanelChat.Visible and (FProfessorId > 0) then
    CarregarConversa;
end;

end.
