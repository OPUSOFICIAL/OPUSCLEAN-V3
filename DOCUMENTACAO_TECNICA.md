# 📚 Documentação Técnica - Acelera it Full Facilities

**Versão:** 1.0  
**Data:** Novembro 2025  
**Plataforma:** Replit  

---

## 📋 Índice

1. [Visão Geral do Sistema](#1-visão-geral-do-sistema)
2. [Modelo de Dados](#2-modelo-de-dados)
3. [Backend](#3-backend)
4. [Frontend](#4-frontend)
5. [Funcionalidades Principais](#5-funcionalidades-principais)
6. [Segurança](#6-segurança)
7. [Configurações e Deploy](#7-configurações-e-deploy)

---

## 1. Visão Geral do Sistema

### 1.1 Descrição

**Acelera it Full Facilities** é uma plataforma modular para gestão de facilities, atualmente suportando módulos de **Limpeza (Clean)** e **Manutenção (Maintenance)**. O sistema foi projetado para ambientes multi-empresa, multi-site e multi-zona, oferecendo:

- Gestão de atividades programadas
- Ordens de serviço (Work Orders)
- Execução via QR Code
- Solicitações públicas de serviço
- Dashboards analíticos
- Modo TV para visualização pública

### 1.2 Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────┐
│                        FRONTEND                              │
│  React 18 + TypeScript + Vite + Wouter + TanStack Query    │
│  UI: shadcn/ui + Radix UI + Tailwind CSS + Framer Motion   │
└─────────────────────────────────────────────────────────────┘
                              ↕ HTTP/REST
┌─────────────────────────────────────────────────────────────┐
│                        BACKEND                               │
│     Express.js + TypeScript + Passport.js + JWT            │
│     ORM: Drizzle + Database: PostgreSQL (Neon)             │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                    BANCO DE DADOS                            │
│              PostgreSQL (hospedado no Neon)                  │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Stack Tecnológico

#### Frontend
- **Framework:** React 18 com TypeScript
- **Build Tool:** Vite
- **Roteamento:** Wouter
- **Estado:** TanStack Query v5
- **Formulários:** React Hook Form + Zod
- **UI Components:** shadcn/ui (Radix UI primitives)
- **Styling:** Tailwind CSS
- **Animações:** Framer Motion
- **Ícones:** Lucide React, React Icons

#### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Linguagem:** TypeScript
- **ORM:** Drizzle ORM
- **Database:** PostgreSQL (Neon)
- **Autenticação:** Passport.js (Local + Microsoft SSO)
- **Tokens:** JWT (jsonwebtoken)
- **Hash de Senhas:** Bcrypt.js
- **Validação:** Zod

#### Segurança & Infraestrutura
- **CORS:** cors
- **Security Headers:** Helmet.js
- **Rate Limiting:** express-rate-limit
- **Sessions:** express-session + connect-pg-simple
- **Environment:** dotenv

#### Utilitários
- **Datas:** date-fns
- **QR Codes:** qrcode, qr-scanner
- **PDFs:** jsPDF + jspdf-autotable
- **Excel:** xlsx
- **Gráficos:** ApexCharts, Recharts

### 1.4 Estrutura de Diretórios

```
acelera-full-facilities/
├── client/                    # Frontend React
│   ├── src/
│   │   ├── components/       # Componentes UI (shadcn)
│   │   │   └── ui/          # Componentes base do shadcn
│   │   ├── pages/           # Páginas da aplicação
│   │   ├── lib/             # Utilitários (queryClient, etc)
│   │   ├── hooks/           # Custom React hooks
│   │   ├── contexts/        # Context providers (Client, Module)
│   │   ├── App.tsx          # Componente raiz
│   │   └── main.tsx         # Entry point
│   └── index.html
│
├── server/                    # Backend Express
│   ├── auth.ts               # Configuração Passport (Local + Microsoft)
│   ├── db.ts                 # Cliente Drizzle + conexão PostgreSQL
│   ├── storage.ts            # Interface de Storage + implementações
│   ├── routes.ts             # Rotas da API REST
│   ├── index.ts              # Entry point do servidor
│   ├── vite.ts               # Integração Vite no Express
│   └── utils/
│       └── serialization.ts  # Serialização de dados (JSON-safe)
│
├── shared/                    # Código compartilhado
│   └── schema.ts             # Schemas Drizzle + Zod + Types
│
├── scripts/                   # Scripts utilitários
│   └── import-dump.ts        # Importação de dumps SQL
│
├── attached_assets/          # Assets anexados
│   └── acelera-full-facilities-logo.png
│
├── package.json              # Dependências npm
├── tsconfig.json            # Config TypeScript
├── vite.config.ts           # Config Vite
├── tailwind.config.ts       # Config Tailwind
├── drizzle.config.ts        # Config Drizzle ORM
└── replit.md                # Documentação do projeto
```

---

## 2. Modelo de Dados

### 2.1 Hierarquia Multi-Tenancy

```
Companies (Grupo OPUS)
    ↓
Customers (Clientes - Faurecia, Tecnofibra)
    ↓
Sites (Locais - Fábrica, Escritório)
    ↓
Zones (Zonas - WC Masculino, Cabine de Pintura)
    ↓
Services (Serviços - Limpeza Rotina, Higienização)
    ↓
Activities / Checklists (Atividades de Limpeza / Manutenção)
```

### 2.2 Entidades Principais

#### 2.2.1 Gestão Organizacional

**`companies`** - Empresas operadoras (GRUPO OPUS)
```typescript
{
  id: string (PK)
  name: string
  cnpj: string
  email: string
  phone: string
  address: string
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`customers`** - Clientes finais (Faurecia, Tecnofibra)
```typescript
{
  id: string (PK)
  company_id: string (FK → companies)
  name: string
  email: string
  phone: string
  document: string
  address: string
  city: string
  state: string
  zip_code: string
  contact_person: string
  notes: text
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`sites`** - Locais físicos (Apresentado como "Local" na UI)
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  name: string
  address: string
  city: string
  state: string
  zip_code: string
  contact_person: string
  contact_email: string
  contact_phone: string
  latitude: decimal
  longitude: decimal
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`zones`** - Zonas dentro dos locais
```typescript
{
  id: string (PK)
  site_id: string (FK → sites)
  name: string
  description: text
  zone_type: enum ('area', 'room', 'equipment', 'outdoor', 'other')
  floor: string
  capacity: integer
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

#### 2.2.2 Serviços e Categorias

**`service_types`** - Tipos de serviço (Preventivo, Corretivo, Emergência)
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  name: string
  description: text
  code: string
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`service_categories`** - Categorias de serviço
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  type_id: string (FK → service_types)
  name: string
  description: text
  code: string
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`services`** - Serviços específicos
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  category_id: string (FK → service_categories)
  type_id: string (FK → service_types)
  name: string
  description: text
  estimated_duration_minutes: integer
  priority: enum ('baixa', 'media', 'alta', 'critica')
  requirements: text
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

#### 2.2.3 Módulo Clean (Limpeza)

**`cleaning_activities`** - Atividades de limpeza programadas
```typescript
{
  id: string (PK)
  company_id: string (FK → companies)
  service_id: string (FK → services)
  site_id: string (FK → sites)
  zone_id: string (FK → zones)
  name: string
  description: text
  frequency: enum ('diaria', 'semanal', 'quinzenal', 'mensal', 'turno')
  frequency_config: jsonb
  checklist_template_id: string (FK → checklist_templates)
  sla_config_id: string (FK → sla_configs)
  is_active: boolean
  start_time: time
  end_time: time
  created_at: timestamp
  updated_at: timestamp
}
```

**`checklist_templates`** - Templates de checklists
```typescript
{
  id: string (PK)
  company_id: string (FK → companies)
  service_id: string (FK → services)
  site_id: string (FK → sites)
  zone_id: string (FK → zones)
  name: string
  description: text
  items: jsonb[] // Array de items do checklist
  created_at: timestamp
  updated_at: timestamp
}
```

#### 2.2.4 Módulo Maintenance (Manutenção)

**`equipment`** - Equipamentos
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  site_id: string (FK → sites)
  zone_id: string (FK → zones)
  name: string
  description: text
  manufacturer: string
  model: string
  serial_number: string
  installation_date: date
  warranty_expiry: date
  status: enum ('operacional', 'manutencao', 'inativo', 'quebrado')
  criticality: enum ('baixa', 'media', 'alta', 'critica')
  specifications: jsonb
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`maintenance_plans`** - Planos de manutenção
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  service_id: string (FK → services)
  equipment_id: string (FK → equipment)
  name: string
  description: text
  frequency: enum ('diaria', 'semanal', 'quinzenal', 'mensal', 'trimestral', 'semestral', 'anual')
  frequency_config: jsonb
  checklist_template_id: string (FK → checklist_templates)
  is_active: boolean
  next_execution: timestamp
  created_at: timestamp
  updated_at: timestamp
}
```

#### 2.2.5 Work Orders (Ordens de Serviço)

**`work_orders`** - Ordens de serviço
```typescript
{
  id: string (PK)
  customer_id: string (FK → customers)
  service_id: string (FK → services)
  site_id: string (FK → sites)
  zone_id: string (FK → zones)
  number: string // Número único por cliente
  type: enum ('programada', 'corretiva_interna', 'corretiva_publica')
  status: enum ('pendente', 'em_andamento', 'concluida', 'cancelada')
  priority: enum ('baixa', 'media', 'alta', 'critica')
  title: string
  description: text
  scheduled_start: timestamp
  scheduled_end: timestamp
  actual_start: timestamp
  actual_end: timestamp
  cleaning_activity_id: string (FK → cleaning_activities)
  maintenance_plan_id: string (FK → maintenance_plans)
  equipment_id: string (FK → equipment)
  checklist_template_id: string (FK → checklist_templates)
  checklist_responses: jsonb
  assigned_users: string[] // Array de user IDs
  created_by: string (FK → users)
  completed_by: string (FK → users)
  public_request_id: string
  qr_code_point_id: string (FK → qr_code_points)
  sla_deadline: timestamp
  is_sla_violated: boolean
  created_at: timestamp
  updated_at: timestamp
  completed_at: timestamp
  cancelled_at: timestamp
  cancellation_reason: text
}
```

**`work_order_comments`** - Comentários em OS
```typescript
{
  id: string (PK)
  work_order_id: string (FK → work_orders)
  user_id: string (FK → users)
  comment: text
  photos: text[] // URLs das fotos
  is_internal: boolean
  created_at: timestamp
}
```

#### 2.2.6 Sistema de QR Codes

**`qr_code_points`** - Pontos de QR Code
```typescript
{
  id: string (PK)
  zone_id: string (FK → zones)
  service_id: string (FK → services)
  code: string // Código único do QR
  type: enum ('execucao', 'publico')
  name: string
  description: text
  size_cm: integer // Tamanho físico do QR em cm
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`public_request_logs`** - Log de requisições públicas
```typescript
{
  id: string (PK)
  qr_code_point_id: string (FK → qr_code_points)
  ip_hash: string
  user_agent: text
  request_data: jsonb
  created_at: timestamp
}
```

#### 2.2.7 Usuários e Permissões

**`users`** - Usuários do sistema
```typescript
{
  id: string (PK)
  company_id: string (FK → companies)
  customer_id: string (FK → customers)
  email: string (unique)
  password_hash: string
  full_name: string
  role: enum ('admin', 'operador', 'cliente', 'auditor')
  custom_role_id: string (FK → custom_roles)
  user_type: enum ('opus_user', 'customer_user')
  auth_provider: enum ('local', 'microsoft')
  microsoft_id: string
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`custom_roles`** - Roles customizados
```typescript
{
  id: string (PK)
  company_id: string (FK → companies)
  name: string
  description: text
  is_system_role: boolean
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**`role_permissions`** - Permissões por role
```typescript
{
  id: string (PK)
  role_id: string (FK → custom_roles)
  permission: string
  created_at: timestamp
}
```

### 2.3 Enumerações (Enums)

Definidas em `shared/schema.ts`:

```typescript
// Roles
export const userRoleEnum = pgEnum('user_role', ['admin', 'operador', 'cliente', 'auditor']);

// Auth Providers
export const authProviderEnum = pgEnum('auth_provider', ['local', 'microsoft']);

// User Types
export const userTypeEnum = pgEnum('user_type', ['opus_user', 'customer_user']);

// Work Order Status
export const workOrderStatusEnum = pgEnum('work_order_status', [
  'pendente', 'em_andamento', 'concluida', 'cancelada'
]);

// Work Order Types
export const workOrderTypeEnum = pgEnum('work_order_type', [
  'programada', 'corretiva_interna', 'corretiva_publica'
]);

// Priorities
export const priorityEnum = pgEnum('priority', ['baixa', 'media', 'alta', 'critica']);

// Frequencies
export const frequencyEnum = pgEnum('frequency', [
  'diaria', 'semanal', 'quinzenal', 'mensal', 'trimestral', 'semestral', 'anual', 'turno'
]);

// Equipment Status
export const equipmentStatusEnum = pgEnum('equipment_status', [
  'operacional', 'manutencao', 'inativo', 'quebrado'
]);

// Zone Types
export const zoneTypeEnum = pgEnum('zone_type', [
  'area', 'room', 'equipment', 'outdoor', 'other'
]);

// QR Code Types
export const qrCodeTypeEnum = pgEnum('qr_code_type', ['execucao', 'publico']);

// Module Types
export const moduleTypeEnum = pgEnum('module_type', ['clean', 'maintenance']);
```

### 2.4 Relacionamentos Chave

```
companies (1) ──→ (N) customers
customers (1) ──→ (N) sites
sites (1) ──→ (N) zones
zones (1) ──→ (N) qr_code_points
zones (1) ──→ (N) equipment

customers (1) ──→ (N) services
services (1) ──→ (N) cleaning_activities
services (1) ──→ (N) maintenance_plans

cleaning_activities (1) ──→ (N) work_orders
maintenance_plans (1) ──→ (N) work_orders
equipment (1) ──→ (N) work_orders

checklist_templates (1) ──→ (N) cleaning_activities
checklist_templates (1) ──→ (N) maintenance_plans
checklist_templates (1) ──→ (N) work_orders

work_orders (1) ──→ (N) work_order_comments

users (N) ←──→ (N) work_orders (assigned_users - array)
```

---

## 3. Backend

### 3.1 Arquitetura do Backend

O backend é construído com Express.js e segue uma arquitetura em camadas:

```
HTTP Request
    ↓
Middleware Stack (CORS, Helmet, Sessions, Rate Limiting)
    ↓
Authentication Middleware (JWT + Passport)
    ↓
Authorization Middleware (Permission Checking)
    ↓
Route Handlers (server/routes.ts)
    ↓
Storage Layer (server/storage.ts)
    ↓
Database (Drizzle ORM → PostgreSQL)
```

### 3.2 Sistema de Storage

**Localização:** `server/storage.ts`

#### Interface IStorage

Define o contrato para operações de dados:

```typescript
interface IStorage {
  // Companies
  getCompanies(): Promise<Company[]>;
  getCompanyById(id: string): Promise<Company | undefined>;
  createCompany(data: InsertCompany): Promise<Company>;
  
  // Customers
  getCustomers(companyId?: string): Promise<Customer[]>;
  getCustomerById(id: string): Promise<Customer | undefined>;
  createCustomer(data: InsertCustomer): Promise<Customer>;
  
  // Sites
  getSites(customerId?: string): Promise<Site[]>;
  getSiteById(id: string): Promise<Site | undefined>;
  createSite(data: InsertSite): Promise<Site>;
  
  // Zones
  getZones(siteId?: string): Promise<Zone[]>;
  getZoneById(id: string): Promise<Zone | undefined>;
  createZone(data: InsertZone): Promise<Zone>;
  
  // Work Orders
  getWorkOrders(filters: WorkOrderFilters): Promise<WorkOrder[]>;
  getWorkOrderById(id: string): Promise<WorkOrder | undefined>;
  createWorkOrder(data: InsertWorkOrder): Promise<WorkOrder>;
  updateWorkOrder(id: string, data: Partial<InsertWorkOrder>): Promise<WorkOrder>;
  
  // ... e muito mais
}
```

#### Implementações

**DatabaseStorage** - Implementação principal usando Drizzle ORM:
```typescript
export class DatabaseStorage implements IStorage {
  async getCustomers(companyId?: string) {
    if (companyId) {
      return await db
        .select()
        .from(customers)
        .where(eq(customers.companyId, companyId));
    }
    return await db.select().from(customers);
  }
  
  // ... mais métodos
}
```

**MemStorage** - Implementação em memória para testes:
```typescript
export class MemStorage implements IStorage {
  private companies: Map<string, Company> = new Map();
  private customers: Map<string, Customer> = new Map();
  
  async getCustomers(companyId?: string) {
    const allCustomers = Array.from(this.customers.values());
    if (companyId) {
      return allCustomers.filter(c => c.companyId === companyId);
    }
    return allCustomers;
  }
}
```

### 3.3 Rotas da API

**Localização:** `server/routes.ts`

#### Estrutura de Middleware

```typescript
// Autenticação
app.use(passport.initialize());
app.use(passport.session());

// CORS
app.use(cors({ credentials: true, origin: true }));

// Security Headers
app.use(helmet());

// Rate Limiting
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5 // 5 tentativas
});
```

#### Grupos de Rotas

**Autenticação**
```typescript
POST   /api/auth/login                    // Login local
POST   /api/auth/microsoft/login          // Redirecionar para Microsoft
GET    /api/auth/microsoft/callback       // Callback Microsoft OAuth
POST   /api/auth/logout                   // Logout
GET    /api/auth/me                       // Usuário atual
```

**Companies & Customers**
```typescript
GET    /api/companies                     // Listar empresas
POST   /api/companies                     // Criar empresa
GET    /api/companies/:id                 // Detalhes empresa
PUT    /api/companies/:id                 // Atualizar empresa

GET    /api/customers                     // Listar clientes
POST   /api/customers                     // Criar cliente
GET    /api/customers/:id                 // Detalhes cliente
PUT    /api/customers/:id                 // Atualizar cliente
DELETE /api/customers/:id                 // Deletar cliente
```

**Sites & Zones**
```typescript
GET    /api/sites                         // Listar sites
POST   /api/sites                         // Criar site
GET    /api/sites/:id                     // Detalhes site
PUT    /api/sites/:id                     // Atualizar site

GET    /api/zones                         // Listar zonas
POST   /api/zones                         // Criar zona
GET    /api/zones/:id                     // Detalhes zona
PUT    /api/zones/:id                     // Atualizar zona
```

**Services**
```typescript
GET    /api/service-types                 // Listar tipos
POST   /api/service-types                 // Criar tipo
GET    /api/service-categories            // Listar categorias
POST   /api/service-categories            // Criar categoria
GET    /api/services                      // Listar serviços
POST   /api/services                      // Criar serviço
```

**Cleaning Activities**
```typescript
GET    /api/cleaning-activities           // Listar atividades
POST   /api/cleaning-activities           // Criar atividade
GET    /api/cleaning-activities/:id       // Detalhes atividade
PUT    /api/cleaning-activities/:id       // Atualizar atividade
DELETE /api/cleaning-activities/:id       // Deletar atividade
```

**Checklist Templates**
```typescript
GET    /api/checklist-templates           // Listar templates
POST   /api/checklist-templates           // Criar template
GET    /api/checklist-templates/:id       // Detalhes template
PUT    /api/checklist-templates/:id       // Atualizar template
DELETE /api/checklist-templates/:id       // Deletar template
```

**Work Orders**
```typescript
GET    /api/work-orders                   // Listar OSs
POST   /api/work-orders                   // Criar OS
GET    /api/work-orders/:id               // Detalhes OS
PUT    /api/work-orders/:id               // Atualizar OS
POST   /api/work-orders/:id/start         // Iniciar OS
POST   /api/work-orders/:id/complete      // Completar OS
POST   /api/work-orders/:id/cancel        // Cancelar OS
POST   /api/work-orders/:id/comments      // Adicionar comentário
GET    /api/work-orders/:id/comments      // Listar comentários
```

**QR Codes**
```typescript
GET    /api/qr-codes                      // Listar QR codes
POST   /api/qr-codes                      // Criar QR code
GET    /api/qr-codes/:id                  // Detalhes QR code
GET    /api/qr-scan/:code                 // Escanear QR
POST   /api/qr-public-request             // Requisição pública
```

**Equipment (Maintenance)**
```typescript
GET    /api/equipment                     // Listar equipamentos
POST   /api/equipment                     // Criar equipamento
GET    /api/equipment/:id                 // Detalhes equipamento
PUT    /api/equipment/:id                 // Atualizar equipamento
GET    /api/equipment/:id/history         // Histórico de OSs
```

**Dashboards**
```typescript
GET    /api/dashboard/stats               // Estatísticas gerais
GET    /api/dashboard/charts              // Dados para gráficos
GET    /api/tv-mode/stats                 // Stats para TV Mode
```

**Users & Roles**
```typescript
GET    /api/users                         // Listar usuários
POST   /api/users                         // Criar usuário
GET    /api/users/:id                     // Detalhes usuário
PUT    /api/users/:id                     // Atualizar usuário
DELETE /api/users/:id                     // Deletar usuário

GET    /api/roles                         // Listar roles
POST   /api/roles                         // Criar role customizado
GET    /api/roles/:id                     // Detalhes role
PUT    /api/roles/:id                     // Atualizar role
```

**AI Integrations**
```typescript
GET    /api/ai/integrations               // Listar integrações AI
POST   /api/ai/integrations               // Criar integração
PUT    /api/ai/integrations/:id           // Atualizar integração
DELETE /api/ai/integrations/:id           // Deletar integração
POST   /api/ai/integrations/:id/test      // Testar integração
```

### 3.4 Autenticação

**Localização:** `server/auth.ts`

#### Estratégias Passport

**Local Strategy** - Email e senha:
```typescript
passport.use(
  new LocalStrategy(
    {
      usernameField: 'email',
      passwordField: 'password',
    },
    async (email, password, done) => {
      try {
        const user = await storage.getUserByEmail(email);
        
        if (!user) {
          return done(null, false, { message: 'Email ou senha incorretos' });
        }
        
        if (!user.isActive) {
          return done(null, false, { message: 'Usuário inativo' });
        }
        
        const isValidPassword = await bcrypt.compare(password, user.passwordHash);
        
        if (!isValidPassword) {
          return done(null, false, { message: 'Email ou senha incorretos' });
        }
        
        return done(null, user);
      } catch (error) {
        return done(error);
      }
    }
  )
);
```

**Microsoft Strategy** - OAuth2 via OpenID Connect:
```typescript
const microsoftStrategy = new Issuer({
  issuer: 'https://login.microsoftonline.com/{tenant}/v2.0',
  authorization_endpoint: `https://login.microsoftonline.com/${tenant}/oauth2/v2.0/authorize`,
  token_endpoint: `https://login.microsoftonline.com/${tenant}/oauth2/v2.0/token`,
  userinfo_endpoint: 'https://graph.microsoft.com/oidc/userinfo',
});

const client = new microsoftStrategy.Client({
  client_id: process.env.MICROSOFT_CLIENT_ID,
  client_secret: process.env.MICROSOFT_CLIENT_SECRET,
  redirect_uris: [callbackURL],
  response_types: ['code'],
});

passport.use(
  'microsoft',
  new Strategy({ client }, async (tokenSet, userinfo, done) => {
    try {
      let user = await storage.getUserByMicrosoftId(userinfo.sub);
      
      if (!user) {
        // Criar novo usuário
        user = await storage.createUser({
          email: userinfo.email,
          fullName: userinfo.name,
          authProvider: 'microsoft',
          microsoftId: userinfo.sub,
          // ...
        });
      }
      
      return done(null, user);
    } catch (error) {
      return done(error);
    }
  })
);
```

#### JWT Tokens

**Geração:**
```typescript
const generateToken = (user: User): string => {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
      customRoleId: user.customRoleId,
      companyId: user.companyId,
      customerId: user.customerId,
    },
    process.env.JWT_SECRET!,
    { expiresIn: '7d' }
  );
};
```

**Verificação:**
```typescript
const verifyToken = (token: string): JwtPayload => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET!) as JwtPayload;
  } catch (error) {
    throw new Error('Token inválido');
  }
};
```

#### Middlewares de Autenticação

```typescript
// Require autenticação
const requireAuth = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Não autenticado' });
  }
  next();
};

