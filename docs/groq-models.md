# 🚀 Modelos Groq Disponíveis no OPUS

## ⚡ O que é Groq?

Groq é uma plataforma de IA ultra-rápida que usa **LPU (Language Processing Unit)** - tecnologia própria que é **10x mais rápida que GPUs tradicionais**. Oferece acesso **100% gratuito** aos modelos Llama 3 da Meta.

---

## 📋 Modelos Disponíveis

### 1. **llama-3-groq-8b-tool-use** ⭐ RECOMENDADO PARA FUNCTION CALLING

**Uso ideal:** Function calling, ferramentas administrativas, chatbots com ações

```json
{
  "model": "llama-3-groq-8b-tool-use",
  "messages": [...],
  "tools": [...],
  "temperature": 0.7,
  "max_tokens": 1500
}
```

**Vantagens:**
- ✅ Especializado em function calling
- ✅ Resposta ultra-rápida (~200 tokens/s)
- ✅ Excelente para automação
- ✅ Otimizado para chamadas de API e ferramentas
- ✅ 8B parâmetros (rápido e eficiente)

**Use quando:**
- Precisar chamar funções do sistema
- Automatizar tarefas administrativas
- Integrar com APIs e ferramentas
- Criar chatbots que executam ações

---

### 2. **llama-3.3-70b-versatile** 🎯 MODELO GERAL PODEROSO

**Uso ideal:** Conversação geral, análise complexa, tarefas que exigem raciocínio

```json
{
  "model": "llama-3.3-70b-versatile",
  "messages": [...],
  "temperature": 1,
  "max_tokens": 1024
}
```

**Vantagens:**
- ✅ 70B parâmetros (muito inteligente)
- ✅ Versátil para qualquer tarefa
- ✅ Melhor raciocínio e compreensão
- ✅ Excelente em português
- ✅ Ainda muito rápido (LPU)

**Use quando:**
- Precisar de respostas mais elaboradas
- Análise de dados complexos
- Conversação natural avançada
- Tarefas que exigem raciocínio profundo

---

### 3. **llama-3.1-70b-versatile**

**Uso ideal:** Alternativa estável ao 3.3

```json
{
  "model": "llama-3.1-70b-versatile",
  "messages": [...],
  "temperature": 1,
  "max_tokens": 1024
}
```

**Características:**
- 70B parâmetros
- Versão anterior mais estável
- Ótimo desempenho geral

---

### 4. **llama-3.1-8b-instant**

**Uso ideal:** Respostas instantâneas, casos de uso simples

```json
{
  "model": "llama-3.1-8b-instant",
  "messages": [...],
  "temperature": 1,
  "max_tokens": 1024
}
```

**Vantagens:**
- ✅ ULTRA RÁPIDO
- ✅ Ideal para respostas curtas
- ✅ Menor latência possível

**Use quando:**
- Precisar de respostas imediatas
- Tarefas simples de chat
- Alta frequência de requisições

---

### 5. **mixtral-8x7b-32768**

**Uso ideal:** Contexto longo, documentos grandes

```json
{
  "model": "mixtral-8x7b-32768",
  "messages": [...],
  "temperature": 1,
  "max_tokens": 1024
}
```

**Vantagens:**
- ✅ 32.768 tokens de contexto
- ✅ Modelo Mixture-of-Experts
- ✅ Ótimo para documentos longos

---

### 6. **gemma2-9b-it**

**Uso ideal:** Modelo do Google Gemma

```json
{
  "model": "gemma2-9b-it",
  "messages": [...],
  "temperature": 1,
  "max_tokens": 1024
}
```

**Características:**
- Modelo do Google
- 9B parâmetros
- Instruction-tuned

---

## 🎯 Qual Modelo Escolher?

### Para OPUS (Sistema Administrativo):

**1ª Opção: llama-3-groq-8b-tool-use** ⭐
- Function calling nativo
- Responde: "Quantas O.S foram concluídas?" com chamada de função
- Ultra-rápido
- **MELHOR PARA: Chat AI do OPUS**

