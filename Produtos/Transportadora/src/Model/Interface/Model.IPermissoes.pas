unit Model.IPermissoes;

interface

type
  TPermissoesRec = record
    UsuarioID  : Integer;
    PerfilID   : Integer;   { 0 = sem perfil vinculado }
    Permissoes : TArray<string>;
  end;

  IPermissoesModel = interface
    ['{D4E5F6A7-B8C9-0123-DEF0-456789012345}']
    function  FindByUsuario (const AUsuarioID: Integer): TPermissoesRec;
    procedure Save          (const ARec: TPermissoesRec);
    procedure SaveWithPerfil(const AUsuarioID, APerfilID: Integer);
  end;

implementation

end.
