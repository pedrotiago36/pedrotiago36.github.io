unit Model.TLogin;

interface

uses
  Model.ILogin,
  System.SysUtils,
  System.Generics.Collections;

type
  TLogin = class(TInterfacedObject, ILogin)
  strict private
    FUsers : TDictionary<string, string>;
    procedure ValidateCredentials(const ACredentials: TLoginCredentials);
    function  WelcomeMessage(const AUsername: string): string;
  public
    constructor Create;
    destructor  Destroy; override;
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

{ TLogin }

constructor TLogin.Create;
begin
  inherited;
  FUsers := TDictionary<string, string>.Create;
  FUsers.Add('admin',     'admin123');
  FUsers.Add('motorista', 'motor123');
  FUsers.Add('operador',  'op@2024');
end;

destructor TLogin.Destroy;
begin
  FUsers.Free;
  inherited;
end;

procedure TLogin.ValidateCredentials(const ACredentials: TLoginCredentials);
begin
  Assert(Trim(ACredentials.Username) <> '', 'O campo Usu' + #225 + 'rio ' + #233 + ' obrigat' + #243 + 'rio.');
  Assert(Trim(ACredentials.Password) <> '', 'O campo Senha ' + #233 + ' obrigat' + #243 + 'ria.');
end;

function TLogin.WelcomeMessage(const AUsername: string): string;
begin
  Result := 'Acesso autorizado. Bem-vindo, ' + AUsername + '!';
end;

procedure TLogin.Authenticate(
  const ACredentials : TLoginCredentials;
  const AOnSuccess   : TProc<string>;
  const AOnFailure   : TProc<string>
);
var
  LCallbacks     : array[Boolean] of TProc<string>;
  LMessages      : array[Boolean] of string;
  LStoredPwd     : string;
  LAuthenticated : Boolean;
begin
  ValidateCredentials(ACredentials);

  LCallbacks[False] := AOnFailure;
  LCallbacks[True]  := AOnSuccess;

  LMessages[False] := 'Usu' + #225 + 'rio ou senha incorretos. Verifique e tente novamente.';
  LMessages[True]  := WelcomeMessage(ACredentials.Username);

  LAuthenticated := FUsers.TryGetValue(ACredentials.Username, LStoredPwd)
                    and (LStoredPwd = ACredentials.Password);

  LCallbacks[LAuthenticated](LMessages[LAuthenticated]);
end;

end.
