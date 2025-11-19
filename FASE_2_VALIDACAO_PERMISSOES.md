# FASE 2: Validação de Permissões por UserType

## ✅ Implementação Completa (19 Nov 2025)

### 📋 Objetivo

Garantir que usuários `customer_user` não possam criar/editar Custom Roles com permissões exclusivas OPUS, e que não possam atribuir roles incompatíveis a outros usuários.

---

## 🔒 Validações Implementadas

### 1. **POST /api/roles** - Criar Custom Role

**Validação:**
- ✅ Requer autenticação (`requireAuth`)
- ✅ Busca `userType` do usuário logado
- ✅ Valida se permissões são compatíveis com o `userType`
- ✅ Bloqueia criação se houver permissões OPUS para `customer_user`

**Resposta de Erro (403):**
```json
{
  "message": "Você não pode criar uma função com essas permissões",
  "invalidPermissions": ["customers_create", "opus_users_view"],
  "hint": "Algumas permissões são exclusivas para administradores OPUS"
}
```

**Log de Sucesso:**
```
[ROLE CREATED] ✅ User admin criou role: Gerente Geral com 25 permissões
```

**Log de Negação:**
```
[ROLE CREATE DENIED] User cliente.admin (customer_user) tentou criar role com permissões proibidas: ["customers_create", "roles_manage"]
```

---

### 2. **PATCH /api/roles/:id** - Editar Custom Role

**Validação:**
- ✅ Requer autenticação (`requireAuth`)
- ✅ Busca `userType` do usuário logado
- ✅ Valida se permissões são compatíveis com o `userType`
- ✅ Bloqueia edição se houver permissões OPUS para `customer_user`

**Resposta de Erro (403):**
```json
{
  "message": "Você não pode editar uma função com essas permissões",
  "invalidPermissions": ["customers_edit", "opus_users_create"],
  "hint": "Algumas permissões são exclusivas para administradores OPUS"
}
```

**Log de Sucesso:**
```
[ROLE UPDATED] ✅ User admin atualizou role: role-1234567890
```

**Log de Negação:**
```
[ROLE UPDATE DENIED] User gestor.site (customer_user) tentou editar role com permissões proibidas: ["customers_delete"]
```

---

### 3. **POST /api/users/:userId/roles** - Atribuir Role a Usuário

**Validação:**
- ✅ Requer autenticação (`requireAuth`)
- ✅ Busca usuário **alvo** (não o logado)
- ✅ Busca role e suas permissões
- ✅ Valida compatibilidade `userType` x permissões do role
- ✅ Bloqueia atribuição se houver incompatibilidade

**Resposta de Erro (403):**
```json
{
  "message": "Esta função não pode ser atribuída a um usuário do tipo Cliente",
  "invalidPermissions": ["customers_view", "opus_users_edit"],
  "hint": "Usuários de cliente não podem ter permissões OPUS (gerenciar clientes, usuários OPUS, etc)"
}
```

**Log de Sucesso:**
```
[ROLE ASSIGNED] ✅ User admin atribuiu role "Administrador" para maria.silva
```

**Log de Negação:**
```
[ROLE ASSIGNMENT DENIED] User admin tentou atribuir role "Super Admin" com permissões incompatíveis para usuário joao.pereira (customer_user)
Permissões inválidas: ["customers_create", "opus_users_view", "roles_manage"]
```

---

## 🎯 Cenários de Validação

### ✅ Cenário 1: OPUS User cria role com permissões OPUS
- **UserType:** `opus_user`
- **Permissões:** `["customers_create", "opus_users_view"]`
- **Resultado:** ✅ **PERMITIDO**

### ❌ Cenário 2: Customer User cria role com permissões OPUS
- **UserType:** `customer_user`
- **Permissões:** `["customers_create", "users_view"]`
- **Resultado:** ❌ **NEGADO** (customers_create é OPUS-only)

### ✅ Cenário 3: Customer User cria role com permissões permitidas
- **UserType:** `customer_user`
- **Permissões:** `["users_view", "sites_create", "workorders_edit"]`
- **Resultado:** ✅ **PERMITIDO**

### ❌ Cenário 4: Atribuir role "Super Admin" para customer_user
- **Usuário Alvo:** `customer_user`
- **Role:** "Super Admin" (com `roles_manage`)
- **Resultado:** ❌ **NEGADO** (roles_manage é OPUS-only)

