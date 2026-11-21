/*
================================================================================
ATIVIDADE: PROJETO DE BANCO DE DADOS - CLÍNICA ODONTOLÓGICA
================================================================================

1. DIAGRAMA ER (NOTAÇÃO PÉ DE GALINHA / MERMAID):
```mermaid
erDiagram
    UNIDADE ||--o{ DENTISTA_UNIDADE : "aloca"
    DENTISTA ||--o{ DENTISTA_UNIDADE : "atende em"
    PACIENTE ||--o{ CONSULTA : "agenda"
    DENTISTA ||--o{ CONSULTA : "realiza"
    UNIDADE ||--o{ CONSULTA : "sedia"
    CONSULTA ||--o{ CONSULTA_PROCEDIMENTO : "contem"
    PROCEDIMENTO ||--o{ CONSULTA_PROCEDIMENTO : "compoe"

    UNIDADE {
        int id_unidade PK
        string nome
        string endereco
        string telefone
    }
    DENTISTA {
        int id_dentista PK
        string nome
        string cro UK
        string especialidade
        string telefone
    }
    DENTISTA_UNIDADE {
        int id_dentista PK_FK
        int id_unidade PK_FK
    }
    PACIENTE {
        int id_paciente PK
        string nome
        string cpf UK
        string telefone
        string nome_convenio
        string numero_carteirinha
    }
    PROCEDIMENTO {
        int id_procedimento PK
        string nome UK
        numeric preco_tabelado
    }
    CONSULTA {
        int id_consulta PK
        timestamp data_hora
        int id_paciente FK
        int id_dentista FK
        int id_unidade FK
        string situacao
    }
    CONSULTA_PROCEDIMENTO {
        int id_consulta_procedimento PK
        int id_consulta FK
        int id_procedimento FK
        numeric valor_cobrado
        string situacao
    }
```


2. JUSTIFICATIVA DE 3FN (TERCEIRA FORMA NORMAL):
O modelo já nasce normalizado em 3FN porque as entidades foram isoladas desde o início do projeto:
- 1FN: Todos os atributos são atômicos e cada tabela possui sua chave primária. Os múltiplos procedimentos de uma consulta foram separados em linhas individuais na tabela associativa consulta_procedimento.
- 2FN: Não existem dependências parciais. Nas tabelas com chaves compostas (dentista_unidade), os atributos dependem da totalidade da chave.
- 3FN: Nenhuma coluna não-chave depende de outra coluna não-chave. Dados de unidade (endereço), dentista (especialidade) e paciente (telefone, convênio) pertencem estritamente às suas próprias tabelas, e não à tabela consulta. Além disso, não armazenamos campos calculados (como valor_total da consulta), calculando-os dinamicamente por agregações (SUM).

3. JUSTIFICATIVAS DAS RESTRIÇÕES (NOT NULL, UNIQUE, CHECK):
- NOT NULL: colocamos em atributos que não podem ficar vazios, por exemplo, o endereço de uma clínica, que precisa ter sua localização.
- UNIQUE:   colocamos em atributos que são únicos (não podem ser repetidos), como por exemplo, o cro de cada dentista. O ID também deve ser um identificador único, mas o SERIAL já faz esse trabalho sem precisar da constraint unique.
- CHECK:    colocamos em atributos onde nós controlamos o valor que será atribuído a ele. Por exemplo, a situação de uma consulta pode ser agendada, realizada ou cancelada. A constraint check impede qualquer outro valor que não esteja nessa lista.


================================================================================
QUESTIONÁRIO SOBRE USO DE IA (OBRIGATÓRIO)
================================================================================
1. Qual(is) modelo(s) de IA você usou?
Gemini 3.8 Flash (via Antigravity)

2. Como você usou a IA para resolver o problema?
A IA leu o enunciado e foi me guiando na resolução do problema. Como o agy consegue assistir o arquivo em que estou trabalhando, eu optei por fazer algo semelhante à programação em pares (da XP), onde eu fui copiando e a IA foi assistindo, tirando dúvidas etc.

3. Qual foi a sua dificuldade para identificar sozinho as entidades e o N:N?
A dificuldade esteve em diferenciar o que era N:N diretamente ou indiretamente. Por exemplo, eu imaginava que muitos pacientes poderiam ser atendidos por muitos médicos, e estava certo na prática, porém, na modelagem, existe um intermediário que vai referenciar os dois (a consulta), fazendo com que no schema essa relação não seja N:N diretamente, ao contrário de dentista e unidade.

4. Você conseguiria explicar, sem consultar a IA, por que o modelo está em 3FN e como a trigger/view resolve a regra?
Sim. O modelo está em 3FN porque cada tabela tem responsabilidade única: dados de paciente, dentista e unidade não se misturam nem se repetem na tabela consulta (apenas suas FKs são referenciadas). A trigger resolve a regra de negócio interceptando o INSERT na consulta_procedimento e comparando com o preco_tabelado da tabela procedimento, barrando lançamentos com erro de valor. A view resolve a necessidade operacional da clínica juntando as consultas com os nomes de pacientes, dentistas e unidades em uma agenda pronta para o dia a dia.

================================================================================
*/


