-- categorias de CNH (tabela base, evita repetir codigo/descricao
-- em instrutores, veiculos e alunos -> exigencia da 3FN)
create table categorias_cnh (
    id_categoria serial primary key,
    codigo varchar(5) unique not null, 
    descricao varchar(100) not null
);

-- instrutores (depende de categorias_cnh)
create table instrutores (
    id_instrutor serial primary key,
    nome varchar(100) not null,
    cpf varchar(14) unique not null,
    email varchar(100) unique,
    telefone varchar(20),
    categoria_id int references categorias_cnh(id_categoria)
);

-- veiculos (depende de categorias_cnh)
create table veiculos (
    id_veiculo serial primary key,
    placa varchar(10) unique not null,
    modelo varchar(60) not null,
    ano_fabricacao int check (ano_fabricacao > 1980),
    categoria_id int references categorias_cnh(id_categoria)
);


-- alunos (depende de categorias_cnh)
create table alunos (
    id_aluno serial primary key,
    nome varchar(100) not null,
    cpf varchar(14) unique not null,
    email varchar(100) unique,
    data_nascimento date not null,
    categoria_pretendida_id int references categorias_cnh(id_categoria)
);

-- aulas (depende de alunos, instrutores e veiculos)
create table aulas (
    id_aula serial primary key,
    aluno_id int references alunos(id_aluno),
    instrutor_id int references instrutores(id_instrutor),
    veiculo_id int references veiculos(id_veiculo),
    tipo_aula varchar(10) check (tipo_aula in ('teorica','pratica')),
    data_hora timestamp not null,
    duracao_minutos int check (duracao_minutos > 0)
);

-- exames (depende de alunos)
create table exames (
    id_exame serial primary key,
    aluno_id int references alunos(id_aluno),
    tipo_exame varchar(10) check (tipo_exame in ('teorico','pratico')),
    data_exame date not null,
    resultado varchar(15) check (resultado in ('aprovado','reprovado','pendente'))
);

-- pagamentos (depende de alunos)
create table pagamentos (
    id_pagamento serial primary key,
    aluno_id int references alunos(id_aluno),
    valor numeric(10,2) check (valor > 0),
    data_pagamento date not null,
    forma_pagamento varchar(20),
    status varchar(15) check (status in ('pago','pendente','atrasado'))
);

-- INSERTS DE EXEMPLO
INSERT INTO categorias_cnh (codigo, descricao) VALUES
('A', 'Motocicletas'),
('B', 'Veiculos de passeio'),
('AB', 'Motocicletas e veiculos de passeio');

INSERT INTO instrutores (nome, cpf, email, telefone, categoria_id) VALUES
('Carlos Menezes', '111.111.111-11', 'carlos@autoescola.com', '(22) 99999-0001', 2),
('Renata Alves', '222.222.222-22', 'renata@autoescola.com', '(22) 99999-0002', 1);

INSERT INTO veiculos (placa, modelo, ano_fabricacao, categoria_id) VALUES
('ABC1D23', 'Chevrolet Onix', 2022, 2),
('XYZ9E88', 'Honda CG 160', 2023, 1);

INSERT INTO alunos (nome, cpf, email, data_nascimento, categoria_pretendida_id) VALUES
('Jhean Monteiro', '333.333.333-33', 'jhean@email.com', '2003-04-10', 2),
('Luana Silva', '444.444.444-44', 'luana@email.com', '2001-08-22', 2),
('Joao Costa', '555.555.555-55', 'joao@email.com', '2000-01-15', 1);

INSERT INTO aulas (aluno_id, instrutor_id, veiculo_id, tipo_aula, data_hora, duracao_minutos) VALUES
(1, 1, 1, 'pratica', '2026-05-16 08:00:00', 50),
(3, 2, 2, 'pratica', '2026-05-16 10:00:00', 50);

INSERT INTO exames (aluno_id, tipo_exame, data_exame, resultado) VALUES
(1, 'teorico', '2026-06-01', 'aprovado'),
(2, 'teorico', '2026-06-01', 'pendente');

INSERT INTO pagamentos (aluno_id, valor, data_pagamento, forma_pagamento, status) VALUES
(1, 250.00, '2026-05-01', 'pix', 'pago'),
(2, 250.00, '2026-05-05', 'boleto', 'pendente');

select * from alunos;