// Require role específico
const requireRole = (role: string) => (req, res, next) => {
  if (!req.user || req.user.role !== role) {
    return res.status(403).json({ error: 'Sem permissão' });
  }
  next();
};

// Require admin
const requireAdmin = requireRole('admin');

// Require permissão específica
const requirePermission = (permission: string) => async (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Não autenticado' });
  }
  
  const hasPermission = await storage.checkUserPermission(
    req.user.id,
    permission
  );
  
  if (!hasPermission) {
    return res.status(403).json({ error: 'Sem permissão' });
  }
  
  next();
};

// Require acesso ao próprio cliente
const requireOwnCustomer = (req, res, next) => {
  const customerId = req.params.customerId || req.body.customerId;
  
  if (req.user.role === 'admin') {
    return next(); // Admin acessa tudo
  }
  
  if (req.user.customerId !== customerId) {
    return res.status(403).json({ error: 'Acesso negado' });
  }
  
  next();
};
```

### 3.5 Serialização de Dados

**Localização:** `server/utils/serialization.ts`

#### Problema

Drizzle ORM retorna objetos com tipos JavaScript nativos (Date, BigInt) que não são JSON-serializáveis por padrão.

#### Solução

Sistema centralizado de serialização que converte automaticamente:
- `Date` → ISO string
- `BigInt` → Number
- `undefined` → `null`

```typescript
/**
 * Serializa um objeto para ser JSON-safe
 */