-- ================================================================================
-- 1. DDL - CRIAÇÃO DAS TABELAS (CREATE TABLE)
-- ================================================================================
-- COMECE A DIGITAR AS TABELAS A PARTIR DA LINHA ABAIXO:

CREATE TABLE unidade(
    id_unidade SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    telefone VARCHAR(20)
);

CREATE TABLE dentista (
    id_dentista SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cro VARCHAR(20) UNIQUE NOT NULL,
    especialidade VARCHAR(50) NOT NULL,
    telefone VARCHAR(20)
);

CREATE TABLE dentista_unidade (
    id_dentista INT NOT NULL REFERENCES dentista(id_dentista),
    id_unidade INT NOT NULL REFERENCES unidade(id_unidade),
    PRIMARY KEY (id_dentista, id_unidade)
);

CREATE TABLE paciente (
    id_paciente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    nome_convenio VARCHAR(50),
    numero_carteirinha VARCHAR(50)
);

CREATE TABLE procedimento (
    id_procedimento SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    preco_tabelado NUMERIC(10,2) NOT NULL CHECK (preco_tabelado > 0)
);

CREATE TABLE consulta (
    id_consulta SERIAL PRIMARY KEY,
    data_hora TIMESTAMP NOT NULL,
    id_paciente INT NOT NULL REFERENCES paciente(id_paciente),
    id_dentista INT NOT NULL REFERENCES dentista(id_dentista),
    id_unidade INT NOT NULL REFERENCES unidade(id_unidade),
    situacao VARCHAR(20) NOT NULL DEFAULT 'agendada' CHECK (situacao IN ('agendada', 'realizada', 'cancelada'))
);

CREATE TABLE consulta_procedimento (
    id_consulta_procedimento SERIAL PRIMARY KEY,
    id_consulta INT NOT NULL REFERENCES consulta(id_consulta),
    id_procedimento INT NOT NULL REFERENCES procedimento(id_procedimento),
    valor_cobrado NUMERIC(10,2) NOT NULL CHECK (valor_cobrado >= 0),
    situacao VARCHAR(20) NOT NULL DEFAULT 'realizado' CHECK (situacao IN ('realizado', 'cancelado'))
);


-- ================================================================================
-- 2. DML - DADOS DE TESTE (INSERT)
-- ================================================================================

INSERT INTO unidade (nome, endereco, telefone) VALUES
('Unidade Centro', 'Rua do Ouvidor, 50 - Centro', '21999990001'),
('Unidade Tijuca', 'Rua Conde de Bonfim, 120 - Tijuca', '21999990002'),
('Unidade Barra', 'Av. das Americas, 500 - Barra', '21999990003');

INSERT INTO dentista (nome, cro, especialidade, telefone) VALUES
('Dra. Juliana Paes', 'CRO-RJ 12345', 'Clínico Geral', '21988880001'),
('Dr. Ricardo Souza',  'CRO-RJ 23456', 'Ortodontia',    '21988880002'),
('Dra. Camila Dias',   'CRO-RJ 34567', 'Endodontia',    '21988880003'),
('Dr. Bruno Rocha',    'CRO-RJ 45678', 'Implantodontia','21988880004');

INSERT INTO dentista_unidade (id_dentista, id_unidade) VALUES
(1, 1), (1, 2),
(2, 2), (2, 3),
(3, 1), (3, 3),
(4, 1);

INSERT INTO paciente (nome, cpf, telefone, nome_convenio, numero_carteirinha) VALUES
('Lucas Silva',    '111.222.333-44', '21977770001', 'Amil Dental', 'AM-98765'),
('Mariana Costa',  '222.333.444-55', '21977770002', 'SulAmerica', 'SA-54321'),
('Rafael Santos',  '333.444.555-66', '21977770003', NULL,          NULL),
('Fernanda Lima',  '444.555.666-77', '21977770004', NULL,          NULL);

INSERT INTO procedimento (nome, preco_tabelado) VALUES
('Limpeza',              150.00),
('Obturação',            220.00),
('Extração',             300.00),
('Tratamento de Canal',  850.00);

