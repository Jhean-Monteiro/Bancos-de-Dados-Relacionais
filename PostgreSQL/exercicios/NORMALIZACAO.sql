/*
================================================================================
ATIVIDADE: NORMALIZAÇÃO DE BANCO DE DADOS
================================================================================

1. IDENTIFICAÇÃO DAS VIOLAÇÕES DAS FORMAS NORMAIS:

-- 1FN (Primeira Forma Normal):
A 1FN exige que cada coluna contenha apenas valores atômicos (indivisíveis) e que a tabela possua uma Chave Primária definida. Na tabela pedido_loja, a 1FN é violada principalmente pela coluna "produtos", que armazena múltiplos itens, quantidades e valores em uma única string separada por ponto e vírgula. Além disso, a coluna "id" foi criada apenas como SERIAL, sem a restrição PRIMARY KEY declarada.

-- 2FN (Segunda Forma Normal):
A 2FN exige estar na 1FN e que todos os atributos não-chave dependam da chave primária inteira, eliminando dependências parciais. Como a tabela tenta registrar itens e pedidos juntos, os dados da venda (data, cliente, vendedor) não dependem dos produtos que estão sendo comprados. Misturar o cabeçalho do pedido com os itens comprados causa redundância e anomalias de repetição a cada produto adicionado.

-- 3FN (Terceira Forma Normal):
A 3FN exige estar na 2FN e que nenhuma coluna não-chave dependa de outra coluna não chave, eliminando dependencias transitivas. Na tabela original, há três violações claras:
1: "loja_vendedor" depende do vendedor e não do pedido;
2: "endereco_cliente", "telefone_cliente" e "cpf_cliente" dependem do cliente e não do pedido (o que causou divergência do endereço de Ana Souza entre as linhas 1 e 5);
3: "valor_total" é um campo calculado dependente dos itens e quantidades, gerando divergências como na linha 5 (valor_total não bate com os itens).

================================================================================
QUESTIONÁRIO SOBRE USO DE IA (OBRIGATÓRIO)
================================================================================

1. Qual(is) modelo(s) de IA você usou?
R: Gemini 3.8 Flash (via Antigravity).

2. Como você usou a IA para resolver o problema? Descreva o processo: o que você pediu, o que a IA sugeriu, o que você aceitou direto e o que precisou corrigir ou questionar.
R: Trabalhei em conjunto com a IA em um formato de programação em pares. Inicialmente, pedi explicações claras sobre onde o modelo original quebrava a 1FN, 2FN e 3FN. A IA sugeriu as justificativas técnicas e eu as digitei e compreendi uma a uma. Para a modelagem das tabelas (DDL), definimos juntos as 5 entidades (cliente, vendedor, produto, pedido e item_pedido) e a remoção da coluna de total calculado para cumprir a 3FN. Devido ao prazo apertado, pedi para a IA estruturar os comandos de migração com as regras de tratamento de inconsistências (padronização de CPF, maiúsculas, resolução de endereço e cálculo correto do pedido 5) e as consultas de validação, as quais revisei e validei no PostgreSQL.

3. Qual foi a sua dificuldade para entender o problema antes de pedir ajuda da IA? (baixa / média / alta) Justifique em 2–3 frases.
R: Média. Minha maior dificuldade inicial era expressar tecnicamente os conceitos de dependência parcial (2FN) e dependência transitiva (3FN) aplicados a um exemplo prático de varejo. Também tive dúvidas sobre como tratar a coluna multivalorada de produtos sem perder o histórico do preço unitário de cada venda.

4. Você conseguiria explicar, sem consultar a IA de novo, por que a sua modelagem final está correta? Justifique.
R: Sim. A modelagem está correta porque cada entidade tem sua responsabilidade única: dados cadastrais de clientes e vendedores não se repetem a cada compra; a tabela item_pedido atomiza os produtos comprados (resolvendo a 1FN) e preserva o preço da época da venda; e campos calculados como o valor total foram eliminados do armazenamento físico, sendo obtidos por agregação (SUM) para impedir inconsistências de cálculo (cumprindo a 3FN).

================================================================================
DECISÕES DE TRATAMENTO DE INCONSISTÊNCIAS NA MIGRAÇÃO:
================================================================================
- CPFs: Padronizados com máscara ('123.456.789-00'). O CPF nulo de Carlos Pereira foi mantido como NULL.
- Nomes e Lojas: Padronizados em formato Title Case ('Ana Souza', 'Loja Centro', 'Loja Norte') para eliminar inconsistências de caixa baixa.
- Endereço de Ana Souza: O pedido 2 registrava que a cliente trocou de endereço, e o pedido 5 trouxe 'Rua A, 15'. Foi adotado 'Rua A, 15' como o endereço atual cadastrado na tabela cliente.
- Formato de Data: Conversão de VARCHAR ('DD/MM/YYYY') para o tipo nativo DATE ('YYYY-MM-DD').
- Pedido com total divergente (linha 5): Na tabela original, o valor_total constava como 20.00 para 10 canetas de 2.50. No novo modelo normalizado, o subtotal é calculado como 10 x 2.50 = 25.00, corrigindo a anomalia física da modelagem anterior.
================================================================================
*/

