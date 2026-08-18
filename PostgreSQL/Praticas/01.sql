create table Clientes(
	ClienteID SERIAL primary key,
	ClienteNome VARCHAR(255),
	ClienteTelefone VARCHAR(20)
);

create table Produtos(
	ProdutoID SERIAL primary key,
	ProdutoNome VARCHAR(255),
	ProdutoPreco DECIMAL(10, 2)
);

create table Pedidos (
	PedidoID SERIAL primary key,
	ClienteID int REFERENCES Clientes(ClienteID),
	ProdutoID int REFERENCES Produtos(ProdutoID),
	Quantidade INT
);

insert into Clientes(ClienteNome, ClienteTelefone)
values ('Jhean', 22999516809),
	   ('Ze da manga', 123456789);

insert into Produtos(ProdutoNome, ProdutoPreco)
values ('Notebook', 3500),
	   ('Smartphone', 2000),
	   ('Impressora', 900);


insert into Pedidos(ClienteID, ProdutoID, Quantidade)
values (1, 1, 1),
       (2, 2, 2),
       (1, 3, 1);

select 
	Pedidos.PedidoID,
	Clientes.ClienteNome,
	Clientes.ClienteTelefone,
	Produtos.ProdutoNome,
	Produtos.ProdutoPreco,
	Pedidos.Quantidade
from
	Pedidos
join
	Clientes on Pedidos.ClienteID = Clientes.ClienteID
join 
	Produtos on Pedidos.ProdutoID = Produtos.ProdutoID
order by
	Pedidos.PedidoID;


select * from Pedidos;
