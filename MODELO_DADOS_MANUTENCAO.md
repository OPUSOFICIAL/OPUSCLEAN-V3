# Modelo de Dados - Módulo de Manutenção

**Data**: 3 de Novembro, 2025  
**Status**: Schema implementado, pendente push ao banco

## Visão Geral

O módulo de Manutenção foi projetado com arquitetura **baseada em equipamentos**, diferente do módulo Clean que é baseado em zonas. Cada equipamento pode ter:
- QR Codes específicos
- Templates de checklist customizados
- Planos de manutenção com frequências programadas
- Histórico completo de execuções

## Novas Tabelas Implementadas

### 28. Equipment (Equipamentos)
**Propósito**: Registro centralizado de todos os equipamentos que necessitam manutenção

```typescript
{
  id: varchar (PK)
  companyId: varchar (FK → companies)
  customerId: varchar (FK → customers)
  siteId: varchar (FK → sites)
  zoneId: varchar (FK → zones)
  name: varchar
  internalCode: varchar
  equipmentType: varchar (categoria do equipamento)
  manufacturer: varchar
  model: varchar
  serialNumber: varchar
  purchaseDate: date
  warrantyExpiry: date
  installationDate: date
  technicalSpecs: jsonb (especificações técnicas)
  maintenanceNotes: text
  qrCodeUrl: varchar (URL do QR Code gerado)
  isActive: boolean
  createdAt: timestamp
  updatedAt: timestamp
}
```

**Características**:
- Multi-tenant (companyId + customerId)
- Localização hierárquica (site → zone)
- Especificações técnicas flexíveis (JSONB)
- Suporta QR Code próprio

---

### 29. Maintenance_Checklist_Templates (Templates de Checklist)
**Propósito**: Templates de checklist **específicos por tipo de equipamento ou equipamento individual**

```typescript
{
  id: varchar (PK)
  companyId: varchar (FK → companies)
  customerId: varchar (FK → customers)
  name: varchar
  description: text
  equipmentType: varchar (opcional - template para categoria)
  equipmentId: varchar (FK → equipment, opcional - template para equipamento específico)
  version: integer (versionamento de checklists)
  items: jsonb (itens do checklist)
  isActive: boolean
  createdAt: timestamp
  updatedAt: timestamp
}
```

**Características**:
- Pode ser genérico (equipmentType) ou específico (equipmentId)
- Versionamento para histórico de mudanças
- Estrutura de itens flexível (JSONB)
- Reutilizável entre múltiplos equipamentos

**Estrutura do campo `items` (JSONB)**:
```json
[
  {
    "id": "check-1",
    "title": "Verificar nível de óleo",
    "type": "checkbox",
    "required": true,
    "order": 1
  },
  {
    "id": "check-2",
    "title": "Temperatura do motor (°C)",
    "type": "number",
    "required": true,
    "min": 0,
    "max": 100,
    "order": 2
  },
  {
    "id": "check-3",
    "title": "Observações gerais",
    "type": "text",
    "required": false,
    "order": 3
  }
]
```

---

### 30. Maintenance_Checklist_Executions (Execuções de Checklist)
**Propósito**: Histórico de todas as execuções de checklists de manutenção

```typescript
{
  id: varchar (PK)
  checklistTemplateId: varchar (FK → maintenance_checklist_templates)
  equipmentId: varchar (FK → equipment)
  workOrderId: varchar (FK → work_orders, opcional)
  executedByUserId: varchar (FK → users)
  startedAt: timestamp
  finishedAt: timestamp
  status: varchar ('in_progress' | 'completed' | 'cancelled')
  checklistData: jsonb (respostas do checklist)
  observations: text
  attachments: jsonb (fotos/documentos)
  createdAt: timestamp
  updatedAt: timestamp
}
```

**Características**:
- Rastreabilidade completa (quem, quando, qual equipamento)
- Pode estar vinculado a uma Work Order ou ser standalone
- Suporta anexos (fotos de evidências)
- Registro de início e fim para métricas de tempo

