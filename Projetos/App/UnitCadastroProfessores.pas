unit UnitCadastroProfessores;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Ani, FMX.Effects,
  FMX.Layouts, FMX.ScrollBox, System.JSON, UnitHTTPClient;

type
  TFormCadastroProfessores = class(TForm)
    RectFundo: TRectangle;
    RectHeader: TRectangle;
    ShadowHeader: TShadowEffect;
    RectBtnVoltar: TRectangle;
    LblBtnVoltar: TLabel;
    LblTituloHeader: TLabel;
    LblSubtituloHeader: TLabel;
    LblStatus: TLabel;
    ScrollBoxLista: TVertScrollBox;
    RectBtnAdicionar: TRectangle;
    ShadowBtnAdicionar: TShadowEffect;
    LblBtnAdicionar: TLabel;
    RectOverlayEditor: TRectangle;
    RectFormEditor: TRectangle;
    LblEditorTitulo: TLabel;
    LblNomeLabel: TLabel;
    EditNome: TEdit;
    LblSerieLabel: TLabel;
    EditSerie: TEdit;
    LblTurmaLabel: TLabel;
    EditTurma: TEdit;
    RectBtnSalvar: TRectangle;
    LblBtnSalvar: TLabel;
    RectBtnCancelar: TRectangle;
    LblBtnCancelar: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RectBtnVoltarClick(Sender: TObject);
    procedure RectBtnAdicionarClick(Sender: TObject);
    procedure RectBtnSalvarClick(Sender: TObject);
    procedure RectBtnCancelarClick(Sender: TObject);
  private
    FEditandoId: Integer;
    FListaY: Single;
    procedure CarregarProfessores;
    procedure LimparLista;
    procedure CriarItemProfessor(const Nome, Serie, Turma: string; Id: Integer);
    procedure EditarProfessor(Sender: TObject);
    procedure ExcluirProfessor(Sender: TObject);
    function JVal(const ABody, AKey: string): string;
  public
    { Public declarations }
  end;

var
  FormCadastroProfessores: TFormCadastroProfessores;

implementation

{$R *.fmx}

procedure TFormCadastroProfessores.FormShow(Sender: TObject);
begin
  FormResize(nil);
  CarregarProfessores;
end;

procedure TFormCadastroProfessores.FormResize(Sender: TObject);
begin
  LblTituloHeader.Width := Width - 90;
  LblSubtituloHeader.Width := Width - 90;
  LblStatus.Width := Width - 30;
  RectBtnAdicionar.Position.X := Width - 90;
  RectBtnAdicionar.Position.Y := Height - 80;
  RectFormEditor.Position.X := (Width - RectFormEditor.Width) / 2;
  RectFormEditor.Position.Y := (Height - RectFormEditor.Height) / 2;
end;

procedure TFormCadastroProfessores.RectBtnVoltarClick(Sender: TObject);
begin
  Close;
end;

function TFormCadastroProfessores.JVal(const ABody, AKey: string): string;
var
  Obj: TJSONObject;
  V: TJSONValue;
begin
  Result := '';
  Obj := TJSONObject.ParseJSONValue(ABody) as TJSONObject;
  if Assigned(Obj) then
  try
    V := Obj.GetValue(AKey);
    if Assigned(V) then Result := V.Value;
  finally
    Obj.Free;
  end;
end;

procedure TFormCadastroProfessores.LimparLista;
var I: Integer;
begin
  for I := ScrollBoxLista.Content.ChildrenCount - 1 downto 0 do
    ScrollBoxLista.Content.Children[I].Free;
  FListaY := 5;
end;

procedure TFormCadastroProfessores.CriarItemProfessor(
  const Nome, Serie, Turma: string; Id: Integer);
var
  Item: TRectangle;
  LblNome, LblInfo: TLabel;
  BtnEdit, BtnDel: TRectangle;
  LblEdit, LblDel: TLabel;
  ItemW: Single;
