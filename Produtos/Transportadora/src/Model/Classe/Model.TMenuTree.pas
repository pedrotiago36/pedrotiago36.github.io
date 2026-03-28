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
  { SVG paths dos icones }
  ICO_SHIELD  = 'M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z';
  ICO_USER    = 'M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 3a4 4 0 100 8 4 4 0 000-8z';
  ICO_USERS   = 'M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75';
  ICO_KEY     = 'M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4';
  ICO_TRUCK   = 'M1 3h15v13H1zM16 8h4l3 3v5h-7V8zM5.5 19a1.5 1.5 0 100-3 1.5 1.5 0 000 3zM18.5 19a1.5 1.5 0 100-3 1.5 1.5 0 000 3z';
  ICO_DOLLAR  = 'M12 1v22M17 5H9.5a3.5 3.5 0 100 7h5a3.5 3.5 0 110 7H6';
  ICO_CHART   = 'M18 20V10M12 20V4M6 20v-6';
  ICO_GEAR    = 'M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z';

begin
  SetLength(Result, 0);

  { ── Grupos raiz ── }
  Result := Result + [Item('grp-seg',  '', 'Seguran'#231'a',     ICO_SHIELD, '', '', True)];
  Result := Result + [Item('grp-oper', '', 'Operacional',       ICO_TRUCK,  '', '', False)];
  Result := Result + [Item('grp-fin',  '', 'Financeiro',        ICO_DOLLAR, '', '', False)];
  Result := Result + [Item('grp-rel',  '', 'Relat'#243'rios',   ICO_CHART,  '', '', False)];
  Result := Result + [Item('grp-cfg',  '', 'Configura'#231#245'es', ICO_GEAR, '', '', False)];

  { ── Seguranca ── }
  Result := Result + [Item('seg-usr',
    'grp-seg', 'Cadastro de Usu'#225'rio', ICO_USER,
    'seg.usuario', 'Seguran'#231'a > Cadastro de Usu'#225'rio', True)];

  Result := Result + [Item('seg-prf',
    'grp-seg', 'Cadastro de Perfil', ICO_USERS,
    'seg.perfil', 'Seguran'#231'a > Cadastro de Perfil', True)];

  Result := Result + [Item('seg-perm',
    'grp-seg', 'Permiss'#245'es de Usu'#225'rios', ICO_KEY,
    'seg.permissoes', 'Seguran'#231'a > Permiss'#245'es de Usu'#225'rios', True)];

  { ── Operacional ── }
  Result := Result + [Item('op-cli',  'grp-oper', 'Cadastro de Clientes',   ICO_USER,  'op.clientes',   'Operacional > Cadastro de Clientes',   False)];
  Result := Result + [Item('op-mot',  'grp-oper', 'Cadastro de Motoristas', ICO_USERS, 'op.motoristas', 'Operacional > Cadastro de Motoristas', False)];
  Result := Result + [Item('op-vei',  'grp-oper', 'Cadastro de Ve'#237'culos', ICO_TRUCK, 'op.veiculos', 'Operacional > Cadastro de Ve'#237'culos', False)];
  Result := Result + [Item('op-os',   'grp-oper', 'Ordens de Servi'#231'o',  ICO_GEAR,  'op.os',         'Operacional > Ordens de Servi'#231'o',   False)];

  { ── Financeiro ── }
  Result := Result + [Item('fin-rec', 'grp-fin', 'Contas a Receber', ICO_DOLLAR, 'fin.receber',   'Financeiro > Contas a Receber', False)];
  Result := Result + [Item('fin-pag', 'grp-fin', 'Contas a Pagar',   ICO_DOLLAR, 'fin.pagar',     'Financeiro > Contas a Pagar',   False)];
  Result := Result + [Item('fin-fx',  'grp-fin', 'Fluxo de Caixa',   ICO_CHART,  'fin.fluxo',     'Financeiro > Fluxo de Caixa',   False)];

  { ── Relatorios ── }
  Result := Result + [Item('rel-frt', 'grp-rel', 'Relat'#243'rio de Fretes',   ICO_TRUCK,  'rel.fretes',    'Relat'#243'rios > Relat'#243'rio de Fretes',   False)];
  Result := Result + [Item('rel-fin', 'grp-rel', 'Relat'#243'rio Financeiro',  ICO_DOLLAR, 'rel.financeiro','Relat'#243'rios > Relat'#243'rio Financeiro',  False)];
  Result := Result + [Item('rel-op',  'grp-rel', 'Relat'#243'rio Operacional', ICO_CHART,  'rel.operacional','Relat'#243'rios > Relat'#243'rio Operacional', False)];

  { ── Configuracoes ── }
  Result := Result + [Item('cfg-emp', 'grp-cfg', 'Dados da Empresa',  ICO_GEAR,  'cfg.empresa',  'Configura'#231#245'es > Dados da Empresa',  False)];
  Result := Result + [Item('cfg-par', 'grp-cfg', 'Par'#226'metros',   ICO_GEAR,  'cfg.params',   'Configura'#231#245'es > Par'#226'metros',   False)];
end;

end.
