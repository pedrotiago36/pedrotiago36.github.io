program DTClinica;

uses
  Forms,
  ServerModule in '..\Service\ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in '..\Service\MainModule.pas' {UniMainModule: TUniGUIMainModule},
  uPrincipal in '..\src\View\uPrincipal.pas' {MainForm: TUniForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
