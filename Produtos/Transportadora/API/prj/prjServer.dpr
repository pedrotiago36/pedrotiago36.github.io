program prjServer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  System.JSON,
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL,
  FireDAC.Comp.UI,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL;

// Conexao com dtll_Transportadora
function NewMySQLConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;
  with Result.Params do
  begin
    Clear;
    Add('DriverID=MySQL');
    Add('Server=192.168.1.5');
    Add('Port=3306');
    Add('Database=dtll_Transportadora');
    Add('User_Name=root');
    Add('Password=adminbatista');
    Add('CharacterSet=utf8');
  end;
  Result.Connected := True;
end;

// Helpers para ler valores JSON sem lancar excecao
function JStr(const AObj: TJSONObject; const AKey, ADefault: string): string;
var
  LVal: TJSONValue;
begin
  LVal := AObj.GetValue(AKey);
  if Assigned(LVal) then Result := LVal.Value
  else Result := ADefault;
end;

function JInt(const AObj: TJSONObject; const AKey: string; ADefault: Integer): Integer;
var
  LVal: TJSONValue;
begin
  LVal := AObj.GetValue(AKey);
  if Assigned(LVal) then Result := StrToIntDef(LVal.Value, ADefault)
  else Result := ADefault;
end;

// Carrega rotas de permissao de uma tabela para um dado ID
// Retorna TJSONArray com as rotas (caller e responsavel por liberar)
function CarregarRotas(const Conn: TFDConnection;
                       const ATabela, ACampoID: string;
                       const AID: Integer): TJSONArray;
var
  Qry: TFDQuery;
begin
  Result := TJSONArray.Create;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conn;
    Qry.SQL.Text   := 'SELECT rota FROM ' + ATabela +
                      ' WHERE ' + ACampoID + ' = :id ORDER BY rota';
    Qry.ParamByName('id').AsInteger := AID;
    Qry.Open;
    while not Qry.Eof do
    begin
      Result.Add(Qry.FieldByName('rota').AsString);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

