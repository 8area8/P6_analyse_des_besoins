---------------------
-- OC PIZZAS DATABASE
---------------------


-- CREATE DATABASE ocpizzas
-- \c ocpizzas


DROP SCHEMA IF EXISTS PUBLIC CASCADE;
CREATE SCHEMA PUBLIC;


DROP EXTENSION IF EXISTS pgcrypto;
CREATE EXTENSION pgcrypto;
CREATE EXTENSION citext;
CREATE DOMAIN EMAIL AS citext CHECK ( VALUE ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );


CREATE TABLE country (
    id          SERIAL,
    name        VARCHAR (200),
    PRIMARY KEY (id));


CREATE TABLE adress (
    id                          SERIAL,
    country_id                  INTEGER,
    road_number                 SMALLINT,
    road                        VARCHAR (300),
    postal_code                 VARCHAR(40),
    town                        VARCHAR (300),
    PRIMARY KEY (id),
    FOREIGN KEY (country_id) REFERENCES country(id) ON DELETE CASCADE);

CREATE INDEX idx_country_id On adress (country_id);
CREATE INDEX idx_town On adress (town);


CREATE TABLE pizzeria (
    id          SERIAL,
    adress_id   INTEGER,
    name        VARCHAR (150),
    PRIMARY KEY (id),
    FOREIGN KEY (adress_id) REFERENCES adress(id) ON DELETE CASCADE);

CREATE INDEX idx_pizzeria_name ON pizzeria (name);


CREATE TABLE ingredient (
    id          SERIAL,
    name        VARCHAR (150),
    price       NUMERIC (5, 2),
    PRIMARY KEY (id));

CREATE INDEX idx_ingr_name On ingredient (name);


CREATE TABLE product (
    id          SERIAL,
    name        VARCHAR (150),
    price       NUMERIC (5, 2),
    PRIMARY KEY (id));

CREATE INDEX idx_prod_name On product (name);


CREATE TABLE stock_property
(
    id SERIAL,
    name VARCHAR (150),
    PRIMARY KEY (id)
);


CREATE TABLE ingredient_per_pizzeria (
    id              SERIAL,
    pizzeria_id     INTEGER,
    ingredient_id   INTEGER,
    stock_property_id     INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredient(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_property_id) REFERENCES stock_property(id) ON DELETE CASCADE);

CREATE INDEX idx_stock_property On ingredient_per_pizzeria (stock_property_id);


CREATE TABLE ingredient_per_product (
    id                  SERIAL,
    ingredient_id       INTEGER,
    product_id          INTEGER,
    recipe_description  VARCHAR (250),
    recipe_position     SMALLINT,
    PRIMARY KEY (id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredient(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE);


CREATE TABLE gender (
    id          SERIAL,
    sex         VARCHAR (10),
    PRIMARY KEY (id));


CREATE TABLE phone_number (
    id          SERIAL,
    number      TEXT UNIQUE,
    PRIMARY KEY (id));


CREATE TABLE mail (
    id                  SERIAL,
    mail_adress         EMAIL UNIQUE,
    PRIMARY KEY (id));


CREATE TABLE personnal_information (
    id                  SERIAL,
    gender_id           INTEGER,
    phone_number_id     INTEGER,
    first_name          VARCHAR (100),
    last_name           VARCHAR (100),
    PRIMARY KEY (id),
    FOREIGN KEY (gender_id) REFERENCES gender(id) ON DELETE CASCADE,
    FOREIGN KEY (phone_number_id) REFERENCES phone_number(id) ON DELETE CASCADE);

CREATE INDEX idx_names On personnal_information (first_name, last_name);


CREATE TABLE payment_status
(
    id SERIAL,
    name VARCHAR(100),
    PRIMARY KEY (id)
);


CREATE TABLE general_status
(
    id SERIAL,
    name VARCHAR(100),
    PRIMARY KEY (id)
);


CREATE TABLE command (
    id                      SERIAL,
    pizzeria_id             INTEGER NOT NULL,
    mail_id                 INTEGER NOT NULL,
    payment_status_id       INTEGER DEFAULT 1,
    general_status_id       INTEGER DEFAULT 1,
    adress_id               INTEGER NOT NULL,
    phone_number_id         INTEGER NOT NULL,
    tracking_number         UUID DEFAULT gen_random_uuid(),
    creation_date           TIMESTAMP DEFAULT current_timestamp,
    last_modification_date  TIMESTAMP DEFAULT current_timestamp,
    archivated              BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id),
    FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id) ON DELETE CASCADE,
    FOREIGN KEY (mail_id) REFERENCES mail(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_status_id) REFERENCES payment_status(id) ON DELETE CASCADE,
    FOREIGN KEY (general_status_id) REFERENCES general_status(id) ON DELETE CASCADE,
    FOREIGN KEY (adress_id) REFERENCES adress(id) ON DELETE CASCADE,
    FOREIGN KEY (phone_number_id) REFERENCES phone_number(id) ON DELETE CASCADE);

