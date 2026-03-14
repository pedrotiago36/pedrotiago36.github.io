unit Model.TGravarArquivos;

interface

uses
  Model.IGravarArquivos,
  Model.IConfiguracaoSistema;

type
  TGravarArquivos = class(TInterfacedObject, IGravarArquivos)
  private
    function MontarCaminho(const ABase: string;
      const AAno, AMes: Word): string;
    procedure GarantirDiretorio(const ACaminho: string);
    procedure EscreverLinha(const ACaminho, AConteudo: string);
  public
    procedure GravarIni(const AConfiguracao: IConfiguracaoSistema);
    procedure GravarRpsEnviado(const AConteudo: string; const AAno, AMes: Word);
    procedure GravarRpsErro(const AConteudo: string; const AAno, AMes: Word);
    class function Criar: IGravarArquivos;
  end;

implementation

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  System.Classes;

class function TGravarArquivos.Criar: IGravarArquivos;
begin
  Result := TGravarArquivos.Create;
end;

function TGravarArquivos.MontarCaminho(const ABase: string;
  const AAno, AMes: Word): string;
begin
  Result := TPath.Combine(ABase,
    Format('%d\%s', [AAno, FormatFloat('00', AMes)]));
end;

procedure TGravarArquivos.GarantirDiretorio(const ACaminho: string);
begin
  TDirectory.CreateDirectory(ACaminho);
end;

procedure TGravarArquivos.EscreverLinha(const ACaminho, AConteudo: string);
var
  LWriter: TStreamWriter;
begin
  LWriter := TStreamWriter.Create(ACaminho, True, TEncoding.UTF8);
  try
    LWriter.WriteLine(AConteudo);
  finally
    LWriter.Free;
  end;
end;

procedure TGravarArquivos.GravarIni(const AConfiguracao: IConfiguracaoSistema);
var
  LIni  : TIniFile;
  LDados: TDadosConfiguracao;
begin
  AConfiguracao.PreencherDados(LDados);
  GarantirDiretorio(LDados.DiretorioArquivoIni);
  LIni := TIniFile.Create(
    TPath.Combine(LDados.DiretorioArquivoIni, 'NFSe_Servico.ini'));
  try
    LIni.WriteString('WebService', 'UrlHomologacao', LDados.UrlHomologacao);
    LIni.WriteString('WebService', 'UrlProducao',    LDados.UrlProducao);
    LIni.WriteString('Diretorios', 'RpsEnviados',    LDados.DiretorioRpsEnviados);
    LIni.WriteString('Diretorios', 'RpsErro',        LDados.DiretorioRpsErro);
    LIni.WriteString('Diretorios', 'ArquivoIni',     LDados.DiretorioArquivoIni);
    LIni.WriteBool  ('Thread',     'Ativa',          LDados.ThreadAtiva);
  finally
    LIni.Free;
  end;
end;

procedure TGravarArquivos.GravarRpsEnviado(const AConteudo: string;
  const AAno, AMes: Word);
var
  LDir, LArq: string;
begin
  LDir := MontarCaminho('', AAno, AMes);
  GarantirDiretorio(LDir);
  LArq := TPath.Combine(LDir,
    Format('rps_enviados_%s_%s.txt',
      [FormatFloat('0000', AAno), FormatFloat('00', AMes)]));
  EscreverLinha(LArq, AConteudo);
end;

procedure TGravarArquivos.GravarRpsErro(const AConteudo: string;
  const AAno, AMes: Word);
var
  LDir, LArq: string;
begin
  LDir := MontarCaminho('', AAno, AMes);
  GarantirDiretorio(LDir);
  LArq := TPath.Combine(LDir,
    Format('rps_erro_%s_%s.txt',
      [FormatFloat('0000', AAno), FormatFloat('00', AMes)]));
  EscreverLinha(LArq, AConteudo);
end;

end.