**2ª Opção: llama-3.3-70b-versatile**
- Mais inteligente
- Melhor compreensão
- **MELHOR PARA: Análises complexas**

**3ª Opção: llama-3.1-8b-instant**
- Respostas simples instantâneas
- **MELHOR PARA: FAQ e perguntas rápidas**

---

## 🔧 Configuração no OPUS

### Passo 1: Obter API Key

1. Acesse: https://console.groq.com/keys
2. Faça login (gratuito)
3. Clique em **"Create API Key"**
4. Copie a chave (começa com `gsk_...`)

### Passo 2: Configurar no Sistema

1. Vá em **Integrações AI** (`/ai-integrations`)
2. Clique em **"Nova Integração AI"**
3. Preencha:
   - **Provedor:** Groq (Llama 3 Grátis)
   - **Nome:** Opus Cloud (ou qualquer nome)
   - **API Key:** Cole sua chave `gsk_...`
   - **Modelo:** `llama-3-groq-8b-tool-use` (recomendado)
   - **Definir como padrão:** ✅ Ativado

4. Clique em **"Testar"** para validar
5. Salve!

---

## 📊 Comparação Rápida

| Modelo | Parâmetros | Velocidade | Function Calling | Contexto | Uso Ideal |
|--------|-----------|-----------|-----------------|----------|-----------|
| **llama-3-groq-8b-tool-use** | 8B | ⚡⚡⚡ Ultra | ✅ Excelente | 8K | **Automação** |
| **llama-3.3-70b-versatile** | 70B | ⚡⚡ Muito | ⚠️ Básico | 8K | **Análise** |
| **llama-3.1-8b-instant** | 8B | ⚡⚡⚡ Ultra | ❌ Não | 8K | **FAQ** |
| **mixtral-8x7b-32768** | 8x7B | ⚡⚡ Muito | ⚠️ Básico | 32K | **Docs** |

---

## 💡 Exemplos de Uso no OPUS

### Function Calling (Recomendado)

**Usuário:** "Quantas O.S foram concluídas hoje?"

**LLM escolhe:** `llama-3-groq-8b-tool-use`
- Chama função `queryWorkOrdersCount()`
- Retorna: "Foram concluídas 15 O.S hoje!"

### Conversação Geral

**Usuário:** "Explique o que é SLA"

**LLM escolhe:** `llama-3.3-70b-versatile`
- Resposta completa e detalhada
- Melhor compreensão contextual

### Resposta Instantânea

**Usuário:** "Qual o horário agora?"

**LLM escolhe:** `llama-3.1-8b-instant`
- Resposta imediata
- Menor latência

---

## 🚀 Vantagens do Groq sobre outros providers

| Feature | Groq | Google Gemini Free | OpenAI |
|---------|------|-------------------|--------|
| **Custo** | 100% Grátis | 15 RPM limit | Pago |
| **Velocidade** | ⚡⚡⚡ Ultra (LPU) | ⚡ Normal | ⚡⚡ Rápido |
| **Function Calling** | ✅ Nativo | ✅ Sim | ✅ Sim |
| **Rate Limit** | Generoso | 🔴 15/min | 💰 Pago |
| **Latência** | <100ms | ~500ms | ~200ms |

---

## 📝 Notas Importantes

- **Grátis para sempre:** Groq é 100% gratuito
- **Sem cartão de crédito:** Não precisa cadastrar pagamento
- **Rate limits generosos:** Muito mais do que Google free tier
- **LPU Technology:** 10x mais rápido que GPUs tradicionais
- **Llama 3 oficial:** Modelos da Meta otimizados

---

## 🎓 Recursos Adicionais

- **Documentação oficial:** https://console.groq.com/docs
- **Playground:** https://console.groq.com/playground
- **Status:** https://status.groq.com/
- **Discord:** https://groq.com/discord

---

**Última atualização:** Novembro 2024
