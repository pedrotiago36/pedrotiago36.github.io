program EnviarEmail_Gmail;

uses
  Vcl.Forms,
  FormEnviaEmail in 'FormEnviaEmail.pas' {Form1},
  UnitEnviaEmail in 'UnitEnviaEmail.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormEnvia, FormEnvia);
  Application.Run;
end.
