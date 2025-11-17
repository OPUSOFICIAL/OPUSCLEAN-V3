# ✅ MELHORIA: TURNOS COM DIAS DA SEMANA ESPECÍFICOS

**Data:** 17 de Novembro de 2025  
**Funcionalidade:** Atividades por turno agora podem ser configuradas para dias específicos da semana  
**Status:** ✅ IMPLEMENTADO E FUNCIONANDO

---

## 🎯 OBJETIVO

Permitir que atividades de limpeza e manutenção com frequência "por turno" possam ser agendadas para **dias específicos da semana**, não apenas todos os dias.

### Exemplos de Uso:

1. **Limpeza de banheiros** nos turnos **Manhã e Tarde**, apenas de **Segunda a Sexta**
2. **Manutenção HVAC** no turno **Noite**, apenas em **Terça e Quinta**
3. **Limpeza profunda** nos turnos **Manhã, Tarde e Noite**, apenas aos **Sábados**

---

## 📋 ANTES vs DEPOIS

### ❌ ANTES (Limitado)

```
Frequência: Por Turno
Turnos: ☑ Manhã  ☑ Tarde  ☑ Noite

Resultado: Atividade acontece TODOS OS DIAS nos 3 turnos
```

**Problema:** Não havia controle sobre quais dias da semana executar os turnos.

### ✅ DEPOIS (Flexível)

```
Frequência: Por Turno
Turnos: ☑ Manhã  ☑ Tarde  ☐ Noite

Dias da Semana:
☐ Dom  ☑ Seg  ☑ Ter  ☑ Qua  ☑ Qui  ☑ Sex  ☐ Sáb

Resultado: Atividade acontece apenas de SEGUNDA a SEXTA nos turnos Manhã e Tarde
```

**Ganho:** Controle total sobre dias E turnos!

---

## 🛠️ IMPLEMENTAÇÃO TÉCNICA

### 1️⃣ Frontend - Formulário de Criação

**Arquivos Modificados:**
- `client/src/pages/cleaning-schedule.tsx` (linhas 2100-2161)
- `client/src/pages/maintenance-plans.tsx` (linhas 2185-2249)

**Novos Campos Adicionados:**

```tsx
{formData.frequency === "turno" && (
  <>
    {/* Campo de Turnos (já existia) */}
    <div key="shift-config" className="md:col-span-2 space-y-3">
      <Label>Turnos *</Label>
      <div className="flex gap-4">
        {/* Manhã, Tarde, Noite */}
      </div>
    </div>
    
    {/* NOVO: Campo de Dias da Semana */}
    <div key="shift-weekdays-config" className="md:col-span-2 space-y-3">
      <Label>Dias da Semana *</Label>
      <div className="grid grid-cols-7 gap-2">
        {/* Dom, Seg, Ter, Qua, Qui, Sex, Sáb */}
      </div>
      <p className="text-xs text-muted-foreground">
        Selecione os dias da semana em que as atividades dos turnos escolhidos devem ocorrer
      </p>
    </div>
  </>
)}
```

**Validação Adicionada:**

```typescript
// Validação de turnos (já existia)
if (formData.frequency === "turno" && formData.frequencyConfig.turnShifts.length === 0) {
  toast({ title: "Turnos obrigatórios", description: "Selecione pelo menos um turno" });
  return;
}

// NOVA: Validação de dias da semana
if (formData.frequency === "turno" && formData.frequencyConfig.weekDays.length === 0) {
  toast({ 
    title: "Dias da semana obrigatórios",
    description: "Selecione pelo menos um dia da semana para as atividades por turno"
  });
  return;
}
```

---

### 2️⃣ Backend - Geração de Work Orders

**Arquivo Modificado:**
- `server/storage.ts` (linhas 2882-2919)

**Lógica Implementada:**

```typescript
case 'turno':
  // NOVA: Verificar dias da semana configurados
  const turnWeekDays = (frequencyConfig as any)?.weekDays || [];
  const currentDayOfWeek = current.getDay(); // 0 = domingo
  const turnDayMap = {
    'domingo': 0, 'segunda': 1, 'terca': 2, 'quarta': 3,
    'quinta': 4, 'sexta': 5, 'sabado': 6
  };
  
  // NOVA: Se dias da semana foram configurados, verificar se o dia atual está incluído
  const shouldGenerateForToday = turnWeekDays.length === 0 || 
    turnWeekDays.some((day: string) => turnDayMap[day] === currentDayOfWeek);
  
  if (shouldGenerateForToday) {
    const shifts = (frequencyConfig as any)?.turnShifts || ['manha'];
    const shiftTimes = {
      'manha': { hour: 8, minute: 0 },
      'tarde': { hour: 14, minute: 0 },
      'noite': { hour: 20, minute: 0 }
    };
    
    shifts.forEach((shift: string, index: number) => {
      // Gerar work order para este turno neste dia
    });
  }
  break;
```

