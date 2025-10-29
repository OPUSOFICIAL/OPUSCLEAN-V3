# 🔐 TESTE COMPLETO DE PERMISSÕES - OPUS CLEAN

## 📋 Roles do Sistema

### 1. **Admin** 
- Acesso total ao sistema
- Gerencia todos os clientes (companies/customers)
- Gerencia usuários de todos os níveis
- Acesso a todas as funcionalidades

### 2. **Gestor Cliente** (gestor_cliente)
- Gerencia usuários do seu cliente
- Visualiza e gerencia ordens de serviço
- Acessa relatórios
- NÃO pode gerenciar clientes

### 3. **Supervisor Site** (supervisor_site)
- Gerencia ordens de serviço
- Visualiza dados do seu site
- NÃO pode gerenciar usuários
- NÃO acessa relatórios completos

### 4. **Operador** (operador)
- Visualiza APENAS suas próprias ordens de serviço
- Usa app mobile
- Escaneia QR codes
- Finaliza suas OSs
- NÃO acessa dashboard administrativo

### 5. **Auditor** (auditor)
- Visualiza relatórios
- NÃO gerencia usuários
- NÃO gerencia ordens de serviço
- Acesso somente leitura

---

## 🎯 Matriz de Permissões

| Funcionalidade | Admin | Gestor Cliente | Supervisor Site | Operador | Auditor |
|---|:---:|:---:|:---:|:---:|:---:|
| **Gerenciar Clientes** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Ver Todos os Clientes** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Gerenciar Usuários** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Gerenciar Work Orders** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Ver Work Orders (todas)** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Ver Work Orders (próprias)** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Acessar Relatórios** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Acessar Dashboard Admin** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Acessar App Mobile** | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Gerenciar Sites** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Gerenciar Serviços** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Gerenciar QR Codes** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Gerenciar Cronogramas** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Audit Logs** | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## 👥 Usuários de Teste

### Criar usuários para cada role:

```sql
-- 1. ADMIN (já existe)
-- Username: admin
-- Password: opus2025

-- 2. GESTOR CLIENTE
INSERT INTO users (id, company_id, customer_id, username, email, name, password, role, user_type, auth_provider, is_active)
VALUES (
  'user-gestor-test',
  'company-admin-default',
  '43538320-fe1b-427c-9cb9-6b7ab06c1247',
  'gestor.teste',
  'gestor@teste.com',
  'Gestor Teste',
  '$2a$10$...',  -- bcrypt hash de 'teste123'
  'gestor_cliente',
  'client_user',
  'local',
  true
);

-- 3. SUPERVISOR SITE
INSERT INTO users (id, company_id, customer_id, username, email, name, password, role, user_type, auth_provider, is_active, assigned_site_id)
VALUES (
  'user-supervisor-test',
  'company-admin-default',
  '43538320-fe1b-427c-9cb9-6b7ab06c1247',
  'supervisor.teste',
  'supervisor@teste.com',
  'Supervisor Teste',
  '$2a$10$...',  -- bcrypt hash de 'teste123'
  'supervisor_site',
  'client_user',
  'local',
  true,
  'site-faurecia-admin'
);

-- 4. OPERADOR (já existe)
-- Username: TESTE
-- Password: teste123

-- 5. AUDITOR
INSERT INTO users (id, company_id, customer_id, username, email, name, password, role, user_type, auth_provider, is_active)
VALUES (
  'user-auditor-test',
  'company-admin-default',
  '43538320-fe1b-427c-9cb9-6b7ab06c1247',
  'auditor.teste',
  'auditor@teste.com',
  'Auditor Teste',
  '$2a$10$...',  -- bcrypt hash de 'teste123'
  'auditor',
  'client_user',
  'local',
  true
);
```

---

## 🧪 Plano de Testes

### TESTE 1: Admin
**Login:** admin / opus2025
- [ ] Consegue acessar "Clientes" no menu
- [ ] Consegue acessar "Funções" no menu
- [ ] Consegue ver todos os clientes no seletor
- [ ] Consegue criar/editar/excluir usuários
- [ ] Consegue acessar Relatórios
- [ ] Consegue acessar Audit Logs
- [ ] Consegue gerenciar Work Orders

### TESTE 2: Gestor Cliente
**Login:** gestor.teste / teste123
- [ ] NÃO vê opção "Clientes" no menu
- [ ] NÃO vê opção "Funções" no menu
- [ ] Vê apenas o cliente atribuído a ele
- [ ] Consegue gerenciar usuários do seu cliente
- [ ] Consegue acessar Relatórios
- [ ] NÃO consegue acessar Audit Logs
- [ ] Consegue gerenciar Work Orders

### TESTE 3: Supervisor Site
**Login:** supervisor.teste / teste123
- [ ] NÃO vê opção "Clientes" no menu
- [ ] NÃO vê opção "Funções" no menu
- [ ] NÃO consegue gerenciar usuários
- [ ] NÃO consegue acessar Relatórios
- [ ] Consegue gerenciar Work Orders
- [ ] Vê apenas o site atribuído a ele

### TESTE 4: Operador
**Login:** TESTE / teste123
- [ ] É redirecionado automaticamente para app mobile
- [ ] Vê apenas suas próprias Work Orders
- [ ] Consegue escanear QR codes
- [ ] Consegue finalizar suas OSs
- [ ] NÃO consegue acessar dashboard administrativo

### TESTE 5: Auditor
**Login:** auditor.teste / teste123
- [ ] NÃO consegue gerenciar usuários
- [ ] NÃO consegue gerenciar Work Orders
- [ ] Consegue acessar Relatórios (somente leitura)
- [ ] NÃO vê opções de edição/exclusão

---

## ⚙️ Como Executar os Testes

### Passo 1: Criar Usuários de Teste
Execute o script SQL acima no console do banco de dados.

### Passo 2: Testar Cada Role
1. Faça logout
2. Faça login com cada usuário de teste
3. Marque as caixas de verificação acima
4. Tente acessar páginas restritas diretamente via URL

### Passo 3: Testes de Segurança
Tente acessar URLs restritas diretamente:
- `/customers` (somente Admin)
- `/roles` (somente Admin)
- `/users` (Admin e Gestor Cliente)
- `/reports` (Admin, Gestor Cliente e Auditor)

---

## 🚨 Problemas Conhecidos

### Issues Identificados:
1. **ProtectedRoute não cobre todas as rotas** - Algumas páginas podem estar acessíveis sem verificação
2. **Sidebar mostra itens sem verificar permissões** - Menu pode mostrar opções que deveriam estar ocultas
3. **API não valida permissões** - Backend precisa validar antes de retornar dados

---

## ✅ Status da Implementação

### Frontend:
- [x] Hook `useAuth` com funções de permissão
- [x] Componente `ProtectedRoute`
- [ ] Todas as rotas protegidas
- [ ] Menu lateral filtrando por permissões
- [ ] Botões de ação escondidos baseado em permissões

### Backend:
- [ ] Middleware de autenticação
- [ ] Validação de permissões em cada endpoint
- [ ] Filtragem de dados por cliente/site
- [ ] Logs de tentativas de acesso negado

---

## 🔒 Recomendações de Segurança

1. **Implementar middleware de autenticação no backend**
2. **Validar permissões em CADA endpoint da API**
3. **Adicionar logging de tentativas de acesso negado**
4. **Implementar rate limiting por usuário**
5. **Adicionar 2FA para usuários admin**
