unit ServerModule;

interface

uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication,
  uIdCustomHTTPServer, uniGUITypes, IdHTTPServer, IdContext, IOUtils, Types;

type
  TUniServerModule = class(TUniGUIServerModule)
  private
    procedure HandleHTTP(ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo; var Handled: Boolean);
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars, NetEncoding, StrUtils;

// Pasta base do Front-End onde ficam os arquivos do portal
const
  BASE_FRONTEND = 'D:\Projetos Batista\GEB\Projetos\Front-End\prj\Win32\Debug\files\';

function PastaFisica(const pasta: string): string;
begin
  // pasta = 'slider' | 'segmentos' | 'diferenciais'
  Result := BASE_FRONTEND + 'portal\' + pasta + '\';
end;

{ Extrai valor de campo de um JSON simples (sem aninhamento) }
function JsonGet(const json, campo: string): string;
var
  p1, p2: Integer;
  chave: string;
begin
  Result := '';
  chave := '"' + campo + '":"';
  p1 := Pos(chave, json);
  if p1 = 0 then Exit;
  Inc(p1, Length(chave));
  p2 := p1;
  while (p2 <= Length(json)) and (json[p2] <> '"') do
    Inc(p2);
  Result := Copy(json, p1, p2 - p1);
end;

{ Lê o body inteiro de um stream }
function LerBody(stream: TStream): string;
var
  ss: TStringStream;
begin
  ss := TStringStream.Create('', TEncoding.UTF8);
  try
    stream.Position := 0;
    ss.CopyFrom(stream, stream.Size);
    Result := ss.DataString;
  finally
    ss.Free;
  end;
end;

{ Lista imagens de uma pasta e retorna JSON array }
function ListarPNGs(const pasta: string): string;
var
  dir: string;
  files: TStringDynArray;
  sb: TStringBuilder;
  f, nome, urlBase, ext: string;
begin
  dir := PastaFisica(pasta);
  sb := TStringBuilder.Create;
  try
    sb.Append('[');
    if TDirectory.Exists(dir) then
    begin
      files := TDirectory.GetFiles(dir);
      for f in files do
      begin
        nome := TPath.GetFileName(f);
        ext  := LowerCase(TPath.GetExtension(nome));
        if (ext <> '.png') and (ext <> '.jpg') and (ext <> '.jpeg') and (ext <> '.webp') then
          Continue;
        urlBase := '/files/portal/' + pasta + '/';
        if sb.Length > 1 then sb.Append(',');
        sb.Append('{"nome":"').Append(nome)
          .Append('","url":"').Append(urlBase).Append(nome).Append('"}');
      end;
    end;
    sb.Append(']');
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

procedure TUniServerModule.HandleHTTP(ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo; var Handled: Boolean);
var
  doc, body, b64, nome, pasta, filePath, ext: string;
  bytes: TBytes;
  fs: TFileStream;
  jsonFile: TStringList;
