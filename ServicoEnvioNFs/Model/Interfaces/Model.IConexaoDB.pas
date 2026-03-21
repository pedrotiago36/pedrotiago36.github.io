unit Model.IConexaoDB;

interface

uses
  FireDAC.Comp.Client;

type
  IConexaoDB = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function  Conexao: TFDConnection;
    function  Conectar: Boolean;
    procedure Desconectar;
    function  EstaConectado: Boolean;
    function  Servidor: string;
    function  Banco: string;
  end;

implementation

end.