export function serializeForJson<T>(obj: T): T {
  if (obj === null || obj === undefined) {
    return null as T;
  }
  
  if (obj instanceof Date) {
    return obj.toISOString() as unknown as T;
  }
  
  if (typeof obj === 'bigint') {
    return Number(obj) as unknown as T;
  }
  
  if (Array.isArray(obj)) {
    return obj.map(serializeForJson) as unknown as T;
  }
  
  if (typeof obj === 'object') {
    const serialized: any = {};
    for (const key in obj) {
      serialized[key] = serializeForJson(obj[key]);
    }
    return serialized;
  }
  
  return obj;
}

/**
 * Serializa array de objetos
 */
export function serializeArray<T>(items: T[]): T[] {
  return items.map(serializeForJson);
}
```

#### Uso nas Rotas

```typescript
// Antes (pode dar erro)
app.get('/api/customers', async (req, res) => {
  const customers = await storage.getCustomers();
  res.json(customers); // ❌ Pode falhar se houver Dates
});

// Depois (correto)
app.get('/api/customers', async (req, res) => {
  const customers = await storage.getCustomers();
  res.json(serializeArray(customers)); // ✅ JSON-safe
});
```

### 3.6 Configuração do Banco de Dados

**Localização:** `server/db.ts`

```typescript
import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import * as schema from '../shared/schema';

