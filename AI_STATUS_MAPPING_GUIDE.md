# Guia de Mapeamento de Status - Chat AI

Este documento explica como o sistema de mapeamento de termos naturais em português funciona no chat AI do OPUS.

## 🎯 Problema Resolvido

**Antes**: Quando você perguntava "Quantas O.S abertas eu tenho?", o AI não entendia "abertas" e pedia para você escolher entre opções técnicas (`em_aberto`, `em_execucao`, etc).

**Depois**: Agora você pode usar linguagem natural. O AI entende automaticamente termos como "abertas", "ativas", "finalizadas", etc., e converte para os valores exatos do banco de dados.

## 📊 Valores no Banco de Dados

Os status das ordens de serviço no banco são:

| Valor no Banco | Significado |
|----------------|-------------|
| `aberta` | O.S que ainda não foi iniciada |
| `em_execucao` | O.S sendo executada no momento |
| `pausada` | O.S temporariamente pausada |
| `vencida` | O.S que passou do prazo |
| `concluida` | O.S finalizada com sucesso |
| `cancelada` | O.S cancelada |

## 🗣️ Termos Naturais Aceitos

Você pode usar qualquer um destes termos coloquiais ao perguntar para o AI:

### Para O.S "Abertas" (`aberta`)
- "abertas", "aberta"
- "aberto", "abertos"
- "não iniciada", "não iniciadas"
- "pendente", "pendentes"

### Para O.S "Ativas" (`em_execucao`)
- "ativa", "ativas"
- "em execução"
- "em andamento", "andamento"
- "executando"

### Para O.S "Pausadas" (`pausada`)
- "pausada", "pausadas"

### Para O.S "Vencidas/Atrasadas" (`vencida`)
- "vencida", "vencidas"
- "atrasada", "atrasadas"
- "overdue"

### Para O.S "Concluídas" (`concluida`)
- "concluída", "concluídas"
- "finalizada", "finalizadas"
- "completa", "completas"
- "feita", "feitas"
- "terminada", "terminadas"

### Para O.S "Canceladas" (`cancelada`)
- "cancelada", "canceladas"

## 💬 Exemplos de Perguntas

### Exemplo 1: Contar O.S Abertas

**Você pergunta**: "Quantas O.S abertas eu tenho no OPUS Manutenção?"

**O que acontece**:
1. AI entende "abertas" como termo válido
2. Chama função: `queryWorkOrdersCount({ status: "abertas" })`
3. Sistema mapeia: "abertas" → `"aberta"` (valor do banco)
4. Consulta: `SELECT ... WHERE status = 'aberta' AND companyId = 'seu-id' AND module = 'maintenance'`
5. AI responde: "Você tem 5 ordens de serviço abertas no OPUS Manutenção."

### Exemplo 2: Listar O.S Ativas

**Você pergunta**: "Quais são minhas O.S ativas?"

**O que acontece**:
1. AI entende "ativas" como "em execução"
2. Chama função: `queryWorkOrdersList({ status: "ativas" })`
3. Sistema mapeia: "ativas" → `"em_execucao"`
4. Consulta: `SELECT ... WHERE status = 'em_execucao' ...`
5. AI responde com lista detalhada:
   ```
   Você tem 3 ordens de serviço ativas:
   - OS #123: Manutenção do elevador (Alta prioridade)
   - OS #124: Troca de filtros (Média prioridade)
   - OS #125: Inspeção elétrica (Baixa prioridade)
   ```

### Exemplo 3: O.S Finalizadas

**Você pergunta**: "Quantas O.S eu finalizei hoje?"

**O que acontece**:
1. AI entende "finalizei" como "concluídas"
2. Calcula data de hoje
3. Chama função: `queryWorkOrdersCount({ status: "finalizadas", dateFrom: "2024-11-08", dateTo: "2024-11-08" })`
4. Sistema mapeia: "finalizadas" → `"concluida"`
5. Consulta com filtros de data
6. AI responde: "Você finalizou 8 ordens de serviço hoje."

### Exemplo 4: O.S Atrasadas

**Você pergunta**: "Tenho O.S atrasadas?"

**O que acontece**:
1. AI entende "atrasadas" como "vencidas"
2. Chama função: `queryWorkOrdersCount({ status: "atrasadas" })`
3. Sistema mapeia: "atrasadas" → `"vencida"`
4. Consulta no banco
5. AI responde: "Sim, você tem 2 ordens de serviço atrasadas. Deseja ver quais são?"

## 🔧 Como Funciona Tecnicamente

### 1. Função de Mapeamento

```typescript
private mapStatusTerm(term: string | undefined): string | undefined {
  if (!term) return undefined;

  const normalizedTerm = term.toLowerCase().trim();
  
  const statusMap: Record<string, string> = {
    'abertas': 'aberta',
    'ativas': 'em_execucao',
    'concluídas': 'concluida',
    // ... mais mapeamentos
  };

  return statusMap[normalizedTerm] || term;
}
```

### 2. Aplicação nas Consultas

Antes de consultar o banco, o status é mapeado:

```typescript
// Na função aiQueryWorkOrdersCount
const mappedStatus = this.mapStatusTerm(filters?.status);
if (mappedStatus) {
  conditions.push(eq(workOrders.status, mappedStatus as any));
}
```

