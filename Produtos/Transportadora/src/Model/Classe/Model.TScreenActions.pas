unit Model.TScreenActions;

interface

uses
  System.Generics.Collections,
  Model.IScreenActions;

type
  TScreenActionsModel = class(TInterfacedObject, IScreenActionsModel)
  private
    { FData[UsuarioID][Route+ActionKey] = Allowed }
    FData: TDictionary<Integer, TDictionary<string, Boolean>>;
    FScreens: TDictionary<string, TArray<string>>; { tela → [actionKey1, actionKey2, ...] }
    procedure Seed;
    function MakeKey(const ARoute, AActionKey: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    function  GetActionsByScreen(const ARoute: string): TArray<TScreenActionRec>;
    function  IsActionAllowed(const AUsuarioID: Integer; const ARoute, AActionKey: string): Boolean;
    procedure ToggleAction(const AUsuarioID: Integer; const ARoute, AActionKey: string);
    function  GetAllScreens: TArray<string>;
  end;

function NewScreenActionsModel: IScreenActionsModel;

implementation

uses
  System.SysUtils;

function NewScreenActionsModel: IScreenActionsModel;
begin
  Result := TScreenActionsModel.Create;
end;

constructor TScreenActionsModel.Create;
begin
  inherited Create;
  FData := TDictionary<Integer, TDictionary<string, Boolean>>.Create;
  FScreens := TDictionary<string, TArray<string>>.Create;
  Seed;
end;

destructor TScreenActionsModel.Destroy;
var
  D: TDictionary<string, Boolean>;
begin
  for D in FData.Values do
    D.Free;
  FData.Free;
  FScreens.Free;
  inherited;
end;

procedure TScreenActionsModel.Seed;
  { Open array — compatível com qualquer versão do Delphi (XE e anteriores) }
  procedure AddScreen(const ARoute: string; const AActions: array of string);
  var
    LArr : TArray<string>;
    I    : Integer;
  begin
    SetLength(LArr, Length(AActions));
    for I := 0 to High(AActions) do
      LArr[I] := AActions[I];
    FScreens.Add(ARoute, LArr);
  end;
begin
  AddScreen('cfg.perfil',     ['insert', 'edit', 'delete', 'save', 'cancel']);
  AddScreen('cfg.usuario',    ['insert', 'edit', 'delete', 'save', 'cancel']);
  AddScreen('cfg.permissoes', ['save', 'cancel']);
  AddScreen('cfg.acoes',      ['save', 'cancel']);
  AddScreen('cad.clientes',   ['insert', 'edit', 'delete', 'save', 'cancel']);
  AddScreen('cad.motoristas', ['insert', 'edit', 'delete', 'save', 'cancel']);
  AddScreen('cad.veiculos',   ['insert', 'edit', 'delete', 'save', 'cancel']);
end;

function TScreenActionsModel.MakeKey(const ARoute, AActionKey: string): string;
begin
  Result := ARoute + '|' + AActionKey;
end;

function TScreenActionsModel.IsActionAllowed(const AUsuarioID: Integer; const ARoute,
  AActionKey: string): Boolean;
var
  LKey: string;
  LUserActions: TDictionary<string, Boolean>;
  LExists: Boolean;
begin
  LKey := MakeKey(ARoute, AActionKey);

  { Se usuario nao existe, retorna True (allow all) }
  if not FData.TryGetValue(AUsuarioID, LUserActions) then
    Result := True
  else
    { Se acao nao existe no dicionario, retorna True }
    if not LUserActions.TryGetValue(LKey, Result) then
      Result := True;
end;

function TScreenActionsModel.GetActionsByScreen(const ARoute: string): TArray<TScreenActionRec>;
var
  LActions: TArray<string>;
  LAction: string;
  I: Integer;
begin
  SetLength(Result, 0);

  { Se tela nao existe, retorna vazio }
  if not FScreens.TryGetValue(ARoute, LActions) then
    Exit;

  SetLength(Result, Length(LActions));
  for I := 0 to High(LActions) do
  begin
    LAction := LActions[I];
    Result[I].Route := ARoute;
    Result[I].ActionKey := LAction;
    Result[I].Allowed := IsActionAllowed(0, ARoute, LAction); { User 0 for default }
  end;
end;

procedure TScreenActionsModel.ToggleAction(const AUsuarioID: Integer; const ARoute,
  AActionKey: string);
var
  LKey: string;
  LUserActions: TDictionary<string, Boolean>;
  LAllowed: Boolean;
begin
  LKey := MakeKey(ARoute, AActionKey);

  { Cria dict do usuario se nao existe }
  if not FData.TryGetValue(AUsuarioID, LUserActions) then
  begin
    LUserActions := TDictionary<string, Boolean>.Create;
    FData.Add(AUsuarioID, LUserActions);
  end;

  { Toggle: se existe, inverte; senao, cria como True }
  if LUserActions.TryGetValue(LKey, LAllowed) then
    LUserActions.AddOrSetValue(LKey, not LAllowed)
  else
    LUserActions.Add(LKey, True);
end;

function TScreenActionsModel.GetAllScreens: TArray<string>;
var
  LKeys: TArray<string>;
  I: Integer;
begin
  LKeys := FScreens.Keys.ToArray;
  SetLength(Result, Length(LKeys));
  for I := 0 to High(LKeys) do
    Result[I] := LKeys[I];
end;

end.
