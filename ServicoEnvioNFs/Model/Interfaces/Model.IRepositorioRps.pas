unit Model.IRepositorioRps;

{
  Interface do repositorio de RPS.
  Responsavel por buscar os dados do banco SQL Server
  para montar o XML de envio.
}

interface

uses
  Shared.Tipos;

type
  IRepositorioRps = interface
    ['{B2C3D4E5-F6A7-0002-BCDE-F23456789012}']
    procedure BuscarRps(
      const AStringConexao : string;
      const AMes           : Integer;
      const AAno           : Integer;
      const ACnpjUnidade   : string;
      out   ALista         : TListaDadosRps);
  end;

implementation

end.
