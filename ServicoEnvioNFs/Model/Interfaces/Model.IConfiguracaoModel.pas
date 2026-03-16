unit Model.IConfiguracaoModel;

interface

uses
  Shared.Tipos;

type

  IConfiguracaoModel = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure Carregar;
    function  Config: TConfigCompleta;
    function  Agendamento: TConfigAgendamento;
    function  WebService: TConfigWebService;
    function  Diretorios: TConfigDiretorios;
    function  Thread: TConfigThread;
    procedure AtualizarDiaEnvio(NovoDia: Integer);
  end;

implementation

end.