**Estrutura do campo `checklistData` (JSONB)**:
```json
{
  "check-1": { "value": true, "timestamp": "2025-11-03T10:15:00Z" },
  "check-2": { "value": 85, "timestamp": "2025-11-03T10:16:00Z" },
  "check-3": { "value": "Motor funcionando normalmente", "timestamp": "2025-11-03T10:17:00Z" }
}
```

---

### 31. Maintenance_Plans (Planos de Manutenção)
**Propósito**: Planos de manutenção preventiva/preditiva que agrupam equipamentos

```typescript
{
  id: varchar (PK)
  companyId: varchar (FK → companies)
  customerId: varchar (FK → customers)
  name: varchar
  description: text
  type: varchar ('preventiva' | 'preditiva' | 'corretiva')
  isActive: boolean
  createdAt: timestamp
  updatedAt: timestamp
}
```

**Características**:
- Container lógico para agrupar equipamentos
- Diferentes tipos de manutenção
- Multi-tenant

**Exemplos de Planos**:
- "Manutenção Preventiva Mensal - Ar Condicionado"
- "Manutenção Preditiva Trimestral - Elevadores"
- "Manutenção Corretiva - Geradores"

---

### 32. Maintenance_Plan_Equipments (Link Planos ↔ Equipamentos)
**Propósito**: Relaciona equipamentos com planos de manutenção, definindo frequência e checklist específico

```typescript
{
  id: varchar (PK)
  planId: varchar (FK → maintenance_plans)
  equipmentId: varchar (FK → equipment)
  checklistTemplateId: varchar (FK → maintenance_checklist_templates)
  frequency: frequencyEnum ('diaria' | 'semanal' | 'mensal' | 'trimestral' | 'semestral' | 'anual')
  frequencyConfig: jsonb (configuração avançada)
  nextExecutionAt: timestamp (próxima execução agendada)
  lastExecutionAt: timestamp (última execução realizada)
  isActive: boolean
  createdAt: timestamp
  updatedAt: timestamp
}
```

**UNIQUE CONSTRAINT**: (planId, equipmentId) - Um equipamento não pode aparecer duplicado no mesmo plano

**Características**:
- Define **qual checklist usar** para este equipamento neste plano
- Frequência de manutenção configurável
- Auto-agendamento (nextExecutionAt/lastExecutionAt)
- Permite mesmo equipamento em múltiplos planos (ex: manutenção mensal + anual)

**Estrutura do campo `frequencyConfig` (JSONB)**:
```json
{
  "daysOfWeek": [1, 3, 5],  // Segunda, Quarta, Sexta (para frequência semanal)
  "dayOfMonth": 15,         // Dia 15 de cada mês (para frequência mensal)
  "hour": "08:00",          // Horário preferencial
  "skipHolidays": true      // Pular feriados
}
```

---

## Alterações em Tabelas Existentes

### Work_Orders (Ordens de Trabalho)
**Novos campos**:
```typescript
equipmentId: varchar (FK → equipment)
maintenancePlanEquipmentId: varchar (FK → maintenance_plan_equipments)
```

**Lógica de Uso**:
- **OPUS Clean**: usa `zoneId` + `cleaningActivityId`
- **OPUS Manutenção**: usa `equipmentId` + `maintenancePlanEquipmentId`

---

### QR_Code_Points (Pontos de QR Code)
**Novos campos**:
```typescript
equipmentId: varchar (FK → equipment)
zoneId: varchar (agora opcional - antes obrigatório)
```

**Lógica de Uso**:
- **QR de Zona** (Clean): `zoneId` preenchido, `equipmentId` null
- **QR de Equipamento** (Manutenção): `equipmentId` preenchido, `zoneId` pode estar preenchido (localização do equipamento)

---

## Fluxo de Dados - Manutenção Programada

