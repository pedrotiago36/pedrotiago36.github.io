program ServiceEnvioNFs;

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Forms,
  Vcl.SvcMgr,
  View.TServiceEnvioNFs  in '..\View\View.TServiceEnvioNFs.pas',
  View.TInstalador       in '..\View\View.TInstalador.pas',
  Controller.TInstalador in '..\Controller\Classes\Controller.TInstalador.pas',
  Service.TWorkerThread  in '..\Service\Service.TWorkerThread.pas',
  Controller.TAgendamento  in '..\Controller\Classes\Controller.TAgendamento.pas',
  Controller.IAgendamento  in '..\Controller\Interfaces\Controller.IAgendamento.pas',
  Model.TConfiguracaoModel in '..\Model\Classes\Model.TConfiguracaoModel.pas',
  Model.IConfiguracaoModel in '..\Model\Interfaces\Model.IConfiguracaoModel.pas',
  Model.TNotificadorModel  in '..\Model\Classes\Model.TNotificadorModel.pas',
  Model.INotificadorModel  in '..\Model\Interfaces\Model.INotificadorModel.pas',
  Shared.Tipos             in '..\Shared\Shared.Tipos.pas';

{$R *.res}

procedure AbrirInstalador;
var
  LFrm: TFrmInstalador;
begin
  Application.Initialize;
  Application.Title := 'Servico NFSe - Instalador';
  LFrm := TFrmInstalador.Create(Application);
  try
    LFrm.ShowModal;
  finally
    LFrm.Free;
  end;
end;

var
  LEhParametroServico: Boolean;
begin
  LEhParametroServico := FindCmdLineSwitch('install') or
                         FindCmdLineSwitch('uninstall') or
                         Application.Installing;

  case LEhParametroServico of
    True:
    begin
      Vcl.SvcMgr.Application.Initialize;
      ServicoNFs := TServiceEnvioNFs.Create(Vcl.SvcMgr.Application);
      Vcl.SvcMgr.Application.Run;
    end;
    False: AbrirInstalador;
  end;
end.