-- ================================================================================
-- TABELA ORIGINAL (DESNORMALIZADA) - CENÁRIO FORNECIDO
-- ================================================================================
CREATE TABLE IF NOT EXISTS pedido_loja (
    id              SERIAL,
    data_pedido     VARCHAR(20),
    nome_cliente    VARCHAR(100),
    cpf_cliente     VARCHAR(20),
    endereco_cliente VARCHAR(200),
    telefone_cliente VARCHAR(20),
    nome_vendedor   VARCHAR(100),
    loja_vendedor   VARCHAR(100),
    produtos        TEXT,
    valor_total     VARCHAR(20),
    desconto        NUMERIC,
    forma_pagamento VARCHAR(50),
    observacao      TEXT
);

-- Limpa e insere os dados brutos originais caso a tabela já exista
TRUNCATE TABLE pedido_loja;

INSERT INTO pedido_loja
(data_pedido, nome_cliente, cpf_cliente, endereco_cliente, telefone_cliente,
 nome_vendedor, loja_vendedor, produtos, valor_total, desconto, forma_pagamento, observacao)
VALUES
('01/06/2024', 'Ana Souza',      '123.456.789-00', 'Rua A, 10',  '21988887777',
 'Carlos Lima', 'Loja Centro',  'Caderno x2 - 10.00; Caneta x5 - 2.50',       'R$ 32,50', 0,   'Pix',    NULL),

('01/06/2024', 'ana souza',      '12345678900',    'Rua A, 10',  '2198888-7777',
 'Carlos Lima', 'loja centro',  'Mochila x1 - 120.00',                       '120.00',   10,  'Cartão', 'cliente trocou endereço'),

('02/06/2024', 'Beatriz Alves',  '987.654.321-00', 'Rua B, 20',  '21977776666',
 'Carlos Lima', 'Loja Centro',  'Caderno x1 - 10.00; Lápis x3 - 1.00; Borracha x2 - 1.50', 'R$ 16,00', 0, 'Dinheiro', NULL),

('03/06/2024', 'Carlos Pereira', NULL,             'Rua C, 30',  '21966665555',
 'Fernanda Dias','Loja Norte',  'Mochila x1 - 120.00; Estojo x1 - 25.00',    '145,00',   5,   'Pix',    NULL),

('03/06/2024', 'Ana Souza',      '123.456.789-00', 'Rua A, 15',  '21988887777',
 'Fernanda Dias','Loja norte',  'Caneta x10 - 2.50',                        '20.00',    0,   'Cartão', 'valor_total não bate com os itens'),

('04/06/2024', 'Diego Martins',  '111.222.333-44', 'Rua D, 40',  '21955554444',
 'Carlos Lima', 'Loja Centro',  'Caderno x3 - 10.00; Caneta x2 - 2.50',      'R$ 35,00', 0,   'Pix',    NULL);


