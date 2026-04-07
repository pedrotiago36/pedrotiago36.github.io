program prjPainelMatriculas;  //Porta deste projeto : 8072

uses
  Forms,
  ServerModule in '..\src\Service\ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in '..\src\Service\MainModule.pas' {UniMainModule: TUniGUIMainModule},
  uPrincipal in '..\src\View\uPrincipal.pas' {MainForm: TUniForm},
  Model.IAgendamentoPainel in '..\src\Model\Model.IAgendamentoPainel.pas',
  Model.TAgendamentoPainel in '..\src\Model\Model.TAgendamentoPainel.pas',
  Controller.IPainelAgendamentos in '..\src\Controller\Controller.IPainelAgendamentos.pas',
  Controller.TPainelAgendamentos in '..\src\Controller\Controller.TPainelAgendamentos.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
