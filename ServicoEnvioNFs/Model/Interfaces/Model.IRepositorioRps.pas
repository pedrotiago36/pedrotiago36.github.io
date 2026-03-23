unit Model.IRepositorioRps;

interface

uses
  Shared.Tipos,
  Model.IConexaoDB;

type
  IRepositorioRps = interface
    ['{B2C3D4E5-F6A7-0002-BCDE-F23456789012}']
    procedure BuscarRps(
      const AConexao     : IConexaoDB;
      const AMes         : Integer;
      const AAno         : Integer;
      const ACnpjUnidade : string;
      const ACallbackLog : TCallbackProgresso;
      out   ALista       : TListaDadosRps);
  end;

implementation

end.