**Comportamento:**
1. ✅ Se `weekDays` está vazio → Gera para TODOS os dias (retrocompatibilidade)
2. ✅ Se `weekDays` tem valores → Gera APENAS nos dias selecionados

---

### 3️⃣ Frontend - Exibição no Calendário

**Arquivo Modificado:**
- `client/src/pages/cleaning-schedule.tsx` (linhas 357-376)

**Lógica de Filtro:**

```typescript
if (activity.frequency === 'turno') {
  // NOVA: Atividades por turno aparecem apenas nos dias da semana configurados
  const turnWeekDays = activity.frequencyConfig?.weekDays || [];
  
  if (turnWeekDays.length === 0) {
    // Retrocompatibilidade: Se não houver dias configurados, mostrar todos os dias
    return true;
  }
  
  // Verificar se o dia atual está nos dias configurados
  const dayOfWeek = currentDate.getDay(); // 0 = domingo
  const dayMap = {
    'domingo': 0, 'segunda': 1, 'terca': 2, 'quarta': 3,
    'quinta': 4, 'sexta': 5, 'sabado': 6
  };
  
  return turnWeekDays.some((weekDay: string) => 
    dayMap[weekDay as keyof typeof dayMap] === dayOfWeek
  );
}
```

---

## 📊 ESTRUTURA DE DADOS

### Modelo de Dados (`frequencyConfig`):

```typescript
interface FrequencyConfig {
  weekDays: string[];        // NOVO! Para atividades por turno
  turnShifts: string[];      // Já existia
  monthDay?: number;
  timesPerDay?: number;
}
```

### Exemplo de Atividade Salva:

```json
{
  "id": "ca-123",
  "name": "Limpeza de Banheiros",
  "frequency": "turno",
  "frequencyConfig": {
    "turnShifts": ["manha", "tarde"],      // Turnos selecionados
    "weekDays": ["segunda", "terca", "quarta", "quinta", "sexta"]  // NOVO!
  },
  "zoneIds": ["zone-1", "zone-2"],
  "serviceId": "service-limpeza",
  // ...outros campos
}
```

---

## 🧪 CASOS DE TESTE

### Teste 1: Segunda a Sexta, Manhã e Tarde

**Configuração:**
- Turnos: Manhã, Tarde
- Dias: Segunda, Terça, Quarta, Quinta, Sexta

**Resultado Esperado:**
- ✅ Work orders geradas: Seg a Sex (2 por dia = 10 por semana)
- ❌ Nenhuma work order no Sábado ou Domingo

### Teste 2: Apenas Terça e Quinta, Turno Noite

**Configuração:**
- Turnos: Noite
- Dias: Terça, Quinta

**Resultado Esperado:**
- ✅ Work orders geradas: Apenas Terça e Quinta (1 por dia = 2 por semana)
- ❌ Nenhuma work order nos outros dias

### Teste 3: Todos os Dias, Todos os Turnos

**Configuração:**
- Turnos: Manhã, Tarde, Noite
- Dias: Dom, Seg, Ter, Qua, Qui, Sex, Sáb

**Resultado Esperado:**
- ✅ Work orders geradas: Todos os dias (3 por dia = 21 por semana)

### Teste 4: Retrocompatibilidade (Atividade Antiga)

**Configuração:**
- Atividade criada ANTES dessa melhoria
- `frequencyConfig.weekDays` = `[]` (vazio ou undefined)

**Resultado Esperado:**
- ✅ Funciona como antes: Work orders geradas todos os dias
- ✅ Sem quebra de funcionalidade

---

## 📱 COMO USAR

### Criar Nova Atividade por Turno:

1. Vá em **Limpeza > Programação** ou **Manutenção > Planos**
2. Clique em **+ Nova Atividade**
3. Selecione **Frequência: Por Turno**
4. **Selecione os Turnos:**
   - ☑ Manhã (8h)
   - ☑ Tarde (14h)
   - ☐ Noite (20h)
5. **NOVO: Selecione os Dias da Semana:**
   - ☐ Dom
   - ☑ Seg
   - ☑ Ter
   - ☑ Qua
   - ☑ Qui
   - ☑ Sex
   - ☐ Sáb
6. Preencha os demais campos (Local, Zona, Serviço, etc.)
7. Clique em **Salvar**

### Resultado:

✅ Work orders serão geradas:
- **Segunda a Sexta**
- **Nos turnos Manhã (8h) e Tarde (14h)**
- **Total: 10 work orders por semana** (5 dias × 2 turnos)

