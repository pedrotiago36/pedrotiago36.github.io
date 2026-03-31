unit Model.TMenuTree;

interface

uses
  Model.IMenuItem,
  System.SysUtils;

type
  TMenuTree = class(TInterfacedObject, IMenuModel)
  public
    function GetMenuItems: TArray<TMenuItemRec>;
  end;

function NewMenuModel: IMenuModel;

implementation

function NewMenuModel: IMenuModel;
begin
  Result := TMenuTree.Create;
end;

{ TMenuTree }

function TMenuTree.GetMenuItems: TArray<TMenuItemRec>;

  function Item(const AID, AParentID, ACaption, AIcon, ARoute, ABreadPath: string;
    AEnabled: Boolean): TMenuItemRec;
  begin
    Result.ID        := AID;
    Result.ParentID  := AParentID;
    Result.Caption   := ACaption;
    Result.Icon      := AIcon;
    Result.Route     := ARoute;
    Result.BreadPath := ABreadPath;
    Result.Enabled   := AEnabled;
  end;

const
  { SVG paths dos ícones (Feather Icons, viewBox 0 0 24 24) }
  ICO_USER     = 'M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 3a4 4 0 100 8 4 4 0 000-8z';
  ICO_USERS    = 'M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75';
  ICO_KEY      = 'M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4';
  ICO_TRUCK    = 'M1 3h15v13H1zM16 8h4l3 3v5h-7V8zM5.5 19a1.5 1.5 0 100-3 1.5 1.5 0 000 3zM18.5 19a1.5 1.5 0 100-3 1.5 1.5 0 000 3z';
  ICO_DOLLAR   = 'M12 1v22M17 5H9.5a3.5 3.5 0 100 7h5a3.5 3.5 0 110 7H6';
  ICO_CHART    = 'M18 20V10M12 20V4M6 20v-6';
  ICO_GEAR     = 'M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z';
  ICO_DOC      = 'M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8zM14 2v6h6M16 13H8M16 17H8M10 9H8';
  ICO_WRENCH   = 'M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z';
  ICO_TAG      = 'M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82zM7 7h.01';
  ICO_LOCATION = 'M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0zM12 7a3 3 0 100 6 3 3 0 000-6z';
  ICO_CODE     = 'M16 18l6-6-6-6M8 6l-6 6 6 6';
  ICO_ARCHIVE  = 'M21 8v13H3V8M1 3h22v5H1zM10 12h4';

  { Grupos }
  GRP_CAD   = 'grp-cad';
  GRP_OPER  = 'grp-oper';
  GRP_DOC   = 'grp-doc';
  GRP_FROTA = 'grp-frota';
  GRP_FIN   = 'grp-fin';
  GRP_COM   = 'grp-com';
  GRP_RH    = 'grp-rh';
  GRP_RASTR = 'grp-rastr';
  GRP_REL   = 'grp-rel';
  GRP_INT   = 'grp-int';
  GRP_CFG   = 'grp-cfg';
  GRP_UTIL  = 'grp-util';

  CAD  = 'Cadastros';
  OPER = 'Operacional';
  DOC  = 'Doc. Fiscais';
  FROT = 'Frota';
  FIN  = 'Financeiro';
  COM  = 'Fretes/Comercial';
  RH   = 'Motoristas/RH';
  RAST = 'Rastreamento';
  REL  = 'Relat'#243'rios';
  INT  = 'Integra'#231#245'es';
  CFG  = 'Configura'#231#245'es';
  UTIL = 'Utilit'#225'rios';

