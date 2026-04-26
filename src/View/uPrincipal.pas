unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniPanel,
  uniHTMLFrame, System.IOUtils;

type
  TfrmPrincipal = class(TUniForm)
    htmlPrincipal: TUniHTMLFrame;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

function frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication;

function frmPrincipal: TfrmPrincipal;
begin
  Result := TfrmPrincipal(UniMainModule.GetFormInstance(TfrmPrincipal));
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  LArquivo: string;
begin
  LArquivo := TPath.GetFullPath(
    TPath.Combine(ExtractFilePath(ParamStr(0)), '..\src\View\login.html')
  );
  htmlPrincipal.HTML.LoadFromFile(LArquivo);
end;

initialization
  RegisterAppFormClass(TfrmPrincipal);

end.