CREATE INDEX idx_pizzeria_id ON command (pizzeria_id);
CREATE INDEX idx_dates ON command (last_modification_date, creation_date DESC);
CREATE INDEX idx_general_status ON command (general_status_id);
CREATE INDEX idx_archivated ON command (archivated);


CREATE TABLE product_per_command (
    id              SERIAL,
    product_id      INTEGER,
    command_id      INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (command_id) REFERENCES command(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE);

CREATE INDEX idx_product_id On product_per_command (product_id);
CREATE INDEX idx_ppc_command_id On product_per_command (command_id);


CREATE TABLE adding (
    id                          SERIAL,
    ingredient_id               INTEGER,
    product_per_command_id     INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredient(id) ON DELETE CASCADE,
    FOREIGN KEY (product_per_command_id) REFERENCES product_per_command(id) ON DELETE CASCADE);


CREATE TABLE deletion (
    id                          SERIAL,
    ingredient_id               INTEGER,
    product_per_command_id     INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredient(id) ON DELETE CASCADE,
    FOREIGN KEY (product_per_command_id) REFERENCES product_per_command(id) ON DELETE CASCADE);


CREATE TABLE tva (
    id              SERIAL,
    tva_rate        NUMERIC,
    change_date     DATE,
    PRIMARY KEY (id));

CREATE INDEX idx_change_date On tva (change_date DESC);


CREATE TABLE account (
    id                          SERIAL,
    mail_id                     INTEGER,
    personnal_information_id    INTEGER,
    passhash                    TEXT NOT NULL,
    userid                      VARCHAR (20) NOT NULL UNIQUE,
    PRIMARY KEY (id),
    FOREIGN KEY (mail_id) REFERENCES mail(id) ON DELETE CASCADE,
    FOREIGN KEY (personnal_information_id) REFERENCES personnal_information(id) ON DELETE CASCADE);


CREATE TABLE command_per_account (
    id              SERIAL,
    account_id      INTEGER,
    command_id      INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY (command_id) REFERENCES command(id) ON DELETE CASCADE);


CREATE TABLE user_role (
    id              SERIAL,
    role_name       TEXT NOT NULL,
    PRIMARY KEY (id));


CREATE TABLE user_role_per_account (
    id              SERIAL,
    account_id      INTEGER,
    user_role_id    INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE,
    FOREIGN KEY (user_role_id) REFERENCES user_role(id) ON DELETE CASCADE);


CREATE TABLE adress_per_personnal_information(
    id                          SERIAL,
    personnal_information_id    INTEGER,
    adress_id                   INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (personnal_information_id) REFERENCES personnal_information(id) ON DELETE CASCADE,
    FOREIGN KEY (adress_id) REFERENCES adress(id) ON DELETE CASCADE);


CREATE TABLE banking_card (
    id                          SERIAL,
    personnal_information_id    INTEGER,
    token_card                  TEXT,
    PRIMARY KEY (id),
    FOREIGN KEY (personnal_information_id) REFERENCES personnal_information(id) ON DELETE CASCADE);


CREATE TABLE pizzeria_affiliate (
    id SERIAL,
    pizzeria_id     INTEGER,
    account_id      INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE);



-- ------------------------
-- ------- VALUES ---------
---------------------------

INSERT INTO country (name) VALUES ('France');

INSERT INTO tva (tva_rate, change_date) VALUES (20, '2018-01-04');

INSERT INTO gender (sex) VALUES
    ('male'),
    ('female'),
    ('Asexual');

INSERT INTO adress (country_id, road_number, road, postal_code, town) VALUES
    (1, 11, 'rue de rivoli', '750001', 'Paris'),
    (1, 34, 'place de la république', '75005', 'Paris'),
    (1, 2, 'rue du chat', '75019', 'Paris');

INSERT INTO pizzeria (adress_id, name) VALUES
    (1, 'OC pizzas châtelet'),
    (2, 'OC pizzas république'),
    (3, 'OC pizzas belleville');

INSERT INTO ingredient (name, price) VALUES
    ('base tomate', 4),
    ('base crème fraîche', 5),
    ('tomates', 1),
    ('saumon', 4),
    ('fromage', 1),
    ('olives', 1),
    ('jambon', 3),
    ('champignons', 1);

INSERT INTO product (name, price) VALUES
    ('margarita', 9),
    ('jambon fromage', 11),
    ('saumon', 13),
    ('végétarienne', 10);

INSERT INTO stock_property (name) VALUES
    ('vide'),
    ('très peu'),
    ('la moitié'),
    ('beaucoup'),
    ('plein');

INSERT INTO ingredient_per_pizzeria (pizzeria_id, ingredient_id) VALUES
    (1, 1), (2, 1), (3, 1),
    (1, 2), (2, 2), (3, 2),
    (1, 3), (2, 3), (3, 3),
    (1, 4), (3, 4),
    (1, 5), (2, 5), (3, 5),
    (1, 6), (2, 6), (3, 6),
    (1, 7), (2, 7),
    (1, 8), (2, 8), (3, 8);

INSERT INTO ingredient_per_product (product_id, ingredient_id) VALUES
    (1, 2), (1, 5),
    (2, 1), (2, 5), (2, 6), (2, 7),
    (3, 2), (3, 4), (3, 5),
    (4, 1), (4, 3), (4, 5), (4, 8), (4, 6);

INSERT INTO general_status (name) VALUES
    ('en attente'),
    ('en préparation'),
    ('en attente de retrait'),
    ('prête à l envoie'),
    ('en cours de livraison'),
    ('livré'),
    ('annulée');

INSERT INTO payment_status (name) VALUES
    ('en attente de paiment'),
    ('payé');

INSERT INTO user_role (role_name) VALUES
    ('super_user'), ('pizzaïolo'), ('seller'), ('delivery'), ('customer');



-- -------------------------------
-- -------- FUNCTIONS ------------
-- -------------------------------



-- Create an account. Put a "customer" role by default.
--
CREATE FUNCTION f_create_account (a_mail EMAIL, a_gender_id INTEGER, a_first_name VARCHAR(100),
    a_last_name VARCHAR(100), a_phone_number TEXT, a_password TEXT, a_userid VARCHAR(20))
    RETURNS INTEGER
    AS
    '
      DECLARE 
        id_mail INTEGER;
        id_phone_number INTEGER;
        id_perso INTEGER;
        id_account INTEGER;
      BEGIN
        INSERT INTO mail (mail_adress) VALUES (a_mail) ON CONFLICT DO NOTHING;
        INSERT INTO phone_number (number) VALUES (a_phone_number) ON CONFLICT DO NOTHING;

        SELECT id INTO id_phone_number FROM phone_number WHERE number = a_phone_number;

        INSERT INTO personnal_information (gender_id, first_name, last_name, phone_number_id) VALUES
            (a_gender_id, a_first_name, a_last_name, id_phone_number) RETURNING id INTO id_perso;
        
        SELECT id INTO id_mail FROM mail WHERE mail_adress = a_mail;
        INSERT INTO account (mail_id, personnal_information_id, passhash, userid) VALUES
            (id_mail, id_perso, crypt(a_password, gen_salt(''bf'', 8)), a_userid) RETURNING id INTO id_account;
        
        INSERT INTO user_role_per_account (account_id, user_role_id) VALUES
            (id_account, 5);
        RETURN 1;
      END ;
    '
    LANGUAGE 'plpgsql';


-- Set a new role to an account. Use with this query : SELECT * FROM pg_roles WHERE rolname = 'postgres';
--
CREATE FUNCTION f_set_role (a_userid VARCHAR(20), a_user_role_id INTEGER)
    RETURNS INTEGER
    AS
    '
      DECLARE 
        id_account INTEGER;
      BEGIN
        SELECT id INTO id_account FROM account WHERE userid = a_userid;

        INSERT INTO user_role_per_account (account_id, user_role_id) VALUES
            (id_account, a_user_role_id);
        RETURN 1;
      END ;
    '
    LANGUAGE 'plpgsql';


-- Affiliate an account to a pizzeria. Used for crews.
--
CREATE FUNCTION f_affiliate_pizzeria (a_userid VARCHAR(20), a_pizzeria_id INTEGER)
    RETURNS INTEGER
    AS
    '
      DECLARE 
        id_account INTEGER;
      BEGIN
        SELECT id INTO id_account FROM account WHERE userid = a_userid;
        
        INSERT INTO pizzeria_affiliate (account_id, pizzeria_id) VALUES
            (id_account, a_pizzeria_id);
        RETURN 1;
      END ;
    '
    LANGUAGE 'plpgsql';


--
--
CREATE FUNCTION f_create_adress (a_country_id INTEGER, a_road_number SMALLINT,
    a_road VARCHAR(300), a_postal_code VARCHAR(40), a_town VARCHAR(300))
    RETURNS INTEGER
    AS
    '
      DECLARE
        id_adress INTEGER;
      BEGIN   
        INSERT INTO adress (country_id, road_number, road, postal_code, town) VALUES
            (a_country_id, a_road_number, a_road, a_postal_code, a_town) RETURNING id INTO id_adress;
        RETURN id_adress;
      END ;
    '
    LANGUAGE 'plpgsql';


--
--
CREATE FUNCTION f_create_command (a_mail_id INTEGER, a_pizzeria_id INTEGER, a_adress_id INTEGER, a_phone_number_id INTEGER)
    RETURNS INTEGER
    AS
    '
      DECLARE
        id_command INTEGER;
    BEGIN
        INSERT INTO command (pizzeria_id, mail_id, adress_id, phone_number_id) VALUES
            (a_pizzeria_id, a_mail_id, a_adress_id, a_phone_number_id) RETURNING id INTO id_command;
        RETURN id_command;
      END ;
    '
    LANGUAGE 'plpgsql';


--
--
CREATE FUNCTION f_create_command_product (a_command_id INTEGER, a_product_id INTEGER)
    RETURNS INTEGER
    AS
    '
      DECLARE
        id_product_per_command INTEGER;
      BEGIN
        INSERT INTO product_per_command (command_id, product_id) VALUES
            (a_command_id, a_product_id) RETURNING id INTO id_product_per_command;
        RETURN id_product_per_command;
      END ;
    '
    LANGUAGE 'plpgsql';
    

--
--
CREATE FUNCTION f_modify_command_product (a_add_or_del BOOLEAN, a_product_per_command_id INTEGER, a_ingredient_id INTEGER)
    RETURNS INTEGER
    AS
    '
      BEGIN
        IF a_add_or_del = TRUE THEN
            INSERT INTO deletion (product_per_command_id, ingredient_id) VALUES
                (a_product_per_command_id, a_ingredient_id);
        ELSE
            INSERT INTO adding (product_per_command_id, ingredient_id) VALUES
                (a_product_per_command_id, a_ingredient_id);
        END IF;
        RETURN 1;
      END ;
    '
    LANGUAGE 'plpgsql';


--
--
CREATE FUNCTION f_total_price (a_command_id INTEGER)
    RETURNS NUMERIC
    AS
    '
      DECLARE
        total_price NUMERIC;
      BEGIN
        SELECT SUM(price)::NUMERIC INTO total_price
            FROM product
            INNER JOIN product_per_command AS ppc ON ppc.product_id = product.id
            INNER JOIN command ON command.id = ppc.command_id
            WHERE command.id = a_command_id;
        
        SELECT COALESCE(total_price + SUM(price)::NUMERIC, total_price) INTO total_price
            FROM ingredient
            INNER JOIN adding ON adding.ingredient_id = ingredient.id
            INNER JOIN product_per_command AS ppc ON ppc.id = adding.product_per_command_id
            INNER JOIN command ON command.id = ppc.command_id
            WHERE command.id = a_command_id;
        
        SELECT COALESCE(total_price - ROUND(SUM(price) / 2, 2), total_price) INTO total_price
            FROM ingredient
            INNER JOIN deletion ON deletion.ingredient_id = ingredient.id
            INNER JOIN product_per_command AS ppc ON ppc.id = deletion.product_per_command_id
            INNER JOIN command ON command.id = ppc.command_id
            WHERE command.id = a_command_id;

        RETURN total_price;
      END ;
    '
    LANGUAGE 'plpgsql';


CREATE FUNCTION f_notax_price (a_command_id INTEGER)
    RETURNS NUMERIC
    AS
    '
      DECLARE
        notax_price NUMERIC;
        rate_tva NUMERIC;
      BEGIN
        SELECT tva_rate INTO rate_tva
            FROM tva, command
            WHERE command.id = 1 AND change_date = (SELECT MAX(change_date) FROM tva);

        SELECT f_total_price(a_command_id) INTO notax_price;
        SELECT notax_price::NUMERIC / (1::NUMERIC + (rate_tva / 100::NUMERIC)) INTO notax_price;

        RETURN ROUND(notax_price, 2);
      END ;
    '
    LANGUAGE 'plpgsql';



-- -------------------------------
-- ----- SECONDARY VALUES --------
-- -------------------------------


-- CUSTOMERS
--
SELECT f_create_account('lalila@gmail.com', 2, 'Lucie', 'Koko', '0603495920', 'test12', 'luludu48');
DO
'
    DECLARE
        id_adress INTEGER;
        id_personnal_information INTEGER;
    BEGIN
        SELECT f_create_adress (1::INTEGER, 23::SMALLINT, ''rue de chez moi''::VARCHAR(300), ''75020''::VARCHAR(40), ''paris''::VARCHAR(300)) INTO id_adress;

        SELECT personnal_information.id INTO id_personnal_information
            FROM personnal_information
            INNER JOIN account ON account.personnal_information_id = personnal_information.id
            WHERE account.userid = ''luludu48'';

        INSERT INTO adress_per_personnal_information (adress_id, personnal_information_id) VALUES (id_adress, id_personnal_information);
    END;
'
LANGUAGE 'plpgsql';


SELECT f_create_account('mdt@hotmail.fr', 1, 'Marc', 'Luke', '0601195420', 'cestmoilepatron', 'darksidious');
SELECT f_create_account('luciendesete@gmail.com', 1, 'Lucien', 'desète', '0747578329', 'luciendesète1234', 'luludesète');
SELECT f_create_account('margueritemeuh@gmail.com', 2, 'marguerite', 'Meuh', '0601115920', 'meuh&&&111', 'meuhmeuh');


-- SELLERS
--
SELECT f_create_account('jeandarengie@gmail.com', 1, 'Jean', 'Darengie', '0784943355', 'seller1&$', 'Jean Darengie');
SELECT f_affiliate_pizzeria('Jean Darengie', 1);
SELECT f_set_role('Jean Darengie', 3);

SELECT f_create_account('martinparat@gmail.com', 1, 'Martin', 'Parat', '0782222355', 'seller2^^', 'Martin Parat');
SELECT f_affiliate_pizzeria('Martin Parat', 2);
SELECT f_set_role('Martin Parat', 3);


-- PIZZAÏOLOS
--
SELECT f_create_account('agathelarin@gmail.com', 2, 'Agathe', 'Larin', '0784943355', 'pizzaïolo&$', 'Agathe Larin');
SELECT f_affiliate_pizzeria('Agathe Larin', 1);
SELECT f_set_role('Agathe Larin', 2);

-- Martin Parat is a seller AND a pizzaïolo. ;)
SELECT f_set_role('Martin Parat', 2);


