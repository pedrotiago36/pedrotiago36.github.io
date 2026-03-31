unit Service.ApiClient;

// =============================================================
//  Wrapper HTTP para comunicacao com a API REST (Horse/Delphi)
//  Porta: 9000 | Banco: dtll_Transportadora
//  Usa THTTPClient (System.Net.HttpClient — Delphi XE8+)
// =============================================================

interface

uses
  System.Net.HttpClient,
  System.Net.URLClient,
  System.Classes,
  System.SysUtils;

const
  API_BASE_URL = 'http://127.0.0.1:9000';

type
  TApiClient = class
  public
    // GET  endpoint    -> retorna body como string
    function Get(const AEndpoint: string): string;
    // POST endpoint    -> envia JSON, retorna body como string
    function Post(const AEndpoint, ABody: string): string;
  end;

implementation

function NewHTTP: THTTPClient;
begin
  Result := THTTPClient.Create;
  // Bypass proxy para conexoes localhost (evita erro 12029 no WinInet)
  Result.ProxySettings := TProxySettings.Create('', 0, '', '', '127.0.0.1,localhost');
end;

function TApiClient.Get(const AEndpoint: string): string;
var
  LHTTP: THTTPClient;
begin
  LHTTP := NewHTTP;
  try
    Result := LHTTP.Get(API_BASE_URL + AEndpoint).ContentAsString(TEncoding.UTF8);
  finally
    LHTTP.Free;
  end;
end;

function TApiClient.Post(const AEndpoint, ABody: string): string;
var
  LHTTP    : THTTPClient;
  LStream  : TStringStream;
  LHeaders : TNetHeaders;
begin
  LHTTP   := NewHTTP;
  LStream := TStringStream.Create(ABody, TEncoding.UTF8);
  try
    SetLength(LHeaders, 1);
    LHeaders[0] := TNameValuePair.Create('Content-Type', 'application/json');
    Result := LHTTP.Post(API_BASE_URL + AEndpoint, LStream, nil, LHeaders)
                   .ContentAsString(TEncoding.UTF8);
  finally
    LStream.Free;
    LHTTP.Free;
  end;
end;

end.
