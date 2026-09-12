create table produtos(
	id serial primary key,
	nome varchar(100) not null,
	quantidade int not null check(quantidade > 0)
);

create table loja(
	id serial primary key,
	nome varchar(100) not null,
	produto_id int references produtos(id)
);

insert into produtos(nome, quantidade)
values 
('bala', 50),
('chocolate', 35);

insert into loja(nome, produto_id)
values ('Loja de doce', 1);



select * from produtos;
select * from loja;


select sum (quantidade)
from produtos
where id in (
	select id from produtos where id = 1
);

select sum (quantidade)
from produtos
where id in (
	select id from produtos where id = 2
);

select count (quantidade)
from produtos
where id in (
	select id from produtos where id = 1
);


select count (*)
from produtos
where id in (
	select id from produtos where nome in ('bala') -- adicionei 4 vezes pra ver o resultado diferente
);