### 3. Documentação para o AI

As tools do Google Gemini foram documentadas para aceitar termos naturais:

```typescript
{
  name: 'queryWorkOrdersCount',
  description: 'Conta o número de ordens de serviço...',
  parameters: {
    status: {
      type: 'string',
      description: 'Aceita termos naturais: "abertas", "ativas", "concluídas", etc.'
    }
  }
}
```

## ✅ Validação de Segurança

**GARANTIA**: O mapeamento NÃO afeta a segurança. Todas as consultas ainda são filtradas por:

1. ✅ **Cliente ativo** (`customerId`) - sempre filtrado
2. ✅ **Módulo ativo** (`module: 'clean' | 'maintenance'`) - sempre filtrado
3. ✅ **Status mapeado** - convertido para valor válido do banco

**Fluxo de Segurança**:
```
Pergunta: "Quantas O.S abertas?"
    ↓
Mapeamento: "abertas" → "aberta"
    ↓
Query: WHERE companyId = 'cliente-ativo' 
       AND module = 'modulo-ativo'
       AND status = 'aberta'
    ↓
Resultado: APENAS dados do cliente ativo
```

## 🧪 Como Testar

### Teste 1: Termos Naturais

Pergunte ao AI usando linguagem coloquial:
- ✅ "Quantas O.S abertas eu tenho?"
- ✅ "Mostre minhas O.S ativas"
- ✅ "Tenho O.S atrasadas?"
- ✅ "Quantas O.S eu finalizei esta semana?"

### Teste 2: Variações de Termos

Teste variações masculino/feminino:
- ✅ "O.S aberto" (mapeia para `aberta`)
- ✅ "O.S abertos" (mapeia para `aberta`)
- ✅ "O.S abertas" (mapeia para `aberta`)

### Teste 3: Sinônimos

Teste diferentes formas de dizer a mesma coisa:
- ✅ "O.S concluídas" / "O.S finalizadas" / "O.S completas" (todos mapeiam para `concluida`)
- ✅ "O.S ativas" / "O.S em andamento" / "O.S executando" (todos mapeiam para `em_execucao`)

### Teste 4: Segurança

Mude de cliente e pergunte a mesma coisa. Deve retornar dados diferentes:

1. **Cliente A**: "Quantas O.S abertas?" → Resposta: "5 O.S abertas"
2. **Mude para Cliente B**
3. **Cliente B**: "Quantas O.S abertas?" → Resposta: "2 O.S abertas"

Cada cliente vê apenas seus próprios dados.

## 🚀 Benefícios

### Para o Usuário
- ✅ Conversa natural com o AI (não precisa decorar termos técnicos)
- ✅ Aceita variações (masculino/feminino, sinônimos)
- ✅ Respostas precisas baseadas em dados reais do banco

### Para o Sistema
- ✅ Mantém integridade do banco (valores enum consistentes)
- ✅ Segurança preservada (filtros de cliente sempre aplicados)
- ✅ Extensível (fácil adicionar novos sinônimos)

## 📝 Adicionando Novos Termos

Se você quiser adicionar novos termos coloquiais que os usuários usam, edite a função `mapStatusTerm` em `server/storage.ts`:

```typescript
const statusMap: Record<string, string> = {
  // ... mapeamentos existentes
  
  // Adicione novo termo aqui:
  'novo_termo': 'aberta', // mapeia para o valor do banco
};
```

**Importante**: Sempre mapeie para um dos valores válidos do banco:
- `aberta`
- `em_execucao`
- `pausada`
- `vencida`
- `concluida`
- `cancelada`

## 🐛 Troubleshooting

### AI não entende um termo específico

**Solução**: Adicione o termo na função `mapStatusTerm`.

Exemplo: Se usuários dizem "em espera" para status "pausada":

```typescript
'em espera': 'pausada',
```

### Retorna 0 resultados mas deveria ter dados

**Possíveis causas**:
1. **Termo não mapeado**: Adicione o termo ao mapeamento
2. **Cliente sem dados**: Verifique se o cliente realmente tem O.S nesse status
3. **Módulo errado**: Certifique-se de estar no módulo correto (Clean vs Manutenção)

**Debug**:
```
Pergunta: "Quantas O.S [TERMO] eu tenho?"
Verifique nos logs do servidor:
- Qual termo foi enviado?
- Para qual valor do banco foi mapeado?
- A query foi executada com filtros corretos?
```

### AI pede para escolher opções ao invés de mapear

**Causa**: API key com rate limit ou modelo antigo.

**Solução**:
1. Verifique se a API key está funcionando
2. Use modelo `gemini-2.0-flash-exp` ou superior (suporta function calling)

## 📚 Documentação Relacionada

- [AI_INTEGRATION_GUIDE.md](./AI_INTEGRATION_GUIDE.md) - Como configurar API keys
- [AI_FUNCTION_CALLING_GUIDE.md](./AI_FUNCTION_CALLING_GUIDE.md) - Como funciona o function calling
- [shared/schema.ts](./shared/schema.ts) - Definição dos enum de status no banco

---

**Última atualização**: 08/11/2024
**Implementado em**: OPUS v2.0 (Clean + Manutenção)
**Status**: ✅ Funcional e testado
**Aprovado por**: Architect Agent
