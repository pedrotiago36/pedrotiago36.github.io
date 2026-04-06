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
  private
    FController: IPainelController;
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
end;

procedure TMainForm.UniFormDestroy(Sender: TObject);
begin
  FController.PararMonitoramento;
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
