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
      const ACallbackLog : TCallbackProgresso;
      out   ALista       : TListaDadosRps);
    class function Criar: IRepositorioRps;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  FireDAC.Stan.Option,
  FireDAC.Comp.Client;

class function TRepositorioRps.Criar: IRepositorioRps;
begin
  Result := TRepositorioRps.Create;
end;

procedure TRepositorioRps.BuscarRps(
  const AConexao     : IConexaoDB;
  const AMes         : Integer;
  const AAno         : Integer;
  const ACnpjUnidade : string;
  const ACallbackLog : TCallbackProgresso;
  out   ALista       : TListaDadosRps);
var
  LQuery  : TFDQuery;
  LDados  : TDadosRps;
  LIdx    : Integer;
  LBanco  : string;
  LTemErro: Boolean;
  LSQL    : string;
begin
  ALista := [];

  { Resolve banco pelo CNPJ }
  LBanco := BANCO_UNIDADE[unSede];
  case AnsiIndexText(ACnpjUnidade, [
    CNPJ_UNIDADE[unSede],
    CNPJ_UNIDADE[unUEQ],
    CNPJ_UNIDADE[unVarjota],
    CNPJ_UNIDADE[unSeisBocas]]) of
    0: LBanco := BANCO_UNIDADE[unSede];
    1: LBanco := BANCO_UNIDADE[unUEQ];
    2: LBanco := BANCO_UNIDADE[unVarjota];
    3: LBanco := BANCO_UNIDADE[unSeisBocas];
  end;

  {
    SET NOCOUNT ON suprime os result sets intermediarios dos INSERTs
    que a GravaXML executa antes do SELECT final com os dados.
    Sem isso o FireDAC trava nos result sets vazios e nao chega nos dados.
  }
  LSQL :=
    'SET NOCOUNT ON; ' +
    Format('exec %s.dbo.GravaXML %s%s,%s,%s,%s,%s',
      [LBanco,
       IntToStr(AAno),
       FormatFloat('00', AMes),
       '0', '0',
       QuotedStr('00000000000'),
       QuotedStr('99999999999')]);

  ACallbackLog('[DEBUG] SQL: ' + LSQL, False);

  AConexao.Conectar;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConexao.Conexao;
    LQuery.SQL.Text   := LSQL;
    LQuery.Open;

    ACallbackLog(Format('[DEBUG] Fields=%d RecordCount=%d Eof=%s',
      [LQuery.FieldCount, LQuery.RecordCount,
       BoolToStr(LQuery.Eof, True)]), False);

    { Verifica erro no campo RESULTADO }
    LTemErro := (not LQuery.Eof)
      and (LQuery.FindField('Resultado') <> nil)
      and (LQuery.FieldByName('Resultado').AsString <> '');
    case LTemErro of
      True: raise Exception.Create(
        'GravaXML erro: ' + LQuery.FieldByName('Resultado').AsString);
    end;

    { Le os registros — nomes conforme retorno real da GravaXML }
    LIdx := 0;
    while not LQuery.Eof do
    begin
      SetLength(ALista, LIdx + 1);
      LDados.NumeroLote                := LQuery.FieldByName('NumeroLote').AsString;
      LDados.Rps                       := LQuery.FieldByName('RPS').AsString;
      LDados.Serie                     := LQuery.FieldByName('Serie').AsString;
      LDados.DataEmissao               := LQuery.FieldByName('DataEmissao').AsDateTime;
      LDados.ValorServicos             := LQuery.FieldByName('ValorServicos').AsCurrency;
      LDados.IssRetido                 := LQuery.FieldByName('IssRetido').AsInteger;
      LDados.ItemListaServico          := LQuery.FieldByName('ItemListaServico').AsString;
      LDados.CodigoCnaeNovo            := LQuery.FieldByName('Codigo_CNAE').AsString;
      LDados.CodigoTributacaoMunicipio := LQuery.FieldByName('CodigoTributacaoMunicipio').AsString;
      LDados.Discriminacao             := LQuery.FieldByName('Discriminacao').AsString;
      LDados.CodigoMunicipioGerador    := LQuery.FieldByName('CodigodoMunicipioGerador').AsString;
      LDados.NBS                       := LQuery.FieldByName('NBS').AsString;
      LDados.CpfTomador                := LQuery.FieldByName('CPF_Tomador').AsString;
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

    ACallbackLog(Format('[DEBUG] Registros lidos: %d', [LIdx]), False);

  finally
    LQuery.Free;
  end;
end;

end.
