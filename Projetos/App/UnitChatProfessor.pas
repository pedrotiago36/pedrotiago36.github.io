unit UnitChatProfessor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Ani, FMX.Effects,
  FMX.Layouts, FMX.ScrollBox, System.JSON, UnitHTTPClient;

type
  TFormChatProfessor = class(TForm)
    RectFundo: TRectangle;
    RectHeader: TRectangle;
    ShadowHeader: TShadowEffect;
    RectBtnVoltar: TRectangle;
    LblBtnVoltar: TLabel;
    LblTituloHeader: TLabel;
    LblSubtituloHeader: TLabel;
    RectPanelAlunos: TRectangle;
    LblAlunosStatus: TLabel;
    ScrollBoxAlunos: TVertScrollBox;
    RectPanelChat: TRectangle;
    RectChatSubHeader: TRectangle;
    RectBtnVoltarLista: TRectangle;
    LblBtnVoltarLista: TLabel;
    LblAlunoNome: TLabel;
    LblAlunoInfo: TLabel;
    RectInputBar: TRectangle;
    EditMensagem: TEdit;
    RectBtnEnviar: TRectangle;
    LblBtnEnviar: TLabel;
    ScrollBoxMensagens: TVertScrollBox;
    RectOverlaySeletor: TRectangle;
    RectCardSeletor: TRectangle;
    LblSeletorTitulo: TLabel;
    LblSeletorInfo: TLabel;
    ScrollBoxSeletor: TVertScrollBox;
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
    FAlunoMatricula: string;
    FAlunoNome: string;
    FMsgY: Single;
    procedure CarregarSeletor;
    procedure LimparSeletor;
    procedure CriarItemSeletor(const Nome, Serie, Turma: string; Id: Integer);
    procedure SelecionarProfessor(Sender: TObject);
    procedure CarregarAlunos;
    procedure LimparAlunos;
    procedure CriarItemAluno(const Nome, Matricula: string; NaoLidas: Integer);
    procedure AlunoClick(Sender: TObject);
    procedure AbrirChat(const AlunoMatricula, AlunoNome: string);
    procedure CarregarConversa;
    procedure LimparMensagens;
    procedure CriarBolha(const Texto, Remetente, DtEnvio: string);
    procedure RolarParaBaixo;
    function CalcBubbleHeight(const Texto: string; BubbleW: Single): Single;
  public
    { Public declarations }
  end;

var
  FormChatProfessor: TFormChatProfessor;

implementation

{$R *.fmx}

procedure TFormChatProfessor.FormShow(Sender: TObject);
begin
  TimerRefresh.Enabled := False;
  FProfessorId := 0;
  FormResize(nil);
  RectPanelChat.Visible := False;
  RectPanelAlunos.Visible := True;
  RectOverlaySeletor.Visible := True;
  CarregarSeletor;
end;

procedure TFormChatProfessor.FormResize(Sender: TObject);
var PanelH: Single;
begin
  LblTituloHeader.Width := Width - 90;
  LblSubtituloHeader.Width := Width - 90;
  PanelH := Height - 80;
  RectPanelAlunos.Position.Y := 80;
  RectPanelAlunos.Width  := Width;
  RectPanelAlunos.Height := PanelH;
  RectPanelChat.Position.Y := 80;
  RectPanelChat.Width  := Width;
  RectPanelChat.Height := PanelH;
  RectCardSeletor.Position.X := (Width - RectCardSeletor.Width) / 2;
  RectCardSeletor.Position.Y := (Height - RectCardSeletor.Height) / 2;
  EditMensagem.Width := Width - 85;
  RectBtnEnviar.Position.X := Width - 75;
end;

procedure TFormChatProfessor.RectBtnVoltarClick(Sender: TObject);
begin
  TimerRefresh.Enabled := False;
  Close;
end;

procedure TFormChatProfessor.RectBtnVoltarListaClick(Sender: TObject);
begin
  TimerRefresh.Enabled := False;
  RectPanelChat.Visible := False;
  RectPanelAlunos.Visible := True;
  CarregarAlunos;
end;

// ─── Seletor de Professor ──────────────────────────────────────────────────

procedure TFormChatProfessor.LimparSeletor;
var I: Integer;
begin
  for I := ScrollBoxSeletor.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxSeletor.Content.Children[I].Free;
end;

procedure TFormChatProfessor.CriarItemSeletor(const Nome, Serie, Turma: string; Id: Integer);
var
  Item: TRectangle;
  LblNome, LblInfo: TLabel;
  PosY: Single;
  I: Integer;
  MaxY: Single;
