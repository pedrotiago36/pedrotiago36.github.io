unit Model.IConfiguracaoSistema;

interface

type
  TDadosConfiguracao = record
    UrlHomologacao      : string;
    UrlProducao         : string;
    DiretorioRpsEnviados: string;
    DiretorioRpsErro    : string;
    DiretorioArquivoIni : string;
    ThreadAtiva         : Boolean;
    DataEnvio           : string;
  end;

  IConfiguracaoSistema = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure Atualizar(const ADados: TDadosConfiguracao);
    procedure PreencherDados(out ADados: TDadosConfiguracao);
  end;

implementation

end.
