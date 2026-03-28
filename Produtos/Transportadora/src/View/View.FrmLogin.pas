unit View.FrmLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  uniGUITypes, uniGUIAbstractClasses, uniGUIClasses,
  uniGUIRegClasses, uniGUIForm,
  uniHTMLFrame, uniGUIBaseClasses,
  View.ILoginView,
  Controller.ILoginController,
  Model.ILogin;

type
  TFrmLogin = class(TUniForm, ILoginView)
    HtmlLogin: TUniHTMLFrame;
    procedure UniFormCreate(Sender: TObject);
    procedure HtmlLoginAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    FController : ILoginController;
    FUser       : string;
    FPwd        : string;
    function  BuildHtml: string;
    procedure InitController;
  public
    { ILoginView }
    function  CollectCredentials: TLoginCredentials;
    procedure NotifySuccess(const AMessage: string);
    procedure NotifyFailure(const AMessage: string);
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

uses
  Model.TLogin,
  Controller.TLoginController,
  uniGUIApplication,
  uniGUIVars,
  ServerModule,
  uniGUIServer;

{ TFrmLogin }

procedure TFrmLogin.UniFormCreate(Sender: TObject);
begin
  HtmlLogin.HTML.Text := BuildHtml;
  InitController;
end;

procedure TFrmLogin.InitController;
begin
  FController := NewLoginController(NewLogin);
  FController.BindView(Self);
end;

procedure TFrmLogin.HtmlLoginAjaxEvent(Sender: TComponent; EventName: string;
  Params: TUniStrings);
begin
  FUser := Params.Values['user'];
  FPwd  := Params.Values['pwd'];
  try
    FController.ExecuteLogin;
  except
    on E: EAssertionFailed do
      NotifyFailure(E.Message);
  end;
end;

{ ILoginView }

function TFrmLogin.CollectCredentials: TLoginCredentials;
begin
  Result := TLoginCredentials.New(FUser, FPwd);
end;

procedure TFrmLogin.NotifySuccess(const AMessage: string);
var
  LSafe: string;
