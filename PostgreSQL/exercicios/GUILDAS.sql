/*
================================================================================
RELATO DE PROJETO: FEDERAÇÃO DE GUILDAS DE AVENTUREIROS
================================================================================

1. JUSTIFICATIVA DE 3FN (TERCEIRA FORMA NORMAL):
Porque todas as entidades e seus respectivos relacionamentos já estavam isolados previamente. Cada tabela cuida apenas dos seus próprios dados, com chaves primárias definidas, sem repetir dados da guilda dentro de missão e usando uma tabela associativa para o N:N.

2. COMO A TRIGGER RESOLVE UMA REGRA REAL DO MUNDO:
Simples: um aventureiro não pode pegar uma missão rank 'S' sem que ele tenha uma classificação necessária para isso. Para isso, antes de inserir na tabela missao_aventureiro, a trigger ativa uma função que checa se o rank do aventureiro passa no filtro antes de liberar a missão.

3. O QUE FOI DECISÃO SUA VS O QUE VEIO DA IA:
A ideia dessa modelagem foi 100% minha (baseado num sistema de uma web novel que estou escrevendo). Já na modelagem eu tive bastante ajuda da IA para identificar o que se relacionava a o que especificamente, por exemplo, eu não soube identificar imediatamente que um aventureiro não poderia pegar uma missão diretamente, mas sim que ele precisaria de um intermediário para resolver a relação N:N.

4. DECLARAÇÃO DE DOMÍNIO:
Compreendo a arquitetura das tabelas. Compreendo o relacionamento N:N (muitos aventureiros para muitas missões), e compreendo o funcionamento da trigger, que foi a parte que mais me levou tempo na execução dessa atividade. Tive que declarar variáveis internas para atribuir valores, e depois compará-los para verificar se o insert será permitido ou não. Isso é algo que ainda preciso praticar mais.

================================================================================
*/

-- ================================================================================
-- SISTEMA DA FEDERAÇÃO DE GUILDAS DE AVENTUREIROS
-- ================================================================================

-- 1. DDL (CRIAÇÃO DAS TABELAS)

CREATE TABLE guilda (
    nome VARCHAR(100) PRIMARY KEY,
    mestre_da_guilda VARCHAR(100) NOT NULL,
    rank_guilda VARCHAR(20) CHECK (rank_guilda IN ('cobre', 'prata', 'ouro', 'ametharix', 'adamantina'))
);

CREATE TABLE aventureiro (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nome_guilda VARCHAR(100) REFERENCES guilda(nome) NOT NULL,
    classificacao_aventureiro VARCHAR(20) CHECK (classificacao_aventureiro IN ('D', 'C', 'B', 'A', 'S'))
);

CREATE TABLE unidade_federacao (
    id_unidade SERIAL PRIMARY KEY,
    cidade VARCHAR(100) NOT NULL
);

CREATE TABLE missao (
    id SERIAL PRIMARY KEY,
    dificuldade VARCHAR(20) CHECK (dificuldade IN ('D', 'C', 'B', 'A', 'S')),
    descricao VARCHAR(500) NOT NULL,
    id_unidade INT NOT NULL REFERENCES unidade_federacao(id_unidade)
);

CREATE TABLE missao_aventureiro (
    id_missao INT NOT NULL REFERENCES missao(id),
    id_aventureiro INT NOT NULL REFERENCES aventureiro(id),
    PRIMARY KEY (id_missao, id_aventureiro)
);


-- ================================================================================
-- 2. TRIGGER E FUNÇÃO (REGRA DE NEGÓCIO DA FEDERAÇÃO)
-- ================================================================================

CREATE OR REPLACE FUNCTION checa_rank()
RETURNS TRIGGER AS $$
DECLARE
    v_rank_aventureiro VARCHAR(20);
    v_dificuldade_missao VARCHAR(20);
BEGIN
    SELECT classificacao_aventureiro INTO v_rank_aventureiro
    FROM aventureiro
    WHERE id = NEW.id_aventureiro;

    SELECT dificuldade INTO v_dificuldade_missao
    FROM missao
    WHERE id = NEW.id_missao;

    -- Regra: Missões de Rank S só permitem aventureiros de Rank S ou A!
    IF v_dificuldade_missao = 'S' AND v_rank_aventureiro NOT IN ('S', 'A') THEN
        RAISE EXCEPTION 'Acesso Negado: Missões de Rank S exigem aventureiros de Rank S ou A!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_checa_rank
BEFORE INSERT ON missao_aventureiro
FOR EACH ROW
EXECUTE FUNCTION checa_rank();


-- ================================================================================
-- 3. DML (INSERÇÃO DOS DADOS)
-- ================================================================================

-- 3.1. GUILDAS
INSERT INTO guilda (nome, mestre_da_guilda, rank_guilda) VALUES
('Diamond Paladins', 'Yarlan Kronen', 'adamantina'),
('Messier 45',       'King Atlas',    'adamantina'),
('Garras de Dragão', 'Shallate',      'ouro'),
('White Wolves',     'Silman Clavey', 'adamantina'),
('Veist Sword',      'Cyan',          'ametharix'),
('Flower Legion',    'Rosa Valkean',  'adamantina');

