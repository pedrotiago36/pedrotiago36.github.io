unit View.FrmLogin;

{ Form unico da aplicacao.
  - Fase LOGIN : renderiza a tela de autenticacao no frame
  - Fase MAIN  : apos login bem-sucedido, substitui o HTML pelo app principal
  Em UniGUI o form principal eh a janela do browser; nao criamos forms secundarios. }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  uniGUITypes, uniGUIAbstractClasses, uniGUIClasses,
  uniGUIRegClasses, uniGUIForm,
  uniURLFrame, uniGUIBaseClasses,
  View.ILoginView,
  Controller.ILoginController,
  Controller.IMainController,
  Model.ILogin,
  Model.IMenuItem;

type
  TFrmLogin = class(TUniForm, ILoginView, IMainView)
    HtmlLogin: TUniURLFrame;
    procedure UniFormCreate(Sender: TObject);
    procedure HtmlLoginAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    { estado }
    FInMain     : Boolean;
    FJSFrame    : string;  { parent['JSName'] — calculado uma vez }
    { login }
    FLoginCtrl  : ILoginController;
    FUser       : string;
    FPwd        : string;
    { main }
    FMainCtrl   : IMainController;
    { construtores de HTML }
    function  BuildLoginHtml: string;
    function  BuildMainHtml: string;
    function  RenderSidebar(const AItems: TArray<TMenuItemRec>): string;
    { handlers por fase }
    procedure HandleLoginEvent(EventName: string; Params: TUniStrings);
    procedure HandleMainEvent(EventName: string; Params: TUniStrings);
    { ILoginView }
    function  CollectCredentials: TLoginCredentials;
    procedure NotifySuccess(const AMessage: string);
    procedure NotifyFailure(const AMessage: string);
    { IMainView }
    procedure OpenTab(const ARoute, ACaption, ABreadPath: string);
    procedure CloseTab(const ARoute: string);
    procedure RefreshFavorites(const AFavorites: TArray<string>);
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

uses
  StrUtils,
  Model.TLogin,
  Controller.TLoginController,
  Controller.TMainController,
  uniGUIApplication,
  uniGUIVars,
  ServerModule,
  uniGUIServer;

