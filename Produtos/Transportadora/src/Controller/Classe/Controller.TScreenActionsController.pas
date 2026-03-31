unit Controller.TScreenActionsController;

interface

uses
  Controller.IScreenActionsController,
  Model.IScreenActions,
  Model.IUsuario;

type
  TScreenActionsController = class(TInterfacedObject, IScreenActionsController)
  private
    FModel: IScreenActionsModel;
    FUsuarioModel: IUsuarioModel;
    FView: IScreenActionsView;
    FSelectedUserID: Integer;
  public
    constructor Create(const AModel: IScreenActionsModel; const AUsuarioModel: IUsuarioModel);
    procedure BindView(const AView: IScreenActionsView);
    procedure LoadList;
    procedure SelectUser(const AUsuarioID: Integer);
    procedure ToggleAction(const AUsuarioID: Integer; const ARoute, AActionKey: string);
  end;

function NewScreenActionsController(const AModel: IScreenActionsModel;
  const AUsuarioModel: IUsuarioModel): IScreenActionsController;

implementation

function NewScreenActionsController(const AModel: IScreenActionsModel;
  const AUsuarioModel: IUsuarioModel): IScreenActionsController;
begin
  Result := TScreenActionsController.Create(AModel, AUsuarioModel);
end;

constructor TScreenActionsController.Create(const AModel: IScreenActionsModel;
  const AUsuarioModel: IUsuarioModel);
begin
  inherited Create;
  FModel := AModel;
  FUsuarioModel := AUsuarioModel;
  FSelectedUserID := 0;
end;

procedure TScreenActionsController.BindView(const AView: IScreenActionsView);
begin
  FView := AView;
end;

procedure TScreenActionsController.LoadList;
var
  LScreens: TArray<string>;
  LUsers: TArray<TUsuarioRec>;
  LUsersStr: TArray<string>;
  I: Integer;
begin
  if not Assigned(FView) then Exit;

  LScreens := FModel.GetAllScreens;
  LUsers := FUsuarioModel.ListAll;

  SetLength(LUsersStr, Length(LUsers));
  for I := 0 to High(LUsers) do
    LUsersStr[I] := LUsers[I].Login;

  { Seleciona primeiro usuário por padrão }
  FSelectedUserID := 0;
  if Length(LUsers) > 0 then
    FSelectedUserID := LUsers[0].ID;

  FView.ShowScreenActions(LScreens, LUsersStr, FSelectedUserID);
end;

procedure TScreenActionsController.SelectUser(const AUsuarioID: Integer);
begin
  FSelectedUserID := AUsuarioID;
  { Re-render da view com novo usuário selecionado }
  LoadList;
end;

procedure TScreenActionsController.ToggleAction(const AUsuarioID: Integer;
  const ARoute, AActionKey: string);
begin
  FModel.ToggleAction(AUsuarioID, ARoute, AActionKey);
  { Re-render após toggle }
  LoadList;
end;

end.
