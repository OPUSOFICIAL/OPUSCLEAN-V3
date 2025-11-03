# OPUS - Arquitetura do Sistema

## Visão Geral

OPUS é uma plataforma modular de gestão de facilities projetada para otimizar operações e aumentar a eficiência. O sistema oferece dois módulos principais: **OPUS Clean** para gestão de limpeza e **OPUS Manutenção** para gestão de manutenção, cada um com isolamento completo de dados e interface personalizada.

### Características Principais

- **Arquitetura Modular**: Dois módulos operacionais independentes com dados completamente isolados
- **Multi-Tenancy Hierárquico**: Suporte a múltiplas empresas, clientes e locais
- **Interface Web + Mobile**: Administração web completa e aplicativos móveis para operadores
- **Sistema de QR Codes**: Gestão de tarefas via QR codes e solicitações públicas de serviço
- **Analytics em Tempo Real**: Dashboards e relatórios alimentados por dados ao vivo do PostgreSQL

---

## Arquitetura Técnica

### Stack Tecnológico

#### Frontend
- **React 18** com TypeScript
- **Vite** para build e desenvolvimento
- **Wouter** para roteamento
- **TanStack Query v5** para gerenciamento de estado e cache
- **shadcn/ui** com Radix UI para componentes
- **Tailwind CSS** para estilização

#### Backend
- **Node.js** com Express.js
- **TypeScript** para type safety
- **Drizzle ORM** para acesso ao banco de dados
- **PostgreSQL** (Neon) como banco de dados principal

#### Segurança
- **JWT** para autenticação
- **Bcrypt** para hash de senhas
- **Helmet.js** para headers HTTP seguros
- **CORS** configurado
- **Rate Limiting** para proteção contra abuso
- **Microsoft Entra ID** para SSO corporativo

### Estrutura de Diretórios

```
/
├── client/                 # Frontend React
│   └── src/
│       ├── components/     # Componentes reutilizáveis
│       ├── contexts/       # Contextos React (Module, Client, Auth)
│       ├── pages/          # Páginas da aplicação
│       └── lib/            # Utilitários e configurações
├── server/                 # Backend Express
│   ├── index.ts           # Entry point
│   ├── routes.ts          # Rotas da API
│   ├── storage.ts         # Camada de dados
│   └── vite.ts            # Integração Vite
└── shared/
    └── schema.ts          # Schema Drizzle compartilhado
```

---

## Modelo de Dados e Multi-Tenancy

### Hierarquia Organizacional

```
Companies (Empresas)
    └── Customers (Clientes)
        └── Sites (Locais)
            └── Zones (Zonas)
                ├── Work Orders (Ordens de Serviço)
                ├── QR Code Points (Pontos QR)
                └── Equipment (Equipamentos)
```

### Isolamento por Módulo

**17 tabelas** implementam isolamento completo por módulo (`module: 'clean' | 'maintenance'`):

**Tabelas Principais**:
- `sites` - Locais com isolamento por módulo
- `zones` - Zonas associadas a locais do módulo
- `work_orders` - Ordens de serviço por módulo
- `qr_code_points` - Pontos QR por módulo
- `services` - Serviços disponíveis por módulo
- `cleaning_activities` - Atividades de limpeza (OPUS Clean)
- `dashboard_goals` - Metas do dashboard por módulo
- `service_types` - Tipos de serviço por módulo

**Tabelas de Configuração**:
- `service_categories` - Categorias de serviço por módulo
- `checklist_templates` - Templates de checklist por módulo
- `sla_configs` - Configurações de SLA por módulo
- `equipment` - Equipamentos por módulo
- `maintenance_checklist_templates` - Templates de manutenção
- `maintenance_plans` - Planos de manutenção

**Padrão de Filtragem em 3 Camadas**:
```typescript
// Exemplo: Buscar equipamentos do módulo
1. Filtrar Sites por module
2. Filtrar Zones por module (via Sites filtrados)
3. Filtrar Equipment por module (via Zones filtradas)
```

---

## Funcionalidades do Sistema

### 1. Gestão de Usuários e Autenticação

#### Métodos de Autenticação
- **Email/Senha**: Autenticação tradicional com Bcrypt
- **Microsoft SSO**: Integração com Entra ID para empresas

#### Sistema de Roles Personalizado
- **Roles Predefinidos**: Admin, Gestor Cliente, Supervisor Local, Operador, Auditor
- **Permissões Granulares**: Controle baseado em permissões por role
- **Acesso Mobile**: Indicador de quem pode acessar interface mobile
- **Roteamento Diferenciado**: Rotas específicas para web e mobile

#### Gerenciamento de Usuários
- CRUD completo de usuários
- Atribuição de múltiplos roles customizados
- Vinculação a empresas e clientes
- Indicadores visuais de roles e acesso mobile

### 2. Gestão Organizacional

#### Empresas (Companies)
- Gerenciamento de empresas no sistema
- Configurações e dados corporativos
- Associação de clientes

#### Clientes (Customers)
- Cadastro de clientes por empresa
- Dados de contato (CNPJ, email, telefone, endereço)
- Status ativo/inativo
- Visualização de locais associados

