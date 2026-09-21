/*
================================================================
P1 - Banco de Dados Relacional - OficinaTech
Arquivo único com CREATE, INSERT, UPDATE, DELETE, SELECT
e respostas descritivas em comentários SQL (--)
================================================================
*/

/* ============================================================
   QUESTÃO 1 — Normalização (1FN, 2FN e 3FN)
   ============================================================ */

/*
a) (0,4) Por que viola 1FN, 2FN e 3FN + anomalia

-- 1FN:
-- A coluna Telefone_Cliente guarda mais de um telefone na mesma célula
-- (atributo multivalorado). O mesmo ocorre em Serviços_Realizados e
-- Peças_Usadas, que guardam listas de valores. 1FN exige valores atômicos.

-- 2FN:
-- A chave candidata da tabela não-normalizada seria algo como
-- (Num_OS, Cod_Servico, Cod_Peca). Porém Nome_Cliente depende só de
-- CPF_Cliente e Modelo/Ano dependem só de Placa_Veiculo. São
-- dependências parciais da chave composta → viola 2FN.

-- 3FN:
-- Existe dependência transitiva: Num_OS → CPF_Cliente → Nome_Cliente
-- (atributo não-chave dependendo de outro atributo não-chave).

-- Anomalia de inserção:
-- Não é possível cadastrar um novo cliente (ou um novo serviço/peça)
-- sem abrir uma Ordem de Serviço. Além disso, se Carlos Silva
-- comprar outro veículo, seus dados (nome, telefone etc.) teriam
-- que ser inseridos novamente, gerando redundância.

-- Anomalia de alteração:
-- Se o telefone de Carlos Silva mudar, é preciso alterar em todas
-- as linhas das OSs dele.

-- Anomalia de exclusão:
-- Se a última OS de um cliente for apagada, perdem-se os dados
-- do cliente e do veículo.

b) (0,3) Dependências funcionais identificadas

-- CPF_Cliente            → Nome_Cliente
-- Placa_Veiculo          → Modelo_Veiculo, Ano_Veiculo, CPF_Cliente
-- Num_OS                 → Data_Abertura, Placa_Veiculo
-- Cod_Servico            → Descricao_Servico, Valor_Servico
-- Cod_Peca               → Descricao_Peca, Preco_Peca
-- (Num_OS, Cod_Servico)  → (item de serviço da OS)
-- (Num_OS, Cod_Peca)     → (item de peça da OS)
-- Telefone é multivalorado → tabela própria

c) (0,8) Esquema relacional normalizado até 3FN

-- Cliente (cpf PK, nome)
-- Telefone_Cliente (cpf PK/FK → Cliente, telefone PK)
-- Veiculo (placa PK, modelo, ano, cpf FK → Cliente)
-- Servico (cod_servico PK, descricao, valor)
-- Peca (cod_peca PK, descricao, preco)
-- Ordem_Servico (num_os PK, data_abertura, placa FK → Veiculo)
-- Item_Servico (num_os PK/FK → Ordem_Servico, cod_servico PK/FK → Servico)
-- Item_Peca (num_os PK/FK → Ordem_Servico, cod_peca PK/FK → Peca)

-- Observação: a Questão 2 usa um recorte simplificado (3 tabelas).
-- A normalização completa acima inclui Serviço e Peça.
*/

/* ============================================================
   QUESTÃO 2 — Criação do Esquema Físico (DDL)
   ============================================================ */

-- Cliente
CREATE TABLE clientes (
    id_cliente   SERIAL       PRIMARY KEY,
    nome_cliente VARCHAR(200) NOT NULL,
    telefone     VARCHAR(20),                 -- VARCHAR porque tem máscara
    cpf_cliente  VARCHAR(14)  UNIQUE NOT NULL -- mantém formato 111.222.333-44
);

-- Veiculo
CREATE TABLE veiculos (
    placa          VARCHAR(8)   PRIMARY KEY,
    modelo_veiculo VARCHAR(200) NOT NULL,
    ano_veiculo    INT          NOT NULL CHECK (ano_veiculo > 1990),
    id_cliente     INT          NOT NULL
                   REFERENCES clientes(id_cliente)
                   ON DELETE RESTRICT   -- não apaga cliente que ainda tem veículo
);

