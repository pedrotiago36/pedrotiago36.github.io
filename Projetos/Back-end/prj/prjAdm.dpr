program prjAdm;

uses
  Forms,
  ServerModule in '..\src\Service\ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in '..\src\Service\MainModule.pas' {UniMainModule: TUniGUIMainModule},
  uPrincipal in '..\src\uPrincipal.pas' {MainForm: TUniForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
