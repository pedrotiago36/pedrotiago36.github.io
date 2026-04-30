program SGE;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FormLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitAluno in 'UnitAluno.pas' {FormAluno},
  UnitProfessor in 'UnitProfessor.pas' {FormProfessor},
  UnitResponsavel in 'UnitResponsavel.pas' {FormResponsavel},
  UnitAdministrativo in 'UnitAdministrativo.pas' {FormAdministrativo},
  UnitEducInfantil in 'UnitEducInfantil.pas' {FormEducInfantil};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormLogin, FormLogin);
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.CreateForm(TFormAluno, FormAluno);
  Application.CreateForm(TFormProfessor, FormProfessor);
  Application.CreateForm(TFormResponsavel, FormResponsavel);
  Application.CreateForm(TFormAdministrativo, FormAdministrativo);
  Application.CreateForm(TFormEducInfantil, FormEducInfantil);
  Application.Run;
end.
