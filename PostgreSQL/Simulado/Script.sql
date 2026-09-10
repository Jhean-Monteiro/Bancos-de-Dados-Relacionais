-- Tabela Clientes (3FN)
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome_cliente VARCHAR(100) NOT NULL,
    cpf_cliente VARCHAR(11)  NOT NULL UNIQUE,
    email_cliente VARCHAR(100) NOT NULL
);

-- Tabela Produtos (3FN)
CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    descricao_produto VARCHAR(150) NOT NULL,
    preco_produto NUMERIC(10,2) NOT NULL
);

-- Tabela Pedidos (3FN)
CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,
    data_pedido DATE NOT NULL,
    id_cliente INT REFERENCES clientes(id_cliente)
);

-- Tabela Itens_dos_Pedidos (3FN)
CREATE TABLE itens_dos_pedidos (
    id_pedido INT NOT NULL REFERENCES pedidos(id_pedido),
    id_produto INT NOT NULL REFERENCES produtos(id_produto),
    quantidade INT NOT NULL CHECK (quantidade > 0),
    total_item NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_produto)
);



/* Inserções */

-- inserindo os clientes
insert into clientes (nome_cliente, cpf_cliente, email_cliente)
values 
('João Silva', '12345678901', 'joao@email.com'),
('José da Silva', '12345678910', 'jose@email.com'),
('Maria Souza', '98765432109', 'maria@email.com');

-- inserindo  os produtos
insert into produtos(descricao_produto, preco_produto)
values 
('Notebook Dell', 5200.00),
('Mouse Wireless', 120.00),
('Teclado Mecânico', 250.00),
('Notebook Lenovo', 3500.00),
('Mouse Wireless G2', 135.00),
('Teclado Mecânico G2', 265.00);


-- inserindo os pedidos
insert into pedidos(data_pedido, id_cliente)
values
('2023-05-10', 1),
('2023-05-10', 2),
('2023-05-11', 3),
('2023-05-10', 1),
('2023-05-10', 2),
('2023-05-11', 3);

-- inserindo os itens dos pedidos
insert into itens_dos_pedidos (id_pedido, id_produto, quantidade, total_item)
values
(1, 1, 2, 10400.00),
(2, 2, 1, 120.00),
(3, 3, 3, 750.00),
(4, 4, 1, 3500.00),
(5, 5, 3, 405.00),
(6, 6, 2, 530.00);



-- Novo cliente
INSERT INTO clientes (nome_cliente, cpf_cliente, email_cliente) VALUES
('Jhean Monteiro', '11122233344', 'jhean.email@email.com');

-- Novo produto
INSERT INTO produtos (descricao_produto, preco_produto) VALUES
('Headset Gamer', 450.00);

-- Novo pedido do aluno (vai pegar o id_cliente = 4 automaticamente)
INSERT INTO pedidos (data_pedido, id_cliente) VALUES
('2023-05-12', 4);

-- Item do pedido (id_pedido e id_produto vão ser 7)
INSERT INTO itens_dos_pedidos (id_pedido, id_produto, quantidade, total_item) VALUES
(7, 7, 1, 450.00);


SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM pedidos;
SELECT * FROM itens_dos_pedidos;


SELECT * FROM itens_dos_pedidos ORDER BY id_pedido;



/* UPDATE E DELETE */

-- atualizando email de um cliente
update clientes
set email_cliente = 'joao.silva@email.com'
where id_cliente = 1;

-- atualizando o preço de um produto
update produtos
set preco_produto = 5300.00
where id_produto = 1;

-- atualizando a data de um pedido
update pedidos
set data_pedido = '2023-05-13'
where id_pedido = 8;


-- atualizando quantidade e total de um item
update itens_dos_pedidos
set quantidade = 2,
	total_item = 500.00
where id_pedido = 8 and id_produto = 3;


-- delete respeitando as chaves estrangeiras
-- ordem correta: primeiro apaga os itens, depois o pedido

-- excluindo o pedido 8
delete from itens_dos_pedidos
where id_pedido = 8;

delete from pedidos
where id_pedido = 8;



/* count e sum */
-- 1o caso: quantos produtos um cliente comprou
-- (exemplo com o cliente de id = 1 - João Silva)

select count(id_produto)
from itens_dos_pedidos
where id_pedido in (
	select id_pedido
	from pedidos
	where id_cliente = 1
);


-- 2o caso: lucro do dia 10/05/2023
select sum(total_item)
from itens_dos_pedidos
where id_pedido in (
	select id_pedido
	from pedidos
	where data_pedido = '2023-05-10'
);


/* JOIN */
select 
	clientes.id_cliente,
    clientes.nome_cliente,
    clientes.cpf_cliente,
    clientes.email_cliente,
    itens_dos_pedidos.id_produto,
    pedidos.data_pedido,
    produtos.descricao_produto,
    produtos.preco_produto,
    itens_dos_pedidos.quantidade,
    itens_dos_pedidos.total_item
FROM clientes
JOIN pedidos ON clientes.id_cliente = pedidos.id_cliente
JOIN itens_dos_pedidos ON pedidos.id_pedido = itens_dos_pedidos.id_pedido
JOIN produtos ON itens_dos_pedidos.id_produto = produtos.id_produto;