{ ══════════════════════════════════════════════════════════════
  Inicializacao
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.UniFormCreate(Sender: TObject);
begin
  FInMain  := False;
  FJSFrame := 'parent[' + QuotedStr(HtmlLogin.JSName) + ']';

  FLoginCtrl := NewLoginController(NewLogin);
  FLoginCtrl.BindView(Self);

  { TUniURLFrame.HTML.Text dispara LoadCompleted → SetWebHTML → document.write no iframe }
  HtmlLogin.HTML.Text := BuildLoginHtml;

  { Remove qualquer overlay/mask que o ExtJS coloca durante o render inicial.
    Usa afterrender para garantir que o componente ja esta no DOM.
    c.iframe = propriedade nativa do Ext.panel.iframe (TUniURLFrame). }
  UniSession.AddJS(
    'var _c=' + HtmlLogin.JSName + ';' +
    'function _unblock(){' +
    '  try{_c.setLoading(false);}catch(e){}' +
    '  try{_c.getEl().dom.style.pointerEvents="auto";}catch(e){}' +
    '  try{if(_c.iframe)_c.iframe.style.pointerEvents="auto";}catch(e){}' +
    '}' +
    'if(_c.rendered){_unblock();}' +
    'else{_c.on("afterrender",_unblock,null,{single:true});}' +
    'setTimeout(_unblock,800);'
  );
end;

{ ══════════════════════════════════════════════════════════════
  Dispatcher de eventos Ajax
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.HtmlLoginAjaxEvent(Sender: TComponent; EventName: string;
  Params: TUniStrings);
type
  TPhaseProc = array[Boolean] of TProc;
var
  LPhase : TPhaseProc;
begin
  LPhase[False] := procedure begin HandleLoginEvent(EventName, Params) end;
  LPhase[True]  := procedure begin HandleMainEvent(EventName, Params)  end;
  LPhase[FInMain]();
end;

{ ── fase LOGIN ── }

procedure TFrmLogin.HandleLoginEvent(EventName: string; Params: TUniStrings);
begin
  FUser := Params.Values['user'];
  FPwd  := Params.Values['pwd'];
  try
    FLoginCtrl.ExecuteLogin;
  except
    on E: EAssertionFailed do NotifyFailure(E.Message);
    on E: Exception       do NotifyFailure('Erro interno: ' + E.Message);
  end;
end;

{ ── fase MAIN ── }

procedure TFrmLogin.HandleMainEvent(EventName: string; Params: TUniStrings);
type
  TAct = array[0..3] of TProc;
var
  LRoute : string;
  LAct   : TAct;
begin
  LRoute := Params.Values['route'];

  LAct[0] := procedure
    begin
      try FMainCtrl.NavigateTo(LRoute);
      except on E: EAssertionFailed do
        UniSession.AddJS('alert(' + QuotedStr(E.Message) + ')');
      end;
    end;
  LAct[1] := procedure begin FMainCtrl.CloseTab(LRoute); end;
  LAct[2] := procedure begin FMainCtrl.ToggleFavorite(LRoute); end;
  LAct[3] := procedure begin end;

  LAct[
    Ord(EventName='nav')       * 0 +
    Ord(EventName='closeTab')  * 1 +
    Ord(EventName='toggleFav') * 2
  ]();
end;

{ ══════════════════════════════════════════════════════════════
  ILoginView
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.CollectCredentials: TLoginCredentials;
begin
  Result := TLoginCredentials.New(FUser, FPwd);
end;

procedure TFrmLogin.NotifySuccess(const AMessage: string);
begin
  try
    FInMain   := True;
    FMainCtrl := NewMainController;
    FMainCtrl.BindView(Self);
    { NotifyAjax do TUniURLFrame envia o novo HTML via SetWebHTML → document.write }
    HtmlLogin.HTML.Text := BuildMainHtml;
  except
    on E: Exception do
    begin
      FInMain := False;
      NotifyFailure('Erro ao carregar o sistema: ' + E.Message);
    end;
  end;
end;

procedure TFrmLogin.NotifyFailure(const AMessage: string);
begin
  { Ext.Msg.alert roda no contexto da pagina principal (ExtJS) — sempre disponivel }
  UniSession.AddJS('Ext.Msg.alert("Aten' + #231 + #227 + 'o",' + QuotedStr(AMessage) + ');');
end;

{ ══════════════════════════════════════════════════════════════
  IMainView
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.OpenTab(const ARoute, ACaption, ABreadPath: string);
begin
  { O JS do iframe já abre a aba imediatamente em navTo() — no-op aqui }
end;

procedure TFrmLogin.CloseTab(const ARoute: string);
begin
  { O JS do iframe já fechou a aba — no-op aqui }
end;

procedure TFrmLogin.RefreshFavorites(const AFavorites: TArray<string>);
begin
  { O JS do iframe gerencia a lista de favoritos localmente — no-op aqui }
end;

{ ══════════════════════════════════════════════════════════════
  HTML da tela de LOGIN
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.BuildLoginHtml: string;
const
  Q = '''';
var
  S        : TStringBuilder;
  LFilesURL: string;
  LBgURL   : string;
  LLogoURL : string;
begin
  LFilesURL := UniServerModule.FilesFolderURL;
  LBgURL    := LFilesURL + 'bg_login.jpg?v='              + FormatDateTime('yyyymmddhhnnss', Now);
  LLogoURL  := LFilesURL + 'logo_transportadora.png?v='   + FormatDateTime('yyyymmddhhnnss', Now);

  S := TStringBuilder.Create;
  try
    S.Append('<!DOCTYPE html><html lang="pt-BR">');
    S.Append('<head><meta charset="UTF-8">');
    S.Append('<meta name="viewport" content="width=device-width,initial-scale=1.0">');
    S.Append('<style>');

    S.Append('*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}');
    S.Append('html,body{width:100%;height:100%;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;background:#030100}');
    S.Append('#bg{position:fixed;inset:0;z-index:0;');
    S.Append('background:linear-gradient(135deg,#1a0800 0%,#0D0D1A 45%,#00051a 100%);');
    { Sobrepos imagem quando existir, sem travar se o arquivo nao existir }
    S.Append('background-image:url(' + Q + LBgURL + Q + ');');
    S.Append('background-size:cover;background-position:center;background-repeat:no-repeat}');
    S.Append('#ov1{position:fixed;inset:0;z-index:2;pointer-events:none;background:rgba(10,4,0,0.42)}');
    S.Append('#ov2{position:fixed;bottom:0;left:0;right:0;height:45%;z-index:3;pointer-events:none;');
    S.Append('background:linear-gradient(to top,rgba(8,3,0,0.60) 0%,transparent 100%)}');
    S.Append('#ov3{position:fixed;top:0;left:0;right:0;height:30%;z-index:3;pointer-events:none;');
    S.Append('background:linear-gradient(to bottom,rgba(8,3,0,0.35) 0%,transparent 100%)}');
    S.Append('#tela{position:fixed;inset:0;z-index:10;display:flex;align-items:center;justify-content:center}');
    S.Append('.card{width:440px;background:rgba(8,3,1,0.62);');
    S.Append('border-radius:28px;border:1px solid rgba(255,175,55,0.22);padding:32px 36px 28px;');
    S.Append('box-shadow:0 32px 100px rgba(0,0,0,0.72);');
    S.Append('backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);');
    S.Append('animation:cardIn .55s cubic-bezier(.22,1,.36,1) both}');
    S.Append('@keyframes cardIn{from{opacity:0;transform:translateY(28px)}to{opacity:1;transform:translateY(0)}}');
    S.Append('.logo-sec{display:flex;flex-direction:column;align-items:center;gap:4px;margin-bottom:22px}');
    S.Append('.logo-wrap img{width:180px;height:auto;display:block;filter:drop-shadow(0 4px 20px rgba(200,70,5,0.45))}');
    S.Append('.logo-div{width:90%;height:1px;margin:14px auto 16px;background:linear-gradient(to right,transparent,rgba(255,185,55,0.35),transparent)}');
    S.Append('.logo-nm{font-size:26px;font-weight:900;letter-spacing:-.4px;color:#FFE888;text-align:center;text-shadow:0 0 24px rgba(255,185,40,0.55)}');
    S.Append('.logo-nm span{color:#E8520A}');
    S.Append('.logo-sl{font-size:10px;font-weight:600;color:rgba(255,200,90,0.50);text-align:center;letter-spacing:3.5px;text-transform:uppercase;margin-top:2px}');
    S.Append('.badge{display:inline-flex;align-items:center;gap:6px;font-size:10px;font-weight:600;color:rgba(65,230,115,0.92);letter-spacing:.8px;text-transform:uppercase;margin-bottom:14px}');
    S.Append('.dot{width:6px;height:6px;border-radius:50%;background:#41E673;box-shadow:0 0 8px rgba(65,230,115,.88);animation:pulse 2s ease-in-out infinite}');
    S.Append('@keyframes pulse{0%,100%{box-shadow:0 0 6px rgba(65,230,115,.65)}50%{box-shadow:0 0 14px rgba(65,230,115,1)}}');
    S.Append('.titulo{font-size:21px;font-weight:700;color:rgba(255,245,220,0.97);letter-spacing:-.4px;line-height:1.15}');
    S.Append('.subtitulo{font-size:12px;color:rgba(255,200,130,0.38);margin-top:4px;margin-bottom:26px}');
    S.Append('.campo{margin-bottom:18px}');
    S.Append('.clabel{font-size:10.5px;font-weight:600;color:rgba(255,180,65,0.52);letter-spacing:1px;text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:5px;transition:color .2s}');
    S.Append('.campo.foc .clabel{color:rgba(255,210,80,1)}.campo.err .clabel{color:rgba(255,85,70,0.85)}');
    S.Append('.cbox{position:relative;display:flex;align-items:center}');
    S.Append('.cinput{width:100%!important;height:48px!important;padding:0 46px!important;');
    S.Append('background:rgba(255,255,255,0.08)!important;border:none!important;border-radius:12px!important;');
    S.Append('color:rgba(255,245,222,0.97)!important;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif!important;');
    S.Append('font-size:14px!important;outline:none!important;caret-color:#FFCC40!important;');
    S.Append('box-shadow:0 0 0 1.5px rgba(255,170,50,0.22),inset 0 1.5px 0 rgba(255,255,255,0.07)!important;transition:all .2s!important}');
    S.Append('.cinput::placeholder{color:rgba(255,195,110,0.28)!important;font-size:13px!important}');
    S.Append('.cinput:-webkit-autofill{-webkit-box-shadow:0 0 0px 1000px rgba(30,12,2,0.92) inset!important;-webkit-text-fill-color:rgba(255,245,222,0.97)!important}');
    S.Append('.campo.foc .cinput{background:rgba(255,165,38,0.13)!important;box-shadow:0 0 0 2px rgba(255,200,60,0.60),0 0 0 5px rgba(255,160,35,0.14)!important}');
    S.Append('.campo.err .cinput{box-shadow:0 0 0 2px rgba(255,72,58,0.60)!important;animation:shk .26s ease!important}');
    S.Append('@keyframes shk{0%,100%{transform:translateX(0)}20%,60%{transform:translateX(-5px)}40%,80%{transform:translateX(5px)}}');
    S.Append('.cicone{position:absolute;left:0;top:0;bottom:0;width:46px;display:flex;align-items:center;justify-content:center;color:rgba(255,180,60,0.28);pointer-events:none;transition:color .2s}');
    S.Append('.campo.foc .cicone{color:rgba(255,210,75,0.76)}.campo.err .cicone{color:rgba(255,82,65,0.70)}');
    S.Append('.bolho{position:absolute;right:0;top:0;bottom:0;width:46px;background:none;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;color:rgba(255,180,60,0.26);border-radius:0 12px 12px 0;transition:color .18s}');
    S.Append('.bolho:hover{color:rgba(255,210,75,0.90)}');
    S.Append('.errmsg{font-size:11.5px;font-weight:500;color:rgba(255,95,75,0.94);margin-top:12px;min-height:16px;display:none;animation:fadeIn .2s ease}');
    S.Append('@keyframes fadeIn{from{opacity:0;transform:translateY(-4px)}to{opacity:1;transform:translateY(0)}}');
    S.Append('.div{height:1px;margin:16px 0 14px;background:linear-gradient(to right,transparent,rgba(255,170,50,0.14),transparent)}');
    S.Append('.togrow{display:flex;align-items:center;justify-content:space-between;margin-bottom:22px}');
    S.Append('.tog{display:flex;align-items:center;gap:10px;cursor:pointer}');
    S.Append('.ttrack{width:34px;height:19px;background:rgba(255,255,255,0.08);border-radius:10px;position:relative;box-shadow:0 0 0 1px rgba(255,165,45,0.14);transition:background .2s}');
    S.Append('.ttrack::after{content:"";position:absolute;top:3px;left:3px;width:13px;height:13px;border-radius:50%;background:rgba(255,185,90,0.32);transition:transform .22s}');
    S.Append('.tog input{display:none}.tog input:checked~.ttrack{background:rgba(255,155,30,0.22)}');
    S.Append('.tog input:checked~.ttrack::after{transform:translateX(15px);background:#FFAA18}');
    S.Append('.tlabel{font-size:12px;color:rgba(255,200,120,0.46)}');
    S.Append('.lbtn{background:none;border:none;cursor:pointer;padding:0;font-size:12px;font-weight:500;color:rgba(255,172,55,0.58);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;transition:color .16s}');
    S.Append('.lbtn:hover{color:rgba(255,215,80,0.92)}');
    S.Append('#btnLogin{width:100%;height:52px;border:none;border-radius:14px;cursor:pointer;');
    S.Append('font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif;font-size:13px;font-weight:700;letter-spacing:1.8px;text-transform:uppercase;color:#1a0800;');
    S.Append('background:linear-gradient(90deg,transparent 0%,rgba(255,115,15,0.38) 10%,rgba(255,190,55,0.85) 35%,rgba(255,238,120,1) 50%,rgba(255,190,55,0.85) 65%,rgba(255,115,15,0.38) 90%,transparent 100%);');
    S.Append('background-size:200% 100%;box-shadow:0 4px 20px rgba(255,160,30,0.35);');
    S.Append('transition:box-shadow .3s,transform .15s;animation:shimmer 3s ease-in-out infinite}');
    S.Append('@keyframes shimmer{0%,100%{background-position:100% 0}50%{background-position:-100% 0}}');
    S.Append('#btnLogin:hover{box-shadow:0 6px 28px rgba(255,175,35,0.55);transform:translateY(-1px)}');
    S.Append('#btnLogin:active{transform:translateY(0)}');
    S.Append('#btnLogin.loading{pointer-events:none;opacity:.7;animation:none}');
    S.Append('.footer{margin-top:20px;display:flex;align-items:center;justify-content:center;gap:8px;font-size:10px;color:rgba(255,175,70,0.28)}');
    S.Append('.footer .sep{color:rgba(255,140,40,0.18)}');
    S.Append('</style></head><body>');

    S.Append('<div id="bg"></div>');
    S.Append('<div id="ov1"></div><div id="ov2"></div><div id="ov3"></div>');
    S.Append('<div id="tela"><div class="card" id="card">');

    S.Append('<div class="logo-sec">');
    S.Append('<div class="logo-wrap"><img src="' + LLogoURL + '" alt="logo"/></div>');
    S.Append('<div class="logo-div"></div>');
    S.Append('<div class="logo-nm">Grupo DT<span>&amp;</span>LL</div>');
    S.Append('<div class="logo-sl">Tecnologia em Movimento</div>');
    S.Append('</div>');

    S.Append('<div class="badge"><div class="dot"></div>Sistema online</div>');
    S.Append('<div class="titulo">Sistema de Transportadoras</div>');
    S.Append('<div class="subtitulo">Insira suas credenciais para continuar</div>');

    { campo usuario }
    S.Append('<div class="campo" id="cf_user">');
    S.Append('<div class="clabel">');
    S.Append('<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>');
    S.Append('Usu&aacute;rio</div>');
    S.Append('<div class="cbox">');
    S.Append('<div class="cicone"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>');
    S.Append('<input id="inp_user" class="cinput" type="text" placeholder="seu.usuario" autocomplete="username" ');
    S.Append('onfocus="setFocus(' + Q + 'cf_user' + Q + ',true)" onblur="setFocus(' + Q + 'cf_user' + Q + ',false)"/>');
    S.Append('</div></div>');

    { campo senha }
    S.Append('<div class="campo" id="cf_pwd">');
    S.Append('<div class="clabel">');
    S.Append('<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>');
    S.Append('Senha</div>');
    S.Append('<div class="cbox">');
    S.Append('<div class="cicone"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>');
    S.Append('<input id="inp_pwd" class="cinput" type="password" placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;" autocomplete="current-password" ');
    S.Append('onfocus="setFocus(' + Q + 'cf_pwd' + Q + ',true)" onblur="setFocus(' + Q + 'cf_pwd' + Q + ',false)"/>');
    S.Append('<button class="bolho" type="button" onclick="togglePwd()">');
    S.Append('<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>');
    S.Append('</button></div></div>');

    S.Append('<div id="errmsg" class="errmsg"></div>');
    S.Append('<div class="div"></div>');
    S.Append('<div class="togrow">');
    S.Append('<label class="tog"><input type="checkbox" id="ck_rem"><div class="ttrack"></div><span class="tlabel">Lembrar-me</span></label>');
    S.Append('<button class="lbtn" type="button">Esqueceu a senha?</button>');
    S.Append('</div>');
    S.Append('<button id="btnLogin" type="button" onclick="doLogin()">Entrar</button>');
    S.Append('<div class="footer"><span>Grupo DT&amp;LL - 2026</span><span class="sep">&bull;</span><span>Vers&atilde;o: 1.0</span></div>');
    S.Append('</div></div>');

    { JS }
    S.Append('<script>');
    S.Append('var _f=' + FJSFrame + ';');
    S.Append('function togglePwd(){');
    S.Append('var i=document.getElementById(' + Q + 'inp_pwd' + Q + ');');
    S.Append('i.type=i.type==="password"?"text":"password";}');
    S.Append('function setFocus(id,on){');
    S.Append('var el=document.getElementById(id);');
    S.Append('if(!el)return;');
    S.Append('on?el.classList.add(' + Q + 'foc' + Q + '):el.classList.remove(' + Q + 'foc' + Q + ');}');
    S.Append('function setErr(id,on){');
    S.Append('var el=document.getElementById(id);if(!el)return;');
    S.Append('on?el.classList.add(' + Q + 'err' + Q + '):el.classList.remove(' + Q + 'err' + Q + ');}');
    S.Append('function showErrMsg(msg){');
    S.Append('var e=document.getElementById(' + Q + 'errmsg' + Q + ');');
    S.Append('e.textContent=msg;e.style.display=msg?' + Q + 'block' + Q + ':' + Q + 'none' + Q + ';');
    S.Append('setErr(' + Q + 'cf_user' + Q + ',!!msg);setErr(' + Q + 'cf_pwd' + Q + ',!!msg);}');
    S.Append('function doLogin(){');
    S.Append('var u=document.getElementById(' + Q + 'inp_user' + Q + ').value;');
    S.Append('var p=document.getElementById(' + Q + 'inp_pwd' + Q + ').value;');
    S.Append('document.getElementById(' + Q + 'btnLogin' + Q + ').classList.add(' + Q + 'loading' + Q + ');');
    S.Append('showErrMsg(' + Q + Q + ');');
    S.Append('parent.ajaxRequest(_f,' + Q + 'DoLogin' + Q + ',');
    S.Append('[' + Q + 'user=' + Q + '+encodeURIComponent(u),' + Q + 'pwd=' + Q + '+encodeURIComponent(p)]);}');
    S.Append('document.getElementById(' + Q + 'inp_user' + Q + ').addEventListener(' + Q + 'keydown' + Q + ',');
    S.Append('function(e){if(e.key===' + Q + 'Enter' + Q + '){e.preventDefault();document.getElementById(' + Q + 'inp_pwd' + Q + ').focus();}});');
    S.Append('document.getElementById(' + Q + 'inp_pwd' + Q + ').addEventListener(' + Q + 'keydown' + Q + ',');
    S.Append('function(e){if(e.key===' + Q + 'Enter' + Q + '){e.preventDefault();doLogin();}});');
    S.Append('</script></body></html>');

    Result := S.ToString;
  finally
    S.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  HTML do APP PRINCIPAL (sidebar + abas + conteudo)
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.RenderSidebar(const AItems: TArray<TMenuItemRec>): string;
const
  SVG_CHEVRON_R = 'M9 18l6-6-6-6';
  SVG_STAR      = 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z';

  function SvgIcon(const APath: string; ASize: Integer = 16): string;
  begin
    Result := '<svg width="' + IntToStr(ASize) + '" height="' + IntToStr(ASize) + '" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" ' +
      'stroke-linecap="round" stroke-linejoin="round"><path d="' + APath + '"/></svg>';
  end;

var
  B        : TStringBuilder;
  Item     : TMenuItemRec;
  ParentIDs: TStringList;  { IDs que possuem filhos → são grupos drill-down }
  IsGroup  : Boolean;
  HideStyle: string;
begin
  { 1ª passagem: descobre quais IDs têm filhos }
  ParentIDs := TStringList.Create;
  try
    for Item in AItems do
      if (Item.ParentID <> '') and (ParentIDs.IndexOf(Item.ParentID) < 0) then
        ParentIDs.Add(Item.ParentID);

    B := TStringBuilder.Create;
    try
      for Item in AItems do
      begin
        IsGroup   := ParentIDs.IndexOf(Item.ID) >= 0;
        HideStyle := IfThen(Item.ParentID = '', '', 'display:none');

        if IsGroup then
        begin
          { Grupo → usa data-lbl para evitar aspas no onclick }
          B.AppendFormat(
            '<div class="sb-item sb-grp" data-id="%s" data-parent="%s" data-lbl="%s" style="%s"' +
            ' onclick="drillInto(this.dataset.id,this.dataset.lbl)">',
            [Item.ID, Item.ParentID, Item.Caption, HideStyle]);
          B.AppendFormat('<span class="item-ico">%s</span>', [SvgIcon(Item.Icon)]);
          B.AppendFormat('<span class="item-lbl">%s</span>', [Item.Caption]);
          if not Item.Enabled then
            B.Append('<span class="soon">Em breve</span>')
          else
            B.AppendFormat('<span class="sb-arr">%s</span>', [SvgIcon(SVG_CHEVRON_R, 14)]);
          B.Append('</div>');
        end
        else
        begin
          { Folha → navega }
          B.AppendFormat(
            '<div class="sb-item nav-item%s" data-id="%s" data-parent="%s"' +
            ' data-route="%s" data-cap="%s" data-bread="%s" style="%s"' +
            ' onclick="navTo(this.dataset.route,this.dataset.cap,this.dataset.bread)">',
            [IfThen(not Item.Enabled, ' disabled', ''),
             Item.ID, Item.ParentID,
             Item.Route, Item.Caption, Item.BreadPath, HideStyle]);
          B.AppendFormat('<span class="item-ico">%s</span>', [SvgIcon(Item.Icon)]);
          B.AppendFormat('<span class="item-lbl">%s</span>', [Item.Caption]);
          B.AppendFormat(
            '<span class="item-fav"' +
            ' onclick="event.stopPropagation();favToggle(this,this.parentElement.dataset.route)">%s</span>',
            [SvgIcon(SVG_STAR, 12)]);
          B.Append('</div>');
        end;
      end;

      Result := B.ToString;
    finally
      B.Free;
    end;
  finally
    ParentIDs.Free;
  end;
end;

function TFrmLogin.BuildMainHtml: string;
const
  SVG_SEARCH = 'M21 21l-4.35-4.35M17 11A6 6 0 115 11a6 6 0 0112 0z';
  SVG_MENU   = 'M4 6h16M4 12h16M4 18h16';

  function SvgIcon(const APath: string; ASize: Integer = 18): string;
  begin
    Result := '<svg width="' + IntToStr(ASize) + '" height="' + IntToStr(ASize) + '" ' +
      'viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" ' +
      'stroke-linecap="round" stroke-linejoin="round"><path d="' + APath + '"/></svg>';
  end;

var
  H        : TStringBuilder;
  LItems   : TArray<TMenuItemRec>;
  LLogoURL : string;
  CSS, JS  : string;
begin
  LLogoURL := UniServerModule.FilesFolderURL + 'logo_transportadora.png?v=' +
              FormatDateTime('yyyymmddhhnnss', Now);
  LItems := FMainCtrl.GetMenuItems;

  CSS :=
    '*{margin:0;padding:0;box-sizing:border-box!important;}' +
    'html,body{width:100%!important;height:100%!important;overflow:hidden!important;' +
    '  font-family:"Segoe UI",system-ui,sans-serif!important;' +
    '  background:#060410!important;color:#E2E8F0!important;}' +

    ':root{' +
    '  --am:#F59E0B;--am2:#FCD34D;--am3:#D97706;' +
    '  --or:#E8520A;--or2:#FF6B35;' +
    '  --bg:#060410;--bg2:#0C0818;--bg3:#130F22;--bg4:#1C1730;' +
    '  --bdr:rgba(255,255,255,.05);--bdr2:rgba(245,158,11,.2);' +
    '  --glow:rgba(245,158,11,.4);--glow2:rgba(232,82,10,.35);' +
    '  --mt:#4E5A6B;--sw:268px;}' +

    { fundo com orb de luz animado }
    'body::before{content:"";position:fixed;width:600px;height:600px;border-radius:50%;' +
    '  background:radial-gradient(circle,rgba(245,158,11,.07) 0%,transparent 70%);' +
    '  top:-200px;left:-100px;pointer-events:none;z-index:0;' +
    '  animation:orbFloat 12s ease-in-out infinite;}' +
    'body::after{content:"";position:fixed;width:500px;height:500px;border-radius:50%;' +
    '  background:radial-gradient(circle,rgba(232,82,10,.05) 0%,transparent 70%);' +
    '  bottom:-150px;right:-100px;pointer-events:none;z-index:0;' +
    '  animation:orbFloat 16s ease-in-out infinite reverse;}' +
    '@keyframes orbFloat{0%,100%{transform:translate(0,0);}50%{transform:translate(40px,30px);}}' +

    { ══ TOPBAR ══ }
    '#topbar{position:fixed;top:0;left:0;right:0;height:60px;z-index:200;' +
    '  background:rgba(6,4,16,.92)!important;backdrop-filter:blur(32px) saturate(180%);' +
    '  -webkit-backdrop-filter:blur(32px) saturate(180%);' +
    '  border-bottom:1px solid rgba(245,158,11,.15);' +
    '  box-shadow:0 1px 0 rgba(245,158,11,.08),0 4px 24px rgba(0,0,0,.5);' +
    '  display:flex!important;align-items:center;padding:0;gap:0;}' +

    { Brand }
    '.tb-brand{display:flex;align-items:center;gap:10px;width:var(--sw);flex-shrink:0;' +
    '  padding:0 16px;height:100%;' +
    '  border-right:1px solid rgba(245,158,11,.1);' +
    '  background:linear-gradient(90deg,rgba(245,158,11,.04) 0%,transparent 100%);}' +
    '.tb-menu-btn{background:none;border:none;cursor:pointer;' +
    '  color:#64748B;display:flex;align-items:center;padding:7px;' +
    '  border-radius:10px;transition:all .2s;flex-shrink:0;}' +
    '.tb-menu-btn:hover{color:var(--am);' +
    '  background:rgba(245,158,11,.1);' +
    '  box-shadow:0 0 12px rgba(245,158,11,.2);}' +
    '.tb-logo{height:32px;flex-shrink:0;' +
    '  filter:drop-shadow(0 0 12px rgba(245,158,11,.6)) drop-shadow(0 0 24px rgba(232,82,10,.3));}' +
    '.tb-brand-txt{display:flex;flex-direction:column;gap:0;min-width:0;}' +
    '.tb-nm{font-size:14px;font-weight:800;letter-spacing:-.3px;white-space:nowrap;' +
    '  background:linear-gradient(90deg,#FCD34D,#F59E0B,#FF6B35);' +
    '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;' +
    '  filter:drop-shadow(0 0 8px rgba(252,211,77,.4));}' +
    '.tb-sub{font-size:9px;color:var(--mt);letter-spacing:1.5px;text-transform:uppercase;white-space:nowrap;}' +

    { Search }
    '.tb-srch{flex:1;max-width:420px;position:relative;margin-left:24px;}' +
    '.tb-srch input{width:100%;' +
    '  background:rgba(255,255,255,.03)!important;' +
    '  border:1px solid rgba(255,255,255,.07)!important;border-radius:14px!important;' +
    '  padding:9px 16px 9px 40px!important;color:#CBD5E1!important;' +
    '  font-size:13px!important;outline:none!important;transition:all .25s;' +
    '  box-shadow:inset 0 1px 0 rgba(255,255,255,.04);}' +
    '.tb-srch input:focus{border-color:rgba(245,158,11,.4)!important;' +
    '  background:rgba(245,158,11,.03)!important;' +
    '  box-shadow:0 0 0 3px rgba(245,158,11,.08),inset 0 1px 0 rgba(255,255,255,.04)!important;}' +
    '.tb-srch input::placeholder{color:#2E3A4A!important;}' +
    '.srch-ico{position:absolute;left:13px;top:50%;transform:translateY(-50%);color:#2E3A4A;pointer-events:none;}' +
    '#sdrop{position:absolute;top:calc(100% + 8px);left:0;right:0;' +
    '  background:rgba(12,8,24,.98);border:1px solid var(--bdr2);border-radius:16px;' +
    '  box-shadow:0 32px 80px rgba(0,0,0,.8),0 0 0 1px rgba(245,158,11,.06);' +
    '  display:none;z-index:300;max-height:280px;overflow-y:auto;' +
    '  backdrop-filter:blur(20px);}' +
    '.sd-it{padding:11px 16px;cursor:pointer;display:flex;align-items:center;gap:10px;' +
    '  font-size:13px;transition:all .15s;color:#94A3B8;border-radius:8px;margin:3px;}' +
    '.sd-it:hover{background:rgba(245,158,11,.08);color:#E2E8F0;}' +
    '.sd-badge{margin-left:auto;font-size:10px;color:var(--mt);' +
    '  background:rgba(255,255,255,.05);padding:2px 8px;border-radius:6px;letter-spacing:.3px;}' +

    { Right }
    '.tb-right{margin-left:auto;display:flex;align-items:center;gap:10px;padding:0 20px 0 16px;}' +
    '.tb-user{display:flex;align-items:center;gap:10px;' +
    '  background:rgba(245,158,11,.06);' +
    '  border:1px solid rgba(245,158,11,.15);border-radius:28px;padding:4px 14px 4px 4px;' +
    '  cursor:pointer;transition:all .25s;' +
    '  box-shadow:0 0 0 0 rgba(245,158,11,.0);}' +
    '.tb-user:hover{background:rgba(245,158,11,.1);border-color:rgba(245,158,11,.3);' +
    '  box-shadow:0 0 20px rgba(245,158,11,.12);}' +
    '.tb-av{width:32px;height:32px;border-radius:50%;flex-shrink:0;' +
    '  background:linear-gradient(135deg,#FCD34D 0%,#F59E0B 50%,#D97706 100%);' +
    '  display:flex;align-items:center;justify-content:center;' +
    '  font-size:12px;font-weight:800;color:#000;' +
    '  box-shadow:0 0 16px rgba(245,158,11,.5),0 0 32px rgba(245,158,11,.2);}' +
    '.tb-uname{font-size:12px;font-weight:700;color:#CBD5E1;}' +
    '.tb-role{font-size:9.5px;color:var(--mt);letter-spacing:.5px;}' +

    '#app{position:fixed!important;top:60px;bottom:0;left:0;right:0;display:flex!important;}' +

    { ══ SIDEBAR ══ }
    '#sb{width:var(--sw);flex-shrink:0;overflow:hidden;' +
    '  display:flex!important;flex-direction:column;' +
    '  background:linear-gradient(180deg,rgba(12,8,24,.98) 0%,rgba(8,5,16,.98) 100%)!important;' +
    '  border-right:1px solid rgba(245,158,11,.08);' +
    '  box-shadow:4px 0 40px rgba(0,0,0,.6);' +
    '  transition:width .35s cubic-bezier(.4,0,.2,1);}' +
    '#sb.col{width:0;}' +
    '#sb.col .item-lbl,#sb.col .item-fav,#sb.col .sb-arr,#sb.col .soon,' +
    '#sb.col #fav-bar,#sb.col #drill-hdr{display:none!important;}' +

    { Drill header }
    '#drill-hdr{display:none;align-items:center;gap:8px;padding:12px 14px;' +
    '  border-bottom:1px solid rgba(245,158,11,.1);flex-shrink:0;' +
    '  background:linear-gradient(90deg,rgba(245,158,11,.07),transparent);}' +
    '#drill-back{background:rgba(245,158,11,.08);border:1px solid rgba(245,158,11,.2);' +
    '  cursor:pointer;color:var(--am);' +
    '  display:flex;align-items:center;gap:5px;font-size:12px;font-weight:700;' +
    '  padding:5px 11px;border-radius:10px;transition:all .2s;}' +
    '#drill-back:hover{background:rgba(245,158,11,.16);border-color:var(--am);' +
    '  box-shadow:0 0 12px rgba(245,158,11,.25);}' +
    '#drill-lbl{font-size:12px;font-weight:800;flex:1;' +
    '  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;' +
    '  background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
    '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +

    { Fav bar }
    '#fav-bar{padding:10px 14px;border-bottom:1px solid rgba(255,255,255,.04);flex-shrink:0;}' +
    '.fav-ttl{font-size:9px;font-weight:700;color:#2E3A4A;' +
    '  letter-spacing:1.5px;text-transform:uppercase;margin-bottom:8px;}' +
    '#fav-chips{display:flex;flex-wrap:wrap;gap:4px;min-height:4px;}' +
    '.fav-chip{background:rgba(245,158,11,.07);border:1px solid rgba(245,158,11,.15);' +
    '  border-radius:8px;padding:3px 10px;font-size:11px;cursor:pointer;' +
    '  transition:all .2s;color:var(--am2);' +
    '  box-shadow:0 0 0 0 rgba(245,158,11,.0);}' +
    '.fav-chip:hover{background:rgba(245,158,11,.15);border-color:var(--am);' +
    '  box-shadow:0 0 12px rgba(245,158,11,.2);}' +
    '.fav-emp{font-size:11px;color:#2E3A4A;font-style:italic;}' +

    { Scroll }
    '#sb-sc{flex:1;overflow-y:auto;overflow-x:hidden;padding:10px 8px;}' +
    '#sb-sc::-webkit-scrollbar{width:2px;}' +
    '#sb-sc::-webkit-scrollbar-thumb{' +
    '  background:linear-gradient(180deg,var(--am),var(--or));border-radius:2px;}' +

    { sb-item base }
    '.sb-item{display:flex;align-items:center;gap:11px;padding:9px 12px;' +
    '  border-radius:12px;cursor:pointer;font-size:12.5px;' +
    '  transition:all .2s cubic-bezier(.4,0,.2,1);color:#374151;' +
    '  user-select:none;border:1px solid transparent;position:relative;}' +
    '.sb-item:hover:not(.disabled){' +
    '  background:rgba(255,255,255,.04);color:#94A3B8;' +
    '  border-color:rgba(255,255,255,.06);}' +
    '.sb-item.active{' +
    '  background:linear-gradient(90deg,rgba(245,158,11,.12),rgba(245,158,11,.04))!important;' +
    '  color:var(--am2)!important;' +
    '  border-color:rgba(245,158,11,.2)!important;' +
    '  box-shadow:0 0 0 0 transparent;}' +
    '.sb-item.active::before{content:"";position:absolute;left:0;top:20%;bottom:20%;' +
    '  width:3px;border-radius:0 3px 3px 0;' +
    '  background:linear-gradient(180deg,var(--am2),var(--am));' +
    '  box-shadow:0 0 8px var(--am);}' +
    '.sb-item.disabled{opacity:.18;cursor:not-allowed;pointer-events:none;}' +
    '.sb-item.sb-grp{color:#2E3A4A;font-weight:700;font-size:11.5px;' +
    '  letter-spacing:.4px;text-transform:uppercase;}' +
    '.sb-item.sb-grp:hover:not(.disabled){' +
    '  background:rgba(245,158,11,.06);color:var(--am);' +
    '  border-color:rgba(245,158,11,.12);}' +
    '.sb-arr{margin-left:auto;color:#2E3A4A;display:flex;align-items:center;flex-shrink:0;' +
    '  transition:all .2s;}' +
    '.sb-item:hover .sb-arr{color:var(--am);transform:translateX(3px);}' +
    '.soon{font-size:9px;background:rgba(100,116,139,.08);color:#2E3A4A;' +
    '  padding:2px 7px;border-radius:5px;margin-left:auto;letter-spacing:.5px;}' +
    '.item-ico{flex-shrink:0;display:flex;align-items:center;color:inherit;}' +
    '.item-lbl{flex:1;}' +
    '.item-fav{opacity:0;transition:all .2s;color:var(--am);' +
    '  display:flex;align-items:center;padding:2px;flex-shrink:0;}' +
    '.sb-item:hover .item-fav{opacity:.5;}' +
    '.item-fav.on{opacity:1!important;filter:drop-shadow(0 0 5px var(--am));}' +
    '@keyframes grpIn{from{opacity:0;transform:translateX(-12px)}to{opacity:1;transform:translateX(0)}}' +

    { ══ CONTENT ══ }
    '#content{flex:1;display:flex;flex-direction:column;overflow:hidden;' +
    '  background:var(--bg)!important;}' +

    { ══ TABS FLUTUANTES ══ }
    '#tabs-bar{' +
    '  background:transparent!important;' +
    '  border-bottom:none;' +
    '  display:flex;align-items:center;padding:10px 16px 0;min-height:58px;' +
    '  overflow-x:auto;flex-shrink:0;gap:6px;' +
    '  position:relative;}' +
    { linha sutil embaixo do tabs-bar }
    '#tabs-bar::after{content:"";position:absolute;bottom:0;left:0;right:0;height:1px;' +
    '  background:linear-gradient(90deg,transparent,rgba(245,158,11,.12),transparent);}' +
    '#tabs-bar::-webkit-scrollbar{height:0;}' +

    { Tab base — flutuante, arredondada, glassmorphism }
    '.tab-btn{' +
    '  display:flex;align-items:center;gap:8px;' +
    '  padding:0 14px 0 16px;height:36px;' +
    '  border-radius:20px;cursor:pointer;font-size:12px;white-space:nowrap;' +
    '  border:1px solid rgba(255,255,255,.05);' +
    '  background:rgba(255,255,255,.03);' +
    '  backdrop-filter:blur(12px);' +
    '  color:#2E3A4A;' +
    '  transition:all .25s cubic-bezier(.4,0,.2,1);' +
    '  position:relative;' +
    '  box-shadow:0 2px 8px rgba(0,0,0,.3);' +
    '  animation:tabIn .25s cubic-bezier(.22,1,.36,1);}' +
    '@keyframes tabIn{from{opacity:0;transform:translateY(-8px) scale(.95)}to{opacity:1;transform:translateY(0) scale(1)}}' +

    { Tab hover }
    '.tab-btn:hover{' +
    '  background:rgba(255,255,255,.06);' +
    '  border-color:rgba(255,255,255,.1);' +
    '  color:#64748B;' +
    '  transform:translateY(-1px);' +
    '  box-shadow:0 4px 16px rgba(0,0,0,.4);}' +

    { Tab ativa — glow âmbar vibrante }
    '.tab-btn.active{' +
    '  background:linear-gradient(135deg,rgba(245,158,11,.18),rgba(232,82,10,.10))!important;' +
    '  border-color:rgba(245,158,11,.35)!important;' +
    '  color:var(--am2)!important;' +
    '  transform:translateY(-2px);' +
    '  box-shadow:' +
    '    0 6px 24px rgba(245,158,11,.2),' +
    '    0 0 0 1px rgba(245,158,11,.1) inset,' +
    '    0 1px 0 rgba(252,211,77,.3) inset;}' +

    { ponto brilhante no topo da tab ativa }
    '.tab-btn.active::before{content:"";position:absolute;' +
    '  top:0;left:20%;right:20%;height:1px;border-radius:50%;' +
    '  background:linear-gradient(90deg,transparent,rgba(252,211,77,.8),transparent);}' +

    { ícone colorido da tab ativa }
    '.tab-ico{width:8px;height:8px;border-radius:50%;flex-shrink:0;' +
    '  background:rgba(255,255,255,.15);transition:all .25s;}' +
    '.tab-btn.active .tab-ico{' +
    '  background:var(--am);' +
    '  box-shadow:0 0 8px var(--am),0 0 16px rgba(245,158,11,.4);}' +

    { botão fechar }
    '.tab-x{background:none;border:none;cursor:pointer;color:inherit;' +
    '  opacity:0;padding:2px 4px;border-radius:50%;' +
    '  font-size:13px;line-height:1;transition:all .15s;' +
    '  display:flex;align-items:center;justify-content:center;' +
    '  width:18px;height:18px;flex-shrink:0;}' +
    '.tab-btn:hover .tab-x,.tab-btn.active .tab-x{opacity:.5;}' +
    '.tab-x:hover{opacity:1!important;' +
    '  background:rgba(239,68,68,.2);' +
    '  color:#F87171!important;' +
    '  box-shadow:0 0 8px rgba(239,68,68,.3);}' +

    '#no-tab{font-size:12px;color:#1E2530;font-style:italic;' +
    '  padding:0 8px;align-self:center;letter-spacing:.3px;}' +

    { Breadcrumb }
    '#breadcrumb{padding:8px 22px;display:flex;align-items:center;gap:6px;font-size:12px;' +
    '  color:var(--mt);flex-shrink:0;min-height:36px;' +
    '  border-bottom:1px solid rgba(255,255,255,.04);' +
    '  background:rgba(12,8,24,.6)!important;}' +
    '.bc-sep{color:rgba(255,255,255,.08);font-size:8px;margin:0 2px;}' +
    '.bc-last{color:var(--am);font-weight:700;' +
    '  text-shadow:0 0 12px rgba(245,158,11,.4);}' +
    '.bc-link{color:#2E3A4A;cursor:pointer;transition:all .18s;' +
    '  border-radius:5px;padding:1px 6px;}' +
    '.bc-link:hover{color:#94A3B8;background:rgba(255,255,255,.05);}' +

    { Screen }
    '#screen{flex:1;overflow:auto;padding:28px;background:var(--bg)!important;}' +
    '#screen::-webkit-scrollbar{width:4px;}' +
    '#screen::-webkit-scrollbar-thumb{' +
    '  background:linear-gradient(180deg,rgba(245,158,11,.3),rgba(232,82,10,.2));' +
    '  border-radius:4px;}' +
    '.sc-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;' +
    '  height:100%;gap:16px;opacity:.15;}' +
    '.sc-empty svg{width:52px;height:52px;}' +
    '.sc-empty p{font-size:14px;color:var(--mt);}' +
    '.sc-card{' +
    '  background:linear-gradient(135deg,rgba(19,15,34,.9) 0%,rgba(28,23,48,.9) 100%)!important;' +
    '  border:1px solid rgba(245,158,11,.15);border-radius:20px;padding:36px;' +
    '  box-shadow:0 8px 40px rgba(0,0,0,.5),0 0 0 1px rgba(245,158,11,.04) inset;' +
    '  animation:fuSlide .3s cubic-bezier(.22,1,.36,1);}' +
    '.sc-card h2{font-size:22px;font-weight:800;margin-bottom:10px;' +
    '  background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
    '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
    '.sc-card p{color:#374151;font-size:13px;line-height:1.8;}' +
    '.rtag{display:inline-block;margin-top:18px;' +
    '  background:rgba(245,158,11,.07);border:1px solid rgba(245,158,11,.2);' +
    '  border-radius:8px;padding:5px 14px;font-size:11px;color:var(--am);letter-spacing:.5px;}' +
    '@keyframes fuSlide{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)}}' +
    '::-webkit-scrollbar{width:4px;height:4px;}' +
    '::-webkit-scrollbar-track{background:transparent;}' +
    '::-webkit-scrollbar-thumb{background:rgba(245,158,11,.15);border-radius:4px;}';

  JS :=
    'var _f=' + FJSFrame + ';var OT={},SB=false,_favs=[];' +
    'var _navStack=[];' +
    'function toggleSB(){SB=!SB;document.getElementById("sb").classList.toggle("col",SB);}' +
    { Drill-down: salva IDs visíveis, mostra só filhos do grupo clicado }
    'function drillInto(id,label){' +
    '  var cur=[];' +
    '  document.querySelectorAll(".sb-item").forEach(function(el){' +
    '    if(el.style.display!=="none")cur.push(el.dataset.id);' +
    '  });' +
    '  _navStack.push({ids:cur});' +
    '  document.querySelectorAll(".sb-item").forEach(function(el){' +
    '    el.style.display=el.dataset.parent===id?"":"none";' +
    '  });' +
    '  document.getElementById("drill-lbl").textContent=label;' +
    '  document.getElementById("drill-hdr").style.display="flex";' +
    '}' +
    'function drillBack(){' +
    '  if(!_navStack.length)return;' +
    '  var prev=_navStack.pop();' +
    '  document.querySelectorAll(".sb-item").forEach(function(el){' +
    '    el.style.display=prev.ids.indexOf(el.dataset.id)>=0?"":"none";' +
    '  });' +
    '  if(_navStack.length===0)document.getElementById("drill-hdr").style.display="none";' +
    '}' +
    'function navTo(r,c,b){if(!r)return;openTab(r,c,b,JSON.parse(JSON.stringify(_navStack)));parent.ajaxRequest(_f,"nav",["route="+r]);}' +
    'function openTab(route,cap,bread,stack){' +
    '  if(OT[route]){setActive(route);return;}' +
    '  OT[route]={cap:cap,bread:bread,stack:stack||[]};' +
    '  var bar=document.getElementById("tabs-bar");' +
    '  var nt=document.getElementById("no-tab");if(nt)nt.remove();' +
    '  var t=document.createElement("div");t.className="tab-btn";t.dataset.route=route;' +
    '  var dot=document.createElement("span");dot.className="tab-ico";' +
    '  var l=document.createElement("span");l.textContent=cap;' +
    '  var x=document.createElement("button");x.className="tab-x";x.innerHTML="&times;";' +
    '  (function(ro){t.addEventListener("click",function(){setActive(ro);});' +
    '   x.addEventListener("click",function(e){e.stopPropagation();closeTab(ro);});' +
    '  })(route);' +
    '  t.appendChild(dot);t.appendChild(l);t.appendChild(x);bar.appendChild(t);setActive(route);' +
    '}' +
    'function setActive(route){' +
    '  document.querySelectorAll(".tab-btn").forEach(function(t){t.classList.toggle("active",t.dataset.route===route);});' +
    '  document.querySelectorAll(".nav-item").forEach(function(m){m.classList.toggle("active",m.dataset.route===route);});' +
    '  var d=OT[route]||{};renderBC(d.bread||"");renderScr(route,d.cap||"");' +
    '}' +
    'function closeTab(route){' +
    '  var t=document.querySelector(".tab-btn[data-route="+JSON.stringify(route)+"]");' +
    '  if(!t)return;var wa=t.classList.contains("active");t.remove();delete OT[route];' +
    '  parent.ajaxRequest(_f,"closeTab",["route="+route]);' +
    '  var rem=document.querySelectorAll(".tab-btn");' +
    '  if(wa&&rem.length)setActive(rem[rem.length-1].dataset.route);' +
    '  else if(!rem.length){var s=document.createElement("span");s.id="no-tab";' +
    '    s.textContent="Nenhuma tela aberta";document.getElementById("tabs-bar").appendChild(s);' +
    '    renderBC("");renderScr("","");}' +
    '  document.querySelectorAll(".nav-item").forEach(function(m){m.classList.remove("active");});' +
    '}' +
    { _bcp = partes do breadcrumb atual; bcClick(i) evita escape de aspas no onclick }
    'var _bcp=[];' +
    'function renderBC(bread){' +
    '  var el=document.getElementById("breadcrumb");if(!bread){el.innerHTML="";_bcp=[];return;}' +
    '  _bcp=bread.split(" > ");' +
    '  el.innerHTML=_bcp.map(function(s,i,a){' +
    '    if(i===a.length-1)return"<span class=bc-last>"+s+"</span>";' +
    '    return"<span class=bc-link onclick=' + #39 + 'bcClick("+i+")' + #39 + '>"+s+"</span><span class=bc-sep>&#10095;</span>";' +
    '  }).join("");}' +
    'function bcClick(i){' +
    '  var path=_bcp.slice(0,i+1).join(" > ");' +
    '  var found="";' +
    '  Object.keys(OT).forEach(function(r){if((OT[r].bread||"")===path)found=r;});' +
    '  if(found){setActive(found);restoreDrill(OT[found].stack,i);return;}' +
    { Nao tem aba aberta para esse nivel — apenas restaura o drill do sidebar }
    '  var cur=document.querySelectorAll(".sb-item");' +
    '  var activeStack=OT[Object.keys(OT).filter(function(r){return(OT[r].bread||"").indexOf(path)===0;})[0]];' +
    '  if(activeStack)restoreDrill(activeStack.stack,i);' +
    '}' +
    'function restoreDrill(stack,targetDepth){' +
    { Restaura todos os itens visiveis }
    '  document.querySelectorAll(".sb-item").forEach(function(el){' +
    '    el.style.display=el.dataset.parent===""?"":"none";' +
    '  });' +
    '  _navStack=[];' +
    '  document.getElementById("drill-hdr").style.display="none";' +
    { Re-executa o drill ate o nivel desejado (i = indice do segmento clicado) }
    '  if(stack&&stack.length>0&&targetDepth>0){' +
    '    var steps=Math.min(targetDepth,stack.length);' +
    '    for(var k=0;k<steps;k++){' +
    '      var ids=stack[k].ids;' +
    '      var cur=[];' +
    '      document.querySelectorAll(".sb-item").forEach(function(el){' +
    '        if(el.style.display!=="none")cur.push(el.dataset.id);' +
    '      });' +
    '      _navStack.push({ids:cur});' +
    '      var parentId=null;' +
    '      if(k+1<stack.length){' +
    '        var nextIds=stack[k+1].ids;' +
    '        document.querySelectorAll(".sb-item").forEach(function(el){' +
    '          if(nextIds.indexOf(el.dataset.id)>=0&&parentId===null)parentId=el.dataset.parent;' +
    '        });' +
    '      }' +
    '      if(parentId){' +
    '        document.querySelectorAll(".sb-item").forEach(function(el){' +
    '          el.style.display=el.dataset.parent===parentId?"":"none";' +
    '        });' +
    '      }' +
    '    }' +
    '    if(_navStack.length>0)document.getElementById("drill-hdr").style.display="flex";' +
    '  }' +
    '}' +
    'function renderScr(route,cap){' +
    '  var el=document.getElementById("screen");' +
    '  if(!route){el.innerHTML="<div class=sc-empty><p>Selecione uma tela no menu lateral</p></div>";return;}' +
    '  el.innerHTML="<div class=sc-card><h2>"+cap+"</h2><p>Tela em desenvolvimento.</p>' +
    '    <span class=rtag>"+route+"</span></div>";}' +
    'function favToggle(el,route){' +
    '  el.classList.toggle("on");' +
    '  var i=_favs.indexOf(route);' +
    '  if(i>=0)_favs.splice(i,1);else _favs.push(route);' +
    '  updateFavs(JSON.stringify(_favs));' +
    '  parent.ajaxRequest(_f,"toggleFav",["route="+route]);' +
    '}' +
    'function updateFavs(json){' +
    '  var favs=JSON.parse(json);var chips=document.getElementById("fav-chips");' +
    '  var emp=document.getElementById("fav-emp");chips.innerHTML="";' +
    '  if(!favs.length){if(emp)emp.style.display="";return;}' +
    '  if(emp)emp.style.display="none";' +
    '  favs.forEach(function(r){' +
    '    var m=document.querySelector(".nav-item[data-route="+JSON.stringify(r)+"]");' +
    '    var cap=m?m.dataset.cap:r;var bread=m?m.dataset.bread:"";' +
    '    var c=document.createElement("span");c.className="fav-chip";c.textContent=cap;' +
    '    (function(ro,ca,br){c.addEventListener("click",function(){navTo(ro,ca,br);});})(r,cap,bread);' +
    '    chips.appendChild(c);});}' +
    'function doSearch(val){' +
    '  var drop=document.getElementById("sdrop");' +
    '  if(!val.trim()){drop.style.display="none";return;}' +
    '  var all=Array.from(document.querySelectorAll(".nav-item:not(.disabled)"));' +
    '  var ok=all.filter(function(m){return m.dataset.cap.toLowerCase().indexOf(val.toLowerCase())>=0;});' +
    '  drop.innerHTML="";' +
    '  if(!ok.length){drop.innerHTML="<div class=sd-it style=color:var(--mt)>Nenhum resultado</div>";}' +
    '  else{ok.forEach(function(m){var d=document.createElement("div");d.className="sd-it";' +
    '    var l=document.createElement("span");l.textContent=m.dataset.cap;' +
    '    var b=document.createElement("span");b.className="sd-badge";b.textContent=m.dataset.route;' +
    '    d.appendChild(l);d.appendChild(b);' +
    '    (function(ro,ca,br){d.addEventListener("click",function(){' +
    '      navTo(ro,ca,br);drop.style.display="none";' +
    '      document.getElementById("srch-inp").value="";' +
    '    });})(m.dataset.route,m.dataset.cap,m.dataset.bread);drop.appendChild(d);});}' +
    '  drop.style.display="block";}' +
    'document.addEventListener("click",function(e){' +
    '  if(!e.target.closest(".tb-srch"))document.getElementById("sdrop").style.display="none";});' +
    'window.addEventListener("load",function(){renderScr("","");});';

  H := TStringBuilder.Create;
  try
    H.Append('<!DOCTYPE html><html lang="pt-BR">');
    H.Append('<head><meta charset="UTF-8">');
    H.Append('<meta name="viewport" content="width=device-width,initial-scale=1">');
    H.Append('<style>' + CSS + '</style></head><body>');

    H.Append('<div id="topbar">');
    { Brand: botão menu + logo + nome — lado esquerdo, mesma largura do sidebar }
    H.Append('<div class="tb-brand">');
    H.AppendFormat('<button class="tb-menu-btn" onclick="toggleSB()" title="Menu">%s</button>',
      [SvgIcon(SVG_MENU, 20)]);
    H.AppendFormat('<img class="tb-logo" src="%s" alt="logo">', [LLogoURL]);
    H.Append('<div class="tb-brand-txt">');
    H.Append('<div class="tb-nm">Grupo DT&amp;LL</div>');
    H.Append('<div class="tb-sub">Transportadoras</div>');
    H.Append('</div></div>');
    { Search }
    H.Append('<div class="tb-srch">');
    H.Append('<span class="srch-ico">' + SvgIcon(SVG_SEARCH, 15) + '</span>');
    H.Append('<input id="srch-inp" type="text" placeholder="Buscar telas..." oninput="doSearch(this.value)">');
    H.Append('<div id="sdrop"></div></div>');
    { Right: notificação + usuário }
    H.Append('<div class="tb-right">');
    H.Append('<div class="tb-user">');
    H.Append('<div class="tb-av">AD</div>');
    H.Append('<div><div class="tb-uname">Administrador</div>');
    H.Append('<div class="tb-role">Admin</div></div>');
    H.Append('</div></div></div>');

    H.Append('<div id="app">');
    H.Append('<div id="sb">');
    { Cabeçalho de drill-down — aparece quando dentro de um grupo }
    H.Append('<div id="drill-hdr">');
    H.AppendFormat('<button id="drill-back" onclick="drillBack()">%s Voltar</button>', [
      '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M15 18l-6-6 6-6"/></svg>'
    ]);
    H.Append('<span id="drill-lbl"></span>');
    H.Append('</div>');
    H.Append('<div id="fav-bar">');
    H.Append('<div class="fav-ttl">&#9733; Favoritos</div>');
    H.Append('<div id="fav-chips"></div>');
    H.Append('<span id="fav-emp" class="fav-emp">Clique na &#9733; para favoritar</span>');
    H.Append('</div>');
    H.Append('<div id="sb-sc">');
    H.Append(RenderSidebar(LItems));
    H.Append('</div></div>');

    H.Append('<div id="content">');
    H.Append('<div id="tabs-bar"><span id="no-tab">Nenhuma tela aberta</span></div>');
    H.Append('<div id="breadcrumb"></div>');
    H.Append('<div id="screen"></div>');
    H.Append('</div></div>');

    H.AppendFormat('<script>%s</script>', [JS]);
    H.Append('</body></html>');

    Result := H.ToString;
  finally
    H.Free;
  end;
end;

initialization
  RegisterAppFormClass(TFrmLogin);

end.
