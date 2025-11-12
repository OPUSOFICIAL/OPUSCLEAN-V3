--
-- PostgreSQL database dump
--

-- Dumped from database version 16.10
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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: ai_integration_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.ai_integration_status AS ENUM (
    'ativa',
    'inativa',
    'erro'
);


ALTER TYPE public.ai_integration_status OWNER TO postgres;

--
-- Name: ai_provider; Type: TYPE; Schema: public; Owner: postgres
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


ALTER TYPE public.ai_provider OWNER TO postgres;

--
-- Name: auth_provider; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.auth_provider AS ENUM (
    'local',
    'microsoft'
);


ALTER TYPE public.auth_provider OWNER TO postgres;

--
-- Name: bathroom_counter_action; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.bathroom_counter_action AS ENUM (
    'increment',
    'decrement',
    'reset'
);


ALTER TYPE public.bathroom_counter_action OWNER TO postgres;

--
-- Name: equipment_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.equipment_status AS ENUM (
    'operacional',
    'em_manutencao',
    'inoperante',
    'aposentado'
);


ALTER TYPE public.equipment_status OWNER TO postgres;

--
-- Name: frequency; Type: TYPE; Schema: public; Owner: postgres
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


ALTER TYPE public.frequency OWNER TO postgres;

--
-- Name: module; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.module AS ENUM (
    'clean',
    'maintenance'
);


ALTER TYPE public.module OWNER TO postgres;

--
-- Name: permission_key; Type: TYPE; Schema: public; Owner: postgres
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


ALTER TYPE public.permission_key OWNER TO postgres;

--
-- Name: priority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.priority AS ENUM (
    'baixa',
    'media',
    'alta',
    'critica'
);


ALTER TYPE public.priority OWNER TO postgres;

--
-- Name: qr_code_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.qr_code_type AS ENUM (
    'execucao',
    'atendimento'
);


ALTER TYPE public.qr_code_type OWNER TO postgres;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'gestor_cliente',
    'supervisor_site',
    'operador',
    'auditor'
);


ALTER TYPE public.user_role OWNER TO postgres;

--
-- Name: user_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_type AS ENUM (
    'opus_user',
    'customer_user'
);


ALTER TYPE public.user_type OWNER TO postgres;

--
-- Name: work_order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.work_order_status AS ENUM (
    'aberta',
    'em_execucao',
    'pausada',
    'vencida',
    'concluida',
    'cancelada'
);


ALTER TYPE public.work_order_status OWNER TO postgres;

--
-- Name: work_order_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.work_order_type AS ENUM (
    'programada',
    'corretiva_interna',
    'corretiva_publica'
);


ALTER TYPE public.work_order_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_integrations; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.ai_integrations OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: bathroom_counter_logs; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.bathroom_counter_logs OWNER TO postgres;

--
-- Name: bathroom_counters; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.bathroom_counters OWNER TO postgres;

--
-- Name: chat_conversations; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.chat_conversations OWNER TO postgres;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: checklist_templates; Type: TABLE; Schema: public; Owner: postgres
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
    zone_ids text[],
    customer_id character varying
);


ALTER TABLE public.checklist_templates OWNER TO postgres;

--
-- Name: cleaning_activities; Type: TABLE; Schema: public; Owner: postgres
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
    customer_id character varying,
    start_date date,
    end_date date,
    site_ids text[],
    zone_ids text[]
);


ALTER TABLE public.cleaning_activities OWNER TO postgres;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.companies OWNER TO postgres;

