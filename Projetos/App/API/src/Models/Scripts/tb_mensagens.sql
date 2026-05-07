-- =============================================================
-- Tabela: tb_mensagens
-- Chat entre aluno e professor
-- remetente: 'aluno' | 'professor'
-- lida=0 -> nao lida pelo destinatario
-- =============================================================
CREATE TABLE IF NOT EXISTS tb_mensagens (
  id              INT          NOT NULL AUTO_INCREMENT,
  aluno_matricula VARCHAR(50)  NOT NULL,
  aluno_nome      VARCHAR(100) NOT NULL,
  professor_id    INT          NOT NULL,
  texto           TEXT         NOT NULL,
  remetente       ENUM('aluno','professor') NOT NULL DEFAULT 'aluno',
  lida            TINYINT(1)   NOT NULL DEFAULT 0,
  dt_envio        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_professor  (professor_id),
  KEY idx_aluno_prof (aluno_matricula, professor_id),
  KEY idx_nao_lidas  (professor_id, remetente, lida),
  CONSTRAINT fk_msg_professor FOREIGN KEY (professor_id)
    REFERENCES tb_professores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
