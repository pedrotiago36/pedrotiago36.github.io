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
  uniURLFrame, uniHTMLFrame, uniGUIBaseClasses,
  View.ILoginView,
  Controller.ILoginController,
  Controller.IMainController,
  Controller.IPerfilController,
  Controller.IUsuarioController,
  Controller.IPermissoesController,
  Controller.IScreenActionsController,
  Model.ILogin,
  Model.IMenuItem,
  Model.IPerfil,
  Model.IUsuario,
  Model.IPermissoes,
  Model.IScreenActions;

type
  TFrmLogin = class(TUniForm, ILoginView, IMainView)
    HtmlLogin: TUniURLFrame;
    HtmlMain : TUniHTMLFrame;
    procedure UniFormCreate(Sender: TObject);
    procedure HtmlLoginAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure HtmlMainAjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    { estado }
    FInMain     : Boolean;
    FJSFrame    : string;  { parent['JSName'] — atualizado na troca de frame }
    { login }
    FLoginCtrl  : ILoginController;
    FUser       : string;
    FPwd        : string;
    { main }
    FMainCtrl      : IMainController;
    FPerfilModel   : IPerfilModel;
    FPerfilCtrl    : IPerfilController;
    FUsuarioModel    : IUsuarioModel;
    FUsuarioCtrl     : IUsuarioController;
    FPermissoesModel : IPermissoesModel;
    FPermissoesCtrl  : IPermissoesController;
    FScreenActionsModel : IScreenActionsModel;
    FScreenActionsCtrl  : IScreenActionsController;
    { construtores de HTML }
    function  BuildLoginHtml: string;
    function  BuildMainHtml: string;
    function  RenderSidebar(const AItems: TArray<TMenuItemRec>): string;
    { handlers por fase }
    procedure HandleLoginEvent(EventName: string; Params: TUniStrings);
    procedure HandleMainEvent(EventName: string; Params: TUniStrings);
    { perfil — injeção de HTML no #screen }
    procedure InjectPerfilList(const AItems: TArray<TPerfilRec>);
    procedure InjectPerfilForm(const ARec: TPerfilRec);
    function  BuildPerfilListHtml(const AItems: TArray<TPerfilRec>): string;
    function  BuildPerfilFormHtml(const ARec: TPerfilRec): string;
    { usuário — injeção de HTML no #screen }
    procedure InjectUsuarioList(const AItems: TArray<TUsuarioRec>;
                                const APerfis: TArray<TPerfilRec>);
    procedure InjectUsuarioForm(const ARec: TUsuarioRec;
                                const APerfis: TArray<TPerfilRec>);
    function  BuildUsuarioListHtml(const AItems: TArray<TUsuarioRec>;
                                   const APerfis: TArray<TPerfilRec>): string;
    function  BuildUsuarioFormHtml(const ARec: TUsuarioRec;
                                   const APerfis: TArray<TPerfilRec>): string;
    { permissões — injeção de HTML no #screen }
    procedure InjectPermForm(const ARec      : TPermissoesRec;
                             const AUsuarios : TArray<TUsuarioRec>;
                             const AItems    : TArray<TMenuItemRec>);
    function  BuildPermFormHtml(const ARec      : TPermissoesRec;
                                const AUsuarios : TArray<TUsuarioRec>;
                                const AItems    : TArray<TMenuItemRec>): string;
    { ações em telas — injeção de HTML no #screen }
    procedure InjectScreenActions(const AScreens: TArray<string>;
                                  const AUsuarios: TArray<string>;
                                  const ASelectedUserID: Integer);
    function  BuildScreenActionsHtml(const AScreens: TArray<string>;
                                     const AUsuarios: TArray<string>;
                                     const ASelectedUserID: Integer): string;
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
  System.Generics.Collections,
  Model.TLogin,
  Model.TPerfil,
  Model.TUsuario,
  Model.TPermissoes,
  Model.TScreenActions,
  Controller.TLoginController,
  Controller.TMainController,
  Controller.TPerfilController,
  Controller.TUsuarioController,
  Controller.TPermissoesController,
  Controller.TScreenActionsController,
  System.JSON,
  uniGUIApplication,
  uniGUIVars,
  ServerModule,
  uniGUIServer,
  Service.ApiHealthCheck,
  Service.ApiClient;

{ ══════════════════════════════════════════════════════════════
  Adapter privado — conecta IPerfilView a TFrmLogin
  ══════════════════════════════════════════════════════════════ }

type
  TPerfilViewAdapter = class(TInterfacedObject, IPerfilView)
  strict private
    FOwner: TFrmLogin;
  public
    constructor Create(AOwner: TFrmLogin);
    procedure ShowList(const AItems: TArray<TPerfilRec>);
    procedure ShowForm(const ARec: TPerfilRec);
  end;

constructor TPerfilViewAdapter.Create(AOwner: TFrmLogin);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TPerfilViewAdapter.ShowList(const AItems: TArray<TPerfilRec>);
begin
  FOwner.InjectPerfilList(AItems);
end;

procedure TPerfilViewAdapter.ShowForm(const ARec: TPerfilRec);
begin
  FOwner.InjectPerfilForm(ARec);
end;

{ ══════════════════════════════════════════════════════════════
  Adapter privado — conecta IUsuarioView a TFrmLogin
  ══════════════════════════════════════════════════════════════ }

type
  TUsuarioViewAdapter = class(TInterfacedObject, IUsuarioView)
  strict private
    FOwner: TFrmLogin;
  public
    constructor Create(AOwner: TFrmLogin);
    procedure ShowList(const AItems: TArray<TUsuarioRec>;
                       const APerfis: TArray<TPerfilRec>);
    procedure ShowForm(const ARec: TUsuarioRec;
                       const APerfis: TArray<TPerfilRec>);
  end;

constructor TUsuarioViewAdapter.Create(AOwner: TFrmLogin);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TUsuarioViewAdapter.ShowList(const AItems: TArray<TUsuarioRec>;
  const APerfis: TArray<TPerfilRec>);
begin
  FOwner.InjectUsuarioList(AItems, APerfis);
end;

procedure TUsuarioViewAdapter.ShowForm(const ARec: TUsuarioRec;
  const APerfis: TArray<TPerfilRec>);
begin
  FOwner.InjectUsuarioForm(ARec, APerfis);
end;

{ ══════════════════════════════════════════════════════════════
  Adapter privado — conecta IPermissoesView a TFrmLogin
  ══════════════════════════════════════════════════════════════ }

type
  TPermissoesViewAdapter = class(TInterfacedObject, IPermissoesView)
  strict private
    FOwner: TFrmLogin;
  public
    constructor Create(AOwner: TFrmLogin);
    procedure ShowPermissoes(const ARec      : TPermissoesRec;
                             const AUsuarios : TArray<TUsuarioRec>;
                             const AItems    : TArray<TMenuItemRec>);
  end;

constructor TPermissoesViewAdapter.Create(AOwner: TFrmLogin);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TPermissoesViewAdapter.ShowPermissoes(const ARec      : TPermissoesRec;
  const AUsuarios : TArray<TUsuarioRec>; const AItems : TArray<TMenuItemRec>);
begin
  FOwner.InjectPermForm(ARec, AUsuarios, AItems);
end;

{ ══════════════════════════════════════════════════════════════
  Adapter privado — conecta IScreenActionsView a TFrmLogin
  ══════════════════════════════════════════════════════════════ }

type
  TScreenActionsViewAdapter = class(TInterfacedObject, IScreenActionsView)
  strict private
    FOwner: TFrmLogin;
  public
    constructor Create(AOwner: TFrmLogin);
    procedure ShowScreenActions(const AScreens: TArray<string>;
                                const AUsuarios: TArray<string>;
                                const ASelectedUserID: Integer);
  end;

constructor TScreenActionsViewAdapter.Create(AOwner: TFrmLogin);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TScreenActionsViewAdapter.ShowScreenActions(const AScreens: TArray<string>;
  const AUsuarios: TArray<string>; const ASelectedUserID: Integer);
begin
  FOwner.InjectScreenActions(AScreens, AUsuarios, ASelectedUserID);
end;

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
begin
  { HtmlLogin e TUniURLFrame — usado apenas na fase LOGIN }
  HandleLoginEvent(EventName, Params);
end;

procedure TFrmLogin.HtmlMainAjaxEvent(Sender: TComponent; EventName: string;
  Params: TUniStrings);
begin
  { HtmlMain e TUniHTMLFrame — usado apenas na fase MAIN }
  HandleMainEvent(EventName, Params);
end;

{ ── fase LOGIN ── }

procedure TFrmLogin.HandleLoginEvent(EventName: string; Params: TUniStrings);
var
  LThread : TApiHealthThread;
  LOnline : Boolean;
begin
  { ── verificação de saúde da API (disparada periodicamente pelo JS) ── }
  if EventName = 'checkApi' then
  begin
    LThread := TApiHealthThread.Create(API_BASE_URL);
    try
      LThread.Start;
      LThread.WaitFor;   { timeout HTTP = 2 s — não bloqueia por mais que isso }
      LOnline := LThread.IsOnline;
    finally
      LThread.Free;
    end;
    { UniSession.AddJS roda no contexto pai (ExtJS). setApiStatus está dentro do
      iframe (TUniURLFrame) — precisa acessar via contentWindow do elemento iframe. }
    if LOnline then
      UniSession.AddJS('(function(){var c=' + HtmlLogin.JSName +
        ';if(c&&c.iframe&&c.iframe.contentWindow&&c.iframe.contentWindow.setApiStatus)' +
        'c.iframe.contentWindow.setApiStatus(true);})();')
    else
      UniSession.AddJS('(function(){var c=' + HtmlLogin.JSName +
        ';if(c&&c.iframe&&c.iframe.contentWindow&&c.iframe.contentWindow.setApiStatus)' +
        'c.iframe.contentWindow.setApiStatus(false);})();');
    Exit;
  end;

  { ── autenticação normal ── }
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
  TAct = array[0..16] of TProc;
var
  LRoute    : string;
  LID       : Integer;
  LNome     : string;
  LPerms    : TArray<string>;
  LLogin    : string;
  LSenha    : string;
  LIsAdmin  : Boolean;
  LPerfilID : Integer;
  LUsrID    : Integer;
  LActionRoute : string;
  LActionKey : string;
  LAct      : TAct;
begin
  LRoute    := Params.Values['route'];
  LID       := StrToIntDef(Params.Values['id'], 0);
  LNome     := Params.Values['nome'];
  LPerms    := SplitString(Params.Values['perms'], '|');
  LLogin    := Params.Values['login'];
  LSenha    := Params.Values['senha'];
  LIsAdmin  := Params.Values['isadmin'] = '1';
  LPerfilID := StrToIntDef(Params.Values['perfilid'], 0);
  LUsrID    := StrToIntDef(Params.Values['userid'], 0);
  LActionRoute := Params.Values['actroute'];
  LActionKey := Params.Values['actkey'];

  LAct[0] := procedure
    begin
      try FMainCtrl.NavigateTo(LRoute);
      except on E: EAssertionFailed do
        UniSession.AddJS('alert(' + QuotedStr(E.Message) + ')');
      end;
    end;
  LAct[1]  := procedure begin FMainCtrl.CloseTab(LRoute) end;
  LAct[2]  := procedure begin FMainCtrl.ToggleFavorite(LRoute) end;
  LAct[3]  := procedure begin FPerfilCtrl.StartInsert end;
  LAct[4]  := procedure begin FPerfilCtrl.StartEdit(LID) end;
  LAct[5]  := procedure begin FPerfilCtrl.Remove(LID) end;
  LAct[6]  := procedure begin FPerfilCtrl.Save(LNome, LPerms, LID) end;
  LAct[7]  := procedure begin FUsuarioCtrl.StartInsert end;
  LAct[8]  := procedure begin FUsuarioCtrl.StartEdit(LID) end;
  LAct[9]  := procedure begin FUsuarioCtrl.Remove(LID) end;
  LAct[10] := procedure begin
    FUsuarioCtrl.Save(LLogin, LSenha, LIsAdmin, LPerfilID, LID);
  end;
  LAct[11] := procedure begin FPermissoesCtrl.SelectUser(LUsrID) end;
  LAct[12] := procedure begin FPermissoesCtrl.Save(LUsrID, LPerms) end;
  LAct[13] := procedure begin FPermissoesCtrl.LoadList end;
  LAct[14] := procedure begin FScreenActionsCtrl.SelectUser(LUsrID) end;
  LAct[15] := procedure begin FScreenActionsCtrl.ToggleAction(LUsrID, LActionRoute, LActionKey) end;
  LAct[16] := procedure begin FScreenActionsCtrl.LoadList end;

  LAct[
    Ord(EventName='nav')          *  0 +
    Ord(EventName='closeTab')     *  1 +
    Ord(EventName='toggleFav')    *  2 +
    Ord(EventName='prf.insert')   *  3 +
    Ord(EventName='prf.edit')     *  4 +
    Ord(EventName='prf.delete')   *  5 +
    Ord(EventName='prf.save')     *  6 +
    Ord(EventName='usr.insert')   *  7 +
    Ord(EventName='usr.edit')     *  8 +
    Ord(EventName='usr.delete')   *  9 +
    Ord(EventName='usr.save')     * 10 +
    Ord(EventName='perm.select')  * 11 +
    Ord(EventName='perm.save')    * 12 +
    Ord(EventName='perm.back')    * 13 +
    Ord(EventName='ac.select')    * 14 +
    Ord(EventName='ac.toggle')    * 15 +
    Ord(EventName='ac.back')      * 16
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

    { Perfil — instância e wiring }
    FPerfilModel := NewPerfilModel;
    FPerfilCtrl  := NewPerfilController(FPerfilModel, FMainCtrl.GetMenuItems);
    FPerfilCtrl.BindView(TPerfilViewAdapter.Create(Self));

    { Usuário — instância e wiring }
    FUsuarioModel := NewUsuarioModel;
    FUsuarioCtrl  := NewUsuarioController(FUsuarioModel, FPerfilModel);
    FUsuarioCtrl.BindView(TUsuarioViewAdapter.Create(Self));

    { Registra handler de tela para cfg.perfil }
    FMainCtrl.RegisterScreenHandler('cfg.perfil',
      procedure begin FPerfilCtrl.LoadList end);

    { Registra handler de tela para cfg.usuario }
    FMainCtrl.RegisterScreenHandler('cfg.usuario',
      procedure begin FUsuarioCtrl.LoadList end);

    { Permissões — instância e wiring }
    FPermissoesModel := NewPermissoesModel;
    FPermissoesCtrl  := NewPermissoesController(
      FPermissoesModel, FUsuarioModel, FMainCtrl.GetMenuItems);
    FPermissoesCtrl.BindView(TPermissoesViewAdapter.Create(Self));

    { Registra handler de tela para cfg.permissoes }
    FMainCtrl.RegisterScreenHandler('cfg.permissoes',
      procedure begin FPermissoesCtrl.LoadList end);

    { Ações em Telas — instância e wiring }
    FScreenActionsModel := NewScreenActionsModel;
    FScreenActionsCtrl  := NewScreenActionsController(FScreenActionsModel, FUsuarioModel);
    FScreenActionsCtrl.BindView(TScreenActionsViewAdapter.Create(Self));

    { Registra handler de tela para cfg.acoes }
    FMainCtrl.RegisterScreenHandler('cfg.acoes',
      procedure begin FScreenActionsCtrl.LoadList end);

    { Troca de frame: oculta TUniURLFrame (login), ativa TUniHTMLFrame (main) }
    HtmlLogin.Visible := False;
    FJSFrame := 'parent[' + QuotedStr(HtmlMain.JSName) + ']';
    HtmlMain.HTML.Text := BuildMainHtml;
    HtmlMain.Visible := True;
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
  UniSession.AddJS('Ext.Msg.alert("Aten\u00E7\u00E3o",' + QuotedStr(AMessage) + ');');
end;

{ ══════════════════════════════════════════════════════════════
  IMainView
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.OpenTab(const ARoute, ACaption, ABreadPath: string);
begin
  { HtmlMain é TUniHTMLFrame — UniSession.AddJS alcança seu contexto JS diretamente }
  UniSession.AddJS(Format('openTab(%s,%s,%s);',
    [QuotedStr(ARoute), QuotedStr(ACaption), QuotedStr(ABreadPath)]));
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
    S.Append('.badge{display:inline-flex;align-items:center;gap:6px;font-size:10px;font-weight:600;letter-spacing:.8px;text-transform:uppercase;margin-bottom:14px;transition:color .3s}');
    S.Append('.dot{width:6px;height:6px;border-radius:50%;box-shadow:0 0 8px;animation:pulse 2s ease-in-out infinite;transition:background .3s,box-shadow .3s}');
    S.Append('.dot.online{background:#41E673;box-shadow:0 0 8px rgba(65,230,115,.88);color:rgba(65,230,115,0.92)}');
    S.Append('.dot.offline{background:#EF4444;box-shadow:0 0 8px rgba(239,68,68,.88);color:rgba(239,68,68,0.92);animation:none}');
    S.Append('.badge.online{color:rgba(65,230,115,0.92)}');
    S.Append('.badge.online span{color:rgba(65,230,115,0.92)}');
    S.Append('.badge.offline{color:rgba(239,68,68,0.92)}');
    S.Append('.badge.offline span{color:rgba(239,68,68,0.92)}');
    S.Append('@keyframes pulse{0%,100%{box-shadow:0 0 6px currentColor}50%{box-shadow:0 0 14px currentColor}}');
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

    S.Append('<div class="badge" id="api-status"><div class="dot online" id="api-dot"></div><span id="api-txt">API Online</span></div>');
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
    { setApiStatus(true|false) — chamada pelo Delphi via UniSession.AddJS após WaitFor }
    S.Append('function setApiStatus(on){');
    S.Append('var dot=document.getElementById(' + Q + 'api-dot' + Q + ');');
    S.Append('var badge=document.getElementById(' + Q + 'api-status' + Q + ');');
    S.Append('var txt=document.getElementById(' + Q + 'api-txt' + Q + ');');
    S.Append('if(!dot||!badge||!txt)return;');
    S.Append('dot.className=on?' + Q + 'dot online' + Q + ':' + Q + 'dot offline' + Q + ';');
    S.Append('badge.className=on?' + Q + 'badge online' + Q + ':' + Q + 'badge offline' + Q + ';');
    S.Append('txt.textContent=on?' + Q + 'API Online' + Q + ':' + Q + 'API Offline' + Q + ';}');
    { checkApiStatus — solicita verificação ao servidor Delphi (TApiHealthThread) via ajaxRequest }
    S.Append('function checkApiStatus(){');
    S.Append('parent.ajaxRequest(_f,' + Q + 'checkApi' + Q + ',[]);}');
    S.Append('checkApiStatus();');
    S.Append('setInterval(checkApiStatus,5000);');
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
    '.tb-srch input::placeholder{color:rgba(255,255,255,.35)!important;}' +
    '.srch-ico{position:absolute;left:13px;top:50%;transform:translateY(-50%);color:rgba(255,255,255,.35);pointer-events:none;}' +
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
    '  transition:all .2s cubic-bezier(.4,0,.2,1);color:#E2E8F0;' +
    '  user-select:none;border:1px solid transparent;position:relative;}' +
    '.sb-item:hover:not(.disabled){' +
    '  background:rgba(255,255,255,.06);color:#FFFFFF;' +
    '  border-color:rgba(255,255,255,.08);}' +
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
    '.sb-item.sb-grp{color:rgba(245,158,11,.7);font-weight:700;font-size:11.5px;' +
    '  letter-spacing:.4px;text-transform:uppercase;}' +
    '.sb-item.sb-grp:hover:not(.disabled){' +
    '  background:rgba(245,158,11,.06);color:var(--am);' +
    '  border-color:rgba(245,158,11,.12);}' +
    '.sb-arr{margin-left:auto;color:rgba(255,255,255,.3);display:flex;align-items:center;flex-shrink:0;' +
    '  transition:all .2s;}' +
    '.sb-item:hover .sb-arr{color:var(--am);transform:translateX(3px);}' +
    '.soon{font-size:9px;background:rgba(100,116,139,.08);color:rgba(255,255,255,.35);' +
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

    '#no-tab{font-size:12px;color:rgba(255,255,255,.45);font-style:italic;' +
    '  padding:0 8px;align-self:center;letter-spacing:.3px;}' +
    '#tabs-sep{width:1px;height:22px;background:rgba(255,255,255,.08);flex-shrink:0;margin-left:auto;}' +
    '#btn-close-all{display:flex;align-items:center;gap:5px;flex-shrink:0;' +
    '  background:none;border:1px solid rgba(239,68,68,.25);border-radius:16px;' +
    '  padding:0 12px;height:28px;color:rgba(239,68,68,.5);font-size:11px;font-weight:600;' +
    '  cursor:pointer;transition:all .2s;letter-spacing:.4px;white-space:nowrap;}' +
    '#btn-close-all:hover{background:rgba(239,68,68,.1);border-color:rgba(239,68,68,.6);' +
    '  color:#F87171;box-shadow:0 0 12px rgba(239,68,68,.2);}' +
    '#btn-close-all:disabled{opacity:.2;cursor:not-allowed;pointer-events:none;}' +

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
    'function _updCloseAll(){' +
    '  var n=document.querySelectorAll(".tab-btn").length;' +
    '  var btn=document.getElementById("btn-close-all");' +
    '  var sep=document.getElementById("tabs-sep");' +
    '  if(btn)btn.disabled=(n===0);' +
    '  if(sep)sep.style.visibility=n>0?"visible":"hidden";}' +
    'function openTab(route,cap,bread,stack){' +
    '  if(OT[route]){setActive(route);return;}' +
    '  if(Object.keys(OT).length>=6){' +
    '    alert("M\u00E1ximo de 6 abas abertas. Feche uma aba antes de abrir outra.");return;}' +
    '  OT[route]={cap:cap,bread:bread,stack:stack||[]};' +
    '  var bar=document.getElementById("tabs-bar");' +
    '  var nt=document.getElementById("no-tab");if(nt)nt.style.display="none";' +
    '  var t=document.createElement("div");t.className="tab-btn";t.dataset.route=route;' +
    '  var dot=document.createElement("span");dot.className="tab-ico";' +
    '  var l=document.createElement("span");l.textContent=cap;' +
    '  var x=document.createElement("button");x.className="tab-x";x.innerHTML="&times;";' +
    '  (function(ro){t.addEventListener("click",function(){setActive(ro);});' +
    '   x.addEventListener("click",function(e){e.stopPropagation();closeTab(ro);});' +
    '  })(route);' +
    '  t.appendChild(dot);t.appendChild(l);t.appendChild(x);' +
    '  var sep=document.getElementById("tabs-sep");' +
    '  if(sep)bar.insertBefore(t,sep);else bar.appendChild(t);' +
    '  setActive(route);_updCloseAll();}' + +
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
    '  else if(!rem.length){' +
    '    var nt=document.getElementById("no-tab");if(nt)nt.style.display="";' +
    '    renderBC("");renderScr("","");}' +
    '  document.querySelectorAll(".nav-item").forEach(function(m){m.classList.remove("active");});' +
    '  _updCloseAll();}' +
    'function closeAllTabs(){' +
    '  Object.keys(OT).forEach(function(r){' +
    '    var t=document.querySelector(".tab-btn[data-route="+JSON.stringify(r)+"]");' +
    '    if(t)t.remove();' +
    '    parent.ajaxRequest(_f,"closeTab",["route="+r]);' +
    '  });' +
    '  OT={};' +
    '  var nt=document.getElementById("no-tab");if(nt)nt.style.display="";' +
    '  document.querySelectorAll(".nav-item").forEach(function(m){m.classList.remove("active");});' +
    '  renderBC("");renderScr("","");_updCloseAll();}' +
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
    { Cache de telas: Delphi injeta HTML via cacheScreen(route, html) }
    'var SC={};' +
    'function cacheScreen(r,h){SC[r]=h;}' +
    'function renderScr(route,cap){' +
    '  var el=document.getElementById("screen");' +
    '  el.innerHTML=!route' +
    '    ?"<div class=sc-empty><p>Selecione uma tela no menu lateral</p></div>"' +
    '    :(SC[route]?SC[route]:"<div class=sc-card><h2>"+cap+"</h2>' +
    '      <p>Tela em desenvolvimento.</p><span class=rtag>"+route+"</span></div>");' +
    '}' +
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
    { Perfil — funções globais (scripts dentro de innerHTML não executam) }
    'function prfInsert(){parent.ajaxRequest(_f,"prf.insert",[]);}' +
    'function prfEdit(id){parent.ajaxRequest(_f,"prf.edit",["id="+id]);}' +
    'function prfDel(id){parent.ajaxRequest(_f,"prf.delete",["id="+id]);}' +
    'function prfSave(){' +
    '  var id=document.getElementById("prf-id").value;' +
    '  var nome=encodeURIComponent(document.getElementById("prf-nome").value.trim());' +
    '  var perms=[];' +
    '  document.querySelectorAll(".prf-chk input:checked").forEach(function(c){perms.push(c.value);});' +
    '  parent.ajaxRequest(_f,"prf.save",["id="+id,"nome="+nome,"perms="+perms.join("|")]);}' +
    'function prfCancel(){parent.ajaxRequest(_f,"prf.insert",[]);}' +
    { Usuário — funções globais }
    'function usrInsert(){parent.ajaxRequest(_f,"usr.insert",[]);}' +
    'function usrEdit(id){parent.ajaxRequest(_f,"usr.edit",["id="+id]);}' +
    'function usrDel(id){parent.ajaxRequest(_f,"usr.delete",["id="+id]);}' +
    'function usrSave(){' +
    '  var id=document.getElementById("usr-id").value;' +
    '  var login=encodeURIComponent(document.getElementById("usr-login").value.trim());' +
    '  var senha=encodeURIComponent(document.getElementById("usr-senha").value.trim());' +
    '  var isadmin=document.getElementById("usr-admin").checked?"1":"0";' +
    '  var sel=document.getElementById("usr-perfil");' +
    '  var perfilid=sel?sel.value:"0";' +
    '  parent.ajaxRequest(_f,"usr.save",' +
    '    ["id="+id,"login="+login,"senha="+senha,"isadmin="+isadmin,"perfilid="+perfilid]);}' +
    'function usrCancel(){parent.ajaxRequest(_f,"usr.insert",[]);}' +
    { Permissões }
    'function permSelect(id){parent.ajaxRequest(_f,"perm.select",["userid="+id]);}' +
    'function permSave(){' +
    '  var uid=document.getElementById("perm-uid").value;' +
    '  var perms=[];' +
    '  document.querySelectorAll(".prm-chk input:checked").forEach(function(c){perms.push(c.value);});' +
    '  parent.ajaxRequest(_f,"perm.save",["userid="+uid,"perms="+perms.join("|")]);}' +
    'function permBack(){parent.ajaxRequest(_f,"perm.back",[]);}' +
    { Marcar todos — perfil }
    'function prfCheckAll(lbl){' +
    '  var inp=lbl.querySelector("input");' +
    '  var card=lbl.closest(".prf-card");' +
    '  card.querySelectorAll(".prf-chk input").forEach(function(b){b.checked=inp.checked;});}' +
    'function prfUpdateAllChk(inp){' +
    '  var card=inp.closest(".prf-card");' +
    '  var boxes=card.querySelectorAll(".prf-chk input");' +
    '  var allInp=card.querySelector(".prf-chk-all input");' +
    '  if(!allInp)return;' +
    '  var n=0;boxes.forEach(function(b){if(b.checked)n++;});' +
    '  allInp.checked=(boxes.length>0&&n===boxes.length);}' +
    'function prfInitAllChk(){' +
    '  document.querySelectorAll(".prf-card").forEach(function(card){' +
    '    var boxes=card.querySelectorAll(".prf-chk input");' +
    '    var allInp=card.querySelector(".prf-chk-all input");' +
    '    if(!allInp||!boxes.length)return;' +
    '    var n=0;boxes.forEach(function(b){if(b.checked)n++;});' +
    '    allInp.checked=(n===boxes.length);});}' +
    { Marcar todos — permissões }
    'function permCheckAll(lbl){' +
    '  var inp=lbl.querySelector("input");' +
    '  var card=lbl.closest(".prm-card");' +
    '  card.querySelectorAll(".prm-chk input").forEach(function(b){b.checked=inp.checked;});}' +
    'function permUpdateAllChk(inp){' +
    '  var card=inp.closest(".prm-card");' +
    '  var boxes=card.querySelectorAll(".prm-chk input");' +
    '  var allInp=card.querySelector(".prm-chk-all input");' +
    '  if(!allInp)return;' +
    '  var n=0;boxes.forEach(function(b){if(b.checked)n++;});' +
    '  allInp.checked=(boxes.length>0&&n===boxes.length);}' +
    'function permInitAllChk(){' +
    '  document.querySelectorAll(".prm-card").forEach(function(card){' +
    '    var boxes=card.querySelectorAll(".prm-chk input");' +
    '    var allInp=card.querySelector(".prm-chk-all input");' +
    '    if(!allInp||!boxes.length)return;' +
    '    var n=0;boxes.forEach(function(b){if(b.checked)n++;});' +
    '    allInp.checked=(n===boxes.length);});}' +
    { Ações em Telas }
    'function acSelect(id){parent.ajaxRequest(_f,"ac.select",["userid="+id]);}' +
    'function acToggle(el,uid,route,key){' +
    '  var isAllowed=el.classList.contains("allowed");' +
    '  el.classList.toggle("allowed",!isAllowed);' +
    '  el.classList.toggle("denied",isAllowed);' +
    '  parent.ajaxRequest(_f,"ac.toggle",["userid="+uid,"actroute="+encodeURIComponent(route),"actkey="+encodeURIComponent(key)]);}' +
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
    H.Append('<div id="tabs-bar">' +
      '<span id="no-tab">Nenhuma tela aberta</span>' +
      '<span id="tabs-sep"></span>' +
      '<button id="btn-close-all" disabled onclick="closeAllTabs()">' +
      '&#10005; Fechar todas' +
      '</button>' +
      '</div>');
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

{ ══════════════════════════════════════════════════════════════
  Injeção de HTML de perfil no #screen via cacheScreen JS
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.InjectPerfilList(const AItems: TArray<TPerfilRec>);
var
  LHtml : string;
  LJson : TJSONString;
begin
  LHtml := BuildPerfilListHtml(AItems);
  LJson := TJSONString.Create(LHtml);
  try
    UniSession.AddJS(
      'cacheScreen("cfg.perfil",' + LJson.ToString + ');' +
      'renderScr("cfg.perfil","Cadastro de Perfil");');
  finally
    LJson.Free;
  end;
end;

procedure TFrmLogin.InjectPerfilForm(const ARec: TPerfilRec);
type
  TTitleArr = array[Boolean] of string;
const
  TITLES: TTitleArr = ('Novo Perfil', 'Editar Perfil');
var
  LHtml : string;
  LJson : TJSONString;
begin
  LHtml := BuildPerfilFormHtml(ARec);
  LJson := TJSONString.Create(LHtml);
  try
    UniSession.AddJS(
      'cacheScreen("cfg.perfil",' + LJson.ToString + ');' +
      'renderScr("cfg.perfil",' + QuotedStr(TITLES[ARec.ID > 0]) + ');' +
      'prfInitAllChk();');
  finally
    LJson.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  BuildPerfilListHtml — tela de lista de perfis
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.BuildPerfilListHtml(const AItems: TArray<TPerfilRec>): string;
type
  TBodyArr = array[Boolean] of string;
var
  B     : TStringBuilder;
  P     : TPerfilRec;
  CSS   : string;
  Rows  : string;
  LBody : TBodyArr;
begin
  CSS :=
    '<style>' +
    '.prf-screen{font-family:"Segoe UI",system-ui,sans-serif;color:#E2E8F0;animation:fuSlide .3s cubic-bezier(.22,1,.36,1);}' +
    '.prf-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:28px;}' +
    '.prf-title{font-size:22px;font-weight:800;background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
    '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
    '.prf-sub{font-size:12px;color:#4E5A6B;margin-top:4px;}' +
    '.btn-prf-new{display:flex;align-items:center;gap:8px;' +
    '  background:linear-gradient(135deg,rgba(245,158,11,.2),rgba(232,82,10,.12));' +
    '  border:1px solid rgba(245,158,11,.4);border-radius:14px;' +
    '  padding:10px 20px;color:#FCD34D;font-size:13px;font-weight:700;' +
    '  cursor:pointer;transition:all .25s;letter-spacing:.3px;}' +
    '.btn-prf-new:hover{background:linear-gradient(135deg,rgba(245,158,11,.3),rgba(232,82,10,.18));' +
    '  box-shadow:0 0 20px rgba(245,158,11,.25);transform:translateY(-1px);}' +
    '.prf-table-wrap{background:linear-gradient(135deg,rgba(19,15,34,.9),rgba(28,23,48,.9));' +
    '  border:1px solid rgba(245,158,11,.1);border-radius:20px;overflow:hidden;' +
    '  box-shadow:0 8px 40px rgba(0,0,0,.4);}' +
    '.prf-table{width:100%;border-collapse:collapse;}' +
    '.prf-table thead th{padding:14px 20px;text-align:left;font-size:11px;font-weight:700;' +
    '  color:#4E5A6B;letter-spacing:1px;text-transform:uppercase;' +
    '  border-bottom:1px solid rgba(245,158,11,.1);background:rgba(245,158,11,.04);}' +
    '.prf-table thead th:last-child{text-align:right;}' +
    '.prf-row td{padding:16px 20px;font-size:13px;border-bottom:1px solid rgba(255,255,255,.03);}' +
    '.prf-row:last-child td{border-bottom:none;}' +
    '.prf-row:hover td{background:rgba(255,255,255,.02);}' +
    '.prf-row td:last-child{text-align:right;}' +
    '.prf-nome{font-weight:600;color:#CBD5E1;}' +
    '.prf-badge{display:inline-flex;align-items:center;gap:6px;' +
    '  background:rgba(245,158,11,.08);border:1px solid rgba(245,158,11,.2);' +
    '  border-radius:8px;padding:3px 10px;font-size:11px;color:#F59E0B;}' +
    '.prf-dot{width:6px;height:6px;border-radius:50%;background:#F59E0B;' +
    '  box-shadow:0 0 6px rgba(245,158,11,.6);}' +
    '.btn-edit{background:rgba(59,130,246,.08);border:1px solid rgba(59,130,246,.25);' +
    '  border-radius:10px;padding:6px 14px;color:#60A5FA;font-size:12px;font-weight:600;' +
    '  cursor:pointer;transition:all .2s;margin-right:8px;}' +
    '.btn-edit:hover{background:rgba(59,130,246,.15);box-shadow:0 0 12px rgba(59,130,246,.2);}' +
    '.btn-del{background:rgba(239,68,68,.08);border:1px solid rgba(239,68,68,.25);' +
    '  border-radius:10px;padding:6px 14px;color:#F87171;font-size:12px;font-weight:600;' +
    '  cursor:pointer;transition:all .2s;}' +
    '.btn-del:hover{background:rgba(239,68,68,.15);box-shadow:0 0 12px rgba(239,68,68,.2);}' +
    '.prf-empty{padding:60px 20px;text-align:center;color:#2E3A4A;font-size:14px;}' +
    '.prf-empty-ico{font-size:40px;margin-bottom:16px;opacity:.4;}' +
    '</style>';

  { Gera linhas da tabela }
  B := TStringBuilder.Create;
  try
    for P in AItems do
      B.AppendFormat(
        '<tr class="prf-row">' +
        '<td class="prf-nome">%s</td>' +
        '<td><span class="prf-badge"><span class="prf-dot"></span>%d permiss&otilde;es</span></td>' +
        '<td>' +
        '<button class="btn-edit" onclick="prfEdit(%d)">&#9998; Editar</button>' +
        '<button class="btn-del"  onclick="prfDel(%d)">&#10005; Excluir</button>' +
        '</td></tr>',
        [P.Nome, Length(P.Permissoes), P.ID, P.ID]);
    Rows := B.ToString;
  finally
    B.Free;
  end;

  { Conteúdo: tabela com dados ou estado vazio — sem IF }
  LBody[False] :=
    '<div class="prf-empty"><div class="prf-empty-ico">&#128101;</div>' +
    '<p>Nenhum perfil cadastrado.</p>' +
    '<p style="font-size:12px;margin-top:8px;color:#2E3A4A;">Clique em ' +
    '<b style="color:#F59E0B">+ Novo Perfil</b> para come&ccedil;ar.</p></div>';
  LBody[True] :=
    '<table class="prf-table">' +
    '<thead><tr><th>Nome</th><th>Permiss&otilde;es</th><th>A&ccedil;&otilde;es</th></tr></thead>' +
    '<tbody>' + Rows + '</tbody></table>';

  Result :=
    CSS +
    '<div class="prf-screen">' +
    '<div class="prf-hdr">' +
    '<div><div class="prf-title">Cadastro de Perfil</div>' +
    '<div class="prf-sub">Gerencie os perfis de acesso do sistema</div></div>' +
    '<button class="btn-prf-new" onclick="prfInsert()">&#43; Novo Perfil</button>' +
    '</div>' +
    '<div class="prf-table-wrap">' + LBody[Length(AItems) > 0] + '</div>' +
    '</div>';
end;

{ ══════════════════════════════════════════════════════════════
  BuildPerfilFormHtml — tela de cadastro/edição de perfil
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.BuildPerfilFormHtml(const ARec: TPerfilRec): string;
const
  GRP_IDS    : array[0..11] of string =
    ('grp-cad', 'grp-oper', 'grp-doc', 'grp-frota', 'grp-fin',
     'grp-com', 'grp-rh', 'grp-rastr', 'grp-rel', 'grp-int',
     'grp-cfg', 'grp-util');
  GRP_LABELS : array[0..11] of string =
    ('Cadastros', 'Operacional', 'Doc. Fiscais', 'Frota', 'Financeiro',
     'Fretes/Comercial', 'Motoristas/RH', 'Rastreamento',
     'Relat&oacute;rios', 'Integra&ccedil;&otilde;es',
     'Configura&ccedil;&otilde;es', 'Utilit&aacute;rios');
  GRP_COLORS : array[0..11] of string =
    ('#F59E0B', '#3B82F6', '#F97316', '#06B6D4', '#10B981',
     '#EAB308', '#6366F1', '#14B8A6', '#8B5CF6', '#EC4899',
     '#F43F5E', '#64748B');
type
  TDispArr  = array[Boolean] of string;
var
  B         : TStringBuilder;
  Cards     : TStringBuilder;
  G         : Integer;
  Item      : TMenuItemRec;
  LItems    : TArray<TMenuItemRec>;
  LTitle    : TDispArr;
  LChecked  : string;
  LDispArr  : TDispArr;
  LItemArr  : TDispArr;
  LHasPerm  : Boolean;
  LPermSet  : TDictionary<string, Boolean>;
  LPerm     : string;
  CSS       : string;
begin
  LItems := FMainCtrl.GetMenuItems;

  { Dicionário de permissões para lookup O(1) — sem IF }
  LPermSet := TDictionary<string, Boolean>.Create;
  try
    for LPerm in ARec.Permissoes do
      LPermSet.AddOrSetValue(LPerm, True);

    LTitle[False] := 'Novo Perfil';
    LTitle[True]  := 'Editar Perfil';

    CSS :=
      '<style>' +
      '.prf-screen{font-family:"Segoe UI",system-ui,sans-serif;color:#E2E8F0;animation:fuSlide .3s cubic-bezier(.22,1,.36,1);}' +
      '.prf-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:28px;flex-wrap:wrap;gap:12px;}' +
      '.prf-title{font-size:22px;font-weight:800;background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
      '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
      '.prf-form-acts{display:flex;gap:10px;}' +
      '.btn-cancel{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.1);' +
      '  border-radius:14px;padding:10px 20px;color:#64748B;font-size:13px;font-weight:600;cursor:pointer;transition:all .2s;}' +
      '.btn-cancel:hover{background:rgba(255,255,255,.08);color:#94A3B8;}' +
      '.btn-save{background:linear-gradient(135deg,rgba(245,158,11,.2),rgba(232,82,10,.12));' +
      '  border:1px solid rgba(245,158,11,.4);border-radius:14px;' +
      '  padding:10px 24px;color:#FCD34D;font-size:13px;font-weight:700;cursor:pointer;transition:all .25s;}' +
      '.btn-save:hover{background:linear-gradient(135deg,rgba(245,158,11,.3),rgba(232,82,10,.18));' +
      '  box-shadow:0 0 20px rgba(245,158,11,.25);}' +
      '.prf-field{margin-bottom:28px;}' +
      '.prf-label{font-size:11px;font-weight:700;color:#4E5A6B;letter-spacing:1px;' +
      '  text-transform:uppercase;margin-bottom:8px;display:block;}' +
      '.prf-input{width:100%;max-width:480px;background:rgba(255,255,255,.04);' +
      '  border:1px solid rgba(255,255,255,.08);border-radius:14px;' +
      '  padding:12px 18px;color:#E2E8F0;font-size:14px;font-family:inherit;outline:none;' +
      '  transition:all .25s;box-shadow:inset 0 1px 0 rgba(255,255,255,.04);}' +
      '.prf-input:focus{border-color:rgba(245,158,11,.4);' +
      '  box-shadow:0 0 0 3px rgba(245,158,11,.08),inset 0 1px 0 rgba(255,255,255,.04);}' +
      '.prf-input::placeholder{color:#2E3A4A;}' +
      '.prf-perm-title{font-size:13px;font-weight:700;color:#4E5A6B;' +
      '  letter-spacing:.5px;text-transform:uppercase;margin-bottom:16px;}' +
      '.prf-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;}' +
      '.prf-card{background:linear-gradient(135deg,rgba(19,15,34,.9),rgba(28,23,48,.9));' +
      '  border-radius:18px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.3);}' +
      '.prf-card-hdr{display:flex;align-items:center;gap:10px;padding:14px 18px;' +
      '  border-bottom:1px solid rgba(255,255,255,.05);}' +
      '.prf-card-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;}' +
      '.prf-card-lbl{font-size:12px;font-weight:800;letter-spacing:.5px;text-transform:uppercase;flex:1;}' +
      '.prf-chk-all{display:flex;align-items:center;gap:6px;cursor:pointer;' +
      '  font-size:10px;font-weight:700;color:rgba(255,255,255,.3);letter-spacing:.5px;' +
      '  text-transform:uppercase;padding:4px 8px;border-radius:8px;transition:all .15s;' +
      '  border:1px solid rgba(255,255,255,.08);}' +
      '.prf-chk-all:hover{color:rgba(255,255,255,.7);border-color:rgba(255,255,255,.2);}' +
      '.prf-chk-all input{display:none;}' +
      '.prf-chk-all .prf-chk-box{width:14px;height:14px;font-size:9px;}' +
      '.prf-chk-all input:checked~.prf-chk-box{background:var(--cc);box-shadow:0 0 8px var(--cc);border-color:transparent;}' +
      '.prf-chk-list{padding:12px 14px;display:flex;flex-direction:column;gap:4px;}' +
      '.prf-chk{display:flex;align-items:center;gap:10px;padding:7px 10px;' +
      '  border-radius:10px;cursor:pointer;transition:background .15s;}' +
      '.prf-chk:hover{background:rgba(255,255,255,.04);}' +
      '.prf-chk input[type=checkbox]{display:none;}' +
      '.prf-chk-box{width:18px;height:18px;border-radius:5px;flex-shrink:0;' +
      '  border:2px solid rgba(255,255,255,.1);transition:all .2s;' +
      '  display:flex;align-items:center;justify-content:center;font-size:11px;color:#000;}' +
      '.prf-chk input:checked~.prf-chk-box{border-color:transparent;}' +
      '.prf-chk-lbl{font-size:12.5px;color:#64748B;transition:color .15s;}' +
      '.prf-chk:hover .prf-chk-lbl{color:#94A3B8;}' +
      '.prf-chk input:checked~.prf-chk-lbl{color:#E2E8F0;}' +
      { CSS var --cc definida por card, usada nos checkboxes marcados }
      '.prf-chk input:checked~.prf-chk-box{background:var(--cc);' +
      '  box-shadow:0 0 10px var(--cc);border-color:transparent;}' +
      '</style>';

    { Gera cards por grupo }
    Cards := TStringBuilder.Create;
    try
      for G := 0 to 11 do
      begin
        { Verifica se grupo tem itens folha com Route }
        LHasPerm := False;
        for Item in LItems do
          LHasPerm := LHasPerm or
            ((Item.ParentID = GRP_IDS[G]) and (Item.Route <> ''));

        LDispArr[False] := 'display:none';
        LDispArr[True]  := 'display:block';

        Cards.AppendFormat(
          '<div class="prf-card" style="%s;border:1px solid %s30;--cc:%s">',
          [LDispArr[LHasPerm], GRP_COLORS[G], GRP_COLORS[G]]);
        Cards.AppendFormat(
          '<div class="prf-card-hdr">' +
          '<span class="prf-card-dot" style="background:%s;box-shadow:0 0 8px %s60"></span>' +
          '<span class="prf-card-lbl" style="color:%s">%s</span>' +
          '<label class="prf-chk-all" onclick="prfCheckAll(this)">' +
          '<input type="checkbox">' +
          '<span class="prf-chk-box">&#10003;</span>' +
          '<span>Todos</span>' +
          '</label>' +
          '</div><div class="prf-chk-list">',
          [GRP_COLORS[G], GRP_COLORS[G], GRP_COLORS[G], GRP_LABELS[G]]);

        for Item in LItems do
        begin
          LHasPerm := (Item.ParentID = GRP_IDS[G]) and (Item.Route <> '');
          LDispArr[False] := '';
          LDispArr[True]  := 'checked';
          LChecked := LDispArr[LPermSet.ContainsKey(Item.Route)];

          LItemArr[False] := '';
          LItemArr[True]  :=
            Format('<label class="prf-chk">' +
              '<input type="checkbox" value="%s" %s onchange="prfUpdateAllChk(this)">' +
              '<span class="prf-chk-box">&#10003;</span>' +
              '<span class="prf-chk-lbl">%s</span>' +
              '</label>',
              [Item.Route, LChecked, Item.Caption]);

          Cards.Append(LItemArr[LHasPerm]);
        end;

        Cards.Append('</div></div>');
      end;

      B := TStringBuilder.Create;
      try
        B.Append(CSS);
        B.Append('<div class="prf-screen">');
        B.Append('<div class="prf-hdr">');
        B.AppendFormat('<div class="prf-title">%s</div>', [LTitle[ARec.ID > 0]]);
        B.Append('<div class="prf-form-acts">');
        B.Append('<button class="btn-cancel" onclick="prfCancel()">Cancelar</button>');
        B.Append('<button class="btn-save" onclick="prfSave()">&#10003; Salvar</button>');
        B.Append('</div></div>');
        B.AppendFormat('<input type="hidden" id="prf-id" value="%d">', [ARec.ID]);
        B.Append('<div class="prf-field">');
        B.Append('<label class="prf-label" for="prf-nome">Nome do Perfil</label>');
        B.AppendFormat(
          '<input id="prf-nome" class="prf-input" type="text" ' +
          'placeholder="Ex: Operador de fretes" value="%s">',
          [ARec.Nome]);
        B.Append('</div>');
        B.Append('<div class="prf-perm-title">Permiss&otilde;es de Acesso</div>');
        B.Append('<div class="prf-grid">');
        B.Append(Cards.ToString);
        B.Append('</div>');
        B.Append('</div>');
        Result := B.ToString;
      finally
        B.Free;
      end;
    finally
      Cards.Free;
    end;
  finally
    LPermSet.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  Injeção de HTML de usuário no #screen via cacheScreen JS
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.InjectUsuarioList(const AItems: TArray<TUsuarioRec>;
  const APerfis: TArray<TPerfilRec>);
var
  LHtml : string;
  LJson : TJSONString;
begin
  LHtml := BuildUsuarioListHtml(AItems, APerfis);
  LJson := TJSONString.Create(LHtml);
  try
    UniSession.AddJS(
      'cacheScreen("cfg.usuario",' + LJson.ToString + ');' +
      'renderScr("cfg.usuario","Cadastro de Usu\u00E1rio");');
  finally
    LJson.Free;
  end;
end;

procedure TFrmLogin.InjectUsuarioForm(const ARec: TUsuarioRec;
  const APerfis: TArray<TPerfilRec>);
const
  TITLES: array[Boolean] of string = ('Novo Usu\u00E1rio', 'Editar Usu\u00E1rio');
var
  LHtml : string;
  LJson : TJSONString;
begin
  LHtml := BuildUsuarioFormHtml(ARec, APerfis);
  LJson := TJSONString.Create(LHtml);
  try
    UniSession.AddJS(
      'cacheScreen("cfg.usuario",' + LJson.ToString + ');' +
      'renderScr("cfg.usuario",' + QuotedStr(TITLES[ARec.ID > 0]) + ');');
  finally
    LJson.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  BuildUsuarioListHtml
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.BuildUsuarioListHtml(const AItems: TArray<TUsuarioRec>;
  const APerfis: TArray<TPerfilRec>): string;
type
  TBodyArr = array[Boolean] of string;
var
  CSS     : string;
  LRows   : TStringBuilder;
  LBody   : TBodyArr;
  LPerfis : TDictionary<Integer, string>;
  Item    : TUsuarioRec;
  Perfil  : TPerfilRec;
  LAdmBdg : string;
  LPrfNm  : string;
begin
  { Monta dicionário id→nome de perfil para lookup O(1) }
  LPerfis := TDictionary<Integer, string>.Create;
  try
    for Perfil in APerfis do
      LPerfis.AddOrSetValue(Perfil.ID, Perfil.Nome);

    CSS :=
      '<style>' +
      '.usr-screen{font-family:"Segoe UI",system-ui,sans-serif;color:#E2E8F0;}' +
      '.usr-hdr{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:28px;}' +
      '.usr-title{font-size:22px;font-weight:800;background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
      '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
      '.usr-sub{font-size:12px;color:rgba(245,158,11,.6);margin-top:4px;}' +
      '.btn-usr-new{display:flex;align-items:center;gap:8px;' +
      '  background:linear-gradient(135deg,rgba(245,158,11,.2),rgba(232,82,10,.12));' +
      '  border:1px solid rgba(245,158,11,.25);border-radius:12px;' +
      '  color:#F59E0B;font-size:12px;font-weight:700;padding:10px 18px;' +
      '  cursor:pointer;letter-spacing:.3px;transition:all .25s;}' +
      '.btn-usr-new:hover{box-shadow:0 0 20px rgba(245,158,11,.25);transform:translateY(-1px);}' +
      '.usr-table-wrap{background:linear-gradient(135deg,rgba(19,15,34,.9),rgba(28,23,48,.9));' +
      '  border:1px solid rgba(245,158,11,.1);border-radius:20px;overflow:hidden;' +
      '  box-shadow:0 8px 40px rgba(0,0,0,.4);}' +
      '.usr-table{width:100%;border-collapse:collapse;}' +
      '.usr-table thead th{padding:14px 20px;text-align:left;font-size:11px;font-weight:700;' +
      '  color:#F59E0B;letter-spacing:1px;text-transform:uppercase;' +
      '  border-bottom:1px solid rgba(245,158,11,.1);background:rgba(245,158,11,.04);}' +
      '.usr-table thead th:last-child{text-align:right;}' +
      '.usr-row td{padding:16px 20px;font-size:13px;border-bottom:1px solid rgba(255,255,255,.03);}' +
      '.usr-row td:last-child{text-align:right;}' +
      '.usr-row:last-child td{border-bottom:none;}' +
      '.usr-row:hover td{background:rgba(255,255,255,.02);}' +
      '.usr-login{font-weight:600;color:#FCD34D;}' +
      '.badge-admin{display:inline-flex;align-items:center;gap:5px;' +
      '  background:rgba(245,158,11,.12);border:1px solid rgba(245,158,11,.3);' +
      '  border-radius:8px;padding:3px 10px;font-size:11px;color:#F59E0B;font-weight:700;}' +
      '.badge-user{display:inline-flex;align-items:center;gap:5px;' +
      '  background:rgba(245,158,11,.05);border:1px solid rgba(245,158,11,.15);' +
      '  border-radius:8px;padding:3px 10px;font-size:11px;color:rgba(245,158,11,.6);}' +
      '.prf-tag{display:inline-block;background:rgba(245,158,11,.07);' +
      '  border:1px solid rgba(245,158,11,.2);border-radius:8px;' +
      '  padding:3px 10px;font-size:11px;color:#F59E0B;}' +
      '.btn-edit{background:rgba(245,158,11,.08);border:1px solid rgba(245,158,11,.2);' +
      '  border-radius:8px;padding:6px 14px;font-size:12px;color:#F59E0B;' +
      '  cursor:pointer;margin-right:8px;transition:all .2s;}' +
      '.btn-edit:hover{background:rgba(245,158,11,.15);box-shadow:0 0 12px rgba(245,158,11,.2);}' +
      '.btn-del{background:rgba(239,68,68,.06);border:1px solid rgba(239,68,68,.2);' +
      '  border-radius:8px;padding:6px 14px;font-size:12px;color:#EF4444;' +
      '  cursor:pointer;transition:all .2s;}' +
      '.btn-del:hover{background:rgba(239,68,68,.15);box-shadow:0 0 12px rgba(239,68,68,.2);}' +
      '.usr-empty{padding:60px 20px;text-align:center;color:rgba(245,158,11,.4);font-size:14px;}' +
      '</style>';

    LRows := TStringBuilder.Create;
    try
      for Item in AItems do
      begin
        LAdmBdg := '<span class="badge-admin">&#9733; Admin</span>';
        LPrfNm  := '';
        LPerfis.TryGetValue(Item.PerfilID, LPrfNm);

        LRows.AppendFormat(
          '<tr class="usr-row">' +
          '<td class="usr-login">%s</td>' +
          '<td>%s</td>' +
          '<td>%s</td>' +
          '<td>' +
          '<button class="btn-edit" onclick="usrEdit(%d)">&#9998; Editar</button>' +
          '<button class="btn-del"  onclick="usrDel(%d)">&#10005; Excluir</button>' +
          '</td></tr>',
          [Item.Login,
           IfThen(Item.IsAdmin, LAdmBdg, '<span class="badge-user">Usu&aacute;rio</span>'),
           IfThen(LPrfNm <> '', '<span class="prf-tag">' + LPrfNm + '</span>', '&mdash;'),
           Item.ID, Item.ID]);
      end;

      LBody[False] :=
        '<div class="usr-empty"><p>Nenhum usu&aacute;rio cadastrado.</p></div>';
      LBody[True] :=
        '<table class="usr-table">' +
        '<thead><tr>' +
        '<th>Login</th><th>Tipo</th><th>Perfil</th><th>A&ccedil;&otilde;es</th>' +
        '</tr></thead><tbody>' + LRows.ToString + '</tbody></table>';

      Result :=
        CSS +
        '<div class="usr-screen">' +
        '<div class="usr-hdr">' +
        '<div><div class="usr-title">Cadastro de Usu&aacute;rio</div>' +
        '<div class="usr-sub">Gerencie os usu&aacute;rios do sistema</div></div>' +
        '<button class="btn-usr-new" onclick="usrInsert()">&#43; Novo Usu&aacute;rio</button>' +
        '</div>' +
        '<div class="usr-table-wrap">' + LBody[Length(AItems) > 0] + '</div>' +
        '</div>';
    finally
      LRows.Free;
    end;
  finally
    LPerfis.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  BuildUsuarioFormHtml
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.BuildUsuarioFormHtml(const ARec: TUsuarioRec;
  const APerfis: TArray<TPerfilRec>): string;
const
  GRP_IDS    : array[0..11] of string =
    ('grp-cad', 'grp-oper', 'grp-doc', 'grp-frota', 'grp-fin',
     'grp-com', 'grp-rh', 'grp-rastr', 'grp-rel', 'grp-int',
     'grp-cfg', 'grp-util');
  GRP_LABELS : array[0..11] of string =
    ('Cadastros', 'Operacional', 'Doc. Fiscais', 'Frota', 'Financeiro',
     'Fretes/Comercial', 'Motoristas/RH', 'Rastreamento',
     'Relat&oacute;rios', 'Integra&ccedil;&otilde;es',
     'Configura&ccedil;&otilde;es', 'Utilit&aacute;rios');
  GRP_COLORS : array[0..11] of string =
    ('#F59E0B', '#3B82F6', '#F97316', '#06B6D4', '#10B981',
     '#EAB308', '#6366F1', '#14B8A6', '#8B5CF6', '#EC4899',
     '#F43F5E', '#64748B');
type
  TDispArr  = array[Boolean] of string;
var
  B            : TStringBuilder;
  Cards        : TStringBuilder;
  CSS          : string;
  LTitle       : TDispArr;
  LAdmChk      : TDispArr;
  LOptStr      : TStringBuilder;
  Perfil       : TPerfilRec;
  LSel         : TDispArr;
  G            : Integer;
  MenuItem     : TMenuItemRec;
  LItems       : TArray<TMenuItemRec>;
  LHasPerm     : Boolean;
  LPermSet     : TDictionary<string, Boolean>;
  LPerfilPerms : TDictionary<Integer, TArray<string>>;
  LFoundPerms  : TArray<string>;
  LPerm        : string;
  LChecked     : string;
  LItemArr     : TDispArr;
  LDispArr     : TDispArr;
begin
  LTitle[False] := 'Novo Usu&aacute;rio';
  LTitle[True]  := 'Editar Usu&aacute;rio';

  LAdmChk[False] := '';
  LAdmChk[True]  := 'checked';

  CSS :=
    '<style>' +
    '.usr-form{font-family:"Segoe UI",system-ui,sans-serif;color:#E2E8F0;max-width:980px;margin:0 auto;}' +
    '.usr-form-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:28px;}' +
    '.usr-form-title{font-size:22px;font-weight:800;background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
    '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
    '.usr-form-acts{display:flex;gap:12px;}' +
    '.btn-cancel{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.1);' +
    '  border-radius:10px;padding:9px 20px;font-size:12px;color:#64748B;' +
    '  cursor:pointer;font-weight:600;transition:all .2s;}' +
    '.btn-cancel:hover{border-color:rgba(255,255,255,.2);color:#94A3B8;}' +
    '.btn-save{background:linear-gradient(135deg,rgba(245,158,11,.25),rgba(232,82,10,.15));' +
    '  border:1px solid rgba(245,158,11,.35);border-radius:10px;' +
    '  padding:9px 20px;font-size:12px;color:#F59E0B;cursor:pointer;font-weight:700;transition:all .2s;}' +
    '.btn-save:hover{box-shadow:0 0 20px rgba(245,158,11,.3);}' +
    { Layout 2 colunas para campos + card admin }
    '.usr-cols{display:grid;grid-template-columns:1fr 1fr;gap:24px;margin-bottom:32px;align-items:start;}' +
    '.usr-col{display:flex;flex-direction:column;gap:16px;}' +
    '.usr-row{display:grid;grid-template-columns:1fr 1fr;gap:16px;}' +
    { Card de admin — sem margin-bottom pois está dentro de coluna }
    '.usr-admin-card{display:flex;align-items:center;justify-content:space-between;' +
    '  background:linear-gradient(135deg,rgba(245,158,11,.06),rgba(232,82,10,.04));' +
    '  border:1px solid rgba(245,158,11,.2);border-radius:16px;padding:20px 24px;' +
    '  cursor:pointer;transition:all .25s;}' +
    '.usr-admin-card:hover{border-color:rgba(245,158,11,.4);box-shadow:0 0 24px rgba(245,158,11,.1);}' +
    '.usr-admin-lbl{font-size:14px;font-weight:700;color:#FCD34D;margin-bottom:4px;}' +
    '.usr-admin-desc{font-size:12px;color:rgba(245,158,11,.6);}' +
    { Toggle switch }
    '.usr-toggle{position:relative;width:48px;height:26px;flex-shrink:0;}' +
    '.usr-toggle input{display:none;}' +
    '.usr-toggle-track{position:absolute;inset:0;border-radius:13px;' +
    '  background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1);transition:all .25s;cursor:pointer;}' +
    '.usr-toggle input:checked~.usr-toggle-track{background:rgba(245,158,11,.35);' +
    '  border-color:rgba(245,158,11,.5);box-shadow:0 0 12px rgba(245,158,11,.3);}' +
    '.usr-toggle-thumb{position:absolute;top:3px;left:3px;width:18px;height:18px;' +
    '  border-radius:50%;background:rgba(245,158,11,.35);transition:all .25s;pointer-events:none;}' +
    '.usr-toggle input:checked~.usr-toggle-thumb{left:27px;background:#F59E0B;box-shadow:0 0 8px rgba(245,158,11,.6);}' +
    { Campos }
    '.usr-field{display:flex;flex-direction:column;gap:8px;}' +
    '.usr-label{font-size:11px;font-weight:700;color:#F59E0B;letter-spacing:1px;text-transform:uppercase;}' +
    '.usr-input{width:100%;background:rgba(255,255,255,.04);border:1px solid rgba(245,158,11,.15);' +
    '  border-radius:12px;padding:12px 16px;font-size:14px;color:#FCD34D;' +
    '  font-family:"Segoe UI",system-ui,sans-serif;outline:none;transition:border-color .2s,box-shadow .2s;}' +
    '.usr-input::placeholder{color:rgba(245,158,11,.3);}' +
    '.usr-input:focus{border-color:rgba(245,158,11,.5);box-shadow:0 0 0 3px rgba(245,158,11,.1);}' +
    '.usr-select{width:100%;background:rgba(255,255,255,.04);border:1px solid rgba(245,158,11,.15);' +
    '  border-radius:12px;padding:12px 16px;font-size:14px;color:#FCD34D;' +
    '  font-family:"Segoe UI",system-ui,sans-serif;outline:none;cursor:pointer;transition:border-color .2s;}' +
    '.usr-select:focus{border-color:rgba(245,158,11,.5);}' +
    '.usr-select option{background:#130F22;color:#FCD34D;}' +
    '.usr-col-section{font-size:10px;font-weight:800;color:rgba(245,158,11,.5);' +
    '  letter-spacing:2px;text-transform:uppercase;padding-bottom:6px;' +
    '  border-bottom:1px solid rgba(245,158,11,.08);}' +
    { Seção de permissões centralizada }
    '.usr-perm-wrap{margin-top:4px;}' +
    '.usr-perm-hdr{font-size:11px;font-weight:700;color:#F59E0B;letter-spacing:1.5px;' +
    '  text-transform:uppercase;margin-bottom:8px;padding-bottom:8px;' +
    '  border-bottom:1px solid rgba(245,158,11,.1);}' +
    '.usr-perm-note{font-size:12px;color:rgba(245,158,11,.45);margin-bottom:20px;font-style:italic;}' +
    { Grid de cards centralizado }
    '.prf-grid{display:flex;flex-wrap:wrap;justify-content:center;gap:16px;}' +
    '.prf-card{width:240px;background:linear-gradient(135deg,rgba(19,15,34,.9),rgba(28,23,48,.9));' +
    '  border-radius:18px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.3);}' +
    '.prf-card-hdr{display:flex;align-items:center;gap:10px;padding:14px 18px;' +
    '  border-bottom:1px solid rgba(255,255,255,.05);}' +
    '.prf-card-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;}' +
    '.prf-card-lbl{font-size:12px;font-weight:800;letter-spacing:.5px;text-transform:uppercase;}' +
    '.prf-chk-list{padding:12px 14px;display:flex;flex-direction:column;gap:4px;}' +
    '.prf-chk{display:flex;align-items:center;gap:10px;padding:7px 10px;border-radius:10px;cursor:default;}' +
    '.prf-chk input[type=checkbox]{display:none;}' +
    '.prf-chk-box{width:18px;height:18px;border-radius:5px;flex-shrink:0;' +
    '  border:2px solid rgba(255,255,255,.1);transition:all .2s;' +
    '  display:flex;align-items:center;justify-content:center;font-size:11px;color:#000;}' +
    '.prf-chk input:checked~.prf-chk-box{border-color:transparent;background:var(--cc);box-shadow:0 0 10px var(--cc);}' +
    '.prf-chk-lbl{font-size:12.5px;color:#64748B;}' +
    '.prf-chk input:checked~.prf-chk-lbl{color:#E2E8F0;}' +
    '</style>';

  { Monta opções do select de perfil e coleta permissões do perfil vinculado }
  LOptStr      := TStringBuilder.Create;
  LPermSet     := TDictionary<string, Boolean>.Create;
  LPerfilPerms := TDictionary<Integer, TArray<string>>.Create;
  Cards        := TStringBuilder.Create;
  try
    LOptStr.Append('<option value="0">-- Sem perfil --</option>');
    for Perfil in APerfis do
    begin
      LSel[False] := '';
      LSel[True]  := ' selected';
      LOptStr.AppendFormat('<option value="%d"%s>%s</option>',
        [Perfil.ID, LSel[ARec.PerfilID = Perfil.ID], Perfil.Nome]);
      LPerfilPerms.AddOrSetValue(Perfil.ID, Perfil.Permissoes);
    end;

    { Permissões do perfil vinculado ao usuário }
    LItems := FMainCtrl.GetMenuItems;
    LFoundPerms := [];
    LPerfilPerms.TryGetValue(ARec.PerfilID, LFoundPerms);
    for LPerm in LFoundPerms do
      LPermSet.AddOrSetValue(LPerm, True);

    { Gera cards de permissão por grupo }
    for G := 0 to 11 do
    begin
      LHasPerm := False;
      for MenuItem in LItems do
        LHasPerm := LHasPerm or
          ((MenuItem.ParentID = GRP_IDS[G]) and (MenuItem.Route <> ''));

      LDispArr[False] := 'display:none';
      LDispArr[True]  := 'display:block';

      Cards.AppendFormat(
        '<div class="prf-card" style="%s;border:1px solid %s30;--cc:%s">',
        [LDispArr[LHasPerm], GRP_COLORS[G], GRP_COLORS[G]]);
      Cards.AppendFormat(
        '<div class="prf-card-hdr">' +
        '<span class="prf-card-dot" style="background:%s;box-shadow:0 0 8px %s60"></span>' +
        '<span class="prf-card-lbl" style="color:%s">%s</span>' +
        '</div><div class="prf-chk-list">',
        [GRP_COLORS[G], GRP_COLORS[G], GRP_COLORS[G], GRP_LABELS[G]]);

      for MenuItem in LItems do
      begin
        LHasPerm := (MenuItem.ParentID = GRP_IDS[G]) and (MenuItem.Route <> '');
        LDispArr[False] := '';
        LDispArr[True]  := 'checked';
        LChecked := LDispArr[LPermSet.ContainsKey(MenuItem.Route)];

        LItemArr[False] := '';
        LItemArr[True]  :=
          Format('<label class="prf-chk">' +
            '<input type="checkbox" value="%s" %s disabled>' +
            '<span class="prf-chk-box">&#10003;</span>' +
            '<span class="prf-chk-lbl">%s</span>' +
            '</label>',
            [MenuItem.Route, LChecked, MenuItem.Caption]);

        Cards.Append(LItemArr[LHasPerm]);
      end;

      Cards.Append('</div></div>');
    end;

    B := TStringBuilder.Create;
    try
      B.Append(CSS);
      B.Append('<div class="usr-form">');

      { Cabeçalho }
      B.Append('<div class="usr-form-hdr">');
      B.AppendFormat('<div class="usr-form-title">%s</div>', [LTitle[ARec.ID > 0]]);
      B.Append('<div class="usr-form-acts">');
      B.Append('<button class="btn-cancel" onclick="usrCancel()">Cancelar</button>');
      B.Append('<button class="btn-save"   onclick="usrSave()">&#10003; Salvar</button>');
      B.Append('</div></div>');
      B.AppendFormat('<input type="hidden" id="usr-id" value="%d">', [ARec.ID]);

      { Layout 2 colunas }
      B.Append('<div class="usr-cols">');

      { Coluna esquerda: Login + Senha + Perfil }
      B.Append('<div class="usr-col">');
      B.Append('<div class="usr-col-section">Credenciais de Acesso</div>');
      B.Append('<div class="usr-field">');
      B.Append('<label class="usr-label" for="usr-login">Login de Usu&aacute;rio</label>');
      B.AppendFormat(
        '<input id="usr-login" class="usr-input" type="text" ' +
        'placeholder="Ex: joao.silva" autocomplete="off" value="%s">',
        [ARec.Login]);
      B.Append('</div>');
      B.Append('<div class="usr-row">');
      B.Append('<div class="usr-field">');
      B.Append('<label class="usr-label" for="usr-senha">Senha</label>');
      B.AppendFormat(
        '<input id="usr-senha" class="usr-input" type="password" ' +
        'placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;" ' +
        'autocomplete="new-password" value="%s">',
        [ARec.Senha]);
      B.Append('</div>');
      B.Append('<div class="usr-field">');
      B.Append('<label class="usr-label" for="usr-perfil">Perfil vinculado</label>');
      B.AppendFormat('<select id="usr-perfil" class="usr-select">%s</select>',
        [LOptStr.ToString]);
      B.Append('</div>');
      B.Append('</div>');
      B.Append('</div>');

      { Coluna direita: Card de Administrador }
      B.Append('<div class="usr-col">');
      B.Append('<div class="usr-col-section">N&iacute;vel de Acesso</div>');
      B.Append('<label class="usr-admin-card" for="usr-admin">');
      B.Append('<div class="usr-admin-info">');
      B.Append('<div class="usr-admin-lbl">&#9733; Administrador do Sistema</div>');
      B.Append('<div class="usr-admin-desc">Acesso irrestrito a todos os m&oacute;dulos</div>');
      B.Append('</div>');
      B.Append('<div class="usr-toggle">');
      B.AppendFormat('<input type="checkbox" id="usr-admin" %s>', [LAdmChk[ARec.IsAdmin]]);
      B.Append('<div class="usr-toggle-track"></div>');
      B.Append('<div class="usr-toggle-thumb"></div>');
      B.Append('</div></label>');
      B.Append('</div>');

      B.Append('</div>'); { /usr-cols }

      { Cards de permissão centralizados }
      B.Append('<div class="usr-perm-wrap">');
      B.Append('<div class="usr-perm-hdr">Permiss&otilde;es de Acesso (via Perfil)</div>');
      B.Append('<div class="usr-perm-note">&#128274; Somente leitura &mdash; herdadas do perfil vinculado. Gerencie em Cadastro de Perfil</div>');
      B.Append('<div class="prf-grid">');
      B.Append(Cards.ToString);
      B.Append('</div></div>');

      B.Append('</div>');
      Result := B.ToString;
    finally
      B.Free;
    end;
  finally
    Cards.Free;
    LPerfilPerms.Free;
    LPermSet.Free;
    LOptStr.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  Injeção de HTML de permissões no #screen
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.InjectPermForm(const ARec      : TPermissoesRec;
  const AUsuarios : TArray<TUsuarioRec>; const AItems : TArray<TMenuItemRec>);
var
  LHtml : string;
  LJson : TJSONString;
begin
  LHtml := BuildPermFormHtml(ARec, AUsuarios, AItems);
  LJson := TJSONString.Create(LHtml);
  try
    UniSession.AddJS(
      'cacheScreen("cfg.permissoes",' + LJson.ToString + ');' +
      'renderScr("cfg.permissoes","Permiss\u00F5es de Usu\u00E1rios");' +
      'permInitAllChk();');
  finally
    LJson.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  BuildPermFormHtml — tela única: seletor de usuário + cards
  ══════════════════════════════════════════════════════════════ }

function TFrmLogin.BuildPermFormHtml(const ARec      : TPermissoesRec;
  const AUsuarios : TArray<TUsuarioRec>;
  const AItems    : TArray<TMenuItemRec>): string;
const
  GRP_IDS    : array[0..11] of string =
    ('grp-cad', 'grp-oper', 'grp-doc', 'grp-frota', 'grp-fin',
     'grp-com', 'grp-rh', 'grp-rastr', 'grp-rel', 'grp-int',
     'grp-cfg', 'grp-util');
  GRP_LABELS : array[0..11] of string =
    ('Cadastros', 'Operacional', 'Doc. Fiscais', 'Frota', 'Financeiro',
     'Fretes/Comercial', 'Motoristas/RH', 'Rastreamento',
     'Relat&oacute;rios', 'Integra&ccedil;&otilde;es',
     'Configura&ccedil;&otilde;es', 'Utilit&aacute;rios');
  GRP_COLORS : array[0..11] of string =
    ('#F59E0B', '#3B82F6', '#F97316', '#06B6D4', '#10B981',
     '#EAB308', '#6366F1', '#14B8A6', '#8B5CF6', '#EC4899',
     '#F43F5E', '#64748B');
type
  TDispArr = array[Boolean] of string;
  THasArr  = array[Boolean] of string;
var
  B        : TStringBuilder;
  Cards    : TStringBuilder;
  SelOpts  : TStringBuilder;
  CSS      : string;
  G        : Integer;
  Item     : TMenuItemRec;
  Usu      : TUsuarioRec;
  LPermSet : TDictionary<string, Boolean>;
  LDispArr : TDispArr;
  LChecked : string;
  LHasPerm : Boolean;
  LItemArr : THasArr;
  LSel     : TDispArr;
  LHasUsr  : TDispArr;
  LCardsBlock : string;
begin
  LPermSet := TDictionary<string, Boolean>.Create;
  try
    for var P in ARec.Permissoes do
      LPermSet.AddOrSetValue(P, True);

    CSS :=
      '<style>' +
      '.prm-screen{font-family:"Segoe UI",system-ui,sans-serif;color:#E2E8F0;}' +
      '.prm-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;}' +
      '.prm-title{font-size:22px;font-weight:800;background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
      '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
      '.prm-sub{font-size:12px;color:rgba(245,158,11,.6);margin-top:4px;}' +
      { Seletor de usuário }
      '.prm-sel-wrap{background:linear-gradient(135deg,rgba(19,15,34,.9),rgba(28,23,48,.9));' +
      '  border:1px solid rgba(245,158,11,.15);border-radius:16px;' +
      '  padding:20px 24px;margin-bottom:28px;display:flex;align-items:center;gap:16px;}' +
      '.prm-sel-lbl{font-size:11px;font-weight:700;color:#F59E0B;' +
      '  letter-spacing:1px;text-transform:uppercase;white-space:nowrap;}' +
      '.prm-sel{flex:1;background:rgba(255,255,255,.04);' +
      '  border:1px solid rgba(245,158,11,.2);border-radius:10px;' +
      '  padding:10px 14px;font-size:14px;color:#FCD34D;' +
      '  font-family:"Segoe UI",system-ui,sans-serif;outline:none;cursor:pointer;}' +
      '.prm-sel:focus{border-color:rgba(245,158,11,.5);}' +
      '.prm-sel option{background:#130F22;color:#FCD34D;}' +
      '.btn-save-perm{background:linear-gradient(135deg,rgba(245,158,11,.25),rgba(232,82,10,.15));' +
      '  border:1px solid rgba(245,158,11,.35);border-radius:10px;' +
      '  padding:10px 22px;font-size:12px;color:#F59E0B;' +
      '  cursor:pointer;font-weight:700;transition:all .2s;white-space:nowrap;}' +
      '.btn-save-perm:hover{box-shadow:0 0 20px rgba(245,158,11,.3);}' +
      '.btn-save-perm:disabled{opacity:.3;cursor:not-allowed;}' +
      { Hint quando nenhum usuário selecionado }
      '.prm-hint{padding:48px;text-align:center;color:rgba(245,158,11,.35);font-size:14px;}' +
      { Cards }
      '.prm-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;}' +
      '.prm-card{background:linear-gradient(135deg,rgba(19,15,34,.95),rgba(28,23,48,.95));' +
      '  border-radius:16px;padding:20px;border:1px solid rgba(255,255,255,.06);' +
      '  box-shadow:0 4px 24px rgba(0,0,0,.3);}' +
      '.prm-card-hdr{display:flex;align-items:center;gap:10px;margin-bottom:16px;' +
      '  padding-bottom:12px;border-bottom:1px solid rgba(255,255,255,.05);}' +
      '.prm-card-dot{width:8px;height:8px;border-radius:50%;background:var(--cc);' +
      '  box-shadow:0 0 8px var(--cc);flex-shrink:0;}' +
      '.prm-card-lbl{font-size:11px;font-weight:800;letter-spacing:1.2px;' +
      '  text-transform:uppercase;color:var(--cc);flex:1;}' +
      '.prm-chk-all{display:flex;align-items:center;gap:5px;cursor:pointer;' +
      '  font-size:10px;font-weight:700;color:rgba(255,255,255,.3);letter-spacing:.5px;' +
      '  text-transform:uppercase;padding:3px 7px;border-radius:7px;transition:all .15s;' +
      '  border:1px solid rgba(255,255,255,.08);}' +
      '.prm-chk-all:hover{color:rgba(255,255,255,.7);border-color:rgba(255,255,255,.2);}' +
      '.prm-chk-all input{display:none;}' +
      '.prm-chk-all .prm-chk-box{width:14px;height:14px;font-size:9px;}' +
      '.prm-chk-all input:checked~.prm-chk-box{background:var(--cc);border-color:var(--cc);color:#fff;box-shadow:0 0 8px var(--cc);}' +
      '.prm-chk-list{display:flex;flex-direction:column;gap:10px;}' +
      '.prm-chk{display:flex;align-items:center;gap:10px;cursor:pointer;' +
      '  padding:6px 8px;border-radius:8px;transition:background .15s;}' +
      '.prm-chk:hover{background:rgba(255,255,255,.04);}' +
      '.prm-chk input{display:none;}' +
      '.prm-chk-box{width:18px;height:18px;border-radius:5px;flex-shrink:0;' +
      '  border:2px solid rgba(255,255,255,.12);display:flex;align-items:center;' +
      '  justify-content:center;font-size:11px;color:transparent;transition:all .2s;}' +
      '.prm-chk input:checked~.prm-chk-box{' +
      '  background:var(--cc);border-color:var(--cc);color:#fff;box-shadow:0 0 10px var(--cc);}' +
      '.prm-chk-lbl{font-size:13px;color:#CBD5E1;transition:color .15s;}' +
      '.prm-chk input:checked~.prm-chk-lbl{color:#E2E8F0;font-weight:600;}' +
      '</style>';

    { Opções do select }
    SelOpts := TStringBuilder.Create;
    try
      SelOpts.Append('<option value="0">-- Selecione um usu&aacute;rio --</option>');
      for Usu in AUsuarios do
      begin
        LSel[False] := '';
        LSel[True]  := ' selected';
        SelOpts.AppendFormat('<option value="%d"%s>%s</option>',
          [Usu.ID, LSel[ARec.UsuarioID = Usu.ID], Usu.Login]);
      end;

      { Cards de permissão }
      Cards := TStringBuilder.Create;
      try
        for G := 0 to 11 do
        begin
          Cards.AppendFormat(
            '<div class="prm-card" style="--cc:%s">' +
            '<div class="prm-card-hdr">' +
            '<div class="prm-card-dot"></div>' +
            '<span class="prm-card-lbl">%s</span>' +
            '<label class="prm-chk-all" onclick="permCheckAll(this)">' +
            '<input type="checkbox">' +
            '<span class="prm-chk-box">&#10003;</span>' +
            '<span>Todos</span>' +
            '</label>' +
            '</div><div class="prm-chk-list">',
            [GRP_COLORS[G], GRP_LABELS[G]]);

          for Item in AItems do
          begin
            LHasPerm := (Item.ParentID = GRP_IDS[G]) and (Item.Route <> '');
            LDispArr[False] := '';
            LDispArr[True]  := 'checked';
            LChecked := LDispArr[LPermSet.ContainsKey(Item.Route)];

            LItemArr[False] := '';
            LItemArr[True]  :=
              Format('<label class="prm-chk">' +
                '<input type="checkbox" value="%s" %s onchange="permUpdateAllChk(this)">' +
                '<span class="prm-chk-box">&#10003;</span>' +
                '<span class="prm-chk-lbl">%s</span>' +
                '</label>',
                [Item.Route, LChecked, Item.Caption]);

            Cards.Append(LItemArr[LHasPerm]);
          end;
          Cards.Append('</div></div>');
        end;

        { Bloco de cards: só aparece quando há usuário selecionado }
        LHasUsr[False] :=
          '<div class="prm-hint">&#8593; Selecione um usu&aacute;rio acima para definir as permiss&otilde;es</div>';
        LHasUsr[True] :=
          '<div class="prm-grid">' + Cards.ToString + '</div>';
        LCardsBlock := LHasUsr[ARec.UsuarioID > 0];

        B := TStringBuilder.Create;
        try
          B.Append(CSS);
          B.AppendFormat('<input type="hidden" id="perm-uid" value="%d">', [ARec.UsuarioID]);
          B.Append('<div class="prm-screen">');
          B.Append('<div class="prm-hdr">');
          B.Append('<div><div class="prm-title">Permiss&otilde;es de Usu&aacute;rios</div>');
          B.Append('<div class="prm-sub">Selecione o usu&aacute;rio e marque as telas permitidas</div></div>');
          B.Append('</div>');
          { Seletor }
          B.Append('<div class="prm-sel-wrap">');
          B.Append('<span class="prm-sel-lbl">Usu&aacute;rio</span>');
          B.AppendFormat('<select class="prm-sel" onchange="permSelect(this.value)">%s</select>',
            [SelOpts.ToString]);
          B.AppendFormat('<button class="btn-save-perm" onclick="permSave()" %s>&#10003; Salvar</button>',
            [IfThen(ARec.UsuarioID = 0, 'disabled', '')]);
          B.Append('</div>');
          { Cards ou hint }
          B.Append(LCardsBlock);
          B.Append('</div>');
          Result := B.ToString;
        finally
          B.Free;
        end;
      finally
        Cards.Free;
      end;
    finally
      SelOpts.Free;
    end;
  finally
    LPermSet.Free;
  end;
end;

{ ══════════════════════════════════════════════════════════════
  BuildScreenActionsHtml — tela de permissões de ações
  ══════════════════════════════════════════════════════════════ }

procedure TFrmLogin.InjectScreenActions(const AScreens: TArray<string>;
  const AUsuarios: TArray<string>; const ASelectedUserID: Integer);
var
  LHtml : string;
  LJson : TJSONString;
begin
  LHtml := BuildScreenActionsHtml(AScreens, AUsuarios, ASelectedUserID);
  LJson := TJSONString.Create(LHtml);
  try
    UniSession.AddJS(
      'cacheScreen("cfg.acoes",' + LJson.ToString + ');' +
      'renderScr("cfg.acoes","Permiss\u00F5es de A\u00E7\u00F5es");');
  finally
    LJson.Free;
  end;
end;

function TFrmLogin.BuildScreenActionsHtml(const AScreens: TArray<string>;
  const AUsuarios: TArray<string>; const ASelectedUserID: Integer): string;
var
  B        : TStringBuilder;
  CSS      : string;
  I, J     : Integer;
  Screen   : string;
  SelOpts  : TStringBuilder;
  Usuario  : string;
  LKey     : string;
  LLabel   : string;
  LAllowed : Boolean;
begin
  CSS :=
    '<style>' +
    '.ac-screen{font-family:"Segoe UI",system-ui,sans-serif;color:#E2E8F0;}' +
    '.ac-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;}' +
    '.ac-title{font-size:22px;font-weight:800;background:linear-gradient(90deg,#FCD34D,#F59E0B);' +
    '  -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}' +
    '.ac-sub{font-size:12px;color:rgba(245,158,11,.6);margin-top:4px;}' +
    '.ac-sel-wrap{background:linear-gradient(135deg,rgba(19,15,34,.9),rgba(28,23,48,.9));' +
    '  border:1px solid rgba(245,158,11,.15);border-radius:16px;padding:20px 24px;' +
    '  margin-bottom:28px;display:flex;align-items:center;gap:16px;}' +
    '.ac-sel-lbl{font-size:11px;font-weight:700;color:#F59E0B;letter-spacing:1px;' +
    '  text-transform:uppercase;white-space:nowrap;}' +
    '.ac-sel{flex:1;background:rgba(255,255,255,.04);border:1px solid rgba(245,158,11,.2);' +
    '  border-radius:10px;padding:10px 14px;font-size:14px;color:#FCD34D;' +
    '  font-family:"Segoe UI",system-ui,sans-serif;outline:none;cursor:pointer;}' +
    '.ac-sel:focus{border-color:rgba(245,158,11,.5);}' +
    '.ac-sel option{background:#130F22;color:#FCD34D;}' +
    '.ac-hint{padding:48px;text-align:center;color:rgba(245,158,11,.35);font-size:14px;}' +
    '.ac-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;}' +
    '.ac-card{background:linear-gradient(135deg,rgba(19,15,34,.95),rgba(28,23,48,.95));' +
    '  border-radius:16px;padding:20px;border:1px solid rgba(255,255,255,.06);' +
    '  box-shadow:0 4px 24px rgba(0,0,0,.3);}' +
    '.ac-card-hdr{font-size:13px;font-weight:700;color:#FCD34D;margin-bottom:14px;' +
    '  padding-bottom:10px;border-bottom:1px solid rgba(255,255,255,.05);}' +
    '.ac-actions{display:flex;flex-direction:column;gap:8px;}' +
    '.ac-action{display:flex;align-items:center;gap:10px;font-size:12px;color:#CBD5E1;cursor:pointer;}' +
    '.ac-action.allowed .ac-dot{background:#41E673;box-shadow:0 0 6px rgba(65,230,115,.8);}' +
    '.ac-action.denied .ac-dot{background:#EF4444;box-shadow:0 0 6px rgba(239,68,68,.8);}' +
    '.ac-dot{width:6px;height:6px;border-radius:50%;transition:all .2s;}' +
    '</style>';

  SelOpts := TStringBuilder.Create;
  try
    SelOpts.Append('<option value="0">-- Selecione um usuário --</option>');
    for I := 0 to High(AUsuarios) do
      SelOpts.AppendFormat('<option value="%d"%s>%s</option>',
        [I+1, IfThen(I+1 = ASelectedUserID, ' selected', ''), AUsuarios[I]]);

    B := TStringBuilder.Create;
    try
      B.Append(CSS);
      B.Append('<div class="ac-screen">');
      B.Append('<div class="ac-hdr">');
      B.Append('<div><div class="ac-title">Permiss&otilde;es de A&ccedil;&otilde;es</div>');
      B.Append('<div class="ac-sub">Selecione o usu&aacute;rio e marque as a&ccedil;&otilde;es permitidas por tela</div></div>');
      B.Append('</div>');
      { Seletor }
      B.Append('<div class="ac-sel-wrap">');
      B.Append('<span class="ac-sel-lbl">Usu&aacute;rio</span>');
      B.AppendFormat('<select class="ac-sel" onchange="acSelect(this.value)">%s</select>',
        [SelOpts.ToString]);
      B.Append('</div>');

      { Cards de telas — só mostram se usuário selecionado }
      if ASelectedUserID > 0 then
      begin
        B.Append('<div class="ac-grid">');
        for I := 0 to High(AScreens) do
        begin
          Screen := AScreens[I];
          B.Append('<div class="ac-card">');
          B.AppendFormat('<div class="ac-card-hdr">%s</div>', [Screen]);
          B.Append('<div class="ac-actions">');
          { Ações: para este protótipo, mostra insert, edit, delete }
          for J := 0 to 2 do
          begin
            case J of
              0: begin LKey := 'insert'; LLabel := 'Inserir'; end;
              1: begin LKey := 'edit';   LLabel := 'Editar';  end;
            else   begin LKey := 'delete'; LLabel := 'Deletar'; end;
            end;
            LAllowed := True; { Por agora, assume permite tudo }
            B.AppendFormat(
              '<div class="ac-action %s" onclick="acToggle(this,%d,%s,%s)">' +
              '<div class="ac-dot"></div><span>%s</span></div>',
              [IfThen(LAllowed, 'allowed', 'denied'),
               ASelectedUserID, QuotedStr(Screen), QuotedStr(LKey),
               LLabel]);
          end;
          B.Append('</div></div>');
        end;
        B.Append('</div>');
      end
      else
      begin
        B.Append('<div class="ac-hint">&#8593; Selecione um usu&aacute;rio acima para definir as permiss&otilde;es de a&ccedil;&otilde;es</div>');
      end;

      B.Append('</div>');
      Result := B.ToString;
    finally
      B.Free;
    end;
  finally
    SelOpts.Free;
  end;
end;

initialization
  RegisterAppFormClass(TFrmLogin);

end.
