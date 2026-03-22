unit Controller.IGeracaoXml;

{
  ============================================================
  Controller.IGeracaoXml — Interface do controller de geracao
  ============================================================
  Contrato usado pelo WorkerThread para disparar o ciclo
  completo das 4 unidades: busca RPS + gera XMLs.
  ============================================================
}

interface

uses
  Shared.Tipos,
  Model.IConexaoDB;

type
  IGeracaoXml = interface
    ['{D4E5F6A7-B8C9-0004-DEFA-456789012345}']
    {
      Executar — processa as 4 unidades em sequencia.
      Para cada unidade: busca RPS no banco e gera os XMLs
      nas pastas corretas (Unidade\Mes\Dia\Enviadas|Erro).
    }
    procedure Executar(
      const AConexao    : IConexaoDB;
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      out   AResultados : TArray<TResultadoXml>);
  end;

implementation

end.
