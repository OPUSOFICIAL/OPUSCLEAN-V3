# OPUS - Documento Técnico Comercial
## Plataforma Modular de Gestão de Facilities

---

## 📋 Visão Geral

**OPUS** é uma plataforma completa e modular para gestão de facilities, oferecendo soluções especializadas para **limpeza** e **manutenção predial**. O sistema combina tecnologia web e mobile para otimizar operações, aumentar produtividade e garantir qualidade de serviço.

### Diferenciais Principais
- ✅ **Multi-tenancy completo** - Gerenciamento de múltiplas empresas e clientes em uma única plataforma
- ✅ **Arquitetura modular** - OPUS Clean e OPUS Manutenção trabalham de forma independente ou integrada
- ✅ **Web + Mobile** - Interface administrativa web e aplicativos mobile para operadores
- ✅ **QR Code inteligente** - Gestão de tarefas e solicitações públicas através de QR codes
- ✅ **Analytics em tempo real** - Dashboards e relatórios com dados atualizados automaticamente
- ✅ **Sistema de permissões granular** - Controle de acesso baseado em funções customizáveis

---

## 🏢 Estrutura Hierárquica

O OPUS implementa uma hierarquia organizacional completa:

```
OPUS (Sistema)
├── Empresas (Company)
│   └── Clientes (Customers)
│       ├── Locais (Sites)
│       │   └── Zonas (Zones)
│       ├── Usuários
│       ├── Equipamentos
│       └── Configurações
```

### Níveis de Acesso
1. **Administrador OPUS** - Gestão completa do sistema
2. **Gestor de Cliente** - Gestão de um cliente específico
3. **Supervisor de Local** - Supervisão de locais específicos
4. **Operador** - Execução de tarefas de campo
5. **Auditor** - Visualização de relatórios e logs

---

## 🧹 OPUS Clean - Módulo de Limpeza

### Funcionalidades Principais

#### 1. **Gestão de Atividades de Limpeza**
- Criação de atividades de limpeza com frequências customizadas:
  - Diária, Semanal, Quinzenal, Mensal
  - Por turnos (Manhã, Tarde, Noite)
  - Configuração de dias específicos da semana
- Seleção de múltiplos locais e zonas por atividade
- Geração automática de ordens de serviço programadas

**Cenário de uso**: Uma empresa de limpeza pode criar uma atividade "Limpeza de Banheiros" para ser executada 3x ao dia (manhã, tarde, noite) em 15 andares diferentes, gerando automaticamente as ordens de serviço.

#### 2. **Sistema de Checklists Digitais**
- Criação de templates de checklist customizáveis
- Categorização por tipo de serviço
- Campos de verificação com opções sim/não
- Campos de observação para detalhes adicionais
- Anexo de fotos nas respostas
- **Mobile**: Execução de checklists offline com sincronização automática

**Cenário de uso**: Supervisor cria checklist "Inspeção de Área Comum" com 20 itens de verificação. Operador executa pelo celular, tira fotos de não conformidades e sincroniza ao final.

#### 3. **Ordens de Serviço (Work Orders)**
- **3 tipos de OS**:
  1. **Programadas** - Geradas automaticamente pelas atividades de limpeza
  2. **Corretivas Internas** - Criadas por gestores/supervisores
  3. **Corretivas Públicas** - Solicitadas por usuários finais via QR code

- **Gestão completa**:
  - Atribuição de operadores
  - Controle de prioridade (Baixa, Média, Alta, Urgente)
  - Acompanhamento de SLA (tempo de resposta e resolução)
  - Status em tempo real (Pendente, Em Execução, Concluída, Cancelada)
  - Histórico de comentários com fotos
  - Possibilidade de reabertura

**Cenário de uso**: Sistema gera automaticamente 200 OS de limpeza diária. Gestor distribui entre 10 operadores. Cada operador vê apenas suas tarefas no celular e atualiza status em tempo real.

#### 4. **QR Codes para Gestão de Locais**

##### **QR de Execução** (Interno)
- Operador escaneia QR code no local
- Sistema carrega automaticamente a OS associada
- Executa checklist diretamente
- Registra fotos de antes/depois
- Finaliza tarefa com timestamp e geolocalização

##### **QR Público** (Solicitações Externas)
- Usuário final escaneia QR code público
- Abre formulário simplificado sem login
- Descreve o problema + anexa foto
- Sistema gera OS corretiva automaticamente
- Cliente recebe número de protocolo para acompanhamento

**Cenário de uso**: Shopping instala QR codes públicos nos banheiros. Cliente final escaneia, reporta "papel higiênico acabou", anexa foto. Sistema gera OS urgente e notifica supervisor em 30 segundos.

#### 5. **Configuração de SLA**
- Definição de tempos de resposta e resolução por:
  - Tipo de serviço
  - Prioridade
  - Turno de atendimento
