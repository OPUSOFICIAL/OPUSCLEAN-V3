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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: neondb_owner
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO neondb_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: neondb_owner
--

COMMENT ON SCHEMA public IS '';


--
-- Name: ai_integration_status; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.ai_integration_status AS ENUM (
    'ativa',
    'inativa',
    'erro'
);


ALTER TYPE public.ai_integration_status OWNER TO neondb_owner;

--
-- Name: ai_provider; Type: TYPE; Schema: public; Owner: neondb_owner
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


ALTER TYPE public.ai_provider OWNER TO neondb_owner;

--
-- Name: auth_provider; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.auth_provider AS ENUM (
    'local',
    'microsoft'
);


ALTER TYPE public.auth_provider OWNER TO neondb_owner;

--
-- Name: bathroom_counter_action; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.bathroom_counter_action AS ENUM (
    'increment',
    'decrement',
    'reset'
);


ALTER TYPE public.bathroom_counter_action OWNER TO neondb_owner;

--
-- Name: equipment_status; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.equipment_status AS ENUM (
    'operacional',
    'em_manutencao',
    'inoperante',
    'aposentado'
);


ALTER TYPE public.equipment_status OWNER TO neondb_owner;

--
-- Name: frequency; Type: TYPE; Schema: public; Owner: neondb_owner
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


ALTER TYPE public.frequency OWNER TO neondb_owner;

--
-- Name: module; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.module AS ENUM (
    'clean',
    'maintenance'
);


ALTER TYPE public.module OWNER TO neondb_owner;

--
-- Name: permission_key; Type: TYPE; Schema: public; Owner: neondb_owner
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


ALTER TYPE public.permission_key OWNER TO neondb_owner;

--
-- Name: priority; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.priority AS ENUM (
    'baixa',
    'media',
    'alta',
    'critica'
);


ALTER TYPE public.priority OWNER TO neondb_owner;

--
-- Name: qr_code_type; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.qr_code_type AS ENUM (
    'execucao',
    'atendimento'
);


ALTER TYPE public.qr_code_type OWNER TO neondb_owner;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'gestor_cliente',
    'supervisor_site',
    'operador',
    'auditor'
);


ALTER TYPE public.user_role OWNER TO neondb_owner;

--
-- Name: user_type; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.user_type AS ENUM (
    'opus_user',
    'customer_user'
);


ALTER TYPE public.user_type OWNER TO neondb_owner;

--
-- Name: work_order_status; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.work_order_status AS ENUM (
    'aberta',
    'em_execucao',
    'pausada',
    'vencida',
    'concluida',
    'cancelada'
);


ALTER TYPE public.work_order_status OWNER TO neondb_owner;

--
-- Name: work_order_type; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.work_order_type AS ENUM (
    'programada',
    'corretiva_interna',
    'corretiva_publica'
);


ALTER TYPE public.work_order_type OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_integrations; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.ai_integrations OWNER TO neondb_owner;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.audit_logs OWNER TO neondb_owner;

--
-- Name: bathroom_counter_logs; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.bathroom_counter_logs OWNER TO neondb_owner;

--
-- Name: bathroom_counters; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.bathroom_counters OWNER TO neondb_owner;

--
-- Name: chat_conversations; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.chat_conversations OWNER TO neondb_owner;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.chat_messages OWNER TO neondb_owner;

--
-- Name: checklist_templates; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.checklist_templates OWNER TO neondb_owner;

--
-- Name: cleaning_activities; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.cleaning_activities OWNER TO neondb_owner;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.companies OWNER TO neondb_owner;