-- ================================================================================
-- NOVO MODELO RELACIONAL NORMALIZADO (DDL)
-- ================================================================================

-- Dropar tabelas filhas primeiro caso existam para reexecução limpa
DROP TABLE IF EXISTS item_pedido CASCADE;
DROP TABLE IF EXISTS pedido CASCADE;
DROP TABLE IF EXISTS produto CASCADE;
DROP TABLE IF EXISTS vendedor CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;

-- 1. TABELA CLIENTE
CREATE TABLE cliente (
    id_cliente       SERIAL PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    cpf              VARCHAR(14),
    endereco         VARCHAR(200),
    telefone         VARCHAR(20)
);

-- 2. TABELA VENDEDOR
CREATE TABLE vendedor (
    id_vendedor      SERIAL PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    loja             VARCHAR(100) NOT NULL
);

-- 3. TABELA PRODUTO
CREATE TABLE produto (
    id_produto       SERIAL PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL UNIQUE,
    preco            NUMERIC(10,2) NOT NULL
);

-- 4. TABELA PEDIDO
CREATE TABLE pedido (
    id_pedido        SERIAL PRIMARY KEY,
    data_pedido      DATE NOT NULL,
    id_cliente       INT NOT NULL REFERENCES cliente(id_cliente),
    id_vendedor      INT NOT NULL REFERENCES vendedor(id_vendedor),
    desconto         NUMERIC(10,2) DEFAULT 0,
    forma_pagamento  VARCHAR(50) NOT NULL,
    observacao       TEXT
);

-- 5. TABELA ITEM_PEDIDO
CREATE TABLE item_pedido (
    id_item          SERIAL PRIMARY KEY,
    id_pedido        INT NOT NULL REFERENCES pedido(id_pedido),
    id_produto       INT NOT NULL REFERENCES produto(id_produto),
    quantidade       INT NOT NULL CHECK (quantidade > 0),
    preco_unitario   NUMERIC(10,2) NOT NULL CHECK (preco_unitario >= 0)
);


-- ================================================================================
-- MIGRAÇÃO E TRATAMENTO DOS DADOS (DML)
-- ================================================================================

-- 1. Inserção de Clientes (dados limpos e unificados)
INSERT INTO cliente (id_cliente, nome, cpf, endereco, telefone) VALUES
(1, 'Ana Souza',      '123.456.789-00', 'Rua A, 15', '21988887777'), -- Unificado (endereço mais recente)
(2, 'Beatriz Alves',  '987.654.321-00', 'Rua B, 20', '21977776666'),
(3, 'Carlos Pereira', NULL,             'Rua C, 30', '21966665555'), -- CPF nulo preservado
(4, 'Diego Martins',  '111.222.333-44', 'Rua D, 40', '21955554444');

-- 2. Inserção de Vendedores (padronização de capitalização de lojas)
INSERT INTO vendedor (id_vendedor, nome, loja) VALUES
(1, 'Carlos Lima',   'Loja Centro'),
(2, 'Fernanda Dias', 'Loja Norte');

-- 3. Inserção do Catálogo de Produtos
INSERT INTO produto (id_produto, nome, preco) VALUES
(1, 'Caderno',  10.00),
(2, 'Caneta',    2.50),
(3, 'Mochila', 120.00),
(4, 'Lápis',     1.00),
(5, 'Borracha',  1.50),
(6, 'Estojo',   25.00);

-- Ajuste das sequences das tabelas acima para permitir novos inserts automáticos futuros
SELECT setval('cliente_id_cliente_seq', (SELECT MAX(id_cliente) FROM cliente));
SELECT setval('vendedor_id_vendedor_seq', (SELECT MAX(id_vendedor) FROM vendedor));
SELECT setval('produto_id_produto_seq', (SELECT MAX(id_produto) FROM produto));

