-- tabela dos professores
create table professores (
	id_professor SERIAL primary key,
	nome varchar(100) not null,
	email varchar(100) unique,
	departamento varchar(100)
);


-- salas
create table salas (
	id_salas serial primary key,
	numero_sala varchar(20) not null,
	capacidade int check (capacidade > 0),
	localizacao varchar(100)
);


-- cursos_disciplinas (depede de professor)
create table cursos_disciplinas (
	id_curso serial primary key,
	nome_curso varchar(100) not null,
	codigo varchar(20) unique,
	disciplina varchar(20),
	periodo varchar(20),
	professor_id int references professores(id_professor)
);

-- alunos (depende de cursos_disciplinas)
create table alunos (
	id_aluno SERIAL PRIMARY key,
	nome varchar(100) not null,
	matricula varchar(20) unique not null,
	email varchar(100) unique,
	curso_id int references cursos_disciplinas(id_curso)
);


-- ensalamento 
create table ensalamento (
	id_ensalamento serial primary key,
	curso_id int references cursos_disciplinas(id_curso),
	sala_id int references salas(id_sala),
	professor_id int references professores(id_professor),
	data_hora timestamp
);


INSERT INTO professores (nome, email, departamento) VALUES
('Diego Ramos Inácio', 'diego.inacio@univassouras.edu.br', 'Engenharia de Software'),
('Maria', 'maria@univassouras.edu.br', 'Ciência da Computação');

INSERT INTO salas (numero_sala, capacidade, localizacao) VALUES
('4', 60, 'polo 2 - 1º Andar'),
('205', 30, 'polo 3 - 2º Andar');

INSERT INTO cursos_disciplinas (nome_curso, codigo, disciplina, periodo, professor_id) VALUES
('Engenharia de Software', 'ES01', 'Banco de Dados Relacional', '2026.1', 1),
('Ciência da Computação', 'CC01', 'Estrutura de Dados', '2025.1', 2);

INSERT INTO alunos (nome, matricula, email, curso_id) VALUES
('Jhean Monteiro', '2025001', 'jhean@email.com', 1),
('Luana Silva', '2025002', 'luana@email.com', 1),
('João Costa', '2025003', 'joao@email.com', 2);

INSERT INTO ensalamento (curso_id, sala_id, professor_id, data_hora) VALUES
(1, 1, 1, '2025-05-16 08:00:00'),
(2, 2, 2, '2025-05-16 10:00:00');



select * from alunos;