// Conexão com Neon PostgreSQL
const sql = neon(process.env.DATABASE_URL!);

// Cliente Drizzle
export const db = drizzle(sql, { schema });
```

**Drizzle Config:** `drizzle.config.ts`
```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './shared/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

**Comandos Drizzle:**
```bash
# Gerar migrations
npm run db:generate

# Aplicar migrations (push direto)
npm run db:push

# Aplicar migrations com força (sobrescreve)
npm run db:push --force

# Studio (UI visual)
npm run db:studio
```

---

## 4. Frontend

### 4.1 Arquitetura do Frontend

```
App.tsx (Root)
    ↓
Providers (QueryClient, Tooltip, Sidebar, Contexts)
    ↓
Layout (Sidebar + Header + Main)
    ↓
Router (wouter)
    ↓
Pages (Dashboard, Work Orders, etc)
    ↓
Components (shadcn/ui + Custom)
```

### 4.2 Roteamento

**Localização:** `client/src/App.tsx`

#### Estrutura de Rotas

```typescript
function Router() {
  return (
    <Switch>
      {/* Public Routes */}
      <Route path="/" component={LandingPage} />
      <Route path="/login" component={LoginPage} />
      <Route path="/select-module" component={ModuleSelection} />
      
      {/* QR Public */}
      <Route path="/qr/:code" component={QRScanPage} />
      <Route path="/public-request" component={PublicRequestPage} />
      
      {/* Protected Routes */}
      <Route path="/dashboard">
        {(params) => (
          <ProtectedRoute>
            <Dashboard />
          </ProtectedRoute>
        )}
      </Route>
      
      <Route path="/work-orders" component={WorkOrdersPage} />
      <Route path="/work-orders/:id" component={WorkOrderDetailPage} />
      
      <Route path="/cleaning-activities" component={CleaningActivitiesPage} />
      <Route path="/checklist-templates" component={ChecklistTemplatesPage} />
      
      <Route path="/equipment" component={EquipmentPage} />
      <Route path="/maintenance-plans" component={MaintenancePlansPage} />
      
      <Route path="/sites" component={SitesPage} />
      <Route path="/zones" component={ZonesPage} />
      
      <Route path="/users" component={UsersPage} />
      <Route path="/roles" component={RolesPage} />
      
      <Route path="/ai-integrations" component={AIIntegrationsPage} />
      
      <Route path="/tv-mode" component={TVModePage} />
      
      {/* 404 */}
      <Route component={NotFound} />
    </Switch>
  );
}
```

#### Protected Routes

```typescript
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { data: user, isLoading } = useQuery({
    queryKey: ['/api/auth/me'],
  });
  
  const [, setLocation] = useLocation();
  
  useEffect(() => {
    if (!isLoading && !user) {
      setLocation('/login');
    }
  }, [user, isLoading, setLocation]);
  
  if (isLoading) {
    return <LoadingSpinner />;
  }
  
  if (!user) {
    return null;
  }
  
  return <>{children}</>;
}
```

### 4.3 Gerenciamento de Estado

#### TanStack Query Configuration

**Localização:** `client/src/lib/queryClient.ts`

```typescript
import { QueryClient } from '@tanstack/react-query';

// Função padrão de fetch
async function apiRequest(url: string, options: RequestInit = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    credentials: 'include',
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Erro na requisição');
  }
  
  return response.json();
}

// Query function padrão
function getQueryFn(queryKey: string[]) {
  return async () => {
    const url = queryKey[0];
    return apiRequest(url);
  };
}

// Query Client
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: ({ queryKey }) => getQueryFn(queryKey as string[])(),
      staleTime: 1000 * 60 * 5, // 5 minutos
      retry: 1,
    },
  },
});

export { apiRequest };
```

#### Uso em Componentes

**Queries (GET):**
```typescript
// Lista de clientes
const { data: customers, isLoading } = useQuery({
  queryKey: ['/api/customers'],
});

// Detalhes de um cliente
const { data: customer } = useQuery({
  queryKey: ['/api/customers', customerId],
  enabled: !!customerId,
});

// Com filtros
const { data: workOrders } = useQuery({
  queryKey: ['/api/work-orders', { status, customerId }],
  queryFn: async () => {
    const params = new URLSearchParams();
    if (status) params.append('status', status);
    if (customerId) params.append('customerId', customerId);
    return apiRequest(`/api/work-orders?${params}`);
  },
});
```

**Mutations (POST/PUT/DELETE):**
```typescript
import { useMutation } from '@tanstack/react-query';
import { apiRequest, queryClient } from '@/lib/queryClient';

// Criar cliente
const createMutation = useMutation({
  mutationFn: async (data: InsertCustomer) => {
    return apiRequest('/api/customers', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  },
  onSuccess: () => {
    // Invalidar cache
    queryClient.invalidateQueries({ queryKey: ['/api/customers'] });
    toast({ title: 'Cliente criado com sucesso!' });
  },
  onError: (error) => {
    toast({ 
      title: 'Erro ao criar cliente',
      description: error.message,
      variant: 'destructive',
    });
  },
});

// Usar mutation
const handleSubmit = (data: InsertCustomer) => {
  createMutation.mutate(data);
};

// Atualizar
const updateMutation = useMutation({
  mutationFn: async ({ id, data }: { id: string; data: Partial<InsertCustomer> }) => {
    return apiRequest(`/api/customers/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  },
  onSuccess: (_, variables) => {
    queryClient.invalidateQueries({ queryKey: ['/api/customers'] });
    queryClient.invalidateQueries({ queryKey: ['/api/customers', variables.id] });
  },
});

