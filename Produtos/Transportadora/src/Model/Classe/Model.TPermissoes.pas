unit Model.TPermissoes;

// =============================================================
//  Permissoes de usuario via API REST
//  GET  /permissoes/usuario/:id  -> FindByUsuario
//  POST /crud (INSERT)           -> Save (substitui todas do usuario)
// =============================================================

interface

uses
  Model.IPermissoes,
  Service.ApiClient,
  System.JSON,
  System.SysUtils;

type
  TPermissoesAPI = class(TInterfacedObject, IPermissoesModel)
  private
    FAPI: TApiClient;
  public
    constructor Create;
    destructor  Destroy; override;
    function  FindByUsuario  (const AUsuarioID: Integer): TPermissoesRec;
    procedure Save           (const ARec: TPermissoesRec);
    procedure SaveWithPerfil (const AUsuarioID, APerfilID: Integer);
  end;

function NewPermissoesModel: IPermissoesModel;

implementation

function NewPermissoesModel: IPermissoesModel;
begin
  Result := TPermissoesAPI.Create;
end;

constructor TPermissoesAPI.Create;
begin
  inherited;
  FAPI := TApiClient.Create;
end;

destructor TPermissoesAPI.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TPermissoesAPI.FindByUsuario(const AUsuarioID: Integer): TPermissoesRec;
var
  LResponse : string;
  LJson     : TJSONObject;
  LRotas    : TJSONArray;
  LVal      : TJSONValue;
  LI        : Integer;
begin
  Result.UsuarioID := AUsuarioID;
  Result.PerfilID  := 0;
  SetLength(Result.Permissoes, 0);
  if AUsuarioID = 0 then Exit;
  try
    { Busca perfil_id atual do usuario }
    LResponse := FAPI.Get('/usuarios/' + IntToStr(AUsuarioID));
    LJson := TJSONObject.ParseJSONValue(LResponse) as TJSONObject;
    if Assigned(LJson) then
    begin
      try
        LVal := LJson.GetValue('perfil_id');
        if Assigned(LVal) then
          Result.PerfilID := StrToIntDef(LVal.Value, 0);
      finally
        LJson.Free;
      end;
    end;

    { Busca rotas efetivas (UNION individual + perfil) para marcar os checkboxes corretamente }
    LResponse := FAPI.Get('/permissoes/usuario/' + IntToStr(AUsuarioID));
    LJson := TJSONObject.ParseJSONValue(LResponse) as TJSONObject;
    if not Assigned(LJson) then Exit;
    try
      LRotas := LJson.GetValue('rotas') as TJSONArray;
      if Assigned(LRotas) then
      begin
        SetLength(Result.Permissoes, LRotas.Count);
        for LI := 0 to LRotas.Count - 1 do
          Result.Permissoes[LI] := LRotas.Items[LI].Value;
      end;
    finally
      LJson.Free;
    end;
  except
    SetLength(Result.Permissoes, 0);
  end;
end;

procedure TPermissoesAPI.Save(const ARec: TPermissoesRec);
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
    for LI := 0 to Length(ARec.Permissoes) - 1 do
      LRotas.Add(ARec.Permissoes[LI]);

    LDados.AddPair('usuario_id', TJSONNumber.Create(ARec.UsuarioID));
    LDados.AddPair('rotas',      LRotas);   // LDados toma ownership de LRotas

    LRoot.AddPair('tabela', 'tb_permissoes_usuarios');
    LRoot.AddPair('acao',   'INSERT');
    LRoot.AddPair('dados',  LDados);        // LRoot toma ownership de LDados

    LBody := LRoot.ToString;
  finally
    LRoot.Free;
  end;
  FAPI.Post('/crud', LBody);
end;

procedure TPermissoesAPI.SaveWithPerfil(const AUsuarioID, APerfilID: Integer);
var
  LBody : TJSONObject;
begin
  LBody := TJSONObject.Create;
  try
    LBody.AddPair('usuario_id', TJSONNumber.Create(AUsuarioID));
    LBody.AddPair('perfil_id',  TJSONNumber.Create(APerfilID));
    FAPI.Post('/permissoes/usuario/perfil', LBody.ToString);
  finally
    LBody.Free;
  end;
end;

end.
