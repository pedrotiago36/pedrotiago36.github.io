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
    procedure BuildHtml;
    function  BuildSidebarHtml(const AItems: TArray<TMenuItemRec>): string;
    function  BuildCss: string;
    function  BuildJs: string;
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
  FController := NewMainController;
  FController.BindView(Self);
  BuildHtml;
end;

{ ── CSS ── }

function TFrmPrincipal.BuildCss: string;
var
  C: TStringBuilder;
begin
  C := TStringBuilder.Create;
  try
    C.AppendLine(':root{');
    C.AppendLine('  --amber:#F59E0B; --amber-lt:#FCD34D; --amber-dk:#D97706;');
    C.AppendLine('  --bg:#0F0F1A; --bg-card:#1A1A2E; --bg-sb:#12121F;');
    C.AppendLine('  --bg-item:#1E1E35; --border:#2A2A45;');
    C.AppendLine('  --text:#E5E7EB; --muted:#9CA3AF;');
    C.AppendLine('  --ok:#10B981; --err:#EF4444; --sw:260px;');
    C.AppendLine('}');
    C.AppendLine('*{margin:0;padding:0;box-sizing:border-box;}');
    C.AppendLine('body{font-family:"Segoe UI",sans-serif;background:var(--bg);');
    C.AppendLine('  color:var(--text);height:100vh;overflow:hidden;');
    C.AppendLine('  display:flex;flex-direction:column;}');

    { topbar }
    C.AppendLine('#topbar{height:56px;background:var(--bg-sb);');
    C.AppendLine('  border-bottom:1px solid var(--border);');
    C.AppendLine('  display:flex;align-items:center;padding:0 16px;gap:12px;');
    C.AppendLine('  z-index:200;box-shadow:0 2px 20px rgba(0,0,0,.4);}');
    C.AppendLine('.logo-area{display:flex;align-items:center;gap:10px;min-width:220px;}');
    C.AppendLine('.logo-txt{font-size:14px;font-weight:700;color:var(--amber-lt);}');
    C.AppendLine('.logo-sub{font-size:10px;color:var(--muted);}');

    { busca }
    C.AppendLine('.srch{flex:1;max-width:380px;position:relative;}');
    C.AppendLine('.srch input{width:100%;background:var(--bg-item);border:1px solid var(--border);');
    C.AppendLine('  border-radius:8px;padding:8px 12px 8px 36px;color:var(--text);');
    C.AppendLine('  font-size:13px;outline:none;transition:border-color .2s;}');
    C.AppendLine('.srch input:focus{border-color:var(--amber);}');
    C.AppendLine('.srch .ico{position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--muted);}');
    C.AppendLine('#sr{position:absolute;top:calc(100% + 4px);left:0;right:0;');
    C.AppendLine('  background:var(--bg-card);border:1px solid var(--border);');
    C.AppendLine('  border-radius:8px;z-index:999;max-height:280px;overflow-y:auto;');
    C.AppendLine('  box-shadow:0 8px 32px rgba(0,0,0,.6);display:none;}');
    C.AppendLine('.sr-item{padding:10px 14px;cursor:pointer;font-size:13px;');
    C.AppendLine('  display:flex;align-items:center;gap:8px;transition:background .15s;}');
    C.AppendLine('.sr-item:hover{background:var(--bg-item);}');
    C.AppendLine('.sr-badge{font-size:10px;color:var(--muted);margin-left:auto;');
    C.AppendLine('  background:var(--bg-item);padding:2px 6px;border-radius:4px;}');

    { direita topbar }
    C.AppendLine('.tb-right{margin-left:auto;display:flex;align-items:center;gap:16px;}');
    C.AppendLine('.u-chip{display:flex;align-items:center;gap:8px;background:var(--bg-item);');
    C.AppendLine('  border-radius:20px;padding:4px 12px 4px 4px;}');
    C.AppendLine('.u-av{width:28px;height:28px;border-radius:50%;');
    C.AppendLine('  background:linear-gradient(135deg,var(--amber),var(--amber-dk));');
    C.AppendLine('  display:flex;align-items:center;justify-content:center;');
    C.AppendLine('  font-size:12px;font-weight:700;}');
    C.AppendLine('.tog-btn{background:none;border:none;cursor:pointer;');
    C.AppendLine('  color:var(--muted);padding:4px;transition:color .2s;}');
    C.AppendLine('.tog-btn:hover{color:var(--amber);}');

    { layout }
    C.AppendLine('#lay{display:flex;flex:1;overflow:hidden;}');

    { sidebar }
    C.AppendLine('#sb{width:var(--sw);background:var(--bg-sb);border-right:1px solid var(--border);');
    C.AppendLine('  display:flex;flex-direction:column;overflow:hidden;transition:width .3s ease;}');
    C.AppendLine('#sb.col{width:60px;}');
    C.AppendLine('#sb-sc{flex:1;overflow-y:auto;overflow-x:hidden;padding:8px 0;}');
    C.AppendLine('#sb-sc::-webkit-scrollbar{width:4px;}');
    C.AppendLine('#sb-sc::-webkit-scrollbar-thumb{background:var(--border);border-radius:2px;}');

    { grupos }
    C.AppendLine('.grp{margin-bottom:4px;}');
    C.AppendLine('.gh{display:flex;align-items:center;padding:10px 14px;cursor:pointer;');
    C.AppendLine('  border-radius:8px;margin:0 6px;gap:10px;transition:background .2s;');
    C.AppendLine('  user-select:none;}');
    C.AppendLine('.gh:hover{background:var(--bg-item);}');
    C.AppendLine('.gh.ag{background:rgba(245,158,11,.12);border-left:3px solid var(--amber);}');
    C.AppendLine('.gh .gi{width:20px;height:20px;flex-shrink:0;color:var(--muted);transition:color .2s;}');
    C.AppendLine('.gh.ag .gi{color:var(--amber);}');
    C.AppendLine('.gh .gt{font-size:13px;font-weight:600;flex:1;}');
    C.AppendLine('.gh .ga{margin-left:auto;transition:transform .3s;color:var(--muted);flex-shrink:0;}');
    C.AppendLine('.gh.op .ga{transform:rotate(180deg);}');
    C.AppendLine('.bc-tag{font-size:9px;background:rgba(156,163,175,.2);color:var(--muted);');
    C.AppendLine('  padding:2px 6px;border-radius:4px;margin-right:4px;}');

    { itens }
    C.AppendLine('.gi-wrap{overflow:hidden;max-height:0;transition:max-height .35s ease;}');
    C.AppendLine('.gi-wrap.op{max-height:600px;}');
    C.AppendLine('.mi{display:flex;align-items:center;padding:9px 14px 9px 38px;gap:10px;');
    C.AppendLine('  cursor:pointer;border-radius:8px;margin:1px 6px;transition:all .2s;font-size:13px;}');
    C.AppendLine('.mi:hover:not(.dis){background:var(--bg-item);}');
    C.AppendLine('.mi.act{background:linear-gradient(90deg,rgba(245,158,11,.2),rgba(245,158,11,.05));');
    C.AppendLine('  color:var(--amber-lt);border-left:2px solid var(--amber);padding-left:36px;}');
    C.AppendLine('.mi.dis{opacity:.4;cursor:not-allowed;}');
    C.AppendLine('.mi .mico{width:16px;height:16px;flex-shrink:0;}');
    C.AppendLine('.mi .mtit{flex:1;}');
    C.AppendLine('.mi .mfav{opacity:0;transition:opacity .2s;color:var(--amber);flex-shrink:0;}');
    C.AppendLine('.mi:hover .mfav{opacity:.5;}');
    C.AppendLine('.mi .mfav.st{opacity:1;}');

    { conteudo }
    C.AppendLine('#cont{flex:1;display:flex;flex-direction:column;overflow:hidden;background:var(--bg);}');

    { favoritos }
    C.AppendLine('#fav-bar{padding:8px 16px;background:var(--bg-card);');
    C.AppendLine('  border-bottom:1px solid var(--border);');
    C.AppendLine('  display:flex;align-items:center;gap:8px;min-height:44px;flex-shrink:0;}');
    C.AppendLine('.fav-lbl{font-size:11px;color:var(--muted);margin-right:4px;white-space:nowrap;}');
    C.AppendLine('.fav-chips{display:flex;gap:6px;flex-wrap:wrap;}');
    C.AppendLine('.fc{background:var(--bg-item);border:1px solid var(--border);border-radius:16px;');
    C.AppendLine('  padding:3px 10px;font-size:12px;cursor:pointer;transition:all .2s;white-space:nowrap;}');
    C.AppendLine('.fc:hover{border-color:var(--amber);color:var(--amber);}');
    C.AppendLine('.fav-empty{font-size:12px;color:var(--muted);font-style:italic;}');

    { abas }
    C.AppendLine('#tabs{background:var(--bg-sb);border-bottom:1px solid var(--border);');
    C.AppendLine('  display:flex;align-items:center;gap:2px;padding:0 8px;');
    C.AppendLine('  min-height:40px;overflow-x:auto;flex-shrink:0;}');
    C.AppendLine('#tabs::-webkit-scrollbar{height:3px;}');
    C.AppendLine('#tabs::-webkit-scrollbar-thumb{background:var(--border);}');
    C.AppendLine('.tab{display:flex;align-items:center;gap:6px;padding:0 14px;height:36px;');
    C.AppendLine('  border-radius:6px 6px 0 0;cursor:pointer;font-size:12px;white-space:nowrap;');
    C.AppendLine('  transition:all .2s;background:var(--bg-item);border:1px solid transparent;');
    C.AppendLine('  border-bottom:none;position:relative;top:1px;}');
    C.AppendLine('.tab:hover{background:var(--bg-card);}');
    C.AppendLine('.tab.act{background:var(--bg);border-color:var(--border);color:var(--amber-lt);}');
    C.AppendLine('.tab-x{opacity:0;transition:opacity .15s;color:var(--muted);');
    C.AppendLine('  width:14px;height:14px;display:flex;align-items:center;justify-content:center;');
    C.AppendLine('  border-radius:3px;background:none;border:none;cursor:pointer;font-size:12px;}');
    C.AppendLine('.tab:hover .tab-x,.tab.act .tab-x{opacity:1;}');
    C.AppendLine('.tab-x:hover{background:rgba(239,68,68,.2);color:var(--err);}');
    C.AppendLine('#tabs-empty{font-size:12px;color:var(--muted);font-style:italic;padding:0 12px;}');

    { breadcrumb }
    C.AppendLine('#bc{padding:8px 20px;font-size:12px;color:var(--muted);');
    C.AppendLine('  display:flex;align-items:center;gap:6px;flex-shrink:0;}');
    C.AppendLine('.bc-sep{color:var(--border);}');
    C.AppendLine('.bc-last{color:var(--amber);}');

    { tela }
    C.AppendLine('#scr{flex:1;overflow:auto;padding:20px;');
    C.AppendLine('  background:radial-gradient(ellipse at top left,rgba(245,158,11,.03) 0%,transparent 60%);}');
    C.AppendLine('.ph{display:flex;flex-direction:column;align-items:center;justify-content:center;');
    C.AppendLine('  height:100%;gap:16px;opacity:.4;}');
    C.AppendLine('.ph p{font-size:15px;color:var(--muted);}');
    C.AppendLine('.scrd{background:var(--bg-card);border:1px solid var(--border);');
    C.AppendLine('  border-radius:12px;padding:28px;animation:fsl .3s ease;}');
    C.AppendLine('.scrd h2{color:var(--amber-lt);font-size:18px;margin-bottom:8px;}');
    C.AppendLine('.scrd p{color:var(--muted);font-size:13px;}');
    C.AppendLine('@keyframes fsl{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}');

    { collapsed sidebar }
    C.AppendLine('#sb.col .gt,#sb.col .ga,#sb.col .bc-tag,#sb.col .mtit,#sb.col .mfav{display:none;}');
    C.AppendLine('#sb.col .gh{justify-content:center;padding:10px;}');
    C.AppendLine('#sb.col .mi{justify-content:center;padding:9px;}');
    C.AppendLine('#sb.col .mi.act{border-left:none;padding:9px;}');
    C.AppendLine('#sb.col .gi-wrap.op{max-height:0!important;}');

    { scrollbar }
    C.AppendLine('::-webkit-scrollbar{width:6px;height:6px;}');
    C.AppendLine('::-webkit-scrollbar-track{background:var(--bg);}');
    C.AppendLine('::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}');

    Result := C.ToString;
  finally
    C.Free;
  end;
