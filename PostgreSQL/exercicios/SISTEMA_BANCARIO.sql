CREATE TABLE contas (
    id_conta SERIAL PRIMARY KEY,
    titular VARCHAR(200) NOT NULL,
    saldo NUMERIC(10,2) NOT NULL
);

CREATE TABLE transacoes (
    id_transacao SERIAL PRIMARY KEY,
    id_conta INT REFERENCES contas(id_conta),
    tipo varchar(50) CHECK (tipo IN ('depositar', 'sacar')),
    valor NUMERIC(10,2) CHECK (valor > 0) NOT NULL,
    dia DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO contas (titular, saldo)
VALUES
('Jhean Monteiro', 1500.00),
('Luiz Gustavo', 5000.00);



CREATE OR REPLACE FUNCTION checa_saldo()
RETURNS TRIGGER 
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.tipo = 'sacar' AND NEW.valor > (select saldo from contas WHERE id_conta = NEW.id_conta) THEN
        RAISE EXCEPTION 'saldo insuficiente na conta';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- o gatilho (trigger) que dispara a função
CREATE TRIGGER trg_checa_saldo
BEFORE INSERT ON transacoes
FOR EACH ROW
EXECUTE FUNCTION checa_saldo();


CREATE VIEW vw_extrato_transacoes AS 
SELECT
    c.titular,
    t.tipo,
    t.valor,
    t.dia
FROM transacoes t 
JOIN contas c ON t.id_conta = c.id_conta;



-- criação dos perfis (roles) e usuários
CREATE ROLE atendente;
CREATE ROLE gerente;

CREATE USER beto WITH PASSWORD 'caixa123';
CREATE USER alfredo WITH PASSWORD 'gerente123';

GRANT atendente TO beto;
GRANT gerente TO alfredo;

-- permissçoes (grants)
-- concede uso do schema public
GRAnT USAGE ON SCHEMA public TO atendente, gerente;

-- atendente: só enxerga a view (menor privilegio)
GRANT SELECT ON vw_extrato_transacoes TO atendente;

-- gerente: pode consultar e inserir nas tabelas
GRANT SELECT, INSERT ON contas, transacoes TO gerente;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public  TO gerente;


/* TESTES DE FUNCIONAMENTP */
SET ROLE beto;
SELECT * FROM vw_extrato_transacoes; -- sucesso

SELECT * from contas; -- permissão negada (pela role)
RESET ROLE;


SET ROLE alfredo;
INSERT INTO transacoes (id_conta, tipo, valor) 
VALUES (1, 'sacar', 100.00); -- sucesso (tem saldo)

INSERT INTO transacoes (id_conta, tipo, valor)
VALUES (1, 'sacar', 9999.00); -- erro (saldo insuficiente) - barrado na função do trigger
RESET ROLE;