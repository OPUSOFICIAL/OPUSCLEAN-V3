# FASE 3: Filtro Frontend de Permissões OPUS

**Status:** ✅ COMPLETO  
**Data:** 19 de Novembro de 2025  
**Objetivo:** Ocultar permissões OPUS-exclusivas na interface de criação/edição de roles quando o usuário logado for `customer_user`

---

## 📋 Resumo Executivo

A FASE 3 completa a migração do sistema de permissões, adicionando filtros no frontend para **impedir que customer_user visualize ou selecione permissões exclusivas da OPUS** ao criar ou editar custom roles. Isso complementa as validações de backend já implementadas nas FASES 1 e 2.

---

## 🎯 Problema Resolvido

Antes da FASE 3, o backend validava permissões corretamente, mas o frontend mostrava **todas as permissões** para qualquer usuário, incluindo permissões OPUS que customer_user não deveria ver:

- ❌ customer_user via permissões `customers_*`, `opus_users_*`, `roles_manage` na UI
- ❌ Confusão para o usuário (via permissões que não pode usar)
- ❌ Tentativas de criação de roles com permissões inválidas (bloqueadas no backend)

---

## ✅ Solução Implementada

### 1. Interface User Atualizada
**Arquivo:** `client/src/hooks/useAuth.ts`

```typescript
export interface User {
  id: string;
  companyId: string;
  username: string;
  email: string;
  name: string;
  role: 'admin' | 'gestor_cliente' | 'supervisor_site' | 'operador' | 'auditor';
  userType?: 'opus_user' | 'customer_user';  // ✅ NOVO CAMPO
  isActive: boolean;
}
```

**Mudança:** Adicionado campo `userType` opcional que é retornado pelo backend na autenticação.

---

### 2. Constantes OPUS no Frontend
**Arquivo:** `client/src/pages/roles.tsx`

```typescript
// Permissões exclusivas OPUS (sincronizar com backend)
const OPUS_ONLY_PERMISSIONS: PermissionKey[] = [
  'customers_view',
  'customers_create',
  'customers_edit',
  'customers_delete',
  'opus_users_view',
  'opus_users_create',
  'opus_users_edit',
  'opus_users_delete',
  'roles_manage',
];
```

**Importância:** Mesma lista do backend para consistência. Se o backend adicionar novas permissões OPUS, atualizar aqui também.

---

### 3. Lógica de Filtro de Permissões
**Arquivo:** `client/src/pages/roles.tsx`

```typescript
export default function Roles() {
  const { user } = useAuth();  // ✅ Buscar usuário logado
  const { availablePermissions } = usePermissions();

  // Filtrar permissões disponíveis baseado no userType
  const filteredAvailablePermissions = availablePermissions.filter(permission => {
    // Se for opus_user, pode ver todas as permissões
    if (user?.userType === 'opus_user') {
      return true;
    }
    
    // Se for customer_user, ocultar permissões OPUS
    if (user?.userType === 'customer_user') {
      return !OPUS_ONLY_PERMISSIONS.includes(permission.key);
    }
    
    // Fallback: se userType não definido, assumir customer_user (mais restritivo)
    return !OPUS_ONLY_PERMISSIONS.includes(permission.key);
  });

  // Usar filteredAvailablePermissions ao invés de availablePermissions
  const groupedPermissions = filteredAvailablePermissions.reduce(...)
}
```

**Lógica:**
1. **opus_user:** Vê todas as 45 permissões (incluindo OPUS)
2. **customer_user:** Vê apenas 36 permissões (sem OPUS)
3. **Fallback:** Se `userType` não definido, assume `customer_user` (segurança primeiro)

---

### 4. Uso das Permissões Filtradas
**Arquivo:** `client/src/pages/roles.tsx`

```typescript
// Antes:
const groupedPermissions = availablePermissions.reduce((acc, permission) => {
  // ...
}, {} as Record<string, typeof availablePermissions>);

// Depois:
const groupedPermissions = filteredAvailablePermissions.reduce((acc, permission) => {
  // ...
}, {} as Record<string, typeof filteredAvailablePermissions>);
```

**Impacto:** Todos os checkboxes de permissões no form agora renderizam apenas as permissões filtradas.

---

## 🧪 Cenários de Teste

### Teste 1: Login como OPUS User
1. Login como `admin@opus.com` (userType: `opus_user`)
2. Ir para: **Configurações > Roles & Permissões**
3. Clicar em "Criar Novo Role"
4. **Resultado Esperado:** 
   - ✅ Ver TODAS as 45 permissões
   - ✅ Incluindo `Gerenciar Clientes`, `Gerenciar Usuários OPUS`, `Gerenciar Roles`

### Teste 2: Login como Customer User
1. Login como `gestor@cliente.com` (userType: `customer_user`)
2. Ir para: **Configurações > Roles & Permissões**
3. Clicar em "Criar Novo Role"
4. **Resultado Esperado:** 
   - ✅ Ver apenas 36 permissões (sem OPUS)
   - ❌ NÃO ver `Gerenciar Clientes`
   - ❌ NÃO ver `Gerenciar Usuários OPUS`
   - ❌ NÃO ver `Gerenciar Roles`

### Teste 3: Editar Role Existente (Customer User)
1. Login como `customer_user`
2. Editar um role existente
3. **Resultado Esperado:** 
   - ✅ Ver apenas permissões permitidas para customer_user
   - ✅ Se o role tinha permissões OPUS (impossível em produção), elas não aparecem no form

---

## 🔒 Segurança em Camadas

### Camada 1: Backend Validation (FASE 2)
- POST `/api/roles`: Valida permissões no payload
- PATCH `/api/roles/:id`: Valida permissões no payload
- POST `/api/users/:userId/roles`: Valida compatibilidade do role com userType

