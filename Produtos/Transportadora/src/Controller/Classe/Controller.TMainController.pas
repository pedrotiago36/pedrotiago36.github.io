unit Controller.TMainController;

interface

uses
  Controller.IMainController,
  Model.IMenuItem,
  Model.TMenuTree,
  System.SysUtils,
  System.Generics.Collections;

type
  TMainController = class(TInterfacedObject, IMainController)
  private
    FView           : IMainView;
    FMenuModel      : IMenuModel;
    FFavorites      : TList<string>;
    FRouteMap       : TDictionary<string, TMenuItemRec>;
    FScreenHandlers : TDictionary<string, TProc>;
    procedure BuildRouteMap;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BindView(AView: IMainView);
    procedure NavigateTo(const ARoute: string);
    procedure CloseTab(const ARoute: string);
    procedure ToggleFavorite(const ARoute: string);
    function  GetMenuItems: TArray<TMenuItemRec>;
    function  GetFavorites: TArray<string>;
    procedure RegisterScreenHandler(const ARoute: string; const AHandler: TProc);
  end;

function NewMainController: IMainController;

implementation

function NewMainController: IMainController;
begin
  Result := TMainController.Create;
end;

{ TMainController }

constructor TMainController.Create;
begin
  inherited;
  FMenuModel      := NewMenuModel;
  FFavorites      := TList<string>.Create;
  FRouteMap       := TDictionary<string, TMenuItemRec>.Create;
  FScreenHandlers := TDictionary<string, TProc>.Create;
  BuildRouteMap;
end;

destructor TMainController.Destroy;
begin
  FScreenHandlers.Free;
  FRouteMap.Free;
  FFavorites.Free;
  inherited;
end;

procedure TMainController.BuildRouteMap;
var
  LItems : TArray<TMenuItemRec>;
  LItem  : TMenuItemRec;
begin
  LItems := FMenuModel.GetMenuItems;
  for LItem in LItems do
    FRouteMap.AddOrSetValue(LItem.Route, LItem);
end;

procedure TMainController.BindView(AView: IMainView);
begin
  FView := AView;
end;

procedure TMainController.NavigateTo(const ARoute: string);
type
  THandlerArr = array[Boolean] of TProc;
var
  LItem    : TMenuItemRec;
  LHandler : TProc;
  LNoOp    : TProc;
  LArr     : THandlerArr;
  LExists  : Boolean;
begin
  Assert(ARoute <> '', 'Rota não pode ser vazia');
  Assert(FRouteMap.ContainsKey(ARoute), 'Rota não encontrada: ' + ARoute);
  LItem := FRouteMap[ARoute];
  Assert(LItem.Enabled, 'Funcionalidade em breve: ' + LItem.Caption);
  FView.OpenTab(LItem.Route, LItem.Caption, LItem.BreadPath);
  { Dispara o screen handler sem IF — TryGetValue retorna False se rota sem handler }
  LNoOp         := procedure begin end;
  LExists       := FScreenHandlers.TryGetValue(ARoute, LHandler);
  LArr[False]   := LNoOp;
  LArr[True]    := LHandler;
  LArr[LExists]();
end;

procedure TMainController.RegisterScreenHandler(const ARoute: string;
  const AHandler: TProc);
begin
  FScreenHandlers.AddOrSetValue(ARoute, AHandler);
end;

procedure TMainController.CloseTab(const ARoute: string);
begin
  FView.CloseTab(ARoute);
end;

procedure TMainController.ToggleFavorite(const ARoute: string);
type
  TToggleAct = array[Boolean] of TProc;
var
  LIdx    : Integer;
  LToggle : TToggleAct;
begin
  LIdx          := FFavorites.IndexOf(ARoute);
  LToggle[False] := procedure begin FFavorites.Add(ARoute) end;
  LToggle[True]  := procedure begin FFavorites.Remove(ARoute) end;
  LToggle[LIdx >= 0]();
  FView.RefreshFavorites(GetFavorites);
end;

function TMainController.GetMenuItems: TArray<TMenuItemRec>;
begin
  Result := FMenuModel.GetMenuItems;
end;

function TMainController.GetFavorites: TArray<string>;
begin
  Result := FFavorites.ToArray;
end;

end.
