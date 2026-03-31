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
  System.SysUtils,
  System.JSON,
  Service.ApiClient;

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

procedure TScreenActionsModel.LoadUserActions(const AUsuarioID: Integer);
var
  LClient     : TApiClient;
  LJson       : string;
  LArr        : TJSONArray;
  LItem       : TJSONValue;
  LObj        : TJSONObject;
  LTela       : string;
  LAcao       : string;
  LPermitido  : Boolean;
  LKey        : string;
  LUserActions: TDictionary<string, Boolean>;
begin
  { Remove estado anterior deste usuário }
  if FData.TryGetValue(AUsuarioID, LUserActions) then
  begin
    LUserActions.Free;
    FData.Remove(AUsuarioID);
  end;

  LClient := TApiClient.Create;
  try
    LJson := LClient.Get('/acoes/usuario/' + IntToStr(AUsuarioID));
  finally
    LClient.Free;
  end;

  LArr := TJSONObject.ParseJSONValue(LJson) as TJSONArray;
  if not Assigned(LArr) then Exit;
  try
    if LArr.Count = 0 then Exit;

    LUserActions := TDictionary<string, Boolean>.Create;
    FData.Add(AUsuarioID, LUserActions);

    for LItem in LArr do
    begin
      LObj       := LItem as TJSONObject;
      LTela      := LObj.GetValue('tela').Value;
      LAcao      := LObj.GetValue('acao').Value;
      LPermitido := LObj.GetValue('permitido').Value = '1';
      LKey       := MakeKey(LTela, LAcao);
      LUserActions.AddOrSetValue(LKey, LPermitido);
    end;
  finally
    LArr.Free;
  end;
end;

procedure TScreenActionsModel.SaveUserActions(const AUsuarioID: Integer);
var
  LClient      : TApiClient;
  LUserActions : TDictionary<string, Boolean>;
  LRoot        : TJSONObject;
  LAcoesArr    : TJSONArray;
  LItem        : TJSONObject;
  LKey         : string;
  LAllowed     : Boolean;
  LParts       : TArray<string>;
begin
  LRoot     := TJSONObject.Create;
  LAcoesArr := TJSONArray.Create;
  try
    LRoot.AddPair('usuario_id', TJSONNumber.Create(AUsuarioID));

    if FData.TryGetValue(AUsuarioID, LUserActions) then
    begin
      for LKey in LUserActions.Keys do
      begin
        LUserActions.TryGetValue(LKey, LAllowed);
        LParts := LKey.Split(['|']);
        if Length(LParts) = 2 then
        begin
          LItem := TJSONObject.Create;
          LItem.AddPair('tela',      LParts[0]);
          LItem.AddPair('acao',      LParts[1]);
          LItem.AddPair('permitido', TJSONNumber.Create(Ord(LAllowed)));
          LAcoesArr.Add(LItem);
        end;
      end;
    end;

    LRoot.AddPair('acoes', LAcoesArr);

    LClient := TApiClient.Create;
    try
      LClient.Post('/acoes/usuario', LRoot.ToString);
    finally
      LClient.Free;
    end;
  finally
    LRoot.Free;  { LAcoesArr é destruído junto com LRoot }
  end;
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