--
-- Name: company_counters; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.company_counters (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    key character varying NOT NULL,
    next_number integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.company_counters OWNER TO neondb_owner;

--
-- Name: custom_roles; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.custom_roles OWNER TO neondb_owner;

--
-- Name: customer_counters; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.customer_counters (
    id character varying NOT NULL,
    customer_id character varying NOT NULL,
    key character varying NOT NULL,
    next_number integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.customer_counters OWNER TO neondb_owner;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: neondb_owner
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
    module_colors jsonb
);


ALTER TABLE public.customers OWNER TO neondb_owner;

--
-- Name: dashboard_goals; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.dashboard_goals OWNER TO neondb_owner;

--
-- Name: equipment; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.equipment OWNER TO neondb_owner;

--
-- Name: equipment_types; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.equipment_types OWNER TO neondb_owner;

--
-- Name: maintenance_activities; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.maintenance_activities OWNER TO neondb_owner;

--
-- Name: maintenance_checklist_executions; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.maintenance_checklist_executions OWNER TO neondb_owner;

--
-- Name: maintenance_checklist_templates; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.maintenance_checklist_templates OWNER TO neondb_owner;

--
-- Name: maintenance_plan_equipments; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.maintenance_plan_equipments OWNER TO neondb_owner;

--
-- Name: maintenance_plans; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.maintenance_plans OWNER TO neondb_owner;

--
-- Name: public_request_logs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.public_request_logs (
    id character varying NOT NULL,
    qr_code_point_id character varying,
    ip_hash character varying NOT NULL,
    user_agent text,
    request_data jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.public_request_logs OWNER TO neondb_owner;

--
-- Name: qr_code_points; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.qr_code_points OWNER TO neondb_owner;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.role_permissions (
    id character varying NOT NULL,
    role_id character varying NOT NULL,
    permission public.permission_key NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.role_permissions OWNER TO neondb_owner;

--
-- Name: service_categories; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.service_categories OWNER TO neondb_owner;

--
-- Name: service_types; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.service_types OWNER TO neondb_owner;

--
-- Name: service_zones; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.service_zones (
    id character varying NOT NULL,
    service_id character varying NOT NULL,
    zone_id character varying NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.service_zones OWNER TO neondb_owner;

--
-- Name: services; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.services OWNER TO neondb_owner;

--
-- Name: site_shifts; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.site_shifts OWNER TO neondb_owner;

--
-- Name: sites; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.sites OWNER TO neondb_owner;

--
-- Name: sla_configs; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.sla_configs OWNER TO neondb_owner;

--
-- Name: user_role_assignments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.user_role_assignments (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    role_id character varying NOT NULL,
    customer_id character varying,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_role_assignments OWNER TO neondb_owner;

--
-- Name: user_site_assignments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.user_site_assignments (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    site_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_site_assignments OWNER TO neondb_owner;

--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: webhook_configs; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.webhook_configs OWNER TO neondb_owner;

--
-- Name: work_order_comments; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.work_order_comments OWNER TO neondb_owner;

--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.work_orders OWNER TO neondb_owner;

--
-- Name: zones; Type: TABLE; Schema: public; Owner: neondb_owner
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


ALTER TABLE public.zones OWNER TO neondb_owner;

--
-- Data for Name: ai_integrations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.ai_integrations (id, company_id, name, provider, model, api_key, endpoint, status, is_default, max_tokens, temperature, enable_logs, last_tested_at, last_error_message, created_by, created_at, updated_at) FROM stdin;
Opy5Y3iHROPLiXYakM06V	company-admin-default	Facilities Cloud	groq	llama-3.3-70b-versatile	2c7c3deed20a652675d3afb198666392:dd36d42bb397ff2e109d11ac166e55ad:a41413f5bd5001311d9f133410770bc0ab629d054d684b0f30a94ab917b4a29fb13226342efccfa3bf562cbb882a2ad1bf34f5e0de11a07e		ativa	t	4096	0.70	f	\N	\N	user-admin-opus	2025-11-11 04:06:02.553184	2025-11-11 04:06:02.553184
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
\.


--
-- Data for Name: bathroom_counter_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.bathroom_counter_logs (id, counter_id, user_id, delta, action, previous_value, new_value, work_order_id, created_at) FROM stdin;
\.


--
-- Data for Name: bathroom_counters; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.bathroom_counters (id, zone_id, current_count, limit_count, last_reset, auto_reset_turn, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: chat_conversations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.chat_conversations (id, user_id, company_id, customer_id, module, title, is_active, created_at, updated_at) FROM stdin;
Oi9yv8DgY4AyaDSwv7rYP	user-admin-opus	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	clean	oi	t	2025-11-11 04:06:10.394803	2025-11-11 04:06:10.394803
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
-- Data for Name: checklist_templates; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.checklist_templates (id, company_id, service_id, site_id, name, description, items, module, created_at, updated_at, zone_id, site_ids, zone_ids) FROM stdin;
checklist-1761858946503-LOru9jEbKQ	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	WC Feminino corporativo	Limpeza e reposição de de descartáveis WC feminino corporativo	[]	clean	2025-11-11 03:44:04.864905	2025-11-11 03:44:04.864905	\N	\N	\N
checklist-1761786488474-q61adWy1TV	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Masculino Tech center	Realizar limpeza e abastecimento de descartáveis do WC masculino tech center	[{"id": "1761785538950", "type": "checkbox", "label": "Limpeza do piso, foi feita ?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761785621669", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["Ok", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761785809069", "type": "checkbox", "label": "Lavar piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761785998964", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786314983", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786370307", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786450411", "type": "checkbox", "label": "Limpeza de interruptores e bancos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761786512845", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:43:03.673194	2025-11-11 05:37:28.562862	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1761861999785-cVnkJ8I1Xg	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro Corporativo Acessível 02	Limpeza e troca de descartáveis do banheiro masculino ADM RH	[{"id": "1761861638633", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761861697045", "type": "checkbox", "label": "Limpeza de piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761861865006", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxLength": 2, "minLength": 2}, "description": ""}, {"id": "1761861908475", "type": "checkbox", "label": "Limpeza maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761861943616", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862028767", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxLength": 2, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:43:04.078534	2025-11-11 05:37:41.11747	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1761776428513-1vNQZrVqtO	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Feminino Tech center 	Limpeza e reposição de descartáveis do WC feminino Tech center.	[{"id": "1761775239795", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761775268941", "type": "checkbox", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776070903", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776144009", "type": "checkbox", "label": "Lavar o piso, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776214898", "type": "checkbox", "label": "Limpeza de interruptores e bancos, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776275957", "type": "checkbox", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776328789", "type": "checkbox", "label": "Retirada de lixo, foi feito?", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761776458735", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:05.892057	2025-11-11 05:38:42.600882	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1761836254359-8og_w_SonU	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC feminino portaria	Limpeza e troca de descartáveis do WC feminino na portaria	[{"id": "1761829165414", "type": "checkbox", "label": "Limpeza de pias, ralos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831089034", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831147464", "type": "checkbox", "label": "Lavar piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831362294", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831408447", "type": "checkbox", "label": "Limpezas de interruptores e bancos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831476269", "type": "checkbox", "label": "Limpeza maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761831877540", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761836286231", "type": "checkbox", "label": "Abastecimento de descartáveis ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:06.095699	2025-11-11 05:39:00.581862	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1761856942299-pHoKcSHvUb	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Masculino corporativo	Limpeza de WC masculino e reposição de descartáveis	[{"id": "1761856773237", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856800642", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856856045", "type": "checkbox", "label": "Limpeza vertical divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856903409", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856943872", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761856975831", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:05.281182	2025-11-11 05:38:23.701648	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1762193172542-gLSkJ7cCXi	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro ADM Feminino	\N	[{"id": "1762193050345", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 5}, "description": ""}, {"id": "1762193068955", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193080501", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193093141", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193105431", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193117267", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193127418", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193137573", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:05.484677	2025-11-11 05:38:33.244069	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1762193869779-YBWhevaQFd	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro Feminino Cozinha	\N	[{"id": "1762193595488", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193609040", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193659404", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193697920", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193726995", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193737451", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193753378", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193773027", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": false, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:05.688549	2025-11-11 05:38:51.443911	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1759332028080-yP1zdZiE7V	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA PRIME RTM	\N	[{"id": "1762450704351", "type": "checkbox", "label": "Plastificação dos carrinhos, remover e plastificar carrinhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762450753344", "type": "checkbox", "label": "Limpeza interna de paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762450829253", "type": "checkbox", "label": "Aplicação de filme plastico pintável 3M e aplicação de sabão da gage da cabine de pintura do prime ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762450866556", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452273918", "type": "checkbox", "label": "Limpeza do flash off do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452326533", "type": "checkbox", "label": "Limpeza estufa do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452415744", "type": "checkbox", "label": "Limpeza de luminárias do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}, {"id": "1762452492385", "type": "checkbox", "label": "Aspiração superior (teto) da estufa do prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762452695501", "type": "checkbox", "label": "Limpeza raspar rotores (4) da exaustão e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762452833296", "type": "checkbox", "label": "Jateamento com lava jato e aplicação de graxa patente do transportador", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762453431527", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 4, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762453599610", "type": "photo", "label": "Evidencia foto antes atividade", "options": [], "required": true, "validation": {"photoMaxCount": 4, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762453720625", "type": "text", "label": "Comentário relevante da atividade", "options": [], "required": true, "validation": {"maxLength": 30, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:06.300914	2025-11-11 03:44:06.300914	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N
checklist-1762196389815-oSPBgeWCDQ	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Masculino Toyota	\N	[{"id": "1762196015891", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196024269", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196034479", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196048665", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196242051", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196253281", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196266125", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196299330", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:07.121801	2025-11-11 03:44:07.121801	\N	\N	\N
checklist-1762458808131-9CgGFQELcI	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA RTM VERNIZ	Limpeza de ambientes cabine final RTM verniz	[{"id": "1762457585858", "type": "checkbox", "label": "Jateamento com lava jato e aplicação de graxa patente no transportador", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457617693", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457647863", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457681300", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457719343", "type": "checkbox", "label": "Limpeza do flash off do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762457752809", "type": "checkbox", "label": "Limpeza das luminárias do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762457784562", "type": "checkbox", "label": "Limpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762458776711", "type": "photo", "label": "Evidencia de foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762458805315", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762460701782", "type": "text", "label": "Comentario relevante sobre atividades", "options": [], "required": false, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:06.505366	2025-11-11 05:39:39.69639	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N
checklist-1762461380023-MbLbIzdWaG	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CAMBINE DE PINTURA FINAL SMC	Realizar atividades de limpeza técnica na cabine de pintura SMC	[{"id": "1762461105234", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461133005", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461163458", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461197806", "type": "checkbox", "label": "Limpeza do flash off da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461224397", "type": "checkbox", "label": "Limpeza das luminárias da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461250872", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão da base e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461299107", "type": "photo", "label": "Evidencia fotos antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461332422", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461383473", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:06.917013	2025-11-11 05:41:28.707981	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N
checklist-1762461869289-dKtnq1L-Ny	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA FINAL SMC VERNIZ	Limpeza e conservação da cabine de verniz SMC 	[{"id": "1762461583393", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461614929", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461645131", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461677630", "type": "checkbox", "label": "Limpeza do flash off do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461704522", "type": "checkbox", "label": "Limpeza das liminárias do verniz", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461727214", "type": "checkbox", "label": "Aspiração da região superior (teto) da estufa da pintura final", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461755138", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão do verniz e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762461782163", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461808350", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762461875034", "type": "text", "label": "Comentario relevante a atividade", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}, {"id": "1762461985427", "type": "checkbox", "label": "Jateamento com lava jato e aplicação de graxa patente no transportador", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}]	clean	2025-11-11 03:44:07.325743	2025-11-11 05:41:40.027674	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N
checklist-1761862495648-8Za4hjl-QO	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	WC vestiário masculino 01	Limpeza e reposição de descartáveis vestiário masculino	[{"id": "1761862198794", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862374771", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862428007", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862460510", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões ", "options": ["OK", "NOk"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862490196", "type": "checkbox", "label": "Retirada de lixo ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862530580", "type": "checkbox", "label": "Abastecimento de descartáveis ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1762192640343", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {}, "description": ""}]	clean	2025-11-11 03:44:08.34598	2025-11-11 03:44:08.34598	\N	\N	\N
checklist-1762463769882-ftVpLmIQbe	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE RETOQUE RTM 123	Limpeza e conservação da cabine das cabines de retoques RTM	[{"id": "1762463601088", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762463637603", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762463695446", "type": "checkbox", "label": "Limpeza do chão da cabine", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762463715492", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762463746494", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762463770206", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:07.735229	2025-11-11 05:42:00.870232	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N
checklist-1762464395325-_PfmyxiXtl	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE ESTÁTICA SMC FANTE	Limpeza e conservação da cabine fante SMC	[{"id": "1762464089654", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": -23, "minChecked": 1}, "description": ""}, {"id": "1762464117960", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464144269", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464170691", "type": "checkbox", "label": "Limpeza do fosso da cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464189406", "type": "checkbox", "label": "Limpeza das liminárias da cabine estática SMC fante", "options": [], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464214230", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464242903", "type": "checkbox", "label": "Troca de filtro multibolsa cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464265995", "type": "checkbox", "label": "Troca de filtro plenuns cabine estática SMC fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464343119", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464364332", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464400779", "type": "text", "label": "Comentario relevante a atividade", "options": [], "required": true, "validation": {"maxLength": 40, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:07.938783	2025-11-11 05:42:10.510144	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N
checklist-1762196816174-_I4SMQoVe6	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Vestiario Masculino 02	\N	[{"id": "1762196545653", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196560432", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196573818", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196612504", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196627292", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196640708", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196666568", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762196678297", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:08.549005	2025-11-11 03:44:08.549005	\N	\N	\N
checklist-1762195032362-noZuqi5DFs	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Masculino GM	\N	[{"id": "1762194932017", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194943013", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194952592", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194961931", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194971655", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194981105", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194991582", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195003341", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:08.752666	2025-11-11 03:44:08.752666	\N	\N	\N
checklist-1762194762968-ALChrz1j8h	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Feminino GM	\N	[{"id": "1762194616240", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194625813", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194638730", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194670140", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194686562", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194696264", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194704772", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762194721327", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:08.956429	2025-11-11 03:44:08.956429	\N	\N	\N
checklist-1761847649404-ZS0guEhd1C	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	WC acessível corporativo 01	Limpeza de WC e reposição de descartável	[{"id": "1761847444086", "type": "checkbox", "label": "Limpeza de pias, vasose espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761847513577", "type": "checkbox", "label": "Limpeza de piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761847591019", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761847635923", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761847658082", "type": "checkbox", "label": "Retirada de lixo", "options": [], "required": true, "validation": {"minLength": 2, "maxChecked": 2}, "description": ""}, {"id": "1761847684739", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 2, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:09.163706	2025-11-11 03:44:09.163706	\N	\N	\N
checklist-1761860564649-3Usd4x-lsP	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	WC Ambulatório	Limpeza e reposição de descartáveis do WC feminino RH	[{"id": "1761860339614", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761860418024", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761860488899", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portase ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 2}, "description": ""}, {"id": "1761860522818", "type": "checkbox", "label": "Limpezas de maçanetas e corrimão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761860549642", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761860589141", "type": "checkbox", "label": "Abastecimento de descartáveis ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:44:09.36962	2025-11-11 03:44:09.36962	\N	\N	\N
checklist-1761862781513-bLkyIY_I3x	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	WC vestiário feminino	Limpeza e troca de descartáveis vestiário feminino	[{"id": "1761862640237", "type": "checkbox", "label": "Limpeza de pias vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862666056", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "OK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862702806", "type": "checkbox", "label": "Limpeza vertical divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862735931", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862774659", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761862817129", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1762192757887", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:09.573225	2025-11-11 03:44:09.573225	\N	\N	\N
checklist-1762193512877-W94oQ48o60	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro ADM Masculino	\N	[{"id": "1762193208668", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193222950", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193407736", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193418434", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193437194", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193451498", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193470394", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762193481768", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:09.777727	2025-11-11 03:44:09.777727	\N	\N	\N
checklist-1762195227125-oWoxfIb8T0	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Feminino Logística	\N	[{"id": "1762195127441", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195138787", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195148809", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195158049", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195169949", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195179931", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195188752", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195199323", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:09.982463	2025-11-11 03:44:09.982463	\N	\N	\N
checklist-1762195540907-c9pvQAaOPo	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Feminino Scania	\N	[{"id": "1762195432012", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195440397", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195448688", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195457901", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195468888", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195478182", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195489047", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195507582", "type": "text", "label": "Abastecimento de descartáveis2", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:10.186324	2025-11-11 03:44:10.186324	\N	\N	\N
checklist-1762195707396-3MS7VMBGKT	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Masculino Scania	\N	[{"id": "1762195588686", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": false, "validation": {"maxLength": 5, "minLength": 2}, "description": ""}, {"id": "1762195597398", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195606572", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 5, "minLength": 2}, "description": ""}, {"id": "1762195616270", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 5, "minLength": 2}, "description": ""}, {"id": "1762195629418", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195638134", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195648061", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195655900", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:10.390294	2025-11-11 03:44:10.390294	\N	\N	\N
checklist-1762195973614-4wAT2-ME4z	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Banheiro Feminino Toyota	\N	[{"id": "1762195857204", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195868060", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195879049", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195896604", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195908315", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195921284", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195932452", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195942665", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:10.593756	2025-11-11 03:44:10.593756	\N	\N	\N
checklist-1761787799950-ZXGkoce5PR	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Masculino portaria 	Limpeza e troca de descartáveis do WC masculino portaria	[{"id": "1761787483563", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787528548", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787596830", "type": "checkbox", "label": "Limpeza vertical de divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787631507", "type": "checkbox", "label": "Lavar piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787676044", "type": "checkbox", "label": "Limpeza de interruptores e bancos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787762358", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787795633", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761787828492", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:43:03.265932	2025-11-11 05:36:57.667321	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1761847086703-dMeETUQhOU	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	WC Recepção	Limpeza geral do WC da recepção e abastecimento de descartáveis 	[{"id": "1761845873143", "type": "checkbox", "label": "Limpeza de pias, vasos e espelhos", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761845923460", "type": "checkbox", "label": "Limpeza do piso", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761846013334", "type": "checkbox", "label": "Limpeza vertical, divisorias, paredes e portas", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761846078278", "type": "checkbox", "label": "Retirada de lixo", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761846996036", "type": "checkbox", "label": "Abastecimento de descartáveis", "options": ["OK", "NOK"], "required": true, "validation": {"maxLength": 2, "minLength": 2, "maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1761847048621", "type": "checkbox", "label": "Limpeza de maçanetas e corrimões", "options": [], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}]	clean	2025-11-11 03:43:03.470543	2025-11-11 05:37:12.194312	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1762195387385-CW9wW1-MkN	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	Banheiro Masculino Logística	\N	[{"id": "1762195284288", "type": "text", "label": "Limpeza de pias, vasos e espelhos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195295539", "type": "text", "label": "Piso foi limpo?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195304196", "type": "text", "label": "Limpeza vertical, divisorias, paredes e portas, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195312412", "type": "text", "label": "Lavar o piso, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195321274", "type": "text", "label": "Limpeza de interruptores e bancos, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195330690", "type": "text", "label": "Limpeza maçanetas e corrimões, foi feita?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195341837", "type": "text", "label": "Retirada de lixo, foi feito?", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}, {"id": "1762195350953", "type": "text", "label": "Abastecimento de descartáveis", "options": [], "required": true, "validation": {"maxLength": 500, "minLength": 2}, "description": ""}]	clean	2025-11-11 03:44:05.075061	2025-11-11 05:38:13.303849	2ba21003-b82d-4950-8a6b-f504740960ea	\N	\N
checklist-1762460579246-8WeuppXOUV	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE DE PINTURA PRIME SMC	\N	[{"id": "1762460122390", "type": "checkbox", "label": "Plastificação dos carrinhos (remover e recolocar os plásticos)", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460156660", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460189810", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460224237", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460256442", "type": "checkbox", "label": "Limpeza do flash off do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460291143", "type": "checkbox", "label": "Limpeza estufa do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460318546", "type": "checkbox", "label": "Limpeza das luminárias do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460353096", "type": "checkbox", "label": "Aspiração da região superior (teto) da estufa do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460380520", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762460444638", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762460470330", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}]	clean	2025-11-11 03:44:06.711315	2025-11-11 05:39:28.530544	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N
checklist-1760640725459-vyFf79rK0p	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	PINTURA FINAL RTM	Limpeza da cabine de pintura final do RTM	[{"id": "1762454807555", "type": "checkbox", "label": "Limpeza interna de aparedes e vidros da cabine da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": ""}, {"id": "1762455006757", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da gage na cabine de pintura da base ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 1}, "description": ""}, {"id": "1762455202894", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 2}, "description": ""}, {"id": "1762456250879", "type": "checkbox", "label": "Limpeza flash off da base ", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 2}, "description": ""}, {"id": "1762456334238", "type": "checkbox", "label": "Limpeza das luminarias da base", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 4, "minChecked": 2}, "description": ""}, {"id": "1762458938251", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762458962212", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762460666036", "type": "text", "label": "Comentario relevante das atividades", "options": [], "required": false, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:43:03.875717	2025-11-11 05:39:57.64359	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N
checklist-1762462359598-z35kNf1eQh	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE ESTÁTICA RTM COWLING	Limpeza e higienização da cabine estática RTM	[{"id": "1762462257357", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762462287008", "type": "checkbox", "label": "Troca de filtro da exaustão", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762462316016", "type": "checkbox", "label": "Limpeza do chão da cabine", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762462411955", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762462433396", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762462461356", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 50, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:07.531108	2025-11-11 05:41:49.49964	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N
checklist-1762464945821-unYORefXHU	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	CABINE ESTÁTICA SMC PRIMER	Limpeza e conservação da cabine estática SMC primer	[{"id": "1762464624074", "type": "checkbox", "label": "Limpeza interna das paredes e vidros das cabines do primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 6, "minChecked": 1}, "description": ""}, {"id": "1762464653612", "type": "checkbox", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464684730", "type": "checkbox", "label": "Troca de filtro da exaustão da cabine estática SMC primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464706909", "type": "checkbox", "label": "Limpeza do fosso da cabine estática SMC primer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464731936", "type": "checkbox", "label": "Limpeza das liminárias da cabine estática SMC ptimer", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464753748", "type": "checkbox", "label": "Limpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464777807", "type": "checkbox", "label": "Troca de filtro multibolsa cabine estática primer fante", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464799733", "type": "checkbox", "label": "Troca de filtro plenuns cabine estática SMC prime", "options": ["OK", "NOK"], "required": true, "validation": {"maxChecked": 3, "minChecked": 1}, "description": ""}, {"id": "1762464889709", "type": "photo", "label": "Evidencia foto antes da atividade", "options": [], "required": true, "validation": {"photoMaxCount": 3, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464913336", "type": "photo", "label": "Evidencia foto após atividade", "options": [], "required": true, "validation": {"photoMaxCount": 6, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1762464944723", "type": "text", "label": "Comentario relevante a atividades", "options": [], "required": true, "validation": {"maxLength": 40, "minLength": 1}, "description": ""}]	clean	2025-11-11 03:44:08.142551	2025-11-11 05:42:20.674637	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	\N	\N
\.


--
-- Data for Name: cleaning_activities; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
ca-1761591097102-8kf81xk7d	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-corp	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:12.638964	2025-11-11 03:44:12.638964	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761591197326-qzu06d0gn	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-acess-01	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:12.8435	2025-11-11 03:44:12.8435	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761591301979-gci0j116a	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-unissex	Recepção - Limpeza  WC	Limpeza de WC recepção 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.047128	2025-11-11 03:44:13.047128	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1759889629139-pqcuh75ib	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	semanal	{"monthDay": 1, "weekDays": ["terca"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.250909	2025-11-11 03:44:13.250909	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759889808223-kkbhkfsdy	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	semanal	{"monthDay": 1, "weekDays": ["terca"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.454637	2025-11-11 03:44:13.454637	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1759890045118-y0c75246f	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Final RTM	Limpeza do fosso da exaustão da base\\nLimpeza externa das paredes e vidros das cabines da base\\nLimpeza do fosso da exaustão do verniz\\nAspiração da região superior (teto) da estufa da pintura final\\nLimpeza externa das paredes e vidros das cabines do verniz\\n	mensal	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.661081	2025-11-11 03:44:13.661081	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1760182900759-vyp6ush29	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\\nTroca de filtro plenuns cabine do primer - 2 cabines\\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:13.864955	2025-11-11 03:44:13.864955	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1760183618389-283dqb778	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\\nTroca de filtro plenuns cabine do primer - 2 cabines\\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.068298	2025-11-11 03:44:14.068298	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1760183770897-absg8gofg	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\\nTroca de filtro plenuns cabine do primer - 2 cabines\\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.272437	2025-11-11 03:44:14.272437	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N	\N	\N	\N
ca-1761585757243-elx2y62kt	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.476285	2025-11-11 03:44:14.476285	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761585870492-w7xqg80th	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.679564	2025-11-11 03:44:14.679564	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761586116924-imqskabvg	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:14.883163	2025-11-11 03:44:14.883163	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761586621875-47moo9ok0	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-masc-01	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:15.088045	2025-11-11 03:44:15.088045	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761587028027-knglqct7g	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-masc-01	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:15.293997	2025-11-11 03:44:15.293997	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761587225967-w1l2xw0lm	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:15.498226	2025-11-11 03:44:15.498226	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761590395353-n4e6pddup	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-masc-02	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:15.702331	2025-11-11 03:44:15.702331	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761590545608-fucf3mxn5	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:15.906006	2025-11-11 03:44:15.906006	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761590717804-8eo1xtcge	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc	Limpeza WC RH masculinol	Limpeza de WC masculino RH	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:16.111521	2025-11-11 03:44:16.111521	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761590774854-0gkz8w44o	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-fem	Limpeza WC RH feminino	Limpeza de WC feminino RH	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:16.314608	2025-11-11 03:44:16.314608	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761590883222-ctje5t7ze	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-fem-corp	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:16.519235	2025-11-11 03:44:16.519235	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761590969350-suyuqoky7	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-corp	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:16.722298	2025-11-11 03:44:16.722298	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761591407974-9i2pqxrtu	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-portaria	zone-port-fem	Portaria - WC feminino	Limpeza de WC feminino da portaria 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:16.925511	2025-11-11 03:44:16.925511	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761591455060-1zocriqb3	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-portaria	zone-port-masc	Portaria - WC masculino	Limpeza de WC masculino portaria	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:17.130117	2025-11-11 03:44:17.130117	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761591540766-1m8stph7k	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-tech	Tech center - WC masculino	Limpeza de WC masculino Tech center	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:17.333755	2025-11-11 03:44:17.333755	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
ca-1761591637418-eed4drz6c	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-tech	Tech center - WC feminino	Limpeza de WC feminino tech center 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-11 03:44:17.537512	2025-11-11 03:44:17.537512	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N	\N	\N	\N
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.companies (id, name, cnpj, email, phone, address, is_active, created_at, updated_at) FROM stdin;
company-admin-default	GRUPO OPUS					t	2025-09-10 20:41:19.301367	2025-09-10 20:41:19.301367
company-opus-default	Grupo OPUS	12.345.678/0001-90	contato@grupoopus.com.br	(11) 3000-0000	Av. Paulista, 1000 - São Paulo, SP	t	2025-11-11 03:42:52.962018	2025-11-11 03:42:52.962018
\.


--
-- Data for Name: company_counters; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.company_counters (id, company_id, key, next_number, updated_at) FROM stdin;
\.


--
-- Data for Name: custom_roles; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.custom_roles (id, company_id, name, description, is_system_role, is_active, created_at, updated_at) FROM stdin;
role-1759340407-operador	company-admin-default	Operador	Operador de campo - executa OS via aplicativo mobile	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
role-1759340407-cliente	company-admin-default	Cliente	Visualização de dashboards, relatórios, plantas dos locais e ordens de serviço. Pode comentar e avaliar OS.	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
role-1759340407-admin	company-admin-default	Administrador	Acesso total ao sistema - para usuários OPUS	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
\.


--
-- Data for Name: customer_counters; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.customer_counters (id, customer_id, key, next_number, updated_at) FROM stdin;
custc-1762818381226-jld9vdg6n	a6460e7b-7b7f-45f0-b748-efddeea5707c	work_order	27	2025-11-11 02:54:27.282657
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.customers (id, company_id, name, email, phone, document, address, city, state, zip_code, contact_person, notes, modules, is_active, created_at, updated_at, login_logo, sidebar_logo, sidebar_logo_collapsed, module_colors) FROM stdin;
0ce55363-d42f-4027-823c-fff6fdabc95d	company-admin-default	Teste	manager@example.com	69983993634	16.311.911/0001-70	Avenida Xavier de Almeida	São Paulo	GO	74968-496	Mário Torres		{clean,maintenance}	f	2025-11-10 22:16:20.240687	2025-11-10 22:16:37.021571	\N	\N	\N	\N
a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default	Condomínio Sol de Mar	Soldemar@gmail.com	69983993634	84857665000106	Rua Maria de Fátima	São Paulo	SP	04404-160	Mário Torres		{maintenance,clean}	t	2025-11-10 22:11:48.868936	2025-11-10 22:19:23.616547	\N	\N	\N	\N
43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default	FAURECIA	\N	\N	\N	\N	\N	\N	\N	\N	\N	{clean}	t	2025-11-11 03:42:13.585928	2025-11-11 03:42:13.585928	\N	\N	\N	\N
7913bae1-bdca-4fb4-9465-99a4754995b2	company-admin-default	TECNOFIBRA	\N	\N	\N	\N	\N	\N	\N	\N	\N	{clean}	t	2025-11-11 03:42:13.790706	2025-11-11 03:42:13.790706	\N	\N	\N	\N
20ae7c09-3fe9-4db9-a136-2992bac29e10	company-admin-default	teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	{clean}	f	2025-11-11 03:42:13.994876	2025-11-11 03:42:13.994876	\N	\N	\N	\N
customer-teste-default	company-admin-default	Cliente Teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	{clean}	t	2025-11-11 03:42:14.199473	2025-11-11 03:42:14.199473	\N	\N	\N	\N
\.


--
-- Data for Name: dashboard_goals; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.dashboard_goals (id, company_id, module, goal_type, goal_value, current_period, is_active, created_at, updated_at) FROM stdin;
1c998e07-525e-4ba4-a2da-907ce4b6293b	company-admin-default	clean	eficiencia_operacional	95.00	2025-11	t	2025-11-10 22:38:38.458304	2025-11-10 22:38:38.458304
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.equipment (id, company_id, customer_id, site_id, zone_id, equipment_type_id, name, internal_code, manufacturer, model, serial_number, purchase_date, warranty_expiry, installation_date, status, technical_specs, maintenance_notes, qr_code_url, module, is_active, created_at, updated_at, value) FROM stdin;
I3cgNaIghKEHX5DR8yEF-	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	366ab13e-e56a-417a-b8c3-07d9d1ca4264	a12d6f27-ac7a-4851-b37f-14ef855b8b0e	\N	ar condicionado	\N	Samsung	Dual Inverter Compact	SN73621T	\N	2027-11-10	2025-11-10	operacional	\N	\N	\N	maintenance	t	2025-11-10 23:30:36.603947	2025-11-10 23:30:36.603947	2184.90
jNGzf38-Bx6Z1fO9PCWle	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	366ab13e-e56a-417a-b8c3-07d9d1ca4264	7c9bc3ac-1e99-4f19-9726-573a4569918d	\N	ar condicionado	\N	Samsung	Dual Inverter Compact	SN73621T-2	\N	2025-11-30	2025-11-10	operacional	\N	\N	\N	maintenance	t	2025-11-10 23:44:02.525056	2025-11-10 23:44:02.525056	2184.90
\.


--
-- Data for Name: equipment_types; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.equipment_types (id, company_id, name, description, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_activities; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.maintenance_activities (id, company_id, customer_id, site_ids, zone_ids, equipment_ids, site_id, zone_id, name, description, type, frequency, frequency_config, module, checklist_template_id, sla_config_id, assigned_user_id, estimated_hours, sla_minutes, start_date, last_executed_at, is_active, created_at, updated_at, start_time, end_time) FROM stdin;
ma-1762818380501-b9ptcu9ly	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	{366ab13e-e56a-417a-b8c3-07d9d1ca4264}	{a12d6f27-ac7a-4851-b37f-14ef855b8b0e,7c9bc3ac-1e99-4f19-9726-573a4569918d}	{I3cgNaIghKEHX5DR8yEF-,jNGzf38-Bx6Z1fO9PCWle}	\N	\N	Manutenção dos ar condicionados		preventiva	mensal	{"monthDay": 10, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	LSwNG2iHdUQZ4ZijKL-1q	\N	\N	\N	\N	2025-11-10	\N	t	2025-11-10 23:46:20.551674	2025-11-10 23:46:20.551674	\N	\N
ma-1762829349044-b63jtarfr	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	{366ab13e-e56a-417a-b8c3-07d9d1ca4264}	{a12d6f27-ac7a-4851-b37f-14ef855b8b0e}	{I3cgNaIghKEHX5DR8yEF-}	\N	\N	Higienização de Cabine		preventiva	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	LSwNG2iHdUQZ4ZijKL-1q	\N	\N	\N	\N	2025-11-09	\N	t	2025-11-11 02:49:09.095663	2025-11-11 02:49:09.095663	\N	\N
\.


--
-- Data for Name: maintenance_checklist_executions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.maintenance_checklist_executions (id, checklist_template_id, equipment_id, work_order_id, executed_by_user_id, started_at, finished_at, status, checklist_data, observations, attachments, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_checklist_templates; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.maintenance_checklist_templates (id, company_id, customer_id, name, description, version, service_id, site_ids, zone_ids, equipment_ids, items, module, is_active, created_at, updated_at) FROM stdin;
LSwNG2iHdUQZ4ZijKL-1q	company-admin-default	a6460e7b-7b7f-45f0-b748-efddeea5707c	Manutenção dos ar condicionados	\N	1.0	aa599100-b76e-4dff-89ee-116abbce3355	{366ab13e-e56a-417a-b8c3-07d9d1ca4264}	{a12d6f27-ac7a-4851-b37f-14ef855b8b0e,7c9bc3ac-1e99-4f19-9726-573a4569918d}	{I3cgNaIghKEHX5DR8yEF-,jNGzf38-Bx6Z1fO9PCWle}	[{"id": "lBgsIu9xRhCPBH5hnrzhj", "type": "photo", "label": "i", "options": [], "required": false, "validation": {"photoMinCount": 1}, "description": ""}]	maintenance	t	2025-11-10 23:45:44.301835	2025-11-10 23:45:44.301835
\.


--
-- Data for Name: maintenance_plan_equipments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.maintenance_plan_equipments (id, plan_id, equipment_id, checklist_template_id, frequency, frequency_config, next_execution_at, last_execution_at, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_plans; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.maintenance_plans (id, company_id, customer_id, name, description, type, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: public_request_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.public_request_logs (id, qr_code_point_id, ip_hash, user_agent, request_data, created_at) FROM stdin;
\.


--
-- Data for Name: qr_code_points; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
-- Data for Name: service_categories; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.service_categories (id, type_id, name, description, code, module, is_active, created_at, updated_at, customer_id) FROM stdin;
be576348-675a-4b59-a7fa-715bbb0e0f15	fd87bcf6-fc20-4157-84db-bda39a303069	Limpeza Tecnica	\N	LPT	clean	t	2025-11-11 03:43:02.245127	2025-11-11 03:43:02.245127	7913bae1-bdca-4fb4-9465-99a4754995b2
81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive	Limpeza 	\N	1	clean	t	2025-11-11 03:43:02.449897	2025-11-11 03:43:02.449897	43538320-fe1b-427c-9cb9-6b7ab06c1247
\.


--
-- Data for Name: service_types; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.service_types (id, name, description, code, module, is_active, created_at, updated_at, customer_id, company_id) FROM stdin;
01f965aa-8676-4780-8e42-e4a4540a0889	Preventivo		PVT_LPZ	clean	t	2025-11-10 23:02:26.91541	2025-11-10 23:02:26.91541	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
06eafc6f-4aa1-40d2-897c-0d738fdc25cf	Preventivo		PVT_MNT	maintenance	t	2025-11-10 23:27:51.371087	2025-11-10 23:27:51.371087	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
c1c15dad-c628-4b0e-800a-70c71eb05d2d	Corretivo		CRT_MNT	maintenance	t	2025-11-11 02:46:25.604647	2025-11-11 02:46:25.604647	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
st-emergency	Emergência	Serviços de emergência com atendimento crítico imediato	EMERG_SVC	clean	t	2025-11-11 03:43:01.632119	2025-11-11 03:43:01.632119	43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default
st-preventive	Preventivo	Serviços de manutenção preventiva programada regular	PREV_SVC	clean	t	2025-11-11 03:43:01.835218	2025-11-11 03:43:01.835218	43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default
fd87bcf6-fc20-4157-84db-bda39a303069	Preventiva	Limpeza programada.	PVT	clean	t	2025-11-11 03:43:02.039292	2025-11-11 03:43:02.039292	7913bae1-bdca-4fb4-9465-99a4754995b2	company-admin-default
a1623bc1-2a21-4043-98e7-500d5357f8de	Corretivo		CRT_LPZ	clean	t	2025-11-11 04:56:24.371448	2025-11-11 04:56:24.371448	a6460e7b-7b7f-45f0-b748-efddeea5707c	company-admin-default
\.


--
-- Data for Name: service_zones; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.service_zones (id, service_id, zone_id, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.services (id, name, description, estimated_duration_minutes, priority, requirements, module, is_active, created_at, updated_at, customer_id, category_id, type_id) FROM stdin;
2f6262d2-1088-4ffb-9947-49561806e6b8	Recolhimento do Lixo		30	media	\N	clean	t	2025-11-10 23:02:45.433017	2025-11-10 23:02:45.433017	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N	01f965aa-8676-4780-8e42-e4a4540a0889
aa599100-b76e-4dff-89ee-116abbce3355	Manutenção dos ar condicionados		60	media	\N	maintenance	t	2025-11-10 23:28:05.32994	2025-11-10 23:28:05.32994	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N	06eafc6f-4aa1-40d2-897c-0d738fdc25cf
0643fb68-262b-4f4b-bd6f-e6dc1c304a37	Higienização de Cabine	\N	480	alta	\N	clean	t	2025-11-11 03:43:02.655498	2025-11-11 03:43:02.655498	7913bae1-bdca-4fb4-9465-99a4754995b2	be576348-675a-4b59-a7fa-715bbb0e0f15	fd87bcf6-fc20-4157-84db-bda39a303069
1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	Limpeza Rotina	\N	30	media	\N	clean	t	2025-11-11 03:43:02.858809	2025-11-11 03:43:02.858809	43538320-fe1b-427c-9cb9-6b7ab06c1247	81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive
service-3	Reposição de Suprimentos	Reposição de papel, sabão e materiais de higiene	15	media	\N	clean	t	2025-11-11 03:43:03.061205	2025-11-11 03:43:03.061205	43538320-fe1b-427c-9cb9-6b7ab06c1247	81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive
d9be8bc7-62d8-43ec-8a63-65bf2aa64796	Higienização de Cabine		40	media	\N	clean	t	2025-11-11 04:56:38.762808	2025-11-11 04:56:38.762808	a6460e7b-7b7f-45f0-b748-efddeea5707c	\N	01f965aa-8676-4780-8e42-e4a4540a0889
\.


--
-- Data for Name: site_shifts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.site_shifts (id, site_id, name, start_time, end_time, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
\.


--
-- Data for Name: sla_configs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.sla_configs (id, company_id, name, category, module, time_to_start_minutes, time_to_complete_minutes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_role_assignments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.user_role_assignments (id, user_id, role_id, customer_id, created_at) FROM stdin;
ura-1762815860547-xc4uzgpfx	user-joao.silva-1762815860108	role-1759340407-operador	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-10 23:04:20.597201
ura-1762815976452-gxt6p5gzu	user-joao.matos-1762815975982	role-1759340407-operador	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-10 23:06:16.503643
ura-1762816014536-jpi06b1tm	user-joao.torres-1762816014081	role-1759340407-operador	a6460e7b-7b7f-45f0-b748-efddeea5707c	2025-11-10 23:06:54.586823
\.


--
-- Data for Name: user_site_assignments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.user_site_assignments (id, user_id, site_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.users (id, company_id, customer_id, username, email, password, name, role, user_type, assigned_client_id, auth_provider, external_id, ms_tenant_id, modules, is_active, created_at, updated_at) FROM stdin;
user-admin-opus	company-admin-default	\N	admin	admin@opus.com	$2b$12$OysqfXqxwvfxZvr9GZnYFOMLIoiTYcMfAa6QJLEHbmC7R5Ikvl8V6	Administrador Sistema	admin	opus_user	\N	local	\N	\N	{clean,maintenance}	t	2025-11-10 22:07:48.514007	2025-11-10 22:07:48.514007
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
7dc2163b-7762-4cca-8f33-bd4386486e26	company-opus-default	\N	rafael.soriani	rafael.soriani@tecnofibras.com.br	$2b$12$Cg2zqfpx/kVwOjaTk8ktbe.KEgw5TGlzJ0XUyBkLq31MpWpJwItge	Rafael Soriani	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.405394	2025-11-11 03:43:00.405394
c1c3f742-cd7c-4082-a9ae-422f1567da21	company-opus-default	\N	josias.santos	josias.santos@technofibras.com.br	$2b$12$71SBdIefJzar4vTZqiuMF.8yI.GTDAqoKuf82HF7O2btBEj4E8xX6	Josias Santos	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.609249	2025-11-11 03:43:00.609249
177af1be-13d5-4ca7-8c64-d33a0c1e6b4f	company-opus-default	\N	edivaldo.dias	edivaldo.dias@tecnofibras.com.br	$2b$12$0uMMm4L6t38ZIcrZeJHeHeBTJbRQGhr2IYqUKTooR9J9yakg8gd.C	Edivaldo Dias 	auditor	opus_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:00.819437	2025-11-11 03:43:00.819437
2eca20e5-066f-4c4a-afc8-d4ff1b6f5015	company-opus-default	\N	marcelo.alves	marcelo.alves@tecnofibras.com	$2b$12$gYxDuoTXB/aVz38vIjEEz.nxVb/Jf5JK3T5TubNY1t18tW4SlyIeq	Marcelo Alves 	auditor	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:43:01.023149	2025-11-11 03:43:01.023149
ad85d9cf-c3e6-4976-99bb-4b1bbfdf7b43	company-opus-default	\N	eduardo.santos	eduardo.santos@tecnofibras.com	$2b$12$3TQ4.FgA9jBpwu2k3MyxeeiOHeAA0BYS0lEQtnYHmgSPqTzgMWXDG	Eduardo Santos 	auditor	opus_user	\N	local	\N	\N	{clean}	f	2025-11-11 03:43:01.225289	2025-11-11 03:43:01.225289
user-Teste-1761919340112	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	Teste	OperadorTeste2@gmail.com	$2b$10$iptOpH/jL6u7qwel07m1ruRHQxv7UEEkdP7uX3NWBc5uedMIuPA1u	Operador Teste	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-11 03:43:01.428226	2025-11-11 03:43:01.428226
\.


--
-- Data for Name: webhook_configs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.webhook_configs (id, company_id, name, url, events, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_order_comments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
a3081adf-41cf-4616-b23e-dd436ddc41f8	419	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:24.496976	2025-11-11 03:44:24.496976	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
0a3e0acb-8dcb-4f68-ad97-31ed103b3324	420	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:24.907954	2025-11-11 03:44:24.907954	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
47ae0251-216b-457d-bd0c-fbb4f6f4bef8	421	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:25.315951	2025-11-11 03:44:25.315951	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
06a5242b-8a73-40fa-9f7b-ea214d1fa282	422	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:25.725076	2025-11-11 03:44:25.725076	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
81bce98a-7c38-4e31-bb54-b3f189b4b3b9	423	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:26.1331	2025-11-11 03:44:26.1331	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
362cb832-e36e-460b-acfe-926051972798	424	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:26.546759	2025-11-11 03:44:26.546759	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
be8ed5ee-f7d9-4df2-8b2d-1ebc5b554e80	425	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:26.955597	2025-11-11 03:44:26.955597	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
eb6b15ff-cf88-4327-a47b-2bc74b7bdeef	426	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:27.364749	2025-11-11 03:44:27.364749	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9e51386d-0cf0-4635-9e95-9a328727f613	427	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:27.774162	2025-11-11 03:44:27.774162	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
43cc25d0-e95a-4dda-a08e-dc5a944452c2	428	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:28.184808	2025-11-11 03:44:28.184808	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9d96213d-2070-4603-a58b-9b9ff7f60f72	429	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:28.619635	2025-11-11 03:44:28.619635	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
16592b35-db61-4683-ae4c-dda088d0774b	430	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:29.027263	2025-11-11 03:44:29.027263	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a09e799b-a769-4bba-8928-e928ca83c755	431	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:29.435465	2025-11-11 03:44:29.435465	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a03e5145-680c-4fdf-ac90-8ee965ff5c84	432	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:29.843306	2025-11-11 03:44:29.843306	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bf0b9b65-8ba0-40b7-8343-ba010c133ad7	433	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:30.252096	2025-11-11 03:44:30.252096	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
efec1862-dbb6-440d-a4ed-66969dfbac67	434	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:30.669076	2025-11-11 03:44:30.669076	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6002f123-0c5e-4146-ac91-8beddec9d33c	435	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:31.078332	2025-11-11 03:44:31.078332	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
05d87b01-c265-40bc-a50e-53e776bb7421	436	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:31.492344	2025-11-11 03:44:31.492344	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bc66bbf5-79a2-478c-80eb-c7332088b110	437	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:31.899497	2025-11-11 03:44:31.899497	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fa80f107-ad30-4c32-a324-1833ee8b75e4	438	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:32.307452	2025-11-11 03:44:32.307452	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e643d287-5eeb-4a3c-a3a9-253c7197aa34	439	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:32.715656	2025-11-11 03:44:32.715656	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6ca9738d-2757-447c-941a-02c91f1b5ee8	440	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:33.123527	2025-11-11 03:44:33.123527	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3b46773e-2b1e-47be-b8b9-c8a0c6f86c54	441	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:33.530492	2025-11-11 03:44:33.530492	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
a6e9de96-32be-4ea4-a1c7-046378f812ed	442	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:33.9407	2025-11-11 03:44:33.9407	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
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
1104933d-2ce1-47c4-b515-05b58f6d04ec	443	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:38.421866	2025-11-11 03:44:38.421866	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
1bebabe3-aca4-4dff-bc35-2cae8c86ed0c	444	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:38.828239	2025-11-11 03:44:38.828239	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
62111898-5194-40e5-b4fa-a9d16a1f7888	445	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:39.234586	2025-11-11 03:44:39.234586	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ea4e3b30-b5ca-4bc1-b857-ef19451ae089	446	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:39.643002	2025-11-11 03:44:39.643002	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5d48a1f0-b3b5-4e35-9928-f2e981ad5eb9	447	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:40.049253	2025-11-11 03:44:40.049253	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f8fd731c-4efb-4315-be76-5bd6a8cba41d	448	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30 00:00:00	2025-10-30 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:40.455577	2025-11-11 03:44:40.455577	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e44fb95f-09b7-4783-96e1-e91a79ba8567	449	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31 00:00:00	2025-10-31 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:40.863077	2025-11-11 03:44:40.863077	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4795abd6-e51a-4c5b-9070-751c05b6e50b	481	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:41.26933	2025-11-11 03:44:41.26933	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
900da72a-42cc-4c31-830a-14a36fb602c1	482	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:41.683275	2025-11-11 03:44:41.683275	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
935d453d-31d6-4322-a3d0-154f70222b08	483	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:42.091086	2025-11-11 03:44:42.091086	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e6557f1a-6d15-4832-988e-7ff2a4f4f43a	484	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:42.49747	2025-11-11 03:44:42.49747	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6dfc9e20-2e5f-4cc4-af67-ef8a11244b3d	485	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:42.904754	2025-11-11 03:44:42.904754	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
97d52afb-a6fc-4477-a08d-3c24836a80b7	486	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:43.312565	2025-11-11 03:44:43.312565	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d4561938-8b25-43dc-b8d7-cedb5e76540e	487	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:43.724149	2025-11-11 03:44:43.724149	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
260be63c-e641-484d-9dd7-2e6fb2dec954	488	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:44.132758	2025-11-11 03:44:44.132758	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
932563cb-4e1d-4c74-9856-0ae12d29a2ae	489	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:44.541781	2025-11-11 03:44:44.541781	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2309a7f2-665f-4d1a-a7bc-e3d078d7f3f7	490	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:44.949917	2025-11-11 03:44:44.949917	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3c498c2c-5a6b-4da1-9845-fa0f78e6ccc9	491	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:45.359245	2025-11-11 03:44:45.359245	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
67568bc8-765c-4b23-913d-bdcd5c29d8e9	492	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:45.766456	2025-11-11 03:44:45.766456	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
75b0b106-53e2-4916-8585-45d7ffcee005	493	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:46.174403	2025-11-11 03:44:46.174403	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5feae033-2ec5-4ec9-9175-d9c660fff6c5	494	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:46.580312	2025-11-11 03:44:46.580312	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fe1f8835-4451-49ad-9dd8-a6ca6b9f443e	495	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:46.988713	2025-11-11 03:44:46.988713	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bbed1172-72f4-48c9-9c46-26a47b47436a	496	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:47.394574	2025-11-11 03:44:47.394574	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
937208ef-4345-47c3-8777-9386cf6c4e4c	667	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:47.800135	2025-11-11 03:44:47.800135	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ece6f5cc-dd3f-4fbc-a55d-9075fc3efcf5	450	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:48.20701	2025-11-11 03:44:48.20701	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
597837fc-7382-4215-b5a2-fd57ff4dd593	451	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:48.612564	2025-11-11 03:44:48.612564	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e77d4879-625b-49b4-a3b2-6157fa9dcb83	452	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:49.018969	2025-11-11 03:44:49.018969	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c0aab109-32e6-491c-b33d-c35850e0b0bf	266	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:49.427598	2025-11-11 03:44:49.427598	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
6d3ea290-49aa-46cd-ae02-7c37872a76af	267	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:49.833928	2025-11-11 03:44:49.833928	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
d1d1f959-4b9c-431a-8971-12cfe60cbd82	268	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:50.241352	2025-11-11 03:44:50.241352	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
27a89f22-8eb9-447b-8246-44c9cd1177da	269	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:50.650176	2025-11-11 03:44:50.650176	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
603c2bd2-5d95-4d87-bf13-efde31309e55	270	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:51.056281	2025-11-11 03:44:51.056281	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
808f6447-cbd8-4497-8899-7019ecd0ad9d	453	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:51.463775	2025-11-11 03:44:51.463775	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
431ebab9-f76c-424c-9d3f-0d85efdae48f	454	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:51.871263	2025-11-11 03:44:51.871263	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
38dbbce4-6fe3-433c-922c-af7efd5f24bc	455	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:52.278667	2025-11-11 03:44:52.278667	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
56a6974e-c9f2-416a-a623-606bc7854218	456	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:52.686386	2025-11-11 03:44:52.686386	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5c197d0f-8ef2-4c72-ada1-6e73362a4254	457	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:53.093848	2025-11-11 03:44:53.093848	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f64de416-afae-4092-b7b6-20e75e7c24a6	458	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:53.501802	2025-11-11 03:44:53.501802	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7a5a8108-81d9-4248-b26f-38f01f1ab069	459	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:53.911643	2025-11-11 03:44:53.911643	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
aa3495fc-9ff9-4167-bc22-5e08cfcf0914	460	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:54.318619	2025-11-11 03:44:54.318619	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
bffd1911-fc11-4467-bd5b-f7f15fbedbfd	461	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:54.725852	2025-11-11 03:44:54.725852	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fa3b7859-703c-458f-90ce-3c6ea3bd99a3	462	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:55.132883	2025-11-11 03:44:55.132883	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
621d1341-956b-4a74-9805-f6625d6388f2	463	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:44:55.5398	2025-11-11 03:44:55.5398	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
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
ec9fc834-824f-4c48-b819-8eda3c1825cb	464	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:07.772954	2025-11-11 03:45:07.772954	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e95a00bf-cbb3-46f1-92a7-e0ad4ebcce44	465	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:08.181455	2025-11-11 03:45:08.181455	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
fdac49bf-46e7-4e77-95c7-c79b40cc3154	466	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:08.589026	2025-11-11 03:45:08.589026	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
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
697342f5-e3bd-48d0-98a3-ffed79b9368a	501	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:38.737053	2025-11-11 03:45:38.737053	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
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
5ebf5172-dc46-455d-a061-e1e3f560df46	467	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:26.996489	2025-11-11 03:45:26.996489	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7775ede7-0e23-4b6e-bc01-722ef19dc900	381	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:27.406363	2025-11-11 03:45:27.406363	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
8d47cd07-b68b-47dc-a52d-630f5ee8b3bb	382	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:27.817176	2025-11-11 03:45:27.817176	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
87869762-dd5e-4a9d-8d2c-e73f047ab46a	468	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:28.228167	2025-11-11 03:45:28.228167	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f7281089-3632-453a-927a-1c795ee31f18	378	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:28.641039	2025-11-11 03:45:28.641039	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
c20bf156-3aa3-440f-b3fa-fdad5682641c	379	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:29.052927	2025-11-11 03:45:29.052927	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
44173277-465a-4154-a507-12e4d4b41f98	380	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\\nTroca de filtro da exaustão da cabine estática SMC fante\\nLimpeza das liminárias da cabine estática SMC fante\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:29.462023	2025-11-11 03:45:29.462023	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
a1f0534f-81fb-424b-865b-89356cf5a3e8	383	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:29.879726	2025-11-11 03:45:29.879726	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
5b549f49-f4db-44e9-9c60-aa45569d8f30	384	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:30.289385	2025-11-11 03:45:30.289385	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
36c47ef9-1ea2-4c16-ab82-c634c3d7600d	385	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\\nTroca de filtro da exaustão da cabine estática SMC primer\\nLimpeza das liminárias da cabine estática SMC ptimer\\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:30.699162	2025-11-11 03:45:30.699162	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b532726a-31c9-4e9c-9fc8-84332770abb2	386	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759890045118-y0c75246f	\N	\N	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Limpeza do fosso da exaustão da base\\nLimpeza externa das paredes e vidros das cabines da base\\nLimpeza do fosso da exaustão do verniz\\nAspiração da região superior (teto) da estufa da pintura final\\nLimpeza externa das paredes e vidros das cabines do verniz\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:31.136524	2025-11-11 03:45:31.136524	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
ab83a444-b6bf-4fd3-9133-cb5780dce91a	301	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	\N	\N	programada	concluida	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\\nTroca de filtro da exaustão da cabine da base\\nTroca de filtro da exaustão da cabine do verniz\\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \\nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	2025-10-07 21:12:14.291	2025-10-17 17:08:33.467	\N	\N	\N	\N	{"1759332012650": {"type": "photo", "count": 1, "photos": ["data:image/png;base64,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"]}, "1759436504239": "Sim."}	\N	\N	\N	\N	\N	2025-11-11 03:45:31.647538	2025-11-11 03:45:31.647538	\N	\N	\N	7913bae1-bdca-4fb4-9465-99a4754995b2	\N
b42c41aa-cbbf-4b7a-9f03-4195c403880d	469	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:32.169005	2025-11-11 03:45:32.169005	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
96c1ca49-64e5-4be6-ad04-f95e8f1c5b1a	470	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:32.578724	2025-11-11 03:45:32.578724	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f89622b2-2c52-439e-8fe3-f41db23a426d	471	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:32.987571	2025-11-11 03:45:32.987571	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8bf49dfe-8b8a-4110-89f6-53109cc95675	472	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:33.397527	2025-11-11 03:45:33.397527	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4995f68e-ab15-4ecb-97f4-db91fd3105b4	473	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:33.806537	2025-11-11 03:45:33.806537	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
70e71ab1-7a7f-434b-a04c-577f3d74f418	474	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:34.217783	2025-11-11 03:45:34.217783	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c61bd98c-3364-4950-a045-650ae0686268	475	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:34.626942	2025-11-11 03:45:34.626942	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7e489847-2814-413a-8ae3-7b113cade8f1	476	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:35.037064	2025-11-11 03:45:35.037064	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
5fb73ddf-2b43-4f89-8789-13c126706a73	477	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:35.447404	2025-11-11 03:45:35.447404	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8df2d73d-4429-429c-a3a2-9b9615631191	478	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:35.85987	2025-11-11 03:45:35.85987	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
72be2cca-9a06-4166-a5af-8fe1ef0c3312	479	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30 00:00:00	2025-10-30 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:36.270614	2025-11-11 03:45:36.270614	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8f055183-a3c8-4d24-908b-29a75317c5e8	480	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31 00:00:00	2025-10-31 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:36.6819	2025-11-11 03:45:36.6819	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8aac6209-8621-49d1-9ae7-30b20a5ae686	497	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:37.092705	2025-11-11 03:45:37.092705	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4dc5ff7a-5066-46c5-99ea-3b9bbbc3dd91	498	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:37.504138	2025-11-11 03:45:37.504138	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3e56f783-1440-4bbd-b2cd-76362a1fddf9	499	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:37.914568	2025-11-11 03:45:37.914568	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f1e7ec70-efdf-4d0f-aaaa-9117b13673bc	500	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:38.32538	2025-11-11 03:45:38.32538	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
42dfa3c0-9caf-47b1-b3f9-e319902780c2	502	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:39.146548	2025-11-11 03:45:39.146548	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
36fd852b-83b1-415b-a3ca-c38607b5da47	503	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:39.557846	2025-11-11 03:45:39.557846	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ec266b05-4b43-44de-9ac6-c3037f142804	504	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:39.968043	2025-11-11 03:45:39.968043	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
b667689e-5d8d-4ab7-b382-2076687f8264	505	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:40.378366	2025-11-11 03:45:40.378366	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
e656efab-abae-4366-bcca-492fa4142a50	506	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:40.789772	2025-11-11 03:45:40.789772	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
346ecd15-8402-47d4-b25e-2fc551cdc017	507	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:41.199659	2025-11-11 03:45:41.199659	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
18825a18-43f9-4314-a8fe-3748100017b6	508	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28 00:00:00	2025-10-28 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:41.612537	2025-11-11 03:45:41.612537	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
073ac220-6da9-41cc-aa52-61a1382d848e	509	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29 00:00:00	2025-10-29 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:42.024185	2025-11-11 03:45:42.024185	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
f20b274a-00ab-44bd-9ac0-9d45b2d4fe45	510	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30 00:00:00	2025-10-30 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:42.434235	2025-11-11 03:45:42.434235	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
edc74124-d8cd-4496-b9f6-434d8eb25e0f	511	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31 00:00:00	2025-10-31 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:42.844635	2025-11-11 03:45:42.844635	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c40807b5-818d-49ba-9fe6-312c64ef3310	512	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01 00:00:00	2025-10-01 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:43.255712	2025-11-11 03:45:43.255712	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6da5e85e-49c0-48ed-bdb7-65b5d22d6979	513	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02 00:00:00	2025-10-02 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:43.666311	2025-11-11 03:45:43.666311	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9587ef44-7b61-427a-ae7d-49bb03e82255	514	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03 00:00:00	2025-10-03 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:44.076173	2025-11-11 03:45:44.076173	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
737e828d-ce71-452e-a37d-9d41fa723bc5	515	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04 00:00:00	2025-10-04 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:44.489761	2025-11-11 03:45:44.489761	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
87f05f1e-53dc-4e25-93a3-a0a20f5f8413	516	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05 00:00:00	2025-10-05 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:44.900193	2025-11-11 03:45:44.900193	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
d3230064-2547-461a-98c8-86eb1c75ac6d	517	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06 00:00:00	2025-10-06 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:45.313025	2025-11-11 03:45:45.313025	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3e514962-b898-4d26-93ab-6be4e03b5ca8	518	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07 00:00:00	2025-10-07 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:45.725421	2025-11-11 03:45:45.725421	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
20721e63-d2e3-49a3-b15f-f09295c14611	519	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08 00:00:00	2025-10-08 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:46.136477	2025-11-11 03:45:46.136477	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
9e3a4e43-82f1-47db-be11-75af3bfc7080	520	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09 00:00:00	2025-10-09 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:46.546124	2025-11-11 03:45:46.546124	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
df8a89ad-fa61-431a-808a-7efb8028fd1c	521	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10 00:00:00	2025-10-10 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:46.956711	2025-11-11 03:45:46.956711	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8d8e4a4f-16c7-453b-b6c9-ade166a08954	522	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11 00:00:00	2025-10-11 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:47.366161	2025-11-11 03:45:47.366161	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
6424a1cc-7835-4392-af0b-a6fe818832a0	523	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12 00:00:00	2025-10-12 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:47.775817	2025-11-11 03:45:47.775817	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4e138990-132a-4b3d-b710-5c2f8354618c	524	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13 00:00:00	2025-10-13 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:48.18761	2025-11-11 03:45:48.18761	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
ced6fd87-adaa-4d10-ac55-c10bf5f7064c	525	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14 00:00:00	2025-10-14 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:48.597499	2025-11-11 03:45:48.597499	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
952277ac-c155-4af7-bda0-d94870bdbc7f	526	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15 00:00:00	2025-10-15 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:49.0092	2025-11-11 03:45:49.0092	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
be1a8241-b105-4b7b-b5a4-53f2f270f7ab	527	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16 00:00:00	2025-10-16 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:49.420607	2025-11-11 03:45:49.420607	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
61bd63cc-4047-4243-b7f7-dd40ec048045	528	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17 00:00:00	2025-10-17 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:49.836877	2025-11-11 03:45:49.836877	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
71ee6bd9-af31-4744-84bf-577edabf8d33	529	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18 00:00:00	2025-10-18 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:50.250841	2025-11-11 03:45:50.250841	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
4f9133bd-8d8c-433c-96dc-b2b993c66d9c	530	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19 00:00:00	2025-10-19 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:50.660875	2025-11-11 03:45:50.660875	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
8ca0b674-b285-4382-b10e-0a5492c04a6e	531	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20 00:00:00	2025-10-20 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:51.073963	2025-11-11 03:45:51.073963	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
c3edf137-0a80-42b4-a627-3f313b89b6d4	532	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21 00:00:00	2025-10-21 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:51.484063	2025-11-11 03:45:51.484063	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
7470898c-26d4-400f-8ccf-862646794348	533	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22 00:00:00	2025-10-22 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:51.896269	2025-11-11 03:45:51.896269	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3df1cc1f-0077-4d4a-aca4-8e35b4656369	534	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23 00:00:00	2025-10-23 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:52.308025	2025-11-11 03:45:52.308025	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
50045ddb-07c1-4b98-b92b-4920833a43dd	535	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24 00:00:00	2025-10-24 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:52.717249	2025-11-11 03:45:52.717249	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
3568c2aa-8be6-4ea4-9c7b-fa97679f42e5	536	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25 00:00:00	2025-10-25 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:53.129189	2025-11-11 03:45:53.129189	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
2f2064b8-9c7a-4803-9955-fe087dc4069e	537	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26 00:00:00	2025-10-26 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:53.539976	2025-11-11 03:45:53.539976	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
15b3b448-a759-4370-98f1-b91d1588f9b3	538	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27 00:00:00	2025-10-27 00:00:00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-11 03:45:53.950031	2025-11-11 03:45:53.950031	\N	\N	\N	43538320-fe1b-427c-9cb9-6b7ab06c1247	\N
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: neondb_owner
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
\.


--
-- Name: ai_integrations ai_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_pkey PRIMARY KEY (id);


--
-- Name: bathroom_counters bathroom_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bathroom_counters
    ADD CONSTRAINT bathroom_counters_pkey PRIMARY KEY (id);


--
-- Name: chat_conversations chat_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: checklist_templates checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: cleaning_activities cleaning_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: company_counters company_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.company_counters
    ADD CONSTRAINT company_counters_pkey PRIMARY KEY (id);


--
-- Name: custom_roles custom_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.custom_roles
    ADD CONSTRAINT custom_roles_pkey PRIMARY KEY (id);


--
-- Name: customer_counters customer_counters_customer_key_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_customer_key_unique UNIQUE (customer_id, key);


--
-- Name: customer_counters customer_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: dashboard_goals dashboard_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.dashboard_goals
    ADD CONSTRAINT dashboard_goals_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_serial_number_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_serial_number_unique UNIQUE (serial_number);


--
-- Name: equipment_types equipment_types_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_pkey PRIMARY KEY (id);


--
-- Name: maintenance_activities maintenance_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_pkey PRIMARY KEY (id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_pkey PRIMARY KEY (id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plans maintenance_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_pkey PRIMARY KEY (id);


--
-- Name: public_request_logs public_request_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.public_request_logs
    ADD CONSTRAINT public_request_logs_pkey PRIMARY KEY (id);


--
-- Name: qr_code_points qr_code_points_code_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_code_unique UNIQUE (code);


--
-- Name: qr_code_points qr_code_points_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: service_categories service_categories_code_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_code_unique UNIQUE (code);


--
-- Name: service_categories service_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_pkey PRIMARY KEY (id);


--
-- Name: service_types service_types_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_pkey PRIMARY KEY (id);


--
-- Name: service_zones service_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: site_shifts site_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.site_shifts
    ADD CONSTRAINT site_shifts_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: sla_configs sla_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sla_configs
    ADD CONSTRAINT sla_configs_pkey PRIMARY KEY (id);


--
-- Name: maintenance_plan_equipments unique_plan_equipment; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT unique_plan_equipment UNIQUE (plan_id, equipment_id);


--
-- Name: service_zones unique_service_zone; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT unique_service_zone UNIQUE (service_id, zone_id);


--
-- Name: user_role_assignments user_role_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_pkey PRIMARY KEY (id);


--
-- Name: user_site_assignments user_site_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: webhook_configs webhook_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.webhook_configs
    ADD CONSTRAINT webhook_configs_pkey PRIMARY KEY (id);


--
-- Name: work_order_comments work_order_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: work_orders_customer_number_unique; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX work_orders_customer_number_unique ON public.work_orders USING btree (customer_id, number);


--
-- Name: ai_integrations ai_integrations_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: ai_integrations ai_integrations_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ai_integrations
    ADD CONSTRAINT ai_integrations_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: audit_logs audit_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_counter_id_bathroom_counters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_counter_id_bathroom_counters_id_fk FOREIGN KEY (counter_id) REFERENCES public.bathroom_counters(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bathroom_counter_logs bathroom_counter_logs_work_order_id_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bathroom_counter_logs
    ADD CONSTRAINT bathroom_counter_logs_work_order_id_work_orders_id_fk FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: bathroom_counters bathroom_counters_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.bathroom_counters
    ADD CONSTRAINT bathroom_counters_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: chat_conversations chat_conversations_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: chat_conversations chat_conversations_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: chat_conversations chat_conversations_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_conversations
    ADD CONSTRAINT chat_conversations_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: chat_messages chat_messages_ai_integration_id_ai_integrations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_ai_integration_id_ai_integrations_id_fk FOREIGN KEY (ai_integration_id) REFERENCES public.ai_integrations(id);


--
-- Name: chat_messages chat_messages_conversation_id_chat_conversations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_conversation_id_chat_conversations_id_fk FOREIGN KEY (conversation_id) REFERENCES public.chat_conversations(id) ON DELETE CASCADE;


--
-- Name: checklist_templates checklist_templates_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: checklist_templates checklist_templates_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: checklist_templates checklist_templates_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: checklist_templates checklist_templates_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.checklist_templates
    ADD CONSTRAINT checklist_templates_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: cleaning_activities cleaning_activities_checklist_template_id_checklist_templates_i; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_checklist_template_id_checklist_templates_i FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: cleaning_activities cleaning_activities_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: cleaning_activities cleaning_activities_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: cleaning_activities cleaning_activities_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: cleaning_activities cleaning_activities_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: cleaning_activities cleaning_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: cleaning_activities cleaning_activities_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cleaning_activities
    ADD CONSTRAINT cleaning_activities_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: company_counters company_counters_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.company_counters
    ADD CONSTRAINT company_counters_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: custom_roles custom_roles_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.custom_roles
    ADD CONSTRAINT custom_roles_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: customer_counters customer_counters_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customer_counters
    ADD CONSTRAINT customer_counters_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers customers_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: dashboard_goals dashboard_goals_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.dashboard_goals
    ADD CONSTRAINT dashboard_goals_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: equipment equipment_equipment_type_id_equipment_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_equipment_type_id_equipment_types_id_fk FOREIGN KEY (equipment_type_id) REFERENCES public.equipment_types(id);


--
-- Name: equipment equipment_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: equipment_types equipment_types_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment_types
    ADD CONSTRAINT equipment_types_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment equipment_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: maintenance_activities maintenance_activities_assigned_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_assigned_user_id_users_id_fk FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: maintenance_activities maintenance_activities_checklist_template_id_maintenance_checkl; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_checklist_template_id_maintenance_checkl FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_activities maintenance_activities_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_activities maintenance_activities_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: maintenance_activities maintenance_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_checklist_template_id_maintena; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_checklist_template_id_maintena FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_executed_by_user_id_users_id_f; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_executed_by_user_id_users_id_f FOREIGN KEY (executed_by_user_id) REFERENCES public.users(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_work_order_id_work_orders_id_f; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_work_order_id_work_orders_id_f FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: maintenance_checklist_templates maintenance_checklist_templates_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_checklist_template_id_maintenance_c; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_checklist_template_id_maintenance_c FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_plan_id_maintenance_plans_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_plan_id_maintenance_plans_id_fk FOREIGN KEY (plan_id) REFERENCES public.maintenance_plans(id);


--
-- Name: maintenance_plans maintenance_plans_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: maintenance_plans maintenance_plans_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.maintenance_plans
    ADD CONSTRAINT maintenance_plans_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: public_request_logs public_request_logs_qr_code_point_id_qr_code_points_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.public_request_logs
    ADD CONSTRAINT public_request_logs_qr_code_point_id_qr_code_points_id_fk FOREIGN KEY (qr_code_point_id) REFERENCES public.qr_code_points(id);


--
-- Name: qr_code_points qr_code_points_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: qr_code_points qr_code_points_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: qr_code_points qr_code_points_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.qr_code_points
    ADD CONSTRAINT qr_code_points_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: role_permissions role_permissions_role_id_custom_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_custom_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.custom_roles(id);


--
-- Name: service_categories service_categories_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: service_categories service_categories_type_id_service_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_categories
    ADD CONSTRAINT service_categories_type_id_service_types_id_fk FOREIGN KEY (type_id) REFERENCES public.service_types(id);


--
-- Name: service_types service_types_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: service_types service_types_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: service_zones service_zones_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: service_zones service_zones_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_zones
    ADD CONSTRAINT service_zones_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: services services_category_id_service_categories_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_category_id_service_categories_id_fk FOREIGN KEY (category_id) REFERENCES public.service_categories(id);


--
-- Name: services services_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: services services_type_id_service_types_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_type_id_service_types_id_fk FOREIGN KEY (type_id) REFERENCES public.service_types(id);


--
-- Name: site_shifts site_shifts_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.site_shifts
    ADD CONSTRAINT site_shifts_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: sites sites_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: sites sites_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: sla_configs sla_configs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sla_configs
    ADD CONSTRAINT sla_configs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: user_role_assignments user_role_assignments_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: user_role_assignments user_role_assignments_role_id_custom_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_role_id_custom_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.custom_roles(id);


--
-- Name: user_role_assignments user_role_assignments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_site_assignments user_site_assignments_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: user_site_assignments user_site_assignments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_site_assignments
    ADD CONSTRAINT user_site_assignments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: users users_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: webhook_configs webhook_configs_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.webhook_configs
    ADD CONSTRAINT webhook_configs_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: work_order_comments work_order_comments_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: work_order_comments work_order_comments_work_order_id_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_order_comments
    ADD CONSTRAINT work_order_comments_work_order_id_work_orders_id_fk FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


--
-- Name: work_orders work_orders_assigned_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_assigned_user_id_users_id_fk FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_cancelled_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_cancelled_by_users_id_fk FOREIGN KEY (cancelled_by) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_checklist_template_id_checklist_templates_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_checklist_template_id_checklist_templates_id_fk FOREIGN KEY (checklist_template_id) REFERENCES public.checklist_templates(id);


--
-- Name: work_orders work_orders_cleaning_activity_id_cleaning_activities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_cleaning_activity_id_cleaning_activities_id_fk FOREIGN KEY (cleaning_activity_id) REFERENCES public.cleaning_activities(id);


--
-- Name: work_orders work_orders_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: work_orders work_orders_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: work_orders work_orders_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: work_orders work_orders_maintenance_activity_id_maintenance_activities_id_f; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_activity_id_maintenance_activities_id_f FOREIGN KEY (maintenance_activity_id) REFERENCES public.maintenance_activities(id);


--
-- Name: work_orders work_orders_maintenance_checklist_template_id_maintenance_check; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_checklist_template_id_maintenance_check FOREIGN KEY (maintenance_checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: work_orders work_orders_maintenance_plan_equipment_id_maintenance_plan_equi; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_maintenance_plan_equipment_id_maintenance_plan_equi FOREIGN KEY (maintenance_plan_equipment_id) REFERENCES public.maintenance_plan_equipments(id);


--
-- Name: work_orders work_orders_qr_code_point_id_qr_code_points_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_qr_code_point_id_qr_code_points_id_fk FOREIGN KEY (qr_code_point_id) REFERENCES public.qr_code_points(id);


--
-- Name: work_orders work_orders_rated_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_rated_by_users_id_fk FOREIGN KEY (rated_by) REFERENCES public.users(id);


--
-- Name: work_orders work_orders_service_id_services_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_service_id_services_id_fk FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: work_orders work_orders_zone_id_zones_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_zone_id_zones_id_fk FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: zones zones_site_id_sites_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_site_id_sites_id_fk FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: neondb_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