--
-- Name: company_counters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_counters (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    key character varying NOT NULL,
    next_number integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.company_counters OWNER TO postgres;

--
-- Name: custom_roles; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.custom_roles OWNER TO postgres;

--
-- Name: customer_counters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_counters (
    id character varying NOT NULL,
    customer_id character varying NOT NULL,
    key character varying NOT NULL,
    next_number integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.customer_counters OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
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
    updated_at timestamp without time zone DEFAULT now(),
    login_logo text,
    sidebar_logo text,
    sidebar_logo_collapsed text,
    module_colors jsonb,
    subdomain character varying,
    home_logo text,
    favicon_url text,
    primary_color character varying(7),
    secondary_color character varying(7),
    accent_color character varying(7),
    landing_title character varying(200),
    landing_subtitle character varying(500),
    landing_hero_image text,
    meta_description character varying(300)
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: dashboard_goals; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.dashboard_goals OWNER TO postgres;

--
-- Name: equipment; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.equipment OWNER TO postgres;

--
-- Name: equipment_types; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.equipment_types OWNER TO postgres;

--
-- Name: maintenance_activities; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.maintenance_activities OWNER TO postgres;

--
-- Name: maintenance_checklist_executions; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.maintenance_checklist_executions OWNER TO postgres;

--
-- Name: maintenance_checklist_templates; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.maintenance_checklist_templates OWNER TO postgres;

--
-- Name: maintenance_plan_equipments; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.maintenance_plan_equipments OWNER TO postgres;

--
-- Name: maintenance_plans; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.maintenance_plans OWNER TO postgres;

--
-- Name: public_request_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.public_request_logs (
    id character varying NOT NULL,
    qr_code_point_id character varying,
    ip_hash character varying NOT NULL,
    user_agent text,
    request_data jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.public_request_logs OWNER TO postgres;

--
-- Name: qr_code_points; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.qr_code_points OWNER TO postgres;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    id character varying NOT NULL,
    role_id character varying NOT NULL,
    permission public.permission_key NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: service_categories; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.service_categories OWNER TO postgres;

--
-- Name: service_types; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.service_types OWNER TO postgres;

--
-- Name: service_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_zones (
    id character varying NOT NULL,
    service_id character varying NOT NULL,
    zone_id character varying NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.service_zones OWNER TO postgres;

--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: site_shifts; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.site_shifts OWNER TO postgres;

--
-- Name: sites; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.sites OWNER TO postgres;

--
-- Name: sla_configs; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.sla_configs OWNER TO postgres;

--
-- Name: user_allowed_customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_allowed_customers (
    id character varying DEFAULT (gen_random_uuid())::character varying NOT NULL,
    user_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_allowed_customers OWNER TO postgres;

--
-- Name: user_role_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_role_assignments (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    role_id character varying NOT NULL,
    customer_id character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_role_assignments OWNER TO postgres;

--
-- Name: user_site_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_site_assignments (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    site_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_site_assignments OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: webhook_configs; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.webhook_configs OWNER TO postgres;

--
-- Name: work_order_comments; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.work_order_comments OWNER TO postgres;

--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.work_orders OWNER TO postgres;

--
-- Name: zones; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.zones OWNER TO postgres;

--
-- Data for Name: ai_integrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_integrations (id, company_id, name, provider, model, api_key, endpoint, status, is_default, max_tokens, temperature, enable_logs, last_tested_at, last_error_message, created_by, created_at, updated_at) FROM stdin;
Opy5Y3iHROPLiXYakM06V	company-admin-default	Facilities Cloud	groq	llama-3.3-70b-versatile	2c7c3deed20a652675d3afb198666392:dd36d42bb397ff2e109d11ac166e55ad:a41413f5bd5001311d9f133410770bc0ab629d054d684b0f30a94ab917b4a29fb13226342efccfa3bf562cbb882a2ad1bf34f5e0de11a07e		ativa	t	4096	0.70	f	\N	\N	user-admin-opus	2025-11-11 04:06:02.553184	2025-11-11 04:06:02.553184
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, company_id, user_id, entity_type, entity_id, action, changes, metadata, "timestamp", created_at) FROM stdin;
13f858e7-5935-4693-a35f-50174382e39e	company-admin-default	\N	work_order	212d41ad-ef44-47ac-b3c1-701ad57e65b3	update	\N	{"details": "Work order #1 updated - Status: em_execucao"}	2025-11-11 02:54:28.847	2025-11-11 02:54:28.898857
38666bf7-3734-47fa-89c7-44e51e9876c7	company-admin-default	\N	work_order	212d41ad-ef44-47ac-b3c1-701ad57e65b3	update	\N	{"details": "Work order #1 updated - Status: concluida"}	2025-11-11 02:54:35.12	2025-11-11 02:54:35.171641
90c3c4e0-156c-478e-84a7-7e819c96ec31	company-admin-default	\N	work_order	b086a6b1-5605-475f-a010-7f1ea8aa1723	update	\N	{"details": "Work order #5 updated - Status: em_execucao"}	2025-11-11 02:54:55.152	2025-11-11 02:54:55.202736
84b4f107-d7bc-4d1b-bd2f-1c9162a18ea2	company-admin-default	\N	work_order	b086a6b1-5605-475f-a010-7f1ea8aa1723	update	\N	{"details": "Work order #5 updated - Status: concluida"}	2025-11-11 02:54:59.778	2025-11-11 02:54:59.829311
8217f016-d66d-4851-afe1-57eab555ce63	company-admin-default	\N	work_order	db1af978-068d-4f3d-a2cd-501c025d0152	update	\N	{"details": "Work order #3 updated - Status: em_execucao"}	2025-11-11 02:55:20.655	2025-11-11 02:55:20.706341
8222f125-d039-49b9-9b9a-0ce7bc2e0a78	company-admin-default	\N	work_order	db1af978-068d-4f3d-a2cd-501c025d0152	update	\N	{"details": "Work order #3 updated - Status: concluida"}	2025-11-11 02:55:24.591	2025-11-11 02:55:24.642325
8a63f94b-3f55-4da2-83e8-d8e514097101	company-admin-default	\N	work_order	fb0982f6-a330-4a76-81b3-5aa32b249d84	update	\N	{"details": "Work order #4 updated - Status: em_execucao"}	2025-11-11 02:56:53.061	2025-11-11 02:56:53.112396
bf94d641-56f1-4e6e-9165-f8892090c611	company-admin-default	\N	work_order	fb0982f6-a330-4a76-81b3-5aa32b249d84	update	\N	{"details": "Work order #4 updated - Status: concluida"}	2025-11-11 02:56:56.873	2025-11-11 02:56:56.923586
d4b76fc0-483e-482a-8870-71c5bb94f502	company-admin-default	\N	work_order	a5cec180-8b1a-49c4-a724-1f8b9809e5d7	update	\N	{"details": "Work order #6 updated - Status: em_execucao"}	2025-11-11 02:57:15.737	2025-11-11 02:57:15.788227
da7f8c59-e3a4-423c-aa24-1ef4cacf164d	company-admin-default	\N	work_order	a5cec180-8b1a-49c4-a724-1f8b9809e5d7	update	\N	{"details": "Work order #6 updated - Status: pausada"}	2025-11-11 02:57:22.011	2025-11-11 02:57:22.061608
0440abf3-2e91-4aee-a0c4-47f04bffe68f	company-admin-default	\N	work_order	c6ab6737-e588-4453-b519-7b648fbf2955	update	\N	{"details": "Work order #7 updated - Status: em_execucao"}	2025-11-11 02:57:47.367	2025-11-11 02:57:47.419126
86f63c4b-b8d1-4c7f-b92d-536bb9fccaac	company-admin-default	\N	work_order	bbf94365-6acd-4130-b45b-a41250beb308	update	\N	{"details": "Work order #3 updated - Status: em_execucao"}	2025-11-12 20:00:09.371	2025-11-12 20:00:09.371896
cc6b2ef1-d34f-4b10-8312-0add50c3033d	company-admin-default	\N	work_order	bbf94365-6acd-4130-b45b-a41250beb308	update	\N	{"details": "Work order #3 updated - Status: concluida"}	2025-11-12 20:00:16.015	2025-11-12 20:00:16.016874
\.


--
-- Data for Name: bathroom_counter_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bathroom_counter_logs (id, counter_id, user_id, delta, action, previous_value, new_value, work_order_id, created_at) FROM stdin;
\.


--
-- Data for Name: bathroom_counters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bathroom_counters (id, zone_id, current_count, limit_count, last_reset, auto_reset_turn, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: chat_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_conversations (id, user_id, company_id, customer_id, module, title, is_active, created_at, updated_at) FROM stdin;
Oi9yv8DgY4AyaDSwv7rYP	user-admin-opus	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	clean	oi	t	2025-11-11 04:06:10.394803	2025-11-11 04:06:10.394803
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, conversation_id, role, content, context, ai_integration_id, tokens_used, error, created_at) FROM stdin;
Rsq9U0YqzwHwLajS7Elch	Oi9yv8DgY4AyaDSwv7rYP	user	oi	\N	\N	\N	\N	2025-11-11 04:06:10.504035
_whnmjca2I8GZkEpKYdFn	Oi9yv8DgY4AyaDSwv7rYP	assistant	Desculpe, ocorreu um erro ao processar sua mensagem.	\N	Opy5Y3iHROPLiXYakM06V	\N	value.toISOString is not a function	2025-11-11 04:06:10.714641
-ylxOotuwueELQ8Ye1A4z	Oi9yv8DgY4AyaDSwv7rYP	user	oi	\N	\N	\N	\N	2025-11-11 04:07:19.881491
KMlGPFG2p_p4qnvOY1bQ5	Oi9yv8DgY4AyaDSwv7rYP	assistant	Desculpe, ocorreu um erro ao processar sua mensagem.	\N	Opy5Y3iHROPLiXYakM06V	\N	value.toISOString is not a function	2025-11-11 04:07:20.09285
RfxIDd2OMuMZyACuVqHS_	Oi9yv8DgY4AyaDSwv7rYP	user	oi	\N	\N	\N	\N	2025-11-11 04:36:03.491677
NG7YSsAzYelUgrsFznsS4	Oi9yv8DgY4AyaDSwv7rYP	assistant	Desculpe, ocorreu um erro ao processar sua mensagem.	\N	Opy5Y3iHROPLiXYakM06V	\N	value.toISOString is not a function	2025-11-11 04:36:03.701131
y9C9NYcm03a7qQH4yEjVT	Oi9yv8DgY4AyaDSwv7rYP	user	você está funcional?	\N	\N	\N	\N	2025-11-11 04:47:03.218315
6o3YDKekBxjyIsflJl5Pc	Oi9yv8DgY4AyaDSwv7rYP	assistant	Desculpe, ocorreu um erro ao processar sua mensagem.	\N	Opy5Y3iHROPLiXYakM06V	\N	value.toISOString is not a function	2025-11-11 04:47:03.437978
kwxrOVBXHeloJm72i6Dgw	Oi9yv8DgY4AyaDSwv7rYP	user	oi	\N	\N	\N	\N	2025-11-11 04:55:32.50582
u9XdnWxfE7Ed-2SbXwhTG	Oi9yv8DgY4AyaDSwv7rYP	assistant	Desculpe, ocorreu um erro ao processar sua mensagem.	\N	Opy5Y3iHROPLiXYakM06V	\N	value.toISOString is not a function	2025-11-11 04:55:32.715722
\.


--
-- Data for Name: checklist_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checklist_templates (id, company_id, service_id, site_id, name, description, items, module, created_at, updated_at, zone_id, site_ids, zone_ids, customer_id) FROM stdin;
checklist-1762458808131-9CgGFQELcI	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA RTM VERNIZ	Limpeza de ambientes cabine final RTM verniz	[{"id": "1762457585858", "type": "checkbox", "label": "Jateamento com lava jato e aplicação de graxa patente no transportador", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457617693", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457647863", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457681300", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457719343", "type": "checkbox", "label": "Limpeza do flash off do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762457752809", "type": "checkbox", "label": "Limpeza das luminárias do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457784562", "type": "checkbox", "label": "Limpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762458776711", "type": "photo", "label": "Evidencia de foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762458805315", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762460701782", "type": "text", "label": "Comentario relevante sobre atividades", "options": [], "required": false, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:06.505366	2025-11-11 05:39:39.69639	20864c38-1234-46e6-8581-46e3c55a9b87	{ff191700-ac34-4df7-accc-1d420568d645}	{20864c38-1234-46e6-8581-46e3c55a9b87}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762464395325-_PfmyxiXtl	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE ESTÁTICA SMC FANTE	Limpeza e conservação da cabine fante SMC	[{"id": "1762464089654", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": -23, "minChecked": 1}, "description": ""}, {"id": "1762464117960", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464144269", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464170691", "type": "checkbox", "label": "Limpeza do fosso da cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464189406", "type": "checkbox", "label": "Limpeza das liminárias da cabine estática SMC fante", "options": [], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464214230", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464242903", "type": "checkbox", "label": "Troca de filtro multibolsa cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464265995", "type": "checkbox", "label": "Troca de filtro plenuns cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464343119", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464364332", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464400779", "type": "text", "label": "Comentario relevante a atividade", "options": [], "required": true, "validation": {"maxLength": 40, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:07.938783	2025-11-11 05:42:10.510144	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	{ff191700-ac34-4df7-accc-1d420568d645}	{a415c33b-c0ac-4a79-87c3-38a7c36d0cfa}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762973486570-4x-EwqJ3lB	company-admin-default	092ec8ec-352e-4e75-807f-136400f0f4ef	\N	checklist de teste		[{"id": "1762973440515", "type": "text", "label": "1", "options": [], "required": false, "validation": {"minLength": 1}, "description": ""}]	clean	2025-11-12 18:51:26.571762	2025-11-12 19:03:03.63564	\N	{91895d5b-c095-4238-a9c0-d06485ed0ee7,cd953978-a480-4b4b-a3eb-11fc09965748}	{c9621786-3bab-4a67-b23d-d4e5f753b4af,94b64481-098c-40dc-b852-bb3e52a545c9,47266a3a-57c3-4745-91fe-f0cde2754941,a0d972f8-301f-4385-9e62-3c352683b6c7}	783a6a21-aa25-421d-b1da-bbd03410f2c5
checklist-1762195387385-CW9wW1-MkN	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro Masculino Logística	\N	[{"id": "1762195284288", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195295539", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195304196", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195312412", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195321274", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195330690", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195341837", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195350953", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:05.075061	2025-11-11 16:22:24.771583	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1761786488474-q61adWy1TV	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Masculino Tech center	Realizar limpeza e abastecimento de descartáveis do WC masculino tech center	[{"id": "1761785538950", "type": "checkbox", "label": "Limpeza do piso, foi feita ?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761785621669", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["Ok", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761785809069", "type": "checkbox", "label": "Lavar piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761785998964", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786314983", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786370307", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786450411", "type": "checkbox", "label": "Limpeza de interruptores e bancos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786512845", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:43:03.673194	2025-11-11 16:22:05.714903	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1761776428513-1vNQZrVqtO	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Feminino Tech center 	Limpeza e reposição de descartáveis do WC feminino Tech center.	[{"id": "1761775239795", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761775268941", "type": "checkbox", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776070903", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776144009", "type": "checkbox", "label": "Lavar o piso, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776214898", "type": "checkbox", "label": "Limpeza de interruptores e bancos, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776275957", "type": "checkbox", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776328789", "type": "checkbox", "label": "Retirada de lixo, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776458735", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:05.892057	2025-11-11 05:38:42.600882	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{2ba21003-b82d-4950-8a6b-f504740960ea}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1759332028080-yP1zdZiE7V	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA PRIME RTM	\N	[{"id": "1762450704351", "type": "checkbox", "label": "Plastificação dos carrinhos, remover e plastificar carrinhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762450753344", "type": "checkbox", "label": "Limpeza interna de paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762450829253", "type": "checkbox", "label": "Aplicação de filme plastico pintável 3M e aplicação de sabão da gage da cabine de pintura do prime ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762450866556", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452273918", "type": "checkbox", "label": "Limpeza do flash off do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452326533", "type": "checkbox", "label": "Limpeza estufa do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452415744", "type": "checkbox", "label": "Limpeza de luminárias do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452492385", "type": "checkbox", "label": "Aspiração superior (teto) da estufa do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762452695501", "type": "checkbox", "label": "Limpeza raspar rotores (4) da exaustão e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762452833296", "type": "checkbox", "label": "Jateamento com lava jato e aplicação de graxa patente do transportador", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762453431527", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 4, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762453599610", "type": "photo", "label": "Evidencia foto antes atividade", "options": [], "required": true, "validation": {"photoMaxCount": 4, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762453720625", "type": "text", "label": "Comentário relevante da atividade", "options": [], "required": true, "validation": {"maxLength": 30, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:06.300914	2025-11-11 03:44:06.300914	20864c38-1234-46e6-8581-46e3c55a9b87	{ff191700-ac34-4df7-accc-1d420568d645}	{20864c38-1234-46e6-8581-46e3c55a9b87}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762193172542-gLSkJ7cCXi	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro ADM Feminino	\N	[{"id": "1762193050345", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 5}, "description": ""}, {"id": "1762193068955", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193080501", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193093141", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193105431", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193117267", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193127418", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193137573", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:05.484677	2025-11-11 16:22:42.939433	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1761847086703-dMeETUQhOU	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Recepção	Limpeza geral do WC da recepção e abastecimento de descartáveis 	[{"id": "1761845873143", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761845923460", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761846013334", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761846078278", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761846996036", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxLength": 2, "minLength": 2, "maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761847048621", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": [], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:43:03.470543	2025-11-11 16:21:55.687664	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762880029053-PcbN4fv6Ax	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Limpeza de banheiros		[{"id": "1762879966251", "type": "checkbox", "label": "Limpeza Realizada? ", "options": ["Limpeza do piso", "Limpeza vertical de divisórias, paredes e portas", "Lavar o piso", "Limpeza de maçanetas e corrimões", "Retirada do lixo", "Abastecimento dos descartáveis", "Limpeza de interruptores e bancos", "Limpeza de pias, vasos e espelhos"], "required": true, "validation": {"minChecked": 8}, "description": "Assinale o que foi realizado."}, {"id": "1762879989647", "type": "photo", "label": "Fotos do antes da limpeza", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 2, "photoRequired": true}, "description": ""}, {"id": "1762880017337", "type": "photo", "label": "Foto do depois da limpeza", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 2, "photoRequired": true}, "description": ""}]	clean	2025-11-11 16:53:49.055858	2025-11-12 16:41:12.966056	\N	{site-faurecia-administrativo,site-faurecia-ambulatorio,site-faurecia-portaria,site-faurecia-producao,site-faurecia-refeitorio,site-faurecia-vestiarios}	{zone-adm-fem,zone-adm-masc,zone-amb-banheiro,zone-adm-acess-01,zone-adm-acess-02,zone-adm-fem-corp,zone-ref-fem-coz,zone-prod-fem-gm,zone-prod-fem-log,zone-prod-fem-scania,zone-port-fem,zone-adm-fem-tech,zone-prod-fem-toyota,zone-adm-masc-corp,zone-prod-masc-gm,zone-prod-masc-log,zone-port-masc,zone-prod-masc-scania,zone-adm-masc-tech,zone-prod-masc-toyota,zone-adm-unissex}	43538320-fe1b-427c-9cb9-6b7ab06c1247
checklist-1761856942299-pHoKcSHvUb	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Masculino corporativo	Limpeza de WC masculino e reposição de descartáveis	[{"id": "1761856773237", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856800642", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856856045", "type": "checkbox", "label": "Limpeza vertical divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856903409", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856943872", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856975831", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:05.281182	2025-11-11 16:22:34.066307	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762193869779-YBWhevaQFd	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro Feminino Cozinha	\N	[{"id": "1762193595488", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193609040", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193659404", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193697920", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193726995", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193737451", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193753378", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193773027", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": false, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:05.688549	2025-11-11 16:22:52.064507	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1761836254359-8og_w_SonU	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC feminino portaria	Limpeza e troca de descartáveis do WC feminino na portaria	[{"id": "1761829165414", "type": "checkbox", "label": "Limpeza de pias, ralos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831089034", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831147464", "type": "checkbox", "label": "Lavar piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831362294", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831408447", "type": "checkbox", "label": "Limpezas de interruptores e bancos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831476269", "type": "checkbox", "label": "Limpeza maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831877540", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761836286231", "type": "checkbox", "label": "Abastecimento de descartáveis ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:06.095699	2025-11-11 16:23:00.111958	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762461380023-MbLbIzdWaG	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CAMBINE DE PINTURA FINAL SMC	Realizar atividades de limpeza técnica na cabine de pintura SMC	[{"id": "1762461105234", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461133005", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461163458", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461197806", "type": "checkbox", "label": "Limpeza do flash off da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461224397", "type": "checkbox", "label": "Limpeza das luminárias da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461250872", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão da base e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461299107", "type": "photo", "label": "Evidencia fotos antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461332422", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461383473", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:06.917013	2025-11-11 05:41:28.707981	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	{ff191700-ac34-4df7-accc-1d420568d645}	{a415c33b-c0ac-4a79-87c3-38a7c36d0cfa}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762461869289-dKtnq1L-Ny	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA FINAL SMC VERNIZ	Limpeza e conservação da cabine de verniz SMC 	[{"id": "1762461583393", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461614929", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461645131", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461677630", "type": "checkbox", "label": "Limpeza do flash off do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461704522", "type": "checkbox", "label": "Limpeza das liminárias do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461727214", "type": "checkbox", "label": "Aspiração da região superior (teto) da estufa da pintura final", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461755138", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão do verniz e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461782163", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461808350", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461875034", "type": "text", "label": "Comentario relevante a atividade", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}, {"id": "1762461985427", "type": "checkbox", "label": "Jateamento com lava jato e aplicação de graxa patente no transportador", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}]	clean	2025-11-11 03:44:07.325743	2025-11-11 05:41:40.027674	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	{ff191700-ac34-4df7-accc-1d420568d645}	{a415c33b-c0ac-4a79-87c3-38a7c36d0cfa}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762463769882-ftVpLmIQbe	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE RETOQUE RTM 123	Limpeza e conservação da cabine das cabines de retoques RTM	[{"id": "1762463601088", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762463637603", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762463695446", "type": "checkbox", "label": "Limpeza do chão da cabine", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762463715492", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762463746494", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762463770206", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:07.735229	2025-11-11 05:42:00.870232	20864c38-1234-46e6-8581-46e3c55a9b87	{ff191700-ac34-4df7-accc-1d420568d645}	{20864c38-1234-46e6-8581-46e3c55a9b87}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762460579246-8WeuppXOUV	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA PRIME SMC	\N	[{"id": "1762460122390", "type": "checkbox", "label": "Plastificação dos carrinhos (remover e recolocar os plásticos)", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460156660", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460189810", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460224237", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460256442", "type": "checkbox", "label": "Limpeza do flash off do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460291143", "type": "checkbox", "label": "Limpeza estufa do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460318546", "type": "checkbox", "label": "Limpeza das luminárias do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460353096", "type": "checkbox", "label": "Aspiração da região superior (teto) da estufa do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460380520", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460444638", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762460470330", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}]	clean	2025-11-11 03:44:06.711315	2025-11-11 05:39:28.530544	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	{ff191700-ac34-4df7-accc-1d420568d645}	{a415c33b-c0ac-4a79-87c3-38a7c36d0cfa}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1760640725459-vyFf79rK0p	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	PINTURA FINAL RTM	Limpeza da cabine de pintura final do RTM	[{"id": "1762454807555", "type": "checkbox", "label": "Limpeza interna de aparedes e vidros da cabine da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1762455006757", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da gage na cabine de pintura da base ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762455202894", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 2}, "description": ""}, {"id": "1762456250879", "type": "checkbox", "label": "Limpeza flash off da base ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 2}, "description": ""}, {"id": "1762456334238", "type": "checkbox", "label": "Limpeza das luminarias da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 2}, "description": ""}, {"id": "1762458938251", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762458962212", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762460666036", "type": "text", "label": "Comentario relevante das atividades", "options": [], "required": false, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:43:03.875717	2025-11-11 05:39:57.64359	20864c38-1234-46e6-8581-46e3c55a9b87	{ff191700-ac34-4df7-accc-1d420568d645}	{20864c38-1234-46e6-8581-46e3c55a9b87}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762462359598-z35kNf1eQh	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE ESTÁTICA RTM COWLING	Limpeza e higienização da cabine estática RTM	[{"id": "1762462257357", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762462287008", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762462316016", "type": "checkbox", "label": "Limpeza do chão da cabine", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762462411955", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762462433396", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762462461356", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:07.531108	2025-11-11 05:41:49.49964	20864c38-1234-46e6-8581-46e3c55a9b87	{ff191700-ac34-4df7-accc-1d420568d645}	{20864c38-1234-46e6-8581-46e3c55a9b87}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762464945821-unYORefXHU	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE ESTÁTICA SMC PRIMER	Limpeza e conservação da cabine estática SMC primer	[{"id": "1762464624074", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 6, "minChecked": 1}, "description": ""}, {"id": "1762464653612", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464684730", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine estática SMC primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464706909", "type": "checkbox", "label": "Limpeza do fosso da cabine estática SMC primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464731936", "type": "checkbox", "label": "Limpeza das liminárias da cabine estática SMC ptimer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464753748", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464777807", "type": "checkbox", "label": "Troca de filtro multibolsa cabine estática primer fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464799733", "type": "checkbox", "label": "Troca de filtro plenuns cabine estática SMC prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464889709", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464913336", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464944723", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 40, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:08.142551	2025-11-11 05:42:20.674637	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	{ff191700-ac34-4df7-accc-1d420568d645}	{a415c33b-c0ac-4a79-87c3-38a7c36d0cfa}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1761787799950-ZXGkoce5PR	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Masculino portaria 	Limpeza e troca de descartáveis do WC masculino portaria	[{"id": "1761787483563", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787528548", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787596830", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787631507", "type": "checkbox", "label": "Lavar piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787676044", "type": "checkbox", "label": "Limpeza de interruptores e bancos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787762358", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787795633", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787828492", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:43:03.265932	2025-11-11 16:19:42.874904	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1761861999785-cVnkJ8I1Xg	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro Corporativo Acessível 02	Limpeza e troca de descartáveis do banheiro masculino ADM RH	[{"id": "1761861638633", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761861697045", "type": "checkbox", "label": "Limpeza de piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761861865006", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxLength": 2, "minLength": 2}, "description": ""}, {"id": "1761861908475", "type": "checkbox", "label": "Limpeza maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761861943616", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862028767", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxLength": 2, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:43:04.078534	2025-11-11 16:22:14.397589	2ba21003-b82d-4950-8a6b-f504740960ea	{ff191700-ac34-4df7-accc-1d420568d645}	{a92f658a-9440-4a9e-8b92-49e8113d6fbb}	7913bae1-bdca-4fb4-9465-99a4754995b2
checklist-1762977241668-gEaeWMOpZz	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Teste		[{"id": "1762977229312", "type": "text", "label": "22", "options": [], "required": false, "validation": {"minLength": 2}, "description": ""}]	clean	2025-11-12 19:54:01.669207	2025-11-12 19:54:01.669207	\N	{site-faurecia-administrativo}	{zone-adm-masc,zone-adm-fem}	43538320-fe1b-427c-9cb9-6b7ab06c1247
\.


--
-- Data for Name: cleaning_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, frequency_config, module, checklist_template_id, sla_config_id, is_active, created_at, updated_at, start_time, end_time, customer_id, start_date, end_date, site_ids, zone_ids) FROM stdin;
ca-turno-rtm-1759264329	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Limpeza por Turno - Cabine RTM	Limpeza manhã, tarde e noite	turno	{"shifts": ["manha", "tarde", "noite"]}	clean	\N	\N	f	2025-11-11 03:44:10.800352	2025-11-11 03:44:10.800352	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759872977850-wyex3v3sb	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	semanal	{"monthDay": 1, "weekDays": ["segunda"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:11.005816	2025-11-11 03:44:11.005816	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759873220782-9wdyrslvl	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	semanal	{"monthDay": 1, "weekDays": ["sexta"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:11.209995	2025-11-11 03:44:11.209995	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759879717135-p4iquwjki	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	semanal	{"monthDay": 1, "weekDays": ["quarta"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:11.4139	2025-11-11 03:44:11.4139	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759880067433-fd68ihnyq	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	semanal	{"monthDay": 1, "weekDays": ["quinta"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:11.617485	2025-11-11 03:44:11.617485	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759880794641-vnxzwhd83	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	semanal	{"monthDay": 1, "weekDays": ["sabado"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:11.821691	2025-11-11 03:44:11.821691	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759881641311-jajipa099	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	semanal	{"monthDay": 1, "weekDays": ["domingo"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:12.025088	2025-11-11 03:44:12.025088	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759882334068-bqesftjui	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:12.230093	2025-11-11 03:44:12.230093	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759885763030-rw4vueq89	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:12.434602	2025-11-11 03:44:12.434602	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759889629139-pqcuh75ib	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	semanal	{"monthDay": 1, "weekDays": ["terca"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.250909	2025-11-11 03:44:13.250909	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759889808223-kkbhkfsdy	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	semanal	{"monthDay": 1, "weekDays": ["terca"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.454637	2025-11-11 03:44:13.454637	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759890045118-y0c75246f	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Final RTM	Limpeza do fosso da exaustão da base\\nLimpeza externa das paredes e vidros das cabines da base\\nLimpeza do fosso da exaustão do verniz\\nAspiração da região superior (teto) da estufa da pintura final\\nLimpeza externa das paredes e vidros das cabines do verniz\\n	mensal	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.661081	2025-11-11 03:44:13.661081	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1760182900759-vyp6ush29	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\\nTroca de filtro plenuns cabine do primer - 2 cabines\\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.864955	2025-11-11 03:44:13.864955	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1760183618389-283dqb778	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\\nTroca de filtro plenuns cabine do primer - 2 cabines\\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.068298	2025-11-11 03:44:14.068298	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1760183770897-absg8gofg	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\\nTroca de filtro plenuns cabine do primer - 2 cabines\\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.272437	2025-11-11 03:44:14.272437	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1762880431187-33swhqv3w	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	\N	Limpeza de banheiros		diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	checklist-1762880029053-PcbN4fv6Ax	\N	t	2025-11-11 17:00:31.19749	2025-11-11 17:00:31.19749	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11	\N	{site-faurecia-administrativo,site-faurecia-ambulatorio,site-faurecia-portaria,site-faurecia-producao,site-faurecia-refeitorio,site-faurecia-vestiarios}	{zone-adm-fem,zone-adm-masc,zone-amb-banheiro,zone-adm-acess-01,zone-adm-acess-02,zone-adm-fem-corp,zone-ref-fem-coz,zone-prod-fem-gm,zone-prod-fem-log,zone-port-fem,zone-prod-fem-scania,zone-adm-fem-tech,zone-prod-fem-toyota,zone-adm-masc-corp,zone-prod-masc-gm,zone-prod-masc-log,zone-port-masc,zone-adm-masc-tech,zone-prod-masc-toyota,zone-adm-unissex}
ca-1762977118730-i8nf6jpjl	company-admin-default	092ec8ec-352e-4e75-807f-136400f0f4ef	\N	\N	Teste		diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	checklist-1762973486570-4x-EwqJ3lB	\N	t	2025-11-12 19:51:58.732038	2025-11-12 19:51:58.732038	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	2025-11-12	\N	{91895d5b-c095-4238-a9c0-d06485ed0ee7,cd953978-a480-4b4b-a3eb-11fc09965748}	{c9621786-3bab-4a67-b23d-d4e5f753b4af,47266a3a-57c3-4745-91fe-f0cde2754941,94b64481-098c-40dc-b852-bb3e52a545c9,a0d972f8-301f-4385-9e62-3c352683b6c7}
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (id, name, cnpj, email, phone, address, is_active, created_at, updated_at) FROM stdin;
company-admin-default	GRUPO OPUS					t	2025-09-10 20:41:19.301367	2025-09-10 20:41:19.301367
company-opus-default	Grupo OPUS	12.345.678/0001-90	contato@grupoopus.com.br	(11) 3000-0000	Av. Paulista, 1000 - São Paulo, SP	t	2025-11-11 03:42:52.962018	2025-11-11 03:42:52.962018
\.


--
-- Data for Name: company_counters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_counters (id, company_id, key, next_number, updated_at) FROM stdin;
\.


--
-- Data for Name: custom_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_roles (id, company_id, name, description, is_system_role, is_active, created_at, updated_at) FROM stdin;
role-1759340407-operador	company-admin-default	Operador	Operador de campo - executa OS via aplicativo mobile	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
role-1759340407-cliente	company-admin-default	Cliente	Visualização de dashboards, relatórios, plantas dos locais e ordens de serviço. Pode comentar e avaliar OS.	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
role-1759340407-admin	company-admin-default	Administrador	Acesso total ao sistema - para usuários OPUS	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
\.


--
-- Data for Name: customer_counters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_counters (id, customer_id, key, next_number, updated_at) FROM stdin;
custc-1762818381226-jld9vdg6n	a6460e7b-7b7f-45f0-b748-efddeea5707c	work_order	27	2025-11-11 02:54:27.282657
custc-1762880431391-6rt5xuxli	7913bae1-bdca-4fb4-9465-99a4754995b2	work_order	391	2025-11-12 21:26:30.300178
custc-1762880431409-vmobl8dk8	43538320-fe1b-427c-9cb9-6b7ab06c1247	work_order	5	2025-11-12 21:26:30.316392
custc-1762977118997-rrmuwb28o	783a6a21-aa25-421d-b1da-bbd03410f2c5	work_order	4	2025-11-12 21:26:30.332878
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, company_id, name, email, phone, document, address, city, state, zip_code, contact_person, notes, modules, is_active, created_at, updated_at, login_logo, sidebar_logo, sidebar_logo_collapsed, module_colors, subdomain, home_logo, favicon_url, primary_color, secondary_color, accent_color, landing_title, landing_subtitle, landing_hero_image, meta_description) FROM stdin;
783a6a21-aa25-421d-b1da-bbd03410f2c5	company-admin-default	Condomínio estrelas do mar	estreladomar@gmail.com	71994080809	84857665000106	Rua Maria de Fátima	São Paulo	SP	04404-160	Marcos Feliciano		{clean,maintenance}	t	2025-11-12 18:00:09.799157	2025-11-12 18:01:46.537386	/attached_assets/customer_logos/783a6a21-aa25-421d-b1da-bbd03410f2c5_loginLogo_1762970505185.png	/attached_assets/customer_logos/783a6a21-aa25-421d-b1da-bbd03410f2c5_sidebarLogo_1762970505566.png	/attached_assets/customer_logos/783a6a21-aa25-421d-b1da-bbd03410f2c5_sidebarLogoCollapsed_1762970505967.png	{"clean": {"accent": "#60e1fb", "primary": "#00d5ff", "secondary": "#3beaf7"}}	estrelasdomar	/attached_assets/customer_logos/783a6a21-aa25-421d-b1da-bbd03410f2c5_homeLogo_1762970506346.png	\N	\N	\N	\N	\N	\N	\N	\N
43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default	FAURECIA										{clean}	t	2025-11-11 03:42:13.585928	2025-11-12 00:10:04.789074	\N	\N	\N	\N	faurecia	\N	\N	\N	\N	\N	\N	\N	\N	\N
7913bae1-bdca-4fb4-9465-99a4754995b2	company-admin-default	TECNOFIBRA										{clean}	t	2025-11-11 03:42:13.790706	2025-11-12 00:10:21.806285	\N	\N	\N	\N	tecnofibra	\N	\N	\N	\N	\N	\N	\N	\N	\N
a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default	Condomínio Sol de Mar	Soldemar@gmail.com	69983993634	84857665000106	Rua Maria de Fátima	São Paulo	SP	04404-160	Mário Torres		{maintenance,clean}	t	2025-11-10 22:11:48.868936	2025-11-12 00:11:49.542712	/attached_assets/customer_logos/a6460e7b-7b7f-45f0-b748-efddeea5707c_loginLogo_1762901936168.png	/attached_assets/customer_logos/a6460e7b-7b7f-45f0-b748-efddeea5707c_sidebarLogo_1762901936338.png	/attached_assets/customer_logos/a6460e7b-7b7f-45f0-b748-efddeea5707c_sidebarLogoCollapsed_1762901936511.png	{"clean": {"accent": "#e60063", "primary": "#fa004b", "secondary": "#d70909"}}	soldemar	/attached_assets/customer_logos/a6460e7b-7b7f-45f0-b748-efddeea5707c_homeLogo_1762903177531.png	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: dashboard_goals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboard_goals (id, company_id, module, goal_type, goal_value, current_period, is_active, created_at, updated_at) FROM stdin;
1c998e07-525e-4ba4-a2da-907ce4b6293b	company-admin-default	clean	eficiencia_operacional	95.00	2025-11	t	2025-11-10 22:38:38.458304	2025-11-10 22:38:38.458304
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment (id, company_id, customer_id, site_id, zone_id, equipment_type_id, name, internal_code, manufacturer, model, serial_number, purchase_date, warranty_expiry, installation_date, status, technical_specs, maintenance_notes, qr_code_url, module, is_active, created_at, updated_at, value) FROM stdin;
I3cgNaIghKEHX5DR8yEF-	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	366ab13e-e56a-417a-b8c3-07d9d1ca4264	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	\N	ar condicionado	\N	Samsung	Dual Inverter Compact	SN73621T	\N	2027-11-10	2025-11-10	operacional	\N	\N	\N	maintenance	t	2025-11-10 23:30:36.603947	2025-11-10 23:30:36.603947	2184.90
jNGzf38-Bx6Z1fO9PCWle	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	366ab13e-e56a-417a-b8c3-07d9d1ca4264	7c9bc3ac-1e99-4f19-9726-573a4569918d	\N	ar condicionado	\N	Samsung	Dual Inverter Compact	SN73621T-2	\N	2025-11-30	2025-11-10	operacional	\N	\N	\N	maintenance	t	2025-11-10 23:44:02.525056	2025-11-10 23:44:02.525056	2184.90
\.


--
-- Data for Name: equipment_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment_types (id, company_id, name, description, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_activities (id, company_id, customer_id, site_ids, zone_ids, equipment_ids, site_id, zone_id, name, description, type, frequency, frequency_config, module, checklist_template_id, sla_config_id, assigned_user_id, estimated_hours, sla_minutes, start_date, last_executed_at, is_active, created_at, updated_at, start_time, end_time) FROM stdin;
ma-1762818380501-b9ptcu9ly	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	{366ab13e-e56a-417a-b8c3-07d9d1ca4264}	{a12d6f27-ac7a-4851-b37f-14ef855b8b0e,7c9bc3ac-1e99-4f19-9726-573a4569918d}	{I3cgNaIghKEHX5DR8yEF-,jNGzf38-Bx6Z1fO9PCWle}	\N	\N	Manutenção dos ar condicionados		preventiva	mensal	{"monthDay": 10, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	LSwNG2iHdUQZ4ZijKL-1q	\N	\N	\N	\N	2025-11-10	\N	t	2025-11-10 23:46:20.551674	2025-11-10 23:46:20.551674	\N	\N
ma-1762829349044-b63jtarfr	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	{366ab13e-e56a-417a-b8c3-07d9d1ca4264}	{a12d6f27-ac7a-4851-b37f-14ef855b8b0e}	{I3cgNaIghKEHX5DR8yEF-}	\N	\N	Higienização de Cabine		preventiva	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	LSwNG2iHdUQZ4ZijKL-1q	\N	\N	\N	\N	2025-11-09	\N	t	2025-11-11 02:49:09.095663	2025-11-11 02:49:09.095663	\N	\N
\.


--
-- Data for Name: maintenance_checklist_executions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_checklist_executions (id, checklist_template_id, equipment_id, work_order_id, executed_by_user_id, started_at, finished_at, status, checklist_data, observations, attachments, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_checklist_templates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_checklist_templates (id, company_id, customer_id, name, description, version, service_id, site_ids, zone_ids, equipment_ids, items, module, is_active, created_at, updated_at) FROM stdin;
LSwNG2iHdUQZ4ZijKL-1q	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	Manutenção dos ar condicionados	\N	1.0	aa599100-b76e-4dff-89ee-116abbce3355	{366ab13e-e56a-417a-b8c3-07d9d1ca4264}	{a12d6f27-ac7a-4851-b37f-14ef855b8b0e,7c9bc3ac-1e99-4f19-9726-573a4569918d}	{I3cgNaIghKEHX5DR8yEF-,jNGzf38-Bx6Z1fO9PCWle}	[{"id": "lBgsIu9xRhCPBH5hnrzhj", "type": "photo", "label": "i", "options": [], "required": false, "validation": {"photoMinCount": 1}, "description": ""}]	maintenance	t	2025-11-10 23:45:44.301835	2025-11-10 23:45:44.301835
\.


--
-- Data for Name: maintenance_plan_equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_plan_equipments (id, plan_id, equipment_id, checklist_template_id, frequency, frequency_config, next_execution_at, last_execution_at, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maintenance_plans (id, company_id, customer_id, name, description, type, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: public_request_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.public_request_logs (id, qr_code_point_id, ip_hash, user_agent, request_data, created_at) FROM stdin;
\.


--
-- Data for Name: qr_code_points; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.qr_code_points (id, zone_id, equipment_id, service_id, code, type, name, description, size_cm, module, is_active, created_at, updated_at) FROM stdin;
79fc5732-af7e-4622-85e5-fdaea6b814d7	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	\N	\N	275ff958-a28e-4463-86f1-155c7d4b4240	execucao	cabine	\N	5	maintenance	t	2025-11-11 02:51:24.900911	2025-11-11 02:51:24.900911
4d1e9aef-9e68-4225-86c6-91fd1e4cc901	7c9bc3ac-1e99-4f19-9726-573a4569918d	\N	\N	3a03482f-2f8d-4e08-aa69-2dca94c26d34	execucao	Linha de montagem	\N	5	maintenance	t	2025-11-11 02:51:33.87057	2025-11-11 02:51:33.87057
qr-zone-vest-masc-01	zone-vest-masc-01	\N	\N	zone-vest-masc-01	execucao	VESTIÁRIO MASCULINO -01	\N	5	clean	t	2025-11-11 03:44:17.745718	2025-11-11 03:44:17.745718
qr-zone-vest-masc-02	zone-vest-masc-02	\N	\N	zone-vest-masc-02	execucao	VESTIÁRIO MASCULINO -02	\N	5	clean	t	2025-11-11 03:44:17.951201	2025-11-11 03:44:17.951201
qr-zone-vest-fem	zone-vest-fem	\N	\N	zone-vest-fem	execucao	VESTIÁRIO FEMININO	\N	5	clean	t	2025-11-11 03:44:18.154882	2025-11-11 03:44:18.154882
qr-zone-amb-banheiro	zone-amb-banheiro	\N	\N	zone-amb-banheiro	execucao	BANHEIRO AMBULATÓRIO	\N	5	clean	t	2025-11-11 03:44:18.358545	2025-11-11 03:44:18.358545
qr-zone-ref-fem-coz	zone-ref-fem-coz	\N	\N	zone-ref-fem-coz	execucao	BANHEIRO FEMININO COZINHA	\N	5	clean	t	2025-11-11 03:44:18.561581	2025-11-11 03:44:18.561581
qr-zone-port-masc	zone-port-masc	\N	\N	zone-port-masc	execucao	BANHEIRO MASCULINO PORTARIA	\N	5	clean	t	2025-11-11 03:44:18.772327	2025-11-11 03:44:18.772327
qr-zone-port-fem	zone-port-fem	\N	\N	zone-port-fem	execucao	BANHEIRO FEMININO PORTARIA	\N	5	clean	t	2025-11-11 03:44:18.9756	2025-11-11 03:44:18.9756
qr-zone-adm-masc	zone-adm-masc	\N	\N	zone-adm-masc	execucao	BANHEIRO ADM MASCULINO	\N	5	clean	t	2025-11-11 03:44:19.17997	2025-11-11 03:44:19.17997
qr-zone-adm-fem-corp	zone-adm-fem-corp	\N	\N	zone-adm-fem-corp	execucao	BANHEIRO FEMININO CORPORATIVO	\N	5	clean	t	2025-11-11 03:44:19.383794	2025-11-11 03:44:19.383794
qr-zone-adm-acess-01	zone-adm-acess-01	\N	\N	zone-adm-acess-01	execucao	BANHEIRO CORPORATIVO ACESSÍVEL 01	\N	5	clean	t	2025-11-11 03:44:19.588814	2025-11-11 03:44:19.588814
qr-zone-adm-acess-02	zone-adm-acess-02	\N	\N	zone-adm-acess-02	execucao	BANHEIRO CORPORATIVO ACESSÍVEL 02	\N	5	clean	t	2025-11-11 03:44:19.802064	2025-11-11 03:44:19.802064
qr-zone-adm-fem-tech	zone-adm-fem-tech	\N	\N	zone-adm-fem-tech	execucao	BANHEIRO FEMININO TECH CENTER	\N	5	clean	t	2025-11-11 03:44:20.005339	2025-11-11 03:44:20.005339
qr-zone-adm-fem	zone-adm-fem	\N	\N	zone-adm-fem	execucao	BANHEIRO ADM FEMININO	\N	5	clean	t	2025-11-11 03:44:20.208973	2025-11-11 03:44:20.208973
qr-zone-adm-masc-tech	zone-adm-masc-tech	\N	\N	zone-adm-masc-tech	execucao	BANHEIRO MASCULINO TECH CENTER	\N	5	clean	t	2025-11-11 03:44:20.414036	2025-11-11 03:44:20.414036
qr-zone-adm-unissex	zone-adm-unissex	\N	\N	zone-adm-unissex	execucao	BANHEIRO UNISSEX RECEPÇÃO	\N	5	clean	t	2025-11-11 03:44:20.617375	2025-11-11 03:44:20.617375
qr-zone-adm-masc-corp	zone-adm-masc-corp	\N	\N	zone-adm-masc-corp	execucao	BANHEIRO MASCULINO CORPORATIVO	\N	5	clean	t	2025-11-11 03:44:20.821689	2025-11-11 03:44:20.821689
qr-zone-prod-masc-gm	zone-prod-masc-gm	\N	\N	zone-prod-masc-gm	execucao	BANHEIRO MASCULINO GM	\N	5	clean	t	2025-11-11 03:44:21.026051	2025-11-11 03:44:21.026051
qr-zone-prod-fem-toyota	zone-prod-fem-toyota	\N	\N	zone-prod-fem-toyota	execucao	BANHEIRO FEMININO TOYOTA	\N	5	clean	t	2025-11-11 03:44:21.229624	2025-11-11 03:44:21.229624
qr-zone-prod-fem-scania	zone-prod-fem-scania	\N	\N	zone-prod-fem-scania	execucao	BANHEIRO FEMININO SCANIA	\N	5	clean	t	2025-11-11 03:44:21.433244	2025-11-11 03:44:21.433244
qr-zone-prod-fem-log	zone-prod-fem-log	\N	\N	zone-prod-fem-log	execucao	BANHEIRO FEMININO LOGÍSTICA	\N	5	clean	t	2025-11-11 03:44:21.636455	2025-11-11 03:44:21.636455
qr-zone-prod-masc-scania	zone-prod-masc-scania	\N	\N	zone-prod-masc-scania	execucao	BANHEIRO MASCULINO SCANIA	\N	5	clean	t	2025-11-11 03:44:21.840557	2025-11-11 03:44:21.840557
qr-zone-prod-masc-log	zone-prod-masc-log	\N	\N	zone-prod-masc-log	execucao	BANHEIRO MASCULINO LOGÍSTICA	\N	5	clean	t	2025-11-11 03:44:22.045771	2025-11-11 03:44:22.045771
qr-zone-prod-masc-toyota	zone-prod-masc-toyota	\N	\N	zone-prod-masc-toyota	execucao	BANHEIRO MASCULINO TOYOTA	\N	5	clean	t	2025-11-11 03:44:22.249443	2025-11-11 03:44:22.249443
qr-zone-prod-fem-gm	zone-prod-fem-gm	\N	\N	zone-prod-fem-gm	execucao	BANHEIRO FEMININO GM	\N	5	clean	t	2025-11-11 03:44:22.454681	2025-11-11 03:44:22.454681
caed1a61-5345-4209-9b52-b018d7106e01	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N	e8a28503-dabe-4a8a-a480-34a5a211031a	execucao	teste	\N	5	clean	t	2025-11-11 03:44:22.658397	2025-11-11 03:44:22.658397
d5dff978-b9a3-4790-a884-33a78f08356f	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N	c5816652-1b6b-4ad7-9a12-d245dc6f42e8	execucao	Cabine de Pintura Prime RTM	\N	5	clean	t	2025-11-11 03:44:22.861563	2025-11-11 03:44:22.861563
957a605d-44f8-4aa3-a177-36eaf3b43190	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N	46b94ccd-98bd-4e30-ad98-01feac8932a0	execucao	Cabine de Pintura Final RTM	\N	5	clean	t	2025-11-11 03:44:23.064799	2025-11-11 03:44:23.064799
8d4332df-6286-40a4-8888-5008c0f78d35	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N	ee3ec8cf-a8d5-44cb-9b5f-c9a2a222594b	execucao	Cabine Final Verniz RTM	\N	5	clean	t	2025-11-11 03:44:23.268151	2025-11-11 03:44:23.268151
d8f37fa9-e3da-436c-b8b6-fbfc720a78d7	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N	6f77dd27-3cdd-4e3a-b706-d706f1b843c2	execucao	Cabine Pintura Prime SMC	\N	5	clean	t	2025-11-11 03:44:23.471318	2025-11-11 03:44:23.471318
abd07784-0f45-4c08-801c-7108ef809ee4	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N	de51e756-40b9-4d9a-a6ee-2c3c9caecd2d	execucao	Cabine Pintura Final SMC	\N	5	clean	t	2025-11-11 03:44:23.675378	2025-11-11 03:44:23.675378
bcb5a5f4-12b4-4b8a-969a-6bd379c5b2db	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N	5f1f4a23-4c4e-4a40-9cc0-73b5ecf199d0	execucao	Cabine Final Verniz SMC	\N	5	clean	t	2025-11-11 03:44:23.881219	2025-11-11 03:44:23.881219
5b4bdbfd-0f53-4631-90d9-3241eb59c85c	2d9936f6-6093-4885-b0bf-cf655f559dbc	\N	\N	ad7471b3-5520-4f5a-bacb-d248df0527eb	execucao	Cabine Estatica RTM Cowling	\N	5	clean	t	2025-11-11 03:44:24.085376	2025-11-11 03:44:24.085376
bfc93c83-758e-4769-ae7b-3e09e7689bb3	c9621786-3bab-4a67-b23d-d4e5f753b4af	\N	\N	310bd7ff-308f-41c4-8b88-83b2a14412cb	execucao	zona 1	\N	5	clean	t	2025-11-12 18:44:54.124846	2025-11-12 18:44:54.124846
319c6018-1b44-4151-93d3-dbbb6d90a697	47266a3a-57c3-4745-91fe-f0cde2754941	\N	\N	8c82d283-9b71-44bf-9bf0-f29c14988be7	execucao	zona 1 local 2 	\N	5	clean	t	2025-11-12 18:45:04.397326	2025-11-12 18:45:04.397326
462cde08-a46f-4c74-87e7-cfd3d5671a47	a0d972f8-301f-4385-9e62-3c352683b6c7	\N	\N	3f9c6383-72cd-4d7a-9a0e-83875e5fb11e	execucao	zona 2	\N	5	clean	t	2025-11-12 18:45:11.644125	2025-11-12 18:45:11.644125
1314e924-3f36-4b10-a5d4-63a6316d01aa	94b64481-098c-40dc-b852-bb3e52a545c9	\N	\N	59006a47-890d-46e8-ad7d-22f35f055491	execucao	Zona 2 local 2	\N	5	clean	t	2025-11-12 18:45:23.210473	2025-11-12 18:45:23.210473
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (id, role_id, permission, created_at) FROM stdin;
perm-1759340462-1	role-1759340407-operador	dashboard_view	2025-10-01 17:41:00.325741
perm-1759340462-2	role-1759340407-operador	workorders_view	2025-10-01 17:41:00.325741
perm-1759340462-3	role-1759340407-operador	workorders_edit	2025-10-01 17:41:00.325741
perm-1759340462-4	role-1759340407-operador	checklists_view	2025-10-01 17:41:00.325741
rp-cliente-1	role-1759340407-cliente	dashboard_view	2025-10-01 17:58:45.018396
rp-cliente-2	role-1759340407-cliente	workorders_view	2025-10-01 17:58:45.018396
rp-cliente-3	role-1759340407-cliente	workorders_comment	2025-10-01 17:58:45.018396
rp-cliente-4	role-1759340407-cliente	workorders_evaluate	2025-10-01 17:58:45.018396
rp-cliente-5	role-1759340407-cliente	floor_plan_view	2025-10-01 17:58:45.018396
rp-cliente-6	role-1759340407-cliente	heatmap_view	2025-10-01 17:58:45.018396
rp-cliente-7	role-1759340407-cliente	sites_view	2025-10-01 17:58:45.018396
rp-cliente-8	role-1759340407-cliente	reports_view	2025-10-01 17:58:45.018396
rp-1759349004801-0-i018fihns	role-1759340407-admin	dashboard_view	2025-10-01 20:03:24.874894
rp-1759349004801-1-m30zad2pm	role-1759340407-admin	workorders_view	2025-10-01 20:03:24.874894
rp-1759349004801-2-2yy3xn6fi	role-1759340407-admin	workorders_create	2025-10-01 20:03:24.874894
rp-1759349004801-3-ci1fsrxoe	role-1759340407-admin	workorders_edit	2025-10-01 20:03:24.874894
rp-1759349004801-4-4dt6qonab	role-1759340407-admin	workorders_delete	2025-10-01 20:03:24.874894
rp-1759349004801-5-nt8k19gki	role-1759340407-admin	schedule_view	2025-10-01 20:03:24.874894
rp-1759349004801-6-eytzlkx93	role-1759340407-admin	schedule_create	2025-10-01 20:03:24.874894
rp-1759349004801-7-h1jzlh0ky	role-1759340407-admin	schedule_edit	2025-10-01 20:03:24.874894
rp-1759349004801-8-ogdzfrejc	role-1759340407-admin	schedule_delete	2025-10-01 20:03:24.874894
rp-1759349004801-9-zj03dwapi	role-1759340407-admin	checklists_view	2025-10-01 20:03:24.874894
rp-1759349004801-10-9t1dv258z	role-1759340407-admin	checklists_create	2025-10-01 20:03:24.874894
rp-1759349004801-11-4twuj8556	role-1759340407-admin	checklists_edit	2025-10-01 20:03:24.874894
rp-1759349004801-12-m1wo9ujab	role-1759340407-admin	checklists_delete	2025-10-01 20:03:24.874894
rp-1759349004801-13-o2gpjvntj	role-1759340407-admin	qrcodes_view	2025-10-01 20:03:24.874894
rp-1759349004801-14-pqh7cybbf	role-1759340407-admin	qrcodes_create	2025-10-01 20:03:24.874894
rp-1759349004801-15-vcikc2z0a	role-1759340407-admin	qrcodes_edit	2025-10-01 20:03:24.874894
rp-1759349004801-16-spuqqraxk	role-1759340407-admin	qrcodes_delete	2025-10-01 20:03:24.874894
rp-1759349004801-17-bonu5862h	role-1759340407-admin	floor_plan_view	2025-10-01 20:03:24.874894
rp-1759349004801-18-ut0txz9qm	role-1759340407-admin	floor_plan_edit	2025-10-01 20:03:24.874894
rp-1759349004801-19-uf89shgvf	role-1759340407-admin	heatmap_view	2025-10-01 20:03:24.874894
rp-1759349004801-20-udnlzyuyi	role-1759340407-admin	sites_view	2025-10-01 20:03:24.874894
rp-1759349004801-21-ufi9pbhrr	role-1759340407-admin	sites_create	2025-10-01 20:03:24.874894
rp-1759349004801-22-cnyw69d53	role-1759340407-admin	sites_edit	2025-10-01 20:03:24.874894
rp-1759349004801-23-29sdnzyco	role-1759340407-admin	sites_delete	2025-10-01 20:03:24.874894
rp-1759349004801-24-vycjmnbi8	role-1759340407-admin	users_view	2025-10-01 20:03:24.874894
rp-1759349004801-25-6zh5qqhzs	role-1759340407-admin	users_create	2025-10-01 20:03:24.874894
rp-1759349004801-26-jjzhwmo5u	role-1759340407-admin	users_edit	2025-10-01 20:03:24.874894
rp-1759349004801-27-1plgdnfc5	role-1759340407-admin	users_delete	2025-10-01 20:03:24.874894
rp-1759349004801-28-6mxxeeqww	role-1759340407-admin	customers_view	2025-10-01 20:03:24.874894
rp-1759349004801-29-okv758ixx	role-1759340407-admin	customers_create	2025-10-01 20:03:24.874894
rp-1759349004801-30-74c1145vt	role-1759340407-admin	customers_edit	2025-10-01 20:03:24.874894
rp-1759349004801-31-xn0sobirn	role-1759340407-admin	customers_delete	2025-10-01 20:03:24.874894
rp-1759349004801-32-fsx0jdg3z	role-1759340407-admin	reports_view	2025-10-01 20:03:24.874894
rp-1759349004801-33-inp6v4b3d	role-1759340407-admin	audit_logs_view	2025-10-01 20:03:24.874894
rp-1759349004801-34-033cpn0wf	role-1759340407-admin	service_settings_view	2025-10-01 20:03:24.874894
rp-1759349004801-35-ayqfjv835	role-1759340407-admin	service_settings_edit	2025-10-01 20:03:24.874894
rp-1759349004801-36-2wzlz5den	role-1759340407-admin	roles_manage	2025-10-01 20:03:24.874894
rp-1759349004801-37-3zj3xk9e4	role-1759340407-admin	opus_users_view	2025-10-01 20:03:24.874894
rp-1759349004801-38-izhcks982	role-1759340407-admin	opus_users_create	2025-10-01 20:03:24.874894
rp-1759349004801-39-0tgc6dvf2	role-1759340407-admin	opus_users_edit	2025-10-01 20:03:24.874894
rp-1759349004801-40-8wevaz8na	role-1759340407-admin	opus_users_delete	2025-10-01 20:03:24.874894
rp-1759349004801-41-isfawd2t8	role-1759340407-admin	client_users_view	2025-10-01 20:03:24.874894
rp-1759349004801-42-m7y2j6y46	role-1759340407-admin	client_users_create	2025-10-01 20:03:24.874894
rp-1759349004801-43-w8myxq0cm	role-1759340407-admin	client_users_edit	2025-10-01 20:03:24.874894
rp-1759349004801-44-muib1xowz	role-1759340407-admin	client_users_delete	2025-10-01 20:03:24.874894
rp-1759349004801-45-t4bpvg4gb	role-1759340407-admin	workorders_comment	2025-10-01 20:03:24.874894
rp-1759349004801-46-qag8f7s8a	role-1759340407-admin	workorders_evaluate	2025-10-01 20:03:24.874894
\.


--
-- Data for Name: service_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_categories (id, type_id, name, description, code, module, is_active, created_at, updated_at, customer_id) FROM stdin;
be576348-675a-4b59-a7fa-715bbb0e0f15	fd87bcf6-fc20-4157-84db-bda39a303069	Limpeza Tecnica	\N	LPT	clean	t	2025-11-11 03:43:02.245127	2025-11-11 03:43:02.245127	7913bae1-bdca-4fb4-9465-99a4754995b2
81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive	Limpeza 	\N	1	clean	t	2025-11-11 03:43:02.449897	2025-11-11 03:43:02.449897	43538320-fe1b-427c-9cb9-6b7ab06c1247
\.


--
-- Data for Name: service_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_types (id, name, description, code, module, is_active, created_at, updated_at, customer_id, company_id) FROM stdin;
01f965aa-8676-4780-8e42-e4a4540a0889	Preventivo		PVT_LPZ	clean	t	2025-11-10 23:02:26.91541	2025-11-10 23:02:26.91541	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
06eafc6f-4aa1-40d2-897c-0d738fdc25cf	Preventivo		PVT_MNT	maintenance	t	2025-11-10 23:27:51.371087	2025-11-10 23:27:51.371087	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
c1c15dad-c628-4b0e-800a-70c71eb05d2d	Corretivo		CRT_MNT	maintenance	t	2025-11-11 02:46:25.604647	2025-11-11 02:46:25.604647	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
st-emergency	Emergência	Serviços de emergência com atendimento crítico imediato	EMERG_SVC	clean	t	2025-11-11 03:43:01.632119	2025-11-11 03:43:01.632119	43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default
st-preventive	Preventivo	Serviços de manutenção preventiva programada regular	PREV_SVC	clean	t	2025-11-11 03:43:01.835218	2025-11-11 03:43:01.835218	43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default
fd87bcf6-fc20-4157-84db-bda39a303069	Preventiva	Limpeza programada.	PVT	clean	t	2025-11-11 03:43:02.039292	2025-11-11 03:43:02.039292	7913bae1-bdca-4fb4-9465-99a4754995b2	company-admin-default
a1623bc1-2a21-4043-98e7-500d5357f8de	Corretivo		CRT_LPZ	clean	t	2025-11-11 04:56:24.371448	2025-11-11 04:56:24.371448	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
bc995c6e-3f90-4111-9741-2d784b0bccb5	Teste		teste	clean	t	2025-11-12 18:03:10.790806	2025-11-12 18:03:10.790806	783a6a21-aa25-421d-b1da-bbd03410f2c5	company-admin-default
fa862e3d-1833-454c-a35f-92b1d1fc83de	teste 2		teste  2	clean	t	2025-11-12 18:33:10.27943	2025-11-12 18:33:10.27943	783a6a21-aa25-421d-b1da-bbd03410f2c5	company-admin-default
\.


--
-- Data for Name: service_zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_zones (id, service_id, zone_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, name, description, estimated_duration_minutes, priority, requirements, module, is_active, created_at, updated_at, customer_id, category_id, type_id) FROM stdin;
2f6262d2-1088-4ffb-9947-49561806e6b8	Recolhimento do Lixo		30	media	\N	clean	t	2025-11-10 23:02:45.433017	2025-11-10 23:02:45.433017	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N	01f965aa-8676-4780-8e42-e4a4540a0889
aa599100-b76e-4dff-89ee-116abbce3355	Manutenção dos ar condicionados		60	media	\N	maintenance	t	2025-11-10 23:28:05.32994	2025-11-10 23:28:05.32994	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N	06eafc6f-4aa1-40d2-897c-0d738fdc25cf
0643fb68-262b-4f4b-bd6f-e6dc1c304a37	Higienização de Cabine	\N	480	alta	\N	clean	t	2025-11-11 03:43:02.655498	2025-11-11 03:43:02.655498	7913bae1-bdca-4fb4-9465-99a4754995b2	be576348-675a-4b59-a7fa-715bbb0e0f15	fd87bcf6-fc20-4157-84db-bda39a303069
1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	Limpeza Rotina	\N	30	media	\N	clean	t	2025-11-11 03:43:02.858809	2025-11-11 03:43:02.858809	43538320-fe1b-427c-9cb9-6b7ab06c1247	81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive
service-3	Reposição de Suprimentos	Reposição de papel, sabão e materiais de higiene	15	media	\N	clean	t	2025-11-11 03:43:03.061205	2025-11-11 03:43:03.061205	43538320-fe1b-427c-9cb9-6b7ab06c1247	81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive
d9be8bc7-62d8-43ec-8a63-65bf2aa64796	Higienização de Cabine		40	media	\N	clean	t	2025-11-11 04:56:38.762808	2025-11-11 04:56:38.762808	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N	01f965aa-8676-4780-8e42-e4a4540a0889
092ec8ec-352e-4e75-807f-136400f0f4ef	Teste de serviço		\N	media	\N	clean	t	2025-11-12 18:33:00.224573	2025-11-12 18:33:00.224573	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N	bc995c6e-3f90-4111-9741-2d784b0bccb5
643cd055-92cb-41a9-b04c-591db955dc1e	Teste de serviço 2		\N	media	\N	clean	t	2025-11-12 18:34:50.639664	2025-11-12 18:34:50.639664	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N	fa862e3d-1833-454c-a35f-92b1d1fc83de
\.


--
-- Data for Name: site_shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.site_shifts (id, site_id, name, start_time, end_time, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sites (id, company_id, customer_id, module, name, address, description, floor_plan_image_url, is_active, created_at, updated_at) FROM stdin;
ae97c9e2-77cc-4ac9-b31a-bfd16f74f29b	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	clean	Hall principal	r	\N	\N	t	2025-11-10 23:03:03.443985	2025-11-10 23:03:03.443985
366ab13e-e56a-417a-b8c3-07d9d1ca4264	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	maintenance	Fábrica principal	r	\N	\N	t	2025-11-10 23:28:17.604993	2025-11-10 23:28:17.604993
ff191700-ac34-4df7-accc-1d420568d645	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	clean	Fabrica Central	Joinville	\N	\N	t	2025-11-11 03:42:14.402994	2025-11-11 03:42:14.402994
site-faurecia-vestiarios	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	VESTIÁRIOS	Faurecia - Vestiários	\N	\N	t	2025-11-11 03:42:14.606193	2025-11-11 03:42:14.606193
site-faurecia-ambulatorio	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	AMBULATÓRIO	Faurecia - Ambulatório	\N	\N	t	2025-11-11 03:42:14.809168	2025-11-11 03:42:14.809168
site-faurecia-refeitorio	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	REFEITÓRIO	Faurecia - Refeitório	\N	\N	t	2025-11-11 03:42:15.012695	2025-11-11 03:42:15.012695
site-faurecia-portaria	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	PORTARIA	Faurecia - Portaria	\N	\N	t	2025-11-11 03:42:15.215391	2025-11-11 03:42:15.215391
site-faurecia-administrativo	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	ADMINISTRATIVO	Faurecia - Administrativo	\N	\N	t	2025-11-11 03:42:15.417775	2025-11-11 03:42:15.417775
site-faurecia-producao	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	PRODUÇÃO	Faurecia - Produção	\N	\N	t	2025-11-11 03:42:15.621566	2025-11-11 03:42:15.621566
91895d5b-c095-4238-a9c0-d06485ed0ee7	company-admin-default	783a6a21-aa25-421d-b1da-bbd03410f2c5	clean	Local 1	1	\N	\N	t	2025-11-12 18:35:03.510428	2025-11-12 18:35:03.510428
cd953978-a480-4b4b-a3eb-11fc09965748	company-admin-default	783a6a21-aa25-421d-b1da-bbd03410f2c5	clean	Local 2	2	\N	\N	t	2025-11-12 18:35:09.813915	2025-11-12 18:35:09.813915
\.


--
-- Data for Name: sla_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sla_configs (id, company_id, name, category, module, time_to_start_minutes, time_to_complete_minutes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_allowed_customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_allowed_customers (id, user_id, customer_id, created_at) FROM stdin;
fc404cc2-4b09-4e8e-b1a2-6478adc2795d	op-teste-1758573497.448657	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
c52d7d0c-1d91-4a21-8f22-f7ff92ca0992	op-teste-1758573497.448657	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
73466d7e-e3fc-4ff2-b257-d707e1d6414c	op-teste-1758573497.448657	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
a98c17be-4c47-44e1-8507-eb73f32ef56d	840a9cf4-19c2-4547-bb60-58a6c40b2e4a	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
b57d16c3-56a9-446e-a81d-7bab2074f360	840a9cf4-19c2-4547-bb60-58a6c40b2e4a	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
36e9ef16-6816-49c0-b838-6a1889384038	840a9cf4-19c2-4547-bb60-58a6c40b2e4a	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
2c165280-8d1a-42f1-83cd-65eaf0afd157	491fe390-a50c-49dc-80e4-cb28463a2f44	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
2d75234f-1991-400d-82c8-79d2f28118d8	491fe390-a50c-49dc-80e4-cb28463a2f44	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
8111cd5c-b2d9-4366-8322-ae03a63c4dcb	491fe390-a50c-49dc-80e4-cb28463a2f44	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
4ab58601-a4dd-4cdb-887f-b9a0857e4b95	d0f1f357-cdda-49a8-874b-ddad849b0f66	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
5db8197b-d594-4fae-bbaa-c8692a5a69f1	d0f1f357-cdda-49a8-874b-ddad849b0f66	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
68ee90fd-cc3c-48fd-b30d-75971d4d8e99	d0f1f357-cdda-49a8-874b-ddad849b0f66	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
7d060d1b-3681-4c7b-8b8e-3897ef894cfc	c1c3f742-cd7c-4082-a9ae-422f1567da21	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
e93ce6b6-a578-49c2-b5fa-b30c330a4287	c1c3f742-cd7c-4082-a9ae-422f1567da21	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
e7f165c1-6551-4efb-9510-ff5fddefb311	c1c3f742-cd7c-4082-a9ae-422f1567da21	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
a1ed5f47-960b-47cb-ba62-e40c0df48351	2eca20e5-066f-4c4a-afc8-d4ff1b6f5015	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
d8f89039-34ae-44e6-9eb9-359f9af7e8fb	2eca20e5-066f-4c4a-afc8-d4ff1b6f5015	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
3c2ac4ea-b1f8-4d19-a231-a864edb30700	2eca20e5-066f-4c4a-afc8-d4ff1b6f5015	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
d5794add-dcae-440a-b3a0-15db17518f89	ad85d9cf-c3e6-4976-99bb-4b1bbfdf7b43	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-11 19:27:51.804127
f026cd0d-e30f-4cc3-babf-bd6783ed7646	ad85d9cf-c3e6-4976-99bb-4b1bbfdf7b43	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:27:51.804127
48d89988-50c3-4616-984b-bb3d32bebad5	ad85d9cf-c3e6-4976-99bb-4b1bbfdf7b43	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:27:51.804127
user-allowed-customer-177af1be-13d5-4ca7-8c64-d33a0c1e6b4f-43538320-fe1b-427c-9cb9-6b7ab06c1247-1762889758792	177af1be-13d5-4ca7-8c64-d33a0c1e6b4f	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-11 19:35:58.793994
user-allowed-customer-177af1be-13d5-4ca7-8c64-d33a0c1e6b4f-7913bae1-bdca-4fb4-9465-99a4754995b2-1762889758792	177af1be-13d5-4ca7-8c64-d33a0c1e6b4f	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:35:58.793994
user-allowed-customer-7dc2163b-7762-4cca-8f33-bd4386486e26-a6460e7b-7b7f-45f0-b748-efddeea5707c-1762968801761	7dc2163b-7762-4cca-8f33-bd4386486e26	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-12 17:33:21.763554
user-allowed-customer-7dc2163b-7762-4cca-8f33-bd4386486e26-43538320-fe1b-427c-9cb9-6b7ab06c1247-1762968801761	7dc2163b-7762-4cca-8f33-bd4386486e26	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-12 17:33:21.763554
user-allowed-customer-7dc2163b-7762-4cca-8f33-bd4386486e26-7913bae1-bdca-4fb4-9465-99a4754995b2-1762968801761	7dc2163b-7762-4cca-8f33-bd4386486e26	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-12 17:33:21.763554
\.


--
-- Data for Name: user_role_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_role_assignments (id, user_id, role_id, customer_id, created_at) FROM stdin;
ura-1762815860547-xc4uzgpfx	user-joao.silva-1762815860108	role-1759340407-operador	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-10 23:04:20.597201
ura-1762815976452-gxt6p5gzu	user-joao.matos-1762815975982	role-1759340407-operador	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-10 23:06:16.503643
ura-1762816014536-jpi06b1tm	user-joao.torres-1762816014081	role-1759340407-operador	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-10 23:06:54.586823
ura-1762890271173-1rohfj2in	user-clientee-1762890270791	role-1759340407-cliente	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-11-11 19:44:31.174455
ura-1762977575844-3vsttpkpg	user-joao.solva-1762977575399	role-1759340407-operador	783a6a21-aa25-421d-b1da-bbd03410f2c5	2025-11-12 19:59:35.84597
\.


--
-- Data for Name: user_site_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_site_assignments (id, user_id, site_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, company_id, customer_id, username, email, password, name, role, user_type, assigned_client_id, auth_provider, external_id, ms_tenant_id, modules, is_active, created_at, updated_at) FROM stdin;
user-joao.silva-1762815860108	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	joao.silva	joao@empresa.com	$2b$12$v1CZVs26TUlCY3e1g7dheeqVRpuynhqB1Mrjt0stiN93Wa/HelTqG	João da Silva	operador	customer_user	\N	local	\N	\N	{clean,maintenance}	t	2025-11-10 23:04:20.488122	2025-11-10 23:04:20.488122
user-joao.matos-1762815975982	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	joao.matos	joaomatos@gmail.com	$2b$12$zivbtYzy8X2oIZAOvv3fTerQ17CVc.8IepFup8D6dlpAkOB4Seepm	Joao Matos	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-10 23:06:16.395958	2025-11-10 23:06:16.395958
user-joao.torres-1762816014081	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	joao.torres	joaot2@gmail.com	$2b$12$IJUOB/96q.A99bxXe24JTugjovhx2n9UaLS/0Qr8FgFV7YX2KIHQu	Joao Torres	operador	customer_user	\N	local	\N	\N	{maintenance}	t	2025-11-10 23:06:54.478569	2025-11-10 23:06:54.478569
user-CLIENTE-1759343961359	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	CLIENTE	CLIENTE	$2b$12$BbHuotafvT3OgxnpUNHopOx5Ob/cfO789NPcqiSMCiG6TFbEyZ4I6	CLIENTE	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:21.614478	2025-11-11 03:42:21.614478
user-cliente-1759348116705	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	cliente	cliente	$2b$12$Dh5sl8jZu.TaBe6rQyhRx.8vth7CszixuLlCYNjbnKyFQkJtIPOym	cliente	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:21.844001	2025-11-11 03:42:21.844001
edd03c06-0426-4b21-a04d-f0fa8e48614b	company-admin-default	\N	novouser	novo@opus.com	$2b$12$x202EEzqda.ZjNIEZnDuW./Fdx.KcG6/7dh/1UEkZ5/FxCGCtPphy	Novo Usuario	admin	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:42:22.050531	2025-11-11 03:42:22.050531
39752b08-e1a2-491e-881b-818f00af20ab	company-admin-default	\N	teste123	teste@gmail.com	$2b$12$JK0vikbeSTlgVIe/BxKxluE6jroFdiP7bvPzolCSk2pIr34i1txRm	teste	admin	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:42:22.254685	2025-11-11 03:42:22.254685
42f5fd80-cc79-4f2a-946e-91b8abb67da3	company-admin-default	\N	opus123	opus123@opus.com	$2b$12$VC4FHjO2OtNJcnSQYiNCjO2FeodB/w7tKo5dXVfp/14LFGMimxk4q	opus123	admin	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:42:22.456921	2025-11-11 03:42:22.456921
10dbff4c-de78-41a4-a9f0-d9d28e62c8a3	company-admin-default	\N	thiago.lancelotti	thiago.lancelotti@grupoopus.com	$2b$12$Ycr3YqDeUhC48cbWk6b3zOxCum.XlD3rU.jDhxbceH0bTMQ35p85q	thiago.lancelotti	admin	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:22.659386	2025-11-11 03:42:22.659386
user-manoel.mariano-1759521589871	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	manoel.mariano	manoel.mariano	$2b$10$14fH6UDVV7I9vs8v1dWuIeDTZLRt954XqC1aNnuk/w5pH0yKQukv2	manoel.mariano	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:22.866378	2025-11-11 03:42:22.866378
user-thais.lopes-1761920031220	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	thais.lopes	Thais.Lopes@gmail.com	$2b$12$fJtyVq.vZD4e1BXM2ANhYuFUxkNQTB99FRg3eCpsC87oNuekEA1AK	Thais Lopes	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:23.068995	2025-11-11 03:42:23.068995
user-Eduardo.Santos-1760638771842	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	Eduardo.Santos	eduardo.santos@tecnofibras.com.br	$2b$12$OdvggocBkfiLElOrvf0F.upSgvEQ0.KMWcLwpzrPb0DAFIv8dNWjS	Eduardo Santos	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:23.271043	2025-11-11 03:42:23.271043
user-cristiane.aparecida-1760549898846	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	cristiane.aparecida	cristiane.aparecida@grupoopus.com	$2b$10$RViXyGleHkQROdrE4qXbmehn.hOPakS1ytVX/cqaXJ4leLalFsKw2	Cristiane Aparecida	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:23.474022	2025-11-11 03:42:23.474022
op-teste-1758573497.448657	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	teste	teste@operador.com	$2b$10$m3M1Wo3QSMLuPCfqc2wlu.2lTyGghR2Ydv6ouwkBneGS5.xL8HIom	Operador Teste	operador	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:23.676512	2025-11-11 03:42:23.676512
840a9cf4-19c2-4547-bb60-58a6c40b2e4a	company-opus-default	\N	marcos.mattos 	marcos.mattos@grupoopus.com	$2b$10$Fl9KWha8E6v9jlb1GYsrnOpAwNhiSN2tjO1zXk90zw9uL4m9uR/tW	Marcos Mattos	operador	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:42:58.361362	2025-11-11 03:42:58.361362
user-marcelo.cananea-1760461316804	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	marcelo.cananea	marcelo.cananea@grupoopus.com	$2b$10$TWhroUlWxK5cuWA18mxBO.rSPlUIZvNqAM6kJ/2KRajE5fW8y1R86	Marcelo 	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:58.565917	2025-11-11 03:42:58.565917
491fe390-a50c-49dc-80e4-cb28463a2f44	company-opus-default	\N	guilherme.souza	guilherme.souza@tecnofibras.com.br	$2b$12$1DZlpBX9im9zSnwEqqMQZuxO4QwbncsBjRhcLuxePyzTelKycSDjO	Guilherme Souza 	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:58.769536	2025-11-11 03:42:58.769536
d0f1f357-cdda-49a8-874b-ddad849b0f66	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	operador1	operador1@grupoopus.com	$2b$10$M2aCV7VZ4HeiSiIJ71vw.e0u4flhECTmHvBsK/dTa0Yk2zkMAez.C	João Operador	operador	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:58.972754	2025-11-11 03:42:58.972754
user-Tecni-1761921006091	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	Tecni	Tecni@gmail.com	$2b$12$XRmOPgrkeuoHzDbT2OkpDOVla9vkEpuYtSxGAcaezzCiolkKjPWrW	Tecni	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:59.180181	2025-11-11 03:42:59.180181
user-andreia.nicolau-1760549944643	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	andreia.nicolau	andreia.nicolau@grupoopus.com	$2b$10$SNp8LiY/r5n5lhfJROSWL.Au5.q5QcyQCRl5SfZcvsOMNdg657MUe	Andreia Nicolau	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:59.385351	2025-11-11 03:42:59.385351
user-nubia.solange-1760549986782	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	nubia.solange	nubia.solange@grupoopus.com	$2b$10$H1v0idZ9uQmcHWSVN25IrejoctCzAeRUkxPQm/qYQEs3P2rDDIIb2	Nubia Solange	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:59.590321	2025-11-11 03:42:59.590321
user-rita.caetano-1760548000058	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	rita.caetano	rita.caetano@grupoopus.com	$2b$10$0BwvQLF03TsegJ24qKVPS.JQfXKxcJ4bcBNNe8cRlqhORaxAaoJ1G	Rita Caetano	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:59.793077	2025-11-11 03:42:59.793077
user-valeria.pessoa-1760550018472	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	valeria.pessoa	valeria.pessoa@grupoopus.com	$2b$10$1XefjEXBWBwFvSJQKXa3/eUzGhk5qGGYQ5eenSGVxtAiGR8s6AUZm	Valeria Pessoa	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:42:59.995926	2025-11-11 03:42:59.995926
user-valmir.vitor-1760549832765	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	valmir.vitor	valmir.vitor@grupoopus.com	$2b$10$k6iTDcA0DcmzcBqVrSBZ/Oq426DrTpDWZj2ig7v8y5WExnhxldNjO	Valmir Vitor	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.199092	2025-11-11 03:43:00.199092
c1c3f742-cd7c-4082-a9ae-422f1567da21	company-opus-default	\N	josias.santos	josias.santos@technofibras.com.br	$2b$12$71SBdIefJzar4vTZqiuMF.8yI.GTDAqoKuf82HF7O2btBEj4E8xX6	Josias Santos	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.609249	2025-11-11 03:43:00.609249
7dc2163b-7762-4cca-8f33-bd4386486e26	company-opus-default	\N	rafael.soriani	rafael.soriani@tecnofibras.com.br	$2b$12$Cg2zqfpx/kVwOjaTk8ktbe.KEgw5TGlzJ0XUyBkLq31MpWpJwItge	Rafael Soriani	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.405394	2025-11-12 17:33:21.391691
2eca20e5-066f-4c4a-afc8-d4ff1b6f5015	company-opus-default	\N	marcelo.alves	marcelo.alves@tecnofibras.com	$2b$12$gYxDuoTXB/aVz38vIjEEz.nxVb/Jf5JK3T5TubNY1t18tW4SlyIeq	Marcelo Alves 	auditor	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:43:01.023149	2025-11-11 03:43:01.023149
ad85d9cf-c3e6-4976-99bb-4b1bbfdf7b43	company-opus-default	\N	eduardo.santos	eduardo.santos@tecnofibras.com	$2b$12$3TQ4.FgA9jBpwu2k3MyxeeiOHeAA0BYS0lEQtnYHmgSPqTzgMWXDG	Eduardo Santos 	auditor	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:43:01.225289	2025-11-11 03:43:01.225289
user-Teste-1761919340112	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	Teste	OperadorTeste2@gmail.com	$2b$10$iptOpH/jL6u7qwel07m1ruRHQxv7UEEkdP7uX3NWBc5uedMIuPA1u	Operador Teste	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:01.428226	2025-11-11 03:43:01.428226
user-admin-opus	company-admin-default	\N	admin	admin@opus.com	$2b$10$2YSshXvLnm.uggbb1mNw6.sMUZYujg7U/Erk56f1WfVt0eLnIFN.q	Administrador Sistema	admin	opus_user	\N	local	\N	\N	{clean,maintenance}	t	2025-11-10 22:07:48.514007	2025-11-10 22:07:48.514007
177af1be-13d5-4ca7-8c64-d33a0c1e6b4f	company-opus-default	\N	edivaldo.dias	edivaldo.dias@tecnofibras.com.br	$2b$12$0uMMm4L6t38ZIcrZeJHeHeBTJbRQGhr2IYqUKTooR9J9yakg8gd.C	Edivaldo Dias 	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.819437	2025-11-11 19:35:58.410734
user-clientee-1762890270791	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	clientee	cliente@tt.com	$2b$12$4yaK0cJaA9ErsCpTow2aeuWuhbDteCxDNyzgJ5LVjTH.ihiTwcFpe	cliente	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 19:44:31.154748	2025-11-11 19:44:31.154748
user-joao.solva-1762977575399	company-admin-default	783a6a21-aa25-421d-b1da-bbd03410f2c5	joao.solva	joao21312@empresa.com	$2b$12$lSVB/YcgLLyy83wM.5tclu1ky6RHJZariqKmbtcasvWYXK/xKBMNa	joao.silva	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-12 19:59:35.82807	2025-11-12 19:59:35.82807
\.


--
-- Data for Name: webhook_configs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.webhook_configs (id, company_id, name, url, events, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_order_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_order_comments (id, work_order_id, user_id, comment, attachments, is_reopen_request, created_at, updated_at) FROM stdin;
f3340f5a-6207-441a-b929-0e9f4b737c08	212d41ad-ef44-47ac-b3c1-701ad57e65b3	user-joao.torres-1762816014081	⏯️ Joao Torres iniciou a execução da OS	\N	f	2025-11-11 02:54:29.276952	2025-11-11 02:54:29.276952
51fbbe28-9813-4459-a306-253d51d72abe	212d41ad-ef44-47ac-b3c1-701ad57e65b3	user-joao.torres-1762816014081	✅ OS Finalizada!\n\n📋 Checklist:\n	[]	f	2025-11-11 02:54:35.526648	2025-11-11 02:54:35.526648
4baf4915-0fda-4d8c-83c5-4c5bdba1e48b	b086a6b1-5605-475f-a010-7f1ea8aa1723	user-joao.torres-1762816014081	⏯️ Joao Torres iniciou a execução da OS	\N	f	2025-11-11 02:54:55.496125	2025-11-11 02:54:55.496125
30c1d516-6fa0-4ab0-a3ab-4b6046643fdd	b086a6b1-5605-475f-a010-7f1ea8aa1723	user-joao.torres-1762816014081	✅ OS Finalizada!\n\n📋 Checklist:\n	[]	f	2025-11-11 02:55:00.097043	2025-11-11 02:55:00.097043
e0da6243-b2b5-404e-a5c1-a2c039905d5d	db1af978-068d-4f3d-a2cd-501c025d0152	user-joao.torres-1762816014081	⏯️ Joao Torres iniciou a execução da OS	\N	f	2025-11-11 02:55:20.99521	2025-11-11 02:55:20.99521
633a07c4-ff8e-43e4-afc7-5fc7c058fb83	db1af978-068d-4f3d-a2cd-501c025d0152	user-joao.torres-1762816014081	✅ OS Finalizada!\n\n📋 Checklist:\n	[]	f	2025-11-11 02:55:24.908415	2025-11-11 02:55:24.908415
36af3d7f-f8fc-48cd-a981-e669a469b31b	fb0982f6-a330-4a76-81b3-5aa32b249d84	user-joao.silva-1762815860108	⏯️ João da Silva iniciou a execução da OS	\N	f	2025-11-11 02:56:53.461938	2025-11-11 02:56:53.461938
0aa60b23-cc3d-448d-96d7-14b852ce8190	fb0982f6-a330-4a76-81b3-5aa32b249d84	user-joao.silva-1762815860108	✅ OS Finalizada!\n\n📋 Checklist:\n	[]	f	2025-11-11 02:56:57.189807	2025-11-11 02:56:57.189807
839c781e-3570-4a73-ba31-77a972fc6838	a5cec180-8b1a-49c4-a724-1f8b9809e5d7	user-joao.silva-1762815860108	⏯️ João da Silva iniciou a execução da OS	\N	f	2025-11-11 02:57:16.097509	2025-11-11 02:57:16.097509
035ceccc-0db6-4b95-b226-05f71156338c	a5cec180-8b1a-49c4-a724-1f8b9809e5d7	user-joao.silva-1762815860108	⏸️ João da Silva pausou a OS\n\n📝 Motivo: P	\N	f	2025-11-11 02:57:22.337522	2025-11-11 02:57:22.337522
391de044-1b3a-4fdf-8435-602fff82854d	c6ab6737-e588-4453-b519-7b648fbf2955	user-joao.silva-1762815860108	⏯️ João da Silva iniciou a execução da OS	\N	f	2025-11-11 02:57:47.734898	2025-11-11 02:57:47.734898
76e09751-4938-4bfb-bb08-49a3fc9ebfde	bbf94365-6acd-4130-b45b-a41250beb308	user-joao.solva-1762977575399	⏯️ joao.silva iniciou a execução da OS	\N	f	2025-11-12 20:00:09.55572	2025-11-12 20:00:09.55572
5ca3a495-939a-4158-a5c9-e6c60a5847fa	bbf94365-6acd-4130-b45b-a41250beb308	user-joao.solva-1762977575399	✅ OS Finalizada!\n\n📋 Checklist:\n• 1: H\n	[]	f	2025-11-12 20:00:16.248883	2025-11-12 20:00:16.248883
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_orders (id, number, company_id, module, zone_id, service_id, cleaning_activity_id, maintenance_activity_id, checklist_template_id, maintenance_checklist_template_id, equipment_id, maintenance_plan_equipment_id, type, status, priority, title, description, assigned_user_id, origin, qr_code_point_id, requester_name, requester_contact, scheduled_date, due_date, scheduled_start_at, scheduled_end_at, started_at, completed_at, estimated_hours, sla_start_minutes, sla_complete_minutes, observations, checklist_data, attachments, customer_rating, customer_rating_comment, rated_at, rated_by, created_at, updated_at, cancellation_reason, cancelled_at, cancelled_by, customer_id, assigned_user_ids) FROM stdin;
139c9655-2cde-4972-9247-7ace82f5a100	8	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
9bc2754e-6742-4177-99e2-b4afcaa4b673	9	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
dec47d60-39c2-400e-a314-fee9669714c1	10	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
d1ff3323-7af9-42da-b73d-4e80fba5de27	11	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
d3850ed5-c0e5-444c-81df-887a2f937596	12	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
afe5498e-3206-43e6-9f1a-b2c8751c26e0	13	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
ff244dc5-7352-4470-a39e-35b28ecb8595	14	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
200ab0a0-1359-42f4-8465-30bc51332845	15	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
03c3ce05-2e0a-4c9d-8c7b-0437f0d1e84d	16	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
d966aae5-511b-47b3-bfea-342e399c9060	17	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
875779c6-319b-425f-b3a8-2415fdc6249e	18	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
c6ab6737-e588-4453-b519-7b648fbf2955	7	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	em_execucao	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	user-joao.silva-1762815860108	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 12:00:00	\N	\N	2025-11-11 02:57:45.859	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:57:47.313576	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	{user-joao.silva-1762815860108}
b086a6b1-5605-475f-a010-7f1ea8aa1723	5	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	concluida	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	user-joao.torres-1762816014081	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-10 08:00:00	2025-11-10 12:00:00	\N	\N	2025-11-11 02:54:53.627	2025-11-11 02:54:58.068	\N	\N	\N	\N	{"lBgsIu9xRhCPBH5hnrzhj": []}	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:54:59.726902	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	{user-joao.torres-1762816014081}
fb0982f6-a330-4a76-81b3-5aa32b249d84	4	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	concluida	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	user-joao.silva-1762815860108	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-09 08:00:00	2025-11-09 12:00:00	\N	\N	2025-11-11 02:56:51.551	2025-11-11 02:56:55.157	\N	\N	\N	\N	{"lBgsIu9xRhCPBH5hnrzhj": []}	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:56:56.821134	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	{user-joao.silva-1762815860108}
a5cec180-8b1a-49c4-a724-1f8b9809e5d7	6	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	pausada	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	user-joao.silva-1762815860108	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 12:00:00	\N	\N	2025-11-11 02:57:14.235	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:57:21.959185	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	{user-joao.silva-1762815860108}
1f99de65-e1b0-422b-8b2d-189fc694d0c6	19	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
627e9364-c980-4da2-bc16-5dbc9e791f71	20	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
307300e0-fa7f-4d2f-a681-66d251a78223	21	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
eca9b2ab-3f91-4f9d-b9ca-345b82f30b17	22	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
c6240b9d-e244-4ce1-90cf-733f9299cdf9	23	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
40fc8181-0af8-48af-94ce-6470b89b633b	24	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
880a2e52-614d-4226-88e4-dbef0c0a3e5d	25	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762829349044-b63jtarfr	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	aberta	media	Higienização de Cabine - ar condicionado	Manutenção preventiva para ar condicionado	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 12:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 02:49:11.987831	2025-11-11 02:49:11.987831	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N
212d41ad-ef44-47ac-b3c1-701ad57e65b3	1	company-admin-default	maintenance	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762818380501-b9ptcu9ly	\N	LSwNG2iHdUQZ4ZijKL-1q	I3cgNaIghKEHX5DR8yEF-	\N	programada	concluida	media	Manutenção dos ar condicionados - ar condicionado	Manutenção preventiva para ar condicionado	user-joao.torres-1762816014081	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-10 10:00:00	2025-11-10 14:00:00	\N	\N	2025-11-11 02:54:27.325	2025-11-11 02:54:33.404	\N	\N	\N	\N	{"lBgsIu9xRhCPBH5hnrzhj": []}	\N	\N	\N	\N	\N	2025-11-10 23:46:21.482994	2025-11-11 02:54:35.068358	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	{user-joao.torres-1762816014081}
db1af978-068d-4f3d-a2cd-501c025d0152	3	company-admin-default	maintenance	7c9bc3ac-1e99-4f19-9726-573a4569918d	aa599100-b76e-4dff-89ee-116abbce3355	\N	ma-1762818380501-b9ptcu9ly	\N	LSwNG2iHdUQZ4ZijKL-1q	jNGzf38-Bx6Z1fO9PCWle	\N	programada	concluida	media	Manutenção dos ar condicionados - ar condicionado	Manutenção preventiva para ar condicionado	user-joao.torres-1762816014081	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-10 10:00:00	2025-11-10 14:00:00	\N	\N	2025-11-11 02:55:19.144	2025-11-11 02:55:22.88	\N	\N	\N	\N	{"lBgsIu9xRhCPBH5hnrzhj": []}	\N	\N	\N	\N	\N	2025-11-10 23:46:21.482994	2025-11-11 02:55:24.539572	\N	\N	\N	a6460e7b-7b7f-45f0-b748-efddeea5707c	{user-joao.torres-1762816014081}
fb412008-3027-49c5-ba9e-9bc230f0cd3a	387	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 09:00:00	2025-11-11 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0e2f9309-b19e-499b-81d7-74503747e29e	388	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 09:00:00	2025-11-18 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
757136ec-8752-428a-9ea3-0043ecce4d05	389	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 09:00:00	2025-11-25 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0a99b912-9ef9-4b46-bdcc-5ff88a43e338	390	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 09:00:00	2025-11-11 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
aa9f5b12-f160-46c3-96de-f774903ed68d	391	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 09:00:00	2025-11-18 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
540c9191-5f38-4512-adba-6d5e17ccb4a6	1	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9785f590-aaa4-4ccd-8b8b-8842047cab5e	392	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 09:00:00	2025-11-25 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
2a73323c-fb5d-4a4a-93a0-10c11b59cdf1	393	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
e9666cfc-b9eb-4435-8a90-e2164c81d51a	394	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
fbab881b-849c-4d37-8117-ec8647de35e8	395	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5722c9cd-1f17-4009-a1c5-184c9e304144	396	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8def1010-e0f8-4686-a077-bee44e49ecea	397	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
e1f269b1-c270-420b-8993-1b7582ee083e	398	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
61728f72-4959-46ce-b791-4262a0f854a9	399	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
fecda9ca-27c5-4567-9392-6cd44dbe0766	400	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
97ba659f-a87a-4a2d-9bcb-b84747b7ca52	401	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
151d1b5c-5905-49b4-b45b-b4c6169bce6d	402	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d181d870-4590-4f21-b835-aecf8d7205b0	2	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0265470b-ea18-439f-a6fa-b063b1285250	253	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:34.347589	2025-11-11 03:44:34.347589	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0fd6a4a4-bcfc-4da3-a99a-5fc2ee36ed97	254	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:34.758858	2025-11-11 03:44:34.758858	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
3f05fff9-eeec-48ac-ba72-35ad01741f28	255	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:35.165149	2025-11-11 03:44:35.165149	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0b30fb18-61d3-44b4-8809-5727c376cff5	256	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:35.571812	2025-11-11 03:44:35.571812	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5e96e75b-8586-4d9c-8b27-44afc9b3db89	257	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:35.979546	2025-11-11 03:44:35.979546	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6a7eaa99-7307-4a50-b033-04d8243e7fea	258	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:36.385355	2025-11-11 03:44:36.385355	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
f1dab9e4-dbe2-4fb5-9a94-a1ef280a3b09	259	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:36.792541	2025-11-11 03:44:36.792541	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
cbed4d86-cc62-4d50-9e51-201ded6d5ac0	260	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:37.201162	2025-11-11 03:44:37.201162	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
50a5450f-d274-46a4-9861-4f13e1310d31	261	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31 00:00:00	2025-10-31 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:37.608351	2025-11-11 03:44:37.608351	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
35a5b7ec-9870-4c88-8f9a-8b1d003d0bf3	271	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:38.014914	2025-11-11 03:44:38.014914	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
7e588b0b-8035-4e3e-b930-7355ea1cfe75	403	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
09bf9c7b-7194-40f7-834f-b5e869bdc8b5	404	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
abcab419-c819-4ea6-92ce-92dad24930e5	405	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
2d3d9652-2a15-4920-864b-1f2e4d1a9d37	406	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
1eb2dad4-8199-4cd3-b935-9990139247c7	407	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
4f677328-8e00-479c-8295-37a1ecea81be	408	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
3095524e-a8d1-4eba-a4c8-bd5ef45aebc7	409	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
77bcc9c8-e184-4a82-b747-015500078c57	410	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
16dd40d2-295a-4d36-8255-8d1036b66910	411	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
fb6a3533-c4fb-4bd4-bc4c-a5918be508ab	412	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
3be19f38-0942-4e54-9bee-b64965f6a76b	413	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 09:00:00	2025-11-13 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5eae0811-7c0b-491e-939e-5ff85781a8c2	414	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 09:00:00	2025-11-20 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ddaf5290-3a64-40e4-897a-ab07d1b57f9b	415	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 09:00:00	2025-11-27 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8ae8eb68-ba18-40ce-a962-a16747200641	416	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 09:00:00	2025-11-14 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
2a532c0a-f451-4d21-a165-152fc69f8be1	417	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 09:00:00	2025-11-21 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8911e963-b8e9-411b-b94c-1db367e245fe	418	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\\nLimpeza interna das paredes e vidros das cabines do verniz\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do flash off do verniz\\nLimpeza das liminárias do verniz\\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\\n\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 09:00:00	2025-11-28 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
2b3ffb97-cac8-4f7a-affb-6b5f11ee7136	3	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ffedb134-1c91-41c7-8e0b-aefbe609dcb7	419	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 09:00:00	2025-11-17 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
4b4a8215-f8a0-4d6a-95b6-0a6d2a2d242c	420	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nLimpeza interna das paredes e vidros das cabines do primer;\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\\nJateamento com lava jato e aplicação de graxa patente no transportador\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 09:00:00	2025-11-24 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
44997e56-a6c0-4ec4-8261-c8e48e0a7974	421	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c0aab109-32e6-491c-b33d-c35850e0b0bf	266	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:49.427598	2025-11-11 03:44:49.427598	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6d3ea290-49aa-46cd-ae02-7c37872a76af	267	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:49.833928	2025-11-11 03:44:49.833928	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d1d1f959-4b9c-431a-8971-12cfe60cbd82	268	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:50.241352	2025-11-11 03:44:50.241352	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
27a89f22-8eb9-447b-8246-44c9cd1177da	269	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:50.650176	2025-11-11 03:44:50.650176	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
603c2bd2-5d95-4d87-bf13-efde31309e55	270	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:51.056281	2025-11-11 03:44:51.056281	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
e5f15e7b-9709-4041-b257-521abde06d4e	422	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8e37f563-55e1-4ecc-8122-7325a2caf746	4	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
259d8a9f-8b0e-48ca-92bf-852efb208831	423	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
eebd9277-0aa4-44cc-a70e-91dd50151c5c	272	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:55.944423	2025-11-11 03:44:55.944423	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
9fac80c0-c99a-434e-9429-52edd96abddf	273	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:56.351489	2025-11-11 03:44:56.351489	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d526f813-c733-492b-8996-de9aae8da6e3	274	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:56.760692	2025-11-11 03:44:56.760692	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
f10ce639-985a-4532-9f63-fdbbe30991d7	275	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\\nTroca de filtro da exaustão\\nLimpeza do chão da cabine\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30 00:00:00	2025-10-30 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:57.16695	2025-11-11 03:44:57.16695	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c4891cac-7129-40c1-952d-3f6809deefdb	276	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:57.573542	2025-11-11 03:44:57.573542	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d64cdb1b-aa68-4458-b079-1277e353f9d2	277	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:57.98058	2025-11-11 03:44:57.98058	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
aa624e68-3e23-493a-8dbf-6c05f231b258	278	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:58.387596	2025-11-11 03:44:58.387596	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
aaef7504-3025-4fee-acb8-5ca4b5bad773	279	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:58.79617	2025-11-11 03:44:58.79617	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c14c38ee-210e-48c6-99d0-01d12d63f98a	280	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:59.204676	2025-11-11 03:44:59.204676	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
e7fe88a7-c278-4f4e-adf0-24f10b7f9fd4	281	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:59.610399	2025-11-11 03:44:59.610399	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8d8e030d-dd5f-4764-a08b-fc4ebcba59f8	282	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:00.022291	2025-11-11 03:45:00.022291	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
eb0e1a9a-2ac6-4505-92f6-e451a2651ac9	283	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:00.428985	2025-11-11 03:45:00.428985	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
962cb8d1-29d3-4d64-9f0e-67c5f5a3b6be	284	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:00.841611	2025-11-11 03:45:00.841611	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0324b0f5-dad0-48dc-be35-6ab981052f3a	285	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:01.249166	2025-11-11 03:45:01.249166	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
f40edb97-82b2-4106-b978-2bdb07159787	286	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:01.655945	2025-11-11 03:45:01.655945	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
a0b2bd9c-2e97-4264-81b3-d5c8d87ec95a	287	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:02.071601	2025-11-11 03:45:02.071601	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
34aa9f5e-6d17-4551-bde9-553aee31c135	288	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:02.478453	2025-11-11 03:45:02.478453	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
86383070-2c1d-41ea-8a4a-636232de536f	289	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:02.886039	2025-11-11 03:45:02.886039	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0f8f8823-d4bd-4e2a-ba4a-553e9a510cfc	290	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:03.293008	2025-11-11 03:45:03.293008	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
399b0128-36e7-44dd-aca7-0fd9dec187e8	5	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0d12bc7b-15c5-4e5e-ab8a-2178ed2f2618	6	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0e7c0502-4512-44d0-a03a-a1de505d076a	291	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:03.699895	2025-11-11 03:45:03.699895	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
1e1657fc-dbda-4445-9017-3e13882639b3	292	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:04.107288	2025-11-11 03:45:04.107288	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
374b140c-ebab-4ec5-b59a-a2724b0d7088	293	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:04.513354	2025-11-11 03:45:04.513354	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
918c32bf-eb9c-4a62-8366-0ed5e70532f8	294	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:04.920175	2025-11-11 03:45:04.920175	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6033f064-3718-4225-ad68-301c25bac35e	295	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:05.327306	2025-11-11 03:45:05.327306	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
45f69590-f646-4097-9c69-fbe513309550	296	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:05.734552	2025-11-11 03:45:05.734552	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
cf3673e2-b1f3-4f41-a76c-ecf7fdf453b3	297	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:06.142131	2025-11-11 03:45:06.142131	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
cc38fffa-e58b-4a58-9b40-6fe37745ff64	324	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:17.96112	2025-11-11 03:45:17.96112	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0ef562d9-3c71-4b72-819d-e9dacee2a7ff	298	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:06.552133	2025-11-11 03:45:06.552133	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6ac5ea6d-6f99-4aa9-b713-07b6c7c72b4f	299	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:06.959004	2025-11-11 03:45:06.959004	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
4407670b-03fd-48b9-bea1-061e76a8a2ef	300	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:07.366623	2025-11-11 03:45:07.366623	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b8783afe-a23b-417c-ab54-d74a626c5336	424	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
dc285502-83a8-4dc7-88ae-2769c0337ca2	302	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:08.995251	2025-11-11 03:45:08.995251	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ddfae9bf-488a-4330-9c6f-675e9c74aa83	303	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:09.406253	2025-11-11 03:45:09.406253	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c04d1308-5f9d-4753-9c26-861ba3bb2852	304	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:09.81388	2025-11-11 03:45:09.81388	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d428e716-84c6-462d-bacc-bae601d9855a	325	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:18.385963	2025-11-11 03:45:18.385963	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
da0d29b4-9861-4712-b1eb-eb609a463ec3	305	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:10.222002	2025-11-11 03:45:10.222002	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d02c5130-72be-45e9-a642-60d17dac5959	306	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:10.629377	2025-11-11 03:45:10.629377	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
7dc56154-ba4a-4417-9ddf-40a148dc5254	307	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:11.036068	2025-11-11 03:45:11.036068	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ef36b53b-3942-4810-b544-3adab7356f33	308	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:11.44235	2025-11-11 03:45:11.44235	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
64031a41-2651-4c92-9124-e11b75079075	309	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:11.849732	2025-11-11 03:45:11.849732	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
74302911-3aff-4db8-b16a-354306092faf	310	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:12.255717	2025-11-11 03:45:12.255717	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
06dca77d-fbfa-4117-a505-229825462fd0	311	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:12.663776	2025-11-11 03:45:12.663776	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
9f27e645-58c6-4ca6-9d4d-fb5d32a32b9a	326	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:18.793933	2025-11-11 03:45:18.793933	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
21928095-9588-4a0b-995a-4f55cdc98cee	312	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:13.070265	2025-11-11 03:45:13.070265	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
48a6b80a-d7a0-42c9-b5d3-53dd7db6786c	313	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30 00:00:00	2025-10-30 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:13.476025	2025-11-11 03:45:13.476025	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
dc9f254f-8c41-430c-b2fc-fccd4ae4f37f	314	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31 00:00:00	2025-10-31 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:13.883851	2025-11-11 03:45:13.883851	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d778a5c5-44c9-4c4c-a5d1-0630ef274786	315	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:14.291639	2025-11-11 03:45:14.291639	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b1021599-4a98-4db6-8fdd-eb6deaad92b5	316	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:14.697701	2025-11-11 03:45:14.697701	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
976a1e8d-6624-4566-80e4-daa5577dd8df	317	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:15.104714	2025-11-11 03:45:15.104714	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
be4f0cb9-0dd5-4436-a580-8808d1e6c750	318	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:15.514169	2025-11-11 03:45:15.514169	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c05aa57e-0440-40de-a230-5c2f7bcaf3d3	319	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:15.920942	2025-11-11 03:45:15.920942	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
06f4d333-ba23-45e9-b821-da9106630fd3	320	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:16.327556	2025-11-11 03:45:16.327556	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
1d066441-32ff-4a21-9806-a3bbc1ff528c	321	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:16.735457	2025-11-11 03:45:16.735457	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b97959e9-333a-4c7a-9e26-679b26ac00f8	322	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:17.143653	2025-11-11 03:45:17.143653	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d91e0c57-d50e-416c-881b-b854251516b5	323	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:17.553241	2025-11-11 03:45:17.553241	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
adb08071-068d-4418-8a84-e309cfd645a0	7	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
eb6e5306-71bc-4667-b1a8-cc25be51f08a	327	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:19.200443	2025-11-11 03:45:19.200443	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
18b45bb1-2710-4707-a30a-a4571bbeb892	328	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:19.607879	2025-11-11 03:45:19.607879	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
672381d0-3fdc-4936-951e-126107c41faa	329	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:20.01994	2025-11-11 03:45:20.01994	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
10142248-306e-4c9b-8b6d-290c1ab3a32a	330	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:20.427282	2025-11-11 03:45:20.427282	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
3328f7b7-305b-445f-a2ee-f50a675f4165	331	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:20.833836	2025-11-11 03:45:20.833836	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
24456b9f-fcd2-42b1-afe3-80bf4c5f3d8b	332	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:21.241381	2025-11-11 03:45:21.241381	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6654b3cb-2838-4cee-8d4e-ce6ae641d31c	333	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:21.650823	2025-11-11 03:45:21.650823	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
10ec1d2a-3995-4588-8128-24a3fa3cffbe	334	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:22.065969	2025-11-11 03:45:22.065969	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
4d090838-23c0-41d5-a4ea-2afd340f1476	335	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:22.479246	2025-11-11 03:45:22.479246	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
18290b71-bc17-4cda-b4c6-8058c64c1d12	336	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:22.891195	2025-11-11 03:45:22.891195	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
cc3e9305-0b5c-4c80-8ed8-4903ea383dbf	337	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:23.301151	2025-11-11 03:45:23.301151	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
87157635-5d7f-43e9-be26-14d5d1684961	338	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:23.711358	2025-11-11 03:45:23.711358	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
aaf45fba-9f3e-46c8-b194-102c15f1e754	339	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:24.122984	2025-11-11 03:45:24.122984	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
a00adaaf-b092-4f98-ace2-303a6d5853c1	340	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:24.536363	2025-11-11 03:45:24.536363	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
771edfdb-2a24-48c7-b56d-eca31517c941	341	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:24.946764	2025-11-11 03:45:24.946764	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ddbe131e-8658-490b-89a8-96d9aa669429	342	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:25.356842	2025-11-11 03:45:25.356842	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
08fcb1ba-7bc2-45d4-8db6-39464c5986ef	343	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:25.767427	2025-11-11 03:45:25.767427	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d561fd04-472c-48ad-abf9-ba52559c967d	344	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30 00:00:00	2025-10-30 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:26.177598	2025-11-11 03:45:26.177598	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
868dd8da-05c1-4b66-b15c-815701a51ccf	345	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31 00:00:00	2025-10-31 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:26.587306	2025-11-11 03:45:26.587306	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
1d8a8ab3-df41-4fa6-a1b4-b5da0fee4312	8	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7775ede7-0e23-4b6e-bc01-722ef19dc900	381	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:27.406363	2025-11-11 03:45:27.406363	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8d47cd07-b68b-47dc-a52d-630f5ee8b3bb	382	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:27.817176	2025-11-11 03:45:27.817176	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d281e318-6499-4873-86b4-2341392b47e9	9	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f7281089-3632-453a-927a-1c795ee31f18	378	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:28.641039	2025-11-11 03:45:28.641039	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c20bf156-3aa3-440f-b3fa-fdad5682641c	379	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:29.052927	2025-11-11 03:45:29.052927	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
44173277-465a-4154-a507-12e4d4b41f98	380	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:29.462023	2025-11-11 03:45:29.462023	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
a1f0534f-81fb-424b-865b-89356cf5a3e8	383	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:29.879726	2025-11-11 03:45:29.879726	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5b549f49-f4db-44e9-9c60-aa45569d8f30	384	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:30.289385	2025-11-11 03:45:30.289385	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
36c47ef9-1ea2-4c16-ab82-c634c3d7600d	385	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:30.699162	2025-11-11 03:45:30.699162	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b532726a-31c9-4e9c-9fc8-84332770abb2	386	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759890045118-y0c75246f	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Limpeza do fosso da exaustão da base\\nLimpeza externa das paredes e vidros das cabines da base\\nLimpeza do fosso da exaustão do verniz\\nAspiração da região superior (teto) da estufa da pintura final\\nLimpeza externa das paredes e vidros das cabines do verniz\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:31.136524	2025-11-11 03:45:31.136524	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ab83a444-b6bf-4fd3-9133-cb5780dce91a	301	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	concluida	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	2025-10-07 21:12:14.291	2025-10-17 17:08:33.467	\N	\N	\N	\N	{"1759332012650": {"type": "photo", "count": 1, "photos": ["data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABWUAAAHqCAYAAABsuiw0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAALiMAAC4jAXilP3YAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAyMzoxMDowNiAxNDozMTozMUcVVSsAAIRXSURBVHhe7d0FmB3V+cfxzEo2u9GNuxCDhECMkGAJgeCuhdIiNUopUOFfb6lSSgVaoF4ohZYWKaXFigcLFgJR4u6e3SSr8/+9OwcKYX2vjHw/z3Oe855z7+69d+bMvXPfO3PG832/FQAAAAAAAAAgM3JcDQAAAAAAAADIAJKyAAAAAAAAAJBBJGUBAAAAAAAAIINIygIAAAAAAABABpGUBQAAAAAAAIAMIikLAAAAAAAAABlEUhYAAAAAAAAAMoikLAAAAAAAAABkEElZAAAAAAAAAMggkrIAAAAAAAAAkEEkZQEAAAAAAAAgg0jKAgAAAAAAAEAGkZQFAAAAAAAAgAwiKQsAAAAAAAAAGURSFgAAAAAAAAAyiKQsAAAAAAAAAGQQSVkAAAAAAAAAyCCSsgAAAAAAAACQQSRlAQAAAAAAACCDSMoCAAAAAAAAQAaRlAUAAAAAAACADCIpCwAAAAAAAAAZRFIWAAAAAAAAADKIpCwAAAAAAAAAZBBJWQAAAAAAAADIIJKyAAAAAAAAAJBBJGUBAAAAAAAAIINIygIAAAAAAABABpGUBQAAAAAAAIAMIikLAAAAAAAAABlEUhYAAAAAAAAAMoikLAAAAAAAAABkEElZAAAAAAAAAMggkrIAAAAAAAAAkEEkZQEAAAAAAAAgg0jKAgAAAAAAAEAGkZQFAAAAAAAAgAwiKQsAAAAAAAAAGURSFgAAAAAAAAAyiKQsAAAAAAAAAGQQSVkAAAAAAAAAyCCSsgAAAAAAAACQQSRlAQAAAAAAACCDSMoCAAAAAAAAQAaRlAUAAAAAAACADCIpCwAAAAAAAAAZRFIWAAAAAAAAADKIpCwAAAAAAAAAZBBJWQAAAAAAAADIIJKyAAAAAAAAAJBBJGUBAAAAAAAAIINIygIAAAAAAABABpGUBQAAAAAAAIAMIikLAAAAAAAAABlEUhYAAAAAAAAAMoikLAAAAAAAAABkkOf7vguBZCkrr+hSurusz+49ZX32lJV3Ly+vLFZfcXlFZae9qitUl5Wpr7KyU0VFRXv7m4qK6natfD+vJq6qaq/tp84fNvJyc3bl5OSW5+fnlOTn5u3xcr2yNq3zt+Xn524vyM/f3rp13vaC1vlbCwtab2pTkL+psE3BusI2+ZuK2hSszcvLLXX/BgAAAAAAADFDUhaxZcnWHbt2D7Oyq3T3fqW7y/sGSdi9fUr27u1bXeW3cXcNnfy83O3tigpXtWtbsKptUcGq9m2LlnZoV7ikQ7uixaoXk7QFAAAAAACILpKyiDSN39ztO3fvv3XHroMt+bpz5+5h20tKh1tdUVXdzt0tdtoU5K/v1LHt/M4d28/p1KFofqf2iju1m13QOn+LuwsAAAAAAABCiqQsIqO62s/ftqNk1OZtu8Zu2b5rzOZtO8dt21Y6qrK6qsjdJfGKitqs6tqp3Ztditu/2bW4w8yundu/VtSmYJ27GQAAAAAAACFAUhahtWdvec/1m7cfsWHT9iPXb952xLZtJQdVt2pVM58rGs8StT26dJjRrXPHV3p07fhS1+L2b+Tk5JS7mwEAAAAAAJBhJGURGrtK9+y3ftP2o9Zv2nbEhs07jrTpCNxNSKHcHG9P927FL/Xq2un5nt06Pde9a8eXc3NyytzNAAAAAAAASDOSssiaisqq9ms3bD1m9botJ65cv+XE3bv39nM3IYMsSdure+fpfXp2/m/v7p2ftLlp1c0bAwAAAAAAQJqQlEVGbd1ectCaDVuPW7lu00kbN28/orq6Vb67CSFRWFiwtn+vLo/069X1P316dn4iLzd3t7sJAAAAAAAAKUBSFmml8ZWzYfOOw5et2nDe8tUbz9y9t7yPuwkRkOvllPXq2enpgX16PNC/T9eHCgtab3Q3AQAAAAAAoJlIyiLlNKZyN2zecViQiN109u69Zb3cTYgwz/Oqe3Xr9OyAvt3/ObBvt/uL2hSsczcBAAAAAACgCUjKIlW8DZu3H754xbqLlq3afFZZeXk3148YqknQdi9+enD/nn8d2LfbA63z83a4mwAAAAAAANAAkrJokdLde/stWr7u4kXL1l28s3TPENeNBLEpDvr36fLvoYN639G3Z5fHPM+rcjcBAAAAAACgFiRl0WRVVdWFy9dsPHPRsrWXrF6/9VhP3E1IOJvSYMjAnncOG9T79o7ti95x3QAAAAAAAHgfkrJotO07Sw+Yt3j1lUuWr/9oeWVlR9cN1Kpn1+LnRgztc9uAPt0ezMnJKXfdAAAAAAAAiUdSFvXS+MhZuXbzqfMWrbpq7cZtU1030GiFbfI3DBvU508HDOl7W9vCgtWuGwAAAAAAILFIyqJWZeUVnd9ZuvaT85es/mxJ6d6BrhtoAa9qv37d7xs5rN9N3bt0nOE6AQAAAAAAEoekLD5gZ8meIbMXrPjSouVrL66q9gtdN5BS3bp0eGXUsAE/G9i32/2e51W7bgAAAAAAgEQgKYsa23aUjJo1f9nXl67cdG6rVn6u6wbSqkPbwsWjDhhw49CBvf6cm5NT5roBAAAAAABijaRswm3csmPiW/OXf2Pl2s2nuC4g49oU5K8fNXzAL2ze2fy83BLXDQAAAAAAEEskZRNq3cZtU2bOWXbd+s3bJrsuIOta5+dvOeiA/j8dMaTfLSRnAQAAAABAXJGUTZhNW3dOeG32kh+t27D1GNcFhI4lZ0ePGHCDJWdzc3P2uG4AAAAAAIBYICmbENt3lo54bfbiH65cs/kM1wWEXmFhwdqxIwZ9b9h+vf+Y43mVrhsAAAAAACDSSMrGXMnuvQNmzl763YXL137cE9cNREqHdm2WjB819GuD+nW/T03etAAAAAAAQKSRlI2p8orKjrPmLfvW3EUrr6qubpXvuoFI69a548sTxwz9UvcuHV92XQAAAAAAAJFDUjZmtD5zFi1fd+nrby/50Z6y8u6uG4iVQX17/GPCwUO+0q5tm+WuCwAAAAAAIDJIysbIhs3bD3/5zXd+uWVbyVjXBcRWTq63d/T+g3580P4DfsLFwAAAAAAAQJSQlI2B0j1lfV+btegnS1ZtuMB1AYlhR8tOHD3siwP6dPun6wIAAAAAAAg1krIRpnWXO3fRqqten7P0+1WVVW1dN5BIfXt1fvTwsQdcwZQGAAAAAAAg7EjKRtTW7SUHT399/h+2bN053nUBiZeb4+0Ze+Dg6w4c3v/nOZ5X6boBAAAAAABChaRsxFRVVRfOnLv0O28vWPnlVq38XNcN4H2KO7SbfdSEAy7r2rnD664LAAAAAAAgNEjKRsjaDVuPefGN+b/dWbJ3sOsCUCev6uD9B9w4ZuSg7+bm5ux1nQAAAAAAAFlHUjYCKiqr2r0ya+Ev3lm69pOuC0AjdWhX+M7kQ0de0r1LxxmuCwAAAAAAIKtIyobcuo3bpkx/bd7tJaV7B7ouAE3keV71QfsPuGHsyP2+k5PjVbhuAAAAAACArCApG1JV1dUFr7+95Eez31nxBU9cN4AW6NKx/azJE0deVNyx7VzXBQAAAAAAkHEkZUNo+87SEc/MmP23rdtLD3JdAFIk18spO2T0kK+MHNrvl2ryBggAAAAAADKOpGzIzF+8+ooZby38WXWV38Z1AUiDvr26Pjx5wohL2hTkb3ZdAAAAAAAAGUFSNiTKKyo7Pf/a/D8sX73xbNcFIM2K2hSss+kMencvftp1AQAAAAAApB1J2RDYtHXnhKdfnv13LuYFZJ5dBGzMiEHfGz1i4Pctdt0AAAAAAABpQ1I2y2qmK5j1zk3V1a3yXReALOjds/N/jz70wI8ynQEAAAAAAEg3krJZUllZ1faFNxb8dsmK9R91XQCyrKiozapjJh14XvcuHWe4LgAAAAAAgJQjKZsFu0r37PfE828/uG1nySjXBSAkPC+n/Ijxw68YNqj3H10XAAAAAABASpGUzbC1G7Ye8/RLc/5RVlHR2XUBCKEDBvf99cQxw67OyfEqXBcAAAAAAEBKkJTNoLkLV13zyluLfqZlnuO6AIRYj26dph972Khz2hS03uS6gKRqr9LL1VbMbhXbNtaolFsHWuWp9FDprtJR5QWVShWEj+2L2brqpvLuD+V7VWxcb1FZpxLniz/adlyoUqTiqdhr36OyXQUAAAAZQFI2A6qr/fyXZ75zy4Klaz7tugBERLu2bZYff+Tokzp1aDvfdQFx11rlMJUp2kc4UvUBnudZQrZWuo8lrlaqvK77vaz6UZWmbi8NJYIOUrHHaBE919v0HC90zdr82JXGsmTeKfq/U1SPV7FlZYnZdxWrNPTaGrrd1sHsIMwOvb639br6u2ZtbH78h4Ow5fR41+vxPuuaH6Lbf63bv+aajWXJ1xP1t0eonqAyXP+jjd1QG93PfmhYrDJb93tW9TMq76hEjSVdD1E5XK/J6v2s6DW1U/0huk+ZqqWuvKX72Q8Ltl2TrAUAAEgxkrJpVlZeWfzkS2/dv37j9qNdF4CIycvP23nspFHn9unZ+b+uC4ij8donuEz1+Z7ntWiKHf2fufoff1JoczPvqOmsX0M7I4NUlgdhi9yhcnEQ1uq7KtcFYb2O12u0pOEpep25QVetGpOUbei1j1GZFYTZode6XK9zgGvW5kyVB4Ow5fR4N+nxrnbND9HtN+v2a1yzPpYgP1v3/4TqY/U3dkRos+n/2Li+S6GNo/U1neHUVuVUPd9zVZ+k51xn8rkx9H/sh5dn9X/uVW3FjiQGAABAC3EafRqVlO4d+J+nXn+JhCwQbZUVlR0emz7rkQVL1lzuuoA4meT7/mOqX/M877MqLZ7zXP9jpCqbrmeVakty2tF6cTBRr8mOGnxMr/F0lfoSssge27+9ROtqiep7tJ6mqbQoIWv0L2xcX6//u1LlN4rtx4Iw6aXn9UN7for/pud7lkqLErJG/yNHZarCX+t/r1b5reL9a24EAABAs5GUTZPN23aNe+ipV2ds31XKTisQC37ui28s+PXrs5f8UI0Wf7kHQqCr7/u3q37J87zjg67U0v+1eSu/o8ex6Qym1XRGU4Few89Vv6zXNDHoQkgdpHU1Q/XtWlf1TbnQbPq/+SqfcePafnRoceKzhexHj+v0fJbqeX1dJW0Xk9X/bqPyaT3WXBVLztr8yQAAAGgGkrJpsGrdlpMefuqN6Xv2VtgFJADEyFvzl399+ivzbq+urrZ5N4Gosvli53ied4lrp5Uex5Jj/9Vj/kh11PY97OjD5/QavuDaCK/Lta5e1bqyuVPTTo9ToMp+dHhL9aiazsw7Ro9vc91+R88nY8lhPZYdPWvJ2UVqZuR9BAAAIG5IyqbY4uXrPv7ki7MerKyuisupmgD2sWjFuosff+Gtf1dWsZ0jkq72ff9Jz/My/sOhHvNremybkzIqP2r01fN9Xs/7UNdGONk1Em5WbRcAs0RpRukxh+nx7ejci4KejMjVY96g8oQev6/ryzg9dgdVt+t53KPaYgAAADQSSdkUmrNw5Refe3Xen6urW+W7LgAxtXb91uMeefqNZ8rKK9J2miiQBl9XsYsoNXsuVN/3d6msUFmuskZlr7upUfTYZ+lv/q4w7POx2vQOlrwe7NoIJ0vI/knr6SrXzgo9vv1I9xeVxlyArKWK9Jr/pcf8P5VQTKejp3G+ntNzCnsFPQAAAGiI7ci6EC3xxuwlP5g1f/k3XBPvU1jQemObgtYbCotar2uTn7+tdX7ejrz83J2qreywWt8oqvNVuz9plZ+Xu0s7+FUVlVXtNUbtaJBci+22ysqqoupqv3VZRUWnsrKKLmXllZ0tMVZWVq66svOesvKuum+nmn8EpFmnju3mnHjU6OOLCgvWui4grL6scmMQNo7eeytU/Vfvx0+qflFlocoOlX31URmh+x+l+56oeFxNbz1031t13yvfbbq6LnZBpeVB2CJ21fyLg7BW31WxOULtc+dxPb9janqbr1hlexDWqaHXPkZlVhBmh5bFci2LAa5ZmzNVHgzCltPj2Q8HV7vmh+j2m3V7TfJT8Y2KbWzXS/fzdb+Zql5Q/Ya67LT79Sq7VKpVOqp0URmqMlr3m6J6vO7bnB8PrlX5aRCmXEc9NxubTT56W39XpupVlTf194tVr1MpVbHXb0nlHrqP/QhhUzEcpvvU7Hc1hf5+hf7OLnC7LOgBAABAXUjKtpw3482Fv5i7aFWdXx7izPNyyju0a7O8fbs2S9q3LVrWvm3h0g7tCpe2LWqzsqiw9do2Ba035Xhepbt7xlRVVRfu2r1nQEnp3gElu/cOKC3d278m3rNnwI5du4cx3y9SSdvAkuOPGnu8xr5d6RsIo9P1ef+Apzdt166X7rtW97Wk0p9VttZ0Ns1w/Q87cvEy/Z/65rn8mMpdKmFLytqPrD+wjobodb6u1/iUQkv0WdLafqDZpNJYJGX3ocdrbFL2QpW7azrroPuu0n1vVfhXlVU1nY1nF7H6iP7HlfoflqxtivNV/hGEKdNaz+UxPRdLejaK7m8/rPxTf2Pb2RMqjT2y3ZLRh+vvbRl/VH/frqa3EfQ3S3T/SQqbsh0AAAAkDknZFtCyy31p5oJbFyxZ+xnXFVvaua7u0K5wQeeObecVd2w/p7hj29mdFHdsV7RIt1W5u0WGHVm7bUfpgdt3lo7YtqPkwK3bFe/aNXJvWWVXdxegSYratF5z8tTxU7Sd2NFHQJjYRbbeVrEjAeulz7W9ek//oUI7otaOqmupPvqfP9f/PM+192VH3R6ksqKmVbdMJmX/puf8tp5znfPe6vbVuv3XCu3/tfQoeZKy+9DjNSYpe7Pq2arbuu4P0G2bdJtN13GnSnlNZ/PZjxmWnL1B/7NR87fqvnt038MUpmzd6X/+Vf/zAtesl+5r+2a36f62LTc1Gb0vO/voSv3Pr+j/NSo5q/vajxVHKEzF+wgAAEAskZRtJi233OdemXfnkpXr7QiC2GlfVLisW5cOr3bt3OG1bp1VF7efmZeXa6e4xVrpnrK+GzfvmLRp645DN27ZMXHTtp3jqqv8jF3NGNFGYhYhZJ/zNi/qVNeuk+43T/ez5OncoCelLKH1+zoSOnbhr3ODsE4ZS8rqedop6ye79r4siWxH0t6m0tJE37tIyu5Dj9dgUlbVSN3n2KDng3T733XbZxVuC3pSxqZU+qn+96ddu1667xzdd7zCVCQm7TF/G4T10+PO1OPaOJ8T9KSM/chiid7TXLteuu+vdN+szvULAAAQZiRlm0HLLHYJ2eIORXN7de/8bM/uxc/26tbpOZt2wN2UaNW+n7d1267Rm7bunLBu49aj127YPrWsggs7oW6FbfI3nDh57LTiju1muy4gm+yoOjttu176XHvGJVpKgp60GKXHsflpe7p2U2QkKavnZ3N1Hu+aH6DbntVtNt3C6qAnZUjK7kOP11BSdqFuH+aa71F/tfu7W4KetPm4HusPeqwGL+yq+12v+9kRuy1h04HM0v9p8Edi3e83up9N7ZCuI1TtwmLX6HEsOd2Y6VDsB45HghAAAADvR1K2ibS8YpGQtSP6+vXq9kifXp3/SxK28bT+c7Zs2zV2zYat09Zu2Hrshk07Dq/yqwvczUCNojYF606eOu4ojphFltn8kws8z7OEZp10H0vI2sW5MnGa8VA93kt6vKZOFZOpI2VrpedsR/leoTAdc6STlN2HHq/epGxt9DdV+puLFN4T9KTdKXrM+/SY9e4D6D5lus9whQ1N0VEn/Q+bR7bWHwv28S2VRs2FnALn6nndredVb2Ja91mq+4xQyDQGAAAA+yAp2zTeC68t+O07y9Z8yrUjQzvE1T26dnixX69uD/ft2eXRzp3a2fyCaCG7oNj6TduPXLFm0xlWdu8t6+VuQsIxlQFC4BMqfwjC2mkfwI44tKu4bw96MuIwPa4dddrgUYbvk7WkrJ6rHXloCdl07TCRlN2HHq/JSVm5XKVRp/en0EdU/haEddPruUuvx46ybo5TVR4KwrrpMVJxRG5TfVTFLiDWELtw3o+CEAAAAO8iKdt43ouvL7htwdI1ttMfCTmtWlX27tnlqUH9ut87oE+3fxa0zm/OFbTRSNqWcmyag+WrN521Ys2Gs3aW7B3sbkJCWWL21GMOOaJd2zapSCYBTaL3pLc8z7OLaNVKt1fodkvIvhn0ZNRXVa4PwkbJSlJWy+hRLaNTFFYHPWlBUnYferwmJWV1f0uc2xyyGafH/pEe+2uuWSvdx47i3U/hyqCn8fS3r+lvbV7aOuk+D+o+Z1kY9GSOHvv7euxvumatdJ8tuo+Nn9hfmwAAAKApSMo20qtvLf7J7HdWXOuaoaWd3uo+PYsfH9S3x30D+nR7kERs9mzbUTJq6aqN5y1avvZjpbvL6vsyixjr0K7NklOmHnJEYZvW610XkAmWbJ0RhLXT578lk+wItmzI0eO/qcevM2m8j4wnZfX81uv52WnXqb5Y1L5Iyu5Dj9fopKzua0d72zLaHfRkXL6ewyvuOdTnBhX7MaIpjlZ5Oghrp8dep8cepXBL0JNxeXoOL+o5THDtunxeJd1z/QIAAEQKSdlGeGv+8q+9PntJqE+76tSx3ZxhA3v9efCAHnfbfJauG+Hgrdu4bfKi5esuXr5qwzkVVdW1XX0cMWbb56lTxx3ROj/PrtwOpJ0+22/0PO/Lrvkhun2jbrej+dN5Ya+G2JXznwjCBmXjSNlzVe4LwrQiKbsPPV5TjpQNw4WkDlN5MQhrp9e0Sa/JpjiqCnoapr+xOWvPds262Dy6dwdh1ozWc52p52oXAauVbn9HN+/vmgAAABCSsg1YsGTNZ158Y8FvXDNUWufl7RgyqNedwwb2uqNLcfuZrhshVllZ1Xb5mk1nLly+7pJ1G7Ye47qRAN27dJxx4pQxx+Tl5mbraC4kiD7bF3tB0rUumbwgUJ30PN/Q8xzrmvXJaFJWz8uOfJzomulGUnYferzGJmWfU5kShNml5/yAnrMth/rYc7Xn3Bjt9D8tkdvGtT9Et1si1KY2CMPOfGO2LTsyfnYQAgAAIMfVqMXy1RvPemnmO7e5Zmh0Lm7/5hHjD/jUBacd0WfSmGFXkZCNjry83NIhA3reddLkMceee9KkYSOH9vtlXm7OLnczYmzjlh0Tn3px9v3Vvp/nuoB06ePVk5D1fb9SVaYviFQrPc9bXRgqel5ZT1ijUX7m6qzTmGnwuWjbs3lfG+tU/c86E7JGt/9UVViOrmjM67/QhQAAABCSsnXYsHn7Ec+8Mudu7UCGYhnl5LSqGDyg519OO+aQiWdOmzB2+H69/2AJPnczIqhDu6JFE8cMu/rC04/qfdjY4Z/r2L5onrsJMbV6/ZYTXnx9/u8U1nmKJ5ACk1xdl6dUNgVh1j3oksShoeezWtWjQQthpfW0VtXDQSsUXtRzmuviutgcsY2i/1Xv2TS63bbhe4NWKMzWc6p3Cgdp9OsHAABIApKytdi+s/SAx6fP+nd1lV/vEQqZkJeft/PA4f1/ev7JRwyacujIj3fr0uEVdxNiIj8vt+SAIX1vO+fESQeeOHnMsX17dSYZEGMLl627dOacpde5JpByvu/XOx2A53n/dmEY2MUoXwrC0Pi7SqPn/UTWPKBSHYThoG3Lxk59Rqq0D8IGHeHqutjrD9UPGo14/eNUioIQAAAAJGX3sWdveY/Hn5/1SEVlVSfXlRVtC1uvnnDw0GsvPOXwfoeqLiosWONuQnz5vXt0fur4I8ecdMa0CWMH9et+ry/uNsTIm/OWfXvhsrWfcE0gpTzPG+LCujzv6rBo6Oi6jNLy+48LEWJaT9m+uFdtHnN1rfScbb/bEpMN6az7DndxrXR7mI4Sfle9246es03f05jXDwAAkAgkZd+nsqqq6InnZz1UUrp3oOvKuKKiNqsOH7f/Z887+fDBo4b3/2l+ft5OdxMSpEtx+zenThp13jknTRoxdECvP+urDEdtxcyLb8z/9dqN26a6JpAyvu/X+Rmm2ypUzQla4eB53psuzDotHzvykDNSQs79YPly0AqVN/XU9ri4LkNdXZ/G3CeMr3+ZXv86F9dlmKsBAAASj6Ts/3jTX5n7503bdk1w7Yx6Nxl7/kmThuw/uM9vcnJyyt1NSLBO7dsuOOrQEZecf8ph++2/X5/fkZyNj+rqVvlPv/T2fTt27a73aCigGbq7ujZLVUJ1yrfYcwoLS1g3lFRD9q1Q2R6EoWJJ/Xp/9PB9f5AL61Pv0e76H/b6Nwet0HnD1bXSc9/PhQAAAIlHUtaxOR6Xrd50jmtmTEHr1psmjR3+eZKxqE+7ojYrDx+//2fOOXHiiIF9u9/vuhFxZeWVxf99/q1/l5VXdHZdQCrUN2dlGKfC2eDqrPM8b5ELEW5hSuTva4mr69Lf1fVp6D5hfv0NPbfGvH4AAIBEICkry1ZtOM/meHTNjMjLyd09esSgH5x/ymGDRwzpewvJWDRGx/ZFC485bNQ5px17yKE9u3d6xnUjwnaW7B769Euzbf7gXNcFtFR9F6nc5eowKXF11mk7XO5ChFuY59lv6PT9dq6uk8ZhoQvrstrVoeN53ioX1qWxFzoDAACIvcQnZbds3zX6uVfm3uGaaaed1ephg3r98dyTJw0dd+B+38rPyw3jF2SEXLfOHV49ecq4qccfNfrE4g7tZrtuRJTNLfvqW4t/4ppAi+hzxuaNrUt9tyWelt1uFyLcSl0dOhpDDV0LoDFJyQ6urktofsioRUPbEElZAAAAJ9FJWTtl+KkXZj9QVd3gEQkp0aNrxxftqvpHHjLik0WFBWtdN9BsfXt2eeyM4yeMtSkw8vNywzi/HhppzsKVX1y8Yv3HXBNoNt/3y1xYmzAmRFq7Gmis+sZ4qHme15izIhraPw/z2VX1JmUb+foBAAASIbFJWTtV+JmXZ9+za/eexlxwoUXaFOSvn3zoyI+dMnX8kZ07tXvLdQMpkeN5lTYFxrknHzZ82KBet7tuRNDzr8/73ZZtu8a4JtBcdR5F6HleVxeGSRdXI7waPOU+w8L2fN6j/cs8F9ZKtzfmQnsNHdFe3xQl2VbvutHr50J6AAAATmKTsjPnLrtuzYZt01wzTbyqA4f1/8V5Jx02fMiAnnepww/6gdQrLGi98chDRlx26jHjD+vSsf0s140Iqa7y2zz50uz77AJgrgtojjrn2/R9f7ALw4SrsYeb7St2DMLQaOvqMGro/buh6Q3sx5OGprYK8xQARa6uC0lZAAAAJ5FJ2dXrtpw4a96yb7pmWhR3avfW6dMOOfTQ0UO/mJ+f1+AOOJAq3bt0fPn04w4ZP3H0sC/k5uWGdt491K6kdM9+z782z4549oIeoMmWufpDPM/rpKpP0AqNEa5GOPXQuKn36M8sSPtZTi3Qz9V1aUxScpur69LQY2SN7/sDXFiXza4GAABIvMQlZUt27+3/zIy5f3HNlMv1csrGjxr89TOmTRjftbj9G64byCh9ga4aOazfTWcff+ioXt2Ln3XdiIgVazad/vaCFde6JtAk2v6XurAuR7g6FHzfP8yFCKfhrg6TIa4Oo6GurpW2zxUurM9yV9cljEe8v6veddPI1w8AAJAIiUrKVvt+3tMvzbmnvKIiLfPX2YW8zjzh0IMOPmDg9TbPp+sGsqZ928JlJ00ZO3XS2OFXctRstLz29pIfbdyyY5JrAk3xqqtr5fv+cS4Mg3yVyUGIOmT7KNWxrg4Nz/NsPy6M017YNA8NJbEb+tHELHF1rfT6e6vqFbRCZ5yr67LY1QAAAImXqKTszDlLv7dpa+qTHJ6XUz7+oMFfO/nocZM7ti9a6LqBsPBHDOl76zknTBzZp0fxE64PoefnPjNjzl/LKyrtdHOgKV5xdV3OVLFkaBgc43leoudQ9hu+8FNWl4+eX6iOrH6fw10dJodrPDc09UxjkpKLtNwbuthXGF//MJcwr888VwMAACReYpKyazdumzpr3rKvumbKFHcomnv6tPGHHrz/wB9rR7TKdQOh066ozYoTJo89ftLY4Z+3aTZcN0KspHTvwBden/871wQaa4vv+2+7+ENcEvS8oJVdep6XuzCxtD4auqhTNucPteT9sUEYLho7Z7gwNPScTnNhrXS7XfD1taBVL/uMrncKLP2r010YJqe6ui47VOYGIQAAABKRlC0rr+jy3Iy5d+mLT0ovnGNzdp4+7dDxXTpxpXtEhh01e8vpx00Y17lT2zqTNgiPZas2nvvO0rWfdE2gUfRx908X1sr3/S+pyvbF5Iap1JvESgKti70urJVuP8CF2XCyxlJYr/R/okqHIAyF1ipnB2Gd7CjRhpLw73re1bXSerEEaJugFQ4aq+e7sFa6/WVVDR0ZDgAAkBiJSMq+9MY7t+7eW5ayubcKWudtm3bEwafVXN0+N6feL1NAGBV3bDv3tGMmHGrTGrguhNjLsxbetLNkT5gv7ILwuc/VtfI8b4yqC4NWdvi+/xM9j2wnhsNgu6vrkrW5pbWOPuXC0NHQKVR1WdAKhQv0nLq6uC5Pu7pB+l+PubAuNn9tVrfhfRyi53yIi2ul2x9xIQAAACT2Sdllqzact3TVhnp/uW+K7l06zjjjuENH9+/d9d+uC4gk+0HBLgA29bBR5+bl5+103QihqsqqttNfnXOn7/u5rgtoyByNl5dcXCvdfqOqtFz4shFO9TwvjKdfZ8NKV9fFkrKdgzCjxmgdneTiUNIY/oKqMBwtmqfncq2L66TlWe8R7Pt4Vv9znYtrpdu/rCoUnwt6Lv/nwlrpdjtCtt4fiwAAAJIm1knZPXvLe774+ju/ds0WGzW8/89OPnrcUe2K2jT0BQqIjEF9u9935rQJ44o7tJvtuhBCGzbvPOztBSvq/dILvJ/neb9yYa10ey/f9/9gYdCTMb31uH90MVq1WubqWmk92b5axo+I1Dr6kQtDS8umv6qrg1ZWXabnMtLFtdLy3KhqetBqFEti/iMIa6fHtKktPhG0suowPZdzXFwXO0q43iQzAABA0sQ6Kfv8a/P+WFZR0eKjS/Jycnfb0YQTDh765Zwcr6Gr4QKR06Fd4eLTpo2fOKR/z7tcF0Jo5uwl39uyfddo1wQacp/v+wtcXCvP887IcPKtnR7vYT1uN9dOPC2LN11YJy2zq1TlBa2M+Iie1wkuDjUtm2+psvmJs6WvnsMNLq6Tluftqpp0QVj9za/0v+3iYHXSzbb9pmyKrmYo0HNo8AAIvZabXQgAAAAntknZhcvWfmLVui0tPu2ufVHhslOPHT/JjiZ0XUAs5eXm7p48ceTHJo4Zdo2+PHEhjhDSSsl74dX5f6j2/UwmZxBdldqWv+LiOuk+X1V1XdBKq46+7z+ux+OHhQ961dV10jIbqurTQSvthqj8JgjDT8umrcbV3QptjtlMy9dj/0XPoZNr10r3sWTsbUGrSZaoPBCEtdNjd9H/v0NhVqYx0GPfoOdwkGvWSvexH4ceDloAAAB4VyyTsiW79/Z/eeY7v3DNZuvdvfjp0487ZHznTu24Sj0SY+TQfjefcNTo4+2Cdq4LIbJ5+65xby9Y0WCiDXAe8n2/MRfX+Y7uZ1MKpCuxtb/+/4ue5x3m2u9p5POLs1laBhtcXCfd5yeq0n3Bv256nH+ptotIRYbG1Xg97zsVZnK/1tNj/laPPcW162NJ42ZNfaX/f50ep94jbHWf43SfbByJerkeu8HpI3QfO5q53iN+AQAAkiiWSdkX33jntsqq6vau2Sx2VfoTJo85rqB1/lbXBSRG7x6dnzzt2EMO7di+aKHrQojMnLPs29t3lo5wTaBenud9wvf9Bj/LdL/LdL/XFR4e9KSEHb13pf1f/f8Pzbmp/j2NSerEnJ2Z0ODFQ7Wc7IhQS2Cna+qH/vr/T+txPvDeoj6zxzVDS8/7HD3PvyjMD3rSKkePdZse81LXrpPut1f3+6ZrNscclcZMD/A5PZZdvC9Tc0Tb+8WtLq6T7mNzyXK2GQAAQC1il5RdtnrjOavXbT7ZNZtMO7XVh44e+iW7Kr3iJs39BcRJh3ZFi049Zvyknl2Ln3NdCAnfr249/dX5f9CX3dhOQYOUWq/Ps49pvDQ4LYnuZwm5F3Tfe1SPqelsHhubH9H/man6V/q/bWt696F+O+p7cdBKLi0Hm2+0QbrfMC1Tu1jUwKAnZabq/76q/3+ga7/fP1XsIlWhoec6w4UfoOd/oW57VGH3oCctOukx/qnHuty1G2KJ0lVB2Dx6rG/pMVe7Zp10vy/rfnbEcK3bW4rYDy023ckf9Xj1fgbpudiPLle6JgAAAPYRqy/0FRWVHWbMXPhL12yy3Bxvz9RJB5574LD+P3ddQKLZkeInThl93JCBvexLHkJk09Ydk95ZuvZTrgk05BHP865xcYN03/NVzfR93+Y7/aKKzQPb0D5Dkcqx+pufugTS3/R/6pxrUvexK8vfErQS7yUtD0tgN0jLdH9Vs1QuUWnpflxvPa4lhJ/S/+0RdP2PbqtS/3dcM0xe0XOzeVQ/RM/3GN1my+esoCelbJqAmXqM01y7XvY8dN/vu2ZLbNf/uUD/rzE/rFyk+9l2e2jQk1KD9b+fUN2oMaHnYkfBzw9aAAAA2FeskrKvz17yo917y5p1Bdo2BXmbTz56/NED+3av94IKQNLk5OSUT54w4pKD9h/Q4NWlkVmvvrXox3v2ln8okQLU4VcqXwvCxvE87xBVP1N50/f97SpvqNjn5B2qf69yp8ojKgtUdqj/Cf3Nl1Tq/SzWfV/SfezUb+aZdLQ8mnKKu835eruWoyVyL1axhHhj2entk/S3tv6W6HEtuVsXO23eTp8PHT3vL+j5r3HND3Dj737dbgnEyTWdLWNz1tpcu3ahukFBV/10/xLd9yKFFUFPi72g/9eo7Vf3G6HHf1mhJa6H1XS2TE/9vxtU5up/H+366qX72o+5vw9aAAAAqI1dpMCF0bZp684J/3ri1RnaWWzyXFptC1uvPnHKuGOYPxOo39xFq656eeY7NzVnO0N6DO7X429TJh14oWsCjfF5ffbbdpyVH2b12JZcOkWhJXHf1dDOiCXClgdhi1iSypKYdfmuip2anRVaNnZE84mu2Wj6u72qbD5YO63fjky00+VLVCwhWKxip/PbxdZsSoqpul+DP+bovkt1v4MVlihernhAcEutzlR5MAhbTo9n47POuYZ1+8263Y78tuTyc4rrnUdW97EjVv+q0ObuXVDT2TCbIuIk/e1F+ttJQVfj6G+q9Td2NO3DQU/quNd+lWs2SPe3bcvGlV1szOYkfv92V582KjathX2+nK2/t3aj6G8seW2vvzzoAQAAQG1ikZSt9v28B5949fVt20vsy0OTWCL2xCljj2lbWNDgXF0AWrVasmL9R6e/MveO6lat8lwXsuykKWOn9upe/IxrAo1xtD7/7/E8L51zb36IHvNuPeYnFVoS8f1Iygb6aBnN0TLq5NpZoedgc4FaIvIt1w5rUtZ8TKXRU+zobzeosukNFul/2Fy5u6xf7EJqXVUPUTlIt/Wv6W0em2/2t0GYcrbv/gc9v8tcu9H0dzb9ga3TN/X3NpfzOhVL3ts1FOzo6y66T83rVxmv+7RW3ST6e5sKwxKyu4MeAAAA1CUWSVk7em/Gmwtvds1G61LcbuYJR405oU1B602uC0AjrFy7+bSnXn7779VVfqOPnEH6FHcomnvG8RNH53hepesCGqOH9gF+5nneR107nezoPJub9k81rQ8jKfs/07Re7MjGrPzwpceu1GPbfKx2VGkN9YU5KWs+q3JbEGaPnpcdIWvj666gJ21s//06Pda3XTsU9Jz+ruf0cYUcIQsAANAIkZ9Ttqy8ovObc5c2+QtUt+L2r540ZdxUErJA0/Xv3fWh448cc7JdHM91IYu27dw9cv7i1Z9zTaCxNnjBnJc2R+RzNT0p5vt+lcofFNrFqepKyLZ3dX1KXZ0ENi/vJZbgc+2M0WPu1WOfq/C9hGxE2Ny3F+r5lwXNzNNjb9Gys6kn0p2QNb4eyy62ZRfka+x0BGmj127TZHxFz+kC1SRkAQAAGinySdmZc5ddV1ZeafOlNZolZE+YMva41vl5Wd+RBaKqd/fip487aswpJGbD4fU5S7+3p6w8o6eiIzaeVZmicoQfXLjLTmduEf2PjSp2FO4QlU+pa31wS60KXV2fpL3P2DQPZ2kZZiwZrcdarce0cZCyI14z7G96/jaG7bT8jNJjTtdjj1X436AnY/6hcrAe/+mgmXl6bJtu4zCFP7FmTScAAAAaJdJJ2R27dg+ft2j1Fa7ZKCRkgdSxxOwJk8eeQGI2+yorKjvMnLPke64JNMeLnuddrGLJ/VN93/+ZymsqDSZpdZ+dKtNVfqzm0fofvVW+rLgxUw50cXV9WpwojqB/aRnaVf/fdO10+rMey+blfyVoRtbreh2jtcxs7NrRm2mlx7CzrS7VY1oye2VNZ+at0OMfo/psPZ9lQVf66bG2qLpSj20Xj3u9phMAAABNEumk7CuzFv5cu4W5rtkgErJA6vXs1mk6R8yGw4Il6z65bUfpSNcEmsu25f94nvdllQkqNr1AL5VDVGyqg9NVbA7RY1XGqfTUfTqqTFb5mtp25K1dOKix9nN1rXzfr+8o27hboGVqy/2KdCwH/c/HVE1QuURlq/XFQKmWmY3dEXp9d6ikPDmr/2kXyPqSHsPGrs1THIYjRB/Q8xmm+kKVN2p60kCv3RK/n9dj2RzDt6owlzkAAEAzRTYpu3r9luNXrdtykms2iIQskD5MZRAWfu6rby+80TWAVLKEoB0NZwnXh1TsFPenVGaq2NXsW2KEq+uy1NVJZQnuX7sk2KW+7z+t0uz5Zi2ppmKnmo/Q/7Q5UF+ruSF+Fuv12VGs/RX/n0qLEpVaZiUq9yg8xa2Ln6uE7QhuS5D+TWW8ykF6vj9QWWg3tIT+x2qVWxQepdc+RLXFSZrnGQAAIC3s6q0ujI5q38974LEZb+3YtbuhL3I1OnVsN+eUo8dOKWidb6daAUiTlWs3n/bUC2/dX92qVVauGo7AiZPHTOvdo/OTrgmEmvZD/ul53hmu+SG6/U7dble0T4Wr9P+muvhD9DiWdLMSdt1UJuu1TFRt+0IDVexo5kK9hgL128WWdqrY6fV2Wv076rcE+ksqi1SaRP/vd6rqnLNa//t6VSmb+kCPd5P+59Wu+SG6/Wbdfo1rNkUPFVtulrQ8QMWOdLVl2Un/L1/9Fap3q7ajhlepWGJ3rurpKjaNRFOOAA8Te92H63WN0+sZqng/xT0Ut1fdXrUdpLFD8W7VNmbsh5Cl6n93zGRsWgQAAIAkiWRSdtHydZdMf3Xe7a5Zr3ZtC5eeMnXc5LaFBatdF4A0Wrxi/UXPvTL3L66JLOhS3G7mGdMOtaQDF11B2FkCcaPneR1cuzZXqthp0kgIjYl0JWUBAACA0Ijc9AXV1dWtZ85d+h3XrFebgvz1J04eczwJWSBzhgzoedfEMcPq/DKN9NuyrWTsstUbz3ZNIMyObyAha150NQAAAADERuSSsguXrbuspHSvnaZXr7zcnF0nTB5zYod2hYtdF4AMGTm03y8P2r+/zVmILHn97cU/sKleXBMIJd/3P+fCWul2O5V6dtACAAAAgPiIVFK2qqq6cOa8Zd9yzXp4VcccftC5XTq1n+U6AGTYIQcN/ergAT3vdk1k2M6SPcOXrFh/kWsCYWTzWx7n4ro8oBLVeTwBAAAAoE6RSsouWLLmM3v2lPV2zTodMX74Z/v27PK4awLIDv+oQw64rEe3TnaBFGTBrHlLv8nRsggpm9PeruBeLy+48BYAAAAAxE5kkrIVlVXt3py3/OuuWaeD9x/44+H79fm9awLIopycnPJphx90Zsf2RQtdFzJoZ8newRwti/fJVckPwqz7kud5E11cK9/3bdqC54IWAAAAAMRLZJKy8xavurKsvLyba9ZqYN/u948/aHCDiVsAmVPQOn/rtCMOPrWgdd4214UM4mhZvM/lvu8/q7rBM07S7Fg9jx+7uE6e592gyg9aAAAAABAvkUjK2lyycxeuvMY1a9WpY7s5R00YcYlCvsABIWNHyh49adT5nudVuy5kCEfLwunu+/4PtA0epvpNtU8OujNukh7/QT0PO2q3TrrPXFV/D1oAAAAAED+RSMouWr7u4j17K3q45ofYEXjHHXHQ6fl5uSWuC0DI9OnR+YkJBw+51jWRQbPmLfuq7/uRmkMcqaX1/2PP8zpZrLq7qv+o3KHS2foy5Hw9j6f0+G1du066z2dVVQYtAAAAAIif0H9Jt0TC7HeWf9k1P0Rf3KqnThp1Xvu2hUtdF4CQOnBY/58PHtDzbtdEhuws2TN8xZpNZ7gmkmeSPisvdfH7Xaxin532GVtgHWnSQZ/lNtf7PXoehUFX3XTf36h6PmgBAAAAQDyFPim7fPXGc+z0W9f8kEMOGvzV3j06P+maAELuiHH7f8amG3FNZMjb85d/xYVIllzf929zcW06qtyo+6xQ/U2Veudub6IilWv0v5d4nvfJoKt+uu9M3bfe6YoAAAAAIA5Cn5R9a0HdiYT+vbv+Z9TwAT91TQARkJeXWzrt8FFn5eXn7XRdyIBN23ZNWLdx2xTXRHJc7nneaBfXSfexKYK+7/v+WpXHFNtRtH3ttiayuWKn6H/8UvValV/of3e1Gxqiv1mj+56tsCzoAQAAAID4CnVSdu2Grcdu2VYy1jU/oKiozaqjJoywL41c2AuImA7tihYdNf6ARh05h9SZs3Dll1yI5Fjl+/4WFzfI87w8leMV2nyz9rfLVe5T+aHan1CxaTCOVjlMxZL8p6tcodt/qvKUyja1n9H/+LxqOwq3UfR3m/U39v+WBz0AAAAAEG+evgi5MHwee27mf9ds2DbNNd+T06pV5cnHjD+qe5eOL7suABH04hvzf7NgydrPuCbSTO/3/nknHzbckuKuC8nQS6v+T57nneDaoaLn9o6e2ykKFwc9SDqNiZs0Jq52zQ/R7Tfrdqa5AAAAQKSF9kjZHbt2D6stIWvGHzzk6yRkgeibOHr4NcwvmzmezF246irXRHKs06o/UfUFvu/blAKhoefzqJ7bJIUkZAEAAAAkSmiTsvMXr77ChR/Qs3unZ5hHFoiH3NycvVMnjrww18thDskMeWf5ukvLKyobfVo5YuUez/P2933/xyqlri8r9Pi7VH1az+dk1TblAQAAAAAkSiiTspWVVW0XLVt3iWu+p3Ve3o4pE0YyjywQI8Ud280+5OAhX3VNpFlV8P56qWsieXZ5nvc1lYGKb/B9vyTozgw9XoXKbXr84Wr+3rpqbgAAAACAhAllUnbJyvUXlld++Eiuw8YN/1zbojarXBNATIwc1u/m3j06P+maSLMFS9bYPL5e0EJCbVb5qud5vVV/1vf9WTW9aaL/v0Xlp3q8/VU+p651wS0AAAAAkEyhTMrOXbzavrB9wKC+Pf4xeEDPu10TQLz4R44/4FO5eblZPaU6KbbvKt1/3cZtk10TyWbTCPzG87wxqu3o1a/4vv+iSrnd2BL6H5tU7lB4lv5/H5VrFS+tuREAAAAAEs7TFyYXhsPGLTsm/fup119yzRqFBa03nn3ixBEFrfO3uC4AMTRv8erPvTzznVtcE2lkP3RNPezA810T2FeByliVQ7SfMFT1fiqDVNp7ntdedUf1lyneq3qn2utVVqgsV9+bql9TsYt3MT0BmuNajauPuvhDNMbsR/obgxYAAAAQTaFLyj43Y+5fFq9cf5Fr1jh60oEf2a9fj7+7JoD48v7z1BvTN2zZfoRrI01yclpVXHDqkX3aFLTe5LoAAAAAAECGhGr6goqKyg7LVm842zVr9O/d9d8kZIHE8I869IDLcnO8Pa6NNKmubpW/eMUHfwADAAAAAACZEaqk7LLVG8+pqvYLXbNVXm7OrsPG7X+FawJIgA7tihaNGzXk266JNFq4dN2lLgQAAAAAABkUqqTsomXrP+7CGhMOHvrVtoUFq10TQEIcOKzfL7p0bJ/Wq8GjVattO0tGbd66c7xrAgAAAACADAlNUrakdO/A9Zv/dzXwrp3av7H/4D6/cU0ACeJ5XtWkccM/55pIo0XL113iQgAAAAAAkCGhScouXrHuA3MbTho3/ErP86pdE0DC9Oja8aXBA3r+xTWRJktWbjyvutrPd00AAAAAAJABoUnKLlr+v6kLhg3qdXv3Lh1nuCaAhDr04KHX2tzSrok0KCsv77Z249ZjXBMAAAAAAGRAKJKyG7fsmLSzZPdQi1vn5e0Yf9CQr9bcACDRCtu03jBu1ODrXBNpsmT5+o+6EAAAAAAAZEAokrJLV204z4Wtxhw46LuFBa03uiaAhBsxtN8vO3VoO981kQbL1m46s6qqutA1AQAAAABAmoUiKbts9aazrW5fVLhsxJC+t9Z0AoDkeF7loQcP/ZJrIg2qKqvarlq3+STXBAAAAAAAaZb1pOzmbbvG7d69t5/F4w4a/I2cnJzymhsAwOnbq8ujPbsWP+eaSIPlqzed5UIAAAAAAJBmWU/KLl+9seYo2a6d2r8xuH+Pe2o6AWAfhxw8+GsuRBqsWLf5lKrq6gLXBAAAAAAAaZT1pOyyVRtqjs6aMHrol1X5FgPAvrp36fjygD7d/uWaSLHKisoOa9ZvPc41AQAAAABAGmU1Kbt9Z+mInSV7hvft2eXxXt2Ln3XdAFCr8aMGf93zvGrXRIqtWLPxdBcCAAAAAIA0ympSdpmbumDMyEHX1XQAQD06dWg7b8iAnne6JlJs5drNJ6vyghYAAAAAAEiXrCZlV6zdfJodJdu9S8cZrgsA6jV25H7fbdXKq3JNpNDesoqem7buHO+aAAAAAAAgTbKWlNWX/66bt+wYx1GyAJqiXds2ywcP6PFX10SKrVpXc7QsAAAAAABIo6wlZddu2Hpsv15d/8tRsgCaavQBA3/si2sihVau3XSqCwEAAAAAQJpkLSm7ev2W4w8+YMD1rgkAjWZzyw7s2/0h10QKbd66a4ydyeCaAAAAAAAgDbKWlC2vqCzu2a34OdcEgCY5+ICBP3IhUsgTO5PBNQEAAAAAQBpkJSm7bUfJqMH9mRMSQPN169zh1d49Oj/pmkih1eu3TnMhAAAAAABIg6wkZXeW7Bk8oG/3B1wTAJrloP0H/MSFSKE1G0nKAgAAAACQTl42rpVjSdkO7QqXuCYANJd3/6Mz5m3fVbq/ayNFzj3psKF6n17smgAAAAAAxElrlW4qvVU6qLR3pa1KGxVToFIYhK2qVXYGYY1921Uqu4KwRoVKaRC2etbVH5CVpCwApMrcRauumvHmwptdEylyxPgDPjV8v95/cE0gW2ynqFilnYrtNBnryw3CxHl3x+799XYXI17sx8aeQQi8t70b+/JXorJN5d0+xEOeyhFBGCmrVfghP1rs8yWKB7XMUrH9HqApOquMURnq+/5Q1UNc6eV5nn3PyBTP1R9AUhZApFVUVHb420PPr6moqrakDVJk6IBefz7q0BGXuCaQLn1URqiM1P6I7Rz1U+nv+jtrRympydcm0bLbo2qNykYtszVqL1E9X+25Ku+oWAIH0XKHysVBCNRO27olazeorFRZpbJC2/4C1bbtW71XBdHRScWS7ZGicXizxt01rolosH3824MwUo5WqfVoQ8CxH7cmqRyu96Zxqsfp/WmQ3RACJGUBxNNLb7xz2/wlqz/rmkiBtkUFKz5yyhEDXRNIBTsN6EiVidr3OFT1odpJyuSv04ml5W1HML2k5f2i6hdULGHLDmC4kZRFi2i7t1Mq56m8rG3/VdXTVRaqILxIyiJTSMoiTuzAjuP1XnSc6qP1fmRn1YVRrUnZrFzoCwBS6YAhfW91IVKkdHfZgJLde+2IRaAlDlT5unaSnlGxL5qPqnxHO0snqJCQzRAt6yEqH1f4W5W5WhebVf6i+FwVmz8LQMxom89ROVDlU2r+XuUdbfcrVP6o+CyVIhUAAKJoP5Vv6TNttupFKrfo8+40lbAmZOtEUhZA5BV3bDu3V/difjVNsU1bdkx0IdAU+2sH6fsqduqs7Sj9UDtIU1Tya25F1mld2NQQFyn8h9aTJWj/q9iOyrSjmQHElLb7/iqXKbxf2/0WlfsVn69iFzEBACDM7MJbF+uzy878WKLyPX2m2QEgkUZSFkAsDB3Yy071RApt3LLTTjEHGsOSeZ/UTtLLqudrB+mbKsNrbkGoaT3lq0xTeIfW33oVO4ouiheaAdAE2u7bqNgRs/dou1+n8ivFB9fcCABAePTRZ9QNKnb9hDv02WXTocUGSVkAsTCwb/f7c/NyuQJ5Cm3YvMMmSQfqYztJ16vYBWZ+r50kjq6OMK2/dip2FN3zWqd2heOPqtgFEwDEmLb7YpUrFc7Stv+06lNU+J4IAMimIfpM+pPKMn1G/Z9KZ9cfK3zYAoiF/LzckkG9u/3TNZECW3bsHFNd7XPKOWrTXztIv3c7SV+1L/SuHzGhdWpHzN2ldWynh12twvyTQAJo27cL6fxb2/4c1R9R4fsiACCTBqjYGVwL9Jl0qUqsv4/yIQsgNoYM6nWnC5EC1VV+m207Ska5JmB6agfpNyqLtYP0ybjvJKEmQWMX/LvJ1rlqu2AQR84CCaBt/wBVf3PJWZvmAACAdOqo8mNLxqq+WJ9DuTW9MUdSFkBs9O5e/FRhYcFa10QKbNm+a4wLkWw2sf7XtJO0SDtInyEZmzxa571U/U5jwC7edlpNJ4DYc8lZuyCYXVB1tPUBAJBCnsrHtI+5UPVX9Llj3zsSg6QsgNjQG3j10AE97nJNpMCWbSRl0eo47STNVf0jbWPtgi4klcbA/qr+pTHxX9X71XQCSILJ2u7fULlVcYegCwCAFhmq8ozKndrH7F7TkzAkZQHEyuD+vf7qQqTAlu07ScomVxd9+f6z6se1k0TyDR+gMTFN48NOa/6qClMaAAmg7T5H5Qpt+/ZD3alBLwAATWZTE3xZnydvqZ5c05NQJGUBxErnTu3eal9UuMw10UKbt5faxX7slBIky/GWcNOX74+7NvAhGh+Fqq7XWHlD9UE1nQBiT9t+X1UPadu/XTVnUAAAmsIuGGxT4tzo9iUTjaQsgNgZ0LfbP12IFqqqrGpbUrrXroCJZCjQTtIvVD+mnaSeQRdQP42VgzRuXlV4pTVrOgHEnrb9S7Ttz1I4IegBAKBe5+hz4y19fhzh2olHUhZA7Azo0+1BFyIFtu0sGelCxNsA7SS9oJ2ka1wbaDSNmwJVv9IYekh115pOALGnbX+wfXYo/HzQAwDAh+Trs+Jm1ffqc6NT0AVDUhZA7PTo2vGlgtatN7kmWmj7ztIRLkR8Ha0dpde1kzTetYFm0Rg6RWPpTYWHBD0A4k7bfb6qX6rcoZL4U1EBAB/QS/uGz+mz4irXxvuQlAUQO3rDrxrQp4sdrYUU2La9lCNl4+2z2lF6UtsNRzciJTSW+mpMPa/woqAHQEJcrG1/uuoeQRMAkHBj9bnwmvYNJ7k29kFSFkAsDejTnSkMUmR7Sen+LkS8eNpJ+onq27SjxP4AUkpjyqYz+IvKdda0PgDxp21/vD5bZihk3wEAku0sfR7Y1Gh9XBu14EsYgFjq3aP4ac/LKXdNtMDOnXuGuhDx0Vo7SXdrJ+la1wbS5Tsaa39QnRs0AcSdPlsGart/WeHEoAcAkDCf0+eAzR/LlDYNICkLIJbycnN39+jS0b4QoIXKKio6l5VXFrsmos8SsvdpJ+kC1wbSSmPtMhtzClsHPQDiTtt9J233TyucGvQAABLAzsT7oepb9DlAvrERWEgAYqtPz+InXYgW2lWye7ALEW1F2lF6VDtJp7o2kBEac2eQmAWSRdt9obb7/yjkMwcA4s8SsjYt2tddG41AUhZAbPXu0fkpF6KFdpbsGeJCRJcdIftv7Shx1BKywn4MIDELJItLzN6v8NigBwAQQ7l6r79L7/mXuzYaiaQsgNjq2rnDa3n5eTtdEy2wa/eegS5ENL07ZQEJWWSVS8zeYWHQAyDutN3na7t/SOHkoAcAECOWkL1T7/UXujaagKQsgNjK8bzK3t06PeuaaIHS0rL+LkT02KlEt1syzLWBrNJYvEBj8heuCSABtN3bEbOWmB0b9AAAYoCEbAuRlAUQa717dLaLTKCFSvfs7edCRM/17CghbDQmr1b1+aAFIAm03XfQl/eHFfJDLwBEnx348Vu+Z7QMSVkAsda9S8eXXIgW2LWbpGxE2bxOXwlCIFzc0bJHBy0ASaAv7z217T+qsGPQAwCIIr2X/0Tv6Z9wTTQTSVkAsdalU/tZuV5OmWuimUpLy/q6ENFxtHaWbnExEDrakbdT3uzCX4OCHgBJoG1/hLb9exTyXRQAounzei//sovRAnwQAoi1nByvokvn9m+6JpqpvKKiS3V1NVdMj45+9oXXkl6uDYSSxmhnjdV/KSwMegAkgbb9E7Ttf9c1AQDRcbLev29yMVqIpCyA2OvWucOrLkQL7C2r6OpChFuBdpQe0Bfe7q4NhJrG6iiN2Z+5JoCE0Lb/TVWnBS0AQASM1D6bHfhBLjFFWJAAYq9blw6vuBAtsHtveS8XIsS0o/RD7SiNd00gEjRmP6vq5KAFICn0mXW7qj5BCwAQYu31nn2f9tnauTZSgKQsgNjr1rkjR8qmwN6y8m4uRHhN047Sl1wMRIpLzvQIWgCSQJ9ZNoXJXxTyvRQAwu2Pes/e38VIET78AMReh3aFiwvy87e6Jpppb1kFSdlwK9YX2z+7GIgc7eh30xj+rWsCSAht+0er4gdFAAivy1TODUKkEklZAIlQ3LHdbBeimcrKK4pdiBDyff9n+mLLFBOINI3h01WdEbQAJIU+w+yiX0OCFgAgRAbpPZoLe6UJSVkAidCpQ9F8F6KZyssrScqG1zGe513qYiDStOP/S1XMVwYkiD7DCrXt/87CoAcAEAKe3pvv0Ht0e9dGipGUBZAInTq2JSnbQmUVFZ1ciHBprZ0lTvlGbGjHv5/GtB01ByBBtO3bNAYXBS0AQAhcrPfmo1yMNCApCyARiju2m+NCNFN5eSVJ2XC6WjtLg10MxMXVKsODEEBS+L7/Y1UcKQ8A2WcXYvyJi5EmJGUBJEJxh7bzXIhm4kjZUOqunaVvuhiIDc/zcjW2f+SaABJC235vbftfc00AQJbovfh7ek/mQs9pRlIWQCIUtmm9vqB13jbXRDP41X5rFyIktLP0de0sdXBNIFY0ts9SNSFoAUiQL6pw4UoAyB47C+/TQYh0IikLIDE6cbRsi1RUVLd1IcKhv8oVQQjEk+/7N7gQQEJ4ntdG2/5XXBMAkGHuKNl810QakZQFkBjtigpXuBDNUFFdRVI2RNxRsuwsIdY0xqeosgIgWT6j0icIAQAZNFLlgiBEupGUBZAY7YrarHQhmqG6upoEYHj0VLksCIF4833/WhcCSAh3tOyXXBMAkDnX6j3YczHSjKQsgMRo17YNR8q2QEVFVXsXIsv0RfVKjpJFUmisn6TKjtoAkCyfVGHedADInD76nnGhi5EBJGUBJEbbooJVLkQz+H51rguRXYUqlwchkAwcMQckj+d59mOwJWYBABmg/a2rOPAjs0jKAkgMpi9ATJyrnaUuLgaS4qMqXYMQQFL4vv9ZVZxGCwDpZ8nYS4MQmUJSFkBitCUpixjQF9RPuBBIDM/zWqvidDogYbTtD1F1ZNACAKTRqXrP7eZiZIinL3cuBID4e3T6m49XV/oFrokmKCpsvf7oSQd+xDWRHfbldFEQAsmifdY39WVhrGvG3R0qFwchkGza9u/Qtp+Eo7c6qWwLwujQ+rlZ6+ca10Q0XKJyexBGytEqzwYhUk3b8sPalm0ef6RHrWd9kJQFACA6vqXyvSCMP+2jbFE1V2WxymrtKJaqLldJskItF5tncZDK/iojtVySNPfXGJVZQRhrUU3KfsHVSL0Obtu3H+eGqhygbT8RZz3qdZfqtdrRW3uCntgiKYtMISmLfXXTtrw+KZ8rWUJSFgCAKNNn9mztLB3omrGk1/i6XuNfFT6hYglZdlTqV6RypJbbKao/omUX63lX9Tp/rteYhIt+RTUpy9yfmdNRxbb9s1Wfre3CErZxdprKv4MwtkjKIlNIymJfNj3aH4IQaUJSFgCACBuusiAI40X7IlWq7tOXuh+qnl3TieawI2ZP1/L8upalHVEaO3pti/Xa7CjBuCMpi6YoVLnYbfv9gq540Wu7S6/tY64ZVyRlkSkkZfEB2o6ZusDRsrAk6XKVpVZruaxQvUnFzuDbrGJnbexVqUtbFdsntx9Lc1Xsvd3qP6p8CElZAACi4csqNwZhfGg/5AXt7HxG4bygBylyspatfVEe7NpxMlIl7uOFpCyawy6Id422/eu07VuiNjb0mrbpNdkUBvYjXlyRlEWmkJTF+9n0OJu0HdtnSOLota9R9axe/wuq31J5W8WmTMuIFiVl9bc3uRBNpBW+VtVPghYAAPXTZ+5/9dkxzTUjT6+nXK/niwpvs2ZNJ1KtjZbzN1Xb0XNxSpZ9VeWGIIwtkrJoiUHa9u/RZj/BtePiUJVXgzCWSMoiU0jK4v1OV3kwCJNB71sz9b51r8IHVBbWdGZJS4+U5UtUM2m5b9Qg6OGaAADUx5JrdpRQG9eONL2WtXotZyqM85frMDley/yvWuadXTvS9Fpe1Gs5wjXjiqQsWqq1tpVfaluxMxHiwi52+YMgjCWSssgUkrJ4j7bhm7QNX+2asaXXuVPVHXqtt6rOaiL2/biyWpZoIHRXVRC0AACo12H63IhLQnaJXosl1EjIZs7jWuZTtOzXuXbU2dF/sTo1G0gDOxvhctXfDZrRp/ewY1wIAEidqa6OJX12bFX1JX0m9lGx5HNoErKGpGx29Xc1AAD1mejqSNNO0TJLDipcFvQgg2Zr2U/WOrCLFESaXoddPOGQoAWgAdep2BGmcWDbvV0sBQCQGt20XzXKxbGifd5ylZ/o9dn1FX6uUlJzQ8iQlM0ukrIAgAZphyLySVm9hs3aKTpB4eqgB1mwSOvgDNtJde0oO9zVABr2A233Nn93pOn9y65obRf6AwCkxiRXx4o+817XZ8ZYla+ouT3oDacWJWX1Qve6EM3Tz9UAANQn0hdr0f5CtXaKzlEYqtOFEuoFrYtrXRxZGlNHuhBAI2i7v0rbzTOuGWV2sS8AQAroc2G8C2NDr8nmyLUf7+cGPeHWoqSsXmiZC9E8HCkLAGiInVYU6QtD6vl/X9VzQQsh8CvtsD7q4qg62NUAGqdK78UXadvf5NqRpOcfy9NsASBLxrk68vT5UK3qU/qs+4LqyJwV1tIjZXe4EM2g5TfAhQAA1CXSp2rqs+5tVXG+WnYU+dph/azWzR7Xjhw9/96q7ErlABpvrfuyGmVMXwAAqTPG1ZGmfdpKfb6dq/APQU90tHRO2TjMSZZN+7saAIC6RPoLqHaQPqeqMmghRFZo3Vzv4qgiOQM03V/15XW6i6OI708AkBpdtS/Yy8WRptdxmaoHgla0tDQpW+pqNIMGDl8mAAD10pfn/VwYOXruj6t6IWghhH6hdbTFxVE03NUAGs+OlP+GiyNHz92Oki8MWgCAFojLj1x2Ma+/BGH0tDQpW+JqNE9HlT5BCABArSI7/7i+PP/IhQinEq2jn7s4cnzfJykLNM8L2n6ed3EUMQUcALTcUFdH2b0qNwZhNLU0Kbvd1Wg+TsEBANSnn6sjRV/4F6qK8imySfEnrauoTi/BD9tAM3meF7l5994nkp+LABAm2v8b4sJI0vNfpeqTFtZ0RBRJ2exjCgMAQH0i+eVTX/jvdiHCbb3Kw0EYOd1dDaDpHtAX2r0ujhp+kAGAlhvm6kjSd41Pq9oZtKKrpUnZba5GM2lnaIQLAQCoTbGro+YRVyPktFP7kAujhsQM0Hw2DV1Uz2bo4moAQPNFdoo03/f/o+qxoBVtHCmbfRwpCwCoSxvP8yJ3QRPtKNmv1m8GLUTAE66OGo6UBVpAny+RnFdWnzFR/bESAMKkl6sjR59f33Zh5LUoKasFsdmFaL6xKrlBCADAB0T1i+fbKlVBiAhY5fv+BhdHSSdXA2ieqP541tnVAIDm6+HqSNE+69OqYnPwR0uPlI3iDnyoeJ5XpOrAoAUAwAcUuDpqFrsaEaH9kQUujAw95zwXAmgeuyBj5LjvTwCA5uuq99LWLo4UPe/fuTAWWpqU3ehqtMyhrgYA4P0iN3WBY1dDRYT4vr/ChVHT1tUAmm61qwEAyRLJKaC0v1quyuaTjY2WJmXtir1oIQ2sCS4EAOD9InmkrOd5u12I6Njh6qjJdzWAptvj6kjRd6eOLgQANE83V0fNiyqlQRgPHCkbDhNdDQBAHOx1NaJjl6ujpp2rATRPFH+Q8VwNAGieqO4/zXB1bLQ0KbvZ9/0yF6P5DlBpH4QAAACZ5XlehQujhnllAQAAmiaS0z9pfzVy10BoSEuTsiaqc5CFhgaWrYdDghYAAAAAAACQFlE9UjZ2+cdUJGWZID4FfN+f6kIAAAAAAAAgHTq4Omqieg2EOqUiKbvS1WiZY10NAAAAAAAApENUk7I7XR0bJGXDw6Yv4EqiAAAAAAAASJdU5AKzodrVsdHiFeF53mIXogXcvLJTghYAAAAAAACAuEpFdnyJq9FCvu8f40IAAAAAAAAAMZWKpOwiV6PlSMoCAAAAAAAAMZeKpOwm3/djN9luNnieN0JVv6AFAAAAAAAAII5SkZQ1C12NljvD1QAAAAAAAABiKCVJWc/z5roQLeT7PklZAAAAAAAAIMZSdaQsSdnUOUqlcxACAAAAAAAAiJtUJWXnuRot5HlenqpTghYAAAAAAACAuOFI2RBiCgMAAAAAAAAgvlKVlF2usiMIkQInqBQGIQAAAAAAAIA4SVVS1o7unOlCtJDneZaQPS1oAQAAAAAAAIiTlCVlZZarkQK+73/chQAAAAAAAABiJGVJWc/zOFI2tY5X6RGEAAAAAAAAAOIilUfKvuFqpIDnebmqLghaAAAAAAAAAOIilUnZd1S42FcK+b5/sQsBAAAAAAAAxEQqk7LVvu+/4mKkgOd5o1WNDFoAAAAAAAAA4iCVSVlDUjbFfN+/1IUAAAAAAAAAYiClSVnP82a4EKljSdnCIAQAAAAAAAAQdak+UvZF3/erXYwU8Dyvs6qPBC0AAAAAAAAAUZfqpKxd6OvtIESq+L5/pQsBAAAAAAAARFyqk7LmOVcjRTzPG6tqYtACAAAAAAAAEGUpT8p6nkdSNg04WhZACvVyNQAAAAAAyIJ0HCk73RcXI3XOVekehADQbK1VRgYhAAAAAADIhnQkZbd4njfTxUgRLdPWvu9f7ZoA0FwXqcwNQgAAAAAAkA3pSMraqfb/dSFSyPO8z6nqELQAoMk8vT9PU70uaAIAAAAAgGxIS1LW87wnXIjU6qhyRRACQJOdpLI6CAEAAAAAQLakJSkrL/q+v9vFSCEt12tUFQYtAGg8vX/8n+d5j7smAAAAAADIknQlZctVOFo2DTzP66Hq0qAFAI02ReUQlRdqWgAAAAAAIGvSlZS15OHDLkSK+b7/FVV5QQsAGuU6lekqe2taAAAAAAAga9KWlJX/uBop5nlef1UcLQugsewo2cl673goaAIAAAAAgGxKZ1LWru79RhAi1Xzf/44q5pYF0BjX6T3DV/1g0AQAAAAAANmUzqSs+ZerkWKe5/VRdWXQAoA6Ha8yWWWGylrrAAAAAAAA2ZXupOy9rkYa+L7/NVWdghYAfEiO3idutMDzvPtregAAAAAAQNalOym7wPf9d1yMFPM8r1jL9/9cEwD29XG9T4xyMVMXAAAAAAAQEulOyhqOlk2va1R6BSEAvKfQ9/3vW6B6lqolFgMAAAAAgOxLe1LW87x/uBBpoOVriZcfuCYAvOsqvT/0tUD1AzU9AAAAAAAgFDJxpOxs3/fnuxjpcanKoUEIAK166X33Gy42nLEAAAAAAECIZCIpa0dp3e1CpIGWr+f7/q8UZmR9Agg3vR/8RG8L7V38mqoFFgMAAAAAgHDIVBLvb65Gmnied4iqTwQtAAl2hN4PLnKxvTf8xYUAAAAAACAkMpWUXer7/gwXI020jH+kqjhoAUigXL0P3Opie0+oVMWPYgAAAAAAhEzGTnf3PO8OFyJNtIy7+lz0C0iyK/Q+cJCLzcMqm4MQAAAAAACERSbnIL3H9/29Lkb6XK7CRb+A5Omv99gfuriG53l3uhAAAAAAAIRIJpOyO1TuD0Kki+d5Ob7v/1FhQdADIAm03d+m7b/m4l5G7W2q7EhZAAAAAAAQMplMylrC8HYXIo20nEf6vv8t1wQQfxdquz/Zxe+yuWTLghAAAAAAAIRJRpOy8ozv+0tcjPT6isroIAQQYzaX9M0ufo/neb92IQAAAAAACJlMJ2WrPc/7rYuRRlrOeb7v28XV8oIeAHGk7fxWbe9dXbOG+qarmhO0AAAAAABA2GQ6KWtu932/3MVII8/zDlZlR8wCiKePajs/z8XvUR9HyQIAAAAAEGLZSMpuVrk3CJFuvu9fp2ps0AIQI/1Ubg3C/9E2v0HVA0ELAAAAAACEUTaSsnYU14cSCUgPLWubxuCvCouCHgAx4Gm7/rPqjkHzA36nwtkIAAAAAACEWFaSsvKy7/uvuhhp5nnecC3vn7smgOj7orbro138Hm3nVeq3pCwANIneP9q5MGpKXQ2gGbTtt3Yhsm+Pq6OmvasBAE2UraSsJQpvciEyQMv7M6rOCVoAImyCvkBd7+J9/UtldRACWdXB1YiOqJ5RU+FqAM2g7wiFLoySna6OmzJXR00Ux1DSsZ8GhETWkrJyn+/7a1yMDNDy/qOqQUELQAQVazv+u75A5bv2B6j/py5EfOxwdaRonLZ1IaKjtulQAMRbZ1dHivZ3ql2IcODzI3qiup8W1R8ugDplMylboQ/UX7kYGaDl3cESOgoLgh4AEWLzyP5J2/FA1/4A3fa8qpeDFmLEd3XUDHY1oqPW95YIiOsRc0AmDHB1pGifJ7bbvV5bFKdkiernR2JpnO3nwqiJ6hQfQJ2ymZQ1v43zh2oYeZ53iJb5za4JIDqu1vZ7hos/RLfd4ELES1Q/I0nKRs9QV0eG9mf2quKIOaD5hrg6aqpcHUclro4SG0fZziugaaK67Udx+wgl7UNFdZuN3bRV2V4R21V+E4TIFC+YX/bioAUgAo7WB2edUxPotjmqHglaiJmtro6aUSpRnaM0iQZq36Cbi6Nkm6sBNIP2Hya4MFL0frXJhXEUuc99rQ+7WNxBQQsRkKsyLggjh8/91InqvMK7XB0bWc+O6038Ju0QlLsmMkTL3JLhUX0zBpJkoLbXf+i90nagaqXb7CjZqJ7mjgZo/UduB9SN18OCFiLgSFdHTVR/tADCIqrb/gZXx1FUk05RHUtJNFr7ae1dHDV87qdOFH+MN7E70z4MhyyvU7k9CJEpeiNuoy/6DyrsEfQACKEi2061vXZ17Q/R7atU3RO0EFMbXR0pGpunuhDhF9V1Feej5YB066VySBBGjn1/jKuofuaf5kKEXyQ/8zXG7DOfg1BSJ3LzCmsMxHLq01DMI+F53o+0gGM3N0TYabn31XJ/QKGdcgIgXOzCXn/Udnqwa9dKt9u0BpVBCzFlifcoOk+lziO8ERp2EdCoJmVXuhpA052vfYiozikY5yNlo/qZP1WlZxAizPSZf6ELoyaq20YY2Xv/iCCMlFjOKRyWD2Lbqf5TECKTtDN2mCV+LAx6AITEt7R9fsTFtdK2u0bV74MWYiySiSeNX/tyVufF6RAaF2tdtXFx1PAFDWieHO1DfNrFURTbbV/vx5F8bXrelleI8phKimO0riJ3YU+Hz/zUGalxEMU5ZWM3n6wJza+jGhQ/0c5BnK+kGVpa9hep+kbQAhACH1f5bhDWTdvuD1TtCVqIsSgfDfg1VyOc8rXvda2LI0fvgStcCKBpTtf2c4CLo2aHSiRP8W+k5a6OHH2eXKWqbdBCGGkdfdWFUcRnfuoc7eqoWe3qWAnTKStLVf4chMiC76tE9VQGIE6O1g7TH1xcJ91nmSrOMEgAfXFe4MIosgtKnhuECKErNL76uTiK3nE1gMazH2N+6OLI0XOf68K4iuz7mj5PuqiK7A99CTBN6+hYF0eOnvt8F6KF9D56gQujJpbziYcpKWsb2nc1QMpcExmmZX+HqmlBC0AW2FEr/9R7YX7QrJvu8z1V5UELMRfpnVB9ttykKqpX+Y2zXlo39oNslM1xNYDGu0b7EFE9StbE/ceYBXpvjuzZo3rudiTm4KCFECnQuvmVi6MqygcphMlQfQZMdHGk6Hnb1H2xE6qkrNgpmr8JQmSaJYL0Zn2fwtFBD4AMsgvv/Vd1x6BZN93PdkruClpIgEh/QdNnS29VUf8iEDc2n+SftW4imyzX87cL/WwNWgAaabS2nUj/GKP3rbj/GGM/uC8OwujR+rHkn+2jNniAATJH6+QGrZvhrhlVcT9KPiM0Fr7iwiha6+pYCVtS1t7If6CBUuqayDAtf7sKsyWGhgQ9ADKgm7a7p7T99XXteul+Nt9sZdBCAtgXtKh/Cb1Y5VNBiBD4ht5Hon5mzExXA2icjtrXuFfbfoFrR9Xrro6zN10dSRpjEzXWfuyayL6ztE6udnEkaTzZXKKbghZawHI8du2SqOJI2QzZrHJjECIb9KZtCaInFTYqQQSgRexL0mPa7oa5dr1031mq/hG0kCCvuDqyNHZvVXVC0EIW2c64TX8SdZHfJoAMsqMXH9S+RqQPutBrqFD1WtCKL62nGS6MLL2GL6qyC38huw7TdhP5s+s0nl52IVpAY+E2LcsoH8Ue2bMI6hPGpKxtdD/TgInlJL5RoXUwQOvAjpjtFvQASIMibWcPaXsb69oN0n2/oKo6aCEptN7j8AXNpsh5QOGUoAdZcJbWwR9dHGlx2CaADGmt7d6OkI3De68dIb8nCGMtFj86adzZnPJ2pgyyY5zWwX+07Re6dpS96mo03+UaC5E9S0pj2b7/xnJO8VAmZaVEA+ZbLkaWaB0coMH/tEISs0DqWULWdpSOcu0G6f4Pqno2aCFhXnB1pNkXA43jRxWeGfQggz6pZW+JmTzXjiy9DptjmaQs0LB3z8Y51bWj7kVXx91MrbfdLo4sjTtPlV1I2o6aRWYdozH0tFZBsWtH3fOuRvMcqvFws4ujaoXK3iCMl7AmZc3tGjizXYws0Rv5gVoPNpVBXN7QgTB4NyF7tGs3SPev0P2vdU0kzyKNAdsZiTyN4zZ6LfepfEfNMO+HxIUdJWdHK/1eyz4uy9uOmNkRhADqMFLb/ktN2dcIO72WpPwwbXPJPxeEsWBnwdpZGnE4YjPsLBF+jZb3o9peOgRd0abXsl1VEuaSTpdRWob2vbO1a0fVPFfHTph3zqs1cOw0XWSZ1sNB2pCnK+SIWaDlmpyQdezXzVjOo4NGe8LVkafxn6NynbYFe01Dg16kwRgVS8pE+gIftYjNtgCkQa7K1Xp/fVXb/oigK/r0euwIKTtQJBG07mL1PqfXc5nWoc0HPCnoQRr01zJ+SPUvtLyjPG/ovuzMXTtDBk03RmPCjpju6tpRtsDVsRP2Iyae0iCy+eeQZdqQ7YhZpjIAWqZZCVn9zSb9zQ9cEwmlMWCn/ceKXtNUje/ZKj9UMw47jGHRR8v0FhX7Ajwu6IoPjZvHXAjgg47Xdm9HlN2k7aQo6IoNu9ZFEuaTfVfs3uc0Jkeqeklj1I6aHVjTiVTopPINLdf5WsanBF3xodf0uAvReHbEtP0Q8oKWXyz2r/U6YnuRR08ryoWhZRecsjcYTncIAbcujlO4OugB0Eg2r9u/tf0c6dpNcbnKb4MQCWZJ/S0aQ21cO1b02kpV3a7X92fVnKbWdLYDfoSW4yWqP6blGKejZN6j17dOr62vwrhf8NDmYYziBXJsHCKzOqqco23jc9o27Oj4uPq0yu+DMBm0ThdonQ53zVjRa7MjH/+u1/cn1TYtBUdCNp2dzXqxluEnFNv7QOzo9dnZ070Ubgx60AiTtNx+quV2mGvHxQCVlUEYL1FIyppvq3w3CJFtGjPLtZHblfs4lRponG7abh7XdtPkL0v6u5n6uwkK2VmFjYf7NR7Ocs3Y0utcquoJvVa7wNlcFfu82aWC/7G53vdTOVjlKC2zqVpe/eyGONPrvEWv8/OuGWckZVEbm5rAfpSwaV8manuwH3qnaJuI+lyB9dLrtMRMb4Ubgp5k0Ov+vl73N10ztvQ616t6Sq/VLuY0S8U+87eo4H/aqQxWGeG2e/vMj2XC/v30Wu3U+2NcE3UrUDlD5bMqk60jTjQO7Ad5+wyIpagkZe2iIHO1IuzLB0JA62O91scJCt8KegDUoa/boWjyvJn6O/sSYgnZN4IeoNX5KvcEYbJoeyhRZVejTtLpq7Vpq1Ko9wark+golSRchTmSSVltp7G4IGEI2TzcHbR826rOc32Jodf9iF73ya6ZJAeqJPLC11rn9llvJek/yNrZwkUa/5aUTaIrVW4NQuzDjhy1H+VtyooTNUba1/TGkF7jP/X6YntQSlSSssZOmWc+kRDR2NmpjeNMhTbXLIAPs1+z/6vtpI9rN4n+9mb97TWuCRj7kdJ+Lbb5w4BE0dhfqrE/xMKgJ9aieqQskA7nqtwXhMmi97039L431jWBxNDYL9PYt6kLtgU9iWRnR9gRopaAHaQyUsvFLuA43i2bpPiSys+DMH6ilJS1DfOvGnwXuCZCQOukQuvkYwr/HvQAcKaq2IUKmzXHk7at1dq27EOXU7bxARobdvr251wTSJJvqSTloockZQHRZ57NpW4/bpcFPYljn/e3BCGQHNr274lg7udiPe8vuHiXnn+V2nsVW/HV3lFzy/vodjv7wY6ELtDthWrbRRo7qHRRm4vgBg5QWRCE8ROppKz00PO1Cc85Qih8vq5yfRACiWcfyL/Xe1VLLrRjR6E/GITAB9gRM0xpgUTRe2qV3lPtat1JudAoSVlAtO3/Utv+1a6ZRMVaBmu0DLjoNZLG5pKN2hm5dobjL4IQqaD3v2V6/4v1NKY5ro6KDVohX3YxwuVH2mD+qDrWFxoAGmA/dNlFCe/Qe1WzE7L6H/9SRUIWdZmpMZKEOTWB97tfJSkJWQCizzqbW/9m10wqO3X7z0EIJIO2/TmqnglaSLhHXB1bUUvKmj9pI33CxQgR7TRdpnXzpMLuQQ+QKG01/u00m2+7drPof9ipLkm4sjhaQGMktvMqAbVhzAPJo+3efoxZGrSSS8vhJu0fJmEubaCGxrwdbcqYh40FkrIhZHNxfFKfS3YVZoSM1s2RWjevKRwd9ACJMFDj/iWN//Ncu9n0P+y0l1VBC6jTQxpzi10MxJq9v6p6JWgBSJAbXZ1076g8HIRAvOkzf72qu4MWkkxjYbOq2B+QGcWkrFnped5XXYyQ0brprw3oRYUfDXqAWDtG492ujHuQazeb/s9/VP0paAH1slM6k3LBIyScxrpd4AtAgmifyE5dtgM9IHofbNGZWEBUaKzfoCqpF/bDB/1DpSII4yuqSVlzmz6s7VR5hJDeTO2qgXdpHf1SNfPMIo48lS9rjD+u8d456Go+/Z+t+j+fck2gMf6icTPfxUBcPacStQt9AGgh7RN904UIvKnPfLvmABBbGuNrVP02aCHp9DlwpwtjLcpJWZvG4BJtuNtdGyGkdfR5rSP7QtU/6AFiobPG9UOqb9QYzw26Wkb/53JVdroO0Fh2tOx1LgbiiqPDgITRPtY/Vdm0JXgffeZ/R8uGeTYRWxrj31O1J2ghyfRWt1BVIqauinJS1qzRhnuFixFSWkcTtVHNUnhq0ANE2iQbzxrXp7h2i+n//U3VvUELaJJ7NX5suhggdjS27SI/04MWgCTQdl+lfayvuSY+6C2VPwYhEC/a9ueoYho31NDngJ1xnQhRT8qav2kD/ruLEVLaqIpV2YVpblbdpqYTiBZ7v/yKxvB0jed+QVfL6f+t1f/7vGsCTWVnjVyjccSRM4gVDekyje1rXRNAcvxexS5shVroffGben/c5ZpAbGhsf1FVZdBCkuk9zs6G/3PQir84JGVtA/6MVtwy10SIaV1dpXX1usIWXxQJyKCBGrd2wYkfawznBV0tp/9pCbWLFW4JeoBmsfdUjixA3NhV19m3AxJEu0UbtV/0DddE7TZoGX3XxUAsaNt/QFXsr7KPRrMf50qCMP5ikZSVHfpwulAbM7+sRIDW1Uitq1cV2hEwKZmPE0ijizVe39a4Pcq1U+nHKlywEC2m8WkXndvgmkCkaSy/ozH9A9cEkBDa7r+gamvQQj1u0vuk/SALxIHlcq50MRJO7217NR7s7OrEiEtS1szQyuNiEBGhdVWg6icqNnnzgdYHhEx3fSjYfIZ3aLy2D7pSR/+b9yyk0naNp8+5GIgsvTfaGQSfVFgW9ABIAm36/1X116CFBti8u5/QMuOAJMTBl1XWBSHQ6jaVNUGYDHFKypob3Ac6omOc1tkbqu1UpZSdFg60kB0dO187vGe5dkrpf2/T/z5fITvTSKX7NbaYYx1RZ0dHvBCEAJJAn12l2i+63DXROHYW1/ddDESStn3L3XDxOtTQeNil97XrXTMx4paUrdZK/KhW5mrXRgRonbVWZacpzlAZbX1AltjcsbZzYEfHdg66Uk//+2OqVgYtIHU0ti7XGGZsIZI0di3J8FXXBJAQ2u7t1GXmkG66H+p98yUXA5GisbtJ275dW4OL1aKGxsNPVW0OWskRt6Ss2ayVea428grXRnTYUbOvq/xccYegC8gIO0r7Sxp7c/T+MS3oSpsbVB4OQiDlbBqDizSWq10biASNWZtD7AKFTFsAJIi2fTvD446ghSayaQwuVL0jaALRobF7qar1QQtJp8+CparsIq+JE8ekrLG5Gu0iUogYrbdclS9oo3xHzY9aV80NQPpM1XibpfqnGnttg6700OM8rYqrCiPdntdY/pqLgUjQmP20qnlBC0ASaL9ohbZ9pi1omRUqHw9CIBq07dvFjjlIBe/RZ4FdG2NP0EqWuCZlzc3a2O9yMSJGG2VPVXdpHT6relRNJ5Ba/TS+7lH9lMbbyKArffRYK/U45ymsCnqAtLpRY+4+FwOhprF6i6q/BC0ASaDtvsztF20PetACD2l5Mr8sIkFj9Qlt+990TcDcq/JYECZPnJOy7x51YReRQkRpHR6lN+433Re2rkEv0CJ2NOy3NKYWaHzZxbbSTo9lp+XaRcO2BD1A2tkV7C/V2Jvt2kAoaYxO11j9omsCSAht959Q9WrQQktpeV6n99P/uCYQShqjyzRWP6KQg1RQQ2PCprCwo2QTK9ZJWbHDn8/Uit4YNBFFeuO2KQ0+p/Vo84x8S6VdzQ1A09i8sZ/SOFqs+nsaU0U1vRmgx/qkKn4gQqaVaOydrDG/1rWBUNHYfEdj9EyFXAcASBBt+z9RdXfQQorYBa8/omX7pmsDoaKxuVVj9ESFW4MeoOZ78iWqNgWtZIp7Utas0oo+W28C7PBHnNZje1Xf07q0pJr9mpJv/UAjnKZxY0cM/k7jyKbGyBg9rs2ZxBcPZIt9Bp6icVji2kAoaExu1NjkyxmQMNr2H9K2/3XXRGqVatnaj7ErXRsIBY3Jco3N0xXadWOAGhoXN6l6PGglVxKSsuYFvQnYkWqIAa3LHqpu0UY8X7Wd/pCUcYymO0HjZIbqf2nc7B90ZY4e2754cGEvZNubtiNsO8SuDWSVxuJOjcmTFS4LegAkgbb9l7XtX6CQU5fTZ52W8Yla1ptdG8gqjcWao7gVvhD0ADXj4iWNi6+4ZqIlKZl1p1b89S5GDGgjHqzqb1qvlpy1w95bWz8g7yZjH9U4OTToyiw9viXCLlRYHfQAWfW0xuO5GpecNYKs0hjco7F4gsLXgx4ASaBtf462/VMU7g56kEbztKynapnvdG0gKzQGLSH7cYX/DHqAmnGxWuPCrrfCASOSqCMMteK/oQHA1ahjRut1mKrbtW7fndag0PqROPZ+do7GwSuqs5aMNe6Dxr54lAY9QCjYkdsf1/jkhwJkhcaeJWTtvfHloAdAEmjbt4TsVIVMV5I5s7XMj9OyJzGLrNEYtO/mTOOG97h9wTMUbgh6kLTTvu1q1PaF9EXXRoxo3fZTZdMa2AXB7FD4YutH7FkS/gqtd5uj6F6Ngwk1vVliO796DnZaLhdXQhjdo/FpP15wxCwySmNul8aeJWSfDnoAJIG2/XcTsom+kEuWvKJlb4lZkuHIKI05OwDgUpXf1HQAYt8/9J50rkIugP0+SZyL0zLzdtGfBa6NmNH6tQs5/VjreLXKbxWPqrkBcdNb6/e7KqsU36r1PiTozh49F/ugOVvh20EPEEr/1Dg9U+N1j2sDaaWxZj9WTVNIQhZIEG37M7TtH62QhGz2WGJ2itYFc8wiI9z3oYsU3hH0AAGNi0+oejho4V1JTMqarRoQNufkOtdGDGkdF6l8WqElyJ5VsWRZngqiy1OxObLuU1mh9fttlS7BTdmn52JzJj0ZtIBQe1jj9XhtR9tcG0gLjbE1GmtHKbSpZQAkhLb9R7TtH6OQZGD22VQGh2ud2NmEQNpojJVqrJ2u8G9BD/CeK1T+EoR4v6QmZY0ldOwLKfPsJMNkFUvk2ZWer1MZZJ2IjK4q12j92UXdntK2e7ZK2BLsX1S5JwiBSHhe29Fh2q6WuzaQUhpbb2mMTVT4VtADIAm07f9C2/5pCrmoV3gstPdjrRvm9EZaaGyt0xg7UuGjQQ/wHkvI/joIsa8kJ2WN/WpoR8xyCmdCaH33VfUdlaVa79NV2yH0HVQQPq1VztB6elDF5me1HfzhNbeEjJ7fD1T9ImgBkbJA29WhGsPMtY6U0piyo7HtCNnVQQ+AuNN2b1fSvlTbvv1QXVXTiTDZpHVzrNbT310bSAmNqVkaW/Yj7JtBD/AeErINSHpS1rysNxCbW4+LniSM1rv9kvcHrfv1Kn9VfIJKvt2GrLH3pCO1Pm5VsUSszX15ukpo14s9Vz2/b7kmEEUbNYZtWpDbXBtoqe9qTNlRcpyNBCSEPkNsqhKbP5Z5JMNtt9bTBaq/rHVmF2MCWkTj6C6NqcMUrgx6gJpxYfm1C1VIyDaApGzgcb2RXMgHUzJp3Re6nZNHNQY2qNhcJ2eq2FX9kX7vJmJ/pWJHVE3X+rhCJTRzxdZFz/duPc/PuyYQZeUay59TfYnGdWnQBTSNxo5d4ftUFZsmiH0qICG07T+oz5CDFL4U9CDkfJWfaZ1N07pbH3QBTaOxY0fGX6Vx9DHVnHmM92hs2AVeT1TI3MKNQFL2f+7TwPm4BhBfIhJMY6BYxa4W+YDGwhaV+xXbB02x3Y6Uaa9ylpZvzZHKii0Re6VKr5pbI0DP+696vhdbGPQAsfBnjeuxGt8zXRtoFI2ZpzV2LCnzn6AHQNxpu7dEzOXa9u1gBvtRBtFS876t9cj7NppEY2a+xs4Ehb8KeoCAxsYqjQ27ns9TQQ8aQlL2g+yoNxKzqKGxYEfQnqXwTo2JzSqvqNjcoVNUbL5TNJ6nMkrFTpV6WmWL4vu1fD+h0s3uECV6/v+y9wqFzJeGOLKLgUzSOL9ehTGOemmMlKm6VmNmmuo1NZ0AYk/bvv2gPlbhb4MeRJTNM2vTzVyhdVoSdAG10xgxv9KYGacmF/HEB2hszNDYsGT9rKAHjeFpwbkQ73O5CnNfoE7abuzIgOf0pvOk1Sr2ocS8xP9jSdiRKlO0rCyJPVnLqqvdEHV6Pf/WazlHoZ2yA8TdGI35P2jM2xdvYF/2+fcplUU1LaSSzctpZ2MAoaLPhK36TLhW4e3WrOlEXPTX+v2N1q+ddgx8gMaGHR37SYVMU1K3a1SSevHnP6t8RsV+rEcTkJSt20e1bO7UGw9HE6NBGit7VdnpvnbhuFetVlmlkhR2tOshKhO0LKw+VMsh9HPCNpVemx3daxOWk5BFkuSpXKXybZWO1oFk03vhBr0Xfk2hJQ7ZkUwPkrIIFW33vrb7OxX+n8rGmk7E1fla3TdqffdzbSSYxkKpxsL1Cn+qQsKtfolLymp82HUp7HVzUGMzkZStH4lZNJvGzjpVb6rM0xiaq3q2ynyV3SpRZcmZoSoHqozUa7QpCcbq9Q1UHWt6rTaHLFMWIMm6aTv4nupPaVvIDbqQJFr/9oPUTVr/NpXPrppOpAtJWYSGtv3HtN1/VSGnKyeHXfD4Wq37r2rdc/HjBNK6f/eHmK+rrK3pREMSlZTVEFmpMXKuQjsoDc1EUrZhH9EyssRsvmsDzWYfbqqWq8xRWaxxtVL1Clcs3qySbQUqA1QGqQzWU95PtZUhKvsncVvQMrhdr9tO0SUhC7RqNVTbxPdVn6ftwqYqQcxpfdv0PH/S6v6RavusQvqRlEXWadt/Vdu9JWS4YEty9dI4+Irqz2gstAm6EHda53b9DDtD6u2gB42UmKSsxohdKN+mK+Aijy1EUrZxTnKDjl8JkVYaZ3YUrSVo12q8bVXb3uRs7q6aWsWStjtV7NQRm9fW2NFKliy0YrElVd8dq3aUdwcVS5zYacdWrF1T6/93Vt1bpYdKL6v1WNYHR8voFi0TO3WbN0vgg0Zo+7Ajpz6ibYQfLmPIfSbdofV7g2qSsZlFUhZZo23/UW33Nyp8JugBapKzX1ZtZ8u0D7oQJ1q/9l3Spmr7sWo72xNNF/ukrMbJeo0Re51/D3rQUiRlG+8ILauHNQAtoQUgAbTNf1/bvP1KDKBuvbWtfE61fVGz+aURcVqfq7Uub1NoV1XnCIjsICmLjNJ2X6rqH9r2LaFgU24BtbHvwp/UeLlSY8XOqkPEaV1uU2Vnw/xKtR0chOaLbVJW48SuofNzjRP7od4OEkOKkJRtmtFaXo9rIHZ3bQAxpO3c5lC6WqHtnABoHDta9lRtPpepPlHbEPOxR4jWm80X+6DWm11R/b8q1daPrCEpi4zQtv+itvs/KbxXhbmi0Vh2Ft4U95l/tsYQZ5RGiNabJYGe0nr7o+p/qnABr9SIXVJWQ2WbxsnvFNrr2lDTiZQiKdt0+2mZ2WT3drEjADGj7btC2/fHFHJKBtB8XVTO0PZkk/9P1TbF9AYhpPVjRz08ovXzgOr/qOywfoQCSVmkhbZ7+8HlBW33/1ZtyZgl1g+0QDuVEzW2zlZ9isZW25pehIrWj01P8JzWj/0AY9s+CbbUi01SVuPFPicsGWvjxfYXkSYkZZvHrkD9kAbpRNcGEA+WkDhD5dmaFoBUsC9rk/W5OU31MSoj9fnJBcKywL6QadHPUv206sfV9aIKO9rhRFIWKaNtfqEqOyLW5oh9RGWL9QNp0FplkvvMP1ZlrMYdP8xmidbDAlX2mW9nwNj3G358Ta/IJmVtH1HV8xorD6n+l8pS60f6kZRtviItu79p0J7m2gAiTNvzSm3PJyqcF/QASBO7QMgElUO13Y1UbWV/bX92kUKkiJatXaTrHZU5WrY2P+TLKjNVrB/hR1IWTabt3r5UL1aZrzJP2/6rql9S2aQCZEMblTEqdjDTwe5z3z7z7QdbpIiWa4UqS8DO17Kdo9q2/VdUtqsgcyKTlNWYsR/lX1OxH+zsc+IFFZtfGBlGUrZlcrX8btAg/pJrA4imN1ROVVlX0wKQabkqfVX6vVv0+VqsurM+Y4sV25E37RTnqU48LQ+b/9WSq7ZDbTvQNt+XHfm2WmWlK2tV2MmLrqgmZZ9zNVLsfdu9TbNUqvYW1Xb6se27WL1KxRKylpwBwq6XygCVdz/zbdoj+9y3YvPTFml822d/4mnZ2JQjdmEl27bf/cy3i3DaZ75t9++WShVkV6iSsho7Nlfwe2NE48bOmpjrih0Jaz/kIctIyqbGp7Ucb9Ug58siEDHadu/TtmtffDl6DAAQFlFNyjI1CQAgqWyqjvfPqWzx+6fv6OTqjir2edlBxS6Ma2eR2QEKlk96/1Hk+/6/fdl0FJasL1HZ49qWsLdiP9Zz5GsEkJRNnWO0LO/1PM9+3QMQAdpmf6Bt9tsWBj0AAIQCSVkAAICYs6w8UuMpz/PG+75vc7gACDFtp3ZU7HnaZr9lzZpOAAAAAACADCEpm1pLPc+zq03e79oAQkbb5zLbThXeG/QAAAAAAABkFknZ1CvxPO9c1V/3g0m5AYSEtsnH7Yh2hW8HPQAAAAAAAJlHUjY97HTo6z3Pm+b7vl0NFUAWaTs012mbPElNm/gcAAAAAAAga0jKptfTnueN9X3/BdcGkGHa/jZpOzxR5btqcvQ6AAAAAADIOpKy6bfW87yjfd+/3g7Vc30AMuM5bX+jVT8eNAEAAAAAALKPpGxmVHqe93UVm85gnesDkCbazuyIWDsy9hiVtdYHAAAAAAAQFiRlM+spz/MO9n3/EdcGkGLavlZoOztK4XUqVTWdAAAAAAAAIUJSNvNsfstTVH/W9/3SoAtAKmibutt++FD4YtADAAAAAAAQPiRls8Pmlv2N53ljfN9/JegC0FzajraoOk/b1EWqd9R0AgAAAAAAhBRJ2exa5HneEaq/6ft+edAFoCm07fxb29GBCu8NegAAAAAAAMKNpGz2Var80PO8sRw1CzSetpfNqi7StnOa6vU1nQAAAAAAABFAUjY85nqed7jq//N9f0/QBaA22kbu1Payv8K7gx4AAAAAAIDoICkbLnal+BvtVGzf9x8PugC8S9vFUlXTtI1crNrmkQUAAAAAAIgckrLhtNTzvBNUX+D7/oagC0gubQdVKj/RdjFKzSeDXgAAAAAAgGgiKRtu99gp2r7v32JJKdcHJIrG/nRtB+NUvqLm7qAXAAAAAAAgukjKht92z/M+r2IXApvu+oDY03hfqep8jf3Jqt+q6QQAAAAAAIgBkrLR8bbneVNU25QGlqwCYknje4/KdRrvdiGvfwS9AAAAAAAA8UFSNlp8lZopDVR/3ff9XTW9QExoTP9d43u4ynfV3BP0AgAAAAAAxAtJ2WiyZNX1nucN8X3/NhXmm0WkaQw/o2qSxvRHVK+q6QQAAAAAAIgpkrLRttHzvM+p2MXA7lGxI2mByNCQfU3VNI3hqapn1HQCAAAAAADEHEnZeFjsed4FKnYxsEdcHxBaGqfzVZ2tMXuo6idrOgEAAAAAABKCpGy8zPI872TVk3zffzzoAsJD43KJqks1TkepfsC6rB8AAAAAACBJSMrG0wzP805QPc73/X8FXUD2aBy+pcqO5h6m+g4V5kEGAAAAAACJRVI23mZ6nneG6oN8379bhUQYMkpj7iVVp2gcjlF9j0q19QMAAAAAACQZSdlkmO153kUqg33fv0Wl1PUDaaEx9piqKRpzh6t+2LqsHwAAAAAAACRlk2aF53mfV+mn+P98318ZdAMtZ8l+lV8rHKExdqLq52puAAAAAAAAwAeQlE2mbSo32pGzqs/zfX96TS/QDBo/i1Vdo/HUW+UKxfNrbgAAAAAAAECtSMomW6XKvZ7nTVY90g+mNthZcwtQD40T84jCkzR+hqu+WYWxAwAAAAAA0AgkZfGueV4wtUFvxZ/wff+FoBv4H40LOyr2WxonA1VOVvyoChfvAgAAAAAAaALP97n+Duo0VOPjUtUf9zyvT9CFpNEYKFFlR1TfrtqS9bxpAACQXneoXByEkeK5GgAAAA0gKYvGsCOqJ2usXKj6HM/zOtX0Ira0rm1qi6e0rv+q+n6VUusHAAAZQVIWAAAg5kjKoqkKVE7QuDlH9Wme53Wo6UXkvS8Re6/qf6pstX4AAJBxJGUBAABijqQsWsIStMdqDJ2l+nTP87rU9CIytO7KVT2pdfeAahKxAACEA0lZAACAmCMpi1TJVZmo8WQXfzrV87wDa3oROlpHq1U9rnX0iOonVXZaPwAACA2SsgAAADFHUhbp0l/leJVpGmPHeJ7XuaYXGaflX6HqBZeEfUxljvUDAIDQIikLAAAQcyRlkQl2obCxKsdovB2p+kiPuWjTRsu4TNXrKtO1nKerflFllwoAAIgGkrIAAAAxR1IW2WBTHRykcpTG3yTVEz3PG2A3oOm0DC3h+pKW4fOqLQn7mspeFQAAEE0kZQEAAGKOpCzCooeKzUl7iOoxKqM9z+ttN+B/tHy2qZql8oaWz5uqZ6osVKlWAQAA8UBSFgAAIOZIyiLMLFE7WmWkxqldOGyEFc/z2quONb3e3aoW6bUuVLxA9VtqWxJ2qd0OAABijaQsAABAzJGURRT1URmiMljjd7DqYSp2YbH+nuf1VB0Jeu6bVK1RWauy2BKwqheoLFJZpcLGCQBAMpGUBQAAiDmSsoib1iqWtO2nYgnabhrjNg1CV4tVilU6We15ntUdVVJCj7NdlU0v8KFaj7VB9WpXLAlrtV2QCwAAYF8kZQEAAGKOpCwQJHKLVNqp5KlYorauLxU2rUB5ELYqValQsY1oh3UAAACkAElZAACAmCMpCwAAAIQLSVkAAICYy3E1AAAAAAAAACADSMoCAAAAAAAAQAaRlAUAAAAAAACADCIpCwAAAAAAAAAZRFIWAAAAAAAAADKIpCwAAAAAAAAAZBBJWQAAAAAAAADIIJKyAAAAAAAAAJBBJGUBAAAAAAAAIINIygIAAAAAAABABpGUBQAAAAAAAIAMIikLAAAAAAAAABlEUhYAAAAAAAAAMoikLAAAAAAAAABkEElZAAAAAAAAAMggkrIAAAAAAAAAkEEkZQEAAAAAAAAgg0jKAgAAAAAAAEAGkZQFAAAAAAAAgAwiKQsAAAAAAAAAGURSFgAAAAAAAAAyiKQsAAAAAAAAAGQQSVkAAAAAAAAAyCCSsgAAAAAAAACQQSRlAQAAAAAAACCDSMoCAAAAAAAAQAaRlAUAAAAAAACADCIpCwAAAAAAAAAZRFIWAAAAAAAAADKIpCwAAAAAAAAAZBBJWQAAAAAAAADIIJKyAAAAAAAAAJBBJGUBAAAAAAAAIINIygIAAAAAAABABpGUBQAAAAAAAIAMIikLAAAAAAAAABlEUhYAAAAAAAAAMoikLAAAAAAAAABkEElZAAAAAAAAAMggkrIAAAAAAAAAkEEkZQEAAAAAAAAgg0jKAgAAAAAAAEAGkZQFAAAAAAAAgAwiKQsAAAAAAAAAGURSFgAAAAAAAAAyiKQsAAAAAAAAAGQQSVkAAAAAAAAAyCCSsgAAAAAAAACQQSRlAQAAAAAAACCDSMoCAAAAAAAAQAaRlAUAAAAAAACADCIpCwAAAAAAAAAZ5Pm+70IAAAAAAAAAQHq1avX/h124ox3Qaa4AAAAASUVORK5CYII="]}, "1759436504239": "Sim."}	\N	\N	\N	\N	\N	2025-11-11 03:45:31.647538	2025-11-11 03:45:31.647538	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
999ef239-5ddc-4679-8248-2f153c5859f8	425	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
448691a5-04be-459d-8668-43103f6ab582	426	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
97103126-6879-4e22-ad30-0934c017f204	427	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ea38ee07-35b6-4a08-8f17-2986b31f58cd	428	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0c21b263-9a14-4197-95ae-d4aeff7bb3aa	429	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d5942afd-9393-4ec7-90d8-da58baf22e77	430	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d36470ef-9454-4c15-89ac-afca3614fe81	431	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5cc5f110-3e23-4978-8c47-89545356a063	432	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
3ab326ff-49dd-4ee2-97ec-32215f3e4246	433	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
1d580fe3-d192-4a41-bd8f-0d9bac7bec4a	434	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5d627774-7a6e-4e1a-a396-e2549acca1a2	435	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6f7ea791-2c75-4725-b679-cd75e83b3056	436	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
02bb7114-3d88-409f-9462-83a1d53109d7	437	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
627ef3ae-8711-4e3e-9b99-176a4acda59e	449	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 09:00:00	2025-11-29 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
254626ec-4c83-4968-8a2a-76c97230f9ce	438	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ec3d0ebb-46c6-4f42-8e4d-ba538db1d9cb	439	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
9801f208-bf14-4400-a72f-1aec5229efcf	440	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
cf9ea34b-c225-4095-9bb1-aa2af31f4c19	441	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 09:00:00	2025-11-12 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
cdbe6a4f-aa93-4aa1-9e46-39a8cc5b9875	442	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 09:00:00	2025-11-19 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
4ff930f1-f8a3-4bb6-943e-99eb50c2f6df	443	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 09:00:00	2025-11-26 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
a8e009ba-4bec-4893-9212-3628b3ce21a2	444	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 09:00:00	2025-11-16 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b811e459-e642-467d-9d95-7c7479b8f19b	445	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 09:00:00	2025-11-23 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
1fa2d35c-c1c7-4e41-82dc-8a074c99bbf0	446	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\\t\\t\\t\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 09:00:00	2025-11-30 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
f669ab3b-06a5-409c-9a2c-22a6db57c4b1	447	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 09:00:00	2025-11-15 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
0d77e18e-a3e7-4341-846c-56d1ea38bc4b	448	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\\nTroca de filtro da exaustão\\nLimpeza do flash off do primer\\nLimpeza estufa do primer\\nLimpeza das luminárias do primer\\nAspiração da região superior (teto) da estufa do primer\\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 09:00:00	2025-11-22 11:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b64124ec-db84-4b8b-97cd-409e7d8f0f16	10	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c3a88fe7-949b-4180-b4fe-b2ec642bdbec	11	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d8527329-e163-4208-b0b7-63c84db5340b	12	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
825459da-4b2d-4890-998c-e1444fc00405	13	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
28bff99e-a3a4-42f5-b52a-27f9fbb1a4cc	14	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
074e9b47-530f-47b2-9c4a-d0a9d5c52776	15	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1e3d2637-2eb6-4763-85b7-314962344364	16	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c27f3c76-c7c8-408b-ba0f-0286f4939f30	17	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
11ec3441-0d1c-44d5-8945-8b5d21070d53	18	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c9b7a327-8f81-45fe-ac39-1a9963bd6231	19	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5aa60065-3270-41ac-944a-c2d85b54e773	20	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11 08:00:00	2025-11-11 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
501b65d4-8ad4-4861-bf83-e5319d1a229d	21	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
26658c23-3e92-4fac-bdc5-2675fdc79e56	22	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5a218435-ecad-4d90-be53-9e6377439d3c	23	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c52fcd26-1472-4cc9-bc2f-9b9bceca234c	24	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0cd37b81-27a9-437a-bc38-dd17d4d72bde	25	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a0dfb9b4-c0e9-475e-835b-af5a6d3413e5	26	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3f0a1485-bf30-415c-975e-c6a22e4234bf	27	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ae869a61-bbf7-43fe-a5cb-8b606a2a60f5	28	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
526544cf-3d10-406c-b294-567802535595	29	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
dd23594d-21bb-4a0e-bc40-56ca864df45d	30	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
12befc7e-7b49-4bd0-a629-65fa50e379c2	31	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
faac81dd-a410-44ec-b71e-c5ec86de976e	32	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8c8b0aae-4ba3-4205-87c6-f49da94e0f96	33	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2cccfcc6-956f-4930-a9c1-70d72f360d69	34	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1799342b-2104-4299-aa90-7b7c78de4ab1	35	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4a25cb74-6336-4271-a39a-43cea69a9e2c	36	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d27654c7-09ef-4e97-b1d2-dab7a8003e7f	37	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5c294e5c-4d5f-423d-a59b-ddec05633b51	38	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3dd38022-11aa-4151-bc10-af8542787960	39	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
79c188c7-11ba-4a6f-8d2c-622e5c8556ce	40	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e9e4d45a-5be9-4003-ad5e-715904ef6e40	41	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
342c8c28-1280-493b-a994-316d0ed56fd7	42	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
29c96f36-a7c8-4259-bc86-05a52582c370	43	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fc419a0b-4aa1-4370-a4e5-cf8dd0c5a34d	44	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8b997b27-4283-43e2-9219-2899f896931a	45	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
346b649e-926c-45b4-986d-b4ba180ef1de	46	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8dfb4907-9df6-4c4b-aa5c-05f8c5b5d01c	47	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
09a85b6d-94f4-4c93-8ce6-45535d32dc3b	48	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6d43cf83-05a4-4409-b941-b8ebc9b08d33	49	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
37a2ab82-3604-4b38-8309-93d808929d2b	50	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e2665677-1357-46ac-9e09-92dd6e1d5b8d	51	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c515686c-981c-4dc1-a673-536f461c1601	52	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b71e7981-9a89-445e-ad34-01f6c2ad8a7a	53	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
da3f332b-aece-40e7-8987-fa8a25c4439f	54	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8b9157a5-8778-4300-b210-dd58f085ea0e	55	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
765ae0ae-f9c1-464a-8945-c2eba008cd37	56	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1391b9e8-911d-4c1a-a43d-77ca0bb52e84	57	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
283da925-c8e9-4d1a-9076-e45b53988fcc	58	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
475b9bf5-9e58-4af0-8808-053c44622e6c	59	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
72f730a8-ed20-462a-9782-9a75f0e64cfa	60	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
08d2e8ec-a724-42f1-8664-f6d94867e3bf	61	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
eb22c4f4-25bf-476d-8036-fc57a45738e8	62	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1010c0e0-a7a2-4ffc-8bdd-2c860acf6b8e	63	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c5e962ae-e639-4244-a339-b3c764c13a6e	64	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b35d6f41-39e7-4e02-beba-c5b43c5a23a5	65	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
40c9accd-6a2d-4095-9646-6fa94c9e3824	66	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
dc35c3f0-0a64-4c9e-8bea-c133474e0e02	67	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8580409c-e123-4733-af3c-f0e35981b267	68	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1da540ff-b63c-4cc8-86ac-a60b1723f318	69	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4deba9f4-e7d8-4869-8dcf-5d29db41313a	70	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9ce19ab3-f43d-46de-b49d-0c28229a1ee1	71	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
59214d9b-363c-4c45-9797-9c70e98904ef	72	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
042feab3-8207-41e7-ac23-53eef0ae5318	73	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9922c0bf-8337-4370-95be-709dd68e1542	74	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d2c55138-ba8b-43ce-9c51-3599047d8635	75	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
eb4f59b3-dde1-40b5-932f-0b18580647b3	76	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b29e4975-f638-431d-8153-a6644feb75e5	77	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2bc8643e-98af-42eb-9f78-c68b66adb921	78	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9488c410-d9c5-4b4f-9edb-cf27873e7c11	79	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fc0e657d-0db6-4e99-ad58-9412e120bcf5	80	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2ad0de6a-282c-48f4-858a-f081209bf596	81	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
222cf7e6-048c-42cd-bf08-30bff5a95008	82	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b13c7bb0-6239-4042-8bee-95ab202a2f35	83	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1408ea56-59d5-4940-a9ca-4340a322cb47	84	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
584241ae-55c8-4274-a684-201a95d2a76c	85	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ee6040d3-a9b6-4594-8c92-65fbd7046530	86	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8a90b881-997d-43ed-bb84-c0a196256779	87	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e4d269f7-03f4-4152-a682-8dae9315135a	88	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
69649653-4652-465e-a587-f0c1e4fe5c15	89	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e8289bde-266f-41b6-a74c-4a303d9db8e9	90	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
397054d3-b8a0-42a7-8efb-516046428a18	91	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
245cce7e-aee8-42ac-936a-7046a4696d58	92	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c27bba2b-51a1-4102-80a3-81b92535e001	93	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b737b503-93f9-499d-9f29-c66b386cec22	94	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0533d997-f112-4d14-aaaa-5c06e38ac44f	95	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
24d1c84e-c8a6-488e-8968-45182d1bdb61	96	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2f99770f-bd03-4727-9bd3-710477f7f7b3	97	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
de106972-619f-4e24-94a6-0a5847091e3a	98	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
28e400c2-e9bd-4044-b4f5-b2b1f8654b55	99	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4c5f1dcf-6f6c-43ff-bac4-aeba2faf70be	100	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0c91cb24-07fc-429b-88b6-21c764147e9c	101	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
352632e3-7387-4617-8fe2-4d07ad2346ca	102	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
801a43d7-65ac-4006-8bff-361e95c48c7d	103	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5a785e89-7fb5-4def-baf2-c4e7a01dc171	104	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d137182d-fa13-4848-bf71-df207967f7d7	105	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d00cb5a5-b2eb-4cab-bd7d-6d2b2d61380d	106	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ff19b239-72ea-4a72-ba2b-0adb6025ea72	107	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
255a2136-0dbe-479e-8fce-9cfccc57c669	108	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
006b3e5c-24fa-4708-b21e-08184b408f4b	109	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ea03b715-ba3f-4b47-9a56-7bbaa9cce76e	110	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1f66029e-433f-41c2-8538-a28ae1c8e29b	111	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cf8503f9-e48c-43f4-94ad-dfd118ed7a58	112	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8410434f-ae71-4b0c-9d7a-a8695e4496c7	113	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ce36c59b-3b62-4e1d-8b03-0b006340e2f5	114	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e319a2a5-9f41-4308-9814-53fca3b2a876	115	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a79cbaf7-75da-4b80-9ed5-36ed63d27eb7	116	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1c4abdd6-5e06-479c-a65b-cefe33430820	117	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
24aabe2a-4c2c-428f-9a9b-4955a100f7af	118	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5bbed7af-c158-4514-82b2-f6659fdc17f2	119	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
302a7834-576a-4d0f-a1df-a3c34695ce75	120	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
17e86140-ed93-43c6-9f92-eb75a736f9f8	121	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f5b25545-e1cd-48bb-9dfd-d4849c9e59fc	122	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4bcc620d-9727-4069-86ee-d38a3b859ce0	123	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
50e1c00a-9134-4f3e-b588-7a5b6e4b4c4b	124	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
28a727b0-4b96-4500-8ca7-4fc764ab2295	125	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ebd1fc3e-8364-4556-a7a8-71efab514aec	126	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
773b5c80-109b-412c-a979-484af9ae9b4c	127	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2b978200-5610-4895-a50b-6c9f648928dc	128	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
423331d3-98a7-48ac-adee-29b67c0d626f	129	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5aca754d-179e-411d-a087-2cb25bc3bec8	130	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
dca90228-07a6-4f1f-ad9e-d9f3fac973db	131	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d2e6a020-e045-4351-8da3-fd8313105a09	132	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
12f4bf37-917b-40ed-9ad2-2f6eb78fe50a	133	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1a107c55-1fe5-42da-8ffc-619c86d5b9bd	134	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fedbae26-5cda-4ed5-94b1-5e3ac1edd7f0	135	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
302fad74-9abf-4513-ae38-cd5f194a4d7a	136	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e8793a00-1378-43f9-a570-e2dc0dd58a1a	137	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
95e88c8c-9b8e-49e1-9237-e1dbb570db17	138	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
40959a9b-8e00-44e3-a52d-86623cfb9ad9	139	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3aa77afb-facf-470b-828f-d3415414b781	140	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6923ee57-0a51-44bd-8e51-b490c46f3722	141	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a45d9f5c-7bcf-4dfc-995f-824a83ec9f5d	142	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
32c132ab-ae22-46b1-9d36-3bc4ff538d72	143	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b6c6a804-dbd6-4158-bd88-8827fdc4b851	144	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e1cbc749-30e4-43b1-87c3-61601f7d13d9	145	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2acee63b-0ec2-4ebe-abdc-6e7fa67d4c10	146	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d8c19413-e9bd-4fb8-98c6-e05c3accf448	147	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
dfdd2b33-4325-4983-9e24-d75531cfe30a	148	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7321a30d-32e5-46bb-9d3e-db696847e7c7	149	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4e2f0fb2-0594-434e-a14d-19239f461dfb	150	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c536bf53-e4fb-492c-9b96-74643db14198	151	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f7dbefc1-723b-4a2a-aad7-adf5d3772dea	152	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fefb23f1-523b-456e-8348-9fe0a065e75e	153	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
be7a3ea1-ff64-49a7-b879-531321dfb36b	154	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e04bd7d6-0642-4eff-850d-7089a37c54d5	155	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ac84041b-91e0-44e0-8848-06674c869faa	156	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
778f88eb-1d1e-47f3-a974-0a7cb07d4754	157	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
29c5c6ec-29f0-496f-a9e8-878cf0c957f9	158	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
92ffdd20-bbb8-498d-9852-b542de43e523	159	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5751cc27-c4e6-4418-9a19-d31feda039a3	160	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
75a27d93-75a9-4a44-b91b-4acf65d01eab	161	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cf15afbc-019c-46d5-8deb-be2ad1f646b1	162	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6d1c64c1-bf37-4ce6-83a6-617da2c96db2	163	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0102babd-bdbd-4c4c-b237-48839dd8d682	164	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
124e752c-8fce-4417-b217-6608072b357b	165	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
456e42d7-57d4-4889-b17d-400454310283	166	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
00f7fa2b-b17f-44d7-a598-2cce552fe9fc	167	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f9788ed0-f119-4ded-a6eb-a9220e89808b	168	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d0a492fe-7ad3-4169-9893-2c49d4c22e90	169	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
08f22630-f3cb-47ac-9271-4d550e7d32f4	170	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1196d77b-2d95-4bdb-b7ce-3bdec5c2e3c6	171	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5e9b6050-fe53-4ccc-b8c8-4655427e3b5a	172	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
63a2892f-5ce7-4b68-a8d1-675db9e42a89	173	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
59c5dc1c-31c4-4a5a-8eec-044d06e10b0d	174	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5f256cb0-5627-4cb8-9453-3843361a9a0b	175	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
315b0fee-66df-4555-9dbd-6f6ba4b6d9d4	176	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d3711810-1efd-49aa-ab0d-33116a6cf369	177	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
115ff6ea-38ae-43d5-a097-489224f08af0	178	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
14fdc39b-448a-46ed-8e64-4b6296707396	179	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8dd473c1-5576-425a-83e8-9da9657778ca	180	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a5ad1dc9-6829-4c20-b5e0-c80744af20f3	181	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
47d9ca63-7d8a-46d7-bef7-4e2b5594b6d7	182	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2e9993ad-9dc5-45cf-9091-a247761657e6	183	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
45acf5fc-10a4-4ed7-b699-5516d8a1c35f	184	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b41c94e1-e592-44e3-a87c-1756b6b38726	185	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
48d3b83a-d0d4-4649-9998-950fe947a4bc	186	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
77a0fd4e-fe33-4fcb-b6bf-b6c73ea2aaf9	187	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cfb067f7-242c-4d7e-a167-9d427f4a1ebb	188	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0c9c503c-7d75-4f12-be40-27bff5bf0248	189	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5a64e8a4-5116-4f2c-b335-a03eeacc6c37	190	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
13b5170a-388d-4ac4-a901-449842771e4d	191	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1dac7c58-7130-4c77-8dc8-ead2faa4664a	192	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9105f8f8-bcf7-4193-9b80-0b143fafe2dd	193	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3eeaea56-9622-4acc-a992-891abdb96acf	194	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7728ed5a-8228-463d-8b0b-ebde1a702e3c	195	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
716279bd-8653-4edd-b587-b180167b140c	196	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0c9b3243-d5ee-4c67-9c43-716f15cf6c5e	197	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cb156b6e-6b8a-4ae4-9f22-122e15b5f7ae	198	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
81e35ae2-db06-4b12-89e0-3943e9e0a4c5	199	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
868aa610-5714-4fc0-837e-32e26b80ed68	200	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f4df18e8-d7e2-4357-836d-ed4e2598d7fe	201	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6d6571d5-20ee-457d-a724-8034a7adf4af	202	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2439ef82-638d-45a3-8cdb-73dadee787a9	203	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8c706d58-58f0-4ded-a8e0-caef58947b88	204	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
16d346b1-8366-4322-a6ac-d55f2e8045ba	205	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
884b00cc-0229-4305-968f-b650f1d6f4f0	206	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2280256b-c6b4-4ff5-a06f-7c24d428ab3d	207	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a62c6162-20d3-44d4-a36f-02aa4e1db433	208	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4c2321ba-0eb1-4af5-ac08-f7bb3ce7965f	209	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f11f7efc-15fb-4484-b79c-6ee778b53ed6	210	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
569dac08-9b10-4d81-8094-1837d3da5512	211	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e6e47ac5-45ce-4c92-a10a-9830be2c8b32	212	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4dc23b5a-f002-48ea-9922-6414e7a4eee5	213	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
26549615-e19d-40e4-a84a-6dac53d2629d	214	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
55bc2798-73ff-4510-9eab-7762e353f669	215	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
45dafb55-76e3-4041-a50f-33c003e5ab42	216	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
179c2b6f-f2c6-4537-a67a-c69ef21c9145	217	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0a7fbdf8-9c94-4cf1-9ab5-b0a3ec3edaba	218	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
71406275-eb7f-4b91-b8dd-4653ffa0a6c4	219	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1992a50b-4547-41df-89d8-6799053001cc	220	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4f738a8d-ad33-461c-af4c-ad6924b5e3cf	221	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c2cbfd24-a044-4545-aa77-1b663c552011	222	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
078cb562-9b67-4f43-832e-e623592af5bd	223	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
676079b4-6f45-4dcc-9ea3-f0a4abe2c00a	224	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c394c236-129b-4624-85e8-ccaa682529f1	225	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
893d3b2c-4553-4144-83fb-eaaef8facfc5	226	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
374c7851-d444-47e6-9f92-de8efc67a91d	227	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b96b971c-524b-4e5a-800b-18962418360d	228	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a78bb169-2739-48a2-afbf-33de691a9ecd	229	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2bd00aff-4e7a-4de9-8df9-69f1cb3ec15e	230	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
901ff512-163b-4951-973c-5ab34f755fc2	231	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e434c8d1-a586-46f4-b77a-6716223d8043	232	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8d126cd6-ab34-4486-ac14-69e33b9a4f54	233	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fc87bfc1-2698-4c3e-baf5-5bba43fed754	234	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b712ad20-89e8-40fb-b677-252f0a1ada54	235	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e248ad11-dca8-44ba-aa8a-a52206813c8d	236	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b5322733-e384-4a1d-9149-257509b3f479	237	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cb03d6f6-b498-40f8-858f-5e2aebd3f2a6	238	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d8ee3f32-2313-442c-a907-efff86feb71d	239	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3a02a2de-ef11-4c06-b106-cc3fc2a7cd06	240	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c8947d49-7c66-4345-81a3-dbf0e271c9ef	241	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
744b7b76-3943-4a36-b4e6-4fcfee602211	242	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
108c4a77-f569-4210-a9df-6f5b06cce1b2	243	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2220e7b9-6207-4575-9e74-45d017a9c041	244	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a8834eb3-e154-4b2b-ab84-3675775ec5dd	245	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1c2cc8a0-8498-478a-9b0f-a8fa21c49d79	246	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b97ff5a1-2434-42a6-96a3-f5e6521af601	247	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8ce070b7-26a8-48a9-ba0f-b2f0b04a2204	248	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0da736fd-b309-4a75-a000-c57bc0187c8b	249	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d101d5e0-b3a2-4060-a1c0-50932d268f9b	250	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
902cfe7a-7f09-4c08-a787-3251ed422698	251	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0b7219a2-880c-4264-9cff-45f7cb8a13c2	252	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
96c1e8d4-0452-4fb6-b7ea-5850db40ac5f	253	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
88bcd380-bba0-4f49-8662-5caffa1cdb5c	254	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3f6ffbbf-b254-497d-bff7-9fdc8573131a	255	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
dd0c6b2f-e876-4257-b0a1-49d2c1fd5b89	256	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
10a20d0e-f560-424e-9de4-b3125b171ff1	257	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
89a91647-8fca-4d58-af06-539619a27aab	258	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4bb0b532-3381-4799-8cbc-7b2f797a2a53	259	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e480b662-c91d-4b45-b5a7-081190b5efe4	260	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
43341916-789f-4c29-9263-8dbd88f70fe6	261	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f82ec022-e2fb-464b-a139-d34155396a91	262	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3ce07697-74e2-4a18-b3b3-767f5cf1997a	263	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
485f5489-e5f4-44de-94fa-94e0caab2723	264	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
70217abc-99f1-4c64-b6eb-ec25e881e9af	265	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cd105bbb-d522-4e8f-9657-b28ac3494f54	266	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a9d03fdf-2dd0-4708-934b-586299224337	267	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7ff6066e-6a98-4895-8b90-e9fa3b237d37	268	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e4bcb461-6146-4a9e-abb3-35499916fa7d	269	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
afe5cdfb-1a15-40d9-9e95-3fe5fc504a01	270	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4ae25c91-320c-458d-a787-7f8cb5690cc1	271	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
34102009-8f13-41f9-b611-9d25fb338772	272	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
12b9a40b-8c2f-48ee-8eba-1da5209dc697	273	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
08f7d49e-ac22-448f-9e7e-8969d7afc5d1	274	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1349005b-c882-4a85-bad6-9132f7ae6994	275	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5ae8d9cb-90e7-4df8-804b-9b4c8565bfca	276	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0a94623b-39d8-459e-96cb-425b67f0bd87	277	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
873a26ce-459c-4704-8931-4962a87432dd	278	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6201323f-7321-4cc8-b49f-811f892cb03b	279	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bcf679d6-396d-47a1-b74d-a96d038299c9	280	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f8f879f2-1c98-4344-a0a9-82f379ff853b	281	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
758408ca-d00a-4802-802d-288d8a4f91fd	282	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2cf7140e-c116-4a81-b2b9-ab9d5f5ee0a6	283	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
92a33f44-7293-424c-8633-7b96ebbe067f	284	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
35c9a318-3290-4b7d-9125-f1e1a7677592	285	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f029ed26-1fd8-4b94-a9ca-6d4d31ceb680	286	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
707c2a91-b1aa-49d3-850a-f34d27ccd6f3	287	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9fe7298b-a495-4e77-bbb0-28da22014f2b	288	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a697d956-c306-43a8-b191-2ed1b69836fc	289	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8e5f3e8f-e585-4aa8-ae57-2f771c435f70	290	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d14dc47b-6592-4262-929f-a7142855839a	291	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b267cb43-42ab-4fb6-86a3-ca60c1c1e1d3	292	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b32f0991-1c97-4cee-88fa-629f7fd68322	293	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c8bbd761-a54e-455f-825c-e41428be570f	294	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b06d74bc-249f-4dd5-9314-331de11c0cd2	295	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
89df1a82-3769-415a-be85-14936c88f382	296	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8b80df98-4a01-4dce-b78a-d4bc7aed3491	297	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d6af37b2-9049-4db1-b360-bbb994df411b	298	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1910a966-984a-4cf9-9e17-663971b5e30b	299	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a74b9ff8-7fef-4b1e-b26a-0d01f20e6d02	300	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a3279baa-e1be-480f-a936-5aa815593f74	301	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
78ce581e-249f-491c-bc0c-f65a3de9e790	302	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
dd52e1fa-aeec-43be-ad72-2b30e42e1f8b	303	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
157bcffd-5e42-4924-b9c0-da2807d7edd3	304	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
74f9e2ec-aff5-4cc7-ad10-045a00cd4d94	305	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1372c580-3027-44ab-8d41-87b4ed5b3688	306	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
99e764ff-7735-4848-b486-5b655084d62a	307	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9cac75d6-fcc8-4dad-ab79-6509490ea264	308	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9dcddec9-100a-402e-b0c0-307b730be59c	309	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
751c2ceb-a306-4dd8-be6d-e3bb9b26ac14	310	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1f5edb16-db66-4a7a-a754-2fff639c882b	311	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cd664b01-4118-4efd-be2b-107ac6077706	312	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c8a8489c-03ba-4c3c-9b36-5b51153889c9	313	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a1731526-493c-486a-8a36-30dfd808f0a1	314	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d3d74571-8847-4e6d-ba8a-b3de1830cca5	315	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6a1c7d4d-43db-43a6-bd99-0c011680bf99	316	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
68dcd887-c781-4aab-b1a9-e4dbdbfe931c	317	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bae1adde-1220-4c77-bd6a-bf80827905ce	318	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d7adfcf3-08d0-44d9-871a-757b70089925	319	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d891e826-f7a4-4c69-80dc-1c8d7a442b99	320	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7b0765bd-3ab1-40d6-b608-a4f70458af98	321	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e18f5e35-cbe8-417d-960a-7a4b5e95db1f	322	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
32baf3ee-89bc-4bf0-a279-3327b05a4862	323	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
96e6efb3-6215-4cb2-b2f3-0acb78d8109e	324	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1b587e7a-504e-43ce-b185-b11062dc5c3c	325	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
077e7379-ae0e-42a4-8479-a871204a46d4	326	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2dc9bef8-3d13-46f5-8b1f-dfb8faa502b5	327	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
edf0b45d-8cc9-4f45-9997-4aba55c81d4a	328	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
93ed485c-3b98-4349-a199-cce62a1861b1	329	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c7940412-b1bb-4ed3-9646-6c621af2c3bb	330	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
469c7302-d084-4e2a-8871-7f62dfefc9ea	331	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6f67885a-3833-46c2-b3db-3263def982b8	332	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
99b0c36b-a429-4ac4-8d0a-2fab9aebd487	333	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
29ebd7ad-c20b-4114-a615-3eada29904ad	334	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d22ff81f-9933-410a-8214-f22fee75ef24	335	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
72377616-7e1c-42bd-be2e-3855525d0b3f	336	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
53634a3f-ed70-4594-b74f-1be29a5b5cfd	337	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
94d81eb0-d8cd-4b77-9893-c40ef80f9754	338	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6c4b05fc-b249-46aa-b11a-732a8dac162b	339	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e68313c6-5585-4dd7-a61d-1e11e828b2ff	340	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d551d6ec-4925-4c92-a72e-14d3a6111822	341	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
91fda30b-49df-4046-86ef-6e4bb5deafe6	342	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f6320721-3c67-444d-bc48-479e1c96d0ed	343	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
80c0010c-8b6e-4434-88ca-a766ccc7967e	344	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6505de32-ddf7-4e3f-8ca8-7fdbe6c5e379	345	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ac6c78ea-39b9-4544-97fa-6087350f7e19	346	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d46c774a-10d2-49d4-a436-2ebfbde5edee	347	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a9e161f8-7037-454d-a150-56a89cfb0a6e	348	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3474994b-dcda-4a34-902a-bc69cb2920f8	349	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8a479d0d-2c4c-4ebc-81b4-6d136951d864	350	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f26d9487-df77-405b-86b8-a06b2228df16	351	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1683adb9-d0dd-4246-8db4-3f8a5e5f8c4d	352	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
aedf445b-b0b0-4c6b-a14e-2a8024e8d3ae	353	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bcc88622-7fc1-4cbc-8527-4a4715689233	354	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fd430f09-0f52-468e-966b-6afbf1ed82b6	355	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
06cd6acc-b154-4ba0-b4e4-b1a70048c2cc	356	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4f670aa9-75cf-42b7-ac2d-9be3e9505c37	357	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6faed3ab-0d5b-473e-9a3d-ae40f7f2e756	358	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3302b92d-d535-459a-9d2a-fc8d94eb8448	359	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5137883b-7d62-4794-bbbe-8ed0f50c09f5	360	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2d6fda99-8b5f-4f3e-a602-e7df7eff37cd	361	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4bcb1d80-f67e-438d-bff4-a61ad450637a	362	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9baea575-5f03-4d4c-81c0-465485c27cf6	363	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6ed9e92e-ae5f-4c5d-8f3a-bf90ccbf6111	364	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
37890673-06bd-4a61-a849-c33193131cff	365	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
eaaa19f3-f34c-4928-b0a5-50bf1351e7bc	366	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2a973469-73bc-444d-bb65-f60c3b8cd81b	367	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3e3707cc-1cf9-4a66-86ed-e328c4097674	368	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5bf32871-ca5e-44e2-818a-2bbb9b7190ad	369	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0e0434c8-b21d-4ec0-8562-7f4a857a35a2	370	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c6efaba7-6743-4bc5-bfa6-4a87e3f2d031	371	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
def2fbd8-db98-43d4-b3bc-a3c120804f6d	372	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8209076c-19ad-457c-9a4f-4a5dc5c2ab08	373	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7c3707ff-aa02-4d0d-b726-425d47f08b1b	374	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e56cd96c-bba3-4e06-b0b3-231afce121d1	375	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3406ec79-192d-421c-802e-87b0fb9a1e90	376	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
68972b4c-08f7-4312-bc92-6df6bcb04c40	377	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1e2ecbb8-1bd5-46d8-b740-1193c6cec828	378	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1f8e37c6-4cc8-4d65-8c3f-dd2c026b7b8c	379	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6fe60bf2-1d15-4a7f-a02a-b53fa2f834ae	380	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
352b51c3-1214-47b6-88a7-7a09277a8670	381	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6cbd1741-7818-47fd-b6a4-783f07e4352c	382	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7133a4a3-5731-41c0-ae67-1f9ac6a87163	383	company-admin-default	clean	zone-amb-banheiro	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b8cd4f9c-f068-4f16-b9a9-27f4f2d07834	384	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fc96ba39-231a-4dd4-b0ae-9401677c9e04	385	company-admin-default	clean	zone-adm-acess-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
160e9b54-e2e3-41ed-aac4-e075d566d529	386	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
923fcf61-c1cd-4f8c-b931-45bccaeade39	387	company-admin-default	clean	zone-ref-fem-coz	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2cef74a5-9652-4973-9f41-6901e5938d8f	388	company-admin-default	clean	zone-prod-fem-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
548ed8b5-5e59-49af-b750-62f3138fe798	389	company-admin-default	clean	zone-prod-fem-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c663318b-1cc2-457b-85fc-b7a4b49e09df	390	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6978c5ff-45d7-4766-bdd2-12b6baf5ae75	391	company-admin-default	clean	zone-prod-fem-scania	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
cd8f67f5-5c58-493a-bcae-627c320160d4	392	company-admin-default	clean	zone-adm-fem-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
56a43293-10ab-48db-9d48-bfce8ec7c73c	393	company-admin-default	clean	zone-prod-fem-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
194e69bf-a213-4a04-9f9f-9d3b485bffb6	394	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
665cf8fc-bc84-44f2-94ab-3f8ee62f295f	395	company-admin-default	clean	zone-prod-masc-gm	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a5373390-44e2-4f69-9e15-5369b61d930e	396	company-admin-default	clean	zone-prod-masc-log	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
62c0805c-e998-4cb8-aedb-6d74d02e2864	397	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
eab4c90e-2f9a-4baf-9230-5dd9c8ba030c	398	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
57c217fa-210e-4469-8eae-0eadafb0518b	399	company-admin-default	clean	zone-prod-masc-toyota	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b73f52b8-952b-4cd8-a793-16325b972efd	400	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1762880431187-33swhqv3w	\N	checklist-1762880029053-PcbN4fv6Ax	\N	\N	\N	programada	aberta	media	Limpeza de banheiros		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 17:00:31.618592	2025-11-11 17:00:31.618592	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a53c2f2a-1a28-4789-9fde-729cdf1ba113	1	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
5d72e422-854e-48e0-8041-8bf10bb20b59	2	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
34d4166c-882c-4c7f-9bc8-eae58a17e967	4	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
8da0ed81-11fc-4b25-9725-0b9c82c23c2e	5	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
bf2ef1b8-bd57-4724-90c0-b4ab75627a1f	6	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
b12519e7-e4f2-4d07-8a05-85549b269cfe	7	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
0751455b-c67c-46ea-9edc-1e4b0f139938	8	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13 08:00:00	2025-11-13 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
0d63c783-23af-40c5-94d5-0634b7b430fd	9	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
857fbe43-2e6b-4927-b002-41df6f79d60c	10	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
fb9a07d8-1b63-4a96-a90c-45a745fe8616	11	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
bb05cbcd-2a3f-46bb-b5bd-1d407b63536b	12	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14 08:00:00	2025-11-14 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
8b5702ee-a819-49e3-8eee-645710bb68ad	13	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
22a9c5d2-0578-4d1c-9e62-aaaab3f757f6	14	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
3eac5c26-3e3d-452c-ad2f-7cac94cd1c3c	15	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
afed6ad9-4cf4-4e97-9575-7bbafdb4a7ae	16	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15 08:00:00	2025-11-15 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
2f2ba52c-83fb-4873-9a08-60c19ad6210a	17	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
54f03673-2ca8-4422-bb15-053fa8ce18c2	18	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
21dcc7cd-01ce-4a6d-b0c0-90c6b55eaae3	19	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
6bee6725-6706-4f5a-b32b-7ce03eaca4c1	20	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16 08:00:00	2025-11-16 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
31b247bd-52a4-4618-8c96-f681f8b40598	21	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
8a4b6ceb-287a-4fae-b7f2-7e10621a05d2	22	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
7e190336-b7cc-4887-b29a-0bc2d5cf3d7a	23	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
5779f4ff-f527-4ce9-b63a-fe34530f8143	24	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17 08:00:00	2025-11-17 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
013d2b2e-98b1-476d-9704-b7661bc03cb2	25	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
ad8ece34-2002-4ba7-96f2-4a2bbb8c50f5	26	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
b5b694e1-0c23-450e-9ebe-10a927d2553e	27	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
ebe7787e-6607-4bce-8d95-6572caf5bfbe	28	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18 08:00:00	2025-11-18 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
429b9cdb-5904-498c-848a-7843e52a5f22	29	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
d7601833-afce-4fa3-a215-ea86f8e403eb	30	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
e32fc531-1781-47f4-9aae-88465196061c	31	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
158cdedb-8e1c-4996-8038-93027453fabf	32	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19 08:00:00	2025-11-19 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
dae1eaf6-0150-4c27-962b-f6698955abd4	33	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
e0c7c695-0303-4001-8878-c491c15383b6	34	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
b283efc8-5a6a-4c78-9b80-c12d068584fb	35	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
1b7a6e49-9077-44fc-b16f-1a5c57875c30	36	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20 08:00:00	2025-11-20 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
f97b526c-d802-4a7c-9acf-028bbf489e41	37	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
a8b4acd4-deae-41b2-8ca5-2a189826971b	38	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
263ab08b-bd10-4b3a-878c-2c63ead330c7	39	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
72b85d68-31db-4883-a993-ebaad9660364	40	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21 08:00:00	2025-11-21 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
50720cc7-8a48-4146-9d85-e7fcfafd8d02	41	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
f55a86c0-e9af-466b-be89-101d1d676609	42	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
8bdef722-24de-421c-a7ca-0d3a86db6548	43	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
84716c6f-1443-4730-a922-a0473bb01cd5	44	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22 08:00:00	2025-11-22 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
2d8f4296-072a-4b12-8ee1-210dace6bb23	45	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
d2ac10ee-2c84-4687-9a19-be79d8b359f2	46	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
b0a1064e-1456-4909-85d7-919825da5460	47	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
d9622c56-cf40-4385-bae5-bb12839d0f91	48	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23 08:00:00	2025-11-23 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
df3d419d-839d-4a58-bb89-fc0ad63b58d1	49	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
395f602d-e118-41bf-a4eb-554cf722d40e	50	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
d4653e6c-c9c5-4cc5-a60b-2b439c9868c3	51	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
102cd253-d9a4-4fe4-83f8-17827e9e59f0	52	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24 08:00:00	2025-11-24 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
731f4116-a8b0-4766-beb8-5539ab18a724	53	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
39a0640d-0811-415e-96c0-165ffabea322	54	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
5e060b03-b278-4085-8a5f-025378269b3a	55	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
391aad24-4794-4b31-ad9f-7cd65e53bf3f	56	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25 08:00:00	2025-11-25 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
9052169e-e621-4fe2-8db5-d018a9e1795f	57	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
bcb51d46-b469-4d9e-9dd7-4f9ac00d55cc	58	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
ec850599-f183-4b12-9b01-6e6c083b7dc0	59	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
a9c44ccb-6ecf-4ed4-9d70-f7bac435ba08	60	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26 08:00:00	2025-11-26 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
b048ace2-f785-4b71-84a6-d042d8c0de64	61	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
ea82c1a8-4f30-4ba1-8411-cb51bacf90f2	62	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
0c200f8d-730d-49a4-a11d-e3f2e0d19bc9	63	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
ebd19462-cc61-414d-afc0-b770bdab2547	64	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27 08:00:00	2025-11-27 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
7e7e1883-3704-4cd5-8e96-595513485c3d	65	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
20cdf814-ca83-470e-8795-8b2ef8e9c295	66	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
365cab7b-fb3e-481a-aa2b-5d963e54a267	67	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
31b59c0f-c364-4f4d-845f-0399ca19f431	68	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28 08:00:00	2025-11-28 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
2b5eb2bd-eb54-477e-bd74-73993752940e	69	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
ea3cd88c-c933-4517-a508-7f6fc326cb38	70	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
8cbc3d9a-6d5e-4087-8915-2c70bef0f335	71	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
642b4950-20d3-4541-bdf5-c7f6e71e924c	72	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29 08:00:00	2025-11-29 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
d5010089-c95b-474e-9be2-cf4bbff60c34	73	company-admin-default	clean	c9621786-3bab-4a67-b23d-d4e5f753b4af	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
0fcded8e-cf12-4fa3-a1f9-5e5fc78afa29	74	company-admin-default	clean	47266a3a-57c3-4745-91fe-f0cde2754941	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
7b5c8344-a430-42f0-acbf-ba997297c23b	75	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
9612fd55-cc1e-43be-899b-d100dcbe1cb8	76	company-admin-default	clean	a0d972f8-301f-4385-9e62-3c352683b6c7	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	aberta	media	Teste		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30 08:00:00	2025-11-30 10:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 19:51:59.039256	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	\N
bbf94365-6acd-4130-b45b-a41250beb308	3	company-admin-default	clean	94b64481-098c-40dc-b852-bb3e52a545c9	092ec8ec-352e-4e75-807f-136400f0f4ef	ca-1762977118730-i8nf6jpjl	\N	checklist-1762973486570-4x-EwqJ3lB	\N	\N	\N	programada	concluida	media	Teste		user-joao.solva-1762977575399	Sistema - Cronograma	\N	\N	\N	2025-11-12 08:00:00	2025-11-12 10:00:00	\N	\N	2025-11-12 20:00:08.717	2025-11-12 20:00:15.368	\N	\N	\N	\N	{"1762973440515": "H"}	\N	\N	\N	\N	\N	2025-11-12 19:51:59.039256	2025-11-12 20:00:16.007221	\N	\N	\N	783a6a21-aa25-421d-b1da-bbd03410f2c5	{user-joao.solva-1762977575399}
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zones (id, site_id, module, name, description, area_m2, capacity, category, position_x, position_y, size_scale, color, is_active, created_at, updated_at) FROM stdin;
46dc2ae0-ebab-488c-be31-63ef3365f0cb	ae97c9e2-77cc-4ac9-b31a-bfd16f74f29b	clean	Banheiro Masc. - H.P	\N	40.00	5	banheiro	58.75	52.65	1.00	\N	t	2025-11-10 23:03:29.614165	2025-11-10 23:03:29.614165
ecdb8f51-938c-42c7-be76-f1ede07cb690	ae97c9e2-77cc-4ac9-b31a-bfd16f74f29b	clean	Escritório	\N	80.00	8	escritorio	71.91	29.14	1.00	\N	t	2025-11-10 23:03:47.046515	2025-11-10 23:03:47.046515
a12d6f27-ac7a-4851-b37f-14ef855b8b0e	366ab13e-e56a-417a-b8c3-07d9d1ca4264	maintenance	Cabine de manutenção	\N	90.00	8	producao	37.07	49.51	1.00	\N	t	2025-11-10 23:28:43.046143	2025-11-10 23:29:53.293349
7c9bc3ac-1e99-4f19-9726-573a4569918d	366ab13e-e56a-417a-b8c3-07d9d1ca4264	maintenance	Linha de montagem	\N	130.00	13	producao	26.75	25.05	1.00	\N	t	2025-11-10 23:29:33.840956	2025-11-10 23:29:53.294155
zone-vest-masc-01	site-faurecia-vestiarios	clean	VESTIÁRIO MASCULINO -01	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:15.824841	2025-11-11 03:42:15.824841
zone-vest-masc-02	site-faurecia-vestiarios	clean	VESTIÁRIO MASCULINO -02	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:16.031496	2025-11-11 03:42:16.031496
zone-vest-fem	site-faurecia-vestiarios	clean	VESTIÁRIO FEMININO	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:16.234082	2025-11-11 03:42:16.234082
zone-amb-banheiro	site-faurecia-ambulatorio	clean	BANHEIRO AMBULATÓRIO	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:16.436431	2025-11-11 03:42:16.436431
zone-ref-fem-coz	site-faurecia-refeitorio	clean	BANHEIRO FEMININO COZINHA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:16.64341	2025-11-11 03:42:16.64341
zone-port-masc	site-faurecia-portaria	clean	BANHEIRO MASCULINO PORTARIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:16.848015	2025-11-11 03:42:16.848015
zone-port-fem	site-faurecia-portaria	clean	BANHEIRO FEMININO PORTARIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:17.051667	2025-11-11 03:42:17.051667
zone-prod-masc-gm	site-faurecia-producao	clean	BANHEIRO MASCULINO GM	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:18.065056	2025-11-11 03:42:18.065056
zone-prod-fem-toyota	site-faurecia-producao	clean	BANHEIRO FEMININO TOYOTA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:18.266985	2025-11-11 03:42:18.266985
zone-prod-fem-scania	site-faurecia-producao	clean	BANHEIRO FEMININO SCANIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:18.469259	2025-11-11 03:42:18.469259
zone-prod-fem-log	site-faurecia-producao	clean	BANHEIRO FEMININO LOGÍSTICA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:18.673354	2025-11-11 03:42:18.673354
zone-prod-masc-scania	site-faurecia-producao	clean	BANHEIRO MASCULINO SCANIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:19.887077	2025-11-11 03:42:19.887077
zone-prod-masc-log	site-faurecia-producao	clean	BANHEIRO MASCULINO LOGÍSTICA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:20.088682	2025-11-11 03:42:20.088682
zone-prod-masc-toyota	site-faurecia-producao	clean	BANHEIRO MASCULINO TOYOTA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:20.292466	2025-11-11 03:42:20.292466
zone-prod-fem-gm	site-faurecia-producao	clean	BANHEIRO FEMININO GM	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-11-11 03:42:20.495441	2025-11-11 03:42:20.495441
2ba21003-b82d-4950-8a6b-f504740960ea	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Estática SMC Fante	\N	20.00	\N	producao	\N	\N	\N	\N	t	2025-11-11 03:42:20.70394	2025-11-11 03:42:20.70394
20864c38-1234-46e6-8581-46e3c55a9b87	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Pintura RTM	\N	\N	\N	producao	\N	\N	\N	\N	t	2025-11-11 03:42:20.905489	2025-11-11 03:42:20.905489
2d9936f6-6093-4885-b0bf-cf655f559dbc	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Pintura Estatica	\N	12.00	\N	producao	\N	\N	\N	\N	t	2025-11-11 03:42:21.107393	2025-11-11 03:42:21.107393
a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Pintura SMC	\N	\N	\N	producao	\N	\N	\N	\N	t	2025-11-11 03:42:21.309984	2025-11-11 03:42:21.309984
zone-adm-masc	site-faurecia-administrativo	clean	BANHEIRO ADM MASCULINO	\N	\N	\N	banheiro	64.05	21.41	\N	\N	t	2025-11-11 03:42:17.254436	2025-11-11 03:48:40.641133
zone-adm-acess-01	site-faurecia-administrativo	clean	BANHEIRO CORPORATIVO ACESSÍVEL 01	\N	\N	\N	banheiro	53.07	48.97	\N	\N	t	2025-11-11 03:42:17.659075	2025-11-11 03:48:40.643794
zone-adm-fem-corp	site-faurecia-administrativo	clean	BANHEIRO FEMININO CORPORATIVO	\N	\N	\N	banheiro	65.88	48.82	\N	\N	t	2025-11-11 03:42:17.457165	2025-11-11 03:48:40.645071
zone-adm-fem-tech	site-faurecia-administrativo	clean	BANHEIRO FEMININO TECH CENTER	\N	\N	\N	banheiro	37.06	24.47	\N	\N	t	2025-11-11 03:42:18.875139	2025-11-11 03:48:40.642788
zone-adm-fem	site-faurecia-administrativo	clean	BANHEIRO ADM FEMININO	\N	\N	\N	banheiro	23.33	19.95	\N	\N	t	2025-11-11 03:42:19.078163	2025-11-11 03:48:40.647003
zone-adm-acess-02	site-faurecia-administrativo	clean	BANHEIRO CORPORATIVO ACESSÍVEL 02	\N	\N	\N	banheiro	15.00	75.00	\N	\N	t	2025-11-11 03:42:17.861485	2025-11-11 03:48:40.647697
zone-adm-masc-corp	site-faurecia-administrativo	clean	BANHEIRO MASCULINO CORPORATIVO	\N	\N	\N	banheiro	50.33	20.97	\N	\N	t	2025-11-11 03:42:19.684754	2025-11-11 03:48:40.894648
zone-adm-masc-tech	site-faurecia-administrativo	clean	BANHEIRO MASCULINO TECH CENTER	\N	\N	\N	banheiro	39.44	48.38	\N	\N	t	2025-11-11 03:42:19.280247	2025-11-11 03:48:40.900037
zone-adm-unissex	site-faurecia-administrativo	clean	BANHEIRO UNISSEX RECEPÇÃO	\N	\N	\N	banheiro	23.24	48.82	\N	\N	t	2025-11-11 03:42:19.482237	2025-11-11 03:48:40.901294
72487a65-2d86-47af-ba69-5402714225bc	ae97c9e2-77cc-4ac9-b31a-bfd16f74f29b	clean	Cabine 2	\N	40.00	2	producao	47.18	23.55	1.00	\N	t	2025-11-11 04:56:58.101451	2025-11-11 04:57:10.624944
a92f658a-9440-4a9e-8b92-49e8113d6fbb	ff191700-ac34-4df7-accc-1d420568d645	clean	Banheiros	\N	\N	\N	banheiro	36.43	49.85	1.00	\N	t	2025-11-11 16:18:23.276255	2025-11-11 16:18:23.276255
c9621786-3bab-4a67-b23d-d4e5f753b4af	91895d5b-c095-4238-a9c0-d06485ed0ee7	clean	Zona 1	\N	\N	\N	banheiro	35.62	56.22	1.00	\N	t	2025-11-12 18:35:21.971104	2025-11-12 18:35:21.971104
a0d972f8-301f-4385-9e62-3c352683b6c7	91895d5b-c095-4238-a9c0-d06485ed0ee7	clean	Zona 2	\N	\N	\N	banheiro	71.45	29.40	1.00	\N	t	2025-11-12 18:35:29.499618	2025-11-12 18:35:29.499618
47266a3a-57c3-4745-91fe-f0cde2754941	cd953978-a480-4b4b-a3eb-11fc09965748	clean	Zona 1 Local 2	\N	\N	\N	banheiro	24.45	59.87	1.00	\N	t	2025-11-12 18:35:40.799128	2025-11-12 18:35:40.799128
94b64481-098c-40dc-b852-bb3e52a545c9	cd953978-a480-4b4b-a3eb-11fc09965748	clean	Zona 2 Local 2	\N	\N	\N	banheiro	26.28	62.81	1.00	\N	t	2025-11-12 18:35:47.778439	2025-11-12 19:53:03.299302
\.


--
-- Name: ai_integrations ai_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_pkey PRIMARY KEY (id);


--
-- Name: bathroom_counters bathroom_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bathroom_counters
    ADD CONSTRAINT bathroom_counters_pkey PRIMARY KEY (id);


--
-- Name: chat_conversations chat_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: checklist_templates checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: cleaning_activities cleaning_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_counters company_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_counters
    ADD CONSTRAINT company_counters_pkey PRIMARY KEY (id);


--
-- Name: custom_roles custom_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_roles
    ADD CONSTRAINT custom_roles_pkey PRIMARY KEY (id);


--
-- Name: customer_counters customer_counters_customer_key_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_customer_key_unique UNIQUE (customer_id, key);


--
-- Name: customer_counters customer_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: dashboard_goals dashboard_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_goals
    ADD CONSTRAINT dashboard_goals_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_serial_number_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_serial_number_unique UNIQUE (serial_number);


--
-- Name: equipment_types equipment_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_pkey PRIMARY KEY (id);


--
-- Name: maintenance_activities maintenance_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_pkey PRIMARY KEY (id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_pkey PRIMARY KEY (id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plans maintenance_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_pkey PRIMARY KEY (id);


--
-- Name: public_request_logs public_request_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_request_logs
    ADD CONSTRAINT public_request_logs_pkey PRIMARY KEY (id);


--
-- Name: qr_code_points qr_code_points_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_code_unique UNIQUE (code);


--
-- Name: qr_code_points qr_code_points_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: service_categories service_categories_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_code_unique UNIQUE (code);


--
-- Name: service_categories service_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_pkey PRIMARY KEY (id);


--
-- Name: service_types service_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_pkey PRIMARY KEY (id);


--
-- Name: service_zones service_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: site_shifts site_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_shifts
    ADD CONSTRAINT site_shifts_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: sla_configs sla_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sla_configs
    ADD CONSTRAINT sla_configs_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plan_equipments unique_plan_equipment; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT unique_plan_equipment UNIQUE (plan_id, equipment_id);


--
-- Name: service_zones unique_service_zone; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT unique_service_zone UNIQUE (service_id, zone_id);


--
-- Name: user_allowed_customers user_allowed_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_allowed_customers
    ADD CONSTRAINT user_allowed_customers_pkey PRIMARY KEY (id);


--
-- Name: user_allowed_customers user_allowed_customers_user_id_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_allowed_customers
    ADD CONSTRAINT user_allowed_customers_user_id_customer_id_key UNIQUE (user_id, customer_id);


--
-- Name: user_role_assignments user_role_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_pkey PRIMARY KEY (id);


--
-- Name: user_site_assignments user_site_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: webhook_configs webhook_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook_configs
    ADD CONSTRAINT webhook_configs_pkey PRIMARY KEY (id);


--
-- Name: work_order_comments work_order_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: customers_subdomain_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX customers_subdomain_unique ON public.customers USING btree (subdomain) WHERE (subdomain IS NOT NULL);


--
-- Name: work_orders_customer_number_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX work_orders_customer_number_unique ON public.work_orders USING btree (customer_id, number);


--
-- Name: ai_integrations ai_integrations_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: ai_integrations ai_integrations_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: audit_logs audit_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_counter_id_bathroom_counters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_counter_id_bathroom_counters_id_fk FOREIGN KEY (counter_id) REFERENCES public.bathroom_counters(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_work_order_id_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_work_order_id_work_orders_id_fk FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: bathroom_counters bathroom_counters_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bathroom_counters
    ADD CONSTRAINT bathroom_counters_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: chat_conversations chat_conversations_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: chat_conversations chat_conversations_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: chat_conversations chat_conversations_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: chat_messages chat_messages_ai_integration_id_ai_integrations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_ai_integration_id_ai_integrations_id_fk FOREIGN KEY (ai_integration_id) REFERENCES public.ai_integrations(id);


--
-- Name: chat_messages chat_messages_conversation_id_chat_conversations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_conversation_id_chat_conversations_id_fk FOREIGN KEY (conversation_id) REFERENCES public.chat_conversations(id) ON DELETE CASCADE;


--
-- Name: checklist_templates checklist_templates_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: checklist_templates checklist_templates_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: checklist_templates checklist_templates_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: checklist_templates checklist_templates_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: checklist_templates checklist_templates_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: cleaning_activities cleaning_activities_checklist_template_id_checklist_templates_i; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_checklist_template_id_checklist_templates_i FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: cleaning_activities cleaning_activities_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: cleaning_activities cleaning_activities_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: cleaning_activities cleaning_activities_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: cleaning_activities cleaning_activities_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: cleaning_activities cleaning_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: cleaning_activities cleaning_activities_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: company_counters company_counters_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_counters
    ADD CONSTRAINT company_counters_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: custom_roles custom_roles_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_roles
    ADD CONSTRAINT custom_roles_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: customer_counters customer_counters_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers customers_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: dashboard_goals dashboard_goals_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_goals
    ADD CONSTRAINT dashboard_goals_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: equipment equipment_equipment_type_id_equipment_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_equipment_type_id_equipment_types_id_fk FOREIGN KEY (equipment_type_id) REFERENCES public.equipment_types(id);


--
-- Name: equipment equipment_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: equipment_types equipment_types_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: maintenance_activities maintenance_activities_assigned_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_assigned_user_id_users_id_fk FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: maintenance_activities maintenance_activities_checklist_template_id_maintenance_checkl; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_checklist_template_id_maintenance_checkl FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_activities maintenance_activities_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_activities maintenance_activities_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: maintenance_activities maintenance_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_checklist_template_id_maintena; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_checklist_template_id_maintena FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_executed_by_user_id_users_id_f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_executed_by_user_id_users_id_f FOREIGN KEY (executed_by_user_id) REFERENCES public.users(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_work_order_id_work_orders_id_f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_work_order_id_work_orders_id_f FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_checklist_template_id_maintenance_c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_checklist_template_id_maintenance_c FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_plan_id_maintenance_plans_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_plan_id_maintenance_plans_id_fk FOREIGN KEY (plan_id) REFERENCES public.maintenance_plans(id);


--
-- Name: maintenance_plans maintenance_plans_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_plans maintenance_plans_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: public_request_logs public_request_logs_qr_code_point_id_qr_code_points_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_request_logs
    ADD CONSTRAINT public_request_logs_qr_code_point_id_qr_code_points_id_fk FOREIGN KEY (qr_code_point_id) REFERENCES public.qr_code_points(id);


--
-- Name: qr_code_points qr_code_points_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: qr_code_points qr_code_points_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: qr_code_points qr_code_points_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: role_permissions role_permissions_role_id_custom_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_custom_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.custom_roles(id);


--
-- Name: service_categories service_categories_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: service_categories service_categories_type_id_service_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_type_id_service_types_id_fk FOREIGN KEY (type_id) REFERENCES public.service_types(id);


--
-- Name: service_types service_types_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: service_types service_types_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: service_zones service_zones_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: service_zones service_zones_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: services services_category_id_service_categories_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_category_id_service_categories_id_fk FOREIGN KEY (category_id) REFERENCES public.service_categories(id);


--
-- Name: services services_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: services services_type_id_service_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_type_id_service_types_id_fk FOREIGN KEY (type_id) REFERENCES public.service_types(id);


--
-- Name: site_shifts site_shifts_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_shifts
    ADD CONSTRAINT site_shifts_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: sites sites_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: sites sites_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: sla_configs sla_configs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sla_configs
    ADD CONSTRAINT sla_configs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: user_allowed_customers user_allowed_customers_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_allowed_customers
    ADD CONSTRAINT user_allowed_customers_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: user_allowed_customers user_allowed_customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_allowed_customers
    ADD CONSTRAINT user_allowed_customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_role_assignments user_role_assignments_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: user_role_assignments user_role_assignments_role_id_custom_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_role_id_custom_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.custom_roles(id);


--
-- Name: user_role_assignments user_role_assignments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_site_assignments user_site_assignments_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: user_site_assignments user_site_assignments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: users users_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: webhook_configs webhook_configs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.webhook_configs
    ADD CONSTRAINT webhook_configs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: work_order_comments work_order_comments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: work_order_comments work_order_comments_work_order_id_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_work_order_id_work_orders_id_fk FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: work_orders work_orders_assigned_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_assigned_user_id_users_id_fk FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_cancelled_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_cancelled_by_users_id_fk FOREIGN KEY (cancelled_by) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_checklist_template_id_checklist_templates_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_checklist_template_id_checklist_templates_id_fk FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: work_orders work_orders_cleaning_activity_id_cleaning_activities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_cleaning_activity_id_cleaning_activities_id_fk FOREIGN KEY (cleaning_activity_id) REFERENCES public.cleaning_activities(id);


--
-- Name: work_orders work_orders_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: work_orders work_orders_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: work_orders work_orders_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: work_orders work_orders_maintenance_activity_id_maintenance_activities_id_f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_activity_id_maintenance_activities_id_f FOREIGN KEY (maintenance_activity_id) REFERENCES public.maintenance_activities(id);


--
-- Name: work_orders work_orders_maintenance_checklist_template_id_maintenance_check; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_checklist_template_id_maintenance_check FOREIGN KEY (maintenance_checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: work_orders work_orders_maintenance_plan_equipment_id_maintenance_plan_equi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_plan_equipment_id_maintenance_plan_equi FOREIGN KEY (maintenance_plan_equipment_id) REFERENCES public.maintenance_plan_equipments(id);


--
-- Name: work_orders work_orders_qr_code_point_id_qr_code_points_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_qr_code_point_id_qr_code_points_id_fk FOREIGN KEY (qr_code_point_id) REFERENCES public.qr_code_points(id);


--
-- Name: work_orders work_orders_rated_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_rated_by_users_id_fk FOREIGN KEY (rated_by) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: work_orders work_orders_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: zones zones_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

