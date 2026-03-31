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

{ ── Conexão principal — dtll_Transportadora ────────────────────── }
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


begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('online', TJSONBool.Create(True)));
      Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' Requisição GET: Endpoint:/Ping.');
    end
  );


  THorse.Get('/ListaProdutos',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      Conn: TFDConnection;
      QryConsultaProduto: TFDQuery;
      Clientes: TJSONArray;
      EmpresaID, I: Integer;
    begin
      try
        Conn := NewMySQLConnection;
        QryConsultaProduto := TFDQuery.Create(Nil);
        QryConsultaProduto.FetchOptions.RowsetSize := 10000000;

        //Pega qual empresa o PDV vai trabalhar
        EmpresaID := StrToIntDef(Req.Query['empresa_id'], 0); // pega da query string

        try
          with QryConsultaProduto do
          begin
            Connection := Conn;

            sql.Clear;
            sql.Add('SELECT ID, CODIGO_BARRAS, REFERENCIA, VALOR_UNITARIO, VALOR_COMPRA, NOME FROM produtos WHERE CODIGO_BARRAS IS NOT NULL AND CODIGO_BARRAS <> '
                    + QuotedStr('') + ' AND REFERENCIA IS NOT NULL AND REFERENCIA <> ' + QuotedStr('') + ' AND EMPRESA_ID = :EMPRESA_ID  ;');

            ParamByName('EMPRESA_ID').AsInteger := EmpresaID;
            Open();

            Clientes := TJSONArray.Create;
            Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' Requisição GET: Endpoint:/ListaProdutos.');

            for I := 0 to pred(QryConsultaProduto.RecordCount) do
            begin
            var
              ProdutoObj: TJSONObject;
            begin
              ProdutoObj := TJSONObject.Create;
              ProdutoObj.AddPair('ID' , QryConsultaProduto.FieldByName('ID' ).AsString);
              ProdutoObj.AddPair('CODIGO_BARRAS' , QryConsultaProduto.FieldByName('CODIGO_BARRAS' ).AsString);
              ProdutoObj.AddPair('NOME'          , QryConsultaProduto.FieldByName('NOME'          ).AsString);
              ProdutoObj.AddPair('REFERENCIA'    , QryConsultaProduto.FieldByName('REFERENCIA'    ).AsString);
              ProdutoObj.AddPair('VALOR_UNITARIO', QryConsultaProduto.FieldByName('VALOR_UNITARIO').AsString);
              ProdutoObj.AddPair('VALOR_COMPRA'  , QryConsultaProduto.FieldByName('VALOR_COMPRA'  ).AsString);

              Clientes.Add(ProdutoObj);
            end;
            QryConsultaProduto.Next;
           end;
          end;
        finally
          Res.Send<TJSONArray>(Clientes);
          Conn.Free;
        end;
      except
        on E: Exception do
          Res.Send('Erro de conexão: ' + E.Message).Status(500);
      end;
    end
  );

{ ── POST /crud — chama sp_CRUD_Generico ────────────────────────────
  Body JSON esperado:
    { "tabela": "tb_usuarios", "acao": "INSERT", "dados": { ... } }

  Exemplo INSERT usuário:
    { "tabela": "tb_usuarios", "acao": "INSERT",
      "dados": { "login": "maria", "senha": "hash256", "is_admin": 0, "perfil_id": 1 } }

  Exemplo SALVAR permissões:
    { "tabela": "tb_permissoes_usuarios", "acao": "INSERT",
      "dados": { "usuario_id": 3, "rotas": ["cfg.usuario","fin.receber"] } }
──────────────────────────────────────────────────────────────────── }
THorse.Post('/crud',
  procedure(Req: THorseRequest; Res: THorseResponse)
  var
    LBody    : string;
    LJsonObj : TJSONObject;
    LTabela  : string;
    LAcao    : string;
    LDados   : TJSONValue;
    LDadosStr: string;
    Conn     : TFDConnection;
    Qry      : TFDQuery;
    LResult  : TJSONObject;
  begin
    try
      LBody := Req.Body;

      if LBody.IsEmpty then
      begin
        Res.Status(400).Send('JSON vazio');
        Exit;
      end;

      LJsonObj := TJSONObject.ParseJSONValue(LBody) as TJSONObject;
      if not Assigned(LJsonObj) then
      begin
        Res.Status(400).Send('JSON inválido');
        Exit;
      end;

      try
        LTabela := LJsonObj.GetValue<string>('tabela');
        LAcao   := LJsonObj.GetValue<string>('acao');
        LDados  := LJsonObj.GetValue('dados');

        if LTabela.IsEmpty or LAcao.IsEmpty or not Assigned(LDados) then
        begin
          Res.Status(400).Send('Campos obrigatórios: tabela, acao, dados');
          Exit;
        end;

        LDadosStr := LDados.ToString;

        Conn := NewMySQLConnection;
        try
          Qry := TFDQuery.Create(nil);
          try
            Qry.Connection := Conn;
            Qry.SQL.Text   := 'CALL sp_CRUD_Generico(:pTabela, :pAcao, :pJson)';
            Qry.ParamByName('pTabela').AsString := LTabela;
            Qry.ParamByName('pAcao').AsString   := LAcao;
            Qry.ParamByName('pJson').AsString   := LDadosStr;
            Qry.Open;

            LResult := TJSONObject.Create;
            try
              LResult.AddPair('sucesso', TJSONBool.Create(True));
              LResult.AddPair('linhas_afetadas',
                TJSONNumber.Create(Qry.FieldByName('linhas_afetadas').AsInteger));
              LResult.AddPair('ultimo_id',
                TJSONNumber.Create(Qry.FieldByName('ultimo_id').AsInteger));

              Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
                ' POST /crud | tabela=' + LTabela + ' acao=' + LAcao);

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
        LJsonObj.Free;
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

THorse.Post('/atualizarestoque',
  procedure(Req: THorseRequest; Res: THorseResponse)
  var
    JsonBody: string;
    Conn: TFDConnection;
    qryAtualizaEstoque: TFDQuery;
  begin
    try
      // Lê o corpo da requisição (JSON)
      JsonBody := Req.Body; // Req.Body contém o JSON enviado pelo cliente

      if JsonBody.IsEmpty then
      begin
        Res.Status(400);
        Res.Send('JSON vazio');
        Exit;
      end;

      // Configura conexão FireDAC (ajuste seu alias/conexão)
      Conn := TFDConnection.Create(nil);
      try
        Conn := NewMySQLConnection;

        qryAtualizaEstoque := TFDQuery.Create(nil);
        try
          qryAtualizaEstoque.Connection := Conn;
          qryAtualizaEstoque.SQL.Add('CALL AtualizarEstoque(:pJson)');
          qryAtualizaEstoque.Params.ParamByName('pJson').AsString := JsonBody;
          qryAtualizaEstoque.Execute;

          //Log da chamada...
          Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' Requisição GET: Endpoint:/atualizarestoque.');

          Res.Status(200);
        finally
          qryAtualizaEstoque.Free;
        end;

      finally
        Conn.Free;
      end;

    except
      on E: Exception do
      begin
        Res.Status(500);
        Res.Send('Erro: ' + E.Message);
      end;
    end;
  end
);

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(Jhonson());
end;

  THorse.Listen(9000,
  procedure
  begin
    Writeln('Servidor Ativo.');
  end);

end.
