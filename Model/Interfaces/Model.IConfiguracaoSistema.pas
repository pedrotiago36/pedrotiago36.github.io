unit Model.IConfiguracaoSistema;

interface

type
  IConfiguracaoSistema = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure AtualizarUrlHomologacao(const AUrl: string);
    procedure AtualizarUrlProducao(const AUrl: string);
    procedure AtualizarDiretorioRpsEnviados(const ADiretorio: string);
    procedure AtualizarDiretorioRpsErro(const ADiretorio: string);
    procedure AtualizarDiretorioArquivoIni(const ADiretorio: string);
    procedure AtualizarThreadAtiva(const AAtiva: Boolean);

    function UrlHomologacao: string;
    function UrlProducao: string;
    function DiretorioRpsEnviados: string;
    function DiretorioRpsErro: string;
    function DiretorioArquivoIni: string;
    function ThreadAtiva: Boolean;
  end;

implementation

end.
