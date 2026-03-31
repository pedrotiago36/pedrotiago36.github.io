-- =============================================================
--  SCRIPT: sp_CRUD_Generico.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.1  (sem JSON_EXTRACT / sem SIGNAL / sem RESIGNAL)
--
--  IMPORTANTE — MySQL 5.1 não possui funções JSON nem SIGNAL.
--  A solução adotada:
--    • A API (Delphi/Horse) parseia o JSON e mapeia os campos
--      para parâmetros posicionais antes de chamar a SP.
--    • Rotas de permissão chegam como string delimitada por pipe "|".
--
--  Assinatura:
--    CALL sp_CRUD_Generico(p_tabela, p_acao, p_id,
--                          p_param1, p_param2, p_param3, p_param4)
--
--  Mapeamento de parâmetros por tabela:
--
--  tb_usuarios
--    p_id      → id do registro  (0 em INSERT)
--    p_param1  → login
--    p_param2  → senha (hash SHA-256 gerado no Delphi)
--    p_param3  → is_admin ('0' ou '1')
--    p_param4  → perfil_id ('0' = sem perfil)
--
--  tb_perfis
--    p_id      → id do registro  (0 em INSERT)
--    p_param1  → nome
--    p_param2  → descricao       ('' = NULL)
--    p_param3  → não usado       (passe '')
--    p_param4  → não usado       (passe '0')
--
--  tb_permissoes_usuarios
--    p_id      → não usado       (passe 0)
--    p_param1  → não usado       (passe '')
--    p_param2  → rotas separadas por "|"
--               ex: 'cfg.usuario|fin.receber|cfg.perfil'
--               (vazio = apagar todas)
--    p_param3  → não usado       (passe '')
--    p_param4  → usuario_id
--
--  Exemplos de chamada:
--
--  INSERT usuário:
--    CALL sp_CRUD_Generico('tb_usuarios','INSERT',0,'maria','sha256hash','0','1');
--
--  UPDATE usuário:
--    CALL sp_CRUD_Generico('tb_usuarios','UPDATE',3,'maria','sha256hash','0','1');
--
--  DELETE (lógico) usuário:
--    CALL sp_CRUD_Generico('tb_usuarios','DELETE',3,'','','','0');
--
--  INSERT perfil:
--    CALL sp_CRUD_Generico('tb_perfis','INSERT',0,'Operador','Acesso operacional','','0');
--
--  UPDATE perfil:
--    CALL sp_CRUD_Generico('tb_perfis','UPDATE',1,'Operador','Novo texto','','0');
--
--  DELETE (lógico) perfil:
--    CALL sp_CRUD_Generico('tb_perfis','DELETE',1,'','','','0');
--
--  SALVAR permissões (substitui tudo do usuário):
--    CALL sp_CRUD_Generico('tb_permissoes_usuarios','INSERT',0,'',
--                          'cfg.usuario|fin.receber|cfg.perfil','','3');
--
--  REMOVER todas as permissões de um usuário:
--    CALL sp_CRUD_Generico('tb_permissoes_usuarios','DELETE',0,'','','','3');
--
--  Retorno (SELECT):
--    linhas_afetadas  INT
--    ultimo_id        INT
-- =============================================================

USE dtll_Transportadora;

DROP PROCEDURE IF EXISTS sp_CRUD_Generico;

DELIMITER $$

