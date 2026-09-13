create table clientes(
	id_cliente serial primary key,
	nome_cliente varchar(100) not null,
	cidade varchar(100) not null
);

insert into clientes(nome_cliente, cidade) values
('Jhean Monteiro', 'Saquarema'),
('Zé da Manga', 'Zé do Manguistão');


create table jogos(
	id_jogo serial primary key,
	nome_jogo varchar(100) not null,
	genero varchar(100) not null,
	preco numeric(10,2) not null
);

insert into jogos(nome_jogo, genero, preco)
values
('Joguin', 'Esporte', 350.00),
('GTA 15', 'Ação', 3900.00);


create table vendas(
	id_venda serial primary key,
	data_venda date not null,
	cliente_id int references clientes(id_cliente),
	status_pagamento varchar(20) check(status_pagamento in ('Pago', 'Pendente', 'Cancelado'))
);

insert into vendas(data_venda, cliente_id, status_pagamento)
values
('2026-01-30', 1, 'Pago'),
('2026-02-28', 2, 'Pendente');

update vendas
set status_pagamento = 'Pago'
where cliente_id = 2;

create table itens_venda(
	id_venda int references vendas(id_venda),
	id_jogo int references jogos(id_jogo),
	quantidade int check (quantidade > 0),
	primary key (id_venda, id_jogo)
);

insert into itens_venda(id_venda, id_jogo, quantidade)
values
(3, 1, 2),
(4, 2, 1);


update clientes
set nome_cliente = 'Jhean Silva'
where nome_cliente = 'Jhean Monteiro';


select
	vendas.id_venda,
	vendas.data_venda,
	clientes.id_cliente,
	clientes.nome_cliente,
	clientes.cidade,
	jogos.id_jogo,
	jogos.nome_jogo,
	jogos.genero,
	jogos.preco,
	itens_venda.quantidade,
	vendas.status_pagamento
from clientes
join vendas on vendas.cliente_id = clientes.id_cliente
join itens_venda on itens_venda.id_venda = vendas.id_venda
join jogos on jogos.id_jogo = itens_venda.id_jogo;


-- 1º apaga os itens da venda
DELETE FROM itens_venda
WHERE id_venda = 2;

-- 2º agora pode apagar a venda
DELETE FROM vendas
WHERE id_venda = 2;

-- quantas vendas o cliente 1 fez
select count(*)
from vendas
where cliente_id = 1;

-- valor total venido (preco x quantidade) das vendas pagas
select sum(jogos.preco * itens_venda.quantidade)
from vendas
join itens_venda on vendas.id_venda = itens_venda.id_venda
join jogos on itens_venda.id_jogo = jogos.id_jogo
where vendas.status_pagamento = 'Pago';