begin
  doc := ARequestInfo.Document;
  AResponseInfo.ContentType := 'application/json; charset=utf-8';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Origin']  := '*';
  AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Headers'] := 'Content-Type';

  // ── Preflight CORS ──────────────────────────────────────────────
  if ARequestInfo.Command = 'OPTIONS' then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET, POST, OPTIONS';
    Handled := True;
    Exit;
  end;

  // ── GET /files/portal/... → serve da pasta do Front-End ─────────
  if (ARequestInfo.Command = 'GET') and StartsStr('/files/portal/', doc) then
  begin
    filePath := BASE_FRONTEND + StringReplace(
      Copy(doc, Length('/files/') + 1, MaxInt), '/', '\', [rfReplaceAll]);
    if TFile.Exists(filePath) then
    begin
      ext := LowerCase(TPath.GetExtension(filePath));
      if      ext = '.png'  then AResponseInfo.ContentType := 'image/png'
      else if ext = '.jpg'  then AResponseInfo.ContentType := 'image/jpeg'
      else if ext = '.jpeg' then AResponseInfo.ContentType := 'image/jpeg'
      else if ext = '.webp' then AResponseInfo.ContentType := 'image/webp'
      else if ext = '.gif'  then AResponseInfo.ContentType := 'image/gif'
      else if ext = '.json' then AResponseInfo.ContentType := 'application/json; charset=utf-8'
      else                       AResponseInfo.ContentType := 'application/octet-stream';
      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyNone);
      AResponseInfo.FreeContentStream := True;
      Handled := True;
    end;
    Exit;
  end;

  // ── GET /listar?pasta=slider ────────────────────────────────────
  if (ARequestInfo.Command = 'GET') and StartsStr('/listar', doc) then
  begin
    pasta := ARequestInfo.Params.Values['pasta'];
    if pasta = '' then pasta := 'slider';
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentText := ListarPNGs(pasta);
    Handled := True;
    Exit;
  end;

  // ── POST /deletar  { "nome":"x.png", "pasta":"slider" } ─────────────
  if (ARequestInfo.Command = 'POST') and (doc = '/deletar') then
  begin
    try
      body  := LerBody(ARequestInfo.PostStream);
      nome  := JsonGet(body, 'nome');
      pasta := JsonGet(body, 'pasta');

      if (nome = '') or (pasta = '') then
      begin
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ContentText := '{"erro":"campos obrigatorios: nome, pasta"}';
        Handled := True;
        Exit;
      end;

      filePath := PastaFisica(pasta) + nome;

      if TFile.Exists(filePath) then
        TFile.Delete(filePath);

      // Remove JSON de metadados se existir
      if TFile.Exists(ChangeFileExt(filePath, '.json')) then
        TFile.Delete(ChangeFileExt(filePath, '.json'));

      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentText := '{"ok":true}';
    except
      on E: Exception do
      begin
        AResponseInfo.ResponseNo := 500;
        AResponseInfo.ContentText := '{"erro":"' + E.Message + '"}';
      end;
    end;
    Handled := True;
    Exit;
  end;

  // ── POST /upload  { "nome":"x.png", "pasta":"slider", "base64":"..." } ──
  if (ARequestInfo.Command = 'POST') and (doc = '/upload') then
  begin
    try
      body  := LerBody(ARequestInfo.PostStream);
      nome  := JsonGet(body, 'nome');
      pasta := JsonGet(body, 'pasta');
      b64   := JsonGet(body, 'base64');

      // Remove prefixo data:image/...;base64,
      if Pos(',', b64) > 0 then
        b64 := Copy(b64, Pos(',', b64) + 1, MaxInt);

      if (nome = '') or (pasta = '') or (b64 = '') then
      begin
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ContentText := '{"erro":"campos obrigatorios: nome, pasta, base64"}';
        Handled := True;
        Exit;
      end;

      filePath := PastaFisica(pasta) + nome;

      if not TDirectory.Exists(PastaFisica(pasta)) then
        TDirectory.CreateDirectory(PastaFisica(pasta));

      bytes := TNetEncoding.Base64.DecodeStringToBytes(b64);
      fs := TFileStream.Create(filePath, fmCreate);
      try
        fs.Write(bytes[0], Length(bytes));
      finally
        fs.Free;
      end;

      // Cria JSON de metadados vazio ao lado da imagem
      jsonFile := TStringList.Create;
      try
        jsonFile.Text := '{}';
        jsonFile.SaveToFile(ChangeFileExt(filePath, '.json'), TEncoding.UTF8);
      finally
        jsonFile.Free;
      end;

      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentText := '{"ok":true,"arquivo":"' + nome + '"}';
    except
      on E: Exception do
      begin
        AResponseInfo.ResponseNo := 500;
        AResponseInfo.ContentText := '{"erro":"' + E.Message + '"}';
      end;
    end;
    Handled := True;
    Exit;
  end;
end;

function UniServerModule: TUniServerModule;
begin
  Result := TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
  OnHTTPCommand := HandleHTTP;
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.