-- DELIVERS
--
SELECT f_create_account('philipedanas@gmail.com', 1, 'Philipe', 'Danas', '0737293847', 'deliver&$', 'Philipe Danas');
SELECT f_affiliate_pizzeria('Philipe Danas', 1);
SELECT f_set_role('Philipe Danas', 4);

SELECT f_create_account('sophiezzz@gmail.com', 2, 'Sophie', 'Zira', '0784243355', 'deliver&$', 'Sophie Zira');
SELECT f_affiliate_pizzeria('Sophie Zira', 2);
SELECT f_set_role('Sophie Zira', 2);


-- ADMIN
--
SELECT f_create_account('mikaelaradu@gmail.com', 1, 'Mikael', 'Aradu', '0737003847', 'admin&$', 'Mikael Aradu');
SELECT f_set_role('Mikael Aradu', 1);



-- -------------------------------
-- ----- COMMANDS ----------------
-- -------------------------------


-- A customer create a command. He has no account.
-- 
DO
'
    DECLARE
        id_adress INTEGER;
        id_mail INTEGER;
        id_phone_number INTEGER;
        id_command INTEGER;
        id_prod_per_com INTEGER;
    BEGIN
        SELECT f_create_adress (1::INTEGER, 10::SMALLINT, ''rue de leon''::VARCHAR(300), ''75010''::VARCHAR(40), ''paris''::VARCHAR(300)) INTO id_adress;

        INSERT INTO mail (mail_adress) VALUES (''jenesuispasauthentifie@gmail.com'') ON CONFLICT DO NOTHING;
        SELECT id INTO id_mail FROM mail WHERE mail_adress = ''jenesuispasauthentifie@gmail.com'';

        INSERT INTO phone_number (number) VALUES (''0603928374'') ON CONFLICT DO NOTHING;
        SELECT id INTO id_phone_number FROM phone_number WHERE number = ''0603928374'';

        SELECT f_create_command (id_mail::INTEGER, 1::INTEGER, id_adress::INTEGER, id_phone_number::INTEGER) INTO id_command;

        SELECT f_create_command_product (id_command, 4) INTO id_prod_per_com;
        PERFORM f_modify_command_product (TRUE, id_prod_per_com, 4);
        
        PERFORM f_create_command_product (id_command, 2);
    END;
