unit Model.TRecuperarArquivos;

interface

uses
  Model.IRecuperarArquivos,
  Model.IConfiguracaoSistema;

type
  TRecuperarArquivos = class(TInterfacedObject, IRecuperarArquivos)
  public
    procedure RecuperarIni(const AConfiguracao: IConfiguracaoSistema;
      const ACaminhoIni: string);
    class function Criar: IRecuperarArquivos;
  end;

implementation

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils;

class function TRecuperarArquivos.Criar: IRecuperarArquivos;
begin
  Result := TRecuperarArquivos.Create;
end;

procedure TRecuperarArquivos.RecuperarIni(
  const AConfiguracao: IConfiguracaoSistema;
  const ACaminhoIni: string);
var
  LIni  : TMemIniFile;
  LDados: TDadosConfiguracao;
begin
  LIni := TMemIniFile.Create(TPath.Combine(ACaminhoIni, 'NFSe_Servico.ini'));
  try
    LDados.AmbienteAtivo          := LIni.ReadString('WebService',  'AmbienteAtivo',  'Homologacao');
    LDados.UrlHomologacao         := LIni.ReadString('Homologacao', 'Url',             '');
    LDados.UrlProducao            := LIni.ReadString('Producao',    'Url',             '');
    LDados.DiretorioRpsEnviados   := LIni.ReadString('Diretorios',  'RpsEnviados',     '');
    LDados.DiretorioRpsErro       := LIni.ReadString('Diretorios',  'RpsErro',         '');
    LDados.DiretorioRpsCancelados := LIni.ReadString('Diretorios',  'RpsCancelados',   '');
    LDados.DiretorioArquivoIni    := LIni.ReadString('Diretorios',  'ArquivoIni',      '');
    LDados.ThreadAtiva            := LIni.ReadBool  ('Thread',      'Ativa',           False);
    LDados.DataEnvio              := LIni.ReadString('Config',      'DiaEnvio',        '');
    AConfiguracao.Atualizar(LDados);
  finally
    LIni.Free;
  end;
end;

end.
