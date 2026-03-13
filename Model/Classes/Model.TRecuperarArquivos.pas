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

{ TRecuperarArquivos }

class function TRecuperarArquivos.Criar: IRecuperarArquivos;
begin
  Result := TRecuperarArquivos.Create;
end;

procedure TRecuperarArquivos.RecuperarIni(const AConfiguracao: IConfiguracaoSistema;
  const ACaminhoIni: string);
var
  LIni: TIniFile;
  LCaminhoCompleto: string;
begin
  LCaminhoCompleto := TPath.Combine(ACaminhoIni, 'NFSe_Servico.ini');

  LIni := TIniFile.Create(LCaminhoCompleto);
  try
    AConfiguracao.AtualizarUrlHomologacao(
      LIni.ReadString('WebService', 'UrlHomologacao', ''));
    AConfiguracao.AtualizarUrlProducao(
      LIni.ReadString('WebService', 'UrlProducao', ''));
    AConfiguracao.AtualizarDiretorioRpsEnviados(
      LIni.ReadString('Diretorios', 'RpsEnviados', ''));
    AConfiguracao.AtualizarDiretorioRpsErro(
      LIni.ReadString('Diretorios', 'RpsErro', ''));
    AConfiguracao.AtualizarDiretorioArquivoIni(
      LIni.ReadString('Diretorios', 'ArquivoIni', ''));
    AConfiguracao.AtualizarThreadAtiva(
      LIni.ReadBool('Thread', 'Ativa', False));
  finally
    LIni.Free;
  end;
end;

end.
