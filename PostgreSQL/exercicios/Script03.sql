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

select * from aluno
