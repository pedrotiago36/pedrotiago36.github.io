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
    procedure ProcessarDownloadContratoAssinado(const Params: TUniStrings);
    procedure ProcessarExcluirNovato(const Params: TUniStrings);
    procedure ProcessarExcluirTodosNovatos(const Params: TUniStrings);
  public
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication,
  System.StrUtils,
  System.NetEncoding;

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
    '};' +

    'window.downloadContratoAssinado = function(cpf) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "DownloadContratoAssinado", ["cpf=" + cpf]);' +
    '};' +

    'window.excluirNovato = function(idx) {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "ExcluirNovato", ["idx=" + idx]);' +
    '};' +

    'window.excluirTodosNovatos = function() {' +
    '  var frm = window._uniFormRef;' +
    '  if (frm) ajaxRequest(frm, "ExcluirTodosNovatos", []);' +
    '};'
  );
end;

procedure TMainForm.UniFormAjaxEvent(Sender: TComponent; EventName: string;
  Params: TUniStrings);
begin
  case AnsiIndexStr(EventName, ['ValidarContrato', 'DownloadContratoAssinado', 'ExcluirNovato', 'ExcluirTodosNovatos']) of
    0: ProcessarValidarContrato(Params);
    1: ProcessarDownloadContratoAssinado(Params);
    2: ProcessarExcluirNovato(Params);
    3: ProcessarExcluirTodosNovatos(Params);
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

  LArquivo := TPath.Combine(
    TPath.Combine(
      TPath.Combine(FController.PastaBase, LCPF),
      'ContratoAssinado'),
    'ContratoMatricula.pdf');

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

procedure TMainForm.ProcessarExcluirNovato(const Params: TUniStrings);
begin
  FController.ExcluirNovato(StrToIntDef(Params.Values['idx'], -1));
  UniSession.AddJS('window._novatoExcluidoPronto = true;');
end;

procedure TMainForm.ProcessarExcluirTodosNovatos(const Params: TUniStrings);
begin
  FController.ExcluirTodosNovatos;
  UniSession.AddJS('window._novatoExcluidoPronto = true;');
end;

procedure TMainForm.UniFormDestroy(Sender: TObject);
begin
  FController.PararMonitoramento;
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
