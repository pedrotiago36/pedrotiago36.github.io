unit Model.IMenuItem;

interface

uses
  System.SysUtils;

type
  { Registro que representa um item de menu }
  TMenuItemRec = record
    ID        : string;  { identificador unico }
    ParentID  : string;  { vazio = grupo raiz }
    Caption   : string;  { texto exibido }
    Icon      : string;  { SVG path data }
    Route     : string;  { rota da tela }
    BreadPath : string;  { ex: Seguranca > Cadastro de Usuario }
    Enabled   : Boolean; { false = Em breve }
  end;

  IMenuModel = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetMenuItems: TArray<TMenuItemRec>;
  end;

implementation

end.
