CREATE TABLE cursos (
	id SERIAL PRIMARY KEY,
	nome_curso VARCHAR(100)
);


ALTER TABLE alunos 
ADD COLUMN curso_id INT REFERENCES cursos(id);


SELECT * FROM alunos;

INSERT INTO cursos (nome_curso) VALUES
('Engenharia de Software'),
('Design Gráfico'),
('Administração');

SELECT * FROM cursos;

UPDATE alunos SET curso_id = 1 WHERE nome = 'Maria';
UPDATE alunos SET curso_id = 1 WHERE nome = 'Jhean Monteiro';
UPDATE alunos SET curso_id = 2 WHERE nome = 'Ana';

SELECT alunos.nome, alunos.idade, cursos.nome_curso
FROM alunos
JOIN cursos ON alunos.curso_id = cursos.id;

SELECT alunos.nome, alunos.idade, cursos.nome_curso
FROM alunos
LEFT JOIN cursos ON alunos.curso_id = cursos.id;

SELECT * FROM alunos;

/*
RELACIONANDO TABELAS
=================================
 
1. ALTER TABLE - modificar tabela existente
---------------------------------
ALTER TABLE alunos
ADD COLUMN curso_id INT REFERENCES cursos(id);
 
- Adiciona uma coluna nova numa tabela que já existe
- REFERENCES cursos(id) cria uma CHAVE ESTRANGEIRA (foreign key):
  o valor de curso_id tem que corresponder a um id que existe na tabela cursos
- Coluna nova criada fica com valor NULL em todas as linhas existentes
 
 
2. Relacionamento entre tabelas
---------------------------------
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nome_curso VARCHAR(100)
);
 
- Em vez de repetir o texto do curso em cada aluno, guarda-se apenas
  um número (curso_id) que aponta pro id na tabela cursos
- Isso evita duplicar informação e é a base do banco de dados relacional
 
 
3. JOIN - juntar dados de duas tabelas
---------------------------------
SELECT alunos.nome, alunos.idade, cursos.nome_curso
FROM alunos
JOIN cursos ON alunos.curso_id = cursos.id;
 
- Junta as duas tabelas, "traduzindo" o curso_id pro nome do curso
- Esse é o INNER JOIN (padrão): só traz alunos que TÊM um curso
  correspondente. Quem está com curso_id = NULL fica de fora do resultado.
 
 
4. LEFT JOIN - juntar tabelas incluindo quem não tem correspondência
---------------------------------
SELECT alunos.nome, alunos.idade, cursos.nome_curso
FROM alunos
LEFT JOIN cursos ON alunos.curso_id = cursos.id;
 
- Traz TODOS os alunos, mesmo os que não têm curso
- Quando não há correspondência, o campo nome_curso aparece como NULL
 
 
OBSERVAÇÕES SOBRE O PGADMIN (dia 2)
=================================================
- No Query Tool, F5 (ou botão "play") executa TUDO que está selecionado.
  Se nada estiver selecionado, executa o script inteiro da tela.
- Por isso é importante selecionar apenas o trecho de SQL que se quer
  rodar. Se mais de um SELECT estiver selecionado, só o resultado do
  ÚLTIMO comando aparece no Data Output.
*/