unit Model.IPerfil;

interface

type
  { Registro que representa um perfil de acesso }
  TPerfilRec = record
    ID        : Integer;         { 0 = novo registro }
    Nome      : string;          { nome do perfil }
    Permissoes: TArray<string>;  { routes habilitadas }
  end;

  IPerfilModel = interface
    ['{D1E2F3A4-B5C6-7890-DEFA-123456789ABC}']
    function  ListAll  : TArray<TPerfilRec>;
    function  FindByID (const AID: Integer): TPerfilRec;  { ID=-1 se nao encontrado }
    procedure Insert   (const ARec: TPerfilRec);
    procedure Update   (const ARec: TPerfilRec);
    procedure Delete   (const AID: Integer);
    function  NextID   : Integer;
  end;

implementation

end.