#### Locais (Sites)
- Cadastro de locais por cliente
- Isolamento por módulo (Clean/Manutenção)
- Informações detalhadas (endereço, contato, horários)
- Status e tipo de local

#### Zonas (Zones)
- Subdivisões de locais
- Isolamento por módulo
- Informações específicas (tamanho em m², descrição)
- Vinculação a locais do mesmo módulo

### 3. Sistema de QR Codes

#### QR Codes de Execução (Internos)
- **Propósito**: Gestão de trabalho para operadores internos
- **Fluxo**: Operador escaneia QR → Visualiza ordem de serviço → Executa checklist
- **Características**:
  - Vinculados a zonas específicas
  - Geram ordens de serviço programadas
  - Suportam checklists dinâmicos
  - Rastreamento de execução e tempo

#### QR Codes Públicos
- **Propósito**: Solicitações de serviço por usuários finais
- **Fluxo**: Usuário escaneia QR → Preenche formulário → Sistema cria ordem corretiva
- **Características**:
  - Acesso público (sem autenticação)
  - Captura de localização
  - Upload de fotos
  - Criação automática de ordem corretiva

### 4. Gestão de Ordens de Serviço

#### Tipos de Ordens
1. **Programadas**: Geradas por agendamento de atividades
2. **Corretivas Internas**: Criadas manualmente por gestores
3. **Corretivas Públicas**: Geradas via QR codes públicos

#### Status e Ciclo de Vida
- **Em aberto**: Aguardando execução
- **Em progresso**: Operador iniciou trabalho
- **Concluída**: Trabalho finalizado com checklist
- **Cancelada**: Ordem cancelada
- **Reabertura**: Suporte para reabrir ordens concluídas

#### Recursos Avançados
- **Prioridades**: Baixa, Média, Alta, Urgente
- **SLA**: Rastreamento de cumprimento de prazos
- **Atribuição**: Vinculação a operadores específicos
- **Comentários**: Sistema de notas com anexo de fotos
- **Avaliação**: Rating de 1-5 estrelas ao concluir
- **Analytics**: Todas as métricas derivadas de dados reais

### 5. Checklists Dinâmicos

#### Templates de Checklist
- Criação de templates reutilizáveis
- Isolamento por módulo
- Items com tipos variados (texto, sim/não, número, foto)
- Versionamento de templates

#### Execução de Checklist
- Preenchimento durante execução da ordem
- Validação de campos obrigatórios
- Captura de fotos como evidência
- Timestamp de conclusão

### 6. Agendamento e Atividades

#### OPUS Clean - Atividades de Limpeza
- **Atividades Recorrentes**:
  - Padrões: Diária, Semanal, Mensal, Anual
  - Frequência customizada (ex: a cada 3 dias)
  - Dias específicos da semana
  - Múltiplas ocorrências por dia
- **Geração Automática**: Ordens criadas conforme agenda
- **Configuração**:
  - Horários específicos
  - Zonas associadas
  - Templates de checklist
  - SLA por atividade

#### OPUS Manutenção - Planos de Manutenção
- **Tipos de Manutenção**:
  - Preventiva
  - Corretiva
  - Preditiva
- **Associação de Equipamentos**:
  - Vinculação de múltiplos equipamentos ao plano
  - Templates de checklist por tipo de equipamento
  - Frequência de manutenção configurável
- **Gestão de Equipamentos**:
  - Cadastro com especificações técnicas
  - Número de série e localização
  - Status operacional
  - Histórico de manutenções

### 7. Configurações do Sistema

#### Tipos e Categorias de Serviço
- Organização hierárquica (Tipo → Categoria)
- Isolamento por módulo
- Códigos e descrições customizáveis

#### Configurações de SLA
- Definição de prazos por prioridade
- Configuração específica por módulo
- Aplicação automática em ordens

#### Metas de Dashboard
- Definição de metas operacionais
- Períodos customizáveis (mensal, trimestral, anual)
- Indicadores visuais de desempenho

### 8. Dashboard e Analytics

#### Métricas em Tempo Real
- **Distribuição de Ordens**:
  - Por prioridade (gráfico pizza)
  - Por local (gráfico barras)
  - Por status
- **Performance**:
  - Tempo médio de conclusão
  - Taxa de cumprimento de SLA
  - Ordens concluídas vs. abertas
- **Tendências Temporais**:
  - Evolução de atividades
  - Padrões sazonais
  - Comparativos com metas

#### Relatórios Avançados
- **Relatório Geral**: Visão consolidada de operações
- **Análise de SLA**: Cumprimento de prazos detalhado
- **Produtividade**: Performance por operador
- **Análise por Local**: Distribuição geográfica
- **Análise Temporal**: Padrões ao longo do tempo
- **Exportação**: Geração de PDF e Excel

### 9. Interface Mobile

#### Características Mobile-First
- Design responsivo e touch-friendly
- Headers fixos para navegação
- Pull-to-refresh em listas
- Otimização para conexões lentas

