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
  case ACaminho.IsEmpty of
    False: ForceDirectories(ACaminho);
  end;
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
  LIni    : TMemIniFile;
  LDados  : TDadosConfiguracao;
  LArquivo: string;
begin
  AConfiguracao.PreencherDados(LDados);

  case LDados.DiretorioArquivoIni.IsEmpty of
    True : LArquivo := 'NFSe_Servico.ini';
    False: begin
      GarantirDiretorio(LDados.DiretorioArquivoIni);
      LArquivo := TPath.Combine(LDados.DiretorioArquivoIni, 'NFSe_Servico.ini');
    end;
  end;

  LIni := TMemIniFile.Create(LArquivo);
  try
    { Ambiente ativo }
    LIni.WriteString('WebService', 'AmbienteAtivo', LDados.AmbienteAtivo);

    { Seções com indicador visual de ativo/inativo }
    case LDados.AmbienteAtivo = 'Homologacao' of
      True: begin
        LIni.WriteString('Homologacao', 'Url',    LDados.UrlHomologacao);
        LIni.WriteString('Homologacao', 'Status', '>>> ATIVO <<<');
        LIni.WriteString('Producao',    'Url',    LDados.UrlProducao);
        LIni.WriteString('Producao',    'Status', '--- inativo ---');
      end;
      False: begin
        LIni.WriteString('Homologacao', 'Url',    LDados.UrlHomologacao);
        LIni.WriteString('Homologacao', 'Status', '--- inativo ---');
        LIni.WriteString('Producao',    'Url',    LDados.UrlProducao);
        LIni.WriteString('Producao',    'Status', '>>> ATIVO <<<');
      end;
    end;

    { Diretórios }
    LIni.WriteString('Diretorios', 'RpsEnviados',   LDados.DiretorioRpsEnviados);
    LIni.WriteString('Diretorios', 'RpsErro',        LDados.DiretorioRpsErro);
    LIni.WriteString('Diretorios', 'RpsCancelados',  LDados.DiretorioRpsCancelados);
    LIni.WriteString('Diretorios', 'ArquivoIni',     LDados.DiretorioArquivoIni);

    { Thread }
    LIni.WriteBool  ('Thread',  'Ativa',     LDados.ThreadAtiva);
    LIni.WriteString('Config',  'DiaEnvio',  LDados.DataEnvio);

    LIni.UpdateFile;
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