end;

{ ── JavaScript ── }

function TFrmPrincipal.BuildJs: string;
var
  J: TStringBuilder;
begin
  J := TStringBuilder.Create;
  try
    J.AppendLine('var OT={}, FAV=[], COL=false;');
    J.AppendLine('var _aj=typeof ajaxRequest!="undefined"?ajaxRequest:parent.ajaxRequest;');
    J.AppendLine('var _cp=typeof UniHTMLFrame1!="undefined"?UniHTMLFrame1:parent.UniHTMLFrame1;');

    { toggle sidebar }
    J.AppendLine('function togSB(){');
    J.AppendLine('  COL=!COL;');
    J.AppendLine('  document.getElementById("sb").classList.toggle("col",COL);');
    J.AppendLine('}');

    { toggle grupo }
    J.AppendLine('function togGrp(el){');
    J.AppendLine('  var h=el.closest(".gh");');
    J.AppendLine('  var w=h.nextElementSibling;');
    J.AppendLine('  var wasOpen=w.classList.contains("op");');
    J.AppendLine('  document.querySelectorAll(".gi-wrap.op").forEach(function(i){');
    J.AppendLine('    i.classList.remove("op");');
    J.AppendLine('    i.previousElementSibling.classList.remove("op","ag");');
    J.AppendLine('  });');
    J.AppendLine('  if(!wasOpen){w.classList.add("op");h.classList.add("op","ag");}');
    J.AppendLine('}');

    { navegar - chama servidor }
    J.AppendLine('function nav(route,cap,bread){');
    J.AppendLine('  if(!route)return;');
    J.AppendLine('  _aj(_cp,"nav",[route,cap,bread]);');
    J.AppendLine('}');

    { abrir aba - chamado pelo servidor via addJS }
    J.AppendLine('function openTab(route,cap,bread){');
    J.AppendLine('  if(OT[route]){actTab(route,bread);return;}');
    J.AppendLine('  OT[route]={cap:cap,bread:bread};');
    J.AppendLine('  var wrap=document.getElementById("tabs");');
    J.AppendLine('  var emp=document.getElementById("tabs-empty");');
    J.AppendLine('  if(emp)emp.remove();');
    J.AppendLine('  var tab=document.createElement("div");');
    J.AppendLine('  tab.className="tab";');
    J.AppendLine('  tab.dataset.route=route;');
    J.AppendLine('  var lbl=document.createElement("span");');
    J.AppendLine('  lbl.textContent=cap;');
    J.AppendLine('  var btn=document.createElement("button");');
    J.AppendLine('  btn.className="tab-x";');
    J.AppendLine('  btn.textContent="\u00D7";');
    J.AppendLine('  btn.title="Fechar";');
    J.AppendLine('  (function(r){');
    J.AppendLine('    btn.addEventListener("click",function(e){e.stopPropagation();closeTab(r);});');
    J.AppendLine('    tab.addEventListener("click",function(){actTab(r,OT[r].bread);});');
    J.AppendLine('  })(route);');
    J.AppendLine('  tab.appendChild(lbl);');
    J.AppendLine('  tab.appendChild(btn);');
    J.AppendLine('  wrap.appendChild(tab);');
    J.AppendLine('  actTab(route,bread);');
    J.AppendLine('  document.querySelectorAll(".mi").forEach(function(m){');
    J.AppendLine('    m.classList.toggle("act",m.dataset.route===route);');
    J.AppendLine('  });');
    J.AppendLine('}');

    { ativar aba }
    J.AppendLine('function actTab(route,bread){');
    J.AppendLine('  document.querySelectorAll(".tab").forEach(function(t){');
    J.AppendLine('    t.classList.toggle("act",t.dataset.route===route);');
    J.AppendLine('  });');
    J.AppendLine('  document.querySelectorAll(".mi").forEach(function(m){');
    J.AppendLine('    m.classList.toggle("act",m.dataset.route===route);');
    J.AppendLine('  });');
    J.AppendLine('  var b=bread||(OT[route]&&OT[route].bread)||"";');
    J.AppendLine('  var c=OT[route]&&OT[route].cap||"";');
    J.AppendLine('  renderBC(b);');
    J.AppendLine('  renderScr(route,c);');
    J.AppendLine('}');

    { fechar aba }
    J.AppendLine('function closeTab(route){');
    J.AppendLine('  var tab=document.querySelector(".tab[data-route="+JSON.stringify(route)+"]");');
    J.AppendLine('  if(!tab)return;');
    J.AppendLine('  var wasAct=tab.classList.contains("act");');
    J.AppendLine('  tab.remove();');
    J.AppendLine('  delete OT[route];');
    J.AppendLine('  _aj(_cp,"closeTab",[route]);');
    J.AppendLine('  var rem=document.querySelectorAll(".tab");');
    J.AppendLine('  if(wasAct&&rem.length>0){');
    J.AppendLine('    var last=rem[rem.length-1];');
    J.AppendLine('    actTab(last.dataset.route,"");');
    J.AppendLine('  }else if(rem.length===0){');
    J.AppendLine('    var w=document.getElementById("tabs");');
    J.AppendLine('    var s=document.createElement("span");');
    J.AppendLine('    s.id="tabs-empty";s.textContent="Nenhuma tela aberta";');
    J.AppendLine('    w.appendChild(s);');
    J.AppendLine('    renderBC("");renderScr("","");');
    J.AppendLine('  }');
    J.AppendLine('  document.querySelectorAll(".mi").forEach(function(m){m.classList.remove("act");});');
    J.AppendLine('}');

    { breadcrumb }
    J.AppendLine('function renderBC(bread){');
    J.AppendLine('  var el=document.getElementById("bc");');
    J.AppendLine('  if(!bread){el.innerHTML="";return;}');
    J.AppendLine('  var p=bread.split(" > ");');
    J.AppendLine('  el.innerHTML=p.map(function(s,i){');
    J.AppendLine('    return i<p.length-1');
    J.AppendLine('      ?"<span>"+s+"</span><span class=bc-sep>&#10095;</span>"');
    J.AppendLine('      :"<span class=bc-last>"+s+"</span>";');
    J.AppendLine('  }).join("");');
    J.AppendLine('}');

    { tela placeholder }
    J.AppendLine('function renderScr(route,cap){');
    J.AppendLine('  var el=document.getElementById("scr");');
    J.AppendLine('  if(!route){');
    J.AppendLine('    el.innerHTML="<div class=ph><p>Selecione uma tela no menu</p></div>";');
    J.AppendLine('    return;');
    J.AppendLine('  }');
    J.AppendLine('  el.innerHTML="<div class=scrd><h2>"+cap+"</h2>"');
    J.AppendLine('    +"<p>Tela em desenvolvimento &mdash; rota: <strong>"+route+"</strong></p></div>";');
    J.AppendLine('}');

    { favoritos - toggle }
    J.AppendLine('function togFav(el,route){');
    J.AppendLine('  el.classList.toggle("st");');
    J.AppendLine('  _aj(_cp,"toggleFav",[route]);');
    J.AppendLine('}');

    { favoritos - atualizar chips (chamado pelo servidor) }
    J.AppendLine('function refreshFavs(json){');
    J.AppendLine('  FAV=JSON.parse(json);');
    J.AppendLine('  var chips=document.getElementById("fav-chips");');
    J.AppendLine('  var emp=document.getElementById("fav-emp");');
    J.AppendLine('  chips.innerHTML="";');
    J.AppendLine('  if(FAV.length===0){if(emp)emp.style.display="";return;}');
    J.AppendLine('  if(emp)emp.style.display="none";');
    J.AppendLine('  FAV.forEach(function(r){');
    J.AppendLine('    var m=document.querySelector(".mi[data-route="+JSON.stringify(r)+"]");');
    J.AppendLine('    var cap=m?m.querySelector(".mtit").textContent:r;');
    J.AppendLine('    var bread=m?m.dataset.bread:"";');
    J.AppendLine('    var ch=document.createElement("span");');
    J.AppendLine('    ch.className="fc";ch.textContent=cap;');
    J.AppendLine('    (function(ro,ca,br){ch.addEventListener("click",function(){nav(ro,ca,br);});})(r,cap,bread);');
    J.AppendLine('    chips.appendChild(ch);');
    J.AppendLine('  });');
    J.AppendLine('}');

    { busca }
    J.AppendLine('function doSearch(val){');
    J.AppendLine('  var res=document.getElementById("sr");');
    J.AppendLine('  if(!val.trim()){res.style.display="none";return;}');
    J.AppendLine('  var items=Array.from(document.querySelectorAll(".mi:not(.dis)"));');
    J.AppendLine('  var matched=items.filter(function(m){');
    J.AppendLine('    return m.querySelector(".mtit").textContent.toLowerCase().indexOf(val.toLowerCase())>=0;');
    J.AppendLine('  });');
    J.AppendLine('  res.innerHTML="";');
    J.AppendLine('  if(matched.length===0){');
    J.AppendLine('    var nd=document.createElement("div");');
    J.AppendLine('    nd.className="sr-item";nd.textContent="Nenhum resultado";');
    J.AppendLine('    nd.style.color="var(--muted)";');
    J.AppendLine('    res.appendChild(nd);');
    J.AppendLine('  }else{');
    J.AppendLine('    matched.forEach(function(m){');
    J.AppendLine('      var r=m.dataset.route;');
    J.AppendLine('      var cap=m.querySelector(".mtit").textContent;');
    J.AppendLine('      var bread=m.dataset.bread;');
    J.AppendLine('      var d=document.createElement("div");');
    J.AppendLine('      d.className="sr-item";');
    J.AppendLine('      var sp=document.createElement("span");');
    J.AppendLine('      sp.textContent=cap;');
    J.AppendLine('      var badge=document.createElement("span");');
    J.AppendLine('      badge.className="sr-badge";badge.textContent=r;');
    J.AppendLine('      d.appendChild(sp);d.appendChild(badge);');
    J.AppendLine('      (function(ro,ca,br){d.addEventListener("click",function(){');
    J.AppendLine('        nav(ro,ca,br);res.style.display="none";');
    J.AppendLine('        document.getElementById("srch-inp").value="";');
    J.AppendLine('      });})(r,cap,bread);');
    J.AppendLine('      res.appendChild(d);');
    J.AppendLine('    });');
    J.AppendLine('  }');
    J.AppendLine('  res.style.display="block";');
    J.AppendLine('}');

    { fechar busca ao clicar fora }
    J.AppendLine('document.addEventListener("click",function(e){');
    J.AppendLine('  if(!e.target.closest(".srch"))');
    J.AppendLine('    document.getElementById("sr").style.display="none";');
    J.AppendLine('});');

    { init: abrir primeiro grupo }
    J.AppendLine('window.addEventListener("load",function(){');
    J.AppendLine('  var h=document.querySelector(".gh");');
    J.AppendLine('  if(h){var w=h.nextElementSibling;h.classList.add("op","ag");w.classList.add("op");}');
    J.AppendLine('  renderScr("","");');
    J.AppendLine('});');

    Result := J.ToString;
  finally
    J.Free;
  end;