begin
  THorse.Use(Jhonson());

  // GET /ping — health check
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('online', TJSONBool.Create(True)));
      Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' GET /ping');
    end
  );

  // POST /login
  // Body: {"login":"admin","senha":"sha256_hash"}
  // Response: {"sucesso":true|false,"mensagem":"..."}
  THorse.Post('/login',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LRoot   : TJSONObject;
      LLogin  : string;
      LSenha  : string;
      Conn    : TFDConnection;
      Qry     : TFDQuery;
      LResp   : TJSONObject;
      LSucesso: Boolean;
    begin
      try
        LRoot := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
        if not Assigned(LRoot) then
        begin
          Res.Status(400).Send('JSON invalido');
          Exit;
        end;
        try
          LLogin := JStr(LRoot, 'login', '');
          LSenha := JStr(LRoot, 'senha', '');
        finally
          LRoot.Free;
        end;

        Conn := NewMySQLConnection;
        try
          Qry := TFDQuery.Create(nil);
          try
            Qry.Connection := Conn;
            Qry.SQL.Text   :=
              'SELECT id, login, is_admin FROM tb_usuarios ' +
              'WHERE login = :login AND senha = :senha AND ativo = 1 LIMIT 1';
            Qry.ParamByName('login').AsString := LLogin;
            Qry.ParamByName('senha').AsString := LSenha;
            Qry.Open;

            LSucesso := Qry.RecordCount > 0;
            LResp    := TJSONObject.Create;
            try
              LResp.AddPair('sucesso', TJSONBool.Create(LSucesso));
              if LSucesso then
                LResp.AddPair('mensagem', 'Bem-vindo, ' + Qry.FieldByName('login').AsString + '!')
              else
                LResp.AddPair('mensagem', 'Usu' + #195 + #161 + 'rio ou senha incorretos.');

              Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
                ' POST /login login=' + LLogin + ' sucesso=' + BoolToStr(LSucesso, True));

              Res.Status(200).Send<TJSONObject>(LResp);
            except
              LResp.Free;
              raise;
            end;
          finally
            Qry.Free;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // GET /usuarios — lista todos os usuarios ativos
  // Response: [{"id":1,"login":"admin","is_admin":1,"perfil_id":0},...]
  THorse.Get('/usuarios',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Conn : TFDConnection;
      Qry  : TFDQuery;
      LArr : TJSONArray;
      LObj : TJSONObject;
    begin
      try
        Conn := NewMySQLConnection;
        try
          Qry := TFDQuery.Create(nil);
          try
            Qry.Connection := Conn;
            Qry.SQL.Text   :=
              'SELECT id, login, is_admin, COALESCE(perfil_id,0) AS perfil_id ' +
              'FROM tb_usuarios WHERE ativo = 1 ORDER BY login';
            Qry.Open;

            LArr := TJSONArray.Create;
            try
              while not Qry.Eof do
              begin
                LObj := TJSONObject.Create;
                LObj.AddPair('id',        TJSONNumber.Create(Qry.FieldByName('id').AsInteger));
                LObj.AddPair('login',     Qry.FieldByName('login').AsString);
                LObj.AddPair('is_admin',  TJSONNumber.Create(Qry.FieldByName('is_admin').AsInteger));
                LObj.AddPair('perfil_id', TJSONNumber.Create(Qry.FieldByName('perfil_id').AsInteger));
                LArr.Add(LObj);
                Qry.Next;
              end;
              Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' GET /usuarios');
              Res.Status(200).Send<TJSONArray>(LArr);
            except
              LArr.Free;
              raise;
            end;
          finally
            Qry.Free;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // GET /usuarios/:id — busca usuario por ID
  // Response: {"id":1,"login":"admin","is_admin":1,"perfil_id":0}
  THorse.Get('/usuarios/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LID  : Integer;
      Conn : TFDConnection;
      Qry  : TFDQuery;
      LObj : TJSONObject;
    begin
      try
        LID  := StrToIntDef(Req.Params['id'], 0);
        Conn := NewMySQLConnection;
        try
          Qry := TFDQuery.Create(nil);
          try
            Qry.Connection := Conn;
            Qry.SQL.Text   :=
              'SELECT id, login, is_admin, COALESCE(perfil_id,0) AS perfil_id ' +
              'FROM tb_usuarios WHERE id = :id AND ativo = 1 LIMIT 1';
            Qry.ParamByName('id').AsInteger := LID;
            Qry.Open;

            LObj := TJSONObject.Create;
            try
              if not Qry.Eof then
              begin
                LObj.AddPair('id',        TJSONNumber.Create(Qry.FieldByName('id').AsInteger));
                LObj.AddPair('login',     Qry.FieldByName('login').AsString);
                LObj.AddPair('is_admin',  TJSONNumber.Create(Qry.FieldByName('is_admin').AsInteger));
                LObj.AddPair('perfil_id', TJSONNumber.Create(Qry.FieldByName('perfil_id').AsInteger));
              end
              else
                LObj.AddPair('id', TJSONNumber.Create(-1));

              Res.Status(200).Send<TJSONObject>(LObj);
            except
              LObj.Free;
              raise;
            end;
          finally
            Qry.Free;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // GET /perfis — lista todos os perfis ativos com suas permissoes
  // Response: [{"id":1,"nome":"Operador","permissoes":["cad.clientes",...]},...]
  THorse.Get('/perfis',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Conn     : TFDConnection;
      Qry      : TFDQuery;
      LArr     : TJSONArray;
      LObj     : TJSONObject;
      LPerms   : TJSONArray;
      LPerfilID: Integer;
    begin
      try
        Conn := NewMySQLConnection;
        try
          Qry := TFDQuery.Create(nil);
          try
            Qry.Connection := Conn;
            Qry.SQL.Text   :=
              'SELECT id, nome FROM tb_perfis WHERE ativo = 1 ORDER BY nome';
            Qry.Open;

            LArr := TJSONArray.Create;
            try
              while not Qry.Eof do
              begin
                LPerfilID := Qry.FieldByName('id').AsInteger;
                LPerms    := CarregarRotas(Conn, 'tb_permissoes_perfis', 'perfil_id', LPerfilID);

                LObj := TJSONObject.Create;
                LObj.AddPair('id',         TJSONNumber.Create(LPerfilID));
                LObj.AddPair('nome',       Qry.FieldByName('nome').AsString);
                LObj.AddPair('permissoes', LPerms);  // LObj toma ownership de LPerms
                LArr.Add(LObj);
                Qry.Next;
              end;
              Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' GET /perfis');
              Res.Status(200).Send<TJSONArray>(LArr);
            except
              LArr.Free;
              raise;
            end;
          finally
            Qry.Free;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // GET /perfis/:id — busca perfil por ID com suas permissoes
  // Response: {"id":1,"nome":"Operador","permissoes":["cad.clientes",...]}
  THorse.Get('/perfis/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LID   : Integer;
      Conn  : TFDConnection;
      Qry   : TFDQuery;
      LObj  : TJSONObject;
      LPerms: TJSONArray;
    begin
      try
        LID  := StrToIntDef(Req.Params['id'], 0);
        Conn := NewMySQLConnection;
        try
          Qry := TFDQuery.Create(nil);
          try
            Qry.Connection := Conn;
            Qry.SQL.Text   :=
              'SELECT id, nome FROM tb_perfis WHERE id = :id AND ativo = 1 LIMIT 1';
            Qry.ParamByName('id').AsInteger := LID;
            Qry.Open;

            LObj := TJSONObject.Create;
            try
              if not Qry.Eof then
              begin
                LPerms := CarregarRotas(Conn, 'tb_permissoes_perfis', 'perfil_id', LID);
                LObj.AddPair('id',         TJSONNumber.Create(Qry.FieldByName('id').AsInteger));
                LObj.AddPair('nome',       Qry.FieldByName('nome').AsString);
                LObj.AddPair('permissoes', LPerms);
              end
              else
                LObj.AddPair('id', TJSONNumber.Create(-1));

              Res.Status(200).Send<TJSONObject>(LObj);
            except
              LObj.Free;
              raise;
            end;
          finally
            Qry.Free;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // GET /permissoes/usuario/:id — rotas liberadas para um usuario
  // Response: {"usuario_id":3,"rotas":["cad.clientes","fin.receber",...]}
  THorse.Get('/permissoes/usuario/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LID   : Integer;
      Conn  : TFDConnection;
      LObj  : TJSONObject;
      LRotas: TJSONArray;
    begin
      try
        LID  := StrToIntDef(Req.Params['id'], 0);
        Conn := NewMySQLConnection;
        try
          LRotas := CarregarRotas(Conn, 'tb_permissoes_usuarios', 'usuario_id', LID);
          LObj   := TJSONObject.Create;
          try
            LObj.AddPair('usuario_id', TJSONNumber.Create(LID));
            LObj.AddPair('rotas',      LRotas);  // LObj toma ownership de LRotas
            Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
              ' GET /permissoes/usuario/' + IntToStr(LID));
            Res.Status(200).Send<TJSONObject>(LObj);
          except
            LObj.Free;
            raise;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // GET /permissoes/perfil/:id — rotas liberadas para um perfil
  // Response: {"perfil_id":1,"rotas":["cad.clientes","fin.receber",...]}
  THorse.Get('/permissoes/perfil/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LID   : Integer;
      Conn  : TFDConnection;
      LObj  : TJSONObject;
      LRotas: TJSONArray;
    begin
      try
        LID  := StrToIntDef(Req.Params['id'], 0);
        Conn := NewMySQLConnection;
        try
          LRotas := CarregarRotas(Conn, 'tb_permissoes_perfis', 'perfil_id', LID);
          LObj   := TJSONObject.Create;
          try
            LObj.AddPair('perfil_id', TJSONNumber.Create(LID));
            LObj.AddPair('rotas',     LRotas);
            Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
              ' GET /permissoes/perfil/' + IntToStr(LID));
            Res.Status(200).Send<TJSONObject>(LObj);
          except
            LObj.Free;
            raise;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // POST /crud — chama sp_CRUD_Generico
  // Body: {"tabela":"tb_usuarios","acao":"INSERT|UPDATE|DELETE","dados":{...}}
  THorse.Post('/crud',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LBody     : string;
      LRoot     : TJSONObject;
      LDados    : TJSONObject;
      LTabela   : string;
      LAcao     : string;
      LpID      : Integer;
      LpParam1  : string;
      LpParam2  : string;
      LpParam3  : string;
      LpParam4  : string;
      LRotasArr : TJSONArray;
      LRotas    : string;
      LI        : Integer;
      Conn      : TFDConnection;
      Qry       : TFDQuery;
      LResult   : TJSONObject;
    begin
      try
        LBody := Req.Body;
        if LBody.IsEmpty then
        begin
          Res.Status(400).Send('JSON vazio');
          Exit;
        end;

        LRoot := TJSONObject.ParseJSONValue(LBody) as TJSONObject;
        if not Assigned(LRoot) then
        begin
          Res.Status(400).Send('JSON invalido');
          Exit;
        end;

        try
          LTabela := JStr(LRoot, 'tabela', '');
          LAcao   := JStr(LRoot, 'acao',   '');
          LDados  := LRoot.GetValue('dados') as TJSONObject;

          if LTabela.IsEmpty or LAcao.IsEmpty or not Assigned(LDados) then
          begin
            Res.Status(400).Send('Campos obrigatorios: tabela, acao, dados');
            Exit;
          end;

          LpID     := 0;
          LpParam1 := '';
          LpParam2 := '';
          LpParam3 := '';
          LpParam4 := '0';

          if LTabela = 'tb_usuarios' then
          begin
            LpID     := JInt(LDados, 'id',        0);
            LpParam1 := JStr(LDados, 'login',     '');
            LpParam2 := JStr(LDados, 'senha',     '');
            LpParam3 := IntToStr(JInt(LDados, 'is_admin',  0));
            LpParam4 := IntToStr(JInt(LDados, 'perfil_id', 0));
          end
          else if LTabela = 'tb_perfis' then
          begin
            LpID     := JInt(LDados, 'id',        0);
            LpParam1 := JStr(LDados, 'nome',      '');
            LpParam2 := JStr(LDados, 'descricao', '');
          end
          else if (LTabela = 'tb_permissoes_usuarios') or
                  (LTabela = 'tb_permissoes_perfis') then
          begin
            // usuario_id ou perfil_id — ambos chegam em 'usuario_id' ou 'perfil_id'
            LpParam4  := IntToStr(JInt(LDados, 'usuario_id', 0));
            if LpParam4 = '0' then
              LpParam4 := IntToStr(JInt(LDados, 'perfil_id', 0));

            LRotas    := '';
            LRotasArr := LDados.GetValue('rotas') as TJSONArray;
            if Assigned(LRotasArr) then
              for LI := 0 to LRotasArr.Count - 1 do
              begin
                if LRotas <> '' then LRotas := LRotas + '|';
                LRotas := LRotas + LRotasArr.Items[LI].Value;
              end;
            LpParam2 := LRotas;
          end;

          Conn := NewMySQLConnection;
          try
            Qry := TFDQuery.Create(nil);
            try
              Qry.Connection := Conn;
              Qry.SQL.Text   :=
                'CALL sp_CRUD_Generico(:pTabela,:pAcao,:pID,' +
                ':pParam1,:pParam2,:pParam3,:pParam4)';
              Qry.ParamByName('pTabela').AsString := LTabela;
              Qry.ParamByName('pAcao').AsString   := LAcao;
              Qry.ParamByName('pID').AsInteger    := LpID;
              Qry.ParamByName('pParam1').AsString := LpParam1;
              Qry.ParamByName('pParam2').AsString := LpParam2;
              Qry.ParamByName('pParam3').AsString := LpParam3;
              Qry.ParamByName('pParam4').AsString := LpParam4;
              Qry.Open;

              LResult := TJSONObject.Create;
              try
                LResult.AddPair('sucesso', TJSONBool.Create(True));
                LResult.AddPair('linhas_afetadas',
                  TJSONNumber.Create(Qry.FieldByName('linhas_afetadas').AsInteger));
                LResult.AddPair('ultimo_id',
                  TJSONNumber.Create(Qry.FieldByName('ultimo_id').AsInteger));

                Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
                  ' POST /crud tabela=' + LTabela + ' acao=' + LAcao);

                Res.Status(200).Send<TJSONObject>(LResult);
              except
                LResult.Free;
                raise;
              end;
            finally
              Qry.Free;
            end;
          finally
            Conn.Free;
          end;

        finally
          LRoot.Free;
        end;

      except
        on E: Exception do
        begin
          Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
            ' ERRO /crud: ' + E.Message);
          Res.Status(500).Send('Erro: ' + E.Message);
        end;
      end;
    end
  );

  // GET /ListaProdutos?empresa_id=X (endpoint legado)
  THorse.Get('/ListaProdutos',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Conn               : TFDConnection;
      QryConsultaProduto : TFDQuery;
      Clientes           : TJSONArray;
      EmpresaID, I       : Integer;
      ProdutoObj         : TJSONObject;
    begin
      try
        Conn := NewMySQLConnection;
        QryConsultaProduto := TFDQuery.Create(nil);
        QryConsultaProduto.FetchOptions.RowsetSize := 10000000;
        try
          EmpresaID := StrToIntDef(Req.Query['empresa_id'], 0);
          QryConsultaProduto.Connection := Conn;
          QryConsultaProduto.SQL.Clear;
          QryConsultaProduto.SQL.Add(
            'SELECT ID, CODIGO_BARRAS, REFERENCIA, VALOR_UNITARIO, VALOR_COMPRA, NOME ' +
            'FROM produtos ' +
            'WHERE CODIGO_BARRAS IS NOT NULL AND CODIGO_BARRAS <> ' + QuotedStr('') +
            '  AND REFERENCIA   IS NOT NULL AND REFERENCIA   <> ' + QuotedStr('') +
            '  AND EMPRESA_ID = :EMPRESA_ID');
          QryConsultaProduto.ParamByName('EMPRESA_ID').AsInteger := EmpresaID;
          QryConsultaProduto.Open;

          Clientes := TJSONArray.Create;
          Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' GET /ListaProdutos');

          for I := 0 to QryConsultaProduto.RecordCount - 1 do
          begin
            ProdutoObj := TJSONObject.Create;
            ProdutoObj.AddPair('ID',            QryConsultaProduto.FieldByName('ID').AsString);
            ProdutoObj.AddPair('CODIGO_BARRAS', QryConsultaProduto.FieldByName('CODIGO_BARRAS').AsString);
            ProdutoObj.AddPair('NOME',          QryConsultaProduto.FieldByName('NOME').AsString);
            ProdutoObj.AddPair('REFERENCIA',    QryConsultaProduto.FieldByName('REFERENCIA').AsString);
            ProdutoObj.AddPair('VALOR_UNITARIO',QryConsultaProduto.FieldByName('VALOR_UNITARIO').AsString);
            ProdutoObj.AddPair('VALOR_COMPRA',  QryConsultaProduto.FieldByName('VALOR_COMPRA').AsString);
            Clientes.Add(ProdutoObj);
            QryConsultaProduto.Next;
          end;

          Res.Send<TJSONArray>(Clientes);
        finally
          QryConsultaProduto.Free;
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  // POST /atualizarestoque (endpoint legado)
  THorse.Post('/atualizarestoque',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      JsonBody          : string;
      Conn              : TFDConnection;
      qryAtualizaEstoque: TFDQuery;
    begin
      try
        JsonBody := Req.Body;
        if JsonBody.IsEmpty then
        begin
          Res.Status(400).Send('JSON vazio');
          Exit;
        end;
        Conn := NewMySQLConnection;
        try
          qryAtualizaEstoque := TFDQuery.Create(nil);
          try
            qryAtualizaEstoque.Connection := Conn;
            qryAtualizaEstoque.SQL.Add('CALL AtualizarEstoque(:pJson)');
            qryAtualizaEstoque.Params.ParamByName('pJson').AsString := JsonBody;
            qryAtualizaEstoque.Execute;
            Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' POST /atualizarestoque');
            Res.Status(200);
          finally
            qryAtualizaEstoque.Free;
          end;
        finally
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Status(500).Send('Erro: ' + E.Message);
      end;
    end
  );

  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor Ativo na porta 9000.');
    end
  );

end.
