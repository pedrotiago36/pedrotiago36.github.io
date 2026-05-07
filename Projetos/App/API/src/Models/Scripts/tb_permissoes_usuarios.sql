-- =============================================================
--  SCRIPT: tb_permissoes_usuarios.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.7+
--  Obs    : Executar APÓS tb_usuarios.sql
-- =============================================================

USE dtll_Transportadora;

CREATE TABLE IF NOT EXISTS tb_permissoes_usuarios (
    id         INT(11)      NOT NULL AUTO_INCREMENT,
    usuario_id INT(11)      NOT NULL              COMMENT 'FK -> tb_usuarios.id',
    rota       VARCHAR(100) NOT NULL              COMMENT 'Rota do menu (ex: cfg.usuario)',

    PRIMARY KEY (id),
    UNIQUE KEY  uk_perm_usuario_rota (usuario_id, rota),
    KEY         fk_perm_usuario_idx (usuario_id),

    CONSTRAINT fk_perm_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES tb_usuarios (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Permissões de acesso por usuário (rotas liberadas)';

COMMIT;
