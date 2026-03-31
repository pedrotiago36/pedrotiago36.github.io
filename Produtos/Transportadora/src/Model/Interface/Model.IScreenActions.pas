unit Model.IScreenActions;

interface

type
  { Representa uma ação (botão) em uma tela do sistema }
  TScreenActionRec = record
    UsuarioID : Integer;      { ID do usuário }
    Route     : string;       { rota da tela (ex: cfg.perfil, cad.usuarios) }
    ActionKey : string;       { chave da ação (ex: "insert", "edit", "delete") }
    Allowed   : Boolean;      { true = usuário pode usar essa ação }
  end;

  { Agrupa todas as ações de uma tela }
  TScreenRec = record
    Route    : string;        { rota da tela }
    Caption  : string;        { nome da tela }
    Actions  : TArray<TScreenActionRec>;
  end;

  IScreenActionsModel = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function  GetActionsByScreen(const ARoute: string): TArray<TScreenActionRec>;
    function  IsActionAllowed(const AUsuarioID: Integer; const ARoute, AActionKey: string): Boolean;
    procedure ToggleAction(const AUsuarioID: Integer; const ARoute, AActionKey: string);
    function  GetAllScreens: TArray<string>;
  end;

implementation

end.
