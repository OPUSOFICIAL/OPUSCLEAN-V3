# Guia de Function Calling - Chat AI

Este documento explica como funciona o sistema de **function calling** (chamada de funções) implementado no chat AI do OPUS.

## 🎯 Objetivo

Permitir que o assistente AI faça **consultas reais ao banco de dados** para responder perguntas com dados exatos, como:
- "Quantas O.S ativas eu tenho?"
- "Quais são minhas O.S pendentes?"
- "Mostre O.S concluídas esta semana"

## 🔒 Segurança Crítica

**TODAS as consultas são automaticamente filtradas pelo cliente ativo (`customerId`)**.

✅ **Garantias de Segurança**:
- O AI só acessa dados do cliente ativo (recebido do contexto do usuário logado)
- Impossível acessar dados de outros clientes
- Todas as funções de consulta filtram por `customerId` e `module` (clean ou maintenance)
- Validado pelo Architect Agent

## 🏗️ Arquitetura

### 1. Funções de Consulta Internas

Localizadas em `server/storage.ts`, estas funções são chamadas internamente pelo AI:

#### `aiQueryWorkOrdersCount(customerId, module, filters)`

Conta ordens de serviço com filtros opcionais.

**Parâmetros**:
```typescript
{
  status?: 'pendente' | 'em_execucao' | 'concluida' | 'atrasada' | 'cancelada',
  type?: 'programada' | 'corretiva_interna' | 'corretiva_publica',
  priority?: 'baixa' | 'media' | 'alta',
  dateFrom?: 'YYYY-MM-DD',
  dateTo?: 'YYYY-MM-DD'
}
```

**Retorna**:
```typescript
{
  count: number,
  breakdown: {
    byStatus: { 
      pendente: 5, 
      em_execucao: 2,
      concluida: 10 
    },
    total: 17
  }
}
```

#### `aiQueryWorkOrdersList(customerId, module, filters)`

Lista ordens de serviço com detalhes.

**Parâmetros**:
```typescript
{
  status?: string,
  limit?: number, // padrão: 20
  userId?: string
}
```

**Retorna**:
```typescript
[
  {
    id: string,
    number: number,
    title: string,
    status: string,
    priority: string,
    type: string,
    scheduledDate: string,
    completedAt: string | null
  }
]
```

### 2. System Function Calling

O AI decide quando chamar essas funções baseado na pergunta do usuário.

**Fluxo de Execução**:

```
1. Usuário: "Quantas O.S ativas eu tenho?"
   ↓
2. AI analisa e decide chamar função: queryWorkOrdersCount({ status: 'em_execucao' })
   ↓
3. Sistema executa: aiQueryWorkOrdersCount(customerId, module, { status: 'em_execucao' })
   ↓
4. Retorna resultado: { count: 3, breakdown: {...} }
   ↓
5. AI formula resposta: "Você tem 3 ordens de serviço ativas no momento."
```

### 3. Definição de Tools (Google Gemini)

As ferramentas são definidas no método `callAI` e enviadas ao Gemini:

```typescript
const tools = [{
  functionDeclarations: [{
    name: 'queryWorkOrdersCount',
    description: 'Conta o número de ordens de serviço (O.S) com base em filtros.',
    parameters: {
      type: 'object',
      properties: {
        status: { 
          type: 'string', 
          enum: ['pendente', 'em_execucao', 'concluida', 'atrasada', 'cancelada'] 
        }
        // ... outros parâmetros
      }
    }
  }]
}];
```

### 4. Loop de Interação

O sistema permite até 3 iterações (configurável) para chamadas de função:

```typescript
for (let iteration = 0; iteration < maxIterations; iteration++) {
  // 1. Envia mensagem para AI com tools disponíveis
  const response = await fetch(geminiApiUrl, {
    body: JSON.stringify({ contents: messages, tools })
  });

  // 2. Verifica se AI quer chamar uma função
  if (response.contains.functionCall) {
    // 3. Executa a função
    const result = await this.aiQueryWorkOrdersCount(...);
    
    // 4. Adiciona resultado às mensagens
    messages.push({ role: 'model', parts: [...] });
    messages.push({ role: 'function', parts: [{ functionResponse: {...} }] });
    
    // 5. Loop continua - AI processa resultado e responde
  } else {
    // 6. AI retornou texto final
    return response.text;
  }
}
```

## 📊 Exemplos de Uso

### Exemplo 1: Contar O.S Ativas

