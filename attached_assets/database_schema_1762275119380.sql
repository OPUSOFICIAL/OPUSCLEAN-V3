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

