unit Controller.IUsuarioController;

interface

uses
  Model.IUsuario,
  Model.IPerfil;

type
  IUsuarioView = interface;

  IUsuarioController = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678903}']
    procedure BindView    (const AView: IUsuarioView);
    procedure LoadList;
    procedure StartInsert;
    procedure StartEdit   (const AID: Integer);
    procedure Save        (const ALogin, ASenha: string; const AIsAdmin: Boolean;
                           const APerfilID: Integer; const AID: Integer);
    procedure Remove      (const AID: Integer);
  end;

  IUsuarioView = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789013}']
    procedure ShowList (const AItems: TArray<TUsuarioRec>;
                        const APerfis: TArray<TPerfilRec>);
    procedure ShowForm (const ARec: TUsuarioRec;
                        const APerfis: TArray<TPerfilRec>);
  end;

implementation

end.
