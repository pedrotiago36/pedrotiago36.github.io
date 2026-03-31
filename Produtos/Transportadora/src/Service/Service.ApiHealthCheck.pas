unit Service.ApiHealthCheck;

{ Thread leve que verifica a disponibilidade da API REST.
  Faz GET /ping com timeout de 2 s e expõe o resultado em IsOnline.
  Uso:
    LThread := TApiHealthThread.Create(API_BASE_URL);
    LThread.Start;
    LThread.WaitFor;   // retorna em até ~2 s (timeout HTTP)
    LOnline := LThread.IsOnline;
    LThread.Free; }

interface

uses
  System.Classes,
  System.Net.HttpClient,
  System.Net.URLClient;

type
  TApiHealthThread = class(TThread)
  private
    FBaseURL  : string;
    FIsOnline : Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const ABaseURL: string);
    property IsOnline: Boolean read FIsOnline;
  end;

implementation

uses
  System.SysUtils;

constructor TApiHealthThread.Create(const ABaseURL: string);
begin
  inherited Create(True);   { começa suspenso — caller chama Start }
  FBaseURL        := ABaseURL;
  FIsOnline       := False;
  FreeOnTerminate := False;
end;

procedure TApiHealthThread.Execute;
var
  LHTTP : THTTPClient;
  LResp : IHTTPResponse;
begin
  try
    LHTTP := THTTPClient.Create;
    try
      LHTTP.ConnectionTimeout := 2000;
      LHTTP.ResponseTimeout   := 2000;
      { Bypass proxy para localhost — evita erro 12029 no WinInet }
      LHTTP.ProxySettings := TProxySettings.Create('', 0, '', '', '127.0.0.1,localhost');
      LResp     := LHTTP.Get(FBaseURL + '/ping');
      FIsOnline := Assigned(LResp) and (LResp.StatusCode = 200);
    finally
      LHTTP.Free;
    end;
  except
    FIsOnline := False;
  end;
end;

end.
