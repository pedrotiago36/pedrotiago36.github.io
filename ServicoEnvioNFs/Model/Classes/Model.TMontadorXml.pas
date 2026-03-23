unit Model.TMontadorXml;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.DateUtils,
  Xml.XMLIntf,
  Xml.XMLDoc,
  Shared.Tipos,
  Model.IMontadorXml;

type
  TMontadorXml = class(TInterfacedObject, IMontadorXml)
  private
    function RetiraAcentos(const ATexto: string): string;
    function SoNumeros(const ATexto: string): string;
    function FormatarValor(const AValor: Currency): string;
    function FormatarDataHora(const AData: TDateTime): string;
    function FormatarItemListaServico(const AItem: string): string;
    function GerarCodigoVerificacao: string;
    function XMLDocParaString(const ADoc: IXMLDocument): string;

    { Retorna o documento E o node ListaRps diretamente — evita FindNode com namespace }
    procedure MontarCabecalho(
      const ANumeroLote        : string;
      const ACnpj              : string;
      const AInscricaoMunicipal: string;
      const ACodigoVerificacao : string;
      const AQuantidade        : Integer;
      out   ADoc               : IXMLDocument;
      out   AListaRpsNode      : IXMLNode);

    procedure MontarRps(
      const AListaRpsNode      : IXMLNode;
      const ADados             : TDadosRps;
      const ACnpj              : string;
      const AInscricaoMunicipal: string);

    procedure MontarIdentificacaoRps(
      const AInfRpsNode: IXMLNode;
      const ADados     : TDadosRps);

    procedure MontarServicosValores(
      const AInfRpsNode : IXMLNode;
      const ADados      : TDadosRps;
      out   AServicoNode: IXMLNode);

    procedure MontarServicosDetalhes(
      const AServicoNode: IXMLNode;
      const ADados      : TDadosRps);

    procedure MontarPrestador(
      const AInfRpsNode        : IXMLNode;
      const ACnpj              : string;
      const AInscricaoMunicipal: string);

    procedure MontarTomador(
      const AInfRpsNode: IXMLNode;
      const ADados     : TDadosRps);

    procedure MontarIbsCbs(
      const AInfRpsNode: IXMLNode;
      const ADados     : TDadosRps);

    function ResolverPastaSaida(
      const ABase: string;
      const AData: TDateTime;
      const AModo: TModoEnvio): string;

    function SalvarXml(
      const AXML    : string;
      const APasta  : string;
      const ANumLote: string;
      const AIdx    : Integer): string;

    procedure MontarLotes(
      const ALista      : TListaDadosRps;
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      out   AResultados : TArray<TResultadoXml>);

    procedure MontarIndividual(
      const ALista      : TListaDadosRps;
      const AConfig     : TDadosConfiguracaoEnvio;
      const ACallbackLog: TCallbackProgresso;
      out   AResultados : TArray<TResultadoXml>);

  public
    procedure Montar(
      const ALista        : TListaDadosRps;
      const AConfiguracoes: TDadosConfiguracaoEnvio;
      const ACallbackLog  : TCallbackProgresso;
      out   AResultados   : TArray<TResultadoXml>);
    class function Criar: IMontadorXml;
  end;

implementation

const
  MAX_RPS_LOTE = 50;

class function TMontadorXml.Criar: IMontadorXml;
begin
  Result := TMontadorXml.Create;
end;

{ -- Helpers ----------------------------------------------------------------- }

function TMontadorXml.RetiraAcentos(const ATexto: string): string;
const
  COM: string = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  SEM: string = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
var
  LI, LP: Integer;
begin
  Result := ATexto;
  for LI := 1 to Length(Result) do
  begin
    LP := System.Pos(Result[LI], COM);
    case LP > 0 of
      True: Result[LI] := SEM[LP];
    end;
  end;
end;

function TMontadorXml.SoNumeros(const ATexto: string): string;
var
  LI: Integer;
begin
  Result := '';
  for LI := 1 to Length(ATexto) do
    case CharInSet(ATexto[LI], ['0'..'9']) of
      True: Result := Result + ATexto[LI];
    end;
