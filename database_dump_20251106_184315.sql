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
    zone_id character varying
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
    end_time time without time zone
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
    updated_at timestamp without time zone DEFAULT now()
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
    updated_at timestamp without time zone DEFAULT now()
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
    customer_id character varying
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
    scheduled_date date,
    due_date date,
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
    cancelled_by character varying
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
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.audit_logs (id, company_id, user_id, entity_type, entity_id, action, changes, metadata, "timestamp", created_at) FROM stdin;
197769d6-e53f-463c-aed1-7fe52a0f71df	company-admin-default	\N	work_order	90d44ba2-18e6-4a34-adf9-86e254577ab1	update	\N	{"details": "Work order #1159 updated - Status: em_execucao"}	2025-11-05 12:43:04.773	2025-11-05 12:43:04.781761
c5d9eb5b-4b2c-4966-805c-c4938ac9c118	company-admin-default	\N	work_order	1c7fee0e-96e5-49b0-8353-31c78f9900b0	update	\N	{"details": "Work order #1160 updated - Status: em_execucao"}	2025-11-05 12:43:24.175	2025-11-05 12:43:24.183811
870a81e5-2e8d-4907-9304-0b78403033aa	company-admin-default	\N	work_order	76078b54-497b-46fb-a253-89b88d752ef3	update	\N	{"details": "Work order #1161 updated - Status: em_execucao"}	2025-11-05 12:43:35.801	2025-11-05 12:43:35.809709
4fde419a-e273-4f92-9333-64a76bf9250f	company-admin-default	\N	work_order	76078b54-497b-46fb-a253-89b88d752ef3	update	\N	{"details": "Work order #1161 updated - Status: concluida"}	2025-11-05 12:44:40.639	2025-11-05 12:44:40.647232
5163327f-541e-4a4a-b357-32700897b99a	company-admin-default	\N	work_order	90d44ba2-18e6-4a34-adf9-86e254577ab1	update	\N	{"details": "Work order #1159 updated - Status: concluida"}	2025-11-05 13:00:50.149	2025-11-05 13:00:50.158171
cd7f18a7-e22e-4d7b-a445-4d44ac17e5e5	company-admin-default	\N	work_order	1c7fee0e-96e5-49b0-8353-31c78f9900b0	update	\N	{"details": "Work order #1160 updated - Status: pausada"}	2025-11-05 13:01:13.154	2025-11-05 13:01:13.161338
8a9dc5c5-5243-4d87-bc9a-3f7263ba715e	company-admin-default	\N	work_order	1c7fee0e-96e5-49b0-8353-31c78f9900b0	update	\N	{"details": "Work order #1160 updated - Status: em_execucao"}	2025-11-05 13:01:16.914	2025-11-05 13:01:16.921177
e8d022d9-e994-4225-b1a6-7baa0dda9b76	company-admin-default	\N	work_order	1c7fee0e-96e5-49b0-8353-31c78f9900b0	update	\N	{"details": "Work order #1160 updated - Status: pausada"}	2025-11-05 13:03:20.747	2025-11-05 13:03:20.754132
e219a4be-29eb-4e55-a7d9-c03f51576f44	company-admin-default	\N	work_order	1c7fee0e-96e5-49b0-8353-31c78f9900b0	update	\N	{"details": "Work order #1160 updated - Status: em_execucao"}	2025-11-05 13:17:05.664	2025-11-05 13:17:05.671876
61bd73df-4f3f-4c00-968f-a707fa318e39	company-admin-default	\N	work_order	1c7fee0e-96e5-49b0-8353-31c78f9900b0	update	\N	{"details": "Work order #1160 updated - Status: concluida"}	2025-11-05 13:17:14.655	2025-11-05 13:17:14.662952
1acc2abf-ea2b-4427-ab0d-52faa624cace	company-admin-default	\N	work_order	466a101c-415e-4e44-bbf7-553592177d16	update	\N	{"details": "Work order #1175 updated - Status: em_execucao"}	2025-11-05 13:57:47.692	2025-11-05 13:57:47.699291
1be53ede-afd6-408b-81d2-ceff1490caf2	company-admin-default	\N	work_order	466a101c-415e-4e44-bbf7-553592177d16	update	\N	{"details": "Work order #1175 updated - Status: concluida"}	2025-11-05 13:58:29.964	2025-11-05 13:58:29.972927
628a723f-7822-4332-b92e-aa1e6f6d7d6e	company-admin-default	\N	work_order	740749d0-9209-4c2a-9633-7930c872125f	update	\N	{"details": "Work order #1177 updated - Status: em_execucao"}	2025-11-05 14:16:29.038	2025-11-05 14:16:29.046671
d44e8c19-6847-4ab7-938c-1dbcd3c7a3d5	company-admin-default	\N	work_order	740749d0-9209-4c2a-9633-7930c872125f	update	\N	{"details": "Work order #1177 updated - Status: pausada"}	2025-11-05 14:28:06.455	2025-11-05 14:28:06.464188
bf45b7b5-a063-4bd2-bb45-849ba07ac19b	company-admin-default	\N	work_order	740749d0-9209-4c2a-9633-7930c872125f	update	\N	{"details": "Work order #1177 updated - Status: em_execucao"}	2025-11-05 14:28:13.557	2025-11-05 14:28:13.565746
f81f83f3-fb8b-4e34-a0e4-8c8f3ba7e4d1	company-admin-default	\N	work_order	740749d0-9209-4c2a-9633-7930c872125f	update	\N	{"details": "Work order #1177 updated - Status: pausada"}	2025-11-05 14:37:02.47	2025-11-05 14:37:02.478131
34b3ec6a-9019-4065-8742-331087308056	company-admin-default	\N	work_order	740749d0-9209-4c2a-9633-7930c872125f	update	\N	{"details": "Work order #1177 updated - Status: em_execucao"}	2025-11-05 14:38:02.879	2025-11-05 14:38:02.887061
ecbc4ce0-2e3b-4dca-ba31-84611bf96c64	company-admin-default	\N	work_order	ecbebdda-67d1-4fbb-b856-075433c0d652	update	\N	{"details": "Work order #1178 updated - Status: cancelada"}	2025-11-05 16:40:10.961	2025-11-05 16:40:10.969981
44bd3631-eee2-4e8f-8fc4-6a89c1232ffd	company-admin-default	\N	work_order	a3d8735c-de34-40af-917a-09dab4e73161	update	\N	{"details": "Work order #1176 updated - Status: cancelada"}	2025-11-05 16:58:43.999	2025-11-05 16:58:44.00641
fc3269ad-f436-4f10-999a-2096ba8d00bd	company-admin-default	\N	work_order	ce1ed579-202b-40e2-b179-61da68a665b6	update	\N	{"details": "Work order #1199 updated - Status: cancelada"}	2025-11-05 19:13:22.726	2025-11-05 19:13:22.733205
2e414b28-3b2a-4b3d-94b0-d7a75848157b	company-admin-default	\N	work_order	740749d0-9209-4c2a-9633-7930c872125f	update	\N	{"details": "Work order #1177 updated - Status: concluida"}	2025-11-05 19:31:17.395	2025-11-05 19:31:17.405815
d595989c-22d8-46f9-a7ef-9231b90d85b0	company-admin-default	\N	work_order	55382f29-9977-47e2-bbde-a4d38e3ef0f1	update	\N	{"details": "Work order #1174 updated - Status: cancelada"}	2025-11-05 22:47:03.566	2025-11-05 22:47:03.575462
5c1bf16a-b659-461e-bf53-81d006aa1f7c	company-admin-default	\N	work_order	2b249aa9-25fa-47a8-b587-bcf5f7fc0bdc	update	\N	{"details": "Work order #1173 updated - Status: cancelada"}	2025-11-05 22:47:21.505	2025-11-05 22:47:21.513983
8a125e8e-c99c-429d-944a-1a5e0e08122e	company-admin-default	\N	work_order	0a72645a-7428-4d83-b48f-bc6d5b47f28a	update	\N	{"details": "Work order #1205 updated - Status: cancelada"}	2025-11-05 23:08:52.134	2025-11-05 23:08:52.141637
a6ba1149-a076-4d56-ab65-18fc8ff97b66	company-admin-default	\N	work_order	77300e15-c1fa-4593-b2b0-6e965ed25ca1	create	\N	{"details": "Work order #1206 created - Type: corretiva_interna, Priority: media, Service: 7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd, Auto-assigned:  Hours"}	2025-11-05 23:09:49.187	2025-11-05 23:09:49.194051
00966e7c-8074-40a6-a583-ebc669226d4f	company-admin-default	\N	work_order	3199ad62-628a-4474-b504-4608bda40087	create	\N	{"details": "Work order #1210 created - Type: corretiva_interna, Priority: media, Service: none, Auto-assigned:  "}	2025-11-05 23:28:51.473	2025-11-05 23:28:51.47993
1d181d1d-9625-4a7f-b81b-ab0717a46949	company-admin-default	\N	work_order	027f2e7f-3c3c-4c5f-9784-9d49bd8b9b51	update	\N	{"details": "Work order #1213 updated - Status: em_execucao"}	2025-11-06 03:11:13.44	2025-11-06 03:11:13.450788
7d27fe82-637c-4f87-9453-1c2916491e9a	company-admin-default	\N	work_order	027f2e7f-3c3c-4c5f-9784-9d49bd8b9b51	update	\N	{"details": "Work order #1213 updated - Status: concluida"}	2025-11-06 03:11:44.056	2025-11-06 03:11:44.063829
83e556bd-d971-46db-aa97-81bab5d87e15	company-admin-default	\N	work_order	7c0f2631-dc9f-4405-9818-0912ac570b12	update	\N	{"details": "Work order #1214 updated - Status: em_execucao"}	2025-11-06 03:12:04.44	2025-11-06 03:12:04.452063
bcdf2083-4e03-4747-b49a-57f2a1dbab8f	company-admin-default	\N	work_order	7c0f2631-dc9f-4405-9818-0912ac570b12	update	\N	{"details": "Work order #1214 updated - Status: concluida"}	2025-11-06 03:12:07.398	2025-11-06 03:12:07.405347
1998f132-d651-44b0-94ee-576eddedd729	company-admin-default	\N	work_order	b23a1d09-8823-4ad6-9132-27a3c7f1b317	update	\N	{"details": "Work order #1215 updated - Status: em_execucao"}	2025-11-06 03:12:25.531	2025-11-06 03:12:25.537906
028a8def-814d-4904-bade-d04d57d018f1	company-admin-default	\N	work_order	b23a1d09-8823-4ad6-9132-27a3c7f1b317	update	\N	{"details": "Work order #1215 updated - Status: pausada"}	2025-11-06 03:12:32.257	2025-11-06 03:12:32.264534
c90e6f55-7809-4eaa-967f-81ac93f0beb0	company-admin-default	\N	work_order	1d62f874-4294-4b43-b385-579b849f3854	update	\N	{"details": "Work order #1249 updated - Status: em_execucao"}	2025-11-06 17:58:21.141	2025-11-06 17:58:21.149605
ac81a11b-11bb-4d01-a199-c0016d1ce4ea	company-admin-default	\N	work_order	1d62f874-4294-4b43-b385-579b849f3854	update	\N	{"details": "Work order #1249 updated - Status: pausada"}	2025-11-06 17:58:59.918	2025-11-06 17:58:59.925057
414809ca-71ca-4621-a53b-8001dc6dc423	company-admin-default	\N	work_order	1d62f874-4294-4b43-b385-579b849f3854	update	\N	{"details": "Work order #1249 updated - Status: pausada"}	2025-11-06 17:59:34.091	2025-11-06 17:59:34.0987
80a07117-4faa-452e-a6e6-b8a1c8659b2e	company-admin-default	\N	work_order	0b7e16d3-9764-4ee0-a80f-db47359ac067	update	\N	{"details": "Work order #1224 updated - Status: em_execucao"}	2025-11-06 17:59:57.222	2025-11-06 17:59:57.229286
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
-- Data for Name: checklist_templates; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.checklist_templates (id, company_id, service_id, site_id, name, description, items, module, created_at, updated_at, zone_id) FROM stdin;
checklist-1762454463518-wZIYSqE_Dp	company-admin-default	9ac6394d-86cc-4953-94a0-947b7c15702b	0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	nova check		[{"id": "1762454463231", "type": "text", "label": "check", "options": [], "required": false, "validation": {"minLength": 3}, "description": ""}]	clean	2025-11-06 18:41:03.525852	2025-11-06 18:41:03.525852	248bf411-964e-43b7-955d-16afbbf50184
\.