-- 3.2. AVENTUREIROS
INSERT INTO aventureiro (nome, nome_guilda, classificacao_aventureiro) VALUES
-- Garras de Dragão
('Shallate',       'Garras de Dragão', 'S'),
('Lucius',         'Garras de Dragão', 'A'),
('Laenard',        'Garras de Dragão', 'A'),
('Daisy Valkean',  'Garras de Dragão', 'A'),
('Veltha',         'Garras de Dragão', 'B'),
('Lin Nowan',      'Garras de Dragão', 'S'),

-- Flower Legion
('Rosa Valkean',     'Flower Legion', 'S'),
('Jasmine Valkean',  'Flower Legion', 'A'),
('Amaranth Valkean', 'Flower Legion', 'S'),
('Flora Valkean',    'Flower Legion', 'A'),
('Carla Valkean',    'Flower Legion', 'A'),
('Iris Valkean',     'Flower Legion', 'S'),
('Rowan Valkean',    'Flower Legion', 'C'),

-- Messier 45
('King Atlas',     'Messier 45', 'S'),
('Queen Pleione',  'Messier 45', 'S'),
('Lady Asterope',  'Messier 45', 'A'),
('Lady Merope',    'Messier 45', 'A'),
('Lady Maia',      'Messier 45', 'A'),

-- White Wolves & Veist Sword & Diamond Paladins
('Silman Clavey', 'White Wolves',     'S'),
('Cyan',          'Veist Sword',      'S'),
('Yarlan Kronen', 'Diamond Paladins', 'S'),
('Kael',          'Veist Sword',      'D');

-- 3.3. UNIDADES DA FEDERAÇÃO
INSERT INTO unidade_federacao (cidade) VALUES
('Capital Imperial'),
('Porto de Oakhaven'),
('Fortaleza de Gelo do Norte');

-- 3.4. MISSÕES
INSERT INTO missao (dificuldade, descricao, id_unidade) VALUES
('D', 'Coleta de Ervas Medicinais nos Arredores', 1),
('C', 'Escolta de Mercadores pela Rota Comercial', 2),
('A', 'Eliminação do Bando de Ogros na Garganta de Pedra', 3),
('S', 'Supressão da Besta da Calamidade nas Ruínas Antigas', 1);

-- 3.5. PARTICIPAÇÃO NAS MISSÕES (GRUPOS/PARTIES)
INSERT INTO missao_aventureiro (id_missao, id_aventureiro) VALUES
-- Missão 1 (Rank D): Kael (Rank D) assume
(1, 22),

-- Missão 2 (Rank C): Rowan Valkean (Rank C) assume
(2, 13),

-- Missão 3 (Rank A): Grupo da Garras de Dragão (Lucius e Laenard, ambos Rank A)
(3, 2),
(3, 3),

-- Missão 4 (Rank S): Grupo de Elite (Shallate [S], King Atlas [S], Lady Asterope [A])
(4, 1),
(4, 14),
(4, 16);


-- ================================================================================
-- 4. ROLES E CONTROLE DE ACESSO (DCL)
-- ================================================================================

CREATE ROLE atendente_federacao;
GRANT INSERT, SELECT ON aventureiro TO atendente_federacao;

CREATE ROLE cidadao;
GRANT INSERT ON missao TO cidadao;


-- ================================================================================
-- 5. VIEW ANALÍTICA (MURAL PÚBLICO DE MISSÕES DA FEDERAÇÃO)
-- ================================================================================

CREATE VIEW vw_mural_missoes AS
SELECT 
    missao.id AS id_missao,
    missao.dificuldade,
    missao.descricao,
    unidade_federacao.cidade,
    aventureiro.nome AS aventureiro,
    aventureiro.classificacao_aventureiro AS rank_aventureiro,
    aventureiro.nome_guilda
FROM missao
JOIN unidade_federacao ON missao.id_unidade = unidade_federacao.id_unidade
LEFT JOIN missao_aventureiro ON missao.id = missao_aventureiro.id_missao
LEFT JOIN aventureiro ON missao_aventureiro.id_aventureiro = aventureiro.id;


-- ================================================================================
-- 6. TESTES DE FUNCIONAMENTO E CONTROLE DE ACESSO
-- ================================================================================

-- Teste 1: Consultando a View do Mural de Missões
SELECT * FROM vw_mural_missoes;

-- Teste 2: Teste do Cidadão (Menor Privilégio - Acesso Negado em aventureiro)
CREATE USER joao_cidadao WITH PASSWORD '123';
GRANT cidadao TO joao_cidadao;

SET ROLE joao_cidadao;
-- Tentativa abaixo será negada pelo banco:
-- SELECT * FROM aventureiro; -- ERRO: permission denied for table aventureiro
RESET ROLE;

-- Teste 3: Teste da Trigger (Tentativa de incluir Rowan Valkean [Rank C] na Missão 4 [Rank S])
-- A linha abaixo dispara o RAISE EXCEPTION:
-- INSERT INTO missao_aventureiro (id_missao, id_aventureiro) VALUES (4, 13);

