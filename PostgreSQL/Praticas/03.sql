create table pessoas(
	id serial primary key,
	nome varchar(100) not null
);

create table profissoes(
	id serial primary key,
	profissao varchar(100) check(profissao in ('dev', 'professor', 'ator'))
	/*pessoa_id int references pessoas(id)*/
);

create table salarios(
	id serial primary key,
	salario int not null,
	pessoa_id int references pessoas(id),
	profissao_id int references profissoes(id)
);


insert into pessoas(nome)
values
('Jhean'),
('eduardo');

insert into profissoes(profissao)
values
('dev'),
/*('dev'),*/
('professor'),
('ator');

insert into salarios(pessoa_id, salario, profissao_id)
values (1, 3000, 1),
	   (2, 2100, 2),
	   (2, 4000, 3);




select * from salarios;
select * from pessoas;
select * from profissoes;

select 
	pessoas.nome,
	profissoes.profissao,
	salarios.salario
from pessoas
join salarios on pessoas.id = salarios.pessoa_id
join profissoes on salarios.profissao_id = profissoes.id;
