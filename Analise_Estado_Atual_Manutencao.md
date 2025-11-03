# Análise do Estado Atual - OPUS Manutenção

**Data:** 3 de Novembro de 2025  
**Autor:** Sistema OPUS - Análise Técnica  
**Objetivo:** Avaliar estado atual e definir estratégia de implementação do módulo de manutenção

---

## 📊 Resumo Executivo

O sistema OPUS foi desenvolvido inicialmente focado no módulo **OPUS Clean** (limpeza), porém a arquitetura foi planejada desde o início para suportar **OPUS Manutenção**. Atualmente temos:

- ✅ **Infraestrutura**: 100% preparada para ambos os módulos
- ✅ **Dados Clean**: 697 registros operacionais
- ⚠️ **Dados Manutenção**: 0% populado (estrutura pronta)
- 🎯 **Próximo passo**: Popular dados de manutenção e ativar o módulo

---

## 🔍 Análise Detalhada dos Dados Atuais

### 1. Dados OPUS Clean (Operacional)

#### Sites e Zonas
```
FAURECIA (cliente ativo)
├── 6 sites ativos (Vestiários, Ambulatório, Refeitório, Portaria, Administrativo, Produção)
└── 24 zones (banheiros e áreas administrativas) - TODOS module='clean'

TECNOFIBRA (cliente ativo)
├── 1 site ativo (Fábrica Central)
└── 4 zones (cabines de pintura) - TODOS module='clean'
    ├── Cabine Pintura SMC
    ├── Cabine Pintura RTM
    ├── Cabine Pintura Estática
    └── Cabine Estática SMC Fante
```

#### Atividades e Serviços
- **3 Service Types**: Emergência, Preventivo, Preventiva (todos 'clean')
- **2 Service Categories**: Limpeza Técnica, Limpeza (todos 'clean')
- **3 Services**: Reposição, Higienização, Limpeza Rotina (todos 'clean')
- **20+ Cleaning Activities**: Diárias, semanais, mensais, anuais (todos 'clean')

#### Ordens de Serviço
- **Total**: 697 work orders
- **Status**: 685 abertas (98.3%), 12 concluídas (1.7%)
- **Todos**: module='clean'

### 2. Potencial para OPUS Manutenção

#### Candidatos Óbvios - TECNOFIBRA

As **cabines de pintura** da TECNOFIBRA são claramente equipamentos industriais que deveriam estar no módulo de manutenção:

**Cabines Atuais (classificadas como 'clean'):**
1. **Cabine Pintura RTM**
   - Atividades semanais e mensais de limpeza técnica
   - 480 minutos de higienização
   - Troca de filtros, limpeza de transportador
   
2. **Cabine Pintura SMC**
   - Atividades semanais de manutenção
   - Limpeza técnica especializada
   
3. **Cabine Pintura Estática**
   - 12m² de área
   - Limpeza técnica programada
   
4. **Cabine Estática SMC Fante**
   - 20m² de área
   - Manutenção preventiva

**Análise:** Estas não são simples "zonas de limpeza", são **equipamentos industriais** que necessitam:
- ✅ Cadastro como Equipment
- ✅ Manutenção preventiva programada
- ✅ Histórico de manutenções
- ✅ Especificações técnicas
- ✅ Planos de manutenção
- ✅ Checklists técnicos especializados

---

## 🎯 Estratégia de Separação Recomendada

### Cenário 1: FAURECIA (Apenas Clean)
**Status:** ✅ Correto como está

```
FAURECIA
├── OPUS Clean (Ativo)
│   ├── Sites: Vestiários, Ambulatório, Refeitório, etc.
│   ├── Zones: Banheiros, vestiários (module='clean')
│   └── Services: Limpeza de rotina, reposição
└── OPUS Manutenção (Não aplicável)
    └── Sem equipamentos industriais neste cliente
```

**Ação:** Nenhuma alteração necessária

### Cenário 2: TECNOFIBRA (Clean + Manutenção)
**Status:** ⚠️ Requer reestruturação

#### Estado Atual (Incorreto):
```
TECNOFIBRA
└── OPUS Clean
    ├── Site: Fábrica Central (module='clean')
    └── Zones: 4 cabines de pintura (module='clean') ❌
        └── Cleaning Activities: Limpeza técnica
```

#### Estado Proposto (Correto):
```
TECNOFIBRA
├── OPUS Clean
│   ├── Site: Fábrica Central - Áreas Gerais (module='clean')
│   └── Zones: Banheiros, refeitório, administrativo (module='clean')
│       └── Cleaning Activities: Limpeza convencional
│
└── OPUS Manutenção ⭐ NOVO
    ├── Site: Fábrica Central - Produção (module='maintenance')
    └── Equipment: 4 cabines de pintura
        ├── Cabine Pintura RTM (equipment_type='cabine_pintura')
        ├── Cabine Pintura SMC (equipment_type='cabine_pintura')
        ├── Cabine Pintura Estática (equipment_type='cabine_pintura')
        └── Cabine Estática SMC Fante (equipment_type='cabine_pintura')
```