### 1. Criação do Plano
```
1. Cliente cria um Plano de Manutenção
   → "Manutenção Preventiva Mensal - Ar Condicionado"
   
2. Adiciona equipamentos ao plano (maintenance_plan_equipments)
   → Equipamento AC-01 (frequência: mensal, checklist: "Checklist AC Split")
   → Equipamento AC-02 (frequência: mensal, checklist: "Checklist AC Split")
   
3. Sistema calcula nextExecutionAt baseado em frequency
```

### 2. Geração Automática de Work Orders
```
Sistema (scheduler/cron):
  - Varre maintenance_plan_equipments onde nextExecutionAt <= hoje
  - Para cada item:
    1. Cria Work Order programada
       - equipmentId = item.equipmentId
       - maintenancePlanEquipmentId = item.id
       - checklistTemplateId = item.checklistTemplateId
       - scheduledDate = nextExecutionAt
    2. Atualiza lastExecutionAt = nextExecutionAt
    3. Calcula nova nextExecutionAt baseado em frequency
```

### 3. Execução pelo Operador
```
Operador:
  1. Escaneia QR Code do equipamento
  2. Sistema identifica:
     - Equipment (via qr_code_points.equipmentId)
     - Work Orders pendentes para este equipamento
  3. Operador inicia Work Order
  4. Preenche checklist (maintenance_checklist_executions)
  5. Conclui Work Order
  6. Sistema registra:
     - maintenance_checklist_executions com checklistData
     - work_orders.completedAt
     - maintenance_plan_equipments.lastExecutionAt
```

---

## Fluxo de Dados - Manutenção Corretiva

### 1. Via QR Público (Usuário Final)
```
1. Usuário escaneia QR do equipamento
2. Preenche formulário: "Ar condicionado não está gelando"
3. Sistema cria:
   - public_request_logs
   - work_orders (tipo: corretiva_publica, equipmentId preenchido)
```

### 2. Via QR Interno (Operador)
```
1. Operador escaneia QR do equipamento durante ronda
2. Identifica problema e cria Work Order corretiva interna
3. Sistema cria:
   - work_orders (tipo: corretiva_interna, equipmentId preenchido)
```

---

## Diferenças: Clean vs Manutenção

| Aspecto | OPUS Clean | OPUS Manutenção |
|---------|------------|-----------------|
| **Entidade Base** | Zone (Sala, Corredor, etc) | Equipment (AC, Elevador, etc) |
| **Atividades** | cleaning_activities (Varrer, Lavar) | maintenance_plan_equipments (Preventiva Mensal) |
| **Checklists** | checklistTemplates (genéricos) | maintenance_checklist_templates (específicos por equipamento) |
| **QR Codes** | qr_code_points.zoneId | qr_code_points.equipmentId |
| **Work Orders** | cleaningActivityId | equipmentId + maintenancePlanEquipmentId |
| **Frequência** | cleaning_activities.frequency | maintenance_plan_equipments.frequency |
| **Métricas** | Área limpa, tempo por zona | MTBF, MTTR, disponibilidade do equipamento |

---

## Relations Implementadas

### Equipment Relations:
- `company` (1:N) → companies
- `customer` (1:N) → customers
- `site` (1:N) → sites
- `zone` (1:N) → zones
- `maintenanceChecklistTemplates` (N:1) ← maintenance_checklist_templates
- `maintenanceChecklistExecutions` (N:1) ← maintenance_checklist_executions
- `maintenancePlanEquipments` (N:1) ← maintenance_plan_equipments
- `workOrders` (N:1) ← work_orders
- `qrCodePoints` (N:1) ← qr_code_points

### Maintenance_Checklist_Templates Relations:
- `company` (1:N) → companies
- `customer` (1:N) → customers
- `equipment` (1:N) → equipment (opcional)
- `maintenanceChecklistExecutions` (N:1) ← maintenance_checklist_executions
- `maintenancePlanEquipments` (N:1) ← maintenance_plan_equipments