'
LANGUAGE 'plpgsql';


-- A seller takes a customer command. We find the pizzeria id from the table 'affiliate_pizzeria'.
--
DO
'
    DECLARE
        id_adress INTEGER;
        id_mail INTEGER;
        id_phone_number INTEGER;
        id_pizzeria INTEGER;
        id_command INTEGER;
        id_prod_per_com INTEGER;
    BEGIN
        SELECT f_create_adress (1::INTEGER, 34::SMALLINT, ''avenu de ouioui''::VARCHAR(300), ''75001''::VARCHAR(40), ''paris''::VARCHAR(300)) INTO id_adress;

        INSERT INTO mail (mail_adress) VALUES (''commandseller@gmail.com'') ON CONFLICT DO NOTHING;
        SELECT id INTO id_mail FROM mail WHERE mail_adress = ''commandseller@gmail.com'';

        INSERT INTO phone_number (number) VALUES (''0640528374'') ON CONFLICT DO NOTHING;
        SELECT id INTO id_phone_number FROM phone_number WHERE number = ''0640528374'';

        SELECT pizz.id INTO id_pizzeria
            FROM pizzeria AS pizz
            INNER JOIN pizzeria_affiliate AS pizz_af ON pizz_af.pizzeria_id = pizz.id
            INNER JOIN account ON account.id = pizz_af.account_id
            WHERE account.userid = ''Martin Parat'';

        SELECT f_create_command (id_mail::INTEGER, id_pizzeria::INTEGER, id_adress::INTEGER, id_phone_number::INTEGER) INTO id_command;

        SELECT f_create_command_product (id_command, 1) INTO id_prod_per_com;
        PERFORM f_modify_command_product (TRUE, id_prod_per_com, 5);
        
        PERFORM f_create_command_product (id_command, 3);
    END;
