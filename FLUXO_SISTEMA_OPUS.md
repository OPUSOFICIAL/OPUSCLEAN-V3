# Fluxo do Sistema OPUS - Documentação Técnica

**Data:** Novembro 2025  
**Versão:** 2.0 (Arquitetura Modular)

---

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura Modular](#arquitetura-modular)
3. [Fluxo de Autenticação](#fluxo-de-autenticação)
4. [Fluxo de Roteamento](#fluxo-de-roteamento)
5. [Fluxo de Dados (Frontend → Backend)](#fluxo-de-dados-frontend--backend)
6. [Seleção e Troca de Módulo](#seleção-e-troca-de-módulo)
7. [Criação de Registros](#criação-de-registros)
8. [Pontos de Adaptação para Novos Módulos](#pontos-de-adaptação-para-novos-módulos)
9. [Diagramas de Fluxo](#diagramas-de-fluxo)

---

## Visão Geral

O **OPUS** é uma plataforma modular de gestão de facilities que suporta múltiplos módulos especializados:

- **OPUS Clean**: Gestão de limpeza e facilities
- **OPUS Manutenção**: Gestão de manutenção

A arquitetura modular permite que cada módulo tenha:
- **Dados isolados** (work orders, serviços, atividades separadas por módulo)
- **Temas visuais próprios** (Clean: azul navy, Manutenção: laranja)
- **Regras de negócio específicas** (workflows adaptados por domínio)

---

## Arquitetura Modular

### Camadas da Aplicação

```
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE APRESENTAÇÃO                   │
│                                                             │
│  React + TypeScript + TanStack Query + Wouter              │
│  • Componentes UI (shadcn/ui)                               │
│  • Páginas por módulo (Dashboard, Work Orders, etc)         │
│  • Context API (ModuleProvider, ClientProvider)             │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                      CAMADA DE API                          │
│                                                             │
│  Express.js + TypeScript                                    │
│  • Rotas RESTful (/api/*)                                   │
│  • Middleware de autenticação (JWT)                         │
│  • Validação com Zod                                        │
│  • Filtros por módulo via query params                      │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                   CAMADA DE NEGÓCIO                         │
│                                                             │
│  Storage Layer (IStorage interface)                         │
│  • Lógica de negócio                                        │
│  • Queries complexas                                        │
│  • Filtros multi-tenancy + módulo                           │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                   CAMADA DE DADOS                           │
│                                                             │
│  PostgreSQL + Drizzle ORM                                   │
│  • Tabelas com discriminador 'module'                       │
│  • Isolamento de dados por módulo                           │
│  • Multi-tenancy (company > customer > site > zone)         │
└─────────────────────────────────────────────────────────────┘
```

### Provedores de Contexto (App.tsx)

A aplicação é envolvida por múltiplos provedores que fornecem serviços globais:

```typescript
<ErrorBoundary>                     // Captura erros globais
  <QueryClientProvider>             // Cache e gerenciamento de queries
    <ModuleProvider>                // Contexto do módulo ativo
      <ClientProvider>              // Contexto do cliente ativo
        <TooltipProvider>           // UI tooltips
          <Toaster />               // Sistema de notificações
          <Router />                // Roteamento principal
        </TooltipProvider>
      </ClientProvider>
    </ModuleProvider>
  </QueryClientProvider>
</ErrorBoundary>
```

**Responsabilidades de cada Provider:**

1. **ErrorBoundary**: Captura erros React e exibe fallback UI
2. **QueryClientProvider**: Gerencia cache de queries, invalidação, refetch
3. **ModuleProvider**: 
   - Armazena módulo atual (clean/maintenance)
   - Aplica temas CSS dinamicamente
   - Persiste escolha no localStorage
4. **ClientProvider**: Gerencia cliente ativo para multi-tenancy
5. **TooltipProvider**: Habilita tooltips do shadcn/ui
6. **Router**: Gerencia navegação e rotas da aplicação

---

## Fluxo de Autenticação

### 1. Entrada no Sistema

```
USUÁRIO ACESSA → App.tsx → Router()
                              ↓
                    Verifica isAuthenticated
                              ↓
              ┌───────────────┴────────────────┐
              │                                 │
         NÃO AUTENTICADO              AUTENTICADO
              ↓                                 ↓
      Mostra Login                    Verifica Role/Permissões
              │                                 │
              │                    ┌────────────┴─────────────┐
              │                    │                          │
              │              isMobileOnlyUser          Admin/Gestor
              │                    ↓                          ↓
              │              MobileRouter           AuthenticatedAdminRouter
              │                                               ↓
              │                                         Dashboard
              │
              └──> /login ou /login-mobile
```

### 2. Processo de Login

**Arquivo:** `client/src/pages/login.tsx` e `client/src/pages/login-mobile.tsx`

```typescript
// Usuário submete credenciais
handleLogin(credentials) {
  
  // 1. Chama API de autenticação
  const { user, token } = await login({
    username: "admin",
    password: "senha123"
  });
  
  // 2. Salva estado no localStorage
  setAuthState(user, token);
  // → localStorage.setItem('opus:auth', JSON.stringify({ user }))
  // → localStorage.setItem('opus:token', token)
  
  // 3. Redireciona baseado no role
  if (user.role === 'operador') {
    navigate('/mobile');        // Interface mobile
  } else {
    navigate('/');              // Dashboard desktop
  }
}
```

### 3. API de Autenticação

**Endpoint:** `POST /api/auth/login`

**Arquivo:** `server/routes.ts`

```typescript
app.post("/api/auth/login", async (req, res) => {
  const { username, password } = req.body;
  
  // 1. Busca usuário no banco
  const user = await storage.getUserByUsername(username);
  
  // 2. Valida senha (bcrypt)
  const isValid = await bcrypt.compare(password, user.passwordHash);
  
  // 3. Gera token JWT
  const token = jwt.sign(
    { userId: user.id, role: user.role },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
  
  // 4. Retorna usuário + token
  res.json({ user, token });
});
```

### 4. Middleware de Autenticação

Todas as rotas protegidas usam middleware JWT:

```typescript
// server/routes.ts
app.use(authenticateToken);

function authenticateToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'Token required' });
  }
  
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ message: 'Invalid token' });
    req.user = decoded;
    next();
  });
}
```

---

## Fluxo de Roteamento

### 1. Router Principal (App.tsx)

```typescript
function Router() {
  const { user, isAuthenticated } = useAuth();
  const { isMobileOnlyUser, isLoading } = usePermissions();

  // 🔒 Não autenticado
  if (!isAuthenticated || !user) {
    return (
      <Switch>
        <Route path="/qr-public/:code" component={QrPublic} />
        <Route path="/login" component={Login} />
        <Route component={Login} />  {/* Fallback */}
      </Switch>
    );
  }

  // ⏳ Carregando permissões
  if (isLoading) {
    return <div>Carregando permissões...</div>;
  }

  // 📱 Operador mobile
  if (isMobileOnlyUser) {
    return <MobileRouter />;
  }

  // 💼 Admin/Gestor/Cliente
  return <AuthenticatedAdminRouter />;
}
```

### 2. Rotas Desktop (AuthenticatedAdminRouter)

```typescript
function AuthenticatedAdminRouter() {
  return (
    <div className="flex">
      <Sidebar />
      <Switch>
        <Route path="/" component={Dashboard} />
        <Route path="/workorders" component={WorkOrders} />
        <Route path="/schedule" component={CleaningSchedule} />
        <Route path="/checklists" component={Checklists} />
        <Route path="/qrcodes" component={QrCodes} />
        <Route path="/sites" component={Sites} />
        <Route path="/floor-plan" component={FloorPlan} />
        <Route path="/users" component={SystemUsers} />
        <Route path="/customers" component={Customers} />
        <Route path="/roles" component={Roles} />
        <Route path="/reports" component={Reports} />
        <Route path="/audit-logs" component={AuditLogs} />
        <Route path="/service-settings" component={ServiceSettings} />
      </Switch>
    </div>
  );
}
```

### 3. Rotas Mobile (MobileRouter)

```typescript
function MobileRouter() {
  return (
    <Switch>
      <Route path="/mobile" component={MobileDashboard} />
      <Route path="/mobile/qr-scanner" component={MobileQrScanner} />
      <Route path="/mobile/work-order/:id" component={MobileWorkOrderExecute} />
      <Route path="/mobile/work-order-details/:id" component={MobileWorkOrderDetails} />
      <Route path="/qr-public/:code" component={QrPublic} />
    </Switch>
  );
}
```

### 4. Sistema de Permissões

**Arquivo:** `client/src/hooks/usePermissions.ts`

O sistema usa permissões granulares por função:

```typescript
const PERMISSIONS_BY_ROLE = {
  admin: [
    'dashboard_view',
    'workorders_view', 'workorders_create', 'workorders_edit',
    'users_view', 'users_create',
    'customers_view', 'customers_create',
    'roles_manage',
    // ... todas as permissões
  ],
  
  gestor_cliente: [
    'dashboard_view',
    'workorders_view',
    'reports_view',
    // ... permissões limitadas
  ],
  
  operador: [
    'workorders_view',
    'workorders_comment',
    // ... apenas mobile
  ]
};

// Uso nas páginas
const { can } = usePermissions();

if (can.viewReports(customerId)) {
  // Mostra página de relatórios
}
```

---

## Fluxo de Dados (Frontend → Backend)

### 1. Obtenção de Dados (GET)

#### Frontend: useQuery

**Arquivo:** `client/src/pages/dashboard.tsx`

```typescript
import { useModule } from '@/contexts/ModuleContext';

function Dashboard() {
  const { activeClientId } = useClient();
  const { currentModule } = useModule();  // 'clean' ou 'maintenance'
  
  // ✅ IDEAL: Passar module como query param
  const { data: workOrders } = useQuery({
    queryKey: [
      '/api/customers',
      activeClientId,
      'work-orders',
      { module: currentModule }  // Filtro de módulo
    ],
    enabled: !!activeClientId,
  });
  
  // Renderiza apenas work orders do módulo atual
  return <WorkOrdersList workOrders={workOrders} />;
}
```

**Como a query é construída:**

TanStack Query transforma a queryKey em URL:
```
queryKey: ['/api/customers', 'customer-123', 'work-orders', { module: 'clean' }]
         ↓
URL: /api/customers/customer-123/work-orders?module=clean
```

#### Backend: API Route

**Arquivo:** `server/routes.ts`

```typescript
app.get("/api/customers/:customerId/work-orders", async (req, res) => {
  try {
    // 1. Extrai parâmetros
    const { customerId } = req.params;
    const module = req.query.module as 'clean' | 'maintenance' | undefined;
    
    // 2. Chama storage com filtro de módulo
    const workOrders = await storage.getWorkOrdersByCustomer(
      customerId,
      module  // Passa module para filtrar
    );
    
    // 3. Retorna dados
    res.json(workOrders);
    
  } catch (error) {
    res.status(500).json({ message: "Failed to get work orders" });
  }
});
```

#### Storage Layer

**Arquivo:** `server/storage.ts`

```typescript
async getWorkOrdersByCustomer(
  customerId: string,
  module?: 'clean' | 'maintenance'
): Promise<WorkOrder[]> {
  
  // 1. Busca sites do cliente (multi-tenancy)
  const customerSites = await db.select()
    .from(sites)
    .where(eq(sites.customerId, customerId));
  
  const siteIds = customerSites.map(s => s.id);
  
  // 2. Busca zonas dos sites
  const customerZones = await db.select()
    .from(zones)
    .where(inArray(zones.siteId, siteIds));
  
  const zoneIds = customerZones.map(z => z.id);
  
  // 3. Monta filtros
  const conditions = [
    inArray(workOrders.zoneId, zoneIds),  // Multi-tenancy
    module ? eq(workOrders.module, module) : sql`true`  // Módulo
  ];
  
  // 4. Query final
  return await db.select()
    .from(workOrders)
    .where(and(...conditions))
    .orderBy(desc(workOrders.createdAt));
}
```

#### Query SQL Gerada

```sql
SELECT * FROM work_orders
WHERE zone_id IN ('zone-1', 'zone-2', 'zone-3')  -- Multi-tenancy
  AND module = 'clean'                           -- Filtro de módulo
ORDER BY created_at DESC;
```

### 2. Múltiplas Queries em Paralelo

```typescript
function Dashboard() {
  const { currentModule } = useModule();
  const { activeClientId } = useClient();
  
  // TanStack Query executa todas em paralelo
  const { data: workOrders } = useQuery({
    queryKey: ['/api/customers', activeClientId, 'work-orders', { module: currentModule }]
  });
  
  const { data: sites } = useQuery({
    queryKey: ['/api/customers', activeClientId, 'sites']
  });
  
  const { data: stats } = useQuery({
    queryKey: ['/api/customers', activeClientId, 'dashboard-stats', { module: currentModule }]
  });
  
  // Renderiza quando todos estiverem carregados
}
```

---

## Seleção e Troca de Módulo

### 1. ModuleProvider (Contexto Global)

**Arquivo:** `client/src/contexts/ModuleContext.tsx`

```typescript
export const MODULE_CONFIGS = {
  clean: {
    id: 'clean',
    displayName: 'OPUS Clean',
    primaryColor: '#1e3a8a',    // Navy blue
    secondaryColor: '#3b82f6',
    accentColor: '#60a5fa',
    description: 'Gestão de Limpeza e Facilities',
    icon: '🧹',
  },
  maintenance: {
    id: 'maintenance',
    displayName: 'OPUS Manutenção',
    primaryColor: '#FF9800',    // Orange
    secondaryColor: '#FB8C00',
    accentColor: '#FFB74D',
    description: 'Gestão de Manutenção',
    icon: '🔧',
  },
};

export function ModuleProvider({ children }) {
  const [currentModule, setCurrentModule] = useState(() => {
    // Carrega do localStorage
    const stored = localStorage.getItem('opus:currentModule');
    return (stored === 'clean' || stored === 'maintenance') ? stored : 'clean';
  });

  useEffect(() => {
    // Salva no localStorage
    localStorage.setItem('opus:currentModule', currentModule);
    
    // Aplica atributo data-module no HTML
    document.documentElement.setAttribute('data-module', currentModule);
    
    // Aplica CSS variables
    const config = MODULE_CONFIGS[currentModule];
    document.documentElement.style.setProperty('--module-primary', config.primaryColor);
    document.documentElement.style.setProperty('--module-secondary', config.secondaryColor);
    document.documentElement.style.setProperty('--module-accent', config.accentColor);
  }, [currentModule]);

  return (
    <ModuleContext.Provider value={{ currentModule, setModule: setCurrentModule, moduleConfig }}>
      {children}
    </ModuleContext.Provider>
  );
}
```

### 2. Sidebar: Seletor de Plataforma

**Arquivo:** `client/src/components/layout/sidebar.tsx`

```typescript
function Sidebar() {
  const { currentModule, setModule } = useModule();
  
  return (
    <aside>
      {/* ... logo, cliente ... */}
      
      {/* Seletor de Plataforma */}
      <div className="px-6 pt-1 pb-3 border-b">
        <label>Plataforma</label>
        <Select 
          value={currentModule} 
          onValueChange={(value) => setModule(value as 'clean' | 'maintenance')}
        >
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="clean">
              🏢 OPUS Clean
            </SelectItem>
            <SelectItem value="maintenance">
              🔧 OPUS Manutenção
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      {/* ... navegação ... */}
    </aside>
  );
}
```

### 3. Efeito da Troca de Módulo

Quando o usuário troca de módulo no sidebar:

```
Usuário seleciona "OPUS Manutenção"
         ↓
setModule('maintenance')
         ↓
ModuleProvider atualiza:
  1. localStorage.setItem('opus:currentModule', 'maintenance')
  2. document.documentElement.setAttribute('data-module', 'maintenance')
  3. CSS variables mudam para laranja
         ↓
Componentes que usam useModule() re-renderizam
         ↓
Queries são invalidadas e refeitas com module='maintenance'
         ↓
Apenas dados de manutenção são mostrados
```

### 4. CSS Theming Dinâmico

**Arquivo:** `client/src/index.css`

```css
:root {
  --module-primary: #1e3a8a;   /* Default: Clean */
  --module-secondary: #3b82f6;
  --module-accent: #60a5fa;
}

/* Tema Clean */
[data-module="clean"] {
  --primary: hsl(215 84% 27%);
  --ring: hsl(215 84% 27%);
  --chart-1: hsl(215 84% 27%);
}

/* Tema Manutenção */
[data-module="maintenance"] {
  --primary: hsl(26 100% 50%);  /* Orange */
  --ring: hsl(26 100% 50%);
  --chart-1: hsl(26 98% 50%);
}
```

Todas as cores primárias, rings, charts mudam automaticamente!

---

## Criação de Registros

### 1. Frontend: Formulário com Mutation

**Exemplo:** Criar Work Order

```typescript
function WorkOrderModal() {
  const { currentModule } = useModule();
  const { activeClientId } = useClient();
  
  const createMutation = useMutation({
    mutationFn: async (data) => {
      return apiRequest('POST', '/api/work-orders', {
        ...data,
        module: currentModule  // ✅ Inclui módulo
      });
    },
    onSuccess: () => {
      // Invalida cache para refetch
      queryClient.invalidateQueries({
        queryKey: ['/api/customers', activeClientId, 'work-orders']
      });
    }
  });
  
  const handleSubmit = (formData) => {
    createMutation.mutate({
      title: formData.title,
      zoneId: formData.zoneId,
      priority: formData.priority,
      // module será adicionado automaticamente
    });
  };
  
  return <Form onSubmit={handleSubmit}>...</Form>;
}
```

### 2. Backend: Validação e Criação

**Arquivo:** `server/routes.ts`

```typescript
app.post("/api/work-orders", async (req, res) => {
  try {
    // 1. Validação com Zod
    const validatedData = insertWorkOrderSchema.parse({
      ...req.body,
      module: req.body.module || 'clean'  // Default clean
    });
    
    // 2. Cria work order
    const workOrder = await storage.createWorkOrder(validatedData);
    
    // 3. Retorna criado
    res.status(201).json(workOrder);
    
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ errors: error.errors });
    }
    res.status(500).json({ message: "Failed to create work order" });
  }
});
```

### 3. Storage: Inserção no Banco

**Arquivo:** `server/storage.ts`

```typescript
async createWorkOrder(workOrder: InsertWorkOrder): Promise<WorkOrder> {
  // 1. Gera número sequencial
  const number = await this.getNextWorkOrderNumber(workOrder.companyId);
  
  // 2. Insere no banco
  const [created] = await db.insert(workOrders)
    .values({
      ...workOrder,
      number,
      module: workOrder.module || 'clean',  // Garante módulo
      createdAt: new Date(),
      updatedAt: new Date(),
    })
    .returning();
  
  return created;
}
```

### 4. SQL Gerado

```sql
INSERT INTO work_orders (
  id, number, company_id, zone_id, title, priority,
  module, created_at, updated_at, ...
) VALUES (
  'wo-uuid-123', 42, 'company-1', 'zone-5', 'Limpeza sala',
  'media', 'clean', NOW(), NOW(), ...
)
RETURNING *;
```

---

## Pontos de Adaptação para Novos Módulos

### 1. Schema Database

**Arquivo:** `shared/schema.ts`

Para adicionar campos específicos de um módulo:

```typescript
export const workOrders = pgTable("work_orders", {
  // ... campos compartilhados ...
  module: moduleEnum("module").notNull().default('clean'),
  
  // 🧹 OPUS Clean
  cleaningActivityId: varchar("cleaning_activity_id")
    .references(() => cleaningActivities.id),
  
  // 🔧 OPUS Manutenção (NOVO)
  maintenanceActivityId: varchar("maintenance_activity_id")
    .references(() => maintenanceActivities.id),
  equipmentId: varchar("equipment_id")
    .references(() => equipment.id),
});

// Nova tabela para Manutenção
export const maintenanceActivities = pgTable("maintenance_activities", {
  id: varchar("id").primaryKey(),
  module: moduleEnum("module").notNull().default('maintenance'),
  name: varchar("name").notNull(),
  frequency: frequencyEnum("frequency").notNull(),
  equipmentType: varchar("equipment_type"),
  // ... campos específicos ...
});
```

### 2. Storage Layer

**Adicionar métodos específicos:**

```typescript
interface IStorage {
  // Métodos compartilhados
  getWorkOrdersByCustomer(customerId: string, module?: ModuleType): Promise<WorkOrder[]>;
  
  // 🔧 Métodos específicos de Manutenção
  getMaintenanceActivitiesByCustomer(customerId: string): Promise<MaintenanceActivity[]>;
  getEquipmentByZone(zoneId: string): Promise<Equipment[]>;
  createMaintenancePlan(plan: InsertMaintenancePlan): Promise<MaintenancePlan>;
}
```

### 3. Rotas API

**Arquivo:** `server/routes.ts`

```typescript
// Rotas específicas de Manutenção
app.get("/api/customers/:customerId/equipment", async (req, res) => {
  const equipment = await storage.getEquipmentByCustomer(req.params.customerId);
  res.json(equipment);
});

app.post("/api/maintenance-plans", async (req, res) => {
  const plan = await storage.createMaintenancePlan({
    ...req.body,
    module: 'maintenance'
  });
  res.json(plan);
});
```

### 4. Páginas Frontend

**Criar páginas específicas:**

```
client/src/pages/
  ├── dashboard.tsx              (compartilhado)
  ├── work-orders.tsx            (compartilhado)
  ├── schedule.tsx               (Clean: plano de limpeza)
  ├── maintenance-plans.tsx      (Manutenção: planos de manutenção) ✨ NOVO
  ├── equipment.tsx              (Manutenção: equipamentos) ✨ NOVO
  └── preventive-calendar.tsx    (Manutenção: calendário preventivo) ✨ NOVO
```

### 5. Sidebar: Menus Condicionais

```typescript
function Sidebar() {
  const { currentModule } = useModule();
  
  const menuItems = [
    // Compartilhado
    { path: "/", label: "Dashboard", icon: Home },
    { path: "/workorders", label: "Ordens de Serviço", icon: ClipboardList },
    
    // Condicional por módulo
    ...(currentModule === 'clean' ? [
      { path: "/schedule", label: "Plano de Limpeza", icon: Calendar },
    ] : []),
    
    ...(currentModule === 'maintenance' ? [
      { path: "/maintenance-plans", label: "Planos de Manutenção", icon: Wrench },
      { path: "/equipment", label: "Equipamentos", icon: Cog },
    ] : []),
  ];
  
  return <nav>{/* renderiza menuItems */}</nav>;
}
```

---

## Diagramas de Fluxo

### Diagrama 1: Autenticação Completa

```
┌─────────────┐
│   USUÁRIO   │
│  acessa /   │
└──────┬──────┘
       │
       ↓
┌──────────────────────────────────────┐
│ Router verifica isAuthenticated      │
└──────┬───────────────────────────────┘
       │
       ├─ NÃO → /login
       │         │
       │         ↓
       │    ┌─────────────────────┐
       │    │ Login.tsx           │
       │    │ • Usuário digita    │
       │    │ • POST /api/login   │
       │    │ • Recebe token      │
       │    │ • setAuthState()    │
       │    └──────┬──────────────┘
       │           │
       │           ↓
       │    localStorage.setItem('opus:auth', user)
       │    localStorage.setItem('opus:token', token)
       │           │
       │           ↓
       │    Redireciona por role:
       │    • operador → /mobile
       │    • outros → /
       │
       └─ SIM → Verifica permissões
                │
                ├─ isMobileOnlyUser → MobileRouter
                │                      (interface mobile)
                │
                └─ Admin/Gestor → AuthenticatedAdminRouter
                                   (interface desktop)
                                   │
                                   ↓
                              ┌─────────────┐
                              │  Dashboard  │
                              └─────────────┘
```

### Diagrama 2: Fluxo de Query com Módulo

```
┌────────────────────────────────────────────────────────────┐
│ PÁGINA: Dashboard.tsx                                      │
│                                                            │
│ const { currentModule } = useModule();  // 'clean'         │
│                                                            │
│ useQuery({                                                 │
│   queryKey: ['/api/customers', 'customer-123',            │
│              'work-orders', { module: currentModule }]     │
│ });                                                        │
└─────────────────────┬──────────────────────────────────────┘
                      │
                      ↓ TanStack Query constrói URL
                      │
  GET /api/customers/customer-123/work-orders?module=clean
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│ API ROUTE: server/routes.ts                                │
│                                                            │
│ app.get("/api/customers/:customerId/work-orders",         │
│   async (req, res) => {                                    │
│     const module = req.query.module; // 'clean'            │
│     const workOrders = await storage                       │
│       .getWorkOrdersByCustomer(customerId, module);        │
│   }                                                        │
│ );                                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│ STORAGE: server/storage.ts                                 │
│                                                            │
│ async getWorkOrdersByCustomer(                             │
│   customerId: string,                                      │
│   module?: 'clean' | 'maintenance'                         │
│ ) {                                                        │
│   // Multi-tenancy                                         │
│   const sites = await getSitesByCustomer(customerId);      │
│   const zones = await getZonesBySites(sites);              │
│                                                            │
│   // Query com filtro                                      │
│   return db.select()                                       │
│     .from(workOrders)                                      │
│     .where(and(                                            │
│       inArray(workOrders.zoneId, zoneIds),                 │
│       module ? eq(workOrders.module, module) : sql`true`   │
│     ));                                                    │
│ }                                                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────┐
│ POSTGRESQL                                                  │
│                                                            │
│ SELECT * FROM work_orders                                  │
│ WHERE zone_id IN ('zone-1', 'zone-2')  -- Multi-tenancy    │
│   AND module = 'clean'                 -- Isolamento       │
│ ORDER BY created_at DESC;                                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ↓ Retorna dados
                      │
              ┌───────┴────────┐
              │  Work Orders   │
              │  do OPUS Clean │
              └────────────────┘
```

### Diagrama 3: Troca de Módulo

```
┌──────────────────────────────────────────────────────────┐
│ SIDEBAR: Usuário seleciona "OPUS Manutenção"            │
└─────────────────────┬────────────────────────────────────┘
                      │
                      ↓
                setModule('maintenance')
                      │
                      ↓
┌──────────────────────────────────────────────────────────┐
│ ModuleProvider.useEffect()                               │
│                                                          │
│ 1. localStorage.setItem('opus:currentModule',           │
│                          'maintenance')                  │
│                                                          │
│ 2. document.documentElement.setAttribute(               │
│      'data-module', 'maintenance')                       │
│                                                          │
│ 3. document.documentElement.style.setProperty(          │
│      '--module-primary', '#FF9800')  // Laranja         │
│                                                          │
│ 4. Dispara re-render de componentes                     │
└─────────────────────┬────────────────────────────────────┘
                      │
        ┌─────────────┴──────────────┐
        │                            │
        ↓                            ↓
┌───────────────┐          ┌──────────────────┐
│ CSS muda      │          │ Queries          │
│ para laranja  │          │ invalidadas      │
└───────────────┘          └────────┬─────────┘
                                    │
                                    ↓
                    Refetch com module='maintenance'
                                    │
                                    ↓
                    ┌──────────────────────────┐
                    │ Dashboard mostra apenas  │
                    │ dados de Manutenção      │
                    └──────────────────────────┘
```

---

## Resumo dos Arquivos Principais

| Arquivo | Responsabilidade |
|---------|------------------|
| `client/src/App.tsx` | Roteamento principal e provedores |
| `client/src/contexts/ModuleContext.tsx` | Gerenciamento de módulo ativo |
| `client/src/contexts/ClientContext.tsx` | Gerenciamento de cliente ativo |
| `client/src/components/layout/sidebar.tsx` | Navegação e seletor de módulo |
| `client/src/pages/*` | Páginas da aplicação |
| `client/src/lib/auth.ts` | Funções de autenticação |
| `server/routes.ts` | Rotas da API |
| `server/storage.ts` | Camada de negócio |
| `shared/schema.ts` | Schema do banco de dados |
| `client/src/index.css` | Temas CSS por módulo |

---

## Checklist para Adicionar Novo Módulo

- [ ] **1. Database Schema** - Adicionar ENUM ao moduleEnum
- [ ] **2. MODULE_CONFIGS** - Adicionar configuração do módulo
- [ ] **3. Temas CSS** - Adicionar `[data-module="novo"]` no index.css
- [ ] **4. Storage Layer** - Adicionar métodos específicos se necessário
- [ ] **5. API Routes** - Adicionar rotas específicas se necessário
- [ ] **6. Páginas Frontend** - Criar páginas específicas
- [ ] **7. Sidebar** - Adicionar menus condicionais
- [ ] **8. Push Schema** - Rodar `npm run db:push` para aplicar mudanças
- [ ] **9. Testar Isolamento** - Verificar que dados não vazam entre módulos
- [ ] **10. Documentar** - Atualizar este documento com novidades

---

**Fim da Documentação**

*Este documento deve ser atualizado conforme novos módulos ou funcionalidades forem adicionados ao sistema OPUS.*
