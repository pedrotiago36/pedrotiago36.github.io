program ServiceEnvioNFs;

{
  ============================================================
  ServicoEnvioNFs — Windows Service de geracao de XMLs NFSe
  ============================================================
  Gera automaticamente os XMLs de RPS para envio a SEFIN
  Fortaleza (GINFES v04), a cada 1 hora conforme configurado.

  Instalacao:
    Executar instalar_servico.bat como Administrador.

  Configuracao:
    Config\NFSe_Servico.ini — banco, emitente, diretorios, modo.

  Log:
    Logs\yyyy-mm-dd.log — um arquivo por dia com cada passo.
  ============================================================
}

uses
  Vcl.SvcMgr,
  { View }
  View.DM in '..\View\View.DM.pas' {DMServico: TService},
  { Service }
  Service.WorkerThread in '..\Service\Service.WorkerThread.pas',
  Service.IWorkerThread in '..\Service\Service.IWorkerThread.pas',
  { Controller }
  Controller.IGeracaoXml in '..\Controller\Interfaces\Controller.IGeracaoXml.pas',
  Controller.TGeracaoXml in '..\Controller\Classes\Controller.TGeracaoXml.pas',
  { Model — Interfaces }
  Model.IConexaoDB in '..\Model\Interfaces\Model.IConexaoDB.pas',
  Model.ILeituraIni in '..\Model\Interfaces\Model.ILeituraIni.pas',
  Model.IRepositorioRps in '..\Model\Interfaces\Model.IRepositorioRps.pas',
  Model.IMontadorXml in '..\Model\Interfaces\Model.IMontadorXml.pas',
  { Model — Classes }
  Model.TConexaoDB in '..\Model\Classes\Model.TConexaoDB.pas',
  Model.TLeituraIni in '..\Model\Classes\Model.TLeituraIni.pas',
  Model.TRepositorioRps in '..\Model\Classes\Model.TRepositorioRps.pas',
  Model.TMontadorXml in '..\Model\Classes\Model.TMontadorXml.pas',
  { Shared }
  Shared.Tipos in '..\Shared\Shared.Tipos.pas';

{$R *.res}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TDMServico, DMServico);
  Application.Run;
end.
