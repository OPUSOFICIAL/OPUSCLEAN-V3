# OPUS - Arquitetura do Sistema

**Data da Análise:** 3 de Novembro de 2025  
**Ambiente:** Desenvolvimento (Replit)  
**Banco de Dados:** PostgreSQL (Neon)

## 📋 Visão Geral

O sistema OPUS é uma plataforma inteligente para gestão completa de facilities e infraestrutura corporativa, oferecendo dois módulos principais:

1. **OPUS Clean** - Gestão de limpeza e higienização
2. **OPUS Manutenção** - Gestão de manutenção preventiva e corretiva de equipamentos

## 🏗️ Arquitetura de Dados

### Isolamento por Módulo

O sistema utiliza um campo `module` (enum: 'clean' | 'maintenance') em **14 tabelas principais** para garantir isolamento completo dos dados entre os módulos:

#### Tabelas com Isolamento por Módulo

1. **sites** - Locais/Instalações físicas
2. **zones** - Zonas/Áreas dentro dos locais
3. **service_types** - Tipos de serviço
4. **service_categories** - Categorias de serviço
5. **services** - Serviços disponíveis
6. **cleaning_activities** - Atividades de limpeza programadas
7. **checklist_templates** - Templates de checklist
8. **work_orders** - Ordens de serviço
9. **dashboard_goals** - Metas do dashboard
10. **qr_code_points** - Pontos de QR code
11. **sla_configs** - Configurações de SLA
12. **equipment** - Equipamentos (exclusivo para manutenção)
13. **maintenance_checklist_templates** - Templates de checklist de manutenção
14. **maintenance_plans** - Planos de manutenção

### Tabelas Compartilhadas (Sem Campo `module`)

Estas tabelas são compartilhadas entre ambos os módulos:

- **companies** - Empresas (Grupo OPUS)
- **customers** - Clientes/Contratantes
- **users** - Usuários do sistema
- **custom_roles** - Perfis personalizados
- **role_permissions** - Permissões por perfil
- **audit_logs** - Logs de auditoria
- **bathroom_counters** - Contadores de banheiro
- **public_request_logs** - Logs de solicitações públicas
- **webhook_configs** - Configurações de webhooks

## 📊 Estado Atual dos Dados (Nov 2025)

### OPUS Clean (module='clean')
- ✅ **Totalmente Operacional**
- 697 ordens de serviço
- 28 zonas
- 7 locais (sites)
- 26 pontos QR
- 20+ atividades de limpeza
- 4 templates de checklist
- 3 tipos de serviço
- 2 metas de dashboard

### OPUS Manutenção (module='maintenance')
- ⚠️ **Preparado, mas sem dados**
- 0 equipamentos
- 0 planos de manutenção
- 0 templates de checklist de manutenção
- 0 ordens de serviço de manutenção

## 🔄 Hierarquia de Dados

```
Companies (2)
  └── Customers (4)
       ├── Sites (7) [module: 'clean' ou 'maintenance']
       │    └── Zones (28) [module: 'clean' ou 'maintenance']
       │         ├── Equipment (0) [exclusivo: 'maintenance']
       │         ├── QR Code Points (26)
       │         └── Work Orders (697) [module: 'clean' ou 'maintenance']
       │              ├── Cleaning Activities (20+) [module: 'clean']
       │              └── Maintenance Plans (0) [module: 'maintenance']
       └── Service Types (3) [module: 'clean' ou 'maintenance']
            └── Service Categories (2)
                 └── Services (3)
```

## 🎯 Estratégia de Separação de Módulos

### Quando Usar module='clean'

- Gestão de limpeza e higienização
- Atividades de limpeza programadas
- Checklists de limpeza
- QR codes para execução de limpeza
- Banheiros e vestiários
- Áreas de refeitório e administrativas

### Quando Usar module='maintenance'

- Gestão de equipamentos
- Manutenção preventiva
- Manutenção corretiva
- Planos de manutenção
- Checklists técnicos de equipamentos
- Cabines de pintura, máquinas, sistemas

## 🔧 Cenários de Uso

### Cenário 1: Cliente Exclusivo de Limpeza
**Exemplo:** FAURECIA (atual)
- Todos os sites com `module='clean'`
- Todas as zonas com `module='clean'`
- Apenas services, activities e work_orders de limpeza

