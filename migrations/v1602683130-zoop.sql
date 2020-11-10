begin;

CREATE TABLE IF NOT EXISTS client_payment (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    mall_id INTEGER NOT NULL,
    id_payment TEXT NOT NULL,
    CONSTRAINT client_id_mall_id_fk FOREIGN KEY(client_id, mall_id) REFERENCES client_mall(client_id, mall_id),
    CONSTRAINT client_payment_client_id_mall_id_key UNIQUE(client_id, mall_id)
);

CREATE TABLE IF NOT EXISTS external_store_payment (
    id SERIAL PRIMARY KEY,
    id_payment TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS store_payment (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL,
    id_payment INTEGER NOT NULL,
    CONSTRAINT store_id_fk FOREIGN KEY(store_id) REFERENCES store(id),
    CONSTRAINT store_payment_id_payment_fk FOREIGN KEY(id_payment) REFERENCES external_store_payment(id),
    CONSTRAINT store_payment_store_id_key UNIQUE(store_id)
);

CREATE TABLE IF NOT EXISTS client_payment_credit_card(
    id SERIAL PRIMARY KEY,    
    client_payment_id INTEGER NOT NULL,
    id_payment TEXT NOT NULL,
    first4_digits TEXT NOT NULL,
    last4_digits TEXT NOT NULL,
    expiration_month TEXT NOT NULL,
    expiration_year TEXT NOT NULL,
    holder_name TEXT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    CONSTRAINT client_payment_id_fk FOREIGN KEY(client_payment_id) REFERENCES client_payment(id)
);

CREATE TABLE IF NOT EXISTS store_payment_bank_account (
    id SERIAL PRIMARY KEY,    
    external_store_payment_id INTEGER NOT NULL,
    bank_account_id TEXT NOT NULL,
    holder_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    bank_code TEXT NOT NULL,
    routing_number TEXT NOT NULL,
    account_number TEXT NOT NULL,
    cnpj TEXT NOT NULL,
    type TEXT NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT store_payment_bank_account_store_payment_id_fk FOREIGN KEY(external_store_payment_id) REFERENCES external_store_payment(id)
);

CREATE TABLE IF NOT EXISTS payment_transaction(
    id SERIAL PRIMARY KEY,    
    value_card INTEGER NOT NULL,
    value_moneri INTEGER,
    store_id TEXT NOT NULL,
    client_id INTEGER NOT NULL,
    mall_id INTEGER NOT NULL, 
    portion real NOT NULL,
    description TEXT NOT NULL,
    date_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    invoice TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    CONSTRAINT client_id_mall_id_fk FOREIGN KEY(client_id, mall_id) REFERENCES client_mall(client_id, mall_id)
);

CREATE TABLE IF NOT EXISTS store_payment_bank_transfer (
    id SERIAL PRIMARY KEY,
    bank_account_id INTEGER NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT bank_account_id_fk FOREIGN KEY(bank_account_id) REFERENCES store_payment_bank_account(id)
);

CREATE TABLE IF NOT EXISTS store_payment_bank_transfer_origin (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

INSERT INTO store_payment_bank_transfer_origin (name)
VALUES
    ('ZOOP'),
    ('MONERI')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS store_payment_bank_transfer_item (
    id SERIAL PRIMARY KEY,
    origin INTEGER NOT NULL,
    value INTEGER NOT NULL,
    bank_transfer_id INTEGER NOT NULL,
    external_id TEXT NOT NULL,
    CONSTRAINT bank_transfer_id_fk FOREIGN KEY(bank_transfer_id) REFERENCES store_payment_bank_transfer(id),
    CONSTRAINT origin_fk FOREIGN KEY(origin) REFERENCES store_payment_bank_transfer_origin(id)
);

INSERT INTO __db_version(version_date, author, comments) VALUES('2020-11-09', 'Carlos Moreira', 'Criação das tabelas para integração com zoop');

commit;