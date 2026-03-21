object DMServico: TDMServico
  DisplayName = 'Servico Envio NFs - SEFIN Fortaleza'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 39
  Width = 136
end
