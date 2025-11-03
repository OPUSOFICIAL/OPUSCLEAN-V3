# Análise do Estado Atual - OPUS Manutenção

**Data:** Novembro 2025  
**Objetivo:** Transformar OPUS Manutenção em sistema baseado em EQUIPAMENTOS

---

## 1. ESTADO ATUAL DO SISTEMA

### 1.1 Tabelas Existentes Relevantes

#### Hierarquia Multi-Tenancy (COMPARTILHADA)
```
companies → customers → sites → zones
```

**Tabelas:**
- `companies` - Empresas (ex: OPUS)
- `customers` - Clientes contratantes (ex: FAURECIA)
- `sites` - Locais físicos do cliente (ex: Fábrica São Paulo)
- `zones` - Zonas/áreas dentro de um site (ex: Sala 301, Banheiro 1º andar)

#### Work Orders (COMPARTILHADA com discriminador `module`)
- `work_orders` - Ordens de serviço
  - **Campo `module`**: 'clean' | 'maintenance'
  - **Campo `cleaningActivityId`**: FK para cleaning_activities (só Clean)
  - **FALTAM**: `maintenanceActivityId`, `equipmentId` (para Manutenção)
  
#### Checklists (ATUALMENTE SÓ CLEAN)
- `checklist_templates` - Templates de checklist
  - Campos: `companyId`, `serviceId`, `siteId`, `zoneId`, `name`, `items` (JSONB)
  - **Vinculado a**: service, site, zone (NÃO vinculado a equipamento)
  - **Usado por**: cleaning_activities

#### Atividades de Limpeza (SÓ CLEAN)
- `cleaning_activities` - Atividades programadas de limpeza
  - Campos: `companyId`, `serviceId`, `siteId`, `zoneId`, `frequency`, `checklistTemplateId`
  - **Modelo**: Atividade vinculada a uma ZONA/LOCAL
  - **Campo `module`**: default 'clean'

#### Serviços (COMPARTILHADA com discriminador `module`)
- `services` - Serviços disponíveis
  - **Campo `module`**: 'clean' | 'maintenance'
  - Campos: `name`, `description`, `estimatedDurationMinutes`, `customerId`

---

## 2. FLUXO ATUAL DO OPUS CLEAN

### Modelo de Operação (ZONE-BASED)
```
1. Cliente (customer) possui Sites
2. Sites possuem Zones (locais/áreas)
3. Cleaning Activity é criada para uma ZONE
   └─ Vincula: serviceId, zoneId, checklistTemplateId, frequency
4. Sistema gera Work Orders programadas baseadas na atividade
5. Operador executa Work Order escaneando QR da zona
   └─ Preenche checklist vinculado à zona
```

### Páginas Frontend (Clean)
- `/schedule` - Plano de Limpeza (lista cleaning_activities)
- `/checklists` - Gerenciamento de checklist templates
- `/workorders` - Ordens de serviço (compartilhado)
- `/qrcodes` - QR Codes por zona

### Rotas Backend (Clean)
```
GET  /api/companies/:companyId/cleaning-activities?module=clean
POST /api/cleaning-activities
GET  /api/companies/:companyId/checklist-templates
POST /api/companies/:companyId/checklist-templates
```

---

## 3. PROBLEMAS IDENTIFICADOS PARA MANUTENÇÃO

### 3.1 Modelo Atual NÃO Serve para Manutenção

**Problema 1: Checklist por ZONA ≠ Checklist por EQUIPAMENTO**
- Clean: "Limpar Sala 301" → checklist vinculado à zona "Sala 301"
- Manutenção: "Manutenção do Compressor XYZ" → checklist vinculado ao EQUIPAMENTO "Compressor XYZ"

**Problema 2: Falta Entidade EQUIPAMENTO**
- Não existe tabela `equipment`
- Não há como cadastrar:
  - Equipamentos por zona
  - Tipo de equipamento
  - Dados técnicos (fabricante, modelo, série)
  - Localização física (zoneId)

**Problema 3: Work Orders NÃO têm vínculo com Equipamento**
- `work_orders.equipmentId` não existe
- Não dá para rastrear histórico de manutenções por equipamento

**Problema 4: Cleaning Activities NÃO serve para Manutenção**
- `cleaning_activities` é específico para limpeza
- Precisamos de `maintenance_plans` com lógica própria

---

## 4. MODELO ALVO PARA MANUTENÇÃO (EQUIPMENT-BASED)

