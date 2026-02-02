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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: merchant; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: merchant_auth_identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant_auth_identity (
    id text NOT NULL,
    auth_identity_id text NOT NULL,
    merchant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: merchant_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sales_channel_id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: merchant_category_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant_category_products (
    category_id uuid NOT NULL,
    product_id text NOT NULL
);


--
-- Name: merchant_collection_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant_collection_products (
    collection_id uuid NOT NULL,
    product_id text NOT NULL
);


--
-- Name: merchant_collections; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: merchant_store; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant_store (
    id uuid NOT NULL,
    merchant_id uuid NOT NULL,
    store_id text NOT NULL
);


--
-- Name: merchant_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchant_user (
    id uuid NOT NULL,
    merchant_id uuid NOT NULL,
    auth_identity_id text NOT NULL,
    role text DEFAULT 'owner'::text NOT NULL
);


--
-- Name: merchants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchants (
    id text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: merchant_auth_identity merchant_auth_identity_auth_identity_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_auth_identity
    ADD CONSTRAINT merchant_auth_identity_auth_identity_id_key UNIQUE (auth_identity_id);


--
-- Name: merchant_auth_identity merchant_auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_auth_identity
    ADD CONSTRAINT merchant_auth_identity_pkey PRIMARY KEY (id);


--
-- Name: merchant_categories merchant_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_categories
    ADD CONSTRAINT merchant_categories_pkey PRIMARY KEY (id);


--
-- Name: merchant_categories merchant_categories_sales_channel_id_handle_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_categories
    ADD CONSTRAINT merchant_categories_sales_channel_id_handle_key UNIQUE (sales_channel_id, handle);


--
-- Name: merchant_category_products merchant_category_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_category_products
    ADD CONSTRAINT merchant_category_products_pkey PRIMARY KEY (category_id, product_id);


--
-- Name: merchant_collection_products merchant_collection_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_collection_products
    ADD CONSTRAINT merchant_collection_products_pkey PRIMARY KEY (collection_id, product_id);


--
-- Name: merchant_collections merchant_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_collections
    ADD CONSTRAINT merchant_collections_pkey PRIMARY KEY (id);


--
-- Name: merchant_collections merchant_collections_sales_channel_id_handle_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_collections
    ADD CONSTRAINT merchant_collections_sales_channel_id_handle_key UNIQUE (sales_channel_id, handle);


--
-- Name: merchant merchant_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_email_unique UNIQUE (email);


--
-- Name: merchant merchant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_pkey PRIMARY KEY (id);


--
-- Name: merchant_store merchant_store_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_store
    ADD CONSTRAINT merchant_store_pkey PRIMARY KEY (id);


--
-- Name: merchant merchant_store_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant
    ADD CONSTRAINT merchant_store_unique UNIQUE (store_id);


--
-- Name: merchant_user merchant_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_user
    ADD CONSTRAINT merchant_user_pkey PRIMARY KEY (id);


--
-- Name: merchants merchants_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_email_key UNIQUE (email);


--
-- Name: merchants merchants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_pkey PRIMARY KEY (id);


--
-- Name: IDX_merchant_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_merchant_deleted_at" ON public.merchant USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_merchant_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_merchant_email_unique" ON public.merchant USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: merchant_collections_handle_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX merchant_collections_handle_idx ON public.merchant_collections USING btree (handle);


--
-- Name: merchant_collection_products merchant_collection_products_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchant_collection_products
    ADD CONSTRAINT merchant_collection_products_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.merchant_collections(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

