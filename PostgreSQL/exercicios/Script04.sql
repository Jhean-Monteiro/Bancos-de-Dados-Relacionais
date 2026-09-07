-- =============================================
-- 1. CRIAÇÃO DAS TABELAS (DDL)
-- =============================================

-- Tabela Clientes (exemplo da aula)
CREATE TABLE Clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    data_nascimento DATE
);

-- Tabela Contas (exemplo de transação)
CREATE TABLE Contas (
    id SERIAL PRIMARY KEY,
    titular VARCHAR(100) NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL
);

-- Tabelas auxiliares para os exemplos de JOIN e agregação
CREATE TABLE Produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(50)
);

CREATE TABLE Pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES Clientes(id),
    produto_id INTEGER REFERENCES Produtos(id),
    quantidade INTEGER DEFAULT 1,
    data_pedido DATE DEFAULT CURRENT_DATE
);

-- =============================================
-- 2. INSERÇÃO DE DADOS (DML)
-- =============================================

-- Clientes (exemplo da aula)
INSERT INTO Clientes (nome, email, data_nascimento) VALUES
('Zé das Couves', 'zecouves@email.com', '1980-01-15'),
('Zé da Manga', 'zemanga@email.com', '1985-04-10'),
('Zé do Milho', 'zemilho@email.com', '1990-06-25'),
('Zé do Picolé', 'zepicole@email.com', '1975-09-05'),
('Zé da Padaria', 'zepadaria@email.com', '1983-12-30');

-- Contas
INSERT INTO Contas (titular, saldo) VALUES
('Zé das Couves', 500.00),
('Zé da Manga', 300.00);

-- Produtos (para agregação e JOIN)
INSERT INTO Produtos (nome, preco, categoria) VALUES
('Notebook Gamer', 4500.00, 'Eletrônicos'),
('Smartphone', 1800.00, 'Eletrônicos'),
('Mouse', 89.90, 'Eletrônicos'),
('Caderno', 15.50, 'Papelaria'),
('Caneta', 3.20, 'Papelaria');

-- Pedidos (para JOIN)
INSERT INTO Pedidos (cliente_id, produto_id, quantidade) VALUES
(1, 1, 1),
(1, 3, 2),
(2, 2, 1),
(3, 1, 1),
(4, 4, 5);

-- =============================================
-- 3. CONSULTAS (SELECT + filtros + agregação)
-- =============================================

-- Exemplo da aula: clientes nascidos antes de 1990
SELECT nome, email
FROM Clientes
WHERE data_nascimento < '1990-01-01';

-- Agregação (exemplo da aula adaptado)
SELECT COUNT(*) AS total_produtos,
       AVG(preco) AS media_preco
FROM Produtos
WHERE categoria = 'Eletrônicos';

-- =============================================
-- 4. JOINs
-- =============================================

SELECT 
    Pedidos.id AS pedido_id,
    Clientes.nome AS cliente,
    Produtos.nome AS produto,
    Pedidos.quantidade
FROM Pedidos
INNER JOIN Clientes ON Pedidos.cliente_id = Clientes.id
INNER JOIN Produtos ON Pedidos.produto_id = Produtos.id;

-- =============================================
-- 5. MANIPULAÇÃO DE DADOS (DML)
-- =============================================

-- Insert
INSERT INTO Clientes (nome, email, data_nascimento)
VALUES ('Zé do Pastel', 'zepastel@email.com', '1992-03-20');

-- Update
UPDATE Clientes
SET email = 'novoemailmilho@email.com'
WHERE nome = 'Zé do Milho';

-- Delete
DELETE FROM Clientes
WHERE nome = 'Zé da Padaria';

-- =============================================
-- 6. CONTROLE DE TRANSAÇÕES (TCL)
-- =============================================

BEGIN;
    UPDATE Contas SET saldo = saldo - 100 WHERE id = 1;  -- Zé das Couves
    UPDATE Contas SET saldo = saldo + 100 WHERE id = 2;  -- Zé da Manga
COMMIT;