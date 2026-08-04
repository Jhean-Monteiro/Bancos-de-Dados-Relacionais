CREATE TABLE alunos (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(100),
	idade INT
);

INSERT INTO alunos (nome, idade) VALUES
('Maria', 22),
('João', 25),
('Ana', 19),
('Jhean', 21)

SELECT * FROM alunos;

DELETE FROM alunos WHERE id < 22;

SELECT * FROM alunos WHERE idade > 22;

SELECT * FROM alunos ORDER BY idade;

SELECT * FROM alunos ORDER BY idade DESC;


/* Buscar apenas os alunos com idade menor ou igual a 22 */

SELECT * FROM alunos WHERE idade <= 22;

/* Buscar os alunos ordenados por nome (ordem alfabética) */
SELECT * FROM alunos ORDER BY nome;

/* Buscar os alunos com idade entre 20 e 25, ordenados por idade do maior pro menor */
SELECT * FROM alunos WHERE idade > 20 AND idade < 25 ORDER BY idade DESC;

/* Buscar os alunos com idade entre 20 e 25, ordenados por idade do maior pro menor */
SELECT * FROM alunos WHERE idade BETWEEN 20 AND 25 ORDER BY idade DESC;


/* UPDATE */
UPDATE alunos
SET idade = 20
WHERE nome = 'Jhean'

SELECT * FROM alunos;


-- Passo 1: conferir quem vai ser afetado
SELECT * FROM alunos WHERE nome = 'Maria';
-- Passo 2: só depois de confirmar, rodar o UPDATE
UPDATE alunos SET idade = 23 WHERE nome = 'Maria';


UPDATE alunos SET idade = 21 WHERE nome = 'Jhean';

UPDATE alunos SET nome = 'Jhean Monteiro' Where id = 22;

select * from alunos;