**Pergunta**: "Quantas O.S ativas eu tenho no OPUS Manutenção?"

**Processo**:
1. AI chama: `queryWorkOrdersCount({ status: 'em_execucao' })`
2. Sistema executa: Busca no banco filtrando por `customerId` + `module: 'maintenance'` + `status: 'em_execucao'`
3. Resultado: `{ count: 3, breakdown: {...} }`
4. AI responde: "Você tem 3 ordens de serviço ativas no OPUS Manutenção."

### Exemplo 2: Listar O.S Pendentes

**Pergunta**: "Quais são minhas O.S pendentes?"

**Processo**:
1. AI chama: `queryWorkOrdersList({ status: 'pendente', limit: 10 })`
2. Sistema executa: Busca no banco filtrando por `customerId` + `module` + `status: 'pendente'`
3. Resultado: Lista de O.S
4. AI responde: "Você tem as seguintes O.S pendentes:\n- OS #123: Limpeza Sala A\n- OS #124: Manutenção Elevador..."

### Exemplo 3: Perguntas Complexas

**Pergunta**: "Quantas O.S eu completei esta semana?"

**Processo**:
1. AI chama: `queryWorkOrdersCount({ status: 'concluida', dateFrom: '2024-11-04', dateTo: '2024-11-08' })`
2. Sistema executa: Busca no banco com filtros de data
3. Resultado: `{ count: 15, breakdown: {...} }`
4. AI responde: "Você completou 15 ordens de serviço esta semana."

## 🔐 Validação de Segurança

### Como Garantimos Segurança?

1. **Filtro Automático por Cliente**:
```typescript
let conditions = [
  eq(workOrders.companyId, customerId), // ← SEMPRE filtrado
  eq(workOrders.module, module)           // ← SEMPRE filtrado
];
```

2. **Contexto Protegido**:
```typescript
const context = await this.getContextForAI(userId, customerId, module);
// customerId vem do req.user (autenticado)
```

3. **Sem Rotas HTTP Expostas**:
- As funções de consulta são **privadas** (não são rotas HTTP)
- Só podem ser chamadas internamente pelo sistema de AI
- Impossível acessar via API externa

### Teste de Segurança

Para validar que não há vazamento de dados entre clientes:

1. Logue como Cliente A
2. Pergunte: "Quantas O.S ativas eu tenho?"
3. Resultado: Apenas O.S do Cliente A
4. Logue como Cliente B
5. Pergunte a mesma pergunta
6. Resultado: Apenas O.S do Cliente B

## 🚀 Próximos Passos (Futuro)

### Funções Adicionais Planejadas

- `aiQueryEquipmentStatus` - Status de equipamentos
- `aiQueryMaintenancePlans` - Planos de manutenção ativos
- `aiQueryChecklistsCompleted` - Checklists concluídos
- `aiQuerySLACompliance` - Compliance de SLA

### Suporte a Outros Provedores

Atualmente implementado apenas para **Google Gemini**.

**Para adicionar OpenAI**:
```typescript
case 'openai':
  // OpenAI também suporta function calling
  // Usar formato de 'functions' do OpenAI
```

**Para adicionar Anthropic**:
```typescript
case 'anthropic':
  // Anthropic também suporta tool use (similar)
  // Usar formato de 'tools' do Claude
```

## 🐛 Troubleshooting

### AI não está chamando funções

**Possíveis causas**:
1. **API key atingiu limite**: Aguarde ou use nova key
2. **Modelo não suporta tools**: Use `gemini-2.0-flash-exp` ou superior
3. **Descrição da função não está clara**: Atualize a descrição na definição de tools

### Respostas imprecisas

**Solução**: Verifique se a pergunta é clara. Exemplos bons:
- ✅ "Quantas O.S ativas eu tenho?"
- ✅ "Liste minhas O.S pendentes"
- ❌ "Como estão as coisas?" (muito vago)

### Erro: customerId is null

**Causa**: Usuário não tem cliente ativo configurado.

**Solução**: Certifique-se de que `req.user.customerId` está definido.

## 📚 Referências

- [Google Gemini Function Calling](https://ai.google.dev/docs/function_calling)
- [OpenAI Function Calling](https://platform.openai.com/docs/guides/function-calling)
- [Anthropic Tool Use](https://docs.anthropic.com/claude/docs/tool-use)

---

**Última atualização**: 08/11/2024
**Implementado em**: OPUS v2.0 (Clean + Manutenção)
**Status**: ✅ Funcional (Google Gemini)