INSERT INTO consulta (data_hora, id_paciente, id_dentista, id_unidade, situacao) VALUES
('2024-05-10 09:00:00', 1, 1, 1, 'realizada'),
('2024-05-10 10:30:00', 2, 1, 1, 'realizada'),
('2024-05-11 14:00:00', 3, 2, 2, 'realizada'),
('2024-05-12 11:00:00', 1, 2, 2, 'cancelada'),
('2024-05-13 15:30:00', 4, 3, 3, 'realizada'),
('2024-05-14 09:30:00', 2, 3, 1, 'realizada'),
('2024-05-15 16:00:00', 3, 1, 2, 'realizada'),
('2024-05-20 10:00:00', 4, 2, 3, 'agendada');

INSERT INTO consulta_procedimento (id_consulta, id_procedimento, valor_cobrado, situacao) VALUES
(1, 1, 150.00, 'realizado'),
(1, 2, 220.00, 'realizado'),
(2, 1, 150.00, 'realizado'),
(3, 2, 220.00, 'realizado'),
(4, 3, 300.00, 'cancelado'),
(5, 4, 850.00, 'realizado'),
(6, 1, 150.00, 'realizado'),
(6, 3, 300.00, 'realizado'),
(7, 2, 220.00, 'realizado'),
(8, 1, 150.00, 'realizado');





-- ================================================================================
-- 3. TRIGGER E FUNÇÃO DE REGRA DE NEGÓCIO
-- ================================================================================

-- 1. A FUNÇÃO DE VALIDAÇÃO
CREATE OR REPLACE FUNCTION valida_preco_procedimento()
RETURNS TRIGGER AS $$
BEGIN
    -- Compara o valor que está entrando com o preço cadastrado no catálogo
    IF NEW.valor_cobrado <> (SELECT preco_tabelado FROM procedimento WHERE id_procedimento = NEW.id_procedimento) THEN
        RAISE EXCEPTION 'Erro: O valor cobrado (R$ %) difere do preço tabelado pela clínica', NEW.valor_cobrado;
    END IF;

    -- permite a operação (insert ou update) caso seja igual (new.valor_cobrado = preco_tabelado(selecionado pela sub query))
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. O GATILHO (TRIGGER)
CREATE TRIGGER trg_valida_preco_procedimento
BEFORE INSERT OR UPDATE ON consulta_procedimento
FOR EACH ROW
EXECUTE FUNCTION valida_preco_procedimento();



-- ================================================================================
-- 4. VIEW ANALÍTICA
-- ================================================================================


CREATE VIEW vw_agenda_consultas AS
SELECT 
    consulta.id_consulta,
    consulta.data_hora,
    paciente.nome AS paciente,
    paciente.telefone AS telefone_paciente,
    dentista.nome AS dentista,
    dentista.especialidade,
    unidade.nome AS unidade,
    consulta.situacao
FROM consulta
JOIN paciente ON consulta.id_paciente = paciente.id_paciente
JOIN dentista ON consulta.id_dentista = dentista.id_dentista
JOIN unidade ON consulta.id_unidade = unidade.id_unidade;


-- ================================================================================
-- 5. CONSULTAS DE NEGÓCIO (DQL)
-- ================================================================================

-- CONSULTA 1: Uso da View analítica (Agenda diária da clínica)
SELECT * FROM vw_agenda_consultas ORDER BY data_hora;

-- CONSULTA 2: JOIN envolvendo 4 tabelas (Histórico clínico completo dos pacientes)
SELECT 
    paciente.nome AS paciente,
    paciente.nome_convenio,
    consulta.data_hora,
    procedimento.nome AS procedimento_feito,
    consulta_procedimento.valor_cobrado
FROM paciente
JOIN consulta ON paciente.id_paciente = consulta.id_paciente
JOIN consulta_procedimento ON consulta.id_consulta = consulta_procedimento.id_consulta
JOIN procedimento ON consulta_procedimento.id_procedimento = procedimento.id_procedimento
WHERE consulta.situacao = 'realizada';

-- CONSULTA 3: Agregação com GROUP BY (Resolve a dor do dentista com 0 consultas no mês)
SELECT 
    dentista.nome AS dentista,
    dentista.especialidade,
    COUNT(consulta.id_consulta) AS total_consultas
FROM dentista
LEFT JOIN consulta ON dentista.id_dentista = consulta.id_dentista
GROUP BY dentista.nome, dentista.especialidade
ORDER BY total_consultas ASC;

-- CONSULTA 4: Prova da Trigger (Tentativa de lançamento com valor diferente do tabelado)
-- A Limpeza custa R$ 150,00. Tentar lançar R$ 999,00 vai disparar o RAISE EXCEPTION e abortar!
-- Descomente a linha abaixo para testar o erro no console:
-- INSERT INTO consulta_procedimento (id_consulta, id_procedimento, valor_cobrado, situacao) VALUES (1, 1, 999.00, 'realizado');