begin
  MaxY := 2;
  for I := 0 to ScrollBoxSeletor.Content.ChildrenCount - 1 do
    if ScrollBoxSeletor.Content.Children[I] is TControl then
      MaxY := Max(MaxY, TControl(ScrollBoxSeletor.Content.Children[I]).Position.Y +
                        TControl(ScrollBoxSeletor.Content.Children[I]).Height + 5);
  PosY := MaxY;

  Item := TRectangle.Create(ScrollBoxSeletor);
  Item.Parent := ScrollBoxSeletor.Content;
  Item.Position.X := 0;
  Item.Position.Y := PosY;
  Item.Width := ScrollBoxSeletor.Width;
  Item.Height := 62;
  Item.Fill.Color := $20FFFFFF;
  Item.Stroke.Color := $4DFDCD62;
  Item.Stroke.Thickness := 1;
  Item.XRadius := 8;
  Item.YRadius := 8;
  Item.Cursor := crHandPoint;
  Item.Tag := Id;
  Item.TagString := Format('%d|%s|%s|%s', [Id, Nome, Serie, Turma]);
  Item.OnClick := SelecionarProfessor;

  LblNome := TLabel.Create(Item);
  LblNome.Parent := Item;
  LblNome.Position.X := 12;
  LblNome.Position.Y := 8;
  LblNome.Width := Item.Width - 20;
  LblNome.Height := 24;
  LblNome.StyledSettings := [];
  LblNome.TextSettings.Font.Size := 14;
  LblNome.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblNome.TextSettings.FontColor := TAlphaColors.White;
  LblNome.Text := Nome;
  LblNome.HitTest := False;

  LblInfo := TLabel.Create(Item);
  LblInfo.Parent := Item;
  LblInfo.Position.X := 12;
  LblInfo.Position.Y := 36;
  LblInfo.Width := Item.Width - 20;
  LblInfo.Height := 20;
  LblInfo.StyledSettings := [];
  LblInfo.TextSettings.Font.Size := 11;
  LblInfo.TextSettings.FontColor := $FFFDCD62;
  LblInfo.Text := Serie + '  |  Turma ' + Turma;
  LblInfo.HitTest := False;
end;

procedure TFormChatProfessor.CarregarSeletor;
begin
  LimparSeletor;
  LblSeletorInfo.Text := 'Aguarde...';

  APIGet('/professores',
    procedure(const ABody, AError: string)
    var
      JVal: TJSONValue;
      Arr: TJSONArray;
      Obj: TJSONObject;
      I, Id: Integer;
      Nome, Serie, Turma: string;
    begin
      if AError <> '' then
      begin
        LblSeletorInfo.Text := 'Erro ao carregar professores.';
        Exit;
      end;
      JVal := TJSONObject.ParseJSONValue(ABody);
      if not Assigned(JVal) then
      begin
        LblSeletorInfo.Text := 'Nenhum professor cadastrado.';
        Exit;
      end;
      try
        if not (JVal is TJSONArray) then
        begin
          LblSeletorInfo.Text := 'Nenhum professor cadastrado.';
          Exit;
        end;
        Arr := TJSONArray(JVal);
        if Arr.Count = 0 then
        begin
          LblSeletorInfo.Text := 'Nenhum professor cadastrado.';
          Exit;
        end;
        LblSeletorInfo.Text := 'Selecione seu nome para ver suas mensagens';
        for I := 0 to Arr.Count - 1 do
        begin
          Obj   := Arr.Items[I] as TJSONObject;
          Id    := StrToIntDef(Obj.GetValue('id').Value, 0);
          Nome  := Obj.GetValue('nome').Value;
          Serie := Obj.GetValue('serie').Value;
          Turma := Obj.GetValue('turma').Value;
          CriarItemSeletor(Nome, Serie, Turma, Id);
        end;
      finally
        JVal.Free;
      end;
    end
  );
end;

procedure TFormChatProfessor.SelecionarProfessor(Sender: TObject);
var
  Parts: TArray<string>;
  Item: TRectangle;
begin
  Item := TRectangle(Sender);
  Parts := Item.TagString.Split(['|'], 4);
  if Length(Parts) < 4 then Exit;
  FProfessorId   := StrToIntDef(Parts[0], 0);
  FProfessorNome := Parts[1];
  LblSubtituloHeader.Text := FProfessorNome;
  RectOverlaySeletor.Visible := False;
  CarregarAlunos;
end;

// ─── Lista de Alunos ──────────────────────────────────────────────────────

