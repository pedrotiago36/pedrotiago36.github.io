unit Model.TPerfil;

// =============================================================
//  CRUD de perfis via API REST
//  GET  /perfis              -> ListAll  (inclui permissoes)
//  GET  /perfis/:id          -> FindByID (inclui permissoes)
//  POST /crud (INSERT)       -> Insert perfil + salva permissoes
//  POST /crud (UPDATE)       -> Update perfil + salva permissoes
//  POST /crud (DELETE)       -> Delete logico (ativo=0)
// =============================================================

interface

uses
  Model.IPerfil,
  Service.ApiClient,
  System.JSON,
  System.SysUtils;

type
  TPerfilAPI = class(TInterfacedObject, IPerfilModel)
  private
    FAPI: TApiClient;
    function  ParseRec(const AJson: TJSONObject): TPerfilRec;
    procedure SalvarPermissoes(const APerfilID: Integer;
                               const APerms: TArray<string>);
  public
    constructor Create;
    destructor  Destroy; override;
    function  ListAll  : TArray<TPerfilRec>;
    function  FindByID (const AID: Integer): TPerfilRec;
    procedure Insert   (const ARec: TPerfilRec);
    procedure Update   (const ARec: TPerfilRec);
    procedure Delete   (const AID: Integer);
    function  NextID   : Integer;
  end;

function NewPerfilModel: IPerfilModel;

implementation

function NewPerfilModel: IPerfilModel;
begin
  Result := TPerfilAPI.Create;
end;

constructor TPerfilAPI.Create;
begin
  inherited;
  FAPI := TApiClient.Create;
end;

destructor TPerfilAPI.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TPerfilAPI.ParseRec(const AJson: TJSONObject): TPerfilRec;
var
  LPermsArr : TJSONArray;
  LI        : Integer;
begin
  Result.ID   := StrToIntDef(AJson.GetValue('id').Value,   -1);
  Result.Nome := AJson.GetValue('nome').Value;
  SetLength(Result.Permissoes, 0);
  LPermsArr := AJson.GetValue('permissoes') as TJSONArray;
  if Assigned(LPermsArr) then
  begin
    SetLength(Result.Permissoes, LPermsArr.Count);
    for LI := 0 to LPermsArr.Count - 1 do
      Result.Permissoes[LI] := LPermsArr.Items[LI].Value;
  end;
end;

procedure TPerfilAPI.SalvarPermissoes(const APerfilID: Integer;
                                      const APerms: TArray<string>);
var
  LRoot  : TJSONObject;
  LDados : TJSONObject;
  LRotas : TJSONArray;
  LI     : Integer;
  LBody  : string;
begin
  LRoot  := TJSONObject.Create;
  LDados := TJSONObject.Create;
  LRotas := TJSONArray.Create;
  try
    for LI := 0 to Length(APerms) - 1 do
      LRotas.Add(APerms[LI]);

    LDados.AddPair('perfil_id', TJSONNumber.Create(APerfilID));
    LDados.AddPair('rotas',     LRotas);   // LDados toma ownership

    LRoot.AddPair('tabela', 'tb_permissoes_perfis');
    LRoot.AddPair('acao',   'INSERT');
    LRoot.AddPair('dados',  LDados);       // LRoot toma ownership

    LBody := LRoot.ToString;
  finally
    LRoot.Free;
  end;
  FAPI.Post('/crud', LBody);
end;

function TPerfilAPI.ListAll: TArray<TPerfilRec>;
var
  LResponse : string;
  LArr      : TJSONArray;
  LI        : Integer;
begin
  SetLength(Result, 0);
  try
    LResponse := FAPI.Get('/perfis');
    LArr := TJSONObject.ParseJSONValue(LResponse) as TJSONArray;
    if not Assigned(LArr) then Exit;
    try
      SetLength(Result, LArr.Count);
      for LI := 0 to LArr.Count - 1 do
        Result[LI] := ParseRec(LArr.Items[LI] as TJSONObject);
    finally
      LArr.Free;
    end;
  except
    SetLength(Result, 0);
  end;
end;

function TPerfilAPI.FindByID(const AID: Integer): TPerfilRec;
var
  LResponse : string;
  LJson     : TJSONObject;
begin
  Result.ID         := -1;
  Result.Nome       := '';
  SetLength(Result.Permissoes, 0);
  try
    LResponse := FAPI.Get('/perfis/' + IntToStr(AID));
    LJson := TJSONObject.ParseJSONValue(LResponse) as TJSONObject;
    if Assigned(LJson) then
    try
      if StrToIntDef(LJson.GetValue('id').Value, -1) > 0 then
        Result := ParseRec(LJson);
    finally
      LJson.Free;
    end;
  except
  end;
end;

procedure TPerfilAPI.Insert(const ARec: TPerfilRec);
var
  LRoot    : TJSONObject;
  LDados   : TJSONObject;
  LBody    : string;
  LResp    : TJSONObject;
  LNovoID  : Integer;
begin
  // 1. Insere o perfil e captura o novo ID (auto-increment)
  LRoot  := TJSONObject.Create;
  LDados := TJSONObject.Create;
  try
    LDados.AddPair('nome', ARec.Nome);
    LRoot.AddPair('tabela', 'tb_perfis');
    LRoot.AddPair('acao',   'INSERT');
    LRoot.AddPair('dados',  LDados);
    LBody := LRoot.ToString;
  finally
    LRoot.Free;
  end;

  LNovoID := 0;
  try
    LResp := TJSONObject.ParseJSONValue(FAPI.Post('/crud', LBody)) as TJSONObject;
    if Assigned(LResp) then
    try
      LNovoID := StrToIntDef(LResp.GetValue('ultimo_id').Value, 0);
    finally
      LResp.Free;
    end;
  except
  end;

  // 2. Salva as permissoes do perfil recem-criado
  if LNovoID > 0 then
    SalvarPermissoes(LNovoID, ARec.Permissoes);
end;

procedure TPerfilAPI.Update(const ARec: TPerfilRec);
var
  LRoot  : TJSONObject;
  LDados : TJSONObject;
  LBody  : string;
begin
  // 1. Atualiza o perfil
  LRoot  := TJSONObject.Create;
  LDados := TJSONObject.Create;
  try
    LDados.AddPair('id',   TJSONNumber.Create(ARec.ID));
    LDados.AddPair('nome', ARec.Nome);
    LRoot.AddPair('tabela', 'tb_perfis');
    LRoot.AddPair('acao',   'UPDATE');
    LRoot.AddPair('dados',  LDados);
    LBody := LRoot.ToString;
  finally
    LRoot.Free;
  end;
  FAPI.Post('/crud', LBody);

  // 2. Substitui todas as permissoes do perfil
  SalvarPermissoes(ARec.ID, ARec.Permissoes);
end;

procedure TPerfilAPI.Delete(const AID: Integer);
var
  LRoot  : TJSONObject;
  LDados : TJSONObject;
  LBody  : string;
begin
  LRoot  := TJSONObject.Create;
  LDados := TJSONObject.Create;
  try
    LDados.AddPair('id', TJSONNumber.Create(AID));
    LRoot.AddPair('tabela', 'tb_perfis');
    LRoot.AddPair('acao',   'DELETE');
    LRoot.AddPair('dados',  LDados);
    LBody := LRoot.ToString;
  finally
    LRoot.Free;
  end;
  FAPI.Post('/crud', LBody);
end;

function TPerfilAPI.NextID: Integer;
begin
  Result := 0;  // ID gerado pelo auto-increment do banco
end;

end.
