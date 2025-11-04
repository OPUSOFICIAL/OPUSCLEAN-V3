# OPUS - Documentação Técnica Completa

**Última atualização**: 04 de Novembro de 2025  
**Versão**: 1.0

---

## 📋 Índice

1. [Visão Geral do Sistema](#visão-geral-do-sistema)
2. [Arquitetura Técnica](#arquitetura-técnica)
3. [Modelo de Dados](#modelo-de-dados)
4. [Funcionalidades Principais](#funcionalidades-principais)
5. [Estrutura do Código](#estrutura-do-código)
6. [Fluxos de Funcionamento](#fluxos-de-funcionamento)
7. [Guia de Desenvolvimento](#guia-de-desenvolvimento)
8. [Changelog](#changelog)

---

## 🎯 Visão Geral do Sistema

### O que é OPUS?

OPUS é uma plataforma modular de gestão de facilities que oferece soluções para diferentes áreas operacionais:

- **OPUS Clean**: Gestão de limpeza e facilities
- **OPUS Manutenção**: Gestão de manutenção e equipamentos

### Características Principais

- ✅ **Multi-tenant**: Suporta múltiplas empresas, clientes, locais e zonas
- ✅ **Multi-módulo**: Arquitetura modular com isolamento completo de dados
- ✅ **Web + Mobile**: Interface administrativa web e aplicativos móveis
- ✅ **QR Code Based**: Execução de tarefas e solicitações públicas via QR codes
- ✅ **Real-time Analytics**: Dashboards e relatórios em tempo real
- ✅ **SSO Integration**: Suporte a Microsoft Entra ID e autenticação local

---

## 🏗️ Arquitetura Técnica

### Stack Tecnológica

#### Frontend
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Roteamento**: Wouter
- **State Management**: TanStack Query v5
- **UI Components**: shadcn/ui (Radix UI + Tailwind CSS)
- **Forms**: React Hook Form + Zod
- **Icons**: Lucide React

#### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript
- **ORM**: Drizzle ORM
- **Database**: PostgreSQL (Neon Serverless)
- **Auth**: JWT + Passport.js + Bcrypt
- **Security**: Helmet, CORS, Rate Limiting

### Arquitetura em Camadas

```
┌─────────────────────────────────────────┐
│         Frontend (React + Vite)         │
│  - Pages, Components, Contexts, Hooks   │
└──────────────────┬──────────────────────┘
                   │ HTTP/REST API
┌──────────────────┴──────────────────────┐
│       Backend (Express + TypeScript)    │
│  - Routes (API Endpoints)               │
│  - Storage Interface (Data Layer)       │
│  - Auth Middleware                      │
└──────────────────┬──────────────────────┘
                   │ Drizzle ORM
┌──────────────────┴──────────────────────┐
│      Database (PostgreSQL/Neon)         │
│  - Tables, Relations, Indexes           │
└─────────────────────────────────────────┘
```

### Estrutura de Diretórios

```
project-root/
├── client/                     # Frontend
│   ├── src/
│   │   ├── components/         # Componentes reutilizáveis
│   │   │   ├── layout/         # Header, Sidebar, etc.
│   │   │   └── ui/             # shadcn components
│   │   ├── contexts/           # React Contexts
│   │   │   ├── AuthContext.tsx         # Autenticação
│   │   │   ├── ClientContext.tsx       # Cliente ativo
│   │   │   └── ModuleContext.tsx       # Módulo ativo
│   │   ├── hooks/              # Custom hooks
│   │   ├── lib/                # Utilitários
│   │   │   └── queryClient.ts  # TanStack Query config
│   │   ├── pages/              # Páginas da aplicação
│   │   ├── App.tsx             # Root component + rotas
│   │   └── index.css           # Estilos globais + tema
│   └── index.html
├── server/                     # Backend
│   ├── auth.ts                 # Estratégias de autenticação
│   ├── index.ts                # Entry point
│   ├── routes.ts               # Definição de rotas API
│   ├── storage.ts              # Interface de dados
│   └── vite.ts                 # Integração Vite
├── shared/                     # Código compartilhado
│   └── schema.ts               # Schema Drizzle + tipos
└── db/                         # Migrations (geradas)
```

---

## 📊 Modelo de Dados

### Hierarquia Multi-Tenant

```
Companies (Empresas)
    ↓
Customers (Clientes)
    ↓
Sites (Locais)
    ↓
Zones (Zonas)
```

### Principais Tabelas

#### 1. **companies** (Empresas)
Representa a empresa proprietária do sistema (ex: OPUS).

```typescript
{
  id: string (PK)
  name: string
  cnpj: string (unique)
  isActive: boolean
  createdAt: timestamp
}
```

#### 2. **customers** (Clientes)
Clientes que utilizam o sistema (ex: FAURECIA, TECNOFIBRA).

```typescript
{
  id: string (PK)
  companyId: string (FK → companies)
  name: string
  tradeName: string
  cnpj: string (unique)
  modules: text[] // ['clean', 'maintenance']
  isActive: boolean
  createdAt: timestamp
}
```

**Campo Crítico**: `modules` - Define quais módulos o cliente tem acesso.

#### 3. **sites** (Locais)
Localidades físicas do cliente.

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  name: string
  address: string
  isActive: boolean
  createdAt: timestamp
}
```

#### 4. **zones** (Zonas)
Áreas específicas dentro de um local (ex: "Térreo - Recepção").

```typescript
{
  id: string (PK)
  siteId: string (FK → sites)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance' // ISOLAMENTO POR MÓDULO
  name: string
  floor: string
  isActive: boolean
  createdAt: timestamp
}
```

**Campo Crítico**: `module` - Isola zonas por módulo.

#### 5. **users** (Usuários)
Todos os usuários do sistema.

```typescript
{
  id: string (PK)
  email: string (unique)
  password: string (hashed)
  name: string
  role: 'admin' | 'manager' | 'operator' | 'viewer'
  userType: 'opus_user' | 'customer_user'
  assignedClientId: string (FK → customers) // Para customer_user
  authProvider: 'local' | 'microsoft'
  modules: text[] // Para opus_user apenas
  isActive: boolean
  createdAt: timestamp
}
```

**Regra Importante**:
- `opus_user`: módulos definidos em `users.modules`
- `customer_user`: módulos herdados de `customers.modules` (via `assignedClientId`)

#### 6. **service_types** (Tipos de Serviço)
Categorias principais de serviços (ex: "Limpeza Geral", "Manutenção Preventiva").

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance' // ISOLAMENTO POR MÓDULO
  name: string
  description: string
  code: string (unique)
  isActive: boolean
  createdAt: timestamp
}
```

#### 7. **service_categories** (Categorias de Serviço)
Subcategorias de serviços.

```typescript
{
  id: string (PK)
  typeId: string (FK → service_types)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance' // ISOLAMENTO POR MÓDULO
  name: string
  description: string
  code: string
  isActive: boolean
  createdAt: timestamp
}
```

#### 8. **work_orders** (Ordens de Serviço)
Core do sistema - registros de trabalho.

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  siteId: string (FK → sites)
  zoneId: string (FK → zones)
  module: 'clean' | 'maintenance' // ISOLAMENTO POR MÓDULO
  orderType: 'programmed' | 'internal_corrective' | 'public_corrective'
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  title: string
  description: string
  assignedUserId: string (FK → users)
  scheduledDate: timestamp
  completedAt: timestamp
  slaDeadline: timestamp
  createdAt: timestamp
}
```

#### 9. **qr_codes** (QR Codes)
Códigos QR para execução e solicitações.

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  siteId: string (FK → sites)
  zoneId: string (FK → zones)
  module: 'clean' | 'maintenance' // ISOLAMENTO POR MÓDULO
  qrType: 'execution' | 'public'
  code: string (unique)
  isActive: boolean
  createdAt: timestamp
}
```

**Tipos**:
- `execution`: Para equipes internas executarem ordens
- `public`: Para usuários finais solicitarem serviços

#### 10. **equipment** (Equipamentos - Manutenção)
Equipamentos gerenciados no módulo de manutenção.

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  siteId: string (FK → sites)
  zoneId: string (FK → zones)
  name: string
  description: string
  serialNumber: string
  manufacturer: string
  model: string
  isActive: boolean
  createdAt: timestamp
}
```

#### 11. **equipment_tags** (Tags de Equipamento)
Sistema de tags para categorização flexível.

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  module: 'clean' | 'maintenance' // ISOLAMENTO POR MÓDULO
  name: string
  description: string
  createdAt: timestamp
}
```

#### 12. **maintenance_plans** (Planos de Manutenção)
Planos de manutenção programada.

```typescript
{
  id: string (PK)
  customerId: string (FK → customers)
  name: string
  description: string
  frequency: 'daily' | 'weekly' | 'shift_based' | 'monthly' | 'quarterly' | 'semi_annual' | 'annual'
  shift: 'morning' | 'afternoon' | 'night' (para shift_based)
  dayOfWeek: number (para weekly)
  dayOfMonth: number (para monthly)
  isActive: boolean
  createdAt: timestamp
}
```

### Relações Principais

```
companies 1───N customers
customers 1───N sites
sites 1───N zones
customers 1───N users (customer_user)
customers 1───N service_types
service_types 1───N service_categories
customers 1───N work_orders
sites 1───N work_orders
zones 1───N work_orders
users 1───N work_orders (assigned)
```

---

## ⚙️ Funcionalidades Principais

### 1. Multi-Tenancy Hierárquico

**Estrutura**: Companies → Customers → Sites → Zones

**Isolamento de Dados**:
- Cada cliente vê apenas seus dados
- Filtragem automática por `customerId` em todas as queries
- Validação backend em todas as operações CRUD

**Implementação**:
```typescript
// Frontend: ClientContext.tsx
const { activeClientId } = useClient();

// Backend: routes.ts
const customerId = req.user.userType === 'customer_user' 
  ? req.user.assignedClientId 
  : req.query.customerId;
```

### 2. Sistema de Módulos

**Módulos Disponíveis**:
- `clean`: OPUS Clean (limpeza e facilities)
- `maintenance`: OPUS Manutenção (equipamentos)

**Isolamento Total**:
- Tabelas com campo `module`: zones, service_types, service_categories, work_orders, qr_codes, equipment_tags, etc.
- Filtragem automática por módulo ativo
- Validação de acesso em cada rota

**Controle de Acesso**:
```typescript
// Customer modules (nível cliente)
customer.modules = ['clean', 'maintenance']

// User modules (herança)
if (user.userType === 'customer_user') {
  userModules = customer.modules // Herda do cliente
} else {
  userModules = user.modules // Próprio
}
```

**Proteção de Rotas**:
- Frontend: `ModuleContext` auto-corrige módulo inválido
- Backend: Valida módulo em operações de create/update
- UI: Esconde/mostra seletor de módulo baseado em permissões

**Implementação Frontend**:
```typescript
// ModuleContext.tsx
useEffect(() => {
  if (!availableModules.includes(currentModule)) {
    setCurrentModule(availableModules[0] || 'clean');
  }
}, [activeClientId, availableModules]);
```

**Implementação Backend** (Exemplo: service-categories):
```typescript
// CREATE
const newCategory = {
  ...data,
  module: currentModule, // Módulo ativo
  customerId
};

// READ
WHERE customerId = ? AND module = ?
```

### 3. Autenticação e Autorização

#### Provedores de Auth
- **Local**: Email + senha (Bcrypt)
- **Microsoft SSO**: Entra ID (OpenID Connect)

#### Tipos de Usuário

**opus_user** (Usuário OPUS):
- Pertence à empresa OPUS
- Pode acessar múltiplos clientes (seleção via dropdown)
- Módulos definidos em `users.modules`
- Roles: admin, manager, viewer

**customer_user** (Usuário do Cliente):
- Pertence a um cliente específico (`assignedClientId`)
- Acesso fixo ao seu cliente
- Módulos herdados de `customers.modules`
- Roles: admin, manager, operator, viewer

#### Roles e Permissões

```typescript
Role: 'admin'
  - Acesso total ao sistema
  - Configurações, usuários, relatórios

Role: 'manager'
  - Gestão operacional
  - Criação de ordens, acompanhamento

Role: 'operator'
  - Execução de tarefas
  - Mobile app, QR scanning

Role: 'viewer'
  - Somente leitura
  - Dashboards, relatórios
```

#### Fluxo de Autenticação

```
1. Login → POST /api/auth/login
2. Validação (local ou Microsoft)
3. Geração de JWT token
4. Frontend armazena token
5. Requisições incluem: Authorization: Bearer <token>
6. Backend valida token em middleware
```

**Middleware**: `requireAuth` em todas as rotas protegidas.

### 4. Sistema de QR Codes

#### Tipos de QR Code

**Execution QR** (Execução Interna):
- Para equipes internas
- Vinculado a zona específica
- Escanear → Listar ordens da zona → Executar

**Public QR** (Solicitação Pública):
- Para usuários finais
- Qualquer pessoa pode escanear
- Escanear → Formulário → Gera ordem corretiva

#### Fluxo de Uso

```
QR Code Execution:
1. Operador escaneia QR
2. Sistema identifica zona
3. Lista ordens pendentes da zona
4. Operador seleciona e executa
5. Preenche checklist (se houver)
6. Finaliza com foto/assinatura

QR Code Public:
1. Usuário escaneia QR público
2. Abre formulário de solicitação
3. Descreve problema + foto
4. Submit
5. Sistema cria work_order (public_corrective)
6. Notifica equipe responsável
```

### 5. Gestão de Ordens de Serviço

#### Tipos de Ordem

```typescript
'programmed'           // Programadas (calendário)
'internal_corrective'  // Corretivas internas
'public_corrective'    // Solicitações públicas (via QR)
```

#### Status Lifecycle

```
pending → in_progress → completed
           ↓
        cancelled
```

#### SLA e Prioridades

**Prioridades**:
- `urgent`: Crítico, resolver ASAP
- `high`: Alta prioridade
- `medium`: Prioridade média
- `low`: Pode aguardar

**SLA**: 
- Configurável por categoria de serviço
- Campo `slaDeadline` calcula prazo
- Dashboard mostra % conformidade

#### Reabertura de Ordens

- Ordens completadas podem ser reabertas
- Histórico mantido em comentários
- Útil para retrabalho ou problemas recorrentes

### 6. Sistema de Tags (Equipamentos)

**Objetivo**: Categorização flexível de equipamentos.

**Funcionamento**:
```typescript
// Tag examples
tags = ["Cafeteira", "Ar Condicionado", "Impressora"]

// Equipment association
equipment.tags = [tagId1, tagId2]

// Maintenance template targeting
template.targetType = 'tag_based'
template.targetTagIds = [tagId1]
// Aplica template a TODOS equipamentos com essa tag
```

**Vantagens**:
- Gestão em massa de equipamentos similares
- Templates reutilizáveis
- Facilita manutenção preventiva

### 7. Geração Automática de Ordens Mensais

**Estratégia Dual**:

1. **Visualização Virtual** (Calendar):
   - Frontend calcula ordens futuras baseado em `maintenance_plans`
   - Mostra 12 meses no calendário
   - Sem overhead no banco

2. **Persistência Deferred** (Database):
   - Scheduler roda último dia do mês às 23:00
   - Gera ordens do mês seguinte no banco
   - Apenas próximo mês persiste

**Implementação**:
```typescript
// server/index.ts
cron.schedule('0 23 L * *', async () => {
  // Gera ordens para próximo mês
  await generateMonthlyWorkOrders();
});
```

### 8. Dashboard e Analytics

**Métricas Principais**:
- Total de ordens (por status, prioridade)
- Taxa de conclusão no prazo (SLA)
- Distribuição por local/zona
- Tempo médio de conclusão
- Tendências (gráficos de linha)

**Metas Dashboard**:
- Configuráveis por cliente
- Tipos: completion_rate, response_time, satisfaction
- Indicadores visuais (verde/amarelo/vermelho)

**Implementação**:
- Queries em tempo real (PostgreSQL)
- TanStack Query com cache
- Recharts para visualização

---

## 📂 Estrutura do Código

### Frontend Architecture

#### Contexts (Estado Global)

**AuthContext.tsx**:
```typescript
// Gerencia autenticação
{
  user: User | null
  login(email, password)
  loginWithMicrosoft()
  logout()
  isLoading: boolean
}
```

**ClientContext.tsx**:
```typescript
// Gerencia cliente ativo (para opus_user)
{
  activeClientId: string | null
  setActiveClientId(id: string)
  availableClients: Customer[]
}
```

**ModuleContext.tsx**:
```typescript
// Gerencia módulo ativo
{
  currentModule: 'clean' | 'maintenance'
  setCurrentModule(module)
  availableModules: string[]
}

// Auto-correção quando módulo inválido
useEffect(() => {
  if (!availableModules.includes(currentModule)) {
    setCurrentModule(availableModules[0]);
  }
}, [activeClientId, availableModules]);
```

#### Custom Hooks

**useUserModules.ts**:
```typescript
// Busca módulos do usuário
function useUserModules() {
  return useQuery({
    queryKey: ['/api/auth/user-modules'],
    // Retorna módulos baseado em userType
  });
}
```

#### Pages (Rotas Principais)

```
/                        → Dashboard
/work-orders             → Lista de ordens
/work-orders/:id         → Detalhes da ordem
/sites                   → Gestão de locais
/zones                   → Gestão de zonas
/services                → Gestão de serviços
/equipment               → Gestão de equipamentos (maintenance)
/maintenance-plans       → Planos de manutenção (maintenance)
/qr-codes                → Gestão de QR codes
/users                   → Gestão de usuários
/settings                → Configurações
/login                   → Autenticação
/mobile/*                → Rotas mobile
```

#### Components Structure

```
components/
├── layout/
│   ├── header.tsx          # Cabeçalho com logout
│   └── sidebar.tsx         # Menu lateral + module selector
└── ui/                     # shadcn components
    ├── button.tsx
    ├── dialog.tsx
    ├── form.tsx
    └── ... (30+ components)
```

### Backend Architecture

#### Routes (server/routes.ts)

**Padrão de Organização**:
```typescript
// Auth
POST   /api/auth/login
POST   /api/auth/login/microsoft
POST   /api/auth/logout
GET    /api/auth/user
GET    /api/auth/user-modules

// Customers
GET    /api/customers
POST   /api/customers
GET    /api/customers/:id
PUT    /api/customers/:id
DELETE /api/customers/:id

// Sites
GET    /api/customers/:customerId/sites
POST   /api/customers/:customerId/sites
PUT    /api/customers/:customerId/sites/:id
DELETE /api/customers/:customerId/sites/:id

// Work Orders
GET    /api/customers/:customerId/work-orders
POST   /api/customers/:customerId/work-orders
GET    /api/work-orders/:id
PUT    /api/work-orders/:id
DELETE /api/work-orders/:id
```

**Middleware Stack**:
```typescript
app.use(helmet());              // Security headers
app.use(cors());                // CORS
app.use(rateLimiter);           // Rate limiting
app.use(express.json());        // JSON parser
app.use(session());             // Session
app.use(passport.initialize()); // Auth
```

#### Storage Layer (server/storage.ts)

**Interface Pattern**:
```typescript
interface IStorage {
  // Users
  getUsers(filters): Promise<User[]>
  getUserById(id): Promise<User>
  createUser(data): Promise<User>
  updateUser(id, data): Promise<User>
  deleteUser(id): Promise<void>
  
  // Work Orders
  getWorkOrders(filters): Promise<WorkOrder[]>
  // ... CRUD methods
  
  // Etc for all entities
}
```

**Implementação PostgreSQL**:
```typescript
class PostgresStorage implements IStorage {
  async getWorkOrders(filters) {
    return await db
      .select()
      .from(workOrders)
      .where(and(
        eq(workOrders.customerId, filters.customerId),
        eq(workOrders.module, filters.module)
      ));
  }
}
```

### Shared Schema (shared/schema.ts)

**Estrutura**:
```typescript
// 1. Enums
export const moduleEnum = pgEnum('module', ['clean', 'maintenance']);
export const userRoleEnum = pgEnum('user_role', ['admin', 'manager', 'operator', 'viewer']);

// 2. Tables
export const customers = pgTable('customers', { ... });
export const sites = pgTable('sites', { ... });
export const zones = pgTable('zones', { ... });
export const workOrders = pgTable('work_orders', { ... });

// 3. Relations
export const customersRelations = relations(customers, ({ many }) => ({
  sites: many(sites),
  users: many(users),
  workOrders: many(workOrders)
}));

// 4. Zod Schemas
export const insertCustomerSchema = createInsertSchema(customers).omit({ id: true });
export type InsertCustomer = z.infer<typeof insertCustomerSchema>;
export type Customer = typeof customers.$inferSelect;
```

---

## 🔄 Fluxos de Funcionamento

### Fluxo 1: Login e Seleção de Módulo

```
1. Usuário acessa /login
2. Escolhe método (email/password ou Microsoft SSO)
3. Backend valida credenciais
4. Gera JWT token
5. Frontend armazena token + user data
6. Redirect para /

7. AuthContext carrega user
8. ClientContext carrega clientes disponíveis
9. ModuleContext carrega módulos do usuário
   - customer_user: herda de customer.modules
   - opus_user: usa user.modules

10. Se opus_user: mostra dropdown de clientes
11. Se customer_user: cliente fixo

12. Sidebar verifica módulos disponíveis:
    - Se 1 módulo: esconde seletor
    - Se 2+ módulos: mostra dropdown

13. Usuário seleciona módulo (se disponível)
14. Sistema filtra dados pelo módulo ativo
```

### Fluxo 2: Criar Ordem de Serviço Programada

```
1. Manager acessa /work-orders
2. Clica "Nova Ordem"
3. Dialog abre

4. Preenche form:
   - Tipo: "Programada"
   - Local: [dropdown filtrado por cliente]
   - Zona: [dropdown filtrado por local + módulo]
   - Categoria: [dropdown filtrado por cliente + módulo]
   - Título, Descrição
   - Data agendada
   - Prioridade
   - Operador: [dropdown de users com role operator]

5. Submit form

6. Frontend valida (Zod)
7. POST /api/customers/:id/work-orders
   {
     ...formData,
     module: currentModule, // Adiciona módulo
     orderType: 'programmed',
     status: 'pending'
   }

8. Backend valida:
   - Usuário tem permissão?
   - Cliente existe?
   - Zona pertence ao cliente?
   - Módulo da zona === módulo enviado?

9. Se OK:
   - Calcula slaDeadline (baseado em categoria)
   - Insere no banco
   - Retorna ordem criada

10. Frontend:
    - Invalida cache
    - Fecha dialog
    - Mostra toast "Ordem criada!"
    - Lista atualiza automaticamente
```

### Fluxo 3: Execução via QR Code (Mobile)

```
1. Operador abre app mobile
2. Navega para /mobile/scanner
3. Escaneia QR code (execution)

4. App decodifica: qrCode.id
5. GET /api/qr-codes/:id/scan
   - Backend retorna: qrCode + zone + pending work orders

6. App mostra lista de ordens pendentes da zona
7. Operador seleciona uma ordem

8. Carrega checklist (se houver)
9. Operador preenche checklist:
   - Marca itens como OK/NOK
   - Adiciona observações
   - Tira fotos

10. Operador clica "Finalizar"

11. App envia:
    PUT /api/work-orders/:id
    {
      status: 'completed',
      completedAt: now(),
      checklistData: [...],
      photos: [...]
    }

12. Backend:
    - Valida operador
    - Atualiza ordem
    - Armazena checklist
    - Upload de fotos

13. App mostra "Ordem finalizada!"
14. Retorna para lista de ordens
```

### Fluxo 4: Solicitação Pública via QR Code

```
1. Usuário final escaneia QR público (celular comum)
2. Abre URL: /public/qr/:code

3. Frontend:
   - Não requer login
   - GET /api/public/qr/:code
   - Carrega info da zona

4. Mostra formulário:
   - "O que está acontecendo?"
   - Descrição (textarea)
   - Anexar foto (opcional)

5. Usuário preenche e envia

6. POST /api/public/requests
   {
     qrCodeId,
     description,
     photo
   }

7. Backend:
   - Identifica zona pelo QR
   - Cria work_order:
     - orderType: 'public_corrective'
     - status: 'pending'
     - priority: 'medium' (default)
     - assignedUserId: null (atribuir depois)

8. Retorna: "Solicitação enviada! Protocolo: #12345"

9. Manager vê nova ordem no dashboard
10. Atribui operador
11. Operador resolve
```

### Fluxo 5: Auto-correção de Módulo Inválido

```
Cenário: Usuário está em OPUS Clean, troca para cliente que só tem Manutenção

1. Usuário no cliente FAURECIA (clean)
2. currentModule = 'clean' (localStorage)

3. Usuário muda para "Teste de manutenção" (só maintenance)
4. ClientContext.setActiveClientId('teste-manutencao-id')

5. ModuleContext detecta mudança:
   useEffect(() => {
     // availableModules agora = ['maintenance']
     // currentModule = 'clean' (não está em availableModules)
     
     if (!availableModules.includes(currentModule)) {
       setCurrentModule('maintenance'); // AUTO-CORREÇÃO
       localStorage.setItem('opus:currentModule', 'maintenance');
     }
   }, [activeClientId, availableModules]);

6. UI atualiza:
   - Sidebar muda cor (laranja)
   - Menu mostra opções de manutenção
   - Dados filtrados por module='maintenance'

7. Usuário vê apenas dados de manutenção
```

---

## 🛠️ Guia de Desenvolvimento

### Adicionar Nova Funcionalidade

#### 1. Definir o Schema (shared/schema.ts)

```typescript
// 1. Criar tabela
export const myNewTable = pgTable('my_new_table', {
  id: varchar('id').primaryKey(),
  customerId: varchar('customer_id').references(() => customers.id),
  module: moduleEnum('module').notNull().default('clean'), // Se modular
  name: varchar('name').notNull(),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at').default(sql`now()`),
});

// 2. Definir relações
export const myNewTableRelations = relations(myNewTable, ({ one }) => ({
  customer: one(customers, {
    fields: [myNewTable.customerId],
    references: [customers.id],
  }),
}));

// 3. Criar Zod schemas
export const insertMyNewTableSchema = createInsertSchema(myNewTable).omit({ 
  id: true, 
  createdAt: true 
});
export type InsertMyNewTable = z.infer<typeof insertMyNewTableSchema>;
export type MyNewTable = typeof myNewTable.$inferSelect;
```

#### 2. Atualizar Storage (server/storage.ts)

```typescript
// Interface
interface IStorage {
  // ... existing methods
  getMyNewTables(filters: { customerId: string, module?: string }): Promise<MyNewTable[]>
  createMyNewTable(data: InsertMyNewTable): Promise<MyNewTable>
  updateMyNewTable(id: string, data: Partial<InsertMyNewTable>): Promise<MyNewTable>
  deleteMyNewTable(id: string): Promise<void>
}

// Implementation
class PostgresStorage implements IStorage {
  async getMyNewTables(filters) {
    const conditions = [eq(myNewTable.customerId, filters.customerId)];
    if (filters.module) {
      conditions.push(eq(myNewTable.module, filters.module));
    }
    return await db.select().from(myNewTable).where(and(...conditions));
  }
  
  async createMyNewTable(data) {
    const id = nanoid();
    const [result] = await db.insert(myNewTable).values({ id, ...data }).returning();
    return result;
  }
  
  async updateMyNewTable(id, data) {
    const [result] = await db.update(myNewTable).set(data).where(eq(myNewTable.id, id)).returning();
    return result;
  }
  
  async deleteMyNewTable(id) {
    await db.delete(myNewTable).where(eq(myNewTable.id, id));
  }
}
```

#### 3. Criar Rotas (server/routes.ts)

```typescript
// GET all
app.get('/api/customers/:customerId/my-new-tables', requireAuth, async (req, res) => {
  try {
    const { customerId } = req.params;
    const { module } = req.query;
    
    // Validar acesso
    if (req.user.userType === 'customer_user' && req.user.assignedClientId !== customerId) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    
    const items = await storage.getMyNewTables({ 
      customerId, 
      module: module as string 
    });
    res.json(items);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST create
app.post('/api/customers/:customerId/my-new-tables', requireAuth, async (req, res) => {
  try {
    const { customerId } = req.params;
    
    // Validar body
    const validatedData = insertMyNewTableSchema.parse(req.body);
    
    // Adicionar customerId
    const newItem = await storage.createMyNewTable({
      ...validatedData,
      customerId
    });
    
    res.status(201).json(newItem);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// PUT update
app.put('/api/customers/:customerId/my-new-tables/:id', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const validatedData = insertMyNewTableSchema.partial().parse(req.body);
    
    const updated = await storage.updateMyNewTable(id, validatedData);
    res.json(updated);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE
app.delete('/api/customers/:customerId/my-new-tables/:id', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    await storage.deleteMyNewTable(id);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

#### 4. Criar Frontend Page (client/src/pages/my-new-feature.tsx)

```typescript
import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Plus } from "lucide-react";

export default function MyNewFeature() {
  const { activeClientId: customerId } = useClient();
  const { currentModule } = useModule();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  
  // Query
  const { data: items = [], isLoading } = useQuery({
    queryKey: ['/api/customers', customerId, 'my-new-tables', { module: currentModule }],
    enabled: !!customerId,
  });
  
  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: any) => 
      apiRequest('POST', `/api/customers/${customerId}/my-new-tables`, {
        ...data,
        module: currentModule // IMPORTANTE: adicionar módulo
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/customers', customerId, 'my-new-tables'] });
      setIsDialogOpen(false);
      toast({ title: 'Item criado com sucesso!' });
    },
    onError: () => {
      toast({ title: 'Erro ao criar item', variant: 'destructive' });
    },
  });
  
  return (
    <div>
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogTrigger asChild>
          <Button data-testid="button-create-item">
            <Plus className="w-4 h-4 mr-2" />
            Novo Item
          </Button>
        </DialogTrigger>
        <DialogContent className="max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Novo Item</DialogTitle>
          </DialogHeader>
          {/* Form here */}
        </DialogContent>
      </Dialog>
      
      {/* List items */}
      {isLoading ? <p>Carregando...</p> : (
        <div>
          {items.map(item => (
            <div key={item.id}>{item.name}</div>
          ))}
        </div>
      )}
    </div>
  );
}
```

#### 5. Registrar Rota (client/src/App.tsx)

```typescript
import MyNewFeature from "@/pages/my-new-feature";

function App() {
  return (
    <Route path="/my-new-feature" component={MyNewFeature} />
  );
}
```

#### 6. Adicionar ao Menu (client/src/components/layout/sidebar.tsx)

```typescript
// Adicionar ao array de menuItems
{
  label: 'Minha Feature',
  icon: Star, // Escolher ícone
  path: '/my-new-feature',
  modules: ['clean', 'maintenance'], // ou ['maintenance'] se exclusivo
}
```

#### 7. Push Schema para Database

```bash
npm run db:push
# Ou se houver warning de data loss:
npm run db:push --force
```

### Checklist de Desenvolvimento

- [ ] Schema definido em `shared/schema.ts`
- [ ] Relações criadas
- [ ] Zod schemas exportados
- [ ] Storage interface atualizada
- [ ] Storage implementation criada
- [ ] Rotas backend criadas com validação
- [ ] Frontend page criada
- [ ] Queries/mutations implementadas
- [ ] Forms validados com Zod
- [ ] Dialogs com `max-h-[90vh] overflow-y-auto`
- [ ] `data-testid` em elementos interativos
- [ ] Module filtering aplicado (se relevante)
- [ ] Rota registrada em App.tsx
- [ ] Menu item adicionado (se aplicável)
- [ ] Database migrada (`npm run db:push`)
- [ ] Testado em ambos os módulos (se relevante)

### Padrões de Código

#### Naming Conventions

```typescript
// Components: PascalCase
MyComponent.tsx

// Files: kebab-case
my-feature-page.tsx

// Variables: camelCase
const myVariable = 'value';

// Constants: SCREAMING_SNAKE_CASE
const API_BASE_URL = '/api';

// Types/Interfaces: PascalCase
type MyType = { ... }
interface IMyInterface { ... }

// Database tables: snake_case
export const my_table = pgTable('my_table', { ... });

// API routes: kebab-case
GET /api/my-feature-items
```

#### Folder Organization

```
client/src/pages/
  - dashboard.tsx         # Main dashboards
  - work-orders.tsx       # Entity listing
  - work-order-detail.tsx # Single entity
  - settings.tsx          # Config pages
  
client/src/components/
  - layout/               # Layout components
  - ui/                   # shadcn primitives
  - (feature-specific)    # Apenas se reutilizável
```

#### Import Order

```typescript
// 1. React
import { useState } from 'react';

// 2. Third-party
import { useQuery } from '@tanstack/react-query';

// 3. UI Components
import { Button } from '@/components/ui/button';

// 4. Contexts/Hooks
import { useClient } from '@/contexts/ClientContext';

// 5. Utils
import { apiRequest } from '@/lib/queryClient';

// 6. Types
import type { MyType } from '@shared/schema';
```

---

## 📝 Changelog

### 04/11/2025 - Correção: Module Assignment em Service Categories/Types

**Problema**: Ao criar categorias ou tipos de serviço no módulo de Manutenção, o sistema não enviava o campo `module`, resultando em uso do valor padrão `'clean'`.

**Solução Implementada**:
- Atualizado `onSubmitType` em `service-settings.tsx` para incluir `module: currentModule` ao criar tipo de serviço
- Atualizado `onSubmitCategory` em `service-settings.tsx` para incluir `module: currentModule` ao criar categoria de serviço

**Arquivos Modificados**:
- `client/src/pages/service-settings.tsx`

**Impacto**:
- Categorias e tipos criados em Manutenção agora são corretamente atribuídos ao módulo `'maintenance'`
- Filtros por módulo funcionam corretamente
- Isolamento de dados mantido entre módulos

---

### 03/11/2025 - Melhorias de UX em Dialogs

**Problema**: Dialogs em telas menores não permitiam scroll, cortando conteúdo.

**Solução Implementada**:
- Adicionado `max-h-[90vh] overflow-y-auto` a 8+ dialogs no sistema
- Formulários longos agora têm scroll interno
- Reset automático de forms ao fechar dialogs

**Arquivos Modificados**:
- `client/src/pages/service-settings.tsx`
- `client/src/pages/users.tsx`
- `client/src/pages/sites.tsx`
- (outros)

**Padrão Estabelecido**:
Todos os novos dialogs devem usar:
```tsx
<DialogContent className="max-h-[90vh] overflow-y-auto">
```

---

### 02/11/2025 - Fix: ClientContext LocalStorage Bug

**Problema**: useEffect no ClientContext resetava `activeClientId` toda vez que o usuário fazia login, impedindo fluxo de seleção de módulo.

**Solução Implementada**:
- Removido useEffect problemático que resetava localStorage
- Mantido apenas lógica de inicialização no mounting

**Arquivos Modificados**:
- `client/src/contexts/ClientContext.tsx`

**Impacto**:
- Fluxo de login → seleção de módulo funciona corretamente
- localStorage persistente entre reloads

---

### 01/11/2025 - Implementação: Module Inheritance System

**Feature**: Sistema de herança de módulos para customer_user.

**Implementação**:
- `customer_user` agora herda módulos do registro do cliente (`customers.modules`)
- `opus_user` continua usando `users.modules`
- Endpoint `/api/auth/user-modules` retorna módulos corretos baseado em `userType`
- Frontend valida e desabilita checkboxes de módulos não disponíveis ao criar usuários

**Arquivos Criados**:
- `client/src/hooks/useUserModules.ts`

**Arquivos Modificados**:
- `server/routes.ts` (endpoint user-modules)
- `client/src/pages/users.tsx` (validação de módulos)

**Validação**:
- Backend valida se módulos selecionados estão disponíveis no cliente
- Frontend desabilita checkboxes de módulos indisponíveis

---

## 🔐 Segurança

### Práticas Implementadas

1. **Password Hashing**: Bcrypt com salt rounds adequados
2. **JWT Tokens**: Signed tokens para sessões
3. **CORS**: Configurado para domínios permitidos
4. **Helmet**: Headers de segurança HTTP
5. **Rate Limiting**: Proteção contra brute force
6. **SQL Injection**: Drizzle ORM previne (parameterized queries)
7. **XSS**: React escapa output automaticamente
8. **CSRF**: Token-based auth mitiga
9. **Input Validation**: Zod valida todos os inputs

### Variáveis de Ambiente

```bash
# Database
DATABASE_URL=postgresql://...
PGHOST=...
PGPORT=5432
PGUSER=...
PGPASSWORD=...
PGDATABASE=...

# Auth
JWT_SECRET=your-secret-key

# Microsoft SSO (opcional)
MS_CLIENT_ID=...
MS_CLIENT_SECRET=...
MS_TENANT_ID=...
```

**IMPORTANTE**: Nunca commitar secrets no código. Usar secrets do Replit.

---

## 🚀 Deploy

### Replit Deployment

O projeto está configurado para deploy no Replit. O sistema já está configurado com:

- PostgreSQL database (Neon)
- Environment secrets
- Workflow: `npm run dev`

### Processo de Deploy

1. Garantir que todos os secrets estão configurados
2. Executar `npm run db:push` para sincronizar schema
3. Clicar em "Deploy" na interface do Replit
4. Selecionar tipo de deployment (autoscale recomendado)

---

## 📚 Referências Técnicas

### Bibliotecas Principais

- **React**: https://react.dev
- **TypeScript**: https://www.typescriptlang.org
- **Vite**: https://vitejs.dev
- **TanStack Query**: https://tanstack.com/query
- **Drizzle ORM**: https://orm.drizzle.team
- **shadcn/ui**: https://ui.shadcn.com
- **Tailwind CSS**: https://tailwindcss.com
- **Wouter**: https://github.com/molefrog/wouter

### Documentação Interna

- **replit.md**: Resumo do projeto e preferências
- **shared/schema.ts**: Fonte da verdade para tipos de dados
- **DOCUMENTATION.md**: Este arquivo (documentação completa)

---

## 🎯 Roadmap Futuro

### Funcionalidades Planejadas

- [ ] Módulo OPUS Controle de Acesso
- [ ] Módulo OPUS Recepção
- [ ] Notificações push (mobile)
- [ ] Chat em tempo real (work orders)
- [ ] Exportação de relatórios (PDF/Excel)
- [ ] Integração com WhatsApp (solicitações)
- [ ] Dashboard customizável (drag & drop)
- [ ] Multi-idioma (i18n)

### Melhorias Técnicas

- [ ] Testes automatizados (Jest + Testing Library)
- [ ] CI/CD pipeline
- [ ] Monitoring e logging estruturado
- [ ] Performance optimization (lazy loading, code splitting)
- [ ] PWA support (offline-first)
- [ ] WebSocket para updates em tempo real

---

## 👥 Suporte

Para questões técnicas ou bugs, documentar neste arquivo na seção Changelog.

---

**Fim da Documentação**
