unit Model.TPermissoes;

interface

uses
  Model.IPermissoes,
  System.Generics.Collections;

type
  TPermissoesModel = class(TInterfacedObject, IPermissoesModel)
  strict private
    FStore: TDictionary<Integer, TPermissoesRec>;
  public
    constructor Create;
    destructor  Destroy; override;
    function  FindByUsuario (const AUsuarioID: Integer): TPermissoesRec;
    procedure Save          (const ARec: TPermissoesRec);
  end;

function NewPermissoesModel: IPermissoesModel;

implementation

function NewPermissoesModel: IPermissoesModel;
begin
  Result := TPermissoesModel.Create;
end;

{ TPermissoesModel }

constructor TPermissoesModel.Create;
begin
  inherited;
  FStore := TDictionary<Integer, TPermissoesRec>.Create;
end;

destructor TPermissoesModel.Destroy;
begin
  FStore.Free;
  inherited;
end;

function TPermissoesModel.FindByUsuario(const AUsuarioID: Integer): TPermissoesRec;
type
  TResArr = array[Boolean] of TPermissoesRec;
var
  LFound  : TPermissoesRec;
  LEmpty  : TPermissoesRec;
  LExists : Boolean;
  LArr    : TResArr;
begin
  LEmpty.UsuarioID  := AUsuarioID;
  LEmpty.Permissoes := [];
  LExists           := FStore.TryGetValue(AUsuarioID, LFound);
  LArr[False]       := LEmpty;
  LArr[True]        := LFound;
  Result            := LArr[LExists];
end;

procedure TPermissoesModel.Save(const ARec: TPermissoesRec);
begin
  FStore.AddOrSetValue(ARec.UsuarioID, ARec);
end;

end.