begin
  ItemW := ScrollBoxLista.Width;

  Item := TRectangle.Create(ScrollBoxLista);
  Item.Parent := ScrollBoxLista.Content;
  Item.Position.X := 0;
  Item.Position.Y := FListaY;
  Item.Width := ItemW;
  Item.Height := 72;
  Item.Fill.Color := $20FFFFFF;
  Item.Stroke.Color := $4DFDCD62;
  Item.Stroke.Thickness := 1;
  Item.XRadius := 10;
  Item.YRadius := 10;
  Item.Tag := Id;
  Item.TagString := Format('%d|%s|%s|%s', [Id, Nome, Serie, Turma]);

  LblNome := TLabel.Create(Item);
  LblNome.Parent := Item;
  LblNome.Position.X := 12;
  LblNome.Position.Y := 10;
  LblNome.Width := ItemW - 115;
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
  LblInfo.Position.Y := 38;
  LblInfo.Width := ItemW - 115;
  LblInfo.Height := 22;
  LblInfo.StyledSettings := [];
  LblInfo.TextSettings.Font.Size := 11;
  LblInfo.TextSettings.FontColor := $FFFDCD62;
  LblInfo.Text := Serie + '  |  Turma ' + Turma;
  LblInfo.HitTest := False;

  BtnEdit := TRectangle.Create(Item);
  BtnEdit.Parent := Item;
  BtnEdit.Position.X := ItemW - 100;
  BtnEdit.Position.Y := 13;
  BtnEdit.Width := 40;
  BtnEdit.Height := 46;
  BtnEdit.Fill.Color := $20FFFFFF;
  BtnEdit.Stroke.Color := $40FDCD62;
  BtnEdit.XRadius := 8;
  BtnEdit.YRadius := 8;
  BtnEdit.Cursor := crHandPoint;
  BtnEdit.TagString := Format('%d|%s|%s|%s', [Id, Nome, Serie, Turma]);
  BtnEdit.OnClick := EditarProfessor;

  LblEdit := TLabel.Create(BtnEdit);
  LblEdit.Parent := BtnEdit;
  LblEdit.Align := TAlignLayout.Client;
  LblEdit.HitTest := False;
  LblEdit.StyledSettings := [];
  LblEdit.Text := #9998;
  LblEdit.TextSettings.Font.Size := 18;
  LblEdit.TextSettings.FontColor := $FFFDCD62;
  LblEdit.TextSettings.HorzAlign := TTextAlign.Center;
  LblEdit.TextSettings.VertAlign := TTextAlign.Center;

  BtnDel := TRectangle.Create(Item);
  BtnDel.Parent := Item;
  BtnDel.Position.X := ItemW - 52;
  BtnDel.Position.Y := 13;
  BtnDel.Width := 40;
  BtnDel.Height := 46;
  BtnDel.Fill.Color := $20FFFFFF;
  BtnDel.Stroke.Color := $40FF5555;
  BtnDel.XRadius := 8;
  BtnDel.YRadius := 8;
  BtnDel.Cursor := crHandPoint;
  BtnDel.Tag := Id;
  BtnDel.OnClick := ExcluirProfessor;

  LblDel := TLabel.Create(BtnDel);
  LblDel.Parent := BtnDel;
  LblDel.Align := TAlignLayout.Client;
  LblDel.HitTest := False;
  LblDel.StyledSettings := [];
  LblDel.Text := #10006;
  LblDel.TextSettings.Font.Size := 16;
  LblDel.TextSettings.FontColor := $FFFF6666;
  LblDel.TextSettings.HorzAlign := TTextAlign.Center;
  LblDel.TextSettings.VertAlign := TTextAlign.Center;

  FListaY := FListaY + 78;
end;

