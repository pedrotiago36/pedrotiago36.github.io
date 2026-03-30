unit Model.TPerfil;

interface

uses
  Model.IPerfil,
  System.Generics.Collections,
  System.SysUtils;

type
  TPerfilModel = class(TInterfacedObject, IPerfilModel)
  strict private
    FStore  : TDictionary<Integer, TPerfilRec>;
    FNextID : Integer;
  public
    constructor Create;
    destructor  Destroy; override;
    function  ListAll  : TArray<TPerfilRec>;
    function  FindByID (const AID: Integer): TPerfilRec;
    procedure Insert   (const ARec: TPerfilRec);
    procedure Update   (const ARec: TPerfilRec);
    procedure Delete   (const AID: Integer);
    function  NextID   : Integer;
  end;

function NewPerfilModel: IPerfilModel;

implementation

function NewPerfilModel: IPerfilModel;
begin
  Result := TPerfilModel.Create;
end;

{ TPerfilModel }

constructor TPerfilModel.Create;
begin
  inherited;
  FStore  := TDictionary<Integer, TPerfilRec>.Create;
  FNextID := 1;
end;

destructor TPerfilModel.Destroy;
begin
  FStore.Free;
  inherited;
end;

function TPerfilModel.NextID: Integer;
begin
  Result  := FNextID;
  Inc(FNextID);
end;

function TPerfilModel.ListAll: TArray<TPerfilRec>;
begin
  Result := FStore.Values.ToArray;
end;

function TPerfilModel.FindByID(const AID: Integer): TPerfilRec;
type
  TResArr = array[Boolean] of TPerfilRec;
var
  LFound  : TPerfilRec;
  LEmpty  : TPerfilRec;
  LExists : Boolean;
  LArr    : TResArr;
begin
  LEmpty.ID         := -1;
  LEmpty.Nome       := '';
  LEmpty.Permissoes := [];
  LExists           := FStore.TryGetValue(AID, LFound);
  LArr[False]       := LEmpty;
  LArr[True]        := LFound;
  Result            := LArr[LExists];
end;

procedure TPerfilModel.Insert(const ARec: TPerfilRec);
var
  LRec: TPerfilRec;
begin
  LRec    := ARec;
  LRec.ID := NextID;
  FStore.AddOrSetValue(LRec.ID, LRec);
end;

procedure TPerfilModel.Update(const ARec: TPerfilRec);
begin
  FStore.AddOrSetValue(ARec.ID, ARec);
end;

procedure TPerfilModel.Delete(const AID: Integer);
begin
  FStore.Remove(AID);
end;

end.
