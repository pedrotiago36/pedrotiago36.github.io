unit Controller.TInstalador;

{
  Responsabilidade: executar o ciclo completo de reinstalacao do servico.
  Para -> Desinstala -> Instala -> Inicia
  Comunica progresso via callback para a View.
}

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows;

type
  TCallbackLog = reference to procedure(const AMensagem: string;
    const AErro: Boolean = False);

  TControllerInstalador = class
  private
    FExePath     : string;
    FNomeServico : string;
    FOnLog       : TCallbackLog;

    procedure Log(const AMensagem: string; const AErro: Boolean = False);
    procedure ExecutarSC(const AArgs: string; ATimeoutMs: DWORD = 10000);
    procedure InstalarServico;
  public
    constructor Create(
      const AExePath     : string;
      const ANomeServico : string;
      const AOnLog       : TCallbackLog);

    procedure Reinstalar;
    class function Criar(
      const AExePath     : string;
      const ANomeServico : string;
      const AOnLog       : TCallbackLog): TControllerInstalador;
  end;

implementation

class function TControllerInstalador.Criar(
  const AExePath     : string;
  const ANomeServico : string;
  const AOnLog       : TCallbackLog): TControllerInstalador;
begin
  Result := TControllerInstalador.Create(AExePath, ANomeServico, AOnLog);
end;

constructor TControllerInstalador.Create(
  const AExePath     : string;
  const ANomeServico : string;
  const AOnLog       : TCallbackLog);
begin
  inherited Create;
  FExePath     := AExePath;
  FNomeServico := ANomeServico;
  FOnLog       := AOnLog;
end;

procedure TControllerInstalador.Log(const AMensagem: string;
  const AErro: Boolean);
begin
  case Assigned(FOnLog) of
    True: FOnLog(AMensagem, AErro);
  end;
end;

procedure TControllerInstalador.ExecutarSC(const AArgs: string;
  ATimeoutMs: DWORD);
var
  LSI  : TStartupInfo;
  LPI  : TProcessInformation;
  LCmd : array[0..1023] of Char;
begin
  StrPCopy(LCmd, 'sc.exe ' + AArgs);
  FillChar(LSI, SizeOf(LSI), 0);
  LSI.cb          := SizeOf(LSI);
  LSI.dwFlags     := STARTF_USESHOWWINDOW;
  LSI.wShowWindow := SW_HIDE;
  FillChar(LPI, SizeOf(LPI), 0);
  case CreateProcess(nil, LCmd, nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, LSI, LPI) of
    True:
    begin
      WaitForSingleObject(LPI.hProcess, ATimeoutMs);
      CloseHandle(LPI.hProcess);
      CloseHandle(LPI.hThread);
    end;
    False: Log('Falha ao executar sc.exe ' + AArgs, True);
  end;
end;

procedure TControllerInstalador.InstalarServico;
var
  LSI  : TStartupInfo;
  LPI  : TProcessInformation;
  LCmd : array[0..1023] of Char;
begin
  StrPCopy(LCmd, '"' + FExePath + '" /install /silent');
  FillChar(LSI, SizeOf(LSI), 0);
  LSI.cb          := SizeOf(LSI);
  LSI.dwFlags     := STARTF_USESHOWWINDOW;
  LSI.wShowWindow := SW_HIDE;
  FillChar(LPI, SizeOf(LPI), 0);
  case CreateProcess(nil, LCmd, nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, LSI, LPI) of
    True:
    begin
      WaitForSingleObject(LPI.hProcess, 10000);
      CloseHandle(LPI.hProcess);
      CloseHandle(LPI.hThread);
    end;
    False: Log('Falha ao instalar o servico.', True);
  end;
end;

procedure TControllerInstalador.Reinstalar;
begin
  Log('Iniciando reinstalacao...');
  Log('');

  Log('[1/4] Parando o servico...');
  ExecutarSC('stop ' + FNomeServico, 8000);
  Sleep(2500);
  Log('[1/4] Concluido.');

  Log('[2/4] Desinstalando versao anterior...');
  ExecutarSC('delete ' + FNomeServico, 5000);
  Sleep(1500);
  Log('[2/4] Concluido.');

  Log('[3/4] Instalando nova versao...');
  InstalarServico;
  Sleep(1500);
  Log('[3/4] Concluido.');

  Log('[4/4] Iniciando o servico...');
  ExecutarSC('start ' + FNomeServico, 8000);
  Sleep(1000);
  Log('[4/4] Concluido.');

  Log('');
  Log('Servico reinstalado e rodando com sucesso!');
end;

end.
