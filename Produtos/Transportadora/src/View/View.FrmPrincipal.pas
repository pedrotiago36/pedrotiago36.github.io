unit View.FrmPrincipal;

interface

uses
  Controller.IMainController,
  Controller.TMainController,
  Model.IMenuItem,
  uniGUIForm,
  uniHTMLFrame,
  uniGUITypes,
  uniGUIAbstractClasses,
  uniGUIClasses,
  uniGUIBaseClasses,
  System.SysUtils,
  System.Classes;

type
  TFrmPrincipal = class(TUniForm, IMainView)
    UniHTMLFrame1: TUniHTMLFrame;
    procedure HtmlFrameAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure UniFormCreate(Sender: TObject);
  private
    FController : IMainController;
    FJSFrame    : string; { referencia JS ao frame: parent['JSName'] }
    procedure BuildHtml;
    function  RenderSidebar(const AItems: TArray<TMenuItemRec>): string;
    { IMainView }
    procedure OpenTab(const ARoute, ACaption, ABreadPath: string);
    procedure CloseTab(const ARoute: string);
    procedure RefreshFavorites(const AFavorites: TArray<string>);
  end;

function NewFrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses
  uniGUIVars,
  uniGUIApplication,
  uniGUIServer,
  ServerModule,
  System.JSON;

function NewFrmPrincipal: TFrmPrincipal;
begin
  Result := TFrmPrincipal.Create(UniApplication);
end;

{ TFrmPrincipal }

procedure TFrmPrincipal.UniFormCreate(Sender: TObject);
begin
  FJSFrame    := 'parent[' + QuotedStr(UniHTMLFrame1.JSName) + ']';
  FController := NewMainController;
  FController.BindView(Self);
  BuildHtml;
end;

{ ── Sidebar ── }

function TFrmPrincipal.RenderSidebar(const AItems: TArray<TMenuItemRec>): string;
const
  SVG_ARROW = 'M6 9l6 6 6-6';
  SVG_STAR  = 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z';
  C_GRP_OPEN : array[Boolean] of string = ('', ' open');
  C_ITEM_DIS : array[Boolean] of string = ('', ' disabled');

  function SvgIcon(const APath: string; ASize: Integer = 18): string;
  begin
    Result :=
      '<svg width="' + IntToStr(ASize) + '" height="' + IntToStr(ASize) + '" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" ' +
      'stroke-linecap="round" stroke-linejoin="round">' +
      '<path d="' + APath + '"/></svg>';
  end;

var
  B    : TStringBuilder;
  Item : TMenuItemRec;
  InGrp: Boolean;
begin
  B     := TStringBuilder.Create;
  InGrp := False;
  try
    for Item in AItems do
    begin
      if Item.ParentID = '' then
      begin
        if InGrp then B.Append('</div></div>');
        InGrp := True;

        B.Append('<div class="nav-group">');
        B.AppendFormat(
          '<div class="nav-group-hdr%s" onclick="toggleGroup(this)">' +
          '<span class="nav-grp-ico">%s</span>' +
          '<span class="nav-grp-lbl">%s</span>',
          [C_GRP_OPEN[Item.Enabled], SvgIcon(Item.Icon, 18), Item.Caption]);

        if not Item.Enabled then
          B.Append('<span class="soon-badge">Em breve</span>');

        B.AppendFormat(
          '<span class="nav-grp-arr">%s</span></div>',
          [SvgIcon(SVG_ARROW, 14)]);

        B.AppendFormat('<div class="nav-group-items%s">', [C_GRP_OPEN[Item.Enabled]]);
      end
      else
      begin
        B.AppendFormat(
          '<div class="nav-item%s" data-route="%s" data-bread="%s" data-cap="%s" ' +
          'onclick="navTo(''%s'',''%s'',''%s'')">' +
          '<span class="nav-item-ico">%s</span>' +
          '<span class="nav-item-lbl">%s</span>' +
          '<span class="nav-item-fav" title="Favoritar" ' +
          'onclick="event.stopPropagation();favToggle(this,''%s'')">%s</span>' +
          '</div>',
          [C_ITEM_DIS[not Item.Enabled],
           Item.Route, Item.BreadPath, Item.Caption,
           Item.Route, Item.Caption, Item.BreadPath,
           SvgIcon(Item.Icon, 16),
           Item.Caption,
           Item.Route,
           SvgIcon(SVG_STAR, 12)]);
      end;
    end;
    if InGrp then B.Append('</div></div>');
    Result := B.ToString;
  finally
    B.Free;
  end;