- Alertas automáticos de vencimento
- Penalizações configuráveis
- Relatórios de compliance

**Cenário de uso**: Contrato define que OS urgentes devem ter resposta em 30min e resolução em 2h. Sistema alerta automaticamente supervisor quando prazo está próximo de vencer.

#### 6. **Dashboards e Analytics**
- **Visão gerencial**:
  - Total de OS (pendentes, em execução, concluídas)
  - Distribuição por prioridade
  - Performance por local/zona
  - Tempo médio de conclusão
  - Taxa de conformidade com SLA
  - Atividades por período

- **Gráficos interativos**:
  - Distribuição por status
  - Tendências temporais
  - Análise de produtividade
  - Heatmap de ocorrências

**Cenário de uso**: Gestor acessa dashboard e identifica que Bloco A tem 3x mais solicitações que Bloco B no último mês, permitindo remanejamento de equipe.

#### 7. **Relatórios Avançados**
- Relatório de Work Orders (filtros personalizados)
- Performance de operadores
- Análise de SLA
- Relatórios de produtividade
- Análise temporal
- Análise por localização
- **Exportação**: PDF, Excel, CSV

---

## 🔧 OPUS Manutenção - Módulo de Manutenção Predial

### Funcionalidades Principais

#### 1. **Cadastro de Equipamentos**
- Registro completo de ativos:
  - Identificação (nome, código, tipo)
  - Localização (local + zona)
  - Especificações técnicas
  - Fabricante e modelo
  - Data de instalação
  - Documentos anexos (manuais, certificados)
- Histórico completo de manutenções
- Status operacional em tempo real

**Cenário de uso**: Empresa registra 500 equipamentos de ar-condicionado com localizações exatas, permitindo rastreamento completo do histórico de manutenção de cada unidade.

#### 2. **Planos de Manutenção Preventiva**
- **Criação de planos automatizados**:
  - Frequências: Diária, Semanal, Mensal, Trimestral, Semestral, Anual
  - Seleção de múltiplos equipamentos
  - Vinculação com checklists específicos
  - Ativação/desativação de atividades

- **Geração automática de OS**:
  - Sistema gera OS preventivas no último dia de cada mês
  - Calendário visual mostra todas as atividades futuras
  - Previsão de demanda para próximos meses

**Cenário de uso**: Plano de manutenção "Revisão Trimestral de Ar-Condicionado" é criado para 100 equipamentos. Sistema gera automaticamente 100 OS preventivas a cada 3 meses, distribuídas ao longo do período.

#### 3. **Checklists de Manutenção**
- Templates específicos por tipo de equipamento
- Itens de verificação técnicos
- Campos para medições (temperatura, pressão, etc)
- Registro de peças substituídas
- Evidências fotográficas obrigatórias
- Assinatura digital do técnico

**Cenário de uso**: Checklist "Manutenção Preventiva Elevador" com 30 itens técnicos. Técnico preenche pelo celular, registra medições, anexa fotos e assina digitalmente.

#### 4. **Gestão de Work Orders de Manutenção**
- **Tipos**:
  1. **Preventivas** - Geradas pelos planos de manutenção
  2. **Corretivas Internas** - Criadas por gestores
  3. **Corretivas Públicas** - Solicitadas via QR code

- **Recursos específicos**:
  - Vinculação com equipamento
  - Histórico de manutenções do equipamento
  - Registro de peças utilizadas
  - Tempo de parada do equipamento
  - Custo de manutenção
  - Garantia aplicada

**Cenário de uso**: Elevador apresenta defeito. Sistema mostra histórico completo de manutenções anteriores. Técnico registra peças trocadas, tempo de reparo (3h) e custo (R$ 2.500), tudo vinculado ao equipamento.

#### 5. **Calendário de Manutenções**
- **Visualização integrada**:
  - Todas as atividades preventivas futuras
  - Codificação por cores (frequência)
  - Filtros por equipamento, local, tipo
  - Visão mensal/trimestral/anual

**Cenário de uso**: Gestor visualiza calendário anual e identifica que março terá 150 manutenções programadas vs 50 em abril, permitindo melhor planejamento de equipe.

#### 6. **Dashboard de Manutenção**
- Estatísticas em tempo real:
  - Total de equipamentos por status
  - OS preventivas vs corretivas
  - Taxa de conformidade com planos
  - Equipamentos críticos (muitas manutenções)
  - Tempo médio de reparo
  - Custos de manutenção por período

#### 7. **Gerenciamento de Atividades**
- Modal interativo mostrando todas as atividades ativas
- Ativação/desativação rápida de atividades
- Visualização de equipamentos por atividade
- Controle de geração automática de OS