---

## 🎨 INTERFACE DO USUÁRIO

### Visual do Formulário:

```
┌─────────────────────────────────────────────────────────┐
│ Frequência e Periodicidade                              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ Frequência *                                             │
│ ┌─────────────────────────────────┐                     │
│ │ Por Turno                    ▼  │                     │
│ └─────────────────────────────────┘                     │
│                                                          │
│ Turnos *                                                 │
│ ☑ Manhã    ☑ Tarde    ☐ Noite                          │
│                                                          │
│ Dias da Semana *                    ← NOVO!             │
│ ┌───┬───┬───┬───┬───┬───┬───┐                          │
│ │ ☐ │ ☑ │ ☑ │ ☑ │ ☑ │ ☑ │ ☐ │                          │
│ │Dom│Seg│Ter│Qua│Qui│Sex│Sáb│                          │
│ └───┴───┴───┴───┴───┴───┴───┘                          │
│ Selecione os dias da semana em que as atividades dos    │
│ turnos escolhidos devem ocorrer                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 COMPATIBILIDADE

### Atividades Antigas (Criadas Antes da Melhoria):

✅ **Totalmente compatível!**

- Atividades antigas sem `frequencyConfig.weekDays` continuam funcionando
- Backend detecta `weekDays` vazio e gera para todos os dias (comportamento original)
- Frontend mostra atividade no calendário todos os dias (comportamento original)

### Migração de Dados:

❌ **Não é necessária!**

- Não há necessidade de migrar atividades antigas
- O código é retrocompatível
- Atividades antigas funcionam como sempre funcionaram

---

## 📈 BENEFÍCIOS

### 1️⃣ **Flexibilidade Operacional**

- ✅ Limpeza intensiva de Segunda a Sexta
- ✅ Manutenção preventiva apenas em dias específicos
- ✅ Regime diferenciado para finais de semana

### 2️⃣ **Economia de Recursos**

- ✅ Não gerar work orders desnecessárias
- ✅ Otimizar alocação de equipe
- ✅ Reduzir custos operacionais

### 3️⃣ **Melhor Planejamento**

- ✅ Calendário mais preciso
- ✅ Work orders apenas quando necessário
- ✅ Visão clara da programação semanal

---

## 🚀 PRÓXIMOS PASSOS (SUGESTÕES)

### Possíveis Melhorias Futuras:

1. **Horários Personalizados por Turno**
   - Permitir configurar horário específico para cada turno
   - Ex: Manhã às 6h, Tarde às 13h, Noite às 22h

2. **Turnos por Dia da Semana**
   - Permitir turnos diferentes em dias diferentes
   - Ex: Seg-Sex: Manhã e Tarde | Sáb: Apenas Manhã

3. **Exceções de Feriados**
   - Não gerar work orders em feriados
   - Calendário de feriados configurável

4. **Previsão de Carga de Trabalho**
   - Dashboard mostrando quantas work orders serão geradas
   - Estimativa de horas de trabalho por semana/mês

---

## ✅ CHECKLIST DE VALIDAÇÃO

- [x] Campo de dias da semana aparece quando frequency === 'turno'
- [x] Validação impede salvar sem selecionar dias da semana
- [x] Backend gera work orders apenas nos dias selecionados
- [x] Calendário exibe atividades apenas nos dias corretos
- [x] Retrocompatibilidade com atividades antigas
- [x] Funciona tanto em Limpeza quanto em Manutenção
- [x] Servidor rodando sem erros
- [x] Hot reload funcionando
- [x] Documentação completa criada

---

## 📄 ARQUIVOS MODIFICADOS

### Frontend:
1. `client/src/pages/cleaning-schedule.tsx`
   - Linhas 357-376: Filtro de calendário
   - Linhas 1895-1902: Validação de formulário
   - Linhas 2100-2161: Campos de formulário

2. `client/src/pages/maintenance-plans.tsx`
   - Linhas 1991-1998: Validação de formulário
   - Linhas 2185-2249: Campos de formulário

### Backend:
3. `server/storage.ts`
   - Linhas 2882-2919: Lógica de geração de work orders

---

## 🎉 CONCLUSÃO

A melhoria foi implementada com **sucesso total**! Agora é possível criar atividades por turno que acontecem apenas em **dias específicos da semana**, oferecendo:

- ✅ **Flexibilidade máxima** no agendamento
- ✅ **Economia de recursos** (menos work orders desnecessárias)
- ✅ **Compatibilidade total** com dados existentes
- ✅ **Interface intuitiva** e fácil de usar

**A funcionalidade está pronta para uso imediato!** 🚀