'
LANGUAGE 'plpgsql';


-- A customer takes a command. He has an account.
--
DO
'
    DECLARE
        id_adress INTEGER;
        id_mail INTEGER;
        id_phone_number INTEGER;
        id_command INTEGER;
        id_prod_per_com INTEGER;
    BEGIN
        SELECT adress.id INTO id_adress
            FROM adress
            INNER JOIN adress_per_personnal_information AS adr_p_pi ON adress.id = adr_p_pi.adress_id
            INNER JOIN personnal_information AS pi ON pi.id = adr_p_pi.personnal_information_id
            INNER JOIN account ON account.personnal_information_id = pi.id
            WHERE account.userid = ''luludu48'';

        SELECT mail.id INTO id_mail
            FROM mail
            INNER JOIN account ON account.mail_id = mail.id
            WHERE account.userid = ''luludu48'';

        SELECT phone_number.id INTO id_phone_number
            FROM phone_number
            INNER JOIN personnal_information AS pi ON pi.phone_number_id = phone_number.id
            INNER JOIN account ON account.personnal_information_id = pi.id
            WHERE account.userid = ''luludu48'';

        SELECT f_create_command (id_mail::INTEGER, 2::INTEGER, id_adress::INTEGER, id_phone_number::INTEGER) INTO id_command;
        SELECT f_create_command_product (id_command, 4) INTO id_prod_per_com;
        PERFORM f_modify_command_product (FALSE, id_prod_per_com, 6);
        
        PERFORM f_create_command_product (id_command, 2);
        PERFORM f_modify_command_product (TRUE, id_prod_per_com, 3);
        PERFORM f_modify_command_product (FALSE, id_prod_per_com, 4);
    END;
