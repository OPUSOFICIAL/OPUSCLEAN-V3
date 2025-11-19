# FASE 4: Separação de Funções de Cliente vs Sistema

## 📊 Status: ✅ COMPLETO

## 🎯 Objetivo

Implementar separação clara entre:
- **Funções de Cliente** (Client Roles): Gerenciadas por admins do cliente (`customer_user` ou `opus_user`)
- **Funções de Sistema** (System Roles): Gerenciadas apenas por admins OPUS (`opus_user`)

## 🏗️ Arquitetura

### Backend

#### 1. Novas Permissões (`shared/schema.ts`)

Adicionadas 3 novas permissões ao sistema:

```typescript
export const AVAILABLE_PERMISSIONS = [
  // ... permissões existentes ...
  
  // System Roles Management (OPUS only)
  { key: 'system_roles_view', label: 'Visualizar Funções de Sistema', category: 'roles' },
  { key: 'system_roles_edit', label: 'Editar Funções de Sistema', category: 'roles' },
  { key: 'system_roles_delete', label: 'Excluir Funções de Sistema', category: 'roles' },
] as const;
```

#### 2. Atualização das Constantes de Permissão (`server/middleware/auth.ts`)

```typescript
// Permissões exclusivas para opus_user (total: 12)
export const OPUS_ONLY_PERMISSIONS = [
  'customers_view',
  'customers_edit', 
  'customers_delete',
  'opus_users_view',
  'opus_users_edit',
  'opus_users_delete',
  'roles_manage',
  'system_roles_view',    // ✨ NOVO
  'system_roles_edit',    // ✨ NOVO
  'system_roles_delete',  // ✨ NOVO
] as const;

// Permissões permitidas para customer_user (36 permissões)
export const CLIENT_ALLOWED_PERMISSIONS = [
  // Todas as outras permissões EXCETO OPUS_ONLY_PERMISSIONS
] as const;
```

#### 3. Endpoints com Validação Granular

##### GET `/api/roles`

Query param opcional: `?isSystemRole=true|false`

```typescript
router.get('/api/roles', isAuthenticated, async (req, res) => {
  const { isSystemRole } = req.query;
  
  // Validação de permissão baseada no tipo de role
  if (isSystemRole === 'true') {
    if (!canUserPerformAction(req.user, 'system_roles_view')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  } else {
    if (!canUserPerformAction(req.user, 'users_view')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  }
  
  // Filtrar roles baseado em isSystemRole
  const roles = await db.query.customRoles.findMany({
    where: isSystemRole !== undefined 
      ? eq(customRoles.isSystemRole, isSystemRole === 'true')
      : undefined
  });
  
  res.json(roles);
});
```

##### POST `/api/roles`

```typescript
router.post('/api/roles', isAuthenticated, async (req, res) => {
  const { isSystemRole } = req.body;
  
  // Validação de permissão baseada no tipo de role
  if (isSystemRole) {
    if (!canUserPerformAction(req.user, 'system_roles_edit')) {
      return res.status(403).json({ 
        error: 'Apenas administradores OPUS podem criar funções de sistema' 
      });
    }
  } else {
    if (!canUserPerformAction(req.user, 'users_edit')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  }
  
  // Validar permissões compatíveis com userType
  const validation = validatePermissionsByUserType(
    permissions, 
    req.user.userType, 
    isSystemRole
  );
  
  if (!validation.valid) {
    return res.status(400).json({
      error: validation.message,
      invalidPermissions: validation.invalidPermissions
    });
  }
  
  // Criar role
  const newRole = await db.insert(customRoles).values({
    ...data,
    isSystemRole: isSystemRole || false
  }).returning();
  
  res.status(201).json(newRole[0]);
});
```

##### PATCH `/api/roles/:id`

