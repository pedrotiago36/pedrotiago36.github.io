-- =============================================================
--  SCRIPT: tb_permissoes_perfis.sql
--  Banco  : dtll_Transportadora
--  MySQL  : 5.1+
--  Obs    : Executar APOS tb_perfis.sql
--           Armazena as rotas de menu que cada perfil pode acessar
-- =============================================================

USE dtll_Transportadora;

CREATE TABLE IF NOT EXISTS tb_permissoes_perfis (
    id        INT(11)      NOT NULL AUTO_INCREMENT,
    perfil_id INT(11)      NOT NULL COMMENT 'FK -> tb_perfis.id',
    rota      VARCHAR(100) NOT NULL COMMENT 'Rota do menu (ex: cad.clientes)',

    PRIMARY KEY (id),
    UNIQUE KEY  uk_perm_perfil_rota (perfil_id, rota),
    KEY         fk_permperfil_idx   (perfil_id),

    CONSTRAINT fk_perm_perfil
        FOREIGN KEY (perfil_id)
        REFERENCES tb_perfis (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Permissoes de acesso por perfil (rotas liberadas)';

COMMIT;
