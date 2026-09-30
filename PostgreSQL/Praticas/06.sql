create table produtos(
	id serial primary key,
	nome text,
	preco numeric(10,2),
	atualizado_em timestamp default now()
);


/* criando a funcao */
create function atualiza_data() returns trigger as $$
begin
	new.atualizado_em = now();
	return new;
end
$$ language plpgsql;


/* criando o trigger */
create trigger trg_atualiza_data
before update on produtos
for each row
execute function atualiza_data();


/* testando */
insert into produtos (nome, preco) values ('Caneta', 2.50);
select * from produtos;

update produtos set preco = 3.00 where id > 0;
select * from produtos;



/* REGISTRAR CADA INSERÇÃO NUM LOG */
create table log_produtos(
	id serial primary key,
	mensagem text,
	criado_em timestamp default now()
);

create function registra_insert() returns trigger as $$
begin
	insert into log_produtos (mensagem)
	values ('Produto Inserido: ' || new.nome);
	return new;
end;
$$ language plpgsql;


create trigger trg_registra_insert
after insert on produtos
for each row
execute function registra_insert();



-- teste
insert into produtos (nome, preco) values ('Caderno', 15.90);
select * from log_produtos;

insert into produtos (nome, preco) values ('Mochila', 55.90);