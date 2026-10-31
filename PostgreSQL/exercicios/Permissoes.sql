CREATE ROLE operacao;
CREATE ROLE gerencia;

CREATE SCHEMA vendas;

CREATE TABLE vendas.vendedor (
    id_vendedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE vendas.produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10,2) NOT NULL
);

CREATE TABLE vendas.venda (
    id_venda SERIAL PRIMARY KEY,
    id_vendedor INT REFERENCES vendas.vendedor(id_vendedor),
    id_produto INT REFERENCES vendas.produto(id_produto),
    quantidade INT NOT NULL
);

GRANT USAGE ON SCHEMA vendas TO operacao, gerencia;

-- dá permissão para leitura (select) em todas as tabelas do schema vendas para o grupo operacao.
GRANT SELECT ON ALL TABLES IN SCHEMA vendas TO operacao;

-- dá permissão de inserção (insert) apenas na tabela vendas.venda para o grupo operacao
GRANT INSERT ON vendas.venda TO operacao;


-- libera todas as operações de manipulação de dados em todas as tabelas do scheema vendas para o grupo gerencia. (ps: tbm existe o atalho GRANT ALL ON ALL TABLE...)
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA vendas TO gerencia;


ALTER DEFAULT PRIVILEGES IN SCHEMA vendas
GRANT SELECT ON TABLES TO operacao;

ALTER DEFAULT PRIVILEGES IN SCHEMA vendas
GRANT ALL ON TABLES TO gerencia;

CREATE USER joao WITH PASSWORD 'joao@2026';
CREATE USER maria WITH PASSWORD 'maria@2026';

GRANT operacao TO joao;
GRANT gerencia TO maria;


GRANT USAGE ON ALL SEQUENCES IN SCHEMA vendas TO operacao, gerencia;


/* ========================== */

SET ROLE maria;
INSERT INTO vendas.vendedor (nome) VALUES ('Carlos');
INSERT INTO vendas.produto (nome, preco) VALUES ('Notebook', 3500);

RESET ROLE;


SET ROLE joao;
-- funciona (operacao tem INSERT em venda e SELECT em tudo):
INSERT INTO vendas.venda (id_vendedor, id_produto, quantidade) VALUES (1, 1, 2);

-- vai dar ERRO (permission denied for table produto):
INSERT INTO vendas.produto (nome, preco) VALUES('Mouse', 80);

RESET ROLE;