end;

{ ── HTML principal ── }

procedure TFrmPrincipal.BuildHtml;
const
  SVG_SEARCH = 'M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z';
  SVG_MENU   = 'M4 6h16M4 12h16M4 18h16';

  function SvgIcon(const APath: string; ASize: Integer = 18): string;
  begin
    Result :=
      '<svg width="' + IntToStr(ASize) + '" height="' + IntToStr(ASize) + '" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" ' +
      'stroke-linecap="round" stroke-linejoin="round">' +
      '<path d="' + APath + '"/></svg>';
  end;

var
  H        : TStringBuilder;
  LItems   : TArray<TMenuItemRec>;
  LLogoURL : string;
  CSS, JS  : string;
begin
  LLogoURL := UniServerModule.FilesFolderURL + 'logo_transportadora.png?v=' +
              FormatDateTime('yyyymmddhhnnss', Now);
  LItems := FController.GetMenuItems;

  CSS :=
    '*{margin:0;padding:0;box-sizing:border-box;}' +
    'html,body{width:100%!important;height:100%!important;overflow:hidden!important;' +
    '  font-family:"Segoe UI",system-ui,sans-serif;' +
    '  background:#0D0D1A!important;color:#E2E8F0!important;}' +
    ':root{--am:#F59E0B;--am2:#FCD34D;--am3:#D97706;' +
    '  --bg:#0D0D1A;--bg2:#161627;--bg3:#1E1E35;--bg4:#252545;' +
    '  --bdr:rgba(255,255,255,.07);--mt:#64748B;--sw:256px;}' +
    '#topbar{position:fixed;top:0;left:0;right:0;height:58px;z-index:100;' +
    '  background:rgba(13,13,26,.97);backdrop-filter:blur(20px);' +
    '  border-bottom:1px solid var(--bdr);' +
    '  display:flex;align-items:center;padding:0 20px;gap:16px;}' +
    '.tb-brand{display:flex;align-items:center;gap:12px;width:var(--sw);flex-shrink:0;}' +
    '.tb-brand img{height:34px;filter:drop-shadow(0 0 8px rgba(245,158,11,.5));}' +
    '.tb-brand-name{font-size:13px;font-weight:700;color:var(--am2);}' +
    '.tb-brand-sub{font-size:10px;color:var(--mt);}' +
    '.tb-search{flex:1;max-width:420px;position:relative;}' +
    '.tb-search input{width:100%;background:var(--bg3);border:1px solid var(--bdr);' +
    '  border-radius:10px;padding:9px 14px 9px 40px;color:#E2E8F0;' +
    '  font-size:13px;outline:none;transition:border-color .2s,box-shadow .2s;}' +
    '.tb-search input:focus{border-color:rgba(245,158,11,.5);' +
    '  box-shadow:0 0 0 3px rgba(245,158,11,.08);}' +
    '.tb-search input::placeholder{color:var(--mt);}' +
    '.tb-sico{position:absolute;left:12px;top:50%;transform:translateY(-50%);' +
    '  color:var(--mt);pointer-events:none;}' +
    '#sdrop{position:absolute;top:calc(100% + 6px);left:0;right:0;' +
    '  background:var(--bg2);border:1px solid var(--bdr);border-radius:12px;' +
    '  box-shadow:0 20px 60px rgba(0,0,0,.6);display:none;z-index:200;' +
    '  max-height:300px;overflow-y:auto;}' +
    '.sd-item{padding:10px 16px;cursor:pointer;display:flex;' +
    '  align-items:center;gap:10px;font-size:13px;transition:background .15s;}' +
    '.sd-item:hover{background:var(--bg3);}' +
    '.sd-badge{margin-left:auto;font-size:10px;color:var(--mt);' +
    '  background:var(--bg3);padding:2px 7px;border-radius:5px;}' +
    '.tb-right{margin-left:auto;display:flex;align-items:center;gap:12px;}' +
    '.tb-user{display:flex;align-items:center;gap:8px;background:var(--bg3);' +
    '  border:1px solid var(--bdr);border-radius:20px;padding:5px 14px 5px 5px;}' +
    '.tb-avatar{width:28px;height:28px;border-radius:50%;' +
    '  background:linear-gradient(135deg,var(--am),var(--am3));' +
    '  display:flex;align-items:center;justify-content:center;' +
    '  font-size:11px;font-weight:700;color:#000;}' +
    '.tb-uname{font-size:12px;font-weight:500;}' +
    '.tb-btn{background:none;border:1px solid var(--bdr);border-radius:8px;' +
    '  padding:6px;cursor:pointer;color:var(--mt);transition:all .2s;' +
    '  display:flex;align-items:center;justify-content:center;}' +
    '.tb-btn:hover{border-color:var(--am);color:var(--am);}' +
    '#app{position:fixed;top:58px;bottom:0;left:0;right:0;display:flex;}' +
    '#sidebar{width:var(--sw);background:var(--bg2);border-right:1px solid var(--bdr);' +
    '  display:flex;flex-direction:column;overflow:hidden;' +
    '  transition:width .3s cubic-bezier(.4,0,.2,1);flex-shrink:0;}' +
    '#sidebar.collapsed{width:58px;}' +
    '#sidebar.collapsed .nav-grp-lbl,#sidebar.collapsed .nav-grp-arr,' +
    '#sidebar.collapsed .soon-badge,#sidebar.collapsed .nav-item-lbl,' +
    '#sidebar.collapsed .nav-item-fav,#sidebar.collapsed #fav-bar{display:none!important;}' +
    '#sidebar.collapsed .nav-group-items{max-height:0!important;}' +
    '#sidebar.collapsed .nav-group-hdr{justify-content:center;padding:12px;}' +
    '#sidebar.collapsed .nav-item{justify-content:center;padding:12px;}' +
    '#sb-scroll{flex:1;overflow-y:auto;overflow-x:hidden;padding:8px;}' +
    '#sb-scroll::-webkit-scrollbar{width:3px;}' +
    '#sb-scroll::-webkit-scrollbar-thumb{background:var(--bdr);border-radius:2px;}' +
    '.nav-group{margin-bottom:2px;}' +
    '.nav-group-hdr{display:flex;align-items:center;gap:10px;padding:10px 12px;' +
    '  border-radius:10px;cursor:pointer;user-select:none;transition:all .2s;}' +
    '.nav-group-hdr:hover{background:var(--bg3);}' +
    '.nav-group-hdr.open{background:rgba(245,158,11,.1);' +
    '  border-left:2px solid var(--am);padding-left:10px;}' +
    '.nav-grp-ico{color:var(--mt);flex-shrink:0;transition:color .2s;' +
    '  display:flex;align-items:center;}' +
    '.nav-group-hdr.open .nav-grp-ico{color:var(--am);}' +
    '.nav-grp-lbl{font-size:12.5px;font-weight:600;flex:1;letter-spacing:.2px;}' +
    '.nav-grp-arr{color:var(--mt);flex-shrink:0;transition:transform .25s;' +
    '  display:flex;align-items:center;}' +
    '.nav-group-hdr.open .nav-grp-arr{transform:rotate(180deg);}' +
    '.soon-badge{font-size:9px;background:rgba(100,116,139,.15);color:var(--mt);' +
    '  padding:2px 7px;border-radius:5px;letter-spacing:.3px;}' +
    '.nav-group-items{overflow:hidden;max-height:0;transition:max-height .3s ease;}' +
    '.nav-group-items.open{max-height:500px;}' +
    '.nav-item{display:flex;align-items:center;gap:10px;' +
    '  padding:8px 10px 8px 30px;border-radius:8px;cursor:pointer;' +
    '  font-size:12.5px;transition:all .18s;color:#64748B;}' +
    '.nav-item:hover:not(.disabled){background:var(--bg3);color:#CBD5E1;}' +
    '.nav-item.active{background:rgba(245,158,11,.12);' +
    '  color:var(--am2);border-left:2px solid var(--am);padding-left:28px;}' +
    '.nav-item.disabled{opacity:.3;cursor:not-allowed;}' +
    '.nav-item-ico{flex-shrink:0;display:flex;align-items:center;}' +
    '.nav-item-lbl{flex:1;}' +
    '.nav-item-fav{opacity:0;transition:opacity .2s;color:var(--am);' +
    '  display:flex;align-items:center;padding:2px;}' +
    '.nav-item:hover .nav-item-fav{opacity:.4;}' +
    '.nav-item-fav.active{opacity:1!important;}' +
    '#fav-bar{padding:10px 12px;border-bottom:1px solid var(--bdr);flex-shrink:0;}' +
    '.fav-title{font-size:10px;font-weight:600;color:var(--mt);' +
    '  letter-spacing:.8px;text-transform:uppercase;margin-bottom:8px;}' +
    '#fav-chips{display:flex;flex-wrap:wrap;gap:5px;min-height:4px;}' +
    '.fav-chip{background:var(--bg3);border:1px solid var(--bdr);border-radius:8px;' +
    '  padding:4px 10px;font-size:11px;cursor:pointer;transition:all .18s;' +
    '  white-space:nowrap;color:#94A3B8;}' +
    '.fav-chip:hover{border-color:var(--am);color:var(--am);}' +
    '.fav-empty{font-size:11px;color:var(--mt);font-style:italic;}' +
    '#content{flex:1;display:flex;flex-direction:column;overflow:hidden;}' +
    '#tabs-bar{background:var(--bg2);border-bottom:1px solid var(--bdr);' +
    '  display:flex;align-items:flex-end;padding:0 12px;' +
    '  min-height:42px;overflow-x:auto;flex-shrink:0;gap:2px;}' +
    '#tabs-bar::-webkit-scrollbar{height:2px;}' +
    '#tabs-bar::-webkit-scrollbar-thumb{background:var(--bdr);}' +
    '.tab-btn{display:flex;align-items:center;gap:6px;padding:0 14px;height:38px;' +
    '  border-radius:8px 8px 0 0;cursor:pointer;font-size:12px;white-space:nowrap;' +
    '  border:1px solid transparent;border-bottom:none;' +
    '  background:var(--bg3);color:#475569;transition:all .18s;top:1px;position:relative;}' +
    '.tab-btn:hover{background:var(--bg4);color:#94A3B8;}' +
    '.tab-btn.active{background:var(--bg);border-color:var(--bdr);color:var(--am2);}' +
    '.tab-x{background:none;border:none;cursor:pointer;color:inherit;' +
    '  opacity:0;padding:1px 3px;border-radius:3px;font-size:14px;' +
    '  line-height:1;transition:all .15s;}' +
    '.tab-btn:hover .tab-x,.tab-btn.active .tab-x{opacity:.6;}' +
    '.tab-x:hover{opacity:1!important;background:rgba(239,68,68,.25);color:#EF4444!important;}' +
    '#no-tab{font-size:12px;color:var(--mt);font-style:italic;padding:0 4px;align-self:center;}' +
    '#breadcrumb{padding:8px 20px;display:flex;align-items:center;gap:6px;' +
    '  font-size:12px;color:var(--mt);flex-shrink:0;min-height:34px;' +
    '  border-bottom:1px solid var(--bdr);background:var(--bg2);}' +
    '.bc-sep{color:var(--bdr);font-size:10px;}' +
    '.bc-last{color:var(--am);font-weight:500;}' +
    '#screen{flex:1;overflow:auto;padding:24px;background:var(--bg);}' +
    '#screen::-webkit-scrollbar{width:5px;}' +
    '#screen::-webkit-scrollbar-thumb{background:var(--bdr);border-radius:3px;}' +
    '.sc-empty{display:flex;flex-direction:column;align-items:center;' +
    '  justify-content:center;height:100%;gap:12px;opacity:.25;}' +
    '.sc-empty p{font-size:14px;color:var(--mt);}' +
    '.sc-card{background:var(--bg2);border:1px solid var(--bdr);' +
    '  border-radius:16px;padding:32px;animation:fuSlide .25s ease;}' +
    '.sc-card h2{font-size:20px;font-weight:700;color:var(--am2);margin-bottom:8px;}' +
    '.sc-card p{color:var(--mt);font-size:13px;line-height:1.6;}' +
    '.sc-card .rtag{display:inline-block;margin-top:14px;' +
    '  background:var(--bg3);border:1px solid var(--bdr);' +
    '  border-radius:6px;padding:4px 10px;font-size:11px;color:var(--mt);}' +
    '@keyframes fuSlide{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}' +
    '::-webkit-scrollbar{width:5px;height:5px;}' +
    '::-webkit-scrollbar-track{background:transparent;}' +
    '::-webkit-scrollbar-thumb{background:var(--bdr);border-radius:3px;}';

  JS :=
    'var _f=' + FJSFrame + ';' +
    'var OT={},SB=false;' +
    'function toggleSB(){SB=!SB;document.getElementById("sidebar").classList.toggle("collapsed",SB);}' +
    'function toggleGroup(el){' +
    '  var open=el.classList.contains("open");' +
    '  document.querySelectorAll(".nav-group-hdr.open").forEach(function(h){' +
    '    h.classList.remove("open");h.nextElementSibling.classList.remove("open");});' +
    '  if(!open){el.classList.add("open");el.nextElementSibling.classList.add("open");}' +
    '}' +
    'function navTo(r,c,b){if(r)ajaxRequest(_f,"nav",[r,c,b]);}' +
    'function openTab(route,cap,bread){' +
    '  if(OT[route]){setActive(route);return;}' +
    '  OT[route]={cap:cap,bread:bread};' +
    '  var bar=document.getElementById("tabs-bar");' +
    '  var nt=document.getElementById("no-tab");if(nt)nt.remove();' +
    '  var t=document.createElement("div");t.className="tab-btn";t.dataset.route=route;' +
    '  var l=document.createElement("span");l.textContent=cap;' +
    '  var x=document.createElement("button");x.className="tab-x";' +
    '  x.innerHTML="&times;";x.title="Fechar";' +
    '  (function(ro){' +
    '    t.addEventListener("click",function(){setActive(ro);});' +
    '    x.addEventListener("click",function(e){e.stopPropagation();closeTab(ro);});' +
    '  })(route);' +
    '  t.appendChild(l);t.appendChild(x);bar.appendChild(t);setActive(route);' +
    '}' +
    'function setActive(route){' +
    '  document.querySelectorAll(".tab-btn").forEach(function(t){' +
    '    t.classList.toggle("active",t.dataset.route===route);});' +
    '  document.querySelectorAll(".nav-item").forEach(function(m){' +
    '    m.classList.toggle("active",m.dataset.route===route);});' +
    '  var d=OT[route]||{};renderBC(d.bread||"");renderScreen(route,d.cap||"");' +
    '}' +
    'function closeTab(route){' +
    '  var t=document.querySelector(".tab-btn[data-route="+JSON.stringify(route)+"]");' +
    '  if(!t)return;' +
    '  var wa=t.classList.contains("active");t.remove();delete OT[route];' +
    '  ajaxRequest(_f,"closeTab",[route]);' +
    '  var rem=document.querySelectorAll(".tab-btn");' +
    '  if(wa&&rem.length)setActive(rem[rem.length-1].dataset.route);' +
    '  else if(!rem.length){' +
    '    var s=document.createElement("span");s.id="no-tab";' +
    '    s.textContent="Nenhuma tela aberta";' +
    '    document.getElementById("tabs-bar").appendChild(s);' +
    '    renderBC("");renderScreen("","");' +
    '  }' +
    '  document.querySelectorAll(".nav-item").forEach(function(m){m.classList.remove("active");});' +
    '}' +
    'function renderBC(bread){' +
    '  var el=document.getElementById("breadcrumb");' +
    '  if(!bread){el.innerHTML="";return;}' +
    '  el.innerHTML=bread.split(" > ").map(function(s,i,a){' +
    '    return i<a.length-1?"<span>"+s+"</span><span class=bc-sep>&#10095;</span>"' +
    '      :"<span class=bc-last>"+s+"</span>";}).join("");' +
    '}' +
    'function renderScreen(route,cap){' +
    '  var el=document.getElementById("screen");' +
    '  if(!route){el.innerHTML="<div class=sc-empty><p>Selecione uma tela no menu lateral</p></div>";return;}' +
    '  el.innerHTML="<div class=sc-card><h2>"+cap+"</h2>' +
    '    <p>Tela em desenvolvimento.</p>' +
    '    <span class=rtag>"+route+"</span></div>";' +
    '}' +
    'function favToggle(el,route){el.classList.toggle("active");ajaxRequest(_f,"toggleFav",[route]);}' +
    'function updateFavs(json){' +
    '  var favs=JSON.parse(json);' +
    '  var chips=document.getElementById("fav-chips");' +
    '  var emp=document.getElementById("fav-empty");' +
    '  chips.innerHTML="";' +
    '  if(!favs.length){if(emp)emp.style.display="";return;}' +
    '  if(emp)emp.style.display="none";' +
    '  favs.forEach(function(r){' +
    '    var m=document.querySelector(".nav-item[data-route="+JSON.stringify(r)+"]");' +
    '    var cap=m?m.dataset.cap:r;var bread=m?m.dataset.bread:"";' +
    '    var c=document.createElement("span");c.className="fav-chip";c.textContent=cap;' +
    '    (function(ro,ca,br){c.addEventListener("click",function(){navTo(ro,ca,br);});})(r,cap,bread);' +
    '    chips.appendChild(c);});' +
    '}' +
    'function doSearch(val){' +
    '  var drop=document.getElementById("sdrop");' +
    '  if(!val.trim()){drop.style.display="none";return;}' +
    '  var all=Array.from(document.querySelectorAll(".nav-item:not(.disabled)"));' +
    '  var ok=all.filter(function(m){return m.dataset.cap.toLowerCase().indexOf(val.toLowerCase())>=0;});' +
    '  drop.innerHTML="";' +
    '  if(!ok.length){drop.innerHTML="<div class=sd-item style=color:var(--mt)>Nenhum resultado</div>";}' +
    '  else{ok.forEach(function(m){' +
    '    var d=document.createElement("div");d.className="sd-item";' +
    '    var l=document.createElement("span");l.textContent=m.dataset.cap;' +
    '    var b=document.createElement("span");b.className="sd-badge";b.textContent=m.dataset.route;' +
    '    d.appendChild(l);d.appendChild(b);' +
    '    (function(ro,ca,br){d.addEventListener("click",function(){' +
    '      navTo(ro,ca,br);drop.style.display="none";' +
    '      document.getElementById("srch").value="";' +
    '    });})(m.dataset.route,m.dataset.cap,m.dataset.bread);' +
    '    drop.appendChild(d);});}' +
    '  drop.style.display="block";' +
    '}' +
    'document.addEventListener("click",function(e){' +
    '  if(!e.target.closest(".tb-search"))document.getElementById("sdrop").style.display="none";});' +
    'window.addEventListener("load",function(){' +
    '  var h=document.querySelector(".nav-group-hdr");' +
    '  if(h){h.classList.add("open");h.nextElementSibling.classList.add("open");}' +
    '  renderScreen("","");' +
    '});';

  H := TStringBuilder.Create;
  try
    H.Append('<!DOCTYPE html><html lang="pt-BR">');
    H.Append('<head><meta charset="UTF-8">');
    H.Append('<meta name="viewport" content="width=device-width,initial-scale=1">');
    H.Append('<style>' + CSS + '</style></head><body>');

    { topbar }
    H.Append('<div id="topbar">');
    H.Append('<div class="tb-brand">');
    H.AppendFormat('<img src="%s" alt="logo">', [LLogoURL]);
    H.Append('<div><div class="tb-brand-name">Grupo DT&amp;LL</div>');
    H.Append('<div class="tb-brand-sub">Sistema de Transportadoras</div></div></div>');
    H.Append('<div class="tb-search">');
    H.Append('<span class="tb-sico">' + SvgIcon(SVG_SEARCH, 15) + '</span>');
    H.Append('<input id="srch" type="text" placeholder="Buscar telas..." oninput="doSearch(this.value)">');
    H.Append('<div id="sdrop"></div></div>');
    H.Append('<div class="tb-right">');
    H.Append('<div class="tb-user">');
    H.Append('<div class="tb-avatar">AD</div>');
    H.Append('<span class="tb-uname">Administrador</span></div>');
    H.Append('<button class="tb-btn" onclick="toggleSB()" title="Menu">');
    H.Append(SvgIcon(SVG_MENU, 18) + '</button></div></div>');

    { app }
    H.Append('<div id="app">');

    { sidebar }
    H.Append('<div id="sidebar">');
    H.Append('<div id="fav-bar">');
    H.Append('<div class="fav-title">&#9733; Favoritos</div>');
    H.Append('<div id="fav-chips"></div>');
    H.Append('<span id="fav-empty" class="fav-empty">Clique na &#9733; para favoritar</span>');
    H.Append('</div>');
    H.Append('<div id="sb-scroll">');
    H.Append(RenderSidebar(LItems));
    H.Append('</div></div>');

    { conteudo }
    H.Append('<div id="content">');
    H.Append('<div id="tabs-bar"><span id="no-tab">Nenhuma tela aberta</span></div>');
    H.Append('<div id="breadcrumb"></div>');
    H.Append('<div id="screen"></div>');
    H.Append('</div></div>');

    H.AppendFormat('<script>%s</script>', [JS]);
    H.Append('</body></html>');

    UniHTMLFrame1.HTML.Text := H.ToString;
  finally
    H.Free;
  end;