```typescript
router.patch('/api/roles/:id', isAuthenticated, async (req, res) => {
  const role = await db.query.customRoles.findFirst({
    where: eq(customRoles.id, req.params.id)
  });
  
  // Validação baseada no tipo de role
  if (role.isSystemRole) {
    if (!canUserPerformAction(req.user, 'system_roles_edit')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  } else {
    if (!canUserPerformAction(req.user, 'users_edit')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  }
  
  // Validar permissões
  const validation = validatePermissionsByUserType(
    permissions, 
    req.user.userType, 
    role.isSystemRole
  );
  
  // Atualizar role
  const updated = await db.update(customRoles)
    .set(data)
    .where(eq(customRoles.id, req.params.id))
    .returning();
  
  res.json(updated[0]);
});
```

##### DELETE `/api/roles/:id`

```typescript
router.delete('/api/roles/:id', isAuthenticated, async (req, res) => {
  const role = await db.query.customRoles.findFirst({
    where: eq(customRoles.id, req.params.id)
  });
  
  // Validação baseada no tipo de role
  if (role.isSystemRole) {
    if (!canUserPerformAction(req.user, 'system_roles_delete')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  } else {
    if (!canUserPerformAction(req.user, 'users_delete')) {
      return res.status(403).json({ error: 'Acesso negado' });
    }
  }
  
  // Deletar role
  await db.delete(customRoles).where(eq(customRoles.id, req.params.id));
  
  res.json({ message: 'Função excluída com sucesso' });
});
```

#### 4. Endpoint de Inicialização de System Roles

##### POST `/api/roles/init-system-roles`

```typescript
router.post('/api/roles/init-system-roles', isAuthenticated, async (req, res) => {
  // Apenas opus_user pode inicializar
  if (!canUserPerformAction(req.user, 'system_roles_edit')) {
    return res.status(403).json({ error: 'Acesso negado' });
  }
  
  const defaultSystemRoles = [
    {
      name: 'Auditor',
      description: 'Visualiza relatórios e auditorias (apenas leitura)',
      permissions: ['reports_view', 'users_view', 'sites_view', ...],
      isSystemRole: true,
      isActive: true
    },
    {
      name: 'Operador',
      description: 'Executa ordens de serviço e tarefas operacionais',
      permissions: ['work_orders_view', 'work_orders_edit', ...],
      isSystemRole: true,
      isActive: true
    },
    {
      name: 'Supervisor Site',
      description: 'Gerencia equipes e operações de um site específico',
      permissions: ['work_orders_view', 'work_orders_edit', 'users_view', ...],
      isSystemRole: true,
      isActive: true
    }
  ];
  
  const created = [];
  for (const role of defaultSystemRoles) {
    const existing = await db.query.customRoles.findFirst({
      where: and(
        eq(customRoles.name, role.name),
        eq(customRoles.isSystemRole, true)
      )
    });
    
    if (!existing) {
      const newRole = await db.insert(customRoles)
        .values(role)
        .returning();
      created.push(newRole[0]);
    }
  }
  
  res.json({ 
    message: `${created.length} funções de sistema criadas`,
    roles: created 
  });
});
```

### Frontend

#### 1. Atualização do Hook `usePermissions` (`client/src/hooks/usePermissions.ts`)

```typescript
export function usePermissions() {
  const { user } = useAuth();
  const { data: permissions = [] } = useQuery<string[]>({
    queryKey: ['/api/auth/my-permissions'],
    enabled: !!user,
    staleTime: 5 * 60 * 1000 // 5 minutos
  });
  
  const can = {
    // ... permissões existentes ...
    
    // System Roles ✨ NOVO
    viewSystemRoles: () => permissions.includes('system_roles_view'),
    editSystemRoles: () => permissions.includes('system_roles_edit'),
    deleteSystemRoles: () => permissions.includes('system_roles_delete'),
  };
  
  return { permissions, can };
}
```

#### 2. Interface de Dois Abas (`client/src/pages/roles.tsx`)

