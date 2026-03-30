unit Controller.TPerfilController;

interface

uses
  Controller.IPerfilController,
  Model.IPerfil,
  Model.IMenuItem,
  System.SysUtils;

type
  TPerfilController = class(TInterfacedObject, IPerfilController)
  strict private
    FView      : IPerfilView;
    FModel     : IPerfilModel;
    FMenuItems : TArray<TMenuItemRec>;
  public
    constructor Create(const AModel: IPerfilModel;
                       const AMenuItems: TArray<TMenuItemRec>);
    procedure BindView   (const AView: IPerfilView);
    procedure LoadList;
    procedure StartInsert;
    procedure StartEdit  (const AID: Integer);
    procedure Save       (const ANome: string; const APerms: TArray<string>; const AID: Integer);
    procedure Remove     (const AID: Integer);
  end;

function NewPerfilController(const AModel: IPerfilModel;
  const AMenuItems: TArray<TMenuItemRec>): IPerfilController;

implementation

function NewPerfilController(const AModel: IPerfilModel;
  const AMenuItems: TArray<TMenuItemRec>): IPerfilController;
begin
  Result := TPerfilController.Create(AModel, AMenuItems);
end;

{ TPerfilController }

constructor TPerfilController.Create(const AModel: IPerfilModel;
  const AMenuItems: TArray<TMenuItemRec>);
begin
  inherited Create;
  FModel     := AModel;
  FMenuItems := AMenuItems;
end;

procedure TPerfilController.BindView(const AView: IPerfilView);
begin
  FView := AView;
end;

procedure TPerfilController.LoadList;
begin
  FView.ShowList(FModel.ListAll);
end;

procedure TPerfilController.StartInsert;
var
  LBlank: TPerfilRec;
begin
  LBlank.ID         := 0;
  LBlank.Nome       := '';
  LBlank.Permissoes := [];
  FView.ShowForm(LBlank);
end;

procedure TPerfilController.StartEdit(const AID: Integer);
begin
  FView.ShowForm(FModel.FindByID(AID));
end;

procedure TPerfilController.Save(const ANome: string;
  const APerms: TArray<string>; const AID: Integer);
type
  TSaveAct = array[Boolean] of TProc;
var
  LRec  : TPerfilRec;
  LSave : TSaveAct;
begin
  LRec.ID         := AID;
  LRec.Nome       := ANome;
  LRec.Permissoes := APerms;

  LSave[False] := procedure begin FModel.Insert(LRec) end;
  LSave[True]  := procedure begin FModel.Update(LRec) end;
  LSave[AID > 0]();

  FView.ShowList(FModel.ListAll);
end;

procedure TPerfilController.Remove(const AID: Integer);
begin
  FModel.Delete(AID);
  FView.ShowList(FModel.ListAll);
end;

end.
