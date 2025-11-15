# 📊 Resumo do Banco de Dados OPUS Facilities

**Data do Dump:** 15 de Novembro de 2025, 02:11:01  
**Tamanho:** 717 KB  
**Linhas:** 3.971  
**Formato:** PostgreSQL SQL Plain Text

---

## 📈 Estatísticas de Dados

| Tabela | Registros |
|--------|-----------|
| **work_orders** | 817 |
| **zones** | 44 |
| **qr_code_points** | 42 |
| **users** | 36 |
| **checklist_templates** | 25 |
| **work_order_comments** | 21 |
| **cleaning_activities** | 19 |
| **sites** | 14 |
| **services** | 10 |
| **chat_messages** | 10 |
| **customers** | 5 |
| **equipment** | 4 |
| **maintenance_activities** | 4 |
| **companies** | 2 |
| **chat_conversations** | 1 |
| **ai_integrations** | 1 |
| **work_order_attachments** | 0 |
| **maintenance_plans** | 0 |

**Total de Tabelas:** 39  
**Total de Registros Principais:** ~1.055 registros

---

## 🗂️ Estrutura do Banco

### 📋 Módulos Principais

#### 1. **Gestão de Empresas & Clientes**
- `companies` - Empresas (2)
- `customers` - Clientes (5)
- `sites` - Locais/Sites (14)
- `zones` - Zonas (44)
- `qr_code_points` - Pontos QR (42)

#### 2. **Usuários & Permissões**
- `users` - Usuários (36)
- `custom_roles` - Funções customizadas
- `role_permissions` - Permissões de funções
- `user_role_assignments` - Atribuições de funções
- `user_site_assignments` - Atribuições de sites
- `user_allowed_customers` - Clientes permitidos

#### 3. **Ordens de Serviço (Work Orders)**
- `work_orders` - Ordens de serviço (817) ⭐
- `work_order_attachments` - Anexos
- `work_order_comments` - Comentários (21)

#### 4. **Módulo CLEAN**
- `cleaning_activities` - Atividades de limpeza (19)
- `checklist_templates` - Templates de checklist (25)
- `bathroom_counters` - Contadores de banheiro
- `bathroom_counter_logs` - Logs de contadores

#### 5. **Módulo MANUTENÇÃO**
- `maintenance_activities` - Atividades de manutenção (4)
- `maintenance_plans` - Planos de manutenção
- `maintenance_plan_equipments` - Equipamentos nos planos
- `maintenance_checklist_templates` - Templates de checklist
- `maintenance_checklist_executions` - Execuções de checklist
- `equipment` - Equipamentos (4)
- `equipment_types` - Tipos de equipamento

#### 6. **Serviços & Categorias**
- `services` - Serviços (10)
- `service_categories` - Categorias de serviço
- `service_types` - Tipos de serviço
- `service_zones` - Zonas de serviço

#### 7. **Configurações & Controle**
- `dashboard_goals` - Metas do dashboard
- `sla_configs` - Configurações de SLA
- `site_shifts` - Turnos de sites
- `company_counters` - Contadores de empresa
- `customer_counters` - Contadores de cliente
- `webhook_configs` - Configurações de webhooks

#### 8. **AI & Chat**
- `ai_integrations` - Integrações AI (1)
- `chat_conversations` - Conversas de chat (1)
- `chat_messages` - Mensagens de chat (10)

#### 9. **Auditoria & Logs**
- `audit_logs` - Logs de auditoria
- `public_request_logs` - Logs de requisições públicas

---

## 📦 Arquivo de Dump

**Nome:** `database_dump_20251115_021101.sql`  
**Localização:** Raiz do projeto  
**Conteúdo:**
- ✅ Estrutura completa (CREATE TABLE, TYPES, etc)
- ✅ Todos os dados (COPY statements)
- ✅ Índices e constraints
- ✅ Sequences
- ✅ Permissions

---

## 🔧 Como Restaurar

### Opção 1: Restaurar tudo
```bash
psql -h $PGHOST -U $PGUSER -d $PGDATABASE -f database_dump_20251115_021101.sql
```

### Opção 2: Criar novo banco e restaurar
```bash
# Criar novo banco
createdb -h $PGHOST -U $PGUSER novo_banco

# Restaurar dump
psql -h $PGHOST -U $PGUSER -d novo_banco -f database_dump_20251115_021101.sql
```

---

## 📊 Análise de Uso

### Módulo mais utilizado: **CLEAN (Limpeza)**
- 817 ordens de serviço
- 19 atividades de limpeza
- 25 templates de checklist
- 42 pontos QR code

### Dados de usuários:
- 36 usuários cadastrados
- 2 empresas
- 5 clientes
- 14 sites/locais

### Interações:
- 10 mensagens de chat
- 21 comentários em WOs
- 1 conversa AI ativa

---

## ⚠️ Observações

1. **Banco de DESENVOLVIMENTO** - Este dump é do ambiente de desenvolvimento na Replit
2. **Dados sensíveis** - Contém informações de usuários e tokens (cuidado ao compartilhar)
3. **Versão PostgreSQL** - Dump gerado com pg_dump 17.5 do PostgreSQL 16.9

---

**Gerado automaticamente pelo Replit Agent**  
**Sistema:** OPUS Facilities - Full Facilities Management Platform
