-- Script para MySQL 5.1
CREATE DATABASE IF NOT EXISTS dtll_Transportadora;

USE dtll_Transportadora;

-- Tabela de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT(11) NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    login VARCHAR(50) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    administrador TINYINT(1) NOT NULL DEFAULT 0,
    perfil VARCHAR(50),
    data_cadastro DATETIME NOT NULL,
    data_atualizacao DATETIME,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uk_login (login),
    UNIQUE KEY uk_email (email),
    KEY idx_administrador (administrador),
    KEY idx_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Inserir usuario de teste (senha: 123456)
-- Hash gerado com TSecurityService.GerarHashSenha('123456')
INSERT INTO usuarios (nome, email, senha, data_cadastro) 
VALUES ('Admin Teste', 'admin@teste.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', NOW());

-- Commit
COMMIT;