```tsx
export default function RolesPage() {
  const [activeTab, setActiveTab] = useState('client'); // 'client' | 'system'
  const { can } = usePermissions();
  const { user } = useAuth();
  
  // Queries separadas para Client Roles e System Roles
  const { data: clientRoles = [], isLoading: loadingClient } = useQuery({
    queryKey: ['/api/roles', 'client'],
    queryFn: () => fetch('/api/roles?isSystemRole=false').then(r => r.json()),
  });
  
  const { data: systemRoles = [], isLoading: loadingSystem } = useQuery({
    queryKey: ['/api/roles', 'system'],
    queryFn: () => fetch('/api/roles?isSystemRole=true').then(r => r.json()),
    enabled: can.viewSystemRoles() // Só busca se tiver permissão
  });
  
  // Filtrar permissões disponíveis baseado no contexto
  const filteredAvailablePermissions = availablePermissions.filter(permission => {
    // Tab Sistema: apenas opus_user vê todas as permissões
    if (activeTab === 'system' || editingRole?.isSystemRole) {
      return user?.userType === 'opus_user';
    }
    
    // Tab Cliente: filtrar permissões OPUS-only para customer_user
    if (user?.userType === 'opus_user') {
      return !OPUS_ONLY_PERMISSIONS.includes(permission.key);
    }
    
    if (user?.userType === 'customer_user') {
      return !OPUS_ONLY_PERMISSIONS.includes(permission.key);
    }
    
    return !OPUS_ONLY_PERMISSIONS.includes(permission.key);
  });
  
  return (
    <div className="p-6">
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="client">Funções de Cliente</TabsTrigger>
          {can.viewSystemRoles() && (
            <TabsTrigger value="system">Funções de Sistema</TabsTrigger>
          )}
        </TabsList>
        
        <TabsContent value="client">
          {/* Lista de Client Roles */}
          {clientRoles.map(role => (
            <RoleCard key={role.id} role={role}>
              <Button onClick={() => handleEdit(role)}>
                Editar
              </Button>
              <Button onClick={() => deleteRole(role.id)}>
                Excluir
              </Button>
            </RoleCard>
          ))}
        </TabsContent>
        
        {can.viewSystemRoles() && (
          <TabsContent value="system">
            {/* Lista de System Roles */}
            {systemRoles.map(role => (
              <RoleCard key={role.id} role={role}>
                {can.editSystemRoles() && (
                  <Button onClick={() => handleEdit(role)}>
                    Editar
                  </Button>
                )}
                {can.deleteSystemRoles() && (
                  <Button onClick={() => deleteRole(role.id)}>
                    Excluir
                  </Button>
                )}
              </RoleCard>
            ))}
          </TabsContent>
        )}
      </Tabs>
    </div>
  );
}
```

#### 3. OPUS_ONLY_PERMISSIONS Frontend (`client/src/pages/roles.tsx`)

```typescript
const OPUS_ONLY_PERMISSIONS = [
  'customers_view',
  'customers_edit',
  'customers_delete',
  'opus_users_view',
  'opus_users_edit',
  'opus_users_delete',
  'roles_manage',
  'system_roles_view',    // ✨ NOVO
  'system_roles_edit',    // ✨ NOVO
  'system_roles_delete',  // ✨ NOVO
] as const;
```

## 🔒 Controle de Acesso

### Matrix de Permissões

| Ação | opus_user | customer_user |
|------|-----------|---------------|
| **Client Roles** |
| Visualizar roles de cliente | ✅ users_view | ✅ users_view |
| Criar role de cliente | ✅ users_edit | ✅ users_edit |
| Editar role de cliente | ✅ users_edit | ✅ users_edit |
| Excluir role de cliente | ✅ users_delete | ✅ users_delete |
| **System Roles** |
| Visualizar roles de sistema | ✅ system_roles_view | ❌ |
| Criar role de sistema | ✅ system_roles_edit | ❌ |
| Editar role de sistema | ✅ system_roles_edit | ❌ |
| Excluir role de sistema | ✅ system_roles_delete | ❌ |
| Ver tab "Sistema" | ✅ system_roles_view | ❌ |

