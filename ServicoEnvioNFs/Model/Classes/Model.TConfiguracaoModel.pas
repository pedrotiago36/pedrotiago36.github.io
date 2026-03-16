unit Model.TConfiguracaoModel;

{
  Le e grava o NFSe_Servico.ini.

  Secoes mapeadas:
    [WebService]  -> AmbienteAtivo
    [Homologacao] -> Url, Status
    [Producao]    -> Url, Status
    [Diretorios]  -> RpsEnviados, RpsErro, RpsCancelados, ArquivoIni
    [Thread]      -> Ativa (0/1)
    [Config]      -> DiaEnvio

  AtualizarDiaEnvio grava somente em [Config] -> DiaEnvio.
  DiasAviso nao existe no .ini -> sempre 1 (fixo do sistema).
}

interface

uses
  System.SysUtils,
  System.IniFiles,
  Model.IConfiguracaoModel,
  Shared.Tipos;

type

  TConfiguracaoModel = class(TInterfacedObject, IConfiguracaoModel)
  strict private
    FIniPath : String;
    FConfig  : TConfigCompleta;

    procedure ResolverUrlAtiva;
  public
    constructor Create(IniPath: String);
    procedure Carregar;
    function  Config: TConfigCompleta;
    function  Agendamento: TConfigAgendamento;
    function  WebService: TConfigWebService;
    function  Diretorios: TConfigDiretorios;
    function  Thread: TConfigThread;
    procedure AtualizarDiaEnvio(NovoDia: Integer);
  end;

implementation

constructor TConfiguracaoModel.Create(IniPath: String);
begin
  inherited Create;
  FIniPath                        := IniPath;
  FConfig.Agendamento.IniPath     := IniPath;
  FConfig.Agendamento.DiasAviso   := 1;   // fixo — nao existe no .ini
end;

procedure TConfiguracaoModel.ResolverUrlAtiva;
begin
  // Sem IF: usa indexacao por string para resolver a URL ativa
  // AmbienteAtivo = 'Homologacao' -> UrlAtiva = UrlHomologacao
  // AmbienteAtivo = 'Producao'    -> UrlAtiva = UrlProducao
  // Qualquer outro valor           -> usa Homologacao como seguro padrao

  case AnsiCompareText(FConfig.WebService.AmbienteAtivo, 'Producao') = 0 of
    True : FConfig.WebService.UrlAtiva := FConfig.WebService.UrlProducao;
    False: FConfig.WebService.UrlAtiva := FConfig.WebService.UrlHomologacao;
  end;
end;

procedure TConfiguracaoModel.Carregar;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FIniPath);
  try
    // [WebService]
    FConfig.WebService.AmbienteAtivo  := Ini.ReadString('WebService', 'AmbienteAtivo', 'Homologacao');

    // [Homologacao]
    FConfig.WebService.UrlHomologacao := Ini.ReadString('Homologacao', 'Url',    '');
    FConfig.WebService.StatusHomolog  := Ini.ReadString('Homologacao', 'Status', '');

    // [Producao]
    FConfig.WebService.UrlProducao    := Ini.ReadString('Producao', 'Url',    '');
    FConfig.WebService.StatusProducao := Ini.ReadString('Producao', 'Status', '');

    // [Diretorios]
    FConfig.Diretorios.RpsEnviados    := Ini.ReadString('Diretorios', 'RpsEnviados',   '');
    FConfig.Diretorios.RpsErro        := Ini.ReadString('Diretorios', 'RpsErro',       '');
    FConfig.Diretorios.RpsCancelados  := Ini.ReadString('Diretorios', 'RpsCancelados', '');
    FConfig.Diretorios.ArquivoIni     := Ini.ReadString('Diretorios', 'ArquivoIni',    '');

    // [Thread]
    FConfig.Thread.Ativa              := Ini.ReadInteger('Thread', 'Ativa', 0) = 1;

    // [Config]
    FConfig.Agendamento.DiaEnvio      := Ini.ReadInteger('Config', 'DiaEnvio', 5);
    FConfig.Agendamento.IniPath       := FIniPath;
    FConfig.Agendamento.DiasAviso     := 1;  // fixo

    // Resolve URL ativa com base no ambiente escolhido
    ResolverUrlAtiva;
  finally
    Ini.Free;
  end;
end;

function TConfiguracaoModel.Config: TConfigCompleta;
begin
  Result := FConfig;
end;

function TConfiguracaoModel.Agendamento: TConfigAgendamento;
begin
  Result := FConfig.Agendamento;
end;

function TConfiguracaoModel.WebService: TConfigWebService;
begin
  Result := FConfig.WebService;
end;

function TConfiguracaoModel.Diretorios: TConfigDiretorios;
begin
  Result := FConfig.Diretorios;
end;

function TConfiguracaoModel.Thread: TConfigThread;
begin
  Result := FConfig.Thread;
end;

procedure TConfiguracaoModel.AtualizarDiaEnvio(NovoDia: Integer);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FIniPath);
  try
    // Grava somente a chave DiaEnvio na secao [Config]
    // Todas as outras secoes e chaves permanecem intactas
    Ini.WriteInteger('Config', 'DiaEnvio', NovoDia);
    FConfig.Agendamento.DiaEnvio := NovoDia;
  finally
    Ini.Free;
  end;
end;

end.
