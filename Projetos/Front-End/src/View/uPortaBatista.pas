unit uPortaBatista;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm,
  uniHTMLFrame,
  System.StrUtils,
  System.IOUtils,
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
  case AnsiIndexStr(EventName, ['RegistrarMatricula', 'EntradaPai']) of
    0: ProcessarPreMatricula(Params);
    1: ProcessarEntradaPai(Params);
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
  LCPF: string;
begin
  LCPF := Params.Values['cpf'];
  FController.PrepararPastaPai(LCPF);
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
