# Overview

OPUS is a modular facilities management platform designed to streamline operations and enhance efficiency across various domains. It currently includes **OPUS Clean** for cleaning and facilities management and **OPUS Manutenção** for maintenance management. The platform offers web-based administration and mobile applications, supporting scheduling, work order management, QR code-based task execution, and public service requests. OPUS is built to serve multiple companies, sites, and zones, providing real-time analytics through a modern full-stack architecture. The vision is to offer a comprehensive, scalable solution for modern facilities management.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## UI/UX Decisions

The system maintains a consistent brand identity using a navy and slate blue palette. The frontend utilizes shadcn/ui with Radix UI primitives and Tailwind CSS for a responsive and intuitive design, incorporating gradient cards, color-coded charts, and streamlined navigation. Mobile interfaces are optimized for touch-friendly elements, including sticky headers and pull-to-refresh functionality.

## Technical Implementations

### Frontend

Developed with React and TypeScript, employing Wouter for routing and TanStack Query for efficient data management. Vite is used for development and build processes.

### Backend

An Express.js server, written in TypeScript, adheres to RESTful API principles. It features a layered architecture and uses Drizzle ORM for type-safe interactions with PostgreSQL.

## Feature Specifications

### Multi-Tenancy

The platform implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with robust role-based access controls and client-specific data filtering to ensure segregation.

### QR Code System

Supports two types of QR codes:
-   **Execution QRs**: Used by internal staff for managing work orders and checklists.
-   **Public QRs**: Allow end-users to submit service requests, which automatically generate corrective work orders.

### Work Order Management

Manages programmed, internal corrective, and public corrective work orders. It tracks status, SLA compliance, priority, operator assignments, allows comments with photo attachments, and supports re-opening of work orders. All analytics are derived from real-time PostgreSQL data.

### Authentication and Authorization

Supports both Microsoft SSO (Entra ID) and email/password authentication. Security measures include JWT, Bcrypt for password hashing, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access for predefined roles (Administrador, Cliente, Operador) with differentiated routing for web and mobile users.

### Dashboard

Provides analytical charts for work orders, including distribution by priority and location, average completion time, and activity trends, all powered by real-time data. Dashboard goals are integrated with visual indicators.

### User Management

Offers full CRUD operations for users, including client user creation and custom role assignment, with clear indicators for roles and mobile access.

## System Design Choices

The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning, schema pushing, and dependency installation. The Vite dev server is compatible with Replit's proxy. The system is designed to be modular, supporting new operational modules like OPUS Clean and OPUS Manutenção with distinct theming and data isolation.

# Recent Changes

## November 3, 2025 - Isolamento Completo de Locais, Zonas e Ordens de Serviço por Módulo
**Separação total de dados entre OPUS Clean e OPUS Manutenção + Renomeação "Site" para "Local"**

### Problema Identificado:
- Locais (Sites), Zonas e Ordens de Serviço eram compartilhados entre os módulos Clean e Manutenção
- Usuários podiam ver dados de um módulo quando estavam em outro
- Terminologia "Site" não era clara para usuários finais
- **CRÍTICO**: Work Orders não respeitavam isolamento de módulo mesmo com campo `module` existente

### Implementação Completa:

**1. Schema Database (shared/schema.ts)**:
- Adicionado campo `module: moduleEnum('module').notNull().default('clean')` nas tabelas `sites` e `zones`
- Tabela `work_orders` já possuía campo `module` mas não era usado corretamente
- Isolamento completo: cada módulo tem seus próprios locais, zonas e work orders independentes
- Renomeação de comentários: "Sites" → "Locais" em toda documentação

**2. Storage Layer (server/storage.ts)**:
- Interface IStorage atualizada: parâmetro opcional `module?: 'clean' | 'maintenance'` em:
  - `getSitesByCompany(companyId, module?)`
  - `getSitesByCustomer(customerId, module?)`
  - `getZonesByCompany(companyId, module?)`
  - `getZonesByCustomer(customerId, module?)`
  - `getZonesBySite(siteId, module?)`
