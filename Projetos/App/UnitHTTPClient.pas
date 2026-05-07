unit UnitHTTPClient;

// HTTP helper para chamadas async a API Horse.
// Todas as callbacks chegam na Main Thread (TThread.Queue).
// Assinatura: procedure(const ABody, AError: string)
//   AError='' -> sucesso; ABody='' -> erro em AError

interface

uses
  System.SysUtils, System.Classes,
  System.Net.HttpClient, System.Net.URLClient,
  System.Threading;

const
  API_BASE = 'http://192.168.1.5:9000';

type
  TAPICallback = reference to procedure(const ABody, AError: string);

procedure APIGet   (const APath: string;                          ACallback: TAPICallback);
procedure APIPost  (const APath, ABody: string;                   ACallback: TAPICallback);
procedure APIPut   (const APath, ABody: string;                   ACallback: TAPICallback);
procedure APIDelete(const APath: string;                          ACallback: TAPICallback);

implementation

procedure DoRequest(const AMethod, AUrl, ABodyStr: string; ACallback: TAPICallback);
begin
  TTask.Run(
    procedure
    var
      Http   : THTTPClient;
      Resp   : IHTTPResponse;
      LBody  : TStringStream;
      LResult: string;
      LError : string;
    begin
      Http := THTTPClient.Create;
      try
        Http.ConnectionTimeout := 10000;
        Http.ResponseTimeout   := 15000;
        try
          if AMethod = 'GET' then
            Resp := Http.Get(AUrl)
          else if AMethod = 'DELETE' then
            Resp := Http.Delete(AUrl)
          else
          begin
            LBody := TStringStream.Create(ABodyStr, TEncoding.UTF8);
            try
              Http.ContentType := 'application/json';
              if AMethod = 'POST' then
                Resp := Http.Post(AUrl, LBody)
              else
                Resp := Http.Put(AUrl, LBody);
            finally
              LBody.Free;
            end;
          end;

          if Resp.StatusCode in [200, 201] then
          begin
            LResult := Resp.ContentAsString(TEncoding.UTF8);
            TThread.Queue(nil, procedure begin ACallback(LResult, ''); end);
          end
          else
          begin
            LError := 'HTTP ' + Resp.StatusCode.ToString + ': ' + Resp.ContentAsString;
            TThread.Queue(nil, procedure begin ACallback('', LError); end);
          end;
        except
          on E: Exception do
          begin
            LError := E.Message;
            TThread.Queue(nil, procedure begin ACallback('', LError); end);
          end;
        end;
      finally
        Http.Free;
      end;
    end
  );
end;

procedure APIGet(const APath: string; ACallback: TAPICallback);
begin
  DoRequest('GET', API_BASE + APath, '', ACallback);
end;

procedure APIPost(const APath, ABody: string; ACallback: TAPICallback);
begin
  DoRequest('POST', API_BASE + APath, ABody, ACallback);
end;

procedure APIPut(const APath, ABody: string; ACallback: TAPICallback);
begin
  DoRequest('PUT', API_BASE + APath, ABody, ACallback);
end;

procedure APIDelete(const APath: string; ACallback: TAPICallback);
begin
  DoRequest('DELETE', API_BASE + APath, '', ACallback);
end;

end.
