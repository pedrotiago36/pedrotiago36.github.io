-- =============================================================
--  SCRIPT: tb_acoes_usuarios.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.1+
--  Obs    : Executar APOS tb_usuarios.sql
--           Armazena quais acoes (insert/edit/delete/save/cancel)
--           cada usuario tem permissao em cada tela do sistema.
-- =============================================================

USE dtll_Transportadora;

CREATE TABLE IF NOT EXISTS tb_acoes_usuarios (
    id         INT(11)      NOT NULL AUTO_INCREMENT        COMMENT 'PK',
    usuario_id INT(11)      NOT NULL                       COMMENT 'FK -> tb_usuarios.id',
    tela       VARCHAR(100) NOT NULL                       COMMENT 'Rota da tela (ex: cfg.perfil, cad.clientes)',
    acao       VARCHAR(50)  NOT NULL                       COMMENT 'Chave da acao (insert, edit, delete, save, cancel)',
    permitido  TINYINT(1)   NOT NULL DEFAULT 1             COMMENT '1 = permitido, 0 = bloqueado',

    PRIMARY KEY (id),

    -- garante um unico registro por (usuario, tela, acao)
    UNIQUE KEY  uk_acao_usuario_tela (usuario_id, tela, acao),
    KEY         fk_acao_usuario_idx  (usuario_id),

    CONSTRAINT fk_acao_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES tb_usuarios (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8
  COMMENT='Permissoes de acoes por tela para cada usuario';

COMMIT;
