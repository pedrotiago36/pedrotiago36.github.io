program ServiceEnvioNFs;

{
  CICLO DE DEV - REINSTALACAO AUTOMATICA:
  Execute com /REINSTALL para: parar -> desinstalar -> instalar -> iniciar

  Uso: Project -> Options -> Debugger -> Parameters -> /REINSTALL
}

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.SvcMgr,
  View.TServiceEnvioNFs   in '..\View\View.TServiceEnvioNFs.pas',
  Service.TWorkerThread   in '..\Service\Service.TWorkerThread.pas',
  Controller.TAgendamento in '..\Controller\Classes\Controller.TAgendamento.pas',
  Controller.IAgendamento in '..\Controller\Interfaces\Controller.IAgendamento.pas',
  Model.TConfiguracaoModel   in '..\Model\Classes\Model.TConfiguracaoModel.pas',
  Model.IConfiguracaoModel   in '..\Model\Interfaces\Model.IConfiguracaoModel.pas',
  Model.TNotificadorModel    in '..\Model\Classes\Model.TNotificadorModel.pas',
  Model.INotificadorModel    in '..\Model\Interfaces\Model.INotificadorModel.pas',
  Shared.Tipos            in '..\Shared\Shared.Tipos.pas';

{$R *.res}

const
  NOME_SERVICO = 'ServicoEnvioNFs';

procedure ExecutarComando(const Cmd: String; TimeoutMs: DWORD = 10000);
var
  SI  : TStartupInfo;
  PI  : TProcessInformation;
  Buf : array[0..1023] of Char;
begin
  StrPCopy(Buf, Cmd);
  FillChar(SI, SizeOf(SI), 0);
  SI.cb          := SizeOf(SI);
  SI.dwFlags     := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  FillChar(PI, SizeOf(PI), 0);
  if CreateProcess(nil, Buf, nil, nil, False,
     CREATE_NO_WINDOW, nil, nil, SI, PI) then
  begin
    WaitForSingleObject(PI.hProcess, TimeoutMs);
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
  end;
end;

procedure ReinstalarServico;
var
  ExePath : String;
  InstCmd : array[0..1023] of Char;
  SI      : TStartupInfo;
  PI      : TProcessInformation;
begin
  ExePath := ParamStr(0);
  AllocConsole;
  Writeln('');
  Writeln('=========================================');
  Writeln('  ServicoEnvioNFs - REINSTALACAO');
  Writeln('=========================================');
  Writeln('');
  Write('  [1/4] Parando servico...    ');
  ExecutarComando('sc.exe stop '   + NOME_SERVICO, 8000);
  Sleep(2500);
  Writeln('feito.');
  Write('  [2/4] Desinstalando...      ');
  ExecutarComando('sc.exe delete ' + NOME_SERVICO, 5000);
  Sleep(1500);
  Writeln('feito.');
  Write('  [3/4] Instalando...         ');
  StrPCopy(InstCmd, '"' + ExePath + '" /install /silent');
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  FillChar(PI, SizeOf(PI), 0);
  if CreateProcess(nil, InstCmd, nil, nil, False,
     CREATE_NO_WINDOW, nil, nil, SI, PI) then
  begin
    WaitForSingleObject(PI.hProcess, 10000);
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
  end;
  Sleep(1000);
  Writeln('feito.');
  Write('  [4/4] Iniciando servico...  ');
  ExecutarComando('sc.exe start '  + NOME_SERVICO, 8000);
  Writeln('feito.');
  Writeln('');
  Writeln('  Servico rodando!');
  Writeln('');
  Writeln('  Pressione Enter para fechar...');
  Readln;
end;

begin
  if FindCmdLineSwitch('REINSTALL') then
  begin
    ReinstalarServico;
    Exit;
  end;

  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;

  Application.CreateForm(TServiceEnvioNFs, ServiceEnvioNFs);
  Application.Run;
end.
