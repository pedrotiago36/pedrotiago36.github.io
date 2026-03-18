object ServicoNFs: TServiceEnvioNFs
  OldCreateOrder = True
  DisplayName = 'Servico Envio NFs - SEFIN Fortaleza'
  OnStart = ServiceStart
  OnStop = ServiceStop
  OnExecute = ServiceExecute
  OnShutdown = ServiceShutdown
  AfterInstall = ServiceAfterInstall
  Left = 40
  Top = 56
end
