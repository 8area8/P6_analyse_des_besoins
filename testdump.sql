--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 10.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: email; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.email AS public.citext
	CONSTRAINT email_check CHECK ((VALUE OPERATOR(public.~) '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'::public.citext));


ALTER DOMAIN public.email OWNER TO postgres;

--
-- Name: f_affiliate_pizzeria(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_affiliate_pizzeria(a_userid character varying, a_pizzeria_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

      DECLARE 

        id_account INTEGER;

      BEGIN

        SELECT id INTO id_account FROM account WHERE userid = a_userid;

        

        INSERT INTO pizzeria_affiliate (account_id, pizzeria_id) VALUES

            (id_account, a_pizzeria_id);

        RETURN 1;

      END ;

    $$;


ALTER FUNCTION public.f_affiliate_pizzeria(a_userid character varying, a_pizzeria_id integer) OWNER TO postgres;

--
-- Name: f_create_account(public.email, integer, character varying, character varying, text, text, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_create_account(a_mail public.email, a_gender_id integer, a_first_name character varying, a_last_name character varying, a_phone_number text, a_password text, a_userid character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

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

            (id_mail, id_perso, crypt(a_password, gen_salt('bf', 8)), a_userid) RETURNING id INTO id_account;

        

        INSERT INTO user_role_per_account (account_id, user_role_id) VALUES

            (id_account, 5);

        RETURN 1;

      END ;

    $$;


ALTER FUNCTION public.f_create_account(a_mail public.email, a_gender_id integer, a_first_name character varying, a_last_name character varying, a_phone_number text, a_password text, a_userid character varying) OWNER TO postgres;

--
-- Name: f_create_adress(integer, smallint, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_create_adress(a_country_id integer, a_road_number smallint, a_road character varying, a_postal_code character varying, a_town character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

      DECLARE

        id_adress INTEGER;

      BEGIN   

        INSERT INTO adress (country_id, road_number, road, postal_code, town) VALUES

            (a_country_id, a_road_number, a_road, a_postal_code, a_town) RETURNING id INTO id_adress;

        RETURN id_adress;

      END ;

    $$;


ALTER FUNCTION public.f_create_adress(a_country_id integer, a_road_number smallint, a_road character varying, a_postal_code character varying, a_town character varying) OWNER TO postgres;

--
-- Name: f_create_command(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_create_command(a_mail_id integer, a_pizzeria_id integer, a_adress_id integer, a_phone_number_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

      DECLARE

        id_command INTEGER;

    BEGIN

        INSERT INTO command (pizzeria_id, mail_id, adress_id, phone_number_id) VALUES

            (a_pizzeria_id, a_mail_id, a_adress_id, a_phone_number_id) RETURNING id INTO id_command;

        RETURN id_command;

      END ;

    $$;


ALTER FUNCTION public.f_create_command(a_mail_id integer, a_pizzeria_id integer, a_adress_id integer, a_phone_number_id integer) OWNER TO postgres;

--
-- Name: f_create_command_product(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_create_command_product(a_command_id integer, a_product_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

      DECLARE

        id_product_per_command INTEGER;

      BEGIN

        INSERT INTO product_per_command (command_id, product_id) VALUES

            (a_command_id, a_product_id) RETURNING id INTO id_product_per_command;

        RETURN id_product_per_command;

      END ;

    $$;


ALTER FUNCTION public.f_create_command_product(a_command_id integer, a_product_id integer) OWNER TO postgres;

--
-- Name: f_modify_command_product(boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_modify_command_product(a_add_or_del boolean, a_product_per_command_id integer, a_ingredient_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

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

    $$;


ALTER FUNCTION public.f_modify_command_product(a_add_or_del boolean, a_product_per_command_id integer, a_ingredient_id integer) OWNER TO postgres;

--
-- Name: f_notax_price(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_notax_price(a_command_id integer, a_tva_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

      DECLARE

        notax_price NUMERIC;

        rate_tva NUMERIC;

      BEGIN

        SELECT f_total_price(a_command_id) INTO notax_price;

        SELECT tva_rate INTO rate_tva FROM tva WHERE tva.id = a_tva_id;

        SELECT notax_price::NUMERIC / (1::NUMERIC + (rate_tva / 100::NUMERIC)) INTO notax_price;

        RETURN ROUND(notax_price, 2);

      END ;

    $$;


ALTER FUNCTION public.f_notax_price(a_command_id integer, a_tva_id integer) OWNER TO postgres;

--
-- Name: f_set_role(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_set_role(a_userid character varying, a_user_role_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

      DECLARE 

        id_account INTEGER;

      BEGIN

        SELECT id INTO id_account FROM account WHERE userid = a_userid;



        INSERT INTO user_role_per_account (account_id, user_role_id) VALUES

            (id_account, a_user_role_id);

        RETURN 1;

      END ;

    $$;


ALTER FUNCTION public.f_set_role(a_userid character varying, a_user_role_id integer) OWNER TO postgres;

--
-- Name: f_total_price(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.f_total_price(a_command_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

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

    $$;


ALTER FUNCTION public.f_total_price(a_command_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    id integer NOT NULL,
    mail_id integer,
    personnal_information_id integer,
    passhash text NOT NULL,
    userid character varying(20) NOT NULL
);


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_id_seq OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_id_seq OWNED BY public.account.id;


--
-- Name: adding; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adding (
    id integer NOT NULL,
    ingredient_id integer,
    product_per_command_id integer
);


ALTER TABLE public.adding OWNER TO postgres;

--
-- Name: adding_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adding_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adding_id_seq OWNER TO postgres;

--
-- Name: adding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adding_id_seq OWNED BY public.adding.id;


--
-- Name: adress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adress (
    id integer NOT NULL,
    country_id integer,
    road_number smallint,
    road character varying(300),
    postal_code character varying(40),
    town character varying(300)
);


ALTER TABLE public.adress OWNER TO postgres;

--
-- Name: adress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adress_id_seq OWNER TO postgres;

--
-- Name: adress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adress_id_seq OWNED BY public.adress.id;


--
-- Name: adress_per_personnal_information; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adress_per_personnal_information (
    id integer NOT NULL,
    personnal_information_id integer,
    adress_id integer
);


ALTER TABLE public.adress_per_personnal_information OWNER TO postgres;

--
-- Name: adress_per_personnal_information_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adress_per_personnal_information_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adress_per_personnal_information_id_seq OWNER TO postgres;

--
-- Name: adress_per_personnal_information_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adress_per_personnal_information_id_seq OWNED BY public.adress_per_personnal_information.id;


--
-- Name: banking_card; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.banking_card (
    id integer NOT NULL,
    personnal_information_id integer,
    token_card text
);


ALTER TABLE public.banking_card OWNER TO postgres;

--
-- Name: banking_card_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.banking_card_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.banking_card_id_seq OWNER TO postgres;

--
-- Name: banking_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.banking_card_id_seq OWNED BY public.banking_card.id;


--
-- Name: bill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bill (
    id integer NOT NULL,
    tva_id integer,
    command_id integer,
    bill_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bill OWNER TO postgres;

--
-- Name: bill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bill_id_seq OWNER TO postgres;

--
-- Name: bill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bill_id_seq OWNED BY public.bill.id;


--
-- Name: command; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.command (
    id integer NOT NULL,
    pizzeria_id integer NOT NULL,
    mail_id integer NOT NULL,
    payment_status_id integer DEFAULT 1,
    general_status_id integer DEFAULT 1,
    adress_id integer NOT NULL,
    phone_number_id integer NOT NULL,
    tracking_number uuid DEFAULT public.gen_random_uuid(),
    creation_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_modification_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    archivated boolean DEFAULT false
);


ALTER TABLE public.command OWNER TO postgres;

--
-- Name: ingredient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient (
    id integer NOT NULL,
    name character varying(150),
    price numeric(5,2)
);


ALTER TABLE public.ingredient OWNER TO postgres;

--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id integer NOT NULL,
    name character varying(150),
    price numeric(5,2)
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_per_command; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_per_command (
    id integer NOT NULL,
    product_id integer,
    command_id integer
);


ALTER TABLE public.product_per_command OWNER TO postgres;

--
-- Name: command_adding; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.command_adding AS
 SELECT adding.id AS additions_id,
    ppc.id AS product_per_com_id,
    product.name AS produits,
    concat(ingredient.name, ' + ', ingredient.price, ' euros') AS retraits,
    command.id AS "numero de commande"
   FROM ((((public.product_per_command ppc
     JOIN public.adding ON ((ppc.id = adding.product_per_command_id)))
     JOIN public.ingredient ON ((ingredient.id = adding.ingredient_id)))
     LEFT JOIN public.product ON ((product.id = ppc.product_id)))
     LEFT JOIN public.command ON ((command.id = ppc.command_id)))
  ORDER BY product.name;


ALTER TABLE public.command_adding OWNER TO postgres;

--
-- Name: deletion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deletion (
    id integer NOT NULL,
    ingredient_id integer,
    product_per_command_id integer
);


ALTER TABLE public.deletion OWNER TO postgres;

--
-- Name: command_deletion; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.command_deletion AS
 SELECT deletion.id AS deletion_id,
    ppc.id AS product_per_com_id,
    product.name AS produits,
    concat(ingredient.name, ' - ', trunc((ingredient.price / (2)::numeric), 2), ' euros') AS retraits,
    command.id AS "numero de commande"
   FROM ((((public.product_per_command ppc
     JOIN public.deletion ON ((ppc.id = deletion.product_per_command_id)))
     JOIN public.ingredient ON ((ingredient.id = deletion.ingredient_id)))
     LEFT JOIN public.product ON ((product.id = ppc.product_id)))
     LEFT JOIN public.command ON ((command.id = ppc.command_id)))
  ORDER BY product.name;


ALTER TABLE public.command_deletion OWNER TO postgres;

--
-- Name: general_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.general_status (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.general_status OWNER TO postgres;

--
-- Name: payment_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_status (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.payment_status OWNER TO postgres;

--
-- Name: tva; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tva (
    id integer NOT NULL,
    tva_rate numeric,
    change_date date
);


ALTER TABLE public.tva OWNER TO postgres;

--
-- Name: command_general; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.command_general AS
 SELECT command.id AS "numero de commande",
    command.tracking_number AS "num├â┬®ro de suivi",
    to_char(command.creation_date, 'YYYY-MM-DD HH24:MI'::text) AS "date de cr├â┬®ation",
    public.f_notax_price(command.id, tva.id) AS "prix hors taxe",
    public.f_total_price(command.id) AS "prix TTC",
    general_status.name AS statut,
    payment_status.name AS "statut de paiement"
   FROM ((((public.command
     JOIN public.bill ON ((bill.command_id = command.id)))
     JOIN public.tva ON ((tva.id = bill.tva_id)))
     JOIN public.general_status ON ((general_status.id = command.general_status_id)))
     JOIN public.payment_status ON ((payment_status.id = command.payment_status_id)));


ALTER TABLE public.command_general OWNER TO postgres;

--
-- Name: command_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.command_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.command_id_seq OWNER TO postgres;

--
-- Name: command_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.command_id_seq OWNED BY public.command.id;


--
-- Name: command_per_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.command_per_account (
    id integer NOT NULL,
    account_id integer,
    command_id integer
);


ALTER TABLE public.command_per_account OWNER TO postgres;

--
-- Name: command_per_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.command_per_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.command_per_account_id_seq OWNER TO postgres;

--
-- Name: command_per_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.command_per_account_id_seq OWNED BY public.command_per_account.id;


--
-- Name: command_product; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.command_product AS
 SELECT product.name AS nom,
    product.price AS prix,
    command.id AS "numero de commande"
   FROM ((public.product
     JOIN public.product_per_command ppc ON ((ppc.product_id = product.id)))
     JOIN public.command ON ((command.id = ppc.command_id)));


ALTER TABLE public.command_product OWNER TO postgres;

--
-- Name: country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.country (
    id integer NOT NULL,
    name character varying(200)
);


ALTER TABLE public.country OWNER TO postgres;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_id_seq OWNER TO postgres;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.country_id_seq OWNED BY public.country.id;


--
-- Name: deletion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deletion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deletion_id_seq OWNER TO postgres;

--
-- Name: deletion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deletion_id_seq OWNED BY public.deletion.id;


--
-- Name: gender; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gender (
    id integer NOT NULL,
    sex character varying(10)
);


ALTER TABLE public.gender OWNER TO postgres;

--
-- Name: gender_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gender_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gender_id_seq OWNER TO postgres;

--
-- Name: gender_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gender_id_seq OWNED BY public.gender.id;


--
-- Name: general_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.general_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.general_status_id_seq OWNER TO postgres;

--
-- Name: general_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.general_status_id_seq OWNED BY public.general_status.id;


--
-- Name: ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingredient_id_seq OWNER TO postgres;

--
-- Name: ingredient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredient_id_seq OWNED BY public.ingredient.id;


--
-- Name: ingredient_per_pizzeria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient_per_pizzeria (
    id integer NOT NULL,
    pizzeria_id integer,
    ingredient_id integer,
    stock_property_id integer
);


ALTER TABLE public.ingredient_per_pizzeria OWNER TO postgres;

--
-- Name: ingredient_per_pizzeria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredient_per_pizzeria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingredient_per_pizzeria_id_seq OWNER TO postgres;

--
-- Name: ingredient_per_pizzeria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredient_per_pizzeria_id_seq OWNED BY public.ingredient_per_pizzeria.id;


--
-- Name: ingredient_per_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient_per_product (
    id integer NOT NULL,
    ingredient_id integer,
    product_id integer,
    recipe_description character varying(250),
    recipe_position smallint
);


ALTER TABLE public.ingredient_per_product OWNER TO postgres;

--
-- Name: ingredient_per_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredient_per_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingredient_per_product_id_seq OWNER TO postgres;

--
-- Name: ingredient_per_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredient_per_product_id_seq OWNED BY public.ingredient_per_product.id;


--
-- Name: mail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mail (
    id integer NOT NULL,
    mail_adress public.email
);


ALTER TABLE public.mail OWNER TO postgres;

--
-- Name: mail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mail_id_seq OWNER TO postgres;

--
-- Name: mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mail_id_seq OWNED BY public.mail.id;


--
-- Name: payment_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_status_id_seq OWNER TO postgres;

--
-- Name: payment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_status_id_seq OWNED BY public.payment_status.id;


--
-- Name: personnal_information; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personnal_information (
    id integer NOT NULL,
    gender_id integer,
    phone_number_id integer,
    first_name character varying(100),
    last_name character varying(100)
);


ALTER TABLE public.personnal_information OWNER TO postgres;

--
-- Name: personnal_information_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personnal_information_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personnal_information_id_seq OWNER TO postgres;

--
-- Name: personnal_information_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personnal_information_id_seq OWNED BY public.personnal_information.id;


--
-- Name: phone_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phone_number (
    id integer NOT NULL,
    number text
);


ALTER TABLE public.phone_number OWNER TO postgres;

--
-- Name: phone_number_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.phone_number_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.phone_number_id_seq OWNER TO postgres;

--
-- Name: phone_number_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.phone_number_id_seq OWNED BY public.phone_number.id;


--
-- Name: pizzeria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pizzeria (
    id integer NOT NULL,
    adress_id integer,
    name character varying(150)
);


ALTER TABLE public.pizzeria OWNER TO postgres;

--
-- Name: pizzeria_affiliate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pizzeria_affiliate (
    id integer NOT NULL,
    pizzeria_id integer,
    account_id integer
);


ALTER TABLE public.pizzeria_affiliate OWNER TO postgres;

--
-- Name: pizzeria_affiliate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pizzeria_affiliate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pizzeria_affiliate_id_seq OWNER TO postgres;

--
-- Name: pizzeria_affiliate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pizzeria_affiliate_id_seq OWNED BY public.pizzeria_affiliate.id;


--
-- Name: pizzeria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pizzeria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pizzeria_id_seq OWNER TO postgres;

--
-- Name: pizzeria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pizzeria_id_seq OWNED BY public.pizzeria.id;


--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_id_seq OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: product_per_command_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_per_command_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_per_command_id_seq OWNER TO postgres;

--
-- Name: product_per_command_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_per_command_id_seq OWNED BY public.product_per_command.id;


--
-- Name: ready_for_delivery; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.ready_for_delivery AS
 SELECT command.id AS "numero de commande",
    command.pizzeria_id AS pizzeria,
    general_status.name AS "statut general"
   FROM (public.command
     JOIN public.general_status ON ((general_status.id = command.general_status_id)))
  WHERE (command.general_status_id = 4)
  ORDER BY command.creation_date;


ALTER TABLE public.ready_for_delivery OWNER TO postgres;

--
-- Name: standing_command; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.standing_command AS
 SELECT command.id AS "numero de commande",
    command.pizzeria_id AS pizzeria,
    general_status.name AS "statut general"
   FROM (public.command
     JOIN public.general_status ON ((general_status.id = command.general_status_id)))
  ORDER BY command.creation_date;


ALTER TABLE public.standing_command OWNER TO postgres;

--
-- Name: stock_property; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_property (
    id integer NOT NULL,
    name character varying(150)
);


ALTER TABLE public.stock_property OWNER TO postgres;

--
-- Name: stock_property_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_property_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stock_property_id_seq OWNER TO postgres;

--
-- Name: stock_property_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_property_id_seq OWNED BY public.stock_property.id;


--
-- Name: tva_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tva_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tva_id_seq OWNER TO postgres;

--
-- Name: tva_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tva_id_seq OWNED BY public.tva.id;


--
-- Name: user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role (
    id integer NOT NULL,
    role_name text NOT NULL
);


ALTER TABLE public.user_role OWNER TO postgres;

--
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_role_id_seq OWNER TO postgres;

--
-- Name: user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_role_id_seq OWNED BY public.user_role.id;


--
-- Name: user_role_per_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role_per_account (
    id integer NOT NULL,
    account_id integer,
    user_role_id integer
);


ALTER TABLE public.user_role_per_account OWNER TO postgres;

--
-- Name: user_role_per_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_role_per_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_role_per_account_id_seq OWNER TO postgres;

--
-- Name: user_role_per_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_role_per_account_id_seq OWNED BY public.user_role_per_account.id;


--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT nextval('public.account_id_seq'::regclass);


--
-- Name: adding id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adding ALTER COLUMN id SET DEFAULT nextval('public.adding_id_seq'::regclass);


--
-- Name: adress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress ALTER COLUMN id SET DEFAULT nextval('public.adress_id_seq'::regclass);


--
-- Name: adress_per_personnal_information id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress_per_personnal_information ALTER COLUMN id SET DEFAULT nextval('public.adress_per_personnal_information_id_seq'::regclass);


--
-- Name: banking_card id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banking_card ALTER COLUMN id SET DEFAULT nextval('public.banking_card_id_seq'::regclass);


--
-- Name: bill id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill ALTER COLUMN id SET DEFAULT nextval('public.bill_id_seq'::regclass);


--
-- Name: command id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command ALTER COLUMN id SET DEFAULT nextval('public.command_id_seq'::regclass);


--
-- Name: command_per_account id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command_per_account ALTER COLUMN id SET DEFAULT nextval('public.command_per_account_id_seq'::regclass);


--
-- Name: country id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.country ALTER COLUMN id SET DEFAULT nextval('public.country_id_seq'::regclass);


--
-- Name: deletion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deletion ALTER COLUMN id SET DEFAULT nextval('public.deletion_id_seq'::regclass);


--
-- Name: gender id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gender ALTER COLUMN id SET DEFAULT nextval('public.gender_id_seq'::regclass);


--
-- Name: general_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.general_status ALTER COLUMN id SET DEFAULT nextval('public.general_status_id_seq'::regclass);


--
-- Name: ingredient id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient ALTER COLUMN id SET DEFAULT nextval('public.ingredient_id_seq'::regclass);


--
-- Name: ingredient_per_pizzeria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_pizzeria ALTER COLUMN id SET DEFAULT nextval('public.ingredient_per_pizzeria_id_seq'::regclass);


--
-- Name: ingredient_per_product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_product ALTER COLUMN id SET DEFAULT nextval('public.ingredient_per_product_id_seq'::regclass);


--
-- Name: mail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail ALTER COLUMN id SET DEFAULT nextval('public.mail_id_seq'::regclass);


--
-- Name: payment_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_status ALTER COLUMN id SET DEFAULT nextval('public.payment_status_id_seq'::regclass);


--
-- Name: personnal_information id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnal_information ALTER COLUMN id SET DEFAULT nextval('public.personnal_information_id_seq'::regclass);


--
-- Name: phone_number id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_number ALTER COLUMN id SET DEFAULT nextval('public.phone_number_id_seq'::regclass);


--
-- Name: pizzeria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria ALTER COLUMN id SET DEFAULT nextval('public.pizzeria_id_seq'::regclass);


--
-- Name: pizzeria_affiliate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria_affiliate ALTER COLUMN id SET DEFAULT nextval('public.pizzeria_affiliate_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Name: product_per_command id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_per_command ALTER COLUMN id SET DEFAULT nextval('public.product_per_command_id_seq'::regclass);


--
-- Name: stock_property id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_property ALTER COLUMN id SET DEFAULT nextval('public.stock_property_id_seq'::regclass);


--
-- Name: tva id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tva ALTER COLUMN id SET DEFAULT nextval('public.tva_id_seq'::regclass);


--
-- Name: user_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role ALTER COLUMN id SET DEFAULT nextval('public.user_role_id_seq'::regclass);


--
-- Name: user_role_per_account id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_per_account ALTER COLUMN id SET DEFAULT nextval('public.user_role_per_account_id_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account (id, mail_id, personnal_information_id, passhash, userid) FROM stdin;
1	1	1	$2a$08$fakUh5RBmNY2SKhdFKgCIumixGUQzLjFLpa8PC6hMPnjO/aLlA4A2	luludu48
2	2	2	$2a$08$OB9Br5PJuieEVj1bzzclh.JQAqle29gt9XJzOK1BYMGtSJzgdzH5G	darksidious
3	3	3	$2a$08$Gr0ASPzrDQn82BBxuLLkOunUgchzbybS50FZScZ1/SA/PI3hzTGEO	luludes├â┬¿te
4	4	4	$2a$08$s.gB6ldBwTqJz9cfvm.lM.NJc5k9P71CRrxpQzt74UFwKGjV01ac.	meuhmeuh
5	5	5	$2a$08$dh6zYvCJSbSj18wpr1i2ce69i68un2oxG5ONb5LheyIKWQic3jJZ2	Jean Darengie
6	6	6	$2a$08$dFGEYTu.07Ibttzx5j62ievVTFMnOwvPzOFuyRoCYFBHO/EZShG8i	Martin Parat
7	7	7	$2a$08$5eR3dAIBN2cfvO8bfx/Ox.JwkfIadaW.kBL.MWvB4oG4b7mbWMt5y	Agathe Larin
8	8	8	$2a$08$bm3Mnt3.xKeIrxx30HrkXOa5iPWnQl5fZuBmQtJQbMhktncSArOLK	Philipe Danas
9	9	9	$2a$08$ey.w8ipvaHIspYWJXCSIjOBIwTcjUVDp8J3d9eeJGPAMrAUD32Nbi	Sophie Zira
10	10	10	$2a$08$C2jIXfqYDrD7yqXR/T8RoupSzlwzWXDi01.RBEgSNXJNV/60Z1ISm	Mikael Aradu
\.


--
-- Data for Name: adding; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adding (id, ingredient_id, product_per_command_id) FROM stdin;
1	6	5
2	4	5
\.


--
-- Data for Name: adress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adress (id, country_id, road_number, road, postal_code, town) FROM stdin;
1	1	11	rue de rivoli	750001	Paris
2	1	34	place de la r├â┬®publique	75005	Paris
3	1	2	rue du chat	75019	Paris
4	1	23	rue de chez moi	75020	paris
5	1	10	rue de leon	75010	paris
6	1	34	avenu de ouioui	75001	paris
\.


--
-- Data for Name: adress_per_personnal_information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adress_per_personnal_information (id, personnal_information_id, adress_id) FROM stdin;
1	1	4
\.


--
-- Data for Name: banking_card; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.banking_card (id, personnal_information_id, token_card) FROM stdin;
\.


--
-- Data for Name: bill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bill (id, tva_id, command_id, bill_date) FROM stdin;
1	1	1	2018-08-14 18:43:51.962264
2	1	2	2018-08-14 18:43:51.968355
3	1	3	2018-08-14 18:43:51.97124
\.


--
-- Data for Name: command; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.command (id, pizzeria_id, mail_id, payment_status_id, general_status_id, adress_id, phone_number_id, tracking_number, creation_date, last_modification_date, archivated) FROM stdin;
1	1	11	1	1	5	11	7ca79145-0c96-425e-8e62-d162fc951fda	2018-08-14 18:43:51.962264	2018-08-14 18:43:51.962264	f
2	2	12	1	6	6	12	af8bea37-445a-4b3d-9302-835327078e93	2018-08-14 18:43:51.968355	2018-08-14 18:43:51.968355	t
3	2	1	1	7	4	1	df157a0d-c2b5-48bc-b6c6-0a94f44f403e	2018-08-14 18:43:51.97124	2018-08-14 18:43:51.97124	t
\.


--
-- Data for Name: command_per_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.command_per_account (id, account_id, command_id) FROM stdin;
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.country (id, name) FROM stdin;
1	France
\.


--
-- Data for Name: deletion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deletion (id, ingredient_id, product_per_command_id) FROM stdin;
1	4	1
2	5	3
3	3	5
\.


--
-- Data for Name: gender; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gender (id, sex) FROM stdin;
1	male
2	female
3	Asexual
\.


--
-- Data for Name: general_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.general_status (id, name) FROM stdin;
1	en attente
2	en pr├â┬®paration
3	en attente de retrait
4	pr├â┬¬te ├â┬á l envoie
5	en cours de livraison
6	livr├â┬®
7	annul├â┬®e
\.


--
-- Data for Name: ingredient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredient (id, name, price) FROM stdin;
1	base tomate	4.00
2	base cr├â┬¿me fra├â┬«che	5.00
3	tomates	1.00
4	saumon	4.00
5	fromage	1.00
6	olives	1.00
7	jambon	3.00
8	champignons	1.00
\.


--
-- Data for Name: ingredient_per_pizzeria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredient_per_pizzeria (id, pizzeria_id, ingredient_id, stock_property_id) FROM stdin;
1	1	1	\N
2	2	1	\N
3	3	1	\N
4	1	2	\N
5	2	2	\N
6	3	2	\N
7	1	3	\N
8	2	3	\N
9	3	3	\N
10	1	4	\N
11	3	4	\N
12	1	5	\N
13	2	5	\N
14	3	5	\N
15	1	6	\N
16	2	6	\N
17	3	6	\N
18	1	7	\N
19	2	7	\N
20	1	8	\N
21	2	8	\N
22	3	8	\N
\.


--
-- Data for Name: ingredient_per_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredient_per_product (id, ingredient_id, product_id, recipe_description, recipe_position) FROM stdin;
1	2	1	\N	\N
2	5	1	\N	\N
3	1	2	\N	\N
4	5	2	\N	\N
5	6	2	\N	\N
6	7	2	\N	\N
7	2	3	\N	\N
8	4	3	\N	\N
9	5	3	\N	\N
10	1	4	\N	\N
11	3	4	\N	\N
12	5	4	\N	\N
13	8	4	\N	\N
14	6	4	\N	\N
\.


--
-- Data for Name: mail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mail (id, mail_adress) FROM stdin;
1	lalila@gmail.com
2	mdt@hotmail.fr
3	luciendesete@gmail.com
4	margueritemeuh@gmail.com
5	jeandarengie@gmail.com
6	martinparat@gmail.com
7	agathelarin@gmail.com
8	philipedanas@gmail.com
9	sophiezzz@gmail.com
10	mikaelaradu@gmail.com
11	jenesuispasauthentifie@gmail.com
12	commandseller@gmail.com
\.


--
-- Data for Name: payment_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_status (id, name) FROM stdin;
1	en attente de paiment
2	pay├â┬®
\.


--
-- Data for Name: personnal_information; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personnal_information (id, gender_id, phone_number_id, first_name, last_name) FROM stdin;
1	2	1	Lucie	Koko
2	1	2	Marc	Luke
3	1	3	Lucien	des├â┬¿te
4	2	4	marguerite	Meuh
5	1	5	Jean	Darengie
6	1	6	Martin	Parat
7	2	5	Agathe	Larin
8	1	8	Philipe	Danas
9	2	9	Sophie	Zira
10	1	10	Mikael	Aradu
\.


--
-- Data for Name: phone_number; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.phone_number (id, number) FROM stdin;
1	0603495920
2	0601195420
3	0747578329
4	0601115920
5	0784943355
6	0782222355
8	0737293847
9	0784243355
10	0737003847
11	0603928374
12	0640528374
\.


--
-- Data for Name: pizzeria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pizzeria (id, adress_id, name) FROM stdin;
1	1	OC pizzas ch├â┬ótelet
2	2	OC pizzas r├â┬®publique
3	3	OC pizzas belleville
\.


--
-- Data for Name: pizzeria_affiliate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pizzeria_affiliate (id, pizzeria_id, account_id) FROM stdin;
1	1	5
2	2	6
3	1	7
4	1	8
5	2	9
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, name, price) FROM stdin;
1	margarita	9.00
2	jambon fromage	11.00
3	saumon	13.00
4	v├â┬®g├â┬®tarienne	10.00
\.


--
-- Data for Name: product_per_command; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_per_command (id, product_id, command_id) FROM stdin;
1	4	1
2	2	1
3	1	2
4	3	2
5	4	3
6	2	3
\.


--
-- Data for Name: stock_property; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_property (id, name) FROM stdin;
1	vide
2	tr├â┬¿s peu
3	la moiti├â┬®
4	beaucoup
5	plein
\.


--
-- Data for Name: tva; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tva (id, tva_rate, change_date) FROM stdin;
1	20	2018-01-04
\.


--
-- Data for Name: user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role (id, role_name) FROM stdin;
1	super_user
2	pizza├â┬»olo
3	seller
4	delivery
5	customer
\.


--
-- Data for Name: user_role_per_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role_per_account (id, account_id, user_role_id) FROM stdin;
1	1	5
2	2	5
3	3	5
4	4	5
5	5	5
6	5	3
7	6	5
8	6	3
9	7	5
10	7	2
11	6	2
12	8	5
13	8	4
14	9	5
15	9	2
16	10	5
17	10	1
\.


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_id_seq', 10, true);


--
-- Name: adding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adding_id_seq', 2, true);


--
-- Name: adress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adress_id_seq', 6, true);


--
-- Name: adress_per_personnal_information_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adress_per_personnal_information_id_seq', 1, true);


--
-- Name: banking_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.banking_card_id_seq', 1, false);


--
-- Name: bill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bill_id_seq', 3, true);


--
-- Name: command_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.command_id_seq', 3, true);


--
-- Name: command_per_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.command_per_account_id_seq', 1, false);


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.country_id_seq', 1, true);


--
-- Name: deletion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deletion_id_seq', 3, true);


--
-- Name: gender_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gender_id_seq', 3, true);


--
-- Name: general_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.general_status_id_seq', 7, true);


--
-- Name: ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredient_id_seq', 8, true);


--
-- Name: ingredient_per_pizzeria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredient_per_pizzeria_id_seq', 22, true);


--
-- Name: ingredient_per_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredient_per_product_id_seq', 14, true);


--
-- Name: mail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mail_id_seq', 12, true);


--
-- Name: payment_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_status_id_seq', 2, true);


--
-- Name: personnal_information_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personnal_information_id_seq', 10, true);


--
-- Name: phone_number_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.phone_number_id_seq', 12, true);


--
-- Name: pizzeria_affiliate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pizzeria_affiliate_id_seq', 5, true);


--
-- Name: pizzeria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pizzeria_id_seq', 3, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 4, true);


--
-- Name: product_per_command_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_per_command_id_seq', 6, true);


--
-- Name: stock_property_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_property_id_seq', 5, true);


--
-- Name: tva_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tva_id_seq', 1, true);


--
-- Name: user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_id_seq', 5, true);


--
-- Name: user_role_per_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_role_per_account_id_seq', 17, true);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account account_userid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_userid_key UNIQUE (userid);


--
-- Name: adding adding_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adding
    ADD CONSTRAINT adding_pkey PRIMARY KEY (id);


--
-- Name: adress_per_personnal_information adress_per_personnal_information_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress_per_personnal_information
    ADD CONSTRAINT adress_per_personnal_information_pkey PRIMARY KEY (id);


--
-- Name: adress adress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress
    ADD CONSTRAINT adress_pkey PRIMARY KEY (id);


--
-- Name: banking_card banking_card_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banking_card
    ADD CONSTRAINT banking_card_pkey PRIMARY KEY (id);


--
-- Name: bill bill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (id);


--
-- Name: command_per_account command_per_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command_per_account
    ADD CONSTRAINT command_per_account_pkey PRIMARY KEY (id);


--
-- Name: command command_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_pkey PRIMARY KEY (id);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: deletion deletion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deletion
    ADD CONSTRAINT deletion_pkey PRIMARY KEY (id);


--
-- Name: gender gender_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gender
    ADD CONSTRAINT gender_pkey PRIMARY KEY (id);


--
-- Name: general_status general_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.general_status
    ADD CONSTRAINT general_status_pkey PRIMARY KEY (id);


--
-- Name: ingredient_per_pizzeria ingredient_per_pizzeria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_pizzeria
    ADD CONSTRAINT ingredient_per_pizzeria_pkey PRIMARY KEY (id);


--
-- Name: ingredient_per_product ingredient_per_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_product
    ADD CONSTRAINT ingredient_per_product_pkey PRIMARY KEY (id);


--
-- Name: ingredient ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);


--
-- Name: mail mail_mail_adress_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail
    ADD CONSTRAINT mail_mail_adress_key UNIQUE (mail_adress);


--
-- Name: mail mail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail
    ADD CONSTRAINT mail_pkey PRIMARY KEY (id);


--
-- Name: payment_status payment_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_status
    ADD CONSTRAINT payment_status_pkey PRIMARY KEY (id);


--
-- Name: personnal_information personnal_information_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnal_information
    ADD CONSTRAINT personnal_information_pkey PRIMARY KEY (id);


--
-- Name: phone_number phone_number_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_number
    ADD CONSTRAINT phone_number_number_key UNIQUE (number);


--
-- Name: phone_number phone_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_number
    ADD CONSTRAINT phone_number_pkey PRIMARY KEY (id);


--
-- Name: pizzeria_affiliate pizzeria_affiliate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria_affiliate
    ADD CONSTRAINT pizzeria_affiliate_pkey PRIMARY KEY (id);


--
-- Name: pizzeria pizzeria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria
    ADD CONSTRAINT pizzeria_pkey PRIMARY KEY (id);


--
-- Name: product_per_command product_per_command_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_per_command
    ADD CONSTRAINT product_per_command_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: stock_property stock_property_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_property
    ADD CONSTRAINT stock_property_pkey PRIMARY KEY (id);


--
-- Name: tva tva_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tva
    ADD CONSTRAINT tva_pkey PRIMARY KEY (id);


--
-- Name: user_role_per_account user_role_per_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_per_account
    ADD CONSTRAINT user_role_per_account_pkey PRIMARY KEY (id);


--
-- Name: user_role user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);


--
-- Name: idx_archivated; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_archivated ON public.command USING btree (archivated);


--
-- Name: idx_bill_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bill_date ON public.bill USING btree (bill_date DESC);


--
-- Name: idx_change_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_change_date ON public.tva USING btree (change_date DESC);


--
-- Name: idx_country_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_country_id ON public.adress USING btree (country_id);


--
-- Name: idx_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dates ON public.command USING btree (last_modification_date, creation_date DESC);


--
-- Name: idx_general_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_general_status ON public.command USING btree (general_status_id);


--
-- Name: idx_ingr_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ingr_name ON public.ingredient USING btree (name);


--
-- Name: idx_names; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_names ON public.personnal_information USING btree (first_name, last_name);


--
-- Name: idx_pizzeria_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pizzeria_id ON public.command USING btree (pizzeria_id);


--
-- Name: idx_pizzeria_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pizzeria_name ON public.pizzeria USING btree (name);


--
-- Name: idx_ppc_command_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ppc_command_id ON public.product_per_command USING btree (command_id);


--
-- Name: idx_prod_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prod_name ON public.product USING btree (name);


--
-- Name: idx_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_id ON public.product_per_command USING btree (product_id);


--
-- Name: idx_stock_property; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stock_property ON public.ingredient_per_pizzeria USING btree (stock_property_id);


--
-- Name: idx_town; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_town ON public.adress USING btree (town);


--
-- Name: account account_mail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_mail_id_fkey FOREIGN KEY (mail_id) REFERENCES public.mail(id) ON DELETE CASCADE;


--
-- Name: account account_personnal_information_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_personnal_information_id_fkey FOREIGN KEY (personnal_information_id) REFERENCES public.personnal_information(id) ON DELETE CASCADE;


--
-- Name: adding adding_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adding
    ADD CONSTRAINT adding_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id) ON DELETE CASCADE;


--
-- Name: adding adding_product_per_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adding
    ADD CONSTRAINT adding_product_per_command_id_fkey FOREIGN KEY (product_per_command_id) REFERENCES public.product_per_command(id) ON DELETE CASCADE;


--
-- Name: adress adress_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress
    ADD CONSTRAINT adress_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id) ON DELETE CASCADE;


--
-- Name: adress_per_personnal_information adress_per_personnal_information_adress_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress_per_personnal_information
    ADD CONSTRAINT adress_per_personnal_information_adress_id_fkey FOREIGN KEY (adress_id) REFERENCES public.adress(id) ON DELETE CASCADE;


--
-- Name: adress_per_personnal_information adress_per_personnal_information_personnal_information_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adress_per_personnal_information
    ADD CONSTRAINT adress_per_personnal_information_personnal_information_id_fkey FOREIGN KEY (personnal_information_id) REFERENCES public.personnal_information(id) ON DELETE CASCADE;


--
-- Name: banking_card banking_card_personnal_information_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banking_card
    ADD CONSTRAINT banking_card_personnal_information_id_fkey FOREIGN KEY (personnal_information_id) REFERENCES public.personnal_information(id) ON DELETE CASCADE;


--
-- Name: bill bill_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_command_id_fkey FOREIGN KEY (command_id) REFERENCES public.command(id) ON DELETE CASCADE;


--
-- Name: bill bill_tva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_tva_id_fkey FOREIGN KEY (tva_id) REFERENCES public.tva(id) ON DELETE CASCADE;


--
-- Name: command command_adress_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_adress_id_fkey FOREIGN KEY (adress_id) REFERENCES public.adress(id) ON DELETE CASCADE;


--
-- Name: command command_general_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_general_status_id_fkey FOREIGN KEY (general_status_id) REFERENCES public.general_status(id) ON DELETE CASCADE;


--
-- Name: command command_mail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_mail_id_fkey FOREIGN KEY (mail_id) REFERENCES public.mail(id) ON DELETE CASCADE;


--
-- Name: command command_payment_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_payment_status_id_fkey FOREIGN KEY (payment_status_id) REFERENCES public.payment_status(id) ON DELETE CASCADE;


--
-- Name: command_per_account command_per_account_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command_per_account
    ADD CONSTRAINT command_per_account_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id) ON DELETE CASCADE;


--
-- Name: command_per_account command_per_account_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command_per_account
    ADD CONSTRAINT command_per_account_command_id_fkey FOREIGN KEY (command_id) REFERENCES public.command(id) ON DELETE CASCADE;


--
-- Name: command command_phone_number_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_phone_number_id_fkey FOREIGN KEY (phone_number_id) REFERENCES public.phone_number(id) ON DELETE CASCADE;


--
-- Name: command command_pizzeria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.command
    ADD CONSTRAINT command_pizzeria_id_fkey FOREIGN KEY (pizzeria_id) REFERENCES public.pizzeria(id) ON DELETE CASCADE;


--
-- Name: deletion deletion_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deletion
    ADD CONSTRAINT deletion_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id) ON DELETE CASCADE;


--
-- Name: deletion deletion_product_per_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deletion
    ADD CONSTRAINT deletion_product_per_command_id_fkey FOREIGN KEY (product_per_command_id) REFERENCES public.product_per_command(id) ON DELETE CASCADE;


--
-- Name: ingredient_per_pizzeria ingredient_per_pizzeria_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_pizzeria
    ADD CONSTRAINT ingredient_per_pizzeria_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id) ON DELETE CASCADE;


--
-- Name: ingredient_per_pizzeria ingredient_per_pizzeria_pizzeria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_pizzeria
    ADD CONSTRAINT ingredient_per_pizzeria_pizzeria_id_fkey FOREIGN KEY (pizzeria_id) REFERENCES public.pizzeria(id) ON DELETE CASCADE;


--
-- Name: ingredient_per_pizzeria ingredient_per_pizzeria_stock_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_pizzeria
    ADD CONSTRAINT ingredient_per_pizzeria_stock_property_id_fkey FOREIGN KEY (stock_property_id) REFERENCES public.stock_property(id) ON DELETE CASCADE;


--
-- Name: ingredient_per_product ingredient_per_product_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_product
    ADD CONSTRAINT ingredient_per_product_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient(id) ON DELETE CASCADE;


--
-- Name: ingredient_per_product ingredient_per_product_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_per_product
    ADD CONSTRAINT ingredient_per_product_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: personnal_information personnal_information_gender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnal_information
    ADD CONSTRAINT personnal_information_gender_id_fkey FOREIGN KEY (gender_id) REFERENCES public.gender(id) ON DELETE CASCADE;


--
-- Name: personnal_information personnal_information_phone_number_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnal_information
    ADD CONSTRAINT personnal_information_phone_number_id_fkey FOREIGN KEY (phone_number_id) REFERENCES public.phone_number(id) ON DELETE CASCADE;


--
-- Name: pizzeria pizzeria_adress_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria
    ADD CONSTRAINT pizzeria_adress_id_fkey FOREIGN KEY (adress_id) REFERENCES public.adress(id) ON DELETE CASCADE;


--
-- Name: pizzeria_affiliate pizzeria_affiliate_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria_affiliate
    ADD CONSTRAINT pizzeria_affiliate_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id) ON DELETE CASCADE;


--
-- Name: pizzeria_affiliate pizzeria_affiliate_pizzeria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pizzeria_affiliate
    ADD CONSTRAINT pizzeria_affiliate_pizzeria_id_fkey FOREIGN KEY (pizzeria_id) REFERENCES public.pizzeria(id) ON DELETE CASCADE;


--
-- Name: product_per_command product_per_command_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_per_command
    ADD CONSTRAINT product_per_command_command_id_fkey FOREIGN KEY (command_id) REFERENCES public.command(id) ON DELETE CASCADE;


--
-- Name: product_per_command product_per_command_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_per_command
    ADD CONSTRAINT product_per_command_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: user_role_per_account user_role_per_account_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_per_account
    ADD CONSTRAINT user_role_per_account_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id) ON DELETE CASCADE;


--
-- Name: user_role_per_account user_role_per_account_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_per_account
    ADD CONSTRAINT user_role_per_account_user_role_id_fkey FOREIGN KEY (user_role_id) REFERENCES public.user_role(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