begin
  SetLength(Result, 0);

  { ══════════════════════════════════════════════════════ }
  { 1. CADASTROS                                          }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_CAD, '', CAD, ICO_USER, '', '', True)];
  Result := Result + [Item('cad-cli',  GRP_CAD, 'Clientes',                   ICO_USER,  'cad.clientes',   CAD+' > Clientes',                   False)];
  Result := Result + [Item('cad-rem',  GRP_CAD, 'Remetentes',                 ICO_USER,  'cad.remetentes', CAD+' > Remetentes',                 False)];
  Result := Result + [Item('cad-dest', GRP_CAD, 'Destinat'#225'rios',         ICO_USER,  'cad.destinatarios', CAD+' > Destinat'#225'rios',      False)];
  Result := Result + [Item('cad-for',  GRP_CAD, 'Fornecedores',               ICO_USER,  'cad.fornecedores', CAD+' > Fornecedores',             False)];
  Result := Result + [Item('cad-mot',  GRP_CAD, 'Motoristas',                 ICO_USERS, 'cad.motoristas', CAD+' > Motoristas',                 False)];
  Result := Result + [Item('cad-vei',  GRP_CAD, 'Ve'#237'culos',              ICO_TRUCK, 'cad.veiculos',   CAD+' > Ve'#237'culos',              False)];
  Result := Result + [Item('cad-tvei', GRP_CAD, 'Tipos de Ve'#237'culos',     ICO_TRUCK, 'cad.tipoveiculos', CAD+' > Tipos de Ve'#237'culos',   False)];
  Result := Result + [Item('cad-prod', GRP_CAD, 'Produtos / Mercadorias',     ICO_ARCHIVE,'cad.produtos',  CAD+' > Produtos / Mercadorias',     False)];
  Result := Result + [Item('cad-fil',  GRP_CAD, 'Filiais',                    ICO_GEAR,  'cad.filiais',    CAD+' > Filiais',                    False)];
  Result := Result + [Item('cad-usr',  GRP_CAD, 'Usu'#225'rios',              ICO_USER,  'cad.usuarios',   CAD+' > Usu'#225'rios',              False)];
  Result := Result + [Item('cad-acl',  GRP_CAD, 'Permiss'#245'es de Acesso',  ICO_KEY,   'cad.permissoes', CAD+' > Permiss'#245'es de Acesso',  False)];
  Result := Result + [Item('cad-tab',  GRP_CAD, 'Tabelas de Frete',           ICO_TAG,   'cad.tabfrete',   CAD+' > Tabelas de Frete',           False)];
  Result := Result + [Item('cad-rot',  GRP_CAD, 'Rotas / Regi'#245'es / Cidades', ICO_LOCATION, 'cad.rotas', CAD+' > Rotas / Regi'#245'es / Cidades', False)];
  Result := Result + [Item('cad-nat',  GRP_CAD, 'Natureza da Opera'#231#227'o', ICO_DOC,  'cad.natureza',   CAD+' > Natureza da Opera'#231#227'o', False)];
  Result := Result + [Item('cad-seg',  GRP_CAD, 'Seguradoras',                ICO_DOC,   'cad.seguradoras', CAD+' > Seguradoras',               False)];

  { ══════════════════════════════════════════════════════ }
  { 2. OPERACIONAL                                        }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_OPER, '', OPER, ICO_TRUCK, '', '', True)];
  Result := Result + [Item('op-col',  GRP_OPER, 'Ordem de Coleta',                  ICO_TRUCK,  'op.coleta',       OPER+' > Ordem de Coleta',                  False)];
  Result := Result + [Item('op-otr',  GRP_OPER, 'Ordem de Transporte',              ICO_TRUCK,  'op.transporte',   OPER+' > Ordem de Transporte',              False)];
  Result := Result + [Item('op-vgm',  GRP_OPER, 'Planejamento de Viagem',           ICO_LOCATION,'op.viagem',      OPER+' > Planejamento de Viagem',           False)];
  Result := Result + [Item('op-rtz',  GRP_OPER, 'Roteiriza'#231#227'o',             ICO_LOCATION,'op.roteirizacao', OPER+' > Roteiriza'#231#227'o',            False)];
  Result := Result + [Item('op-cld',  GRP_OPER, 'Consolida'#231#227'o de Carga',    ICO_ARCHIVE, 'op.consolidacao', OPER+' > Consolida'#231#227'o de Carga',   False)];
  Result := Result + [Item('op-dsp',  GRP_OPER, 'Despacho de Carga',                ICO_TRUCK,  'op.despacho',     OPER+' > Despacho de Carga',                False)];
  Result := Result + [Item('op-bxe',  GRP_OPER, 'Baixa de Entrega',                 ICO_DOC,    'op.baixa',        OPER+' > Baixa de Entrega',                 False)];
  Result := Result + [Item('op-oce',  GRP_OPER, 'Ocorr'#234'ncias de Entrega',      ICO_DOC,    'op.ocorrencias',  OPER+' > Ocorr'#234'ncias de Entrega',      False)];
  Result := Result + [Item('op-pod',  GRP_OPER, 'Comprovante de Entrega (POD)',      ICO_DOC,    'op.pod',          OPER+' > Comprovante de Entrega (POD)',      False)];
  Result := Result + [Item('op-emb',  GRP_OPER, 'Controle de Embarque',             ICO_TRUCK,  'op.embarque',     OPER+' > Controle de Embarque',             False)];
  Result := Result + [Item('op-crx',  GRP_OPER, 'Cross Docking',                    ICO_TRUCK,  'op.crossdocking', OPER+' > Cross Docking',                    False)];

  { ══════════════════════════════════════════════════════ }
  { 3. DOCUMENTOS FISCAIS                                 }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_DOC, '', DOC, ICO_DOC, '', '', True)];
  Result := Result + [Item('doc-cte',  GRP_DOC, 'Emiss'#227'o de CT-e',              ICO_DOC, 'doc.cte',         DOC+' > Emiss'#227'o de CT-e',              False)];
  Result := Result + [Item('doc-ctc',  GRP_DOC, 'Cancelamento de CT-e',              ICO_DOC, 'doc.ctecancel',   DOC+' > Cancelamento de CT-e',              False)];
  Result := Result + [Item('doc-ccc',  GRP_DOC, 'Carta de Corre'#231#227'o CT-e',    ICO_DOC, 'doc.ctecorr',     DOC+' > Carta de Corre'#231#227'o CT-e',    False)];
  Result := Result + [Item('doc-mdf',  GRP_DOC, 'MDF-e (Manifesto)',                 ICO_DOC, 'doc.mdfe',        DOC+' > MDF-e (Manifesto)',                  False)];
  Result := Result + [Item('doc-mde',  GRP_DOC, 'Encerramento MDF-e',               ICO_DOC, 'doc.mdfeenc',     DOC+' > Encerramento MDF-e',                False)];
  Result := Result + [Item('doc-cit',  GRP_DOC, 'CIOT',                             ICO_KEY,  'doc.ciot',        DOC+' > CIOT',                              False)];
  Result := Result + [Item('doc-avb',  GRP_DOC, 'Averba'#231#227'o de Carga',        ICO_DOC, 'doc.averbacao',   DOC+' > Averba'#231#227'o de Carga',        False)];
  Result := Result + [Item('doc-xml',  GRP_DOC, 'Importa'#231#227'o XML (NF-e/CT-e)',ICO_DOC, 'doc.importxml',   DOC+' > Importa'#231#227'o XML',             False)];
  Result := Result + [Item('doc-sfz',  GRP_DOC, 'Integra'#231#227'o SEFAZ',         ICO_CODE, 'doc.sefaz',       DOC+' > Integra'#231#227'o SEFAZ',          False)];

  { ══════════════════════════════════════════════════════ }
  { 4. FROTA                                              }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_FROTA, '', FROT, ICO_TRUCK, '', '', True)];
  Result := Result + [Item('frt-vei',  GRP_FROTA, 'Controle de Ve'#237'culos',       ICO_TRUCK,  'frot.veiculos',    FROT+' > Controle de Ve'#237'culos',       False)];
  Result := Result + [Item('frt-mnp',  GRP_FROTA, 'Manuten'#231#227'o Preventiva',   ICO_WRENCH, 'frot.manprev',     FROT+' > Manuten'#231#227'o Preventiva',   False)];
  Result := Result + [Item('frt-mnc',  GRP_FROTA, 'Manuten'#231#227'o Corretiva',    ICO_WRENCH, 'frot.mancorr',     FROT+' > Manuten'#231#227'o Corretiva',    False)];
  Result := Result + [Item('frt-pnu',  GRP_FROTA, 'Controle de Pneus',               ICO_TRUCK,  'frot.pneus',       FROT+' > Controle de Pneus',               False)];
  Result := Result + [Item('frt-abs',  GRP_FROTA, 'Abastecimentos',                  ICO_TRUCK,  'frot.abastecimento', FROT+' > Abastecimentos',               False)];
  Result := Result + [Item('frt-cmb',  GRP_FROTA, 'Consumo de Combust'#237'vel',     ICO_CHART,  'frot.combustivel', FROT+' > Consumo de Combust'#237'vel',     False)];
  Result := Result + [Item('frt-dvc',  GRP_FROTA, 'Documenta'#231#227'o de Ve'#237'culos', ICO_DOC, 'frot.docveiculos', FROT+' > Documenta'#231#227'o de Ve'#237'culos', False)];
  Result := Result + [Item('frt-gps',  GRP_FROTA, 'Rastreamento GPS',                ICO_LOCATION,'frot.gps',        FROT+' > Rastreamento GPS',                False)];
  Result := Result + [Item('frt-mlt',  GRP_FROTA, 'Multas',                          ICO_DOC,    'frot.multas',      FROT+' > Multas',                          False)];

  { ══════════════════════════════════════════════════════ }
  { 5. FINANCEIRO                                         }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_FIN, '', FIN, ICO_DOLLAR, '', '', True)];
  Result := Result + [Item('fin-rec',  GRP_FIN, 'Contas a Receber',           ICO_DOLLAR, 'fin.receber',     FIN+' > Contas a Receber',           False)];
  Result := Result + [Item('fin-pag',  GRP_FIN, 'Contas a Pagar',             ICO_DOLLAR, 'fin.pagar',       FIN+' > Contas a Pagar',             False)];
  Result := Result + [Item('fin-flx',  GRP_FIN, 'Fluxo de Caixa',             ICO_CHART,  'fin.fluxo',       FIN+' > Fluxo de Caixa',             False)];
  Result := Result + [Item('fin-fat',  GRP_FIN, 'Faturamento de Fretes',      ICO_DOLLAR, 'fin.faturamento', FIN+' > Faturamento de Fretes',      False)];
  Result := Result + [Item('fin-cnc',  GRP_FIN, 'Concilia'#231#227'o Banc'#225'ria', ICO_DOLLAR, 'fin.conciliacao', FIN+' > Concilia'#231#227'o Banc'#225'ria', False)];
  Result := Result + [Item('fin-dsp',  GRP_FIN, 'Controle de Despesas',       ICO_DOLLAR, 'fin.despesas',    FIN+' > Controle de Despesas',       False)];
  Result := Result + [Item('fin-cct',  GRP_FIN, 'Centro de Custos',           ICO_CHART,  'fin.centrocusto', FIN+' > Centro de Custos',           False)];
  Result := Result + [Item('fin-plt',  GRP_FIN, 'Plano de Contas',            ICO_DOC,    'fin.planocontas', FIN+' > Plano de Contas',            False)];
  Result := Result + [Item('fin-cxa',  GRP_FIN, 'Caixa',                      ICO_DOLLAR, 'fin.caixa',       FIN+' > Caixa',                      False)];

  { ══════════════════════════════════════════════════════ }
  { 6. FRETES / COMERCIAL                                 }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_COM, '', COM, ICO_TAG, '', '', True)];
  Result := Result + [Item('com-cot',  GRP_COM, 'Cota'#231#227'o de Frete',          ICO_TAG,    'com.cotacao',    COM+' > Cota'#231#227'o de Frete',          False)];
  Result := Result + [Item('com-sim',  GRP_COM, 'Simula'#231#227'o de Frete',        ICO_TAG,    'com.simulacao',  COM+' > Simula'#231#227'o de Frete',        False)];
  Result := Result + [Item('com-tbc',  GRP_COM, 'Tabela de Frete por Cliente', ICO_TAG,    'com.tabcliente', COM+' > Tabela de Frete por Cliente', False)];
  Result := Result + [Item('com-tbr',  GRP_COM, 'Tabela por Regi'#227'o',            ICO_TAG,    'com.tabregiao',  COM+' > Tabela por Regi'#227'o',            False)];
  Result := Result + [Item('com-ctr',  GRP_COM, 'Contratos',                   ICO_DOC,    'com.contratos',  COM+' > Contratos',                   False)];
  Result := Result + [Item('com-mrg',  GRP_COM, 'Margem de Lucro',             ICO_CHART,  'com.margem',     COM+' > Margem de Lucro',             False)];
  Result := Result + [Item('com-neg',  GRP_COM, 'Negocia'#231#227'o',               ICO_USERS,  'com.negociacao', COM+' > Negocia'#231#227'o',               False)];

  { ══════════════════════════════════════════════════════ }
  { 7. MOTORISTAS / RH                                    }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_RH, '', RH, ICO_USERS, '', '', True)];
  Result := Result + [Item('rh-cad',   GRP_RH, 'Cadastro de Motoristas',       ICO_USERS,  'rh.motoristas',   RH+' > Cadastro de Motoristas',       False)];
  Result := Result + [Item('rh-jrn',   GRP_RH, 'Controle de Jornada',          ICO_CHART,  'rh.jornada',      RH+' > Controle de Jornada',          False)];
  Result := Result + [Item('rh-doc',   GRP_RH, 'Documentos (CNH / Exames)',    ICO_DOC,    'rh.documentos',   RH+' > Documentos (CNH / Exames)',    False)];
  Result := Result + [Item('rh-pft',   GRP_RH, 'Pagamento de Frete',           ICO_DOLLAR, 'rh.pagamento',    RH+' > Pagamento de Frete',           False)];
  Result := Result + [Item('rh-cms',   GRP_RH, 'Comiss'#227'o de Motoristas',      ICO_DOLLAR, 'rh.comissao',     RH+' > Comiss'#227'o de Motoristas',      False)];
  Result := Result + [Item('rh-trc',   GRP_RH, 'Controle de Terceiros',        ICO_USERS,  'rh.terceiros',    RH+' > Controle de Terceiros',        False)];
  Result := Result + [Item('rh-adi',   GRP_RH, 'Adiantamentos',                ICO_DOLLAR, 'rh.adiantamentos',RH+' > Adiantamentos',                False)];

  { ══════════════════════════════════════════════════════ }
  { 8. RASTREAMENTO                                       }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_RASTR, '', RAST, ICO_LOCATION, '', '', True)];
  Result := Result + [Item('ras-trk',  GRP_RASTR, 'Tracking de Entregas',          ICO_LOCATION,'ras.tracking',   RAST+' > Tracking de Entregas',          False)];
  Result := Result + [Item('ras-mtr',  GRP_RASTR, 'Monitoramento em Tempo Real',   ICO_LOCATION,'ras.monitor',    RAST+' > Monitoramento em Tempo Real',   False)];
  Result := Result + [Item('ras-hst',  GRP_RASTR, 'Hist'#243'rico de Viagens',     ICO_CHART,   'ras.historico',  RAST+' > Hist'#243'rico de Viagens',     False)];
  Result := Result + [Item('ras-ocr',  GRP_RASTR, 'Ocorr'#234'ncias',              ICO_DOC,     'ras.ocorrencias',RAST+' > Ocorr'#234'ncias',              False)];
  Result := Result + [Item('ras-alt',  GRP_RASTR, 'Alertas (Atraso / Parada)',     ICO_DOC,     'ras.alertas',    RAST+' > Alertas (Atraso / Parada)',     False)];
  Result := Result + [Item('ras-map',  GRP_RASTR, 'Localiza'#231#227'o no Mapa',   ICO_LOCATION,'ras.mapa',       RAST+' > Localiza'#231#227'o no Mapa',   False)];

  { ══════════════════════════════════════════════════════ }
  { 9. RELATÓRIOS                                         }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_REL, '', REL, ICO_CHART, '', '', True)];
  Result := Result + [Item('rel-fin',  GRP_REL, 'Relat'#243'rios Financeiros',    ICO_DOLLAR, 'rel.financeiro',   REL+' > Relat'#243'rios Financeiros',    False)];
  Result := Result + [Item('rel-frt',  GRP_REL, 'Relat'#243'rios de Fretes',      ICO_TRUCK,  'rel.fretes',       REL+' > Relat'#243'rios de Fretes',      False)];
  Result := Result + [Item('rel-rnt',  GRP_REL, 'Rentabilidade por Viagem',       ICO_CHART,  'rel.rentabilidade',REL+' > Rentabilidade por Viagem',       False)];
  Result := Result + [Item('rel-dft',  GRP_REL, 'Desempenho da Frota',            ICO_TRUCK,  'rel.frota',        REL+' > Desempenho da Frota',            False)];
  Result := Result + [Item('rel-mot',  GRP_REL, 'Produtividade de Motoristas',    ICO_USERS,  'rel.motoristas',   REL+' > Produtividade de Motoristas',    False)];
  Result := Result + [Item('rel-ent',  GRP_REL, 'Entregas Realizadas',            ICO_DOC,    'rel.entregas',     REL+' > Entregas Realizadas',            False)];
  Result := Result + [Item('rel-ocr',  GRP_REL, 'Ocorr'#234'ncias',               ICO_DOC,    'rel.ocorrencias',  REL+' > Ocorr'#234'ncias',               False)];
  Result := Result + [Item('rel-kpi',  GRP_REL, 'Indicadores (KPI)',              ICO_CHART,  'rel.kpi',          REL+' > Indicadores (KPI)',              False)];

  { ══════════════════════════════════════════════════════ }
  { 10. INTEGRAÇÕES                                       }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_INT, '', INT, ICO_CODE, '', '', True)];
  Result := Result + [Item('int-api',  GRP_INT, 'API REST',                          ICO_CODE, 'int.api',       INT+' > API REST',                         False)];
  Result := Result + [Item('int-erp',  GRP_INT, 'Integra'#231#227'o com ERP',        ICO_CODE, 'int.erp',       INT+' > Integra'#231#227'o com ERP',       False)];
  Result := Result + [Item('int-rst',  GRP_INT, 'Integra'#231#227'o com Rastreador', ICO_CODE, 'int.rastreador',INT+' > Integra'#231#227'o com Rastreador', False)];
  Result := Result + [Item('int-edi',  GRP_INT, 'EDI',                              ICO_CODE, 'int.edi',       INT+' > EDI',                               False)];
  Result := Result + [Item('int-imp',  GRP_INT, 'Importa'#231#227'o / Exporta'#231#227'o de Dados', ICO_ARCHIVE, 'int.importexport', INT+' > Importa'#231#227'o / Exporta'#231#227'o', False)];

  { ══════════════════════════════════════════════════════ }
  { 11. CONFIGURAÇÕES                                     }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_CFG, '', CFG, ICO_GEAR, '', '', True)];
  Result := Result + [Item('cfg-par',  GRP_CFG, 'Par'#226'metros do Sistema',        ICO_GEAR, 'cfg.parametros', CFG+' > Par'#226'metros do Sistema',        False)];
  Result := Result + [Item('cfg-fsc',  GRP_CFG, 'Configura'#231#227'o Fiscal',       ICO_DOC,  'cfg.fiscal',     CFG+' > Configura'#231#227'o Fiscal',       False)];
  Result := Result + [Item('cfg-crt',  GRP_CFG, 'Certificado Digital',               ICO_KEY,  'cfg.certificado',CFG+' > Certificado Digital',               False)];
  Result := Result + [Item('cfg-imp',  GRP_CFG, 'Configura'#231#227'o de Impress'#227'o', ICO_DOC, 'cfg.impressao', CFG+' > Configura'#231#227'o de Impress'#227'o', False)];
  Result := Result + [Item('cfg-log',  GRP_CFG, 'Logs do Sistema',                   ICO_DOC,  'cfg.logs',       CFG+' > Logs do Sistema',                   False)];
  Result := Result + [Item('cfg-bak',  GRP_CFG, 'Backup',                            ICO_ARCHIVE,'cfg.backup',   CFG+' > Backup',                            False)];
  Result := Result + [Item('cfg-usr',  GRP_CFG, 'Cadastro de Usu'#225'rios',         ICO_USER,  'cfg.usuario',   CFG+' > Cadastro de Usu'#225'rios',         True)];
  Result := Result + [Item('cfg-prf',  GRP_CFG, 'Cadastro de Perfil',                ICO_USERS, 'cfg.perfil',    CFG+' > Cadastro de Perfil',                True)];
  Result := Result + [Item('cfg-prm',  GRP_CFG, 'Permiss'#245'es de Usu'#225'rios',  ICO_KEY,   'cfg.permissoes',CFG+' > Permiss'#245'es de Usu'#225'rios',  True)];

  { ══════════════════════════════════════════════════════ }
  { 12. UTILITÁRIOS                                       }
  { ══════════════════════════════════════════════════════ }
  Result := Result + [Item(GRP_UTIL, '', UTIL, ICO_WRENCH, '', '', True)];
  Result := Result + [Item('util-aud', GRP_UTIL, 'Auditoria',                       ICO_DOC,   'util.auditoria',      UTIL+' > Auditoria',                       False)];
  Result := Result + [Item('util-mnt', GRP_UTIL, 'Monitor de Integra'#231#227'o',   ICO_CODE,  'util.monitor',        UTIL+' > Monitor de Integra'#231#227'o',   False)];
  Result := Result + [Item('util-rpx', GRP_UTIL, 'Reprocessamento de XML',          ICO_ARCHIVE,'util.reprocessamento',UTIL+' > Reprocessamento de XML',          False)];
  Result := Result + [Item('util-lmp', GRP_UTIL, 'Limpeza de Dados',                ICO_WRENCH,'util.limpeza',        UTIL+' > Limpeza de Dados',                False)];
end;

end.