CREATE PROCEDURE sp_CRUD_Generico(
    IN p_tabela  VARCHAR(50),   -- tabela alvo
    IN p_acao    VARCHAR(10),   -- INSERT | UPDATE | DELETE
    IN p_id      INT,           -- PK para UPDATE/DELETE  (0 em INSERT)
    IN p_param1  VARCHAR(255),  -- login  | nome     | (não usado em permissoes)
    IN p_param2  TEXT,          -- senha  | descricao| rotas pipe-separated
    IN p_param3  VARCHAR(10),   -- is_admin ('0'/'1')| (não usado)
    IN p_param4  VARCHAR(20)    -- perfil_id         | usuario_id (permissoes)
)
BEGIN
    -- ── variáveis locais ─────────────────────────────────────────────────
    DECLARE v_afetadas   INT         DEFAULT 0;
    DECLARE v_ultimo_id  INT         DEFAULT 0;
    DECLARE v_usuario_id INT         DEFAULT 0;
    DECLARE v_resto      TEXT;
    DECLARE v_pos        INT         DEFAULT 0;
    DECLARE v_rota       VARCHAR(100);

    -- Em MySQL 5.1 não existe RESIGNAL; apenas faz ROLLBACK no handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- ════════════════════════════════════════════════════════════════════
    --  tb_usuarios
    --  p_param1 = login | p_param2 = senha | p_param3 = is_admin | p_param4 = perfil_id
    -- ════════════════════════════════════════════════════════════════════
    IF p_tabela = 'tb_usuarios' THEN

        IF UPPER(p_acao) = 'INSERT' THEN

            INSERT INTO tb_usuarios (login, senha, is_admin, perfil_id)
            VALUES (
                p_param1,
                p_param2,
                CAST(p_param3 AS UNSIGNED),
                NULLIF(CAST(p_param4 AS UNSIGNED), 0)
            );

        ELSEIF UPPER(p_acao) = 'UPDATE' THEN

            UPDATE tb_usuarios
            SET
                login     = p_param1,
                senha     = p_param2,
                is_admin  = CAST(p_param3 AS UNSIGNED),
                perfil_id = NULLIF(CAST(p_param4 AS UNSIGNED), 0)
            WHERE id = p_id
              AND ativo = 1;

        ELSEIF UPPER(p_acao) = 'DELETE' THEN

            -- Delete lógico: mantém histórico
            UPDATE tb_usuarios SET ativo = 0 WHERE id = p_id;

        END IF;

    -- ════════════════════════════════════════════════════════════════════
    --  tb_perfis
    --  p_param1 = nome | p_param2 = descricao ('' → NULL)
    -- ════════════════════════════════════════════════════════════════════
    ELSEIF p_tabela = 'tb_perfis' THEN

        IF UPPER(p_acao) = 'INSERT' THEN

            INSERT INTO tb_perfis (nome, descricao)
            VALUES (
                p_param1,
                NULLIF(p_param2, '')
            );

        ELSEIF UPPER(p_acao) = 'UPDATE' THEN

            UPDATE tb_perfis
            SET
                nome      = p_param1,
                descricao = NULLIF(p_param2, '')
            WHERE id = p_id
              AND ativo = 1;

        ELSEIF UPPER(p_acao) = 'DELETE' THEN

            -- Delete lógico: FK de usuarios aponta aqui — não apaga fisicamente
            UPDATE tb_perfis SET ativo = 0 WHERE id = p_id;

        END IF;

    -- ════════════════════════════════════════════════════════════════════
    --  tb_permissoes_usuarios
    --  p_param4 = usuario_id
    --  p_param2 = rotas separadas por "|"
    --            ex: 'cfg.usuario|fin.receber|cfg.perfil'
    --            vazio → apenas limpa, não insere nada
    -- ════════════════════════════════════════════════════════════════════
    ELSEIF p_tabela = 'tb_permissoes_usuarios' THEN

        SET v_usuario_id = CAST(p_param4 AS UNSIGNED);

        -- Sempre apaga tudo antes (INSERT = substitui; DELETE = só apaga)
        DELETE FROM tb_permissoes_usuarios WHERE usuario_id = v_usuario_id;

        IF UPPER(p_acao) = 'INSERT' AND LENGTH(TRIM(p_param2)) > 0 THEN

            -- Percorre a string 'rota1|rota2|rota3' e insere cada rota
            SET v_resto = CONCAT(TRIM(p_param2), '|');  -- garante delimitador no final

            WHILE LENGTH(v_resto) > 0 DO

                SET v_pos  = LOCATE('|', v_resto);
                SET v_rota = TRIM(SUBSTRING(v_resto, 1, v_pos - 1));
                SET v_resto = SUBSTRING(v_resto, v_pos + 1);

                IF LENGTH(v_rota) > 0 THEN
                    INSERT INTO tb_permissoes_usuarios (usuario_id, rota)
                    VALUES (v_usuario_id, v_rota);
                END IF;

            END WHILE;

        END IF;

    END IF;
    -- ── Tabela não mapeada: a SP simplesmente não faz nada (MySQL 5.1 sem SIGNAL)

    -- Salva ROW_COUNT() ANTES do COMMIT (COMMIT zera o contador)
    SET v_afetadas  = ROW_COUNT();
    SET v_ultimo_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_afetadas AS linhas_afetadas, v_ultimo_id AS ultimo_id;

END$$

DELIMITER ;