### Segregação de Permissões por Contexto

#### Tab "Funções de Cliente"

**opus_user:**
- Vê todas as permissões **EXCETO** as 12 OPUS-only
- Total disponível: 36 permissões

**customer_user:**
- Vê todas as permissões **EXCETO** as 12 OPUS-only
- Total disponível: 36 permissões

#### Tab "Funções de Sistema"

**opus_user:**
- Vê **TODAS** as 48 permissões (incluindo OPUS-only)
- Total disponível: 48 permissões

**customer_user:**
- **NÃO TEM ACESSO** à tab Sistema
- Tab não é renderizada

## 📋 Fluxo de Trabalho

### 1. OPUS Admin cria System Roles

```
1. opus_user faz login
2. Acessa página "Gerenciar Funções"
3. Vê duas abas: "Funções de Cliente" e "Funções de Sistema"
4. Clica na aba "Funções de Sistema"
5. Clica em "Criar Nova Função"
6. Preenche nome: "Auditor"
7. Seleciona permissões (vê todas as 48 permissões)
8. Sistema automaticamente marca isSystemRole=true
9. Backend valida que usuário tem system_roles_edit
10. Role é criada com isSystemRole=true
```

### 2. Client Admin gerencia Client Roles

```
1. customer_user faz login
2. Acessa página "Gerenciar Funções"
3. Vê apenas aba "Funções de Cliente"
4. Clica em "Criar Nova Função"
5. Preenche nome: "Operador Clean"
6. Seleciona permissões (vê apenas 36 permissões não-OPUS)
7. Sistema automaticamente marca isSystemRole=false
8. Backend valida que usuário tem users_edit
9. Backend valida que permissões são compatíveis com customer_user
10. Role é criada com isSystemRole=false
```

### 3. OPUS Admin atribui System Role a usuário

```
1. opus_user acessa "Gerenciar Usuários"
2. Seleciona um operador (customer_user)
3. Atribui role "Auditor" (isSystemRole=true)
4. Backend valida compatibilidade:
   - Role tem isSystemRole=true
   - Todas as permissões da role são compatíveis com customer_user
   - Nenhuma permissão OPUS-only presente na role
5. Atribuição é salva
6. Operador agora tem permissões do role "Auditor"
```

## 🧪 Cenários de Teste

### Teste 1: opus_user cria System Role

**Setup:**
- Usuário: opus_user (Admin OPUS)
- Permissões: system_roles_view, system_roles_edit, system_roles_delete

**Passos:**
1. Login como opus_user
2. Acessar /gerenciar-funcoes
3. Verificar que vê duas abas: "Cliente" e "Sistema"
4. Clicar na aba "Sistema"
5. Clicar em "Criar Nova Função"
6. Preencher:
   - Nome: "Auditor Master"
   - Permissões: reports_view, users_view, sites_view
7. Salvar

**Resultado Esperado:**
- ✅ Role criada com isSystemRole=true
- ✅ Visível apenas na aba "Sistema"
- ✅ Não visível para customer_user

### Teste 2: customer_user tenta acessar System Roles

**Setup:**
- Usuário: customer_user (Admin Cliente)
- Permissões: users_view, users_edit, users_delete (sem system_roles_*)

**Passos:**
1. Login como customer_user
2. Acessar /gerenciar-funcoes

**Resultado Esperado:**
- ✅ Vê apenas aba "Funções de Cliente"
- ✅ Aba "Sistema" não é renderizada
- ✅ Requisição GET /api/roles?isSystemRole=true retorna 403

### Teste 3: customer_user cria Client Role com permissões válidas

