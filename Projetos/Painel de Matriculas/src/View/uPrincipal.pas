unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm,
  uniHTMLFrame,
  System.IOUtils,
  Controller.IPainelAgendamentos,
  Controller.TPainelAgendamentos,
  uniGUIBaseClasses, uniPanel;

type
  TMainForm = class(TUniForm)
    HTMLAgenda: TUniHTMLFrame;
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
    procedure UniFormAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    FController: IPainelController;
    procedure ConfigurarBridge;
    procedure ProcessarValidarContrato(const Params: TUniStrings);
  public
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication,
  System.StrUtils;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.UniFormCreate(Sender: TObject);
var
  LLista      : TStringList;
  LArquivo    : string;
  LPastaAg    : string;
  LArquivoJSON: string;
begin
  FController := TPainelController.Create;

  // Carrega o HTML — identico ao portal
  LArquivo := TPath.Combine(ExtractFilePath(ParamStr(0)),
                'files' + PathDelim + 'agenda.html');
  LLista := TStringList.Create;
  try
    LLista.LoadFromFile(LArquivo, TEncoding.UTF8);
    HTMLAgenda.HTML.Text := LLista.Text;
  finally
    LLista.Free;
  end;

  LPastaAg := ExpandFileName(
    ExtractFilePath(ParamStr(0)) +
    '..\..\..\..\Front-End\prj\Win32\Debug\agendamentos');

  LArquivoJSON := TPath.Combine(
    ExtractFilePath(ParamStr(0)), 'files' + PathDelim + 'agendamentos.json');

  FController.IniciarMonitoramento(LPastaAg, LArquivoJSON);
  ConfigurarBridge;
end;

procedure TMainForm.ConfigurarBridge;
begin
  UniSession.AddJS(
    'Ext.onReady(function() {' +
    '  var byId  = Ext.ComponentQuery.query("[id*=HTMLAgenda]")[0];' +
    '  var todos = Ext.ComponentQuery.query("*");' +
    '  window._uniFormRef = byId || todos[todos.length - 1] || null;' +
    '});' +

    'window.validarContrato = function(cpf) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "ValidarContrato", ["cpf=" + cpf]);' +
    '};'
  );
end;

procedure TMainForm.UniFormAjaxEvent(Sender: TComponent; EventName: string;
  Params: TUniStrings);
begin
  case AnsiIndexStr(EventName, ['ValidarContrato']) of
    0: ProcessarValidarContrato(Params);
  end;
end;

procedure TMainForm.ProcessarValidarContrato(const Params: TUniStrings);
var
  LCPF: string;
begin
  LCPF := Params.Values['cpf'];
  FController.ValidarContrato(LCPF);

  UniSession.AddJS(
    'window._validadoCPF   = "' + LCPF + '";' +
    'window._validadoPronto = true;'
  );
end;

procedure TMainForm.UniFormDestroy(Sender: TObject);
begin
  FController.PararMonitoramento;
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
