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

// Le string de TJSONObject sem lancar excecao — retorna ADefault se campo ausente
function JStr(const AObj: TJSONObject; const AKey, ADefault: string): string;
var
  LVal: TJSONValue;
begin
  LVal := AObj.GetValue(AKey);
  if Assigned(LVal) then
    Result := LVal.Value
  else
    Result := ADefault;
end;

// Le inteiro de TJSONObject — retorna ADefault se campo ausente
function JInt(const AObj: TJSONObject; const AKey: string; ADefault: Integer): Integer;
var
  LVal: TJSONValue;
begin
  LVal := AObj.GetValue(AKey);
  if Assigned(LVal) then
    Result := StrToIntDef(LVal.Value, ADefault)
  else
    Result := ADefault;
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

  // GET /ListaProdutos?empresa_id=X
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

  // POST /crud
  // Body: "tabela", "acao" (INSERT|UPDATE|DELETE), "dados" (objeto JSON)
  //
  // tb_usuarios:
  //   dados: id, login, senha, is_admin, perfil_id
  // tb_perfis:
  //   dados: id, nome, descricao
  // tb_permissoes_usuarios:
  //   dados: usuario_id, rotas (array de strings)
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

          // Mapeia campos do JSON para parametros posicionais da SP
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
          else if LTabela = 'tb_permissoes_usuarios' then
          begin
            LpParam4  := IntToStr(JInt(LDados, 'usuario_id', 0));
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

          // Chama SP
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
        begin
          Res.Status(500).Send('Erro: ' + E.Message);
        end;
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
