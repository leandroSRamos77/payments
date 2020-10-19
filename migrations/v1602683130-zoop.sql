begin;

DROP TABLE IF EXISTS payment_transaction;
DROP TABLE IF EXISTS store_payment_bank_account;
DROP TABLE IF EXISTS client_payment_credit_card;
DROP TABLE IF EXISTS store_payment;
DROP TABLE IF EXISTS client_payment;
delete from __db_version where version = 196;

CREATE TABLE client_payment (
    id	SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    mall_id INTEGER NOT NULL,
    id_payment TEXT NOT NULL
);

ALTER TABLE client_payment ADD CONSTRAINT client_id_mall_id_fk FOREIGN KEY(client_id, mall_id) REFERENCES client_mall(client_id, mall_id);

CREATE TABLE store_payment(
    id	SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL,
    mall_id INTEGER NOT NULL,
    id_payment TEXT NOT NULL
);

ALTER TABLE store_payment ADD CONSTRAINT store_id_mall_id_fk FOREIGN KEY(store_id, mall_id) REFERENCES store(id, mall_id);

CREATE TABLE client_payment_credit_card(
    id SERIAL PRIMARY KEY,    
    client_payment_id INTEGER NOT NULL,
    id_payment TEXT NOT NULL,
    first4_digits TEXT NOT NULL,
    last4_digits TEXT NOT NULL,
    expiration_month TEXT NOT NULL,
    expiration_year TEXT NOT NULL,
    holder_name TEXT NOT NULL,
    mall_id INTEGER NOT NULL, 
    enabled BOOLEAN DEFAULT TRUE 
);

ALTER TABLE client_payment_credit_card ADD CONSTRAINT client_payment_id_fk FOREIGN KEY(client_payment_id) REFERENCES client_payment(id);

CREATE TABLE store_payment_bank_account(
    id SERIAL PRIMARY KEY,    
    store_payment_id INTEGER NOT NULL,
    bank_account_id TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    routing_number INTEGER NOT NULL,
    account_number INTEGER NOT NULL, 
    mall_id INTEGER NOT NULL, 
    enabled BOOLEAN DEFAULT TRUE 
);

ALTER TABLE store_payment_bank_account ADD CONSTRAINT store_payment_id_fk FOREIGN KEY(store_payment_id) REFERENCES store_payment(id);

CREATE TABLE payment_transaction(
    id SERIAL PRIMARY KEY,    
    value INTEGER NOT NULL,
    store_id TEXT NOT NULL,
    client_id INTEGER NOT NULL,
    mall_id INTEGER NOT NULL, 
    portion real NOT NULL,
    description TEXT NOT NULL,
    date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    invoice TEXT,
    status TEXT NOT NULL DEFAULT 'pending' 
);

ALTER TABLE payment_transaction ADD CONSTRAINT client_id_mall_id_fk FOREIGN KEY(client_id, mall_id) REFERENCES client_mall(client_id, mall_id);

INSERT INTO __db_version(version_date, author, comments) VALUES('2020-10-19', 'Maycon Aguiar Teixeira da Silva', 'Criação da tabela client_payment');

commit;
