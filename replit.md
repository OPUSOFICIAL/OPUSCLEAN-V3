# Overview

OPUS CLEAN is a comprehensive cleaning and facilities management system designed for multi-tenant, multi-site operations. It provides web-based administration and mobile applications for managing cleaning schedules, work orders, QR code-based task execution, and public service requests across multiple companies, sites, and zones. The system integrates a modern full-stack architecture with a React frontend, Express.js backend, PostgreSQL database (Drizzle ORM), and a sophisticated QR code system. The project's ambition is to streamline facilities management, enhance operational efficiency, and provide real-time analytics for diverse organizational structures.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## UI/UX Decisions

The system features a complete brand identity for "grupo opus" with a consistent navy blue (#1e3a8a) and slate blue (#475569) color scheme. The frontend uses shadcn/ui with Radix UI primitives for consistent design and Tailwind CSS for styling, focusing on responsive layouts and intuitive user experiences. Key design elements include gradient cards, color-coded charts, and modern, streamlined navigation. Mobile interfaces are designed as separate, responsive components with sticky headers, pull-to-refresh, and optimized touch-friendly elements.

## Technical Implementations

### Frontend

The client application is built with React and TypeScript, utilizing Wouter for routing and TanStack Query for data fetching and state management. Vite is used for development and optimized builds.

### Backend

The server uses Express.js with TypeScript, following RESTful API principles. It employs a layered architecture separating concerns into routes, storage, and database connection management. Drizzle ORM is used for type-safe PostgreSQL queries.

## Feature Specifications

### Multi-Tenancy

The system implements a hierarchical multi-tenancy model with Companies as top-level tenants, containing Sites, which in turn contain Zones. Users have role-based access controls tied to company and site levels. Client filtering ensures users are locked to their assigned customer context.

### QR Code System

Two distinct QR code types are implemented:
-   **Execution QRs**: For internal staff to start scheduled or corrective work orders with checklist completion.
-   **Public QRs**: For end users to submit service requests that generate corrective work orders. The QR code service selection flow is enhanced to guide users for creating new or executing existing work orders.

### Work Order Management

Work orders can be programmed (from cleaning schedules), internal corrective (from execution QRs), or public corrective (from public QRs). The system tracks status, SLA compliance, priority, and operator assignments with role-based visibility. It includes a commenting system with photo attachments and the ability to reopen work orders. All dashboard analytics related to work orders now use 100% real-time data from the PostgreSQL database, processed via comprehensive backend endpoints.

### Authentication and Authorization

Dual authentication is supported: Microsoft SSO (Entra ID) and traditional email/password. Security hardening measures include JWT authentication, Bcrypt password hashing, rate limiting, timing attack prevention, data sanitization, CORS protection, security headers (Helmet.js), and SQL injection prevention via Drizzle ORM. A custom role system provides granular, permission-based access control with predefined system roles (Administrador, Cliente, Operador) and UI for assignment. Routing logic differentiates between web and mobile-only users based on assigned permissions.

### Dashboard

The dashboard provides analytical charts for insights into work orders, including distribution by priority and location, average completion time, and activity by day of the week, all powered by real-time backend data. Dashboard goals (metas) are integrated with visual indicators and various goal types.

### User Management

Complete CRUD operations are available for users, with support for client user creation and custom role assignment. The UI provides clear indicators for user roles and mobile access.

## System Design Choices

The project is configured for the Replit cloud environment, with PostgreSQL provisioned and schema pushed, and dependencies installed. The Vite dev server is configured for Replit proxy compatibility.

# Recent Changes

## October 31, 2025 (Parte 3)
- **DOCUMENTAÇÃO DO BANCO DE DADOS**: Criado arquivo completo de documentação
  - Arquivo: `DOCUMENTACAO_BANCO_DE_DADOS.md`
  - Documenta todas as 27 tabelas do sistema
  - Inclui todos os 11 enums e 66 permissões
  - Estrutura detalhada de campos JSONB (checklist_data, items, attachments)
  - Regras de negócio e relacionamentos
  - Comandos úteis e notas importantes
  - Estatísticas completas do banco

- **FIX LABELS CHECKLIST**: Corrigido exibição de labels em "Dados da Finalização"
  - Labels dos itens agora aparecem em vez de IDs numéricos
  - Busca correta do template pelo checklistTemplateId
  - Tenta múltiplos campos (label, title, name, text)
  - UX profissional e legível

## October 31, 2025 (Parte 2)
- **HISTÓRICO ADICIONADO NO MODAL WEB**: Modal de detalhes da OS agora inclui histórico completo
  - Histórico adicionado à seção direita do modal (após "Dados da Finalização")
  - Timeline visual idêntica ao mobile com ícones coloridos
  - Mostra: criação, início, pausas, retomadas e conclusão da OS
  - "Dados da Finalização" mantido intacto como solicitado

- **FIX DE TIMEZONE**: Corrigido problema de data agendada salvando dia anterior
  - Problema: datas sem hora eram interpretadas como UTC causando -1 dia
  - Solução backend: transformação no schema para manter strings YYYY-MM-DD sem conversão
  - Solução frontend: função `formatDateOnly()` que formata datas sem criar Date object
  - Campos afetados: `scheduledDate` e `dueDate`
  - Agora datas são salvas e exibidas corretamente

- **SEPARAÇÃO HISTÓRICO vs COMENTÁRIOS**: Comentários de sistema movidos para histórico
  - Comentários automáticos (iniciou, pausou, retomou, finalizou) aparecem APENAS no Histórico
  - Seção "Comentários" mostra apenas comentários reais de usuários
  - Filtro automático detecta emojis de sistema (⏯️, ⏸️, ▶️) e frases ("OS Finalizada!", "✅ Checklist")
  - Badge de contador de comentários agora mostra apenas comentários de usuários
  - UX mais limpa e organizada

## October 31, 2025 (Parte 1)
- **HISTÓRICO MOVIDO PARA DETALHES**: Histórico da OS movido da tela de execução para detalhes
  - Histórico não aparece mais na tela de execução (operadores não veem)
  - Histórico agora está na tela de detalhes da OS (apenas administradores/clientes veem)
  - Timeline visual mostra: abertura, pausas, retomadas, conclusão
  - Cada evento mostra data/hora completa e nome do operador responsável
  - Ícones coloridos identificam tipo de ação (azul: início, laranja: pausa, verde: conclusão)

- **LÓGICA "INICIOU" VS "RETOMOU"**: Corrigida diferenciação de mensagens
  - Primeira execução mostra: "⏯️ [Nome] iniciou a execução da OS"
  - Retomada após pausa mostra: "⏯️ [Nome] retomou a execução da OS"
  - Sistema verifica histórico de comentários para determinar se é primeira vez
  - Se não existe comentário anterior de início/retomada → usa "iniciou"
  - Se já existe comentário anterior de início/retomada → usa "retomou"

- **TEMPO REAL DE EXECUÇÃO**: Campo "Horas Estimadas" substituído por cálculo automático
  - Novo campo "Tempo Real de Execução" mostra tempo que OS ficou em execução
  - Cálculo considera pausas automaticamente (desconta tempo pausado)
  - Lógica detecta pausas/retomadas através dos comentários
  - Campo read-only calculado em tempo real (não é mais input manual)
  - Exibição em formato legível: "1h 23min" ou "45min"
  - Para OSs não iniciadas mostra: "Não iniciada"
  - Para OSs em execução: calcula tempo até momento atual
  - Para OSs concluídas: calcula tempo total de execução

- **FILTRO "PAUSADAS"**: Adicionado quarto filtro no modal de seleção de serviço
  - Modal QR code agora tem 4 filtros: Hoje / Próximos / Pausadas / Todos
  - Filtro "Pausadas" mostra apenas OSs com status pausada
  - Badge visual laranja "⏸ PAUSADA" para identificar OSs pausadas
  - Sistema busca automaticamente OSs pausadas junto com abertas e em execução

## October 17, 2025
- **MULTISELECT FILTERS**: Implementado sistema de filtros multiselect para Status e Zona
  - Criado componente reutilizável MultiSelect com Popover e Checkbox
  - Permite selecionar múltiplos status e zonas simultaneamente em ambas versões (web e mobile)
  - Filtros agora usam arrays ao invés de valores únicos (statusFilter: string[] e zoneFilter: string[])
  - Lógica de filtragem atualizada para suportar múltiplas seleções usando array.includes()
  - Botão "X" para limpar todas as seleções de uma vez
  - Contador mostra quantidade de itens selecionados (ex: "3 selecionados")
  - UX melhorada com indicadores visuais de seleção via checkboxes
  - Implementação consistente entre interface web e mobile

- **GERAÇÃO AUTOMÁTICA DE OSs**: Corrigida geração de OSs ao criar plano de limpeza
  - Corrigido companyId dinâmico ao invés de hardcoded "company-opus-default"
  - Adicionado melhor tratamento de erros com mensagens de toast informativas
  - Sistema agora mostra quantidade de OSs geradas após criar plano de limpeza
  - Logs detalhados no console para debug

- **FILTRO DE ZONA**: Adicionado filtro de zona na página de Ordens de Serviço (web)
  - Filtro de zona implementado ao lado do filtro de status
  - Permite filtrar OSs por zona específica ou "Todas as Zonas"
  - Integrado com lógica de filtragem existente (status, busca, data)
  - Já existia no mobile, agora disponível também na versão web

## October 9, 2025
- **QR CODE REDESIGN**: Redesenhados QR codes com branding Grupo OPUS
  - Expandida área azul superior para incluir logo branca do Grupo OPUS
  - Logo centralizada e responsiva em PDFs individuais e múltiplos
  - Layout aprimorado mantendo badge "EXECUÇÃO" abaixo da área azul
  - Aplicado em todas as funções de geração de PDF (individual e em lote)

- **DASHBOARD ANALYTICS**: Gráficos e cards corrigidos com dados 100% reais
  - **SLA Compliance**: Calculado corretamente (OSs concluídas no prazo / total concluídas)
  - **OS por Prioridade/Local**: Agora excluem OSs concluídas (mostram apenas abertas/vencidas)
  - **Atividade por Semana**: Traduzido para português (Segunda, Terça, Quarta, etc.)
  - **Atividade por Semana**: Usa scheduledDate para mostrar todos os dias do plano de limpeza
  - **Tempo Médio de Conclusão**: Corrigido para usar averageExecutionTime (em minutos)
  - **Auto-completedAt**: OSs marcadas como concluídas recebem timestamps automaticamente

- **PERFORMANCE FIX**: Dashboard de performance agora usa 100% dados reais do PostgreSQL
  - Substituídos todos os dados mockados/estáticos por queries reais
  - Dados diários: GROUP BY por data com cálculo real de eficiência (últimos 30 dias)
  - Área limpa: JOIN com zones para pegar areaM2 real das zonas
  - Tempo médio: Cálculo real baseado em completedAt - createdAt (em minutos)
  - Variação %: Comparação real com período anterior (hoje vs ontem, semana vs semana anterior, etc)
  - Todos os KPIs agora mostram dados precisos do banco

## October 8, 2025
- **CRITICAL FIX**: Corrigido bug de inconsistência de IDs entre frontend e backend
  - Seed criava `company-opus-default` mas frontend buscava `company-admin-default`
  - Isso causava dashboards vazios mesmo com dados no banco
  - Solução: Padronizado `company-opus-default` em todo o código
- Adicionadas 3 novas frequências ao plano de limpeza: Trimestral, Semestral e Anual
- Implementado date picker para frequências Trimestral, Semestral e Anual
- Adicionado efeito de rotação animado ao botão Atualizar do dashboard
- Atualizada legenda do calendário com as novas frequências

# Known Issues & Solutions

## Dashboard Vazio na VM
**Problema**: Dashboard não mostra dados mesmo tendo OSs e planos de limpeza cadastrados.

**Causas Possíveis**:
1. Inconsistência de IDs (company-opus-default vs company-admin-default) - **CORRIGIDO**
2. Dados em banco de desenvolvimento não sincronizados com produção
3. activeClientId não está sendo definido corretamente

**Solução na VM**:
1. Verificar se o código tem `company-opus-default` consistentemente
2. Executar `npm run db:seed` para garantir estrutura base
3. Verificar logs do browser console para erros de API
4. Confirmar que o user.companyId corresponde ao ID da company no banco

# External Dependencies

## Database
-   **PostgreSQL**: Primary database.
-   **Neon**: Serverless PostgreSQL hosting.
-   **Drizzle ORM**: Type-safe database operations.

## UI Components
-   **Radix UI**: Accessible primitive components.
-   **shadcn/ui**: Pre-built component library.
-   **Tailwind CSS**: Utility-first styling.

## Development Tools
-   **Vite**: Build tool.
-   **TypeScript**: Type safety.
-   **TanStack Query**: Server state management.
-   **Wouter**: Frontend routing.

## Security & Authentication
-   **JWT (jsonwebtoken)**: Secure token-based authentication.
-   **Helmet**: HTTP security headers.
-   **CORS**: Cross-origin resource sharing protection.
-   **Express Rate Limit**: Brute force protection.
-   **Bcrypt**: Password hashing.
-   **Microsoft Entra ID**: SSO integration.