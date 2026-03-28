unit Model.ILogin;

interface

uses
  System.SysUtils;

type
  TLoginCredentials = record
  public
    Username : string;
    Password : string;
    class function New(const AUsername, APassword: string): TLoginCredentials; static;
  end;

  ILogin = interface
    ['{3A1F9E2C-7B4D-4F8A-9C3E-1D5B8F2E6A4C}']
    procedure Authenticate(
      const ACredentials : TLoginCredentials;
      const AOnSuccess   : TProc<string>;
      const AOnFailure   : TProc<string>
    );
  end;

implementation

{ TLoginCredentials }

class function TLoginCredentials.New(const AUsername, APassword: string): TLoginCredentials;
begin
  Result.Username := AUsername;
  Result.Password := APassword;
end;

end.
