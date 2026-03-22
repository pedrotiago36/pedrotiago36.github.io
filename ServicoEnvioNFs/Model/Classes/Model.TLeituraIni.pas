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
  System.IOUtils;

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
    LTentativa := TPath.Combine(TPath.Combine(LBase, 'exe'), 'Config');
    case TFile.Exists(TPath.Combine(LTentativa, 'NFSe_Servico.ini')) of
      True: begin Result := TPath.Combine(LTentativa, 'NFSe_Servico.ini'); Exit; end;
    end;

    LTentativa := TPath.Combine(LBase, 'Config');
    case TFile.Exists(TPath.Combine(LTentativa, 'NFSe_Servico.ini')) of
      True: begin Result := TPath.Combine(LTentativa, 'NFSe_Servico.ini'); Exit; end;
    end;

    LBase := TPath.GetFullPath(TPath.Combine(LBase, '..'));
  end;

  Result := TPath.Combine(
    TPath.Combine(ExtractFilePath(AExePath), 'Config'),
    'NFSe_Servico.ini');
end;

function TLeituraIni.Carregar(
  const AExePath: string;
  const AMes    : Integer;
  const AAno    : Integer): TDadosConfiguracaoEnvio;
var
  LIni       : TMemIniFile;
  LCaminho   : string;
  LEnviarLote: Integer;
begin
  LCaminho := ResolverCaminhoIni(AExePath);

  LIni := TMemIniFile.Create(LCaminho);
  try
    Result.Servidor           := LIni.ReadString ('Banco',      'Servidor',           '192.168.1.12');
    Result.Banco              := LIni.ReadString ('Banco',      'Banco',              'conacd');
    Result.Login              := LIni.ReadString ('Banco',      'Login',              'sa');
    Result.Senha              := LIni.ReadString ('Banco',      'Senha',              'Admbatista#');
    Result.CnpjUnidade        := LIni.ReadString ('Emitente',   'Cnpj',               '07199060000124');
    Result.InscricaoMunicipal := LIni.ReadString ('Emitente',   'InscricaoMunicipal', '13371');
    Result.DiretorioBase      := LIni.ReadString ('Diretorios', 'DiretorioXml',
      ExtractFilePath(AExePath) + 'XML');
    LEnviarLote               := LIni.ReadInteger('ModoEnvio',  'EnviarEmLote',       0);
  finally
    LIni.Free;
  end;

  case LEnviarLote = 1 of
    True : Result.ModoEnvio := meLote;
    False: Result.ModoEnvio := meIndividual;
  end;

  Result.Mes := AMes;
  Result.Ano := AAno;
end;

end.
