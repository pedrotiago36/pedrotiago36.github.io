unit uPortaBatista;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm,
  uniHTMLFrame,
  System.StrUtils,
  System.IOUtils,
  System.NetEncoding,
  Controller.IPortal,
  Controller.TPortal,
  Model.IAgendamento,
  Model.TAgendamento, uniGUIBaseClasses, uniPanel;

type
  TMainForm = class(TUniForm)
    HTMLPortal: TUniHTMLFrame;
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    FController  : IPortalController;
    FLGPDCodigo  : string;
    procedure ConfigurarBridge;
    procedure ProcessarPreMatricula(const Params: TUniStrings);
    procedure ProcessarEntradaPai(const Params: TUniStrings);
    procedure ProcessarUploadContrato(const Params: TUniStrings);
    procedure ProcessarDownloadContrato(const Params: TUniStrings);
    procedure ProcessarDownloadContratoAssinado(const Params: TUniStrings);
    procedure ProcessarConsultarStatus(const Params: TUniStrings);
    procedure ProcessarCadastrarNovato(const Params: TUniStrings);
    procedure ProcessarListarPasta(const Params: TUniStrings);
    procedure ProcessarEnviarCodigoLGPD(const Params: TUniStrings);
    procedure ProcessarVerificarCodigoLGPD(const Params: TUniStrings);
  public
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication,
  UnitEnviaEmail;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.UniFormCreate(Sender: TObject);
begin
  FController := TPortalController.Create;

  // Carrega via iframe — timestamp evita cache do browser
  HTMLPortal.HTML.Text :=
    '<iframe src="/files/portal.html?v=' + FormatDateTime('yyyymmddhhnnss', Now) + '" ' +
    'style="width:100%;height:100%;border:none;display:block;" ' +
    'allowtransparency="true"></iframe>';

  ConfigurarBridge;
end;

procedure TMainForm.ConfigurarBridge;
begin
  UniSession.AddJS(
    'Ext.onReady(function() {' +
    '  var byId  = Ext.ComponentQuery.query("[id*=HTMLPortal]")[0];' +
    '  var todos = Ext.ComponentQuery.query("*");' +
    '  window._uniFormRef = byId || todos[todos.length - 1] || null;' +
    '});' +

    'window.enviarPreMatricula = function(cpf, data) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "RegistrarMatricula", ["cpf=" + cpf, "data=" + data]);' +
    '};' +

    'window.cadastrarPai = function(cpf) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "EntradaPai", ["cpf=" + cpf]);' +
    '};' +

    'window.uploadContrato = function(cpf, base64, nome) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "UploadContrato", ["cpf=" + cpf, "base64=" + encodeURIComponent(base64), "nome=" + encodeURIComponent(nome)]);' +
    '};' +

    'window.downloadContrato = function(cpf) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "DownloadContrato", ["cpf=" + cpf]);' +
    '};' +

    'window.downloadContratoAssinado = function(cpf) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "DownloadContratoAssinado", ["cpf=" + cpf]);' +
    '};' +

    'window.consultarStatus = function(cpf) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "ConsultarStatus", ["cpf=" + cpf]);' +
    '};' +

    'window.listarPasta = function(pasta) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "ListarPasta", ["pasta=" + pasta]);' +
    '};' +

    'window.cadastrarNovato = function(nome, sobrenome, email, tel) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "CadastrarNovato", [' +
    '    "nome=" + encodeURIComponent(nome),' +
    '    "sobrenome=" + encodeURIComponent(sobrenome),' +
    '    "email=" + encodeURIComponent(email),' +
    '    "telefone=" + encodeURIComponent(tel)' +
    '  ]);' +
    '};' +

    'window.enviarCodigoLGPD = function(email) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "EnviarCodigoLGPD", ["email=" + encodeURIComponent(email)]);' +
    '};' +

    'window.verificarCodigoLGPD = function(codigo) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "VerificarCodigoLGPD", ["codigo=" + encodeURIComponent(codigo)]);' +
    '};' +

    'setTimeout(function() {' +
    '  document.querySelectorAll("iframe").forEach(function(f) {' +
    '    f.setAttribute("scrolling", "yes");' +
    '    f.style.overflow = "auto";' +
    '    f.style.overflowY = "scroll";' +
    '  });' +
    '}, 800);'
  );
end;

procedure TMainForm.UniFormAjaxEvent(Sender: TComponent; EventName: string;
  Params: TUniStrings);