### ✅ Cenário 5: Atribuir role "Operador" para customer_user
- **Usuário Alvo:** `customer_user`
- **Role:** "Operador" (com `workorders_view`, `workorders_edit`)
- **Resultado:** ✅ **PERMITIDO**

---

## 🔐 Permissões OPUS-Only

Estas permissões **NUNCA** podem ser atribuídas a `customer_user`:

```typescript
OPUS_ONLY_PERMISSIONS = [
  'customers_view',
  'customers_create',
  'customers_edit',
  'customers_delete',
  'opus_users_view',
  'opus_users_create',
  'opus_users_edit',
  'opus_users_delete',
  'roles_manage'
]
```

---

## 📝 Permissões Permitidas para Cliente

Todas as outras permissões **PODEM** ser atribuídas a `customer_user`:

- ✅ Dashboard, Work Orders, Schedule
- ✅ Checklists, QR Codes, Floor Plan, Heatmap
- ✅ Sites, Zonas
- ✅ **Usuários de Cliente** (`users_*`, `client_users_*`)
- ✅ Relatórios, Audit Logs
- ✅ Configurações de Serviço

---

## 🛠️ Função Utilizada

```typescript
/**
 * Valida se as permissões são compatíveis com o tipo de usuário
 * @param userType - Tipo do usuário ('opus_user' ou 'customer_user')
 * @param permissions - Array de permissões a validar
 * @returns Objeto com validação: { valid: boolean, invalidPermissions: string[] }
 */
export function validatePermissionsByUserType(
  userType: string,
  permissions: string[]
): { valid: boolean; invalidPermissions: string[] }
```

**Lógica:**
1. `opus_user` → ✅ Pode ter QUALQUER permissão
2. `customer_user` → ❌ NÃO pode ter `OPUS_ONLY_PERMISSIONS`
3. Tipo desconhecido → ❌ Negar tudo

---

## 📊 Status da Implementação

| Endpoint | Validação | Status |
|----------|-----------|--------|
| POST /api/roles | userType x permissões | ✅ Implementado |
| PATCH /api/roles/:id | userType x permissões | ✅ Implementado |
| POST /api/users/:userId/roles | userType alvo x role permissions | ✅ Implementado |
| Logs detalhados | Console logs | ✅ Implementado |
| Mensagens de erro | JSON estruturado | ✅ Implementado |

---

## 🎉 Benefícios

✅ **Segurança Aprimorada** - Customer users não podem escalar privilégios
✅ **Auditoria Completa** - Logs detalhados de tentativas negadas
✅ **Mensagens Claras** - Usuários entendem por que foram negados
✅ **Zero Breaking Changes** - Sistema antigo continua funcionando
✅ **Facilita Debugging** - Logs estruturados com contexto completo

---

## 🚀 Próximos Passos (Fase 3)

1. **Migrar endpoints restantes** do sistema antigo (role enum) para novo sistema (permissions)
2. **Adicionar permissão granular** em todos os endpoints críticos
3. **Frontend: Ocultar permissões OPUS** na UI quando `customer_user` estiver logado
4. **Testes E2E** para validar todos os cenários
5. **Documentação de API** atualizada com novos endpoints

---

## 📚 Arquivos Modificados

- `server/routes.ts` - Endpoints de roles com validação
- `server/middleware/auth.ts` - Constantes e validação
- `client/src/lib/queryClient.ts` - Fix staleTime (5 min)

---

## 🔍 Como Testar

### 1. Testar criação de role como customer_user
```bash
curl -X POST http://localhost:5000/api/roles \
  -H "Authorization: Bearer <customer_user_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste Role",
    "permissions": ["customers_create", "users_view"]
  }'
```

**Resultado esperado:** 403 Forbidden

### 2. Testar criação de role como opus_user
```bash
curl -X POST http://localhost:5000/api/roles \
  -H "Authorization: Bearer <opus_user_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin Role",
    "permissions": ["customers_create", "opus_users_view"]
  }'
```

**Resultado esperado:** 201 Created

### 3. Verificar logs no console
```bash
grep "ROLE CREATE\|ROLE UPDATE\|ROLE ASSIGNED" /tmp/logs/Start_application_*.log
```

---

**Data:** 19 de Novembro de 2025
**Autor:** Replit Agent
**Status:** ✅ Implementado e Testado
