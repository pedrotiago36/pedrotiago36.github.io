-- =============================================================
--  SCRIPT: sp_CRUD_Generico.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.7+  (requer JSON_EXTRACT / JSON_UNQUOTE)
--
--  Assinatura:
--    CALL sp_CRUD_Generico(p_tabela, p_acao, p_json)
--
--  Parâmetros:
--    p_tabela  VARCHAR(50)  — nome da tabela alvo
--                            'tb_usuarios' | 'tb_perfis' | 'tb_permissoes_usuarios'
--    p_acao    VARCHAR(10)  — operação: 'INSERT' | 'UPDATE' | 'DELETE'
--    p_json    TEXT         — payload JSON com os campos do registro
--
--  Retorno:
--    SELECT linhas_afetadas, ultimo_id
--
--  Exemplos de chamada:
--
--  INSERT usuário:
--    CALL sp_CRUD_Generico('tb_usuarios', 'INSERT',
--      '{"login":"joao","senha":"hash256","is_admin":0,"perfil_id":2}');
--
--  UPDATE usuário:
--    CALL sp_CRUD_Generico('tb_usuarios', 'UPDATE',
--      '{"id":3,"login":"joao","senha":"novohash","is_admin":0,"perfil_id":2}');
--
--  DELETE lógico usuário:
--    CALL sp_CRUD_Generico('tb_usuarios', 'DELETE', '{"id":3}');
--
--  INSERT perfil:
--    CALL sp_CRUD_Generico('tb_perfis', 'INSERT',
--      '{"nome":"Operador","descricao":"Acesso operacional"}');
--
--  UPDATE perfil:
--    CALL sp_CRUD_Generico('tb_perfis', 'UPDATE',
--      '{"id":1,"nome":"Operador","descricao":"Acesso operacional atualizado"}');
--
--  DELETE lógico perfil:
--    CALL sp_CRUD_Generico('tb_perfis', 'DELETE', '{"id":1}');
--
--  SALVAR permissões (substitui todas do usuário):
--    CALL sp_CRUD_Generico('tb_permissoes_usuarios', 'INSERT',
--      '{"usuario_id":3,"rotas":["cfg.usuario","cfg.perfil","fin.receber"]}');
--
--  REMOVER todas as permissões de um usuário:
--    CALL sp_CRUD_Generico('tb_permissoes_usuarios', 'DELETE',
--      '{"usuario_id":3}');
-- =============================================================

USE dtll_Transportadora;

DROP PROCEDURE IF EXISTS sp_CRUD_Generico;

DELIMITER $$

CREATE PROCEDURE sp_CRUD_Generico(
    IN p_tabela  VARCHAR(50),
    IN p_acao    VARCHAR(10),
    IN p_json    TEXT
)
BEGIN
    -- ── variáveis locais ─────────────────────────────────────
    DECLARE v_id          INT     DEFAULT 0;
    DECLARE v_usuario_id  INT     DEFAULT 0;
    DECLARE v_i           INT     DEFAULT 0;
    DECLARE v_len         INT     DEFAULT 0;
    DECLARE v_rota        VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- ── id genérico para UPDATE / DELETE ────────────────────
    SET v_id = COALESCE(
        CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.id')) AS UNSIGNED),
        0
    );

    -- ════════════════════════════════════════════════════════
    --  tb_usuarios
    -- ════════════════════════════════════════════════════════
    IF p_tabela = 'tb_usuarios' THEN

        IF UPPER(p_acao) = 'INSERT' THEN
            INSERT INTO tb_usuarios (login, senha, is_admin, perfil_id)
            VALUES (
                JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.login')),
                JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.senha')),
                COALESCE(JSON_EXTRACT(p_json, '$.is_admin'), 0),
                NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.perfil_id')) AS UNSIGNED), 0)
            );

        ELSEIF UPPER(p_acao) = 'UPDATE' THEN
            UPDATE tb_usuarios SET
                login     = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.login')),
                senha     = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.senha')),
                is_admin  = COALESCE(JSON_EXTRACT(p_json, '$.is_admin'), 0),
                perfil_id = NULLIF(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.perfil_id')) AS UNSIGNED), 0)
            WHERE id = v_id
              AND ativo = 1;

        ELSEIF UPPER(p_acao) = 'DELETE' THEN
            -- Delete lógico
            UPDATE tb_usuarios SET ativo = 0 WHERE id = v_id;
        END IF;

    -- ════════════════════════════════════════════════════════
    --  tb_perfis
    -- ════════════════════════════════════════════════════════
    ELSEIF p_tabela = 'tb_perfis' THEN

        IF UPPER(p_acao) = 'INSERT' THEN
            INSERT INTO tb_perfis (nome, descricao)
            VALUES (
                JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nome')),
                NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descricao')), 'null')
            );

        ELSEIF UPPER(p_acao) = 'UPDATE' THEN
            UPDATE tb_perfis SET
                nome      = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.nome')),
                descricao = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.descricao')), 'null')
            WHERE id = v_id
              AND ativo = 1;

        ELSEIF UPPER(p_acao) = 'DELETE' THEN
            -- Delete lógico (mantém histórico de usuários vinculados)
            UPDATE tb_perfis SET ativo = 0 WHERE id = v_id;
        END IF;

    -- ════════════════════════════════════════════════════════
    --  tb_permissoes_usuarios
    -- ════════════════════════════════════════════════════════
    ELSEIF p_tabela = 'tb_permissoes_usuarios' THEN

        SET v_usuario_id = COALESCE(
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.usuario_id')) AS UNSIGNED),
            0
        );

        IF UPPER(p_acao) = 'INSERT' THEN
            -- Remove todas as permissões atuais do usuário
            DELETE FROM tb_permissoes_usuarios WHERE usuario_id = v_usuario_id;

            -- Insere cada rota do array
            SET v_len = COALESCE(JSON_LENGTH(JSON_EXTRACT(p_json, '$.rotas')), 0);
            SET v_i   = 0;

            WHILE v_i < v_len DO
                SET v_rota = JSON_UNQUOTE(
                    JSON_EXTRACT(p_json, CONCAT('$.rotas[', v_i, ']'))
                );
                INSERT INTO tb_permissoes_usuarios (usuario_id, rota)
                VALUES (v_usuario_id, v_rota);
                SET v_i = v_i + 1;
            END WHILE;

        ELSEIF UPPER(p_acao) = 'DELETE' THEN
            -- Remove todas as permissões do usuário
            DELETE FROM tb_permissoes_usuarios WHERE usuario_id = v_usuario_id;
        END IF;

    ELSE
        -- Tabela não mapeada
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tabela não suportada pela procedure sp_CRUD_Generico';
    END IF;

    COMMIT;

    -- Retorno para o endpoint
    SELECT
        ROW_COUNT()      AS linhas_afetadas,
        LAST_INSERT_ID() AS ultimo_id;

END$$

DELIMITER ;