procedure TFormChatProfessor.LimparAlunos;
var I: Integer;
begin
  for I := ScrollBoxAlunos.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxAlunos.Content.Children[I].Free;
end;

procedure TFormChatProfessor.CriarItemAluno(const Nome, Matricula: string; NaoLidas: Integer);
var
  Item: TRectangle;
  LblNome, LblMat, LblBadge: TLabel;
  PosY: Single;
  I: Integer;
  MaxY: Single;
begin
  MaxY := 5;
  for I := 0 to ScrollBoxAlunos.Content.ChildrenCount - 1 do
    if ScrollBoxAlunos.Content.Children[I] is TControl then
      MaxY := Max(MaxY, TControl(ScrollBoxAlunos.Content.Children[I]).Position.Y +
                        TControl(ScrollBoxAlunos.Content.Children[I]).Height + 5);
  PosY := MaxY;

  Item := TRectangle.Create(ScrollBoxAlunos);
  Item.Parent := ScrollBoxAlunos.Content;
  Item.Position.X := 0;
  Item.Position.Y := PosY;
  Item.Width := ScrollBoxAlunos.Width;
  Item.Height := 72;
  Item.Fill.Color := $20FFFFFF;
  Item.Stroke.Color := $4DFDCD62;
  Item.Stroke.Thickness := 1;
  Item.XRadius := 10;
  Item.YRadius := 10;
  Item.Cursor := crHandPoint;
  Item.TagString := Matricula + '|' + Nome;
  Item.OnClick := AlunoClick;

  LblNome := TLabel.Create(Item);
  LblNome.Parent := Item;
  LblNome.Position.X := 15;
  LblNome.Position.Y := 10;
  LblNome.Width := Item.Width - 75;
  LblNome.Height := 26;
  LblNome.StyledSettings := [];
  LblNome.TextSettings.Font.Size := 14;
  LblNome.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblNome.TextSettings.FontColor := TAlphaColors.White;
  LblNome.Text := Nome;
  LblNome.HitTest := False;

  LblMat := TLabel.Create(Item);
  LblMat.Parent := Item;
  LblMat.Position.X := 15;
  LblMat.Position.Y := 38;
  LblMat.Width := Item.Width - 75;
  LblMat.Height := 22;
  LblMat.StyledSettings := [];
  LblMat.TextSettings.Font.Size := 11;
  LblMat.TextSettings.FontColor := $FFFDCD62;
  LblMat.Text := 'Matrícula: ' + Matricula;
  LblMat.HitTest := False;

  if NaoLidas > 0 then
  begin
    LblBadge := TLabel.Create(Item);
    LblBadge.Parent := Item;
    LblBadge.Position.X := Item.Width - 52;
    LblBadge.Position.Y := 20;
    LblBadge.Width := 38;
    LblBadge.Height := 30;
    LblBadge.StyledSettings := [];
    LblBadge.TextSettings.Font.Size := 13;
    LblBadge.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblBadge.TextSettings.FontColor := $FFFDCD62;
    LblBadge.TextSettings.HorzAlign := TTextAlign.Center;
    LblBadge.Text := IntToStr(NaoLidas);
    LblBadge.HitTest := False;
  end;
end;

procedure TFormChatProfessor.CarregarAlunos;
begin
  LblAlunosStatus.Text := 'Carregando conversas...';
  LblAlunosStatus.Visible := True;
  LimparAlunos;

  if FProfessorId = 0 then Exit;

  APIGet('/mensagens/professor/' + IntToStr(FProfessorId),
    procedure(const ABody, AError: string)
    var
      JVal: TJSONValue;
      Arr: TJSONArray;
      Obj: TJSONObject;
      I, NaoLidas: Integer;
      Nome, Matricula: string;
    begin
      if AError <> '' then
      begin
        LblAlunosStatus.Text := 'Erro: ' + AError;
        Exit;
      end;
      JVal := TJSONObject.ParseJSONValue(ABody);
      if not Assigned(JVal) then
      begin
        LblAlunosStatus.Text := 'Nenhuma mensagem recebida.';
        Exit;
      end;
      try
        if not (JVal is TJSONArray) then
        begin
          LblAlunosStatus.Text := 'Nenhuma mensagem recebida.';
          Exit;
        end;
        Arr := TJSONArray(JVal);
        if Arr.Count = 0 then
        begin
          LblAlunosStatus.Text := 'Nenhuma mensagem recebida ainda.';
          Exit;
        end;
        LblAlunosStatus.Visible := False;
        for I := 0 to Arr.Count - 1 do
        begin
          Obj        := Arr.Items[I] as TJSONObject;
          Matricula  := Obj.GetValue('matricula').Value;
          Nome       := Obj.GetValue('nome').Value;
          NaoLidas   := StrToIntDef(Obj.GetValue('nao_lidas').Value, 0);
          CriarItemAluno(Nome, Matricula, NaoLidas);
        end;
      finally
        JVal.Free;
      end;
    end
  );