// Deletar
const deleteMutation = useMutation({
  mutationFn: async (id: string) => {
    return apiRequest(`/api/customers/${id}`, {
      method: 'DELETE',
    });
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['/api/customers'] });
  },
});
```

### 4.4 Context Providers

#### ClientContext - Gestão de Cliente Ativo

**Localização:** `client/src/contexts/ClientContext.tsx`

```typescript
interface ClientContextType {
  activeCustomerId: string | null;
  setActiveCustomerId: (id: string | null) => void;
  activeCustomer: Customer | undefined;
}

export function ClientProvider({ children }: { children: React.ReactNode }) {
  const [activeCustomerId, setActiveCustomerId] = useState<string | null>(() => {
    return localStorage.getItem('activeCustomerId');
  });
  
  const { data: activeCustomer } = useQuery({
    queryKey: ['/api/customers', activeCustomerId],
    enabled: !!activeCustomerId,
  });
  
  useEffect(() => {
    if (activeCustomerId) {
      localStorage.setItem('activeCustomerId', activeCustomerId);
    } else {
      localStorage.removeItem('activeCustomerId');
    }
  }, [activeCustomerId]);
  
  return (
    <ClientContext.Provider value={{ 
      activeCustomerId, 
      setActiveCustomerId,
      activeCustomer,
    }}>
      {children}
    </ClientContext.Provider>
  );
}

// Hook
export function useClient() {
  const context = useContext(ClientContext);
  if (!context) {
    throw new Error('useClient must be used within ClientProvider');
  }
  return context;
}
```

#### ModuleContext - Gestão de Módulo Ativo

**Localização:** `client/src/contexts/ModuleContext.tsx`

```typescript
type ModuleType = 'clean' | 'maintenance' | null;

interface ModuleContextType {
  activeModule: ModuleType;
  setActiveModule: (module: ModuleType) => void;
  moduleColor: string;
  moduleTheme: string;
}

export function ModuleProvider({ children }: { children: React.ReactNode }) {
  const [activeModule, setActiveModule] = useState<ModuleType>(() => {
    return localStorage.getItem('activeModule') as ModuleType || null;
  });
  
  const moduleColor = activeModule === 'clean' ? 'blue' : 
                      activeModule === 'maintenance' ? 'orange' : 'gray';
  
  const moduleTheme = `module-${activeModule || 'default'}`;
  
  useEffect(() => {
    if (activeModule) {
      localStorage.setItem('activeModule', activeModule);
      document.body.setAttribute('data-module', activeModule);
    } else {
      localStorage.removeItem('activeModule');
      document.body.removeAttribute('data-module');
    }
  }, [activeModule]);
  
  return (
    <ModuleContext.Provider value={{
      activeModule,
      setActiveModule,
      moduleColor,
      moduleTheme,
    }}>
      {children}
    </ModuleContext.Provider>
  );
}
```

### 4.5 Sistema de Formulários

#### React Hook Form + Zod

Exemplo de formulário completo:

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { insertCustomerSchema, type InsertCustomer } from '@shared/schema';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

export function CustomerForm({ onSubmit, defaultValues }: CustomerFormProps) {
  const form = useForm<InsertCustomer>({
    resolver: zodResolver(insertCustomerSchema),
    defaultValues: defaultValues || {
      name: '',
      email: '',
      phone: '',
      document: '',
      isActive: true,
    },
  });
  
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Nome</FormLabel>
              <FormControl>
                <Input {...field} data-testid="input-name" />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" {...field} data-testid="input-email" />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        
        {/* Mais campos... */}
        
        <Button type="submit" data-testid="button-submit">
          {defaultValues ? 'Atualizar' : 'Criar'}
        </Button>
      </form>
    </Form>
  );
}
```

### 4.6 Componentes Principais

#### Sidebar Navigation

**Localização:** `client/src/components/app-sidebar.tsx`

```typescript
import { Sidebar, SidebarContent, SidebarGroup, SidebarMenu } from '@/components/ui/sidebar';
import { useClient } from '@/contexts/ClientContext';
import { useModule } from '@/contexts/ModuleContext';

export function AppSidebar() {
  const { activeModule } = useModule();
  const { activeCustomer } = useClient();
  
  const cleanMenuItems = [
    { title: 'Dashboard', url: '/dashboard', icon: LayoutDashboard },
    { title: 'Calendário', url: '/schedule', icon: Calendar },
    { title: 'Atividades', url: '/cleaning-activities', icon: ClipboardCheck },
    { title: 'Checklists', url: '/checklist-templates', icon: CheckSquare },
    { title: 'Ordens de Serviço', url: '/work-orders', icon: FileText },
  ];
  
  const maintenanceMenuItems = [
    { title: 'Dashboard', url: '/dashboard', icon: LayoutDashboard },
    { title: 'Equipamentos', url: '/equipment', icon: Wrench },
    { title: 'Planos', url: '/maintenance-plans', icon: Calendar },
    { title: 'Checklists', url: '/checklist-templates', icon: CheckSquare },
    { title: 'Ordens de Serviço', url: '/work-orders', icon: FileText },
  ];
  
  const menuItems = activeModule === 'clean' ? cleanMenuItems : 
                    activeModule === 'maintenance' ? maintenanceMenuItems : [];
  
  return (
    <Sidebar>
      <SidebarContent>
        <SidebarGroup>
          <div className="px-4 py-2">
            <h2 className="font-bold">{activeCustomer?.name}</h2>
            <p className="text-sm text-muted-foreground">
              {activeModule === 'clean' ? 'Limpeza' : 'Manutenção'}
            </p>
          </div>
          
          <SidebarMenu>
            {menuItems.map((item) => (
              <SidebarMenuItem key={item.url}>
                <SidebarMenuButton asChild>
                  <Link href={item.url}>
                    <item.icon className="w-4 h-4" />
                    <span>{item.title}</span>
                  </Link>
                </SidebarMenuButton>
              </SidebarMenuItem>
            ))}
          </SidebarMenu>
        </SidebarGroup>
      </SidebarContent>
    </Sidebar>
  );
}
```

#### Data Tables

Exemplo de tabela com shadcn:

```typescript
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';

export function CustomersTable({ customers }: { customers: Customer[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Nome</TableHead>
          <TableHead>Email</TableHead>
          <TableHead>Telefone</TableHead>
          <TableHead>Status</TableHead>
          <TableHead>Ações</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {customers.map((customer) => (
          <TableRow key={customer.id} data-testid={`row-customer-${customer.id}`}>
            <TableCell data-testid={`text-name-${customer.id}`}>
              {customer.name}
            </TableCell>
            <TableCell>{customer.email}</TableCell>
            <TableCell>{customer.phone}</TableCell>
            <TableCell>
              <Badge variant={customer.isActive ? 'default' : 'secondary'}>
                {customer.isActive ? 'Ativo' : 'Inativo'}
              </Badge>
            </TableCell>
            <TableCell>
              <Button 
                size="sm" 
                variant="ghost"
                data-testid={`button-edit-${customer.id}`}
              >
                <Pencil className="w-4 h-4" />
              </Button>
              <Button 
                size="sm" 
                variant="ghost"
                data-testid={`button-delete-${customer.id}`}
              >
                <Trash className="w-4 h-4" />
              </Button>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

### 4.7 Tema e Estilos

#### Tailwind Configuration

**Localização:** `tailwind.config.ts`

```typescript
export default {
  darkMode: ["class"],
  content: [
    "./client/index.html",
    "./client/src/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Módulo Clean (azul)
        'clean-primary': 'hsl(221, 83%, 53%)',
        'clean-hover': 'hsl(221, 83%, 43%)',
        
        // Módulo Maintenance (laranja)
        'maintenance-primary': 'hsl(24, 95%, 53%)',
        'maintenance-hover': 'hsl(24, 95%, 43%)',
        
        // shadcn color system
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        // ... mais cores
      },
    },
  },
  plugins: [
    require("tailwindcss-animate"),
    require("@tailwindcss/typography"),
  ],
};
```

#### CSS Variables

**Localização:** `client/src/index.css`

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    
    --primary: 221 83% 53%;
    --primary-foreground: 210 40% 98%;
    
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    
    /* ... mais variáveis */
  }
  
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    
    /* ... mais variáveis dark */
  }
  
  /* Módulo Clean */
  [data-module="clean"] {
    --primary: 221 83% 53%;
    --primary-foreground: 210 40% 98%;
  }
  
  /* Módulo Maintenance */
  [data-module="maintenance"] {
    --primary: 24 95% 53%;
    --primary-foreground: 60 9% 98%;
  }
}
```

