--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (165f042)
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY public.zones DROP CONSTRAINT zones_site_id_sites_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_zone_id_zones_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_service_id_services_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_rated_by_users_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_qr_code_point_id_qr_code_points_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_maintenance_plan_equipment_id_maintenance_plan_equi;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_maintenance_checklist_template_id_maintenance_check;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_maintenance_activity_id_maintenance_activities_id_f;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_equipment_id_equipment_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_customer_id_customers_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_company_id_companies_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_cleaning_activity_id_cleaning_activities_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_checklist_template_id_checklist_templates_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_cancelled_by_users_id_fk;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_assigned_user_id_users_id_fk;
ALTER TABLE ONLY public.work_order_comments DROP CONSTRAINT work_order_comments_work_order_id_work_orders_id_fk;
ALTER TABLE ONLY public.work_order_comments DROP CONSTRAINT work_order_comments_user_id_users_id_fk;
ALTER TABLE ONLY public.webhook_configs DROP CONSTRAINT webhook_configs_company_id_companies_id_fk;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_customer_id_customers_id_fk;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_company_id_companies_id_fk;
ALTER TABLE ONLY public.user_site_assignments DROP CONSTRAINT user_site_assignments_user_id_users_id_fk;
ALTER TABLE ONLY public.user_site_assignments DROP CONSTRAINT user_site_assignments_site_id_sites_id_fk;
ALTER TABLE ONLY public.user_role_assignments DROP CONSTRAINT user_role_assignments_user_id_users_id_fk;
ALTER TABLE ONLY public.user_role_assignments DROP CONSTRAINT user_role_assignments_role_id_custom_roles_id_fk;
ALTER TABLE ONLY public.user_role_assignments DROP CONSTRAINT user_role_assignments_customer_id_customers_id_fk;
ALTER TABLE ONLY public.sla_configs DROP CONSTRAINT sla_configs_company_id_companies_id_fk;
ALTER TABLE ONLY public.sites DROP CONSTRAINT sites_customer_id_customers_id_fk;
ALTER TABLE ONLY public.sites DROP CONSTRAINT sites_company_id_companies_id_fk;
ALTER TABLE ONLY public.site_shifts DROP CONSTRAINT site_shifts_site_id_sites_id_fk;
ALTER TABLE ONLY public.services DROP CONSTRAINT services_type_id_service_types_id_fk;
ALTER TABLE ONLY public.services DROP CONSTRAINT services_customer_id_customers_id_fk;
ALTER TABLE ONLY public.services DROP CONSTRAINT services_category_id_service_categories_id_fk;
ALTER TABLE ONLY public.service_zones DROP CONSTRAINT service_zones_zone_id_zones_id_fk;
ALTER TABLE ONLY public.service_zones DROP CONSTRAINT service_zones_service_id_services_id_fk;
ALTER TABLE ONLY public.service_types DROP CONSTRAINT service_types_customer_id_customers_id_fk;
ALTER TABLE ONLY public.service_types DROP CONSTRAINT service_types_company_id_companies_id_fk;
ALTER TABLE ONLY public.service_categories DROP CONSTRAINT service_categories_type_id_service_types_id_fk;
ALTER TABLE ONLY public.service_categories DROP CONSTRAINT service_categories_customer_id_customers_id_fk;
ALTER TABLE ONLY public.role_permissions DROP CONSTRAINT role_permissions_role_id_custom_roles_id_fk;
ALTER TABLE ONLY public.qr_code_points DROP CONSTRAINT qr_code_points_zone_id_zones_id_fk;
ALTER TABLE ONLY public.qr_code_points DROP CONSTRAINT qr_code_points_service_id_services_id_fk;
ALTER TABLE ONLY public.qr_code_points DROP CONSTRAINT qr_code_points_equipment_id_equipment_id_fk;
ALTER TABLE ONLY public.public_request_logs DROP CONSTRAINT public_request_logs_qr_code_point_id_qr_code_points_id_fk;
ALTER TABLE ONLY public.maintenance_plans DROP CONSTRAINT maintenance_plans_customer_id_customers_id_fk;
ALTER TABLE ONLY public.maintenance_plans DROP CONSTRAINT maintenance_plans_company_id_companies_id_fk;
ALTER TABLE ONLY public.maintenance_plan_equipments DROP CONSTRAINT maintenance_plan_equipments_plan_id_maintenance_plans_id_fk;
ALTER TABLE ONLY public.maintenance_plan_equipments DROP CONSTRAINT maintenance_plan_equipments_equipment_id_equipment_id_fk;
ALTER TABLE ONLY public.maintenance_checklist_templates DROP CONSTRAINT maintenance_checklist_templates_service_id_services_id_fk;
ALTER TABLE ONLY public.maintenance_checklist_templates DROP CONSTRAINT maintenance_checklist_templates_customer_id_customers_id_fk;
ALTER TABLE ONLY public.maintenance_checklist_templates DROP CONSTRAINT maintenance_checklist_templates_company_id_companies_id_fk;
ALTER TABLE ONLY public.maintenance_checklist_executions DROP CONSTRAINT maintenance_checklist_executions_equipment_id_equipment_id_fk;
ALTER TABLE ONLY public.maintenance_activities DROP CONSTRAINT maintenance_activities_sla_config_id_sla_configs_id_fk;
ALTER TABLE ONLY public.maintenance_activities DROP CONSTRAINT maintenance_activities_customer_id_customers_id_fk;
ALTER TABLE ONLY public.maintenance_activities DROP CONSTRAINT maintenance_activities_company_id_companies_id_fk;
ALTER TABLE ONLY public.maintenance_activities DROP CONSTRAINT maintenance_activities_checklist_template_id_maintenance_checkl;
ALTER TABLE ONLY public.maintenance_activities DROP CONSTRAINT maintenance_activities_assigned_user_id_users_id_fk;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_zone_id_zones_id_fk;
ALTER TABLE ONLY public.equipment_types DROP CONSTRAINT equipment_types_company_id_companies_id_fk;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_site_id_sites_id_fk;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_equipment_type_id_equipment_types_id_fk;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_customer_id_customers_id_fk;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_company_id_companies_id_fk;
ALTER TABLE ONLY public.dashboard_goals DROP CONSTRAINT dashboard_goals_company_id_companies_id_fk;
ALTER TABLE ONLY public.customers DROP CONSTRAINT customers_company_id_companies_id_fk;
ALTER TABLE ONLY public.customer_counters DROP CONSTRAINT customer_counters_customer_id_customers_id_fk;
ALTER TABLE ONLY public.custom_roles DROP CONSTRAINT custom_roles_company_id_companies_id_fk;
ALTER TABLE ONLY public.company_counters DROP CONSTRAINT company_counters_company_id_companies_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_zone_id_zones_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_sla_config_id_sla_configs_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_site_id_sites_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_service_id_services_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_customer_id_customers_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_company_id_companies_id_fk;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_checklist_template_id_checklist_templates_i;
ALTER TABLE ONLY public.checklist_templates DROP CONSTRAINT checklist_templates_zone_id_zones_id_fk;
ALTER TABLE ONLY public.checklist_templates DROP CONSTRAINT checklist_templates_site_id_sites_id_fk;
ALTER TABLE ONLY public.checklist_templates DROP CONSTRAINT checklist_templates_service_id_services_id_fk;
ALTER TABLE ONLY public.checklist_templates DROP CONSTRAINT checklist_templates_company_id_companies_id_fk;
ALTER TABLE ONLY public.chat_messages DROP CONSTRAINT chat_messages_conversation_id_chat_conversations_id_fk;
ALTER TABLE ONLY public.chat_messages DROP CONSTRAINT chat_messages_ai_integration_id_ai_integrations_id_fk;
ALTER TABLE ONLY public.chat_conversations DROP CONSTRAINT chat_conversations_user_id_users_id_fk;
ALTER TABLE ONLY public.chat_conversations DROP CONSTRAINT chat_conversations_customer_id_customers_id_fk;
ALTER TABLE ONLY public.chat_conversations DROP CONSTRAINT chat_conversations_company_id_companies_id_fk;
ALTER TABLE ONLY public.bathroom_counters DROP CONSTRAINT bathroom_counters_zone_id_zones_id_fk;
ALTER TABLE ONLY public.bathroom_counter_logs DROP CONSTRAINT bathroom_counter_logs_work_order_id_work_orders_id_fk;
ALTER TABLE ONLY public.bathroom_counter_logs DROP CONSTRAINT bathroom_counter_logs_user_id_users_id_fk;
ALTER TABLE ONLY public.bathroom_counter_logs DROP CONSTRAINT bathroom_counter_logs_counter_id_bathroom_counters_id_fk;
ALTER TABLE ONLY public.audit_logs DROP CONSTRAINT audit_logs_user_id_users_id_fk;
ALTER TABLE ONLY public.audit_logs DROP CONSTRAINT audit_logs_company_id_companies_id_fk;
ALTER TABLE ONLY public.ai_integrations DROP CONSTRAINT ai_integrations_created_by_users_id_fk;
ALTER TABLE ONLY public.ai_integrations DROP CONSTRAINT ai_integrations_company_id_companies_id_fk;
DROP INDEX public.work_orders_customer_number_unique;
ALTER TABLE ONLY public.zones DROP CONSTRAINT zones_pkey;
ALTER TABLE ONLY public.work_orders DROP CONSTRAINT work_orders_pkey;
ALTER TABLE ONLY public.work_order_comments DROP CONSTRAINT work_order_comments_pkey;
ALTER TABLE ONLY public.webhook_configs DROP CONSTRAINT webhook_configs_pkey;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_unique;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_unique;
ALTER TABLE ONLY public.user_site_assignments DROP CONSTRAINT user_site_assignments_pkey;
ALTER TABLE ONLY public.user_role_assignments DROP CONSTRAINT user_role_assignments_pkey;
ALTER TABLE ONLY public.service_zones DROP CONSTRAINT unique_service_zone;
ALTER TABLE ONLY public.maintenance_plan_equipments DROP CONSTRAINT unique_plan_equipment;
ALTER TABLE ONLY public.sla_configs DROP CONSTRAINT sla_configs_pkey;
ALTER TABLE ONLY public.sites DROP CONSTRAINT sites_pkey;
ALTER TABLE ONLY public.site_shifts DROP CONSTRAINT site_shifts_pkey;
ALTER TABLE ONLY public.services DROP CONSTRAINT services_pkey;
ALTER TABLE ONLY public.service_zones DROP CONSTRAINT service_zones_pkey;
ALTER TABLE ONLY public.service_types DROP CONSTRAINT service_types_pkey;
ALTER TABLE ONLY public.service_categories DROP CONSTRAINT service_categories_pkey;
ALTER TABLE ONLY public.service_categories DROP CONSTRAINT service_categories_code_unique;
ALTER TABLE ONLY public.role_permissions DROP CONSTRAINT role_permissions_pkey;
ALTER TABLE ONLY public.qr_code_points DROP CONSTRAINT qr_code_points_pkey;
ALTER TABLE ONLY public.qr_code_points DROP CONSTRAINT qr_code_points_code_unique;
ALTER TABLE ONLY public.public_request_logs DROP CONSTRAINT public_request_logs_pkey;
ALTER TABLE ONLY public.maintenance_plans DROP CONSTRAINT maintenance_plans_pkey;
ALTER TABLE ONLY public.maintenance_plan_equipments DROP CONSTRAINT maintenance_plan_equipments_pkey;
ALTER TABLE ONLY public.maintenance_checklist_templates DROP CONSTRAINT maintenance_checklist_templates_pkey;
ALTER TABLE ONLY public.maintenance_checklist_executions DROP CONSTRAINT maintenance_checklist_executions_pkey;
ALTER TABLE ONLY public.maintenance_activities DROP CONSTRAINT maintenance_activities_pkey;
ALTER TABLE ONLY public.equipment_types DROP CONSTRAINT equipment_types_pkey;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_serial_number_unique;
ALTER TABLE ONLY public.equipment DROP CONSTRAINT equipment_pkey;
ALTER TABLE ONLY public.dashboard_goals DROP CONSTRAINT dashboard_goals_pkey;
ALTER TABLE ONLY public.customers DROP CONSTRAINT customers_pkey;
ALTER TABLE ONLY public.customer_counters DROP CONSTRAINT customer_counters_pkey;
ALTER TABLE ONLY public.customer_counters DROP CONSTRAINT customer_counters_customer_key_unique;
ALTER TABLE ONLY public.custom_roles DROP CONSTRAINT custom_roles_pkey;
ALTER TABLE ONLY public.company_counters DROP CONSTRAINT company_counters_pkey;
ALTER TABLE ONLY public.companies DROP CONSTRAINT companies_pkey;
ALTER TABLE ONLY public.cleaning_activities DROP CONSTRAINT cleaning_activities_pkey;
ALTER TABLE ONLY public.checklist_templates DROP CONSTRAINT checklist_templates_pkey;
ALTER TABLE ONLY public.chat_messages DROP CONSTRAINT chat_messages_pkey;
ALTER TABLE ONLY public.chat_conversations DROP CONSTRAINT chat_conversations_pkey;
ALTER TABLE ONLY public.bathroom_counters DROP CONSTRAINT bathroom_counters_pkey;
ALTER TABLE ONLY public.bathroom_counter_logs DROP CONSTRAINT bathroom_counter_logs_pkey;
ALTER TABLE ONLY public.audit_logs DROP CONSTRAINT audit_logs_pkey;
ALTER TABLE ONLY public.ai_integrations DROP CONSTRAINT ai_integrations_pkey;
DROP TABLE public.zones;
DROP TABLE public.work_orders;
DROP TABLE public.work_order_comments;
DROP TABLE public.webhook_configs;
DROP TABLE public.users;
DROP TABLE public.user_site_assignments;
DROP TABLE public.user_role_assignments;
DROP TABLE public.sla_configs;
DROP TABLE public.sites;
DROP TABLE public.site_shifts;
DROP TABLE public.services;
DROP TABLE public.service_zones;
DROP TABLE public.service_types;
DROP TABLE public.service_categories;
DROP TABLE public.role_permissions;
DROP TABLE public.qr_code_points;
DROP TABLE public.public_request_logs;
DROP TABLE public.maintenance_plans;
DROP TABLE public.maintenance_plan_equipments;
DROP TABLE public.maintenance_checklist_templates;
DROP TABLE public.maintenance_checklist_executions;
DROP TABLE public.maintenance_activities;
DROP TABLE public.equipment_types;
DROP TABLE public.equipment;
DROP TABLE public.dashboard_goals;
DROP TABLE public.customers;
DROP TABLE public.customer_counters;
DROP TABLE public.custom_roles;
DROP TABLE public.company_counters;
DROP TABLE public.companies;
DROP TABLE public.cleaning_activities;
DROP TABLE public.checklist_templates;
DROP TABLE public.chat_messages;
DROP TABLE public.chat_conversations;
DROP TABLE public.bathroom_counters;
DROP TABLE public.bathroom_counter_logs;
DROP TABLE public.audit_logs;
DROP TABLE public.ai_integrations;
DROP TYPE public.work_order_type;
DROP TYPE public.work_order_status;
DROP TYPE public.user_type;
DROP TYPE public.user_role;
DROP TYPE public.qr_code_type;
DROP TYPE public.priority;
DROP TYPE public.permission_key;
DROP TYPE public.module;
DROP TYPE public.frequency;
DROP TYPE public.equipment_status;
DROP TYPE public.bathroom_counter_action;
DROP TYPE public.auth_provider;
DROP TYPE public.ai_provider;
DROP TYPE public.ai_integration_status;
--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: ai_integration_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ai_integration_status AS ENUM (
    'ativa',
    'inativa',
    'erro'
);


