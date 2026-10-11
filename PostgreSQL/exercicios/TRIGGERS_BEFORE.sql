CREATE OR REPLACE FUNCTION checa_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantidade > (SELECT estoque FROM produto WHERE id_produto = NEW.id_produto) THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto %', NEW.id_produto;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_checa_estoque
BEFORE INSERT ON vendas
FOR EACH ROW
EXECUTE FUNCTION checa_estoque();


INSERT INTO vendas (id_vendedor, id_produto, quantidade)
VALUES (1, 1, 5);

INSERT INTO vendas (id_vendedor, id_produto, quantidade)
VALUES (1, 1, 999);
