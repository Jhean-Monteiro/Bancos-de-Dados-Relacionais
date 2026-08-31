/* MODELAGEM BANCO DE DADOS DE AUTO ESCOLA */

-- tabela de categoria
CREATE TABLE categoria (
    id SERIAL primary key,
    categoria VARCHAR(10) not null -- A, B, AB, C, D, E -> definição de categoria
);

-- tabela de usuário
CREATE TABLE aluno(
	id SERIAL PRIMARY KEY,
	nome VARCHAR(100) NOT NULL,
	nasc DATE NOT NULL,
	cpf VARCHAR(11) NOT NULL UNIQUE,
	telefone VARCHAR(20) NOT NULL,
	email varchar(200) NOT null,
	categ_id INT REFERENCES categoria(id)
);

-- tabela de Veiculo
create table auto(
	id SERIAL primary key,
	placa VARCHAR(8) not null unique,
	modelo VARCHAR(10) not null,
	marca VARCHAR(15) not null,
	ano DATE not null,
	categoria VARCHAR(10) not null 
);

-- tabela de instrutores
create table instrutor(
	id SERIAL primary key,
	nome VARCHAR(100) not null,
	cpf VARCHAR(11) NOT NULL UNIQUE,
	telefone VARCHAR(20) NOT NULL,
	email varchar(200) NOT null,
	categ_id INT REFERENCES categoria(id)
);

-- tabela de aula
create table aula(
	id SERIAL primary key,
	nome VARCHAR(100) not null unique,
	modalidades VARCHAR(10) not null,
	id_instrutor int references instrutor(id),
	id_aluno int references aluno(id),
	id_auto int references auto(id)
);


insert into categoria(categoria) 
values
	('acc'),
	('A'),
	('B'),
	('AB'),
	('C'),
	('D'),
	('E');

-- subquery
insert into aluno(nome, cpf, nasc, telefone, email, categ_id)
values
	('Jorge', '12345678909', '1976-05-24', '1234444498', 'jorge@email.com', (select id from categoria where categoria = 'D'));

select * from aluno;




-- ===========================================================
--       CONTINUAÇÃO DO EXERCÍCIO
-- =========================================================== 
 
-- mais alunos, para termos dados o suficiente pros joins
insert into aluno(nome, cpf, nasc, telefone, email, categ_id)
values
	('Maria', '98765432100', '1990-03-15', '21988887777', 'maria@email.com', (select id from categoria where categoria = 'B')),
	('Carlos', '45612378909', '2001-11-02', '21977776666', 'carlos@email.com', (select id from categoria where categoria = 'A'));
 
-- instrutores (usando subquery pra pegar o id da categoria pelo nome dela)
insert into instrutor(nome, cpf, telefone, email, categ_id)
values
	('Roberto Silva', '11122233344', '21966665555', 'roberto@autoescola.com', (select id from categoria where categoria = 'D')),
	('Ana Souza', '55566677788', '21955554444', 'ana@autoescola.com', (select id from categoria where categoria = 'B')),
	('Paulo Lima', '99988877766', '21944443333', 'paulo@autoescola.com', (select id from categoria where categoria = 'A'));
 
-- veículos usados nas aulas práticas
insert into auto(placa, modelo, marca, ano, categoria)
values
	('ABC1234', 'Onix', 'Chevrolet', '2022-01-01', 'B'),
	('XYZ9876', 'Gol', 'Volkswagen', '2020-01-01', 'B'),
	('MTO1122', 'CG 160', 'Honda', '2021-01-01', 'A');
 
-- aulas: teóricas (sem carro) e práticas (com carro), usando subquery pra achar
-- o id do aluno, do instrutor e do auto pelos seus atributos "naturais"
insert into aula(nome, modalidades, id_instrutor, id_aluno, id_auto)
values
	(
		'Legislação de Trânsito',
		'teorica',
		(select id from instrutor where nome = 'Roberto Silva'),
		(select id from aluno where nome = 'Jorge'),
		null
	),
	(
		'Direção Veicular B',
		'pratica',
		(select id from instrutor where nome = 'Ana Souza'),
		(select id from aluno where nome = 'Maria'),
		(select id from auto where placa = 'ABC1234')
	),
	(
		'Primeiros Socorros',
		'teorica',
		(select id from instrutor where nome = 'Paulo Lima'),
		(select id from aluno where nome = 'Carlos'),
		null
	),
	(
		'Direção Moto A',
		'pratica',
		(select id from instrutor where nome = 'Paulo Lima'),
		(select id from aluno where nome = 'Carlos'),
		(select id from auto where placa = 'MTO1122')
	);
 
 
/* ===========================================================
   JOIN FINAL
   =========================================================== */
 
select
	al.nome        as nome_aluno,
	au.nome        as nome_aula,
	ins.nome       as nome_instrutor,
	au.modalidades as modalidade,
	v.modelo       as modelo_carro,
	v.placa        as placa_carro,
	v.ano          as ano_carro
from aula au
join aluno al      on al.id  = au.id_aluno
join instrutor ins on ins.id = au.id_instrutor
left join auto v   on v.id   = au.id_auto
order by au.nome;