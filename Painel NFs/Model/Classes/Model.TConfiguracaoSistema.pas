unit Model.TConfiguracaoSistema;

interface

uses
  Model.IConfiguracaoSistema;

type
  TConfiguracaoSistema = class(TInterfacedObject, IConfiguracaoSistema)
  private
    FDados: TDadosConfiguracao;
  public
    procedure Atualizar(const ADados: TDadosConfiguracao);
    procedure PreencherDados(out ADados: TDadosConfiguracao);
    class function Criar: IConfiguracaoSistema;
  end;

implementation

class function TConfiguracaoSistema.Criar: IConfiguracaoSistema;
begin
  Result := TConfiguracaoSistema.Create;
end;

procedure TConfiguracaoSistema.Atualizar(const ADados: TDadosConfiguracao);
begin
  FDados := ADados;
end;

procedure TConfiguracaoSistema.PreencherDados(out ADados: TDadosConfiguracao);
begin
  ADados := FDados;
end;

end.
