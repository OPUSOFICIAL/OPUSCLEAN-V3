# 🏢 OPUS - Guia Completo do Sistema

> **Documentação técnica completa para desenvolvedores e agentes Replit**  
> Última atualização: 08/11/2025

---

## 📑 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Estrutura de Pastas](#estrutura-de-pastas)
5. [Banco de Dados](#banco-de-dados)
6. [Fluxos Principais](#fluxos-principais)
7. [Autenticação e Autorização](#autenticação-e-autorização)
8. [Sistema Multi-Tenant](#sistema-multi-tenant)
9. [Sistema de Módulos](#sistema-de-módulos)
10. [Integrações e APIs](#integrações-e-apis)
11. [Como Fazer Modificações Comuns](#como-fazer-modificações-comuns)
12. [Debugging e Troubleshooting](#debugging-e-troubleshooting)
13. [Regras e Convenções](#regras-e-convenções)
14. [Deploy e Produção](#deploy-e-produção)

---

## 🎯 Visão Geral

### O que é OPUS?

OPUS é uma **plataforma modular de gestão de facilities** que oferece dois módulos principais:

- **OPUS Clean**: Gestão de limpeza e facilities
- **OPUS Manutenção**: Gestão de manutenção preventiva e corretiva

### Características Principais

- ✅ **Multi-tenant**: Suporta múltiplas empresas, clientes, locais e zonas
- ✅ **Modular**: Cada cliente pode ter um ou ambos os módulos
- ✅ **Web + Mobile**: Interface web para admin e mobile para colaboradores
- ✅ **Gestão de O.S**: Ordens de serviço programadas, corretivas internas e públicas
- ✅ **QR Codes**: Sistema de QR para execução de tarefas e solicitações públicas
- ✅ **IA Integrada**: Chat AI com Google Gemini para consultas e gestão de O.S
- ✅ **Checklists**: Templates e execução de checklists dinâmicos
- ✅ **Analytics**: Dashboards em tempo real com metas e KPIs

---

## 🏗️ Arquitetura do Sistema

### Arquitetura Geral

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (React)                      │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │  Web Admin  │  │ Mobile Web   │  │  Public Pages  │ │
│  │  Interface  │  │ (PWA/Native) │  │  (QR Public)   │ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST API
┌────────────────────▼────────────────────────────────────┐
│              BACKEND (Express + TypeScript)              │
│  ┌──────────┐  ┌───────────┐  ┌──────────────────────┐ │
│  │  Routes  │  │  Storage  │  │  Business Logic      │ │
│  │  Layer   │──▶│  Layer    │──▶│  (AI, Scheduler)    │ │
│  └──────────┘  └───────────┘  └──────────────────────┘ │
└────────────────────┬────────────────────────────────────┘
                     │ Drizzle ORM
┌────────────────────▼────────────────────────────────────┐
│            DATABASE (PostgreSQL/Neon)                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Multi-tenant data (Companies → Customers →      │  │
│  │  Sites → Zones → Work Orders, etc.)              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Camadas da Aplicação

#### 1. **Frontend (Client)**
- **React** com TypeScript
- **Wouter** para roteamento
- **TanStack Query** para data fetching e cache
- **shadcn/ui + Tailwind CSS** para componentes e estilos

#### 2. **Backend (Server)**
- **Express.js** com TypeScript
- **Drizzle ORM** para database
- **JWT + Bcrypt** para autenticação
- **Google Gemini API** para IA

#### 3. **Database**
- **PostgreSQL** (hosted no Neon)
- Schema totalmente tipado com Drizzle
- Hierarquia multi-tenant: `companies → customers → sites → zones`

---

## 🛠️ Stack Tecnológico

### Frontend

| Tecnologia | Propósito | Versão |
|-----------|----------|--------|
| React | UI Framework | 18.x |
| TypeScript | Type Safety | 5.x |
| Vite | Build Tool | 5.x |
| Wouter | Routing | 3.x |
| TanStack Query | Data Fetching | 5.x |
| shadcn/ui | Component Library | - |
| Tailwind CSS | Styling | 3.x |
| Radix UI | Primitives | - |
| Lucide React | Icons | - |
| Zod | Validation | 3.x |
| React Hook Form | Form Management | 7.x |

### Backend

| Tecnologia | Propósito |
|-----------|----------|
| Express.js | Web Framework |
| TypeScript | Type Safety |
| Drizzle ORM | Database ORM |
| Drizzle Zod | Schema Validation |
| PostgreSQL | Database |
| JWT | Authentication |
| Bcrypt | Password Hashing |
| Helmet | Security Headers |
| CORS | Cross-Origin Requests |
| Express Session | Session Management |
| Google Gemini | AI Integration |

### DevOps

- **Neon**: Serverless PostgreSQL hosting
- **Replit**: Development and hosting platform
- **GitHub**: Version control (implícito)

---

## 📁 Estrutura de Pastas

```
opus/
├── client/                        # Frontend React
│   └── src/
│       ├── components/            # Componentes React
│       │   ├── ui/               # shadcn/ui components
│       │   ├── modern-card.tsx   # Card moderno reutilizável
│       │   ├── ai-chat.tsx       # Chat AI component
│       │   └── ...
│       ├── pages/                # Páginas da aplicação
│       │   ├── Dashboard.tsx
│       │   ├── WorkOrders.tsx
│       │   ├── Checklists.tsx
│       │   ├── mobile/           # Páginas mobile
│       │   └── ...
│       ├── contexts/             # React Contexts
│       │   ├── AuthContext.tsx   # Autenticação
│       │   ├── ClientContext.tsx # Cliente ativo
│       │   └── ModuleContext.tsx # Módulo ativo
│       ├── hooks/                # Custom hooks
│       │   ├── use-toast.ts
│       │   ├── use-module-theme.ts
│       │   └── ...
│       ├── lib/                  # Utilities
│       │   ├── queryClient.ts    # TanStack Query setup
│       │   └── utils.ts
│       ├── App.tsx               # Main app component
│       └── main.tsx              # Entry point
│
├── server/                       # Backend Express
│   ├── index.ts                  # Server entry point
│   ├── routes.ts                 # API routes (4000+ linhas)
│   ├── storage.ts                # Database layer (6000+ linhas)
│   ├── vite.ts                   # Vite dev server integration
│   └── ...
│
├── shared/                       # Código compartilhado
│   └── schema.ts                 # Database schema (Drizzle)
│
├── backups/                      # Database backups
│   ├── opus_backup_*.sql
│   ├── README.md
│   └── restore_backup.sh
│
├── attached_assets/              # Assets (imagens, etc)
│
├── replit.md                     # Resumo do projeto
├── DOCUMENTATION.md              # Documentação técnica
├── SYSTEM_FLOW.md                # Fluxos do sistema
├── DATABASE_BACKUP_INFO.md       # Info sobre backups
├── OPUS_SYSTEM_GUIDE.md          # Este arquivo
│
├── package.json                  # Dependencies
├── tsconfig.json                 # TypeScript config
├── tailwind.config.ts            # Tailwind config
├── vite.config.ts                # Vite config
├── drizzle.config.ts             # Drizzle config
└── .env                          # Environment variables
```

### Arquivos Críticos

#### **shared/schema.ts** (Database Schema)
- Define **TODAS** as tabelas do banco
- Usa Drizzle ORM
- Exporta tipos TypeScript para frontend e backend
- Inclui schemas de validação Zod

#### **server/storage.ts** (Database Layer)
- Interface `IStorage` com todos os métodos CRUD
- Implementação `DbStorage` usando Drizzle
- **6000+ linhas** - centraliza TODA a lógica de acesso a dados
- Inclui lógica de AI (Google Gemini integration)

#### **server/routes.ts** (API Routes)
- Define **TODAS** as rotas REST API
- **4000+ linhas** - cada rota é bem documentada
- Validação de permissões e filtros multi-tenant
- Middlewares de autenticação

#### **client/src/App.tsx** (Main Router)
- Define todas as rotas do frontend
- Proteção de rotas baseada em autenticação e módulo
- Separação clara entre rotas web e mobile

---

## 🗄️ Banco de Dados

### Hierarquia Multi-Tenant

```
Companies (Empresas)
    ↓
Customers (Clientes)
    ↓
Sites (Locais)
    ↓
Zones (Zonas)
    ↓
Work Orders (Ordens de Serviço)
```

### Tabelas Principais

#### **Estrutura Organizacional**

```typescript
// companies
{
  id: string (PK)
  name: string
  createdBy: string
}

// customers
{
  id: string (PK)
  companyId: string (FK → companies)
  name: string
  modules: string[]  // ['clean', 'maintenance']
  createdBy: string
}

// sites (Locais)
{
  id: string (PK)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance'
  name: string
}

// zones
{
  id: string (PK)
  siteId: string (FK → sites)
  name: string
}
```

#### **Usuários e Autenticação**

```typescript
// users
{
  id: string (PK)
  email: string (unique)
  password: string (bcrypt hash)
  name: string
  companyId: string (FK → companies)
  customerId: string (FK → customers)
  modules: string[]  // ['clean', 'maintenance']
  role: string  // 'admin', 'manager', 'operator', etc.
  isMobileUser: boolean
  microsoftId: string (para SSO)
}
```

#### **Ordens de Serviço**

```typescript
// work_orders
{
  id: string (PK)
  number: number (auto-increment único por customer)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance'
  type: 'programada' | 'corretiva_interna' | 'corretiva_publica'
  status: 'aberta' | 'em_execucao' | 'pausada' | 'vencida' | 'concluida' | 'cancelada'
  priority: 'baixa' | 'media' | 'alta'
  title: string
  description: string
  siteId: string (FK → sites)
  zoneId: string (FK → zones)
  assignedUserId: string (FK → users)
  scheduledDate: date
  scheduledTime: time
  deadline: timestamp
  completedAt: timestamp
  slaConfigId: string (FK → sla_configs)
  // ... campos adicionais
}
```

#### **Checklists**

```typescript
// checklist_templates
{
  id: string (PK)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance'
  name: string
  items: JSON[]  // Array de perguntas/tarefas
}

// checklist_executions
{
  id: string (PK)
  workOrderId: string (FK → work_orders)
  templateId: string (FK → checklist_templates)
  responses: JSON  // Respostas do colaborador
  completedAt: timestamp
}
```

#### **Equipamentos (Módulo Manutenção)**

```typescript
// equipment
{
  id: string (PK)
  customerId: string (FK → customers)
  name: string
  tag: string (identificador único)
  category: string
  manufacturer: string
  model: string
  serialNumber: string
  acquisitionDate: date
  siteId: string (FK → sites)
  zoneId: string (FK → zones)
}
```

#### **Planos de Manutenção**

```typescript
// maintenance_plans
{
  id: string (PK)
  customerId: string (FK → customers)
  name: string
  description: string
}

// maintenance_activities
{
  id: string (PK)
  planId: string (FK → maintenance_plans)
  name: string
  type: 'preventiva' | 'preditiva' | 'rotina'
  frequency: 'daily' | 'weekly' | 'shift' | 'monthly' | 'quarterly' | 'semiannual' | 'annual'
  equipmentIds: string[]  // Array de equipment IDs
  checklistTemplateId: string (FK → checklist_templates)
  isActive: boolean
  // ... configurações de agendamento
}
```

#### **IA e Conversas**

```typescript
// ai_integrations
{
  id: string (PK)
  customerId: string (FK → customers)
  provider: 'google' | 'openai'
  apiKey: string (encrypted)
  model: string
  isActive: boolean
}

// ai_conversations
{
  id: string (PK)
  userId: string (FK → users)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance'
  title: string
  messages: JSON[]  // Array de mensagens
  lastMessageAt: timestamp
}
```

### Schema Management

**NUNCA modifique manualmente o banco de dados!**

1. **Modificar schema**: Edite `shared/schema.ts`
2. **Push para database**: `npm run db:push`
3. **Se houver warning de data loss**: `npm run db:push --force`

---

## 🔄 Fluxos Principais

### 1. Fluxo de Login

```
1. Usuário acessa /login
2. Frontend envia POST /api/auth/login com { email, password }
3. Backend verifica:
   - Usuário existe?
   - Senha correta (bcrypt)?
   - Módulos disponíveis?
4. Backend retorna JWT token + dados do usuário
5. Frontend armazena token no localStorage
6. Frontend redireciona para:
   - /dashboard (web admin)
   - /mobile/dashboard (mobile user)
```

### 2. Fluxo de Seleção de Cliente e Módulo

```
1. Usuário faz login
2. ClientContext carrega lista de clientes do usuário
3. Usuário seleciona cliente → armazenado no localStorage
4. ModuleContext verifica módulos disponíveis para aquele cliente
5. Se 1 módulo: auto-selecionado
6. Se 2+ módulos: usuário escolhe (dropdown no sidebar)
7. Todas as requisições incluem customerId + module nos filtros
```

### 3. Fluxo de Criação de Ordem de Serviço

```
1. Usuário clica "Nova O.S"
2. Frontend mostra formulário
3. Formulário carrega:
   - Locais do cliente + módulo ativo
   - Zonas do local selecionado
   - Colaboradores disponíveis
   - Templates de checklist
4. Usuário preenche e submete
5. Frontend envia POST /api/customers/:id/work-orders
6. Backend:
   - Valida dados (Zod schema)
   - Gera número único da O.S (auto-increment por customer)
   - Calcula deadline baseado em SLA
   - Salva no banco
7. Backend retorna O.S criada
8. Frontend invalida cache e mostra toast de sucesso
```

### 4. Fluxo de Execução de Checklist (Mobile)

```
1. Colaborador escaneia QR Code
2. QR Code redireciona para /mobile/execute-qr/:code
3. Frontend carrega dados do QR:
   - O.S associada
   - Template de checklist
   - Itens do checklist
4. Colaborador responde cada item (sim/não, texto, foto)
5. Ao finalizar, frontend envia:
   - POST /api/checklist-executions (salva respostas)
   - PATCH /api/work-orders/:id (atualiza status para "concluida")
6. Sistema atualiza timestamp de conclusão
```

### 5. Fluxo de Geração Automática de O.S Mensais

```
1. Scheduler roda no último dia de cada mês às 23:00
2. Backend busca todas as maintenance_activities com isActive=true
3. Para cada atividade:
   - Calcula datas de O.S para o próximo mês baseado em frequency
   - Para cada equipamento vinculado:
     - Cria uma O.S programada
     - Vincula checklist template
     - Define deadline
     - Status inicial: "aberta"
4. Logger registra quantas O.S foram criadas
```

### 6. Fluxo de Chat AI

```
1. Usuário digita mensagem no chat
2. Frontend envia POST /api/chat/message
3. Backend:
   - Busca ou cria conversation (userId + customerId + module)
   - Adiciona mensagem do usuário ao histórico
   - Busca integração AI ativa do cliente
   - Prepara contexto:
     - Data atual
     - Período do mês
     - Módulo ativo
     - O.S do dia
   - Chama Google Gemini API com:
     - System prompt (instruções + contexto)
     - Histórico de mensagens
     - Function declarations (ferramentas disponíveis)
   - Se AI chamar função:
     - Executa função (queryWorkOrders, updateWorkOrder, etc)
     - Retorna resultado para AI
     - AI gera resposta final
4. Backend salva resposta da AI no histórico
5. Frontend exibe resposta em tempo real
```

---

## 🔐 Autenticação e Autorização

### Métodos de Autenticação

#### 1. **Email/Password**
- Password hash com **Bcrypt** (10 rounds)
- JWT token com expiração de 7 dias
- Token armazenado no `localStorage`

#### 2. **Microsoft SSO (Entra ID)**
- OAuth 2.0 flow
- Login sem senha
- Vinculação por `microsoftId`

### Sistema de Roles

```typescript
type Role = 
  | 'superadmin'      // Acesso total, multi-company
  | 'company_admin'   // Admin de uma empresa
  | 'customer_admin'  // Admin de um cliente
  | 'manager'         // Gerente (web)
  | 'operator'        // Operador (web)
  | 'mobile_user'     // Colaborador mobile
```

### Middleware de Autenticação

```typescript
// server/routes.ts
app.use((req, res, next) => {
  // Verifica JWT token
  // Anexa userId ao req.userId
  // Permite acesso ou retorna 401
});
```

### Verificação de Permissões

Cada rota verifica:
1. ✅ Usuário autenticado?
2. ✅ Usuário tem acesso a este cliente?
3. ✅ Usuário tem permissão para esta ação?
4. ✅ Dados pertencem ao cliente correto?

---

## 🏢 Sistema Multi-Tenant

### Isolamento de Dados

**REGRA DE OURO**: Todos os dados são filtrados por `customerId` + `module`

#### No Backend (server/routes.ts)

```typescript
// SEMPRE filtre por customerId
app.get('/api/customers/:customerId/work-orders', async (req, res) => {
  const { customerId } = req.params;
  const { module } = req.query;
  
  // Verifica se usuário tem acesso ao cliente
  const user = await storage.getUser(req.userId);
  if (user.customerId !== customerId) {
    return res.status(403).json({ error: 'Acesso negado' });
  }
  
  // Busca dados apenas deste cliente + módulo
  const workOrders = await storage.getWorkOrders(customerId, module);
  res.json(workOrders);
});
```

#### No Frontend (TanStack Query)

```typescript
// SEMPRE use customerId do ClientContext
const { activeCustomer } = useClientContext();
const { activeModule } = useModuleContext();

const { data } = useQuery({
  queryKey: ['/api/work-orders', activeCustomer.id, activeModule],
  enabled: !!activeCustomer
});
```

### Hierarquia de Acesso

```
Superadmin
  ↓ Acessa todas companies
Company Admin
  ↓ Acessa todos customers da company
Customer Admin
  ↓ Acessa apenas seu customer
Manager/Operator
  ↓ Acessa apenas seu customer (limitado)
```

---

## 🧩 Sistema de Módulos

### Módulos Disponíveis

- **clean**: OPUS Clean (limpeza e facilities)
- **maintenance**: OPUS Manutenção

### Isolamento de Dados por Módulo

**Tabelas isoladas por módulo:**

- `sites` (locais)
- `zones` (zonas)
- `work_orders` (O.S)
- `checklist_templates` (templates)
- `service_categories` (categorias)
- `sla_configs` (SLAs)
- `equipment` (equipamentos - apenas maintenance)
- `maintenance_plans` (planos - apenas maintenance)
- `maintenance_activities` (atividades - apenas maintenance)

**Tabelas compartilhadas:**

- `companies`
- `customers`
- `users`
- `ai_integrations`
- `ai_conversations` (isoladas por module também)

### Proteção de Rotas por Módulo

```typescript
// client/src/pages/Equipment.tsx (exclusivo maintenance)
const { activeModule } = useModuleContext();

if (activeModule !== 'maintenance') {
  return <AccessDenied message="Esta página é exclusiva do OPUS Manutenção" />;
}
```

### Theme Dinâmico por Módulo

```typescript
// client/src/hooks/use-module-theme.ts
const { activeModule } = useModuleContext();

const colors = activeModule === 'clean' 
  ? { primary: 'blue', secondary: 'sky' }
  : { primary: 'orange', secondary: 'amber' };
```

---

## 🔌 Integrações e APIs

### Google Gemini AI

**Localização**: `server/storage.ts` (função `processAIMessage`)

#### Configuração

```typescript
// ai_integrations table
{
  provider: 'google',
  apiKey: 'encrypted_key',
  model: 'gemini-1.5-flash',
  temperature: '0.7',
  maxTokens: 500
}
```

#### Funções Disponíveis para AI

1. **queryWorkOrdersCount**: Conta O.S baseado em filtros
2. **queryWorkOrdersList**: Lista O.S com detalhes
3. **getWorkOrderDetails**: Detalhes de O.S específica
4. **updateWorkOrder**: Atualiza status/campos de O.S
5. **createWorkOrder**: Cria nova O.S

#### Fluxo de Function Calling

```
1. Usuário: "Quantas O.S foram concluídas esse mês?"
2. AI reconhece: precisa chamar queryWorkOrdersCount
3. AI retorna: functionCall com parâmetros
4. Backend executa função → retorna resultado
5. AI recebe resultado → gera resposta em português
6. Usuário recebe: "Foram concluídas 15 O.S em novembro de 2025"
```

### API REST

**Base URL**: `http://localhost:5000/api`

#### Endpoints Principais

```
AUTH:
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/auth/user-modules

CUSTOMERS:
GET    /api/customers/:id
GET    /api/customers/:id/sites
GET    /api/customers/:id/zones
GET    /api/customers/:id/work-orders
POST   /api/customers/:id/work-orders
PATCH  /api/customers/:id/work-orders/:woId

CHECKLISTS:
GET    /api/customers/:id/checklist-templates
POST   /api/checklist-executions

EQUIPMENT (Maintenance):
GET    /api/customers/:id/equipment
POST   /api/customers/:id/equipment

MAINTENANCE PLANS:
GET    /api/customers/:id/maintenance-plans
POST   /api/customers/:id/maintenance-plans
GET    /api/customers/:id/maintenance-activities

AI CHAT:
GET    /api/chat/conversation
POST   /api/chat/message
```

---

## 🛠️ Como Fazer Modificações Comuns

### 1. Adicionar Nova Coluna a Tabela Existente

**Passo 1**: Editar `shared/schema.ts`

```typescript
export const workOrders = pgTable('work_orders', {
  // ... campos existentes
  newField: varchar('new_field', { length: 255 }),  // ← nova coluna
});
```

**Passo 2**: Push para database

```bash
npm run db:push
# Se avisar sobre data loss:
npm run db:push --force
```

**Passo 3**: Atualizar tipos frontend/backend conforme necessário

### 2. Criar Nova Tabela

**Passo 1**: Adicionar em `shared/schema.ts`

```typescript
export const myNewTable = pgTable('my_new_table', {
  id: varchar('id').primaryKey().default(sql`gen_random_uuid()`),
  customerId: varchar('customer_id').references(() => customers.id).notNull(),
  name: varchar('name', { length: 255 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Export type
export type MyNewTable = typeof myNewTable.$inferSelect;
export type InsertMyNewTable = typeof myNewTable.$inferInsert;

// Zod schema
export const insertMyNewTableSchema = createInsertSchema(myNewTable);
```

**Passo 2**: Atualizar `IStorage` em `server/storage.ts`

```typescript
interface IStorage {
  // ... métodos existentes
  createMyNewTable(data: InsertMyNewTable): Promise<MyNewTable>;
  getMyNewTables(customerId: string): Promise<MyNewTable[]>;
}
```

**Passo 3**: Implementar em `DbStorage`

```typescript
async createMyNewTable(data: InsertMyNewTable): Promise<MyNewTable> {
  const [item] = await db.insert(myNewTable).values(data).returning();
  return item;
}
```

**Passo 4**: Criar rotas em `server/routes.ts`

```typescript
app.post('/api/customers/:customerId/my-table', async (req, res) => {
  const { customerId } = req.params;
  const parsed = insertMyNewTableSchema.safeParse(req.body);
  
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error });
  }
  
  const item = await storage.createMyNewTable({
    ...parsed.data,
    customerId
  });
  
  res.json(item);
});
```

**Passo 5**: Push schema

```bash
npm run db:push --force
```

### 3. Adicionar Nova Página

**Passo 1**: Criar componente em `client/src/pages/`

```typescript
// client/src/pages/MyNewPage.tsx
export default function MyNewPage() {
  const { activeCustomer } = useClientContext();
  const { activeModule } = useModuleContext();
  
  const { data, isLoading } = useQuery({
    queryKey: ['/api/my-data', activeCustomer.id],
    enabled: !!activeCustomer
  });
  
  if (isLoading) return <div>Carregando...</div>;
  
  return (
    <div>
      <h1>Minha Nova Página</h1>
      {/* Conteúdo */}
    </div>
  );
}
```

**Passo 2**: Registrar rota em `client/src/App.tsx`

```typescript
import MyNewPage from '@/pages/MyNewPage';

function App() {
  return (
    <Routes>
      {/* ... rotas existentes */}
      <Route path="/my-page" element={
        <ProtectedRoute>
          <MainLayout>
            <MyNewPage />
          </MainLayout>
        </ProtectedRoute>
      } />
    </Routes>
  );
}
```

**Passo 3**: Adicionar link no sidebar

```typescript
// client/src/components/sidebar.tsx
<SidebarMenuItem>
  <Link href="/my-page">
    <Icon />
    Minha Página
  </Link>
</SidebarMenuItem>
```

### 4. Adicionar Função para AI

**Passo 1**: Definir função em `server/storage.ts` (Google Gemini tools)

```typescript
const tools = [{
  functionDeclarations: [
    // ... funções existentes
    {
      name: 'myNewFunction',
      description: 'Faz algo útil com dados',
      parameters: {
        type: 'object',
        properties: {
          param1: { type: 'string', description: 'Primeiro parâmetro' }
        }
      }
    }
  ]
}];
```

**Passo 2**: Implementar handler da função

```typescript
// Dentro do loop de function calling
if (functionCall.name === 'myNewFunction') {
  const args = functionCall.args;
  const result = await storage.myCustomMethod(args.param1);
  
  functionResponses.push({
    name: 'myNewFunction',
    response: { result }
  });
}
```

**Passo 3**: Adicionar método em `IStorage` se necessário

### 5. Modificar Tema/Cores

**Editar**: `client/src/index.css`

```css
:root {
  /* OPUS Clean - Blue */
  --primary-clean: 219 95% 60%;
  --secondary-clean: 199 89% 60%;
  
  /* OPUS Maintenance - Orange */
  --primary-maintenance: 25 95% 53%;
  --secondary-maintenance: 43 100% 50%;
}
```

**Hook de tema**: `client/src/hooks/use-module-theme.ts`

---

## 🐛 Debugging e Troubleshooting

### Problemas Comuns

#### 1. **"Relation does not exist" (PostgreSQL)**

**Causa**: Schema não sincronizado com banco

**Solução**:
```bash
npm run db:push --force
```

#### 2. **Frontend não atualiza após mudança**

**Causa**: Cache do TanStack Query

**Solução**: Invalidar cache após mutation
```typescript
import { queryClient } from '@/lib/queryClient';

mutation.mutate(data, {
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['/api/work-orders'] });
  }
});
```

#### 3. **Usuário não consegue ver dados de outro cliente**

**Causa**: Isso é correto! Sistema multi-tenant isola dados

**Solução**: Verificar se `user.customerId` está correto

#### 4. **AI não retorna dados, só texto**

**Causa**: AI não está chamando funções

**Solução**: Verificar system prompt e function descriptions

#### 5. **Workflow não reinicia**

**Solução**:
```bash
# Matar processo na porta 5000
pkill -f "tsx server/index.ts"

# Reiniciar
npm run dev
```

#### 6. **"Module not found" após adicionar dependência**

**Solução**:
```bash
# Não edite package.json manualmente!
# Use o packager tool ou:
npm install nome-do-pacote
```

### Logs e Debugging

#### Backend Logs

```bash
# Ver logs do servidor
tail -f /tmp/logs/Start_application_*.log
```

#### Database Queries

```bash
# Conectar ao banco
psql "$DATABASE_URL"

# Queries úteis
SELECT * FROM users WHERE email = 'admin@grupoopus.com';
SELECT COUNT(*) FROM work_orders WHERE customer_id = 'xxx';
SELECT * FROM ai_conversations ORDER BY last_message_at DESC LIMIT 5;
```

#### Frontend Debug

```javascript
// No componente
console.log('[DEBUG]', { activeCustomer, activeModule, data });

// TanStack Query DevTools (já incluído)
// Acesse na interface web
```

---

## 📋 Regras e Convenções

### Code Style

1. ✅ Use TypeScript - SEMPRE
2. ✅ Componentes React em PascalCase
3. ✅ Funções e variáveis em camelCase
4. ✅ Constantes em UPPER_SNAKE_CASE
5. ✅ Arquivos de componentes: `MyComponent.tsx`
6. ✅ Hooks customizados: `use-my-hook.ts`

### Database

1. ✅ **NUNCA** mude tipo de coluna ID (serial ↔ varchar)
2. ✅ Use `npm run db:push` - NUNCA escreva migrations manualmente
3. ✅ Sempre filtre por `customerId` + `module`
4. ✅ Use foreign keys para relacionamentos
5. ✅ Timestamps: `createdAt`, `updatedAt`, `completedAt`

### API Routes

1. ✅ Use Zod para validação de body
2. ✅ Sempre verifique permissões
3. ✅ Retorne erros descritivos (400, 401, 403, 404, 500)
4. ✅ Use `storage` layer - NUNCA acesse DB direto nas rotas
5. ✅ Nomes de rotas em kebab-case: `/work-orders`

### Frontend

1. ✅ Use TanStack Query para data fetching
2. ✅ Invalide cache após mutations
3. ✅ Use `@/` para imports absolutos
4. ✅ shadcn/ui para componentes - não invente do zero
5. ✅ Tailwind para estilos - CSS mínimo
6. ✅ Sempre mostre loading states
7. ✅ Sempre trate errors
8. ✅ Use `data-testid` para elementos interativos

### Multi-Tenant

1. ✅ **SEMPRE** filtre por `customerId`
2. ✅ Verifique acesso do usuário ao cliente
3. ✅ Tabelas multi-tenant TÊM que ter `customerId`
4. ✅ Tabelas com módulo TÊM que ter campo `module`

### Git Commits (Sugestão)

```
feat: adiciona página de equipamentos
fix: corrige filtro de O.S por data
refactor: otimiza query de dashboard
docs: atualiza documentação de API
```

---

## 🚀 Deploy e Produção

### Ambiente Development

```bash
# Iniciar servidor
npm run dev

# Acesso
http://localhost:5000
```

### Environment Variables

```env
# .env (NUNCA commite este arquivo!)
DATABASE_URL=postgresql://...
AI_INTEGRATION_KEY=...
PGHOST=...
PGPORT=5432
PGUSER=...
PGPASSWORD=...
PGDATABASE=...
```

### Build para Produção

```bash
# Build frontend
npm run build

# O Replit faz deploy automático via workflow
```

### Database Backup

```bash
# Criar backup
pg_dump "$DATABASE_URL" --clean --if-exists --column-inserts > backups/backup_$(date +%Y%m%d).sql

# Restaurar backup
psql "$DATABASE_URL" < backups/backup_20251108.sql

# Ou use o script
bash backups/restore_backup.sh backups/backup_20251108.sql
```

### Monitoring

- Logs do servidor: `/tmp/logs/`
- Database: Neon Dashboard
- Performance: TanStack Query DevTools

---

## 🔍 Checklist de Desenvolvimento

Ao fazer mudanças no sistema, verifique:

### Antes de Modificar Código

- [ ] Li a documentação relevante?
- [ ] Entendi o fluxo atual?
- [ ] Sei qual arquivo modificar?

### Modificando Database

- [ ] Editei `shared/schema.ts`?
- [ ] Rodei `npm run db:push`?
- [ ] Atualizei tipos TypeScript?
- [ ] Atualizei `IStorage` interface?
- [ ] Implementei métodos em `DbStorage`?

### Modificando Backend

- [ ] Atualizei `server/routes.ts`?
- [ ] Adicionei validação Zod?
- [ ] Verifiquei permissões?
- [ ] Filtrei por `customerId`?
- [ ] Tratei erros adequadamente?

### Modificando Frontend

- [ ] Usei TanStack Query?
- [ ] Invalidei cache após mutation?
- [ ] Mostrei loading state?
- [ ] Tratei errors?
- [ ] Usei shadcn/ui components?
- [ ] Adicionei `data-testid`?

### Testando

- [ ] Testei no navegador?
- [ ] Testei com diferentes clientes?
- [ ] Testei com diferentes módulos?
- [ ] Testei permissões?
- [ ] Verifiquei logs do servidor?
- [ ] Verifiquei console do navegador?

### Antes de Commit

- [ ] Removi console.logs de debug?
- [ ] Código está formatado?
- [ ] Não quebrei funcionalidades existentes?
- [ ] Atualizei documentação se necessário?

---

## 📞 Recursos Adicionais

### Documentação do Projeto

- `replit.md`: Resumo executivo
- `DOCUMENTATION.md`: Documentação técnica detalhada
- `SYSTEM_FLOW.md`: Fluxos completos do sistema
- `DATABASE_BACKUP_INFO.md`: Informações de backup
- `OPUS_SYSTEM_GUIDE.md`: Este arquivo

### Documentação Externa

- [React](https://react.dev)
- [TypeScript](https://www.typescriptlang.org/docs/)
- [Drizzle ORM](https://orm.drizzle.team/)
- [TanStack Query](https://tanstack.com/query/latest)
- [shadcn/ui](https://ui.shadcn.com/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Google Gemini API](https://ai.google.dev/docs)

---

## 🎓 Conclusão

Este guia cobre os aspectos fundamentais do sistema OPUS. Para dúvidas específicas:

1. Consulte os arquivos de documentação listados acima
2. Leia o código-fonte (muito bem comentado)
3. Verifique os logs do sistema
4. Teste em ambiente de desenvolvimento primeiro

**Regra de Ouro**: Quando em dúvida, pergunte ou teste em dev antes de modificar produção!

---

**Última atualização**: 08/11/2025  
**Versão do Sistema**: 1.0.0  
**Autor**: Documentação gerada para agentes Replit e desenvolvedores
