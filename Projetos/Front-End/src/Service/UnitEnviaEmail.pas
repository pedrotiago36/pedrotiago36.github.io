unit UnitEnviaEmail;

interface

uses
  SysUtils, IniFiles,
  IdSMTP, IdMessage, IdText, IdSSLOpenSSL, IdExplicitTLSClientSupport;

type
  TConfigEmail = record
    SMTPServer: string;
    SMTPPort  : Integer;
    Username  : string;
    Password  : string;
    FromName  : string;
    Subject   : string;
  end;

function CarregarConfig(const ArquivoIni: string): TConfigEmail;
function EnviarEmail(const Config: TConfigEmail; const Para, CorpoHTML: string): string;

implementation

function CarregarConfig(const ArquivoIni: string): TConfigEmail;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ArquivoIni);
  try
    Result.SMTPServer := Ini.ReadString('Email', 'SMTPServer', '');
    Result.SMTPPort   := Ini.ReadInteger('Email', 'SMTPPort',   587);
    Result.Username   := Ini.ReadString('Email', 'Username',   '');
    Result.Password   := Ini.ReadString('Email', 'Password',   '');
    Result.FromName   := Ini.ReadString('Email', 'FromName',   'Portal Batista');
    Result.Subject    := Ini.ReadString('Email', 'Subject',    'Código de Verificação');
  finally
    Ini.Free;
  end;
end;

function EnviarEmail(const Config: TConfigEmail; const Para, CorpoHTML: string): string;
var
  SMTP   : TIdSMTP;
  SSL    : TIdSSLIOHandlerSocketOpenSSL;
  Msg    : TIdMessage;
  Texto  : TIdText;
begin
  Result := '';
  SMTP := TIdSMTP.Create(nil);
  SSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Msg  := TIdMessage.Create(nil);
  try
    try
      // SSL/TLS
      SSL.SSLOptions.Method  := sslvTLSv1_2;
      SSL.SSLOptions.Mode    := sslmUnassigned;
      SMTP.IOHandler         := SSL;
      SMTP.UseTLS            := utUseExplicitTLS;

      // Servidor
      SMTP.Host     := Config.SMTPServer;
      SMTP.Port     := Config.SMTPPort;
      SMTP.Username := Config.Username;
      SMTP.Password := Config.Password;

      // Mensagem
      Msg.From.Address  := Config.Username;
      Msg.From.Name     := Config.FromName;
      Msg.Subject       := Config.Subject;
      Msg.Recipients.EMailAddresses := Para;
      Msg.ContentType := 'text/html; charset=UTF-8';

      Texto := TIdText.Create(Msg.MessageParts, nil);
      Texto.ContentType := 'text/html; charset=UTF-8';
      Texto.Body.Text   := CorpoHTML;

      SMTP.Connect;
      try
        SMTP.Send(Msg);
      finally
        SMTP.Disconnect;
      end;

      Result := 'OK';
    except
      on E: Exception do
        Result := 'ERRO: ' + E.Message;
    end;
  finally
    Msg.Free;
    SSL.Free;
    SMTP.Free;
  end;
end;

end.