**Cenário de uso**: Gestor identifica que atividade "Revisão Mensal Gerador" está inativa. Com 1 clique, reativa a atividade e sistema volta a gerar OS automaticamente.

---

## 📱 Aplicativo Mobile - Operador/Técnico

### Funcionalidades Mobile

#### 1. **Dashboard Pessoal**
- Minhas OS (pendentes, em execução)
- Indicador visual de OS em execução (card verde destacado)
- Contadores de tarefas
- Acesso rápido por prioridade
- Notificações push

#### 2. **Execução de Tarefas**
- Scanner QR code integrado
- Checklists digitais offline
- Câmera para evidências
- Comentários com fotos
- Início/pausa/conclusão de tarefas
- Sincronização automática

#### 3. **Pull-to-Refresh**
- Atualização rápida de dados
- Sincronização de novas OS
- Atualização de status

#### 4. **Modo Offline**
- Execução de checklists sem internet
- Armazenamento local de fotos
- Sincronização automática ao conectar

---

## 🎯 Recursos Avançados do Sistema

### 1. **Autenticação Flexível**
- Login tradicional (usuário + senha)
- **Microsoft SSO** (Single Sign-On via Entra ID)
- Tokens JWT seguros
- Controle de sessão

### 2. **Sistema de Permissões Granular**
- 5 roles base predefinidos
- Custom roles com permissões específicas
- 40+ permissões granulares:
  - Visualizar/Criar/Editar/Deletar por módulo
  - Gerenciar usuários
  - Acessar relatórios
  - Configurações avançadas
- Mapeamento automático para roles efetivos

### 3. **Auditoria Completa**
- Registro de todas as ações no sistema
- Logs de criação/edição/exclusão
- Rastreamento de mudanças
- Histórico de comentários em OS
- Exportação de logs para compliance

### 4. **Multi-módulo por Usuário**
- Usuários podem ter acesso a:
  - Apenas OPUS Clean
  - Apenas OPUS Manutenção
  - Ambos os módulos
- Troca de módulo instantânea
- Dados isolados por módulo

### 5. **Isolamento de Dados por Cliente**
- Cada cliente vê apenas seus dados
- Isolamento completo entre clientes
- Sites, zonas, equipamentos e usuários segregados
- Segurança multi-camadas

### 6. **Numeração Independente por Cliente**
- Cada cliente tem sequência própria de OS (1, 2, 3...)
- Facilita identificação interna do cliente
- Evita confusão com numeração global

### 7. **Webhooks e Integrações**
- Configuração de webhooks por evento
- Integração com sistemas externos
- API REST completa
- Notificações em tempo real

### 8. **Metas e KPIs**
- Definição de metas por cliente
- Acompanhamento de performance
- Alertas de desvios
- Relatórios de cumprimento

### 9. **Chat AI Integrado** (Opcional)
- Assistente virtual para gestores
- Consultas em linguagem natural
- Análise de dados por IA
- Sugestões automáticas

---

## 📊 Relatórios e Analytics

### Tipos de Relatórios

#### 1. **Relatório de Work Orders**
- Filtros avançados (período, status, prioridade, local, operador)
- Detalhamento completo de cada OS
- Tempo de execução
- Evidências fotográficas
- Exportação PDF/Excel

#### 2. **Performance de Operadores**
- Total de OS por operador
- Taxa de conclusão
- Tempo médio de execução
- Conformidade com SLA
- Ranking de performance

#### 3. **Análise de SLA**
- Compliance geral
- OS dentro/fora do prazo
- Tempo médio de resposta
- Tempo médio de resolução
- Penalizações aplicadas

#### 4. **Relatório Temporal**
- Distribuição de OS por período
- Tendências mensais/trimestrais
- Sazonalidade
- Previsão de demanda

#### 5. **Análise por Localização**
- Heatmap de ocorrências
- Comparação entre locais
- Zonas críticas
- Distribuição geográfica

#### 6. **Relatório de Produtividade**
- Horas trabalhadas
- OS por hora
- Eficiência operacional
- Ociosidade

#### 7. **Relatório de Equipamentos** (Manutenção)
- Status de todos os equipamentos
- Histórico de manutenções
- Custos por equipamento
- Equipamentos críticos (alta frequência de manutenção)
- Vida útil restante

---

## 🔐 Segurança e Compliance

### Medidas de Segurança
- ✅ Criptografia de senhas (Bcrypt)
- ✅ Tokens JWT com expiração
- ✅ Rate limiting (proteção contra ataques)
- ✅ Sanitização de dados
- ✅ CORS configurado
- ✅ Headers de segurança (Helmet.js)
- ✅ Prevenção de SQL injection
- ✅ Validação de entrada (Zod schemas)

### Auditoria e Rastreabilidade
- ✅ Logs de todas as ações
- ✅ Timestamps em todas as operações
- ✅ Histórico de modificações
- ✅ Registro de login/logout
- ✅ Rastreamento de geolocalização (mobile)

