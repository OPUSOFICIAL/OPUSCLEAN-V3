# OPUS - Database Dump Information

**Data do Dump**: 04 de Novembro de 2025  
**Banco de Dados**: PostgreSQL (Neon Serverless)

---

## 📦 Arquivos Gerados

### 1. **database_full_dump.sql** (476 KB)
- **Dump completo** com schema + dados
- Use este arquivo para restaurar o sistema completo
- Contém: estruturas de tabelas, índices, constraints, enums E todos os dados

### 2. **database_schema.sql** (57 KB)
- **Apenas estrutura** do banco de dados
- Schema completo sem dados
- Útil para criar ambiente de desenvolvimento limpo
- Contém: CREATE TABLE, CREATE INDEX, CREATE TYPE (enums), etc.

### 3. **database_data.sql** (420 KB)
- **Apenas dados** do banco de dados
- INSERT statements para todas as tabelas
- Útil para migrar dados entre ambientes com mesmo schema

---

## 📊 Estatísticas do Banco

- **Total de Tabelas**: 35 tabelas
- **Total de Linhas**: 3.136 linhas (dump completo)
- **Schema Lines**: 1.920 linhas
- **Data Lines**: 1.239 linhas

---

## 🗂️ Lista Completa de Tabelas

### Core Tables (Hierarquia Multi-Tenant)
1. **companies** - Empresas proprietárias
2. **customers** - Clientes que usam o sistema
3. **sites** - Locais físicos dos clientes
4. **zones** - Zonas dentro dos locais

### User Management
5. **users** - Todos os usuários do sistema
6. **user_role_assignments** - Atribuição de roles customizadas
7. **user_site_assignments** - Atribuição de usuários a locais
8. **custom_roles** - Roles personalizadas
9. **role_permissions** - Permissões granulares

### Service Configuration
10. **service_types** - Tipos de serviço (módulo-específico)
11. **service_categories** - Categorias de serviço (módulo-específico)
12. **services** - Serviços disponíveis
13. **service_zones** - Relação serviços × zonas
14. **sla_configs** - Configurações de SLA

### Work Orders
15. **work_orders** - Ordens de serviço (core do sistema)
16. **work_order_comments** - Comentários e fotos nas ordens

### QR Code System
17. **qr_code_points** - QR Codes (execution e public)
18. **public_request_logs** - Log de solicitações públicas

### Cleaning Module (OPUS Clean)
19. **cleaning_activities** - Atividades de limpeza
20. **bathroom_counters** - Contadores de banheiro
21. **bathroom_counter_logs** - Logs de contadores
22. **company_counters** - Contadores da empresa
23. **checklist_templates** - Templates de checklist de limpeza

### Maintenance Module (OPUS Manutenção)
24. **equipment** - Equipamentos gerenciados
25. **equipment_types** - Tipos de equipamento
26. **equipment_tags** - Tags de categorização
27. **maintenance_plans** - Planos de manutenção programada
28. **maintenance_plan_equipments** - Relação planos × equipamentos
29. **maintenance_checklist_templates** - Templates de checklist de manutenção
30. **maintenance_checklist_executions** - Execuções de checklists
31. **maintenance_activities** - Atividades de manutenção

### Analytics & Configuration
32. **dashboard_goals** - Metas do dashboard
33. **site_shifts** - Turnos dos locais
34. **audit_logs** - Logs de auditoria
35. **webhook_configs** - Configurações de webhooks

---

## 🔄 Como Restaurar o Banco de Dados

### Restauração Completa (Schema + Dados)

```bash
# Limpar banco existente (CUIDADO!)
psql $DATABASE_URL -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Restaurar dump completo
psql $DATABASE_URL < database_full_dump.sql
```

### Restauração Apenas Schema

```bash
# Criar estrutura sem dados
psql $DATABASE_URL < database_schema.sql
```

### Restauração Apenas Dados

```bash
# Banco deve ter schema correto
psql $DATABASE_URL < database_data.sql
```

---

## 📋 Enums Definidos no Sistema

O banco utiliza PostgreSQL ENUMs para garantir integridade de dados:

```sql
-- Módulos do sistema
CREATE TYPE module AS ENUM ('clean', 'maintenance');

-- Tipos de usuário
CREATE TYPE user_type AS ENUM ('opus_user', 'customer_user');

-- Roles de usuário
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'operator', 'viewer');

-- Provedores de autenticação
CREATE TYPE auth_provider AS ENUM ('local', 'microsoft');

-- Tipos de ordem de serviço
CREATE TYPE order_type AS ENUM ('programmed', 'internal_corrective', 'public_corrective');

-- Status de ordem
CREATE TYPE order_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- Prioridades
CREATE TYPE priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- Tipos de QR Code
CREATE TYPE qr_type AS ENUM ('execution', 'public');

-- Frequências de manutenção
CREATE TYPE maintenance_frequency AS ENUM (
  'daily', 'weekly', 'shift_based', 'monthly', 
  'quarterly', 'semi_annual', 'annual'
);

-- Turnos
CREATE TYPE shift_type AS ENUM ('morning', 'afternoon', 'night');

-- Tipos de template de checklist
CREATE TYPE template_target_type AS ENUM ('tag_based', 'equipment_specific');
```

---

## 🔒 Segurança

**IMPORTANTE**: Estes dumps contém dados sensíveis, incluindo:
- Hashes de senhas de usuários
- Informações de clientes
- Dados operacionais

**NÃO COMPARTILHE** estes arquivos publicamente ou em repositórios Git não protegidos.

### .gitignore

Certifique-se de que o `.gitignore` inclui:

```
# Database dumps
*.sql
database_*.sql
backup_*.sql
dump_*.sql
```

---

## 📝 Manutenção

### Quando Fazer Novos Dumps

Recomenda-se fazer novos dumps:
- ✅ Antes de grandes mudanças no schema
- ✅ Semanalmente (backup de rotina)
- ✅ Antes de deploy em produção
- ✅ Após migrações importantes de dados

### Comando Rápido para Novo Dump

```bash
# Dump completo com timestamp
pg_dump $DATABASE_URL --no-owner --no-privileges > "database_backup_$(date +%Y%m%d_%H%M%S).sql"
```

---

## 🔍 Inspeção do Dump

### Ver Schema de uma Tabela Específica

```bash
grep -A 20 "CREATE TABLE public.work_orders" database_schema.sql
```

### Ver Dados de uma Tabela

```bash
grep "INSERT INTO public.companies" database_data.sql
```

### Contar Registros por Tabela

```bash
# No dump de dados
grep "INSERT INTO" database_data.sql | sed 's/INSERT INTO //' | sed 's/ VALUES.*//' | sort | uniq -c
```

---

## ✅ Verificação de Integridade

Para verificar se o dump foi criado corretamente:

```bash
# Verificar sintaxe SQL
psql $DATABASE_URL --single-transaction --set ON_ERROR_STOP=on --dry-run < database_full_dump.sql

# Ou simplesmente verificar tamanho
ls -lh database*.sql
```

---

## 🎯 Próximos Passos

1. **Backup Regular**: Configurar backup automático diário
2. **Versionamento**: Manter dumps com timestamp
3. **Storage Seguro**: Armazenar dumps em local seguro (S3, Dropbox criptografado)
4. **Teste de Restauração**: Testar restauração regularmente em ambiente de staging

---

**Gerado automaticamente pelo sistema OPUS**
