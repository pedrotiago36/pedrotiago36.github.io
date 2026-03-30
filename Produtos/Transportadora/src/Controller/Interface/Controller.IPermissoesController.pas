unit Controller.IPermissoesController;

interface

uses
  Model.IPermissoes,
  Model.IUsuario,
  Model.IMenuItem;

type
  IPermissoesView = interface;

  IPermissoesController = interface
    ['{E5F6A7B8-C9D0-1234-EF01-567890123457}']
    procedure BindView   (const AView: IPermissoesView);
    procedure LoadList;
    procedure SelectUser (const AUsuarioID: Integer);
    procedure Save       (const AUsuarioID: Integer;
                          const APerms: TArray<string>);
  end;

  IPermissoesView = interface
    ['{F6A7B8C9-D0E1-2345-F012-678901234568}']
    { Tela única: seletor de usuário + cards de permissão }
    procedure ShowPermissoes(const ARec      : TPermissoesRec;
                             const AUsuarios : TArray<TUsuarioRec>;
                             const AItems    : TArray<TMenuItemRec>);
  end;

implementation

end.