end;

{ ── Sidebar HTML ── }

function TFrmPrincipal.BuildSidebarHtml(const AItems: TArray<TMenuItemRec>): string;
const
  ICO_ARROW = 'M19 9l-7 7-7-7';
  ICO_STAR  = 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z';
  C_OPEN : array[Boolean] of string = ('', ' op ag');
  C_DIS  : array[Boolean] of string = ('', ' dis');

  function Svg(const APath: string; AW: Integer = 20): string;
  begin
    Result := Format(
      '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
      'stroke-linecap="round" stroke-linejoin="round"><path d="%s"/></svg>',
      [AW, AW, APath]);
  end;

var
  S      : TStringBuilder;
  Item   : TMenuItemRec;
  LGrp   : string;
  LOpen  : Boolean;
begin
  S    := TStringBuilder.Create;
  LGrp := '';
  try
    for Item in AItems do
    begin
      if Item.ParentID = '' then
      begin
        { Fechar grupo anterior }
        if LGrp <> '' then
          S.Append('</div></div>');

        LGrp  := Item.ID;
        LOpen := Item.Enabled;

        S.Append('<div class="grp">');
        S.AppendFormat(
          '<div class="gh%s" onclick="togGrp(this)">' +
          '<span class="gi">%s</span>' +
          '<span class="gt">%s</span>',
          [C_OPEN[LOpen], Svg(Item.Icon, 20), Item.Caption]);

        { badge Em breve para grupos desabilitados }
        if not Item.Enabled then
          S.Append('<span class="bc-tag">Em breve</span>');

        S.AppendFormat(
          '<span class="ga">%s</span></div>',
          [Svg(ICO_ARROW, 14)]);

        S.AppendFormat('<div class="gi-wrap%s">', [C_OPEN[LOpen]]);
      end
      else
      begin
        S.AppendFormat(
          '<div class="mi%s" data-route="%s" data-bread="%s" ' +
          'onclick="nav(''%s'',''%s'',''%s'')">' +
          '<span class="mico">%s</span>' +
          '<span class="mtit">%s</span>' +
          '<span class="mfav" title="Favoritar" ' +
          'onclick="event.stopPropagation();togFav(this,''%s'')">%s</span>' +
          '</div>',
          [C_DIS[not Item.Enabled],
           Item.Route, Item.BreadPath,
           Item.Route, Item.Caption, Item.BreadPath,
           Svg(Item.Icon, 16),
           Item.Caption,
           Item.Route,
           Svg(ICO_STAR, 12)]);
      end;
    end;

    if LGrp <> '' then
      S.Append('</div></div>');

    Result := S.ToString;
  finally
    S.Free;
  end;
