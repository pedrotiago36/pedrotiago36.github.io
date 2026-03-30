unit Model.TUsuario;

interface

uses
  Model.IUsuario,
  System.Generics.Collections;

type
  TUsuarioModel = class(TInterfacedObject, IUsuarioModel)
  strict private
    FStore  : TDictionary<Integer, TUsuarioRec>;
    FNextID : Integer;
  public
    constructor Create;
    destructor  Destroy; override;
    function  ListAll  : TArray<TUsuarioRec>;
    function  FindByID (const AID: Integer): TUsuarioRec;
    procedure Insert   (const ARec: TUsuarioRec);
    procedure Update   (const ARec: TUsuarioRec);
    procedure Delete   (const AID: Integer);
    function  NextID   : Integer;
  end;

function NewUsuarioModel: IUsuarioModel;

implementation

function NewUsuarioModel: IUsuarioModel;
begin
  Result := TUsuarioModel.Create;
end;

{ TUsuarioModel }

constructor TUsuarioModel.Create;

  procedure Seed(const ALogin, ASenha: string; AAdmin: Boolean);
  var
    LRec: TUsuarioRec;
  begin
    LRec.ID      := FNextID;
    LRec.Login   := ALogin;
    LRec.Senha   := ASenha;
    LRec.IsAdmin := AAdmin;
    LRec.PerfilID:= 0;
    FStore.AddOrSetValue(LRec.ID, LRec);
    Inc(FNextID);
  end;

begin
  inherited;
  FStore  := TDictionary<Integer, TUsuarioRec>.Create;
  FNextID := 1;
  Seed('admin',     'admin123', True);
  Seed('motorista', 'motor123', False);
  Seed('operador',  'op@2024',  False);
end;

destructor TUsuarioModel.Destroy;
begin
  FStore.Free;
  inherited;
end;

function TUsuarioModel.NextID: Integer;
begin
  Result  := FNextID;
  Inc(FNextID);
end;

function TUsuarioModel.ListAll: TArray<TUsuarioRec>;
var
  LRec : TUsuarioRec;
  LIdx : Integer;
begin
  SetLength(Result, FStore.Count);
  LIdx := 0;
  for LRec in FStore.Values do
  begin
    Result[LIdx] := LRec;
    Inc(LIdx);
  end;
end;

function TUsuarioModel.FindByID(const AID: Integer): TUsuarioRec;
type
  TResArr = array[Boolean] of TUsuarioRec;
var
  LFound  : TUsuarioRec;
  LEmpty  : TUsuarioRec;
  LExists : Boolean;
  LArr    : TResArr;
begin
  LEmpty.ID       := -1;
  LEmpty.Login    := '';
  LEmpty.Senha    := '';
  LEmpty.IsAdmin  := False;
  LEmpty.PerfilID := 0;
  LExists         := FStore.TryGetValue(AID, LFound);
  LArr[False]     := LEmpty;
  LArr[True]      := LFound;
  Result          := LArr[LExists];
end;

procedure TUsuarioModel.Insert(const ARec: TUsuarioRec);
var
  LRec: TUsuarioRec;
begin
  LRec         := ARec;
  LRec.ID      := NextID;
  FStore.AddOrSetValue(LRec.ID, LRec);
end;

procedure TUsuarioModel.Update(const ARec: TUsuarioRec);
begin
  FStore.AddOrSetValue(ARec.ID, ARec);
end;

procedure TUsuarioModel.Delete(const AID: Integer);
begin
  FStore.Remove(AID);
end;

end.
