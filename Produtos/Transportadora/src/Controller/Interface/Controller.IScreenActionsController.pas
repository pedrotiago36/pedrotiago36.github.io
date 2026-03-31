unit Controller.IScreenActionsController;

interface

uses
  Model.IScreenActions;

type
  { View para tela de ações por usuário }
  IScreenActionsView = interface
    ['{B2C3D4E5-F6A7-B8C9-D0E1-F234567890AB}']
    procedure ShowScreenActions(const AScreens: TArray<string>;
                                const AUsuarios: TArray<string>;
                                const ASelectedUserID: Integer);
  end;

  IScreenActionsController = interface
    ['{C3D4E5F6-A7B8-C9D0-E1F2-34567890ABCD}']
    procedure BindView(const AView: IScreenActionsView);
    procedure LoadList;
    procedure SelectUser(const AUsuarioID: Integer);
    procedure ToggleAction(const AUsuarioID: Integer; const ARoute, AActionKey: string);
  end;

implementation

end.