end;

{ ── BuildHtml ── }

procedure TFrmPrincipal.BuildHtml;
var
  H        : TStringBuilder;
  LItems   : TArray<TMenuItemRec>;
  LFilesURL: string;
  LLogoURL : string;

  function Svg(const APath: string; AW: Integer = 20): string;
  begin
    Result := Format(
      '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">' +
      '<path d="%s"/></svg>',
      [AW, AW, APath]);
  end;

begin
  LFilesURL := UniServerModule.FilesFolderURL;
  LLogoURL  := LFilesURL + 'logo_transportadora.png?v=' +
               FormatDateTime('yyyymmddhhnnss', Now);

  LItems := FController.GetMenuItems;

  H := TStringBuilder.Create;
  try
    H.AppendLine('<!DOCTYPE html><html lang="pt-BR">');
    H.AppendLine('<head><meta charset="UTF-8">');
    H.AppendLine('<meta name="viewport" content="width=device-width,initial-scale=1">');
    H.AppendLine('<style>' + BuildCss + '</style>');
    H.AppendLine('</head><body>');

    { ── Topbar ── }
    H.AppendLine('<div id="topbar">');
    H.AppendLine('  <div class="logo-area">');
    H.AppendFormat('  <img src="%s" style="height:36px;filter:drop-shadow(0 0 6px rgba(245,158,11,.6));" alt="logo">', [LLogoURL]);
    H.AppendLine;
    H.AppendLine('  <div><div class="logo-txt">Grupo DT&amp;LL</div>');
    H.AppendLine('    <div class="logo-sub">Sistema de Transportadoras</div></div>');
    H.AppendLine('  </div>');

    H.AppendLine('  <div class="srch">');
    H.AppendLine('    <span class="ico">' + Svg('M21 21l-4.35-4.35M11 19a8 8 0 100-16 8 8 0 000 16z', 14) + '</span>');
    H.AppendLine('    <input type="text" id="srch-inp" placeholder="Buscar telas..."');
    H.AppendLine('           oninput="doSearch(this.value)">');
    H.AppendLine('    <div id="sr"></div>');
    H.AppendLine('  </div>');

    H.AppendLine('  <div class="tb-right">');
    H.AppendLine('    <div class="u-chip">');
    H.AppendLine('      <div class="u-av">AD</div>');
    H.AppendLine('      <span style="font-size:13px">Administrador</span>');
    H.AppendLine('    </div>');
    H.AppendLine('    <button class="tog-btn" onclick="togSB()" title="Recolher menu">');
    H.AppendLine('      ' + Svg('M3 12h18M3 6h18M3 18h18', 20));
    H.AppendLine('    </button>');
    H.AppendLine('  </div>');
    H.AppendLine('</div>');

    { ── Layout ── }
    H.AppendLine('<div id="lay">');

    { ── Sidebar ── }
    H.AppendLine('<div id="sb"><div id="sb-sc">');
    H.Append(BuildSidebarHtml(LItems));
    H.AppendLine('</div></div>');

    { ── Conteúdo ── }
    H.AppendLine('<div id="cont">');

    H.AppendLine('<div id="fav-bar">');
    H.AppendLine('  <span class="fav-lbl">&#9733; Favoritos:</span>');
    H.AppendLine('  <div class="fav-chips" id="fav-chips"></div>');
    H.AppendLine('  <span id="fav-emp" class="fav-empty">');
    H.AppendLine('    Clique na estrela em um item do menu para favoritar</span>');
    H.AppendLine('</div>');

    H.AppendLine('<div id="tabs">');
    H.AppendLine('  <span id="tabs-empty">Nenhuma tela aberta</span>');
    H.AppendLine('</div>');

    H.AppendLine('<div id="bc"></div>');
    H.AppendLine('<div id="scr"></div>');

    H.AppendLine('</div>'); { /cont }
    H.AppendLine('</div>'); { /lay }

    H.AppendLine('<script>' + BuildJs + '</script>');
    H.AppendLine('</body></html>');

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
      { nav }
      try
        FController.NavigateTo(LRoute);
      except
        on E: EAssertionFailed do
          UniSession.AddJS(
            'alert(' + QuotedStr(E.Message) + ');');
      end;
    end;

  LAct[1] := procedure
    begin
      { closeTab }
      FController.CloseTab(LRoute);
    end;

  LAct[2] := procedure
    begin
      { toggleFav }
      FController.ToggleFavorite(LRoute);
    end;

  LAct[3] := procedure begin end;

  LAct[
    Ord(EventName = 'nav')       * 0 +
    Ord(EventName = 'closeTab')  * 1 +
    Ord(EventName = 'toggleFav') * 2
  ]();
end;

{ ── IMainView ── }

procedure TFrmPrincipal.OpenTab(const ARoute, ACaption, ABreadPath: string);
begin
  UniSession.AddJS(Format(
    'openTab(%s,%s,%s);',
    [QuotedStr(ARoute), QuotedStr(ACaption), QuotedStr(ABreadPath)]));
end;

procedure TFrmPrincipal.CloseTab(const ARoute: string);
begin
  { Fechamento já tratado no JS; nada a fazer no servidor }
end;

procedure TFrmPrincipal.RefreshFavorites(const AFavorites: TArray<string>);
var
  LJSON : TJSONArray;
  LFav  : string;
begin
  LJSON := TJSONArray.Create;
  try
    for LFav in AFavorites do
      LJSON.Add(LFav);
    UniSession.AddJS('refreshFavs(' + QuotedStr(LJSON.ToString) + ');');
  finally
    LJSON.Free;
  end;
end;

end.