---

## 5. Funcionalidades Principais

### 5.1 Dashboard

**Localização:** `client/src/pages/dashboard.tsx`

#### Funcionalidades

- Estatísticas em tempo real (OSs pendentes, em andamento, concluídas)
- Gráficos de distribuição de OSs por prioridade
- Gráficos de distribuição por localização
- Tempo médio de conclusão
- Tendências de atividades
- Filtros por cliente, módulo, período

#### Queries Principais

```typescript
// Stats gerais
const { data: stats } = useQuery({
  queryKey: ['/api/dashboard/stats', { customerId, module }],
});

// Dados para gráficos
const { data: charts } = useQuery({
  queryKey: ['/api/dashboard/charts', { customerId, module, period }],
});
```

### 5.2 TV Mode Dashboard

**Localização:** `client/src/pages/tv-mode.tsx`

#### Características

- **Auto-refresh a cada 10 segundos**
- Design otimizado para telas grandes
- Métricas em tempo real
- Leaderboard gamificado (Top 10 colaboradores)
- Gráfico de donut para OSs resolvidas vs não resolvidas
- Filtrado por cliente e módulo ativo

#### Implementação

```typescript
export function TVModePage() {
  const { activeCustomerId } = useClient();
  const { activeModule } = useModule();
  
  // Auto-refresh a cada 10 segundos
  const { data: stats } = useQuery({
    queryKey: ['/api/tv-mode/stats', { customerId: activeCustomerId, module: activeModule }],
    refetchInterval: 10000, // 10 segundos
  });
  
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800 p-8">
      <div className="grid grid-cols-3 gap-6">
        {/* Métricas */}
        <MetricCard 
          title="OSs Resolvidas" 
          value={stats?.resolvedCount} 
          icon={CheckCircle}
          color="green"
        />
        <MetricCard 
          title="OSs Pendentes" 
          value={stats?.pendingCount} 
          icon={Clock}
          color="yellow"
        />
        <MetricCard 
          title="Em Andamento" 
          value={stats?.inProgressCount} 
          icon={Activity}
          color="blue"
        />
      </div>
      
      {/* Gráfico de donut */}
      <div className="mt-8">
        <DonutChart data={stats?.chartData} />
      </div>
      
      {/* Leaderboard */}
      <div className="mt-8">
        <h2 className="text-2xl font-bold text-white mb-4">
          Top 10 Colaboradores
        </h2>
        <LeaderboardTable users={stats?.topUsers} />
      </div>
    </div>
  );
}
```

### 5.3 Work Orders (Ordens de Serviço)

**Localização:** `client/src/pages/work-orders.tsx`

#### Fluxo de Estados

```
Pendente → Em Andamento → Concluída
    ↓            ↓
Cancelada    Cancelada
```

#### Tipos de OS

1. **Programada** - Criada automaticamente pelo scheduler
2. **Corretiva Interna** - Criada manualmente por usuários internos
3. **Corretiva Pública** - Criada via QR Code público

#### Funcionalidades

- **Listagem** com filtros (status, prioridade, data, responsável)
- **Criação manual** de OSs corretivas
- **Atribuição** de responsáveis (múltiplos)
- **Execução de checklist** com validação
- **Comentários** com fotos
- **Transições de estado**:
  - `Iniciar` (pendente → em_andamento)
  - `Completar` (em_andamento → concluída)
  - `Cancelar` (qualquer → cancelada)
- **SLA tracking** e alertas
- **Histórico completo** de alterações

#### Exemplo de Transição

```typescript
const startMutation = useMutation({
  mutationFn: async (workOrderId: string) => {
    return apiRequest(`/api/work-orders/${workOrderId}/start`, {
      method: 'POST',
    });
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['/api/work-orders'] });
    toast({ title: 'OS iniciada com sucesso!' });
  },
});

const completeMutation = useMutation({
  mutationFn: async ({ 
    workOrderId, 
    checklistResponses 
  }: { 
    workOrderId: string; 
    checklistResponses: any; 
  }) => {
    return apiRequest(`/api/work-orders/${workOrderId}/complete`, {
      method: 'POST',
      body: JSON.stringify({ checklistResponses }),
    });
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['/api/work-orders'] });
    toast({ title: 'OS concluída com sucesso!' });
  },
});
```

### 5.4 Cleaning Activities (Atividades de Limpeza)

**Localização:** `client/src/pages/cleaning-activities.tsx`

#### Funcionalidades

- **CRUD completo** de atividades
- **Configuração de frequência**:
  - Diária (X vezes por dia)
  - Semanal (dias da semana)
  - Quinzenal
  - Mensal (dia do mês)
  - Por turno (manhã, tarde, noite)
- **Associação com checklist template**
- **Configuração de SLA**
- **Horários de início/fim**
- **Vinculação**: Serviço → Site → Zona

#### Scheduler Automático

O sistema possui um scheduler que:
- Roda a cada hora
- Cria Work Orders automaticamente baseado nas atividades
- Respeita a configuração de frequência
- Atribui checklist template
- Aplica SLA configurado

### 5.5 Equipment & Maintenance Plans

**Localização:** `client/src/pages/equipment.tsx`, `client/src/pages/maintenance-plans.tsx`

#### Equipment (Equipamentos)

**Funcionalidades:**
- Cadastro completo de equipamentos
- Informações técnicas (fabricante, modelo, serial)
- Status (operacional, manutenção, inativo, quebrado)
- Criticidade (baixa, média, alta, crítica)
- Especificações em JSON
- Histórico de Work Orders
- Localização (Site + Zona)

#### Maintenance Plans (Planos de Manutenção)

**Funcionalidades:**
- Planos de manutenção preventiva
- Frequências variadas (diária, semanal, mensal, trimestral, semestral, anual)
- Associação com equipamento
- Checklist template
- Próxima execução calculada automaticamente
- Geração automática de Work Orders

### 5.6 Sistema de QR Codes

**Tipos de QR Code:**

#### 1. QR de Execução

**Uso:** Colaboradores escaneiam para executar OSs

**Fluxo:**
1. Colaborador escaneia QR Code fixo em uma zona
2. Sistema lista OSs pendentes/em andamento daquela zona
3. Colaborador seleciona OS para executar
4. Preenche checklist
5. Adiciona fotos e comentários
6. Completa OS

**Implementação:**
```typescript
// Escanear QR
const { data: qrData } = useQuery({
  queryKey: ['/api/qr-scan', code],
});

// Listar OSs da zona
const { data: workOrders } = useQuery({
  queryKey: ['/api/work-orders', { zoneId: qrData.zoneId, status: ['pendente', 'em_andamento'] }],
  enabled: !!qrData?.zoneId,
});
```

#### 2. QR Público

**Uso:** Clientes finais solicitam serviços

**Fluxo:**
1. Cliente escaneia QR Code fixo em uma zona
2. Preenche formulário de solicitação
3. Sistema cria Work Order corretiva pública automaticamente
4. OS entra na fila para atendimento

**Implementação:**
```typescript
const submitPublicRequest = useMutation({
  mutationFn: async (data: PublicRequestData) => {
    return apiRequest('/api/qr-public-request', {
      method: 'POST',
      body: JSON.stringify({
        qrCodePointId: data.qrCodePointId,
        description: data.description,
        photos: data.photos,
      }),
    });
  },
  onSuccess: () => {
    toast({ 
      title: 'Solicitação enviada!',
      description: 'Sua solicitação foi recebida e será atendida em breve.',
    });
  },
});
```

### 5.7 Checklist Templates

**Localização:** `client/src/pages/checklist-templates.tsx`

#### Tipos de Items

1. **Checkbox** - Seleção múltipla
```json
{
  "id": "item-123",
  "type": "checkbox",
  "label": "Limpeza de pias, vasos e espelhos",
  "options": ["OK", "NOK"],
  "required": true,
  "validation": {
    "minChecked": 1,
    "maxChecked": 2
  }
}
```

2. **Text** - Texto livre
```json
{
  "id": "item-456",
  "type": "text",
  "label": "Observações gerais",
  "required": false,
  "validation": {
    "minLength": 10,
    "maxLength": 500
  }
}
```

3. **Photo** - Upload de fotos
```json
{
  "id": "item-789",
  "type": "photo",
  "label": "Evidência fotográfica",
  "required": true,
  "validation": {
    "photoMinCount": 1,
    "photoMaxCount": 3,
    "photoRequired": true
  }
}
```