--
-- Name: ai_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ai_provider AS ENUM (
    'openai',
    'anthropic',
    'google',
    'groq',
    'azure_openai',
    'cohere',
    'huggingface',
    'custom'
);


--
-- Name: auth_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.auth_provider AS ENUM (
    'local',
    'microsoft'
);


--
-- Name: bathroom_counter_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.bathroom_counter_action AS ENUM (
    'increment',
    'decrement',
    'reset'
);


--
-- Name: equipment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.equipment_status AS ENUM (
    'operacional',
    'em_manutencao',
    'inoperante',
    'aposentado'
);


--
-- Name: frequency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.frequency AS ENUM (
    'diaria',
    'semanal',
    'mensal',
    'trimestral',
    'semestral',
    'anual',
    'turno',
    'custom'
);


--
-- Name: module; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.module AS ENUM (
    'clean',
    'maintenance'
);


--
-- Name: permission_key; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.permission_key AS ENUM (
    'dashboard_view',
    'workorders_view',
    'workorders_create',
    'workorders_edit',
    'workorders_delete',
    'workorders_comment',
    'workorders_evaluate',
    'schedule_view',
    'schedule_create',
    'schedule_edit',
    'schedule_delete',
    'checklists_view',
    'checklists_create',
    'checklists_edit',
    'checklists_delete',
    'qrcodes_view',
    'qrcodes_create',
    'qrcodes_edit',
    'qrcodes_delete',
    'floor_plan_view',
    'floor_plan_edit',
    'heatmap_view',
    'sites_view',
    'sites_create',
    'sites_edit',
    'sites_delete',
    'users_view',
    'users_create',
    'users_edit',
    'users_delete',
    'customers_view',
    'customers_create',
    'customers_edit',
    'customers_delete',
    'reports_view',
    'audit_logs_view',
    'service_settings_view',
    'service_settings_edit',
    'roles_manage',
    'opus_users_view',
    'opus_users_create',
    'opus_users_edit',
    'opus_users_delete',
    'client_users_view',
    'client_users_create',
    'client_users_edit',
    'client_users_delete'
);


