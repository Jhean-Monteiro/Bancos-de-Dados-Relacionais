create table pessoas(
	id serial primary key,
	nome varchar(50)
);

create table telefones (
	id serial primary key,
	pessoa_id int references pessoas(id),
	numero varchar(20)
);


insert into pessoas(nome) values
('Pedro'),
('Luiz');

insert into telefones (pessoa_id, numero) values
(1, '9999-1111'),
(1, '9999-2222'),
(2, '9888-3333');

select
	pessoas.id,
	pessoas.nome,
	telefones.numero,
	telefones.id
from pessoas
join telefones on pessoas.id = telefones.pessoa_id;