---

## 📋 Plano de Migração - TECNOFIBRA

### Fase 1: Preparação (Sem impacto nos dados atuais)

#### 1.1 Criar Site de Manutenção
```sql
-- Novo site específico para manutenção
INSERT INTO sites (id, company_id, customer_id, module, name, address, is_active)
VALUES (
  'site-tecnofibra-producao',
  'company-admin-default',
  '7913bae1-bdca-4fb4-9465-99a4754995b2',
  'maintenance',
  'Fábrica Central - Área de Produção',
  'Joinville - Setor Industrial',
  true
);
```

#### 1.2 Cadastrar Equipamentos
```sql
-- Equipamento 1: Cabine RTM
INSERT INTO equipment (
  id, company_id, customer_id, site_id, zone_id,
  name, internal_code, equipment_type,
  manufacturer, model, installation_date,
  module, is_active
) VALUES (
  'equip-cabine-rtm',
  'company-admin-default',
  '7913bae1-bdca-4fb4-9465-99a4754995b2',
  'site-tecnofibra-producao',
  '20864c38-1234-46e6-8581-46e3c55a9b87', -- zona atual
  'Cabine de Pintura Primer RTM',
  'RTM-001',
  'cabine_pintura',
  'Fabricante Industrial',
  'Modelo RTM-2024',
  '2024-01-15',
  'maintenance',
  true
);

-- Repetir para as outras 3 cabines...
```

#### 1.3 Criar Service Types de Manutenção
```sql
INSERT INTO service_types (id, name, code, customer_id, module)
VALUES 
  ('st-preventiva-tecno', 'Manutenção Preventiva', 'MANU_PREV', '7913bae1-bdca-4fb4-9465-99a4754995b2', 'maintenance'),
  ('st-corretiva-tecno', 'Manutenção Corretiva', 'MANU_CORR', '7913bae1-bdca-4fb4-9465-99a4754995b2', 'maintenance');
```

#### 1.4 Criar Planos de Manutenção
```sql
-- Plano de manutenção semanal para RTM
INSERT INTO maintenance_plans (
  id, company_id, customer_id, equipment_id,
  name, description, frequency, frequency_config,
  module, is_active
) VALUES (
  'plan-rtm-semanal',
  'company-admin-default',
  '7913bae1-bdca-4fb4-9465-99a4754995b2',
  'equip-cabine-rtm',
  'Manutenção Semanal Cabine RTM',
  'Plastificação, limpeza interna, troca de filtros',
  'semanal',
  '{"weekDays": ["sexta"], "timesPerDay": 1}',
  'maintenance',
  true
);
```

### Fase 2: Migração de Dados (Cuidado!)

#### 2.1 Converter Cleaning Activities em Maintenance Plans
```sql
-- Desativar cleaning activities das cabines
UPDATE cleaning_activities
SET is_active = false, 
    updated_at = NOW()
WHERE zone_id IN (
  '20864c38-1234-46e6-8581-46e3c55a9b87', -- RTM
  'a415c33b-c0ac-4a79-87c3-38a7c36d0cfa', -- SMC
  '2d9936f6-6093-4885-b0bf-cf655f559dbc', -- Estática
  '2ba21003-b82d-4950-8a6b-f504740960ea'  -- SMC Fante
);

-- Criar maintenance plans baseadas nas activities existentes
-- (usando os dados das cleaning_activities como referência)
```

#### 2.2 Atualizar Work Orders Antigas
```sql
-- Manter histórico: não alterar work orders concluídas
-- Apenas marcar para referência
UPDATE work_orders
SET observations = 'MIGRADO: Esta OS foi criada antes da implementação do módulo de manutenção'
WHERE zone_id IN (...cabines...)
  AND status = 'concluida';

-- Work orders abertas: converter para manutenção
UPDATE work_orders
SET module = 'maintenance',
    equipment_id = (SELECT equipment_id FROM equipment WHERE zone_id = work_orders.zone_id LIMIT 1)
WHERE zone_id IN (...cabines...)
  AND status IN ('aberta', 'em_execucao');
```

### Fase 3: Ativação

#### 3.1 Atualizar Zones
```sql
-- Converter zones das cabines para manutenção
UPDATE zones
SET module = 'maintenance',
    category = 'equipamento_industrial',
    updated_at = NOW()
WHERE id IN (
  '20864c38-1234-46e6-8581-46e3c55a9b87',
  'a415c33b-c0ac-4a79-87c3-38a7c36d0cfa',
  '2d9936f6-6093-4885-b0bf-cf655f559dbc',
  '2ba21003-b82d-4950-8a6b-f504740960ea'
);
```