--
-- Name: priority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.priority AS ENUM (
    'baixa',
    'media',
    'alta',
    'critica'
);


--
-- Name: qr_code_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.qr_code_type AS ENUM (
    'execucao',
    'atendimento'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'gestor_cliente',
    'supervisor_site',
    'operador',
    'auditor'
);


--
-- Name: user_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_type AS ENUM (
    'opus_user',
    'customer_user'
);


--
-- Name: work_order_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.work_order_status AS ENUM (
    'aberta',
    'em_execucao',
    'pausada',
    'vencida',
    'concluida',
    'cancelada'
);


--
-- Name: work_order_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.work_order_type AS ENUM (
    'programada',
    'corretiva_interna',
    'corretiva_publica'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_integrations (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    name character varying NOT NULL,
    provider public.ai_provider NOT NULL,
    model character varying NOT NULL,
    api_key text NOT NULL,
    endpoint character varying,
    status public.ai_integration_status DEFAULT 'ativa'::public.ai_integration_status NOT NULL,
    is_default boolean DEFAULT false,
    max_tokens integer DEFAULT 4096,
    temperature numeric(3,2) DEFAULT 0.7,
    enable_logs boolean DEFAULT false,
    last_tested_at timestamp without time zone,
    last_error_message text,
    created_by character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id character varying NOT NULL,
    company_id character varying,
    user_id character varying,
    entity_type character varying NOT NULL,
    entity_id character varying NOT NULL,
    action character varying NOT NULL,
    changes jsonb,
    metadata jsonb,
    "timestamp" timestamp without time zone DEFAULT now(),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: bathroom_counter_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bathroom_counter_logs (
    id character varying NOT NULL,
    counter_id character varying NOT NULL,
    user_id character varying,
    delta integer NOT NULL,
    action public.bathroom_counter_action NOT NULL,
    previous_value integer NOT NULL,
    new_value integer NOT NULL,
    work_order_id character varying,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: bathroom_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bathroom_counters (
    id character varying NOT NULL,
    zone_id character varying NOT NULL,
    current_count integer DEFAULT 0,
    limit_count integer NOT NULL,
    last_reset timestamp without time zone DEFAULT now(),
    auto_reset_turn boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: chat_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_conversations (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying,
    module public.module NOT NULL,
    title character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_messages (
    id character varying NOT NULL,
    conversation_id character varying NOT NULL,
    role character varying NOT NULL,
    content text NOT NULL,
    context jsonb,
    ai_integration_id character varying,
    tokens_used integer,
    error text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: checklist_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checklist_templates (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    service_id character varying,
    site_id character varying,
    name character varying NOT NULL,
    description text,
    items jsonb NOT NULL,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    zone_id character varying,
    site_ids text[],
    zone_ids text[]
);


--
-- Name: cleaning_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cleaning_activities (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    service_id character varying,
    site_id character varying,
    zone_id character varying,
    name character varying NOT NULL,
    description text,
    frequency public.frequency NOT NULL,
    frequency_config jsonb,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    checklist_template_id character varying,
    sla_config_id character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    start_time time without time zone,
    end_time time without time zone,
    start_date date,
    end_date date,
    site_ids text[],
    zone_ids text[],
    customer_id character varying
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id character varying NOT NULL,
    name character varying NOT NULL,
    cnpj character varying,
    email character varying,
    phone character varying,
    address character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: company_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_counters (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    key character varying NOT NULL,
    next_number integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: custom_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_roles (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    is_system_role boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: customer_counters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_counters (
    id character varying NOT NULL,
    customer_id character varying NOT NULL,
    key character varying NOT NULL,
    next_number integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    name character varying NOT NULL,
    email character varying,
    phone character varying,
    document character varying,
    address character varying,
    city character varying,
    state character varying,
    zip_code character varying,
    contact_person character varying,
    notes text,
    modules text[] DEFAULT ARRAY['clean'::text] NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: dashboard_goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_goals (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    goal_type character varying NOT NULL,
    goal_value numeric(10,2) NOT NULL,
    current_period character varying NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    site_id character varying NOT NULL,
    zone_id character varying NOT NULL,
    equipment_type_id character varying,
    name character varying NOT NULL,
    internal_code character varying,
    manufacturer character varying,
    model character varying,
    serial_number character varying,
    purchase_date date,
    warranty_expiry date,
    installation_date date,
    status public.equipment_status DEFAULT 'operacional'::public.equipment_status NOT NULL,
    technical_specs jsonb,
    maintenance_notes text,
    qr_code_url character varying,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    value numeric(10,2)
);


--
-- Name: equipment_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment_types (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: maintenance_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_activities (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    site_ids character varying[] NOT NULL,
    zone_ids character varying[] NOT NULL,
    equipment_ids character varying[],
    site_id character varying,
    zone_id character varying,
    name character varying NOT NULL,
    description text,
    type character varying DEFAULT 'preventiva'::character varying NOT NULL,
    frequency public.frequency NOT NULL,
    frequency_config jsonb,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    checklist_template_id character varying,
    sla_config_id character varying,
    assigned_user_id character varying,
    estimated_hours numeric(5,2),
    sla_minutes integer,
    start_date date,
    last_executed_at timestamp without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    start_time time without time zone,
    end_time time without time zone
);


--
-- Name: maintenance_checklist_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_checklist_executions (
    id character varying NOT NULL,
    checklist_template_id character varying NOT NULL,
    equipment_id character varying NOT NULL,
    work_order_id character varying,
    executed_by_user_id character varying NOT NULL,
    started_at timestamp without time zone NOT NULL,
    finished_at timestamp without time zone,
    status character varying DEFAULT 'in_progress'::character varying NOT NULL,
    checklist_data jsonb,
    observations text,
    attachments jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: maintenance_checklist_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_checklist_templates (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    version character varying DEFAULT '1.0'::character varying NOT NULL,
    service_id character varying NOT NULL,
    site_ids character varying[],
    zone_ids character varying[],
    equipment_ids character varying[],
    items jsonb NOT NULL,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: maintenance_plan_equipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_plan_equipments (
    id character varying NOT NULL,
    plan_id character varying NOT NULL,
    equipment_id character varying NOT NULL,
    checklist_template_id character varying,
    frequency public.frequency NOT NULL,
    frequency_config jsonb,
    next_execution_at timestamp without time zone,
    last_execution_at timestamp without time zone,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: maintenance_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_plans (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    type character varying DEFAULT 'preventiva'::character varying NOT NULL,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: public_request_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_request_logs (
    id character varying NOT NULL,
    qr_code_point_id character varying,
    ip_hash character varying NOT NULL,
    user_agent text,
    request_data jsonb,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: qr_code_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qr_code_points (
    id character varying NOT NULL,
    zone_id character varying,
    equipment_id character varying,
    service_id character varying,
    code character varying NOT NULL,
    type public.qr_code_type NOT NULL,
    name character varying NOT NULL,
    description text,
    size_cm integer DEFAULT 5,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id character varying NOT NULL,
    role_id character varying NOT NULL,
    permission public.permission_key NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: service_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_categories (
    id character varying NOT NULL,
    type_id character varying,
    name character varying NOT NULL,
    description text,
    code character varying NOT NULL,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    customer_id character varying
);


--
-- Name: service_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_types (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    code character varying NOT NULL,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    customer_id character varying NOT NULL,
    company_id character varying NOT NULL
);


--
-- Name: service_zones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_zones (
    id character varying NOT NULL,
    service_id character varying NOT NULL,
    zone_id character varying NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    estimated_duration_minutes integer,
    priority public.priority DEFAULT 'media'::public.priority,
    requirements text,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    customer_id character varying,
    category_id character varying,
    type_id character varying
);


--
-- Name: site_shifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_shifts (
    id character varying NOT NULL,
    site_id character varying NOT NULL,
    name character varying NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    name character varying NOT NULL,
    address character varying,
    description text,
    floor_plan_image_url character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: sla_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sla_configs (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    name character varying NOT NULL,
    category character varying,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    time_to_start_minutes integer NOT NULL,
    time_to_complete_minutes integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_role_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_role_assignments (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    role_id character varying NOT NULL,
    customer_id character varying,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_site_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_site_assignments (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    site_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying NOT NULL,
    company_id character varying,
    customer_id character varying,
    username character varying NOT NULL,
    email character varying NOT NULL,
    password character varying,
    name character varying NOT NULL,
    role public.user_role NOT NULL,
    user_type public.user_type DEFAULT 'opus_user'::public.user_type NOT NULL,
    assigned_client_id character varying,
    auth_provider public.auth_provider DEFAULT 'local'::public.auth_provider,
    external_id character varying,
    ms_tenant_id character varying,
    modules text[] DEFAULT ARRAY['clean'::text] NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: webhook_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_configs (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    name character varying NOT NULL,
    url character varying NOT NULL,
    events jsonb NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: work_order_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_order_comments (
    id character varying NOT NULL,
    work_order_id character varying NOT NULL,
    user_id character varying NOT NULL,
    comment text NOT NULL,
    attachments jsonb,
    is_reopen_request boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_orders (
    id character varying NOT NULL,
    number integer NOT NULL,
    company_id character varying NOT NULL,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    zone_id character varying,
    service_id character varying,
    cleaning_activity_id character varying,
    maintenance_activity_id character varying,
    checklist_template_id character varying,
    maintenance_checklist_template_id character varying,
    equipment_id character varying,
    maintenance_plan_equipment_id character varying,
    type public.work_order_type NOT NULL,
    status public.work_order_status DEFAULT 'aberta'::public.work_order_status NOT NULL,
    priority public.priority DEFAULT 'media'::public.priority NOT NULL,
    title character varying NOT NULL,
    description text,
    assigned_user_id character varying,
    origin character varying,
    qr_code_point_id character varying,
    requester_name character varying,
    requester_contact character varying,
    scheduled_date timestamp without time zone,
    due_date timestamp without time zone,
    scheduled_start_at timestamp without time zone,
    scheduled_end_at timestamp without time zone,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    estimated_hours numeric(5,2),
    sla_start_minutes integer,
    sla_complete_minutes integer,
    observations text,
    checklist_data jsonb,
    attachments jsonb,
    customer_rating integer,
    customer_rating_comment text,
    rated_at timestamp without time zone,
    rated_by character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    cancellation_reason text,
    cancelled_at timestamp without time zone,
    cancelled_by character varying,
    customer_id character varying,
    assigned_user_ids text[]
);


--
-- Name: zones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zones (
    id character varying NOT NULL,
    site_id character varying NOT NULL,
    module public.module DEFAULT 'clean'::public.module NOT NULL,
    name character varying NOT NULL,
    description text,
    area_m2 numeric(10,2),
    capacity integer,
    category character varying,
    position_x numeric(5,2),
    position_y numeric(5,2),
    size_scale numeric(3,2),
    color character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Data for Name: ai_integrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_integrations (id, company_id, name, provider, model, api_key, endpoint, status, is_default, max_tokens, temperature, enable_logs, last_tested_at, last_error_message, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, company_id, user_id, entity_type, entity_id, action, changes, metadata, "timestamp", created_at) FROM stdin;
\.


--
-- Data for Name: bathroom_counter_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bathroom_counter_logs (id, counter_id, user_id, delta, action, previous_value, new_value, work_order_id, created_at) FROM stdin;
\.


--
-- Data for Name: bathroom_counters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bathroom_counters (id, zone_id, current_count, limit_count, last_reset, auto_reset_turn, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: chat_conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chat_conversations (id, user_id, company_id, customer_id, module, title, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chat_messages (id, conversation_id, role, content, context, ai_integration_id, tokens_used, error, created_at) FROM stdin;
\.


--
-- Data for Name: checklist_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checklist_templates (id, company_id, service_id, site_id, name, description, items, module, created_at, updated_at, zone_id, site_ids, zone_ids) FROM stdin;
\.


--
-- Data for Name: cleaning_activities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, frequency_config, module, checklist_template_id, sla_config_id, is_active, created_at, updated_at, start_time, end_time, start_date, end_date, site_ids, zone_ids, customer_id) FROM stdin;
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.companies (id, name, cnpj, email, phone, address, is_active, created_at, updated_at) FROM stdin;
company-admin-default	GRUPO OPUS					t	2025-09-10 20:41:19.301367	2025-09-10 20:41:19.301367
company-opus-default	Grupo OPUS	12.345.678/0001-90	contato@grupoopus.com.br	(11) 3000-0000	Av. Paulista, 1000 - São Paulo, SP	t	2025-10-19 17:58:47.078825	2025-10-19 17:58:47.078825
\.


--
-- Data for Name: company_counters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.company_counters (id, company_id, key, next_number, updated_at) FROM stdin;
\.


--
-- Data for Name: custom_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.custom_roles (id, company_id, name, description, is_system_role, is_active, created_at, updated_at) FROM stdin;
role-system-admin	company-opus-default	Administrador	Acesso total ao sistema - para usuários OPUS	t	t	2025-11-10 15:41:08.996064	2025-11-10 15:41:08.996064
role-system-cliente	company-opus-default	Cliente	Visualização de dashboards, relatórios, plantas dos locais e ordens de serviço. Pode comentar e avaliar OS.	t	t	2025-11-10 15:41:08.996064	2025-11-10 15:41:08.996064
role-system-operador	company-opus-default	Operador	Operador de campo - executa OS via aplicativo mobile	t	t	2025-11-10 15:41:08.996064	2025-11-10 15:41:08.996064
\.


--
-- Data for Name: customer_counters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_counters (id, customer_id, key, next_number, updated_at) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (id, company_id, name, email, phone, document, address, city, state, zip_code, contact_person, notes, modules, is_active, created_at, updated_at) FROM stdin;
3f04639c-fea8-44d7-9d95-3591cad79a67	company-opus-default	Opus Manager	administradorFacilities@grupoopus.com	71994080797	59.912.499/0001-56	Rua das palmeiras, 821 - Block residence 201 - Cruzeiro	Caxias do Sul	RS	95074-310	Daniel Lacerda		{clean,maintenance}	t	2025-11-10 15:33:16.639746	2025-11-10 15:33:16.639746
\.


--
-- Data for Name: dashboard_goals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dashboard_goals (id, company_id, module, goal_type, goal_value, current_period, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment (id, company_id, customer_id, site_id, zone_id, equipment_type_id, name, internal_code, manufacturer, model, serial_number, purchase_date, warranty_expiry, installation_date, status, technical_specs, maintenance_notes, qr_code_url, module, is_active, created_at, updated_at, value) FROM stdin;
\.


--
-- Data for Name: equipment_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_types (id, company_id, name, description, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_activities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_activities (id, company_id, customer_id, site_ids, zone_ids, equipment_ids, site_id, zone_id, name, description, type, frequency, frequency_config, module, checklist_template_id, sla_config_id, assigned_user_id, estimated_hours, sla_minutes, start_date, last_executed_at, is_active, created_at, updated_at, start_time, end_time) FROM stdin;
\.


--
-- Data for Name: maintenance_checklist_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_checklist_executions (id, checklist_template_id, equipment_id, work_order_id, executed_by_user_id, started_at, finished_at, status, checklist_data, observations, attachments, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_checklist_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_checklist_templates (id, company_id, customer_id, name, description, version, service_id, site_ids, zone_ids, equipment_ids, items, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_plan_equipments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_plan_equipments (id, plan_id, equipment_id, checklist_template_id, frequency, frequency_config, next_execution_at, last_execution_at, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_plans (id, company_id, customer_id, name, description, type, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: public_request_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.public_request_logs (id, qr_code_point_id, ip_hash, user_agent, request_data, created_at) FROM stdin;
\.


--
-- Data for Name: qr_code_points; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.qr_code_points (id, zone_id, equipment_id, service_id, code, type, name, description, size_cm, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (id, role_id, permission, created_at) FROM stdin;
perm-admin-1	role-system-admin	dashboard_view	2025-11-10 15:41:31.860517
perm-admin-2	role-system-admin	workorders_view	2025-11-10 15:41:31.860517
perm-admin-3	role-system-admin	workorders_create	2025-11-10 15:41:31.860517
perm-admin-4	role-system-admin	workorders_edit	2025-11-10 15:41:31.860517
perm-admin-5	role-system-admin	workorders_delete	2025-11-10 15:41:31.860517
perm-admin-6	role-system-admin	workorders_comment	2025-11-10 15:41:31.860517
perm-admin-7	role-system-admin	workorders_evaluate	2025-11-10 15:41:31.860517
perm-admin-8	role-system-admin	schedule_view	2025-11-10 15:41:31.860517
perm-admin-9	role-system-admin	schedule_create	2025-11-10 15:41:31.860517
perm-admin-10	role-system-admin	schedule_edit	2025-11-10 15:41:31.860517
perm-admin-11	role-system-admin	schedule_delete	2025-11-10 15:41:31.860517
perm-admin-12	role-system-admin	checklists_view	2025-11-10 15:41:31.860517
perm-admin-13	role-system-admin	checklists_create	2025-11-10 15:41:31.860517
perm-admin-14	role-system-admin	checklists_edit	2025-11-10 15:41:31.860517
perm-admin-15	role-system-admin	checklists_delete	2025-11-10 15:41:31.860517
perm-admin-16	role-system-admin	qrcodes_view	2025-11-10 15:41:31.860517
perm-admin-17	role-system-admin	qrcodes_create	2025-11-10 15:41:31.860517
perm-admin-18	role-system-admin	qrcodes_edit	2025-11-10 15:41:31.860517
perm-admin-19	role-system-admin	qrcodes_delete	2025-11-10 15:41:31.860517
perm-admin-20	role-system-admin	floor_plan_view	2025-11-10 15:41:31.860517
perm-admin-21	role-system-admin	floor_plan_edit	2025-11-10 15:41:31.860517
perm-admin-22	role-system-admin	heatmap_view	2025-11-10 15:41:31.860517
perm-admin-23	role-system-admin	sites_view	2025-11-10 15:41:31.860517
perm-admin-24	role-system-admin	sites_create	2025-11-10 15:41:31.860517
perm-admin-25	role-system-admin	sites_edit	2025-11-10 15:41:31.860517
perm-admin-26	role-system-admin	sites_delete	2025-11-10 15:41:31.860517
perm-admin-27	role-system-admin	users_view	2025-11-10 15:41:31.860517
perm-admin-28	role-system-admin	users_create	2025-11-10 15:41:31.860517
perm-admin-29	role-system-admin	users_edit	2025-11-10 15:41:31.860517
perm-admin-30	role-system-admin	users_delete	2025-11-10 15:41:31.860517
perm-admin-31	role-system-admin	customers_view	2025-11-10 15:41:31.860517
perm-admin-32	role-system-admin	customers_create	2025-11-10 15:41:31.860517
perm-admin-33	role-system-admin	customers_edit	2025-11-10 15:41:31.860517
perm-admin-34	role-system-admin	customers_delete	2025-11-10 15:41:31.860517
perm-admin-35	role-system-admin	reports_view	2025-11-10 15:41:31.860517
perm-admin-36	role-system-admin	audit_logs_view	2025-11-10 15:41:31.860517
perm-admin-37	role-system-admin	service_settings_view	2025-11-10 15:41:31.860517
perm-admin-38	role-system-admin	service_settings_edit	2025-11-10 15:41:31.860517
perm-admin-39	role-system-admin	roles_manage	2025-11-10 15:41:31.860517
perm-admin-40	role-system-admin	opus_users_view	2025-11-10 15:41:31.860517
perm-admin-41	role-system-admin	opus_users_create	2025-11-10 15:41:31.860517
perm-admin-42	role-system-admin	opus_users_edit	2025-11-10 15:41:31.860517
perm-admin-43	role-system-admin	opus_users_delete	2025-11-10 15:41:31.860517
perm-admin-44	role-system-admin	client_users_view	2025-11-10 15:41:31.860517
perm-admin-45	role-system-admin	client_users_create	2025-11-10 15:41:31.860517
perm-admin-46	role-system-admin	client_users_edit	2025-11-10 15:41:31.860517
perm-admin-47	role-system-admin	client_users_delete	2025-11-10 15:41:31.860517
perm-cliente-1	role-system-cliente	dashboard_view	2025-11-10 15:41:45.95035
perm-cliente-2	role-system-cliente	workorders_view	2025-11-10 15:41:45.95035
perm-cliente-3	role-system-cliente	workorders_comment	2025-11-10 15:41:45.95035
perm-cliente-4	role-system-cliente	workorders_evaluate	2025-11-10 15:41:45.95035
perm-cliente-5	role-system-cliente	floor_plan_view	2025-11-10 15:41:45.95035
perm-cliente-6	role-system-cliente	heatmap_view	2025-11-10 15:41:45.95035
perm-cliente-7	role-system-cliente	sites_view	2025-11-10 15:41:45.95035
perm-cliente-8	role-system-cliente	reports_view	2025-11-10 15:41:45.95035
perm-operador-1	role-system-operador	dashboard_view	2025-11-10 15:41:45.95035
perm-operador-2	role-system-operador	workorders_view	2025-11-10 15:41:45.95035
perm-operador-3	role-system-operador	workorders_edit	2025-11-10 15:41:45.95035
perm-operador-4	role-system-operador	checklists_view	2025-11-10 15:41:45.95035
\.


--
-- Data for Name: service_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_categories (id, type_id, name, description, code, module, is_active, created_at, updated_at, customer_id) FROM stdin;
\.


--
-- Data for Name: service_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_types (id, name, description, code, module, is_active, created_at, updated_at, customer_id, company_id) FROM stdin;
\.


--
-- Data for Name: service_zones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_zones (id, service_id, zone_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.services (id, name, description, estimated_duration_minutes, priority, requirements, module, is_active, created_at, updated_at, customer_id, category_id, type_id) FROM stdin;
\.


--
-- Data for Name: site_shifts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.site_shifts (id, site_id, name, start_time, end_time, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sites (id, company_id, customer_id, module, name, address, description, floor_plan_image_url, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sla_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sla_configs (id, company_id, name, category, module, time_to_start_minutes, time_to_complete_minutes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_role_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_role_assignments (id, user_id, role_id, customer_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_site_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_site_assignments (id, user_id, site_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, company_id, customer_id, username, email, password, name, role, user_type, assigned_client_id, auth_provider, external_id, ms_tenant_id, modules, is_active, created_at, updated_at) FROM stdin;
user-admin-opus-default	company-opus-default	\N	admin@opus.com	admin@opus.com	$2b$10$pv80/LTkqa5FX08tnusg0ut4urWNcAiMMuwCyrl7lWrFsXfD5Skxa	Administrador OPUS	admin	opus_user	\N	local	\N	\N	{clean,maintenance}	t	2025-11-10 05:17:27.539379	2025-11-10 05:17:27.539379
\.


--
-- Data for Name: webhook_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.webhook_configs (id, company_id, name, url, events, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_order_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_order_comments (id, work_order_id, user_id, comment, attachments, is_reopen_request, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_orders (id, number, company_id, module, zone_id, service_id, cleaning_activity_id, maintenance_activity_id, checklist_template_id, maintenance_checklist_template_id, equipment_id, maintenance_plan_equipment_id, type, status, priority, title, description, assigned_user_id, origin, qr_code_point_id, requester_name, requester_contact, scheduled_date, due_date, scheduled_start_at, scheduled_end_at, started_at, completed_at, estimated_hours, sla_start_minutes, sla_complete_minutes, observations, checklist_data, attachments, customer_rating, customer_rating_comment, rated_at, rated_by, created_at, updated_at, cancellation_reason, cancelled_at, cancelled_by, customer_id, assigned_user_ids) FROM stdin;
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zones (id, site_id, module, name, description, area_m2, capacity, category, position_x, position_y, size_scale, color, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Name: ai_integrations ai_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_pkey PRIMARY KEY (id);


--
-- Name: bathroom_counters bathroom_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bathroom_counters
    ADD CONSTRAINT bathroom_counters_pkey PRIMARY KEY (id);


--
-- Name: chat_conversations chat_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: checklist_templates checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: cleaning_activities cleaning_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_counters company_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_counters
    ADD CONSTRAINT company_counters_pkey PRIMARY KEY (id);


--
-- Name: custom_roles custom_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_roles
    ADD CONSTRAINT custom_roles_pkey PRIMARY KEY (id);


--
-- Name: customer_counters customer_counters_customer_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_customer_key_unique UNIQUE (customer_id, key);


--
-- Name: customer_counters customer_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: dashboard_goals dashboard_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_goals
    ADD CONSTRAINT dashboard_goals_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_serial_number_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_serial_number_unique UNIQUE (serial_number);


--
-- Name: equipment_types equipment_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_pkey PRIMARY KEY (id);


--
-- Name: maintenance_activities maintenance_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_pkey PRIMARY KEY (id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_pkey PRIMARY KEY (id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plans maintenance_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_pkey PRIMARY KEY (id);


--
-- Name: public_request_logs public_request_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_request_logs
    ADD CONSTRAINT public_request_logs_pkey PRIMARY KEY (id);


--
-- Name: qr_code_points qr_code_points_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_code_unique UNIQUE (code);


--
-- Name: qr_code_points qr_code_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: service_categories service_categories_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_code_unique UNIQUE (code);


--
-- Name: service_categories service_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_pkey PRIMARY KEY (id);


--
-- Name: service_types service_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_pkey PRIMARY KEY (id);


--
-- Name: service_zones service_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: site_shifts site_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_shifts
    ADD CONSTRAINT site_shifts_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: sla_configs sla_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sla_configs
    ADD CONSTRAINT sla_configs_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plan_equipments unique_plan_equipment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT unique_plan_equipment UNIQUE (plan_id, equipment_id);


--
-- Name: service_zones unique_service_zone; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT unique_service_zone UNIQUE (service_id, zone_id);


--
-- Name: user_role_assignments user_role_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_pkey PRIMARY KEY (id);


--
-- Name: user_site_assignments user_site_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: webhook_configs webhook_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_configs
    ADD CONSTRAINT webhook_configs_pkey PRIMARY KEY (id);


--
-- Name: work_order_comments work_order_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: work_orders_customer_number_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX work_orders_customer_number_unique ON public.work_orders USING btree (customer_id, number);


--
-- Name: ai_integrations ai_integrations_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: ai_integrations ai_integrations_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: audit_logs audit_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_counter_id_bathroom_counters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_counter_id_bathroom_counters_id_fk FOREIGN KEY (counter_id) REFERENCES public.bathroom_counters(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_work_order_id_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_work_order_id_work_orders_id_fk FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: bathroom_counters bathroom_counters_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bathroom_counters
    ADD CONSTRAINT bathroom_counters_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: chat_conversations chat_conversations_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: chat_conversations chat_conversations_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: chat_conversations chat_conversations_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: chat_messages chat_messages_ai_integration_id_ai_integrations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_ai_integration_id_ai_integrations_id_fk FOREIGN KEY (ai_integration_id) REFERENCES public.ai_integrations(id);


--
-- Name: chat_messages chat_messages_conversation_id_chat_conversations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_conversation_id_chat_conversations_id_fk FOREIGN KEY (conversation_id) REFERENCES public.chat_conversations(id) ON DELETE CASCADE;


--
-- Name: checklist_templates checklist_templates_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: checklist_templates checklist_templates_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: checklist_templates checklist_templates_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: checklist_templates checklist_templates_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: cleaning_activities cleaning_activities_checklist_template_id_checklist_templates_i; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_checklist_template_id_checklist_templates_i FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: cleaning_activities cleaning_activities_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: cleaning_activities cleaning_activities_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: cleaning_activities cleaning_activities_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: cleaning_activities cleaning_activities_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: cleaning_activities cleaning_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: cleaning_activities cleaning_activities_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: company_counters company_counters_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_counters
    ADD CONSTRAINT company_counters_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: custom_roles custom_roles_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_roles
    ADD CONSTRAINT custom_roles_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: customer_counters customer_counters_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers customers_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: dashboard_goals dashboard_goals_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_goals
    ADD CONSTRAINT dashboard_goals_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: equipment equipment_equipment_type_id_equipment_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_equipment_type_id_equipment_types_id_fk FOREIGN KEY (equipment_type_id) REFERENCES public.equipment_types(id);


--
-- Name: equipment equipment_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: equipment_types equipment_types_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: maintenance_activities maintenance_activities_assigned_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_assigned_user_id_users_id_fk FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: maintenance_activities maintenance_activities_checklist_template_id_maintenance_checkl; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_checklist_template_id_maintenance_checkl FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_activities maintenance_activities_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_activities maintenance_activities_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: maintenance_activities maintenance_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_plan_id_maintenance_plans_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_plan_id_maintenance_plans_id_fk FOREIGN KEY (plan_id) REFERENCES public.maintenance_plans(id);


--
-- Name: maintenance_plans maintenance_plans_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_plans maintenance_plans_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: public_request_logs public_request_logs_qr_code_point_id_qr_code_points_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_request_logs
    ADD CONSTRAINT public_request_logs_qr_code_point_id_qr_code_points_id_fk FOREIGN KEY (qr_code_point_id) REFERENCES public.qr_code_points(id);


--
-- Name: qr_code_points qr_code_points_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: qr_code_points qr_code_points_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: qr_code_points qr_code_points_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: role_permissions role_permissions_role_id_custom_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_custom_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.custom_roles(id);


--
-- Name: service_categories service_categories_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: service_categories service_categories_type_id_service_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_type_id_service_types_id_fk FOREIGN KEY (type_id) REFERENCES public.service_types(id);


--
-- Name: service_types service_types_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: service_types service_types_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: service_zones service_zones_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: service_zones service_zones_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: services services_category_id_service_categories_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_category_id_service_categories_id_fk FOREIGN KEY (category_id) REFERENCES public.service_categories(id);


--
-- Name: services services_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: services services_type_id_service_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_type_id_service_types_id_fk FOREIGN KEY (type_id) REFERENCES public.service_types(id);


--
-- Name: site_shifts site_shifts_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_shifts
    ADD CONSTRAINT site_shifts_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: sites sites_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: sites sites_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: sla_configs sla_configs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sla_configs
    ADD CONSTRAINT sla_configs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: user_role_assignments user_role_assignments_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: user_role_assignments user_role_assignments_role_id_custom_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_role_id_custom_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.custom_roles(id);


--
-- Name: user_role_assignments user_role_assignments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_site_assignments user_site_assignments_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: user_site_assignments user_site_assignments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: users users_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: webhook_configs webhook_configs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_configs
    ADD CONSTRAINT webhook_configs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: work_order_comments work_order_comments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: work_order_comments work_order_comments_work_order_id_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_work_order_id_work_orders_id_fk FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: work_orders work_orders_assigned_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_assigned_user_id_users_id_fk FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_cancelled_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_cancelled_by_users_id_fk FOREIGN KEY (cancelled_by) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_checklist_template_id_checklist_templates_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_checklist_template_id_checklist_templates_id_fk FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: work_orders work_orders_cleaning_activity_id_cleaning_activities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_cleaning_activity_id_cleaning_activities_id_fk FOREIGN KEY (cleaning_activity_id) REFERENCES public.cleaning_activities(id);


--
-- Name: work_orders work_orders_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: work_orders work_orders_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: work_orders work_orders_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: work_orders work_orders_maintenance_activity_id_maintenance_activities_id_f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_activity_id_maintenance_activities_id_f FOREIGN KEY (maintenance_activity_id) REFERENCES public.maintenance_activities(id);


--
-- Name: work_orders work_orders_maintenance_checklist_template_id_maintenance_check; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_checklist_template_id_maintenance_check FOREIGN KEY (maintenance_checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: work_orders work_orders_maintenance_plan_equipment_id_maintenance_plan_equi; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_plan_equipment_id_maintenance_plan_equi FOREIGN KEY (maintenance_plan_equipment_id) REFERENCES public.maintenance_plan_equipments(id);


--
-- Name: work_orders work_orders_qr_code_point_id_qr_code_points_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_qr_code_point_id_qr_code_points_id_fk FOREIGN KEY (qr_code_point_id) REFERENCES public.qr_code_points(id);


--
-- Name: work_orders work_orders_rated_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_rated_by_users_id_fk FOREIGN KEY (rated_by) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: work_orders work_orders_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: zones zones_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- PostgreSQL database dump complete
--

