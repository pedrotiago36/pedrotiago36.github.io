program prjServer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  System.JSON,
  System.SysUtils,
  Controllers.ProdutoController,
  Controllers.EstoqueController,
  Controllers.HealthController;

procedure InicializarServidor;
begin
  // Middleware global para JSON
  THorse.Use(Jhonson);
  
  // Registrar Controllers
  TProdutoController.RegistrarRotas;
  TEstoqueController.RegistrarRotas;
  THealthController.RegistrarRotas;
  
  // Iniciar servidor
  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor Ativo na porta 9000');
      Writeln('Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
    end);
end;

begin
  try
    InicializarServidor;
    Readln;
  except
    on E: Exception do
      Writeln('Erro ao iniciar servidor: ', E.Message);
  end;
end.