end;

function TMontadorXml.FormatarValor(const AValor: Currency): string;
begin
  Result := StringReplace(FormatFloat('0.00', AValor), ',', '.', [rfReplaceAll]);
end;

function TMontadorXml.FormatarDataHora(const AData: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', AData) + 'T' +
            FormatDateTime('hh:nn:ss', Now);
end;

function TMontadorXml.FormatarItemListaServico(const AItem: string): string;
var
  LLimpo: string;
  LI    : Integer;
begin
  LLimpo := '';
  for LI := 1 to Length(AItem) do
    case CharInSet(AItem[LI], ['0'..'9']) of
      True: LLimpo := LLimpo + AItem[LI];
    end;

  case Pos('.', AItem) > 0 of
    True: begin Result := AItem; Exit; end;
  end;

  case Length(LLimpo) of
    1: Result := '0' + LLimpo + '.00';
    2: Result := LLimpo + '.00';
    3: Result := '0' + LLimpo[1] + '.' + Copy(LLimpo, 2, 2);
    4: Result := Copy(LLimpo, 1, 2) + '.' + Copy(LLimpo, 3, 2);
  else
    case Length(LLimpo) >= 6 of
      True : Result := Copy(LLimpo,1,2)+'.'+Copy(LLimpo,3,2)+'.'+Copy(LLimpo,5,2);
      False: Result := LLimpo;
    end;
  end;
end;

function TMontadorXml.GerarCodigoVerificacao: string;
begin
  Result := IntToStr(Random(900000) + 100000);
end;

function TMontadorXml.XMLDocParaString(const ADoc: IXMLDocument): string;
var
  LStream: TStringStream;
begin
  LStream := TStringStream.Create('', TEncoding.UTF8);
  try
    ADoc.SaveToStream(LStream);
    Result := LStream.DataString;
  finally
    LStream.Free;
  end;
end;

{ -- Cabecalho --------------------------------------------------------------- }

procedure TMontadorXml.MontarCabecalho(
  const ANumeroLote        : string;
  const ACnpj              : string;
  const AInscricaoMunicipal: string;
  const ACodigoVerificacao : string;
  const AQuantidade        : Integer;
  out   ADoc               : IXMLDocument;
  out   AListaRpsNode      : IXMLNode);
var
  LDoc    : TXMLDocument;
  LRaiz   : IXMLNode;
  LLoteRps: IXMLNode;
  LNode   : IXMLNode;
begin
  LDoc := TXMLDocument.Create(nil);
  LDoc.Active   := True;
  LDoc.Version  := '1.0';
  LDoc.Encoding := 'UTF-8';
  LDoc.Options  := LDoc.Options - [doNodeAutoIndent];
  ADoc := LDoc;

  LRaiz := ADoc.AddChild('ns3:EnviarLoteRpsEnvio');
  LRaiz.Attributes['xmlns:ns3'] := 'http://www.ginfes.com.br/servico_enviar_lote_rps_envio_v03.xsd';
  LRaiz.Attributes['xmlns:ns4'] := 'http://www.ginfes.com.br/tipos_v03.xsd';

  LLoteRps := LRaiz.AddChild('ns3:LoteRps');
  LLoteRps.Attributes['Id'] := 'Lote' + ACodigoVerificacao;

  LNode      := LLoteRps.AddChild('ns4:NumeroLote');
  LNode.Text := ANumeroLote;

  LNode      := LLoteRps.AddChild('ns4:Cnpj');
  LNode.Text := ACnpj;

  LNode      := LLoteRps.AddChild('ns4:InscricaoMunicipal');
  LNode.Text := AInscricaoMunicipal;

  LNode      := LLoteRps.AddChild('ns4:QuantidadeRps');
  LNode.Text := IntToStr(AQuantidade);

  { Guarda referencia direta ao ListaRps — FindNode com namespace falha no TXMLDocument }
  AListaRpsNode := LLoteRps.AddChild('ns4:ListaRps');
end;

{ -- Nos do RPS -------------------------------------------------------------- }

procedure TMontadorXml.MontarIdentificacaoRps(
  const AInfRpsNode: IXMLNode;
  const ADados     : TDadosRps);
var
  LIdent: IXMLNode;
  LNode : IXMLNode;
begin
  LIdent := AInfRpsNode.AddChild('IdentificacaoRps');

  LNode      := LIdent.AddChild('Numero');
  LNode.Text := ADados.Rps;

  LNode      := LIdent.AddChild('Serie');
  LNode.Text := ADados.Serie;

  LNode      := LIdent.AddChild('Tipo');
  LNode.Text := '1';

  LNode      := AInfRpsNode.AddChild('DataEmissao');
  LNode.Text := FormatarDataHora(ADados.DataEmissao);

  LNode      := AInfRpsNode.AddChild('NaturezaOperacao');
  LNode.Text := '1';

  LNode      := AInfRpsNode.AddChild('RegimeEspecialTributacao');
  LNode.Text := '4';

  LNode      := AInfRpsNode.AddChild('OptanteSimplesNacional');
  LNode.Text := '2';

  LNode      := AInfRpsNode.AddChild('IncentivadorCultural');
  LNode.Text := '2';

  LNode      := AInfRpsNode.AddChild('Status');
  LNode.Text := '1';
end;

procedure TMontadorXml.MontarServicosValores(
  const AInfRpsNode : IXMLNode;
  const ADados      : TDadosRps;
  out   AServicoNode: IXMLNode);
var
  LValores: IXMLNode;
  LNode   : IXMLNode;
begin
  AServicoNode := AInfRpsNode.AddChild('ns4:Servico');
  LValores     := AServicoNode.AddChild('ns4:Valores');

  LNode      := LValores.AddChild('ns4:ValorServicos');
  LNode.Text := FormatarValor(ADados.ValorServicos);

  LNode      := LValores.AddChild('ns4:IssRetido');
  LNode.Text := '2';

  LNode      := LValores.AddChild('ns4:ValorIss');
  LNode.Text := '0.00';

  LNode      := LValores.AddChild('ns4:BaseCalculo');
  LNode.Text := FormatarValor(ADados.ValorServicos);

  LNode      := LValores.AddChild('ns4:Aliquota');
  LNode.Text := '0.02';
end;

procedure TMontadorXml.MontarServicosDetalhes(
  const AServicoNode: IXMLNode;
  const ADados      : TDadosRps);
var
  LNode: IXMLNode;
begin
  LNode      := AServicoNode.AddChild('ns4:ItemListaServico');
  LNode.Text := FormatarItemListaServico(ADados.ItemListaServico);

  LNode      := AServicoNode.AddChild('ns4:CodigoCnae');
  LNode.Text := ADados.CodigoCnaeNovo;

  LNode      := AServicoNode.AddChild('ns4:CodigoTributacaoMunicipio');
  LNode.Text := ADados.CodigoTributacaoMunicipio;

  LNode      := AServicoNode.AddChild('ns4:Discriminacao');
  LNode.Text := RetiraAcentos(ADados.Discriminacao);

  LNode      := AServicoNode.AddChild('ns4:CodigoMunicipio');
  LNode.Text := ADados.CodigoMunicipioGerador;

  LNode      := AServicoNode.AddChild('ns4:CodigoNbs');
  LNode.Text := ADados.NBS;
end;

procedure TMontadorXml.MontarPrestador(
  const AInfRpsNode        : IXMLNode;
  const ACnpj              : string;
  const AInscricaoMunicipal: string);
var
  LPrest: IXMLNode;
  LNode : IXMLNode;
begin
  LPrest := AInfRpsNode.AddChild('ns4:Prestador');

  LNode      := LPrest.AddChild('ns4:Cnpj');
  LNode.Text := ACnpj;

  LNode      := LPrest.AddChild('ns4:InscricaoMunicipal');
  LNode.Text := AInscricaoMunicipal;
end;

procedure TMontadorXml.MontarTomador(
  const AInfRpsNode: IXMLNode;
  const ADados     : TDadosRps);
var
  LTomador: IXMLNode;
  LIdent  : IXMLNode;
  LCpfCnpj: IXMLNode;
  LEndNode: IXMLNode;
  LNode   : IXMLNode;
  LNumero : string;
begin
  LTomador := AInfRpsNode.AddChild('ns4:Tomador');
  LIdent   := LTomador.AddChild('ns4:IdentificacaoTomador');
  LCpfCnpj := LIdent.AddChild('ns4:CpfCnpj');

  LNode      := LCpfCnpj.AddChild('ns4:Cpf');
  LNode.Text := SoNumeros(ADados.CpfTomador);

  LNode      := LTomador.AddChild('ns4:RazaoSocial');
  LNode.Text := RetiraAcentos(ADados.Tomador);

  LEndNode := LTomador.AddChild('ns4:Endereco');

  LNode      := LEndNode.AddChild('ns4:Endereco');
  LNode.Text := RetiraAcentos(ADados.EnderecoTomador);

  LNumero := SoNumeros(ADados.EnderecoTomador);
  case LNumero.IsEmpty of
    True: LNumero := 'S/N';
  end;

  LNode      := LEndNode.AddChild('ns4:Numero');
  LNode.Text := LNumero;

  LNode      := LEndNode.AddChild('ns4:Bairro');
  LNode.Text := RetiraAcentos(ADados.BairroTomador);

  LNode      := LEndNode.AddChild('ns4:CodigoMunicipio');
  LNode.Text := '2304400';

  LNode      := LEndNode.AddChild('ns4:Uf');
  LNode.Text := 'CE';

  LNode      := LEndNode.AddChild('ns4:Cep');
  LNode.Text := SoNumeros(ADados.CepTomador);
end;

procedure TMontadorXml.MontarIbsCbs(
  const AInfRpsNode: IXMLNode;
  const ADados     : TDadosRps);
var
  LIbs    : IXMLNode;
  LValores: IXMLNode;
  LTrib   : IXMLNode;
  LGrupo  : IXMLNode;
  LNode   : IXMLNode;
begin
  LIbs := AInfRpsNode.AddChild('ns4:IbsCbs');

  LNode      := LIbs.AddChild('ns4:CodigoIndicadorFinalidadeNFSe');
  LNode.Text := '0';

  LNode      := LIbs.AddChild('ns4:CodigoIndicadorOperacaoUsoConsumoPessoal');
  LNode.Text := '0';

  LNode      := LIbs.AddChild('ns4:CodigoIndicadorOperacao');
  LNode.Text := ADados.CodigoIndicadorOperacao;

  LNode      := LIbs.AddChild('ns4:IndDest');
  LNode.Text := '1';

  LValores := LIbs.AddChild('ns4:Valores');
  LTrib    := LValores.AddChild('ns4:TributosIbsCbs');
  LGrupo   := LTrib.AddChild('ns4:GrupoIbsCbs');

  LNode      := LGrupo.AddChild('ns4:CST');
  LNode.Text := ADados.CST;

  LNode      := LGrupo.AddChild('ns4:CodigoClassTrib');
  LNode.Text := ADados.cClassTrib;
end;

procedure TMontadorXml.MontarRps(
  const AListaRpsNode      : IXMLNode;
  const ADados             : TDadosRps;
  const ACnpj              : string;
  const AInscricaoMunicipal: string);
var
  LRpsNode    : IXMLNode;
  LInfRps     : IXMLNode;
  LServicoNode: IXMLNode;
begin
  LRpsNode := AListaRpsNode.AddChild('Rps');
  LInfRps  := LRpsNode.AddChild('InfRps');

  MontarIdentificacaoRps(LInfRps, ADados);
  MontarServicosValores(LInfRps, ADados, LServicoNode);
  MontarServicosDetalhes(LServicoNode, ADados);
  MontarPrestador(LInfRps, ACnpj, AInscricaoMunicipal);
  MontarTomador(LInfRps, ADados);
  MontarIbsCbs(LInfRps, ADados);
end;

{ -- Persistencia ------------------------------------------------------------ }

function TMontadorXml.ResolverPastaSaida(
  const ABase: string;
  const AData: TDateTime;
  const AModo: TModoEnvio): string;
const
  SUBPASTA: array[TModoEnvio] of string = ('Individual', 'Lote');
begin
  Result := TPath.Combine(ABase,
    Format('%d\%s\%s\%s', [
      YearOf(AData),
      FormatFloat('00', MonthOf(AData)),
      FormatFloat('00', DayOf(AData)),
      SUBPASTA[AModo]
    ]));
  ForceDirectories(Result);
end;

function TMontadorXml.SalvarXml(
  const AXML    : string;
  const APasta  : string;
  const ANumLote: string;
  const AIdx    : Integer): string;
var
  LNomeArq: string;
  LWriter : TStreamWriter;
begin
  LNomeArq := TPath.Combine(APasta,
    Format('NFSe_%s_%s.xml', [ANumLote, FormatFloat('000', AIdx)]));

  LWriter := TStreamWriter.Create(LNomeArq, False, TEncoding.UTF8);
  try
    LWriter.Write(AXML);
  finally
    LWriter.Free;
  end;

  Result := LNomeArq;
end;

{ -- Montagem em Lote -------------------------------------------------------- }

procedure TMontadorXml.MontarLotes(
  const ALista      : TListaDadosRps;
  const AConfig     : TDadosConfiguracaoEnvio;
  const ACallbackLog: TCallbackProgresso;
  out   AResultados : TArray<TResultadoXml>);
var
  LIdxGeral    : Integer;
  LIdxArq      : Integer;
  LIdxNoLote   : Integer;
  LQtdTotal    : Integer;
  LQtdNesteLote: Integer;
  LDoc         : IXMLDocument;
  LListaRpsNode: IXMLNode;
  LCodVerif    : string;
  LPasta       : string;
  LXmlStr      : string;
  LCaminho     : string;
  LResultado   : TResultadoXml;
begin
  AResultados := [];
  LQtdTotal   := Length(ALista);
  LIdxGeral   := 0;
  LIdxArq     := 0;

  case LQtdTotal = 0 of
    True:
    begin
      ACallbackLog('Nenhum RPS encontrado para o periodo.', False);
      Exit;
    end;
  end;

  ACallbackLog(Format('Iniciando montagem em LOTE — %d RPS encontrados.', [LQtdTotal]), False);

  LPasta := ResolverPastaSaida(AConfig.DiretorioBase, ALista[0].DataEmissao, meLote);

  while LIdxGeral < LQtdTotal do
  begin
    LCodVerif     := GerarCodigoVerificacao;
    LIdxNoLote    := 0;
    Inc(LIdxArq);

    LQtdNesteLote := LQtdTotal - LIdxGeral;
    case LQtdNesteLote > MAX_RPS_LOTE of
      True: LQtdNesteLote := MAX_RPS_LOTE;
    end;

    ACallbackLog(Format('[Lote %d] Montando %d RPS...', [LIdxArq, LQtdNesteLote]), False);

    try
      MontarCabecalho(
        ALista[LIdxGeral].NumeroLote,
        AConfig.CnpjUnidade,
        AConfig.InscricaoMunicipal,
        LCodVerif,
        LQtdNesteLote,
        LDoc,
        LListaRpsNode);

      while (LIdxNoLote < LQtdNesteLote) and (LIdxGeral < LQtdTotal) do
      begin
        MontarRps(LListaRpsNode, ALista[LIdxGeral],
          AConfig.CnpjUnidade, AConfig.InscricaoMunicipal);
        Inc(LIdxNoLote);
        Inc(LIdxGeral);
      end;

      LXmlStr  := XMLDocParaString(LDoc);
      LCaminho := SalvarXml(LXmlStr, LPasta,
        ALista[LIdxGeral - 1].NumeroLote, LIdxArq);

      LResultado.Sucesso        := True;
      LResultado.CaminhoArquivo := LCaminho;
      LResultado.MensagemErro   := '';
      LResultado.QuantidadeRps  := LQtdNesteLote;
      AResultados               := AResultados + [LResultado];

      ACallbackLog(Format('[Lote %d] Salvo: %s', [LIdxArq, LCaminho]), False);

    except
      on E: Exception do
      begin
        LResultado.Sucesso        := False;
        LResultado.CaminhoArquivo := '';
        LResultado.MensagemErro   := E.Message;
        LResultado.QuantidadeRps  := 0;
        AResultados               := AResultados + [LResultado];
        ACallbackLog(Format('[Lote %d] ERRO: %s', [LIdxArq, E.Message]), True);
        Inc(LIdxGeral, LQtdNesteLote);
      end;
    end;
  end;

  ACallbackLog(Format('Lote concluido. %d arquivo(s) gerado(s).', [LIdxArq]), False);
end;

{ -- Montagem Individual ----------------------------------------------------- }

procedure TMontadorXml.MontarIndividual(
  const ALista      : TListaDadosRps;
  const AConfig     : TDadosConfiguracaoEnvio;
  const ACallbackLog: TCallbackProgresso;
  out   AResultados : TArray<TResultadoXml>);
var
  LIdx         : Integer;
  LQtdTotal    : Integer;
  LDoc         : IXMLDocument;
  LListaRpsNode: IXMLNode;
  LCodVerif    : string;
  LPasta       : string;
  LXmlStr      : string;
  LCaminho     : string;
  LResultado   : TResultadoXml;
begin
  AResultados := [];
  LQtdTotal   := Length(ALista);

  case LQtdTotal = 0 of
    True:
    begin
      ACallbackLog('Nenhum RPS encontrado para o periodo.', False);
      Exit;
    end;
  end;

  ACallbackLog(Format('Iniciando montagem INDIVIDUAL — %d RPS.', [LQtdTotal]), False);

  LPasta := ResolverPastaSaida(AConfig.DiretorioBase,
    ALista[0].DataEmissao, meIndividual);

  for LIdx := 0 to LQtdTotal - 1 do
  begin
    LCodVerif := GerarCodigoVerificacao;
    try
      MontarCabecalho(
        ALista[LIdx].NumeroLote,
        AConfig.CnpjUnidade,
        AConfig.InscricaoMunicipal,
        LCodVerif,
        1,
        LDoc,
        LListaRpsNode);

      MontarRps(LListaRpsNode, ALista[LIdx],
        AConfig.CnpjUnidade, AConfig.InscricaoMunicipal);

      LXmlStr  := XMLDocParaString(LDoc);
      LCaminho := SalvarXml(LXmlStr, LPasta,
        ALista[LIdx].NumeroLote, LIdx + 1);

      LResultado.Sucesso        := True;
      LResultado.CaminhoArquivo := LCaminho;
      LResultado.MensagemErro   := '';
      LResultado.QuantidadeRps  := 1;
      AResultados               := AResultados + [LResultado];

      ACallbackLog(Format('[%d/%d] RPS %s salvo: %s',
        [LIdx + 1, LQtdTotal, ALista[LIdx].Rps, LCaminho]), False);

    except
      on E: Exception do
      begin
        LResultado.Sucesso        := False;
        LResultado.CaminhoArquivo := '';
        LResultado.MensagemErro   := E.Message;
        LResultado.QuantidadeRps  := 0;
        AResultados               := AResultados + [LResultado];
        ACallbackLog(Format('[%d/%d] RPS %s ERRO: %s',
          [LIdx + 1, LQtdTotal, ALista[LIdx].Rps, E.Message]), True);
      end;
    end;
  end;

  ACallbackLog(Format('Individual concluido. %d XML(s) gerado(s).', [LQtdTotal]), False);
end;

{ -- Ponto de entrada -------------------------------------------------------- }

procedure TMontadorXml.Montar(
  const ALista        : TListaDadosRps;
  const AConfiguracoes: TDadosConfiguracaoEnvio;
  const ACallbackLog  : TCallbackProgresso;
  out   AResultados   : TArray<TResultadoXml>);
begin
  case AConfiguracoes.ModoEnvio of
    meLote      : MontarLotes(ALista, AConfiguracoes, ACallbackLog, AResultados);
    meIndividual: MontarIndividual(ALista, AConfiguracoes, ACallbackLog, AResultados);
  end;
end;

end.
