unit Controller.IMainController;

interface

uses
  Model.IMenuItem;

type
  IMainView = interface;

  IMainController = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    procedure BindView(AView: IMainView);
    procedure NavigateTo(const ARoute: string);
    procedure CloseTab(const ARoute: string);
    procedure ToggleFavorite(const ARoute: string);
    function  GetMenuItems: TArray<TMenuItemRec>;
    function  GetFavorites: TArray<string>;
  end;

  IMainView = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    procedure OpenTab(const ARoute, ACaption, ABreadPath: string);
    procedure CloseTab(const ARoute: string);
    procedure RefreshFavorites(const AFavorites: TArray<string>);
  end;

implementation

end.
