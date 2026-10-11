CREATE TABLE vendedor (
    id_vendedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0
);


CREATE TABLE vendas (
    id_venda SERIAL PRIMARY KEY,
    id_vendedor INT REFERENCES vendedor(id_vendedor),
    id_produto INT REFERENCES produto(id_produto),
    quantidade INT NOT NULL,
    data_venda TIMESTAMP DEFAULT NOW()
);

CREATE TABLE log_vendas (
    id_log SERIAL PRIMARY KEY,
    id_venda INT,
    id_vendedor INT,
    nome_vendedor VARCHAR(100),
    quantidade INT,
    data_log TIMESTAMP DEFAULT NOW()
);


CREATE OR REPLACE FUNCTION log_venda()
RETURNS TRIGGER AS $$
DECLARE 
    v_nome vendedor.nome%TYPE;
BEGIN
    SELECT nome INTO v_nome
    FROM vendedor
    WHERE id_vendedor = NEW.id_vendedor;

    INSERT INTO log_vendas
        (id_venda, id_vendedor, nome_vendedor, quantidade, data_log)
        VALUES
            (NEW.id_venda, NEW.id_vendedor, v_nome, NEW.quantidade, NOW());

        RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_log_venda
AFTER INSERT ON vendas
FOR EACH ROW
EXECUTE FUNCTION log_venda();




INSERT INTO vendedor (nome) VALUES ('Carlos Silva');
INSERT INTO produto (nome, preco, estoque) VALUES
  ('Teclado Mecânico', 250.00, 20);
    
INSERT INTO vendas (id_vendedor, id_produto, quantidade)
VALUES (1, 1, 2);
    
SELECT * FROM vendas;
SELECT * FROM log_vendas;