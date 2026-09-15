/*
a) (0,4) Aponte, como comentários SQL (--), por que a estrutura viola a 1FN, a 2FN e
a 3FN. Cite pelo menos uma anomalia (inserção, alteração ou exclusão) causada por essa 
estrutura.

-- A tabela viola a 1 FN em na coluna Telefone_Cliente, onde possui mais de um telefone em uma célula;
também viola a 1FN nas colunas servicos_realizados e pecas_usadas pelo mesmo motivo.
A tabela viola a 2FN porque sua inserção de dados é ineficiente, onde num cenário
em que o cliente 'Carlos Silva' comprasse outro veículo, seus dados teriam que ser inseridos novamente,
duplicando seu nome, telefone, e diversas outras informações desse cliente na base de dados. (anomalia de inserção)
A tabela viola a 3FN por conta de dependencia transitiva entre suas colunas. placa_veiculo deveria depender unicamente
de uma chave primaria pertencente a uma tabela específica feita para a entidade 'veículos', mas na tabela desnormalizada apresentada,
conseguimos "atrelar" nome_cliente com placa_veiculo, que deviam estar em entidades distintas, ambas dependendo 
apenas de sua respectiva chave primária.
mais um cenário possível de anomalia de inserção: o usuário 'Carlos Silva' adiciona mais um telefone pra contato,
e isso acaba colocando uma terceira informação em uma única célula (violando 1FN).
  
 
b) (0,3) Liste, como comentários SQL, as dependências funcionais que você identificou
nos dados.


c) (0,8) Aplique a normalização passo a passo e apresente o esquema relacional final 
normalizado até a 3FN, indicando claramente as Chaves Primárias (PK) e as Chaves 
Estrangeiras (FK) de cada tabela resultante. (Pode apresentar como comentários SQL 
ou como os CREATE TABLE correspondentes.) [feito na questão 2)

*/



/* Questão 2 */
create table clientes(
	id_cliente serial primary key,
	nome_cliente varchar(200) not null,
	telefone numeric(13),
	cpf_cliente numeric(11) unique not null
);

create table veiculos(
	placa varchar(8) primary key,
	modelo_veiculo varchar(200) not null,
	ano_veiculo int not null check(ano_veiculo between 1990 and 2026),
	id_cliente int references clientes(id_cliente)
);


create table ordem_servico(
	id_os serial primary key,
	data_abertura date not null default current_date,
	status varchar(100) default 'ABERTO',
	valor_total numeric(12,2) not null,
	placa_veiculo varchar references veiculos(placa)
);


/* Questão 3 */

-- Dois clientes com dados fictícios.
insert into clientes(nome_cliente, telefone, cpf_cliente) values
('Jean de Sta Cruz', 22987657864, 12345678901),
('Pedrão da Manga', 21986789432, 11122233344),
('Zé da Manga', 22987657864, 12355678901);

-- Dois veículos — um associado ao primeiro cliente e outro ao segundo.
insert into veiculos(placa, modelo_veiculo, ano_veiculo, id_cliente) values
('ABC-12B1', 'Fiat Argo', 2021, 1),
('DIV-1234', 'VW Polo', 2019, 2);

-- Duas ordens de serviço: uma com status 'ABERTA' para o primeiro veículo e outra 
-- com status 'CONCLUÍDA' para o segundo veículo, cada uma com um valor_total à sua escolha.
insert into ordem_servico(status, valor_total, placa_veiculo) values
('ABERTO', 38000, 'ABC-12B1'),
('CONCLUIDA', 42000, 'DIV-1234');




/* Questão 4 */
-- a) O cliente de CPF '111.222.333-44' mudou de número. 
-- Atualize o telefone dele para '(11) 99999-0000'
update clientes
set telefone = 119999900000
where cpf_cliente = 11122233344;


-- b) A oficina decidiu finalizar a OS aberta para o primeiro veículo. Atualize o 
-- campo status para 'CONCLUÍDA' na ordem correspondente.
update ordem_servico
set status = 'CONCLUIDA'
where placa_veiculo = 'ABC-12B1';

select * from ordem_servico;





/* Questão 5 */

-- a) (0,35) Escreva o comando SQL para remover do banco a(s) OS com status 'CANCELADA' 
-- que tenham sido abertas antes de '2023-01-01'. (O comando deve estar correto ainda 
-- que, nos seus dados de teste, ele afete 0 linhas.)
delete from ordem_servico 
where data_abertura < '2023-01-01' and status = 'ABERTO';


/*

-- b) (0,40) Se você executar DELETE FROM Cliente WHERE id_cliente = 1; em um banco onde 
-- esse cliente possui veículos e ordens de serviço vinculadas, sem configuração de 
-- cascata (ON DELETE RESTRICT), o que acontece? Como você resolveria essa operação 
-- mantendo a consistência dos dados? Responda em comentário SQL.

-- Como clientes tem uma tabela que depende dela (veiculos, que referencia a chave primária
-- de clientes), não seria possível deletar imediatamente um registro da tabela clientes sem
-- antes deletar o registro que referencia o identificador desse cliente na outra tabela.
-- Resumindo: primeiro apaga o registro na tabela 'filha', pra depois apagar na tabela 'pai'
-- O mesmo se aplica a registros da tabela ordens de servico, que depende de veiculos.

*/




/* Questão 6 */

-- a) (0,5) Uma consulta que liste o nome do cliente, a placa do veículo e o status da
-- OS de todas as ordens de serviço já abertas, utilizando INNER JOIN.

select 
	clientes.nome_cliente,
	veiculos.placa,
	ordem_servico.status
from clientes
inner join veiculos on clientes.id_cliente = veiculos.id_cliente
inner join ordem_servico on veiculos.placa = ordem_servico.placa_veiculo;


-- b) (0,5) Uma consulta que liste todos os clientes cadastrados e seus respectivos veículos 
-- (placa e modelo), incluindo clientes que ainda não possuem veículo registrado — nesse 
-- caso, use LEFT JOIN (os campos do veículo devem aparecer como NULL).
select
	clientes.id_cliente,
	clientes.nome_cliente,
	clientes.telefone,
	clientes.cpf_cliente,
	veiculos.placa,
	veiculos.modelo_veiculo,
	veiculos.ano_veiculo
from clientes
left join veiculos on clientes.id_cliente = veiculos.id_cliente; -- FUNCIONANDO!


-- c) (0,5) Uma consulta com JOIN entre Ordem_Servico e Veiculo que retorne a quantidade 
-- de ordens de serviço por veículo (agrupando pela placa), utilizando GROUP BY e COUNT
select
	ordem_servico.placa_veiculo
from ordem_servico
join veiculos on veiculos.placa = ordem_servico.placa_veiculo;
/*join count(placa_veiculo) from ordem_servico group by placa_veiculo;*/



-- d) (0,5) Uma consulta que retorne o valor total faturado 
-- (SUM de valor_total) por status de OS, utilizando GROUP BY.

select sum(valor_total)
from ordem_servico
group by status;

select * from ordem_servico;