begin
  case AnsiIndexStr(EventName, ['RegistrarMatricula', 'EntradaPai', 'UploadContrato', 'DownloadContrato', 'DownloadContratoAssinado', 'ConsultarStatus', 'CadastrarNovato', 'ListarPasta', 'EnviarCodigoLGPD', 'VerificarCodigoLGPD']) of
    0: ProcessarPreMatricula(Params);
    1: ProcessarEntradaPai(Params);
    2: ProcessarUploadContrato(Params);
    3: ProcessarDownloadContrato(Params);
    4: ProcessarDownloadContratoAssinado(Params);
    5: ProcessarConsultarStatus(Params);
    6: ProcessarCadastrarNovato(Params);
    7: ProcessarListarPasta(Params);
    8: ProcessarEnviarCodigoLGPD(Params);
    9: ProcessarVerificarCodigoLGPD(Params);
  end;
end;

procedure TMainForm.ProcessarPreMatricula(const Params: TUniStrings);
var
  LAgendamento: IAgendamento;
  LCPF, LData: string;
begin
  LCPF := Params.Values['cpf'];
  LData := Params.Values['data'];

  LAgendamento := TAgendamento.Create(LCPF, StrToDateDef(LData, Now));
  FController.RegistrarPreMatricula(LAgendamento);

  UniSession.AddJS(
    '(function() {' +
    '  var frames = document.querySelectorAll("iframe");' +
    '  frames.forEach(function(f) {' +
    '    try {' +
    '      f.contentWindow.mostrarSucessoServidor("' + LCPF + '", "' + LData + '");' +
    '    } catch(e) {}' +
    '  });' +
    '})();'
  );
end;

procedure TMainForm.ProcessarEntradaPai(const Params: TUniStrings);
var
  LCPF    : string;
  LPartes : TArray<string>;
  LStatus : string;
  LArquivo: string;
begin
  LCPF := Params.Values['cpf'];
  FController.PrepararPastaPai(LCPF);

  LStatus  := 'sem_contrato';
  LArquivo := '';
  LPartes := FController.ConsultarContrato(LCPF).Split(['|']);
  if Length(LPartes) > 0 then LStatus  := LPartes[0];
  if Length(LPartes) > 1 then LArquivo := LPartes[1];

  // Grava na janela pai — portal.html lê via window.parent quando o modal abre
  UniSession.AddJS(
    'window._contratoStatus  = "' + LStatus  + '";' +
    'window._contratoArquivo = "' + LArquivo + '";'
  );
end;

procedure TMainForm.ProcessarUploadContrato(const Params: TUniStrings);
var
  LCPF    : string;
  LNome   : string;
  LBase64 : string;
  LBytes  : TBytes;
  LPasta  : string;
  LDestino: string;
begin
  LCPF    := Params.Values['cpf'];
  LNome   := Params.Values['nome'];
  LBase64 := Params.Values['base64'];

  LCPF := StringReplace(LCPF, '.', '', [rfReplaceAll]);
  LCPF := StringReplace(LCPF, '-', '', [rfReplaceAll]);

  LPasta   := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), LCPF), 'ContratoAssinado');
  TDirectory.CreateDirectory(LPasta);
  // Sempre salva como ContratoMatricula.pdf — nome fixo que o portal e o painel consultam
  LDestino := TPath.Combine(LPasta, 'ContratoMatricula.pdf');

  LBytes := TNetEncoding.Base64.DecodeStringToBytes(LBase64);
  TFile.WriteAllBytes(LDestino, LBytes);

  UniSession.AddJS(
    'window._uploadNome   = "ContratoMatricula.pdf";' +
    'window._uploadPronto = true;'
  );
end;

procedure TMainForm.ProcessarDownloadContrato(const Params: TUniStrings);
var
  LCPF    : string;
  LArquivo: string;
  LBytes  : TBytes;
  LBase64 : string;