#### Builder de Checklist

Interface visual para criar checklists:
- Arrastar e soltar items
- Configurar validações
- Preview em tempo real
- Exportar/Importar JSON

### 5.8 AI Integrations

**Localização:** `client/src/pages/ai-integrations.tsx`

#### Providers Suportados

1. **OpenAI** (GPT-4, GPT-3.5)
2. **Google Gemini**
3. **Groq** (Llama, Mixtral)
4. **Azure OpenAI**
5. **Cohere**
6. **Anthropic Claude**

#### Funcionalidades

- **Configuração de múltiplas integrações**
- **Teste de conexão**
- **Seleção de provider padrão**
- **Configuração de modelos**
- **Gerenciamento de API keys** (criptografadas)
- **Status de disponibilidade**

**Nota:** O chat assistant está temporariamente desabilitado e em desenvolvimento.

#### Schema de Integração

```typescript
{
  id: string
  company_id: string
  provider: 'openai' | 'google' | 'groq' | 'azure' | 'cohere' | 'anthropic'
  name: string
  api_key: string // criptografado
  model: string
  config: jsonb // configurações específicas do provider
  is_default: boolean
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

---

## 6. Segurança

### 6.1 Sistema de Roles e Permissões

#### Roles Padrão (System Roles)

1. **admin** (OPUS)
   - Acesso total ao sistema
   - Gerenciamento de empresas
   - Gerenciamento de clientes
   - Configurações globais

2. **operador** (Campo)
   - Executar OSs via mobile
   - Escanear QR Codes
   - Preencher checklists
   - Adicionar comentários e fotos

3. **cliente** (Cliente Final)
   - Visualizar dashboards
   - Visualizar OSs do próprio cliente
   - Comentar e avaliar OSs
   - Visualizar relatórios

4. **auditor** (OPUS)
   - Visualizar tudo
   - Gerar relatórios
   - Sem permissões de edição

#### Custom Roles

Administradores podem criar roles customizados com permissões granulares:

```typescript
const customRole = {
  name: 'Supervisor de Limpeza',
  description: 'Supervisiona atividades de limpeza',
  permissions: [
    'cleaning_activities_view',
    'cleaning_activities_edit',
    'work_orders_view',
    'work_orders_edit',
    'work_orders_assign',
    'users_view',
    'reports_view',
  ],
};
```

#### Lista de Permissões

**Dashboard:**
- `dashboard_view`
- `tv_mode_access`

**Work Orders:**
- `workorders_view`
- `workorders_create`
- `workorders_edit`
- `workorders_delete`
- `workorders_assign`
- `workorders_start`
- `workorders_complete`
- `workorders_cancel`
- `workorders_comment`
- `workorders_evaluate`

**Cleaning Activities:**
- `cleaning_activities_view`
- `cleaning_activities_create`
- `cleaning_activities_edit`
- `cleaning_activities_delete`

**Checklist Templates:**
- `checklist_templates_view`
- `checklist_templates_create`
- `checklist_templates_edit`
- `checklist_templates_delete`

**Equipment (Maintenance):**
- `equipment_view`
- `equipment_create`
- `equipment_edit`
- `equipment_delete`

**Sites & Zones:**
- `sites_view`
- `sites_create`
- `sites_edit`
- `sites_delete`
- `zones_view`
- `zones_create`
- `zones_edit`
- `zones_delete`

**Users:**
- `opus_users_view`
- `opus_users_create`
- `opus_users_edit`
- `opus_users_delete`
- `client_users_view`
- `client_users_create`
- `client_users_edit`
- `client_users_delete`

**Customers:**
- `customers_view`
- `customers_create`
- `customers_edit`
- `customers_delete`

**Roles:**
- `roles_manage`

**Reports:**
- `reports_view`
- `reports_export`

**Service Settings:**
- `service_settings_view`
- `service_settings_edit`

**Audit Logs:**
- `audit_logs_view`

### 6.2 Proteção de Rotas

#### Backend

```typescript
// Middleware stack para uma rota protegida
app.get('/api/customers',
  requireAuth,                              // 1. Autenticado?
  requirePermission('customers_view'),      // 2. Tem permissão?
  async (req, res) => {
    // Se admin, ver todos
    if (req.user.role === 'admin') {
      const customers = await storage.getCustomers();
      return res.json(serializeArray(customers));
    }
    
    // Se não admin, ver apenas do próprio company
    const customers = await storage.getCustomers(req.user.companyId);
    res.json(serializeArray(customers));
  }
);

// Proteção por propriedade do cliente
app.put('/api/customers/:id',
  requireAuth,
  requirePermission('customers_edit'),
  requireOwnCustomer,                       // 3. É do próprio cliente?
  async (req, res) => {
    // Atualizar cliente
  }
);
```

#### Frontend

```typescript
// Higher-Order Component para proteção
function ProtectedRoute({ 
  children, 
  requiredPermission 
}: { 
  children: React.ReactNode;
  requiredPermission?: string;
}) {
  const { data: user, isLoading } = useQuery({
    queryKey: ['/api/auth/me'],
  });
  
  const [, setLocation] = useLocation();
  
  useEffect(() => {
    if (!isLoading && !user) {
      setLocation('/login');
      return;
    }
    
    if (requiredPermission && !user?.permissions?.includes(requiredPermission)) {
      setLocation('/unauthorized');
    }
  }, [user, isLoading, requiredPermission]);
  
  if (isLoading) return <LoadingSpinner />;
  if (!user) return null;
  if (requiredPermission && !user.permissions?.includes(requiredPermission)) {
    return null;
  }
  
  return <>{children}</>;
}

// Uso
<Route path="/customers">
  {() => (
    <ProtectedRoute requiredPermission="customers_view">
      <CustomersPage />
    </ProtectedRoute>
  )}
</Route>
```

### 6.3 Validação de Dados

#### Zod Schemas

Todos os dados são validados usando Zod tanto no frontend quanto no backend:

```typescript
// shared/schema.ts
import { z } from 'zod';
import { createInsertSchema } from 'drizzle-zod';

// Schema Drizzle
export const customers = pgTable('customers', {
  id: varchar('id').primaryKey(),
  companyId: varchar('company_id').notNull().references(() => companies.id),
  name: text('name').notNull(),
  email: text('email'),
  phone: text('phone'),
  document: text('document'),
  isActive: boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

// Schema Zod para inserção
export const insertCustomerSchema = createInsertSchema(customers, {
  email: z.string().email('Email inválido').optional(),
  phone: z.string().min(10, 'Telefone inválido').optional(),
  name: z.string().min(3, 'Nome deve ter no mínimo 3 caracteres'),
}).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

// Type para TypeScript
export type InsertCustomer = z.infer<typeof insertCustomerSchema>;
export type Customer = typeof customers.$inferSelect;
```

#### Validação no Backend

```typescript
app.post('/api/customers', requireAuth, async (req, res) => {
  try {
    // Validar dados
    const validatedData = insertCustomerSchema.parse(req.body);
    
    // Criar cliente
    const customer = await storage.createCustomer(validatedData);
    
    res.json(serializeForJson(customer));
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ 
        error: 'Dados inválidos',
        details: error.errors,
      });
    }
    res.status(500).json({ error: 'Erro ao criar cliente' });
  }
});
```

### 6.4 Segurança de Senhas

#### Hashing com Bcrypt

```typescript
import bcrypt from 'bcryptjs';

// Criar senha
const hashedPassword = await bcrypt.hash(plainPassword, 12);

// Verificar senha
const isValid = await bcrypt.compare(plainPassword, hashedPassword);
```

#### Política de Senhas

- Mínimo 8 caracteres
- Pelo menos 1 letra maiúscula
- Pelo menos 1 letra minúscula
- Pelo menos 1 número
- Validação via Zod:

```typescript
const passwordSchema = z.string()
  .min(8, 'Senha deve ter no mínimo 8 caracteres')
  .regex(/[a-z]/, 'Senha deve conter pelo menos uma letra minúscula')
  .regex(/[A-Z]/, 'Senha deve conter pelo menos uma letra maiúscula')
  .regex(/[0-9]/, 'Senha deve conter pelo menos um número');