--
-- Data for Name: cleaning_activities; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, frequency_config, module, checklist_template_id, sla_config_id, is_active, created_at, updated_at, start_time, end_time) FROM stdin;
ca-1762446800382-n46k2sgat	company-admin-default	03228a59-c210-48a5-90fd-c717de1296c6	0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	532f3a67-80ea-4598-b811-dc18b9cce619	teste ordem de serviço clean		diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-06 16:33:21.859439	2025-11-06 16:33:21.859439	\N	\N
ca-1762446881897-b4gkpgbqf	company-admin-default	03228a59-c210-48a5-90fd-c717de1296c6	0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	532f3a67-80ea-4598-b811-dc18b9cce619	teste de ordens clean mensal		mensal	{"monthDay": 6, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-06 16:34:42.005848	2025-11-06 16:34:42.005848	\N	\N
ca-1762454508378-spj1i5qu1	company-admin-default	9ac6394d-86cc-4953-94a0-947b7c15702b	0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	248bf411-964e-43b7-955d-16afbbf50184	check		mensal	{"monthDay": 6, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-11-06 18:41:48.507998	2025-11-06 18:41:48.507998	\N	\N
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.companies (id, name, cnpj, email, phone, address, is_active, created_at, updated_at) FROM stdin;
company-admin-default	GRUPO OPUS					t	2025-09-10 20:41:19.301367	2025-09-10 20:41:19.301367
company-opus-default	Grupo OPUS	12.345.678/0001-90	contato@grupoopus.com.br	(11) 3000-0000	Av. Paulista, 1000 - São Paulo, SP	t	2025-10-19 17:58:47.078825	2025-10-19 17:58:47.078825
\.


--
-- Data for Name: company_counters; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.company_counters (id, company_id, key, next_number, updated_at) FROM stdin;
cc-1759264397895-dj5bo9tx9	company-admin-default	work_order	1250	2025-11-06 18:41:48.784181
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
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.customers (id, company_id, name, email, phone, document, address, city, state, zip_code, contact_person, notes, modules, is_active, created_at, updated_at) FROM stdin;
43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default	FAURECIA										{clean}	t	2025-09-15 19:03:55.605952	2025-09-15 19:03:55.605952
7913bae1-bdca-4fb4-9465-99a4754995b2	company-admin-default	TECNOFIBRA										{clean}	t	2025-09-28 16:31:54.577274	2025-09-28 16:31:54.577274
20ae7c09-3fe9-4db9-a136-2992bac29e10	company-admin-default	teste										{clean}	f	2025-09-30 20:01:52.200153	2025-09-30 20:01:54.962302
customer-teste-default	company-opus-default	Cliente Teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	{clean}	t	2025-10-19 17:58:47.081652	2025-10-19 17:58:47.081652
d891d578-e86a-4cee-90f1-90158e82c2b0	company-admin-default	Teste de manutenção	manager@example.com	6723877569	53456778000176	Rua Maria de Fátima	São Paulo	SP	04404-160	Teste de Manutenção		{maintenance}	t	2025-11-04 13:38:12.622192	2025-11-04 13:38:12.622192
64107b7f-0367-49ba-99cd-a650c86a39b0	company-admin-default	cliente completo	TesteClienteCompleto@gmail.com	69983993634	74968-496	Avenida Xavier de Almeida	Aparecida de Goiânia	GO	74968-496	Teste da silva	74968-496	{clean,maintenance}	t	2025-11-06 14:07:14.41943	2025-11-06 14:07:14.41943
\.


--
-- Data for Name: dashboard_goals; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.dashboard_goals (id, company_id, module, goal_type, goal_value, current_period, is_active, created_at, updated_at) FROM stdin;
6a972bd1-3c42-4905-ba78-e2b1e4220ce4	company-admin-default	clean	eficiencia_operacional	100.00	2025-09	f	2025-09-30 21:09:36.742578	2025-09-30 21:09:38.627842
c3ab769c-4862-44ba-bf11-32e0fee8c13d	company-admin-default	clean	eficiencia_operacional	95.00	2025-10	t	2025-10-10 16:44:04.537352	2025-10-10 16:44:04.537352
b03cdce0-51c6-4d1d-a18b-2d5c586280b4	company-admin-default	clean	os_concluidas_mes	40.00	2025-11	t	2025-11-04 14:34:27.644608	2025-11-04 14:34:27.644608
d3bf57cd-0372-4cb0-9e35-eca081ceb939	company-admin-default	clean	sla_compliance	80.00	2025-11	t	2025-11-06 13:54:07.761645	2025-11-06 13:54:07.761645
f2e99695-3988-4fad-9097-cf522d2c3917	company-admin-default	maintenance	sla_compliance	85.00	2025-11	t	2025-11-06 17:28:45.191716	2025-11-06 17:28:45.191716
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.equipment (id, company_id, customer_id, site_id, zone_id, equipment_type_id, name, internal_code, manufacturer, model, serial_number, purchase_date, warranty_expiry, installation_date, status, technical_specs, maintenance_notes, qr_code_url, module, is_active, created_at, updated_at) FROM stdin;
qr_VSTgAJPncRPQ0scE0B	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	10c3b253-aa59-4a91-acb8-a3b6152f975c	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	Teste de Equipamento	\N	Samsaung	ARI-453	SN73621T-01	\N	2025-11-10	2025-11-01	operacional	\N	\N	\N	maintenance	t	2025-11-05 06:09:56.868817	2025-11-05 06:09:56.868817
IOgQcZuGAc7fBfXS7nBrz	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	10c3b253-aa59-4a91-acb8-a3b6152f975c	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	Teste de Equipamento 2 	\N	Samsaung	ARI-453-2	SN73621T-02	\N	2026-11-01	2025-11-01	operacional	\N	\N	\N	maintenance	t	2025-11-05 06:10:41.166727	2025-11-05 06:10:41.166727
p2i5Tb50MQ5epS5uhCbbF	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	10c3b253-aa59-4a91-acb8-a3b6152f975c	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	Teste de Equipamento 3	\N	Samsaung	ARI-453	SN73621T-03	\N	2026-11-01	2025-11-01	operacional	\N	\N	\N	maintenance	t	2025-11-05 06:11:34.481531	2025-11-05 06:11:34.481531
WM4I4U0fTBVtaGZOVwZcG	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	10c3b253-aa59-4a91-acb8-a3b6152f975c	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	Teste de Inoperante	\N	Samsaung	ARI-453-2	SN73621T-4	\N	2025-11-30	2025-11-05	inoperante	\N	\N	\N	maintenance	t	2025-11-05 21:53:32.42095	2025-11-05 21:53:32.42095
bZ-IQQDvC0ujQvgrhjXfw	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	10c3b253-aa59-4a91-acb8-a3b6152f975c	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	Teste de Em Manutenção	\N	Samsaung	ARI-453-2	SN73621T-5	\N	2025-12-30	2025-11-05	em_manutencao	\N	\N	\N	maintenance	t	2025-11-05 21:55:57.417104	2025-11-05 21:55:57.417104
JxyRFxgnA9ZECJyzn-rZa	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	10c3b253-aa59-4a91-acb8-a3b6152f975c	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	Teste Aposentado	\N	Samsaung	ARI-453-2	SN73621T-6	\N	2025-12-05	2025-11-05	aposentado	\N	\N	\N	maintenance	t	2025-11-05 21:57:38.868941	2025-11-05 21:57:38.868941
u64FmJq3Sls3XMEHn3vNI	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	6b4d7be2-abd3-4926-8b98-181830ba5a1f	616e248d-258c-44bb-a793-ed8acdc0ff05	\N	Equipamento Teste final 	\N	Teste final	Modelo de teste	Teste001	\N	2025-12-30	2025-11-05	operacional	\N	\N	\N	maintenance	t	2025-11-06 00:22:01.103791	2025-11-06 00:22:01.103791
ECbLexvcoT7OnV3biuPmj	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	6b4d7be2-abd3-4926-8b98-181830ba5a1f	616e248d-258c-44bb-a793-ed8acdc0ff05	\N	Teste final de fluxo equipamento	\N	Teste final	Modelo de teste	SN-3	\N	2025-11-10	2025-11-05	operacional	\N	\N	\N	maintenance	t	2025-11-06 00:32:14.608338	2025-11-06 00:32:14.608338
aL6T_RXlMMeQH2V3d21Lk	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	01ca0d3c-947d-47c3-bb7a-82d1837d031e	00d2326f-af56-497c-8c32-5a572a81a465	\N	teste de equipamento	\N	Samsaung	Dry Van Teste	SN73621T-5=7	\N	\N	2025-11-05	operacional	\N	\N	\N	maintenance	t	2025-11-06 02:34:25.152789	2025-11-06 02:34:25.152789
OJvDwtewGWbcZpGd4Bc2m	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	a899ba26-00b9-4c85-b25b-d48752c7eb4a	6b1e66e5-4523-42d5-b3a9-b4e66b37d64a	\N	Teste de Equipamento 2 	\N	Samsaung	ARI-453-2	SN73621T-2	\N	2025-11-06	2025-11-06	operacional	\N	\N	\N	maintenance	t	2025-11-06 14:50:15.367911	2025-11-06 14:50:15.367911
zcpiMjMJQlyYEHR82k81e	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	a899ba26-00b9-4c85-b25b-d48752c7eb4a	b7b7b4d6-3a99-4aee-80ab-1c26f72f3842	\N	Teste	\N	Teste final	ARI-453-2	SN73621T-1	\N	2025-11-10	2025-11-06	operacional	\N	\N	\N	maintenance	t	2025-11-06 14:49:38.813079	2025-11-06 14:51:36.63097
Z-KRyk4_-ZhHTff7Dpmd4	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	a899ba26-00b9-4c85-b25b-d48752c7eb4a	b7b7b4d6-3a99-4aee-80ab-1c26f72f3842	\N	Teste zz	\N	Samsaung	Dry Van Teste	SN-3242	\N	2025-11-06	2025-11-06	operacional	\N	\N	\N	maintenance	t	2025-11-06 14:54:32.107686	2025-11-06 14:54:32.107686
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
ma-1762384113700-w65jbaiyp	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	{10c3b253-aa59-4a91-acb8-a3b6152f975c}	{19bfd0c9-043f-4da1-bbce-f94aa6a7d983}	{p2i5Tb50MQ5epS5uhCbbF,IOgQcZuGAc7fBfXS7nBrz,qr_VSTgAJPncRPQ0scE0B}	\N	\N	Teste de Manutenção		preventiva	mensal	{"monthDay": 5, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	ipL3x9KSsRl9gC6jEWh4r	\N	\N	\N	\N	2025-11-05	\N	t	2025-11-05 23:08:33.709135	2025-11-05 23:08:33.709135	\N	\N
ma-1762390081388-7vepvygwz	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	{6b4d7be2-abd3-4926-8b98-181830ba5a1f}	{fcd30124-2917-4041-bb61-8ef5982cd08d,616e248d-258c-44bb-a793-ed8acdc0ff05}	{u64FmJq3Sls3XMEHn3vNI,ECbLexvcoT7OnV3biuPmj}	\N	\N	Teste de manutenção 3		preventiva	mensal	{"monthDay": 5, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	riVgS2TLqhRLKwpqZtVn9	\N	\N	\N	\N	2025-11-05	\N	t	2025-11-06 00:48:01.512681	2025-11-06 00:48:01.512681	\N	\N
ma-1762396814250-oubsfl7gt	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	{01ca0d3c-947d-47c3-bb7a-82d1837d031e}	{00d2326f-af56-497c-8c32-5a572a81a465}	{aL6T_RXlMMeQH2V3d21Lk}	\N	\N	Teste		preventiva	mensal	{"monthDay": 6, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	W1ojibZ6WgMBOCl_sc9-_	\N	\N	\N	\N	2025-11-06	\N	t	2025-11-06 02:40:14.359242	2025-11-06 02:40:14.359242	\N	\N
ma-1762397169759-7mjcqqg5p	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	{01ca0d3c-947d-47c3-bb7a-82d1837d031e}	{00d2326f-af56-497c-8c32-5a572a81a465}	{aL6T_RXlMMeQH2V3d21Lk}	\N	\N	teste tttt		preventiva	mensal	{"monthDay": 6, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	W1ojibZ6WgMBOCl_sc9-_	\N	\N	\N	\N	2025-11-06	\N	t	2025-11-06 02:46:09.767708	2025-11-06 02:46:09.767708	\N	\N
ma-1762397312468-ifwq24l5h	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	{01ca0d3c-947d-47c3-bb7a-82d1837d031e}	{00d2326f-af56-497c-8c32-5a572a81a465}	{aL6T_RXlMMeQH2V3d21Lk}	\N	\N	teste dia 06		preventiva	mensal	{"monthDay": 6, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	W1ojibZ6WgMBOCl_sc9-_	\N	\N	\N	\N	2025-11-06	\N	t	2025-11-06 02:48:32.562365	2025-11-06 02:48:32.562365	\N	\N
ma-1762441308893-hpjqoammj	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	{a899ba26-00b9-4c85-b25b-d48752c7eb4a}	{b7b7b4d6-3a99-4aee-80ab-1c26f72f3842,6b1e66e5-4523-42d5-b3a9-b4e66b37d64a}	{Z-KRyk4_-ZhHTff7Dpmd4,zcpiMjMJQlyYEHR82k81e,OJvDwtewGWbcZpGd4Bc2m}	\N	\N	teste de ordens		preventiva	mensal	{"monthDay": 6, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	MHqgRtiwGe9uodAbYVnEJ	\N	\N	\N	\N	2025-11-06	\N	t	2025-11-06 15:01:48.902288	2025-11-06 15:01:48.902288	\N	\N
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
ipL3x9KSsRl9gC6jEWh4r	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Teste checklist	Teste do checklist	1.0	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	{10c3b253-aa59-4a91-acb8-a3b6152f975c}	{19bfd0c9-043f-4da1-bbce-f94aa6a7d983}	{p2i5Tb50MQ5epS5uhCbbF,IOgQcZuGAc7fBfXS7nBrz,qr_VSTgAJPncRPQ0scE0B}	[{"id": "bYD2KZhc_2TtgZMxwfaAT", "type": "checkbox", "label": "Teste de checkbox", "options": ["Teste de checkbox", "Teste de checkbox"], "required": false, "validation": {"minChecked": 1}, "description": ""}]	maintenance	t	2025-11-05 12:29:52.888904	2025-11-05 12:29:52.888904
XtZnQymV7ZSHatd2lUybA	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Teste de checklist 2 	\N	1.0	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	{10c3b253-aa59-4a91-acb8-a3b6152f975c}	{19bfd0c9-043f-4da1-bbce-f94aa6a7d983}	{qr_VSTgAJPncRPQ0scE0B}	[{"id": "JroHam6DdlNTqDfElWAiX", "type": "checkbox", "label": "Teste de checklist 2 ", "options": ["Teste de checkbox 1", "Teste de checkbox 2", "Teste de checkbox 3"], "required": false, "validation": {"maxChecked": 2, "minChecked": 1}, "description": ""}]	maintenance	t	2025-11-05 12:48:15.202352	2025-11-05 12:48:15.202352
OX2v6ykMquS7_iDpSe-En	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Teste de Checklist 3	Checklist descrição	1.0	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	{10c3b253-aa59-4a91-acb8-a3b6152f975c}	{19bfd0c9-043f-4da1-bbce-f94aa6a7d983}	{p2i5Tb50MQ5epS5uhCbbF,IOgQcZuGAc7fBfXS7nBrz,qr_VSTgAJPncRPQ0scE0B}	[{"id": "0T_-D748_osn7nIlISfxL", "type": "checkbox", "label": "Checklist total", "options": ["1", "2", "3", "4"], "required": false, "validation": {"minChecked": 1}, "description": ""}, {"id": "I0sunzt71THjgS_mOJj-l", "type": "text", "label": "Teste texto", "options": [], "required": false, "validation": {"minLength": 10}, "description": ""}, {"id": "UCb2Xl-dJNZEbn3-2UbSo", "type": "number", "label": "Teste número", "options": [], "required": false, "validation": {"minValue": 30}, "description": ""}, {"id": "ZVFdf7Un7Rh9sC6V-axCt", "type": "photo", "label": "Teste de foto", "options": [], "required": true, "validation": {"photoMinCount": 1}, "description": ""}]	maintenance	t	2025-11-05 13:45:53.633038	2025-11-05 13:45:53.633038
AwgEwWGiY2dWOzYBfCDGP	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Teste de Checklist final	\N	1.0	69e3e773-7fbc-4838-bf46-83b661624366	{6b4d7be2-abd3-4926-8b98-181830ba5a1f}	{616e248d-258c-44bb-a793-ed8acdc0ff05}	{u64FmJq3Sls3XMEHn3vNI}	[{"id": "69W8-onIS2Hhvdu9oqlVj", "type": "checkbox", "label": "Teste final", "options": ["op1"], "required": false, "validation": {"minChecked": 1}, "description": ""}]	maintenance	t	2025-11-06 00:23:41.598947	2025-11-06 00:23:41.598947
eJX1AfcDzgil9SEes_Snl	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	checklist total teste	\N	1.0	69e3e773-7fbc-4838-bf46-83b661624366	{6b4d7be2-abd3-4926-8b98-181830ba5a1f}	{fcd30124-2917-4041-bb61-8ef5982cd08d,616e248d-258c-44bb-a793-ed8acdc0ff05}	{u64FmJq3Sls3XMEHn3vNI}	[{"id": "FD8Xum0Pz2f33gJLFRT7a", "type": "text", "label": "teste", "options": [], "required": false, "validation": {}, "description": ""}]	maintenance	t	2025-11-06 00:31:21.143646	2025-11-06 00:31:21.143646
riVgS2TLqhRLKwpqZtVn9	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Multiteste	\N	1.0	69e3e773-7fbc-4838-bf46-83b661624366	{6b4d7be2-abd3-4926-8b98-181830ba5a1f,10c3b253-aa59-4a91-acb8-a3b6152f975c}	{fcd30124-2917-4041-bb61-8ef5982cd08d,616e248d-258c-44bb-a793-ed8acdc0ff05,19bfd0c9-043f-4da1-bbce-f94aa6a7d983}	{ECbLexvcoT7OnV3biuPmj,u64FmJq3Sls3XMEHn3vNI,JxyRFxgnA9ZECJyzn-rZa}	[{"id": "VUKpFkgsPnrqi8-7O8x8P", "type": "text", "label": "texto", "options": [], "required": false, "validation": {}, "description": ""}]	maintenance	t	2025-11-06 00:32:58.143681	2025-11-06 00:32:58.143681
W1ojibZ6WgMBOCl_sc9-_	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	teste 44	\N	1.0	e8503cbe-c8f6-49ee-ba27-265a93151e00	{01ca0d3c-947d-47c3-bb7a-82d1837d031e}	{00d2326f-af56-497c-8c32-5a572a81a465}	{aL6T_RXlMMeQH2V3d21Lk}	[{"id": "CwB7BRuTJUxLHlQLw-EmF", "type": "text", "label": "teste", "options": [], "required": false, "validation": {}, "description": ""}]	maintenance	t	2025-11-06 02:39:34.24063	2025-11-06 02:39:34.24063
MHqgRtiwGe9uodAbYVnEJ	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	teste	\N	1.0	03228a59-c210-48a5-90fd-c717de1296c6	{a899ba26-00b9-4c85-b25b-d48752c7eb4a}	{b7b7b4d6-3a99-4aee-80ab-1c26f72f3842,6b1e66e5-4523-42d5-b3a9-b4e66b37d64a}	{Z-KRyk4_-ZhHTff7Dpmd4,zcpiMjMJQlyYEHR82k81e,OJvDwtewGWbcZpGd4Bc2m}	[{"id": "4N0ewy4msf2ThC1ulunhs", "type": "checkbox", "label": "Fez o teste", "options": ["Sim", "Não"], "required": false, "validation": {"minChecked": 1}, "description": ""}]	maintenance	t	2025-11-06 14:55:58.754472	2025-11-06 14:55:58.754472
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
c9f21c8a-be2d-4f47-bd08-774ec734b150	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	\N	93d4ad00-0aa3-4980-b6d0-056a5685d10d	execucao	Teste Qr Code	\N	5	maintenance	t	2025-11-05 06:09:06.207245	2025-11-05 06:09:06.207245
15c22540-f56a-4ff2-9adb-6548de326bd7	616e248d-258c-44bb-a793-ed8acdc0ff05	\N	\N	edcc0ada-5a6a-4b35-bd41-37fecc0b1a89	execucao	Zona de teste fluxo final	\N	5	maintenance	t	2025-11-06 00:19:42.26037	2025-11-06 00:19:42.26037
2271e1dc-0b03-47f3-8cda-71eb3a1b4d96	93dd126e-96ab-496c-9664-4ab7ea0cc40d	\N	\N	5c9c9088-44fb-4756-a176-6bb41ecb1973	execucao	Teste final zona 1	\N	5	maintenance	t	2025-11-06 02:23:20.445062	2025-11-06 02:23:20.445062
b2058a64-eedb-4b24-a6a5-44a35ae7cb1f	7f45e6ad-7692-4046-b3f5-649f1695ccb0	\N	\N	bfa3a14e-731a-40a5-ac3b-23455337a12c	execucao	Teste final zona 2	\N	5	maintenance	t	2025-11-06 02:23:35.502923	2025-11-06 02:23:35.502923
09224fd3-fe1d-4d9a-a7c5-b4c6df3054c8	00d2326f-af56-497c-8c32-5a572a81a465	\N	\N	6b27249e-ad0e-4373-a73a-00378ccca06c	execucao	Teste final zona 3	\N	5	maintenance	t	2025-11-06 02:23:49.275118	2025-11-06 02:23:49.275118
67e7e406-b113-4f51-bf81-d75f86051d3a	b7b7b4d6-3a99-4aee-80ab-1c26f72f3842	\N	\N	5d78747c-9dff-4c05-8dae-1f0ee7be321b	execucao	teste de zona 1	\N	5	maintenance	t	2025-11-06 14:43:41.982622	2025-11-06 14:43:41.982622
5ab989a1-8eed-44bb-a86b-38292dba68e1	6b1e66e5-4523-42d5-b3a9-b4e66b37d64a	\N	\N	0a572f61-e0a7-417b-94f2-6e8bea28251c	execucao	teste de zona 2	\N	5	maintenance	t	2025-11-06 14:43:52.103423	2025-11-06 14:43:52.103423
fe2aba32-e1fa-4e34-b763-30eb28ab480f	248bf411-964e-43b7-955d-16afbbf50184	\N	\N	7dacab23-bcc7-4baa-8d64-93925d2d9489	execucao	teste de local	\N	5	clean	t	2025-11-06 15:02:34.437942	2025-11-06 15:02:34.437942
84e73569-57a9-4360-b047-89cc1e39b0ad	532f3a67-80ea-4598-b811-dc18b9cce619	\N	\N	dabd4742-d393-4f4b-ae84-ae1dc1420c96	execucao	teste de zona	\N	5	clean	t	2025-11-06 15:02:51.964081	2025-11-06 15:02:51.964081
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
\.


--
-- Data for Name: service_types; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.service_types (id, name, description, code, module, is_active, created_at, updated_at, customer_id) FROM stdin;
st-emergency	Emergência	Serviços de emergência com atendimento crítico imediato	EMERG_SVC	clean	t	2025-09-22 20:27:06.022123	2025-09-22 20:27:06.022123	43538320-fe1b-427c-9cb9-6b7ab06c1247
st-preventive	Preventivo	Serviços de manutenção preventiva programada regular	PREV_SVC	clean	t	2025-09-22 20:27:06.022123	2025-09-22 20:27:06.022123	43538320-fe1b-427c-9cb9-6b7ab06c1247
fd87bcf6-fc20-4157-84db-bda39a303069	Preventiva	Limpeza programada.	PVT	clean	t	2025-09-29 11:34:51.663005	2025-09-29 11:34:51.663005	7913bae1-bdca-4fb4-9465-99a4754995b2
2fa15718-d1aa-4a21-9438-4c21b4c4342b	Preventivo	Manutenção preventiva	MNT_PREV	clean	t	2025-11-04 14:27:21.045528	2025-11-04 14:27:21.045528	d891d578-e86a-4cee-90f1-90158e82c2b0
a92a5290-57e9-4705-bafb-a517796a199b	Imprevisto	Serviço Urgente.	MNT_UGT	clean	t	2025-11-04 14:31:53.52691	2025-11-04 14:31:53.52691	d891d578-e86a-4cee-90f1-90158e82c2b0
9db6b666-16c8-430b-af34-03b5b6f3affc	Teste	teste\n	teste	maintenance	t	2025-11-04 17:05:19.039113	2025-11-04 17:05:19.039113	d891d578-e86a-4cee-90f1-90158e82c2b0
6ddace65-c01a-4393-a88d-13381db9b9aa	Teste final	Teste final de fluxo\n	Teste final	maintenance	t	2025-11-06 00:13:29.011071	2025-11-06 00:13:29.011071	d891d578-e86a-4cee-90f1-90158e82c2b0
5ff6ea00-71c7-4e0a-a918-3085be6c2a62	Teste final de serviço		teste final f	maintenance	t	2025-11-06 02:20:41.979106	2025-11-06 02:20:41.979106	d891d578-e86a-4cee-90f1-90158e82c2b0
5a82876a-e70d-4646-8cce-eb68e17b57d0	Teste dawn		tesste dawn	maintenance	t	2025-11-06 13:53:03.824652	2025-11-06 13:53:03.824652	d891d578-e86a-4cee-90f1-90158e82c2b0
def4e4f5-40b8-4453-9f43-b7c72ea84649	teste completo		tst_all	clean	t	2025-11-06 14:13:50.475816	2025-11-06 14:13:50.475816	64107b7f-0367-49ba-99cd-a650c86a39b0
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
7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	Teste de serviço	Teste de serviço descrição	12	media	\N	maintenance	t	2025-11-05 06:07:51.640385	2025-11-05 06:07:51.640385	d891d578-e86a-4cee-90f1-90158e82c2b0	\N	9db6b666-16c8-430b-af34-03b5b6f3affc
69e3e773-7fbc-4838-bf46-83b661624366	Teste final de fluxo	Teste final de fluxo	40	media	\N	maintenance	t	2025-11-06 00:13:54.67686	2025-11-06 00:13:54.67686	d891d578-e86a-4cee-90f1-90158e82c2b0	\N	6ddace65-c01a-4393-a88d-13381db9b9aa
e8503cbe-c8f6-49ee-ba27-265a93151e00	teste final de serviço		40	media	\N	maintenance	t	2025-11-06 02:21:05.000526	2025-11-06 02:21:05.000526	d891d578-e86a-4cee-90f1-90158e82c2b0	\N	5ff6ea00-71c7-4e0a-a918-3085be6c2a62
b0428dd4-1c68-4220-bbee-838ce2c4b762	teste dawn		30	media	\N	maintenance	t	2025-11-06 13:53:29.464428	2025-11-06 13:53:29.464428	d891d578-e86a-4cee-90f1-90158e82c2b0	\N	5a82876a-e70d-4646-8cce-eb68e17b57d0
03228a59-c210-48a5-90fd-c717de1296c6	serviço de teste completo		22	media	\N	maintenance	t	2025-11-06 14:14:23.735036	2025-11-06 14:14:23.735036	64107b7f-0367-49ba-99cd-a650c86a39b0	\N	def4e4f5-40b8-4453-9f43-b7c72ea84649
9ac6394d-86cc-4953-94a0-947b7c15702b	teste de serviço clean		30	media	\N	clean	t	2025-11-06 16:31:11.550675	2025-11-06 16:31:11.550675	64107b7f-0367-49ba-99cd-a650c86a39b0	\N	def4e4f5-40b8-4453-9f43-b7c72ea84649
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
ff191700-ac34-4df7-accc-1d420568d645	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	clean	Fabrica Central	Joinville			t	2025-09-29 12:03:00.214659	2025-09-29 12:03:15.394842
site-faurecia-vestiarios	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	VESTIÁRIOS	Faurecia - Vestiários	\N	\N	t	2025-10-03 20:36:46.827984	2025-10-03 20:36:46.827984
site-faurecia-ambulatorio	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	AMBULATÓRIO	Faurecia - Ambulatório	\N	\N	t	2025-10-03 20:36:46.827984	2025-10-03 20:36:46.827984
site-faurecia-refeitorio	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	REFEITÓRIO	Faurecia - Refeitório	\N	\N	t	2025-10-03 20:36:46.827984	2025-10-03 20:36:46.827984
site-faurecia-portaria	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	PORTARIA	Faurecia - Portaria	\N	\N	t	2025-10-03 20:36:46.827984	2025-10-03 20:36:46.827984
site-faurecia-administrativo	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	ADMINISTRATIVO	Faurecia - Administrativo	\N	\N	t	2025-10-03 20:36:46.827984	2025-10-03 20:36:46.827984
site-faurecia-producao	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	PRODUÇÃO	Faurecia - Produção	\N	\N	t	2025-10-03 20:36:46.827984	2025-10-03 20:36:46.827984
69c6973a-c8a1-427b-84ed-ced27300d7d3	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	clean	Fábrica Principal	DASXXASDAS	oasdoa	\N	t	2025-11-03 21:52:21.063746	2025-11-03 21:52:21.063746
abe90b75-109e-4980-a1cc-4f787cb886b9	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	maintenance	TESTE MANU	teSTE DO tESTE	\N	\N	t	2025-11-03 22:23:04.833771	2025-11-03 22:23:04.833771
a309bcbc-466a-4aba-8515-fd1a39bdbb29	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	maintenance	Teste de Local	Teste de Rua	Teste	\N	t	2025-11-04 00:04:16.817497	2025-11-04 00:04:16.817497
10c3b253-aa59-4a91-acb8-a3b6152f975c	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	maintenance	Local de Teste	Endereço Teste	Teste de Locais	\N	t	2025-11-04 14:34:52.360963	2025-11-04 14:34:52.360963
6b4d7be2-abd3-4926-8b98-181830ba5a1f	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	maintenance	Local de Teste final	Teste final de fluxo	Teste final de fluxo	\N	t	2025-11-06 00:14:19.449351	2025-11-06 00:14:19.449351
01ca0d3c-947d-47c3-bb7a-82d1837d031e	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	maintenance	Teste final de local	teste final	\N	\N	t	2025-11-06 02:21:25.029587	2025-11-06 02:21:25.029587
e956f4f6-599c-4d7f-9c28-621d6ba2241a	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	maintenance	teste dawn	teste der rua	\N	\N	t	2025-11-06 13:54:29.270409	2025-11-06 13:54:29.270409
0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	clean	teste completo	teste completo	\N	\N	t	2025-11-06 14:15:51.481928	2025-11-06 14:15:51.481928
a899ba26-00b9-4c85-b25b-d48752c7eb4a	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	maintenance	teste de local completo	teste	\N	\N	t	2025-11-06 14:42:27.950582	2025-11-06 14:42:27.950582
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
ura-1762380778683-6jajolmys	user-teste.cliente-1762380778290	role-1759340407-cliente	d891d578-e86a-4cee-90f1-90158e82c2b0	2025-11-05 22:12:58.689784
ura-1762388108097-11pc2kvsd	user-teste.final-1762388107696	role-1759340407-operador	d891d578-e86a-4cee-90f1-90158e82c2b0	2025-11-06 00:15:08.105155
ura-1762438802372-7wdmmormo	user-usuario.completo-1762438801885	role-1759340407-operador	64107b7f-0367-49ba-99cd-a650c86a39b0	2025-11-06 14:20:02.380551
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
user-CLIENTE-1759343961359	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	CLIENTE	CLIENTE	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	CLIENTE	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-01 18:39:21.841755	2025-10-01 18:39:21.841755
user-cliente-1759348116705	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	cliente	cliente	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	cliente	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-01 19:48:37.156067	2025-10-01 19:48:37.156067
edd03c06-0426-4b21-a04d-f0fa8e48614b	company-admin-default	\N	novouser	novo@opus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Novo Usuario	admin	opus_user	\N	local	\N	\N	{clean}	f	2025-10-03 19:50:12.82637	2025-10-03 19:50:41.221367
39752b08-e1a2-491e-881b-818f00af20ab	company-admin-default	\N	teste123	teste@gmail.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	teste	admin	opus_user	\N	local	\N	\N	{clean}	f	2025-10-03 19:50:37.283292	2025-10-03 19:50:44.05959
42f5fd80-cc79-4f2a-946e-91b8abb67da3	company-admin-default	\N	opus123	opus123@opus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	opus123	admin	opus_user	\N	local	\N	\N	{clean}	f	2025-10-03 19:50:56.90826	2025-10-03 19:51:00.378371
10dbff4c-de78-41a4-a9f0-d9d28e62c8a3	company-admin-default	\N	thiago.lancelotti	thiago.lancelotti@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	thiago.lancelotti	admin	opus_user	\N	local	\N	\N	{clean}	t	2025-10-05 14:50:05.671043	2025-10-05 14:50:05.671043
user-manoel.mariano-1759521589871	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	manoel.mariano	manoel.mariano	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	manoel.mariano	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-03 19:59:50.309608	2025-10-06 14:01:13.504171
user-marcelo.cananea-1760461316804	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	marcelo.cananea	marcelo.cananea@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Marcelo 	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-14 14:01:57.191224	2025-10-14 15:21:06.645876
user-rita.caetano-1760548000058	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	rita.caetano	rita.caetano@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Rita Caetano	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-15 14:06:40.437454	2025-10-15 14:06:40.437454
user-valmir.vitor-1760549832765	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	valmir.vitor	valmir.vitor@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Valmir Vitor	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-15 14:37:13.137207	2025-10-15 14:37:13.137207
user-cristiane.aparecida-1760549898846	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	cristiane.aparecida	cristiane.aparecida@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Cristiane Aparecida	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-15 14:38:19.215855	2025-10-15 14:38:19.215855
user-andreia.nicolau-1760549944643	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	andreia.nicolau	andreia.nicolau@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Andreia Nicolau	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-15 14:39:05.016494	2025-10-15 14:39:05.016494
user-nubia.solange-1760549986782	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	nubia.solange	nubia.solange@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Nubia Solange	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-15 14:39:47.155811	2025-10-15 14:39:47.155811
user-valeria.pessoa-1760550018472	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	valeria.pessoa	valeria.pessoa@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Valeria Pessoa	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-15 14:40:18.854005	2025-10-15 14:40:18.854005
user-Eduardo.Santos-1760638771842	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	Eduardo.Santos	eduardo.santos@tecnofibras.com.br	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Eduardo Santos	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-10-16 15:19:32.214869	2025-10-16 15:19:32.214869
840a9cf4-19c2-4547-bb60-58a6c40b2e4a	company-opus-default	\N	marcos.mattos 	marcos.mattos@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Marcos Mattos	operador	opus_user	\N	local	\N	\N	{clean}	f	2025-10-27 16:22:26.231216	2025-10-27 16:29:59.139225
op-teste-1758573497.448657	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	teste	teste@operador.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Operador Teste	operador	opus_user		local			{clean}	t	2025-09-22 20:38:17.448657	2025-10-29 14:51:58.036405
d0f1f357-cdda-49a8-874b-ddad849b0f66	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	operador1	operador1@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	João Operador	operador	opus_user		local			{clean}	t	2025-09-22 10:40:01.589971	2025-10-29 14:56:13.294323
user-TesteManu-1762213291259	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	TesteManu	teste@teste.com	$2b$12$GWFcw/1Fh5jeYn/TOndztOP7PNbwjm3fTJWzHSPiBqWv4YirVQMzS	Teste2	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-03 23:41:31.619296	2025-11-03 23:41:31.619296
user-testeM-1762214239673	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	testeM	Teste@teste.com	$2b$10$JczMQlkZNakHf3FW/osZ5udZ1owC5wsO8GpCBfjQY9RvhCuJLdqg6	Teste Manutenção	operador	customer_user	\N	local	\N	\N	{clean}	t	2025-11-03 23:57:20.12052	2025-11-04 12:49:29.59965
user-Teste.manutencao-1762267308881	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Teste.manutencao	TestedeTeste@gmail.com	$2b$12$0q1SVVyXapHrPFczBHbWbuqFffsSOt5boQ1JT3EgrD.s2NbSnPeya	Teste de manutenção	operador	customer_user	\N	local	\N	\N	{maintenance}	t	2025-11-04 14:41:49.300472	2025-11-04 14:41:49.300472
user-admin-opus	company-admin-default	\N	admin	admin@grupoopus.com	$2b$10$dOeREOIuR8PTdOxC/g6XAugas2Kg0rdxJgI1P.U9ssk0QifDSfRdm	Administrador Sistema	admin	opus_user		local			{clean,maintenance}	t	2025-09-10 20:41:26.774513	2025-09-10 20:41:26.774513
user-teste.cliente-1762380778290	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	teste.cliente	testedecliente@gmail.com	$2b$12$EDavdoCvHjBxIZzL6L6Ac.paDpxDGpC35SEICfXM5KVCOW9RKmete	teste de cliente	operador	customer_user	\N	local	\N	\N	{maintenance}	t	2025-11-05 22:12:58.658353	2025-11-05 22:12:58.658353
user-teste.final-1762388107696	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	teste.final	Testefinal@gmail.com	$2b$12$YPAg3Czbn5JaNE.pvH9BgOTgtN3IHgVJStQ2.u0zPIvQOetwR6ote	Teste Final	operador	customer_user	\N	local	\N	\N	{maintenance}	t	2025-11-06 00:15:08.081392	2025-11-06 00:15:08.081392
user-usuario.completo-1762438801885	company-admin-default	64107b7f-0367-49ba-99cd-a650c86a39b0	usuario.completo	testetetete@gmail.com	$2b$12$WwlnPkpVEjmRr3cHyxQ6pulMQlSBJ0BRwja2j7.ifXYAe2tNe6.uO	usuario de teste completo	operador	customer_user	\N	local	\N	\N	{clean,maintenance}	t	2025-11-06 14:20:02.357218	2025-11-06 14:20:02.357218
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
d0e02816-a861-4198-adbe-a082ca01decd	027f2e7f-3c3c-4c5f-9784-9d49bd8b9b51	user-Teste.manutencao-1762267308881	⏯️ Teste de manutenção iniciou a execução da OS	\N	f	2025-11-06 03:11:13.670265	2025-11-06 03:11:13.670265
6ea0445a-c661-4b85-b063-f10b25acbe6f	027f2e7f-3c3c-4c5f-9784-9d49bd8b9b51	user-Teste.manutencao-1762267308881	✅ OS Finalizada!\n\n📋 Checklist:\n• teste: Teste\n	[]	f	2025-11-06 03:11:44.307877	2025-11-06 03:11:44.307877
b3aa0de3-eeab-4509-adb4-83a9c247d55c	7c0f2631-dc9f-4405-9818-0912ac570b12	user-Teste.manutencao-1762267308881	⏯️ Teste de manutenção iniciou a execução da OS	\N	f	2025-11-06 03:12:04.692194	2025-11-06 03:12:04.692194
23096b11-03e1-4aee-8d82-ef23d53fe303	7c0f2631-dc9f-4405-9818-0912ac570b12	user-Teste.manutencao-1762267308881	✅ OS Finalizada!\n\n📋 Checklist:\n	[]	f	2025-11-06 03:12:07.615421	2025-11-06 03:12:07.615421
921b9c53-7a8e-48eb-8b51-90dcfaec10c4	b23a1d09-8823-4ad6-9132-27a3c7f1b317	user-Teste.manutencao-1762267308881	⏯️ Teste de manutenção iniciou a execução da OS	\N	f	2025-11-06 03:12:25.748026	2025-11-06 03:12:25.748026
0592ce74-9741-4442-b19a-41d1afed0840	b23a1d09-8823-4ad6-9132-27a3c7f1b317	user-Teste.manutencao-1762267308881	⏸️ Teste de manutenção pausou a OS\n\n📝 Motivo: Teste\n	\N	f	2025-11-06 03:12:32.531987	2025-11-06 03:12:32.531987
34ddc344-f7be-4f11-8d64-b6e61aba311b	1d62f874-4294-4b43-b385-579b849f3854	user-usuario.completo-1762438801885	⏯️ usuario de teste completo iniciou a execução da OS	\N	f	2025-11-06 17:58:21.406884	2025-11-06 17:58:21.406884
468598a8-6b23-4d8f-9cfb-fa6275da3c24	1d62f874-4294-4b43-b385-579b849f3854	user-usuario.completo-1762438801885	⏸️ usuario de teste completo pausou a OS\n\n📝 Motivo: Sem checklist 	\N	f	2025-11-06 17:59:00.163817	2025-11-06 17:59:00.163817
ee638c75-a672-48c1-ac67-7bc36f88860f	1d62f874-4294-4b43-b385-579b849f3854	user-usuario.completo-1762438801885	⏸️ usuario de teste completo pausou a OS\n\n📝 Motivo: Sem checklist 	\N	f	2025-11-06 17:59:34.329699	2025-11-06 17:59:34.329699
e5dc6f2f-fc72-4375-8aa8-a4baf4179c24	0b7e16d3-9764-4ee0-a80f-db47359ac067	user-usuario.completo-1762438801885	⏯️ usuario de teste completo iniciou a execução da OS	\N	f	2025-11-06 17:59:57.447535	2025-11-06 17:59:57.447535
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.work_orders (id, number, company_id, module, zone_id, service_id, cleaning_activity_id, maintenance_activity_id, checklist_template_id, maintenance_checklist_template_id, equipment_id, maintenance_plan_equipment_id, type, status, priority, title, description, assigned_user_id, origin, qr_code_point_id, requester_name, requester_contact, scheduled_date, due_date, scheduled_start_at, scheduled_end_at, started_at, completed_at, estimated_hours, sla_start_minutes, sla_complete_minutes, observations, checklist_data, attachments, customer_rating, customer_rating_comment, rated_at, rated_by, created_at, updated_at, cancellation_reason, cancelled_at, cancelled_by) FROM stdin;
4375d665-09e2-4874-8506-9675f087df64	1216	company-admin-default	maintenance	6b1e66e5-4523-42d5-b3a9-b4e66b37d64a	03228a59-c210-48a5-90fd-c717de1296c6	\N	ma-1762441308893-hpjqoammj	\N	MHqgRtiwGe9uodAbYVnEJ	OJvDwtewGWbcZpGd4Bc2m	\N	programada	aberta	media	teste de ordens - Teste de Equipamento 2 	Manutenção preventiva para Teste de Equipamento 2 	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 15:01:49.277709	2025-11-06 15:01:49.277709	\N	\N	\N
4fd3c4b8-9bf5-4dc7-9d01-1306b7cb2b59	1217	company-admin-default	maintenance	b7b7b4d6-3a99-4aee-80ab-1c26f72f3842	03228a59-c210-48a5-90fd-c717de1296c6	\N	ma-1762441308893-hpjqoammj	\N	MHqgRtiwGe9uodAbYVnEJ	zcpiMjMJQlyYEHR82k81e	\N	programada	aberta	media	teste de ordens - Teste	Manutenção preventiva para Teste	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 15:01:49.365457	2025-11-06 15:01:49.365457	\N	\N	\N
d63aa9e8-9689-4902-86cf-ec49a62bdefd	1218	company-admin-default	maintenance	b7b7b4d6-3a99-4aee-80ab-1c26f72f3842	03228a59-c210-48a5-90fd-c717de1296c6	\N	ma-1762441308893-hpjqoammj	\N	MHqgRtiwGe9uodAbYVnEJ	Z-KRyk4_-ZhHTff7Dpmd4	\N	programada	aberta	media	teste de ordens - Teste zz	Manutenção preventiva para Teste zz	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 15:01:49.441092	2025-11-06 15:01:49.441092	\N	\N	\N
f3b5a0b3-efe0-460f-a2e7-e37a0474e8c5	1219	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-01	2025-11-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.289725	2025-11-06 16:33:22.289725	\N	\N	\N
945991e7-b3aa-44b9-aa89-ccb50c245344	1220	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-02	2025-11-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.357446	2025-11-06 16:33:22.357446	\N	\N	\N
97409d1e-1261-4ef7-b500-1023135cf4ab	1221	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-03	2025-11-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.406419	2025-11-06 16:33:22.406419	\N	\N	\N
81242223-afa5-45ec-a6ba-bb35fc1ea320	1222	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-04	2025-11-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.457081	2025-11-06 16:33:22.457081	\N	\N	\N
f84e1040-4a65-49e3-a72a-fac06d92f850	1223	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-05	2025-11-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.508123	2025-11-06 16:33:22.508123	\N	\N	\N
1ff316f8-36f0-4aa7-a838-d8f6a2f8836e	1225	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-07	2025-11-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.609076	2025-11-06 16:33:22.609076	\N	\N	\N
9c58b157-b86c-40b9-9232-08bf3437dc02	1226	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-08	2025-11-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.657441	2025-11-06 16:33:22.657441	\N	\N	\N
40f4a205-c49b-4b79-9731-946235ac1f17	1227	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-09	2025-11-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.707983	2025-11-06 16:33:22.707983	\N	\N	\N
6552a1df-b7d8-4a8c-bb1b-65e25ef2e9f2	1228	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-10	2025-11-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.769948	2025-11-06 16:33:22.769948	\N	\N	\N
b23a1d09-8823-4ad6-9132-27a3c7f1b317	1215	company-admin-default	maintenance	00d2326f-af56-497c-8c32-5a572a81a465	e8503cbe-c8f6-49ee-ba27-265a93151e00	\N	ma-1762397312468-ifwq24l5h	\N	W1ojibZ6WgMBOCl_sc9-_	aL6T_RXlMMeQH2V3d21Lk	\N	programada	pausada	media	teste dia 06 - teste de equipamento	Manutenção preventiva para teste de equipamento	user-Teste.manutencao-1762267308881	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	2025-11-06 03:12:24.87	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 02:48:32.784595	2025-11-06 03:12:32.249027	\N	\N	\N
1d62f874-4294-4b43-b385-579b849f3854	1249	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446881897-b4gkpgbqf	\N	\N	\N	\N	\N	programada	pausada	media	teste de ordens clean mensal		user-usuario.completo-1762438801885	Sistema - Cronograma	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	2025-11-06 17:58:20.369	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:34:42.272928	2025-11-06 17:59:34.078417	\N	\N	\N
0454afd1-6e3a-4b4c-aeb7-3980059b48d0	1238	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-20	2025-11-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.271069	2025-11-06 16:33:23.271069	\N	\N	\N
0ebdc603-0258-4988-8e33-67726c0ea079	1203	company-admin-default	maintenance	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	\N	ma-1762384113700-w65jbaiyp	\N	ipL3x9KSsRl9gC6jEWh4r	qr_VSTgAJPncRPQ0scE0B	\N	programada	aberta	media	Teste de Manutenção - Teste de Equipamento	Manutenção preventiva para Teste de Equipamento	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-05	2025-11-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-05 23:08:33.83744	2025-11-05 23:08:33.83744	\N	\N	\N
3ffe5028-4adf-4055-a602-0a45d2a29d46	1204	company-admin-default	maintenance	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	\N	ma-1762384113700-w65jbaiyp	\N	ipL3x9KSsRl9gC6jEWh4r	IOgQcZuGAc7fBfXS7nBrz	\N	programada	aberta	media	Teste de Manutenção - Teste de Equipamento 2 	Manutenção preventiva para Teste de Equipamento 2 	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-05	2025-11-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-05 23:08:33.908922	2025-11-05 23:08:33.908922	\N	\N	\N
0a72645a-7428-4d83-b48f-bc6d5b47f28a	1205	company-admin-default	maintenance	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	\N	ma-1762384113700-w65jbaiyp	\N	ipL3x9KSsRl9gC6jEWh4r	p2i5Tb50MQ5epS5uhCbbF	\N	programada	cancelada	media	Teste de Manutenção - Teste de Equipamento 3	Manutenção preventiva para Teste de Equipamento 3	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-05	2025-11-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-05 23:08:33.972302	2025-11-05 23:08:52.12504	Teste de cancelamento	2025-11-05 23:08:52.118	user-admin-opus
77300e15-c1fa-4593-b2b0-6e965ed25ca1	1206	company-admin-default	clean	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	7ee18f0c-20d1-4b0e-84b4-f7b2915d5dfd	\N	\N	\N	\N	\N	\N	corretiva_interna	aberta	media	Teste de pausa	\N	\N	\N	\N	\N	\N	2025-11-05	2026-05-10	\N	\N	\N	\N	1.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-05 23:09:49.176436	2025-11-05 23:09:49.176436	\N	\N	\N
2d66916a-bd8c-40fc-863e-dbca23cbc3c2	1239	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-21	2025-11-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.320243	2025-11-06 16:33:23.320243	\N	\N	\N
299a7114-d52d-4d22-b7e2-cd137b45ff7c	1240	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-22	2025-11-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.371981	2025-11-06 16:33:23.371981	\N	\N	\N
3199ad62-628a-4474-b504-4608bda40087	1210	company-admin-default	maintenance	19bfd0c9-043f-4da1-bbce-f94aa6a7d983	\N	\N	\N	\N	ipL3x9KSsRl9gC6jEWh4r	p2i5Tb50MQ5epS5uhCbbF	\N	corretiva_interna	aberta	media	teste de pausa	\N	\N	\N	\N	\N	\N	2025-11-05	2025-11-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-05 23:28:51.449021	2025-11-05 23:28:51.449021	\N	\N	\N
7532388e-ee22-4f95-a09d-e79a712b1a26	1211	company-admin-default	maintenance	616e248d-258c-44bb-a793-ed8acdc0ff05	69e3e773-7fbc-4838-bf46-83b661624366	\N	ma-1762390081388-7vepvygwz	\N	riVgS2TLqhRLKwpqZtVn9	u64FmJq3Sls3XMEHn3vNI	\N	programada	aberta	media	Teste de manutenção 3 - Equipamento Teste final 	Manutenção preventiva para Equipamento Teste final 	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-05	2025-11-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 00:48:01.748966	2025-11-06 00:48:01.748966	\N	\N	\N
cd8a3023-d2bb-49f5-ba6d-bad61a648954	1212	company-admin-default	maintenance	616e248d-258c-44bb-a793-ed8acdc0ff05	69e3e773-7fbc-4838-bf46-83b661624366	\N	ma-1762390081388-7vepvygwz	\N	riVgS2TLqhRLKwpqZtVn9	ECbLexvcoT7OnV3biuPmj	\N	programada	aberta	media	Teste de manutenção 3 - Teste final de fluxo equipamento	Manutenção preventiva para Teste final de fluxo equipamento	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-05	2025-11-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 00:48:01.827568	2025-11-06 00:48:01.827568	\N	\N	\N
027f2e7f-3c3c-4c5f-9784-9d49bd8b9b51	1213	company-admin-default	maintenance	00d2326f-af56-497c-8c32-5a572a81a465	e8503cbe-c8f6-49ee-ba27-265a93151e00	\N	ma-1762396814250-oubsfl7gt	\N	W1ojibZ6WgMBOCl_sc9-_	aL6T_RXlMMeQH2V3d21Lk	\N	programada	concluida	media	Teste - teste de equipamento	Manutenção preventiva para teste de equipamento	user-Teste.manutencao-1762267308881	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	2025-11-06 03:11:12.753	2025-11-06 03:11:43.266	\N	\N	\N	\N	{"CwB7BRuTJUxLHlQLw-EmF": "Teste"}	\N	\N	\N	\N	\N	2025-11-06 02:40:14.468722	2025-11-06 03:11:44.046508	\N	\N	\N
7c0f2631-dc9f-4405-9818-0912ac570b12	1214	company-admin-default	maintenance	00d2326f-af56-497c-8c32-5a572a81a465	e8503cbe-c8f6-49ee-ba27-265a93151e00	\N	ma-1762397169759-7mjcqqg5p	\N	W1ojibZ6WgMBOCl_sc9-_	aL6T_RXlMMeQH2V3d21Lk	\N	programada	concluida	media	teste tttt - teste de equipamento	Manutenção preventiva para teste de equipamento	user-Teste.manutencao-1762267308881	Sistema - Plano de Manutenção	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	2025-11-06 03:12:03.782	2025-11-06 03:12:06.725	\N	\N	\N	\N	{"CwB7BRuTJUxLHlQLw-EmF": ""}	\N	\N	\N	\N	\N	2025-11-06 02:46:10.062911	2025-11-06 03:12:07.389145	\N	\N	\N
34362cd8-fba6-4a9f-b81c-b2c42291cd21	1229	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-11	2025-11-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.820549	2025-11-06 16:33:22.820549	\N	\N	\N
4eaed5a9-5465-40ed-9a2f-f606c65eee01	1230	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-12	2025-11-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.871033	2025-11-06 16:33:22.871033	\N	\N	\N
c3062d02-6169-49a8-96d9-b411f2b5b173	1231	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-13	2025-11-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.919834	2025-11-06 16:33:22.919834	\N	\N	\N
f937f49a-01e5-4906-a7ce-602109ab4c0e	1232	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-14	2025-11-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.968877	2025-11-06 16:33:22.968877	\N	\N	\N
468bcd6b-9ae4-4d80-b27b-fa1d443b17a3	1233	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-15	2025-11-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.018221	2025-11-06 16:33:23.018221	\N	\N	\N
c86439c3-ede3-4d2b-96c6-582db8cd0e38	1234	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-16	2025-11-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.06652	2025-11-06 16:33:23.06652	\N	\N	\N
74ff9693-d0f9-4631-959c-4a81422098cb	1235	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-17	2025-11-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.116486	2025-11-06 16:33:23.116486	\N	\N	\N
8d441758-1f70-499d-93e0-f6f6281977a2	1236	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-18	2025-11-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.169366	2025-11-06 16:33:23.169366	\N	\N	\N
6e73207e-3e11-4ab1-b1a3-5ca63d18475a	1237	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-19	2025-11-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.221553	2025-11-06 16:33:23.221553	\N	\N	\N
da810510-a5ef-4cf9-8d15-154d84f0085a	1241	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-23	2025-11-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.421108	2025-11-06 16:33:23.421108	\N	\N	\N
d0cff4c8-1d88-43bc-8497-68f9807a66aa	1242	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-24	2025-11-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.468587	2025-11-06 16:33:23.468587	\N	\N	\N
8494cd5c-2162-41ff-97fc-55603202f916	1243	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-25	2025-11-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.519603	2025-11-06 16:33:23.519603	\N	\N	\N
344482ce-bbfc-46c7-bcc9-41d86b0966ed	1244	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-26	2025-11-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.567861	2025-11-06 16:33:23.567861	\N	\N	\N
6b5b35ce-fbb5-44c4-83bd-0d9e0af7c207	1245	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-27	2025-11-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.615848	2025-11-06 16:33:23.615848	\N	\N	\N
a03048f0-2620-4a5d-b23d-660ede246681	1246	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-28	2025-11-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.663977	2025-11-06 16:33:23.663977	\N	\N	\N
2c923db5-25fa-46f3-893a-bc4bd19ac99e	1247	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-29	2025-11-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.711226	2025-11-06 16:33:23.711226	\N	\N	\N
41a704f7-c91a-450c-a39e-01f272aed768	1248	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	aberta	media	teste ordem de serviço clean		\N	Sistema - Cronograma	\N	\N	\N	2025-11-30	2025-11-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:23.759143	2025-11-06 16:33:23.759143	\N	\N	\N
0b7e16d3-9764-4ee0-a80f-db47359ac067	1224	company-admin-default	clean	532f3a67-80ea-4598-b811-dc18b9cce619	03228a59-c210-48a5-90fd-c717de1296c6	ca-1762446800382-n46k2sgat	\N	\N	\N	\N	\N	programada	em_execucao	media	teste ordem de serviço clean		user-usuario.completo-1762438801885	Sistema - Cronograma	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	2025-11-06 17:59:56.524	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 16:33:22.56034	2025-11-06 17:59:57.20421	\N	\N	\N
da7f8ba7-ba65-48e6-9f12-5e0bf6784df5	1250	company-admin-default	clean	248bf411-964e-43b7-955d-16afbbf50184	9ac6394d-86cc-4953-94a0-947b7c15702b	ca-1762454508378-spj1i5qu1	\N	\N	\N	\N	\N	programada	aberta	media	check		\N	Sistema - Cronograma	\N	\N	\N	2025-11-06	2025-11-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-06 18:41:48.803897	2025-11-06 18:41:48.803897	\N	\N	\N
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.zones (id, site_id, module, name, description, area_m2, capacity, category, position_x, position_y, size_scale, color, is_active, created_at, updated_at) FROM stdin;
zone-vest-masc-01	site-faurecia-vestiarios	clean	VESTIÁRIO MASCULINO -01	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-vest-masc-02	site-faurecia-vestiarios	clean	VESTIÁRIO MASCULINO -02	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-vest-fem	site-faurecia-vestiarios	clean	VESTIÁRIO FEMININO	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-amb-banheiro	site-faurecia-ambulatorio	clean	BANHEIRO AMBULATÓRIO	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-ref-fem-coz	site-faurecia-refeitorio	clean	BANHEIRO FEMININO COZINHA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-port-masc	site-faurecia-portaria	clean	BANHEIRO MASCULINO PORTARIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-port-fem	site-faurecia-portaria	clean	BANHEIRO FEMININO PORTARIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:36:59.907585	2025-10-03 20:36:59.907585
zone-adm-masc	site-faurecia-administrativo	clean	BANHEIRO ADM MASCULINO	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:37:11.541079
zone-adm-fem-corp	site-faurecia-administrativo	clean	BANHEIRO FEMININO CORPORATIVO	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:37:11.541079
zone-adm-acess-01	site-faurecia-administrativo	clean	BANHEIRO CORPORATIVO ACESSÍVEL 01	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:37:11.541079
zone-adm-acess-02	site-faurecia-administrativo	clean	BANHEIRO CORPORATIVO ACESSÍVEL 02	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:37:11.541079
zone-prod-masc-gm	site-faurecia-producao	clean	BANHEIRO MASCULINO GM	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:37:23.534849
zone-prod-fem-toyota	site-faurecia-producao	clean	BANHEIRO FEMININO TOYOTA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:37:23.534849
zone-prod-fem-scania	site-faurecia-producao	clean	BANHEIRO FEMININO SCANIA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:37:23.534849
zone-prod-fem-log	site-faurecia-producao	clean	BANHEIRO FEMININO LOGÍSTICA	\N	\N	\N	banheiro	\N	\N	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:37:23.534849
zone-adm-fem-tech	site-faurecia-administrativo	clean	BANHEIRO FEMININO TECH CENTER	\N	\N	\N	banheiro	88.75	38.01	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:38:06.068711
zone-adm-fem	site-faurecia-administrativo	clean	BANHEIRO ADM FEMININO	\N	\N	\N	banheiro	30.58	25.71	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:38:06.07142
zone-adm-masc-tech	site-faurecia-administrativo	clean	BANHEIRO MASCULINO TECH CENTER	\N	\N	\N	banheiro	12.80	41.48	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:38:06.070709
zone-adm-unissex	site-faurecia-administrativo	clean	BANHEIRO UNISSEX RECEPÇÃO	\N	\N	\N	banheiro	45.19	19.23	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:38:06.080745
zone-adm-masc-corp	site-faurecia-administrativo	clean	BANHEIRO MASCULINO CORPORATIVO	\N	\N	\N	banheiro	45.62	79.50	\N	\N	t	2025-10-03 20:37:11.541079	2025-10-03 20:38:06.116216
zone-prod-masc-scania	site-faurecia-producao	clean	BANHEIRO MASCULINO SCANIA	\N	\N	\N	banheiro	6.27	29.65	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:38:17.237134
zone-prod-masc-log	site-faurecia-producao	clean	BANHEIRO MASCULINO LOGÍSTICA	\N	\N	\N	banheiro	10.05	73.50	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:38:17.24549
zone-prod-masc-toyota	site-faurecia-producao	clean	BANHEIRO MASCULINO TOYOTA	\N	\N	\N	banheiro	47.42	21.54	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:38:17.258594
zone-prod-fem-gm	site-faurecia-producao	clean	BANHEIRO FEMININO GM	\N	\N	\N	banheiro	27.23	33.28	\N	\N	t	2025-10-03 20:37:23.534849	2025-10-03 20:38:17.271698
2ba21003-b82d-4950-8a6b-f504740960ea	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Estática SMC Fante	\N	20.00	\N	producao	67.95	30.05	1.42		t	2025-09-29 12:06:20.732367	2025-10-20 10:36:21.227876
20864c38-1234-46e6-8581-46e3c55a9b87	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Pintura RTM		\N	\N	producao	52.56	57.57	1.21		t	2025-09-29 12:04:15.692157	2025-10-20 10:36:21.235424
2d9936f6-6093-4885-b0bf-cf655f559dbc	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Pintura Estatica		12.00	\N	producao	19.55	37.26	1.42		t	2025-09-29 12:06:02.8882	2025-10-20 10:36:21.249322
a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	ff191700-ac34-4df7-accc-1d420568d645	clean	Cabine Pintura SMC		\N	\N	producao	36.78	58.44	1.21		t	2025-09-29 12:03:55.125574	2025-10-20 10:36:21.252153
6b4c568e-3256-4a97-a2c5-2e21ca1ed3a2	a309bcbc-466a-4aba-8515-fd1a39bdbb29	maintenance	Zona T	Teste	12.00	9	banheiro	49.11	22.61	1.00	\N	t	2025-11-04 00:05:04.470515	2025-11-04 00:05:04.470515
4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	abe90b75-109e-4980-a1cc-4f787cb886b9	maintenance	TEste 1	\N	12.00	9	banheiro	24.22	41.57	1.00	\N	t	2025-11-04 00:07:11.736809	2025-11-04 00:07:11.736809
2decb845-150b-4db5-a0a4-fba241d241ae	abe90b75-109e-4980-a1cc-4f787cb886b9	maintenance	Teste 2	Teste	20.00	1	banheiro	25.02	70.31	1.00	\N	t	2025-11-04 01:29:17.143843	2025-11-04 01:29:17.143843
19bfd0c9-043f-4da1-bbce-f94aa6a7d983	10c3b253-aa59-4a91-acb8-a3b6152f975c	maintenance	teste	teste	20.00	5	banheiro	29.78	20.48	1.00	\N	t	2025-11-04 17:25:31.348948	2025-11-04 17:25:31.348948
616e248d-258c-44bb-a793-ed8acdc0ff05	6b4d7be2-abd3-4926-8b98-181830ba5a1f	maintenance	Zona de teste final	Teste de fluxo final	12.00	5	producao	12.90	34.88	1.00	\N	t	2025-11-06 00:18:37.479812	2025-11-06 00:19:19.677813
fcd30124-2917-4041-bb61-8ef5982cd08d	6b4d7be2-abd3-4926-8b98-181830ba5a1f	maintenance	Multi zona	\N	12.00	1	banheiro	74.83	76.10	1.00	\N	t	2025-11-06 00:24:11.178872	2025-11-06 00:24:11.178872
93dd126e-96ab-496c-9664-4ab7ea0cc40d	01ca0d3c-947d-47c3-bb7a-82d1837d031e	maintenance	Teste final de zona 1	\N	12.00	2	banheiro	41.75	50.84	1.00	\N	t	2025-11-06 02:22:03.400146	2025-11-06 02:22:03.400146
7f45e6ad-7692-4046-b3f5-649f1695ccb0	01ca0d3c-947d-47c3-bb7a-82d1837d031e	maintenance	Teste final de zona 2	\N	12.00	2	escritorio	29.68	61.21	1.00	\N	t	2025-11-06 02:22:17.832253	2025-11-06 02:22:17.832253
00d2326f-af56-497c-8c32-5a572a81a465	01ca0d3c-947d-47c3-bb7a-82d1837d031e	maintenance	Teste final de zona 3	\N	12.00	2	producao	55.83	22.11	1.00	\N	t	2025-11-06 02:22:34.170767	2025-11-06 02:22:34.170767
248bf411-964e-43b7-955d-16afbbf50184	0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	clean	teste completo de local	\N	20.00	3	banheiro	54.42	68.95	1.00	\N	t	2025-11-06 14:16:56.465612	2025-11-06 14:16:56.465612
532f3a67-80ea-4598-b811-dc18b9cce619	0b96c1cc-49bd-4a8f-93e7-3f0b87f08dd2	clean	teste completo zona 1	\N	20.00	2	producao	60.03	33.41	1.00	\N	t	2025-11-06 14:17:15.999344	2025-11-06 14:17:15.999344
b7b7b4d6-3a99-4aee-80ab-1c26f72f3842	a899ba26-00b9-4c85-b25b-d48752c7eb4a	maintenance	teste de zona 1	\N	20.00	12	producao	46.18	69.05	1.00	\N	t	2025-11-06 14:43:01.719256	2025-11-06 14:43:01.719256
6b1e66e5-4523-42d5-b3a9-b4e66b37d64a	a899ba26-00b9-4c85-b25b-d48752c7eb4a	maintenance	teste de zona 2	\N	12.00	2	producao	21.06	35.98	1.00	\N	t	2025-11-06 14:43:14.590041	2025-11-06 14:43:14.590041
\.


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
-- Name: service_types service_types_code_unique; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_code_unique UNIQUE (code);


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
-- Name: work_orders_company_number_unique; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX work_orders_company_number_unique ON public.work_orders USING btree (company_id, number);


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
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

