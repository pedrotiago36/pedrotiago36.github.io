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
  LIni  : TIniFile;
  LDados: TDadosConfiguracao;
begin
  LIni := TIniFile.Create(TPath.Combine(ACaminhoIni, 'NFSe_Servico.ini'));
  try
    LDados.UrlHomologacao       := LIni.ReadString('WebService', 'UrlHomologacao', '');
    LDados.UrlProducao          := LIni.ReadString('WebService', 'UrlProducao',    '');
    LDados.DiretorioRpsEnviados := LIni.ReadString('Diretorios', 'RpsEnviados',    '');
    LDados.DiretorioRpsErro     := LIni.ReadString('Diretorios', 'RpsErro',        '');
    LDados.DiretorioArquivoIni  := LIni.ReadString('Diretorios', 'ArquivoIni',     '');
    LDados.ThreadAtiva          := LIni.ReadBool  ('Thread',     'Ativa',          False);
    AConfiguracao.Atualizar(LDados);
  finally
    LIni.Free;
  end;
end;

end.