end;

procedure TFormChatProfessor.AlunoClick(Sender: TObject);
var
  Parts: TArray<string>;
begin
  Parts := TRectangle(Sender).TagString.Split(['|'], 2);
  if Length(Parts) < 2 then Exit;
  AbrirChat(Parts[0], Parts[1]);
end;

// ─── Chat Thread ──────────────────────────────────────────────────────────

procedure TFormChatProfessor.AbrirChat(const AlunoMatricula, AlunoNome: string);
begin
  FAlunoMatricula := AlunoMatricula;
  FAlunoNome      := AlunoNome;
  LblAlunoNome.Text := AlunoNome;
  LblAlunoInfo.Text := 'Matrícula: ' + AlunoMatricula;
  RectPanelAlunos.Visible := False;
  RectPanelChat.Visible := True;

  APIPut('/mensagens/lida/professor/' + IntToStr(FProfessorId) + '/' + AlunoMatricula, '{}',
    procedure(const ABody, AError: string) begin end);

  CarregarConversa;
  TimerRefresh.Enabled := True;
end;

procedure TFormChatProfessor.LimparMensagens;
var I: Integer;
begin
  for I := ScrollBoxMensagens.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxMensagens.Content.Children[I].Free;
  FMsgY := 8;
end;

function TFormChatProfessor.CalcBubbleHeight(const Texto: string; BubbleW: Single): Single;
var CharsPerLine, Lines: Integer;
begin
  CharsPerLine := Max(1, Round((BubbleW - 24) / 7.5));
  Lines := Max(1, Ceil(Length(Texto) / CharsPerLine));
  Result := Max(50, Lines * 22 + 38);
end;

procedure TFormChatProfessor.CriarBolha(const Texto, Remetente, DtEnvio: string);
var
  Bubble: TRectangle;
  LblTexto, LblTempo: TLabel;
  BubbleW, BubbleH, BubbleX: Single;
  IsProfessor: Boolean;
begin
  IsProfessor := Remetente = 'professor';
  BubbleW := ScrollBoxMensagens.Width * 0.78;
  BubbleH := CalcBubbleHeight(Texto, BubbleW);

  if IsProfessor then
    BubbleX := ScrollBoxMensagens.Width - BubbleW - 8
  else
    BubbleX := 8;

  Bubble := TRectangle.Create(ScrollBoxMensagens);
  Bubble.Parent := ScrollBoxMensagens.Content;
  Bubble.Position.X := BubbleX;
  Bubble.Position.Y := FMsgY;
  Bubble.Width := BubbleW;
  Bubble.Height := BubbleH;
  if IsProfessor then
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
  if IsProfessor then
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
  if IsProfessor then
    LblTempo.TextSettings.FontColor := $88501818
  else
    LblTempo.TextSettings.FontColor := $88FFFFFF;
  LblTempo.TextSettings.HorzAlign := TTextAlign.Trailing;
  LblTempo.Text := DtEnvio;
  LblTempo.HitTest := False;

  FMsgY := FMsgY + BubbleH + 6;
end;

procedure TFormChatProfessor.RolarParaBaixo;
begin
  ScrollBoxMensagens.ScrollBy(0, ScrollBoxMensagens.ContentBounds.Height);
end;

procedure TFormChatProfessor.CarregarConversa;
begin
  LimparMensagens;
  APIGet('/mensagens/conversa/' + IntToStr(FProfessorId) + '/' + FAlunoMatricula,
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

procedure TFormChatProfessor.RectBtnEnviarClick(Sender: TObject);
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
    JBody.AddPair('aluno_matricula', FAlunoMatricula);
    JBody.AddPair('aluno_nome',      FAlunoNome);
    JBody.AddPair('professor_id',    TJSONNumber.Create(FProfessorId));
    JBody.AddPair('texto',           Texto);
    JBody.AddPair('remetente',       'professor');
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

procedure TFormChatProfessor.TimerRefreshTimer(Sender: TObject);
begin
  if RectPanelChat.Visible and (FProfessorId > 0) and (FAlunoMatricula <> '') then
    CarregarConversa;
end;

end.
