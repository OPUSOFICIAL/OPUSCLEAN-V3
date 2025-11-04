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
    zone_id character varying
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
    end_time time without time zone
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
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    modules text[] DEFAULT ARRAY['clean'::text] NOT NULL
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
    name character varying NOT NULL,
    internal_code character varying,
    manufacturer character varying,
    model character varying,
    serial_number character varying,
    purchase_date date,
    warranty_expiry date,
    installation_date date,
    technical_specs jsonb,
    maintenance_notes text,
    qr_code_url character varying,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    status public.equipment_status DEFAULT 'operacional'::public.equipment_status NOT NULL,
    equipment_type_id character varying,
    tag_ids character varying[]
);


--
-- Name: equipment_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment_tags (
    id character varying NOT NULL,
    company_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    color character varying,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
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
    equipment_id character varying,
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
    end_time time without time zone,
    site_ids character varying[] NOT NULL,
    zone_ids character varying[] NOT NULL,
    application_target character varying NOT NULL,
    tag_ids character varying[]
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
    items jsonb NOT NULL,
    module public.module DEFAULT 'maintenance'::public.module NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    site_ids character varying[],
    zone_ids character varying[],
    tag_ids character varying[],
    equipment_id character varying
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
    customer_id character varying
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
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    modules text[] DEFAULT ARRAY['clean'::text] NOT NULL
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
    checklist_template_id character varying,
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
    maintenance_activity_id character varying
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
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, company_id, user_id, entity_type, entity_id, action, changes, metadata, "timestamp", created_at) FROM stdin;
89cb76fc-c3ea-4eb4-a663-37cde98f046f	company-admin-default	\N	work_order	48b417d5-ebcf-415f-96ec-49e55849b434	update	\N	{"details": "Work order #66 updated - Status: em_andamento"}	2025-10-01 01:27:08.925	2025-10-01 01:27:08.996976
21598abc-7cb2-4d3e-bf9f-f99de0e302c3	company-admin-default	\N	work_order	48b417d5-ebcf-415f-96ec-49e55849b434	update	\N	{"details": "Work order #66 updated - Status: concluida"}	2025-10-01 14:03:27.974	2025-10-01 14:03:28.046004
225084aa-c457-48d9-b116-38c1d4a87f05	company-admin-default	\N	work_order	40634f41-e769-47ba-a0e3-43a9efb86ad1	update	\N	{"details": "Work order #65 updated - Status: em_andamento"}	2025-10-01 15:21:43.091	2025-10-01 15:21:43.16417
95230e8c-d853-4bfa-bc82-5ce6758a07f0	company-admin-default	\N	work_order	40634f41-e769-47ba-a0e3-43a9efb86ad1	update	\N	{"details": "Work order #65 updated - Status: concluida"}	2025-10-01 15:22:06.591	2025-10-01 15:22:06.662617
be7b96af-317c-41e2-bb74-15d4a24b5fb5	company-admin-default	\N	work_order	331ef28c-eefb-4363-a61a-243fd8d2bbf9	delete	\N	{"details": "Work order #98 deleted - Type: programada"}	2025-10-02 15:21:01.081	2025-10-02 15:21:01.098622
feb9e340-acb1-458e-9bf3-1c487fd13df2	company-admin-default	\N	work_order	023facd4-36c1-42a8-af88-7b3f755e173a	delete	\N	{"details": "Work order #99 deleted - Type: programada"}	2025-10-02 15:21:05.972	2025-10-02 15:21:05.989369
cbc7d8da-d3fc-4e8f-897c-56d565e9a0ea	company-admin-default	\N	work_order	c61034be-7c2c-44f2-9e10-2b253e0a36f0	update	\N	{"details": "Work order #111 updated - Status: concluida"}	2025-10-02 17:41:55.923	2025-10-02 17:41:55.941833
6d0ef2a1-17ce-45c8-9e3b-52041cef8413	company-admin-default	\N	work_order	f2d2430a-47d6-49a2-ad54-13153ee34f8b	update	\N	{"details": "Work order #110 updated - Status: concluida"}	2025-10-02 20:20:30.513	2025-10-02 20:20:30.531531
7e8af5d8-5036-4013-9402-f7de44604e57	company-admin-default	\N	work_order	ab83a444-b6bf-4fd3-9133-cb5780dce91a	update	\N	{"details": "Work order #301 updated - Status: concluida"}	2025-10-17 17:08:35.648	2025-10-17 14:08:35.648585
3d0f8ee3-c165-48f5-864f-a993172750d1	company-admin-default	\N	work_order	d2bcb6da-150b-4c3a-a44d-aefcb453e306	update	\N	{"details": "Work order #727 updated - Status: concluida"}	2025-10-29 19:41:02.505	2025-10-29 16:41:02.505987
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
-- Data for Name: checklist_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.checklist_templates (id, company_id, service_id, site_id, name, description, items, module, created_at, updated_at, zone_id) FROM stdin;
checklist-1760640725459-vyFf79rK0p	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	PINTURA SMC	Atividades a serem realizadas na cabine de pintura SMC 	[{"id": "1760640463204", "type": "text", "label": "Plastificação dos Skid's", "required": true, "validation": {}, "description": ""}, {"id": "1760641533399", "type": "photo", "label": "Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer", "required": true, "validation": {"photoMaxCount": 2, "photoMinCount": 1, "photoRequired": true}, "description": ""}]	clean	2025-10-16 15:52:05.462372	2025-10-16 16:05:35.929407	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa
checklist-1761585131363-ksHIlM6w8O	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	Limpeza de banheiros e vestiarios - Femininos 	Limpeza convencional de banheiros e vestiarios.	[{"id": "1761585131183", "type": "checkbox", "label": "Sim", "options": ["Limpeza de pias, vasos e espelhos", "Limpeza de piso", "Limpeza vertical de divisorias, paredes e portas", "Limpeza de maçanetas e corrimões", "Retirada de lixo ", "Abastecimento de descartaveis "], "required": true, "validation": {"maxChecked": 2, "minChecked": 2}, "description": "N/A"}]	clean	2025-10-27 14:12:11.365306	2025-10-27 14:12:11.365306	\N
checklist-1761594742714-2NXCD3KFSb	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	\N	CWC feminino - Tech center 		[{"id": "1761594756460", "type": "checkbox", "label": "Sim", "options": ["Limpeza de pias vasos e espelhos, foram feitas?", "Limpeza de piso, foi feita?", "Limpeza vertical de divisorias, paredes e portas, foram feitas?", "Limpeza de maçanetas e coerrimões, foram feitas?", "Foi realizada a retirada de lixo?", "Foi realizado o abastecimento de descartáveis ?"], "required": false, "validation": {"maxChecked": 6, "minChecked": 6}, "description": ""}]	clean	2025-10-27 16:52:22.715867	2025-10-27 16:52:22.715867	\N
checklist-1759332028080-yP1zdZiE7V	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	RTM		[{"id": "1759332012650", "type": "photo", "label": "Fotos", "required": false, "validation": {"photoMaxCount": 1, "photoMinCount": 1, "photoRequired": true}, "description": ""}, {"id": "1759436504239", "type": "text", "label": "Limpeza concluida?", "required": true, "validation": {}, "description": ""}]	clean	2025-10-01 15:20:28.153116	2025-10-29 14:49:40.794044	20864c38-1234-46e6-8581-46e3c55a9b87
\.