### 4.1 Novo Fluxo Proposto
```
1. Cliente (customer) possui Sites
2. Sites possuem Zones (locais/áreas)
3. EQUIPAMENTOS são cadastrados em Zones
   └─ Cada equipamento tem: name, type, manufacturer, model, serialNumber
4. CHECKLIST DE MANUTENÇÃO é criado POR EQUIPAMENTO (ou tipo)
   └─ Exemplo: "Checklist Manutenção Preventiva - Compressor"
5. PLANO DE MANUTENÇÃO vincula equipamentos + checklists
   └─ Define periodicidade, tipo (preventiva/corretiva)
6. Sistema gera Work Orders de manutenção para equipamentos
7. Técnico executa WO escaneando QR do EQUIPAMENTO
   └─ Preenche checklist vinculado ao equipamento
```

### 4.2 Novas Entidades Necessárias

#### 1. `equipment` (Equipamentos)
```typescript
{
  id: varchar,
  companyId: varchar (FK),
  customerId: varchar (FK),
  siteId: varchar (FK),
  zoneId: varchar (FK),          // Localização física
  name: varchar,
  internalCode: varchar,          // Código interno do cliente
  equipmentType: varchar,         // "Compressor", "HVAC", "Elevador"
  manufacturer: varchar,
  model: varchar,
  serialNumber: varchar,
  purchaseDate: date,
  warrantyExpiry: date,
  technicalSpecs: jsonb,          // Especificações técnicas
  qrCodeUrl: varchar,             // QR Code do equipamento
  isActive: boolean,
  module: 'maintenance'
}
```

#### 2. `maintenance_checklist_templates` (Templates de Checklist de Manutenção)
```typescript
{
  id: varchar,
  companyId: varchar (FK),
  customerId: varchar (FK),
  name: varchar,
  description: text,
  equipmentType: varchar,         // "Compressor", "HVAC", etc (opcional)
  equipmentId: varchar (FK),      // Checklist específico de UM equipamento (opcional)
  version: integer,               // Versionamento
  items: jsonb,                   // Array de itens do checklist
  isActive: boolean,
  module: 'maintenance'
}
```

#### 3. `maintenance_checklist_executions` (Execuções de Checklist)
```typescript
{
  id: varchar,
  checklistTemplateId: varchar (FK),
  equipmentId: varchar (FK),
  workOrderId: varchar (FK),
  startedAt: timestamp,
  finishedAt: timestamp,
  status: 'in_progress' | 'completed' | 'cancelled',
  executedByUserId: varchar (FK),
  checklistData: jsonb,           // Respostas do checklist
  observations: text,
  attachments: jsonb
}
```

#### 4. `maintenance_plans` (Planos de Manutenção)
```typescript
{
  id: varchar,
  companyId: varchar (FK),
  customerId: varchar (FK),
  name: varchar,
  description: text,
  type: 'preventiva' | 'preditiva' | 'inspecao',
  isActive: boolean,
  module: 'maintenance'
}
```

#### 5. `maintenance_plan_equipments` (Equipamentos no Plano)
```typescript
{
  id: varchar,
  planId: varchar (FK),
  equipmentId: varchar (FK),
  checklistTemplateId: varchar (FK),
  frequency: 'diaria' | 'semanal' | 'mensal' | 'trimestral',
  frequencyConfig: jsonb,
  nextExecutionAt: timestamp,
  lastExecutionAt: timestamp,
  isActive: boolean
}
```

---

## 5. DECISÕES DE ARQUITETURA

### 5.1 Reutilizar vs Criar Novas Tabelas

**DECISÃO: CRIAR TABELAS ESPECÍFICAS para Manutenção**

**Razões:**
1. **Isolamento Claro**: `cleaning_activities` é específico de limpeza
   - Mantém backwards compatibility
   - Não quebra Clean
   
2. **Campos Específicos**: Manutenção precisa de:
   - `equipmentId` (não existe em cleaning_activities)
   - `equipmentType`
   - `technicalSpecs`
   
3. **Facilita Evolução**: Cada módulo evolui independentemente

### 5.2 Work Orders: Compartilhar ou Separar?

**DECISÃO: COMPARTILHAR `work_orders` com discriminador `module`**

**Razões:**
1. Work orders são conceito universal (Clean + Manutenção + futuros módulos)
2. Relatórios consolidados de todas as ordens
3. Apenas adicionar campos:
   - `maintenanceActivityId` (FK para maintenance_plans)
   - `equipmentId` (FK para equipment)

### 5.3 QR Codes: Zona vs Equipamento

**DECISÃO: QR Codes PODEM ser vinculados a EQUIPAMENTOS**

**Implementação:**
- Tabela `qr_code_points` já existe
- Adicionar campo opcional `equipmentId`
- Quando escanear QR:
  - Se tem `zoneId` → Clean (limpar zona)
  - Se tem `equipmentId` → Manutenção (manutenção do equipamento)

---

