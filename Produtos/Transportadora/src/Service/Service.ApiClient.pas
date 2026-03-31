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
  API_BASE_URL = 'http://192.168.1.5:9000';

type
  TApiClient = class
  public
    // GET  endpoint    -> retorna body como string
    function Get(const AEndpoint: string): string;
    // POST endpoint    -> envia JSON, retorna body como string
    function Post(const AEndpoint, ABody: string): string;
  end;

implementation

function TApiClient.Get(const AEndpoint: string): string;
var
  LHTTP: THTTPClient;
begin
  LHTTP := THTTPClient.Create;
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
  LHTTP   := THTTPClient.Create;
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