'
LANGUAGE 'plpgsql';



-- -------------------------------
-- -------- VIEWS ----------------
-- -------------------------------



CREATE VIEW v_command_product AS
    SELECT product.name AS "nom", product.price AS "prix", command.id AS "numero de commande"
    FROM product
    INNER JOIN product_per_command AS ppc ON ppc.product_id = product.id
    INNER JOIN command ON command.id = ppc.command_id;

CREATE VIEW v_command_adding AS
    SELECT adding.id AS additions_id, ppc.id AS product_per_com_id,
        product.name AS produits, CONCAT(ingredient.name, ' + ', ingredient.price, ' euros') AS retraits,
        command.id AS "numero de commande"
    FROM product_per_command AS ppc
    INNER JOIN adding ON ppc.id = adding.product_per_command_id
    INNER JOIN ingredient ON ingredient.id = adding.ingredient_id
    LEFT JOIN product ON product.id = ppc.product_id
    LEFT JOIN command ON command.id = ppc.command_id
    ORDER BY product.name;

CREATE VIEW v_command_deletion AS
    SELECT deletion.id AS deletion_id, ppc.id AS product_per_com_id,
        product.name AS produits, CONCAT(ingredient.name, ' - ', TRUNC(ingredient.price / 2, 2), ' euros') AS retraits,
        command.id AS "numero de commande"
    FROM product_per_command AS ppc
    INNER JOIN deletion ON ppc.id = deletion.product_per_command_id
    INNER JOIN ingredient ON ingredient.id = deletion.ingredient_id
    LEFT JOIN product ON product.id = ppc.product_id
    LEFT JOIN command ON command.id = ppc.command_id
    ORDER BY product.name;


