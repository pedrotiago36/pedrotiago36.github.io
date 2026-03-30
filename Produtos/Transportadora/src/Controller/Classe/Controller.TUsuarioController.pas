unit Controller.TUsuarioController;

interface

uses
  Controller.IUsuarioController,
  Model.IUsuario,
  Model.IPerfil,
  System.SysUtils;

type
  TUsuarioController = class(TInterfacedObject, IUsuarioController)
  strict private
    FView        : IUsuarioView;
    FModel       : IUsuarioModel;
    FPerfilModel : IPerfilModel;
  public
    constructor Create(const AModel: IUsuarioModel;
                       const APerfilModel: IPerfilModel);
    procedure BindView    (const AView: IUsuarioView);
    procedure LoadList;
    procedure StartInsert;
    procedure StartEdit   (const AID: Integer);
    procedure Save        (const ALogin, ASenha: string; const AIsAdmin: Boolean;
                           const APerfilID: Integer; const AID: Integer);
    procedure Remove      (const AID: Integer);
  end;

function NewUsuarioController(const AModel: IUsuarioModel;
  const APerfilModel: IPerfilModel): IUsuarioController;

implementation

function NewUsuarioController(const AModel: IUsuarioModel;
  const APerfilModel: IPerfilModel): IUsuarioController;
begin
  Result := TUsuarioController.Create(AModel, APerfilModel);
end;

{ TUsuarioController }

constructor TUsuarioController.Create(const AModel: IUsuarioModel;
  const APerfilModel: IPerfilModel);
begin
  inherited Create;
  FModel       := AModel;
  FPerfilModel := APerfilModel;
end;

procedure TUsuarioController.BindView(const AView: IUsuarioView);
begin
  FView := AView;
end;

procedure TUsuarioController.LoadList;
begin
  FView.ShowList(FModel.ListAll, FPerfilModel.ListAll);
end;

procedure TUsuarioController.StartInsert;
var
  LBlank: TUsuarioRec;
begin
  LBlank.ID       := 0;
  LBlank.Login    := '';
  LBlank.Senha    := '';
  LBlank.IsAdmin  := False;
  LBlank.PerfilID := 0;
  FView.ShowForm(LBlank, FPerfilModel.ListAll);
end;

procedure TUsuarioController.StartEdit(const AID: Integer);
begin
  FView.ShowForm(FModel.FindByID(AID), FPerfilModel.ListAll);
end;

procedure TUsuarioController.Save(const ALogin, ASenha: string;
  const AIsAdmin: Boolean; const APerfilID: Integer; const AID: Integer);
type
  TSaveAct = array[Boolean] of TProc;
var
  LRec  : TUsuarioRec;
  LSave : TSaveAct;
begin
  LRec.ID       := AID;
  LRec.Login    := ALogin;
  LRec.Senha    := ASenha;
  LRec.IsAdmin  := AIsAdmin;
  LRec.PerfilID := APerfilID;

  LSave[False] := procedure begin FModel.Insert(LRec) end;
  LSave[True]  := procedure begin FModel.Update(LRec) end;
  LSave[AID > 0]();

  FView.ShowList(FModel.ListAll, FPerfilModel.ListAll);
end;

procedure TUsuarioController.Remove(const AID: Integer);
begin
  FModel.Delete(AID);
  FView.ShowList(FModel.ListAll, FPerfilModel.ListAll);
end;

end.
