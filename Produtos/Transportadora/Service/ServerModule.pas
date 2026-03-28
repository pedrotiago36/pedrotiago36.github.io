unit ServerModule;

interface

uses
  Classes, SysUtils, Forms,
  uniGUIServer, uniGUIMainModule, uniGUIApplication,
  uIdCustomHTTPServer, uniGUITypes;

type
  TUniServerModule = class(TUniGUIServerModule)
  private
    { Private declarations }
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars;

function UniServerModule: TUniServerModule;
begin
  Result := TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
  { Aponta FilesFolder para onde as imagens estao, relativo ao exe }
  FilesFolder := ExtractFilePath(Application.ExeName) + '..\exe\files\';
end;

initialization
  RegisterServerModuleClass(TUniServerModule);

end.
