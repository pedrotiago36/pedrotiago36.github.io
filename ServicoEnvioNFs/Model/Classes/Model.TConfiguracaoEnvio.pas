unit Model.TConfiguracaoEnvio;

interface

uses
  Model.IConfiguracaoEnvio,
  Shared.Tipos;

type
  TConfiguracaoEnvio = class(TInterfacedObject, IConfiguracaoEnvio)
  private
    FDados: TDadosConfiguracaoEnvio;
  public
    procedure Atualizar(const ADados: TDadosConfiguracaoEnvio);
    procedure PreencherDados(out ADados: TDadosConfiguracaoEnvio);
    class function Criar: IConfiguracaoEnvio;
  end;

implementation

class function TConfiguracaoEnvio.Criar: IConfiguracaoEnvio;
begin
  Result := TConfiguracaoEnvio.Create;
end;

procedure TConfiguracaoEnvio.Atualizar(const ADados: TDadosConfiguracaoEnvio);
begin
  FDados := ADados;
end;

procedure TConfiguracaoEnvio.PreencherDados(out ADados: TDadosConfiguracaoEnvio);
begin
  ADados := FDados;
end;

end.