begin
  LCPF := Params.Values['cpf'];
  LCPF := StringReplace(LCPF, '.', '', [rfReplaceAll]);
  LCPF := StringReplace(LCPF, '-', '', [rfReplaceAll]);

  LArquivo := TPath.Combine(TPath.Combine(TPath.Combine(
                ExtractFilePath(ParamStr(0)), LCPF), 'ContratoOriginal'), 'ContratoMatricula.pdf');
  if not TFile.Exists(LArquivo) then Exit;

  LBytes  := TFile.ReadAllBytes(LArquivo);
  LBase64 := TNetEncoding.Base64.EncodeBytesToString(LBytes);
  // Remove quebras de linha que o Delphi insere a cada 76 chars — quebram o JS
  LBase64 := StringReplace(LBase64, #13, '', [rfReplaceAll]);
  LBase64 := StringReplace(LBase64, #10, '', [rfReplaceAll]);

  // Mesmo padrão do contratoStatus — grava na janela pai
  UniSession.AddJS(
    'window._downloadBase64 = "' + LBase64 + '";' +
    'window._downloadNome   = "ContratoMatricula.pdf";' +
    'window._downloadPronto = true;'
  );
end;

procedure TMainForm.ProcessarDownloadContratoAssinado(const Params: TUniStrings);
var
  LCPF    : string;
  LArquivo: string;
  LBytes  : TBytes;
  LBase64 : string;
begin
  LCPF := Params.Values['cpf'];
  LCPF := StringReplace(LCPF, '.', '', [rfReplaceAll]);
  LCPF := StringReplace(LCPF, '-', '', [rfReplaceAll]);

  LArquivo := TPath.Combine(TPath.Combine(TPath.Combine(
                ExtractFilePath(ParamStr(0)), LCPF), 'ContratoAssinado'), 'ContratoMatricula.pdf');
  if not TFile.Exists(LArquivo) then Exit;

  LBytes  := TFile.ReadAllBytes(LArquivo);
  LBase64 := TNetEncoding.Base64.EncodeBytesToString(LBytes);
  LBase64 := StringReplace(LBase64, #13, '', [rfReplaceAll]);
  LBase64 := StringReplace(LBase64, #10, '', [rfReplaceAll]);

  UniSession.AddJS(
    'window._downloadAsBase64 = "' + LBase64 + '";' +
    'window._downloadAsNome   = "ContratoMatricula.pdf";' +
    'window._downloadAsPronto = true;'
  );
end;

procedure TMainForm.ProcessarCadastrarNovato(const Params: TUniStrings);
var
  LNome     : string;
  LSobrenome: string;
  LEmail    : string;
  LTelefone : string;
  LArquivo  : string;
  LLista    : TStringList;
  LRegistro : string;
begin
  LNome      := TNetEncoding.URL.Decode(Params.Values['nome']);
  LSobrenome := TNetEncoding.URL.Decode(Params.Values['sobrenome']);
  LEmail     := TNetEncoding.URL.Decode(Params.Values['email']);
  LTelefone  := TNetEncoding.URL.Decode(Params.Values['telefone']);

  LArquivo := TPath.Combine(ExtractFilePath(ParamStr(0)), 'files' + PathDelim + 'novatos.json');

  LLista := TStringList.Create;
  try
    if TFile.Exists(LArquivo) then
      LLista.LoadFromFile(LArquivo, TEncoding.UTF8);

    LRegistro :=
      '{"nome":"'      + LNome      + '",' +
      '"sobrenome":"'  + LSobrenome + '",' +
      '"email":"'      + LEmail     + '",' +
      '"telefone":"'   + LTelefone  + '",' +
      '"dataHora":"'   + FormatDateTime('dd\/MM\/yyyy HH:nn:ss', Now) + '"}';

    LLista.Add(LRegistro);
    LLista.SaveToFile(LArquivo, TEncoding.UTF8);
  finally
    LLista.Free;
  end;
end;

procedure TMainForm.ProcessarConsultarStatus(const Params: TUniStrings);
var
  LCPF   : string;
  LPartes: TArray<string>;
  LStatus: string;
  LArquivo: string;
begin
  LCPF := Params.Values['cpf'];
  LStatus  := 'sem_contrato';
  LArquivo := '';
  LPartes := FController.ConsultarContrato(LCPF).Split(['|']);
  if Length(LPartes) > 0 then LStatus  := LPartes[0];
  if Length(LPartes) > 1 then LArquivo := LPartes[1];

  UniSession.AddJS(
    'window._statusCheckResult = "' + LStatus + '";'
  );
end;

procedure TMainForm.ProcessarListarPasta(const Params: TUniStrings);
var
  LPasta  : string;
  LJSON   : string;
  LVar    : string;
  LArqJSON: string;
begin
  LPasta := Params.Values['pasta'];
  LJSON  := FController.ListarPasta(LPasta);

  // Remove caracteres que quebrariam o AddJS
  LJSON := StringReplace(LJSON, #13, '', [rfReplaceAll]);
  LJSON := StringReplace(LJSON, #10, '', [rfReplaceAll]);

  // Grava JSON em disco para páginas abertas em nova aba (sem window.parent)
  LArqJSON := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), 'files'), LPasta + '.json');
  TFile.WriteAllText(LArqJSON, LJSON, TEncoding.UTF8);

  // Variável global indexada pela pasta: window._lista_slider, _lista_niveis, etc.
  LVar := 'window._lista_' + StringReplace(LPasta, '/', '_', [rfReplaceAll]);
  UniSession.AddJS(LVar + ' = ' + LJSON + ';');
end;

function GerarCodigoAleatorio(Tamanho: Integer): string;
const
  CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sem I, O, 0, 1 (fácil confusão)
var
  I: Integer;
begin
  Result := '';
  Randomize;
  for I := 1 to Tamanho do
    Result := Result + CHARS[Random(Length(CHARS)) + 1];
end;

procedure TMainForm.ProcessarEnviarCodigoLGPD(const Params: TUniStrings);
var
  LEmail  : string;
  LConfig : TConfigEmail;
  LCorpo  : string;
  LRes    : string;
begin
  LEmail := TNetEncoding.URL.Decode(Params.Values['email']);

  // Gera e armazena o código desta sessão
  FLGPDCodigo := GerarCodigoAleatorio(6);

  LConfig := CarregarConfig('Config_email.ini');
  LConfig.Subject := 'Codigo de Verificacao - Portal Batista';

  LCorpo :=
    '<div style="font-family:Arial,sans-serif;max-width:520px;margin:auto;padding:32px;' +
    'background:#fff9f0;border-radius:16px;border:2px solid #fdcd62;">' +
    '<h2 style="color:#7d2728;font-size:1.4rem;margin-bottom:8px;">&#127979; Colégio Batista Santos Dumont</h2>' +
    '<p style="color:#5a3a2e;margin-bottom:20px;">Seu código de verificação para o <strong>Portal do Pai</strong> é:</p>' +
    '<div style="text-align:center;letter-spacing:10px;font-size:2.4rem;font-weight:800;' +
    'color:#d33327;background:#fff;border:3px dashed #fdcd62;border-radius:12px;padding:18px 8px;' +
    'margin-bottom:24px;font-family:monospace;">' + FLGPDCodigo + '</div>' +
    '<p style="color:#888;font-size:0.85rem;">Se você não solicitou este código, ignore este email.</p>' +
    '</div>';

  LRes := EnviarEmail(LConfig, LEmail, LCorpo);

  if LRes = 'OK' then
    UniSession.AddJS(
      '(function(){' +
      '  var frames = document.querySelectorAll("iframe");' +
      '  frames.forEach(function(f){' +
      '    try{ f.contentWindow.parent._lgpdEmailEnviado = true; }catch(e){}' +
      '  });' +
      '  window._lgpdEmailEnviado = true;' +
      '})();'
    )
  else
    UniSession.AddJS(
      '(function(){' +
      '  var frames = document.querySelectorAll("iframe");' +
      '  frames.forEach(function(f){' +
      '    try{ f.contentWindow.parent._lgpdEmailEnviado = false;' +
      '         f.contentWindow.parent._lgpdEmailErro = ' + QuotedStr(LRes) + '; }catch(e){}' +
      '  });' +
      '  window._lgpdEmailEnviado = false;' +
      '  window._lgpdEmailErro = ' + QuotedStr(LRes) + ';' +
      '})();'
    );
end;

procedure TMainForm.ProcessarVerificarCodigoLGPD(const Params: TUniStrings);
var
  LCodigo: string;
  LOk    : Boolean;
begin
  LCodigo := UpperCase(TNetEncoding.URL.Decode(Params.Values['codigo']));
  LOk     := (Trim(LCodigo) = Trim(FLGPDCodigo)) and (FLGPDCodigo <> '');

  if LOk then
    UniSession.AddJS(
      '(function(){' +
      '  var frames = document.querySelectorAll("iframe");' +
      '  frames.forEach(function(f){' +
      '    try{ f.contentWindow.parent._lgpdCodigoOk = true; }catch(e){}' +
      '  });' +
      '  window._lgpdCodigoOk = true;' +
      '})();'
    )
  else
    UniSession.AddJS(
      '(function(){' +
      '  var frames = document.querySelectorAll("iframe");' +
      '  frames.forEach(function(f){' +
      '    try{ f.contentWindow.parent._lgpdCodigoOk = false; }catch(e){}' +
      '  });' +
      '  window._lgpdCodigoOk = false;' +
      '})();'
    );
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
