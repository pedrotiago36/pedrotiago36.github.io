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
    FController: IPortalController;
    procedure ConfigurarBridge;
    procedure ProcessarPreMatricula(const Params: TUniStrings);
    procedure ProcessarEntradaPai(const Params: TUniStrings);
    procedure ProcessarUploadContrato(const Params: TUniStrings);
    procedure ProcessarDownloadContrato(const Params: TUniStrings);
  public
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.UniFormCreate(Sender: TObject);
var
  LLista: TStringList;
  LArquivo: string;
begin
  FController := TPortalController.Create;

  LArquivo := TPath.Combine(ExtractFilePath(ParamStr(0)), 'files' + PathDelim + 'portal.html');
  LLista := TStringList.Create;
  try
    LLista.LoadFromFile(LArquivo, TEncoding.UTF8);
    HTMLPortal.HTML.Text := LLista.Text;
  finally
    LLista.Free;
  end;

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
  case AnsiIndexStr(EventName, ['RegistrarMatricula', 'EntradaPai', 'UploadContrato', 'DownloadContrato']) of
    0: ProcessarPreMatricula(Params);
    1: ProcessarEntradaPai(Params);
    2: ProcessarUploadContrato(Params);
    3: ProcessarDownloadContrato(Params);
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
  LDestino := TPath.Combine(LPasta, LNome);

  LBytes := TNetEncoding.Base64.DecodeStringToBytes(LBase64);
  TFile.WriteAllBytes(LDestino, LBytes);

  UniSession.AddJS(
    '(function(){' +
    '  var frames = document.querySelectorAll("iframe");' +
    '  frames.forEach(function(f){' +
    '    try{ f.contentWindow.uploadContratoOk("' + LNome + '"); }catch(e){}' +
    '  });' +
    '})();'
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

initialization
  RegisterAppFormClass(TMainForm);

end.