CREATE VIEW v_command_general AS
    SELECT command.id AS "numero de commande", command.tracking_number AS "numero de suivi",
    TO_CHAR(command.creation_date, 'YYYY-MM-DD HH24:MI') AS "date de creation", 
    TO_CHAR(command.last_modification_date, 'YYYY-MM-DD HH24:MI') AS "derniere modification",
        f_notax_price(command.id::INTEGER) AS "prix hors taxe", f_total_price(command.id) AS "prix TTC",
        general_status.name AS "statut", payment_status.name AS "statut de paiement"
    FROM command
    INNER JOIN general_status ON general_status.id = command.general_status_id
    INNER JOIN payment_status ON payment_status.id = command.payment_status_id;





CREATE VIEW v_standing_command AS
    SELECT command.id AS "numero de commande", command.pizzeria_id AS "pizzeria",
        general_status.name AS "statut general"
    FROM command
    INNER JOIN general_status ON general_status.id = command.general_status_id
    ORDER BY creation_date;

SELECT "numero de commande", "statut general" FROM v_standing_command WHERE "pizzeria" = 2;
UPDATE command SET general_status_id = 2 WHERE command.id = 2;
UPDATE command SET general_status_id = 4 WHERE command.id = 2;
UPDATE command SET general_status_id = 2 WHERE command.id = 3;
UPDATE command SET general_status_id = 4 WHERE command.id = 3;

CREATE VIEW v_ready_for_delivery AS
    SELECT command.id AS "numero de commande", command.pizzeria_id AS "pizzeria",
        general_status.name AS "statut general"
    FROM command
    INNER JOIN general_status ON general_status.id = command.general_status_id
    WHERE command.general_status_id = 4
    ORDER BY creation_date;

SELECT "numero de commande", "statut general" FROM v_ready_for_delivery WHERE "pizzeria" = 2;
UPDATE command SET general_status_id = 6, archivated = TRUE WHERE command.id = 2;
UPDATE command SET general_status_id = 7, archivated = TRUE WHERE command.id = 3;

SELECT command.archivated AS "archivée", command.id AS "numero de commande",
        general_status.name AS "statut"
    FROM command
    INNER JOIN general_status ON general_status.id = command.general_status_id
    WHERE archivated = TRUE;