---

## 💡 Casos de Uso Reais

### Caso 1: Shopping Center - Limpeza
**Desafio**: Gerenciar limpeza de 200 áreas diferentes, 3 turnos/dia, com SLA rigoroso

**Solução OPUS Clean**:
- 15 atividades de limpeza criadas (banheiros, praça de alimentação, corredores, etc)
- 600 OS geradas automaticamente por dia
- 30 operadores com aplicativo mobile
- QR codes públicos em 50 pontos estratégicos
- Dashboard gerencial em tempo real
- Relatórios de SLA automáticos

**Resultado**: Redução de 40% no tempo de resposta, 95% de compliance com SLA

### Caso 2: Condomínio Empresarial - Manutenção
**Desafio**: Manter 300 equipamentos (elevadores, ar-condicionado, geradores) com manutenção preventiva rigorosa

**Solução OPUS Manutenção**:
- 300 equipamentos cadastrados
- 12 planos de manutenção preventiva (frequências variadas)
- 150 OS preventivas/mês geradas automaticamente
- Checklists técnicos específicos por equipamento
- Histórico completo de manutenções
- Calendário anual de atividades

**Resultado**: Redução de 60% em manutenções corretivas, previsibilidade total de custos

### Caso 3: Hospital - Clean + Manutenção Integrados
**Desafio**: Gestão integrada de limpeza hospitalar e manutenção de equipamentos críticos

**Solução OPUS Completo**:
- OPUS Clean para limpeza de 100 áreas (enfermarias, UTIs, centros cirúrgicos)
- OPUS Manutenção para 200 equipamentos médicos
- Controle rigoroso de SLA
- Rastreabilidade completa
- Relatórios para acreditação hospitalar

**Resultado**: 100% de rastreabilidade, compliance com normas sanitárias, redução de custos operacionais

---

## 🎥 Roteiro Sugerido para Vídeo Comercial

### Parte 1: Introdução (30 segundos)
- Apresentar OPUS como solução completa de facilities
- Destacar modularidade (Clean + Manutenção)
- Mostrar tela inicial do sistema

### Parte 2: OPUS Clean (2 minutos)
- Demonstrar criação de atividade de limpeza
- Mostrar geração automática de OS
- Simular operador escaneando QR code no celular
- Executar checklist digital com fotos
- Mostrar dashboard com analytics em tempo real
- Demonstrar QR público (usuário final reportando problema)

### Parte 3: OPUS Manutenção (2 minutos)
- Cadastrar equipamento
- Criar plano de manutenção preventiva
- Visualizar calendário anual de atividades
- Mostrar geração automática de OS preventivas
- Técnico executando checklist técnico no mobile
- Dashboard de equipamentos e custos

### Parte 4: Diferenciais (1 minuto)
- Multi-tenancy (múltiplos clientes em um sistema)
- QR codes inteligentes
- Analytics em tempo real
- Permissões granulares
- Mobile + Web integrados

### Parte 5: Resultados e CTA (30 segundos)
- Mostrar resultados reais (redução de custos, aumento de produtividade)
- Call-to-action para demonstração

---

## 🚀 Tecnologia e Infraestrutura

### Stack Tecnológico
- **Frontend**: React + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + TypeScript
- **Database**: PostgreSQL (Neon serverless)
- **Mobile**: Progressive Web App (PWA) - funciona como app nativo
- **Autenticação**: JWT + Microsoft Entra ID
- **ORM**: Drizzle (type-safe)
- **Hospedagem**: Cloud (Replit) com escalabilidade automática

### Escalabilidade
- ✅ Arquitetura serverless
- ✅ Database em cloud com backup automático
- ✅ CDN para assets estáticos
- ✅ Cache inteligente
- ✅ Suporta milhares de usuários simultâneos

---

## 📞 Próximos Passos

### Para o Cliente
1. **Demonstração ao vivo** - Agendar sessão de 30 minutos
2. **Trial gratuito** - 30 dias com suporte completo
3. **Implantação** - Onboarding em 2 semanas
4. **Treinamento** - Capacitação de equipe incluída

### Contato Comercial
- Solicitar demo personalizada
- Receber proposta comercial
- Agendar reunião técnica

---

## 📝 Observações Técnicas

### Customização
O sistema permite customizações específicas por cliente:
- Campos personalizados em checklists
- Categorias próprias de serviços
- Integrações com sistemas legados
- Relatórios customizados
- Workflows específicos

### Suporte
- Documentação técnica completa
- Suporte via chat/email
- Atualizações automáticas
- SLA de atendimento

---

**Versão do documento**: 1.0  
**Data**: Novembro 2024  
**Sistema**: OPUS v2.0 (Clean + Manutenção)