#### 3.2 Criar Dashboard Goals
```sql
INSERT INTO dashboard_goals (
  id, company_id, module, goal_type, goal_value, current_period, is_active
) VALUES (
  gen_random_uuid()::text,
  'company-admin-default',
  'maintenance',
  'disponibilidade_equipamentos',
  95.00,
  '2025-11',
  true
);
```

---

## ⚠️ Considerações Importantes

### Impacto da Migração

1. **Histórico Preservado**
   - ✅ Work orders antigas permanecem como 'clean'
   - ✅ Cleaning activities antigas são desativadas, não deletadas
   - ✅ Histórico completo mantido para auditoria

2. **Integridade Referencial**
   - ⚠️ Zone pode ter work_orders de ambos módulos (histórico)
   - ✅ Novos registros sempre no módulo correto
   - ✅ Equipment sempre linkado a zone 'maintenance'

3. **Interface do Usuário**
   - 🔄 Necessário toggle entre módulos
   - 🔄 Dashboard deve filtrar por módulo
   - 🔄 Listagens devem respeitar módulo ativo

### Alternativa: Manter Dupla Natureza

**Opção B:** Não migrar, manter cabines com ambos módulos

```
Cabine RTM
├── Zone (module='clean') - para limpeza diária
└── Equipment (module='maintenance') - para manutenção técnica

Work Orders
├── Limpeza de rotina → zone (clean)
└── Manutenção preventiva → equipment (maintenance)
```

**Vantagens:**
- ✅ Não quebra dados existentes
- ✅ Permite ambos tipos de serviço
- ✅ Migração gradual

**Desvantagens:**
- ❌ Duplicação conceitual
- ❌ Complexidade adicional
- ❌ Pode confundir usuários

---

## 🎯 Recomendação Final

### Para TECNOFIBRA:

**Implementar Opção B (Dupla Natureza) com as seguintes diretrizes:**

1. **Manter zones atuais como 'clean'**
   - Para limpeza de rotina das cabines
   - Work orders simples de higienização

2. **Criar equipment 'maintenance'**
   - Para manutenção técnica especializada
   - Planos de manutenção preventiva
   - Gestão de peças e componentes

3. **UI com seletor de contexto**
   - "Ver como: Limpeza | Manutenção"
   - Filtra dados automaticamente
   - Dashboard adaptativo

4. **Migração gradual**
   - Fase 1: Adicionar equipment (sem remover zones)
   - Fase 2: Criar planos de manutenção
   - Fase 3: Treinar usuários
   - Fase 4: Avaliar necessidade de conversão completa

---

## 📊 Estrutura de Dados Recomendada

### Equipment Table - Campos Essenciais
```typescript
{
  id: string,
  companyId: string,
  customerId: string,
  siteId: string,
  zoneId: string,              // Localização física
  name: string,                 // "Cabine Pintura RTM"
  internalCode: string,         // "RTM-001"
  equipmentType: string,        // "cabine_pintura"
  manufacturer: string,         // "Industrial Paint Systems"
  model: string,                // "IPS-RTM-2024"
  serialNumber: string,         // "SN123456789"
  purchaseDate: Date,           // Data de aquisição
  warrantyExpiry: Date,         // Fim da garantia
  installationDate: Date,       // Instalação
  technicalSpecs: JSON,         // Especificações técnicas
  maintenanceNotes: string,     // Observações
  qrCodeUrl: string,            // QR code do equipamento
  module: 'maintenance',
  isActive: boolean
}
```

### Maintenance Plan - Exemplo
```typescript
{
  id: string,
  companyId: string,
  customerId: string,
  equipmentId: string,
  name: "Manutenção Preventiva Semanal - RTM",
  description: "Plastificação, limpeza técnica, troca de filtros",
  frequency: "semanal",
  frequencyConfig: {
    weekDays: ["sexta"],
    startTime: "18:00",
    duration: 480  // 8 horas
  },
  checklistTemplateId: string,
  estimatedDurationMinutes: 480,
  module: 'maintenance',
  isActive: true
}
```

---

## ✅ Checklist de Implementação

### Banco de Dados
- [ ] Verificar que todas as tabelas têm campo `module`
- [ ] Criar índices para performance em queries filtradas por módulo
- [ ] Testar constraints e integridade referencial

### Backend
- [ ] Adicionar filtro de módulo em todas as queries
- [ ] Criar endpoints específicos para equipment
- [ ] Criar endpoints para maintenance_plans
- [ ] Validar que work_orders respeitam módulo da zone/equipment

### Frontend
- [ ] Toggle de módulo no header/sidebar
- [ ] Dashboard filtrado por módulo
- [ ] Página de equipment (nova)
- [ ] Página de maintenance plans (nova)
- [ ] Adaptar formulários para contexto do módulo

### Dados
- [ ] Cadastrar equipamentos TECNOFIBRA
- [ ] Criar planos de manutenção
- [ ] Configurar checklists técnicos
- [ ] Testar geração de work orders

---

**Próxima Ação:** Decidir estratégia (Migração ou Dupla Natureza) e iniciar implementação
