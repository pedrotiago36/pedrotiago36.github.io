unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniPanel,
  uniHTMLFrame;

type
  TMainForm = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    procedure UniFormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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
begin
  UniHTMLFrame1.HTML.Text :=
    '<iframe src="/files/admin/index.html?v=' + FormatDateTime('yyyymmddhhnnss', Now) + '" ' +
    'style="width:100%;height:100%;border:none;display:block;" ' +
    'allowtransparency="true"></iframe>';
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