- **CORREÇÃO CRÍTICA** - Work Orders agora filtram Sites e Zones por módulo ANTES de buscar WOs:
  - `getWorkOrdersByCustomer()` - filtra sites e zones por módulo primeiro
  - `getDashboardStatsByCustomer()` - filtra sites e zones por módulo primeiro
  - `getGeneralReport()` - corrigido para filtrar por módulo
  - `getSLAAnalysis()` - corrigido para filtrar por módulo
  - `getProductivityReport()` - corrigido para filtrar por módulo
  - `getOperatorPerformance()` - corrigido para filtrar por módulo
  - `getLocationAnalysis()` - corrigido para filtrar por módulo
  - `getTemporalAnalysis()` - corrigido para filtrar por módulo
  - `getAnalyticsByCustomer()` - corrigido para filtrar por módulo
- Implementação com filtros usando `and(eq(...), eq(sites.module, module))` quando módulo é fornecido
- Backward compatible: funciona sem parâmetro module (retorna todos)

**3. API Routes (server/routes.ts)**:
- Todas rotas GET aceitam query param `?module=clean|maintenance`:
  - `GET /api/companies/:companyId/sites?module=clean`
  - `GET /api/customers/:customerId/sites?module=maintenance`
  - `GET /api/sites/:siteId/zones?module=clean`
  - `GET /api/customers/:customerId/work-orders?module=clean`
- Rotas POST defaultam para 'clean': `module: req.body.module || 'clean'`
- Filtro propagado corretamente do routes → storage → database

**4. Frontend - Renomeação Completa (client/src/)**:
- 20+ arquivos atualizados com 50+ substituições de strings de UI:
  - "Site" → "Local"
  - "Sites" → "Locais"
  - "Selecione um site" → "Selecione um local"
  - "Todos os Sites" → "Todos os Locais"
  - "Supervisor de Site" → "Supervisor de Local"
- Mantidos nomes técnicos: `siteId`, `sites` (variáveis), `/api/sites` (rotas)
- Arquivos principais: sites.tsx, users.tsx, equipment.tsx, qr-codes.tsx, cleaning-schedule.tsx, etc.

**5. Database Migration**:
- Push schema executado com sucesso: `npm run db:push`
- Colunas `module` adicionadas em `sites` e `zones`
- Campo `module` em `work_orders` agora usado corretamente
- Dados existentes migrados com default 'clean'

### Resultado Final:
- ✅ OPUS Clean só vê locais/zonas/work orders com `module='clean'`
- ✅ OPUS Manutenção só vê locais/zonas/work orders com `module='maintenance'`
- ✅ Isolamento 100% completo entre módulos em TODOS os níveis
- ✅ Terminologia clara: "Local" em vez de "Site"
- ✅ Backward compatible: código antigo continua funcionando
- ✅ 9 métodos de analytics/reports corrigidos para respeitar isolamento
- ✅ Zero vazamento de dados entre módulos
- ✅ Hot reload testado e funcional

**Hierarquia Atualizada**: Companies > Clientes > **Locais** > Zonas > Work Orders (cada módulo tem dados completamente isolados)

# External Dependencies

## Database
-   **PostgreSQL**: Primary relational database.
-   **Neon**: Serverless PostgreSQL hosting.
-   **Drizzle ORM**: Type-safe ORM for database interactions.

## UI Components
-   **Radix UI**: Accessible primitive UI components.
-   **shadcn/ui**: Component library built on Radix UI and Tailwind CSS.
-   **Tailwind CSS**: Utility-first CSS framework for styling.

## Development Tools
-   **Vite**: Fast build tool and development server.
-   **TypeScript**: Superset of JavaScript for type-safe code.
-   **TanStack Query**: Data fetching and state management library.
-   **Wouter**: Lightweight React router.

## Security & Authentication
-   **JWT (jsonwebtoken)**: For creating and verifying access tokens.
-   **Helmet**: Helps secure Express apps by setting various HTTP headers.
-   **CORS**: Middleware for enabling Cross-Origin Resource Sharing.
-   **Express Rate Limit**: Middleware for basic rate-limiting to prevent abuse.
-   **Bcrypt**: For hashing passwords securely.
-   **Microsoft Entra ID**: For single sign-on (SSO) capabilities.