-- Ordem_Servico
CREATE TABLE ordem_servico (
    id_os         SERIAL         PRIMARY KEY,
    data_abertura DATE           NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(20)    NOT NULL DEFAULT 'ABERTA',
    valor_total   NUMERIC(12,2)  NOT NULL DEFAULT 0,
    placa_veiculo VARCHAR(8)     NOT NULL
                  REFERENCES veiculos(placa)
                  ON DELETE RESTRICT   -- uma OS não pode existir sem veículo
);

-- Justificativa das FKs:
-- ON DELETE RESTRICT nas duas FKs.
-- Regra de negócio: uma Ordem de Serviço não pode existir sem um
-- veículo cadastrado, e um veículo não pode ser apagado enquanto
-- ainda houver OSs vinculadas a ele.


/* ============================================================
   QUESTÃO 3 — Carga Inicial de Dados (INSERT)
   ============================================================ */

-- Dois clientes com dados fictícios
INSERT INTO clientes (nome_cliente, telefone, cpf_cliente) VALUES
('Carlos Silva',  '(11) 98888-1111', '111.222.333-44'),
('Marina Souza',  '(21) 97777-2020', '555.666.777-88');

-- Dois veículos — um associado ao primeiro cliente e outro ao segundo
INSERT INTO veiculos (placa, modelo_veiculo, ano_veiculo, id_cliente) VALUES
('ABC-1234', 'Fiat Argo', 2021, 1),
('XYZ-9K87', 'VW Polo',   2019, 2);

-- Duas ordens de serviço
INSERT INTO ordem_servico (status, valor_total, placa_veiculo) VALUES
('ABERTA',    350.00, 'ABC-1234'),
('CONCLUÍDA', 450.00, 'XYZ-9K87');


/* ============================================================
   QUESTÃO 4 — Atualização de Dados (UPDATE)
   ============================================================ */

-- a) Cliente de CPF '111.222.333-44' mudou de número
UPDATE clientes
SET telefone = '(11) 99999-0000'
WHERE cpf_cliente = '111.222.333-44';

-- b) Finalizar a OS aberta do primeiro veículo
UPDATE ordem_servico
SET status = 'CONCLUÍDA'
WHERE placa_veiculo = 'ABC-1234'
  AND status = 'ABERTA';


/* ============================================================
   QUESTÃO 5 — Exclusão Segura e Integridade Referencial
   ============================================================ */

-- a) Remover OSs com status 'CANCELADA' abertas antes de 2023-01-01
DELETE FROM ordem_servico
WHERE status = 'CANCELADA'
  AND data_abertura < '2023-01-01';

/*
b) (0,40) O que acontece ao executar
   DELETE FROM clientes WHERE id_cliente = 1;
   sem cascata (ON DELETE RESTRICT)?

-- O comando é REJEITADO pelo PostgreSQL com erro de violação de
-- chave estrangeira, porque existem veículos (e indiretamente OSs)
-- que referenciam esse cliente.

-- Como resolver mantendo a consistência:
--   1) Apagar primeiro as ordens de serviço dos veículos do cliente;
--   2) Apagar os veículos do cliente;
--   3) Só então apagar o cliente.
-- Alternativas: usar ON DELETE CASCADE (se a regra de negócio
-- permitir) ou fazer exclusão lógica (coluna ativo = FALSE).
*/


/* ============================================================
   QUESTÃO 6 — Consultas com Junção de Tabelas (JOIN)
   ============================================================ */

-- a) Nome do cliente, placa do veículo e status da OS (INNER JOIN)
SELECT
    c.nome_cliente,
    v.placa,
    os.status
FROM ordem_servico os
INNER JOIN veiculos v ON v.placa = os.placa_veiculo
INNER JOIN clientes c ON c.id_cliente = v.id_cliente;

-- b) Todos os clientes e seus veículos (LEFT JOIN)
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.telefone,
    c.cpf_cliente,
    v.placa,
    v.modelo_veiculo,
    v.ano_veiculo
FROM clientes c
LEFT JOIN veiculos v ON c.id_cliente = v.id_cliente;

-- c) Quantidade de ordens de serviço por veículo (GROUP BY + COUNT)
SELECT
    v.placa,
    COUNT(os.id_os) AS qtd_ordens
FROM veiculos v
JOIN ordem_servico os ON os.placa_veiculo = v.placa
GROUP BY v.placa;

-- d) Valor total faturado por status de OS (GROUP BY + SUM)
SELECT
    status,
    SUM(valor_total) AS total_faturado
FROM ordem_servico
GROUP BY status;
