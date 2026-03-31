unit Model.TUsuario;

// =============================================================
//  CRUD de usuarios via API REST
//  GET  /usuarios          -> ListAll
//  GET  /usuarios/:id      -> FindByID
//  POST /crud (INSERT)     -> Insert   (senha hasheada SHA-256)
//  POST /crud (UPDATE)     -> Update   (senha hasheada se preenchida)
//  POST /crud (DELETE)     -> Delete   (logico — ativo=0)
// =============================================================

interface

uses
  Model.IUsuario,
  Service.ApiClient,
  System.JSON,
  System.SysUtils;

type
  TUsuarioAPI = class(TInterfacedObject, IUsuarioModel)
  private
    FAPI: TApiClient;
    function ParseRec(const AJson: TJSONObject): TUsuarioRec;
    function BuildCrudBody(const ATabela, AAcao: string;
                           const ADados: TJSONObject): string;
  public
    constructor Create;
    destructor  Destroy; override;
    function  ListAll  : TArray<TUsuarioRec>;
    function  FindByID (const AID: Integer): TUsuarioRec;
    procedure Insert   (const ARec: TUsuarioRec);
    procedure Update   (const ARec: TUsuarioRec);
    procedure Delete   (const AID: Integer);
    function  NextID   : Integer;
  end;

function NewUsuarioModel: IUsuarioModel;

implementation

uses
  System.Hash;

function NewUsuarioModel: IUsuarioModel;
begin
  Result := TUsuarioAPI.Create;
end;

constructor TUsuarioAPI.Create;
begin
  inherited;
  FAPI := TApiClient.Create;
end;

destructor TUsuarioAPI.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TUsuarioAPI.ParseRec(const AJson: TJSONObject): TUsuarioRec;
begin
  Result.ID       := StrToIntDef(AJson.GetValue('id').Value,       -1);
  Result.Login    := AJson.GetValue('login').Value;
  Result.Senha    := '';  // hash nao e retornado pela API
  Result.IsAdmin  := AJson.GetValue('is_admin').Value = '1';
  Result.PerfilID := StrToIntDef(AJson.GetValue('perfil_id').Value, 0);
end;

function TUsuarioAPI.BuildCrudBody(const ATabela, AAcao: string;
                                   const ADados: TJSONObject): string;
var
  LRoot: TJSONObject;
begin
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('tabela', ATabela);
    LRoot.AddPair('acao',   AAcao);
    LRoot.AddPair('dados',  ADados);  // LRoot toma ownership de ADados
    Result := LRoot.ToString;
  finally
    LRoot.Free;
  end;
end;

function TUsuarioAPI.ListAll: TArray<TUsuarioRec>;
var
  LResponse : string;
  LArr      : TJSONArray;
  LI        : Integer;
begin
  SetLength(Result, 0);
  try
    LResponse := FAPI.Get('/usuarios');
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

function TUsuarioAPI.FindByID(const AID: Integer): TUsuarioRec;
var
  LResponse : string;
  LJson     : TJSONObject;
begin
  Result.ID      := -1;
  Result.Login   := '';
  Result.Senha   := '';
  Result.IsAdmin := False;
  Result.PerfilID:= 0;
  try
    LResponse := FAPI.Get('/usuarios/' + IntToStr(AID));
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

procedure TUsuarioAPI.Insert(const ARec: TUsuarioRec);
var
  LDados: TJSONObject;
begin
  LDados := TJSONObject.Create;
  LDados.AddPair('login',     ARec.Login);
  LDados.AddPair('senha',     THashSHA2.GetHashString(ARec.Senha));
  LDados.AddPair('is_admin',  TJSONNumber.Create(Ord(ARec.IsAdmin)));
  LDados.AddPair('perfil_id', TJSONNumber.Create(ARec.PerfilID));
  // BuildCrudBody toma ownership de LDados
  FAPI.Post('/crud', BuildCrudBody('tb_usuarios', 'INSERT', LDados));
end;

procedure TUsuarioAPI.Update(const ARec: TUsuarioRec);
var
  LDados : TJSONObject;
  LSenha : string;
begin
  // Se o usuario nao informou nova senha, envia vazio — SP mantem a existente
  if Trim(ARec.Senha) <> '' then
    LSenha := THashSHA2.GetHashString(ARec.Senha)
  else
    LSenha := '';

  LDados := TJSONObject.Create;
  LDados.AddPair('id',        TJSONNumber.Create(ARec.ID));
  LDados.AddPair('login',     ARec.Login);
  LDados.AddPair('senha',     LSenha);
  LDados.AddPair('is_admin',  TJSONNumber.Create(Ord(ARec.IsAdmin)));
  LDados.AddPair('perfil_id', TJSONNumber.Create(ARec.PerfilID));
  FAPI.Post('/crud', BuildCrudBody('tb_usuarios', 'UPDATE', LDados));
end;

procedure TUsuarioAPI.Delete(const AID: Integer);
var
  LDados: TJSONObject;
begin
  LDados := TJSONObject.Create;
  LDados.AddPair('id', TJSONNumber.Create(AID));
  FAPI.Post('/crud', BuildCrudBody('tb_usuarios', 'DELETE', LDados));
end;

function TUsuarioAPI.NextID: Integer;
begin
  Result := 0;  // ID gerado pelo auto-increment do banco
end;

end.
