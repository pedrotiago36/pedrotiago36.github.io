unit Model.IUsuario;

interface

type
  TUsuarioRec = record
    ID      : Integer;   { 0 = novo }
    Login   : string;
    Senha   : string;
    IsAdmin : Boolean;
    PerfilID: Integer;   { 0 = sem perfil }
  end;

  IUsuarioModel = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function  ListAll  : TArray<TUsuarioRec>;
    function  FindByID (const AID: Integer): TUsuarioRec;
    procedure Insert   (const ARec: TUsuarioRec);
    procedure Update   (const ARec: TUsuarioRec);
    procedure Delete   (const AID: Integer);
    function  NextID   : Integer;
  end;

implementation

end.