## 6. CAMPOS A ADICIONAR EM TABELAS EXISTENTES

### 6.1 `work_orders`
```typescript
// ADICIONAR:
maintenanceActivityId: varchar().references(() => maintenancePlans.id)
equipmentId: varchar().references(() => equipment.id)
```

### 6.2 `qr_code_points`
```typescript
// ADICIONAR:
equipmentId: varchar().references(() => equipment.id)
```

---

## 7. COMPATIBILIDADE E MIGRAÇÃO

### 7.1 Backwards Compatibility

**OPUS Clean continua funcionando 100%:**
- Todas as tabelas de Clean permanecem
- `cleaning_activities` não é alterado
- Páginas `/schedule`, `/checklists` permanecem iguais
- Rotas de Clean não mudam

### 7.2 Estratégia de Migração

**Fase 1: Adicionar Novas Tabelas**
```sql
-- Criar tabelas novas:
CREATE TABLE equipment (...)
CREATE TABLE maintenance_checklist_templates (...)
CREATE TABLE maintenance_checklist_executions (...)
CREATE TABLE maintenance_plans (...)
CREATE TABLE maintenance_plan_equipments (...)
```

**Fase 2: Adicionar Campos Opcionais**
```sql
-- work_orders
ALTER TABLE work_orders ADD COLUMN equipment_id VARCHAR;
ALTER TABLE work_orders ADD COLUMN maintenance_activity_id VARCHAR;

-- qr_code_points
ALTER TABLE qr_code_points ADD COLUMN equipment_id VARCHAR;
```

**Fase 3: Popular Equipamentos (se já existir WOs de manutenção)**
- Se já existem work orders com `module='maintenance'`:
  - Criar equipamentos genéricos baseados nas zones
  - Migrar work orders antigas para novos equipamentos

### 7.3 Rollback Plan

Se der problema:
1. Manter feature flag `ENABLE_MAINTENANCE_MODULE` = false
2. Todas as novas tabelas ficam vazias mas não quebram nada
3. Clean continua operando normalmente
4. Remover tabelas novas se necessário (sem impacto)

---

## 8. IMPACTO NO SISTEMA

### 8.1 Backend

**Storage Layer (`server/storage.ts`):**
- ✅ Adicionar interface para equipamentos
- ✅ Adicionar CRUD de maintenance checklists
- ✅ Adicionar CRUD de maintenance plans
- ✅ Atualizar work orders para suportar equipmentId

**Routes (`server/routes.ts`):**
- ✅ Adicionar rotas de equipamentos
- ✅ Adicionar rotas de maintenance checklists
- ✅ Adicionar rotas de maintenance plans

### 8.2 Frontend

**Novas Páginas (só visíveis quando `currentModule === 'maintenance'`):**
- `/equipment` - Listagem e cadastro de equipamentos
- `/maintenance-checklists` - Checklists de manutenção
- `/maintenance-plans` - Planos de manutenção
- `/maintenance-schedule` - Calendário de manutenções

**Sidebar:**
- Mostrar itens condicionalmente baseado em `currentModule`

### 8.3 Mobile

**Execução de Manutenção:**
- `/mobile/qr-scanner` já existe
- Quando escanear QR de equipamento:
  - Resolver equipmentId
  - Criar WO de manutenção
  - Executar checklist de manutenção
  - Similar ao fluxo de Clean, mas com dados de equipamento

---

## 9. PRÓXIMOS PASSOS

1. ✅ **Criar schema de manutenção** em `shared/schema.ts`
2. ✅ **Atualizar Storage Layer** com métodos de manutenção
3. ✅ **Criar rotas API REST** para equipamentos e planos
4. ✅ **Implementar páginas frontend** de manutenção
5. ✅ **Testar isolamento** entre Clean e Manutenção
6. ✅ **Push schema** e validar em desenvolvimento
7. ✅ **Documentar** arquitetura final

---

## 10. RESUMO EXECUTIVO

### Estado Atual
- OPUS Clean funciona baseado em **ZONAS/LOCAIS**
- Checklists vinculados a zonas
- Cleaning activities programam trabalhos por zona

### Estado Alvo (Manutenção)
- OPUS Manutenção funciona baseado em **EQUIPAMENTOS**
- Checklists vinculados a equipamentos (ou tipos)
- Maintenance plans programam trabalhos por equipamento
- Histórico de manutenções rastreável por equipamento

### Isolamento
- Clean e Manutenção **NÃO se misturam**
- Compartilham: customers, sites, zones, work_orders (com `module`)
- Específicos:
  - Clean: `cleaning_activities`, checklists por zona
  - Manutenção: `equipment`, `maintenance_plans`, checklists por equipamento

**Zero impacto no OPUS Clean!** ✅