-- 4. Inserção de Pedidos (cabeçalhos migrados com tipos corretos)
INSERT INTO pedido (id_pedido, data_pedido, id_cliente, id_vendedor, desconto, forma_pagamento, observacao) VALUES
(1, '2024-06-01', 1, 1, 0.00,  'Pix',      NULL),
(2, '2024-06-01', 1, 1, 10.00, 'Cartão',   'cliente trocou endereço'),
(3, '2024-06-02', 2, 1, 0.00,  'Dinheiro', NULL),
(4, '2024-06-03', 3, 2, 5.00,  'Pix',      NULL),
(5, '2024-06-03', 1, 2, 0.00,  'Cartão',   'valor_total não bate com os itens'),
(6, '2024-06-04', 4, 1, 0.00,  'Pix',      NULL);

SELECT setval('pedido_id_pedido_seq', (SELECT MAX(id_pedido) FROM pedido));

-- 5. Inserção de Itens dos Pedidos (atomização da antiga coluna "produtos")
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
-- Pedido 1: Caderno x2 (10.00) + Caneta x5 (2.50)
(1, 1, 2, 10.00),
(1, 2, 5,  2.50),

-- Pedido 2: Mochila x1 (120.00)
(2, 3, 1, 120.00),

-- Pedido 3: Caderno x1 (10.00) + Lápis x3 (1.00) + Borracha x2 (1.50)
(3, 1, 1, 10.00),
(3, 4, 3,  1.00),
(3, 5, 2,  1.50),

-- Pedido 4: Mochila x1 (120.00) + Estojo x1 (25.00)
(4, 3, 1, 120.00),
(4, 6, 1,  25.00),

-- Pedido 5: Caneta x10 (2.50) -> subtotal correto: R$ 25,00
(5, 2, 10, 2.50),

-- Pedido 6: Caderno x3 (10.00) + Caneta x2 (2.50)
(6, 1, 3, 10.00),
(6, 2, 2,  2.50);


-- ================================================================================
-- CONSULTAS DE VERIFICAÇÃO E VALIDAÇÃO DA MIGRAÇÃO
-- ================================================================================

-- Consulta 1: Relatório completo de pedidos com total recalculado via itens e desconto
-- Demonstra que o total agora é calculado de forma confiável através da 3FN.
SELECT 
    p.id_pedido,
    p.data_pedido,
    c.nome AS cliente,
    v.nome AS vendedor,
    v.loja,
    SUM(i.quantidade * i.preco_unitario) AS subtotal,
    p.desconto,
    SUM(i.quantidade * i.preco_unitario) - p.desconto AS valor_total_calculado,
    p.forma_pagamento,
    p.observacao
FROM pedido p
JOIN cliente c ON p.id_cliente = c.id_cliente
JOIN vendedor v ON p.id_vendedor = v.id_vendedor
JOIN item_pedido i ON p.id_pedido = i.id_pedido
GROUP BY p.id_pedido, p.data_pedido, c.nome, v.nome, v.loja, p.desconto, p.forma_pagamento, p.observacao
ORDER BY p.id_pedido;

-- Consulta 2: Total de pedidos e volume financeiro consolidado por cliente
SELECT 
    c.id_cliente,
    c.nome AS cliente,
    COUNT(DISTINCT p.id_pedido) AS total_pedidos,
    SUM(i.quantidade * i.preco_unitario) - SUM(DISTINCT p.desconto) AS total_gasto
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente
LEFT JOIN item_pedido i ON p.id_pedido = i.id_pedido
GROUP BY c.id_cliente, c.nome
ORDER BY total_gasto DESC;

-- Consulta 3: Vendas por produto (prova a atomicidade e 1FN)
SELECT 
    pr.nome AS produto,
    SUM(i.quantidade) AS total_unidades_vendidas,
    SUM(i.quantidade * i.preco_unitario) AS faturamento_produto
FROM produto pr
JOIN item_pedido i ON pr.id_produto = i.id_produto
GROUP BY pr.nome
ORDER BY total_unidades_vendidas DESC;
