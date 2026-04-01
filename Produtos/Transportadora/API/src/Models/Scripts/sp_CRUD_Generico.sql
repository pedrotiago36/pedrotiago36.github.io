-- =============================================================
--  SCRIPT: sp_CRUD_Generico.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.1  (sem JSON_EXTRACT / sem SIGNAL / sem RESIGNAL)
--
--  Assinatura:
--    CALL sp_CRUD_Generico(p_tabela, p_acao, p_id,
--                          p_param1, p_param2, p_param3, p_param4)
--
--  Mapeamento de parametros:
--
--  tb_usuarios
--    p_id      -> id (0 em INSERT)
--    p_param1  -> login
--    p_param2  -> senha (hash SHA-256; vazio = manter existente no UPDATE)
--    p_param3  -> is_admin ('0' ou '1')
--    p_param4  -> perfil_id ('0' = sem perfil)
--
--  tb_perfis
--    p_id      -> id (0 em INSERT)
--    p_param1  -> nome
--    p_param2  -> descricao ('' = NULL)
--    p_param3  -> nao usado (passe '')
--    p_param4  -> nao usado (passe '0')
--
--  tb_permissoes_usuarios
--    p_id      -> nao usado (passe 0)
--    p_param2  -> rotas pipe-separated ('r1|r2|r3'; vazio = apaga tudo)
--    p_param4  -> usuario_id
--
--  tb_permissoes_perfis
--    p_id      -> nao usado (passe 0)
--    p_param2  -> rotas pipe-separated ('r1|r2|r3'; vazio = apaga tudo)
--    p_param4  -> perfil_id
--
--  Retorno:
--    SELECT linhas_afetadas, ultimo_id
-- =============================================================

USE dtll_Transportadora;

DROP PROCEDURE IF EXISTS sp_CRUD_Generico;

DELIMITER $$

CREATE PROCEDURE sp_CRUD_Generico(
    IN p_tabela  VARCHAR(50),
    IN p_acao    VARCHAR(10),
    IN p_id      INT,
    IN p_param1  VARCHAR(255),
    IN p_param2  TEXT,
    IN p_param3  VARCHAR(10),
    IN p_param4  VARCHAR(20)
)
BEGIN
    DECLARE v_afetadas    INT         DEFAULT 0;
    DECLARE v_ultimo_id   INT         DEFAULT 0;
    DECLARE v_usuario_id  INT         DEFAULT 0;
    DECLARE v_perfil_id   INT         DEFAULT 0;
    DECLARE v_resto       TEXT;
    DECLARE v_pos         INT         DEFAULT 0;
    DECLARE v_rota        VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- ============================================================
    --  tb_usuarios
    -- ============================================================
    IF p_tabela = 'tb_usuarios' THEN

        IF UPPER(p_acao) = 'INSERT' THEN

            -- ativo = 1 garante que o novo usuario apareca na listagem imediatamente
            INSERT INTO tb_usuarios (login, senha, is_admin, perfil_id, ativo)
            VALUES (
                p_param1,
                p_param2,
                CAST(p_param3 AS UNSIGNED),
                NULLIF(CAST(p_param4 AS UNSIGNED), 0),
                1
            );

        ELSEIF UPPER(p_acao) = 'UPDATE' THEN

            UPDATE tb_usuarios
            SET
                login     = p_param1,
                -- Se senha vier vazia, mantem a existente (usuario nao alterou)
                senha     = CASE WHEN LENGTH(TRIM(p_param2)) > 0
                                 THEN p_param2
                                 ELSE senha
                            END,
                is_admin  = CAST(p_param3 AS UNSIGNED),
                perfil_id = NULLIF(CAST(p_param4 AS UNSIGNED), 0)
            WHERE id = p_id
              AND ativo = 1;

        ELSEIF UPPER(p_acao) = 'DELETE' THEN

            -- DELETE real: tb_permissoes_usuarios e tb_acoes_usuarios
            -- possuem ON DELETE CASCADE, entao sao limpos automaticamente
            DELETE FROM tb_usuarios WHERE id = p_id;

        END IF;

    -- ============================================================
    --  tb_perfis
    -- ============================================================
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

            UPDATE tb_perfis SET ativo = 0 WHERE id = p_id;

        END IF;

    -- ============================================================
    --  tb_permissoes_usuarios
    --  p_param4 = usuario_id | p_param2 = rotas pipe-separated
    -- ============================================================
    ELSEIF p_tabela = 'tb_permissoes_usuarios' THEN

        SET v_usuario_id = CAST(p_param4 AS UNSIGNED);

        DELETE FROM tb_permissoes_usuarios WHERE usuario_id = v_usuario_id;

        IF UPPER(p_acao) = 'INSERT' AND LENGTH(TRIM(p_param2)) > 0 THEN

            SET v_resto = CONCAT(TRIM(p_param2), '|');

            WHILE LENGTH(v_resto) > 0 DO
                SET v_pos   = LOCATE('|', v_resto);
                SET v_rota  = TRIM(SUBSTRING(v_resto, 1, v_pos - 1));
                SET v_resto = SUBSTRING(v_resto, v_pos + 1);
                IF LENGTH(v_rota) > 0 THEN
                    INSERT INTO tb_permissoes_usuarios (usuario_id, rota)
                    VALUES (v_usuario_id, v_rota);
                END IF;
            END WHILE;

        END IF;

    -- ============================================================
    --  tb_permissoes_perfis
    --  p_param4 = perfil_id | p_param2 = rotas pipe-separated
    -- ============================================================
    ELSEIF p_tabela = 'tb_permissoes_perfis' THEN

        SET v_perfil_id = CAST(p_param4 AS UNSIGNED);

        DELETE FROM tb_permissoes_perfis WHERE perfil_id = v_perfil_id;

        IF UPPER(p_acao) = 'INSERT' AND LENGTH(TRIM(p_param2)) > 0 THEN

            SET v_resto = CONCAT(TRIM(p_param2), '|');

            WHILE LENGTH(v_resto) > 0 DO
                SET v_pos   = LOCATE('|', v_resto);
                SET v_rota  = TRIM(SUBSTRING(v_resto, 1, v_pos - 1));
                SET v_resto = SUBSTRING(v_resto, v_pos + 1);
                IF LENGTH(v_rota) > 0 THEN
                    INSERT INTO tb_permissoes_perfis (perfil_id, rota)
                    VALUES (v_perfil_id, v_rota);
                END IF;
            END WHILE;

        END IF;

    END IF;

    SET v_afetadas  = ROW_COUNT();
    SET v_ultimo_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_afetadas AS linhas_afetadas, v_ultimo_id AS ultimo_id;

END$$

DELIMITER ;
