program ServiceEnvioNFs;

uses
  Vcl.SvcMgr,
  View.DM in '..\View\View.DM.pas' {DMServico: TService},
  Service.WorkerThread in '..\Service\Service.WorkerThread.pas',
  Model.TConexaoDB in '..\Model\Classes\Model.TConexaoDB.pas',
  Model.IConfiguracaoEnvio in '..\Model\Interfaces\Model.IConfiguracaoEnvio.pas',
  Model.TConfiguracaoEnvio in '..\Model\Classes\Model.TConfiguracaoEnvio.pas',
  Model.IMontadorXml in '..\Model\Interfaces\Model.IMontadorXml.pas',
  Model.TMontadorXml in '..\Model\Classes\Model.TMontadorXml.pas',
  Model.IRepositorioRps in '..\Model\Interfaces\Model.IRepositorioRps.pas',
  Model.TRepositorioRps in '..\Model\Classes\Model.TRepositorioRps.pas',
  Model.TLeituraIni in '..\Model\Classes\Model.TLeituraIni.pas',
  Controller.IGeracaoXml in '..\Controller\Interfaces\Controller.IGeracaoXml.pas',
  Controller.TGeracaoXml in '..\Controller\Classes\Controller.TGeracaoXml.pas',
  Shared.Tipos in '..\Shared\Shared.Tipos.pas',
  Service.IWorkerThread in '..\Service\Service.IWorkerThread.pas',
  Model.ILeituraIni in '..\Model\Interfaces\Model.ILeituraIni.pas',
  Model.IConexaoDB in '..\Model\Interfaces\Model.IConexaoDB.pas';

{$R *.res}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TDMServico, DMServico);
  Application.Run;
end.