procedure TFormCadastroProfessores.CarregarProfessores;
begin
  LblStatus.Text := 'Carregando professores...';
  LblStatus.Visible := True;
  LimparLista;

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
        LblStatus.Text := 'Erro ao carregar: ' + AError;
        Exit;
      end;
      JVal := TJSONObject.ParseJSONValue(ABody);
      if not Assigned(JVal) then
      begin
        LblStatus.Text := 'Nenhum professor cadastrado.';
        Exit;
      end;
      try
        if not (JVal is TJSONArray) then
        begin
          LblStatus.Text := 'Nenhum professor cadastrado.';
          Exit;
        end;
        Arr := TJSONArray(JVal);
        if Arr.Count = 0 then
        begin
          LblStatus.Text := 'Nenhum professor cadastrado. Toque + para adicionar.';
          Exit;
        end;
        LblStatus.Visible := False;
        for I := 0 to Arr.Count - 1 do
        begin
          Obj := Arr.Items[I] as TJSONObject;
          Id    := StrToIntDef(Obj.GetValue('id').Value,    0);
          Nome  := Obj.GetValue('nome').Value;
          Serie := Obj.GetValue('serie').Value;
          Turma := Obj.GetValue('turma').Value;
          CriarItemProfessor(Nome, Serie, Turma, Id);
        end;
      finally
        JVal.Free;
      end;
    end
  );
end;

procedure TFormCadastroProfessores.EditarProfessor(Sender: TObject);
var
  Parts: TArray<string>;
begin
  Parts := TRectangle(Sender).TagString.Split(['|'], 4);
  if Length(Parts) < 4 then Exit;
  FEditandoId := StrToIntDef(Parts[0], 0);
  LblEditorTitulo.Text := 'Editar Professor';
  EditNome.Text  := Parts[1];
  EditSerie.Text := Parts[2];
  EditTurma.Text := Parts[3];
  EditNome.Visible  := True;
  EditSerie.Visible := True;
  EditTurma.Visible := True;
  RectOverlayEditor.Visible := True;
end;

procedure TFormCadastroProfessores.ExcluirProfessor(Sender: TObject);
var
  ProfId: Integer;
begin
  ProfId := TRectangle(Sender).Tag;
  APIDelete('/professores/' + IntToStr(ProfId),
    procedure(const ABody, AError: string)
    begin
      if AError <> '' then
      begin
        LblStatus.Text := 'Erro ao excluir: ' + AError;
        LblStatus.Visible := True;
      end
      else
        CarregarProfessores;
    end
  );
end;

procedure TFormCadastroProfessores.RectBtnAdicionarClick(Sender: TObject);
begin
  FEditandoId := 0;
  LblEditorTitulo.Text := 'Novo Professor';
  EditNome.Text  := '';
  EditSerie.Text := '';
  EditTurma.Text := '';
  EditNome.Visible  := True;
  EditSerie.Visible := True;
  EditTurma.Visible := True;
  RectOverlayEditor.Visible := True;
end;

procedure TFormCadastroProfessores.RectBtnSalvarClick(Sender: TObject);
var
  JBody: TJSONObject;
  Body: string;
begin
  if EditNome.Text.Trim = '' then
  begin
    LblStatus.Text := 'Informe o nome do professor.';
    LblStatus.Visible := True;
    Exit;
  end;

  JBody := TJSONObject.Create;
  try
    JBody.AddPair('nome',  EditNome.Text.Trim);
    JBody.AddPair('serie', EditSerie.Text.Trim);
    JBody.AddPair('turma', EditTurma.Text.Trim);
    Body := JBody.ToJSON;
  finally
    JBody.Free;
  end;

  RectBtnCancelarClick(nil);

  if FEditandoId = 0 then
    APIPost('/professores', Body,
      procedure(const ABody, AError: string)
      begin
        if AError <> '' then begin LblStatus.Text := 'Erro: ' + AError; LblStatus.Visible := True; end
        else CarregarProfessores;
      end)
  else
    APIPut('/professores/' + IntToStr(FEditandoId), Body,
      procedure(const ABody, AError: string)
      begin
        if AError <> '' then begin LblStatus.Text := 'Erro: ' + AError; LblStatus.Visible := True; end
        else CarregarProfessores;
      end);
end;

procedure TFormCadastroProfessores.RectBtnCancelarClick(Sender: TObject);
begin
  RectOverlayEditor.Visible := False;
  EditNome.Visible  := False;
  EditSerie.Visible := False;
  EditTurma.Visible := False;
end;

end.
