unit Model.IPermissoes;

interface

type
  TPermissoesRec = record
    UsuarioID  : Integer;
    Permissoes : TArray<string>;
  end;

  IPermissoesModel = interface
    ['{D4E5F6A7-B8C9-0123-DEF0-456789012345}']
    function  FindByUsuario (const AUsuarioID: Integer): TPermissoesRec;
    procedure Save          (const ARec: TPermissoesRec);
  end;

implementation

end.
