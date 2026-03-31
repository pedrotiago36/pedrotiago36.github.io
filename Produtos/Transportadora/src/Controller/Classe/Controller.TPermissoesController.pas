unit Controller.TPermissoesController;

interface

uses
  Controller.IPermissoesController,
  Model.IPermissoes,
  Model.IUsuario,
  Model.IPerfil,
  Model.IMenuItem;

type
  TPermissoesController = class(TInterfacedObject, IPermissoesController)
  strict private
    FView       : IPermissoesView;
    FModel      : IPermissoesModel;
    FUsuModel   : IUsuarioModel;
    FPerfilModel: IPerfilModel;
    FMenuItems  : TArray<TMenuItemRec>;
  public
    constructor Create(const AModel      : IPermissoesModel;
                       const AUsuModel   : IUsuarioModel;
                       const APerfilModel: IPerfilModel;
                       const AMenuItems  : TArray<TMenuItemRec>);
    procedure BindView       (const AView: IPermissoesView);
    procedure LoadList;
    procedure SelectUser     (const AUsuarioID: Integer);
    procedure Save           (const AUsuarioID: Integer;
                              const APerms: TArray<string>);
    procedure SaveWithPerfil (const AUsuarioID, APerfilID: Integer);
  end;

function NewPermissoesController(const AModel      : IPermissoesModel;
                                 const AUsuModel   : IUsuarioModel;
                                 const APerfilModel: IPerfilModel;
                                 const AMenuItems  : TArray<TMenuItemRec>)
  : IPermissoesController;

implementation

function NewPermissoesController(const AModel      : IPermissoesModel;
                                 const AUsuModel   : IUsuarioModel;
                                 const APerfilModel: IPerfilModel;
                                 const AMenuItems  : TArray<TMenuItemRec>)
  : IPermissoesController;
begin
  Result := TPermissoesController.Create(AModel, AUsuModel, APerfilModel, AMenuItems);
end;

{ TPermissoesController }

constructor TPermissoesController.Create(const AModel      : IPermissoesModel;
                                         const AUsuModel   : IUsuarioModel;
                                         const APerfilModel: IPerfilModel;
                                         const AMenuItems  : TArray<TMenuItemRec>);
begin
  inherited Create;
  FModel       := AModel;
  FUsuModel    := AUsuModel;
  FPerfilModel := APerfilModel;
  FMenuItems   := AMenuItems;
end;

procedure TPermissoesController.BindView(const AView: IPermissoesView);
begin
  FView := AView;
end;

procedure TPermissoesController.LoadList;
var
  LUsers  : TArray<TUsuarioRec>;
  LFirstID: Integer;
begin
  LUsers   := FUsuModel.ListAll;
  LFirstID := 0;
  if Length(LUsers) > 0 then LFirstID := LUsers[0].ID;
  FView.ShowPermissoes(
    FModel.FindByUsuario(LFirstID),
    LUsers,
    FPerfilModel.ListAll,
    FMenuItems);
end;

procedure TPermissoesController.SelectUser(const AUsuarioID: Integer);
begin
  FView.ShowPermissoes(
    FModel.FindByUsuario(AUsuarioID),
    FUsuModel.ListAll,
    FPerfilModel.ListAll,
    FMenuItems);
end;

procedure TPermissoesController.Save(const AUsuarioID: Integer;
  const APerms: TArray<string>);
var
  LRec: TPermissoesRec;
begin
  LRec.UsuarioID  := AUsuarioID;
  LRec.PerfilID   := 0;
  LRec.Permissoes := APerms;
  FModel.Save(LRec);
  FView.ShowPermissoes(
    FModel.FindByUsuario(AUsuarioID),
    FUsuModel.ListAll,
    FPerfilModel.ListAll,
    FMenuItems);
end;

procedure TPermissoesController.SaveWithPerfil(const AUsuarioID, APerfilID: Integer);
begin
  FModel.SaveWithPerfil(AUsuarioID, APerfilID);
  FView.ShowPermissoes(
    FModel.FindByUsuario(AUsuarioID),
    FUsuModel.ListAll,
    FPerfilModel.ListAll,
    FMenuItems);
end;

end.