```

### 6.5 Criptografia de API Keys

API keys de integrações (OpenAI, etc) são criptografadas antes de serem salvas:

```typescript
import crypto from 'crypto';

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY!;
const ALGORITHM = 'aes-256-cbc';

export function encryptApiKey(apiKey: string): string {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(ALGORITHM, Buffer.from(ENCRYPTION_KEY, 'hex'), iv);
  
  let encrypted = cipher.update(apiKey, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  return iv.toString('hex') + ':' + encrypted;
}

export function decryptApiKey(encrypted: string): string {
  const parts = encrypted.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const encryptedText = parts[1];
  
  const decipher = crypto.createDecipheriv(ALGORITHM, Buffer.from(ENCRYPTION_KEY, 'hex'), iv);
  
  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
```

### 6.6 Rate Limiting

#### Login Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 tentativas
  message: 'Muitas tentativas de login. Tente novamente em 15 minutos.',
  standardHeaders: true,
  legacyHeaders: false,
});

app.post('/api/auth/login', loginLimiter, async (req, res) => {
  // Login logic
});
```

#### API Rate Limiting

```typescript
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minuto
  max: 100, // máximo 100 requisições por minuto
  message: 'Muitas requisições. Tente novamente em breve.',
});

app.use('/api', apiLimiter);
```

### 6.7 CORS e Headers de Segurança

#### CORS

```typescript
import cors from 'cors';

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
```

#### Helmet.js

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));
```

---

## 7. Configurações e Deploy

### 7.1 Variáveis de Ambiente

**Arquivo:** `.env` (não commitado)

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/database
PGHOST=host
PGPORT=5432
PGUSER=user
PGPASSWORD=password
PGDATABASE=database

# Authentication
JWT_SECRET=your-super-secret-jwt-key-here
SESSION_SECRET=your-super-secret-session-key-here

# Encryption (para API keys)
ENCRYPTION_KEY=your-256-bit-hex-encryption-key-here

# Microsoft OAuth (opcional)
MICROSOFT_CLIENT_ID=your-microsoft-app-id
MICROSOFT_CLIENT_SECRET=your-microsoft-app-secret
MICROSOFT_TENANT_ID=your-microsoft-tenant-id

# Frontend (opcional - Vite)
VITE_API_URL=http://localhost:5000

# Environment
NODE_ENV=development
```

### 7.2 Scripts NPM

**Localização:** `package.json`

```json
{
  "scripts": {
    "dev": "tsx server/index.ts",
    "build": "vite build && tsc",
    "preview": "vite preview",
    "db:generate": "drizzle-kit generate",
    "db:push": "drizzle-kit push",
    "db:studio": "drizzle-kit studio",
    "db:import": "tsx scripts/import-dump.ts"
  }
}
```

**Comandos:**

```bash
# Desenvolvimento
npm run dev              # Inicia servidor dev (Express + Vite)

# Build para produção
npm run build           # Build do frontend + compilação TS

# Database
npm run db:generate     # Gera migrations a partir do schema
npm run db:push         # Aplica schema ao banco (push direto)
npm run db:studio       # Abre Drizzle Studio (UI visual)
npm run db:import       # Importa dump SQL

# Preview produção
npm run preview         # Preview do build de produção
```

### 7.3 Workflow do Replit

**Nome:** "Start application"  
**Comando:** `npm run dev`

**Configuração:**
- **output_type:** `webview` (mostra preview web)
- **wait_for_port:** `5000` (aguarda porta 5000)

O servidor Express serve o frontend Vite na porta 5000, que é a única porta exposta publicamente pelo Replit.

### 7.4 Configuração Vite

**Localização:** `vite.config.ts`

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: '0.0.0.0',
    strictPort: false,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './client/src'),
      '@shared': path.resolve(__dirname, './shared'),
      '@assets': path.resolve(__dirname, './attached_assets'),
    },
  },
  build: {
    outDir: 'dist/client',
    emptyOutDir: true,
  },
});
```

**Aliases:**
- `@/` → `client/src/`
- `@shared/` → `shared/`
- `@assets/` → `attached_assets/`

### 7.5 Integração Express + Vite

**Localização:** `server/vite.ts` e `server/index.ts`

```typescript
// server/vite.ts
import { createServer as createViteServer } from 'vite';

export async function setupVite(app: Express) {
  if (process.env.NODE_ENV === 'production') {
    // Produção: servir arquivos estáticos do build
    app.use(express.static('dist/client'));
    app.get('*', (req, res) => {
      res.sendFile(path.join(__dirname, '../dist/client/index.html'));
    });
  } else {
    // Desenvolvimento: Vite dev server
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    
    app.use(vite.middlewares);
  }
}

// server/index.ts
import { setupVite } from './vite';

const app = express();

// ... middlewares, routes, etc

// Setup Vite (deve ser o último)
await setupVite(app);

app.listen(5000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:5000');
});
```

### 7.6 Deploy (Publishing)

Para fazer deploy no Replit:

1. **Configurar Deploy Config:**

```typescript
// Via deploy_config_tool ou .replit file
{
  deployment_target: 'autoscale',
  run: ['npm', 'run', 'dev'],
}
```

2. **Build de Produção:**

```bash
npm run build
```

3. **Publicar via UI:**
- Clicar em "Publish" no Replit
- Escolher domínio
- Confirmar deploy

4. **Variáveis de Ambiente:**
- Configurar todas as secrets necessárias via UI do Replit
- Incluir `DATABASE_URL`, `JWT_SECRET`, etc.

### 7.7 Estrutura de Banco de Dados

#### Criação Inicial

```bash
# 1. Criar database no Replit (PostgreSQL via Neon)
# Automaticamente cria variáveis DATABASE_URL, PGHOST, etc.

# 2. Aplicar schema
npm run db:push

# 3. (Opcional) Importar dados
npm run db:import
```

#### Migrations

O projeto usa **Drizzle Kit** com **push direto** (sem migrations versionadas):

```bash
# Modificar shared/schema.ts
# Depois:
npm run db:push

# Se houver conflitos:
npm run db:push --force
```

**Atenção:** `db:push --force` pode ser destrutivo. Use com cuidado em produção.

#### Backup

```bash
# Exportar dump
pg_dump $DATABASE_URL > backup.sql

# Importar dump
psql $DATABASE_URL < backup.sql
```

---

## 8. Observações Finais

### 8.1 Boas Práticas

1. **Sempre validar dados** com Zod em ambos frontend e backend
2. **Sempre serializar** dados do Drizzle antes de enviar ao frontend
3. **Sempre invalidar cache** do TanStack Query após mutations
4. **Sempre usar data-testid** em elementos interativos
5. **Sempre verificar permissões** antes de permitir ações sensíveis
6. **Sempre usar transações** para operações multi-tabela
7. **Sempre logar ações críticas** (audit logs)

### 8.2 Limitações Conhecidas

1. **AI Chat Assistant** - Temporariamente desabilitado (em desenvolvimento)
2. **Checklists templates** - Alguns têm `zone_id = NULL` no dump importado
3. **Mobile App** - Ainda não implementado (planejado)
4. **Notificações em tempo real** - Não implementadas (planejado WebSockets)
5. **Multi-idioma** - Apenas português por enquanto

### 8.3 Roadmap

**Próximas Features:**
- [ ] AI Chat Assistant funcional
- [ ] Notificações push via WebSocket
- [ ] Aplicativo mobile React Native
- [ ] Sistema de relatórios avançado
- [ ] Integração com calendários externos (Google Calendar, Outlook)
- [ ] Dashboard de custos por cliente
- [ ] Gamificação expandida
- [ ] Multi-idioma (EN, ES)

### 8.4 Manutenção

**Atualizações de Dependências:**
```bash
# Verificar outdated
npm outdated

# Atualizar
npm update

# Atualizar major versions (com cuidado)
npm install <package>@latest
```

**Limpeza de Cache:**
```bash
# NPM cache
npm cache clean --force

# Vite cache
rm -rf node_modules/.vite

# Build artifacts
rm -rf dist
```

**Logs:**
```bash
# Ver logs do servidor
npm run dev 2>&1 | tee server.log

# Ver logs do Drizzle
npm run db:studio
```

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar esta documentação
2. Verificar `replit.md`
3. Consultar logs do servidor
4. Contatar equipe de desenvolvimento

---

**Última atualização:** Novembro 2025  
**Versão:** 1.0  
**Autor:** Equipe Acelera it
