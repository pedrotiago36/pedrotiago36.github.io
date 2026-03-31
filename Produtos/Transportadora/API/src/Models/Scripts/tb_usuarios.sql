-- =============================================================
--  SCRIPT: tb_usuarios.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.7+
--  Obs    : Executar APÓS tb_perfis.sql
-- =============================================================

USE dtll_Transportadora;

CREATE TABLE IF NOT EXISTS tb_usuarios (
    id             INT(11)      NOT NULL AUTO_INCREMENT,
    login          VARCHAR(50)  NOT NULL,
    senha          VARCHAR(255) NOT NULL              COMMENT 'SHA-256 hash',
    is_admin       TINYINT(1)   NOT NULL DEFAULT 0,
    perfil_id      INT(11)          NULL              COMMENT 'FK -> tb_perfis.id',
    ativo          TINYINT(1)   NOT NULL DEFAULT 1,
    dt_cadastro    DATETIME     NOT NULL,
    dt_atualizacao DATETIME         NULL,

    PRIMARY KEY (id),
    UNIQUE KEY  uk_usuario_login  (login),
    KEY         idx_usuario_ativo (ativo),
    KEY         fk_usuario_perfil_idx (perfil_id),

    CONSTRAINT fk_usuario_perfil
        FOREIGN KEY (perfil_id)
        REFERENCES tb_perfis (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Usuários do sistema';

-- Usuário admin inicial (senha: admin123 — trocar em produção)
INSERT IGNORE INTO tb_usuarios (login, senha, is_admin, dt_cadastro)
VALUES (
    'admin',
    '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    1,
    NOW()
);

COMMIT;