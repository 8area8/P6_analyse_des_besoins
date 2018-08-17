-------------------------------------------------------------------------------
-- the various requests of this file are commented in the
-- explanatory document of the project, in the part "Parcours d'une commande".
-------------------------------------------------------------------------------



-- -------------------------------
-- ----- COMMANDS CREATION -------
-- -------------------------------
SELECT * FROM v_product_per_pizzeria WHERE pizz = 1;
SELECT * FROM v_product_per_pizzeria WHERE pizz = 2;
SELECT * FROM v_product_per_pizzeria WHERE pizz = 3;



-- -------------------------------
-- ----- COMMANDS CREATION -------
-- -------------------------------


-- A customer takes a command. He has no account.
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

        SELECT f_create_command (id_mail::INTEGER, 1::INTEGER, id_adress::INTEGER, id_phone_number::INTEGER, 1) INTO id_command;

        SELECT f_create_command_product (id_command, 4) INTO id_prod_per_com;
        PERFORM f_modify_command_product (TRUE, id_prod_per_com, 4);
        
        PERFORM f_create_command_product (id_command, 2);
    END;
'
LANGUAGE 'plpgsql';


-- A seller takes a customer command.
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

        SELECT f_create_command (id_mail::INTEGER, id_pizzeria::INTEGER, id_adress::INTEGER, id_phone_number::INTEGER, 1) INTO id_command;

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

        SELECT f_create_command (id_mail::INTEGER, 2::INTEGER, id_adress::INTEGER, id_phone_number::INTEGER, 1) INTO id_command;
        SELECT f_create_command_product (id_command, 4) INTO id_prod_per_com;
        PERFORM f_modify_command_product (FALSE, id_prod_per_com, 6);
        
        PERFORM f_create_command_product (id_command, 2);
        PERFORM f_modify_command_product (TRUE, id_prod_per_com, 3);
        PERFORM f_modify_command_product (FALSE, id_prod_per_com, 4);
    END;
'
LANGUAGE 'plpgsql';



-- -------------------------------
-- --- GENERAL COMMAND VISION ----
-- -------------------------------


select * from v_command_product;
select * from v_command_deletion;
select * from v_command_adding;
select * from v_command_general;



-- -------------------------------
-- ---- PIZZAIOLO SELECTION ------
-- -------------------------------


SELECT "numero de commande", "statut general"
    FROM v_standing_command
    WHERE "pizzeria" = 2;
UPDATE command SET general_status_id = 2 WHERE command.id = 2;
UPDATE command SET general_status_id = 4 WHERE command.id = 2;
UPDATE command SET general_status_id = 2 WHERE command.id = 3;
UPDATE command SET general_status_id = 4 WHERE command.id = 3;



-- -------------------------------
-- ---- DELIVERY SELECTION -------
-- -------------------------------


SELECT "numero de commande", "statut general"
    FROM v_ready_for_delivery
    WHERE "pizzeria" = 2;
UPDATE command SET general_status_id = 5 WHERE command.id = 2;
UPDATE command SET general_status_id = 6 WHERE command.id = 2;
UPDATE command SET general_status_id = 5 WHERE command.id = 3;
UPDATE command SET general_status_id = 7 WHERE command.id = 3;



-- -------------------------------
-- ---- ARCHIVATED SELECTION -----
-- -------------------------------

SELECT command.archivated AS "archivée", command.id AS "numero de commande",                general_status.name AS "statut"
    FROM command
    INNER JOIN general_status ON general_status.id = command.general_status_id
    WHERE archivated = TRUE;

