unit Controller.IGeracaoXml;

{
  ============================================================
  Controller.IGeracaoXml — Interface do controller de geracao
  ============================================================
  Define o contrato que o WorkerThread usa para disparar o
  ciclo completo: buscar RPS no banco e gerar os XMLs.

  Parametros do metodo Executar:
    AConexao    : conexao ja aberta com o SQL Server
    AConfig     : configuracoes lidas do .ini
    ACallbackLog: delegate para reportar progresso ao log
    AResultados : lista de resultados de cada XML gerado
  ============================================================
}

interface

uses
  Shared.Tipos,    { TDadosConfiguracaoEnvio, TResultadoXml, TCallbackProgresso }
  Model.IConexaoDB;{ IConexaoDB }

type
  IGeracaoXml = interface
    ['{D4E5F6A7-B8C9-0004-DEFA-456789012345}']
    {
      Executar — dispara o ciclo completo de geracao de XML.
      Internamente: busca RPS via repositorio e monta XMLs via montador.
    }
    procedure Executar(
      const AConexao    : IConexaoDB;              { Conexao com o banco }
      const AConfig     : TDadosConfiguracaoEnvio; { Configuracoes do .ini }
      const ACallbackLog: TCallbackProgresso;       { Delegate de log }
      out   AResultados : TArray<TResultadoXml>);   { Resultados dos XMLs }
  end;

implementation

end.
