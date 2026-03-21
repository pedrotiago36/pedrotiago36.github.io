unit Model.TRepositorioRps;

interface

uses
  Model.IRepositorioRps,
  Model.IConexaoDB,
  Shared.Tipos;

type
  TRepositorioRps = class(TInterfacedObject, IRepositorioRps)
  public
    procedure BuscarRps(
      const AConexao     : IConexaoDB;
      const AMes         : Integer;
      const AAno         : Integer;
      const ACnpjUnidade : string;
      out   ALista       : TListaDadosRps);
    class function Criar: IRepositorioRps;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client;

const
  SQL_BUSCAR_RPS =
    'SELECT ' +
    '  f.NumeroLote, ' +
    '  f.RPS, ' +
    '  f.Serie, ' +
    '  f.DataEmissao, ' +
    '  f.ValorServicos, ' +
    '  f.IssRetido, ' +
    '  f.ItemListaServico, ' +
    '  f.Codigo_Cnae_Novo, ' +
    '  f.CodigoTributacaoMunicipio, ' +
    '  f.Discriminacao, ' +
    '  f.CodigodoMunicipioGerador, ' +
    '  f.NBS, ' +
    '  f.Cpf_Tomador, ' +
    '  f.Tomador, ' +
    '  f.Endereco_Tomador, ' +
    '  f.Bairro_Tomador, ' +
    '  f.CEP_Tomador, ' +
    '  f.CodigoIndicadorOperacao, ' +
    '  f.CST, ' +
    '  f.cClassTrib ' +
    'FROM vw_NFSe_GeracaoXML f ' +
    'WHERE MONTH(f.DataEmissao) = :pMes ' +
    '  AND YEAR(f.DataEmissao)  = :pAno ' +
    '  AND f.CNPJ_Unidade       = :pCnpj ' +
    'ORDER BY f.RPS';

class function TRepositorioRps.Criar: IRepositorioRps;
begin
  Result := TRepositorioRps.Create;
end;

procedure TRepositorioRps.BuscarRps(
  const AConexao     : IConexaoDB;
  const AMes         : Integer;
  const AAno         : Integer;
  const ACnpjUnidade : string;
  out   ALista       : TListaDadosRps);
var
  LQuery: TFDQuery;
  LDados: TDadosRps;
  LIdx  : Integer;
begin
  ALista := [];
  AConexao.Conectar;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection         := AConexao.Conexao;
    LQuery.SQL.Text           := SQL_BUSCAR_RPS;
    LQuery.ParamByName('pMes').AsInteger  := AMes;
    LQuery.ParamByName('pAno').AsInteger  := AAno;
    LQuery.ParamByName('pCnpj').AsString  := ACnpjUnidade;
    LQuery.Open;

    LIdx := 0;
    while not LQuery.Eof do
    begin
      SetLength(ALista, LIdx + 1);
      LDados.NumeroLote                := LQuery.FieldByName('NumeroLote').AsString;
      LDados.Rps                       := LQuery.FieldByName('RPS').AsString;
      LDados.Serie                     := LQuery.FieldByName('Serie').AsString;
      LDados.DataEmissao               := LQuery.FieldByName('DataEmissao').AsDateTime;
      LDados.ValorServicos             := LQuery.FieldByName('ValorServicos').AsCurrency;
      LDados.IssRetido                 := LQuery.FieldByName('IssRetido').AsCurrency;
      LDados.ItemListaServico          := LQuery.FieldByName('ItemListaServico').AsString;
      LDados.CodigoCnaeNovo            := LQuery.FieldByName('Codigo_Cnae_Novo').AsString;
      LDados.CodigoTributacaoMunicipio := LQuery.FieldByName('CodigoTributacaoMunicipio').AsString;
      LDados.Discriminacao             := LQuery.FieldByName('Discriminacao').AsString;
      LDados.CodigoMunicipioGerador    := LQuery.FieldByName('CodigodoMunicipioGerador').AsString;
      LDados.NBS                       := LQuery.FieldByName('NBS').AsString;
      LDados.CpfTomador                := LQuery.FieldByName('Cpf_Tomador').AsString;
      LDados.Tomador                   := LQuery.FieldByName('Tomador').AsString;
      LDados.EnderecoTomador           := LQuery.FieldByName('Endereco_Tomador').AsString;
      LDados.BairroTomador             := LQuery.FieldByName('Bairro_Tomador').AsString;
      LDados.CepTomador                := LQuery.FieldByName('CEP_Tomador').AsString;
      LDados.CodigoIndicadorOperacao   := LQuery.FieldByName('CodigoIndicadorOperacao').AsString;
      LDados.CST                       := LQuery.FieldByName('CST').AsString;
      LDados.cClassTrib                := LQuery.FieldByName('cClassTrib').AsString;
      ALista[LIdx]                     := LDados;
      Inc(LIdx);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
