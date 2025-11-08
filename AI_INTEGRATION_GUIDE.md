# Guia de Configuração de Integrações AI

Este guia explica como configurar e usar as integrações AI no sistema OPUS.

## 🔑 Como Obter API Keys

### Google Gemini (Recomendado - Gratuito)

**Vantagens**: Gratuito, fácil de configurar, modelo poderoso
**Limites**: 15 requisições por minuto (tier gratuito)

1. Acesse [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Faça login com sua conta Google
3. Clique em "Get API Key" ou "Create API Key"
4. Copie a API key gerada (formato: `AIzaSy...`)

**Modelos Disponíveis**:
- `gemini-2.0-flash-exp` (padrão, mais rápido)
- `gemini-1.5-pro` (mais preciso)
- `gemini-1.5-flash` (balanceado)

### OpenAI

**Vantagens**: Modelos mais avançados, alta confiabilidade
**Limites**: Pago, requer cartão de crédito

1. Acesse [OpenAI Platform](https://platform.openai.com/api-keys)
2. Crie uma conta e adicione créditos
3. Clique em "Create new secret key"
4. Copie a API key (formato: `sk-...`)

**Modelos Disponíveis**:
- `gpt-4o` (padrão, mais recente)
- `gpt-4o-mini` (mais barato)
- `gpt-3.5-turbo` (mais rápido e barato)

**Preços**:
- GPT-4o: $2.50 / 1M tokens entrada, $10.00 / 1M tokens saída
- GPT-4o-mini: $0.15 / 1M tokens entrada, $0.60 / 1M tokens saída

### Anthropic Claude

**Vantagens**: Respostas detalhadas, boa para análise
**Limites**: Pago, requer verificação

1. Acesse [Anthropic Console](https://console.anthropic.com/)
2. Crie uma conta e configure pagamento
3. Vá em "API Keys" e clique em "Create Key"
4. Copie a API key (formato: `sk-ant-...`)

**Modelos Disponíveis**:
- `claude-3-5-sonnet-20241022` (padrão, mais recente)
- `claude-3-opus-20240229` (mais poderoso)
- `claude-3-haiku-20240307` (mais rápido e barato)

## ⚙️ Configuração no OPUS

### 1. Acessar Integrações AI

1. Faça login como administrador
2. Vá em **Configurações** > **Integrações AI**
3. Clique em **"+ Nova Integração"**

### 2. Preencher Formulário

**Campos obrigatórios**:
- **Nome**: Nome descritivo (ex: "Gemini Principal", "GPT-4 Produção")
- **Provedor**: Selecione o provedor (Google, OpenAI, Anthropic)
- **API Key**: Cole a chave API obtida
- **Modelo**: Nome do modelo (deixe vazio para usar o padrão)

**Campos opcionais**:
- **Temperatura**: 0.0 a 1.0 (padrão: 0.7)
  - Valores baixos (0.1-0.3): Respostas mais precisas e determinísticas
  - Valores altos (0.7-1.0): Respostas mais criativas e variadas
- **Max Tokens**: Limite de tokens na resposta (padrão: 500)
- **Status**: Ativa ou Inativa
- **Padrão**: Marque se esta deve ser a integração padrão para o chat

### 3. Testar Integração

Após salvar, clique em **"Testar"** para verificar se a configuração está correta.

**Mensagens de erro comuns**:
- ❌ "API key inválida": Verifique se copiou a key corretamente
- ❌ "Limite de requisições atingido": Aguarde alguns minutos ou use uma key com mais cota
- ❌ "Modelo não encontrado": Verifique o nome do modelo
- ✅ "Teste realizado com sucesso": Configuração OK!

## 💬 Usando o Chat AI

### Como Acessar

1. Clique no ícone de chat no canto inferior direito (💬)
2. Digite sua pergunta em português
3. O assistente responderá com base no contexto do módulo ativo (OPUS Clean ou OPUS Manutenção)

### Exemplos de Perguntas

**Ordens de Serviço**:
- "Quantas O.S eu tenho para hoje?"
- "Quais são minhas tarefas pendentes?"
- "Mostre o status das minhas ordens de serviço"

**Análises**:
- "Como está minha performance nesta semana?"
- "Quantas O.S eu completei este mês?"
- "Tenho alguma O.S atrasada?"

**Informações Gerais**:
- "Como funciona o sistema de checklist?"
- "O que significa SLA?"
- "Como eu marco uma tarefa como concluída?"

### Contexto Automático

O assistente tem acesso automático a:
- ✅ Suas ordens de serviço do dia
- ✅ Módulo ativo (Clean ou Manutenção)
- ✅ Data atual
- ✅ Estatísticas básicas

## 🔧 Solução de Problemas

### Chat não responde

1. **Verifique se há uma integração padrão ativa**
   - Vá em Integrações AI
   - Certifique-se de que uma integração está marcada como "Padrão" e "Ativa"

2. **Teste a integração**
   - Clique em "Testar" na integração
   - Corrija erros se houver

3. **Verifique o saldo/cota da API**
   - Google Gemini: Limite de 15 req/min no tier gratuito
   - OpenAI: Verifique saldo em [platform.openai.com/usage](https://platform.openai.com/usage)
   - Anthropic: Verifique créditos no console

### Mensagens de erro detalhadas

O chat agora exibe erros detalhados quando algo dá errado:
- **Background vermelho**: Indica erro na resposta
- **Seção "Detalhes do erro"**: Mostra informação técnica e orientações

### Limites de taxa (Rate Limits)

**Google Gemini (Gratuito)**:
- 15 requisições por minuto
- 1,500 requisições por dia
- **Solução**: Aguarde alguns minutos ou crie uma conta paga

**OpenAI**:
- Varia por tier e modelo
- Novos usuários: ~3 req/min
- **Solução**: Upgrade para tier superior

**Anthropic**:
- Varia por plano
- **Solução**: Verifique plano no console

## 📊 Melhores Práticas

### Escolha do Provedor

**Para produção (uso intenso)**:
- OpenAI GPT-4o-mini (melhor custo-benefício)
- Anthropic Claude Haiku (rápido e barato)

**Para testes e desenvolvimento**:
- Google Gemini gratuito (ideal para começar)

**Para análises complexas**:
- OpenAI GPT-4o (mais preciso)
- Anthropic Claude Sonnet (respostas detalhadas)

### Múltiplas Integrações

Você pode configurar múltiplas integrações e alternar entre elas:

1. Configure uma integração principal (padrão)
2. Configure backups com outros provedores
3. Altere a integração padrão conforme necessário

### Segurança

✅ **As API keys são criptografadas no banco de dados**
✅ Cada empresa tem suas próprias integrações isoladas
✅ As keys nunca são expostas na interface (mascaradas como `****abc`)

## 🆘 Suporte

Se você tiver problemas:

1. Verifique este guia primeiro
2. Teste a integração na página de Integrações AI
3. Verifique as mensagens de erro detalhadas no chat
4. Entre em contato com o suporte técnico da OPUS

---

**Última atualização**: 08/11/2024
**Versão do sistema**: OPUS v2.0 (Clean + Manutenção)
