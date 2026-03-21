unit Model.TConexaoDB;

{
  TConexaoDB - Conexao dinamica FireDAC para SQL Server
  ======================================================
  Parametros espelhados do FireDAC Explorer (conexao testada e aprovada):
    DriverID  = MSSQL
    Server    = 192.168.1.12
    Database  = conacd
    User_Name = sa
    Password  = Admbatista#

  MARS=Yes       — multiplos cursores ativos simultaneamente
  fmAll          — traz todos os registros para memoria de uma vez
  RowsetSize=10M — pratico sem limite, elimina conflitos de cursor
}

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  FireDAC.DApt,
  FireDAC.Comp.UI,
  Model.IConexaoDB;

type
  TConexaoDB = class(TInterfacedObject, IConexaoDB)
  private
    FConexao   : TFDConnection;
    FDriverLink: TFDPhysMSSQLDriverLink;
    FWaitCursor: TFDGUIxWaitCursor;
    FServidor  : string;
    FBanco     : string;
    FLogin     : string;
    FSenha     : string;

    procedure ConfigurarDriver;
    procedure ConfigurarWaitCursor;
    procedure ConfigurarParametros;
    procedure ConfigurarFetch;
  public
    constructor Create(const AServidor, ABanco, ALogin, ASenha: string);
    destructor  Destroy; override;

    class function Criar(
      const AServidor: string;
      const ABanco   : string;
      const ALogin   : string;
      const ASenha   : string): IConexaoDB;

    { IConexaoDB }
    function  Conexao: TFDConnection;
    function  Conectar: Boolean;
    procedure Desconectar;
    function  EstaConectado: Boolean;
    function  Servidor: string;
    function  Banco: string;
  end;

implementation

{ TConexaoDB }

class function TConexaoDB.Criar(
  const AServidor: string;
  const ABanco   : string;
  const ALogin   : string;
  const ASenha   : string): IConexaoDB;
begin
  Result := TConexaoDB.Create(AServidor, ABanco, ALogin, ASenha);
end;

constructor TConexaoDB.Create(const AServidor, ABanco, ALogin, ASenha: string);
begin
  inherited Create;
  FServidor := AServidor;
  FBanco    := ABanco;
  FLogin    := ALogin;
  FSenha    := ASenha;

  ConfigurarDriver;
  ConfigurarWaitCursor;

  FConexao := TFDConnection.Create(nil);
  ConfigurarParametros;
  ConfigurarFetch;
end;

destructor TConexaoDB.Destroy;
begin
  case Assigned(FConexao) of
    True:
    begin
      case FConexao.Connected of
        True: FConexao.Connected := False;
      end;
      FConexao.Free;
    end;
  end;

  case Assigned(FWaitCursor) of
    True: FWaitCursor.Free;
  end;

  case Assigned(FDriverLink) of
    True: FDriverLink.Free;
  end;

  inherited;
end;

procedure TConexaoDB.ConfigurarDriver;
begin
  FDriverLink           := TFDPhysMSSQLDriverLink.Create(nil);
  FDriverLink.VendorLib := '';
end;

procedure TConexaoDB.ConfigurarWaitCursor;
begin
  FWaitCursor          := TFDGUIxWaitCursor.Create(nil);
  FWaitCursor.Provider := 'Forms';
end;

procedure TConexaoDB.ConfigurarParametros;
begin
  FConexao.DriverName  := 'MSSQL';
  FConexao.LoginPrompt := False;

  FConexao.Params.Clear;
  FConexao.Params.Add('DriverID=MSSQL');
  FConexao.Params.Add('Server='    + FServidor);
  FConexao.Params.Add('Database='  + FBanco);
  FConexao.Params.Add('User_Name=' + FLogin);
  FConexao.Params.Add('Password='  + FSenha);
  FConexao.Params.Add('MARS=Yes');

  FConexao.ResourceOptions.AutoReconnect := True;
  FConexao.ResourceOptions.SilentMode    := True;
  FConexao.ResourceOptions.MacroExpand   := True;
end;

procedure TConexaoDB.ConfigurarFetch;
begin
  FConexao.FetchOptions.Mode      := fmAll;
  FConexao.FetchOptions.RowsetSize := 10000000;
  FConexao.FetchOptions.RecsMax   := -1;
end;

function TConexaoDB.Conectar: Boolean;
begin
  Result := False;
  try
    case not FConexao.Connected of
      True: FConexao.Open;
    end;
    Result := FConexao.Connected;
  except
    on E: Exception do
      raise EFDDBEngineException.CreateFmt(
        'Falha ao conectar em %s/%s: %s', [FServidor, FBanco, E.Message]);
  end;
end;

procedure TConexaoDB.Desconectar;
begin
  case Assigned(FConexao) and FConexao.Connected of
    True: FConexao.Close;
  end;
end;

function TConexaoDB.EstaConectado: Boolean;
begin
  Result := Assigned(FConexao) and FConexao.Connected;
end;

function TConexaoDB.Conexao: TFDConnection;
begin
  Result := FConexao;
end;

function TConexaoDB.Servidor: string;
begin
  Result := FServidor;
end;

function TConexaoDB.Banco: string;
begin
  Result := FBanco;
end;

end.
