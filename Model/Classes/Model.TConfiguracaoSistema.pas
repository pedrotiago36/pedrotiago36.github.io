unit Model.TConfiguracaoSistema;

interface

uses
  Model.IConfiguracaoSistema;

type
  TConfiguracaoSistema = class(TInterfacedObject, IConfiguracaoSistema)
  private
    FUrlHomologacao      : string;
    FUrlProducao         : string;
    FDiretorioRpsEnviados: string;
    FDiretorioRpsErro    : string;
    FDiretorioArquivoIni : string;
    FThreadAtiva         : Boolean;
  public
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

    class function Criar: IConfiguracaoSistema;
  end;

implementation

{ TConfiguracaoSistema }

class function TConfiguracaoSistema.Criar: IConfiguracaoSistema;
begin
  Result := TConfiguracaoSistema.Create;
end;

procedure TConfiguracaoSistema.AtualizarUrlHomologacao(const AUrl: string);
begin
  FUrlHomologacao := AUrl;
end;

procedure TConfiguracaoSistema.AtualizarUrlProducao(const AUrl: string);
begin
  FUrlProducao := AUrl;
end;

procedure TConfiguracaoSistema.AtualizarDiretorioRpsEnviados(const ADiretorio: string);
begin
  FDiretorioRpsEnviados := ADiretorio;
end;

procedure TConfiguracaoSistema.AtualizarDiretorioRpsErro(const ADiretorio: string);
begin
  FDiretorioRpsErro := ADiretorio;
end;

procedure TConfiguracaoSistema.AtualizarDiretorioArquivoIni(const ADiretorio: string);
begin
  FDiretorioArquivoIni := ADiretorio;
end;

procedure TConfiguracaoSistema.AtualizarThreadAtiva(const AAtiva: Boolean);
begin
  FThreadAtiva := AAtiva;
end;

function TConfiguracaoSistema.UrlHomologacao: string;
begin
  Result := FUrlHomologacao;
end;

function TConfiguracaoSistema.UrlProducao: string;
begin
  Result := FUrlProducao;
end;

function TConfiguracaoSistema.DiretorioRpsEnviados: string;
begin
  Result := FDiretorioRpsEnviados;
end;

function TConfiguracaoSistema.DiretorioRpsErro: string;
begin
  Result := FDiretorioRpsErro;
end;

function TConfiguracaoSistema.DiretorioArquivoIni: string;
begin
  Result := FDiretorioArquivoIni;
end;

function TConfiguracaoSistema.ThreadAtiva: Boolean;
begin
  Result := FThreadAtiva;
end;

end.
