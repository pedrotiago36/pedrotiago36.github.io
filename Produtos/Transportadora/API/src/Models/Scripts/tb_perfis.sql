-- =============================================================
--  SCRIPT: tb_perfis.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.7+
--  Obs    : Executar ANTES de tb_usuarios.sql (FK depende desta)
-- =============================================================

USE dtll_Transportadora;

CREATE TABLE IF NOT EXISTS tb_perfis (
    id             INT(11)      NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    descricao      VARCHAR(255)     NULL,
    ativo          TINYINT(1)   NOT NULL DEFAULT 1,
    dt_cadastro    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_atualizacao DATETIME         NULL ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uk_perfil_nome (nome),
    KEY        idx_perfil_ativo (ativo)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Perfis de acesso do sistema';

COMMIT;
