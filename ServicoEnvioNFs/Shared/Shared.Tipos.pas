unit Shared.Tipos;

{
  Records e tipos compartilhados entre todas as camadas.
  Espelha exatamente a estrutura do NFSe_Servico.ini:

  [WebService]
    AmbienteAtivo = Homologacao | Producao

  [Homologacao]
    Url    = https://...
    Status = texto

  [Producao]
    Url    = http://...
    Status = texto

  [Diretorios]
    RpsEnviados   = caminho
    RpsErro       = caminho
    RpsCancelados = caminho
    ArquivoIni    = caminho

  [Thread]
    Ativa = 0 | 1

  [Config]
    DiaEnvio = 10
}

interface

type

  TConfigWebService = record
    AmbienteAtivo : String;   // 'Homologacao' ou 'Producao'
    UrlHomologacao : String;
    StatusHomolog  : String;
    UrlProducao    : String;
    StatusProducao : String;
    UrlAtiva       : String;  // resolvida automaticamente pelo modelo
  end;

  TConfigDiretorios = record
    RpsEnviados   : String;
    RpsErro       : String;
    RpsCancelados : String;
    ArquivoIni    : String;
  end;

  TConfigThread = record
    Ativa : Boolean;   // 0 = False, 1 = True
  end;

  TConfigAgendamento = record
    DiaEnvio  : Integer;  // [Config] DiaEnvio
    DiasAviso : Integer;  // fixo = 1 (nao existe no .ini, padrao do sistema)
    IniPath   : String;   // caminho completo do .ini
  end;

  // Record principal — toda a configuracao do .ini em um unico lugar
  TConfigCompleta = record
    WebService   : TConfigWebService;
    Diretorios   : TConfigDiretorios;
    Thread       : TConfigThread;
    Agendamento  : TConfigAgendamento;
  end;

  TResultadoAgendamento = record
    DeveNotificar : Boolean;
    DiaEnvio      : Integer;
    DiasRestantes : Integer;
    MesReferencia : Integer;
    AnoReferencia : Integer;
  end;

implementation

end.
