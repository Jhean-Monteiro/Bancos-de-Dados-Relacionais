/* =====================================================
   SIMULADO P1 - BANCO DE DADOS RELACIONAL
   Aluno: Jhean Monteiro
   ===================================================== */


/* =====================================================
   QUESTÃO 1 - Normalização e Criação das Tabelas
   ===================================================== */

/*
a) Problemas de normalização da tabela bruta:

1. REDUNDÂNCIA
   - O nome e a cidade do cliente se repetem toda vez que ele faz um pedido.
   - O nome, categoria e preço do produto também se repetem.

2. ANOMALIA DE ATUALIZAÇÃO
   - Se o cliente mudar de cidade, é preciso alterar em várias linhas.
   - Se o preço do produto mudar, também precisa alterar em várias linhas.
   Risco alto de ficar inconsistente.

3. ANOMALIA DE INSERÇÃO
   - Não dá para cadastrar um cliente novo sem ele ter feito um pedido.
   - Não dá para cadastrar um produto novo sem ele ter sido vendido.

4. ANOMALIA DE EXCLUSÃO
   - Se apagar o único pedido de um cliente, perde os dados do cliente também.
   - O mesmo acontece com produtos.

5. DEPENDÊNCIA PARCIAL (viola 2FN)
   - A chave seria (id_pedido, id_produto).
   - Porém nome_cliente e cidade dependem só de id_cliente.
   - nome_produto, categoria e preco_unitario dependem só de id_produto.

6. DEPENDÊNCIA TRANSITIVA (viola 3FN)
   - id_cliente → nome_cliente → cidade (cidade depende de algo que não é chave)
   - id_produto → nome_produto → categoria
*/


/* b e c) Modelo normalizado até 3FN + criação das tabelas */


-- Tabela de clientes
create table clientes (
	id_cliente serial primary key,
	nome_cliente varchar(100) not null,
	cidade varchar(100) not null
);

-- Tabela de Produtos
create table produtos(
	id_produto serial primary key,
	nome_produto varchar(100) not null,
	categoria varchar(50) not null,
	preco_unitario numeric(10,2) not null
);

-- Tabela de Pedidos
create table pedidos(
	id_pedido serial primary key,
	data_pedido date not null,
	id_cliente int not null references clientes(id_cliente),
	status_entrega varchar(20) not null
);

-- Tabela de Itens do Pedido (relacionamento N:N)
create table itens_pedido (
	id_pedido int not null references pedidos(id_pedido),
	id_produto int not null references produtos(id_produto),
	quantidade int not null check (quantidade > 0),
	primary key (id_pedido, id_produto)
);



/* QUESTÃO 2 - INSERÇÕES */
-- Inserindo os clientes da tabela bruta
insert into clientes(id_cliente, nome_cliente, cidade)
values
(101, 'Zé da Manga', 'Saquarema'),
(102, 'Goku buxa', 'Araruama'),
(103, 'Pandora', 'Bacaxá'),
(104, 'Juvenal do Mioral', 'Cabo Frio');

-- Inserindo os produtos da tabela bruta
insert into produtos(id_produto, nome_produto, categoria, preco_unitario)
values 
(201, 'Sanduiche Natural', 'Lanche', 12.00),
(202, 'Suco de laranja', 'bebida', 7.50),
(203, 'Bolo de Chocolate', 'Sobremesa', 8.00),
(204, 'Café Expresso', 'Bebida', 5.00);

-- Inserindo os pedidos da tabbela bruta
insert into pedidos(id_pedido, data_pedido, id_cliente, status_entrega)
values
(1, '2025-03-10', 101, 'Entregue'),
(2, '2025-03-10', 102, 'Pendente'),
(3, '2025-03-11', 101, 'Entregue'),
(4, '2025-03-12', 103, 'Cancelado'),
(5, '2025-03-12', 104, 'Entregue');

-- Inserindo os itens dos pedidos
insert into itens_pedido (id_pedido, id_produto, quantidade)
values
(1,201,2),
(2,202,1),
(3,203,3),
(4,201,1),
(5,204,2);


-- ========== REGISTROS EXTRAS ============
-- novo cliente
insert into clientes(nome_cliente, cidade)
values ('Jhean Monteiro', 'Saquarema');

-- novo produto
INSERT INTO produtos (nome_produto, categoria, preco_unitario) values
('Agua Mineral', 'Bebida', 3.00);

-- novo pedido
insert into pedidos(data_pedido, id_cliente, status_entrega)
values 
('2025-03-13', 1, 'Entregue');

insert into itens_pedido (id_pedido, id_produto, quantidade)
values
(7,1,2);

-- pedido novo com status pendente
insert into pedidos (data_pedido, id_cliente, status_entrega)
values
('2025-03-13', 102, 'Pendente');

insert into itens_pedido (id_pedido, id_produto, quantidade) values
(7, 202, 1);



/* QUESTÂO 3 - Atualizações e DELEÇÕES */
-- a) Atualizar a cidade de um cliente
update clientes
set cidade = 'Rio de Janeiro'
where id_cliente = 101;


-- b) Excluir o pedido com status cancelado
-- Ordem correta: primeiro os itens, depois o pedido, por causa da FK
delete from itens_pedido
where id_pedido = 4;

delete from pedidos
where id_pedido = 4;


/* QUESTÃO 4 - Funções Agregadoras */

-- a) Quantidade total de pedidos de um cliente (exemplo: cliente 101)
select count (*)
from pedidos
where id_cliente = 101;

-- b) valor total vendido dos pedidos com status entregue
select SUM(produtos.preco_unitario * itens_pedido.quantidade)
from pedidos
join itens_pedido on pedidos.id_pedido = itens_pedido.id_pedido
join produtos on itens_pedido.id_produto = produtos.id_produto
where pedidos.status_entrega = 'Entregue';



/* QUESTÃO 5 - Consulta com JOIN */
select
	clientes.id_cliente,
	clientes.nome_cliente,
	clientes.cidade,
	pedidos.id_pedido,
	pedidos.data_pedido,
	produtos.id_produto,
	produtos.nome_produto,
	produtos.categoria,
	itens_pedido.quantidade,
	pedidos.status_entrega
from clientes
join pedidos on clientes.id_cliente = pedidos.id_cliente
join itens_pedido on pedidos.id_pedido = itens_pedido.id_pedido
join produtos on itens_pedido.id_produto = produtos.id_produto;