# 🗄️ Backup do Banco de Dados OPUS

**Data do Backup**: 06/11/2025  
**Hora**: 18:43 UTC  
**Tamanho**: 144KB

---

## 📋 Informações do Backup

### Arquivo de Backup

- **Nome**: `database_dump_20251106_184315.sql`
- **Formato**: SQL completo (pg_dump)
- **Tipo**: Dump completo com schema + dados

### Banco de Dados

- **Sistema**: PostgreSQL (Neon)
- **Região**: US West 2 (AWS)
- **Endpoint**: ep-rapid-term-afghuiqb.c-2.us-west-2.aws.neon.tech
- **Database**: neondb

---

## 📊 Estrutura do Banco

### Tabelas Principais

#### Multi-Tenancy & Hierarquia
- `companies` - Empresas
- `customers` - Clientes
- `sites` - Locais
- `zones` - Zonas

#### Usuários & Autenticação
- `users` - Usuários do sistema
- `role_assignments` - Atribuições de papéis
- `sessions` - Sessões de usuários

#### Módulo Clean
- `services` - Serviços de limpeza
- `service_types` - Tipos de serviço
- `cleaning_activities` - Atividades de limpeza agendadas
- `checklist_templates` - Templates de checklist
- `qr_points` - Pontos QR para execução e solicitação pública

#### Módulo Manutenção
- `equipment` - Equipamentos
- `maintenance_activities` - Planos de manutenção
- `maintenance_checklist_templates` - Templates de checklist de manutenção

#### Ordens de Serviço
- `work_orders` - Ordens de trabalho
- `work_order_comments` - Comentários nas work orders
- `sla_configs` - Configurações de SLA

#### Analytics & Metas
- `dashboard_goals` - Metas do dashboard

---

## 🔄 Como Restaurar o Backup

### Restaurar em Ambiente Local

```bash
# Restaurar completamente
psql $DATABASE_URL < database_dump_20251106_184315.sql

# Restaurar apenas schema (sem dados)
psql $DATABASE_URL < database_dump_20251106_184315.sql --schema-only

# Restaurar apenas dados (sem schema)
psql $DATABASE_URL < database_dump_20251106_184315.sql --data-only
```

### Restaurar no Neon (Replit)

```bash
# Via Replit Shell
psql $DATABASE_URL < database_dump_20251106_184315.sql
```

### Restaurar Tabelas Específicas

```bash
# Extrair apenas uma tabela
pg_restore -t users database_dump_20251106_184315.sql | psql $DATABASE_URL
```

---

## ⚠️ Avisos Importantes

### Antes de Restaurar

1. **Backup do estado atual**: Sempre faça backup do banco atual antes de restaurar
2. **Verificar compatibilidade**: Certifique-se de que a versão do PostgreSQL é compatível
3. **Permissões**: Garanta que tem permissões de superuser para restaurar

### Após Restaurar

1. **Recrie índices**: Alguns índices podem precisar ser recriados
2. **Atualize sequences**: Certifique-se de que as sequences estão corretas
3. **Teste a aplicação**: Valide que tudo funciona corretamente

---

## 📈 Estatísticas do Backup

### Volume de Dados (Estimado)

- **Companies**: ~1 registro
- **Customers**: ~5 registros
- **Sites**: ~10 registros
- **Zones**: ~15 registros
- **Users**: ~5 registros
- **Work Orders**: ~200+ registros
- **Checklist Templates**: 0 (módulo clean limpo para testes)
- **Services**: ~5 registros

### Estado Atual

- ✅ Checklists do módulo Clean foram **removidos** para permitir novos testes
- ✅ Work Orders existentes tiveram vínculo de checklist removido
- ✅ Atividades de limpeza sem checklist vinculado
- ✅ Banco pronto para criar novos checklists com vínculos corretos

---

## 🔧 Manutenção Regular

### Frequência Recomendada de Backup

- **Desenvolvimento**: Diariamente
- **Produção**: A cada 6 horas + antes de deploys

### Armazenamento

- Manter últimos 7 backups diários
- Manter backup semanal do último mês
- Backup mensal por 1 ano

---

## 📝 Notas da Versão Atual

**Alterações Recentes** (06/11/2025):

1. ✅ Removidos todos os checklist templates do módulo Clean
2. ✅ Removido vínculo de checklist de 31 work orders
3. ✅ Removido vínculo de checklist de 2 atividades de limpeza
4. ✅ Backend ajustado para converter `zoneIds` (array) para `zoneId` (singular)
5. ✅ Frontend configurado para filtrar checklists por serviço + local + zona

**Objetivo**: Preparar ambiente para testar fluxo completo de criação de checklist com vínculos corretos.

---

## 🔗 Arquivos Relacionados

- **Fluxo do Sistema**: `SYSTEM_FLOW.md`
- **Documentação Técnica**: `DOCUMENTATION.md`
- **Resumo do Projeto**: `replit.md`

---

**Fim do Documento de Backup**