end;

{ ── Ajax ── }

procedure TFrmPrincipal.HtmlFrameAjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
type
  TAct = array[0..3] of TProc;
var
  LRoute : string;
  LAct   : TAct;
begin
  LRoute := Params.Values['0'];

  LAct[0] := procedure
    begin
      try FController.NavigateTo(LRoute);
      except on E: EAssertionFailed do
        UniSession.AddJS('alert(' + QuotedStr(E.Message) + ')');
      end;
    end;
  LAct[1] := procedure begin FController.CloseTab(LRoute); end;
  LAct[2] := procedure begin FController.ToggleFavorite(LRoute); end;
  LAct[3] := procedure begin end;

  LAct[
    Ord(EventName='nav')       * 0 +
    Ord(EventName='closeTab')  * 1 +
    Ord(EventName='toggleFav') * 2
  ]();
end;

{ ── IMainView ── }

procedure TFrmPrincipal.OpenTab(const ARoute, ACaption, ABreadPath: string);
begin
  UniSession.AddJS(Format('openTab(%s,%s,%s);',
    [QuotedStr(ARoute), QuotedStr(ACaption), QuotedStr(ABreadPath)]));
end;

procedure TFrmPrincipal.CloseTab(const ARoute: string);
begin
  { fechamento ja tratado no JS }
end;

procedure TFrmPrincipal.RefreshFavorites(const AFavorites: TArray<string>);
var
  J   : TJSONArray;
  Fav : string;
begin
  J := TJSONArray.Create;
  try
    for Fav in AFavorites do J.Add(Fav);
    UniSession.AddJS('updateFavs(' + QuotedStr(J.ToString) + ');');
  finally
    J.Free;
  end;
end;

end.
