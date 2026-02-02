--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: claim_reason_enum; Type: TYPE; Schema: public; Owner: leslieaine
--

CREATE TYPE public.claim_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);


ALTER TYPE public.claim_reason_enum OWNER TO leslieaine;

--
-- Name: order_claim_type_enum; Type: TYPE; Schema: public; Owner: leslieaine
--

CREATE TYPE public.order_claim_type_enum AS ENUM (
    'refund',
    'replace'
);


ALTER TYPE public.order_claim_type_enum OWNER TO leslieaine;

--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: leslieaine
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'draft',
    'archived',
    'canceled',
    'requires_action'
);


ALTER TYPE public.order_status_enum OWNER TO leslieaine;

--
-- Name: return_status_enum; Type: TYPE; Schema: public; Owner: leslieaine
--

CREATE TYPE public.return_status_enum AS ENUM (
    'open',
    'requested',
    'received',
    'partially_received',
    'canceled'
);


ALTER TYPE public.return_status_enum OWNER TO leslieaine;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_holder; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.account_holder (
    id text NOT NULL,
    provider_id text NOT NULL,
    external_id text NOT NULL,
    email text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.account_holder OWNER TO leslieaine;

--
-- Name: api_key; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.api_key (
    id text NOT NULL,
    token text NOT NULL,
    salt text NOT NULL,
    redacted text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    last_used_at timestamp with time zone,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_by text,
    revoked_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT api_key_type_check CHECK ((type = ANY (ARRAY['publishable'::text, 'secret'::text])))
);


ALTER TABLE public.api_key OWNER TO leslieaine;

--
-- Name: application_method_buy_rules; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.application_method_buy_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_buy_rules OWNER TO leslieaine;

--
-- Name: application_method_target_rules; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.application_method_target_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_target_rules OWNER TO leslieaine;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.auth_identity (
    id text NOT NULL,
    app_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.auth_identity OWNER TO leslieaine;

--
-- Name: capture; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.capture (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb
);


ALTER TABLE public.capture OWNER TO leslieaine;

--
-- Name: cart; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart (
    id text NOT NULL,
    region_id text,
    customer_id text,
    sales_channel_id text,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    locale text
);


ALTER TABLE public.cart OWNER TO leslieaine;

--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_address OWNER TO leslieaine;

--
-- Name: cart_line_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_line_item (
    id text NOT NULL,
    cart_id text NOT NULL,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    quantity integer NOT NULL,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    product_type_id text,
    is_custom_price boolean DEFAULT false NOT NULL,
    is_giftcard boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.cart_line_item OWNER TO leslieaine;

--
-- Name: cart_line_item_adjustment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_adjustment_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.cart_line_item_adjustment OWNER TO leslieaine;

--
-- Name: cart_line_item_tax_line; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text
);


ALTER TABLE public.cart_line_item_tax_line OWNER TO leslieaine;

--
-- Name: cart_payment_collection; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_payment_collection (
    cart_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_payment_collection OWNER TO leslieaine;

--
-- Name: cart_promotion; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_promotion (
    cart_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_promotion OWNER TO leslieaine;

--
-- Name: cart_shipping_method; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_shipping_method (
    id text NOT NULL,
    cart_id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT cart_shipping_method_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.cart_shipping_method OWNER TO leslieaine;

--
-- Name: cart_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


ALTER TABLE public.cart_shipping_method_adjustment OWNER TO leslieaine;

--
-- Name: cart_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.cart_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


ALTER TABLE public.cart_shipping_method_tax_line OWNER TO leslieaine;

--
-- Name: credit_line; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.credit_line (
    id text NOT NULL,
    cart_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.credit_line OWNER TO leslieaine;

--
-- Name: currency; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.currency (
    code text NOT NULL,
    symbol text NOT NULL,
    symbol_native text NOT NULL,
    decimal_digits integer DEFAULT 0 NOT NULL,
    rounding numeric DEFAULT 0 NOT NULL,
    raw_rounding jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.currency OWNER TO leslieaine;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.customer (
    id text NOT NULL,
    company_name text,
    first_name text,
    last_name text,
    email text,
    phone text,
    has_account boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.customer OWNER TO leslieaine;

--
-- Name: customer_account_holder; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.customer_account_holder (
    customer_id character varying(255) NOT NULL,
    account_holder_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_account_holder OWNER TO leslieaine;

--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.customer_address (
    id text NOT NULL,
    customer_id text NOT NULL,
    address_name text,
    is_default_shipping boolean DEFAULT false NOT NULL,
    is_default_billing boolean DEFAULT false NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_address OWNER TO leslieaine;

--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.customer_group (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    created_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_group OWNER TO leslieaine;

--
-- Name: customer_group_customer; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.customer_group_customer (
    id text NOT NULL,
    customer_id text NOT NULL,
    customer_group_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_group_customer OWNER TO leslieaine;

--
-- Name: fulfillment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.fulfillment (
    id text NOT NULL,
    location_id text NOT NULL,
    packed_at timestamp with time zone,
    shipped_at timestamp with time zone,
    delivered_at timestamp with time zone,
    canceled_at timestamp with time zone,
    data jsonb,
    provider_id text,
    shipping_option_id text,
    metadata jsonb,
    delivery_address_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    marked_shipped_by text,
    created_by text,
    requires_shipping boolean DEFAULT true NOT NULL
);


ALTER TABLE public.fulfillment OWNER TO leslieaine;

--
-- Name: fulfillment_address; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.fulfillment_address (
    id text NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_address OWNER TO leslieaine;

--
-- Name: fulfillment_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.fulfillment_item (
    id text NOT NULL,
    title text NOT NULL,
    sku text NOT NULL,
    barcode text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    line_item_id text,
    inventory_item_id text,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_item OWNER TO leslieaine;

--
-- Name: fulfillment_label; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.fulfillment_label (
    id text NOT NULL,
    tracking_number text NOT NULL,
    tracking_url text NOT NULL,
    label_url text NOT NULL,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_label OWNER TO leslieaine;

--
-- Name: fulfillment_provider; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.fulfillment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_provider OWNER TO leslieaine;

--
-- Name: fulfillment_set; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.fulfillment_set (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_set OWNER TO leslieaine;

--
-- Name: geo_zone; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.geo_zone (
    id text NOT NULL,
    type text DEFAULT 'country'::text NOT NULL,
    country_code text NOT NULL,
    province_code text,
    city text,
    service_zone_id text NOT NULL,
    postal_expression jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT geo_zone_type_check CHECK ((type = ANY (ARRAY['country'::text, 'province'::text, 'city'::text, 'zip'::text])))
);


ALTER TABLE public.geo_zone OWNER TO leslieaine;

--
-- Name: image; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.image (
    id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    rank integer DEFAULT 0 NOT NULL,
    product_id text NOT NULL
);


ALTER TABLE public.image OWNER TO leslieaine;

--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.inventory_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    sku text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    requires_shipping boolean DEFAULT true NOT NULL,
    description text,
    title text,
    thumbnail text,
    metadata jsonb
);


ALTER TABLE public.inventory_item OWNER TO leslieaine;

--
-- Name: inventory_level; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.inventory_level (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    inventory_item_id text NOT NULL,
    location_id text NOT NULL,
    stocked_quantity numeric DEFAULT 0 NOT NULL,
    reserved_quantity numeric DEFAULT 0 NOT NULL,
    incoming_quantity numeric DEFAULT 0 NOT NULL,
    metadata jsonb,
    raw_stocked_quantity jsonb,
    raw_reserved_quantity jsonb,
    raw_incoming_quantity jsonb
);


ALTER TABLE public.inventory_level OWNER TO leslieaine;

--
-- Name: invite; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.invite (
    id text NOT NULL,
    email text NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.invite OWNER TO leslieaine;

--
-- Name: link_module_migrations; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.link_module_migrations (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL,
    link_descriptor jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.link_module_migrations OWNER TO leslieaine;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.link_module_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.link_module_migrations_id_seq OWNER TO leslieaine;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.link_module_migrations_id_seq OWNED BY public.link_module_migrations.id;


--
-- Name: location_fulfillment_provider; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.location_fulfillment_provider (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_provider OWNER TO leslieaine;

--
-- Name: location_fulfillment_set; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.location_fulfillment_set (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_set OWNER TO leslieaine;

--
-- Name: merchant; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant (
    id text NOT NULL,
    email text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    store_id text,
    sales_channel_id text,
    name text,
    CONSTRAINT merchant_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text])))
);


ALTER TABLE public.merchant OWNER TO leslieaine;

--
-- Name: merchant_auth_identity; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_auth_identity (
    id text NOT NULL,
    auth_identity_id text NOT NULL,
    merchant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.merchant_auth_identity OWNER TO leslieaine;

--
-- Name: merchant_categories; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sales_channel_id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.merchant_categories OWNER TO leslieaine;

--
-- Name: merchant_category_products; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_category_products (
    category_id uuid NOT NULL,
    product_id text NOT NULL
);


ALTER TABLE public.merchant_category_products OWNER TO leslieaine;

--
-- Name: merchant_collection_products; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_collection_products (
    collection_id uuid NOT NULL,
    product_id text NOT NULL
);


ALTER TABLE public.merchant_collection_products OWNER TO leslieaine;

--
-- Name: merchant_collections; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sales_channel_id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.merchant_collections OWNER TO leslieaine;

--
-- Name: merchant_store; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_store (
    id uuid NOT NULL,
    merchant_id uuid NOT NULL,
    store_id text NOT NULL
);


ALTER TABLE public.merchant_store OWNER TO leslieaine;

--
-- Name: merchant_user; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchant_user (
    id uuid NOT NULL,
    merchant_id uuid NOT NULL,
    auth_identity_id text NOT NULL,
    role text DEFAULT 'owner'::text NOT NULL
);


ALTER TABLE public.merchant_user OWNER TO leslieaine;

--
-- Name: merchants; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.merchants (
    id text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.merchants OWNER TO leslieaine;

--
-- Name: mikro_orm_migrations; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.mikro_orm_migrations (
    id integer NOT NULL,
    name character varying(255),
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mikro_orm_migrations OWNER TO leslieaine;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.mikro_orm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mikro_orm_migrations_id_seq OWNER TO leslieaine;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNED BY public.mikro_orm_migrations.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.notification (
    id text NOT NULL,
    "to" text NOT NULL,
    channel text NOT NULL,
    template text,
    data jsonb,
    trigger_type text,
    resource_id text,
    resource_type text,
    receiver_id text,
    original_notification_id text,
    idempotency_key text,
    external_id text,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    "from" text,
    provider_data jsonb,
    CONSTRAINT notification_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'success'::text, 'failure'::text])))
);


ALTER TABLE public.notification OWNER TO leslieaine;

--
-- Name: notification_provider; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.notification_provider (
    id text NOT NULL,
    handle text NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    channels text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.notification_provider OWNER TO leslieaine;

--
-- Name: order; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public."order" (
    id text NOT NULL,
    region_id text,
    display_id integer,
    customer_id text,
    version integer DEFAULT 1 NOT NULL,
    sales_channel_id text,
    status public.order_status_enum DEFAULT 'pending'::public.order_status_enum NOT NULL,
    is_draft_order boolean DEFAULT false NOT NULL,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    no_notification boolean,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    custom_display_id text,
    locale text
);


ALTER TABLE public."order" OWNER TO leslieaine;

--
-- Name: order_address; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_address OWNER TO leslieaine;

--
-- Name: order_cart; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_cart (
    order_id character varying(255) NOT NULL,
    cart_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_cart OWNER TO leslieaine;

--
-- Name: order_change; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_change (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    description text,
    status text DEFAULT 'pending'::text NOT NULL,
    internal_note text,
    created_by text,
    requested_by text,
    requested_at timestamp with time zone,
    confirmed_by text,
    confirmed_at timestamp with time zone,
    declined_by text,
    declined_reason text,
    metadata jsonb,
    declined_at timestamp with time zone,
    canceled_by text,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type text,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text,
    carry_over_promotions boolean,
    CONSTRAINT order_change_status_check CHECK ((status = ANY (ARRAY['confirmed'::text, 'declined'::text, 'requested'::text, 'pending'::text, 'canceled'::text])))
);


ALTER TABLE public.order_change OWNER TO leslieaine;

--
-- Name: order_change_action; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_change_action (
    id text NOT NULL,
    order_id text,
    version integer,
    ordering bigint NOT NULL,
    order_change_id text,
    reference text,
    reference_id text,
    action text NOT NULL,
    details jsonb,
    amount numeric,
    raw_amount jsonb,
    internal_note text,
    applied boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_change_action OWNER TO leslieaine;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.order_change_action_ordering_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_change_action_ordering_seq OWNER TO leslieaine;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.order_change_action_ordering_seq OWNED BY public.order_change_action.ordering;


--
-- Name: order_claim; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_claim (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    type public.order_claim_type_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.order_claim OWNER TO leslieaine;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.order_claim_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_claim_display_id_seq OWNER TO leslieaine;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.order_claim_display_id_seq OWNED BY public.order_claim.display_id;


--
-- Name: order_claim_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_claim_item (
    id text NOT NULL,
    claim_id text NOT NULL,
    item_id text NOT NULL,
    is_additional_item boolean DEFAULT false NOT NULL,
    reason public.claim_reason_enum,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_claim_item OWNER TO leslieaine;

--
-- Name: order_claim_item_image; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_claim_item_image (
    id text NOT NULL,
    claim_item_id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_claim_item_image OWNER TO leslieaine;

--
-- Name: order_credit_line; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_credit_line (
    id text NOT NULL,
    order_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    version integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.order_credit_line OWNER TO leslieaine;

--
-- Name: order_display_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_display_id_seq OWNER TO leslieaine;

--
-- Name: order_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.order_display_id_seq OWNED BY public."order".display_id;


--
-- Name: order_exchange; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_exchange (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    no_notification boolean,
    allow_backorder boolean DEFAULT false NOT NULL,
    difference_due numeric,
    raw_difference_due jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.order_exchange OWNER TO leslieaine;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.order_exchange_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_exchange_display_id_seq OWNER TO leslieaine;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.order_exchange_display_id_seq OWNED BY public.order_exchange.display_id;


--
-- Name: order_exchange_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_exchange_item (
    id text NOT NULL,
    exchange_id text NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_exchange_item OWNER TO leslieaine;

--
-- Name: order_fulfillment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_fulfillment (
    order_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_fulfillment OWNER TO leslieaine;

--
-- Name: order_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_item (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    fulfilled_quantity numeric NOT NULL,
    raw_fulfilled_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    shipped_quantity numeric NOT NULL,
    raw_shipped_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_requested_quantity numeric NOT NULL,
    raw_return_requested_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_received_quantity numeric NOT NULL,
    raw_return_received_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_dismissed_quantity numeric NOT NULL,
    raw_return_dismissed_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    written_off_quantity numeric NOT NULL,
    raw_written_off_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    delivered_quantity numeric DEFAULT 0 NOT NULL,
    raw_delivered_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    unit_price numeric,
    raw_unit_price jsonb,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb
);


ALTER TABLE public.order_item OWNER TO leslieaine;

--
-- Name: order_line_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_line_item (
    id text NOT NULL,
    totals_id text,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_price boolean DEFAULT false NOT NULL,
    product_type_id text,
    is_giftcard boolean DEFAULT false NOT NULL
);


ALTER TABLE public.order_line_item OWNER TO leslieaine;

--
-- Name: order_line_item_adjustment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    version integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.order_line_item_adjustment OWNER TO leslieaine;

--
-- Name: order_line_item_tax_line; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_line_item_tax_line OWNER TO leslieaine;

--
-- Name: order_payment_collection; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_payment_collection (
    order_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_payment_collection OWNER TO leslieaine;

--
-- Name: order_promotion; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_promotion (
    order_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_promotion OWNER TO leslieaine;

--
-- Name: order_shipping; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_shipping (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    shipping_method_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_shipping OWNER TO leslieaine;

--
-- Name: order_shipping_method; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_shipping_method (
    id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_amount boolean DEFAULT false NOT NULL
);


ALTER TABLE public.order_shipping_method OWNER TO leslieaine;

--
-- Name: order_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_shipping_method_adjustment OWNER TO leslieaine;

--
-- Name: order_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_shipping_method_tax_line OWNER TO leslieaine;

--
-- Name: order_summary; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_summary (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    totals jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_summary OWNER TO leslieaine;

--
-- Name: order_transaction; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.order_transaction (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    reference text,
    reference_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_transaction OWNER TO leslieaine;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.payment (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    provider_id text NOT NULL,
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    captured_at timestamp with time zone,
    canceled_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    payment_session_id text NOT NULL,
    metadata jsonb
);


ALTER TABLE public.payment OWNER TO leslieaine;

--
-- Name: payment_collection; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.payment_collection (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    authorized_amount numeric,
    raw_authorized_amount jsonb,
    captured_amount numeric,
    raw_captured_amount jsonb,
    refunded_amount numeric,
    raw_refunded_amount jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    status text DEFAULT 'not_paid'::text NOT NULL,
    metadata jsonb,
    CONSTRAINT payment_collection_status_check CHECK ((status = ANY (ARRAY['not_paid'::text, 'awaiting'::text, 'authorized'::text, 'partially_authorized'::text, 'canceled'::text, 'failed'::text, 'partially_captured'::text, 'completed'::text])))
);


ALTER TABLE public.payment_collection OWNER TO leslieaine;

--
-- Name: payment_collection_payment_providers; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.payment_collection_payment_providers (
    payment_collection_id text NOT NULL,
    payment_provider_id text NOT NULL
);


ALTER TABLE public.payment_collection_payment_providers OWNER TO leslieaine;

--
-- Name: payment_provider; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.payment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.payment_provider OWNER TO leslieaine;

--
-- Name: payment_session; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.payment_session (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    context jsonb,
    status text DEFAULT 'pending'::text NOT NULL,
    authorized_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT payment_session_status_check CHECK ((status = ANY (ARRAY['authorized'::text, 'captured'::text, 'pending'::text, 'requires_more'::text, 'error'::text, 'canceled'::text])))
);


ALTER TABLE public.payment_session OWNER TO leslieaine;

--
-- Name: price; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.price (
    id text NOT NULL,
    title text,
    price_set_id text NOT NULL,
    currency_code text NOT NULL,
    raw_amount jsonb NOT NULL,
    rules_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    price_list_id text,
    amount numeric NOT NULL,
    min_quantity numeric,
    max_quantity numeric,
    raw_min_quantity jsonb,
    raw_max_quantity jsonb
);


ALTER TABLE public.price OWNER TO leslieaine;

--
-- Name: price_list; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.price_list (
    id text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    rules_count integer DEFAULT 0,
    title text NOT NULL,
    description text NOT NULL,
    type text DEFAULT 'sale'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT price_list_status_check CHECK ((status = ANY (ARRAY['active'::text, 'draft'::text]))),
    CONSTRAINT price_list_type_check CHECK ((type = ANY (ARRAY['sale'::text, 'override'::text])))
);


ALTER TABLE public.price_list OWNER TO leslieaine;

--
-- Name: price_list_rule; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.price_list_rule (
    id text NOT NULL,
    price_list_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    value jsonb,
    attribute text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.price_list_rule OWNER TO leslieaine;

--
-- Name: price_preference; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.price_preference (
    id text NOT NULL,
    attribute text NOT NULL,
    value text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_preference OWNER TO leslieaine;

--
-- Name: price_rule; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.price_rule (
    id text NOT NULL,
    value text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    price_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    attribute text DEFAULT ''::text NOT NULL,
    operator text DEFAULT 'eq'::text NOT NULL,
    CONSTRAINT price_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text])))
);


ALTER TABLE public.price_rule OWNER TO leslieaine;

--
-- Name: price_set; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.price_set (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_set OWNER TO leslieaine;

--
-- Name: product; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    subtitle text,
    description text,
    is_giftcard boolean DEFAULT false NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    thumbnail text,
    weight text,
    length text,
    height text,
    width text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    collection_id text,
    type_id text,
    discountable boolean DEFAULT true NOT NULL,
    external_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    CONSTRAINT product_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'proposed'::text, 'published'::text, 'rejected'::text])))
);


ALTER TABLE public.product OWNER TO leslieaine;

--
-- Name: product_category; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_category (
    id text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    handle text NOT NULL,
    mpath text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    parent_category_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);


ALTER TABLE public.product_category OWNER TO leslieaine;

--
-- Name: product_category_product; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_category_product (
    product_id text NOT NULL,
    product_category_id text NOT NULL
);


ALTER TABLE public.product_category_product OWNER TO leslieaine;

--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_collection (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_collection OWNER TO leslieaine;

--
-- Name: product_option; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_option (
    id text NOT NULL,
    title text NOT NULL,
    product_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_option OWNER TO leslieaine;

--
-- Name: product_option_value; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_option_value (
    id text NOT NULL,
    value text NOT NULL,
    option_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_option_value OWNER TO leslieaine;

--
-- Name: product_sales_channel; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_sales_channel (
    product_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_sales_channel OWNER TO leslieaine;

--
-- Name: product_shipping_profile; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_shipping_profile (
    product_id character varying(255) NOT NULL,
    shipping_profile_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_shipping_profile OWNER TO leslieaine;

--
-- Name: product_tag; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_tag (
    id text NOT NULL,
    value text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_tag OWNER TO leslieaine;

--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_tags (
    product_id text NOT NULL,
    product_tag_id text NOT NULL
);


ALTER TABLE public.product_tags OWNER TO leslieaine;

--
-- Name: product_type; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_type (
    id text NOT NULL,
    value text NOT NULL,
    metadata json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_type OWNER TO leslieaine;

--
-- Name: product_variant; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_variant (
    id text NOT NULL,
    title text NOT NULL,
    sku text,
    barcode text,
    ean text,
    upc text,
    allow_backorder boolean DEFAULT false NOT NULL,
    manage_inventory boolean DEFAULT true NOT NULL,
    hs_code text,
    origin_country text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    metadata jsonb,
    variant_rank integer DEFAULT 0,
    product_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    thumbnail text
);


ALTER TABLE public.product_variant OWNER TO leslieaine;

--
-- Name: product_variant_inventory_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_variant_inventory_item (
    variant_id character varying(255) NOT NULL,
    inventory_item_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    required_quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_inventory_item OWNER TO leslieaine;

--
-- Name: product_variant_option; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_variant_option (
    variant_id text NOT NULL,
    option_value_id text NOT NULL
);


ALTER TABLE public.product_variant_option OWNER TO leslieaine;

--
-- Name: product_variant_price_set; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_variant_price_set (
    variant_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_price_set OWNER TO leslieaine;

--
-- Name: product_variant_product_image; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.product_variant_product_image (
    id text NOT NULL,
    variant_id text NOT NULL,
    image_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_product_image OWNER TO leslieaine;

--
-- Name: promotion; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion (
    id text NOT NULL,
    code text NOT NULL,
    campaign_id text,
    is_automatic boolean DEFAULT false NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'draft'::text NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    "limit" integer,
    used integer DEFAULT 0 NOT NULL,
    metadata jsonb,
    CONSTRAINT promotion_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'inactive'::text]))),
    CONSTRAINT promotion_type_check CHECK ((type = ANY (ARRAY['standard'::text, 'buyget'::text])))
);


ALTER TABLE public.promotion OWNER TO leslieaine;

--
-- Name: promotion_application_method; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_application_method (
    id text NOT NULL,
    value numeric,
    raw_value jsonb,
    max_quantity integer,
    apply_to_quantity integer,
    buy_rules_min_quantity integer,
    type text NOT NULL,
    target_type text NOT NULL,
    allocation text,
    promotion_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_application_method_allocation_check CHECK ((allocation = ANY (ARRAY['each'::text, 'across'::text, 'once'::text]))),
    CONSTRAINT promotion_application_method_target_type_check CHECK ((target_type = ANY (ARRAY['order'::text, 'shipping_methods'::text, 'items'::text]))),
    CONSTRAINT promotion_application_method_type_check CHECK ((type = ANY (ARRAY['fixed'::text, 'percentage'::text])))
);


ALTER TABLE public.promotion_application_method OWNER TO leslieaine;

--
-- Name: promotion_campaign; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_campaign (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    campaign_identifier text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_campaign OWNER TO leslieaine;

--
-- Name: promotion_campaign_budget; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_campaign_budget (
    id text NOT NULL,
    type text NOT NULL,
    campaign_id text NOT NULL,
    "limit" numeric,
    raw_limit jsonb,
    used numeric DEFAULT 0 NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    attribute text,
    CONSTRAINT promotion_campaign_budget_type_check CHECK ((type = ANY (ARRAY['spend'::text, 'usage'::text, 'use_by_attribute'::text, 'spend_by_attribute'::text])))
);


ALTER TABLE public.promotion_campaign_budget OWNER TO leslieaine;

--
-- Name: promotion_campaign_budget_usage; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_campaign_budget_usage (
    id text NOT NULL,
    attribute_value text NOT NULL,
    used numeric DEFAULT 0 NOT NULL,
    budget_id text NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_campaign_budget_usage OWNER TO leslieaine;

--
-- Name: promotion_promotion_rule; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_promotion_rule (
    promotion_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.promotion_promotion_rule OWNER TO leslieaine;

--
-- Name: promotion_rule; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_rule (
    id text NOT NULL,
    description text,
    attribute text NOT NULL,
    operator text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT promotion_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text, 'ne'::text, 'in'::text])))
);


ALTER TABLE public.promotion_rule OWNER TO leslieaine;

--
-- Name: promotion_rule_value; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.promotion_rule_value (
    id text NOT NULL,
    promotion_rule_id text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_rule_value OWNER TO leslieaine;

--
-- Name: provider_identity; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.provider_identity (
    id text NOT NULL,
    entity_id text NOT NULL,
    provider text NOT NULL,
    auth_identity_id text NOT NULL,
    user_metadata jsonb,
    provider_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.provider_identity OWNER TO leslieaine;

--
-- Name: publishable_api_key_sales_channel; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.publishable_api_key_sales_channel (
    publishable_key_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.publishable_api_key_sales_channel OWNER TO leslieaine;

--
-- Name: refund; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.refund (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb,
    refund_reason_id text,
    note text
);


ALTER TABLE public.refund OWNER TO leslieaine;

--
-- Name: refund_reason; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.refund_reason (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    code text NOT NULL
);


ALTER TABLE public.refund_reason OWNER TO leslieaine;

--
-- Name: region; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.region (
    id text NOT NULL,
    name text NOT NULL,
    currency_code text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    automatic_taxes boolean DEFAULT true NOT NULL
);


ALTER TABLE public.region OWNER TO leslieaine;

--
-- Name: region_country; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.region_country (
    iso_2 text NOT NULL,
    iso_3 text NOT NULL,
    num_code text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    region_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_country OWNER TO leslieaine;

--
-- Name: region_payment_provider; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.region_payment_provider (
    region_id character varying(255) NOT NULL,
    payment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_payment_provider OWNER TO leslieaine;

--
-- Name: reservation_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.reservation_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    line_item_id text,
    location_id text NOT NULL,
    quantity numeric NOT NULL,
    external_id text,
    description text,
    created_by text,
    metadata jsonb,
    inventory_item_id text NOT NULL,
    allow_backorder boolean DEFAULT false,
    raw_quantity jsonb
);


ALTER TABLE public.reservation_item OWNER TO leslieaine;

--
-- Name: return; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.return (
    id text NOT NULL,
    order_id text NOT NULL,
    claim_id text,
    exchange_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    status public.return_status_enum DEFAULT 'open'::public.return_status_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    received_at timestamp with time zone,
    canceled_at timestamp with time zone,
    location_id text,
    requested_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.return OWNER TO leslieaine;

--
-- Name: return_display_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.return_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.return_display_id_seq OWNER TO leslieaine;

--
-- Name: return_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.return_display_id_seq OWNED BY public.return.display_id;


--
-- Name: return_fulfillment; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.return_fulfillment (
    return_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_fulfillment OWNER TO leslieaine;

--
-- Name: return_item; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.return_item (
    id text NOT NULL,
    return_id text NOT NULL,
    reason_id text,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    received_quantity numeric DEFAULT 0 NOT NULL,
    raw_received_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    damaged_quantity numeric DEFAULT 0 NOT NULL,
    raw_damaged_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL
);


ALTER TABLE public.return_item OWNER TO leslieaine;

--
-- Name: return_reason; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.return_reason (
    id character varying NOT NULL,
    value character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    metadata jsonb,
    parent_return_reason_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_reason OWNER TO leslieaine;

--
-- Name: sales_channel; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.sales_channel (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    is_disabled boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel OWNER TO leslieaine;

--
-- Name: sales_channel_stock_location; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.sales_channel_stock_location (
    sales_channel_id character varying(255) NOT NULL,
    stock_location_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel_stock_location OWNER TO leslieaine;

--
-- Name: script_migrations; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.script_migrations (
    id integer NOT NULL,
    script_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp with time zone
);


ALTER TABLE public.script_migrations OWNER TO leslieaine;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: leslieaine
--

CREATE SEQUENCE public.script_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.script_migrations_id_seq OWNER TO leslieaine;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: leslieaine
--

ALTER SEQUENCE public.script_migrations_id_seq OWNED BY public.script_migrations.id;


--
-- Name: service_zone; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.service_zone (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    fulfillment_set_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.service_zone OWNER TO leslieaine;

--
-- Name: shipping_option; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.shipping_option (
    id text NOT NULL,
    name text NOT NULL,
    price_type text DEFAULT 'flat'::text NOT NULL,
    service_zone_id text NOT NULL,
    shipping_profile_id text,
    provider_id text,
    data jsonb,
    metadata jsonb,
    shipping_option_type_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_price_type_check CHECK ((price_type = ANY (ARRAY['calculated'::text, 'flat'::text])))
);


ALTER TABLE public.shipping_option OWNER TO leslieaine;

--
-- Name: shipping_option_price_set; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.shipping_option_price_set (
    shipping_option_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_price_set OWNER TO leslieaine;

--
-- Name: shipping_option_rule; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.shipping_option_rule (
    id text NOT NULL,
    attribute text NOT NULL,
    operator text NOT NULL,
    value jsonb,
    shipping_option_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_rule_operator_check CHECK ((operator = ANY (ARRAY['in'::text, 'eq'::text, 'ne'::text, 'gt'::text, 'gte'::text, 'lt'::text, 'lte'::text, 'nin'::text])))
);


ALTER TABLE public.shipping_option_rule OWNER TO leslieaine;

--
-- Name: shipping_option_type; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.shipping_option_type (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_type OWNER TO leslieaine;

--
-- Name: shipping_profile; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.shipping_profile (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_profile OWNER TO leslieaine;

--
-- Name: sites; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.sites (
    id text NOT NULL,
    handle text NOT NULL,
    merchant_id text,
    sales_channel_id text NOT NULL,
    status text DEFAULT 'draft'::text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.sites OWNER TO leslieaine;

--
-- Name: stock_location; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.stock_location (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    address_id text,
    metadata jsonb
);


ALTER TABLE public.stock_location OWNER TO leslieaine;

--
-- Name: stock_location_address; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.stock_location_address (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    address_1 text NOT NULL,
    address_2 text,
    company text,
    city text,
    country_code text NOT NULL,
    phone text,
    province text,
    postal_code text,
    metadata jsonb
);


ALTER TABLE public.stock_location_address OWNER TO leslieaine;

--
-- Name: store; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.store (
    id text NOT NULL,
    name text DEFAULT 'Medusa Store'::text NOT NULL,
    default_sales_channel_id text,
    default_region_id text,
    default_location_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    handle text
);


ALTER TABLE public.store OWNER TO leslieaine;

--
-- Name: store_currency; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.store_currency (
    id text NOT NULL,
    currency_code text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store_currency OWNER TO leslieaine;

--
-- Name: store_locale; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.store_locale (
    id text NOT NULL,
    locale_code text NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store_locale OWNER TO leslieaine;

--
-- Name: tax_provider; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.tax_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_provider OWNER TO leslieaine;

--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.tax_rate (
    id text NOT NULL,
    rate real,
    code text NOT NULL,
    name text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_combinable boolean DEFAULT false NOT NULL,
    tax_region_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_rate OWNER TO leslieaine;

--
-- Name: tax_rate_rule; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.tax_rate_rule (
    id text NOT NULL,
    tax_rate_id text NOT NULL,
    reference_id text NOT NULL,
    reference text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_rate_rule OWNER TO leslieaine;

--
-- Name: tax_region; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.tax_region (
    id text NOT NULL,
    provider_id text,
    country_code text NOT NULL,
    province_code text,
    parent_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone,
    CONSTRAINT "CK_tax_region_country_top_level" CHECK (((parent_id IS NULL) OR (province_code IS NOT NULL))),
    CONSTRAINT "CK_tax_region_provider_top_level" CHECK (((parent_id IS NULL) OR (provider_id IS NULL)))
);


ALTER TABLE public.tax_region OWNER TO leslieaine;

--
-- Name: user; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public."user" (
    id text NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    avatar_url text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public."user" OWNER TO leslieaine;

--
-- Name: user_preference; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.user_preference (
    id text NOT NULL,
    user_id text NOT NULL,
    key text NOT NULL,
    value jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.user_preference OWNER TO leslieaine;

--
-- Name: view_configuration; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.view_configuration (
    id text NOT NULL,
    entity text NOT NULL,
    name text,
    user_id text,
    is_system_default boolean DEFAULT false NOT NULL,
    configuration jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.view_configuration OWNER TO leslieaine;

--
-- Name: workflow_execution; Type: TABLE; Schema: public; Owner: leslieaine
--

CREATE TABLE public.workflow_execution (
    id character varying NOT NULL,
    workflow_id character varying NOT NULL,
    transaction_id character varying NOT NULL,
    execution jsonb,
    context jsonb,
    state character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    retention_time integer,
    run_id text DEFAULT '01KEEQEZ7T64CW7TNFCVV55FET'::text NOT NULL
);


ALTER TABLE public.workflow_execution OWNER TO leslieaine;

--
-- Name: link_module_migrations id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.link_module_migrations ALTER COLUMN id SET DEFAULT nextval('public.link_module_migrations_id_seq'::regclass);


--
-- Name: mikro_orm_migrations id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.mikro_orm_migrations ALTER COLUMN id SET DEFAULT nextval('public.mikro_orm_migrations_id_seq'::regclass);


--
-- Name: order display_id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);


--
-- Name: order_change_action ordering; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_change_action ALTER COLUMN ordering SET DEFAULT nextval('public.order_change_action_ordering_seq'::regclass);


--
-- Name: order_claim display_id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_claim ALTER COLUMN display_id SET DEFAULT nextval('public.order_claim_display_id_seq'::regclass);


--
-- Name: order_exchange display_id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_exchange ALTER COLUMN display_id SET DEFAULT nextval('public.order_exchange_display_id_seq'::regclass);


--
-- Name: return display_id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.return ALTER COLUMN display_id SET DEFAULT nextval('public.return_display_id_seq'::regclass);


--
-- Name: script_migrations id; Type: DEFAULT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.script_migrations ALTER COLUMN id SET DEFAULT nextval('public.script_migrations_id_seq'::regclass);


--
-- Data for Name: account_holder; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.account_holder (id, provider_id, external_id, email, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.api_key (id, token, salt, redacted, title, type, last_used_at, created_by, created_at, revoked_by, revoked_at, updated_at, deleted_at) FROM stdin;
apk_01KEEQF2Y42AH1FWG0FP6YMFGX	pk_5645c23bfb46de9950fa60a99ad5dcb7a33d76431a41f52fcabefc5cabb65e18		pk_564***e18	Default Publishable API Key	publishable	\N		2026-01-08 03:56:56.132-08	\N	\N	2026-01-08 03:56:56.132-08	\N
apk_01KEEWS3CQCM473R3EMA0QH8W1	pk_7300e27168db625dcbac22555dcd7b6020ff9a1112d2c17e9924aa9b1094c7b2		pk_730***7b2	storefront(local)	publishable	\N	user_01KEEQGY53Q28HW9SSFY87F4S6	2026-01-08 05:29:47.161-08	\N	\N	2026-01-08 05:29:47.161-08	\N
apk_01KERYVW0X926ZC5AFX8E3X8P6	d1c1a6cb9242f2c2084b2eb38e575665352628764973e23c69e6932a7acdefa87701d3bd1219795cadb4e3d47dca439d88e5ceec42cb59626f38132c9a7a6540	15c6853adb53fe30792022ee00d7e360	sk_b8d***e25	Leslie	secret	\N	user_01KEEQGY53Q28HW9SSFY87F4S6	2026-01-12 03:18:39.389-08	\N	\N	2026-01-12 03:18:39.389-08	\N
apk_01KFDCSYBP8D44DA9TXRGSBHD5	pk_a8446372eb50d371fed4142836f413313535e829719b1cc2b430214e094e96ac		pk_a84***6ac	test-merchant	publishable	\N	user_01KEEQGY53Q28HW9SSFY87F4S6	2026-01-20 01:47:04.951-08	\N	\N	2026-01-20 01:47:04.951-08	\N
apk_01KFFZ29PGX0FGT1T6S00QF08C	10b30dfdf96d1cf81127b852a3819c3d0a1116faeaed949a65a29f4cbb7f0754b3127dccea1babce38bf4d422a1046dd4072b34faaae19cd586f7f25fde8edd9	53e3207791a10e4904b27e5a683a0365	sk_1bd***c7a	test	secret	\N	user_01KEEQGY53Q28HW9SSFY87F4S6	2026-01-21 01:44:41.936-08	user_01KEEQGY53Q28HW9SSFY87F4S6	2026-01-21 01:47:31.443-08	2026-01-21 01:47:31.446-08	\N
apk_01KG1RG2RHPJCBSQHM3BA7S4N4	30d71dad5d0d4f5ddddf93e460827d3da9fcb3295d6439b0e402e63950f9dbec428175971c1597a3bbe29e2c617f59f234462ecfa4aa922bb913b7468db2a24f	fccd2d2d09680ccce5ef981f9583fb9a	sk_476***f66	delete-productss	secret	\N	user_01KFZZM8KB8H1FH09QBDMWSFZN	2026-01-27 23:36:13.331-08	\N	\N	2026-01-27 23:36:13.331-08	\N
\.


--
-- Data for Name: application_method_buy_rules; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.application_method_buy_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: application_method_target_rules; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.application_method_target_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.auth_identity (id, app_metadata, created_at, updated_at, deleted_at) FROM stdin;
authid_01KFZNC90C7QN5WQ0QEMB7GABB	\N	2026-01-27 04:03:14.077-08	2026-01-27 04:03:14.106-08	\N
authid_01KFZZM8P5PWF9J8A3NS490638	{"user_id": "user_01KFZZM8KB8H1FH09QBDMWSFZN"}	2026-01-27 07:02:21.637-08	2026-01-27 07:02:21.65-08	\N
authid_01KG49DC5CP597H8W8KYG5RR63	\N	2026-01-28 23:10:19.309-08	2026-01-28 23:10:19.309-08	\N
authid_01KG4A1B87TBA5893QDWPQP71R	\N	2026-01-28 23:21:13.736-08	2026-01-28 23:21:13.736-08	\N
authid_01KFZNKB5C6HM4HFFN3T227AM9	{"user_id": "user_01KG4CZ37N7J5E1Q6GQNCXB7NR"}	2026-01-27 04:07:05.644-08	2026-01-29 00:12:25.736-08	\N
authid_01KG1WWK72QPQK21P5VSMT3QDN	{"merchant_id": "01KG4G1R7V456M8YJCFTA0NVEQ"}	2026-01-28 00:52:57.698-08	2026-01-29 01:06:18.532-08	\N
authid_01KG4TPQ6BQAHY557CDPYJAJ6E	{"merchant_id": "01KG4TQPYVQ3AFRJAEXM5Q8SVZ"}	2026-01-29 04:12:31.307-08	2026-01-29 04:13:03.866-08	\N
authid_01KG4V1GQ4KDWS6F1V983GX0TQ	{"merchant_id": "01KG4V4VJJ9SW0ZZEPQGHR111F"}	2026-01-29 04:18:25.132-08	2026-01-29 04:20:14.56-08	\N
authid_01KG78MMN3R0SYAV4Y34FSFTDY	{"merchant_id": "01KG790HGFK9SANV7WMJ4MZZ1G"}	2026-01-30 02:54:32.1-08	2026-01-30 03:01:02.136-08	\N
authid_01KG79GW0ENKZAQ8ERMCK6Y4KQ	{"merchant_id": "01KG79J21JR0AD4BPANQ7A40K1"}	2026-01-30 03:09:57.136-08	2026-01-30 03:10:36.095-08	\N
authid_01KG79YWP8794046S29YG92WBR	{"merchant_id": "01KG7A0EG7W0FTVPZKMZX5WQ8E"}	2026-01-30 03:17:36.585-08	2026-01-30 03:18:27.61-08	\N
authid_01KGC9BYXQP487PJ477XEKVWPA	\N	2026-02-01 01:43:28.44-08	2026-02-01 01:43:28.44-08	\N
authid_01KGCADYX6990PDPATVB1G54ZG	\N	2026-02-01 02:02:02.537-08	2026-02-01 02:02:02.537-08	\N
authid_01KGEK0R1QDW5N095Y0P733A10	\N	2026-02-01 23:10:35.577-08	2026-02-01 23:10:35.577-08	\N
\.


--
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.capture (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata) FROM stdin;
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart (id, region_id, customer_id, sales_channel_id, email, currency_code, shipping_address_id, billing_address_id, metadata, created_at, updated_at, deleted_at, completed_at, locale) FROM stdin;
cart_01KEGVRXSRD2DKTTMK6BNVNH87	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEEX6NRW9KCDMQ2VCWPWDXGF	\N	eur	\N	\N	\N	2026-01-08 23:50:41.728-08	2026-01-08 23:50:41.728-08	\N	\N	\N
cart_01KERZQ0RX9MCSE4HFA07EVFWV	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KERZRT9A4NAE5BGFGGS11Y32	\N	\N	2026-01-12 03:33:28.991-08	2026-01-12 03:34:27.884-08	\N	\N	\N
cart_01KEVFYRDHEMVMXRZEQ6FPSYCN	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEVFZJRQBNDP4WN2SYZ1DN0T	\N	\N	2026-01-13 02:55:48.658-08	2026-01-13 02:56:21.243-08	\N	2026-01-13 02:56:21.234-08	\N
cart_01KEVFZS3KB62B5MFTNW7HZ9XB	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEVH0S9EEVKJ8R738QN34Z8F	\N	\N	2026-01-13 02:56:22.131-08	2026-01-13 03:58:24.936-08	\N	2026-01-13 03:58:24.916-08	\N
cart_01KEH65CGXQ5HD4JJVRTRH1GAS	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KERPSDNBFRJXHA8AZ2Y724HE	\N	\N	2026-01-09 02:52:15.778-08	2026-01-13 00:03:12.312-08	\N	\N	\N
cart_01KEV6HSM8QX3N8F15SEYGAFCV	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEV6KXNN25J0N7G8N8FQHC4C	\N	\N	2026-01-13 00:11:26.729-08	2026-01-13 00:12:36.405-08	\N	\N	\N
cart_01KEV77ZFA43Z3TVTD9YC0SR71	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEV79PMPWZAW2BZAJR759R9Q	\N	\N	2026-01-13 00:23:33.612-08	2026-01-13 00:27:00.415-08	\N	2026-01-13 00:27:00.393-08	\N
cart_01KEV80N64TN22V0V63H0MHS1F	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEVB48XP85R02BKHPKQQ7W2Y	\N	\N	2026-01-13 00:37:02.282-08	2026-01-13 01:31:26.518-08	\N	\N	\N
cart_01KEVBQ01B641BZEFP2Z6NRZ4T	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-13 01:41:40.027-08	2026-01-13 01:41:40.027-08	\N	\N	\N
cart_01KEVBQ0ZB0QRW1Z3EAW0X7MVG	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEVBSVPYF1S9ZV6NV0GKZQE7	\N	\N	2026-01-13 01:41:40.973-08	2026-01-13 01:43:13.887-08	\N	\N	\N
cart_01KEVBTFT37AGJBNYXSTAFXHWY	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEVBVT8E44E6V63118AFZZAA	\N	\N	2026-01-13 01:43:34.468-08	2026-01-13 02:04:55.916-08	\N	2026-01-13 02:04:55.909-08	\N
cart_01KEVD1MPKKSMPGJ7H09P1WEPQ	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-13 02:04:57.429-08	2026-01-13 02:04:57.429-08	\N	\N	\N
cart_01KEVFYPMBGZ8JPMETZA9TSJ1A	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-13 02:55:46.827-08	2026-01-13 02:55:46.827-08	\N	\N	\N
cart_01KEVKHF38G4R94BH4CE5QYWRR	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-13 03:58:27.434-08	2026-01-13 03:58:27.434-08	\N	\N	\N
cart_01KEVME3K2Y1J01GTHWC19HDNP	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	cus_01KERPGC66DX42ACMBAYTTR5K7	sc_01KEGW7Y54E127T0FXHV7DA7KX	aineleslie@gmail.com	eur	caaddr_01KEVMEZ0YCB1XA7BDZMKXWS3Y	\N	\N	2026-01-13 04:14:05.923-08	2026-01-13 04:14:54.042-08	\N	2026-01-13 04:14:54.034-08	\N
cart_01KEVMFMEBKH7T9YJHABE62S36	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-13 04:14:55.948-08	2026-01-13 04:14:55.948-08	\N	\N	\N
cart_01KFAM9S17Z1VZF6STYE7KJ69P	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-19 00:00:20.521-08	2026-01-19 00:00:20.521-08	\N	\N	\N
cart_01KFDFHEB5N40188E4V1N2A213	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KFDBA2GYFVJJ5X2YQ63BZRKX	\N	eur	\N	\N	\N	2026-01-20 02:34:52.133-08	2026-01-20 02:34:52.133-08	\N	\N	\N
cart_01KFDVB1Q10PZ2EB6N27AZZFWB	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-20 06:01:05.515-08	2026-01-20 06:01:05.515-08	\N	\N	\N
cart_01KFDVGJXRV78W9G8B7H388FR5	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-20 06:04:06.969-08	2026-01-20 06:04:06.969-08	\N	\N	\N
cart_01KFJEBS6D5DW4MVBKZK9HCFKB	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-22 00:50:30.223-08	2026-01-22 00:50:30.223-08	\N	\N	\N
cart_01KFSY1HPTD4WRXM6KB4ND3S5C	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-24 22:39:13.121-08	2026-01-24 22:39:13.121-08	\N	\N	\N
cart_01KFWK98QNVYJWMB8A2HHV71HZ	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-25 23:28:55.032-08	2026-01-25 23:28:55.032-08	\N	\N	\N
cart_01KFWQMGJMX5JN9XEP0DJ6XWKT	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	sc_01KEGW7Y54E127T0FXHV7DA7KX	\N	eur	\N	\N	\N	2026-01-26 00:44:57.815-08	2026-01-26 00:44:57.815-08	\N	\N	\N
\.


--
-- Data for Name: cart_address; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
caaddr_01KERPSDNBFRJXHA8AZ2Y724HE	\N	\N	john 	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-12 00:57:30.541-08	2026-01-12 00:57:30.541-08	\N
caaddr_01KERZRT9A4NAE5BGFGGS11Y32	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-12 03:34:27.883-08	2026-01-12 03:34:27.883-08	\N
caaddr_01KEV6KXNN25J0N7G8N8FQHC4C	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 00:12:36.405-08	2026-01-13 00:12:36.405-08	\N
caaddr_01KEV79PMPWZAW2BZAJR759R9Q	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 00:24:30.102-08	2026-01-13 00:24:30.102-08	\N
caaddr_01KEVB48XP85R02BKHPKQQ7W2Y	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 01:31:26.518-08	2026-01-13 01:31:26.518-08	\N
caaddr_01KEVBSVPYF1S9ZV6NV0GKZQE7	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 01:43:13.886-08	2026-01-13 01:43:13.886-08	\N
caaddr_01KEVBVT8E44E6V63118AFZZAA	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 01:44:17.934-08	2026-01-13 01:44:17.934-08	\N
caaddr_01KEVFZJRQBNDP4WN2SYZ1DN0T	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 02:56:15.639-08	2026-01-13 02:56:15.639-08	\N
caaddr_01KEVH0S9EEVKJ8R738QN34Z8F	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 03:14:23.663-08	2026-01-13 03:14:23.663-08	\N
caaddr_01KEVMEZ0YCB1XA7BDZMKXWS3Y	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 04:14:34.015-08	2026-01-13 04:14:34.015-08	\N
\.


--
-- Data for Name: cart_line_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_line_item (id, cart_id, title, subtitle, thumbnail, quantity, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, product_type_id, is_custom_price, is_giftcard) FROM stdin;
cali_01KEGYC083K8CCKK1EX33VXZ00	cart_01KEGVRXSRD2DKTTMK6BNVNH87	shirt cold	Default variant	http://localhost:9000/static/1767874479955-card1.jpg	1	variant_01KEERFJ36H7HJ437NNQTRVM3T	prod_01KEERFHV6PFYPA83BZRPMW4SE	shirt cold	warm shirt for cold weather		\N	Beardcare	shirt-cold	\N	\N	Default variant	\N	f	t	f	\N	\N	30	{"value": "30", "precision": 20}	{}	2026-01-09 00:36:03.973-08	2026-01-09 00:37:35.973-08	2026-01-09 00:37:35.97-08	\N	f	f
cali_01KERZQY2ZVMV5CR5HWWPHGGW9	cart_01KERZQ0RX9MCSE4HFA07EVFWV	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	3	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-12 03:33:59.007-08	2026-01-12 03:34:07.345-08	\N	\N	f	f
cali_01KEV6JDQW1H6JXSY3416DY0AK	cart_01KEV6HSM8QX3N8F15SEYGAFCV	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	1	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 00:11:47.325-08	2026-01-13 00:11:47.325-08	\N	\N	f	f
cali_01KERNXZHA7GTHVB3P9AXKX6YB	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	Medusa Sweatpants	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	2	variant_01KEEQF5092822XGN36BRKT8NM	prod_01KEEQF4YGS2F914XC4T8P09M1	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	Beardcare	sweatpants	SWEATPANTS-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-12 00:42:31.34-08	2026-01-12 02:51:23.513-08	\N	\N	f	f
cali_01KERMEPNE918ZW9NGWKTV9313	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	Medusa Sweatpants	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	3	variant_01KEEQF5092822XGN36BRKT8NM	prod_01KEEQF4YGS2F914XC4T8P09M1	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	Beardcare	sweatpants	SWEATPANTS-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-12 00:16:42.16-08	2026-01-12 00:34:48.081-08	2026-01-12 00:34:48.074-08	\N	f	f
cali_01KERNYNFPFVH7VDTJTGQHM46H	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	shirt cold	Default variant	http://localhost:9000/static/1767874479955-card1.jpg	1	variant_01KEERFJ36H7HJ437NNQTRVM3T	prod_01KEERFHV6PFYPA83BZRPMW4SE	shirt cold	warm shirt for cold weather		\N	Beardcare	shirt-cold	\N	\N	Default variant	\N	f	t	f	\N	\N	30	{"value": "30", "precision": 20}	{}	2026-01-12 00:42:53.814-08	2026-01-12 02:51:31.818-08	\N	\N	f	f
cali_01KERPAYH3WQJNVS90W4J1NHVR	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	2	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-12 00:49:36.293-08	2026-01-12 02:51:42.715-08	\N	\N	f	f
cali_01KEH7EZDJQQB1EPAGAR74KTK8	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	2	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-09 03:14:58.61-08	2026-01-12 00:34:58.315-08	2026-01-12 00:34:58.315-08	\N	f	f
cali_01KEV78NASN3B2EYCHEF1NCGRD	cart_01KEV77ZFA43Z3TVTD9YC0SR71	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	1	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 00:23:55.993-08	2026-01-13 00:23:55.993-08	\N	\N	f	f
cali_01KERZQDC155M7XR5XPEASH2AW	cart_01KERZQ0RX9MCSE4HFA07EVFWV	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	1	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-12 03:33:41.889-08	2026-01-12 03:33:41.89-08	\N	\N	f	f
cali_01KEVB37E4XTMWG01P5HM0AV7J	cart_01KEV80N64TN22V0V63H0MHS1F	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	1	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 01:30:52.229-08	2026-01-13 01:30:52.229-08	\N	\N	f	f
cali_01KEV6JWY0QAM1GCBFZN6XYAWW	cart_01KEV6HSM8QX3N8F15SEYGAFCV	Medusa Sweatpants	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	3	variant_01KEEQF5092822XGN36BRKT8NM	prod_01KEEQF4YGS2F914XC4T8P09M1	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	Beardcare	sweatpants	SWEATPANTS-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 00:12:02.88-08	2026-01-13 00:12:09.914-08	\N	\N	f	f
cali_01KEV78B1ACAWD8004P541B8G8	cart_01KEV77ZFA43Z3TVTD9YC0SR71	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	1	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 00:23:45.45-08	2026-01-13 00:23:45.45-08	\N	\N	f	f
cali_01KEVB3JA5QTAGAR82V5W2MVRG	cart_01KEV80N64TN22V0V63H0MHS1F	Medusa Sweatpants	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	2	variant_01KEEQF5092822XGN36BRKT8NM	prod_01KEEQF4YGS2F914XC4T8P09M1	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	Beardcare	sweatpants	SWEATPANTS-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 01:31:03.365-08	2026-01-13 01:31:15.236-08	\N	\N	f	f
cali_01KEVGQ8WDDC73KN04FMSTKAKC	cart_01KEVFZS3KB62B5MFTNW7HZ9XB	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	3	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 03:09:11.952-08	2026-01-13 03:09:20.771-08	\N	\N	f	f
cali_01KEVMEB5G3SZ72NPFEWQN94ZE	cart_01KEVME3K2Y1J01GTHWC19HDNP	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	3	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 04:14:13.68-08	2026-01-13 04:14:23.373-08	\N	\N	f	f
cali_01KEVBRDKR30AJNE0WG3H22GKY	cart_01KEVBQ0ZB0QRW1Z3EAW0X7MVG	Medusa Sweatpants	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	1	variant_01KEEQF5092822XGN36BRKT8NM	prod_01KEEQF4YGS2F914XC4T8P09M1	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	Beardcare	sweatpants	SWEATPANTS-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 01:42:26.68-08	2026-01-13 01:42:59.35-08	\N	\N	f	f
cali_01KEVBQCKR8F5MC6Z8B6DV0KNV	cart_01KEVBQ0ZB0QRW1Z3EAW0X7MVG	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	5	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 01:41:52.888-08	2026-01-13 01:43:01.281-08	\N	\N	f	f
cali_01KEVBV0YHAXJ93SQ29K29E2WY	cart_01KEVBTFT37AGJBNYXSTAFXHWY	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	1	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 01:43:52.018-08	2026-01-13 01:43:52.018-08	\N	\N	f	f
cali_01KEVFYZJTA7FDGR01X1FWWFY4	cart_01KEVFYRDHEMVMXRZEQ6FPSYCN	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	4	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 02:55:55.994-08	2026-01-13 02:56:03.067-08	\N	\N	f	f
\.


--
-- Data for Name: cart_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, item_id, is_tax_inclusive) FROM stdin;
\.


--
-- Data for Name: cart_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_line_item_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_payment_collection; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_payment_collection (cart_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
cart_01KEH65CGXQ5HD4JJVRTRH1GAS	pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	capaycol_01KEV56EX4E35RKTBC81YPXDWS	2026-01-12 23:47:46.723506-08	2026-01-12 23:47:46.723506-08	\N
cart_01KEV6HSM8QX3N8F15SEYGAFCV	pay_col_01KEV6SQJAD28Z1QFVQDPGBN87	capaycol_01KEV6SQK3DHGRBA6YSSEB7V2Y	2026-01-13 00:15:46.786918-08	2026-01-13 00:15:46.786918-08	\N
cart_01KEV77ZFA43Z3TVTD9YC0SR71	pay_col_01KEV7A1KK5HZ1JYETWQTBYB3B	capaycol_01KEV7A1KVCQHDSHR84DSWNHA3	2026-01-13 00:24:41.339171-08	2026-01-13 00:24:41.339171-08	\N
cart_01KEV80N64TN22V0V63H0MHS1F	pay_col_01KEVB4E6SVREHCXAXNQHP2HD9	capaycol_01KEVB4E74B121KPZ6D9V0H97H	2026-01-13 01:31:31.939637-08	2026-01-13 01:31:31.939637-08	\N
cart_01KEVBQ0ZB0QRW1Z3EAW0X7MVG	pay_col_01KEVBSZR76YR10Q0P5CJ61Z29	capaycol_01KEVBSZRHM5P2ENVV39NPGYV6	2026-01-13 01:43:18.033163-08	2026-01-13 01:43:18.033163-08	\N
cart_01KEVBTFT37AGJBNYXSTAFXHWY	pay_col_01KEVBVXX2ZR0SRPZJNATWJX0V	capaycol_01KEVBVXX78K8Z7BXGS4QJQ2DG	2026-01-13 01:44:21.671176-08	2026-01-13 01:44:21.671176-08	\N
cart_01KEVFYRDHEMVMXRZEQ6FPSYCN	pay_col_01KEVFZR2BRGNVC9S73JDJ141Y	capaycol_01KEVFZR2HCFHTF4AV8PNXNVWM	2026-01-13 02:56:21.073138-08	2026-01-13 02:56:21.073138-08	\N
cart_01KEVFZS3KB62B5MFTNW7HZ9XB	pay_col_01KEVH0YPRJPZD7CWKWW30YQJT	capaycol_01KEVH0YPWR4WF09TKVYD380EK	2026-01-13 03:14:29.212784-08	2026-01-13 03:14:29.212784-08	\N
cart_01KEVME3K2Y1J01GTHWC19HDNP	pay_col_01KEVMFFEDAQDX3DTVYX7ZPH0S	capaycol_01KEVMFFES6PD6AX5D86Y64TS5	2026-01-13 04:14:50.841249-08	2026-01-13 04:14:50.841249-08	\N
\.


--
-- Data for Name: cart_promotion; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_promotion (cart_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_shipping_method (id, cart_id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
casm_01KERSHVTN453167P1SA2MD8J2	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-12 01:45:48.629-08	2026-01-12 01:45:48.629-08	\N
casm_01KERZS0MK4KJS5SF93Y979FQX	cart_01KERZQ0RX9MCSE4HFA07EVFWV	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-12 03:34:34.388-08	2026-01-12 03:34:34.388-08	\N
casm_01KEV6M1A42FCRN1YD8CXJD39E	cart_01KEV6HSM8QX3N8F15SEYGAFCV	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 00:12:40.132-08	2026-01-13 00:12:40.132-08	\N
casm_01KEV79T54XBNHWB9JG4THB59F	cart_01KEV77ZFA43Z3TVTD9YC0SR71	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 00:24:33.7-08	2026-01-13 00:24:33.7-08	\N
casm_01KEVB4CJFNMW2Z21MW4K7VJJ3	cart_01KEV80N64TN22V0V63H0MHS1F	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 01:31:30.255-08	2026-01-13 01:31:30.255-08	\N
casm_01KEVBSYARKDCSZYKYPAQC2YVY	cart_01KEVBQ0ZB0QRW1Z3EAW0X7MVG	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 01:43:16.568-08	2026-01-13 01:43:16.568-08	\N
casm_01KEVBVWQT0XCJX17SM0D2182V	cart_01KEVBTFT37AGJBNYXSTAFXHWY	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 01:44:20.474-08	2026-01-13 01:44:20.474-08	\N
casm_01KEVFZPH2VRDNQCY6S8VHB22Z	cart_01KEVFYRDHEMVMXRZEQ6FPSYCN	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 02:56:19.49-08	2026-01-13 02:56:19.49-08	\N
casm_01KEVH0X1A7V58ZDDMDR1WCS3M	cart_01KEVFZS3KB62B5MFTNW7HZ9XB	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 03:14:27.498-08	2026-01-13 03:14:27.498-08	\N
casm_01KEVMF1SMDE4FD1BVH7YMEZSC	cart_01KEVME3K2Y1J01GTHWC19HDNP	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 04:14:36.852-08	2026-01-13 04:14:36.852-08	\N
\.


--
-- Data for Name: cart_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.cart_shipping_method_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: credit_line; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.credit_line (id, cart_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.currency (code, symbol, symbol_native, decimal_digits, rounding, raw_rounding, name, created_at, updated_at, deleted_at) FROM stdin;
usd	$	$	2	0	{"value": "0", "precision": 20}	US Dollar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
cad	CA$	$	2	0	{"value": "0", "precision": 20}	Canadian Dollar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
eur	€	€	2	0	{"value": "0", "precision": 20}	Euro	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
aed	AED	د.إ.‏	2	0	{"value": "0", "precision": 20}	United Arab Emirates Dirham	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
afn	Af	؋	0	0	{"value": "0", "precision": 20}	Afghan Afghani	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
all	ALL	Lek	0	0	{"value": "0", "precision": 20}	Albanian Lek	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
amd	AMD	դր.	0	0	{"value": "0", "precision": 20}	Armenian Dram	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
ars	AR$	$	2	0	{"value": "0", "precision": 20}	Argentine Peso	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
aud	AU$	$	2	0	{"value": "0", "precision": 20}	Australian Dollar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
azn	man.	ман.	2	0	{"value": "0", "precision": 20}	Azerbaijani Manat	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bam	KM	KM	2	0	{"value": "0", "precision": 20}	Bosnia-Herzegovina Convertible Mark	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bdt	Tk	৳	2	0	{"value": "0", "precision": 20}	Bangladeshi Taka	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bgn	BGN	лв.	2	0	{"value": "0", "precision": 20}	Bulgarian Lev	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bhd	BD	د.ب.‏	3	0	{"value": "0", "precision": 20}	Bahraini Dinar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bif	FBu	FBu	0	0	{"value": "0", "precision": 20}	Burundian Franc	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bnd	BN$	$	2	0	{"value": "0", "precision": 20}	Brunei Dollar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bob	Bs	Bs	2	0	{"value": "0", "precision": 20}	Bolivian Boliviano	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
brl	R$	R$	2	0	{"value": "0", "precision": 20}	Brazilian Real	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bwp	BWP	P	2	0	{"value": "0", "precision": 20}	Botswanan Pula	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
byn	Br	руб.	2	0	{"value": "0", "precision": 20}	Belarusian Ruble	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
bzd	BZ$	$	2	0	{"value": "0", "precision": 20}	Belize Dollar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
cdf	CDF	FrCD	2	0	{"value": "0", "precision": 20}	Congolese Franc	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
chf	CHF	CHF	2	0.05	{"value": "0.05", "precision": 20}	Swiss Franc	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
clp	CL$	$	0	0	{"value": "0", "precision": 20}	Chilean Peso	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
cny	CN¥	CN¥	2	0	{"value": "0", "precision": 20}	Chinese Yuan	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
cop	CO$	$	0	0	{"value": "0", "precision": 20}	Colombian Peso	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
crc	₡	₡	0	0	{"value": "0", "precision": 20}	Costa Rican Colón	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
cve	CV$	CV$	2	0	{"value": "0", "precision": 20}	Cape Verdean Escudo	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
czk	Kč	Kč	2	0	{"value": "0", "precision": 20}	Czech Republic Koruna	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
djf	Fdj	Fdj	0	0	{"value": "0", "precision": 20}	Djiboutian Franc	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
dkk	Dkr	kr	2	0	{"value": "0", "precision": 20}	Danish Krone	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
dop	RD$	RD$	2	0	{"value": "0", "precision": 20}	Dominican Peso	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
dzd	DA	د.ج.‏	2	0	{"value": "0", "precision": 20}	Algerian Dinar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
eek	Ekr	kr	2	0	{"value": "0", "precision": 20}	Estonian Kroon	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
egp	EGP	ج.م.‏	2	0	{"value": "0", "precision": 20}	Egyptian Pound	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
ern	Nfk	Nfk	2	0	{"value": "0", "precision": 20}	Eritrean Nakfa	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
etb	Br	Br	2	0	{"value": "0", "precision": 20}	Ethiopian Birr	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
gbp	£	£	2	0	{"value": "0", "precision": 20}	British Pound Sterling	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
gel	GEL	GEL	2	0	{"value": "0", "precision": 20}	Georgian Lari	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
ghs	GH₵	GH₵	2	0	{"value": "0", "precision": 20}	Ghanaian Cedi	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
gnf	FG	FG	0	0	{"value": "0", "precision": 20}	Guinean Franc	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
gtq	GTQ	Q	2	0	{"value": "0", "precision": 20}	Guatemalan Quetzal	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
hkd	HK$	$	2	0	{"value": "0", "precision": 20}	Hong Kong Dollar	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
hnl	HNL	L	2	0	{"value": "0", "precision": 20}	Honduran Lempira	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
hrk	kn	kn	2	0	{"value": "0", "precision": 20}	Croatian Kuna	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
huf	Ft	Ft	0	0	{"value": "0", "precision": 20}	Hungarian Forint	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
idr	Rp	Rp	0	0	{"value": "0", "precision": 20}	Indonesian Rupiah	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
ils	₪	₪	2	0	{"value": "0", "precision": 20}	Israeli New Sheqel	2026-01-08 03:56:53.593-08	2026-01-08 03:56:53.593-08	\N
inr	Rs	₹	2	0	{"value": "0", "precision": 20}	Indian Rupee	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
iqd	IQD	د.ع.‏	0	0	{"value": "0", "precision": 20}	Iraqi Dinar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
irr	IRR	﷼	0	0	{"value": "0", "precision": 20}	Iranian Rial	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
isk	Ikr	kr	0	0	{"value": "0", "precision": 20}	Icelandic Króna	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
jmd	J$	$	2	0	{"value": "0", "precision": 20}	Jamaican Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
jod	JD	د.أ.‏	3	0	{"value": "0", "precision": 20}	Jordanian Dinar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
jpy	¥	￥	0	0	{"value": "0", "precision": 20}	Japanese Yen	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
kes	Ksh	Ksh	2	0	{"value": "0", "precision": 20}	Kenyan Shilling	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
khr	KHR	៛	2	0	{"value": "0", "precision": 20}	Cambodian Riel	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
kmf	CF	FC	0	0	{"value": "0", "precision": 20}	Comorian Franc	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
krw	₩	₩	0	0	{"value": "0", "precision": 20}	South Korean Won	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
kwd	KD	د.ك.‏	3	0	{"value": "0", "precision": 20}	Kuwaiti Dinar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
kzt	KZT	тңг.	2	0	{"value": "0", "precision": 20}	Kazakhstani Tenge	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
lbp	LB£	ل.ل.‏	0	0	{"value": "0", "precision": 20}	Lebanese Pound	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
lkr	SLRs	SL Re	2	0	{"value": "0", "precision": 20}	Sri Lankan Rupee	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
ltl	Lt	Lt	2	0	{"value": "0", "precision": 20}	Lithuanian Litas	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
lvl	Ls	Ls	2	0	{"value": "0", "precision": 20}	Latvian Lats	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
lyd	LD	د.ل.‏	3	0	{"value": "0", "precision": 20}	Libyan Dinar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mad	MAD	د.م.‏	2	0	{"value": "0", "precision": 20}	Moroccan Dirham	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mdl	MDL	MDL	2	0	{"value": "0", "precision": 20}	Moldovan Leu	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mga	MGA	MGA	0	0	{"value": "0", "precision": 20}	Malagasy Ariary	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mkd	MKD	MKD	2	0	{"value": "0", "precision": 20}	Macedonian Denar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mmk	MMK	K	0	0	{"value": "0", "precision": 20}	Myanma Kyat	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mnt	MNT	₮	0	0	{"value": "0", "precision": 20}	Mongolian Tugrig	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mop	MOP$	MOP$	2	0	{"value": "0", "precision": 20}	Macanese Pataca	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mur	MURs	MURs	0	0	{"value": "0", "precision": 20}	Mauritian Rupee	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mwk	K	K	2	0	{"value": "0", "precision": 20}	Malawian Kwacha	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mxn	MX$	$	2	0	{"value": "0", "precision": 20}	Mexican Peso	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
myr	RM	RM	2	0	{"value": "0", "precision": 20}	Malaysian Ringgit	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
mzn	MTn	MTn	2	0	{"value": "0", "precision": 20}	Mozambican Metical	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
nad	N$	N$	2	0	{"value": "0", "precision": 20}	Namibian Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
ngn	₦	₦	2	0	{"value": "0", "precision": 20}	Nigerian Naira	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
nio	C$	C$	2	0	{"value": "0", "precision": 20}	Nicaraguan Córdoba	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
nok	Nkr	kr	2	0	{"value": "0", "precision": 20}	Norwegian Krone	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
npr	NPRs	नेरू	2	0	{"value": "0", "precision": 20}	Nepalese Rupee	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
nzd	NZ$	$	2	0	{"value": "0", "precision": 20}	New Zealand Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
omr	OMR	ر.ع.‏	3	0	{"value": "0", "precision": 20}	Omani Rial	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
pab	B/.	B/.	2	0	{"value": "0", "precision": 20}	Panamanian Balboa	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
pen	S/.	S/.	2	0	{"value": "0", "precision": 20}	Peruvian Nuevo Sol	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
php	₱	₱	2	0	{"value": "0", "precision": 20}	Philippine Peso	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
pkr	PKRs	₨	0	0	{"value": "0", "precision": 20}	Pakistani Rupee	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
pln	zł	zł	2	0	{"value": "0", "precision": 20}	Polish Zloty	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
pyg	₲	₲	0	0	{"value": "0", "precision": 20}	Paraguayan Guarani	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
qar	QR	ر.ق.‏	2	0	{"value": "0", "precision": 20}	Qatari Rial	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
ron	RON	RON	2	0	{"value": "0", "precision": 20}	Romanian Leu	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
rsd	din.	дин.	0	0	{"value": "0", "precision": 20}	Serbian Dinar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
rub	RUB	₽.	2	0	{"value": "0", "precision": 20}	Russian Ruble	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
rwf	RWF	FR	0	0	{"value": "0", "precision": 20}	Rwandan Franc	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
sar	SR	ر.س.‏	2	0	{"value": "0", "precision": 20}	Saudi Riyal	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
sdg	SDG	SDG	2	0	{"value": "0", "precision": 20}	Sudanese Pound	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
sek	Skr	kr	2	0	{"value": "0", "precision": 20}	Swedish Krona	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
sgd	S$	$	2	0	{"value": "0", "precision": 20}	Singapore Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
sos	Ssh	Ssh	0	0	{"value": "0", "precision": 20}	Somali Shilling	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
syp	SY£	ل.س.‏	0	0	{"value": "0", "precision": 20}	Syrian Pound	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
thb	฿	฿	2	0	{"value": "0", "precision": 20}	Thai Baht	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
tnd	DT	د.ت.‏	3	0	{"value": "0", "precision": 20}	Tunisian Dinar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
top	T$	T$	2	0	{"value": "0", "precision": 20}	Tongan Paʻanga	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
tjs	TJS	с.	2	0	{"value": "0", "precision": 20}	Tajikistani Somoni	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
try	₺	₺	2	0	{"value": "0", "precision": 20}	Turkish Lira	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
ttd	TT$	$	2	0	{"value": "0", "precision": 20}	Trinidad and Tobago Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
twd	NT$	NT$	2	0	{"value": "0", "precision": 20}	New Taiwan Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
tzs	TSh	TSh	0	0	{"value": "0", "precision": 20}	Tanzanian Shilling	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
uah	₴	₴	2	0	{"value": "0", "precision": 20}	Ukrainian Hryvnia	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
ugx	USh	USh	0	0	{"value": "0", "precision": 20}	Ugandan Shilling	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
uyu	$U	$	2	0	{"value": "0", "precision": 20}	Uruguayan Peso	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
uzs	UZS	UZS	0	0	{"value": "0", "precision": 20}	Uzbekistan Som	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
vef	Bs.F.	Bs.F.	2	0	{"value": "0", "precision": 20}	Venezuelan Bolívar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
vnd	₫	₫	0	0	{"value": "0", "precision": 20}	Vietnamese Dong	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
xaf	FCFA	FCFA	0	0	{"value": "0", "precision": 20}	CFA Franc BEAC	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
xof	CFA	CFA	0	0	{"value": "0", "precision": 20}	CFA Franc BCEAO	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
xpf	₣	₣	0	0	{"value": "0", "precision": 20}	CFP Franc	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
yer	YR	ر.ي.‏	0	0	{"value": "0", "precision": 20}	Yemeni Rial	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
zar	R	R	2	0	{"value": "0", "precision": 20}	South African Rand	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
zmk	ZK	ZK	0	0	{"value": "0", "precision": 20}	Zambian Kwacha	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
zwl	ZWL$	ZWL$	0	0	{"value": "0", "precision": 20}	Zimbabwean Dollar	2026-01-08 03:56:53.594-08	2026-01-08 03:56:53.594-08	\N
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.customer (id, company_name, first_name, last_name, email, phone, has_account, metadata, created_at, updated_at, deleted_at, created_by) FROM stdin;
cus_01KERPGC66DX42ACMBAYTTR5K7	\N	\N	\N	aineleslie@gmail.com	\N	f	\N	2026-01-12 00:52:34.118-08	2026-01-12 00:52:34.118-08	\N	\N
\.


--
-- Data for Name: customer_account_holder; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.customer_account_holder (customer_id, account_holder_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_address; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.customer_address (id, customer_id, address_name, is_default_shipping, is_default_billing, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.customer_group (id, name, metadata, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group_customer; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.customer_group_customer (id, customer_id, customer_group_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.fulfillment (id, location_id, packed_at, shipped_at, delivered_at, canceled_at, data, provider_id, shipping_option_id, metadata, delivery_address_id, created_at, updated_at, deleted_at, marked_shipped_by, created_by, requires_shipping) FROM stdin;
ful_01KFB1HM1JNZ6GDVQPBJ9YJ17S	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	2026-01-19 03:51:49.03-08	\N	\N	\N	{}	manual_manual	so_01KEEQF4VJRE372E61E8K0FZT3	\N	fuladdr_01KFB1HM1JTXGDKNDDHYQS3WMC	2026-01-19 03:51:49.045-08	2026-01-19 03:51:49.045-08	\N	\N	\N	t
\.


--
-- Data for Name: fulfillment_address; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.fulfillment_address (id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuladdr_01KFB1HM1JTXGDKNDDHYQS3WMC	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 04:14:34.015-08	2026-01-13 04:14:34.015-08	\N
\.


--
-- Data for Name: fulfillment_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.fulfillment_item (id, title, sku, barcode, quantity, raw_quantity, line_item_id, inventory_item_id, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
fulit_01KFB1HM1HK1676HTKEKGE11R3	M	SWEATSHIRT-M		3	{"value": "3", "precision": 20}	ordli_01KEVMFJ5M4G4EPXK9MSAZKC9B	iitem_01KEEQF50SD0R2E5TE38HPMKM5	ful_01KFB1HM1JNZ6GDVQPBJ9YJ17S	2026-01-19 03:51:49.046-08	2026-01-19 03:51:49.046-08	\N
\.


--
-- Data for Name: fulfillment_label; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.fulfillment_label (id, tracking_number, tracking_url, label_url, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.fulfillment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
manual_manual	t	2026-01-08 03:56:53.6-08	2026-01-08 03:56:53.6-08	\N
\.


--
-- Data for Name: fulfillment_set; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.fulfillment_set (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuset_01KEEQF4TDBRS857H6BWRKMGNX	European Warehouse delivery	shipping	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
\.


--
-- Data for Name: geo_zone; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.geo_zone (id, type, country_code, province_code, city, service_zone_id, postal_expression, metadata, created_at, updated_at, deleted_at) FROM stdin;
fgz_01KEEQF4TDSJCPEB652C4NSFQJ	country	gb	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
fgz_01KEEQF4TDTG60S225Z9MFV172	country	de	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
fgz_01KEEQF4TDH66E46FZ50TPA3RB	country	dk	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
fgz_01KEEQF4TDJ1RPMDF3E00CJ30M	country	se	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
fgz_01KEEQF4TD30R3HN9SDXT3V2CN	country	fr	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
fgz_01KEEQF4TDJXFQHTJH2B3CRXRV	country	es	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
fgz_01KEEQF4TDHGB883FWJRCRGW7A	country	it	\N	\N	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	\N	\N	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.image (id, url, metadata, created_at, updated_at, deleted_at, rank, product_id) FROM stdin;
img_01KG1S3Q45HPEQQAW7E04N4QHQ	http://localhost:9000/static/1769586416643-IMG_6150.JPG	\N	2026-01-27 23:46:56.783-08	2026-01-27 23:46:56.783-08	\N	0	prod_01KG1S3Q37C8GVJGSZSPTMPA1F
img_01KG1S5D4G72W1CRE0QXYX4HZ6	http://localhost:9000/static/1769586472060-refle.jpg	\N	2026-01-27 23:47:52.081-08	2026-01-27 23:47:52.081-08	\N	0	prod_01KG1S5D4F7C6CM90FS0MSVPXJ
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.inventory_item (id, created_at, updated_at, deleted_at, sku, origin_country, hs_code, mid_code, material, weight, length, height, width, requires_shipping, description, title, thumbnail, metadata) FROM stdin;
iitem_01KEEQF50S7A5HWCEKQZ82J072	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-S-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	S / Black	S / Black	\N	\N
iitem_01KEEQF50S474SXJP30H37MQBD	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-S-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	S / White	S / White	\N	\N
iitem_01KEEQF50SXCB5RBB8V77ZH4BZ	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-M-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	M / Black	M / Black	\N	\N
iitem_01KEEQF50SEYW21B1SQ6X1D7CY	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-M-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	M / White	M / White	\N	\N
iitem_01KEEQF50SEW23ETP62PC0ZA9C	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-L-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	L / Black	L / Black	\N	\N
iitem_01KEEQF50STA95ECWXQDPRS1GB	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-L-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	L / White	L / White	\N	\N
iitem_01KEEQF50SKXRJT02H8K35JG9A	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-XL-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / Black	XL / Black	\N	\N
iitem_01KEEQF50S0P9TZN6TNCE3PAZM	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHIRT-XL-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / White	XL / White	\N	\N
iitem_01KEEQF50SX6VFJX7GBGZF127S	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATSHIRT-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KEEQF50SD0R2E5TE38HPMKM5	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATSHIRT-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KEEQF50S4SRCVVM2TQE6EH63	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATSHIRT-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KEEQF50S6233NY8W77VS9WRT	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATSHIRT-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KEEQF50SMA82KJN6SSFHYN81	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATPANTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KEEQF50SYPHH43ZHNYZ44V1H	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATPANTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KEEQF50TB1ZHA5GT8C0DRC48	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATPANTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KEEQF50TH947YNXCXZSC79HK	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SWEATPANTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KEEQF50TQM0YDJ06NAQW1PPN	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHORTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KEEQF50TYHWP4ZT1BYRTJ5G1	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHORTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KEEQF50T91311NC83CQA75NX	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHORTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KEEQF50TNW2YRQSBCT4KJN2K	2026-01-08 03:56:58.266-08	2026-01-08 03:56:58.266-08	\N	SHORTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
\.


--
-- Data for Name: inventory_level; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.inventory_level (id, created_at, updated_at, deleted_at, inventory_item_id, location_id, stocked_quantity, reserved_quantity, incoming_quantity, metadata, raw_stocked_quantity, raw_reserved_quantity, raw_incoming_quantity) FROM stdin;
ilev_01KEEQF5301JSYSJD69MAHW6YR	2026-01-08 03:56:58.337-08	2026-01-08 03:56:58.337-08	\N	iitem_01KEEQF50S0P9TZN6TNCE3PAZM	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5316KH00SR3R81VWFV0	2026-01-08 03:56:58.337-08	2026-01-08 03:56:58.337-08	\N	iitem_01KEEQF50S474SXJP30H37MQBD	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531WBWGHCVS5M0B97ES	2026-01-08 03:56:58.337-08	2026-01-08 03:56:58.337-08	\N	iitem_01KEEQF50S4SRCVVM2TQE6EH63	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531RFHYXVVKRPP53D76	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50S6233NY8W77VS9WRT	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5314XTW9GBD3PEJE78B	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50SEW23ETP62PC0ZA9C	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531EP01W5EXH1MH8AJD	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50SEYW21B1SQ6X1D7CY	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5316TT1S0ECV3VANV7M	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50SKXRJT02H8K35JG9A	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5315DAPQBJ1Q2W1CR46	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50SMA82KJN6SSFHYN81	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5312GV9VDVEDV7WQ1E0	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50STA95ECWXQDPRS1GB	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531DHBWSDB5P04B4C51	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50SX6VFJX7GBGZF127S	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF53108VDT0DQ6AK60Z9W	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50SXCB5RBB8V77ZH4BZ	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5313QSRRPR8PR7VTYD1	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50T91311NC83CQA75NX	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531V6PD4755F642PR3D	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50TB1ZHA5GT8C0DRC48	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5319DMN0FG7ZEHSB8T5	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50TH947YNXCXZSC79HK	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531EPEN0RVHW345410H	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50TNW2YRQSBCT4KJN2K	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5318D0KBMY126MTT17A	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50TQM0YDJ06NAQW1PPN	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF5315D7GHWWZ4Y8CKFEV	2026-01-08 03:56:58.338-08	2026-01-08 03:56:58.338-08	\N	iitem_01KEEQF50TYHWP4ZT1BYRTJ5G1	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531W7Y5BJFXH75VRHAC	2026-01-08 03:56:58.338-08	2026-01-13 02:56:21.244-08	\N	iitem_01KEEQF50S7A5HWCEKQZ82J072	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	6	0	\N	{"value": "1000000", "precision": 20}	{"value": "6", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531XWRZC9ZZ5JNVWQZ1	2026-01-08 03:56:58.338-08	2026-01-13 00:03:12.317-08	\N	iitem_01KEEQF50SYPHH43ZHNYZ44V1H	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KEEQF531YD8EHZFFX8XV1VM6	2026-01-08 03:56:58.338-08	2026-01-19 03:51:49.163-08	\N	iitem_01KEEQF50SD0R2E5TE38HPMKM5	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	999997	4	0	\N	{"value": "999997", "precision": 20}	{"value": "4", "precision": 20}	{"value": "0", "precision": 20}
\.


--
-- Data for Name: invite; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.invite (id, email, accepted, token, expires_at, metadata, created_at, updated_at, deleted_at) FROM stdin;
invite_01KEEQF2YQWCQXV9ME92WN83PT	admin@medusa-test.com	f	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Imludml0ZV8wMUtFRVFGMllRV0NRWFY5TUU5MldOODNQVCIsImVtYWlsIjoiYWRtaW5AbWVkdXNhLXRlc3QuY29tIiwiaWF0IjoxNzY3ODczNDE2LCJleHAiOjE3Njc5NTk4MTYsImp0aSI6IjhlOGJmMmU2LTM1YjItNGRjYi04NDRmLWMxMTcxMzEwNTVkYSJ9.qGU5nE4GTzUkNNN8wpBitJ0CQo8X23piqQs8kv13zS8	2026-01-09 03:56:56.151-08	\N	2026-01-08 03:56:56.153-08	2026-01-08 03:57:56.782-08	2026-01-08 03:57:56.782-08
\.


--
-- Data for Name: link_module_migrations; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.link_module_migrations (id, table_name, link_descriptor, created_at) FROM stdin;
1	cart_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "cart", "fromModule": "cart"}	2026-01-08 03:56:52.538219
2	cart_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "cart", "fromModule": "cart"}	2026-01-08 03:56:52.543709
3	location_fulfillment_provider	{"toModel": "fulfillment_provider", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2026-01-08 03:56:52.547057
4	location_fulfillment_set	{"toModel": "fulfillment_set", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2026-01-08 03:56:52.550335
5	order_cart	{"toModel": "cart", "toModule": "cart", "fromModel": "order", "fromModule": "order"}	2026-01-08 03:56:52.55314
6	order_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "order", "fromModule": "order"}	2026-01-08 03:56:52.555994
7	order_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "order", "fromModule": "order"}	2026-01-08 03:56:52.558664
8	order_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "order", "fromModule": "order"}	2026-01-08 03:56:52.560803
9	return_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "return", "fromModule": "order"}	2026-01-08 03:56:52.563131
10	product_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "product", "fromModule": "product"}	2026-01-08 03:56:52.565126
11	product_variant_inventory_item	{"toModel": "inventory", "toModule": "inventory", "fromModel": "variant", "fromModule": "product"}	2026-01-08 03:56:52.567417
12	product_variant_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "variant", "fromModule": "product"}	2026-01-08 03:56:52.569716
13	publishable_api_key_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "api_key", "fromModule": "api_key"}	2026-01-08 03:56:52.571659
14	region_payment_provider	{"toModel": "payment_provider", "toModule": "payment", "fromModel": "region", "fromModule": "region"}	2026-01-08 03:56:52.5736
15	sales_channel_stock_location	{"toModel": "location", "toModule": "stock_location", "fromModel": "sales_channel", "fromModule": "sales_channel"}	2026-01-08 03:56:52.575918
16	shipping_option_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "shipping_option", "fromModule": "fulfillment"}	2026-01-08 03:56:52.577942
17	product_shipping_profile	{"toModel": "shipping_profile", "toModule": "fulfillment", "fromModel": "product", "fromModule": "product"}	2026-01-08 03:56:52.580574
18	customer_account_holder	{"toModel": "account_holder", "toModule": "payment", "fromModel": "customer", "fromModule": "customer"}	2026-01-08 03:56:52.582938
\.


--
-- Data for Name: location_fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.location_fulfillment_provider (stock_location_id, fulfillment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KEEQF4SSX9F3AERPW5A4GJYM	manual_manual	locfp_01KEEQF4T5JR36EVTS9N9BZJ75	2026-01-08 03:56:58.053453-08	2026-01-08 03:56:58.053453-08	\N
\.


--
-- Data for Name: location_fulfillment_set; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.location_fulfillment_set (stock_location_id, fulfillment_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KEEQF4SSX9F3AERPW5A4GJYM	fuset_01KEEQF4TDBRS857H6BWRKMGNX	locfs_01KEEQF4TVQTYJADBVA2A63EJ2	2026-01-08 03:56:58.075009-08	2026-01-08 03:56:58.075009-08	\N
\.


--
-- Data for Name: merchant; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant (id, email, status, created_at, updated_at, deleted_at, store_id, sales_channel_id, name) FROM stdin;
merchant_01ONBOARDTEST	merchant@test.com	pending	2026-01-27 04:02:41.236113-08	2026-01-27 04:02:41.236113-08	\N	\N	\N	\N
01KG4G1R7V456M8YJCFTA0NVEQ	merchant1@test.com	active	2026-01-29 01:06:18.491-08	2026-01-29 03:14:07.904-08	\N	store_01KG4QBSW9HCD22TYA0TJ71YH4	sc_01KG4QBSWN6P42V5DJNJYK9ARJ	Merchant One
01KG4TQPYVQ3AFRJAEXM5Q8SVZ	merchant_isolation_test@test.com	pending	2026-01-29 04:13:03.835-08	2026-01-29 04:13:03.836-08	\N	\N	\N	Isolation Test Merchant
01KG4V4VJJ9SW0ZZEPQGHR111F	merchant_isolation_test1@test.com	active	2026-01-29 04:20:14.546-08	2026-01-29 04:22:27.088-08	\N	store_01KG4V8WYPNDJTWCG75CDXDT9F	sc_01KG4V8WZY36J6TJWYHNPYVHKW	Isolation Test Merchant
01KG790HGFK9SANV7WMJ4MZZ1G	test1@test.com	pending	2026-01-30 03:01:02.096-08	2026-01-30 03:01:02.096-08	\N	\N	\N	Test Merchant 1
01KG79J21JR0AD4BPANQ7A40K1	test2@test.com	active	2026-01-30 03:10:36.083-08	2026-01-30 03:15:40.279-08	\N	store_01KG79VB13CXM32NDJJ7D92E5Y	sc_01KG79VB2SN48WW9NB1FF1C699	Test Merchant 2
01KG7A0EG7W0FTVPZKMZX5WQ8E	iso1@test.com	active	2026-01-30 03:18:27.591-08	2026-01-30 03:21:43.388-08	\N	store_01KG7A6DNSX33MZ5SYE87AK1WD	sc_01KG7A6DPGJZYW5J2ECHH0DFBH	Isolation Merchant 1
\.


--
-- Data for Name: merchant_auth_identity; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_auth_identity (id, auth_identity_id, merchant_id, created_at) FROM stdin;
\.


--
-- Data for Name: merchant_categories; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_categories (id, sales_channel_id, title, handle, created_at) FROM stdin;
fb12f491-03c8-49c6-9d21-b27c1f9e130e	sc_01KG4V8WZY36J6TJWYHNPYVHKW	Winter	winter	2026-01-30 02:51:16.356104
6d6617a7-0d96-4c9c-bd07-1d1c4124be57	sc_01KG7A6DPGJZYW5J2ECHH0DFBH	Winter1	winter1	2026-01-30 03:31:42.827978
\.


--
-- Data for Name: merchant_category_products; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_category_products (category_id, product_id) FROM stdin;
fb12f491-03c8-49c6-9d21-b27c1f9e130e	prod_01KG4WF9MPK74ZQXBC7N4GAK8A
6d6617a7-0d96-4c9c-bd07-1d1c4124be57	prod_01KG7A810QE7PKNBQ8VVWBS38K
\.


--
-- Data for Name: merchant_collection_products; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_collection_products (collection_id, product_id) FROM stdin;
000fae9f-8959-4548-8a68-9a94e3871d15	prod_01KG4WF9MPK74ZQXBC7N4GAK8A
\.


--
-- Data for Name: merchant_collections; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_collections (id, sales_channel_id, title, handle, description, created_at, updated_at) FROM stdin;
000fae9f-8959-4548-8a68-9a94e3871d15	sc_01KG4V8WZY36J6TJWYHNPYVHKW	Winter	winter	Winter collection	2026-01-30 01:29:01.994002	2026-01-30 01:29:01.994002
\.


--
-- Data for Name: merchant_store; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_store (id, merchant_id, store_id) FROM stdin;
\.


--
-- Data for Name: merchant_user; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchant_user (id, merchant_id, auth_identity_id, role) FROM stdin;
\.


--
-- Data for Name: merchants; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.merchants (id, email, password, created_at) FROM stdin;
\.


--
-- Data for Name: mikro_orm_migrations; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.mikro_orm_migrations (id, name, executed_at) FROM stdin;
1	Migration20240307161216	2026-01-08 03:56:50.756661-08
2	Migration20241210073813	2026-01-08 03:56:50.756661-08
3	Migration20250106142624	2026-01-08 03:56:50.756661-08
4	Migration20250120110820	2026-01-08 03:56:50.756661-08
5	Migration20240307132720	2026-01-08 03:56:50.824544-08
6	Migration20240719123015	2026-01-08 03:56:50.824544-08
7	Migration20241213063611	2026-01-08 03:56:50.824544-08
8	Migration20251010131115	2026-01-08 03:56:50.824544-08
9	InitialSetup20240401153642	2026-01-08 03:56:50.873916-08
10	Migration20240601111544	2026-01-08 03:56:50.873916-08
11	Migration202408271511	2026-01-08 03:56:50.873916-08
12	Migration20241122120331	2026-01-08 03:56:50.873916-08
13	Migration20241125090957	2026-01-08 03:56:50.873916-08
14	Migration20250411073236	2026-01-08 03:56:50.873916-08
15	Migration20250516081326	2026-01-08 03:56:50.873916-08
16	Migration20250910154539	2026-01-08 03:56:50.873916-08
17	Migration20250911092221	2026-01-08 03:56:50.873916-08
18	Migration20250929204438	2026-01-08 03:56:50.873916-08
19	Migration20251008132218	2026-01-08 03:56:50.873916-08
20	Migration20251011090511	2026-01-08 03:56:50.873916-08
21	Migration20230929122253	2026-01-08 03:56:50.96638-08
22	Migration20240322094407	2026-01-08 03:56:50.96638-08
23	Migration20240322113359	2026-01-08 03:56:50.96638-08
24	Migration20240322120125	2026-01-08 03:56:50.96638-08
25	Migration20240626133555	2026-01-08 03:56:50.96638-08
26	Migration20240704094505	2026-01-08 03:56:50.96638-08
27	Migration20241127114534	2026-01-08 03:56:50.96638-08
28	Migration20241127223829	2026-01-08 03:56:50.96638-08
29	Migration20241128055359	2026-01-08 03:56:50.96638-08
30	Migration20241212190401	2026-01-08 03:56:50.96638-08
31	Migration20250408145122	2026-01-08 03:56:50.96638-08
32	Migration20250409122219	2026-01-08 03:56:50.96638-08
33	Migration20251009110625	2026-01-08 03:56:50.96638-08
34	Migration20251112192723	2026-01-08 03:56:50.96638-08
35	Migration20240227120221	2026-01-08 03:56:51.054855-08
36	Migration20240617102917	2026-01-08 03:56:51.054855-08
37	Migration20240624153824	2026-01-08 03:56:51.054855-08
38	Migration20241211061114	2026-01-08 03:56:51.054855-08
39	Migration20250113094144	2026-01-08 03:56:51.054855-08
40	Migration20250120110700	2026-01-08 03:56:51.054855-08
41	Migration20250226130616	2026-01-08 03:56:51.054855-08
42	Migration20250508081510	2026-01-08 03:56:51.054855-08
43	Migration20250828075407	2026-01-08 03:56:51.054855-08
44	Migration20250909083125	2026-01-08 03:56:51.054855-08
45	Migration20250916120552	2026-01-08 03:56:51.054855-08
46	Migration20250917143818	2026-01-08 03:56:51.054855-08
47	Migration20250919122137	2026-01-08 03:56:51.054855-08
48	Migration20251006000000	2026-01-08 03:56:51.054855-08
49	Migration20251015113934	2026-01-08 03:56:51.054855-08
50	Migration20251107050148	2026-01-08 03:56:51.054855-08
51	Migration20240124154000	2026-01-08 03:56:51.124699-08
52	Migration20240524123112	2026-01-08 03:56:51.124699-08
53	Migration20240602110946	2026-01-08 03:56:51.124699-08
54	Migration20241211074630	2026-01-08 03:56:51.124699-08
55	Migration20251010130829	2026-01-08 03:56:51.124699-08
56	Migration20240115152146	2026-01-08 03:56:51.151871-08
57	Migration20240222170223	2026-01-08 03:56:51.163168-08
58	Migration20240831125857	2026-01-08 03:56:51.163168-08
59	Migration20241106085918	2026-01-08 03:56:51.163168-08
60	Migration20241205095237	2026-01-08 03:56:51.163168-08
61	Migration20241216183049	2026-01-08 03:56:51.163168-08
62	Migration20241218091938	2026-01-08 03:56:51.163168-08
63	Migration20250120115059	2026-01-08 03:56:51.163168-08
64	Migration20250212131240	2026-01-08 03:56:51.163168-08
65	Migration20250326151602	2026-01-08 03:56:51.163168-08
66	Migration20250508081553	2026-01-08 03:56:51.163168-08
67	Migration20251017153909	2026-01-08 03:56:51.163168-08
68	Migration20251208130704	2026-01-08 03:56:51.163168-08
69	Migration20240205173216	2026-01-08 03:56:51.214562-08
70	Migration20240624200006	2026-01-08 03:56:51.214562-08
71	Migration20250120110744	2026-01-08 03:56:51.214562-08
72	InitialSetup20240221144943	2026-01-08 03:56:51.789391-08
73	Migration20240604080145	2026-01-08 03:56:51.789391-08
74	Migration20241205122700	2026-01-08 03:56:51.789391-08
75	Migration20251015123842	2026-01-08 03:56:51.789391-08
76	InitialSetup20240227075933	2026-01-08 03:56:51.835902-08
77	Migration20240621145944	2026-01-08 03:56:51.835902-08
78	Migration20241206083313	2026-01-08 03:56:51.835902-08
79	Migration20251202184737	2026-01-08 03:56:51.835902-08
80	Migration20251212161429	2026-01-08 03:56:51.835902-08
81	Migration20240227090331	2026-01-08 03:56:51.866636-08
82	Migration20240710135844	2026-01-08 03:56:51.866636-08
83	Migration20240924114005	2026-01-08 03:56:51.866636-08
84	Migration20241212052837	2026-01-08 03:56:51.866636-08
85	InitialSetup20240228133303	2026-01-08 03:56:51.903806-08
86	Migration20240624082354	2026-01-08 03:56:51.903806-08
87	Migration20240225134525	2026-01-08 03:56:51.91806-08
88	Migration20240806072619	2026-01-08 03:56:51.91806-08
89	Migration20241211151053	2026-01-08 03:56:51.91806-08
90	Migration20250115160517	2026-01-08 03:56:51.91806-08
91	Migration20250120110552	2026-01-08 03:56:51.91806-08
92	Migration20250123122334	2026-01-08 03:56:51.91806-08
93	Migration20250206105639	2026-01-08 03:56:51.91806-08
94	Migration20250207132723	2026-01-08 03:56:51.91806-08
95	Migration20250625084134	2026-01-08 03:56:51.91806-08
96	Migration20250924135437	2026-01-08 03:56:51.91806-08
97	Migration20250929124701	2026-01-08 03:56:51.91806-08
98	Migration20240219102530	2026-01-08 03:56:51.983541-08
99	Migration20240604100512	2026-01-08 03:56:51.983541-08
100	Migration20240715102100	2026-01-08 03:56:51.983541-08
101	Migration20240715174100	2026-01-08 03:56:51.983541-08
102	Migration20240716081800	2026-01-08 03:56:51.983541-08
103	Migration20240801085921	2026-01-08 03:56:51.983541-08
104	Migration20240821164505	2026-01-08 03:56:51.983541-08
105	Migration20240821170920	2026-01-08 03:56:51.983541-08
106	Migration20240827133639	2026-01-08 03:56:51.983541-08
107	Migration20240902195921	2026-01-08 03:56:51.983541-08
108	Migration20240913092514	2026-01-08 03:56:51.983541-08
109	Migration20240930122627	2026-01-08 03:56:51.983541-08
110	Migration20241014142943	2026-01-08 03:56:51.983541-08
111	Migration20241106085223	2026-01-08 03:56:51.983541-08
112	Migration20241129124827	2026-01-08 03:56:51.983541-08
113	Migration20241217162224	2026-01-08 03:56:51.983541-08
114	Migration20250326151554	2026-01-08 03:56:51.983541-08
115	Migration20250522181137	2026-01-08 03:56:51.983541-08
116	Migration20250702095353	2026-01-08 03:56:51.983541-08
117	Migration20250704120229	2026-01-08 03:56:51.983541-08
118	Migration20250910130000	2026-01-08 03:56:51.983541-08
119	Migration20251016160403	2026-01-08 03:56:51.983541-08
120	Migration20251016182939	2026-01-08 03:56:51.983541-08
121	Migration20251017155709	2026-01-08 03:56:51.983541-08
122	Migration20251114100559	2026-01-08 03:56:51.983541-08
123	Migration20251125164002	2026-01-08 03:56:51.983541-08
124	Migration20251210112909	2026-01-08 03:56:51.983541-08
125	Migration20251210112924	2026-01-08 03:56:51.983541-08
126	Migration20251225120947	2026-01-08 03:56:51.983541-08
127	Migration20250717162007	2026-01-08 03:56:52.123545-08
128	Migration20240205025928	2026-01-08 03:56:52.139943-08
129	Migration20240529080336	2026-01-08 03:56:52.139943-08
130	Migration20241202100304	2026-01-08 03:56:52.139943-08
131	Migration20240214033943	2026-01-08 03:56:52.173863-08
132	Migration20240703095850	2026-01-08 03:56:52.173863-08
133	Migration20241202103352	2026-01-08 03:56:52.173863-08
134	Migration20240311145700_InitialSetupMigration	2026-01-08 03:56:52.195232-08
135	Migration20240821170957	2026-01-08 03:56:52.195232-08
136	Migration20240917161003	2026-01-08 03:56:52.195232-08
137	Migration20241217110416	2026-01-08 03:56:52.195232-08
138	Migration20250113122235	2026-01-08 03:56:52.195232-08
139	Migration20250120115002	2026-01-08 03:56:52.195232-08
140	Migration20250822130931	2026-01-08 03:56:52.195232-08
141	Migration20250825132614	2026-01-08 03:56:52.195232-08
142	Migration20251114133146	2026-01-08 03:56:52.195232-08
143	Migration20240509083918_InitialSetupMigration	2026-01-08 03:56:52.2665-08
144	Migration20240628075401	2026-01-08 03:56:52.2665-08
145	Migration20240830094712	2026-01-08 03:56:52.2665-08
146	Migration20250120110514	2026-01-08 03:56:52.2665-08
147	Migration20251028172715	2026-01-08 03:56:52.2665-08
148	Migration20251121123942	2026-01-08 03:56:52.2665-08
149	Migration20251121150408	2026-01-08 03:56:52.2665-08
150	Migration20231228143900	2026-01-08 03:56:52.332815-08
151	Migration20241206101446	2026-01-08 03:56:52.332815-08
152	Migration20250128174331	2026-01-08 03:56:52.332815-08
153	Migration20250505092459	2026-01-08 03:56:52.332815-08
154	Migration20250819104213	2026-01-08 03:56:52.332815-08
155	Migration20250819110924	2026-01-08 03:56:52.332815-08
156	Migration20250908080305	2026-01-08 03:56:52.332815-08
157	Migration20260120071824	2026-01-19 23:18:35.13327-08
158	Migration20260120074848	2026-01-19 23:48:51.059378-08
159	Migration20260120081003	2026-01-20 00:10:05.814685-08
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.notification (id, "to", channel, template, data, trigger_type, resource_id, resource_type, receiver_id, original_notification_id, idempotency_key, external_id, provider_id, created_at, updated_at, deleted_at, status, "from", provider_data) FROM stdin;
\.


--
-- Data for Name: notification_provider; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.notification_provider (id, handle, name, is_enabled, channels, created_at, updated_at, deleted_at) FROM stdin;
local	local	local	t	{feed}	2026-01-08 03:56:53.606-08	2026-01-08 03:56:53.606-08	\N
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public."order" (id, region_id, display_id, customer_id, version, sales_channel_id, status, is_draft_order, email, currency_code, shipping_address_id, billing_address_id, no_notification, metadata, created_at, updated_at, deleted_at, canceled_at, custom_display_id, locale) FROM stdin;
order_01KEV7E9AG7W2HCKCPW42DSA1M	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	5	cus_01KERPGC66DX42ACMBAYTTR5K7	1	sc_01KEGW7Y54E127T0FXHV7DA7KX	pending	f	aineleslie@gmail.com	eur	ordaddr_01KEV7E9AE2M5WMMH3XHTJHHHF	\N	f	\N	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	\N	\N	\N
order_01KEVD1K571S6FMSHNFB9R39M6	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	6	cus_01KERPGC66DX42ACMBAYTTR5K7	1	sc_01KEGW7Y54E127T0FXHV7DA7KX	pending	f	aineleslie@gmail.com	eur	ordaddr_01KEVD1K54H6SG2H189RZ6X374	\N	f	\N	2026-01-13 02:04:55.848-08	2026-01-13 02:04:55.848-08	\N	\N	\N	\N
order_01KEVFZR5YQ1NCSHMMAT7R7H52	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	7	cus_01KERPGC66DX42ACMBAYTTR5K7	1	sc_01KEGW7Y54E127T0FXHV7DA7KX	pending	f	aineleslie@gmail.com	eur	ordaddr_01KEVFZR5WVJ0EHNH7X74PG1JN	\N	f	\N	2026-01-13 02:56:21.182-08	2026-01-13 02:56:21.182-08	\N	\N	\N	\N
order_01KEVKHCH1W6QBXJ3955TEBKYW	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	8	cus_01KERPGC66DX42ACMBAYTTR5K7	1	sc_01KEGW7Y54E127T0FXHV7DA7KX	pending	f	aineleslie@gmail.com	eur	ordaddr_01KEVKHCGTJP1YXRZ2717BMEW5	\N	f	\N	2026-01-13 03:58:24.803-08	2026-01-13 03:58:24.803-08	\N	\N	\N	\N
order_01KEVMFJ5KECS35MGFCATFAWM3	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	9	cus_01KERPGC66DX42ACMBAYTTR5K7	2	sc_01KEGW7Y54E127T0FXHV7DA7KX	pending	f	aineleslie@gmail.com	eur	ordaddr_01KEVMFJ5JVFPKKV25PE0ZTHAT	\N	f	\N	2026-01-13 04:14:53.621-08	2026-01-19 03:51:49.212-08	\N	\N	\N	\N
\.


--
-- Data for Name: order_address; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
ordaddr_01KEV7E9AE2M5WMMH3XHTJHHHF	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 00:24:30.102-08	2026-01-13 00:24:30.102-08	\N
ordaddr_01KEVD1K54H6SG2H189RZ6X374	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 01:44:17.934-08	2026-01-13 01:44:17.934-08	\N
ordaddr_01KEVFZR5WVJ0EHNH7X74PG1JN	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 02:56:15.639-08	2026-01-13 02:56:15.639-08	\N
ordaddr_01KEVKHCGTJP1YXRZ2717BMEW5	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 03:14:23.663-08	2026-01-13 03:14:23.663-08	\N
ordaddr_01KEVMFJ5JVFPKKV25PE0ZTHAT	\N	\N	john	doe	123 Main St	\N	Kampala	de	\N	10115	\N	\N	2026-01-13 04:14:34.015-08	2026-01-13 04:14:34.015-08	\N
\.


--
-- Data for Name: order_cart; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_cart (order_id, cart_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KEV5K32Z4168CC67XVDZPQNB	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	ordercart_01KEV5K3DHJZK432BMEE69P17D	2026-01-12 23:54:40.92919-08	2026-01-12 23:54:41.809-08	2026-01-12 23:54:41.809-08
order_01KEV5M80NRXP3T2Y43W3W7H9S	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	ordercart_01KEV5M825GVKFBPE2AACKYS88	2026-01-12 23:55:18.469246-08	2026-01-12 23:55:18.945-08	2026-01-12 23:55:18.945-08
order_01KEV62J995TTME8AD9K4X07J8	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	ordercart_01KEV62JC417ER17857EDB10V9	2026-01-13 00:03:07.780239-08	2026-01-13 00:03:08.67-08	2026-01-13 00:03:08.67-08
order_01KEV62PB2Q1KM8NJZ8SY8R008	cart_01KEH65CGXQ5HD4JJVRTRH1GAS	ordercart_01KEV62PC9YKKJ49ZHG7GAV8EX	2026-01-13 00:03:11.881867-08	2026-01-13 00:03:12.304-08	2026-01-13 00:03:12.304-08
order_01KEV7E9AG7W2HCKCPW42DSA1M	cart_01KEV77ZFA43Z3TVTD9YC0SR71	ordercart_01KEV7E9DRV0VQ3DBSBC6YWN93	2026-01-13 00:27:00.408306-08	2026-01-13 00:27:00.408306-08	\N
order_01KEVD1K571S6FMSHNFB9R39M6	cart_01KEVBTFT37AGJBNYXSTAFXHWY	ordercart_01KEVD1K7DM191TGBQMKP9ES1R	2026-01-13 02:04:55.917263-08	2026-01-13 02:04:55.917263-08	\N
order_01KEVFZR5YQ1NCSHMMAT7R7H52	cart_01KEVFYRDHEMVMXRZEQ6FPSYCN	ordercart_01KEVFZR7S5BAC0FQ9KSVC6HX1	2026-01-13 02:56:21.240608-08	2026-01-13 02:56:21.240608-08	\N
order_01KEVKHCH1W6QBXJ3955TEBKYW	cart_01KEVFZS3KB62B5MFTNW7HZ9XB	ordercart_01KEVKHCND7VCJAEV2J7FPEEER	2026-01-13 03:58:24.940552-08	2026-01-13 03:58:24.940552-08	\N
order_01KEVMFJ5KECS35MGFCATFAWM3	cart_01KEVME3K2Y1J01GTHWC19HDNP	ordercart_01KEVMFJN3FKND2MVFSZ44E5CV	2026-01-13 04:14:54.11559-08	2026-01-13 04:14:54.11559-08	\N
\.


--
-- Data for Name: order_change; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_change (id, order_id, version, description, status, internal_note, created_by, requested_by, requested_at, confirmed_by, confirmed_at, declined_by, declined_reason, metadata, declined_at, canceled_by, canceled_at, created_at, updated_at, change_type, deleted_at, return_id, claim_id, exchange_id, carry_over_promotions) FROM stdin;
ordch_01KFB1HM4XB7XWE937BG0RAXSP	order_01KEVMFJ5KECS35MGFCATFAWM3	2	\N	confirmed	\N	\N	\N	\N	\N	2026-01-19 03:51:49.181-08	\N	\N	\N	\N	\N	\N	2026-01-19 03:51:49.15-08	2026-01-19 03:51:49.187-08	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: order_change_action; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_change_action (id, order_id, version, ordering, order_change_id, reference, reference_id, action, details, amount, raw_amount, internal_note, applied, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
ordchact_01KFB1HM4XN39J3T07G7AA95ZX	order_01KEVMFJ5KECS35MGFCATFAWM3	2	1	ordch_01KFB1HM4XB7XWE937BG0RAXSP	fulfillment	ful_01KFB1HM1JNZ6GDVQPBJ9YJ17S	FULFILL_ITEM	{"quantity": 3, "reference_id": "ordli_01KEVMFJ5M4G4EPXK9MSAZKC9B"}	\N	\N	\N	t	2026-01-19 03:51:49.15-08	2026-01-19 03:51:49.212-08	\N	\N	\N	\N
\.


--
-- Data for Name: order_claim; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_claim (id, order_id, return_id, order_version, display_id, type, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_claim_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_claim_item (id, claim_id, item_id, is_additional_item, reason, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_claim_item_image; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_claim_item_image (id, claim_item_id, url, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_credit_line; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_credit_line (id, order_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: order_exchange; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_exchange (id, order_id, return_id, order_version, display_id, no_notification, allow_backorder, difference_due, raw_difference_due, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_exchange_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_exchange_item (id, exchange_id, item_id, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_fulfillment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_fulfillment (order_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KEVMFJ5KECS35MGFCATFAWM3	ful_01KFB1HM1JNZ6GDVQPBJ9YJ17S	ordful_01KFB1HM50DD17FAVAKV2MP7GQ	2026-01-19 03:51:49.148943-08	2026-01-19 03:51:49.148943-08	\N
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_item (id, order_id, version, item_id, quantity, raw_quantity, fulfilled_quantity, raw_fulfilled_quantity, shipped_quantity, raw_shipped_quantity, return_requested_quantity, raw_return_requested_quantity, return_received_quantity, raw_return_received_quantity, return_dismissed_quantity, raw_return_dismissed_quantity, written_off_quantity, raw_written_off_quantity, metadata, created_at, updated_at, deleted_at, delivered_quantity, raw_delivered_quantity, unit_price, raw_unit_price, compare_at_unit_price, raw_compare_at_unit_price) FROM stdin;
orditem_01KEV7E9AH8D86352NEY072NPZ	order_01KEV7E9AG7W2HCKCPW42DSA1M	1	ordli_01KEV7E9AHNM1PY5724FKVQ7GC	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KEV7E9AHS6H9D708R0RZHZWT	order_01KEV7E9AG7W2HCKCPW42DSA1M	1	ordli_01KEV7E9AH2S3ASBBBEQG63BGN	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KEVD1K58SJ5ZSSHWFH6KPSH1	order_01KEVD1K571S6FMSHNFB9R39M6	1	ordli_01KEVD1K57EA6DVH6KJ2XJJT7F	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-13 02:04:55.848-08	2026-01-13 02:04:55.848-08	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KEVFZR5YZ8WTFMEW6QH755NX	order_01KEVFZR5YQ1NCSHMMAT7R7H52	1	ordli_01KEVFZR5YXB9V8A9Y9WV18XC0	4	{"value": "4", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-13 02:56:21.182-08	2026-01-13 02:56:21.182-08	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KEVKHCH22AN045H1XS56CSH7	order_01KEVKHCH1W6QBXJ3955TEBKYW	1	ordli_01KEVKHCH2A693QRK1GEGA6FTX	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-13 03:58:24.804-08	2026-01-13 03:58:24.804-08	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KEVMFJ5MF7TMTHQ2T02CGRW6	order_01KEVMFJ5KECS35MGFCATFAWM3	1	ordli_01KEVMFJ5M4G4EPXK9MSAZKC9B	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-13 04:14:53.621-08	2026-01-13 04:14:53.621-08	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KFB1HM6QF34AM4208QXC11JM	order_01KEVMFJ5KECS35MGFCATFAWM3	2	ordli_01KEVMFJ5M4G4EPXK9MSAZKC9B	3	{"value": "3", "precision": 20}	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-01-19 03:51:49.212-08	2026-01-19 03:51:49.212-08	\N	0	{"value": "0", "precision": 20}	10	{"value": "10", "precision": 20}	\N	\N
\.


--
-- Data for Name: order_line_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_line_item (id, totals_id, title, subtitle, thumbnail, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, is_custom_price, product_type_id, is_giftcard) FROM stdin;
ordli_01KEV7E9AHNM1PY5724FKVQ7GC	\N	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	f	\N	f
ordli_01KEV7E9AH2S3ASBBBEQG63BGN	\N	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	f	\N	f
ordli_01KEVD1K57EA6DVH6KJ2XJJT7F	\N	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 02:04:55.848-08	2026-01-13 02:04:55.848-08	\N	f	\N	f
ordli_01KEVFZR5YXB9V8A9Y9WV18XC0	\N	Medusa T-Shirt	S / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	variant_01KEEQF506EPEBHDBDGZ4GAS91	prod_01KEEQF4YGMJFH623CYXBZS52J	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	haircare	t-shirt	SHIRT-S-BLACK	\N	S / Black	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 02:56:21.182-08	2026-01-13 02:56:21.182-08	\N	f	\N	f
ordli_01KEVKHCH2A693QRK1GEGA6FTX	\N	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 03:58:24.804-08	2026-01-13 03:58:24.804-08	\N	f	\N	f
ordli_01KEVMFJ5M4G4EPXK9MSAZKC9B	\N	Medusa Sweatshirt	M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	variant_01KEEQF50754S3MGR0F3BEWGCV	prod_01KEEQF4YGN7BYQDRM1WQ4BMD8	Medusa Sweatshirt	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	\N	\N	haircare	sweatshirt	SWEATSHIRT-M	\N	M	\N	t	t	f	\N	\N	10	{"value": "10", "precision": 20}	{}	2026-01-13 04:14:53.621-08	2026-01-13 04:14:53.621-08	\N	f	\N	f
\.


--
-- Data for Name: order_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, item_id, deleted_at, is_tax_inclusive, version) FROM stdin;
\.


--
-- Data for Name: order_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_line_item_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_payment_collection; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_payment_collection (order_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KEV5K32Z4168CC67XVDZPQNB	pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	ordpay_01KEV5K3DJJ0S709CJWY474VTM	2026-01-12 23:54:40.929216-08	2026-01-12 23:54:41.81-08	2026-01-12 23:54:41.81-08
order_01KEV5M80NRXP3T2Y43W3W7H9S	pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	ordpay_01KEV5M825C4KHYXMBF9JJJ1NM	2026-01-12 23:55:18.469292-08	2026-01-12 23:55:18.946-08	2026-01-12 23:55:18.945-08
order_01KEV62J995TTME8AD9K4X07J8	pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	ordpay_01KEV62JC4B86X6CF2GH551P3N	2026-01-13 00:03:07.780264-08	2026-01-13 00:03:08.672-08	2026-01-13 00:03:08.672-08
order_01KEV62PB2Q1KM8NJZ8SY8R008	pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	ordpay_01KEV62PCAMYP5F9ZVZJ500XD7	2026-01-13 00:03:11.881873-08	2026-01-13 00:03:12.305-08	2026-01-13 00:03:12.305-08
order_01KEV7E9AG7W2HCKCPW42DSA1M	pay_col_01KEV7A1KK5HZ1JYETWQTBYB3B	ordpay_01KEV7E9DSRRZCS8KNQZQG8BK7	2026-01-13 00:27:00.408365-08	2026-01-13 00:27:00.408365-08	\N
order_01KEVD1K571S6FMSHNFB9R39M6	pay_col_01KEVBVXX2ZR0SRPZJNATWJX0V	ordpay_01KEVD1K7DEW800FFKJA7MPKWR	2026-01-13 02:04:55.917283-08	2026-01-13 02:04:55.917283-08	\N
order_01KEVFZR5YQ1NCSHMMAT7R7H52	pay_col_01KEVFZR2BRGNVC9S73JDJ141Y	ordpay_01KEVFZR7SQ00AXBTR95HB3Z21	2026-01-13 02:56:21.240618-08	2026-01-13 02:56:21.240618-08	\N
order_01KEVKHCH1W6QBXJ3955TEBKYW	pay_col_01KEVH0YPRJPZD7CWKWW30YQJT	ordpay_01KEVKHCNE1KR3XJDH8QBR2M4R	2026-01-13 03:58:24.940551-08	2026-01-13 03:58:24.940551-08	\N
order_01KEVMFJ5KECS35MGFCATFAWM3	pay_col_01KEVMFFEDAQDX3DTVYX7ZPH0S	ordpay_01KEVMFJN48Z99820S04Q4VF5X	2026-01-13 04:14:54.115646-08	2026-01-13 04:14:54.115646-08	\N
\.


--
-- Data for Name: order_promotion; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_promotion (order_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_shipping (id, order_id, version, shipping_method_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
ordspmv_01KEV7E9AG1FQM6BKGJBW91JTM	order_01KEV7E9AG7W2HCKCPW42DSA1M	1	ordsm_01KEV7E9AGX2JHB5PKPHAGETC9	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	\N	\N	\N
ordspmv_01KEVD1K57MPESX2H37EN96E8S	order_01KEVD1K571S6FMSHNFB9R39M6	1	ordsm_01KEVD1K57HS4Q8KG7CW38ZCM3	2026-01-13 02:04:55.848-08	2026-01-13 02:04:55.848-08	\N	\N	\N	\N
ordspmv_01KEVFZR5X4MNAYTZE4EVMYXR7	order_01KEVFZR5YQ1NCSHMMAT7R7H52	1	ordsm_01KEVFZR5X45MMYC010FCXGXSX	2026-01-13 02:56:21.183-08	2026-01-13 02:56:21.183-08	\N	\N	\N	\N
ordspmv_01KEVKHCH11V6HHZWTMAF4BDG5	order_01KEVKHCH1W6QBXJ3955TEBKYW	1	ordsm_01KEVKHCH1YMBMRSEK4ABRAKBJ	2026-01-13 03:58:24.804-08	2026-01-13 03:58:24.804-08	\N	\N	\N	\N
ordspmv_01KEVMFJ5KWBDWVSSKDTQTKABK	order_01KEVMFJ5KECS35MGFCATFAWM3	1	ordsm_01KEVMFJ5KFG36M3G1BT5920Y1	2026-01-13 04:14:53.621-08	2026-01-13 04:14:53.621-08	\N	\N	\N	\N
ordspmv_01KFB1HM6R5TPNRX5H8A575B3T	order_01KEVMFJ5KECS35MGFCATFAWM3	2	ordsm_01KEVMFJ5KFG36M3G1BT5920Y1	2026-01-13 04:14:53.621-08	2026-01-13 04:14:53.621-08	\N	\N	\N	\N
\.


--
-- Data for Name: order_shipping_method; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_shipping_method (id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at, is_custom_amount) FROM stdin;
ordsm_01KEV7E9AGX2JHB5PKPHAGETC9	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N	f
ordsm_01KEVD1K57HS4Q8KG7CW38ZCM3	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 02:04:55.848-08	2026-01-13 02:04:55.848-08	\N	f
ordsm_01KEVFZR5X45MMYC010FCXGXSX	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 02:56:21.183-08	2026-01-13 02:56:21.183-08	\N	f
ordsm_01KEVKHCH1YMBMRSEK4ABRAKBJ	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 03:58:24.804-08	2026-01-13 03:58:24.804-08	\N	f
ordsm_01KEVMFJ5KFG36M3G1BT5920Y1	Standard Shipping	\N	10	{"value": "10", "precision": 20}	f	so_01KEEQF4VJRE372E61E8K0FZT3	{}	\N	2026-01-13 04:14:53.621-08	2026-01-13 04:14:53.621-08	\N	f
\.


--
-- Data for Name: order_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_shipping_method_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_summary; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_summary (id, order_id, version, totals, created_at, updated_at, deleted_at) FROM stdin;
ordsum_01KEV7E9AFC13WJPSD7A0RH611	order_01KEV7E9AG7W2HCKCPW42DSA1M	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 30, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 30, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 30, "original_order_total": 30, "raw_accounting_total": {"value": "30", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "30", "precision": 20}, "raw_current_order_total": {"value": "30", "precision": 20}, "raw_original_order_total": {"value": "30", "precision": 20}}	2026-01-13 00:27:00.306-08	2026-01-13 00:27:00.306-08	\N
ordsum_01KEVD1K57Z5AYJZJAPZ3M4Y55	order_01KEVD1K571S6FMSHNFB9R39M6	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 20, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 20, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 20, "original_order_total": 20, "raw_accounting_total": {"value": "20", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "20", "precision": 20}, "raw_current_order_total": {"value": "20", "precision": 20}, "raw_original_order_total": {"value": "20", "precision": 20}}	2026-01-13 02:04:55.848-08	2026-01-13 02:04:55.848-08	\N
ordsum_01KEVFZR5X8EZXNR1WQ1Y9YAWX	order_01KEVFZR5YQ1NCSHMMAT7R7H52	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 50, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 50, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 50, "original_order_total": 50, "raw_accounting_total": {"value": "50", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "50", "precision": 20}, "raw_current_order_total": {"value": "50", "precision": 20}, "raw_original_order_total": {"value": "50", "precision": 20}}	2026-01-13 02:56:21.183-08	2026-01-13 02:56:21.183-08	\N
ordsum_01KEVKHCGZTNYV9CDR55MAAK8H	order_01KEVKHCH1W6QBXJ3955TEBKYW	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 40, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 40, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 40, "original_order_total": 40, "raw_accounting_total": {"value": "40", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "40", "precision": 20}, "raw_current_order_total": {"value": "40", "precision": 20}, "raw_original_order_total": {"value": "40", "precision": 20}}	2026-01-13 03:58:24.804-08	2026-01-13 03:58:24.804-08	\N
ordsum_01KEVMFJ5KD0RNC39C85YKYNA8	order_01KEVMFJ5KECS35MGFCATFAWM3	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 40, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 40, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 40, "original_order_total": 40, "raw_accounting_total": {"value": "40", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "40", "precision": 20}, "raw_current_order_total": {"value": "40", "precision": 20}, "raw_original_order_total": {"value": "40", "precision": 20}}	2026-01-13 04:14:53.621-08	2026-01-13 04:14:53.621-08	\N
ordsum_01KFB1HM6Q41GB9JDNZYC4K9MN	order_01KEVMFJ5KECS35MGFCATFAWM3	2	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 40, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 40, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 40, "original_order_total": 40, "raw_accounting_total": {"value": "40", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "40", "precision": 20}, "raw_current_order_total": {"value": "40", "precision": 20}, "raw_original_order_total": {"value": "40", "precision": 20}}	2026-01-19 03:51:49.212-08	2026-01-19 03:51:49.212-08	\N
\.


--
-- Data for Name: order_transaction; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.order_transaction (id, order_id, version, amount, raw_amount, currency_code, reference, reference_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.payment (id, amount, raw_amount, currency_code, provider_id, data, created_at, updated_at, deleted_at, captured_at, canceled_at, payment_collection_id, payment_session_id, metadata) FROM stdin;
pay_01KEV7E9ENK580PKCNJ56FN5DQ	30	{"value": "30", "precision": 20}	eur	pp_system_default	{}	2026-01-13 00:27:00.437-08	2026-01-13 00:27:00.437-08	\N	\N	\N	pay_col_01KEV7A1KK5HZ1JYETWQTBYB3B	payses_01KEV7C6CE8EQGYJSBWYYQ6T9D	\N
pay_01KEVD1K82GE3PN25B2JMPQEN6	20	{"value": "20", "precision": 20}	eur	pp_system_default	{}	2026-01-13 02:04:55.938-08	2026-01-13 02:04:55.938-08	\N	\N	\N	pay_col_01KEVBVXX2ZR0SRPZJNATWJX0V	payses_01KEVD1K173J2K2DN6NCRJSBW3	\N
pay_01KEVFZR866CPDEEG39KQV7059	50	{"value": "50", "precision": 20}	eur	pp_system_default	{}	2026-01-13 02:56:21.255-08	2026-01-13 02:56:21.255-08	\N	\N	\N	pay_col_01KEVFZR2BRGNVC9S73JDJ141Y	payses_01KEVFZR3EDCEG412HKJPVNPBA	\N
pay_01KEVKHD2XPA5Z0YHA4CKZF3YQ	40	{"value": "40", "precision": 20}	eur	pp_stripe_stripe	{"id": "pi_3Sp6EsLguX0AFlBv0YG1tyeA", "amount": 4000, "object": "payment_intent", "review": null, "source": null, "status": "requires_capture", "created": 1768305502, "invoice": null, "currency": "eur", "customer": null, "livemode": false, "metadata": {"session_id": "payses_01KEVKH9YFTP3D0A5EGN399FQK"}, "shipping": null, "processing": null, "application": null, "canceled_at": null, "description": null, "next_action": null, "on_behalf_of": null, "client_secret": "pi_3Sp6EsLguX0AFlBv0YG1tyeA_secret_DQ93yUeQoqEolUuUMzbnfcb2N", "latest_charge": "ch_3Sp6EsLguX0AFlBv02PjWrXs", "receipt_email": null, "transfer_data": null, "amount_details": {"tip": {}}, "capture_method": "manual", "payment_method": "pm_1Sp6EtLguX0AFlBvKHJS8ctn", "transfer_group": null, "amount_received": 0, "customer_account": null, "amount_capturable": 4000, "last_payment_error": null, "setup_future_usage": null, "cancellation_reason": null, "confirmation_method": "automatic", "payment_method_types": ["card", "link"], "statement_descriptor": null, "application_fee_amount": null, "payment_method_options": {"card": {"network": null, "installments": null, "mandate_options": null, "request_three_d_secure": "automatic"}, "link": {"persistent_token": null}}, "automatic_payment_methods": {"enabled": true, "allow_redirects": "always"}, "statement_descriptor_suffix": null, "excluded_payment_method_types": null, "payment_method_configuration_details": {"id": "pmc_1Sok2TLguX0AFlBvNRKlXO49", "parent": null}}	2026-01-13 03:58:25.374-08	2026-01-13 03:58:25.374-08	\N	\N	\N	pay_col_01KEVH0YPRJPZD7CWKWW30YQJT	payses_01KEVKH9YFTP3D0A5EGN399FQK	\N
pay_01KEVMFK5463XX4HH9JPV35Z5X	40	{"value": "40", "precision": 20}	eur	pp_stripe_stripe	{"id": "pi_3Sp6UpLbn2sf8BPY1GQMBu0x", "amount": 4000, "object": "payment_intent", "review": null, "source": null, "status": "requires_capture", "created": 1768306491, "invoice": null, "currency": "eur", "customer": null, "livemode": false, "metadata": {"session_id": "payses_01KEVMFFFRG772RRGDTR8DHBND"}, "shipping": null, "processing": null, "application": null, "canceled_at": null, "description": null, "next_action": null, "on_behalf_of": null, "client_secret": "pi_3Sp6UpLbn2sf8BPY1GQMBu0x_secret_TjcP45CgbXzmrcerXM9Dv22CU", "latest_charge": "ch_3Sp6UpLbn2sf8BPY1CNuQ89I", "receipt_email": null, "transfer_data": null, "amount_details": {"tip": {}}, "capture_method": "manual", "payment_method": "pm_1Sp6UqLbn2sf8BPYwDFxZVS2", "transfer_group": null, "amount_received": 0, "customer_account": null, "amount_capturable": 4000, "last_payment_error": null, "setup_future_usage": null, "cancellation_reason": null, "confirmation_method": "automatic", "payment_method_types": ["card", "link"], "statement_descriptor": null, "application_fee_amount": null, "payment_method_options": {"card": {"network": null, "installments": null, "mandate_options": null, "request_three_d_secure": "automatic"}, "link": {"persistent_token": null}}, "automatic_payment_methods": {"enabled": true, "allow_redirects": "always"}, "statement_descriptor_suffix": null, "excluded_payment_method_types": null, "payment_method_configuration_details": {"id": "pmc_1ReaVwLbn2sf8BPY83hQt4lZ", "parent": null}}	2026-01-13 04:14:54.628-08	2026-01-13 04:14:54.628-08	\N	\N	\N	pay_col_01KEVMFFEDAQDX3DTVYX7ZPH0S	payses_01KEVMFFFRG772RRGDTR8DHBND	\N
\.


--
-- Data for Name: payment_collection; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.payment_collection (id, currency_code, amount, raw_amount, authorized_amount, raw_authorized_amount, captured_amount, raw_captured_amount, refunded_amount, raw_refunded_amount, created_at, updated_at, deleted_at, completed_at, status, metadata) FROM stdin;
pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	eur	80	{"value": "80", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-01-12 23:47:46.691-08	2026-01-12 23:47:46.691-08	\N	\N	not_paid	\N
pay_col_01KEV6SQJAD28Z1QFVQDPGBN87	eur	50	{"value": "50", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-01-13 00:15:46.763-08	2026-01-13 00:15:46.763-08	\N	\N	not_paid	\N
pay_col_01KEV7A1KK5HZ1JYETWQTBYB3B	eur	30	{"value": "30", "precision": 20}	30	{"value": "30", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-01-13 00:24:41.331-08	2026-01-13 00:27:00.49-08	\N	\N	authorized	\N
pay_col_01KEVB4E6SVREHCXAXNQHP2HD9	eur	40	{"value": "40", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-01-13 01:31:31.93-08	2026-01-13 01:31:31.93-08	\N	\N	not_paid	\N
pay_col_01KEVBSZR76YR10Q0P5CJ61Z29	eur	70	{"value": "70", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-01-13 01:43:18.023-08	2026-01-13 01:43:18.023-08	\N	\N	not_paid	\N
pay_col_01KEVBVXX2ZR0SRPZJNATWJX0V	eur	20	{"value": "20", "precision": 20}	20	{"value": "20", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-01-13 01:44:21.666-08	2026-01-13 02:04:55.971-08	\N	\N	authorized	\N
pay_col_01KEVFZR2BRGNVC9S73JDJ141Y	eur	50	{"value": "50", "precision": 20}	50	{"value": "50", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-01-13 02:56:21.067-08	2026-01-13 02:56:21.275-08	\N	\N	authorized	\N
pay_col_01KEVH0YPRJPZD7CWKWW30YQJT	eur	40	{"value": "40", "precision": 20}	40	{"value": "40", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-01-13 03:14:29.208-08	2026-01-13 03:58:25.425-08	\N	\N	authorized	\N
pay_col_01KEVMFFEDAQDX3DTVYX7ZPH0S	eur	40	{"value": "40", "precision": 20}	40	{"value": "40", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-01-13 04:14:50.83-08	2026-01-13 04:14:54.681-08	\N	\N	authorized	\N
\.


--
-- Data for Name: payment_collection_payment_providers; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.payment_collection_payment_providers (payment_collection_id, payment_provider_id) FROM stdin;
\.


--
-- Data for Name: payment_provider; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.payment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
pp_system_default	t	2026-01-08 03:56:53.601-08	2026-01-08 03:56:53.601-08	\N
pp_stripe-oxxo_stripe	t	2026-01-12 23:21:47.853-08	2026-01-12 23:21:47.853-08	\N
pp_stripe-promptpay_stripe	t	2026-01-12 23:21:47.853-08	2026-01-12 23:21:47.853-08	\N
pp_stripe-przelewy24_stripe	t	2026-01-12 23:21:47.853-08	2026-01-12 23:21:47.853-08	\N
pp_stripe_stripe	t	2026-01-12 23:21:47.854-08	2026-01-12 23:21:47.854-08	\N
pp_stripe-ideal_stripe	t	2026-01-12 23:21:47.854-08	2026-01-12 23:21:47.854-08	\N
pp_stripe-giropay_stripe	t	2026-01-12 23:21:47.854-08	2026-01-12 23:21:47.854-08	\N
pp_stripe-blik_stripe	t	2026-01-12 23:21:47.854-08	2026-01-12 23:21:47.854-08	\N
pp_stripe-bancontact_stripe	t	2026-01-12 23:21:47.854-08	2026-01-12 23:21:47.854-08	\N
\.


--
-- Data for Name: payment_session; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.payment_session (id, currency_code, amount, raw_amount, provider_id, data, context, status, authorized_at, payment_collection_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
payses_01KEV5D8D2G8RBEK6H3CPKMJ38	eur	80	{"value": "80", "precision": 20}	pp_stripe_stripe	{"id": "pi_3Sp2NxLguX0AFlBv0IV8fb47", "amount": 8000, "object": "payment_intent", "review": null, "source": null, "status": "requires_payment_method", "created": 1768290689, "invoice": null, "currency": "eur", "customer": null, "livemode": false, "metadata": {"session_id": "payses_01KEV5D8D2G8RBEK6H3CPKMJ38"}, "shipping": null, "processing": null, "application": null, "canceled_at": null, "description": null, "next_action": null, "on_behalf_of": null, "client_secret": "pi_3Sp2NxLguX0AFlBv0IV8fb47_secret_c9mjqrfJinKvXGQcML4k50Kfp", "latest_charge": null, "receipt_email": null, "transfer_data": null, "amount_details": {"tip": {}}, "capture_method": "manual", "payment_method": null, "transfer_group": null, "amount_received": 0, "customer_account": null, "amount_capturable": 0, "last_payment_error": null, "setup_future_usage": null, "cancellation_reason": null, "confirmation_method": "automatic", "payment_method_types": ["card", "link"], "statement_descriptor": null, "application_fee_amount": null, "payment_method_options": {"card": {"network": null, "installments": null, "mandate_options": null, "request_three_d_secure": "automatic"}, "link": {"persistent_token": null}}, "automatic_payment_methods": {"enabled": true, "allow_redirects": "always"}, "statement_descriptor_suffix": null, "excluded_payment_method_types": null, "payment_method_configuration_details": {"id": "pmc_1Sok2TLguX0AFlBvNRKlXO49", "parent": null}}	{}	pending	\N	pay_col_01KEV56EW2KXQXVQC0HH1PHFQT	{}	2026-01-12 23:51:29.442-08	2026-01-12 23:51:29.898-08	\N
payses_01KEV7JD358Q1HQ78S04Z1NWFD	eur	30	{"value": "30", "precision": 20}	pp_system_default	{}	{}	pending	\N	pay_col_01KEV7A1KK5HZ1JYETWQTBYB3B	{}	2026-01-13 00:29:15.237-08	2026-01-13 00:29:15.237-08	\N
payses_01KEVD1K173J2K2DN6NCRJSBW3	eur	20	{"value": "20", "precision": 20}	pp_system_default	{}	{}	authorized	2026-01-13 02:04:55.935-08	pay_col_01KEVBVXX2ZR0SRPZJNATWJX0V	{}	2026-01-13 02:04:55.719-08	2026-01-13 02:04:55.938-08	\N
payses_01KEVFZR3EDCEG412HKJPVNPBA	eur	50	{"value": "50", "precision": 20}	pp_system_default	{}	{}	authorized	2026-01-13 02:56:21.253-08	pay_col_01KEVFZR2BRGNVC9S73JDJ141Y	{}	2026-01-13 02:56:21.103-08	2026-01-13 02:56:21.255-08	\N
payses_01KEVKH9YFTP3D0A5EGN399FQK	eur	40	{"value": "40", "precision": 20}	pp_stripe_stripe	{"id": "pi_3Sp6EsLguX0AFlBv0YG1tyeA", "amount": 4000, "object": "payment_intent", "review": null, "source": null, "status": "requires_capture", "created": 1768305502, "invoice": null, "currency": "eur", "customer": null, "livemode": false, "metadata": {"session_id": "payses_01KEVKH9YFTP3D0A5EGN399FQK"}, "shipping": null, "processing": null, "application": null, "canceled_at": null, "description": null, "next_action": null, "on_behalf_of": null, "client_secret": "pi_3Sp6EsLguX0AFlBv0YG1tyeA_secret_DQ93yUeQoqEolUuUMzbnfcb2N", "latest_charge": "ch_3Sp6EsLguX0AFlBv02PjWrXs", "receipt_email": null, "transfer_data": null, "amount_details": {"tip": {}}, "capture_method": "manual", "payment_method": "pm_1Sp6EtLguX0AFlBvKHJS8ctn", "transfer_group": null, "amount_received": 0, "customer_account": null, "amount_capturable": 4000, "last_payment_error": null, "setup_future_usage": null, "cancellation_reason": null, "confirmation_method": "automatic", "payment_method_types": ["card", "link"], "statement_descriptor": null, "application_fee_amount": null, "payment_method_options": {"card": {"network": null, "installments": null, "mandate_options": null, "request_three_d_secure": "automatic"}, "link": {"persistent_token": null}}, "automatic_payment_methods": {"enabled": true, "allow_redirects": "always"}, "statement_descriptor_suffix": null, "excluded_payment_method_types": null, "payment_method_configuration_details": {"id": "pmc_1Sok2TLguX0AFlBvNRKlXO49", "parent": null}}	{}	authorized	2026-01-13 03:58:25.367-08	pay_col_01KEVH0YPRJPZD7CWKWW30YQJT	{}	2026-01-13 03:58:22.16-08	2026-01-13 03:58:25.374-08	\N
payses_01KEVMFFFRG772RRGDTR8DHBND	eur	40	{"value": "40", "precision": 20}	pp_stripe_stripe	{"id": "pi_3Sp6UpLbn2sf8BPY1GQMBu0x", "amount": 4000, "object": "payment_intent", "review": null, "source": null, "status": "requires_capture", "created": 1768306491, "invoice": null, "currency": "eur", "customer": null, "livemode": false, "metadata": {"session_id": "payses_01KEVMFFFRG772RRGDTR8DHBND"}, "shipping": null, "processing": null, "application": null, "canceled_at": null, "description": null, "next_action": null, "on_behalf_of": null, "client_secret": "pi_3Sp6UpLbn2sf8BPY1GQMBu0x_secret_TjcP45CgbXzmrcerXM9Dv22CU", "latest_charge": "ch_3Sp6UpLbn2sf8BPY1CNuQ89I", "receipt_email": null, "transfer_data": null, "amount_details": {"tip": {}}, "capture_method": "manual", "payment_method": "pm_1Sp6UqLbn2sf8BPYwDFxZVS2", "transfer_group": null, "amount_received": 0, "customer_account": null, "amount_capturable": 4000, "last_payment_error": null, "setup_future_usage": null, "cancellation_reason": null, "confirmation_method": "automatic", "payment_method_types": ["card", "link"], "statement_descriptor": null, "application_fee_amount": null, "payment_method_options": {"card": {"network": null, "installments": null, "mandate_options": null, "request_three_d_secure": "automatic"}, "link": {"persistent_token": null}}, "automatic_payment_methods": {"enabled": true, "allow_redirects": "always"}, "statement_descriptor_suffix": null, "excluded_payment_method_types": null, "payment_method_configuration_details": {"id": "pmc_1ReaVwLbn2sf8BPY83hQt4lZ", "parent": null}}	{}	authorized	2026-01-13 04:14:54.62-08	pay_col_01KEVMFFEDAQDX3DTVYX7ZPH0S	{}	2026-01-13 04:14:50.872-08	2026-01-13 04:14:54.629-08	\N
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.price (id, title, price_set_id, currency_code, raw_amount, rules_count, created_at, updated_at, deleted_at, price_list_id, amount, min_quantity, max_quantity, raw_min_quantity, raw_max_quantity) FROM stdin;
price_01KEEQF4VX5CMKT2NHN9SJGD9B	\N	pset_01KEEQF4VXZ5K5G2V53N5S6VH8	usd	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF4VXGXD2JJ4B0YGJ2018	\N	pset_01KEEQF4VXZ5K5G2V53N5S6VH8	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF4VXERCG04BFXMNQXWA0	\N	pset_01KEEQF4VXZ5K5G2V53N5S6VH8	eur	{"value": "10", "precision": 20}	1	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF4VYCT51KPCR3Z2SBD27	\N	pset_01KEEQF4VYC7XZFTP0CTTAVPBA	usd	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF4VY9GRYFY2TMF7EG4T9	\N	pset_01KEEQF4VYC7XZFTP0CTTAVPBA	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF4VYK2VMAX5KYAR27WDS	\N	pset_01KEEQF4VYC7XZFTP0CTTAVPBA	eur	{"value": "10", "precision": 20}	1	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51DX8KZM2YWC6Y1HYKV	\N	pset_01KEEQF51DVAASA3RYW5BBW7MR	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51DCK88KWJ7C0G1Q8WH	\N	pset_01KEEQF51DVAASA3RYW5BBW7MR	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51D6MBK6WDZ7JAHMCRF	\N	pset_01KEEQF51D4TFD5710821S1Z22	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51DYNBQVSC43CHKVAZE	\N	pset_01KEEQF51D4TFD5710821S1Z22	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51DR0JMFMZYKJ07HPTF	\N	pset_01KEEQF51DR37EESY3BYP9KS0M	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51DNHY68CFE0H87PKRJ	\N	pset_01KEEQF51DR37EESY3BYP9KS0M	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51DHMS7C7G8HJYHKVZA	\N	pset_01KEEQF51D9PSKP3KG3DBWVRXZ	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51DF90QY2Y2Q5VMAK0V	\N	pset_01KEEQF51D9PSKP3KG3DBWVRXZ	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51DFCP0E7K3CEPNE4Z2	\N	pset_01KEEQF51EZ5NVEFYGJN296ACA	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51DRNV8BC5CF2RPZ1J4	\N	pset_01KEEQF51EZ5NVEFYGJN296ACA	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51E8DA1M7PPRV2XZRGN	\N	pset_01KEEQF51EDHQRJ7C2JGVP4WZV	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51EDGGQQ9GJY3DW3MGN	\N	pset_01KEEQF51EDHQRJ7C2JGVP4WZV	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51EZ0BZEFRR4FY6WS58	\N	pset_01KEEQF51E360WZNEG8S61DJMF	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51EDY50T0VGZB6C4XQW	\N	pset_01KEEQF51E360WZNEG8S61DJMF	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51ERAEMG1FC3X428MD5	\N	pset_01KEEQF51EC0M9YKQJX20XCGQD	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51ESNX9PEZXB2RFT790	\N	pset_01KEEQF51EC0M9YKQJX20XCGQD	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51ECRYP3TPE6R75QM64	\N	pset_01KEEQF51EANFBV1JC624SMK4B	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51EWCZ4FMSEGA61NS6J	\N	pset_01KEEQF51EANFBV1JC624SMK4B	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51EE4W821TG0NESB6EG	\N	pset_01KEEQF51EZPH7E7G91B36TKR3	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51E8YNF4FE4SFNSMJAE	\N	pset_01KEEQF51EZPH7E7G91B36TKR3	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51EY9P670JCJXDJM5N3	\N	pset_01KEEQF51EW1X3XZCBYDKS50EA	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51E14NX655MS3Q2APJT	\N	pset_01KEEQF51EW1X3XZCBYDKS50EA	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51E905CA1W6P1D6RNE2	\N	pset_01KEEQF51ED18051FCHJKBJ657	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51EV7QNJSRGY0YFJME3	\N	pset_01KEEQF51ED18051FCHJKBJ657	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51EJGRZM6265YZ07WNN	\N	pset_01KEEQF51ER0REE6RG48ZHAWGN	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51E497SMMNTRT20YXN1	\N	pset_01KEEQF51ER0REE6RG48ZHAWGN	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51FZDZ6K3K5T8SKHS83	\N	pset_01KEEQF51FM6A0KMC2ANJXQWKM	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51F10XG54KD276S3752	\N	pset_01KEEQF51FM6A0KMC2ANJXQWKM	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51FSPF7TN42RYDDPNQ3	\N	pset_01KEEQF51FCY7E4KXA6Q6HVN4X	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51F29SP83JYZKCVV4J3	\N	pset_01KEEQF51FCY7E4KXA6Q6HVN4X	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51F7R7QJGJS2QMPB6XJ	\N	pset_01KEEQF51FW7V19ZNFMG1JAMX9	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51FRGMM34NR4KGG959Z	\N	pset_01KEEQF51FW7V19ZNFMG1JAMX9	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51F1WRNSYH8WXGKXG7N	\N	pset_01KEEQF51FAED5973J8ZABA8GZ	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51FC5R06S3P3CP4794D	\N	pset_01KEEQF51FAED5973J8ZABA8GZ	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51F2PMVQXKSBJ2VDCTF	\N	pset_01KEEQF51F0K0TSHK2C97J1VT6	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51FHHNV629EVESP8330	\N	pset_01KEEQF51F0K0TSHK2C97J1VT6	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51F75A6VKAJ902BSRNQ	\N	pset_01KEEQF51FP2ENBCT21CVKE2GT	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51F18B61CQRAHFW3SJ4	\N	pset_01KEEQF51FP2ENBCT21CVKE2GT	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEEQF51FXK486ZDNPDQKWCBH	\N	pset_01KEEQF51FXV8X73MYFKQFB227	eur	{"value": "10", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	10	\N	\N	\N	\N
price_01KEEQF51FGQVJ5GF80TF5YBZJ	\N	pset_01KEEQF51FXV8X73MYFKQFB227	usd	{"value": "15", "precision": 20}	0	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N	\N	15	\N	\N	\N	\N
price_01KEERFJ3MFH2G206WAB6HSTPB	\N	pset_01KEERFJ3MSPDYCS3SVWHH2Q2D	eur	{"value": "30", "precision": 20}	0	2026-01-08 04:14:40.244-08	2026-01-08 04:14:40.244-08	\N	\N	30	\N	\N	\N	\N
price_01KEERFJ3MPEJX9MPYVEDT1RDQ	\N	pset_01KEERFJ3MSPDYCS3SVWHH2Q2D	usd	{"value": "25", "precision": 20}	0	2026-01-08 04:14:40.244-08	2026-01-08 04:14:40.244-08	\N	\N	25	\N	\N	\N	\N
price_01KEERFJ3M6CXX3HB6ME0JXPHP	\N	pset_01KEERFJ3MSPDYCS3SVWHH2Q2D	eur	{"value": "30", "precision": 20}	1	2026-01-08 04:14:40.244-08	2026-01-08 04:14:40.244-08	\N	\N	30	\N	\N	\N	\N
price_01KG1S3QBFK5DHQSW022C40HQX	\N	pset_01KG1S3QBGW58NN18W0BMWZ20P	eur	{"value": "23", "precision": 20}	0	2026-01-27 23:46:57.008-08	2026-01-27 23:46:57.008-08	\N	\N	23	\N	\N	\N	\N
price_01KG1S3QBGZA360DJ5T2S3P8DJ	\N	pset_01KG1S3QBGW58NN18W0BMWZ20P	eur	{"value": "23", "precision": 20}	1	2026-01-27 23:46:57.009-08	2026-01-27 23:46:57.009-08	\N	\N	23	\N	\N	\N	\N
price_01KG1S5D5QHXTZMPB70XMW72BK	\N	pset_01KG1S5D5Q1WBWYZ6GJR8S4YSY	eur	{"value": "10", "precision": 20}	0	2026-01-27 23:47:52.119-08	2026-01-27 23:47:52.119-08	\N	\N	10	\N	\N	\N	\N
price_01KG1S5D5Q75JRZ00EGNCQ3JGZ	\N	pset_01KG1S5D5Q1WBWYZ6GJR8S4YSY	eur	{"value": "10", "precision": 20}	1	2026-01-27 23:47:52.119-08	2026-01-27 23:47:52.119-08	\N	\N	10	\N	\N	\N	\N
\.


--
-- Data for Name: price_list; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.price_list (id, status, starts_at, ends_at, rules_count, title, description, type, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price_list_rule; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.price_list_rule (id, price_list_id, created_at, updated_at, deleted_at, value, attribute) FROM stdin;
\.


--
-- Data for Name: price_preference; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.price_preference (id, attribute, value, is_tax_inclusive, created_at, updated_at, deleted_at) FROM stdin;
prpref_01KEEQF2XYJAM2TZAS0RJMFR2D	currency_code	eur	f	2026-01-08 03:56:56.126-08	2026-01-08 03:56:56.126-08	\N
prpref_01KEEQF4SCZJRY4ZNC3JWABD0P	region_id	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	f	2026-01-08 03:56:58.029-08	2026-01-08 03:56:58.029-08	\N
prpref_01KEGSBH59MWSJJQQTQQVRFP4N	region_id	reg_01KEGSBH3J34V8ASJRQ2QYYZG6	f	2026-01-08 23:08:25.641-08	2026-01-08 23:08:25.641-08	\N
prpref_01KEGTFEJ4C85AH3TVB45T9J2R	currency_code	usd	f	2026-01-08 23:28:02.629-08	2026-01-08 23:28:02.629-08	\N
\.


--
-- Data for Name: price_rule; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.price_rule (id, value, priority, price_id, created_at, updated_at, deleted_at, attribute, operator) FROM stdin;
prule_01KEEQF4VXV1YPBS88PAXP3B53	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	0	price_01KEEQF4VXERCG04BFXMNQXWA0	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	region_id	eq
prule_01KEEQF4VY2N6VJQF4WEE2PJ0Z	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	0	price_01KEEQF4VYK2VMAX5KYAR27WDS	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N	region_id	eq
prule_01KEERFJ3MC4B04TMAHFVTQRBZ	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	0	price_01KEERFJ3M6CXX3HB6ME0JXPHP	2026-01-08 04:14:40.244-08	2026-01-08 04:14:40.244-08	\N	region_id	eq
prule_01KG1S3QBGPB3PYZK7M5RF7ANN	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	0	price_01KG1S3QBGZA360DJ5T2S3P8DJ	2026-01-27 23:46:57.009-08	2026-01-27 23:46:57.009-08	\N	region_id	eq
prule_01KG1S5D5Q40GKX72SHCN7N1M1	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	0	price_01KG1S5D5Q75JRZ00EGNCQ3JGZ	2026-01-27 23:47:52.119-08	2026-01-27 23:47:52.119-08	\N	region_id	eq
\.


--
-- Data for Name: price_set; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.price_set (id, created_at, updated_at, deleted_at) FROM stdin;
pset_01KEEQF4VXZ5K5G2V53N5S6VH8	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N
pset_01KEEQF4VYC7XZFTP0CTTAVPBA	2026-01-08 03:56:58.11-08	2026-01-08 03:56:58.11-08	\N
pset_01KEEQF51DVAASA3RYW5BBW7MR	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51D4TFD5710821S1Z22	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51DR37EESY3BYP9KS0M	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51D9PSKP3KG3DBWVRXZ	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51EZ5NVEFYGJN296ACA	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51EDHQRJ7C2JGVP4WZV	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51E360WZNEG8S61DJMF	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51EC0M9YKQJX20XCGQD	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51EANFBV1JC624SMK4B	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51EZPH7E7G91B36TKR3	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51EW1X3XZCBYDKS50EA	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51ED18051FCHJKBJ657	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51ER0REE6RG48ZHAWGN	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51FM6A0KMC2ANJXQWKM	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51FCY7E4KXA6Q6HVN4X	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51FW7V19ZNFMG1JAMX9	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51FAED5973J8ZABA8GZ	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51F0K0TSHK2C97J1VT6	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51FP2ENBCT21CVKE2GT	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEEQF51FXV8X73MYFKQFB227	2026-01-08 03:56:58.288-08	2026-01-08 03:56:58.288-08	\N
pset_01KEERFJ3MSPDYCS3SVWHH2Q2D	2026-01-08 04:14:40.244-08	2026-01-08 04:14:40.244-08	\N
pset_01KG1S3QBGW58NN18W0BMWZ20P	2026-01-27 23:46:57.008-08	2026-01-27 23:46:57.008-08	\N
pset_01KG1S5D5Q1WBWYZ6GJR8S4YSY	2026-01-27 23:47:52.119-08	2026-01-27 23:47:52.119-08	\N
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product (id, title, handle, subtitle, description, is_giftcard, status, thumbnail, weight, length, height, width, origin_country, hs_code, mid_code, material, collection_id, type_id, discountable, external_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
prod_01KG1S3Q37C8GVJGSZSPTMPA1F	jacket	winter-jacket	warm and cozy	warm cozy jacket	f	published	http://localhost:9000/static/1769586416643-IMG_6150.JPG	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-01-27 23:46:56.779-08	2026-01-27 23:46:56.779-08	\N	\N
prod_01KG1S5D4F7C6CM90FS0MSVPXJ	shirt	shirt	cold shirt	shirt that should be cold	f	published	http://localhost:9000/static/1769586472060-refle.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-01-27 23:47:52.08-08	2026-01-27 23:47:52.08-08	\N	\N
prod_01KG4QZ4CE73Q9BVFQ8H3P275E	Merchant Product Alpha	merchant-product-alpha	\N	Owned by Merchant One	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-01-29 03:24:41.232-08	2026-01-29 03:24:41.232-08	\N	\N
prod_01KG4WF9MPK74ZQXBC7N4GAK8A	Isolated Product A	isolated-product-a	\N	Belongs only to this merchant	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-01-29 04:43:25.211-08	2026-01-29 04:43:25.211-08	\N	\N
prod_01KG7A810QE7PKNBQ8VVWBS38K	Iso Product A	iso-product-a	\N	Belongs only to merchant 1	f	published	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-01-30 03:22:35.95-08	2026-01-30 03:22:35.95-08	\N	\N
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_category (id, name, description, handle, mpath, is_active, is_internal, rank, parent_category_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
pcat_01KEEQF4Y4EZHKDMXVJF7GK121	Shirts		shirts	pcat_01KEEQF4Y4EZHKDMXVJF7GK121	t	f	0	\N	2026-01-08 03:56:58.181-08	2026-01-08 03:56:58.181-08	\N	\N
pcat_01KEEQF4Y50PQX1A6FBKJEETD6	Sweatshirts		sweatshirts	pcat_01KEEQF4Y50PQX1A6FBKJEETD6	t	f	1	\N	2026-01-08 03:56:58.181-08	2026-01-08 03:56:58.181-08	\N	\N
pcat_01KEEQF4Y5WZVM7WB57BVQP1CC	Pants		pants	pcat_01KEEQF4Y5WZVM7WB57BVQP1CC	t	f	2	\N	2026-01-08 03:56:58.181-08	2026-01-08 03:56:58.181-08	\N	\N
pcat_01KEEQF4Y533N8M6V96BC8YBRT	Merch		merch	pcat_01KEEQF4Y533N8M6V96BC8YBRT	t	f	3	\N	2026-01-08 03:56:58.181-08	2026-01-08 03:56:58.181-08	\N	\N
\.


--
-- Data for Name: product_category_product; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_category_product (product_id, product_category_id) FROM stdin;
\.


--
-- Data for Name: product_collection; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_collection (id, title, handle, metadata, created_at, updated_at, deleted_at) FROM stdin;
pcol_01KEGPXFYAPND0QX7T9WX4Y54R	Beardcare	beardcare	\N	2026-01-08 22:25:48.485195-08	2026-01-08 22:25:48.485195-08	\N
pcol_01KEGPYTK33QYRD5N2KKCD22HG	haircare	haircare	\N	2026-01-08 22:26:32.16266-08	2026-01-08 22:26:32.16266-08	\N
pcol_01KFJFDNY2DF4X4ZJTJFWFCH6R	pants	pants	\N	2026-01-22 01:09:00.989563-08	2026-01-22 01:09:00.989563-08	\N
pcol_01KFJHTHWTFEN0TKRFXPHVGEK8	testasdf	testasdf	\N	2026-01-22 01:50:59.990724-08	2026-01-22 01:50:59.990724-08	\N
pcol_01KFMRBYQEX87Z7A4VBPE0KSW8	skintoo	skintoo	\N	2026-01-22 22:23:50.49782-08	2026-01-22 22:23:50.49782-08	\N
\.


--
-- Data for Name: product_option; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_option (id, title, product_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
opt_01KG1S3Q417HMDT2JRG97PN31X	Default option	prod_01KG1S3Q37C8GVJGSZSPTMPA1F	\N	2026-01-27 23:46:56.781-08	2026-01-27 23:46:56.781-08	\N
opt_01KG1S5D4GX5DQCMDXQE3KCKY9	Default option	prod_01KG1S5D4F7C6CM90FS0MSVPXJ	\N	2026-01-27 23:47:52.08-08	2026-01-27 23:47:52.08-08	\N
\.


--
-- Data for Name: product_option_value; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_option_value (id, value, option_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
optval_01KG1S3Q3W4VH6GBPYBNN73FQ1	Default option value	opt_01KG1S3Q417HMDT2JRG97PN31X	\N	2026-01-27 23:46:56.781-08	2026-01-27 23:46:56.781-08	\N
optval_01KG1S5D4GBCFKH0Q0XDNM60EE	Default option value	opt_01KG1S5D4GX5DQCMDXQE3KCKY9	\N	2026-01-27 23:47:52.08-08	2026-01-27 23:47:52.08-08	\N
\.


--
-- Data for Name: product_sales_channel; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_sales_channel (product_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KG1S3Q37C8GVJGSZSPTMPA1F	sc_01KFZK56EYXWNSVK65K2C155N5	prodsc_01KG1S3Q8G4ZV19FW59W7X3ZKM	2026-01-27 23:46:56.910105-08	2026-01-27 23:46:56.910105-08	\N
prod_01KG1S5D4F7C6CM90FS0MSVPXJ	sc_01KFZK56EYXWNSVK65K2C155N5	prodsc_01KG1S5D4VS2W0MSW4SSTY2KHC	2026-01-27 23:47:52.090218-08	2026-01-27 23:47:52.090218-08	\N
prod_01KG4WF9MPK74ZQXBC7N4GAK8A	sc_01KG4V8WZY36J6TJWYHNPYVHKW	prodsc_01KG4WF9NM84YD5WM8PWZC2RA9	2026-01-29 04:43:25.236084-08	2026-01-29 04:43:25.236084-08	\N
prod_01KG7A810QE7PKNBQ8VVWBS38K	sc_01KG7A6DPGJZYW5J2ECHH0DFBH	prodsc_01KG7A813RGQTDEVKAKGE4AX5Y	2026-01-30 03:22:36.019842-08	2026-01-30 03:22:36.019842-08	\N
\.


--
-- Data for Name: product_shipping_profile; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_shipping_profile (product_id, shipping_profile_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_tag; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_tag (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_tags (product_id, product_tag_id) FROM stdin;
\.


--
-- Data for Name: product_type; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_type (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_variant; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_variant (id, title, sku, barcode, ean, upc, allow_backorder, manage_inventory, hs_code, origin_country, mid_code, material, weight, length, height, width, metadata, variant_rank, product_id, created_at, updated_at, deleted_at, thumbnail) FROM stdin;
variant_01KG1S3QAF6W5X9N0MXJ3WWR89	Default variant	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KG1S3Q37C8GVJGSZSPTMPA1F	2026-01-27 23:46:56.975-08	2026-01-27 23:46:56.975-08	\N	\N
variant_01KG1S5D5DPECW1K22SG9J91R0	Default variant	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KG1S5D4F7C6CM90FS0MSVPXJ	2026-01-27 23:47:52.109-08	2026-01-27 23:47:52.109-08	\N	\N
\.


--
-- Data for Name: product_variant_inventory_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_variant_inventory_item (variant_id, inventory_item_id, id, required_quantity, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_variant_option; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_variant_option (variant_id, option_value_id) FROM stdin;
variant_01KG1S3QAF6W5X9N0MXJ3WWR89	optval_01KG1S3Q3W4VH6GBPYBNN73FQ1
variant_01KG1S5D5DPECW1K22SG9J91R0	optval_01KG1S5D4GBCFKH0Q0XDNM60EE
\.


--
-- Data for Name: product_variant_price_set; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_variant_price_set (variant_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
variant_01KG1S3QAF6W5X9N0MXJ3WWR89	pset_01KG1S3QBGW58NN18W0BMWZ20P	pvps_01KG1S3QCMAJA62Q02VSVVHCPS	2026-01-27 23:46:57.044326-08	2026-01-27 23:46:57.044326-08	\N
variant_01KG1S5D5DPECW1K22SG9J91R0	pset_01KG1S5D5Q1WBWYZ6GJR8S4YSY	pvps_01KG1S5D64ERDT0RQNS4C328TA	2026-01-27 23:47:52.132468-08	2026-01-27 23:47:52.132468-08	\N
\.


--
-- Data for Name: product_variant_product_image; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.product_variant_product_image (id, variant_id, image_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion (id, code, campaign_id, is_automatic, type, created_at, updated_at, deleted_at, status, is_tax_inclusive, "limit", used, metadata) FROM stdin;
\.


--
-- Data for Name: promotion_application_method; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_application_method (id, value, raw_value, max_quantity, apply_to_quantity, buy_rules_min_quantity, type, target_type, allocation, promotion_id, created_at, updated_at, deleted_at, currency_code) FROM stdin;
\.


--
-- Data for Name: promotion_campaign; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_campaign (id, name, description, campaign_identifier, starts_at, ends_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_campaign_budget (id, type, campaign_id, "limit", raw_limit, used, raw_used, created_at, updated_at, deleted_at, currency_code, attribute) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget_usage; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_campaign_budget_usage (id, attribute_value, used, budget_id, raw_used, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_promotion_rule; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_promotion_rule (promotion_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: promotion_rule; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_rule (id, description, attribute, operator, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_rule_value; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.promotion_rule_value (id, promotion_rule_id, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: provider_identity; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.provider_identity (id, entity_id, provider, auth_identity_id, user_metadata, provider_metadata, created_at, updated_at, deleted_at) FROM stdin;
01KG4A1B87VS9M786ZDZ9V7RQ6	merchant4@test.com	emailpass	authid_01KG4A1B87TBA5893QDWPQP71R	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAeCh/Pz1NZJIYZ7wJEhwF4n//xyhZYX44aZST/GdBuqv1A24bvaeyvA3Qfd2p7yGS+he9CrbBfDcNvPxhx+wKsqampsyCrV2p/JtfL2FotZg"}	2026-01-28 23:21:13.736-08	2026-01-28 23:21:13.736-08	\N
01KFZNKB5CZKC9AWHP8QWNSFYS	merchant@test.com	emailpass	authid_01KFZNKB5C6HM4HFFN3T227AM9	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAVcLxubQyzVk4O42nERzh9uW0g2jnRV5V/Lv7bMZH080nRHmDHe4kedorREhqSD92TOFkDwcE3bKHmkT6XI+Xqpvn78FalYlLa+Ag27WrBeW"}	2026-01-27 04:07:05.644-08	2026-01-29 00:11:29.285-08	\N
01KG1WWK71Z58CAWZQD802GVJ3	merchant1@test.com	emailpass	authid_01KG1WWK72QPQK21P5VSMT3QDN	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAakyKwJ0ZTS0xQyOeaswADxa9yizfxOIFF+EjHQk6PiuiIormIEOcSgF3B4/j6DSooEVelAAE/fL7M4NipLvs2ozsCr7YEYM6csPW1K/Fj78"}	2026-01-28 00:52:57.698-08	2026-01-29 01:03:10.57-08	\N
01KFZNC906P4FE5X4CB0SQ8X7C	merchant_01ONBOARDTEST	emailpass	authid_01KFZNC90C7QN5WQ0QEMB7GABB	\N	{"password": "c2NyeXB0AA8AAAAIAAAAARfXNbDEpacY+Yf4ltRbg0YoRqB1BcjMufEO23gm2CyiSaPgw6HNyNBaA/h3hJxC2wYOPK1iT0aMObbg5qB9PJG6pT1SJF88EThsGA033G8T"}	2026-01-27 04:03:14.112-08	2026-01-27 04:03:14.112-08	\N
01KFZZM8P5NS18NQHB41090KMT	admin@local.dev	emailpass	authid_01KFZZM8P5PWF9J8A3NS490638	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAYujsPnc7PSA++lrWhs+uNYvOmZK60n/siilVPzBBc7sptb8cc1PsRivaGkrYWxifjx57osINFdta0cts0NEF0TWgSnzk+1ghiOVan4Xn5cP"}	2026-01-27 07:02:21.638-08	2026-01-27 07:02:21.638-08	\N
01KG49DC5AZ17ZH43J1W6ENYCA	test@merchant.com	emailpass	authid_01KG49DC5CP597H8W8KYG5RR63	\N	{"password": "c2NyeXB0AA8AAAAIAAAAASis7OaSYgeXviNNU5ZfKpJSWnVXG1+nNOPZlciGdYGVvJYuTHfD1ht18BAkPVL6lJuCUK4fWPAoqCM/d7c/9WBvPXbgz5ZndALX2M+EYejK"}	2026-01-28 23:10:19.31-08	2026-01-28 23:10:19.31-08	\N
01KG4TPQ6A5AYGQKY882XGS2AW	merchant_isolation_test@test.com	emailpass	authid_01KG4TPQ6BQAHY557CDPYJAJ6E	\N	{"password": "c2NyeXB0AA8AAAAIAAAAASVzvdjoQCOLOn1++gJexel2vnON65SfuPyj5ySO4ezocAnTJndKXbmgp1QiwloWprx/5iRUXT+pNgR3OehF3dxik953Z1Xvz4MKzShOAiVl"}	2026-01-29 04:12:31.307-08	2026-01-29 04:12:31.307-08	\N
01KG4V1GQ1QZRF27B79E66WV79	merchant_isolation_test1@test.com	emailpass	authid_01KG4V1GQ4KDWS6F1V983GX0TQ	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfJ8EmhJAGR54yDW62jw4WP4D/vIpB9tl9GJ5KES7sparY8242u5ut0Mxy3yv5d1ipEKFeXEMR3VPxgNUTp9opoGQdwImZDOkadKkKjV+/lZ"}	2026-01-29 04:18:25.134-08	2026-01-29 04:18:25.134-08	\N
01KG78MMN1MB4V7C780B94MSW6	test1@test.com	emailpass	authid_01KG78MMN3R0SYAV4Y34FSFTDY	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAXt9zXwuGu3nevQMY/u2QNN9zD4sUZ0CdXDuonfgz4EzaH/F2z+Jdi6Dt56L7MmOZYxdVitdTB9aw8xiLZaGmnM/0IIour8rUh5I2xvEADu3"}	2026-01-30 02:54:32.101-08	2026-01-30 03:00:19.792-08	\N
01KG79GW094TBQ47SQZMD5TNAT	test2@test.com	emailpass	authid_01KG79GW0ENKZAQ8ERMCK6Y4KQ	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAQgqdRAL3o2hp5fMP4qzzJmxPoZ0+7NMmt/f/hl92blKnmQxDObEnAF47bb3B62ch6H8tOZv/QzIpwmgQk3QWVYd09bIQzwjqdei8yv+1ln5"}	2026-01-30 03:09:57.137-08	2026-01-30 03:09:57.137-08	\N
01KG79YWP5TS0HJWMW6VZ3HBE8	iso1@test.com	emailpass	authid_01KG79YWP8794046S29YG92WBR	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAdOCaea06uYHRL9POHkw9XOQF34nvw7Vn+g+IDwuBiw+7e8ZyNP6R+rgghc3NLvBgi1Cj0JsFlZB3oWkbnKaUteisuhQocPI0IZHbGstWo78"}	2026-01-30 03:17:36.586-08	2026-01-30 03:17:36.586-08	\N
01KGC9BYXQ3FPE3GQ5V11190CN	testemail@test.com	emailpass	authid_01KGC9BYXQP487PJ477XEKVWPA	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAf6091dsmlAVCoo2H/W1dQGblW9ckMWe8r6fc7uI+b7+J8q98oX5mGSyzG54Bdj3Iay1ELsPvGAw04oJ7jhn6hO0u1cDRbDL077lWWZzsQen"}	2026-02-01 01:43:28.441-08	2026-02-01 01:43:28.441-08	\N
01KGCADYX5RSQNKHPKDR12E7GP	iso_front_1@test.com	emailpass	authid_01KGCADYX6990PDPATVB1G54ZG	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAW+MFuIPEz3uU3E9qOLffeh+18hGD6aVu6KKDqUpR2O6ON+dexPntxmABtsciyFQkcGRp2BaITNLE8jXDbHI+OpiJtoIAKvv3EQqlYSibnkS"}	2026-02-01 02:02:02.539-08	2026-02-01 02:37:30.058-08	\N
01KGEK0R1NSRWWJP3XXZMQM8J2	iso@test.com	emailpass	authid_01KGEK0R1QDW5N095Y0P733A10	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfZ2Ewf2dACv0jSw06Rf8b3ePN6PWN6xp+GHcg4VxhKsMmAtm9UtmYoe03kTTDvqE1iPJDER90BJr0u29b0uhdohwPdWijgrJtt2TYvWRUzC"}	2026-02-01 23:10:35.578-08	2026-02-01 23:10:35.578-08	\N
\.


--
-- Data for Name: publishable_api_key_sales_channel; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.publishable_api_key_sales_channel (publishable_key_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
apk_01KEEQF2Y42AH1FWG0FP6YMFGX	sc_01KEEQF2X9D7XXV5DVM2DBT8G5	pksc_01KEEQF4XWK9T910GCMNSM4EGE	2026-01-08 03:56:56.141856-08	2026-01-08 03:56:56.141856-08	\N
apk_01KEEWS3CQCM473R3EMA0QH8W1	sc_01KEEX6NRW9KCDMQ2VCWPWDXGF	pksc_01KEEX7W5H7P1WKAZXWE6ASWSG	2026-01-08 05:37:51.280213-08	2026-01-08 23:57:19.043-08	2026-01-08 23:57:19.042-08
apk_01KEEWS3CQCM473R3EMA0QH8W1	sc_01KEGW7Y54E127T0FXHV7DA7KX	pksc_01KEGWB6CKYBR0ZBTZHXMP528N	2026-01-09 00:00:40.335148-08	2026-01-09 00:00:40.335148-08	\N
apk_01KEEQF2Y42AH1FWG0FP6YMFGX	sc_01KEGW7Y54E127T0FXHV7DA7KX	pksc_01KEGWBGW3GQB7VXYHVGY7RNZ6	2026-01-09 00:00:51.074849-08	2026-01-09 00:00:51.074849-08	\N
apk_01KEEWS3CQCM473R3EMA0QH8W1	sc_01KEEQF2X9D7XXV5DVM2DBT8G5	pksc_01KEGW9NPZ5BQ8QNGJ2CXXKSQ0	2026-01-08 23:59:50.494794-08	2026-01-09 03:00:27.814-08	2026-01-09 03:00:27.811-08
apk_01KFDCSYBP8D44DA9TXRGSBHD5	sc_01KFDBA2GYFVJJ5X2YQ63BZRKX	pksc_01KFDCT6ACJ5D85R3F4934N6G8	2026-01-20 01:47:13.09964-08	2026-01-20 01:47:13.09964-08	\N
\.


--
-- Data for Name: refund; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.refund (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata, refund_reason_id, note) FROM stdin;
\.


--
-- Data for Name: refund_reason; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.refund_reason (id, label, description, metadata, created_at, updated_at, deleted_at, code) FROM stdin;
refr_01KEEQEYW13TA7RH5JWKVH4AXC	Shipping Issue	Refund due to lost, delayed, or misdelivered shipment	\N	2026-01-08 03:56:51.91806-08	2026-01-08 03:56:51.91806-08	\N	shipping_issue
refr_01KEEQEYW15NE34PNB3TNKSC6G	Customer Care Adjustment	Refund given as goodwill or compensation for inconvenience	\N	2026-01-08 03:56:51.91806-08	2026-01-08 03:56:51.91806-08	\N	customer_care_adjustment
refr_01KEEQEYW2E33BE6KG6SYPTH6F	Pricing Error	Refund to correct an overcharge, missing discount, or incorrect price	\N	2026-01-08 03:56:51.91806-08	2026-01-08 03:56:51.91806-08	\N	pricing_error
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.region (id, name, currency_code, metadata, created_at, updated_at, deleted_at, automatic_taxes) FROM stdin;
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	Europe	eur	\N	2026-01-08 03:56:58.015-08	2026-01-08 03:56:58.015-08	\N	t
reg_01KEGSBH3J34V8ASJRQ2QYYZG6	Default	usd	\N	2026-01-08 23:08:25.588-08	2026-01-08 23:08:25.588-08	\N	t
\.


--
-- Data for Name: region_country; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.region_country (iso_2, iso_3, num_code, name, display_name, region_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
af	afg	004	AFGHANISTAN	Afghanistan	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
al	alb	008	ALBANIA	Albania	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
dz	dza	012	ALGERIA	Algeria	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
as	asm	016	AMERICAN SAMOA	American Samoa	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ad	and	020	ANDORRA	Andorra	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ao	ago	024	ANGOLA	Angola	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ai	aia	660	ANGUILLA	Anguilla	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
aq	ata	010	ANTARCTICA	Antarctica	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ag	atg	028	ANTIGUA AND BARBUDA	Antigua and Barbuda	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ar	arg	032	ARGENTINA	Argentina	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
am	arm	051	ARMENIA	Armenia	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
aw	abw	533	ARUBA	Aruba	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
au	aus	036	AUSTRALIA	Australia	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
at	aut	040	AUSTRIA	Austria	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
az	aze	031	AZERBAIJAN	Azerbaijan	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bs	bhs	044	BAHAMAS	Bahamas	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bh	bhr	048	BAHRAIN	Bahrain	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bd	bgd	050	BANGLADESH	Bangladesh	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bb	brb	052	BARBADOS	Barbados	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
by	blr	112	BELARUS	Belarus	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
be	bel	056	BELGIUM	Belgium	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bz	blz	084	BELIZE	Belize	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bj	ben	204	BENIN	Benin	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bm	bmu	060	BERMUDA	Bermuda	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bt	btn	064	BHUTAN	Bhutan	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bo	bol	068	BOLIVIA	Bolivia	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bq	bes	535	BONAIRE, SINT EUSTATIUS AND SABA	Bonaire, Sint Eustatius and Saba	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ba	bih	070	BOSNIA AND HERZEGOVINA	Bosnia and Herzegovina	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bw	bwa	072	BOTSWANA	Botswana	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bv	bvd	074	BOUVET ISLAND	Bouvet Island	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
br	bra	076	BRAZIL	Brazil	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
io	iot	086	BRITISH INDIAN OCEAN TERRITORY	British Indian Ocean Territory	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bn	brn	096	BRUNEI DARUSSALAM	Brunei Darussalam	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bg	bgr	100	BULGARIA	Bulgaria	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bf	bfa	854	BURKINA FASO	Burkina Faso	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
bi	bdi	108	BURUNDI	Burundi	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
kh	khm	116	CAMBODIA	Cambodia	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cm	cmr	120	CAMEROON	Cameroon	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ca	can	124	CANADA	Canada	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cv	cpv	132	CAPE VERDE	Cape Verde	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ky	cym	136	CAYMAN ISLANDS	Cayman Islands	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cf	caf	140	CENTRAL AFRICAN REPUBLIC	Central African Republic	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
td	tcd	148	CHAD	Chad	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cl	chl	152	CHILE	Chile	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cn	chn	156	CHINA	China	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cx	cxr	162	CHRISTMAS ISLAND	Christmas Island	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cc	cck	166	COCOS (KEELING) ISLANDS	Cocos (Keeling) Islands	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
co	col	170	COLOMBIA	Colombia	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
km	com	174	COMOROS	Comoros	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cg	cog	178	CONGO	Congo	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cd	cod	180	CONGO, THE DEMOCRATIC REPUBLIC OF THE	Congo, the Democratic Republic of the	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ck	cok	184	COOK ISLANDS	Cook Islands	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cr	cri	188	COSTA RICA	Costa Rica	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ci	civ	384	COTE D'IVOIRE	Cote D'Ivoire	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
hr	hrv	191	CROATIA	Croatia	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cu	cub	192	CUBA	Cuba	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cw	cuw	531	CURAÇAO	Curaçao	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cy	cyp	196	CYPRUS	Cyprus	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
cz	cze	203	CZECH REPUBLIC	Czech Republic	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
dj	dji	262	DJIBOUTI	Djibouti	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
dm	dma	212	DOMINICA	Dominica	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
do	dom	214	DOMINICAN REPUBLIC	Dominican Republic	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ec	ecu	218	ECUADOR	Ecuador	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
eg	egy	818	EGYPT	Egypt	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
sv	slv	222	EL SALVADOR	El Salvador	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
gq	gnq	226	EQUATORIAL GUINEA	Equatorial Guinea	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
er	eri	232	ERITREA	Eritrea	\N	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:53.57-08	\N
ee	est	233	ESTONIA	Estonia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
et	eth	231	ETHIOPIA	Ethiopia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
fk	flk	238	FALKLAND ISLANDS (MALVINAS)	Falkland Islands (Malvinas)	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
fo	fro	234	FAROE ISLANDS	Faroe Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
fj	fji	242	FIJI	Fiji	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
fi	fin	246	FINLAND	Finland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gf	guf	254	FRENCH GUIANA	French Guiana	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pf	pyf	258	FRENCH POLYNESIA	French Polynesia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tf	atf	260	FRENCH SOUTHERN TERRITORIES	French Southern Territories	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ga	gab	266	GABON	Gabon	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gm	gmb	270	GAMBIA	Gambia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ge	geo	268	GEORGIA	Georgia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gh	gha	288	GHANA	Ghana	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gi	gib	292	GIBRALTAR	Gibraltar	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gr	grc	300	GREECE	Greece	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gl	grl	304	GREENLAND	Greenland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gd	grd	308	GRENADA	Grenada	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gp	glp	312	GUADELOUPE	Guadeloupe	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gu	gum	316	GUAM	Guam	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gt	gtm	320	GUATEMALA	Guatemala	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gg	ggy	831	GUERNSEY	Guernsey	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gn	gin	324	GUINEA	Guinea	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gw	gnb	624	GUINEA-BISSAU	Guinea-Bissau	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gy	guy	328	GUYANA	Guyana	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ht	hti	332	HAITI	Haiti	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
hm	hmd	334	HEARD ISLAND AND MCDONALD ISLANDS	Heard Island And Mcdonald Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
va	vat	336	HOLY SEE (VATICAN CITY STATE)	Holy See (Vatican City State)	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
hn	hnd	340	HONDURAS	Honduras	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
hk	hkg	344	HONG KONG	Hong Kong	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
hu	hun	348	HUNGARY	Hungary	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
is	isl	352	ICELAND	Iceland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
in	ind	356	INDIA	India	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
id	idn	360	INDONESIA	Indonesia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ir	irn	364	IRAN, ISLAMIC REPUBLIC OF	Iran, Islamic Republic of	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
iq	irq	368	IRAQ	Iraq	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ie	irl	372	IRELAND	Ireland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
im	imn	833	ISLE OF MAN	Isle Of Man	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
il	isr	376	ISRAEL	Israel	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
jm	jam	388	JAMAICA	Jamaica	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
jp	jpn	392	JAPAN	Japan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
je	jey	832	JERSEY	Jersey	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
jo	jor	400	JORDAN	Jordan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
kz	kaz	398	KAZAKHSTAN	Kazakhstan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ke	ken	404	KENYA	Kenya	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ki	kir	296	KIRIBATI	Kiribati	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
kp	prk	408	KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF	Korea, Democratic People's Republic of	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
kr	kor	410	KOREA, REPUBLIC OF	Korea, Republic of	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
xk	xkx	900	KOSOVO	Kosovo	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
kw	kwt	414	KUWAIT	Kuwait	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
kg	kgz	417	KYRGYZSTAN	Kyrgyzstan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
la	lao	418	LAO PEOPLE'S DEMOCRATIC REPUBLIC	Lao People's Democratic Republic	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lv	lva	428	LATVIA	Latvia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lb	lbn	422	LEBANON	Lebanon	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ls	lso	426	LESOTHO	Lesotho	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lr	lbr	430	LIBERIA	Liberia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ly	lby	434	LIBYA	Libya	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
li	lie	438	LIECHTENSTEIN	Liechtenstein	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lt	ltu	440	LITHUANIA	Lithuania	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lu	lux	442	LUXEMBOURG	Luxembourg	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mo	mac	446	MACAO	Macao	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mg	mdg	450	MADAGASCAR	Madagascar	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mw	mwi	454	MALAWI	Malawi	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
my	mys	458	MALAYSIA	Malaysia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mv	mdv	462	MALDIVES	Maldives	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ml	mli	466	MALI	Mali	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mt	mlt	470	MALTA	Malta	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mh	mhl	584	MARSHALL ISLANDS	Marshall Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mq	mtq	474	MARTINIQUE	Martinique	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mr	mrt	478	MAURITANIA	Mauritania	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mu	mus	480	MAURITIUS	Mauritius	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
yt	myt	175	MAYOTTE	Mayotte	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mx	mex	484	MEXICO	Mexico	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
fm	fsm	583	MICRONESIA, FEDERATED STATES OF	Micronesia, Federated States of	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
md	mda	498	MOLDOVA, REPUBLIC OF	Moldova, Republic of	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mc	mco	492	MONACO	Monaco	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mn	mng	496	MONGOLIA	Mongolia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
me	mne	499	MONTENEGRO	Montenegro	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ms	msr	500	MONTSERRAT	Montserrat	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ma	mar	504	MOROCCO	Morocco	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mz	moz	508	MOZAMBIQUE	Mozambique	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mm	mmr	104	MYANMAR	Myanmar	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
na	nam	516	NAMIBIA	Namibia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
nr	nru	520	NAURU	Nauru	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
np	npl	524	NEPAL	Nepal	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
nl	nld	528	NETHERLANDS	Netherlands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
nc	ncl	540	NEW CALEDONIA	New Caledonia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
nz	nzl	554	NEW ZEALAND	New Zealand	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ni	nic	558	NICARAGUA	Nicaragua	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ne	ner	562	NIGER	Niger	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ng	nga	566	NIGERIA	Nigeria	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
nu	niu	570	NIUE	Niue	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
nf	nfk	574	NORFOLK ISLAND	Norfolk Island	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mk	mkd	807	NORTH MACEDONIA	North Macedonia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mp	mnp	580	NORTHERN MARIANA ISLANDS	Northern Mariana Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
no	nor	578	NORWAY	Norway	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
om	omn	512	OMAN	Oman	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pk	pak	586	PAKISTAN	Pakistan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pw	plw	585	PALAU	Palau	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ps	pse	275	PALESTINIAN TERRITORY, OCCUPIED	Palestinian Territory, Occupied	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pa	pan	591	PANAMA	Panama	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pg	png	598	PAPUA NEW GUINEA	Papua New Guinea	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
py	pry	600	PARAGUAY	Paraguay	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pe	per	604	PERU	Peru	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ph	phl	608	PHILIPPINES	Philippines	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pn	pcn	612	PITCAIRN	Pitcairn	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pl	pol	616	POLAND	Poland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pt	prt	620	PORTUGAL	Portugal	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pr	pri	630	PUERTO RICO	Puerto Rico	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
qa	qat	634	QATAR	Qatar	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
re	reu	638	REUNION	Reunion	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ro	rom	642	ROMANIA	Romania	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ru	rus	643	RUSSIAN FEDERATION	Russian Federation	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
rw	rwa	646	RWANDA	Rwanda	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
bl	blm	652	SAINT BARTHÉLEMY	Saint Barthélemy	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sh	shn	654	SAINT HELENA	Saint Helena	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
kn	kna	659	SAINT KITTS AND NEVIS	Saint Kitts and Nevis	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lc	lca	662	SAINT LUCIA	Saint Lucia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
mf	maf	663	SAINT MARTIN (FRENCH PART)	Saint Martin (French part)	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
pm	spm	666	SAINT PIERRE AND MIQUELON	Saint Pierre and Miquelon	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
vc	vct	670	SAINT VINCENT AND THE GRENADINES	Saint Vincent and the Grenadines	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ws	wsm	882	SAMOA	Samoa	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sm	smr	674	SAN MARINO	San Marino	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
st	stp	678	SAO TOME AND PRINCIPE	Sao Tome and Principe	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sa	sau	682	SAUDI ARABIA	Saudi Arabia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sn	sen	686	SENEGAL	Senegal	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
rs	srb	688	SERBIA	Serbia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sc	syc	690	SEYCHELLES	Seychelles	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sl	sle	694	SIERRA LEONE	Sierra Leone	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sg	sgp	702	SINGAPORE	Singapore	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sx	sxm	534	SINT MAARTEN	Sint Maarten	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sk	svk	703	SLOVAKIA	Slovakia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
si	svn	705	SLOVENIA	Slovenia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sb	slb	090	SOLOMON ISLANDS	Solomon Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
so	som	706	SOMALIA	Somalia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
za	zaf	710	SOUTH AFRICA	South Africa	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
gs	sgs	239	SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS	South Georgia and the South Sandwich Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ss	ssd	728	SOUTH SUDAN	South Sudan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
lk	lka	144	SRI LANKA	Sri Lanka	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sd	sdn	729	SUDAN	Sudan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sr	sur	740	SURINAME	Suriname	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sj	sjm	744	SVALBARD AND JAN MAYEN	Svalbard and Jan Mayen	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sz	swz	748	SWAZILAND	Swaziland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ch	che	756	SWITZERLAND	Switzerland	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
sy	syr	760	SYRIAN ARAB REPUBLIC	Syrian Arab Republic	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tw	twn	158	TAIWAN, PROVINCE OF CHINA	Taiwan, Province of China	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tj	tjk	762	TAJIKISTAN	Tajikistan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tz	tza	834	TANZANIA, UNITED REPUBLIC OF	Tanzania, United Republic of	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
th	tha	764	THAILAND	Thailand	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tl	tls	626	TIMOR LESTE	Timor Leste	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tg	tgo	768	TOGO	Togo	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tk	tkl	772	TOKELAU	Tokelau	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
to	ton	776	TONGA	Tonga	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tt	tto	780	TRINIDAD AND TOBAGO	Trinidad and Tobago	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tn	tun	788	TUNISIA	Tunisia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tr	tur	792	TURKEY	Turkey	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tm	tkm	795	TURKMENISTAN	Turkmenistan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tc	tca	796	TURKS AND CAICOS ISLANDS	Turks and Caicos Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
tv	tuv	798	TUVALU	Tuvalu	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ug	uga	800	UGANDA	Uganda	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ua	ukr	804	UKRAINE	Ukraine	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ae	are	784	UNITED ARAB EMIRATES	United Arab Emirates	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
us	usa	840	UNITED STATES	United States	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
um	umi	581	UNITED STATES MINOR OUTLYING ISLANDS	United States Minor Outlying Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
uy	ury	858	URUGUAY	Uruguay	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
uz	uzb	860	UZBEKISTAN	Uzbekistan	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
vu	vut	548	VANUATU	Vanuatu	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ve	ven	862	VENEZUELA	Venezuela	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
vn	vnm	704	VIET NAM	Viet Nam	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
vg	vgb	092	VIRGIN ISLANDS, BRITISH	Virgin Islands, British	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
vi	vir	850	VIRGIN ISLANDS, U.S.	Virgin Islands, U.S.	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
wf	wlf	876	WALLIS AND FUTUNA	Wallis and Futuna	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
eh	esh	732	WESTERN SAHARA	Western Sahara	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ye	yem	887	YEMEN	Yemen	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
zm	zmb	894	ZAMBIA	Zambia	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
zw	zwe	716	ZIMBABWE	Zimbabwe	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
ax	ala	248	ÅLAND ISLANDS	Åland Islands	\N	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:53.571-08	\N
dk	dnk	208	DENMARK	Denmark	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.57-08	2026-01-08 03:56:58.015-08	\N
fr	fra	250	FRANCE	France	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:58.015-08	\N
de	deu	276	GERMANY	Germany	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:58.015-08	\N
it	ita	380	ITALY	Italy	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:58.015-08	\N
es	esp	724	SPAIN	Spain	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:58.015-08	\N
se	swe	752	SWEDEN	Sweden	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:58.015-08	\N
gb	gbr	826	UNITED KINGDOM	United Kingdom	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	\N	2026-01-08 03:56:53.571-08	2026-01-08 03:56:58.015-08	\N
\.


--
-- Data for Name: region_payment_provider; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.region_payment_provider (region_id, payment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
reg_01KEGSBH3J34V8ASJRQ2QYYZG6	pp_stripe_stripe	regpp_01KEV3RQ6S1VJH4F8A8E3N2HFZ	2026-01-12 23:22:47.896111-08	2026-01-12 23:22:47.896111-08	\N
reg_01KEGSBH3J34V8ASJRQ2QYYZG6	pp_system_default	regpp_01KEGSBH53WTKV8YBYF231W63E	2026-01-08 23:08:25.632502-08	2026-01-12 23:22:47.898-08	2026-01-12 23:22:47.897-08
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_system_default	regpp_01KEV5YDHCNDX90DHHEB3PP0TA	2026-01-08 03:56:58.027264-08	2026-01-12 23:22:28.609-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe_stripe	regpp_01KEVG7XJJJ4MEXMEW6FAKNRB5	2026-01-12 23:22:28.602256-08	2026-01-13 00:11:09.758-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-przelewy24_stripe	regpp_01KEVG7XJJ3SXQEXC08KVJ1T98	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-promptpay_stripe	regpp_01KEVG7XJK3PS970A4EK39PDEK	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-oxxo_stripe	regpp_01KEVG7XJKY65ZS05ZNK6A223E	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-ideal_stripe	regpp_01KEVG7XJK3ETQGY3HPRTK6N50	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-giropay_stripe	regpp_01KEVG7XJKFZHJ0PHGV5Y2DZWE	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-blik_stripe	regpp_01KEVG7XJKRN2JW09YY42YYFPP	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	pp_stripe-bancontact_stripe	regpp_01KEVG7XJKCR8Q76984ZV6NA3C	2026-01-13 03:00:48.850081-08	2026-01-13 03:00:48.850081-08	\N
\.


--
-- Data for Name: reservation_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.reservation_item (id, created_at, updated_at, deleted_at, line_item_id, location_id, quantity, external_id, description, created_by, metadata, inventory_item_id, allow_backorder, raw_quantity) FROM stdin;
resitem_01KEV7E9DT0ZTFEM9F5G60ZCJR	2026-01-13 00:27:00.412-08	2026-01-13 00:27:00.412-08	\N	ordli_01KEV7E9AH2S3ASBBBEQG63BGN	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1	\N	\N	\N	\N	iitem_01KEEQF50S7A5HWCEKQZ82J072	f	{"value": "1", "precision": 20}
resitem_01KEV7E9DTM6JXA7R925QY0AQ8	2026-01-13 00:27:00.412-08	2026-01-13 00:27:00.412-08	\N	ordli_01KEV7E9AHNM1PY5724FKVQ7GC	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1	\N	\N	\N	\N	iitem_01KEEQF50SD0R2E5TE38HPMKM5	f	{"value": "1", "precision": 20}
resitem_01KEVD1K7ECBMSCRSZG44VFCSG	2026-01-13 02:04:55.92-08	2026-01-13 02:04:55.92-08	\N	ordli_01KEVD1K57EA6DVH6KJ2XJJT7F	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	1	\N	\N	\N	\N	iitem_01KEEQF50S7A5HWCEKQZ82J072	f	{"value": "1", "precision": 20}
resitem_01KEVFZR7R29WX68ZXXFJ37PRB	2026-01-13 02:56:21.244-08	2026-01-13 02:56:21.244-08	\N	ordli_01KEVFZR5YXB9V8A9Y9WV18XC0	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	4	\N	\N	\N	\N	iitem_01KEEQF50S7A5HWCEKQZ82J072	f	{"value": "4", "precision": 20}
resitem_01KEVKHCNCB2MTVWX5KWAZQ18J	2026-01-13 03:58:24.942-08	2026-01-13 03:58:24.942-08	\N	ordli_01KEVKHCH2A693QRK1GEGA6FTX	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	3	\N	\N	\N	\N	iitem_01KEEQF50SD0R2E5TE38HPMKM5	f	{"value": "3", "precision": 20}
resitem_01KEVMFJJY9WE9ZXY2GB97S9K2	2026-01-13 04:14:54.048-08	2026-01-19 03:51:49.163-08	2026-01-19 03:51:49.156-08	ordli_01KEVMFJ5M4G4EPXK9MSAZKC9B	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	3	\N	\N	\N	\N	iitem_01KEEQF50SD0R2E5TE38HPMKM5	f	{"value": "3", "precision": 20}
\.


--
-- Data for Name: return; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.return (id, order_id, claim_id, exchange_id, order_version, display_id, status, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, received_at, canceled_at, location_id, requested_at, created_by) FROM stdin;
\.


--
-- Data for Name: return_fulfillment; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.return_fulfillment (return_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: return_item; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.return_item (id, return_id, reason_id, item_id, quantity, raw_quantity, received_quantity, raw_received_quantity, note, metadata, created_at, updated_at, deleted_at, damaged_quantity, raw_damaged_quantity) FROM stdin;
\.


--
-- Data for Name: return_reason; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.return_reason (id, value, label, description, metadata, parent_return_reason_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sales_channel; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.sales_channel (id, name, description, is_disabled, metadata, created_at, updated_at, deleted_at) FROM stdin;
sc_01KFZK56EYXWNSVK65K2C155N5	Default Sales Channel	Created by Medusa	f	\N	2026-01-27 03:24:24.926-08	2026-01-27 03:24:24.926-08	\N
sc_01KG4QBSWN6P42V5DJNJYK9ARJ	Merchant One Store Channel	\N	f	\N	2026-01-29 03:14:07.894-08	2026-01-29 03:14:07.894-08	\N
sc_01KG4V8WZY36J6TJWYHNPYVHKW	Isolation Test Store Channel	\N	f	\N	2026-01-29 04:22:27.07-08	2026-01-29 04:22:27.07-08	\N
sc_01KG79VB2SN48WW9NB1FF1C699	Test Merchant 2 Store Channel	\N	f	\N	2026-01-30 03:15:40.25-08	2026-01-30 03:15:40.25-08	\N
sc_01KG7A6DPGJZYW5J2ECHH0DFBH	Iso Store 1 Channel	\N	f	\N	2026-01-30 03:21:43.377-08	2026-01-30 03:21:43.377-08	\N
\.


--
-- Data for Name: sales_channel_stock_location; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.sales_channel_stock_location (sales_channel_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
sc_01KEEQF2X9D7XXV5DVM2DBT8G5	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	scloc_01KEEQF4XF3W24A93591FVWD5T	2026-01-08 03:56:58.158878-08	2026-01-08 03:56:58.158878-08	\N
sc_01KEGW7Y54E127T0FXHV7DA7KX	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	scloc_01KEH7E7PBF9N94YMQ5RHPQX1B	2026-01-09 03:14:34.314582-08	2026-01-09 03:14:34.314582-08	\N
\.


--
-- Data for Name: script_migrations; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.script_migrations (id, script_name, created_at, finished_at) FROM stdin;
1	migrate-product-shipping-profile.js	2026-01-08 03:56:54.045027-08	2026-01-08 03:56:54.08071-08
2	migrate-tax-region-provider.js	2026-01-08 03:56:54.082366-08	2026-01-08 03:56:54.093386-08
\.


--
-- Data for Name: service_zone; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.service_zone (id, name, metadata, fulfillment_set_id, created_at, updated_at, deleted_at) FROM stdin;
serzo_01KEEQF4TDQSTDWZPATQSFCW5T	Europe	\N	fuset_01KEEQF4TDBRS857H6BWRKMGNX	2026-01-08 03:56:58.062-08	2026-01-08 03:56:58.062-08	\N
\.


--
-- Data for Name: shipping_option; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.shipping_option (id, name, price_type, service_zone_id, shipping_profile_id, provider_id, data, metadata, shipping_option_type_id, created_at, updated_at, deleted_at) FROM stdin;
so_01KEEQF4VJRE372E61E8K0FZT3	Standard Shipping	flat	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	sp_01KEEQF0XXYA28B4MDY6JW7H76	manual_manual	\N	\N	sotype_01KEEQF4VJ5JNGJ67QTBBJ0CYX	2026-01-08 03:56:58.098-08	2026-01-08 03:56:58.098-08	\N
so_01KEEQF4VJ9ZM0SA693S37VF0R	Express Shipping	flat	serzo_01KEEQF4TDQSTDWZPATQSFCW5T	sp_01KEEQF0XXYA28B4MDY6JW7H76	manual_manual	\N	\N	sotype_01KEEQF4VJF4Y9DMCPMY7D7H7F	2026-01-08 03:56:58.098-08	2026-01-08 03:56:58.098-08	\N
\.


--
-- Data for Name: shipping_option_price_set; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.shipping_option_price_set (shipping_option_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
so_01KEEQF4VJRE372E61E8K0FZT3	pset_01KEEQF4VXZ5K5G2V53N5S6VH8	sops_01KEEQF4X903VMYDEHTPR6M6J3	2026-01-08 03:56:58.152925-08	2026-01-08 03:56:58.152925-08	\N
so_01KEEQF4VJ9ZM0SA693S37VF0R	pset_01KEEQF4VYC7XZFTP0CTTAVPBA	sops_01KEEQF4X9TQADFMGN1C03E78W	2026-01-08 03:56:58.152925-08	2026-01-08 03:56:58.152925-08	\N
\.


--
-- Data for Name: shipping_option_rule; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.shipping_option_rule (id, attribute, operator, value, shipping_option_id, created_at, updated_at, deleted_at) FROM stdin;
sorul_01KEEQF4VJ8X83ABH5ZD73A2ZK	enabled_in_store	eq	"true"	so_01KEEQF4VJRE372E61E8K0FZT3	2026-01-08 03:56:58.098-08	2026-01-08 03:56:58.098-08	\N
sorul_01KEEQF4VJ146DN5XD03K3EFFR	is_return	eq	"false"	so_01KEEQF4VJRE372E61E8K0FZT3	2026-01-08 03:56:58.099-08	2026-01-08 03:56:58.099-08	\N
sorul_01KEEQF4VJX8ZM55V5QQRDNACA	enabled_in_store	eq	"true"	so_01KEEQF4VJ9ZM0SA693S37VF0R	2026-01-08 03:56:58.099-08	2026-01-08 03:56:58.099-08	\N
sorul_01KEEQF4VJEEWXXK4WNP2Y5Y89	is_return	eq	"false"	so_01KEEQF4VJ9ZM0SA693S37VF0R	2026-01-08 03:56:58.099-08	2026-01-08 03:56:58.099-08	\N
\.


--
-- Data for Name: shipping_option_type; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.shipping_option_type (id, label, description, code, created_at, updated_at, deleted_at) FROM stdin;
sotype_01KEEQF4VJ5JNGJ67QTBBJ0CYX	Standard	Ship in 2-3 days.	standard	2026-01-08 03:56:58.098-08	2026-01-08 03:56:58.098-08	\N
sotype_01KEEQF4VJF4Y9DMCPMY7D7H7F	Express	Ship in 24 hours.	express	2026-01-08 03:56:58.098-08	2026-01-08 03:56:58.098-08	\N
\.


--
-- Data for Name: shipping_profile; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.shipping_profile (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
sp_01KEEQF0XXYA28B4MDY6JW7H76	Default Shipping Profile	default	\N	2026-01-08 03:56:54.077-08	2026-01-08 03:56:54.077-08	\N
\.


--
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.sites (id, handle, merchant_id, sales_channel_id, status, created_at) FROM stdin;
\.


--
-- Data for Name: stock_location; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.stock_location (id, created_at, updated_at, deleted_at, name, address_id, metadata) FROM stdin;
sloc_01KEEQF4SSX9F3AERPW5A4GJYM	2026-01-08 03:56:58.042-08	2026-01-08 03:56:58.042-08	\N	European Warehouse	laddr_01KEEQF4SS4JZZ9ZT44657R6BY	\N
\.


--
-- Data for Name: stock_location_address; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.stock_location_address (id, created_at, updated_at, deleted_at, address_1, address_2, company, city, country_code, phone, province, postal_code, metadata) FROM stdin;
laddr_01KEEQF4SS4JZZ9ZT44657R6BY	2026-01-08 03:56:58.041-08	2026-01-08 03:56:58.041-08	\N		\N	\N	Copenhagen	DK	\N	\N	\N	\N
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.store (id, name, default_sales_channel_id, default_region_id, default_location_id, metadata, created_at, updated_at, deleted_at, handle) FROM stdin;
store_01KFZK56F9TFC90DFYPTN4GHFP	Medusa Store	sc_01KFZK56EYXWNSVK65K2C155N5	reg_01KEEQF4RSEDQ5HA5ZQ1DBT449	sloc_01KEEQF4SSX9F3AERPW5A4GJYM	\N	2026-01-27 03:24:24.936403-08	2026-01-27 03:24:24.936403-08	\N	\N
store_01KG4QBSW9HCD22TYA0TJ71YH4	Merchant One Store	\N	\N	\N	\N	2026-01-29 03:14:07.880033-08	2026-01-29 03:14:07.880033-08	\N	\N
store_01KG4V8WYPNDJTWCG75CDXDT9F	Isolation Test Store	\N	\N	\N	\N	2026-01-29 04:22:27.01392-08	2026-01-29 04:22:27.01392-08	\N	\N
store_01KG79VB13CXM32NDJJ7D92E5Y	Test Merchant 2 Store	\N	\N	\N	\N	2026-01-30 03:15:40.173342-08	2026-01-30 03:15:40.173342-08	\N	\N
store_01KG7A6DNSX33MZ5SYE87AK1WD	Iso Store 1	\N	\N	\N	\N	2026-01-30 03:21:43.348357-08	2026-01-30 03:21:43.348357-08	\N	\N
\.


--
-- Data for Name: store_currency; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.store_currency (id, currency_code, is_default, store_id, created_at, updated_at, deleted_at) FROM stdin;
stocur_01KFZZRSKWR2YYE0TVTQ3JC2SV	eur	t	store_01KFZK56F9TFC90DFYPTN4GHFP	2026-01-27 07:04:50.036803-08	2026-01-27 07:04:50.036803-08	\N
\.


--
-- Data for Name: store_locale; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.store_locale (id, locale_code, store_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_provider; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.tax_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
tp_system	t	2026-01-08 03:56:53.609-08	2026-01-08 03:56:53.609-08	\N
\.


--
-- Data for Name: tax_rate; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.tax_rate (id, rate, code, name, is_default, is_combinable, tax_region_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_rate_rule; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.tax_rate_rule (id, tax_rate_id, reference_id, reference, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_region; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.tax_region (id, provider_id, country_code, province_code, parent_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txreg_01KEEQF4SHK5SY552RC012ACRT	tp_system	gb	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
txreg_01KEEQF4SHGPNETH24SG8PEQ6G	tp_system	de	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
txreg_01KEEQF4SH2027GYN9QH1RD8WV	tp_system	dk	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
txreg_01KEEQF4SHN0GWYFK1TG0VCKY7	tp_system	se	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
txreg_01KEEQF4SH0KXS44FPDY6G2MGB	tp_system	fr	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
txreg_01KEEQF4SHDW7BFZG7E6XJTRVE	tp_system	es	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
txreg_01KEEQF4SHQV3ESJ5HZE0VAHE5	tp_system	it	\N	\N	\N	2026-01-08 03:56:58.033-08	2026-01-08 03:56:58.033-08	\N	\N
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public."user" (id, first_name, last_name, email, avatar_url, metadata, created_at, updated_at, deleted_at) FROM stdin;
user_01KEEQGY53Q28HW9SSFY87F4S6	Leslie	Aine	aineleslie@gmail.com	\N	\N	2026-01-08 03:57:56.771-08	2026-01-08 03:57:56.771-08	\N
user_01KFZZM8KB8H1FH09QBDMWSFZN	\N	\N	admin@local.dev	\N	\N	2026-01-27 07:02:21.548-08	2026-01-27 07:02:21.548-08	\N
user_01KG4CZ37N7J5E1Q6GQNCXB7NR	\N	\N	merchant@test.com	\N	\N	2026-01-29 00:12:25.717-08	2026-01-29 00:12:25.717-08	\N
\.


--
-- Data for Name: user_preference; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.user_preference (id, user_id, key, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: view_configuration; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.view_configuration (id, entity, name, user_id, is_system_default, configuration, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: workflow_execution; Type: TABLE DATA; Schema: public; Owner: leslieaine
--

COPY public.workflow_execution (id, workflow_id, transaction_id, execution, context, state, created_at, updated_at, deleted_at, retention_time, run_id) FROM stdin;
\.


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.link_module_migrations_id_seq', 90, true);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.mikro_orm_migrations_id_seq', 159, true);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.order_change_action_ordering_seq', 1, true);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.order_claim_display_id_seq', 1, false);


--
-- Name: order_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.order_display_id_seq', 9, true);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.order_exchange_display_id_seq', 1, false);


--
-- Name: return_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.return_display_id_seq', 1, false);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: leslieaine
--

SELECT pg_catalog.setval('public.script_migrations_id_seq', 2, true);


--
-- Name: account_holder account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT account_holder_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: application_method_buy_rules application_method_buy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: application_method_target_rules application_method_target_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY (id);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item cart_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: cart_payment_collection cart_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_payment_collection
    ADD CONSTRAINT cart_payment_collection_pkey PRIMARY KEY (cart_id, payment_collection_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_promotion cart_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_promotion
    ADD CONSTRAINT cart_promotion_pkey PRIMARY KEY (cart_id, promotion_id);


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method cart_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: credit_line credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_pkey PRIMARY KEY (id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (code);


--
-- Name: customer_account_holder customer_account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_account_holder
    ADD CONSTRAINT customer_account_holder_pkey PRIMARY KEY (customer_id, account_holder_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (id);


--
-- Name: customer_group_customer customer_group_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_pkey PRIMARY KEY (id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_address fulfillment_address_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_address
    ADD CONSTRAINT fulfillment_address_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_item fulfillment_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_label fulfillment_label_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_pkey PRIMARY KEY (id);


--
-- Name: fulfillment fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_provider fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT fulfillment_provider_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_set fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_set
    ADD CONSTRAINT fulfillment_set_pkey PRIMARY KEY (id);


--
-- Name: geo_zone geo_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: inventory_level inventory_level_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_pkey PRIMARY KEY (id);


--
-- Name: invite invite_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_table_name_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_table_name_key UNIQUE (table_name);


--
-- Name: location_fulfillment_provider location_fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.location_fulfillment_provider
    ADD CONSTRAINT location_fulfillment_provider_pkey PRIMARY KEY (stock_location_id, fulfillment_provider_id);


--
-- Name: location_fulfillment_set location_fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.location_fulfillment_set
    ADD CONSTRAINT location_fulfillment_set_pkey PRIMARY KEY (stock_location_id, fulfillment_set_id);


--
-- Name: merchant_auth_identity merchant_auth_identity_auth_identity_id_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_auth_identity
    ADD CONSTRAINT merchant_auth_identity_auth_identity_id_key UNIQUE (auth_identity_id);


--
-- Name: merchant_auth_identity merchant_auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_auth_identity
    ADD CONSTRAINT merchant_auth_identity_pkey PRIMARY KEY (id);


--
-- Name: merchant_categories merchant_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_categories
    ADD CONSTRAINT merchant_categories_pkey PRIMARY KEY (id);


--
-- Name: merchant_categories merchant_categories_sales_channel_id_handle_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_categories
    ADD CONSTRAINT merchant_categories_sales_channel_id_handle_key UNIQUE (sales_channel_id, handle);


--
-- Name: merchant_category_products merchant_category_products_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_category_products
    ADD CONSTRAINT merchant_category_products_pkey PRIMARY KEY (category_id, product_id);


--
-- Name: merchant_collection_products merchant_collection_products_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_collection_products
    ADD CONSTRAINT merchant_collection_products_pkey PRIMARY KEY (collection_id, product_id);


--
-- Name: merchant_collections merchant_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_collections
    ADD CONSTRAINT merchant_collections_pkey PRIMARY KEY (id);


--
-- Name: merchant_collections merchant_collections_sales_channel_id_handle_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_collections
    ADD CONSTRAINT merchant_collections_sales_channel_id_handle_key UNIQUE (sales_channel_id, handle);


--
-- Name: merchant merchant_email_unique; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_email_unique UNIQUE (email);


--
-- Name: merchant merchant_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_pkey PRIMARY KEY (id);


--
-- Name: merchant_store merchant_store_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_store
    ADD CONSTRAINT merchant_store_pkey PRIMARY KEY (id);


--
-- Name: merchant merchant_store_unique; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_store_unique UNIQUE (store_id);


--
-- Name: merchant_user merchant_user_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_user
    ADD CONSTRAINT merchant_user_pkey PRIMARY KEY (id);


--
-- Name: merchants merchants_email_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_email_key UNIQUE (email);


--
-- Name: merchants merchants_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_pkey PRIMARY KEY (id);


--
-- Name: mikro_orm_migrations mikro_orm_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.mikro_orm_migrations
    ADD CONSTRAINT mikro_orm_migrations_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_provider notification_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT notification_provider_pkey PRIMARY KEY (id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (id);


--
-- Name: order_cart order_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_cart
    ADD CONSTRAINT order_cart_pkey PRIMARY KEY (order_id, cart_id);


--
-- Name: order_change_action order_change_action_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_pkey PRIMARY KEY (id);


--
-- Name: order_change order_change_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item_image order_claim_item_image_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_claim_item_image
    ADD CONSTRAINT order_claim_item_image_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item order_claim_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_claim_item
    ADD CONSTRAINT order_claim_item_pkey PRIMARY KEY (id);


--
-- Name: order_claim order_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_claim
    ADD CONSTRAINT order_claim_pkey PRIMARY KEY (id);


--
-- Name: order_credit_line order_credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_pkey PRIMARY KEY (id);


--
-- Name: order_exchange_item order_exchange_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_exchange_item
    ADD CONSTRAINT order_exchange_item_pkey PRIMARY KEY (id);


--
-- Name: order_exchange order_exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_exchange
    ADD CONSTRAINT order_exchange_pkey PRIMARY KEY (id);


--
-- Name: order_fulfillment order_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_fulfillment
    ADD CONSTRAINT order_fulfillment_pkey PRIMARY KEY (order_id, fulfillment_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_adjustment order_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_line_item order_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_tax_line order_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_payment_collection order_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_payment_collection
    ADD CONSTRAINT order_payment_collection_pkey PRIMARY KEY (order_id, payment_collection_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_promotion order_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_promotion
    ADD CONSTRAINT order_promotion_pkey PRIMARY KEY (order_id, promotion_id);


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method order_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping_method
    ADD CONSTRAINT order_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_shipping order_shipping_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_pkey PRIMARY KEY (id);


--
-- Name: order_summary order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_pkey PRIMARY KEY (id);


--
-- Name: order_transaction order_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_pkey PRIMARY KEY (id);


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_pkey PRIMARY KEY (payment_collection_id, payment_provider_id);


--
-- Name: payment_collection payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_collection
    ADD CONSTRAINT payment_collection_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_provider payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT payment_provider_pkey PRIMARY KEY (id);


--
-- Name: payment_session payment_session_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_pkey PRIMARY KEY (id);


--
-- Name: price_list price_list_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT price_list_pkey PRIMARY KEY (id);


--
-- Name: price_list_rule price_list_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_pkey PRIMARY KEY (id);


--
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (id);


--
-- Name: price_preference price_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_preference
    ADD CONSTRAINT price_preference_pkey PRIMARY KEY (id);


--
-- Name: price_rule price_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_pkey PRIMARY KEY (id);


--
-- Name: price_set price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_set
    ADD CONSTRAINT price_set_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_category_product product_category_product_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_pkey PRIMARY KEY (product_id, product_category_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (id);


--
-- Name: product_option product_option_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_pkey PRIMARY KEY (id);


--
-- Name: product_option_value product_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sales_channel product_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT product_sales_channel_pkey PRIMARY KEY (product_id, sales_channel_id);


--
-- Name: product_shipping_profile product_shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_shipping_profile
    ADD CONSTRAINT product_shipping_profile_pkey PRIMARY KEY (product_id, shipping_profile_id);


--
-- Name: product_tag product_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT product_tag_pkey PRIMARY KEY (id);


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_pkey PRIMARY KEY (product_id, product_tag_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);


--
-- Name: product_variant_inventory_item product_variant_inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_inventory_item
    ADD CONSTRAINT product_variant_inventory_item_pkey PRIMARY KEY (variant_id, inventory_item_id);


--
-- Name: product_variant_option product_variant_option_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_pkey PRIMARY KEY (variant_id, option_value_id);


--
-- Name: product_variant product_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_pkey PRIMARY KEY (id);


--
-- Name: product_variant_price_set product_variant_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_price_set
    ADD CONSTRAINT product_variant_price_set_pkey PRIMARY KEY (variant_id, price_set_id);


--
-- Name: product_variant_product_image product_variant_product_image_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_pkey PRIMARY KEY (id);


--
-- Name: promotion_application_method promotion_application_method_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget promotion_campaign_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign promotion_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_campaign
    ADD CONSTRAINT promotion_campaign_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: promotion_promotion_rule promotion_promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_pkey PRIMARY KEY (promotion_id, promotion_rule_id);


--
-- Name: promotion_rule promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_rule
    ADD CONSTRAINT promotion_rule_pkey PRIMARY KEY (id);


--
-- Name: promotion_rule_value promotion_rule_value_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_pkey PRIMARY KEY (id);


--
-- Name: provider_identity provider_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_pkey PRIMARY KEY (id);


--
-- Name: publishable_api_key_sales_channel publishable_api_key_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.publishable_api_key_sales_channel
    ADD CONSTRAINT publishable_api_key_sales_channel_pkey PRIMARY KEY (publishable_key_id, sales_channel_id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: refund_reason refund_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.refund_reason
    ADD CONSTRAINT refund_reason_pkey PRIMARY KEY (id);


--
-- Name: region_country region_country_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_pkey PRIMARY KEY (iso_2);


--
-- Name: region_payment_provider region_payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.region_payment_provider
    ADD CONSTRAINT region_payment_provider_pkey PRIMARY KEY (region_id, payment_provider_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: reservation_item reservation_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_pkey PRIMARY KEY (id);


--
-- Name: return_fulfillment return_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.return_fulfillment
    ADD CONSTRAINT return_fulfillment_pkey PRIMARY KEY (return_id, fulfillment_id);


--
-- Name: return_item return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT return_item_pkey PRIMARY KEY (id);


--
-- Name: return return_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (id);


--
-- Name: return_reason return_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_pkey PRIMARY KEY (id);


--
-- Name: sales_channel sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT sales_channel_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_stock_location sales_channel_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.sales_channel_stock_location
    ADD CONSTRAINT sales_channel_stock_location_pkey PRIMARY KEY (sales_channel_id, stock_location_id);


--
-- Name: script_migrations script_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.script_migrations
    ADD CONSTRAINT script_migrations_pkey PRIMARY KEY (id);


--
-- Name: service_zone service_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_pkey PRIMARY KEY (id);


--
-- Name: shipping_option shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_price_set shipping_option_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option_price_set
    ADD CONSTRAINT shipping_option_price_set_pkey PRIMARY KEY (shipping_option_id, price_set_id);


--
-- Name: shipping_option_rule shipping_option_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_type shipping_option_type_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option_type
    ADD CONSTRAINT shipping_option_type_pkey PRIMARY KEY (id);


--
-- Name: shipping_profile shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT shipping_profile_pkey PRIMARY KEY (id);


--
-- Name: sites sites_handle_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_handle_key UNIQUE (handle);


--
-- Name: sites sites_merchant_id_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_merchant_id_key UNIQUE (merchant_id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: stock_location_address stock_location_address_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.stock_location_address
    ADD CONSTRAINT stock_location_address_pkey PRIMARY KEY (id);


--
-- Name: stock_location stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_pkey PRIMARY KEY (id);


--
-- Name: store_currency store_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_pkey PRIMARY KEY (id);


--
-- Name: store store_handle_key; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_handle_key UNIQUE (handle);


--
-- Name: store_locale store_locale_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_pkey PRIMARY KEY (id);


--
-- Name: store store_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);


--
-- Name: tax_provider tax_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT tax_provider_pkey PRIMARY KEY (id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (id);


--
-- Name: tax_rate_rule tax_rate_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT tax_rate_rule_pkey PRIMARY KEY (id);


--
-- Name: tax_region tax_region_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT tax_region_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_preference user_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.user_preference
    ADD CONSTRAINT user_preference_pkey PRIMARY KEY (id);


--
-- Name: view_configuration view_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.view_configuration
    ADD CONSTRAINT view_configuration_pkey PRIMARY KEY (id);


--
-- Name: workflow_execution workflow_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.workflow_execution
    ADD CONSTRAINT workflow_execution_pkey PRIMARY KEY (workflow_id, transaction_id, run_id);


--
-- Name: IDX_account_holder_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_account_holder_deleted_at" ON public.account_holder USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_account_holder_id_5cb3a0c0" ON public.customer_account_holder USING btree (account_holder_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_provider_id_external_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_account_holder_provider_id_external_id_unique" ON public.account_holder USING btree (provider_id, external_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_api_key_deleted_at" ON public.api_key USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_redacted; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_api_key_redacted" ON public.api_key USING btree (redacted) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_revoked_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_api_key_revoked_at" ON public.api_key USING btree (revoked_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_token_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_api_key_token_unique" ON public.api_key USING btree (token);


--
-- Name: IDX_api_key_type; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_api_key_type" ON public.api_key USING btree (type);


--
-- Name: IDX_application_method_allocation; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_application_method_allocation" ON public.promotion_application_method USING btree (allocation);


--
-- Name: IDX_application_method_target_type; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_application_method_target_type" ON public.promotion_application_method USING btree (target_type);


--
-- Name: IDX_application_method_type; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_application_method_type" ON public.promotion_application_method USING btree (type);


--
-- Name: IDX_auth_identity_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_auth_identity_deleted_at" ON public.auth_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_campaign_budget_type; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_campaign_budget_type" ON public.promotion_campaign_budget USING btree (type);


--
-- Name: IDX_capture_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_capture_deleted_at" ON public.capture USING btree (deleted_at);


--
-- Name: IDX_capture_payment_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_capture_payment_id" ON public.capture USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_address_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_address_deleted_at" ON public.cart_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_billing_address_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_billing_address_id" ON public.cart USING btree (billing_address_id) WHERE ((deleted_at IS NULL) AND (billing_address_id IS NOT NULL));


--
-- Name: IDX_cart_credit_line_reference_reference_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_credit_line_reference_reference_id" ON public.credit_line USING btree (reference, reference_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_currency_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_currency_code" ON public.cart USING btree (currency_code);


--
-- Name: IDX_cart_customer_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_customer_id" ON public.cart USING btree (customer_id) WHERE ((deleted_at IS NULL) AND (customer_id IS NOT NULL));


--
-- Name: IDX_cart_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_deleted_at" ON public.cart USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_id_-4a39f6c9" ON public.cart_payment_collection USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-71069c16; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_id_-71069c16" ON public.order_cart USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_id_-a9d4a70b" ON public.cart_promotion USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_line_item_adjustment_deleted_at" ON public.cart_line_item_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_line_item_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_cart_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_line_item_deleted_at" ON public.cart_line_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_line_item_tax_line_deleted_at" ON public.cart_line_item_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_line_item_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_region_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_region_id" ON public.cart USING btree (region_id) WHERE ((deleted_at IS NULL) AND (region_id IS NOT NULL));


--
-- Name: IDX_cart_sales_channel_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_sales_channel_id" ON public.cart USING btree (sales_channel_id) WHERE ((deleted_at IS NULL) AND (sales_channel_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_address_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_address_id" ON public.cart USING btree (shipping_address_id) WHERE ((deleted_at IS NULL) AND (shipping_address_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_method_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_deleted_at" ON public.cart_shipping_method_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_method_deleted_at" ON public.cart_shipping_method USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_deleted_at" ON public.cart_shipping_method_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_category_handle_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_category_handle_unique" ON public.product_category USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_collection_handle_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_collection_handle_unique" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_cart_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_credit_line_cart_id" ON public.credit_line USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_credit_line_deleted_at" ON public.credit_line USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_customer_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_address_customer_id" ON public.customer_address USING btree (customer_id);


--
-- Name: IDX_customer_address_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_address_deleted_at" ON public.customer_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_unique_customer_billing; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_billing" ON public.customer_address USING btree (customer_id) WHERE (is_default_billing = true);


--
-- Name: IDX_customer_address_unique_customer_shipping; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_shipping" ON public.customer_address USING btree (customer_id) WHERE (is_default_shipping = true);


--
-- Name: IDX_customer_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_deleted_at" ON public.customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_email_has_account_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_customer_email_has_account_unique" ON public.customer USING btree (email, has_account) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_group_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_group_customer_customer_group_id" ON public.customer_group_customer USING btree (customer_group_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_group_customer_customer_id" ON public.customer_group_customer USING btree (customer_id);


--
-- Name: IDX_customer_group_customer_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_group_customer_deleted_at" ON public.customer_group_customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_group_deleted_at" ON public.customer_group USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_customer_group_name_unique" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_customer_id_5cb3a0c0" ON public.customer_account_holder USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_deleted_at_-1d67bae40; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1e5992737; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-1e5992737" ON public.location_fulfillment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-31ea43a; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-31ea43a" ON public.return_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-4a39f6c9; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-4a39f6c9" ON public.cart_payment_collection USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71069c16; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-71069c16" ON public.order_cart USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71518339; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-71518339" ON public.order_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-a9d4a70b; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-a9d4a70b" ON public.cart_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e88adb96; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-e88adb96" ON public.location_fulfillment_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e8d2543e; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_-e8d2543e" ON public.order_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17a262437; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_17a262437" ON public.product_shipping_profile USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17b4c4e35; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_17b4c4e35" ON public.product_variant_inventory_item USING btree (deleted_at);


--
-- Name: IDX_deleted_at_1c934dab0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_1c934dab0" ON public.region_payment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_20b454295; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_20b454295" ON public.product_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_26d06f470; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_26d06f470" ON public.sales_channel_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_52b23597; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_52b23597" ON public.product_variant_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_5cb3a0c0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_5cb3a0c0" ON public.customer_account_holder USING btree (deleted_at);


--
-- Name: IDX_deleted_at_ba32fa9c; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_ba32fa9c" ON public.shipping_option_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_f42b9949; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_deleted_at_f42b9949" ON public.order_payment_collection USING btree (deleted_at);


--
-- Name: IDX_fulfillment_address_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_address_deleted_at" ON public.fulfillment_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_deleted_at" ON public.fulfillment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_id_-31ea43a; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_id_-31ea43a" ON public.return_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_id_-e8d2543e; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_id_-e8d2543e" ON public.order_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_item_deleted_at" ON public.fulfillment_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_item_fulfillment_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_item_fulfillment_id" ON public.fulfillment_item USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_inventory_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_item_inventory_item_id" ON public.fulfillment_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_line_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_item_line_item_id" ON public.fulfillment_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_label_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_label_deleted_at" ON public.fulfillment_label USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_label_fulfillment_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_label_fulfillment_id" ON public.fulfillment_label USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_location_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_location_id" ON public.fulfillment USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_provider_deleted_at" ON public.fulfillment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_id_-1e5992737; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_provider_id_-1e5992737" ON public.location_fulfillment_provider USING btree (fulfillment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_set_deleted_at" ON public.fulfillment_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_set_id_-e88adb96; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_set_id_-e88adb96" ON public.location_fulfillment_set USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_name_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_fulfillment_set_name_unique" ON public.fulfillment_set USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_shipping_option_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_fulfillment_shipping_option_id" ON public.fulfillment USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_city; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_geo_zone_city" ON public.geo_zone USING btree (city) WHERE ((deleted_at IS NULL) AND (city IS NOT NULL));


--
-- Name: IDX_geo_zone_country_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_geo_zone_country_code" ON public.geo_zone USING btree (country_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_geo_zone_deleted_at" ON public.geo_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_geo_zone_province_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_geo_zone_province_code" ON public.geo_zone USING btree (province_code) WHERE ((deleted_at IS NULL) AND (province_code IS NOT NULL));


--
-- Name: IDX_geo_zone_service_zone_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_geo_zone_service_zone_id" ON public.geo_zone USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_id_-1d67bae40; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (id);


--
-- Name: IDX_id_-1e5992737; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-1e5992737" ON public.location_fulfillment_provider USING btree (id);


--
-- Name: IDX_id_-31ea43a; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-31ea43a" ON public.return_fulfillment USING btree (id);


--
-- Name: IDX_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-4a39f6c9" ON public.cart_payment_collection USING btree (id);


--
-- Name: IDX_id_-71069c16; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-71069c16" ON public.order_cart USING btree (id);


--
-- Name: IDX_id_-71518339; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-71518339" ON public.order_promotion USING btree (id);


--
-- Name: IDX_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-a9d4a70b" ON public.cart_promotion USING btree (id);


--
-- Name: IDX_id_-e88adb96; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-e88adb96" ON public.location_fulfillment_set USING btree (id);


--
-- Name: IDX_id_-e8d2543e; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_-e8d2543e" ON public.order_fulfillment USING btree (id);


--
-- Name: IDX_id_17a262437; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_17a262437" ON public.product_shipping_profile USING btree (id);


--
-- Name: IDX_id_17b4c4e35; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (id);


--
-- Name: IDX_id_1c934dab0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_1c934dab0" ON public.region_payment_provider USING btree (id);


--
-- Name: IDX_id_20b454295; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_20b454295" ON public.product_sales_channel USING btree (id);


--
-- Name: IDX_id_26d06f470; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_26d06f470" ON public.sales_channel_stock_location USING btree (id);


--
-- Name: IDX_id_52b23597; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_52b23597" ON public.product_variant_price_set USING btree (id);


--
-- Name: IDX_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_5cb3a0c0" ON public.customer_account_holder USING btree (id);


--
-- Name: IDX_id_ba32fa9c; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_ba32fa9c" ON public.shipping_option_price_set USING btree (id);


--
-- Name: IDX_id_f42b9949; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_id_f42b9949" ON public.order_payment_collection USING btree (id);


--
-- Name: IDX_image_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_image_deleted_at" ON public.image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_image_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_image_product_id" ON public.image USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_inventory_item_deleted_at" ON public.inventory_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_item_id_17b4c4e35; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_inventory_item_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_sku; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_inventory_item_sku" ON public.inventory_item USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_inventory_level_deleted_at" ON public.inventory_level USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_level_inventory_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_inventory_level_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_inventory_level_location_id" ON public.inventory_level USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id_inventory_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_inventory_level_location_id_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_invite_deleted_at" ON public.invite USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_invite_email_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_invite_email_unique" ON public.invite USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_token; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_invite_token" ON public.invite USING btree (token) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_line_item_adjustment_promotion_id" ON public.cart_line_item_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_line_item_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_line_item_product_id" ON public.cart_line_item USING btree (product_id) WHERE ((deleted_at IS NULL) AND (product_id IS NOT NULL));


--
-- Name: IDX_line_item_product_type_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_line_item_product_type_id" ON public.order_line_item USING btree (product_type_id) WHERE ((deleted_at IS NULL) AND (product_type_id IS NOT NULL));


--
-- Name: IDX_line_item_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_line_item_tax_line_tax_rate_id" ON public.cart_line_item_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_line_item_variant_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_line_item_variant_id" ON public.cart_line_item USING btree (variant_id) WHERE ((deleted_at IS NULL) AND (variant_id IS NOT NULL));


--
-- Name: IDX_merchant_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_merchant_deleted_at" ON public.merchant USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_merchant_email_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_merchant_email_unique" ON public.merchant USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_notification_deleted_at" ON public.notification USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_idempotency_key_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_notification_idempotency_key_unique" ON public.notification USING btree (idempotency_key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_notification_provider_deleted_at" ON public.notification_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_notification_provider_id" ON public.notification USING btree (provider_id);


--
-- Name: IDX_notification_receiver_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_notification_receiver_id" ON public.notification USING btree (receiver_id);


--
-- Name: IDX_option_product_id_title_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_option_product_id_title_unique" ON public.product_option USING btree (product_id, title) WHERE (deleted_at IS NULL);


--
-- Name: IDX_option_value_option_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_option_value_option_id_unique" ON public.product_option_value USING btree (option_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_address_customer_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_address_customer_id" ON public.order_address USING btree (customer_id);


--
-- Name: IDX_order_address_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_address_deleted_at" ON public.order_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_billing_address_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_billing_address_id" ON public."order" USING btree (billing_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_claim_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_claim_id" ON public.order_change_action USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_deleted_at" ON public.order_change_action USING btree (deleted_at);


--
-- Name: IDX_order_change_action_exchange_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_exchange_id" ON public.order_change_action USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_order_change_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_order_change_id" ON public.order_change_action USING btree (order_change_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_order_id" ON public.order_change_action USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_ordering; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_ordering" ON public.order_change_action USING btree (ordering) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_action_return_id" ON public.order_change_action USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_change_type; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_change_type" ON public.order_change USING btree (change_type);


--
-- Name: IDX_order_change_claim_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_claim_id" ON public.order_change USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_deleted_at" ON public.order_change USING btree (deleted_at);


--
-- Name: IDX_order_change_exchange_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_exchange_id" ON public.order_change USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_order_id" ON public.order_change USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_order_id_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_order_id_version" ON public.order_change USING btree (order_id, version);


--
-- Name: IDX_order_change_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_return_id" ON public.order_change USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_status; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_status" ON public.order_change USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_change_version" ON public.order_change USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_deleted_at" ON public.order_claim USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_display_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_display_id" ON public.order_claim USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_claim_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_item_claim_id" ON public.order_claim_item USING btree (claim_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_item_deleted_at" ON public.order_claim_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_claim_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_item_image_claim_item_id" ON public.order_claim_item_image USING btree (claim_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_item_image_deleted_at" ON public.order_claim_item_image USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_item_item_id" ON public.order_claim_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_order_id" ON public.order_claim USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_claim_return_id" ON public.order_claim USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_credit_line_deleted_at" ON public.order_credit_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_credit_line_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_credit_line_order_id" ON public.order_credit_line USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_credit_line_order_id_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_credit_line_order_id_version" ON public.order_credit_line USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_currency_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_currency_code" ON public."order" USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_custom_display_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_order_custom_display_id" ON public."order" USING btree (custom_display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_customer_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_customer_id" ON public."order" USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_deleted_at" ON public."order" USING btree (deleted_at);


--
-- Name: IDX_order_display_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_display_id" ON public."order" USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_deleted_at" ON public.order_exchange USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_display_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_display_id" ON public.order_exchange USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_item_deleted_at" ON public.order_exchange_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_exchange_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_item_exchange_id" ON public.order_exchange_item USING btree (exchange_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_item_item_id" ON public.order_exchange_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_order_id" ON public.order_exchange USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_exchange_return_id" ON public.order_exchange USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_id_-71069c16; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_id_-71069c16" ON public.order_cart USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-71518339; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_id_-71518339" ON public.order_promotion USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-e8d2543e; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_id_-e8d2543e" ON public.order_fulfillment USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_f42b9949; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_id_f42b9949" ON public.order_payment_collection USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_is_draft_order; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_is_draft_order" ON public."order" USING btree (is_draft_order) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_item_deleted_at" ON public.order_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_item_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_item_item_id" ON public.order_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_item_order_id" ON public.order_item USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_item_order_id_version" ON public.order_item USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_line_item_adjustment_item_id" ON public.order_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_line_item_product_id" ON public.order_line_item USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_line_item_tax_line_item_id" ON public.order_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_variant_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_line_item_variant_id" ON public.order_line_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_region_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_region_id" ON public."order" USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_sales_channel_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_sales_channel_id" ON public."order" USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_address_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_address_id" ON public."order" USING btree (shipping_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_claim_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_claim_id" ON public.order_shipping USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_deleted_at" ON public.order_shipping USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_shipping_exchange_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_exchange_id" ON public.order_shipping USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_item_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_method_adjustment_shipping_method_id" ON public.order_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_shipping_option_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_method_shipping_option_id" ON public.order_shipping_method USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_method_tax_line_shipping_method_id" ON public.order_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_order_id" ON public.order_shipping USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_order_id_version" ON public.order_shipping USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_return_id" ON public.order_shipping USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_shipping_method_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_shipping_shipping_method_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_summary_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_summary_deleted_at" ON public.order_summary USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_summary_order_id_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_summary_order_id_version" ON public.order_summary USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_claim_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_claim_id" ON public.order_transaction USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_currency_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_currency_code" ON public.order_transaction USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_exchange_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_exchange_id" ON public.order_transaction USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_order_id" ON public.order_transaction USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_order_id_version; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_order_id_version" ON public.order_transaction USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_reference_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_reference_id" ON public.order_transaction USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_order_transaction_return_id" ON public.order_transaction USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_payment_collection_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_collection_deleted_at" ON public.payment_collection USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_collection_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_collection_id_-4a39f6c9" ON public.cart_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_collection_id_f42b9949; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_collection_id_f42b9949" ON public.order_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_deleted_at" ON public.payment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_payment_collection_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_payment_collection_id" ON public.payment USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_payment_session_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_payment_session_id" ON public.payment USING btree (payment_session_id);


--
-- Name: IDX_payment_payment_session_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_payment_payment_session_id_unique" ON public.payment USING btree (payment_session_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_provider_deleted_at" ON public.payment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_provider_id" ON public.payment USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id_1c934dab0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_provider_id_1c934dab0" ON public.region_payment_provider USING btree (payment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_session_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_session_deleted_at" ON public.payment_session USING btree (deleted_at);


--
-- Name: IDX_payment_session_payment_collection_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_payment_session_payment_collection_id" ON public.payment_session USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_currency_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_currency_code" ON public.price USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_deleted_at" ON public.price USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_list_deleted_at" ON public.price_list USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_id_status_starts_at_ends_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_list_id_status_starts_at_ends_at" ON public.price_list USING btree (id, status, starts_at, ends_at) WHERE ((deleted_at IS NULL) AND (status = 'active'::text));


--
-- Name: IDX_price_list_rule_attribute; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_list_rule_attribute" ON public.price_list_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_list_rule_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_list_rule_deleted_at" ON public.price_list_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_price_list_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_list_rule_price_list_id" ON public.price_list_rule USING btree (price_list_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_list_rule_value" ON public.price_list_rule USING gin (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_attribute_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_price_preference_attribute_value" ON public.price_preference USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_preference_deleted_at" ON public.price_preference USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_price_list_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_price_list_id" ON public.price USING btree (price_list_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_price_set_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_price_set_id" ON public.price USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_attribute" ON public.price_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_attribute_value" ON public.price_rule USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value_price_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_attribute_value_price_id" ON public.price_rule USING btree (attribute, value, price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_deleted_at" ON public.price_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_rule_operator; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_operator" ON public.price_rule USING btree (operator);


--
-- Name: IDX_price_rule_operator_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_operator_value" ON public.price_rule USING btree (operator, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_rule_price_id" ON public.price_rule USING btree (price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id_attribute_operator_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_price_rule_price_id_attribute_operator_unique" ON public.price_rule USING btree (price_id, attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_set_deleted_at" ON public.price_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_set_id_52b23597; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_set_id_52b23597" ON public.product_variant_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_id_ba32fa9c; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_price_set_id_ba32fa9c" ON public.shipping_option_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_parent_category_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_category_parent_category_id" ON public.product_category USING btree (parent_category_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_path; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_category_path" ON public.product_category USING btree (mpath) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_collection_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_collection_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_collection_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_collection_id" ON public.product USING btree (collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_deleted_at" ON public.product USING btree (deleted_at);


--
-- Name: IDX_product_handle_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_product_handle_unique" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_17a262437; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_id_17a262437" ON public.product_shipping_profile USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_20b454295; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_id_20b454295" ON public.product_sales_channel USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_image_rank" ON public.image USING btree (rank) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_image_rank_product_id" ON public.image USING btree (rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_image_url" ON public.image USING btree (url) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url_rank_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_image_url_rank_product_id" ON public.image USING btree (url, rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_option_deleted_at" ON public.product_option USING btree (deleted_at);


--
-- Name: IDX_product_option_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_option_product_id" ON public.product_option USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_value_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_option_value_deleted_at" ON public.product_option_value USING btree (deleted_at);


--
-- Name: IDX_product_option_value_option_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_option_value_option_id" ON public.product_option_value USING btree (option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_status; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_status" ON public.product USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_tag_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_tag_deleted_at" ON public.product_tag USING btree (deleted_at);


--
-- Name: IDX_product_type_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_type_deleted_at" ON public.product_type USING btree (deleted_at);


--
-- Name: IDX_product_type_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_type_id" ON public.product USING btree (type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_barcode_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_product_variant_barcode_unique" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_variant_deleted_at" ON public.product_variant USING btree (deleted_at);


--
-- Name: IDX_product_variant_ean_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_product_variant_ean_unique" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_id_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_variant_id_product_id" ON public.product_variant USING btree (id, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_variant_product_id" ON public.product_variant USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_variant_product_image_deleted_at" ON public.product_variant_product_image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_image_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_variant_product_image_image_id" ON public.product_variant_product_image USING btree (image_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_variant_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_product_variant_product_image_variant_id" ON public.product_variant_product_image USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_sku_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_product_variant_sku_unique" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_upc_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_product_variant_upc_unique" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_currency_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_application_method_currency_code" ON public.promotion_application_method USING btree (currency_code) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_promotion_application_method_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_application_method_deleted_at" ON public.promotion_application_method USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_promotion_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_promotion_application_method_promotion_id_unique" ON public.promotion_application_method USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_campaign_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_campaign_id_unique" ON public.promotion_campaign_budget USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_campaign_budget_deleted_at" ON public.promotion_campaign_budget USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u" ON public.promotion_campaign_budget_usage USING btree (attribute_value, budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_budget_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_budget_id" ON public.promotion_campaign_budget_usage USING btree (budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_deleted_at" ON public.promotion_campaign_budget_usage USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_campaign_identifier_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_campaign_identifier_unique" ON public.promotion_campaign USING btree (campaign_identifier) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_campaign_deleted_at" ON public.promotion_campaign USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_campaign_id" ON public.promotion USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_deleted_at" ON public.promotion USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-71518339; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_id_-71518339" ON public.order_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_id_-a9d4a70b" ON public.cart_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_is_automatic; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_is_automatic" ON public.promotion USING btree (is_automatic) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_attribute" ON public.promotion_rule USING btree (attribute);


--
-- Name: IDX_promotion_rule_attribute_operator; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_attribute_operator" ON public.promotion_rule USING btree (attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute_operator_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_attribute_operator_id" ON public.promotion_rule USING btree (operator, attribute, id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_deleted_at" ON public.promotion_rule USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_operator; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_operator" ON public.promotion_rule USING btree (operator);


--
-- Name: IDX_promotion_rule_value_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_value_deleted_at" ON public.promotion_rule_value USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_promotion_rule_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_value_promotion_rule_id" ON public.promotion_rule_value USING btree (promotion_rule_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_rule_id_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_value_rule_id_value" ON public.promotion_rule_value USING btree (promotion_rule_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_rule_value_value" ON public.promotion_rule_value USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_status; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_status" ON public.promotion USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_type; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_promotion_type" ON public.promotion USING btree (type);


--
-- Name: IDX_provider_identity_auth_identity_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_provider_identity_auth_identity_id" ON public.provider_identity USING btree (auth_identity_id);


--
-- Name: IDX_provider_identity_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_provider_identity_deleted_at" ON public.provider_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_provider_entity_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_provider_identity_provider_entity_id" ON public.provider_identity USING btree (entity_id, provider);


--
-- Name: IDX_publishable_key_id_-1d67bae40; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_publishable_key_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (publishable_key_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_refund_deleted_at" ON public.refund USING btree (deleted_at);


--
-- Name: IDX_refund_payment_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_refund_payment_id" ON public.refund USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_reason_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_refund_reason_deleted_at" ON public.refund_reason USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_refund_reason_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_refund_refund_reason_id" ON public.refund USING btree (refund_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_region_country_deleted_at" ON public.region_country USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_region_country_region_id" ON public.region_country USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id_iso_2_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_region_country_region_id_iso_2_unique" ON public.region_country USING btree (region_id, iso_2);


--
-- Name: IDX_region_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_region_deleted_at" ON public.region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_region_id_1c934dab0; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_region_id_1c934dab0" ON public.region_payment_provider USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_reservation_item_deleted_at" ON public.reservation_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_reservation_item_inventory_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_reservation_item_inventory_item_id" ON public.reservation_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_line_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_reservation_item_line_item_id" ON public.reservation_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_location_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_reservation_item_location_id" ON public.reservation_item USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_claim_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_claim_id" ON public.return USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_display_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_display_id" ON public.return USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_exchange_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_exchange_id" ON public.return USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_id_-31ea43a; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_id_-31ea43a" ON public.return_fulfillment USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_item_deleted_at" ON public.return_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_item_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_item_item_id" ON public.return_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_reason_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_item_reason_id" ON public.return_item USING btree (reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_return_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_item_return_id" ON public.return_item USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_order_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_order_id" ON public.return USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_parent_return_reason_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_reason_parent_return_reason_id" ON public.return_reason USING btree (parent_return_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_value; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_return_reason_value" ON public.return_reason USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_sales_channel_deleted_at" ON public.sales_channel USING btree (deleted_at);


--
-- Name: IDX_sales_channel_id_-1d67bae40; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_sales_channel_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_20b454295; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_sales_channel_id_20b454295" ON public.product_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_26d06f470; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_sales_channel_id_26d06f470" ON public.sales_channel_stock_location USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_service_zone_deleted_at" ON public.service_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_service_zone_fulfillment_set_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_service_zone_fulfillment_set_id" ON public.service_zone USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_name_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_service_zone_name_unique" ON public.service_zone USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_method_adjustment_promotion_id" ON public.cart_shipping_method_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_shipping_method_option_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_method_option_id" ON public.cart_shipping_method USING btree (shipping_option_id) WHERE ((deleted_at IS NULL) AND (shipping_option_id IS NOT NULL));


--
-- Name: IDX_shipping_method_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_method_tax_line_tax_rate_id" ON public.cart_shipping_method_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_shipping_option_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_deleted_at" ON public.shipping_option USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_id_ba32fa9c; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_id_ba32fa9c" ON public.shipping_option_price_set USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_provider_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_provider_id" ON public.shipping_option USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_rule_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_rule_deleted_at" ON public.shipping_option_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_rule_shipping_option_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_rule_shipping_option_id" ON public.shipping_option_rule USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_service_zone_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_service_zone_id" ON public.shipping_option USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_option_type_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_shipping_option_type_id" ON public.shipping_option USING btree (shipping_option_type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_profile_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_shipping_profile_id" ON public.shipping_option USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_type_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_option_type_deleted_at" ON public.shipping_option_type USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_profile_deleted_at" ON public.shipping_profile USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_id_17a262437; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_shipping_profile_id_17a262437" ON public.product_shipping_profile USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_profile_name_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_shipping_profile_name_unique" ON public.shipping_profile USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_single_default_region; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_single_default_region" ON public.tax_rate USING btree (tax_region_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- Name: IDX_stock_location_address_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_stock_location_address_deleted_at" ON public.stock_location_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_address_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_stock_location_address_id_unique" ON public.stock_location USING btree (address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_stock_location_deleted_at" ON public.stock_location USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_id_-1e5992737; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_stock_location_id_-1e5992737" ON public.location_fulfillment_provider USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_-e88adb96; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_stock_location_id_-e88adb96" ON public.location_fulfillment_set USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_26d06f470; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_stock_location_id_26d06f470" ON public.sales_channel_stock_location USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_currency_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_store_currency_deleted_at" ON public.store_currency USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_currency_store_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_store_currency_store_id" ON public.store_currency USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_store_deleted_at" ON public.store USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_locale_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_store_locale_deleted_at" ON public.store_locale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_locale_store_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_store_locale_store_id" ON public.store_locale USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tag_value_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_tag_value_unique" ON public.product_tag USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_provider_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_provider_deleted_at" ON public.tax_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_rate_deleted_at" ON public.tax_rate USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_rate_rule_deleted_at" ON public.tax_rate_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_reference_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_rate_rule_reference_id" ON public.tax_rate_rule USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_tax_rate_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_rate_rule_tax_rate_id" ON public.tax_rate_rule USING btree (tax_rate_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_unique_rate_reference; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_tax_rate_rule_unique_rate_reference" ON public.tax_rate_rule USING btree (tax_rate_id, reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_tax_region_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_rate_tax_region_id" ON public.tax_rate USING btree (tax_region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_region_deleted_at" ON public.tax_region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_region_parent_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_region_parent_id" ON public.tax_region USING btree (parent_id);


--
-- Name: IDX_tax_region_provider_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_tax_region_provider_id" ON public.tax_region USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_unique_country_nullable_province; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_nullable_province" ON public.tax_region USING btree (country_code) WHERE ((province_code IS NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_tax_region_unique_country_province; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_province" ON public.tax_region USING btree (country_code, province_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_type_value_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_type_value_unique" ON public.product_type USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_unique_promotion_code; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_unique_promotion_code" ON public.promotion USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_user_deleted_at" ON public."user" USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_user_email_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_user_email_unique" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_user_preference_deleted_at" ON public.user_preference USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_user_preference_user_id" ON public.user_preference USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id_key_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_user_preference_user_id_key_unique" ON public.user_preference USING btree (user_id, key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_17b4c4e35; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_variant_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_52b23597; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_variant_id_52b23597" ON public.product_variant_price_set USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_view_configuration_deleted_at" ON public.view_configuration USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_is_system_default; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_view_configuration_entity_is_system_default" ON public.view_configuration USING btree (entity, is_system_default) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_user_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_view_configuration_entity_user_id" ON public.view_configuration USING btree (entity, user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_user_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_view_configuration_user_id" ON public.view_configuration USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_deleted_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_deleted_at" ON public.workflow_execution USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_id" ON public.workflow_execution USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_retention_time_updated_at_state; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_retention_time_updated_at_state" ON public.workflow_execution USING btree (retention_time, updated_at, state) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL));


--
-- Name: IDX_workflow_execution_run_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_run_id" ON public.workflow_execution USING btree (run_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_state" ON public.workflow_execution USING btree (state) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state_updated_at; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_state_updated_at" ON public.workflow_execution USING btree (state, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_transaction_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_transaction_id" ON public.workflow_execution USING btree (transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_updated_at_retention_time; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_updated_at_retention_time" ON public.workflow_execution USING btree (updated_at, retention_time) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL) AND ((state)::text = ANY ((ARRAY['done'::character varying, 'failed'::character varying, 'reverted'::character varying])::text[])));


--
-- Name: IDX_workflow_execution_workflow_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_workflow_id" ON public.workflow_execution USING btree (workflow_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE INDEX "IDX_workflow_execution_workflow_id_transaction_id" ON public.workflow_execution USING btree (workflow_id, transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id_run_id_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX "IDX_workflow_execution_workflow_id_transaction_id_run_id_unique" ON public.workflow_execution USING btree (workflow_id, transaction_id, run_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_script_name_unique; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX idx_script_name_unique ON public.script_migrations USING btree (script_name);


--
-- Name: merchant_collections_handle_idx; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX merchant_collections_handle_idx ON public.merchant_collections USING btree (handle);


--
-- Name: store_handle_idx; Type: INDEX; Schema: public; Owner: leslieaine
--

CREATE UNIQUE INDEX store_handle_idx ON public.store USING btree (handle);


--
-- Name: tax_rate_rule FK_tax_rate_rule_tax_rate_id; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT "FK_tax_rate_rule_tax_rate_id" FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;


--
-- Name: tax_rate FK_tax_rate_tax_region_id; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_tax_rate_tax_region_id" FOREIGN KEY (tax_region_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_parent_id" FOREIGN KEY (parent_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_provider_id" FOREIGN KEY (provider_id) REFERENCES public.tax_provider(id) ON DELETE SET NULL;


--
-- Name: application_method_buy_rules application_method_buy_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_buy_rules application_method_buy_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture capture_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item cart_line_item_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method cart_shipping_method_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credit_line credit_line_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE;


--
-- Name: customer_address customer_address_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_delivery_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_delivery_address_id_foreign FOREIGN KEY (delivery_address_id) REFERENCES public.fulfillment_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment_item fulfillment_item_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment_label fulfillment_label_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment fulfillment_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: geo_zone geo_zone_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_level inventory_level_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: merchant_collection_products merchant_collection_products_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.merchant_collection_products
    ADD CONSTRAINT merchant_collection_products_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.merchant_collections(id) ON DELETE CASCADE;


--
-- Name: notification notification_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order order_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_change_action order_change_action_order_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_order_change_id_foreign FOREIGN KEY (order_change_id) REFERENCES public.order_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change order_change_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_credit_line order_credit_line_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_adjustment order_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_tax_line order_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item order_line_item_totals_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_totals_id_foreign FOREIGN KEY (totals_id) REFERENCES public.order_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order order_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping order_shipping_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_summary order_summary_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_transaction order_transaction_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_col_aa276_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_col_aa276_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_pro_2d555_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_pro_2d555_foreign FOREIGN KEY (payment_provider_id) REFERENCES public.payment_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment payment_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_session payment_session_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_list_rule price_list_rule_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_set_id_foreign FOREIGN KEY (price_set_id) REFERENCES public.price_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_rule price_rule_price_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_price_id_foreign FOREIGN KEY (price_id) REFERENCES public.price(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category product_category_parent_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_category_id_foreign FOREIGN KEY (parent_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_collection_id_foreign FOREIGN KEY (collection_id) REFERENCES public.product_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_option product_option_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_value product_option_value_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_option_id_foreign FOREIGN KEY (option_id) REFERENCES public.product_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_tag_id_foreign FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.product_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variant_option product_variant_option_option_value_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_option_value_id_foreign FOREIGN KEY (option_value_id) REFERENCES public.product_option_value(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_option product_variant_option_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant product_variant_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_product_image product_variant_product_image_image_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_image_id_foreign FOREIGN KEY (image_id) REFERENCES public.image(id) ON DELETE CASCADE;


--
-- Name: promotion_application_method promotion_application_method_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget promotion_campaign_budget_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.promotion_campaign_budget(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion promotion_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_rule_value promotion_rule_value_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_identity provider_identity_auth_identity_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_auth_identity_id_foreign FOREIGN KEY (auth_identity_id) REFERENCES public.auth_identity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refund refund_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: region_country region_country_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reservation_item reservation_item_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: return_reason return_reason_parent_return_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_parent_return_reason_id_foreign FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);


--
-- Name: service_zone service_zone_fulfillment_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_fulfillment_set_id_foreign FOREIGN KEY (fulfillment_set_id) REFERENCES public.fulfillment_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shipping_option_rule shipping_option_rule_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_option_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_option_type_id_foreign FOREIGN KEY (shipping_option_type_id) REFERENCES public.shipping_option_type(id) ON UPDATE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_profile_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_profile_id_foreign FOREIGN KEY (shipping_profile_id) REFERENCES public.shipping_profile(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sites sites_merchant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES public.merchants(id);


--
-- Name: stock_location stock_location_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_address_id_foreign FOREIGN KEY (address_id) REFERENCES public.stock_location_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_currency store_currency_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_locale store_locale_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: leslieaine
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