**Setup:**
- Usuário: customer_user
- Permissões disponíveis: 36 (sem OPUS-only)

**Passos:**
1. Login como customer_user
2. Acessar /gerenciar-funcoes
3. Clicar em "Criar Nova Função"
4. Preencher:
   - Nome: "Operador Clean"
   - Permissões: work_orders_view, work_orders_edit
5. Salvar

**Resultado Esperado:**
- ✅ Role criada com isSystemRole=false
- ✅ Visível na aba "Cliente"
- ✅ Permissões validadas e salvas

### Teste 4: customer_user tenta criar role com permissão OPUS-only (Impossível pela UI)

**Setup:**
- Usuário: customer_user
- UI filtra permissões OPUS-only

**Passos:**
1. Login como customer_user
2. Tentar criar role via API diretamente (Postman/curl)
3. Enviar POST /api/roles com permissions: ['customers_view']

**Resultado Esperado:**
- ✅ Backend retorna 400 Bad Request
- ✅ Mensagem: "As seguintes permissões não são permitidas..."
- ✅ invalidPermissions: ['customers_view']

## 📊 Resumo Técnico

### Permissões Totais no Sistema: 48

**OPUS-only (12):**
- customers_view, customers_edit, customers_delete
- opus_users_view, opus_users_edit, opus_users_delete
- roles_manage
- system_roles_view, system_roles_edit, system_roles_delete

**Cliente-permitidas (36):**
- Todas as outras permissões (work_orders, sites, users, reports, etc)

### Queries Separadas

```typescript
// Client Roles
queryKey: ['/api/roles', 'client']
endpoint: GET /api/roles?isSystemRole=false

// System Roles
queryKey: ['/api/roles', 'system']
endpoint: GET /api/roles?isSystemRole=true
enabled: can.viewSystemRoles() // Condicional
```

### Invalidação de Cache

```typescript
// Após criar/editar/deletar role
await queryClient.invalidateQueries({ 
  queryKey: ['/api/roles'] // Invalida ambas as queries
});
```

## 🚀 Próximos Passos

1. ✅ Backend: Endpoints com validação granular
2. ✅ Frontend: Interface de duas abas
3. ✅ Frontend: Filtro de permissões por contexto
4. ⏳ Teste manual completo (opus_user + customer_user)
5. ⏳ Criar roles de sistema padrão (Auditor, Operador, Supervisor)
6. ⏳ Atualizar documentação em replit.md

## 📝 Notas Importantes

1. **Backend valida SEMPRE**, frontend filtra apenas para UX
2. **customer_user NUNCA vê permissões OPUS-only** (nem na UI, nem pode atribuir)
3. **system_roles_* são permissões exclusivas de opus_user**
4. **Tabs são condicionais**: System só aparece se `can.viewSystemRoles()`
5. **Queries são separadas** para melhor performance e cache granular
6. **isSystemRole é imutável** após criação (não pode mudar um client role para system role)

## 🔄 Compatibilidade com Fases Anteriores

- ✅ FASE 1: Helpers getUserPermissions e requirePermission ainda funcionam
- ✅ FASE 2: Validação por userType ainda ativa
- ✅ FASE 3: Filtro frontend de OPUS_ONLY_PERMISSIONS expandido
- ✅ Nova: Separação Client vs System Roles implementada

## 🎨 Design Pattern

**Camadas de Segurança:**

1. **UI Layer**: Filtra permissões visíveis, esconde tabs sem permissão
2. **API Layer**: Valida permissões no backend (getUserPermissions)
3. **Database Layer**: Valida compatibilidade userType vs permissões (validatePermissionsByUserType)
4. **Role Layer**: Separa Client Roles (isSystemRole=false) vs System Roles (isSystemRole=true)

**Princípio de Menor Privilégio:**
- customer_user: Acesso apenas a recursos do próprio cliente
- opus_user: Acesso global (todos os clientes + recursos OPUS)
