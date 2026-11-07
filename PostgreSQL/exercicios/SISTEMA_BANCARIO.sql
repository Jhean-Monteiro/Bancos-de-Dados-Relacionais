/*
=== Cenario Escolhido:
Escolhi o Sistema Bancário para trabalhar nessa atividade.
por quê: Porque é um cenário clássico onde o controle de saldo exige validação estrita (regra de negócio via trigger) e onde dados confidenciais (saldo da conta) precisam ser encapsulados e restritos por perfil (view + DCL)



=== O que foi decisão minha vs o que veio da IA:

Trigger: A IA tentou inicialmente sugerir um código gigante com variáveis e atualização automática de saldo (update). eu rejeitei essa sugestão porque era desnecessariamente complexa e eu queria algo mais limpo e fácil de explicar/entender. eu optei por manter apenas a validação de saque (before insert), comparando o saldo da conta, disparada antes de inserir para bloquear saques sem fundos.

View: deu pra entender como funciona ao fazer um paralelo com um "getter" (encapsulamento da orientação a objetos) para expor as transações com o nome do titular sem expor o saldo total da conta.

Perfis e Permissões: Foi fácil entender a ordem lógica de estruturar perfis (atendente e gerente), aplicando o principio do menor privilégio (o atendente só enxerga a view. o gerente pode operar tabeas, mas não tem permissão de delete para preservar o histórico). além disso, recentemente eu tenho estudado esse conteúdo relacionado ao princípio do menor privilégio na disciplina de Computação em Nuvem com o professor Ralfh, então isso também serviu de base para entender esse conceito nessa atividade. A IA ajudou com a sintaxe do PostgreSQL.

=== Declaração de Domínio
eu compreendo a lógica de cada linha entregue. as tabelas, a trigger com NEW e RAISE EXCEPTION, a view com JOIN e as permissões com SET ROLE. apesar de eu não ter memorizado a sintaxe (foi nisso que eu mais precisei de ajuda da IA), eu consigo explicar o que cada linha faz

*/




CREATE TABLE contas (
    id_conta SERIAL PRIMARY KEY,
    titular VARCHAR(200) NOT NULL,
    saldo NUMERIC(10,2) NOT NULL
);

CREATE TABLE transacoes (
    id_transacao SERIAL PRIMARY KEY,
    id_conta INT REFERENCES contas(id_conta),
    tipo varchar(50) CHECK (tipo IN ('depositar', 'sacar')),
    valor NUMERIC(10,2) CHECK (valor > 0) NOT NULL,
    dia DATE NOT NULL DEFAULT CURRENT_DATE
);

INSERT INTO contas (titular, saldo)
VALUES
('Jhean Monteiro', 1500.00),
('Luiz Gustavo', 5000.00);



CREATE OR REPLACE FUNCTION checa_saldo()
RETURNS TRIGGER 
AS $$
BEGIN
    IF NEW.tipo = 'sacar' AND NEW.valor > (select saldo from contas WHERE id_conta = NEW.id_conta) THEN
        RAISE EXCEPTION 'saldo insuficiente na conta';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- o gatilho (trigger) que dispara a função
CREATE TRIGGER trg_checa_saldo
BEFORE INSERT ON transacoes
FOR EACH ROW
EXECUTE FUNCTION checa_saldo();


CREATE VIEW vw_extrato_transacoes AS 
SELECT
    c.titular,
    t.tipo,
    t.valor,
    t.dia
FROM transacoes t 
JOIN contas c ON t.id_conta = c.id_conta;



-- criação dos perfis (roles) e usuários
CREATE ROLE atendente;
CREATE ROLE gerente;

CREATE USER beto WITH PASSWORD 'caixa123';
CREATE USER alfredo WITH PASSWORD 'gerente123';

GRANT atendente TO beto;
GRANT gerente TO alfredo;

-- permissçoes (grants)
-- concede uso do schema public
GRAnT USAGE ON SCHEMA public TO atendente, gerente;

-- atendente: só enxerga a view (menor privilegio)
GRANT SELECT ON vw_extrato_transacoes TO atendente;

-- gerente: pode consultar e inserir nas tabelas
GRANT SELECT, INSERT ON contas, transacoes TO gerente;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public  TO gerente;


/* TESTES DE FUNCIONAMENTP */
SET ROLE beto;
SELECT * FROM vw_extrato_transacoes; -- sucesso

SELECT * from contas; -- permissão negada (pela role)
RESET ROLE;


SET ROLE alfredo;
INSERT INTO transacoes (id_conta, tipo, valor) 
VALUES (1, 'sacar', 100.00); -- sucesso (tem saldo)

INSERT INTO transacoes (id_conta, tipo, valor)
VALUES (1, 'sacar', 9999.00); -- erro (saldo insuficiente) - barrado na função do trigger
RESET ROLE;