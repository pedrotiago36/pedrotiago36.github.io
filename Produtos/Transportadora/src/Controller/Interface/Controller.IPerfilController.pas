unit Controller.IPerfilController;

interface

uses
  Model.IPerfil;

type
  IPerfilView = interface;

  IPerfilController = interface
    ['{E4F5A6B7-C8D9-0123-EFAB-234567890BCD}']
    procedure BindView   (const AView: IPerfilView);
    procedure LoadList;
    procedure StartInsert;
    procedure StartEdit  (const AID: Integer);
    procedure Save       (const ANome: string; const APerms: TArray<string>; const AID: Integer);
    procedure Remove     (const AID: Integer);
  end;

  IPerfilView = interface
    ['{F5A6B7C8-D9E0-1234-FABC-345678901CDE}']
    procedure ShowList (const AItems: TArray<TPerfilRec>);
    procedure ShowForm (const ARec: TPerfilRec);
  end;

implementation

end.