--
-- Data for Name: cleaning_activities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, frequency_config, module, checklist_template_id, sla_config_id, is_active, created_at, updated_at, start_time, end_time) FROM stdin;
ca-turno-rtm-1759264329	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Limpeza por Turno - Cabine RTM	Limpeza manhã, tarde e noite	turno	{"shifts": ["manha", "tarde", "noite"]}	clean	\N	\N	f	2025-09-30 20:32:08.791088	2025-09-30 20:32:08.791088	\N	\N
ca-1759872977850-wyex3v3sb	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nLimpeza interna das paredes e vidros das cabines do primer;\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\nJateamento com lava jato e aplicação de graxa patente no transportador\n	semanal	{"monthDay": 1, "weekDays": ["segunda"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 18:36:17.858536	2025-10-07 18:36:17.858536	\N	\N
ca-1759873220782-9wdyrslvl	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\nLimpeza interna das paredes e vidros das cabines do verniz\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do flash off do verniz\nLimpeza das liminárias do verniz\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\n\n	semanal	{"monthDay": 1, "weekDays": ["sexta"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 18:40:20.79229	2025-10-07 18:40:20.79229	\N	\N
ca-1759879717135-p4iquwjki	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	semanal	{"monthDay": 1, "weekDays": ["quarta"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 20:28:37.143593	2025-10-07 20:28:37.143593	\N	\N
ca-1759880067433-fd68ihnyq	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\nTroca de filtro da exaustão\nLimpeza do chão da cabine\n	semanal	{"monthDay": 1, "weekDays": ["quinta"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 20:34:27.444064	2025-10-07 20:34:27.444064	\N	\N
ca-1759880794641-vnxzwhd83	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\n	semanal	{"monthDay": 1, "weekDays": ["sabado"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 20:46:34.649247	2025-10-07 20:46:34.649247	\N	\N
ca-1759881641311-jajipa099	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\t\t\t\n	semanal	{"monthDay": 1, "weekDays": ["domingo"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 21:00:41.32079	2025-10-07 21:00:41.32079	\N	\N
ca-1759882334068-bqesftjui	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 21:12:14.078646	2025-10-07 21:12:14.078646	\N	\N
ca-1759885763030-rw4vueq89	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 22:09:23.04215	2025-10-07 22:09:23.04215	\N	\N
ca-1761591097102-8kf81xk7d	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-corp	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:51:37.111267	2025-10-27 15:51:37.111267	\N	\N
ca-1761591197326-qzu06d0gn	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-acess-01	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:53:17.33496	2025-10-27 15:53:17.33496	\N	\N
ca-1761591301979-gci0j116a	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-unissex	Recepção - Limpeza  WC	Limpeza de WC recepção 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:55:01.987558	2025-10-27 15:55:01.987558	\N	\N
ca-1759889629139-pqcuh75ib	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\nTroca de filtro da exaustão da cabine estática SMC fante\nLimpeza das liminárias da cabine estática SMC fante\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\n	semanal	{"monthDay": 1, "weekDays": ["terca"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 23:13:49.149016	2025-10-07 23:13:49.149016	\N	\N
ca-1759889808223-kkbhkfsdy	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	2ba21003-b82d-4950-8a6b-f504740960ea	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	semanal	{"monthDay": 1, "weekDays": ["terca"], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 23:16:48.23195	2025-10-07 23:16:48.23195	\N	\N
ca-1759890045118-y0c75246f	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Final RTM	Limpeza do fosso da exaustão da base\nLimpeza externa das paredes e vidros das cabines da base\nLimpeza do fosso da exaustão do verniz\nAspiração da região superior (teto) da estufa da pintura final\nLimpeza externa das paredes e vidros das cabines do verniz\n	mensal	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-07 23:20:45.126827	2025-10-07 23:20:45.126827	\N	\N
ca-1760182900759-vyp6ush29	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\nTroca de filtro plenuns cabine do primer - 2 cabines\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-11 08:41:40.767373	2025-10-11 08:41:40.767373	\N	\N
ca-1760183618389-283dqb778	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\nTroca de filtro plenuns cabine do primer - 2 cabines\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-11 08:53:38.397919	2025-10-11 08:53:38.397919	\N	\N
ca-1760183770897-absg8gofg	company-admin-default	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ff191700-ac34-4df7-accc-1d420568d645	20864c38-1234-46e6-8581-46e3c55a9b87	Cabine de Pintura Primer RTM	Troca de filtro multibolsa cabine do primer\nTroca de filtro plenuns cabine do primer - 2 cabines\n	anual	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-11 08:56:10.911458	2025-10-11 08:56:10.911458	\N	\N
ca-1761585757243-elx2y62kt	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 14:22:37.251386	2025-10-27 14:22:37.251386	\N	\N
ca-1761585870492-w7xqg80th	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 14:24:30.502021	2025-10-27 14:24:30.502021	\N	\N
ca-1761586116924-imqskabvg	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 14:28:36.932641	2025-10-27 14:28:36.932641	\N	\N
ca-1761586621875-47moo9ok0	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-masc-01	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 14:37:01.883481	2025-10-27 14:37:01.883481	\N	\N
ca-1761587028027-knglqct7g	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-masc-01	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 14:43:48.037341	2025-10-27 14:43:48.037341	\N	\N
ca-1761587225967-w1l2xw0lm	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 14:47:05.977951	2025-10-27 14:47:05.977951	\N	\N
ca-1761590395353-n4e6pddup	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-masc-02	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:39:55.362427	2025-10-27 15:39:55.362427	\N	\N
ca-1761590545608-fucf3mxn5	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-vestiarios	zone-vest-fem	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:42:25.616677	2025-10-27 15:42:25.616677	\N	\N
ca-1761590717804-8eo1xtcge	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc	Limpeza WC RH masculinol	Limpeza de WC masculino RH	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:45:17.81219	2025-10-27 15:45:17.81219	\N	\N
ca-1761590774854-0gkz8w44o	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-fem	Limpeza WC RH feminino	Limpeza de WC feminino RH	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:46:14.862879	2025-10-27 15:46:14.862879	\N	\N
ca-1761590883222-ctje5t7ze	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-fem-corp	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:48:03.230305	2025-10-27 15:48:03.230305	\N	\N
ca-1761590969350-suyuqoky7	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-corp	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:49:29.359063	2025-10-27 15:49:29.359063	\N	\N
ca-1761591407974-9i2pqxrtu	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-portaria	zone-port-fem	Portaria - WC feminino	Limpeza de WC feminino da portaria 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:56:47.983316	2025-10-27 15:56:47.983316	\N	\N
ca-1761591455060-1zocriqb3	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-portaria	zone-port-masc	Portaria - WC masculino	Limpeza de WC masculino portaria	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:57:35.068243	2025-10-27 15:57:35.068243	\N	\N
ca-1761591540766-1m8stph7k	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-tech	Tech center - WC masculino	Limpeza de WC masculino Tech center	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 15:59:00.774573	2025-10-27 15:59:00.774573	\N	\N
ca-1761591637418-eed4drz6c	company-admin-default	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	site-faurecia-administrativo	zone-adm-masc-tech	Tech center - WC feminino	Limpeza de WC feminino tech center 	diaria	{"monthDay": 1, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	clean	\N	\N	t	2025-10-27 16:00:37.427163	2025-10-27 16:00:37.427163	\N	\N
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
cc-1759264397895-dj5bo9tx9	company-admin-default	work_order	1110	2025-11-04 12:21:43.744397
\.


--
-- Data for Name: custom_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.custom_roles (id, company_id, name, description, is_system_role, is_active, created_at, updated_at) FROM stdin;
role-1759340407-operador	company-admin-default	Operador	Operador de campo - executa OS via aplicativo mobile	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
role-1759340407-cliente	company-admin-default	Cliente	Visualização de dashboards, relatórios, plantas dos locais e ordens de serviço. Pode comentar e avaliar OS.	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
role-1759340407-admin	company-admin-default	Administrador	Acesso total ao sistema - para usuários OPUS	t	t	2025-10-01 17:40:06.730146	2025-10-01 17:40:06.730146
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (id, company_id, name, email, phone, document, address, city, state, zip_code, contact_person, notes, is_active, created_at, updated_at, modules) FROM stdin;
43538320-fe1b-427c-9cb9-6b7ab06c1247	company-admin-default	FAURECIA										t	2025-09-15 19:03:55.605952	2025-09-15 19:03:55.605952	{clean}
7913bae1-bdca-4fb4-9465-99a4754995b2	company-admin-default	TECNOFIBRA										t	2025-09-28 16:31:54.577274	2025-09-28 16:31:54.577274	{clean}
20ae7c09-3fe9-4db9-a136-2992bac29e10	company-admin-default	teste										f	2025-09-30 20:01:52.200153	2025-09-30 20:01:54.962302	{clean}
customer-teste-default	company-opus-default	Cliente Teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	2025-10-19 17:58:47.081652	2025-10-19 17:58:47.081652	{clean}
d891d578-e86a-4cee-90f1-90158e82c2b0	company-admin-default	Teste de manutenção	manager@example.com	6723877569	53456778000176	Rua Maria de Fátima	São Paulo	SP	04404-160	Teste de Manutenção		t	2025-11-04 13:38:12.622192	2025-11-04 13:38:12.622192	{maintenance}
\.


--
-- Data for Name: dashboard_goals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dashboard_goals (id, company_id, module, goal_type, goal_value, current_period, is_active, created_at, updated_at) FROM stdin;
6a972bd1-3c42-4905-ba78-e2b1e4220ce4	company-admin-default	clean	eficiencia_operacional	100.00	2025-09	f	2025-09-30 21:09:36.742578	2025-09-30 21:09:38.627842
c3ab769c-4862-44ba-bf11-32e0fee8c13d	company-admin-default	clean	eficiencia_operacional	95.00	2025-10	t	2025-10-10 16:44:04.537352	2025-10-10 16:44:04.537352
b03cdce0-51c6-4d1d-a18b-2d5c586280b4	company-admin-default	clean	os_concluidas_mes	40.00	2025-11	t	2025-11-04 14:34:27.644608	2025-11-04 14:34:27.644608
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment (id, company_id, customer_id, site_id, zone_id, name, internal_code, manufacturer, model, serial_number, purchase_date, warranty_expiry, installation_date, technical_specs, maintenance_notes, qr_code_url, module, is_active, created_at, updated_at, status, equipment_type_id, tag_ids) FROM stdin;
zr1miixEjGG__S1ctR7qd	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	abe90b75-109e-4980-a1cc-4f787cb886b9	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	Café	TT-001	Samsu	Tt	SN!@#1	\N	2025-11-20	2025-11-10	\N	\N	\N	maintenance	t	2025-11-04 00:10:12.438385	2025-11-04 00:14:06.360379	operacional	\N	\N
QMXyGjKmd3NVdMZRLVywU	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	abe90b75-109e-4980-a1cc-4f787cb886b9	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	Café teste	TT-002	Samsumg	T02	SN28713	\N	2025-11-30	2025-11-04	\N	\N	\N	maintenance	t	2025-11-04 00:23:56.555179	2025-11-04 00:24:39.910557	em_manutencao	\N	\N
gafIzl72p78myK1XzI3LW	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	abe90b75-109e-4980-a1cc-4f787cb886b9	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	Maquina de Café	TT001	Op	AR878	TT546	\N	2025-11-10	2025-11-03	\N	\N	\N	maintenance	t	2025-11-04 02:03:24.121848	2025-11-04 02:03:24.121848	operacional	\N	\N
aC3Uv5u-K1by5BipHyY1_	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	abe90b75-109e-4980-a1cc-4f787cb886b9	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	Maquina de Café	TT001	Samsung	SNR0012	SN!@#!2123	\N	2025-11-20	2025-11-10	\N	\N	\N	maintenance	t	2025-11-04 03:37:52.4836	2025-11-04 03:37:52.4836	operacional	\N	{MCdRrNR0Zsn7KE6_dwYWq}
1gvsr6r7b2EIabtlUcK_-	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	abe90b75-109e-4980-a1cc-4f787cb886b9	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	Maquina do Sofá	TT0123	Samsun	AR90	SN!@#!12343	\N	2025-11-30	2025-11-05	\N	\N	\N	maintenance	t	2025-11-04 06:23:57.952908	2025-11-04 06:23:57.952908	operacional	\N	{MCdRrNR0Zsn7KE6_dwYWq}
\.


--
-- Data for Name: equipment_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_tags (id, company_id, customer_id, name, description, color, module, is_active, created_at, updated_at) FROM stdin;
MCdRrNR0Zsn7KE6_dwYWq	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	Maquinas de café	TEste de maquinas\n	\N	maintenance	t	2025-11-04 03:25:45.098463	2025-11-04 03:25:45.098463
\.


--
-- Data for Name: equipment_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.equipment_types (id, company_id, name, description, module, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_activities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_activities (id, company_id, customer_id, equipment_id, site_id, zone_id, name, description, type, frequency, frequency_config, module, checklist_template_id, sla_config_id, assigned_user_id, estimated_hours, sla_minutes, start_date, last_executed_at, is_active, created_at, updated_at, start_time, end_time, site_ids, zone_ids, application_target, tag_ids) FROM stdin;
ma-1762258844497-dspp6ahsb	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	aC3Uv5u-K1by5BipHyY1_	\N	\N	Teste		preventiva	mensal	{"monthDay": 5, "weekDays": [], "turnShifts": [], "timesPerDay": 1}	maintenance	KB1Qinb6530n4tXeZr25_	\N	\N	\N	\N	2025-11-05	\N	t	2025-11-04 12:20:44.662674	2025-11-04 12:20:44.662674	\N	\N	{abe90b75-109e-4980-a1cc-4f787cb886b9}	{4c7888f3-5c26-4a3b-80f1-e0bd8318f80f,2decb845-150b-4db5-a0a4-fba241d241ae}	equipment	\N
\.


--
-- Data for Name: maintenance_checklist_executions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_checklist_executions (id, checklist_template_id, equipment_id, work_order_id, executed_by_user_id, started_at, finished_at, status, checklist_data, observations, attachments, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: maintenance_checklist_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.maintenance_checklist_templates (id, company_id, customer_id, name, description, version, items, module, is_active, created_at, updated_at, site_ids, zone_ids, tag_ids, equipment_id) FROM stdin;
KB1Qinb6530n4tXeZr25_	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	Teste	tste	1.0	[{"id": "RKlMnVC2Q0kIzuem3vBEb", "type": "checkbox", "label": "Limpou Borra?", "required": true, "validation": {}, "description": ""}]	maintenance	t	2025-11-04 03:35:48.567399	2025-11-04 03:35:48.567399	{abe90b75-109e-4980-a1cc-4f787cb886b9}	{4c7888f3-5c26-4a3b-80f1-e0bd8318f80f,2decb845-150b-4db5-a0a4-fba241d241ae}	{MCdRrNR0Zsn7KE6_dwYWq}	\N
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
OYomjaq__NOKqohDOegJW	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	Manutenção preventiva	\N	preventiva	maintenance	t	2025-11-04 00:27:02.482477	2025-11-04 00:27:02.482477
2NTPatjjNjf6KygCOfnuF	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	Manutenção Preventiva	Descrição teste\n	preventiva	maintenance	t	2025-11-04 03:38:20.155879	2025-11-04 03:38:20.155879
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
qr-zone-vest-masc-01	zone-vest-masc-01	\N	\N	zone-vest-masc-01	execucao	VESTIÁRIO MASCULINO -01	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-vest-masc-02	zone-vest-masc-02	\N	\N	zone-vest-masc-02	execucao	VESTIÁRIO MASCULINO -02	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-vest-fem	zone-vest-fem	\N	\N	zone-vest-fem	execucao	VESTIÁRIO FEMININO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-amb-banheiro	zone-amb-banheiro	\N	\N	zone-amb-banheiro	execucao	BANHEIRO AMBULATÓRIO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-ref-fem-coz	zone-ref-fem-coz	\N	\N	zone-ref-fem-coz	execucao	BANHEIRO FEMININO COZINHA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-port-masc	zone-port-masc	\N	\N	zone-port-masc	execucao	BANHEIRO MASCULINO PORTARIA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-port-fem	zone-port-fem	\N	\N	zone-port-fem	execucao	BANHEIRO FEMININO PORTARIA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-masc	zone-adm-masc	\N	\N	zone-adm-masc	execucao	BANHEIRO ADM MASCULINO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-fem-corp	zone-adm-fem-corp	\N	\N	zone-adm-fem-corp	execucao	BANHEIRO FEMININO CORPORATIVO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-acess-01	zone-adm-acess-01	\N	\N	zone-adm-acess-01	execucao	BANHEIRO CORPORATIVO ACESSÍVEL 01	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-acess-02	zone-adm-acess-02	\N	\N	zone-adm-acess-02	execucao	BANHEIRO CORPORATIVO ACESSÍVEL 02	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-fem-tech	zone-adm-fem-tech	\N	\N	zone-adm-fem-tech	execucao	BANHEIRO FEMININO TECH CENTER	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-fem	zone-adm-fem	\N	\N	zone-adm-fem	execucao	BANHEIRO ADM FEMININO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-masc-tech	zone-adm-masc-tech	\N	\N	zone-adm-masc-tech	execucao	BANHEIRO MASCULINO TECH CENTER	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-unissex	zone-adm-unissex	\N	\N	zone-adm-unissex	execucao	BANHEIRO UNISSEX RECEPÇÃO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-adm-masc-corp	zone-adm-masc-corp	\N	\N	zone-adm-masc-corp	execucao	BANHEIRO MASCULINO CORPORATIVO	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-masc-gm	zone-prod-masc-gm	\N	\N	zone-prod-masc-gm	execucao	BANHEIRO MASCULINO GM	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-fem-toyota	zone-prod-fem-toyota	\N	\N	zone-prod-fem-toyota	execucao	BANHEIRO FEMININO TOYOTA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-fem-scania	zone-prod-fem-scania	\N	\N	zone-prod-fem-scania	execucao	BANHEIRO FEMININO SCANIA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-fem-log	zone-prod-fem-log	\N	\N	zone-prod-fem-log	execucao	BANHEIRO FEMININO LOGÍSTICA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-masc-scania	zone-prod-masc-scania	\N	\N	zone-prod-masc-scania	execucao	BANHEIRO MASCULINO SCANIA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-masc-log	zone-prod-masc-log	\N	\N	zone-prod-masc-log	execucao	BANHEIRO MASCULINO LOGÍSTICA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-masc-toyota	zone-prod-masc-toyota	\N	\N	zone-prod-masc-toyota	execucao	BANHEIRO MASCULINO TOYOTA	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
qr-zone-prod-fem-gm	zone-prod-fem-gm	\N	\N	zone-prod-fem-gm	execucao	BANHEIRO FEMININO GM	\N	5	clean	t	2025-10-03 20:50:40.044676	2025-10-03 20:50:40.044676
caed1a61-5345-4209-9b52-b018d7106e01	20864c38-1234-46e6-8581-46e3c55a9b87	\N	\N	e8a28503-dabe-4a8a-a480-34a5a211031a	execucao	teste	\N	5	clean	t	2025-10-17 14:03:45.840977	2025-10-17 14:03:45.840977
a2ce0d09-8940-4bae-accb-f112a7473818	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	\N	\N	SR - Teste 1	execucao	Sala Teste Zona 1	\N	5	maintenance	t	2025-11-04 12:45:53.417454	2025-11-04 12:45:53.417454
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
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
-- Data for Name: service_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_categories (id, type_id, name, description, code, module, is_active, created_at, updated_at, customer_id) FROM stdin;
be576348-675a-4b59-a7fa-715bbb0e0f15	fd87bcf6-fc20-4157-84db-bda39a303069	Limpeza Tecnica		LPT	clean	t	2025-09-29 11:36:45.012782	2025-09-29 11:36:45.012782	7913bae1-bdca-4fb4-9465-99a4754995b2
81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive	Limpeza 		1	clean	t	2025-09-30 21:08:53.666682	2025-09-30 21:08:53.666682	43538320-fe1b-427c-9cb9-6b7ab06c1247
0aac35f5-126c-4beb-bb2e-19be6bb7fa19	2fa15718-d1aa-4a21-9438-4c21b4c4342b	Reposição	Reposição Preventiva	REPO_PVT	clean	t	2025-11-04 14:32:45.41796	2025-11-04 14:32:45.41796	d891d578-e86a-4cee-90f1-90158e82c2b0
4acf2157-5ce5-4474-8075-ddbb2ff925ba	2fa15718-d1aa-4a21-9438-4c21b4c4342b	Manutenção		MNT_PRV	clean	t	2025-11-04 14:55:14.555534	2025-11-04 14:55:14.555534	d891d578-e86a-4cee-90f1-90158e82c2b0
\.


--
-- Data for Name: service_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_types (id, name, description, code, module, is_active, created_at, updated_at, customer_id) FROM stdin;
st-emergency	Emergência	Serviços de emergência com atendimento crítico imediato	EMERG_SVC	clean	t	2025-09-22 20:27:06.022123	2025-09-22 20:27:06.022123	43538320-fe1b-427c-9cb9-6b7ab06c1247
st-preventive	Preventivo	Serviços de manutenção preventiva programada regular	PREV_SVC	clean	t	2025-09-22 20:27:06.022123	2025-09-22 20:27:06.022123	43538320-fe1b-427c-9cb9-6b7ab06c1247
fd87bcf6-fc20-4157-84db-bda39a303069	Preventiva	Limpeza programada.	PVT	clean	t	2025-09-29 11:34:51.663005	2025-09-29 11:34:51.663005	7913bae1-bdca-4fb4-9465-99a4754995b2
2fa15718-d1aa-4a21-9438-4c21b4c4342b	Preventivo	Manutenção preventiva	MNT_PREV	clean	t	2025-11-04 14:27:21.045528	2025-11-04 14:27:21.045528	d891d578-e86a-4cee-90f1-90158e82c2b0
a92a5290-57e9-4705-bafb-a517796a199b	Imprevisto	Serviço Urgente.	MNT_UGT	clean	t	2025-11-04 14:31:53.52691	2025-11-04 14:31:53.52691	d891d578-e86a-4cee-90f1-90158e82c2b0
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
0643fb68-262b-4f4b-bd6f-e6dc1c304a37	Higienização de Cabine		480	alta		clean	t	2025-09-29 11:50:25.144325	2025-09-29 11:53:39.923771	7913bae1-bdca-4fb4-9465-99a4754995b2	be576348-675a-4b59-a7fa-715bbb0e0f15	fd87bcf6-fc20-4157-84db-bda39a303069
1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	Limpeza Rotina		30	media	\N	clean	t	2025-10-01 01:21:20.474254	2025-10-01 01:21:20.474254	43538320-fe1b-427c-9cb9-6b7ab06c1247	81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive
service-3	Reposição de Suprimentos	Reposição de papel, sabão e materiais de higiene	15	media		clean	t	2025-09-20 15:14:25.875852	2025-10-01 01:21:32.882015	43538320-fe1b-427c-9cb9-6b7ab06c1247	81b4f31a-3f7b-4db0-a5af-f88189a961a8	st-preventive
c9fa2498-e81f-4794-a085-93efb487209e	Reposição de garrafas	Reposição de Copos descartável nas cafeteiras 	15	media	\N	clean	t	2025-11-04 14:34:01.830624	2025-11-04 14:34:01.830624	d891d578-e86a-4cee-90f1-90158e82c2b0	0aac35f5-126c-4beb-bb2e-19be6bb7fa19	2fa15718-d1aa-4a21-9438-4c21b4c4342b
142a37e3-f84f-4fbd-a8ef-690751804430	Teste de alteração de serviço Alterado	Teste	10	media	\N	clean	t	2025-11-04 14:52:02.496636	2025-11-04 14:53:25.628031	d891d578-e86a-4cee-90f1-90158e82c2b0	0aac35f5-126c-4beb-bb2e-19be6bb7fa19	2fa15718-d1aa-4a21-9438-4c21b4c4342b
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
ura-1759348117240-riyevbzyk	user-cliente-1759348116705	role-1759340407-cliente	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-01 19:48:37.311785
ura-1759521590344-qnd7yalh3	user-manoel.mariano-1759521589871	role-1759340407-admin	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-10-03 19:59:50.368012
ura-1760465989791-gmfe7wvxy	user-marcelo.cananea-1760461316804	role-1759340407-admin	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-14 15:19:49.791884
ura-1760548000442-afx4d3o1m	user-rita.caetano-1760548000058	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-15 14:06:40.442872
ura-1760549833140-r1iaduwll	user-valmir.vitor-1760549832765	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-15 14:37:13.140924
ura-1760549899218-ya1d3xu7e	user-cristiane.aparecida-1760549898846	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-15 14:38:19.218862
ura-1760549945019-xg66jual3	user-andreia.nicolau-1760549944643	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-15 14:39:05.019352
ura-1760549987158-8t7loarx6	user-nubia.solange-1760549986782	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-15 14:39:47.158988
ura-1760550018856-ggn2uvcbl	user-valeria.pessoa-1760550018472	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-10-15 14:40:18.857086
ura-1760638772219-mc77e3fg8	user-Eduardo.Santos-1760638771842	role-1759340407-cliente	7913bae1-bdca-4fb4-9465-99a4754995b2	2025-10-16 15:19:32.22005
ura-1762213291638-kxxbdislh	user-TesteManu-1762213291259	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-03 23:41:31.648936
ura-1762214240143-phzx4xw7q	user-testeM-1762214239673	role-1759340407-operador	43538320-fe1b-427c-9cb9-6b7ab06c1247	2025-11-03 23:57:20.155288
ura-1762267309317-c4gctgkmi	user-Teste.manutencao-1762267308881	role-1759340407-operador	d891d578-e86a-4cee-90f1-90158e82c2b0	2025-11-04 14:41:49.329175
\.


--
-- Data for Name: user_site_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_site_assignments (id, user_id, site_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, company_id, customer_id, username, email, password, name, role, user_type, assigned_client_id, auth_provider, external_id, ms_tenant_id, is_active, created_at, updated_at, modules) FROM stdin;
user-CLIENTE-1759343961359	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	CLIENTE	CLIENTE	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	CLIENTE	operador	customer_user	\N	local	\N	\N	t	2025-10-01 18:39:21.841755	2025-10-01 18:39:21.841755	{clean}
user-cliente-1759348116705	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	cliente	cliente	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	cliente	operador	customer_user	\N	local	\N	\N	t	2025-10-01 19:48:37.156067	2025-10-01 19:48:37.156067	{clean}
edd03c06-0426-4b21-a04d-f0fa8e48614b	company-admin-default	\N	novouser	novo@opus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Novo Usuario	admin	opus_user	\N	local	\N	\N	f	2025-10-03 19:50:12.82637	2025-10-03 19:50:41.221367	{clean}
39752b08-e1a2-491e-881b-818f00af20ab	company-admin-default	\N	teste123	teste@gmail.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	teste	admin	opus_user	\N	local	\N	\N	f	2025-10-03 19:50:37.283292	2025-10-03 19:50:44.05959	{clean}
42f5fd80-cc79-4f2a-946e-91b8abb67da3	company-admin-default	\N	opus123	opus123@opus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	opus123	admin	opus_user	\N	local	\N	\N	f	2025-10-03 19:50:56.90826	2025-10-03 19:51:00.378371	{clean}
10dbff4c-de78-41a4-a9f0-d9d28e62c8a3	company-admin-default	\N	thiago.lancelotti	thiago.lancelotti@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	thiago.lancelotti	admin	opus_user	\N	local	\N	\N	t	2025-10-05 14:50:05.671043	2025-10-05 14:50:05.671043	{clean}
user-manoel.mariano-1759521589871	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	manoel.mariano	manoel.mariano	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	manoel.mariano	operador	customer_user	\N	local	\N	\N	t	2025-10-03 19:59:50.309608	2025-10-06 14:01:13.504171	{clean}
user-marcelo.cananea-1760461316804	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	marcelo.cananea	marcelo.cananea@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Marcelo 	operador	customer_user	\N	local	\N	\N	t	2025-10-14 14:01:57.191224	2025-10-14 15:21:06.645876	{clean}
user-rita.caetano-1760548000058	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	rita.caetano	rita.caetano@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Rita Caetano	operador	customer_user	\N	local	\N	\N	t	2025-10-15 14:06:40.437454	2025-10-15 14:06:40.437454	{clean}
user-valmir.vitor-1760549832765	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	valmir.vitor	valmir.vitor@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Valmir Vitor	operador	customer_user	\N	local	\N	\N	t	2025-10-15 14:37:13.137207	2025-10-15 14:37:13.137207	{clean}
user-cristiane.aparecida-1760549898846	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	cristiane.aparecida	cristiane.aparecida@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Cristiane Aparecida	operador	customer_user	\N	local	\N	\N	t	2025-10-15 14:38:19.215855	2025-10-15 14:38:19.215855	{clean}
user-admin-opus	company-admin-default	\N	admin	admin@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Administrador Sistema	admin	opus_user		local			t	2025-09-10 20:41:26.774513	2025-09-10 20:41:26.774513	{clean,maintenance}
user-andreia.nicolau-1760549944643	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	andreia.nicolau	andreia.nicolau@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Andreia Nicolau	operador	customer_user	\N	local	\N	\N	t	2025-10-15 14:39:05.016494	2025-10-15 14:39:05.016494	{clean}
user-nubia.solange-1760549986782	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	nubia.solange	nubia.solange@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Nubia Solange	operador	customer_user	\N	local	\N	\N	t	2025-10-15 14:39:47.155811	2025-10-15 14:39:47.155811	{clean}
user-valeria.pessoa-1760550018472	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	valeria.pessoa	valeria.pessoa@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Valeria Pessoa	operador	customer_user	\N	local	\N	\N	t	2025-10-15 14:40:18.854005	2025-10-15 14:40:18.854005	{clean}
user-Eduardo.Santos-1760638771842	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	Eduardo.Santos	eduardo.santos@tecnofibras.com.br	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Eduardo Santos	operador	customer_user	\N	local	\N	\N	t	2025-10-16 15:19:32.214869	2025-10-16 15:19:32.214869	{clean}
840a9cf4-19c2-4547-bb60-58a6c40b2e4a	company-opus-default	\N	marcos.mattos 	marcos.mattos@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Marcos Mattos	operador	opus_user	\N	local	\N	\N	f	2025-10-27 16:22:26.231216	2025-10-27 16:29:59.139225	{clean}
op-teste-1758573497.448657	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	teste	teste@operador.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	Operador Teste	operador	opus_user		local			t	2025-09-22 20:38:17.448657	2025-10-29 14:51:58.036405	{clean}
d0f1f357-cdda-49a8-874b-ddad849b0f66	company-admin-default	7913bae1-bdca-4fb4-9465-99a4754995b2	operador1	operador1@grupoopus.com	$2b$10$OdL/7.EXsfOcg5hgI6VhfubX7n0soD4CeSRApJCrrSxsq.D6jOgX6	João Operador	operador	opus_user		local			t	2025-09-22 10:40:01.589971	2025-10-29 14:56:13.294323	{clean}
user-TesteManu-1762213291259	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	TesteManu	teste@teste.com	$2b$12$GWFcw/1Fh5jeYn/TOndztOP7PNbwjm3fTJWzHSPiBqWv4YirVQMzS	Teste2	operador	customer_user	\N	local	\N	\N	t	2025-11-03 23:41:31.619296	2025-11-03 23:41:31.619296	{clean}
user-testeM-1762214239673	company-admin-default	43538320-fe1b-427c-9cb9-6b7ab06c1247	testeM	Teste@teste.com	$2b$10$JczMQlkZNakHf3FW/osZ5udZ1owC5wsO8GpCBfjQY9RvhCuJLdqg6	Teste Manutenção	operador	customer_user	\N	local	\N	\N	t	2025-11-03 23:57:20.12052	2025-11-04 12:49:29.59965	{clean}
user-Teste.manutencao-1762267308881	company-admin-default	d891d578-e86a-4cee-90f1-90158e82c2b0	Teste.manutencao	TestedeTeste@gmail.com	$2b$12$0q1SVVyXapHrPFczBHbWbuqFffsSOt5boQ1JT3EgrD.s2NbSnPeya	Teste de manutenção	operador	customer_user	\N	local	\N	\N	t	2025-11-04 14:41:49.300472	2025-11-04 14:41:49.300472	{maintenance}
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

COPY public.work_orders (id, number, company_id, module, zone_id, service_id, cleaning_activity_id, checklist_template_id, equipment_id, maintenance_plan_equipment_id, type, status, priority, title, description, assigned_user_id, origin, qr_code_point_id, requester_name, requester_contact, scheduled_date, due_date, scheduled_start_at, scheduled_end_at, started_at, completed_at, estimated_hours, sla_start_minutes, sla_complete_minutes, observations, checklist_data, attachments, customer_rating, customer_rating_comment, rated_at, rated_by, created_at, updated_at, maintenance_activity_id) FROM stdin;
a3081adf-41cf-4616-b23e-dd436ddc41f8	419	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.474638	2025-10-27 14:22:37.474638	\N
0a3e0acb-8dcb-4f68-ad97-31ed103b3324	420	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.477586	2025-10-27 14:22:37.477586	\N
47ae0251-216b-457d-bd0c-fbb4f6f4bef8	421	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.480688	2025-10-27 14:22:37.480688	\N
06a5242b-8a73-40fa-9f7b-ea214d1fa282	422	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.48447	2025-10-27 14:22:37.48447	\N
81bce98a-7c38-4e31-bb54-b3f189b4b3b9	423	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.4889	2025-10-27 14:22:37.4889	\N
362cb832-e36e-460b-acfe-926051972798	424	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.493732	2025-10-27 14:22:37.493732	\N
be8ed5ee-f7d9-4df2-8b2d-1ebc5b554e80	425	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.498065	2025-10-27 14:22:37.498065	\N
eb6b15ff-cf88-4327-a47b-2bc74b7bdeef	426	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.500524	2025-10-27 14:22:37.500524	\N
9e51386d-0cf0-4635-9e95-9a328727f613	427	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.502913	2025-10-27 14:22:37.502913	\N
43cc25d0-e95a-4dda-a08e-dc5a944452c2	428	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.505076	2025-10-27 14:22:37.505076	\N
9d96213d-2070-4603-a58b-9b9ff7f60f72	429	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.510757	2025-10-27 14:22:37.510757	\N
16592b35-db61-4683-ae4c-dda088d0774b	430	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.51317	2025-10-27 14:22:37.51317	\N
a09e799b-a769-4bba-8928-e928ca83c755	431	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.515291	2025-10-27 14:22:37.515291	\N
a03e5145-680c-4fdf-ac90-8ee965ff5c84	432	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.517476	2025-10-27 14:22:37.517476	\N
bf0b9b65-8ba0-40b7-8343-ba010c133ad7	433	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.519656	2025-10-27 14:22:37.519656	\N
efec1862-dbb6-440d-a4ed-66969dfbac67	434	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.524971	2025-10-27 14:22:37.524971	\N
6002f123-0c5e-4146-ac91-8beddec9d33c	435	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.527944	2025-10-27 14:22:37.527944	\N
05d87b01-c265-40bc-a50e-53e776bb7421	436	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.530921	2025-10-27 14:22:37.530921	\N
bc66bbf5-79a2-478c-80eb-c7332088b110	437	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.534623	2025-10-27 14:22:37.534623	\N
fa80f107-ad30-4c32-a324-1833ee8b75e4	438	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.536997	2025-10-27 14:22:37.536997	\N
e643d287-5eeb-4a3c-a3a9-253c7197aa34	439	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.539212	2025-10-27 14:22:37.539212	\N
6ca9738d-2757-447c-941a-02c91f1b5ee8	440	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.541611	2025-10-27 14:22:37.541611	\N
2827fd96-0c21-4309-903e-990d2c26c2d8	991	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.98153	2025-10-27 16:00:37.98153	\N
3b46773e-2b1e-47be-b8b9-c8a0c6f86c54	441	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.543955	2025-10-27 14:22:37.543955	\N
a6e9de96-32be-4ea4-a1c7-046378f812ed	442	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.546018	2025-10-27 14:22:37.546018	\N
0265470b-ea18-439f-a6fa-b063b1285250	253	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nLimpeza interna das paredes e vidros das cabines do primer;\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\nJateamento com lava jato e aplicação de graxa patente no transportador\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:36:17.922146	2025-10-07 18:36:17.922146	\N
0fd6a4a4-bcfc-4da3-a99a-5fc2ee36ed97	254	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nLimpeza interna das paredes e vidros das cabines do primer;\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\nJateamento com lava jato e aplicação de graxa patente no transportador\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:36:17.929224	2025-10-07 18:36:17.929224	\N
3f05fff9-eeec-48ac-ba72-35ad01741f28	255	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nLimpeza interna das paredes e vidros das cabines do primer;\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\nJateamento com lava jato e aplicação de graxa patente no transportador\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:36:17.934721	2025-10-07 18:36:17.934721	\N
0b30fb18-61d3-44b4-8809-5727c376cff5	256	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759872977850-wyex3v3sb	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nLimpeza interna das paredes e vidros das cabines do primer;\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente\nJateamento com lava jato e aplicação de graxa patente no transportador\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:36:17.939227	2025-10-07 18:36:17.939227	\N
5e96e75b-8586-4d9c-8b27-44afc9b3db89	257	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\nLimpeza interna das paredes e vidros das cabines do verniz\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do flash off do verniz\nLimpeza das liminárias do verniz\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\n\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:40:20.845216	2025-10-07 18:40:20.845216	\N
6a7eaa99-7307-4a50-b033-04d8243e7fea	258	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\nLimpeza interna das paredes e vidros das cabines do verniz\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do flash off do verniz\nLimpeza das liminárias do verniz\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\n\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:40:20.851634	2025-10-07 18:40:20.851634	\N
f1dab9e4-dbe2-4fb5-9a94-a1ef280a3b09	259	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\nLimpeza interna das paredes e vidros das cabines do verniz\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do flash off do verniz\nLimpeza das liminárias do verniz\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\n\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:40:20.856738	2025-10-07 18:40:20.856738	\N
cbed4d86-cc62-4d50-9e51-201ded6d5ac0	260	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\nLimpeza interna das paredes e vidros das cabines do verniz\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do flash off do verniz\nLimpeza das liminárias do verniz\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\n\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:40:20.866706	2025-10-07 18:40:20.866706	\N
50a5450f-d274-46a4-9861-4f13e1310d31	261	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759873220782-9wdyrslvl	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Jateamento com lava jato e aplicação de graxa patente no transportador\nLimpeza interna das paredes e vidros das cabines do verniz\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do flash off do verniz\nLimpeza das liminárias do verniz\nLimpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente\n\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 18:40:20.880028	2025-10-07 18:40:20.880028	\N
1e06e0bf-6c45-491a-ace6-ca71780fd5c6	992	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.983649	2025-10-27 16:00:37.983649	\N
35a5b7ec-9870-4c88-8f9a-8b1d003d0bf3	271	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\nTroca de filtro da exaustão\nLimpeza do chão da cabine\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:34:27.495448	2025-10-07 20:34:27.495448	\N
1104933d-2ce1-47c4-b515-05b58f6d04ec	443	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.549625	2025-10-27 14:22:37.549625	\N
1bebabe3-aca4-4dff-bc35-2cae8c86ed0c	444	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.551886	2025-10-27 14:22:37.551886	\N
62111898-5194-40e5-b4fa-a9d16a1f7888	445	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.554844	2025-10-27 14:22:37.554844	\N
ea4e3b30-b5ca-4bc1-b857-ef19451ae089	446	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.557282	2025-10-27 14:22:37.557282	\N
5d48a1f0-b3b5-4e35-9928-f2e981ad5eb9	447	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.559492	2025-10-27 14:22:37.559492	\N
f8fd731c-4efb-4315-be76-5bd6a8cba41d	448	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.561671	2025-10-27 14:22:37.561671	\N
e44fb95f-09b7-4783-96e1-e91a79ba8567	449	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585757243-elx2y62kt	\N	\N	\N	programada	aberta	media	LOG - Limpeza de banheiros e vestiarios femininos 	Limpeza dos vestiários e banheiros femininos da logística	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:22:37.563899	2025-10-27 14:22:37.563899	\N
4795abd6-e51a-4c5b-9070-751c05b6e50b	481	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.177921	2025-10-27 14:28:37.177921	\N
900da72a-42cc-4c31-830a-14a36fb602c1	482	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.18168	2025-10-27 14:28:37.18168	\N
935d453d-31d6-4322-a3d0-154f70222b08	483	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.187656	2025-10-27 14:28:37.187656	\N
e6557f1a-6d15-4832-988e-7ff2a4f4f43a	484	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.190471	2025-10-27 14:28:37.190471	\N
6dfc9e20-2e5f-4cc4-af67-ef8a11244b3d	485	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.192851	2025-10-27 14:28:37.192851	\N
97d52afb-a6fc-4477-a08d-3c24836a80b7	486	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.195305	2025-10-27 14:28:37.195305	\N
d4561938-8b25-43dc-b8d7-cedb5e76540e	487	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.199614	2025-10-27 14:28:37.199614	\N
260be63c-e641-484d-9dd7-2e6fb2dec954	488	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.201839	2025-10-27 14:28:37.201839	\N
932563cb-4e1d-4c74-9856-0ae12d29a2ae	489	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.205627	2025-10-27 14:28:37.205627	\N
2309a7f2-665f-4d1a-a7bc-e3d078d7f3f7	490	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.211421	2025-10-27 14:28:37.211421	\N
3c498c2c-5a6b-4da1-9845-fa0f78e6ccc9	491	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.217456	2025-10-27 14:28:37.217456	\N
67568bc8-765c-4b23-913d-bdcd5c29d8e9	492	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.223761	2025-10-27 14:28:37.223761	\N
75b0b106-53e2-4916-8585-45d7ffcee005	493	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.228752	2025-10-27 14:28:37.228752	\N
5feae033-2ec5-4ec9-9175-d9c660fff6c5	494	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.231471	2025-10-27 14:28:37.231471	\N
78d48a0a-9f17-4e40-9ba2-f7bf0e85fa70	993	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.985762	2025-10-27 16:00:37.985762	\N
fe1f8835-4451-49ad-9dd8-a6ca6b9f443e	495	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.234787	2025-10-27 14:28:37.234787	\N
bbed1172-72f4-48c9-9c46-26a47b47436a	496	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.241623	2025-10-27 14:28:37.241623	\N
937208ef-4345-47c3-8777-9386cf6c4e4c	667	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.065863	2025-10-27 15:45:18.065863	\N
ece6f5cc-dd3f-4fbc-a55d-9075fc3efcf5	450	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.819778	2025-10-27 14:24:30.819778	\N
597837fc-7382-4215-b5a2-fd57ff4dd593	451	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.828025	2025-10-27 14:24:30.828025	\N
e77d4879-625b-49b4-a3b2-6157fa9dcb83	452	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.832892	2025-10-27 14:24:30.832892	\N
c0aab109-32e6-491c-b33d-c35850e0b0bf	266	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:28:37.218734	2025-10-07 20:28:37.218734	\N
6d3ea290-49aa-46cd-ae02-7c37872a76af	267	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:28:37.225084	2025-10-07 20:28:37.225084	\N
d1d1f959-4b9c-431a-8971-12cfe60cbd82	268	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:28:37.229272	2025-10-07 20:28:37.229272	\N
27a89f22-8eb9-447b-8246-44c9cd1177da	269	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:28:37.235252	2025-10-07 20:28:37.235252	\N
603c2bd2-5d95-4d87-bf13-efde31309e55	270	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759879717135-p4iquwjki	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer SMC	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:28:37.240102	2025-10-07 20:28:37.240102	\N
808f6447-cbd8-4497-8899-7019ecd0ad9d	453	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.837858	2025-10-27 14:24:30.837858	\N
431ebab9-f76c-424c-9d3f-0d85efdae48f	454	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.842914	2025-10-27 14:24:30.842914	\N
38dbbce4-6fe3-433c-922c-af7efd5f24bc	455	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.846837	2025-10-27 14:24:30.846837	\N
56a6974e-c9f2-416a-a623-606bc7854218	456	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.849725	2025-10-27 14:24:30.849725	\N
5c197d0f-8ef2-4c72-ada1-6e73362a4254	457	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.853214	2025-10-27 14:24:30.853214	\N
f64de416-afae-4092-b7b6-20e75e7c24a6	458	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.856558	2025-10-27 14:24:30.856558	\N
7a5a8108-81d9-4248-b26f-38f01f1ab069	459	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.859093	2025-10-27 14:24:30.859093	\N
aa3495fc-9ff9-4167-bc22-5e08cfcf0914	460	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.861675	2025-10-27 14:24:30.861675	\N
bffd1911-fc11-4467-bd5b-f7f15fbedbfd	461	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.864185	2025-10-27 14:24:30.864185	\N
fa3b7859-703c-458f-90ce-3c6ea3bd99a3	462	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.866573	2025-10-27 14:24:30.866573	\N
621d1341-956b-4a74-9805-f6625d6388f2	463	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.868874	2025-10-27 14:24:30.868874	\N
eebd9277-0aa4-44cc-a70e-91dd50151c5c	272	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\nTroca de filtro da exaustão\nLimpeza do chão da cabine\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:34:27.502864	2025-10-07 20:34:27.502864	\N
9fac80c0-c99a-434e-9429-52edd96abddf	273	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\nTroca de filtro da exaustão\nLimpeza do chão da cabine\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:34:27.507426	2025-10-07 20:34:27.507426	\N
d526f813-c733-492b-8996-de9aae8da6e3	274	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\nTroca de filtro da exaustão\nLimpeza do chão da cabine\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:34:27.512066	2025-10-07 20:34:27.512066	\N
f10ce639-985a-4532-9f63-fdbbe30991d7	275	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880067433-fd68ihnyq	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática\nTroca de filtro da exaustão\nLimpeza do chão da cabine\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:34:27.518827	2025-10-07 20:34:27.518827	\N
c4891cac-7129-40c1-952d-3f6809deefdb	276	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:46:34.731228	2025-10-07 20:46:34.731228	\N
d64cdb1b-aa68-4458-b079-1277e353f9d2	277	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:46:34.735428	2025-10-07 20:46:34.735428	\N
aa624e68-3e23-493a-8dbf-6c05f231b258	278	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:46:34.738386	2025-10-07 20:46:34.738386	\N
aaef7504-3025-4fee-acb8-5ca4b5bad773	279	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759880794641-vnxzwhd83	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer\nTroca de filtro da exaustão\nLimpeza do flash off do primer\nLimpeza estufa do primer\nLimpeza das luminárias do primer\nAspiração da região superior (teto) da estufa do primer\nLimpeza (raspar) os rotores (2) da exaustão do primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 20:46:34.742298	2025-10-07 20:46:34.742298	\N
c14c38ee-210e-48c6-99d0-01d12d63f98a	280	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\t\t\t\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:00:42.051851	2025-10-07 21:00:42.051851	\N
e7fe88a7-c278-4f4e-adf0-24f10b7f9fd4	281	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\t\t\t\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:00:42.064472	2025-10-07 21:00:42.064472	\N
8d8e030d-dd5f-4764-a08b-fc4ebcba59f8	282	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\t\t\t\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:00:42.072204	2025-10-07 21:00:42.072204	\N
eb0e1a9a-2ac6-4505-92f6-e451a2651ac9	283	company-admin-default	clean	a415c33b-c0ac-4a79-87c3-38a7c36d0cfa	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759881641311-jajipa099	\N	\N	\N	programada	aberta	media	Estufas pintura SMC + cabine final 	Final de semana, piso, paredes e teto\t\t\t\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:00:42.083124	2025-10-07 21:00:42.083124	\N
ccffee3a-4c91-4d46-9859-be8ae91c62c7	585	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.215571	2025-10-27 14:47:06.215571	\N
962cb8d1-29d3-4d64-9f0e-67c5f5a3b6be	284	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.170299	2025-10-07 21:12:14.170299	\N
0324b0f5-dad0-48dc-be35-6ab981052f3a	285	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.178039	2025-10-07 21:12:14.178039	\N
f40edb97-82b2-4106-b978-2bdb07159787	286	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.186721	2025-10-07 21:12:14.186721	\N
a0b2bd9c-2e97-4264-81b3-d5c8d87ec95a	287	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.195101	2025-10-07 21:12:14.195101	\N
34aa9f5e-6d17-4551-bde9-553aee31c135	288	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.205965	2025-10-07 21:12:14.205965	\N
86383070-2c1d-41ea-8a4a-636232de536f	289	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.212339	2025-10-07 21:12:14.212339	\N
0f8f8823-d4bd-4e2a-ba4a-553e9a510cfc	290	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.218039	2025-10-07 21:12:14.218039	\N
0e7c0502-4512-44d0-a03a-a1de505d076a	291	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.225135	2025-10-07 21:12:14.225135	\N
1e1657fc-dbda-4445-9017-3e13882639b3	292	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.230014	2025-10-07 21:12:14.230014	\N
374b140c-ebab-4ec5-b59a-a2724b0d7088	293	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.234122	2025-10-07 21:12:14.234122	\N
918c32bf-eb9c-4a62-8366-0ed5e70532f8	294	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.240468	2025-10-07 21:12:14.240468	\N
6033f064-3718-4225-ad68-301c25bac35e	295	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.244863	2025-10-07 21:12:14.244863	\N
45f69590-f646-4097-9c69-fbe513309550	296	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.25244	2025-10-07 21:12:14.25244	\N
cf3673e2-b1f3-4f41-a76c-ecf7fdf453b3	297	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.260173	2025-10-07 21:12:14.260173	\N
0ef562d9-3c71-4b72-819d-e9dacee2a7ff	298	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.269963	2025-10-07 21:12:14.269963	\N
6ac5ea6d-6f99-4aa9-b713-07b6c7c72b4f	299	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.27961	2025-10-07 21:12:14.27961	\N
4407670b-03fd-48b9-bea1-061e76a8a2ef	300	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.286256	2025-10-07 21:12:14.286256	\N
ec9fc834-824f-4c48-b819-8eda3c1825cb	464	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.871137	2025-10-27 14:24:30.871137	\N
e95a00bf-cbb3-46f1-92a7-e0ad4ebcce44	465	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.875849	2025-10-27 14:24:30.875849	\N
fdac49bf-46e7-4e77-95c7-c79b40cc3154	466	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.878551	2025-10-27 14:24:30.878551	\N
dc285502-83a8-4dc7-88ae-2769c0337ca2	302	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.295664	2025-10-07 21:12:14.295664	\N
ddfae9bf-488a-4330-9c6f-675e9c74aa83	303	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.301887	2025-10-07 21:12:14.301887	\N
c04d1308-5f9d-4753-9c26-861ba3bb2852	304	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.30992	2025-10-07 21:12:14.30992	\N
da0d29b4-9861-4712-b1eb-eb609a463ec3	305	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.316484	2025-10-07 21:12:14.316484	\N
d02c5130-72be-45e9-a642-60d17dac5959	306	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.321586	2025-10-07 21:12:14.321586	\N
7dc56154-ba4a-4417-9ddf-40a148dc5254	307	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.327932	2025-10-07 21:12:14.327932	\N
ef36b53b-3942-4810-b544-3adab7356f33	308	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.334037	2025-10-07 21:12:14.334037	\N
64031a41-2651-4c92-9124-e11b75079075	309	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.33943	2025-10-07 21:12:14.33943	\N
74302911-3aff-4db8-b16a-354306092faf	310	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.343907	2025-10-07 21:12:14.343907	\N
06dca77d-fbfa-4117-a505-229825462fd0	311	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.349009	2025-10-07 21:12:14.349009	\N
21928095-9588-4a0b-995a-4f55cdc98cee	312	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.353934	2025-10-07 21:12:14.353934	\N
48a6b80a-d7a0-42c9-b5d3-53dd7db6786c	313	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.359085	2025-10-07 21:12:14.359085	\N
dc9f254f-8c41-430c-b2fc-fccd4ae4f37f	314	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	aberta	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 21:12:14.363519	2025-10-07 21:12:14.363519	\N
d778a5c5-44c9-4c4c-a5d1-0630ef274786	315	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.144231	2025-10-07 22:09:23.144231	\N
b1021599-4a98-4db6-8fdd-eb6deaad92b5	316	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.157294	2025-10-07 22:09:23.157294	\N
976a1e8d-6624-4566-80e4-daa5577dd8df	317	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.161213	2025-10-07 22:09:23.161213	\N
be4f0cb9-0dd5-4436-a580-8808d1e6c750	318	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.165307	2025-10-07 22:09:23.165307	\N
c05aa57e-0440-40de-a230-5c2f7bcaf3d3	319	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.171533	2025-10-07 22:09:23.171533	\N
06f4d333-ba23-45e9-b821-da9106630fd3	320	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.178137	2025-10-07 22:09:23.178137	\N
1d066441-32ff-4a21-9806-a3bbc1ff528c	321	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.182997	2025-10-07 22:09:23.182997	\N
b97959e9-333a-4c7a-9e26-679b26ac00f8	322	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.186387	2025-10-07 22:09:23.186387	\N
d91e0c57-d50e-416c-881b-b854251516b5	323	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.191173	2025-10-07 22:09:23.191173	\N
cc38fffa-e58b-4a58-9b40-6fe37745ff64	324	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.194822	2025-10-07 22:09:23.194822	\N
d428e716-84c6-462d-bacc-bae601d9855a	325	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.199012	2025-10-07 22:09:23.199012	\N
9f27e645-58c6-4ca6-9d4d-fb5d32a32b9a	326	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.203787	2025-10-07 22:09:23.203787	\N
eb6e5306-71bc-4667-b1a8-cc25be51f08a	327	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.208121	2025-10-07 22:09:23.208121	\N
18b45bb1-2710-4707-a30a-a4571bbeb892	328	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.218841	2025-10-07 22:09:23.218841	\N
672381d0-3fdc-4936-951e-126107c41faa	329	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.232375	2025-10-07 22:09:23.232375	\N
10142248-306e-4c9b-8b6d-290c1ab3a32a	330	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.240044	2025-10-07 22:09:23.240044	\N
3328f7b7-305b-445f-a2ee-f50a675f4165	331	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.247839	2025-10-07 22:09:23.247839	\N
24456b9f-fcd2-42b1-afe3-80bf4c5f3d8b	332	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.252212	2025-10-07 22:09:23.252212	\N
6654b3cb-2838-4cee-8d4e-ce6ae641d31c	333	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.255427	2025-10-07 22:09:23.255427	\N
86d454db-453c-435e-b8a8-b76aaae2b2af	994	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.98796	2025-10-27 16:00:37.98796	\N
10ec1d2a-3995-4588-8128-24a3fa3cffbe	334	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.258263	2025-10-07 22:09:23.258263	\N
4d090838-23c0-41d5-a4ea-2afd340f1476	335	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.261387	2025-10-07 22:09:23.261387	\N
18290b71-bc17-4cda-b4c6-8058c64c1d12	336	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.267412	2025-10-07 22:09:23.267412	\N
cc3e9305-0b5c-4c80-8ed8-4903ea383dbf	337	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.273297	2025-10-07 22:09:23.273297	\N
87157635-5d7f-43e9-be26-14d5d1684961	338	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.279719	2025-10-07 22:09:23.279719	\N
aaf45fba-9f3e-46c8-b194-102c15f1e754	339	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.287904	2025-10-07 22:09:23.287904	\N
a00adaaf-b092-4f98-ace2-303a6d5853c1	340	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.29895	2025-10-07 22:09:23.29895	\N
771edfdb-2a24-48c7-b56d-eca31517c941	341	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.305081	2025-10-07 22:09:23.305081	\N
ddbe131e-8658-490b-89a8-96d9aa669429	342	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.315397	2025-10-07 22:09:23.315397	\N
08fcb1ba-7bc2-45d4-8db6-39464c5986ef	343	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.324025	2025-10-07 22:09:23.324025	\N
d561fd04-472c-48ad-abf9-ba52559c967d	344	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.332889	2025-10-07 22:09:23.332889	\N
868dd8da-05c1-4b66-b15c-815701a51ccf	345	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759885763030-rw4vueq89	\N	\N	\N	programada	aberta	media	Cabine de Pintura Estática RTm Cowling	Limpeza do piso ao redor das Cabinas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 22:09:23.343886	2025-10-07 22:09:23.343886	\N
5ebf5172-dc46-455d-a061-e1e3f560df46	467	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.880926	2025-10-27 14:24:30.880926	\N
7775ede7-0e23-4b6e-bc01-722ef19dc900	381	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\nTroca de filtro da exaustão da cabine estática SMC fante\nLimpeza das liminárias da cabine estática SMC fante\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:13:49.346776	2025-10-07 23:13:49.346776	\N
8d47cd07-b68b-47dc-a52d-630f5ee8b3bb	382	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:16:48.41	2025-10-07 23:16:48.41	\N
87869762-dd5e-4a9d-8d2c-e73f047ab46a	468	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.883382	2025-10-27 14:24:30.883382	\N
a0702e58-32ba-42c7-baca-117100f73997	586	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.220329	2025-10-27 14:47:06.220329	\N
f7281089-3632-453a-927a-1c795ee31f18	378	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\nTroca de filtro da exaustão da cabine estática SMC fante\nLimpeza das liminárias da cabine estática SMC fante\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:13:49.335048	2025-10-07 23:13:49.335048	\N
c20bf156-3aa3-440f-b3fa-fdad5682641c	379	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\nTroca de filtro da exaustão da cabine estática SMC fante\nLimpeza das liminárias da cabine estática SMC fante\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:13:49.338861	2025-10-07 23:13:49.338861	\N
44173277-465a-4154-a507-12e4d4b41f98	380	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889629139-pqcuh75ib	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Fante	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC fante\nTroca de filtro da exaustão da cabine estática SMC fante\nLimpeza das liminárias da cabine estática SMC fante\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC fante e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:13:49.344009	2025-10-07 23:13:49.344009	\N
a1f0534f-81fb-424b-865b-89356cf5a3e8	383	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:16:48.413258	2025-10-07 23:16:48.413258	\N
5b549f49-f4db-44e9-9c60-aa45569d8f30	384	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:16:48.41628	2025-10-07 23:16:48.41628	\N
36c47ef9-1ea2-4c16-ab82-c634c3d7600d	385	company-admin-default	clean	2ba21003-b82d-4950-8a6b-f504740960ea	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759889808223-kkbhkfsdy	\N	\N	\N	programada	aberta	media	Cabine Estática SMC Primer	Limpeza interna das paredes e vidros das cabines do primer\nAplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer\nTroca de filtro da exaustão da cabine estática SMC primer\nLimpeza das liminárias da cabine estática SMC ptimer\nLimpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:16:48.418958	2025-10-07 23:16:48.418958	\N
b532726a-31c9-4e9c-9fc8-84332770abb2	386	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759890045118-y0c75246f	\N	\N	\N	programada	aberta	media	Cabine de Pintura Final RTM	Limpeza do fosso da exaustão da base\nLimpeza externa das paredes e vidros das cabines da base\nLimpeza do fosso da exaustão do verniz\nAspiração da região superior (teto) da estufa da pintura final\nLimpeza externa das paredes e vidros das cabines do verniz\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-07 23:20:45.227062	2025-10-07 23:20:45.227062	\N
ab83a444-b6bf-4fd3-9133-cb5780dce91a	301	company-admin-default	clean	20864c38-1234-46e6-8581-46e3c55a9b87	0643fb68-262b-4f4b-bd6f-e6dc1c304a37	ca-1759882334068-bqesftjui	\N	\N	\N	programada	concluida	media	Cabine de Pintura Primer RTM	Plastificação dos carrinhos (remover e recolocar os plásticos);\nTroca de filtro da exaustão da cabine da base\nTroca de filtro da exaustão da cabine do verniz\nLimpeza do piso ao redor dos postos de trabalho, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\nLimpeza do piso ao redor das Cabinas e Estufas, equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão. \nLimpeza do piso ao redor da Corrente do transportador, fora das Cabinas e Estufas. Área de Gancheiras e arredores. Equipamentos, bancadas (exceto dos operadores), gabinetes, painéis, etc até o nível de 1,60 m do chão.\n	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	2025-10-07 21:12:14.291	2025-10-17 17:08:33.467	\N	\N	\N	\N	{"1759332012650": {"type": "photo", "count": 1, "photos": ["data:image/png;base64,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"]}, "1759436504239": "Sim."}	\N	\N	\N	\N	\N	2025-10-07 21:12:14.291022	2025-10-17 14:08:35.630326	\N
b42c41aa-cbbf-4b7a-9f03-4195c403880d	469	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.885952	2025-10-27 14:24:30.885952	\N
96c1ca49-64e5-4be6-ad04-f95e8f1c5b1a	470	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.888446	2025-10-27 14:24:30.888446	\N
f89622b2-2c52-439e-8fe3-f41db23a426d	471	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.891666	2025-10-27 14:24:30.891666	\N
8bf49dfe-8b8a-4110-89f6-53109cc95675	472	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.894091	2025-10-27 14:24:30.894091	\N
4995f68e-ab15-4ecb-97f4-db91fd3105b4	473	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.89644	2025-10-27 14:24:30.89644	\N
70e71ab1-7a7f-434b-a04c-577f3d74f418	474	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.898776	2025-10-27 14:24:30.898776	\N
c61bd98c-3364-4950-a045-650ae0686268	475	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.901223	2025-10-27 14:24:30.901223	\N
7e489847-2814-413a-8ae3-7b113cade8f1	476	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.903795	2025-10-27 14:24:30.903795	\N
5fb73ddf-2b43-4f89-8789-13c126706a73	477	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.90624	2025-10-27 14:24:30.90624	\N
8df2d73d-4429-429c-a3a2-9b9615631191	478	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.908588	2025-10-27 14:24:30.908588	\N
72be2cca-9a06-4166-a5af-8fe1ef0c3312	479	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.911694	2025-10-27 14:24:30.911694	\N
8f055183-a3c8-4d24-908b-29a75317c5e8	480	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761585870492-w7xqg80th	\N	\N	\N	programada	aberta	media	Scania - Limpeza de WC e vestiários femininos 	Limpeza dos banheiros e vestiarios femininos Scania	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:24:30.91411	2025-10-27 14:24:30.91411	\N
8aac6209-8621-49d1-9ae7-30b20a5ae686	497	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.251767	2025-10-27 14:28:37.251767	\N
4dc5ff7a-5066-46c5-99ea-3b9bbbc3dd91	498	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.260749	2025-10-27 14:28:37.260749	\N
3e56f783-1440-4bbd-b2cd-76362a1fddf9	499	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.268847	2025-10-27 14:28:37.268847	\N
f1e7ec70-efdf-4d0f-aaaa-9117b13673bc	500	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.277205	2025-10-27 14:28:37.277205	\N
697342f5-e3bd-48d0-98a3-ffed79b9368a	501	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.283769	2025-10-27 14:28:37.283769	\N
42dfa3c0-9caf-47b1-b3f9-e319902780c2	502	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.288561	2025-10-27 14:28:37.288561	\N
36fd852b-83b1-415b-a3ca-c38607b5da47	503	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.290755	2025-10-27 14:28:37.290755	\N
ec266b05-4b43-44de-9ac6-c3037f142804	504	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.292941	2025-10-27 14:28:37.292941	\N
b667689e-5d8d-4ab7-b382-2076687f8264	505	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.295144	2025-10-27 14:28:37.295144	\N
e656efab-abae-4366-bcca-492fa4142a50	506	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.297396	2025-10-27 14:28:37.297396	\N
346ecd15-8402-47d4-b25e-2fc551cdc017	507	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.299921	2025-10-27 14:28:37.299921	\N
18825a18-43f9-4314-a8fe-3748100017b6	508	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.302108	2025-10-27 14:28:37.302108	\N
073ac220-6da9-41cc-aa52-61a1382d848e	509	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.304443	2025-10-27 14:28:37.304443	\N
f20b274a-00ab-44bd-9ac0-9d45b2d4fe45	510	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.309377	2025-10-27 14:28:37.309377	\N
edc74124-d8cd-4496-b9f6-434d8eb25e0f	511	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586116924-imqskabvg	\N	\N	\N	programada	aberta	media	Toyota - limpeza de WC e vestiarios femininos 	Limpeza de banheiros e vestiários femininos - Toyota 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:28:37.312424	2025-10-27 14:28:37.312424	\N
c40807b5-818d-49ba-9fe6-312c64ef3310	512	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.109786	2025-10-27 14:37:02.109786	\N
6da5e85e-49c0-48ed-bdb7-65b5d22d6979	513	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.112767	2025-10-27 14:37:02.112767	\N
9587ef44-7b61-427a-ae7d-49bb03e82255	514	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.11536	2025-10-27 14:37:02.11536	\N
737e828d-ce71-452e-a37d-9d41fa723bc5	515	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.118032	2025-10-27 14:37:02.118032	\N
87f05f1e-53dc-4e25-93a3-a0a20f5f8413	516	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.12044	2025-10-27 14:37:02.12044	\N
d3230064-2547-461a-98c8-86eb1c75ac6d	517	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.122765	2025-10-27 14:37:02.122765	\N
3e514962-b898-4d26-93ab-6be4e03b5ca8	518	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.1251	2025-10-27 14:37:02.1251	\N
20721e63-d2e3-49a3-b15f-f09295c14611	519	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.127366	2025-10-27 14:37:02.127366	\N
9e3a4e43-82f1-47db-be11-75af3bfc7080	520	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.129912	2025-10-27 14:37:02.129912	\N
df8a89ad-fa61-431a-808a-7efb8028fd1c	521	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.132149	2025-10-27 14:37:02.132149	\N
8d8e4a4f-16c7-453b-b6c9-ade166a08954	522	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.134434	2025-10-27 14:37:02.134434	\N
6424a1cc-7835-4392-af0b-a6fe818832a0	523	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.136886	2025-10-27 14:37:02.136886	\N
4e138990-132a-4b3d-b710-5c2f8354618c	524	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.139172	2025-10-27 14:37:02.139172	\N
ced6fd87-adaa-4d10-ac55-c10bf5f7064c	525	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.141555	2025-10-27 14:37:02.141555	\N
952277ac-c155-4af7-bda0-d94870bdbc7f	526	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.143938	2025-10-27 14:37:02.143938	\N
be1a8241-b105-4b7b-b5a4-53f2f270f7ab	527	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.148746	2025-10-27 14:37:02.148746	\N
61bd63cc-4047-4243-b7f7-dd40ec048045	528	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.15298	2025-10-27 14:37:02.15298	\N
71ee6bd9-af31-4744-84bf-577edabf8d33	529	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.156288	2025-10-27 14:37:02.156288	\N
4f9133bd-8d8c-433c-96dc-b2b993c66d9c	530	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.16102	2025-10-27 14:37:02.16102	\N
8ca0b674-b285-4382-b10e-0a5492c04a6e	531	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.166267	2025-10-27 14:37:02.166267	\N
c3edf137-0a80-42b4-a627-3f313b89b6d4	532	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.168532	2025-10-27 14:37:02.168532	\N
7470898c-26d4-400f-8ccf-862646794348	533	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.170763	2025-10-27 14:37:02.170763	\N
3df1cc1f-0077-4d4a-aca4-8e35b4656369	534	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.172915	2025-10-27 14:37:02.172915	\N
50045ddb-07c1-4b98-b92b-4920833a43dd	535	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.175099	2025-10-27 14:37:02.175099	\N
3568c2aa-8be6-4ea4-9c7b-fa97679f42e5	536	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.177415	2025-10-27 14:37:02.177415	\N
2f2064b8-9c7a-4803-9955-fe087dc4069e	537	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.179839	2025-10-27 14:37:02.179839	\N
15b3b448-a759-4370-98f1-b91d1588f9b3	538	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.182065	2025-10-27 14:37:02.182065	\N
6d2d007a-c303-45d7-8438-5d3a454b206a	539	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.18729	2025-10-27 14:37:02.18729	\N
c6fb2bf5-8490-4e6c-88e8-64ba5a483c6e	540	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.191743	2025-10-27 14:37:02.191743	\N
0b92b4dd-114c-4648-b7f7-c2132d7f4776	541	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.196707	2025-10-27 14:37:02.196707	\N
afcb593e-23f2-43d7-9a52-2e443cc48f61	542	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761586621875-47moo9ok0	\N	\N	\N	programada	aberta	media	LOG - Limpeza de WC e vestiarios masculinos	Limpeza de WC e vestiários masculinos logística.	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:37:02.200311	2025-10-27 14:37:02.200311	\N
5bae3273-71ff-4c42-8987-59faac417c03	543	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.211682	2025-10-27 14:43:48.211682	\N
4e869e35-5893-4fbf-b75d-5961944eadf3	544	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.214533	2025-10-27 14:43:48.214533	\N
e8b415c0-41ee-4c03-b06d-310039212a8c	545	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.21704	2025-10-27 14:43:48.21704	\N
ba8c3d7c-cdfe-49c4-89bf-20c63aee6509	546	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.2199	2025-10-27 14:43:48.2199	\N
5b75a2c3-b9e1-44a7-a9d8-d1e1220238d3	547	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.224139	2025-10-27 14:43:48.224139	\N
608ffcf7-5bdb-4d37-a990-5c1e1bf031e0	548	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.230263	2025-10-27 14:43:48.230263	\N
210b5d8d-b003-4c52-9705-2465b865f179	549	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.233781	2025-10-27 14:43:48.233781	\N
caea6566-f205-4acf-bd75-fdbf8f8558ae	550	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.238302	2025-10-27 14:43:48.238302	\N
fe44b928-bff0-4fa3-baf1-b24e31dab9d0	551	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.243565	2025-10-27 14:43:48.243565	\N
7a781b11-4cd8-49ca-a0ec-149104271c0f	552	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.247046	2025-10-27 14:43:48.247046	\N
615cfb1b-fcaa-44f5-9474-414859ee090f	553	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.251778	2025-10-27 14:43:48.251778	\N
9af178be-188b-4c9a-99ff-b3c50506393e	554	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.258839	2025-10-27 14:43:48.258839	\N
f988528a-9dcd-44a8-9b03-de6344b6ea77	555	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.261133	2025-10-27 14:43:48.261133	\N
f3ca5f11-0f12-442f-8cbd-0bacc95d5e4d	556	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.266118	2025-10-27 14:43:48.266118	\N
05316551-d674-4bfc-8bf9-6a2ffd748da4	557	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.270765	2025-10-27 14:43:48.270765	\N
3807770b-2604-40bb-bc89-23c98ed73c20	558	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.274077	2025-10-27 14:43:48.274077	\N
a9b0a92e-8aa7-4f5b-96ee-5763077d0899	559	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.277846	2025-10-27 14:43:48.277846	\N
9453e3df-a77f-47f6-9b34-3618f11b33c4	560	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.280271	2025-10-27 14:43:48.280271	\N
0c120732-d718-486e-ad24-25647f52395d	561	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.285741	2025-10-27 14:43:48.285741	\N
07bd327f-d78b-48fd-8ecd-0c677779deb9	562	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.289651	2025-10-27 14:43:48.289651	\N
18de17c5-b484-4167-ad75-36bb7407e32c	563	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.292806	2025-10-27 14:43:48.292806	\N
cce2ba6a-e90d-4a01-a3f2-27e9909454bb	564	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.295008	2025-10-27 14:43:48.295008	\N
60bb00de-98fc-464d-8ae0-47d286d696db	565	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.297447	2025-10-27 14:43:48.297447	\N
15076a50-2281-4c73-9239-6335863bacd5	566	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.299599	2025-10-27 14:43:48.299599	\N
1fd02372-c621-4b41-b6c8-d92ea8860bd6	567	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.301786	2025-10-27 14:43:48.301786	\N
82bb9fd2-bb5c-45f4-adc2-1ca54278dd3c	568	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.3054	2025-10-27 14:43:48.3054	\N
316c601b-21ab-45ac-a95a-06cf199d3879	569	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.310267	2025-10-27 14:43:48.310267	\N
75422b4d-32a5-44ae-ac03-f0826e6a22a4	570	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.314007	2025-10-27 14:43:48.314007	\N
25f355df-53bd-4ae4-99ea-609ae74f5b2c	571	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.326782	2025-10-27 14:43:48.326782	\N
d46dfed5-c18f-46fe-ae23-b13d46ba54bf	572	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.333699	2025-10-27 14:43:48.333699	\N
c1d56dea-b577-4fcb-b51a-0842e3f7d138	573	company-admin-default	clean	zone-vest-masc-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587028027-knglqct7g	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários masculinos	Limpeza dos WC e vestiários GM masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:43:48.340243	2025-10-27 14:43:48.340243	\N
5456352a-d190-4bef-9fc5-d71a75c09fb9	574	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.188915	2025-10-27 14:47:06.188915	\N
6d6bcd41-28e4-45b6-80c8-a56e6eb235a8	575	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.191911	2025-10-27 14:47:06.191911	\N
c9e4b495-7dc9-4384-8597-5b927f658d38	576	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.194341	2025-10-27 14:47:06.194341	\N
4fa55d37-42a3-44f7-af4b-57a564d52baf	577	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.196878	2025-10-27 14:47:06.196878	\N
73a4b29d-c29e-4667-88a2-444daa7e50dd	578	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.199164	2025-10-27 14:47:06.199164	\N
0ed41823-791e-4774-a180-51a301757ab8	579	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.201465	2025-10-27 14:47:06.201465	\N
a1a9aac0-c456-4cd5-bb03-4470a051cbfe	580	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.204017	2025-10-27 14:47:06.204017	\N
724a3bbb-39b5-4d53-9e03-eb2ff7c85cc8	581	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.206282	2025-10-27 14:47:06.206282	\N
5aa351e1-c7b9-4044-8796-edebd9cb699d	582	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.208596	2025-10-27 14:47:06.208596	\N
337718b5-1927-4c29-875a-9ca77a0e9f21	583	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.211096	2025-10-27 14:47:06.211096	\N
3b22f963-deea-40ea-b077-e8f743dc8e38	584	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.213317	2025-10-27 14:47:06.213317	\N
7ca3c67e-d9dc-493a-a577-a53f300b8a9f	587	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.22612	2025-10-27 14:47:06.22612	\N
155ebaa7-784f-4ecc-b2e7-2872c418b637	588	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.230365	2025-10-27 14:47:06.230365	\N
a829e923-cda0-446e-bb3c-d2299a11e301	589	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.233016	2025-10-27 14:47:06.233016	\N
85e51170-3744-4078-89f5-b667c57c9caf	590	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.235323	2025-10-27 14:47:06.235323	\N
641b1f77-76bb-4012-b625-7d5798d9ba7d	591	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.238457	2025-10-27 14:47:06.238457	\N
66dccf31-47d8-454c-8c2b-6fd02381cf3a	592	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.240957	2025-10-27 14:47:06.240957	\N
a93cca28-50f1-4413-9ee6-0944369141dc	593	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.243139	2025-10-27 14:47:06.243139	\N
65bdb13b-3213-424e-8b17-72af1cb32f61	594	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.245399	2025-10-27 14:47:06.245399	\N
166a3181-e2b9-4fca-a42c-8fbaf95fedc8	595	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.248206	2025-10-27 14:47:06.248206	\N
dc6a4615-9dc5-4a4e-8b7c-9c73cbe98d15	596	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.250454	2025-10-27 14:47:06.250454	\N
b27fba15-aa49-465b-a9e7-7453535a4857	597	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.252715	2025-10-27 14:47:06.252715	\N
6c1a2414-69ec-4d2b-8a0c-d75c56598cd4	598	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.255064	2025-10-27 14:47:06.255064	\N
efa95955-a4d2-4559-aefb-1df9749fe59c	599	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.257289	2025-10-27 14:47:06.257289	\N
412b681c-1f5f-41db-9b17-c4a1a75d22bd	600	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.25966	2025-10-27 14:47:06.25966	\N
0a26b3f6-eb93-41f8-9d0b-2b5d5b9bb6dd	601	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.261852	2025-10-27 14:47:06.261852	\N
d6f34208-e36b-4e4e-ab61-7986c740e85d	602	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.264038	2025-10-27 14:47:06.264038	\N
8f89029e-6c65-4eb4-9bfb-f26777e2f0c7	603	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.266551	2025-10-27 14:47:06.266551	\N
22ac5c22-119d-45ab-bb45-1ada57cfe213	604	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761587225967-w1l2xw0lm	\N	\N	\N	programada	aberta	media	GM - Limpeza de WC e vestiários feminino 2	Limpeza de WC e vestiários GM feminino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 14:47:06.271049	2025-10-27 14:47:06.271049	\N
68e87da8-b642-442c-bc3d-00c83874dba8	605	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.59481	2025-10-27 15:39:55.59481	\N
d752ffe0-27f3-40f3-9b95-7e8aef476c55	606	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.60011	2025-10-27 15:39:55.60011	\N
f1dd96bd-8d32-48e8-bfa2-faf8ef109068	607	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.602461	2025-10-27 15:39:55.602461	\N
24ab8818-9e81-44f7-89fc-9fb0357a746b	608	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.604729	2025-10-27 15:39:55.604729	\N
e8942684-d9d7-4a30-909e-15ba18c77150	609	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.607061	2025-10-27 15:39:55.607061	\N
0674144c-9e38-4152-a47e-a52d3cc86db6	610	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.609257	2025-10-27 15:39:55.609257	\N
12aacd8c-26a6-4cca-a177-1248b89dfea8	611	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.611793	2025-10-27 15:39:55.611793	\N
82db1bdc-3931-44f0-8dcf-230066bf0215	612	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.613902	2025-10-27 15:39:55.613902	\N
31f96260-05b0-43ee-9040-177d5dd6c56f	613	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.616038	2025-10-27 15:39:55.616038	\N
f1d901e4-692c-4b27-9b8e-e231eb051285	614	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.620693	2025-10-27 15:39:55.620693	\N
8391a5db-b437-4ef1-88de-298669cf8c1f	615	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.623981	2025-10-27 15:39:55.623981	\N
3e728c72-5b69-4bc2-8bab-2903f6bc7e57	616	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.627925	2025-10-27 15:39:55.627925	\N
8b85a423-959c-48b2-a8aa-4eacddad1dec	617	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.630808	2025-10-27 15:39:55.630808	\N
e98bc38b-50d2-458f-b7a2-f6c33cb614cc	618	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.632885	2025-10-27 15:39:55.632885	\N
7ed56642-3919-4a27-9b24-4699500ccf11	619	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.634967	2025-10-27 15:39:55.634967	\N
84b7ecfa-580e-4cc1-af7d-1e70ed89d385	620	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.637104	2025-10-27 15:39:55.637104	\N
d82c4a60-8f1b-447d-b190-180332a283a3	621	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.639316	2025-10-27 15:39:55.639316	\N
d95370c3-ddf0-4fd3-93cc-a5246066eab5	622	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.641613	2025-10-27 15:39:55.641613	\N
d2512e00-7b66-4534-aecc-8d478535fc63	623	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.644003	2025-10-27 15:39:55.644003	\N
f0ca5d85-0920-4759-be0b-84fce8074ff8	624	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.646702	2025-10-27 15:39:55.646702	\N
8d34e423-9d67-4ce9-a7eb-db63033e7396	625	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.649681	2025-10-27 15:39:55.649681	\N
63582f54-0332-4868-90ec-4e8793aa7d85	626	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.652189	2025-10-27 15:39:55.652189	\N
cc26e771-0001-4032-a2f7-c06b1255c596	627	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.654466	2025-10-27 15:39:55.654466	\N
b70ea5e5-1743-4b5c-a589-2c5bd7dd43f4	628	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.656886	2025-10-27 15:39:55.656886	\N
63a073f4-8c46-4956-a785-244ee6ceb004	629	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.65902	2025-10-27 15:39:55.65902	\N
855b8a30-a648-466d-8f81-bc0bde228082	630	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.661144	2025-10-27 15:39:55.661144	\N
e8662817-3cb2-4b5b-bc16-2e480c73b5a7	631	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.663311	2025-10-27 15:39:55.663311	\N
207cd8a9-ec8d-495a-9782-509552742204	632	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.665464	2025-10-27 15:39:55.665464	\N
b7bc6db0-e263-448b-b35c-2d465772dc20	633	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.667775	2025-10-27 15:39:55.667775	\N
d701f07c-cd7f-40be-9228-2777c17129d7	634	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.671932	2025-10-27 15:39:55.671932	\N
d94c1b2d-1464-4706-9850-155f0208edf8	635	company-admin-default	clean	zone-vest-masc-02	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590395353-n4e6pddup	\N	\N	\N	programada	aberta	media	Limpeza de WC e vestiários masculino 2	Limpeza dos WC e vestiario masculino 2 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:39:55.675716	2025-10-27 15:39:55.675716	\N
b2dfabaf-5247-40b3-ad9b-cbb441d0022a	636	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.840184	2025-10-27 15:42:25.840184	\N
c213dd21-2d0b-4d48-ad3b-c2399f7d9fc6	637	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.843044	2025-10-27 15:42:25.843044	\N
5bf30c45-23c9-4080-8849-c32a30f3828c	638	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.84518	2025-10-27 15:42:25.84518	\N
5598fb8f-0020-491d-8149-9e69f3fb4cd9	639	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.847303	2025-10-27 15:42:25.847303	\N
64b61be7-0bb9-4f1d-8cdc-ba60867424ee	640	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.849607	2025-10-27 15:42:25.849607	\N
db625542-0cf2-48dd-8b74-d6c630738ba5	641	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.851694	2025-10-27 15:42:25.851694	\N
4adaf79a-11da-4dcc-915a-c65e1b66a38b	642	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.853795	2025-10-27 15:42:25.853795	\N
eebc97f5-5039-4666-8f18-2c9cd4b7f5fb	643	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.856026	2025-10-27 15:42:25.856026	\N
08d5a625-e138-4be5-b70a-3721b32349c6	644	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.858253	2025-10-27 15:42:25.858253	\N
f9ad3606-2d76-4e32-b545-2ea68a2eedf3	645	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.860293	2025-10-27 15:42:25.860293	\N
349715b3-d989-4308-b216-9ca4deb97d1a	646	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.862716	2025-10-27 15:42:25.862716	\N
70594036-e9ff-402a-a469-9b5cfbcba14e	647	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.864745	2025-10-27 15:42:25.864745	\N
1fe77500-83ae-47eb-9a43-37af1b1efce4	648	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.867001	2025-10-27 15:42:25.867001	\N
634028a3-271d-4727-90a2-e80579601706	649	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.869225	2025-10-27 15:42:25.869225	\N
b270965e-c859-4468-bba4-6404646b0c4f	650	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.871246	2025-10-27 15:42:25.871246	\N
0b9aeba6-3758-4e9f-a020-223e30e36c16	651	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.873292	2025-10-27 15:42:25.873292	\N
f7cc1cd5-d512-492d-bf74-ba41e8330ec0	652	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.875597	2025-10-27 15:42:25.875597	\N
67a68213-b41e-49fd-aae3-84257169aa87	653	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.877894	2025-10-27 15:42:25.877894	\N
aceea1c0-bc37-4608-99cd-d96499a111f2	654	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.880425	2025-10-27 15:42:25.880425	\N
2651304a-8e26-4cec-8697-dbdc1f82bc91	655	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.882575	2025-10-27 15:42:25.882575	\N
0461b024-6b7b-4f90-8b89-aec450604aeb	656	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.88471	2025-10-27 15:42:25.88471	\N
4ac14576-5483-468d-97f4-0070e690e14a	657	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.886825	2025-10-27 15:42:25.886825	\N
81064eb3-3269-4780-972b-db5a3077df46	658	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.88901	2025-10-27 15:42:25.88901	\N
236fb7ac-9fe1-4f7d-91f6-72b48739bf9e	659	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.891431	2025-10-27 15:42:25.891431	\N
8ea99d2a-e796-4033-aaf0-7fe325beb0e2	660	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.894576	2025-10-27 15:42:25.894576	\N
d8ad3aa4-4c6f-4906-a246-58e622e07271	661	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.896593	2025-10-27 15:42:25.896593	\N
c65b69ab-967b-429d-9fdb-9a5d3c288321	662	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.89862	2025-10-27 15:42:25.89862	\N
57d2ed37-dfa5-40ba-9841-da5f1e92fc66	663	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.900658	2025-10-27 15:42:25.900658	\N
e1cd25bd-d373-4906-b190-4462071ef9f7	664	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.902755	2025-10-27 15:42:25.902755	\N
3098acac-06b3-4747-9ad1-a6050eb20c17	665	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.905033	2025-10-27 15:42:25.905033	\N
7637e55e-a707-4d80-b049-768543b07834	666	company-admin-default	clean	zone-vest-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590545608-fucf3mxn5	\N	\N	\N	programada	aberta	media	Limpeza vestiario e WC feminino	Limpeza de vestiário feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:42:25.907058	2025-10-27 15:42:25.907058	\N
9b152f81-c0e9-4685-a1d6-eb238938cab1	668	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.068727	2025-10-27 15:45:18.068727	\N
5ce215a1-e534-4eef-a3d6-6bec5261bf4c	669	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.071155	2025-10-27 15:45:18.071155	\N
3c242a8a-e9c9-40b3-9044-8613da0de48e	670	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.073426	2025-10-27 15:45:18.073426	\N
44b69311-88c3-4ac2-8fa3-6273c623c293	671	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.075757	2025-10-27 15:45:18.075757	\N
21ac17af-1950-48a6-a5a4-ceed6b60227e	672	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.077866	2025-10-27 15:45:18.077866	\N
625b15ce-7c37-4fd7-b1ca-55adcb63b588	673	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.080168	2025-10-27 15:45:18.080168	\N
d73b8f75-8961-4f36-b0ec-ccca4d317a1c	674	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.08243	2025-10-27 15:45:18.08243	\N
42e5b310-a780-4586-bc6c-7047b872fce8	675	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.084559	2025-10-27 15:45:18.084559	\N
21c05281-bcd5-4523-bc2c-84f05a6c06bc	676	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.086683	2025-10-27 15:45:18.086683	\N
c6c3c0cc-dbab-40c1-8d54-903a42448f25	677	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.089053	2025-10-27 15:45:18.089053	\N
b971ba0b-b194-48f9-8fb8-affccd7a3ea2	678	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.091141	2025-10-27 15:45:18.091141	\N
7b2fd548-b79f-4d50-b89b-63a575ca4f9c	679	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.09318	2025-10-27 15:45:18.09318	\N
1eec5e96-6041-45aa-98a3-acd81f0730c4	680	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.095425	2025-10-27 15:45:18.095425	\N
63349a66-2799-416c-8279-56b1b15bfc42	681	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.097443	2025-10-27 15:45:18.097443	\N
f8430807-599c-4a7e-9721-593156c525b8	682	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.09948	2025-10-27 15:45:18.09948	\N
4865af6c-5981-456e-9243-df6ed44483cc	683	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.101764	2025-10-27 15:45:18.101764	\N
75e15246-2250-4370-a4a9-1bed76bcc351	684	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.103873	2025-10-27 15:45:18.103873	\N
24982d13-4e7e-4a9b-8389-13eb2cd35365	685	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.10656	2025-10-27 15:45:18.10656	\N
7743b7a0-e737-42f3-ace7-0ceb639db77f	686	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.108894	2025-10-27 15:45:18.108894	\N
f7abe3ee-51a7-4850-b81b-6c478d97f0c6	687	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.11097	2025-10-27 15:45:18.11097	\N
3ac95796-4cb7-4fde-a3ca-5c218bb4ca9c	688	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.113408	2025-10-27 15:45:18.113408	\N
ca559723-a99c-4ca8-8470-f4831b446606	689	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.116414	2025-10-27 15:45:18.116414	\N
be20bff4-9df1-402e-bbac-c98ad38dc4af	690	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.118486	2025-10-27 15:45:18.118486	\N
76c21d8e-01f2-4fa3-a244-c016b182b23f	691	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.120712	2025-10-27 15:45:18.120712	\N
97630c92-09a2-4392-b833-6fb00beca4fd	692	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.122911	2025-10-27 15:45:18.122911	\N
db141065-af1b-465f-81a4-904122b21164	693	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.125034	2025-10-27 15:45:18.125034	\N
76f4acf3-0f54-47e0-8f42-c0054df8586c	694	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.127265	2025-10-27 15:45:18.127265	\N
01f084f5-f7c5-4a1f-90e8-b45133038d59	695	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.129413	2025-10-27 15:45:18.129413	\N
c0894427-ae7f-4fa8-bb53-fbb9fa045d32	696	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.131509	2025-10-27 15:45:18.131509	\N
49cf9ca1-0d59-44b5-a0e2-270f4a2e3a21	697	company-admin-default	clean	zone-adm-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590717804-8eo1xtcge	\N	\N	\N	programada	aberta	media	Limpeza WC RH masculinol	Limpeza de WC masculino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:45:18.133753	2025-10-27 15:45:18.133753	\N
09033838-1a93-41d8-bbc3-966bacd3b755	698	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.128526	2025-10-27 15:46:15.128526	\N
d96ca3eb-0f2a-48ea-a3f8-647c077502ae	699	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.131459	2025-10-27 15:46:15.131459	\N
0c70e5d2-0ef0-4a65-b3cd-e12f554b12c3	700	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.133822	2025-10-27 15:46:15.133822	\N
8ea49715-3110-46c6-bbc2-1b774c5c10d3	701	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.136109	2025-10-27 15:46:15.136109	\N
2e6d9e36-8330-4791-8c9c-f965064b9d61	702	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.138443	2025-10-27 15:46:15.138443	\N
4f16a030-2310-495e-9bee-83e38379a38f	703	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.140703	2025-10-27 15:46:15.140703	\N
35741a7f-b04c-4c08-8299-dde0071c7692	704	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.14339	2025-10-27 15:46:15.14339	\N
5c395d7f-cb3c-4e97-abb4-f6e2daab69b1	705	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.145616	2025-10-27 15:46:15.145616	\N
6f83aa59-e09e-42f4-a0de-25827d7cf7ac	706	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.147716	2025-10-27 15:46:15.147716	\N
b70244b5-ea4d-4b11-8653-88f3a4182ab5	707	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.149816	2025-10-27 15:46:15.149816	\N
61052f68-b914-428c-8015-4ea36e045f7f	708	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.151955	2025-10-27 15:46:15.151955	\N
109d441a-14b7-4f70-a1ec-b9a8ab38429b	709	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.154211	2025-10-27 15:46:15.154211	\N
019f0c65-c6f1-4ef8-8c2a-caa13edad43d	710	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.156478	2025-10-27 15:46:15.156478	\N
deb0409d-0497-4ed9-8fa1-4e987f402e18	711	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.158787	2025-10-27 15:46:15.158787	\N
a5eb3022-f977-4546-9641-23718d2e4338	712	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.161094	2025-10-27 15:46:15.161094	\N
4d2fbfd6-a690-481a-85e5-956c82d8f456	713	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.163337	2025-10-27 15:46:15.163337	\N
17f7e4e4-8edf-4d7a-965a-a6f9e739ed6a	714	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.165545	2025-10-27 15:46:15.165545	\N
09f26e0b-ff0c-4b01-a6a4-37aa26d436b4	715	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.168056	2025-10-27 15:46:15.168056	\N
bcf129fb-c26d-4384-a0d4-f14b5b9ba204	716	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.17026	2025-10-27 15:46:15.17026	\N
f0156208-8ddc-4e30-9079-5c6ccc4144ae	717	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.172546	2025-10-27 15:46:15.172546	\N
4278259c-ebe7-406f-a37e-9d6564e31e43	718	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.174915	2025-10-27 15:46:15.174915	\N
88b42dda-8507-41b0-acb4-3b1e4ca023fc	719	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.177249	2025-10-27 15:46:15.177249	\N
4a178ef4-2616-4a70-af98-d49a29e565c5	720	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.1798	2025-10-27 15:46:15.1798	\N
74719bc2-4c29-4354-8f54-1cad0b3e62e7	721	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.182172	2025-10-27 15:46:15.182172	\N
9255e72d-bb8a-4523-8ea6-01f5a779cb73	722	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.184442	2025-10-27 15:46:15.184442	\N
45de5cb7-2301-4ade-8a0e-1b3033f5cd1b	723	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.186699	2025-10-27 15:46:15.186699	\N
596ac6dc-d90b-4920-bcc2-e2bcf1b35727	724	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.188907	2025-10-27 15:46:15.188907	\N
a72480a7-e68f-4f21-8dca-9a44247a34aa	725	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.191504	2025-10-27 15:46:15.191504	\N
05139575-8b66-4965-af7b-9854689f471f	726	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.194	2025-10-27 15:46:15.194	\N
d3bf5f74-98af-4e14-bff9-f3b6791ff309	728	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	aberta	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:46:15.198481	2025-10-27 15:46:15.198481	\N
faa85bb3-c07b-43b9-bf4d-abe6d41dc563	729	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.392388	2025-10-27 15:48:03.392388	\N
94840002-3ef9-4132-a9b3-aab7ae6b67d4	730	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.395044	2025-10-27 15:48:03.395044	\N
8c3247f0-efd1-4a0f-bd5b-3eeb4491390b	731	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.397207	2025-10-27 15:48:03.397207	\N
107082c4-195c-471b-8f04-8250a2db65a7	732	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.399353	2025-10-27 15:48:03.399353	\N
f4f3dafc-a56d-4c88-bc75-2ec06507dee6	733	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.401545	2025-10-27 15:48:03.401545	\N
9be39ab6-6129-4772-b090-5aa85b0ff942	734	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.403913	2025-10-27 15:48:03.403913	\N
04dfaeb2-b25c-42ae-a9df-072c531d06a4	735	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.40607	2025-10-27 15:48:03.40607	\N
5a8025be-5126-45cd-bcd6-68d4eb21ec84	736	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.408091	2025-10-27 15:48:03.408091	\N
4ca7ec82-1e9f-4a3a-b702-503aa8465777	737	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.410119	2025-10-27 15:48:03.410119	\N
ba9d2f2c-4a64-4ffe-b91f-43818785ace2	738	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.412171	2025-10-27 15:48:03.412171	\N
f61c09ab-58f9-440c-bf51-5d4cce7335e7	739	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.414462	2025-10-27 15:48:03.414462	\N
2eae3f01-9eb7-44a9-a973-bbb223b85f0d	740	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.416487	2025-10-27 15:48:03.416487	\N
e1207b2e-e38b-4180-9f0c-d254a467537f	741	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.418502	2025-10-27 15:48:03.418502	\N
b90e15fe-b9bd-48bd-a2c3-b55999929f28	742	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.421027	2025-10-27 15:48:03.421027	\N
087ebd97-cef3-42a6-b374-5830812c8da1	743	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.423325	2025-10-27 15:48:03.423325	\N
39cd67e8-d4a5-4feb-be9b-f9c899283643	744	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.42546	2025-10-27 15:48:03.42546	\N
ca8cf76d-f819-4349-bb01-c1189e91800c	745	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.427704	2025-10-27 15:48:03.427704	\N
211d13cc-b7b3-4639-b710-12267fbfa473	746	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.42977	2025-10-27 15:48:03.42977	\N
2e20e261-affc-4086-bc05-cf07b67959ca	747	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.431786	2025-10-27 15:48:03.431786	\N
444b8244-bf74-4989-91ad-44875c5e0a78	748	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.43396	2025-10-27 15:48:03.43396	\N
adf815cb-1b18-4366-a899-0b299d500650	749	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.435979	2025-10-27 15:48:03.435979	\N
e52e2f80-f4a8-4363-80d9-168e46e97e4e	750	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.438285	2025-10-27 15:48:03.438285	\N
96fa0051-a04a-4f83-bad0-9671c2fdc90a	751	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.440391	2025-10-27 15:48:03.440391	\N
53cffa36-3fc7-4274-99a3-799475ae764a	752	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.442427	2025-10-27 15:48:03.442427	\N
a0f859d2-2911-481b-b2b3-406a214efbfe	753	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.444455	2025-10-27 15:48:03.444455	\N
13149886-78d5-4242-a843-38d98bfbf2fe	754	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.446694	2025-10-27 15:48:03.446694	\N
3acbdf22-b456-44d4-a597-1d8c4ff895ec	755	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.448801	2025-10-27 15:48:03.448801	\N
23493c45-d7bc-4612-88d3-0a8d42dcb41e	756	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.450947	2025-10-27 15:48:03.450947	\N
2a93796f-e296-4209-a4e2-a317e2730a6e	757	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.452958	2025-10-27 15:48:03.452958	\N
0e665545-e24b-4ed5-b1a7-eafcc7d51e8a	758	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.454989	2025-10-27 15:48:03.454989	\N
d6e860c4-ce2a-4c4a-b758-bcac24223494	759	company-admin-default	clean	zone-adm-fem-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590883222-ctje5t7ze	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza WC e vestiário feminino	Corporativo - limpeza de WC feminino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:48:03.457084	2025-10-27 15:48:03.457084	\N
763faace-7a9b-4ad4-b354-a0b43a32ef18	760	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.501716	2025-10-27 15:49:29.501716	\N
7b01564e-5551-42ea-a42f-29b4d26d35bb	761	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.504312	2025-10-27 15:49:29.504312	\N
4f49f76e-09fc-41e4-bf86-1cce027a4fdd	762	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.506657	2025-10-27 15:49:29.506657	\N
6880adc6-dd8f-488f-aedf-6c7028cf698c	763	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.508838	2025-10-27 15:49:29.508838	\N
84ba0dfb-a1b3-45f8-bb08-177871940dd0	764	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.511188	2025-10-27 15:49:29.511188	\N
0a2e035d-a86f-4856-9ea5-ca0fc6ac67ba	765	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.513524	2025-10-27 15:49:29.513524	\N
be9fcf10-da7c-4724-944e-73aafac436c2	766	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.515673	2025-10-27 15:49:29.515673	\N
6173cd63-2356-4f26-be75-6e235aeea300	767	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.517688	2025-10-27 15:49:29.517688	\N
df31c0e1-39e7-4b92-b531-9b8d8be026f4	768	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.519949	2025-10-27 15:49:29.519949	\N
fd554f7e-ab85-48e5-afdc-d6efa8a01dd1	769	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.52197	2025-10-27 15:49:29.52197	\N
f119cf99-a89d-4777-be1e-77e45973c164	770	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.524051	2025-10-27 15:49:29.524051	\N
02aede51-a237-4011-affa-92d34d70fdbe	771	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.526385	2025-10-27 15:49:29.526385	\N
a153248d-1949-4ae7-bbcd-01ecb701846c	772	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.528509	2025-10-27 15:49:29.528509	\N
88e6101a-d3b3-4ad4-b832-acb66c7ed178	773	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.530593	2025-10-27 15:49:29.530593	\N
b8006797-cbbe-45b6-98b3-823b039bb7d6	774	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.533005	2025-10-27 15:49:29.533005	\N
f78fd5a4-5013-4a8f-8d75-7f02ff2b69f2	775	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.535171	2025-10-27 15:49:29.535171	\N
1f12fc72-a64b-4167-9516-82f714ef7267	776	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.537302	2025-10-27 15:49:29.537302	\N
58ee6236-81ad-4a4d-9daa-a309348164cd	777	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.539835	2025-10-27 15:49:29.539835	\N
3d24688e-6918-480e-9572-d4b4b99d2002	778	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.541871	2025-10-27 15:49:29.541871	\N
265c09a7-6636-4592-8b1a-2bebc518b916	779	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.54393	2025-10-27 15:49:29.54393	\N
b9824808-dcbc-475a-b3c6-a351173f52e5	780	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.546404	2025-10-27 15:49:29.546404	\N
ae42e09e-edae-4e02-8da4-7b9f450b20d3	781	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.54846	2025-10-27 15:49:29.54846	\N
3474a61d-fd3e-4d88-8666-8a4676113a31	782	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.550534	2025-10-27 15:49:29.550534	\N
2cdf423b-4e16-4e0b-a92a-462c29127269	783	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.552821	2025-10-27 15:49:29.552821	\N
fe4dfdc9-a0f8-4adb-aba7-59f9a4a33dcf	784	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.554843	2025-10-27 15:49:29.554843	\N
cc49f389-50bc-42c0-a486-8a956779a013	785	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.556897	2025-10-27 15:49:29.556897	\N
1e731c66-73cf-4007-9860-86f466a026ff	786	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.559274	2025-10-27 15:49:29.559274	\N
5ac1f81a-926f-4261-965a-e6bc4f848f4f	995	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.990394	2025-10-27 16:00:37.990394	\N
f5aa584a-5dfd-4759-b2d9-15811455f6a9	787	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.561485	2025-10-27 15:49:29.561485	\N
e7d1fb9f-2ea0-4872-853f-9465a02c3c73	788	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.563544	2025-10-27 15:49:29.563544	\N
a78621cb-f514-435c-8fc9-e4fe13a4fa9b	789	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.565683	2025-10-27 15:49:29.565683	\N
fe3224f8-b286-4f57-a1c2-fdf4dfe90529	790	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590969350-suyuqoky7	\N	\N	\N	programada	aberta	media	Corporativo - Limpeza de WC e vestiário masculino	Corporativo - limpeza de WC e vestiário Masculino	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:49:29.567946	2025-10-27 15:49:29.567946	\N
77a5a3e5-0511-42f8-9452-fd0cf32d6929	791	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.30463	2025-10-27 15:51:37.30463	\N
8ab9bcad-adca-45ec-9040-221339a03d87	792	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.307706	2025-10-27 15:51:37.307706	\N
78686916-56d5-44cb-83f8-dff606ede188	793	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.310076	2025-10-27 15:51:37.310076	\N
7eebd20c-0eb0-4890-8ef4-54943703e84b	794	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.312257	2025-10-27 15:51:37.312257	\N
8d0bf207-35e4-4dfc-b065-0ec8e53ab5b1	795	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.314655	2025-10-27 15:51:37.314655	\N
1993a4bc-1a5e-4601-874f-6bb30e4cb75f	796	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.316815	2025-10-27 15:51:37.316815	\N
42424d5d-1b52-4435-92e7-ca486d81419e	797	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.319088	2025-10-27 15:51:37.319088	\N
c9571a42-b7bb-4bc5-8028-8caafd27a3d6	798	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.321389	2025-10-27 15:51:37.321389	\N
db44fcd9-8b72-41fa-af4e-a38b17fc02ac	799	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.323433	2025-10-27 15:51:37.323433	\N
1bf932af-ab17-42a0-a2ca-12fe3d57ec11	800	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.325482	2025-10-27 15:51:37.325482	\N
42b745ea-eb12-41a1-ae0d-836a9719c7e8	801	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.327537	2025-10-27 15:51:37.327537	\N
cbed29f4-76f5-46bf-923b-1546addff2d7	802	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.32958	2025-10-27 15:51:37.32958	\N
28c5d60e-9b12-4359-93f1-253fed622516	803	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.331723	2025-10-27 15:51:37.331723	\N
bee20e77-2efc-4c0c-854c-324863325d3f	804	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.33402	2025-10-27 15:51:37.33402	\N
26a1fb24-f9b6-471f-b222-d0c9a6d90bae	805	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.336133	2025-10-27 15:51:37.336133	\N
6d1fc9c0-c85a-40d0-ae04-91f9eb103fd0	806	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.338226	2025-10-27 15:51:37.338226	\N
9c211c0f-ec59-426f-ba05-ce706b333cef	807	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.3403	2025-10-27 15:51:37.3403	\N
54cca158-b743-4a9c-a2a6-46f80df28a59	808	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.342376	2025-10-27 15:51:37.342376	\N
42b0def3-872c-4fb1-929a-f3c97fb6e185	809	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.344713	2025-10-27 15:51:37.344713	\N
735548db-c27b-4f7f-be0d-0a5990e8f34a	810	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.346757	2025-10-27 15:51:37.346757	\N
6fb86bfe-a11b-41fa-9fd5-f1c510b82994	811	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.348819	2025-10-27 15:51:37.348819	\N
23f2c5ab-4bf4-4335-bae4-bc036815ec42	812	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.350858	2025-10-27 15:51:37.350858	\N
6e0d8590-6c5d-4b1f-9cec-0763112caafb	813	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.352921	2025-10-27 15:51:37.352921	\N
b126fc98-4f84-46b4-9d7c-3f616aa18301	814	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.355168	2025-10-27 15:51:37.355168	\N
6fdd538e-5a24-47c2-80ab-7fc40afbe94a	815	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.357553	2025-10-27 15:51:37.357553	\N
8116168a-c346-4223-a1cc-a43b8a4b3e13	816	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.359616	2025-10-27 15:51:37.359616	\N
c838f6d6-9087-4d5e-987e-89cc9572c43f	817	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.361654	2025-10-27 15:51:37.361654	\N
0f6fe83d-d66f-4bd4-aa2b-e167ae95dd7d	818	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.363744	2025-10-27 15:51:37.363744	\N
2beb0893-5812-4d9b-be4f-8c5e41ab72ce	819	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.365795	2025-10-27 15:51:37.365795	\N
0dbc2bdd-4f4c-45ce-bbdc-5940db3d6bdb	820	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.368113	2025-10-27 15:51:37.368113	\N
e2a3144f-bafe-4a14-9c91-1aa35eb3bfb2	821	company-admin-default	clean	zone-adm-masc-corp	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591097102-8kf81xk7d	\N	\N	\N	programada	aberta	media	Corporativo - WC extra masculino	Limpeza WC extra masculino corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:51:37.370206	2025-10-27 15:51:37.370206	\N
c6b9c721-177c-48a0-977b-2688261477ce	822	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.516265	2025-10-27 15:53:17.516265	\N
bbfbfef8-263f-4feb-97f4-6cfbbb52ccea	823	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.518913	2025-10-27 15:53:17.518913	\N
7e078704-5c9c-4ceb-8f52-51cba23794cb	824	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.521071	2025-10-27 15:53:17.521071	\N
69d64124-859f-4a25-a7a3-f06a6e4c4674	825	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.523427	2025-10-27 15:53:17.523427	\N
e5099485-5e7e-437d-b501-d0a185319de4	826	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.525773	2025-10-27 15:53:17.525773	\N
9cd7af89-de29-4e84-b847-56d93b12c059	827	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.53062	2025-10-27 15:53:17.53062	\N
3a10e709-35c8-4058-a841-3f7a183369aa	828	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.532795	2025-10-27 15:53:17.532795	\N
0377ed8a-e07d-4131-bf3b-ef428e67376f	829	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.53489	2025-10-27 15:53:17.53489	\N
94410e85-e9aa-44c1-ae59-9bf247231c72	830	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.53697	2025-10-27 15:53:17.53697	\N
99221ebc-abb0-4f83-9124-5d0318d5a298	831	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.539163	2025-10-27 15:53:17.539163	\N
ee3c9dac-3b79-466c-b788-573de8832d7c	832	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.54152	2025-10-27 15:53:17.54152	\N
801aecc8-899b-427b-9adc-91eb2e11b2b5	833	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.543706	2025-10-27 15:53:17.543706	\N
ebbe9fce-f85d-44eb-99ae-9f0f81383ffc	834	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.545855	2025-10-27 15:53:17.545855	\N
1abd50fc-3734-46cb-8024-fee89515648c	835	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.547889	2025-10-27 15:53:17.547889	\N
251e04cf-2661-4567-be09-7f1b009d6650	836	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.549941	2025-10-27 15:53:17.549941	\N
1c2dde9b-2c41-4719-975c-beb033a60d40	837	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.552295	2025-10-27 15:53:17.552295	\N
2717094f-c181-438e-b1cd-b05a177ce356	838	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.55445	2025-10-27 15:53:17.55445	\N
16a158b1-e9d3-469b-853b-eef1b7102842	839	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.556507	2025-10-27 15:53:17.556507	\N
022c4bb2-4119-4e79-9f83-33302ac18c69	840	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.55861	2025-10-27 15:53:17.55861	\N
11cde01a-a49b-4e3f-9c5b-94f8041bacfc	841	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.560691	2025-10-27 15:53:17.560691	\N
affb6fa5-d01c-44b3-a654-3f2594a790ea	842	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.562872	2025-10-27 15:53:17.562872	\N
8f6fdfe7-67e5-4a36-8513-381a96f76c6e	843	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.56509	2025-10-27 15:53:17.56509	\N
855df4a3-f8ac-4e9a-8456-7f93359a923b	844	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.567181	2025-10-27 15:53:17.567181	\N
9351a43c-9516-4e97-8443-0f0b7907986f	845	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.569309	2025-10-27 15:53:17.569309	\N
78b476a4-9e62-4fb8-a0cb-2fd35cef4010	846	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.571601	2025-10-27 15:53:17.571601	\N
f624de10-aae4-48e9-9b1a-52914af40255	847	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.573683	2025-10-27 15:53:17.573683	\N
494f1d36-3ebf-4e91-a7e5-3dadc337ac6e	848	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.576127	2025-10-27 15:53:17.576127	\N
b62f5616-7ce4-46a4-96b0-b5bf57e4e58d	849	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.578242	2025-10-27 15:53:17.578242	\N
4470c040-a922-483e-a498-1cde096f7468	850	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.580354	2025-10-27 15:53:17.580354	\N
fc069353-97e9-4298-a036-ccc23f4777d4	851	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.58243	2025-10-27 15:53:17.58243	\N
f787f7de-4494-43e4-b930-1b4506ac9092	852	company-admin-default	clean	zone-adm-acess-01	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591197326-qzu06d0gn	\N	\N	\N	programada	aberta	media	Corporativo - WC acessível 	Limpeza de WC acessível corporativo	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:53:17.584545	2025-10-27 15:53:17.584545	\N
b201fb2b-f542-4718-9b60-245280c8cb85	853	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.408287	2025-10-27 15:55:02.408287	\N
9eb2e9b6-ebed-4de0-b3cc-1c8c998dff03	854	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.410891	2025-10-27 15:55:02.410891	\N
dece9528-bdc3-4a30-804f-af5535008d86	855	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.413295	2025-10-27 15:55:02.413295	\N
850e3ac1-6a4f-4eb5-bd86-171551d135db	856	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.415438	2025-10-27 15:55:02.415438	\N
134a1abb-3e0c-4389-acd7-ac095d322afc	857	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.417565	2025-10-27 15:55:02.417565	\N
14660493-0d9f-4871-afe4-e82705efe994	858	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.419908	2025-10-27 15:55:02.419908	\N
661651a2-2ee2-4e2f-b5b9-a7e4cef26ade	859	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.422191	2025-10-27 15:55:02.422191	\N
fbaeeed1-eb6b-4109-b4e0-6361fa1eb122	860	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.42425	2025-10-27 15:55:02.42425	\N
a55de5f2-4305-4c73-8d91-f5d300acd966	861	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.426512	2025-10-27 15:55:02.426512	\N
5c5c80d6-9fd9-4f72-b14c-e0aa4246ccf9	862	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.428582	2025-10-27 15:55:02.428582	\N
11a8d1c7-7290-42ce-b039-09de05c92262	863	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.430662	2025-10-27 15:55:02.430662	\N
59233adc-be94-4918-b0da-ad542d1c96b7	864	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.432933	2025-10-27 15:55:02.432933	\N
85744b13-413d-415b-9830-c981399b51ac	865	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.43506	2025-10-27 15:55:02.43506	\N
6f749de3-9d88-441a-add9-e085aaf0c6de	866	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.437116	2025-10-27 15:55:02.437116	\N
4b150e5b-d438-4636-a9b7-5ae6421a8a42	867	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.439405	2025-10-27 15:55:02.439405	\N
c17d3e98-e59b-45c9-a3ea-a90f1cde4fa6	868	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.441478	2025-10-27 15:55:02.441478	\N
198726b2-2192-4242-9a45-4a3152333c9c	869	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.443558	2025-10-27 15:55:02.443558	\N
2491a768-9f79-48d6-8acc-ab20e0d64884	870	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.446069	2025-10-27 15:55:02.446069	\N
9b6394e0-1e05-4567-ac3d-0f6fedae31f1	871	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.448207	2025-10-27 15:55:02.448207	\N
aae89d8a-f81b-4381-876a-b5a568d64466	872	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.450423	2025-10-27 15:55:02.450423	\N
1338152a-d044-41af-a0a8-702432111d65	873	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.452893	2025-10-27 15:55:02.452893	\N
f3c82080-2b2f-4183-a4fc-f226994553e2	874	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.454994	2025-10-27 15:55:02.454994	\N
87fb1c14-93a1-4a56-833c-6f5a8bf84c23	875	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.457175	2025-10-27 15:55:02.457175	\N
78e66894-fb97-4eca-a830-708f4333a0e9	876	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.459367	2025-10-27 15:55:02.459367	\N
49e33f7c-50eb-4ba9-aad7-d24a7f64f0a2	877	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.461474	2025-10-27 15:55:02.461474	\N
1d0a905c-872d-4200-88ce-a5ddf8688f35	878	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.463704	2025-10-27 15:55:02.463704	\N
6373fe3b-f76d-4e11-8f00-2edb8a2728ab	879	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.465839	2025-10-27 15:55:02.465839	\N
ae65cfe9-461a-4077-93c7-e4ac08c10c02	880	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.467892	2025-10-27 15:55:02.467892	\N
eddc6afd-dc75-4963-85b8-4512c441acf8	881	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.470189	2025-10-27 15:55:02.470189	\N
de370b85-c1f6-4187-8d7b-64b6cf78a95c	882	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.483136	2025-10-27 15:55:02.483136	\N
30183625-4a3e-4674-b2ca-5adf1bced482	883	company-admin-default	clean	zone-adm-unissex	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591301979-gci0j116a	\N	\N	\N	programada	aberta	media	Recepção - Limpeza  WC	Limpeza de WC recepção 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:55:02.49596	2025-10-27 15:55:02.49596	\N
a6574aae-7ce9-4432-8fbc-aa98862c2361	884	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.386419	2025-10-27 15:56:48.386419	\N
c73b2edc-d539-4cec-8e57-71645d447747	885	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.389898	2025-10-27 15:56:48.389898	\N
53196b78-79e5-4e69-b1d9-9c2221737b10	886	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.392231	2025-10-27 15:56:48.392231	\N
7ff3ccd3-6ad2-450f-9fc0-c4274c6e7ec6	887	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.394388	2025-10-27 15:56:48.394388	\N
58f5c749-585b-4c88-bdab-fbfd873d80e8	888	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.396536	2025-10-27 15:56:48.396536	\N
07d735ad-e812-4829-8053-47784b5305e3	889	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.398709	2025-10-27 15:56:48.398709	\N
cd97c93a-3754-4512-90de-2cb7ea95fc44	890	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.401221	2025-10-27 15:56:48.401221	\N
0d2e13d3-2387-44bf-a33b-742d6bfd224e	891	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.403451	2025-10-27 15:56:48.403451	\N
ac849466-aa82-4a01-9184-9254fc64150a	892	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.405551	2025-10-27 15:56:48.405551	\N
36058831-285b-45e6-b22a-8ef11f6cb232	893	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.40762	2025-10-27 15:56:48.40762	\N
47338c5c-abeb-4ef9-b339-31274f4744b2	894	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.409891	2025-10-27 15:56:48.409891	\N
dad12de2-80e9-4436-bb05-341ad1a87dc2	895	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.412259	2025-10-27 15:56:48.412259	\N
d82ea769-c7ed-4e3e-951c-a2ad263e60ba	896	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.414476	2025-10-27 15:56:48.414476	\N
039e1eae-4f0b-4a67-95d0-966f5d611e6b	897	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.416543	2025-10-27 15:56:48.416543	\N
46fd96c4-8dae-4073-93a5-e3fd7c6b79e3	898	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.418739	2025-10-27 15:56:48.418739	\N
be293450-2529-4632-af25-a5e71b2895ef	899	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.421075	2025-10-27 15:56:48.421075	\N
5e99bbf7-57bd-4e2c-904e-979dd56cc635	900	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.423218	2025-10-27 15:56:48.423218	\N
8acb0820-cdae-47b1-bb20-1a04fec7c47f	901	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.425574	2025-10-27 15:56:48.425574	\N
5f385fe1-420d-4645-bf93-838461ad31f6	902	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.427667	2025-10-27 15:56:48.427667	\N
5ba76495-5ff2-40f4-bebd-73dd175880b3	903	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.429776	2025-10-27 15:56:48.429776	\N
03007df4-aff1-4bcc-b388-b2110ce85094	904	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.431855	2025-10-27 15:56:48.431855	\N
2ed835e3-6fc8-47ae-9baf-ae4e1bb58733	905	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.433894	2025-10-27 15:56:48.433894	\N
ac2eb7b3-9c5c-4946-a5b4-bc90489fec7c	906	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.436834	2025-10-27 15:56:48.436834	\N
42233327-4f3c-404b-9aaa-17468a26744e	907	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.439103	2025-10-27 15:56:48.439103	\N
88ed6f90-9c0d-4da3-8082-96b266251f2c	908	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.441132	2025-10-27 15:56:48.441132	\N
5bf34d3e-54ed-4c02-bf5f-7264ce0abf63	909	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.44318	2025-10-27 15:56:48.44318	\N
cd88580a-cd2d-4a59-a931-8782b5c8b12e	910	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.445236	2025-10-27 15:56:48.445236	\N
dd672c79-f944-4e7c-b67d-f0660dd54361	911	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.447273	2025-10-27 15:56:48.447273	\N
cf195eb1-9cd7-471b-8dd0-b236cf2a9dc5	912	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.449523	2025-10-27 15:56:48.449523	\N
6311a50f-88a8-44b5-aec8-114ba9f759c9	913	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.451571	2025-10-27 15:56:48.451571	\N
40309bf4-95fa-4597-ba91-bb7476a68fed	914	company-admin-default	clean	zone-port-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591407974-9i2pqxrtu	\N	\N	\N	programada	aberta	media	Portaria - WC feminino	Limpeza de WC feminino da portaria 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:56:48.453605	2025-10-27 15:56:48.453605	\N
7e3a8a2d-6168-4b89-9d80-e3731be33e65	915	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.496291	2025-10-27 15:57:35.496291	\N
2ab62348-b5aa-4fdd-898a-0a5a4619c108	916	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.499568	2025-10-27 15:57:35.499568	\N
af144eaf-ec6f-493c-a1e5-a0b7c6f97ff6	917	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.501697	2025-10-27 15:57:35.501697	\N
4130949e-3d36-4852-9ec2-2de6574f28d1	918	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.503905	2025-10-27 15:57:35.503905	\N
3c44099e-49c2-42b7-892d-8db8ca52639c	919	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.50611	2025-10-27 15:57:35.50611	\N
39f93c9d-94d9-4790-87a7-e371f65b1e84	920	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.508222	2025-10-27 15:57:35.508222	\N
a7fa75d5-0df0-4102-9f69-d2812a79b8e3	921	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.510501	2025-10-27 15:57:35.510501	\N
16ab80a7-f894-4f05-87eb-80e92f2b6ebd	922	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.512553	2025-10-27 15:57:35.512553	\N
5fd168b6-b9da-470d-8a47-0ec2bc94dc60	923	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.514566	2025-10-27 15:57:35.514566	\N
e65df6fe-b9b5-46d6-9996-8edd31f0606a	924	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.516762	2025-10-27 15:57:35.516762	\N
c2166158-3c88-4eca-a81c-9354947f3704	925	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.518779	2025-10-27 15:57:35.518779	\N
1944b35f-9214-477b-ad36-c5f68dbe078f	926	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.520978	2025-10-27 15:57:35.520978	\N
041ccbf0-2935-49e6-b35d-65c024fe5be8	927	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.523405	2025-10-27 15:57:35.523405	\N
3a054f78-fb44-4c98-958a-32f53fc96f68	928	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.525526	2025-10-27 15:57:35.525526	\N
1b3b4612-8de1-4585-b9a6-c2d1ecffb345	929	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.527538	2025-10-27 15:57:35.527538	\N
bd510722-f4b1-4356-a52d-f3752c61a562	930	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.529718	2025-10-27 15:57:35.529718	\N
1940c283-8550-441a-bb1a-f0c1ce80b18c	931	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.533328	2025-10-27 15:57:35.533328	\N
a77c1844-b0c4-4237-bb3c-0f4efd28fb36	932	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.535363	2025-10-27 15:57:35.535363	\N
a953b0b4-0ee1-49ab-8058-995f8e8514ea	933	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.53743	2025-10-27 15:57:35.53743	\N
0d6420ce-363d-41ff-9561-26abafad9fa5	934	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.539549	2025-10-27 15:57:35.539549	\N
14a71012-0031-4423-8607-c9b14d8b0947	935	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.541662	2025-10-27 15:57:35.541662	\N
69ba4ce8-02f7-48e8-83d7-8e95625b6a56	936	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.543688	2025-10-27 15:57:35.543688	\N
67890cae-dcdf-43bb-835b-421abfe68342	937	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.54579	2025-10-27 15:57:35.54579	\N
d00576f1-0b8e-4136-aa8d-3d28d49171a9	938	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.547967	2025-10-27 15:57:35.547967	\N
19d3fd66-fb98-49ea-9d13-278b65a12653	939	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.549982	2025-10-27 15:57:35.549982	\N
fc51a684-3044-4b73-abd6-6eae7a02a31b	940	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.552422	2025-10-27 15:57:35.552422	\N
29ec3ecf-70e2-47f1-8eb0-a6b8f9fc182b	941	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.554448	2025-10-27 15:57:35.554448	\N
e7d6be14-6e4a-4cad-bff0-51663bd1aa1f	942	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.556543	2025-10-27 15:57:35.556543	\N
5d9660c3-afd9-41d0-b999-2c9f9faf1e79	943	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.558784	2025-10-27 15:57:35.558784	\N
cc3161bb-fe07-4f9a-8b3d-14cc96254f1c	944	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.560802	2025-10-27 15:57:35.560802	\N
060a2d6d-c526-4a5f-8088-21135ba034e3	945	company-admin-default	clean	zone-port-masc	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591455060-1zocriqb3	\N	\N	\N	programada	aberta	media	Portaria - WC masculino	Limpeza de WC masculino portaria	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:57:35.562885	2025-10-27 15:57:35.562885	\N
7ef8b284-3954-43a0-80bf-f1e71d6013f5	946	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.283635	2025-10-27 15:59:01.283635	\N
f7421a71-bf47-474d-b27e-ec05c22f6d9b	947	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.28664	2025-10-27 15:59:01.28664	\N
a0e892d5-69e0-489d-b314-8c51c78460b6	948	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.28901	2025-10-27 15:59:01.28901	\N
2e125eb9-eda5-4959-b872-8887ec82d77f	949	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.291415	2025-10-27 15:59:01.291415	\N
d71b87ea-3745-42f2-ba28-e472cb6a5df6	950	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.293798	2025-10-27 15:59:01.293798	\N
8e45ae56-094d-484f-a3b2-a3c03163d9a3	951	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.296133	2025-10-27 15:59:01.296133	\N
4c46fe83-847f-4dda-880e-daa76ed84334	952	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.298765	2025-10-27 15:59:01.298765	\N
e3fb4bef-45bd-42b8-90c3-470ec820de1b	953	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.300977	2025-10-27 15:59:01.300977	\N
5b3fe818-f5b7-4b53-be94-290789e817f7	954	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.303343	2025-10-27 15:59:01.303343	\N
db1d39ce-4518-42c5-a603-d8032a1ed8ea	955	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.305455	2025-10-27 15:59:01.305455	\N
f372c1fb-90a7-4d29-8738-bac561181a2c	956	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.307574	2025-10-27 15:59:01.307574	\N
ca70ab04-1023-4f8c-96b9-9f76e7f2eb40	957	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.309851	2025-10-27 15:59:01.309851	\N
ee7b21b6-b9c0-40ce-a49d-5f5e5306329b	958	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.312127	2025-10-27 15:59:01.312127	\N
9f38c014-10bf-4e1e-9430-1ff6fcba8f66	959	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.314435	2025-10-27 15:59:01.314435	\N
4a653b1f-80f5-4f75-a944-d5059e0281c7	960	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-15	2025-10-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.316725	2025-10-27 15:59:01.316725	\N
c3abee5b-068a-45a7-8792-ab085f4c707c	961	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-16	2025-10-16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.318874	2025-10-27 15:59:01.318874	\N
b0c5cdc0-ad33-4374-8b53-a444c6ff9cc6	962	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-17	2025-10-17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.32098	2025-10-27 15:59:01.32098	\N
b601977b-a75e-4b90-b2d8-13b4a3efada8	963	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-18	2025-10-18	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.323587	2025-10-27 15:59:01.323587	\N
73d8ea21-52e0-41d8-ac0f-cdd80989e8b1	964	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-19	2025-10-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.325704	2025-10-27 15:59:01.325704	\N
475b72bd-b760-49fe-9719-70853cea6553	965	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.327838	2025-10-27 15:59:01.327838	\N
570c0086-4704-436f-ba64-af3c9c2c44dc	966	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.329954	2025-10-27 15:59:01.329954	\N
bb8d3d0b-b38a-419d-96a7-bd87c197c88b	967	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.33207	2025-10-27 15:59:01.33207	\N
c00627a4-67d9-4444-a650-f0ed94069275	968	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.335095	2025-10-27 15:59:01.335095	\N
201c666f-c56f-4629-b763-66d45058db64	969	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.337537	2025-10-27 15:59:01.337537	\N
bd529444-2dae-40fd-9b30-7aadc1d9798f	970	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.339764	2025-10-27 15:59:01.339764	\N
7ed9f71d-c925-4f31-ae1a-de4a676d948f	971	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.341873	2025-10-27 15:59:01.341873	\N
260821cf-9410-45a8-8f7e-9876c4a10a10	972	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.343991	2025-10-27 15:59:01.343991	\N
97405371-b80d-4fc0-9213-8378d59de6cc	973	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.346116	2025-10-27 15:59:01.346116	\N
c7292128-b391-49ec-973a-c0351a0c5ff5	974	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.3488	2025-10-27 15:59:01.3488	\N
60c6a481-ef43-426e-b9ce-eb6c588331ef	975	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.350971	2025-10-27 15:59:01.350971	\N
bd98fc35-5769-49f2-a025-1590860f0345	976	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591540766-1m8stph7k	\N	\N	\N	programada	aberta	media	Tech center - WC masculino	Limpeza de WC masculino Tech center	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 15:59:01.3531	2025-10-27 15:59:01.3531	\N
b98ccfde-a8fe-47a5-834b-a0fa10fde309	977	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-01	2025-10-01	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.948458	2025-10-27 16:00:37.948458	\N
fa07384f-d410-4f3e-9767-c3dbf002b1af	978	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-02	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.951586	2025-10-27 16:00:37.951586	\N
cd07aeb6-ddf1-40b7-ad05-9f385cdd06a5	979	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-03	2025-10-03	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.954403	2025-10-27 16:00:37.954403	\N
a02951ef-78b8-4fc4-807a-2669ef5ba9dc	980	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-04	2025-10-04	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.956742	2025-10-27 16:00:37.956742	\N
b48a4b0f-9fe8-45d5-891e-db0e8ae25d84	981	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-05	2025-10-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.959057	2025-10-27 16:00:37.959057	\N
b81f64e8-cfaf-401c-b7ba-1134c057d381	982	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-06	2025-10-06	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.961355	2025-10-27 16:00:37.961355	\N
4308b3e2-138f-469d-8d3f-ae648f37326d	983	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-07	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.963631	2025-10-27 16:00:37.963631	\N
f7e9d275-5398-40af-a526-02c219347c6a	984	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-08	2025-10-08	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.966078	2025-10-27 16:00:37.966078	\N
d534b942-d799-4797-95c9-1caad053c0f3	985	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-09	2025-10-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.968291	2025-10-27 16:00:37.968291	\N
794292e5-269f-4d5f-ba80-1d44c3e269c4	986	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-10	2025-10-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.970547	2025-10-27 16:00:37.970547	\N
c7edf6ea-be2a-4d41-a908-3adfef4111b2	987	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-11	2025-10-11	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.97269	2025-10-27 16:00:37.97269	\N
b5cdcaf2-afdc-4ecf-b7fd-dcaf895e14a9	988	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-12	2025-10-12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.974822	2025-10-27 16:00:37.974822	\N
b83e59e8-4119-4e14-8be0-39b2b127f206	989	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-13	2025-10-13	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.977272	2025-10-27 16:00:37.977272	\N
c08955b7-8263-41e8-a27f-c90b51dba562	990	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-14	2025-10-14	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.979396	2025-10-27 16:00:37.979396	\N
c0f567b2-1ee0-4b1a-acd6-6d4198fc727f	996	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-20	2025-10-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.993621	2025-10-27 16:00:37.993621	\N
8b426708-0ea3-498f-b9f4-aa9c8f1196cc	997	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-21	2025-10-21	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.995768	2025-10-27 16:00:37.995768	\N
3392b1e2-a0be-475a-a993-db3f25f72ced	998	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-22	2025-10-22	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:37.997958	2025-10-27 16:00:37.997958	\N
39c41d5c-7f1f-47b8-a31e-9041ab1603e7	999	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-23	2025-10-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.000074	2025-10-27 16:00:38.000074	\N
1c21273e-e3ca-4cc2-a557-3d62ea97eb39	1000	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-24	2025-10-24	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.002445	2025-10-27 16:00:38.002445	\N
14a5202a-21a7-49a9-912f-b2dc4db45307	1001	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-25	2025-10-25	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.004733	2025-10-27 16:00:38.004733	\N
aa1af9fc-8932-4c9c-be30-5191b75bb9e4	1002	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.006918	2025-10-27 16:00:38.006918	\N
bb0edd01-1cde-4600-ad93-15e91492f509	1003	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-27	2025-10-27	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.009027	2025-10-27 16:00:38.009027	\N
a85a7c94-4d93-43d9-aaf7-b3baddc96166	1004	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-28	2025-10-28	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.011134	2025-10-27 16:00:38.011134	\N
26cebc75-e3ab-40c0-bc96-35effbd1e659	1005	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-29	2025-10-29	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.013322	2025-10-27 16:00:38.013322	\N
015db67f-4811-4486-99e5-8c45fc1f1045	1006	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.015793	2025-10-27 16:00:38.015793	\N
6cdec6cf-2137-4f7b-9876-7146ff7f0f20	1007	company-admin-default	clean	zone-adm-masc-tech	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761591637418-eed4drz6c	\N	\N	\N	programada	aberta	media	Tech center - WC feminino	Limpeza de WC feminino tech center 	\N	Sistema - Cronograma	\N	\N	\N	2025-10-31	2025-10-31	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-10-27 16:00:38.01794	2025-10-27 16:00:38.01794	\N
d2bcb6da-150b-4c3a-a44d-aefcb453e306	727	company-admin-default	clean	zone-adm-fem	1cf0f4ad-e6ef-4266-ba98-ae8746378ad8	ca-1761590774854-0gkz8w44o	\N	\N	\N	programada	concluida	media	Limpeza WC RH feminino	Limpeza de WC feminino RH	\N	Sistema - Cronograma	\N	\N	\N	2025-10-30	2025-10-30	\N	\N	2025-10-27 15:46:15.196	2025-10-29 19:41:02.72	\N	\N	\N	\N	{"1761585131183": ""}	\N	\N	\N	\N	\N	2025-10-27 15:46:15.196341	2025-10-29 16:41:02.504418	\N
da00b800-ddf0-47d9-bf37-423f1c3bb36a	1110	company-admin-default	maintenance	4c7888f3-5c26-4a3b-80f1-e0bd8318f80f	\N	\N	\N	aC3Uv5u-K1by5BipHyY1_	\N	programada	aberta	media	Teste - Maquina de Café	Manutenção preventiva para Maquina de Café	\N	Sistema - Plano de Manutenção	\N	\N	\N	2025-12-05	2025-12-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-11-04 12:21:43.792214	2025-11-04 12:21:43.792214	ma-1762258844497-dspp6ahsb
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: -
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
\.


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
-- Name: equipment_tags equipment_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_tags
    ADD CONSTRAINT equipment_tags_pkey PRIMARY KEY (id);


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
-- Name: service_types service_types_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_types
    ADD CONSTRAINT service_types_code_unique UNIQUE (code);


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
-- Name: work_orders_company_number_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX work_orders_company_number_unique ON public.work_orders USING btree (company_id, number);


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
-- Name: equipment_tags equipment_tags_company_id_companies_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_tags
    ADD CONSTRAINT equipment_tags_company_id_companies_id_fk FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: equipment_tags equipment_tags_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment_tags
    ADD CONSTRAINT equipment_tags_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id);


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
-- Name: maintenance_activities maintenance_activities_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_activities maintenance_activities_sla_config_id_sla_configs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_activities
    ADD CONSTRAINT maintenance_activities_sla_config_id_sla_configs_id_fk FOREIGN KEY (sla_config_id) REFERENCES public.sla_configs(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_checklist_template_id_maintena; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_checklist_template_id_maintena FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_executed_by_user_id_users_id_f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_executed_by_user_id_users_id_f FOREIGN KEY (executed_by_user_id) REFERENCES public.users(id);


--
-- Name: maintenance_checklist_executions maintenance_checklist_executions_work_order_id_work_orders_id_f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_executions
    ADD CONSTRAINT maintenance_checklist_executions_work_order_id_work_orders_id_f FOREIGN KEY (work_order_id) REFERENCES public.work_orders(id);


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
-- Name: maintenance_checklist_templates maintenance_checklist_templates_equipment_id_equipment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_checklist_templates
    ADD CONSTRAINT maintenance_checklist_templates_equipment_id_equipment_id_fk FOREIGN KEY (equipment_id) REFERENCES public.equipment(id);


--
-- Name: maintenance_plan_equipments maintenance_plan_equipments_checklist_template_id_maintenance_c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_plan_equipments
    ADD CONSTRAINT maintenance_plan_equipments_checklist_template_id_maintenance_c FOREIGN KEY (checklist_template_id) REFERENCES public.maintenance_checklist_templates(id);


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