**Status:** ✅ Implementado e testado

### Camada 2: Frontend Filtering (FASE 3)
- Oculta permissões OPUS da UI para customer_user
- Impede seleção acidental de permissões inválidas
- Melhora UX (usuário não vê permissões que não pode usar)

**Status:** ✅ Implementado e testado

---

## 📊 Permissões por UserType

### OPUS User (opus_user) - 45 permissões
```
✅ Todas as permissões, incluindo:
  - customers_view, customers_create, customers_edit, customers_delete
  - opus_users_view, opus_users_create, opus_users_edit, opus_users_delete
  - roles_manage
  - sites_*, users_*, workorders_*, schedule_*, etc.
```

### Customer User (customer_user) - 36 permissões
```
✅ Permissões permitidas:
  - dashboard_view
  - workorders_*, schedule_*, checklists_*
  - qrcodes_*, floor_plan_*, heatmap_view
  - sites_*, users_*, reports_view
  - audit_logs_view, service_settings_*
  - client_users_*

❌ Permissões BLOQUEADAS:
  - customers_view, customers_create, customers_edit, customers_delete
  - opus_users_view, opus_users_create, opus_users_edit, opus_users_delete
  - roles_manage
```

---

## 🔗 Sincronização Backend-Frontend

### Backend Constants
**Arquivo:** `server/middleware/auth.ts`

```typescript
export const OPUS_ONLY_PERMISSIONS = new Set([
  'customers_view', 'customers_create', 'customers_edit', 'customers_delete',
  'opus_users_view', 'opus_users_create', 'opus_users_edit', 'opus_users_delete',
  'roles_manage'
]);
```

### Frontend Constants
**Arquivo:** `client/src/pages/roles.tsx`

```typescript
const OPUS_ONLY_PERMISSIONS: PermissionKey[] = [
  'customers_view', 'customers_create', 'customers_edit', 'customers_delete',
  'opus_users_view', 'opus_users_create', 'opus_users_edit', 'opus_users_delete',
  'roles_manage',
];
```

**⚠️ IMPORTANTE:** Manter ambas as listas sincronizadas. Se adicionar novas permissões OPUS, atualizar ambos os arquivos.

---

## 🚀 Como Testar Localmente

### 1. Login como OPUS User
```bash
# No navegador:
# Email: admin@opus.com
# Senha: (senha configurada)

# Ir para: Configurações > Roles & Permissões
# Criar novo role
# Verificar: Deve ver TODAS as permissões
```

### 2. Login como Customer User
```bash
# No navegador:
# Email: gestor@cliente.com
# Senha: (senha configurada)

# Ir para: Configurações > Roles & Permissões
# Criar novo role
# Verificar: NÃO deve ver permissões customers_*, opus_users_*, roles_manage
```

### 3. Verificar Console do Navegador
```javascript
// Ao abrir página de roles, verificar:
console.log('[PERMISSIONS] User type:', user?.userType)
console.log('[PERMISSIONS] Total available:', filteredAvailablePermissions.length)

// Deve mostrar:
// opus_user: 45 permissões
// customer_user: 36 permissões
```

---

## 📝 Mudanças nos Arquivos

### Arquivos Modificados
1. `client/src/hooks/useAuth.ts` - Adicionado `userType` ao interface User
2. `client/src/pages/roles.tsx` - Implementado filtro de permissões OPUS

### Nenhuma Mudança em
- Backend routes (já validados na FASE 2)
- Database schema (sem alterações necessárias)
- Outros componentes frontend

---

## 🎯 Próximos Passos (Opcional)

### FASE 4 (Futuro): Migração de Endpoints Restantes
Se houver endpoints críticos ainda usando `role === 'admin'`:
1. Identificar endpoints que ainda usam enum role
2. Mapear para permissões granulares apropriadas
3. Migrar para `requirePermission()`

**Status:** Pendente análise de necessidade

---

## 📊 Status Final do Sistema de Permissões

| Fase | Descrição | Status |
|------|-----------|--------|
| FASE 1 | Foundation (helpers, middleware, constants) | ✅ Completo |
| FASE 2 | Backend validation (roles endpoints) | ✅ Completo |
| FASE 3 | Frontend filtering (UI permissions) | ✅ Completo |
| FASE 4 | Migração de endpoints restantes | 🔜 Futuro |

---

## 🔍 Verificação Rápida

```bash
# Backend validation funcionando?
grep -r "requirePermission" server/routes.ts
# Deve retornar: customers, opus_users, users, sites, zones

# Frontend filtering funcionando?
grep -r "OPUS_ONLY_PERMISSIONS" client/src/pages/roles.tsx
# Deve retornar: constante definida e usada em filter()

# Interface atualizada?
grep -r "userType" client/src/hooks/useAuth.ts
# Deve retornar: userType?: 'opus_user' | 'customer_user'
```

---

## ✅ Conclusão

A FASE 3 completa a implementação do sistema de permissões granulares com **validação em camadas**:

1. **Backend:** Valida permissões nos endpoints (FASES 1 e 2)
2. **Frontend:** Filtra permissões na UI (FASE 3)

**Resultado Final:**
- ✅ customer_user não vê permissões OPUS na UI
- ✅ customer_user não consegue criar roles com permissões OPUS (backend bloqueia)
- ✅ opus_user tem acesso completo a todas as permissões
- ✅ Sistema seguro em produção

**Documentação Relacionada:**
- `FASE_1_FUNDACAO_PERMISSOES.md` - Foundation e helpers
- `FASE_2_VALIDACAO_PERMISSOES.md` - Backend validation
- `replit.md` - Arquitetura geral do sistema

---

**Desenvolvido por:** Replit Agent  
**Data:** 19 de Novembro de 2025  
**Versão:** 1.0
