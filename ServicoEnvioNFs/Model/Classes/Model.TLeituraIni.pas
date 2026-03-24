unit Model.TLeituraIni;

interface

uses
  Model.ILeituraIni,
  Shared.Tipos;

type
  TLeituraIni = class(TInterfacedObject, ILeituraIni)
  public
    function ResolverCaminhoIni(const AExePath: string): string;
    function Carregar(
      const AExePath: string;
      const AMes    : Integer;
      const AAno    : Integer): TDadosConfiguracaoEnvio;
    class function Criar: ILeituraIni;
  end;

implementation

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  System.StrUtils;

class function TLeituraIni.Criar: ILeituraIni;
begin
  Result := TLeituraIni.Create;
end;

function TLeituraIni.ResolverCaminhoIni(const AExePath: string): string;
var
  LBase     : string;
  LTentativa: string;
  LI        : Integer;
begin
  Result := '';
  LBase  := ExtractFilePath(AExePath);

  for LI := 0 to 5 do
  begin
    { 1o — mesma pasta do exe }
    LTentativa := TPath.Combine(LBase, 'NFSe_Servico.ini');
    case TFile.Exists(LTentativa) of
      True: begin Result := LTentativa; Exit; end;
    end;

    { 2o — subpasta Config }
    LTentativa := TPath.Combine(TPath.Combine(LBase, 'Config'), 'NFSe_Servico.ini');
    case TFile.Exists(LTentativa) of
      True: begin Result := LTentativa; Exit; end;
    end;

    LBase := TPath.GetFullPath(TPath.Combine(LBase, '..'));
  end;

  { Fallback — mesma pasta do exe }
  Result := TPath.Combine(ExtractFilePath(AExePath), 'NFSe_Servico.ini');
end;

function TLeituraIni.Carregar(
  const AExePath: string;
  const AMes    : Integer;
  const AAno    : Integer): TDadosConfiguracaoEnvio;
var
  LIni           : TMemIniFile;
  LCaminho       : string;
  LEnviarLote    : Integer;
  LThreadAtiva   : Integer;
  LAmbienteAtivo : string;
begin
  LCaminho := ResolverCaminhoIni(AExePath);

  LIni := TMemIniFile.Create(LCaminho);
  try
    { [Banco] }
    Result.Servidor           := LIni.ReadString ('Banco',      'Servidor',           '192.168.1.19');
    Result.Banco              := LIni.ReadString ('Banco',      'Banco',              'conacd');
    Result.Login              := LIni.ReadString ('Banco',      'Login',              'sa');
    Result.Senha              := LIni.ReadString ('Banco',      'Senha',              '');

    { [Emitente] }
    Result.CnpjUnidade        := LIni.ReadString ('Emitente',   'Cnpj',               '07199060000124');
    Result.InscricaoMunicipal := LIni.ReadString ('Emitente',   'InscricaoMunicipal', '13371');

    { [Diretorios] }
    Result.DiretorioBase      := LIni.ReadString ('Diretorios', 'DiretorioXml',
      ExtractFilePath(AExePath) + 'XML');

    { [ModoEnvio] }
    LEnviarLote               := LIni.ReadInteger('ModoEnvio',  'EnviarEmLote',  0);

    { [Thread] Ativa=1 libera o servico | Ativa=0 paralisa }
    LThreadAtiva              := LIni.ReadInteger('Thread',     'Ativa',         0);

    { [Config] DiaEnvio = dia do mes para execucao em Producao }
    Result.DiaEnvio           := LIni.ReadInteger('Config',     'DiaEnvio',      21);

    { [WebService] AmbienteAtivo = Homologacao ou Producao }
    LAmbienteAtivo            := LIni.ReadString ('WebService', 'AmbienteAtivo', 'Homologacao');

  finally
    LIni.Free;
  end;

  { ModoEnvio }
  case LEnviarLote = 1 of
    True : Result.ModoEnvio := meLote;
    False: Result.ModoEnvio := meIndividual;
  end;

  { ThreadAtiva }
  Result.ThreadAtiva := LThreadAtiva = 1;

  { Ambiente — lido de [WebService] AmbienteAtivo }
  case AnsiSameText(LAmbienteAtivo, 'Producao') of
    True : Result.Ambiente := amProducao;
    False: Result.Ambiente := amHomologacao;
  end;

  Result.Mes := AMes;
  Result.Ano := AAno;
end;

end.
