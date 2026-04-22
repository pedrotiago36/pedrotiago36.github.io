unit UnitEnviaEmail;

interface

uses
  System.SysUtils, System.IniFiles, Vcl.Forms,
  IdSMTP, IdSSLOpenSSL, IdMessage, IdText, IdSSLOpenSSLHeaders;

type
  TConfigEmail = record
    SMTPServer: string;
    SMTPPort: Integer;
    Username: string;
    Password: string;
    FromName: string;
    Subject: string;
  end;

function CarregarConfig(const ArquivoIni: string): TConfigEmail;
function EnviarEmail(const Config: TConfigEmail; Para, CorpoHTML: string): string;

implementation

uses
  IdExplicitTLSClientServerBase;

function CarregarConfig(const ArquivoIni: string): TConfigEmail;
var
  Ini: TIniFile;
  CaminhoCompleto: string;
begin
  CaminhoCompleto := ExtractFilePath(Application.ExeName) + ArquivoIni;

  if not FileExists(CaminhoCompleto) then
    raise Exception.Create('Arquivo ' + CaminhoCompleto + ' não encontrado!');

  Ini := TIniFile.Create(CaminhoCompleto);
  try
    Result.SMTPServer := Ini.ReadString('EmailConfig', 'SMTPServer', 'smtp.gmail.com');
    Result.SMTPPort := Ini.ReadInteger('EmailConfig', 'SMTPPort', 587);
    Result.Username := Ini.ReadString('EmailConfig', 'Username', '');
    Result.Password := Ini.ReadString('EmailConfig', 'Password', '');
    Result.FromName := Ini.ReadString('EmailConfig', 'FromName', 'Meu App');
    Result.Subject := Ini.ReadString('EmailConfig', 'Subject', 'Mensagem Automática');
  finally
    Ini.Free;
  end;
end;

function EnviarEmail(const Config: TConfigEmail; Para, CorpoHTML: string): string;
var
  SMTP: TIdSMTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Msg: TIdMessage;
  TextBody: TIdText;
begin
  Result := '';
  SMTP := TIdSMTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Msg := TIdMessage.Create(nil);

  try
    SSLHandler.SSLOptions.Method := sslvTLSv1_2;
    SSLHandler.SSLOptions.Mode := sslmUnassigned;

    SMTP.IOHandler := SSLHandler;
    SMTP.Host := Config.SMTPServer;
    SMTP.Port := Config.SMTPPort;
    SMTP.Username := Config.Username;
    SMTP.Password := Config.Password;
    SMTP.UseTLS := utUseExplicitTLS;

    Msg.From.Name := Config.FromName;
    Msg.From.Address := Config.Username;
    Msg.Recipients.EMailAddresses := Para;
    Msg.Subject := Config.Subject;
    Msg.ContentType := 'text/html';

    TextBody := TIdText.Create(Msg.MessageParts);
    TextBody.ContentType := 'text/html';
    TextBody.Body.Text := CorpoHTML;

    SMTP.Connect;
    SMTP.Authenticate;
    SMTP.Send(Msg);

    if SMTP.Connected then
      SMTP.Disconnect;

    Result := 'E-mail enviado com sucesso!';
  except
    on E: Exception do
      Result := 'Erro: ' + E.Message;
  end;

  FreeAndNil(TextBody);
  FreeAndNil(Msg);
  FreeAndNil(SSLHandler);
  FreeAndNil(SMTP);
end;

end.