begin
  LSafe := StringReplace(AMessage, '\', '\\', [rfReplaceAll]);
  LSafe := StringReplace(LSafe,    '"', '\"', [rfReplaceAll]);
  UniSession.AddJS(
    'document.getElementById("btnLogin").classList.remove("loading");' +
    'showSuccessMsg("' + LSafe + '");'
  );
  // TODO: abrir form principal apos animacao de sucesso
  // TFrmPrincipal.Create(Application).Show; Self.Hide;
end;

procedure TFrmLogin.NotifyFailure(const AMessage: string);
var
  LSafe: string;
begin
  LSafe := StringReplace(AMessage, '\', '\\', [rfReplaceAll]);
  LSafe := StringReplace(LSafe,    '"', '\"', [rfReplaceAll]);
  UniSession.AddJS(
    'document.getElementById("btnLogin").classList.remove("loading");' +
    'showErrMsg("' + LSafe + '");'
  );
end;

{ HTML Builder }


function TFrmLogin.BuildHtml: string;
const
  Q = '''';   { single-quote character }
var
  S        : TStringBuilder;
  LFilesURL: string;
  LBgURL   : string;
  LLogoURL : string;
begin
  LFilesURL := UniServerModule.FilesFolderURL;
  LBgURL    := LFilesURL + 'bg_login.jpg?v=' + FormatDateTime('yyyymmddhhnnss', Now);
  LLogoURL  := LFilesURL + 'logo_transportadora.png?v=' + FormatDateTime('yyyymmddhhnnss', Now);

  S := TStringBuilder.Create;
  try

    { ── DOCTYPE / HEAD ─────────────────────────────────────────────────── }
    S.Append('<!DOCTYPE html>');
    S.Append('<html lang="pt-BR">');
    S.Append('<head>');
    S.Append('<meta charset="UTF-8">');
    S.Append('<meta name="viewport" content="width=device-width,initial-scale=1.0">');
    S.Append('<link rel="preconnect" href="https://fonts.googleapis.com">');
    S.Append('<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">');
    S.Append('<style>');

    { reset }
    S.Append('*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}');
    S.Append('html,body{width:100%;height:100%;overflow:hidden;font-family:"Inter",system-ui,sans-serif;background:#030100}');

    { background — URL absoluta gerada em runtime com a porta real do UniGUI }
    S.Append('#bg{position:fixed;inset:0;z-index:0;');
    S.Append('background-image:url(' + Q + LBgURL + Q + ');');
    S.Append('background-size:cover;background-position:center center;background-repeat:no-repeat}');

    { overlay unico e leve — so para dar contraste ao card e texto, sem matar a foto }
    S.Append('#ov1{position:fixed;inset:0;z-index:2;pointer-events:none;background:rgba(10,4,0,0.42)}');
    S.Append('#ov2{position:fixed;bottom:0;left:0;right:0;height:45%;z-index:3;pointer-events:none;');
    S.Append('background:linear-gradient(to top,rgba(8,3,0,0.60) 0%,transparent 100%)}');
    S.Append('#ov3{position:fixed;top:0;left:0;right:0;height:30%;z-index:3;pointer-events:none;');
    S.Append('background:linear-gradient(to bottom,rgba(8,3,0,0.35) 0%,transparent 100%)}');
    S.Append('#ov4{display:none}');

    { ── layout: card unico centralizado ── }
    S.Append('#tela{position:fixed;inset:0;z-index:10;display:flex;align-items:center;');
    S.Append('justify-content:center;pointer-events:none}');

    { card unico que contem logo + formulario }
    S.Append('.card{pointer-events:all;width:440px;background:rgba(8,3,1,0.62);');
    S.Append('border-radius:28px;border:1px solid rgba(255,175,55,0.22);padding:32px 36px 28px;');
    S.Append('box-shadow:inset 0 1px 0 rgba(255,210,100,0.12),inset 0 -1px 0 rgba(255,90,10,0.06),');
    S.Append('0 0 0 1px rgba(0,0,0,0.32),0 32px 100px rgba(0,0,0,0.72),0 8px 30px rgba(0,0,0,0.55);');
    S.Append('backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);');
    S.Append('animation:cardIn .55s cubic-bezier(.22,1,.36,1) both}');
    S.Append('@keyframes cardIn{from{opacity:0;transform:translateY(28px)}to{opacity:1;transform:translateY(0)}}');

    { secao da logo dentro do card }
    S.Append('.logo-sec{display:flex;flex-direction:column;align-items:center;gap:4px;margin-bottom:22px}');

    { wrapper transparente — PNG ja tem transparencia }
    S.Append('.logo-wrap{display:inline-block}');
    S.Append('.logo-wrap img{width:180px;height:auto;display:block;');
    S.Append('filter:drop-shadow(0 4px 20px rgba(200,70,5,0.45)) drop-shadow(0 0 40px rgba(255,100,10,0.20))}');

    { divisor decorativo }
    S.Append('.logo-div{width:90%;height:1px;margin:14px auto 16px;');
    S.Append('background:linear-gradient(to right,transparent,rgba(255,185,55,0.35),transparent)}');

    { textos da logo }
    S.Append('.logo-nm{font-size:26px;font-weight:900;letter-spacing:-.4px;color:#FFE888;');
    S.Append('text-align:center;');
    S.Append('text-shadow:0 0 24px rgba(255,185,40,0.55),0 2px 10px rgba(0,0,0,0.98)}');
    S.Append('.logo-nm span{color:#E8520A}');
    S.Append('.logo-sl{font-size:10px;font-weight:600;color:rgba(255,200,90,0.50);');
    S.Append('text-align:center;letter-spacing:3.5px;text-transform:uppercase;margin-top:2px;');
    S.Append('text-shadow:0 1px 8px rgba(0,0,0,0.98)}');

    { badge online }
    S.Append('.badge{display:inline-flex;align-items:center;gap:6px;font-size:10px;font-weight:600;');
    S.Append('color:rgba(65,230,115,0.92);letter-spacing:.8px;text-transform:uppercase;margin-bottom:14px}');
    S.Append('.dot{width:6px;height:6px;border-radius:50%;background:#41E673;');
    S.Append('box-shadow:0 0 8px rgba(65,230,115,.88);animation:pulse 2s ease-in-out infinite}');
    S.Append('@keyframes pulse{0%,100%{box-shadow:0 0 6px rgba(65,230,115,.65)}50%{box-shadow:0 0 14px rgba(65,230,115,1),0 0 26px rgba(65,230,115,.22)}}');

    { titles }
    S.Append('.titulo{font-size:21px;font-weight:700;color:rgba(255,245,220,0.97);letter-spacing:-.4px;line-height:1.15}');
    S.Append('.subtitulo{font-size:12px;font-weight:400;color:rgba(255,200,130,0.38);margin-top:4px;margin-bottom:26px}');

    { fields }
    S.Append('.campo{margin-bottom:18px}');
    S.Append('.clabel{font-size:10.5px;font-weight:600;color:rgba(255,180,65,0.52);');
    S.Append('letter-spacing:1px;text-transform:uppercase;margin-bottom:8px;');
    S.Append('display:flex;align-items:center;gap:5px;transition:color .2s}');
    S.Append('.campo.foc .clabel{color:rgba(255,210,80,1)}');
    S.Append('.campo.err .clabel{color:rgba(255,85,70,0.85)}');
    S.Append('.campo.ok .clabel{color:rgba(60,205,105,0.80)}');
    S.Append('.cbox{position:relative;display:flex;align-items:center}');
    S.Append('.cinput{width:100% !important;height:48px !important;padding:0 46px !important;');
    S.Append('background:rgba(255,255,255,0.08) !important;border:none !important;border-radius:12px !important;');
    S.Append('color:rgba(255,245,222,0.97) !important;font-family:"Inter",system-ui,sans-serif !important;');
    S.Append('font-size:14px !important;font-weight:400 !important;outline:none !important;caret-color:#FFCC40 !important;');
    S.Append('box-shadow:0 0 0 1.5px rgba(255,170,50,0.22),inset 0 1.5px 0 rgba(255,255,255,0.07),inset 0 -1.5px 0 rgba(0,0,0,0.26) !important;');
    S.Append('transition:all .2s !important;appearance:none !important;-webkit-appearance:none !important}');
    S.Append('.cinput::placeholder{color:rgba(255,195,110,0.28) !important;font-size:13px !important;font-weight:300 !important}');
    { fix autofill browser override }
    S.Append('.cinput:-webkit-autofill,.cinput:-webkit-autofill:hover,.cinput:-webkit-autofill:focus{');
    S.Append('-webkit-box-shadow:0 0 0px 1000px rgba(30,12,2,0.92) inset !important;');
    S.Append('-webkit-text-fill-color:rgba(255,245,222,0.97) !important;');
    S.Append('transition:background-color 5000s ease-in-out 0s !important}');
    S.Append('.campo.foc .cinput{background:rgba(255,165,38,0.13) !important;');
    S.Append('box-shadow:0 0 0 2px rgba(255,200,60,0.60),0 0 0 5px rgba(255,160,35,0.14),inset 0 1.5px 0 rgba(255,215,80,0.09),inset 0 -1.5px 0 rgba(0,0,0,0.26) !important}');
    S.Append('.campo.err .cinput{box-shadow:0 0 0 2px rgba(255,72,58,0.60),0 0 0 5px rgba(255,55,40,0.12),inset 0 1.5px 0 rgba(255,255,255,0.04),inset 0 -1.5px 0 rgba(0,0,0,0.26) !important;animation:shk .26s ease !important}');
    S.Append('@keyframes shk{0%,100%{transform:translateX(0)}20%,60%{transform:translateX(-5px)}40%,80%{transform:translateX(5px)}}');
    S.Append('.cicone{position:absolute;left:0;top:0;bottom:0;width:46px;display:flex;align-items:center;justify-content:center;color:rgba(255,180,60,0.28);pointer-events:none;transition:color .2s}');
    S.Append('.campo.foc .cicone{color:rgba(255,210,75,0.76)}');
    S.Append('.campo.err .cicone{color:rgba(255,82,65,0.70)}');
    S.Append('.bolho{position:absolute;right:0;top:0;bottom:0;width:46px;background:none;border:none;cursor:pointer;');
    S.Append('display:flex;align-items:center;justify-content:center;color:rgba(255,180,60,0.26);');
    S.Append('border-radius:0 12px 12px 0;transition:color .18s,background .18s}');
    S.Append('.bolho:hover{color:rgba(255,210,75,0.90);background:rgba(255,175,45,0.08)}');

    { error / success messages }
    S.Append('.errmsg{font-size:11.5px;font-weight:500;color:rgba(255,95,75,0.94);margin-top:12px;min-height:16px;display:none;animation:fadeIn .2s ease}');
    S.Append('.okmsg{font-size:11.5px;font-weight:500;color:rgba(65,230,115,0.92);margin-top:12px;min-height:16px;display:none;animation:fadeIn .2s ease}');
    S.Append('@keyframes fadeIn{from{opacity:0;transform:translateY(-4px)}to{opacity:1;transform:translateY(0)}}');

    { divider }
    S.Append('.div{height:1px;margin:16px 0 14px;background:linear-gradient(to right,transparent,rgba(255,170,50,0.14),transparent)}');

    { toggle row }
    S.Append('.togrow{display:flex;align-items:center;justify-content:space-between;margin-bottom:22px}');
    S.Append('.tog{display:flex;align-items:center;gap:10px;cursor:pointer}');
    S.Append('.ttrack{width:34px;height:19px;background:rgba(255,255,255,0.08);border-radius:10px;position:relative;');
    S.Append('box-shadow:0 0 0 1px rgba(255,165,45,0.14);transition:background .2s,box-shadow .2s}');
    S.Append('.ttrack::after{content:"";position:absolute;top:3px;left:3px;width:13px;height:13px;border-radius:50%;');
    S.Append('background:rgba(255,185,90,0.32);transition:transform .22s cubic-bezier(.22,1,.36,1),background .22s}');
    S.Append('.tog input{display:none}');
    S.Append('.tog input:checked~.ttrack{background:rgba(255,155,30,0.22);box-shadow:0 0 0 1px rgba(255,160,35,0.48)}');
    S.Append('.tog input:checked~.ttrack::after{transform:translateX(15px);background:#FFAA18;box-shadow:0 0 7px rgba(255,170,35,0.60)}');
    S.Append('.tlabel{font-size:12px;font-weight:400;color:rgba(255,200,120,0.46)}');
    S.Append('.lbtn{background:none;border:none;cursor:pointer;padding:0;font-size:12px;font-weight:500;');
    S.Append('color:rgba(255,172,55,0.58);font-family:"Inter",system-ui,sans-serif;transition:color .16s}');
    S.Append('.lbtn:hover{color:rgba(255,215,80,0.92)}');

    { login button }
    S.Append('#btnLogin{width:100%;height:52px;border:none;border-radius:14px;cursor:pointer;');
    S.Append('font-family:"Inter",system-ui,sans-serif;font-size:13px;font-weight:700;letter-spacing:1.8px;text-transform:uppercase;color:#1a0800;');
    S.Append('background:linear-gradient(90deg,transparent 0%,rgba(255,115,15,0.38) 10%,rgba(255,190,55,0.85) 35%,rgba(255,238,120,1) 50%,rgba(255,190,55,0.85) 65%,rgba(255,115,15,0.38) 90%,transparent 100%);');
    S.Append('background-size:200% 100%;');
    S.Append('box-shadow:0 4px 20px rgba(255,160,30,0.35),0 1px 0 rgba(255,255,255,0.14) inset;');
    S.Append('transition:background-position .5s ease,box-shadow .3s,transform .15s;animation:shimmer 3s ease-in-out infinite}');
    S.Append('@keyframes shimmer{0%,100%{background-position:100% 0}50%{background-position:-100% 0}}');
    S.Append('#btnLogin:hover{box-shadow:0 6px 28px rgba(255,175,35,0.55),0 1px 0 rgba(255,255,255,0.18) inset;transform:translateY(-1px)}');
    S.Append('#btnLogin:active{transform:translateY(0);box-shadow:0 2px 10px rgba(255,155,25,0.40)}');
    S.Append('#btnLogin.loading{pointer-events:none;opacity:.7;animation:none}');

    { footer }
    S.Append('.footer{margin-top:20px;display:flex;align-items:center;justify-content:center;gap:8px;');
    S.Append('font-size:10px;font-weight:400;color:rgba(255,175,70,0.28);letter-spacing:.4px}');
    S.Append('.footer .sep{color:rgba(255,140,40,0.18)}');
    S.Append('</style>');
    S.Append('</head>');

    { ── BODY ────────────────────────────────────────────────────────────── }
    S.Append('<body>');

    { background + overlays }
    S.Append('<div id="bg"></div>');
    S.Append('<div id="ov1"></div><div id="ov2"></div><div id="ov3"></div>');

    { main container }
    S.Append('<div id="tela">');

    { ── card unico ── }
    S.Append('<div class="card" id="card">');

    { secao logo no topo do card }
    S.Append('<div class="logo-sec">');
    S.Append('<div class="logo-wrap">');
    S.Append('<img src="' + LLogoURL + '" alt="DT&amp;LL Transporte Logo"/>');
    S.Append('</div>');
    S.Append('<div class="logo-div"></div>');
    S.Append('<div class="logo-nm">DT<span>&amp;</span>LL Transporte</div>');
    S.Append('<div class="logo-sl">Tecnologia em Movimento</div>');
    S.Append('</div>');
    S.Append('<div class="badge"><div class="dot"></div>Sistema online</div>');
    S.Append('<div class="titulo">Acesse sua conta</div>');
    S.Append('<div class="subtitulo">Insira suas credenciais para continuar</div>');

    { username }
    S.Append('<div class="campo" id="cf_user">');
    S.Append('<div class="clabel">');
    S.Append('<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">');
    S.Append('<path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>');
    S.Append('Usu&aacute;rio</div>');
    S.Append('<div class="cbox">');
    S.Append('<div class="cicone">');
    S.Append('<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">');
    S.Append('<path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>');
    S.Append('</div>');
    S.Append('<input id="inp_user" class="cinput" type="text" placeholder="seu.usuario" autocomplete="username" ');
    S.Append('onfocus="setFocus(' + Q + 'cf_user' + Q + ',true)" onblur="setFocus(' + Q + 'cf_user' + Q + ',false)"/>');
    S.Append('</div></div>');

    { password }
    S.Append('<div class="campo" id="cf_pwd">');
    S.Append('<div class="clabel">');
    S.Append('<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">');
    S.Append('<rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>');
    S.Append('<path d="M7 11V7a5 5 0 0110 0v4"/></svg>');
    S.Append('Senha</div>');
    S.Append('<div class="cbox">');
    S.Append('<div class="cicone">');
    S.Append('<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">');
    S.Append('<rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>');
    S.Append('<path d="M7 11V7a5 5 0 0110 0v4"/></svg>');
    S.Append('</div>');
    S.Append('<input id="inp_pwd" class="cinput" type="password" placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;" autocomplete="current-password" ');
    S.Append('onfocus="setFocus(' + Q + 'cf_pwd' + Q + ',true)" onblur="setFocus(' + Q + 'cf_pwd' + Q + ',false)"/>');
    S.Append('<button class="bolho" id="bolho_pwd" type="button" onclick="togglePwd()">');
    S.Append('<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">');
    S.Append('<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>');
    S.Append('</button>');
    S.Append('</div></div>');

    { messages }
    S.Append('<div id="errmsg" class="errmsg"></div>');
    S.Append('<div id="okmsg"  class="okmsg"></div>');

    { divider + options }
    S.Append('<div class="div"></div>');
    S.Append('<div class="togrow">');
    S.Append('<label class="tog">');
    S.Append('<input type="checkbox" id="ck_rem">');
    S.Append('<div class="ttrack"></div>');
    S.Append('<span class="tlabel">Lembrar-me</span>');
    S.Append('</label>');
    S.Append('<button class="lbtn" type="button">Esqueceu a senha?</button>');
    S.Append('</div>');

    { login button }
    S.Append('<button id="btnLogin" type="button" onclick="doLogin()">Entrar</button>');

    { footer }
    S.Append('<div class="footer">');
    S.Append('<span>DT&amp;LL Transporte v1.0</span>');
    S.Append('<span class="sep">&bull;</span>');
    S.Append('<span>&copy; 2025 DTecno Sistemas</span>');
    S.Append('</div>');

    S.Append('</div>'); { .card }
    S.Append('</div>'); { #tela }

    { ── JAVASCRIPT ──────────────────────────────────────────────────────── }
    S.Append('<script>');

    { toggle password visibility }
    S.Append('function togglePwd(){');
    S.Append('var i=document.getElementById(' + Q + 'inp_pwd' + Q + ');');
    S.Append('var b=document.getElementById(' + Q + 'bolho_pwd' + Q + ');');
    S.Append('var show=(i.type==="password");');
    S.Append('i.type=show?"text":"password";');
    S.Append('b.innerHTML=show?');
    S.Append(Q + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/></svg>' + Q);
    S.Append(':' + Q + '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>' + Q + ';}');

    { field focus/error helpers }
    S.Append('function setFocus(id,on){');
    S.Append('var el=document.getElementById(id);');
    S.Append('if(!el)return;');
    S.Append('on?el.classList.add(' + Q + 'foc' + Q + '):el.classList.remove(' + Q + 'foc' + Q + ');}');

    S.Append('function setErr(id,on){');
    S.Append('var el=document.getElementById(id);');
    S.Append('if(!el)return;');
    S.Append('on?el.classList.add(' + Q + 'err' + Q + '):el.classList.remove(' + Q + 'err' + Q + ');}');

    { show error }
    S.Append('function showErrMsg(msg){');
    S.Append('var e=document.getElementById(' + Q + 'errmsg' + Q + ');');
    S.Append('var o=document.getElementById(' + Q + 'okmsg'  + Q + ');');
    S.Append('e.textContent=msg;');
    S.Append('e.style.display=msg?' + Q + 'block' + Q + ':' + Q + 'none' + Q + ';');
    S.Append('o.style.display=' + Q + 'none' + Q + ';');
    S.Append('setErr(' + Q + 'cf_user' + Q + ',msg!=' + Q + Q + ');');
    S.Append('setErr(' + Q + 'cf_pwd'  + Q + ',msg!=' + Q + Q + ');}');

    { show success }
    S.Append('function showSuccessMsg(msg){');
    S.Append('var o=document.getElementById(' + Q + 'okmsg'  + Q + ');');
    S.Append('var e=document.getElementById(' + Q + 'errmsg' + Q + ');');
    S.Append('o.textContent=msg;');
    S.Append('o.style.display=' + Q + 'block' + Q + ';');
    S.Append('e.style.display=' + Q + 'none' + Q + ';');
    S.Append('setErr(' + Q + 'cf_user' + Q + ',false);');
    S.Append('setErr(' + Q + 'cf_pwd'  + Q + ',false);}');

    { main login action }
    S.Append('function doLogin(){');
    S.Append('var u=document.getElementById(' + Q + 'inp_user' + Q + ').value;');
    S.Append('var p=document.getElementById(' + Q + 'inp_pwd'  + Q + ').value;');
    S.Append('document.getElementById(' + Q + 'btnLogin' + Q + ').classList.add(' + Q + 'loading' + Q + ');');
    S.Append('showErrMsg(' + Q + Q + ');');
    S.Append('ajaxRequest(window.HtmlLogin,' + Q + 'DoLogin' + Q + ',');
    S.Append('[' + Q + 'user=' + Q + '+encodeURIComponent(u),' + Q + 'pwd=' + Q + '+encodeURIComponent(p)]);}');

    { enter key }
    S.Append('document.addEventListener(' + Q + 'keydown' + Q + ',');
    S.Append('function(e){e.key===' + Q + 'Enter' + Q + '&&doLogin();});');

    S.Append('</script>');
    S.Append('</body></html>');

    Result := S.ToString;
  finally
    S.Free;
  end;
end;

initialization
  RegisterAppFormClass(TFrmLogin);

end.