### Cenário 2: Cliente Exclusivo de Manutenção
**Exemplo:** Fábrica industrial com apenas manutenção
- Sites com `module='maintenance'`
- Zonas com `module='maintenance'`
- Equipment cadastrados
- Maintenance plans ativos
- Work orders de manutenção

### Cenário 3: Cliente com Ambos os Módulos
**Exemplo:** TECNOFIBRA (potencial)
- **OPUS Clean:** Banheiros, refeitórios, áreas administrativas
  - Sites específicos ou zones marcadas como 'clean'
- **OPUS Manutenção:** Cabines de pintura, equipamentos industriais
  - Mesmos sites, mas zones marcadas como 'maintenance'
  - Equipment cadastrados nestas zones

## 📋 Checklist para Implementação de Novo Módulo

### Para Adicionar OPUS Clean a um Cliente

1. ✅ Criar/verificar sites com `module='clean'`
2. ✅ Criar zones com `module='clean'`
3. ✅ Criar service_types com `module='clean'`
4. ✅ Criar services com `module='clean'`
5. ✅ Criar cleaning_activities
6. ✅ Criar checklist_templates com `module='clean'`
7. ✅ Criar qr_code_points
8. ✅ Configurar dashboard_goals com `module='clean'`

### Para Adicionar OPUS Manutenção a um Cliente

1. ⏳ Criar/verificar sites com `module='maintenance'`
2. ⏳ Criar zones com `module='maintenance'`
3. ⏳ Cadastrar equipment
4. ⏳ Criar service_types com `module='maintenance'`
5. ⏳ Criar services com `module='maintenance'`
6. ⏳ Criar maintenance_plans
7. ⏳ Criar maintenance_checklist_templates
8. ⏳ Configurar sla_configs
9. ⏳ Configurar dashboard_goals com `module='maintenance'`

## 🎨 Interface e Navegação

### Seleção de Módulo

A interface deve permitir:
- Toggle entre módulos (Clean / Manutenção)
- Dashboard separado por módulo
- Listagens filtradas por módulo
- Criação de recursos com módulo pré-selecionado

### Permissões por Módulo

As permissões do sistema já suportam ambos os módulos:
- `workorders_view` - pode ser filtrada por módulo
- `sites_view` - pode ser filtrada por módulo
- `dashboard_view` - mostra dados do módulo ativo

## 🚀 Próximos Passos Recomendados

1. **Definir clientes que usarão cada módulo**
   - FAURECIA: apenas Clean
   - TECNOFIBRA: Clean + Manutenção (cabines de pintura)

2. **Criar estrutura de OPUS Manutenção**
   - Cadastrar equipamentos
   - Configurar planos de manutenção
   - Criar templates de checklist técnico

3. **Interface de alternância de módulo**
   - Adicionar toggle no header
   - Filtrar dados automaticamente
   - Atualizar dashboard conforme módulo selecionado

4. **Migração de dados (se necessário)**
   - Identificar zones que devem ser 'maintenance'
   - Converter cabines de pintura para equipamentos
   - Manter histórico de limpeza em 'clean'

## 📝 Notas Importantes

- ⚠️ **Não misturar módulos na mesma work order**
- ✅ **OK:** Mesmo site com zones de módulos diferentes
- ✅ **OK:** Mesmo cliente com ambos os módulos
- ❌ **EVITAR:** Work order 'clean' referenciando equipment
- ❌ **EVITAR:** Cleaning activity em zone 'maintenance'

## 🔍 Consultas Úteis

### Ver distribuição de dados por módulo
```sql
-- Sites por módulo
SELECT module, COUNT(*) FROM sites GROUP BY module;

-- Zones por módulo
SELECT module, COUNT(*) FROM zones GROUP BY module;

-- Work Orders por módulo
SELECT module, status, COUNT(*) 
FROM work_orders 
GROUP BY module, status;
```

### Verificar integridade
```sql
-- Work orders com módulo incompatível com zone
SELECT wo.id, wo.module, z.module as zone_module
FROM work_orders wo
JOIN zones z ON wo.zone_id = z.id
WHERE wo.module != z.module;
```

---

**Última atualização:** 3 de Novembro de 2025  
**Responsável:** Sistema OPUS - Replit Agent
