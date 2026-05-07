-- =============================================================
-- Tabela: tb_professores
-- Cadastro de professores da escola
-- =============================================================
CREATE TABLE IF NOT EXISTS tb_professores (
  id             INT          NOT NULL AUTO_INCREMENT,
  nome           VARCHAR(100) NOT NULL,
  serie          VARCHAR(50)  NOT NULL,
  turma          VARCHAR(10)  NOT NULL,
  ativo          TINYINT(1)   NOT NULL DEFAULT 1,
  dt_cadastro    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dt_atualizacao TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