#### Funcionalidades Mobile
- Escaneamento de QR codes
- Execução de checklists offline-ready
- Captura e upload de fotos
- Visualização de ordens atribuídas
- Navegação simplificada

### 10. Auditoria e Rastreabilidade

#### Logs de Auditoria
- Registro de todas ações críticas
- Informações capturadas:
  - Usuário executor
  - Timestamp preciso
  - Tipo de ação (criação, edição, exclusão)
  - Dados modificados (JSON diff)
  - Metadados contextuais

#### Rastreamento de Mudanças
- Histórico completo de ordens
- Registro de status changes
- Comentários timestamped
- Fotos com metadata

---

## OPUS Clean - Módulo de Limpeza

### Identidade Visual
- **Cor Principal**: Azul Navy (#1e3a8a)
- **Tema**: Profissionalismo e confiabilidade

### Funcionalidades Específicas

#### Gestão de Atividades de Limpeza
- Agendamento recorrente flexível
- Múltiplas frequências e padrões
- Geração automática de ordens programadas
- Checklists específicos para limpeza

#### Tipos de Serviço
- Limpeza geral
- Sanitização
- Higienização especializada
- Coleta de resíduos

#### Categorias Customizáveis
- Ambientes (escritórios, banheiros, áreas comuns)
- Superfícies (vidros, pisos, carpetes)
- Equipamentos (aspiradores, lavadoras)

---

## OPUS Manutenção - Módulo de Manutenção

### Identidade Visual
- **Cor Principal**: Laranja (#FF9800)
- **Tema**: Energia e ação

### Funcionalidades Específicas

#### Gestão de Equipamentos
- Cadastro completo de ativos
- Especificações técnicas detalhadas
- Localização e tracking
- Histórico de intervenções

#### Planos de Manutenção
- Manutenção preventiva programada
- Manutenção corretiva sob demanda
- Manutenção preditiva baseada em dados
- Templates por tipo de equipamento

#### Checklist Templates de Manutenção
- Procedimentos específicos por equipamento
- Inspeções técnicas
- Testes de funcionalidade
- Registro de medições e parâmetros

---

## Padrões de Desenvolvimento

### Backend - Camada de Dados

```typescript
// Interface de Storage define contratos
interface IStorage {
  getWorkOrdersByCustomer(customerId: string, module?: 'clean' | 'maintenance'): Promise<WorkOrder[]>;
}

// Implementação filtra por módulo quando fornecido
async getWorkOrdersByCustomer(customerId: string, module?: 'clean' | 'maintenance') {
  const customerSites = await this.db
    .select()
    .from(sites)
    .where(module ? and(eq(sites.customerId, customerId), eq(sites.module, module)) : eq(sites.customerId, customerId));
  // ... resto da lógica
}
```

### Frontend - Queries com Módulo

```typescript
// Hook useModule fornece contexto do módulo atual
const { currentModule } = useModule();

// Queries incluem módulo no queryKey para cache isolado
const { data: workOrders } = useQuery({
  queryKey: [`/api/customers/${customerId}/work-orders`, { module: currentModule }],
  enabled: !!customerId,
});
```

### API - Routes com Query Params

```typescript
// Rotas aceitam parâmetro module via query string
app.get("/api/customers/:customerId/work-orders", async (req, res) => {
  const module = req.query.module as 'clean' | 'maintenance' | undefined;
  const workOrders = await storage.getWorkOrdersByCustomer(req.params.customerId, module);
  res.json(workOrders);
});
```

---

## Segurança e Compliance

### Autenticação e Autorização
- JWT com expiração configurável
- Refresh tokens para sessões longas
- Rate limiting por IP e usuário
- Validação de permissões em cada rota

### Proteção de Dados
- Senhas nunca armazenadas em plain text
- Bcrypt com salt rounds configurável
- Sanitização de inputs
- Prevenção de SQL injection via ORM
- CORS restrito a domínios autorizados

### Auditoria
- Logs completos de ações críticas
- Rastreamento de mudanças em dados sensíveis
- Retenção de logs configurável
- Exportação de dados para compliance

---

## Escalabilidade e Performance

### Otimizações de Query
- Índices em campos frequentemente consultados
- Queries otimizadas com joins eficientes
- Paginação em listagens grandes
- Cache de queries com TanStack Query

### Arquitetura Preparada para Escala
- Separação clara de responsabilidades
- Stateless backend (JWT)
- Database connection pooling
- Pronto para load balancing horizontal

---

## Roadmap de Funcionalidades Futuras

### Em Consideração
- Notificações push para mobile
- Integração com sistemas externos (ERP, CMMS)
- IA para previsão de manutenções
- Geolocalização em tempo real de operadores
- Assinatura digital em checklists
- Integração com IoT para sensores

---

## Conclusão

OPUS é uma plataforma robusta e escalável para gestão de facilities, oferecendo isolamento completo entre módulos operacionais, interface intuitiva tanto para gestores quanto operadores, e analytics em tempo real para tomada de decisões informadas. A arquitetura moderna e tecnologias de ponta garantem performance, segurança e facilidade de manutenção.
