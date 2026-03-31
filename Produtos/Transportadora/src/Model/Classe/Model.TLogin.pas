unit Model.TLogin;

// =============================================================
//  Autentica o usuario contra a API REST (POST /login)
//  A senha e enviada como SHA-256 antes de trafegar na rede
// =============================================================

interface

uses
  Model.ILogin,
  Service.ApiClient,
  System.JSON,
  System.Hash,
  System.SysUtils;

type
  TLogin = class(TInterfacedObject, ILogin)
  public
    procedure Authenticate(
      const ACredentials : TLoginCredentials;
      const AOnSuccess   : TProc<string>;
      const AOnFailure   : TProc<string>
    );
  end;

function NewLogin: ILogin;

implementation

function NewLogin: ILogin;
begin
  Result := TLogin.Create;
end;

procedure TLogin.Authenticate(
  const ACredentials : TLoginCredentials;
  const AOnSuccess   : TProc<string>;
  const AOnFailure   : TProc<string>
);
var
  LAPI      : TApiClient;
  LBody     : TJSONObject;
  LResponse : string;
  LJson     : TJSONObject;
  LSucesso  : Boolean;
  LMensagem : string;
begin
  Assert(Trim(ACredentials.Username) <> '',
    'O campo Usu' + #225 + 'rio ' + #233 + ' obrigat' + #243 + 'rio.');
  Assert(Trim(ACredentials.Password) <> '',
    'O campo Senha ' + #233 + ' obrigat' + #243 + 'ria.');

  LAPI  := TApiClient.Create;
  LBody := TJSONObject.Create;
  try
    LBody.AddPair('login', ACredentials.Username);
    LBody.AddPair('senha', THashSHA2.GetHashString(ACredentials.Password));

    LResponse := LAPI.Post('/login', LBody.ToString);

    LJson := TJSONObject.ParseJSONValue(LResponse) as TJSONObject;
    if not Assigned(LJson) then
    begin
      AOnFailure('Erro de comunica' + #231 + #227 + 'o com o servidor.');
      Exit;
    end;

    try
      LSucesso  := LJson.GetValue('sucesso').Value = 'true';
      LMensagem := LJson.GetValue('mensagem').Value;
    finally
      LJson.Free;
    end;

    if LSucesso then
      AOnSuccess(LMensagem)
    else
      AOnFailure(LMensagem);

  except
    on E: Exception do
      AOnFailure('Erro ao conectar com o servidor: ' + E.Message);
  end;

  LBody.Free;
  LAPI.Free;
end;

end.