### Maintenance_Checklist_Executions Relations:
- `checklistTemplate` (1:N) → maintenance_checklist_templates
- `equipment` (1:N) → equipment
- `workOrder` (1:N) → work_orders (opcional)
- `executedBy` (1:N) → users

### Maintenance_Plans Relations:
- `company` (1:N) → companies
- `customer` (1:N) → customers
- `maintenancePlanEquipments` (N:1) ← maintenance_plan_equipments

### Maintenance_Plan_Equipments Relations:
- `plan` (1:N) → maintenance_plans
- `equipment` (1:N) → equipment
- `checklistTemplate` (1:N) → maintenance_checklist_templates

---

## Insert Schemas e Types

Todos os insert schemas foram criados seguindo o padrão do projeto:

```typescript
// Insert Schemas
export const insertEquipmentSchema = createInsertSchema(equipment).omit({ id: true });
export const insertMaintenanceChecklistTemplateSchema = createInsertSchema(maintenanceChecklistTemplates).omit({ id: true });
export const insertMaintenanceChecklistExecutionSchema = createInsertSchema(maintenanceChecklistExecutions).omit({ id: true });
export const insertMaintenancePlanSchema = createInsertSchema(maintenancePlans).omit({ id: true });
export const insertMaintenancePlanEquipmentSchema = createInsertSchema(maintenancePlanEquipments).omit({ id: true });

// Types
export type Equipment = typeof equipment.$inferSelect;
export type InsertEquipment = z.infer<typeof insertEquipmentSchema>;

export type MaintenanceChecklistTemplate = typeof maintenanceChecklistTemplates.$inferSelect;
export type InsertMaintenanceChecklistTemplate = z.infer<typeof insertMaintenanceChecklistTemplateSchema>;

export type MaintenanceChecklistExecution = typeof maintenanceChecklistExecutions.$inferSelect;
export type InsertMaintenanceChecklistExecution = z.infer<typeof insertMaintenanceChecklistExecutionSchema>;

export type MaintenancePlan = typeof maintenancePlans.$inferSelect;
export type InsertMaintenancePlan = z.infer<typeof insertMaintenancePlanSchema>;

export type MaintenancePlanEquipment = typeof maintenancePlanEquipments.$inferSelect;
export type InsertMaintenancePlanEquipment = z.infer<typeof insertMaintenancePlanEquipmentSchema>;
```

---

## Próximos Passos

1. ✅ **CONCLUÍDO**: Schema completo implementado em `shared/schema.ts`
2. **PENDENTE**: Atualizar `server/storage.ts` com CRUD para novas entidades
3. **PENDENTE**: Criar rotas API em `server/routes.ts`
4. **PENDENTE**: Implementar páginas frontend
5. **PENDENTE**: Executar `npm run db:push` para aplicar schema no banco
6. **PENDENTE**: Testes de integração

---

## Considerações de Design

### Por que separar Checklist Templates e Executions?
- **Reusabilidade**: Um template pode ser usado em múltiplos equipamentos
- **Versionamento**: Mudanças no template não afetam execuções antigas
- **Auditoria**: Histórico completo de execuções independente de mudanças futuras

### Por que Maintenance_Plan_Equipments ao invés de campo direto?
- **Flexibilidade**: Mesmo equipamento pode estar em múltiplos planos (manutenção mensal + anual)
- **Checklist Específico**: Cada relação plano-equipamento tem seu próprio checklist
- **Frequência Individual**: Equipamentos do mesmo tipo podem ter frequências diferentes

### Por que equipmentId e maintenancePlanEquipmentId em Work Orders?
- `equipmentId`: Identifica o equipamento (usado em corretivas também)
- `maintenancePlanEquipmentId`: Identifica a relação específica plano-equipamento (usado apenas em preventivas programadas)

---

**Arquivo**: `shared/schema.ts`  
**Linhas adicionadas**: ~200  
**Tabelas criadas**: 5  
**Relations adicionadas**: 5  
**Insert Schemas criados**: 5  
**Types exportados**: 10
