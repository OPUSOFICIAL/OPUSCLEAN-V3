# OPUS - Project Summary

> **📚 Documentação Completa**: Para documentação técnica detalhada, arquitetura, fluxos e changelog, consulte [DOCUMENTATION.md](./DOCUMENTATION.md)

# Overview

OPUS is a modular facilities management platform designed to streamline operations and enhance efficiency. It currently includes OPUS Clean for cleaning and facilities management and OPUS Manutenção for maintenance management. The platform offers web-based administration and mobile applications, supporting scheduling, work order management, QR code-based task execution, and public service requests. OPUS is built to serve multiple companies, sites, and zones, providing real-time analytics through a modern full-stack architecture, with the vision of offering a comprehensive, scalable solution for modern facilities management.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## UI/UX Decisions

**Design System (Atualizado em 05/11/2025)**: O sistema implementa um design **predominantemente BRANCO e moderno**, com gradientes sutis que criam profundidade visual. As cores dos módulos (azul para Clean, laranja para Manutenção) aparecem apenas como identificação em badges, botões primários e bordas de ênfase. 

O frontend utiliza:
- **shadcn/ui** com Radix UI primitives e Tailwind CSS
- **Componentes modernos reutilizáveis**: ModernCard, ModernPageHeader, ModernCardContent
- **Hook de tema dinâmico**: `use-module-theme` que adapta cores baseado no módulo ativo
- **Gradientes sutis**: Backgrounds com gradientes white-to-light-gray que criam profundidade
- **Glassmorphism**: Cards com efeito glass (backdrop-blur) para visual sofisticado
- **Paleta neutra**: Fundos com gradientes suaves, sombras cinza discretas, bordas limpas
- **Identificação por módulo**: Cor do módulo apenas em elementos focais (botões, badges, ícones)
- **Responsividade**: Design otimizado para desktop e mobile com navegação streamlined

**Variantes de Cards**:
- `default`: Card branco limpo com borda sutil
- `gradient`: Card com gradiente muito sutil (white-to-module-color/20)
- `glass`: Card glassmorphism com backdrop-blur e gradiente translúcido
- `featured`: Card com cor do módulo (destaque)

**Páginas com Design Moderno Aplicado**:
- Dashboard (ambos módulos) - gradientes de página e section, cards glass
- Equipment (Manutenção) - gradientes modernos, cards gradient
- Maintenance Plans (Manutenção) - gradientes de página, cards glass com calendário integrado
- Checklists (Clean) - gradientes modernos, ModernCard com variantes gradient e glass

Mobile interfaces são otimizadas para elementos touch-friendly, incluindo sticky headers e funcionalidade pull-to-refresh.

**Mobile Dashboard - Indicador Visual de O.S em Execução (Atualizado em 05/11/2025)**: O dashboard mobile do colaborador apresenta um sistema visual destacado para mostrar quais ordens de serviço estão sendo executadas atualmente pelo colaborador:
- **Seção Destacada no Topo**: Card verde com gradiente (green-to-emerald) que lista todas as O.S com status "em_execucao" do colaborador, incluindo número da OS, título, local/zona, prazo e tipo
- **Card de Estatística Especial**: Card maior no grid de estatísticas mostrando contador de O.S em execução com ícone Zap e emoji 🔥
- **Separação Inteligente**: O.S em execução são filtradas separadamente das "Pendentes", evitando duplicação
- **Design Visual**: Usa gradientes verde-esmeralda, ícones animados (pulse), e efeito glassmorphism para destacar visualmente as tarefas ativas

## Technical Implementations

### Frontend

Developed with React and TypeScript, using Wouter for routing and TanStack Query for data management. Vite handles development and build processes.

### Backend

An Express.js server, written in TypeScript, follows RESTful API principles. It features a layered architecture and uses Drizzle ORM for type-safe interactions with PostgreSQL.

## Feature Specifications

### Multi-Tenancy

The platform implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with robust role-based access controls and client-specific, module-isolated data filtering. Each module (OPUS Clean, OPUS Manutenção) has completely isolated data for sites, zones, work orders, QR codes, and configuration tables (service categories, checklist templates, SLA configs, equipment, maintenance checklist templates, maintenance plans).

**Module-Specific Page Protection**: All module-specific pages include built-in verification to prevent cross-module access. Pages exclusive to OPUS Clean cannot be accessed when OPUS Manutenção is active, and vice versa. Users attempting to access restricted pages see a friendly error message directing them to switch modules.

### Equipment Management (Maintenance Module)

The Maintenance module uses direct equipment selection for checklist assignment and maintenance planning. Equipment can be managed through the Equipment page and selected directly when creating:

**Maintenance Checklist Templates**: Templates can target one or multiple specific equipment items using a multiselect interface. This allows both individual equipment targeting and group management by selecting multiple pieces of equipment that share similar maintenance procedures.

**Maintenance Plans**: Plans support selecting multiple equipment items, with the system automatically generating work orders for each selected equipment based on the configured frequency and schedule.

All equipment is customer-specific and module-specific, managed through the Equipment page accessible via the sidebar in OPUS Manutenção.

### QR Code System

Supports two types of QR codes: Execution QRs for internal staff work order management and Public QRs for end-users to submit service requests, which automatically generate corrective work orders.

### Work Order Management

Manages programmed, internal corrective, and public corrective work orders. It tracks status, SLA compliance, priority, operator assignments, allows comments with photo attachments, and supports re-opening. All analytics are derived from real-time PostgreSQL data.

**Automated Monthly Work Order Generation (Maintenance Module)**: To optimize database performance, the system uses a dual approach for work order visibility and persistence:

1. **Virtual Calendar Display**: The Maintenance Plans page (`/maintenance-plans`) includes an integrated calendar view that shows all future planned maintenance activities by calculating them on-the-fly based on maintenance plan frequency settings. Activities are color-coded by frequency (daily=green, weekly=blue, shift-based=orange, monthly=purple, quarterly=indigo, semi-annual=violet, annual=rose). This provides complete visibility of upcoming work without database overhead.

2. **Deferred Database Creation**: When a maintenance plan is created, NO work orders are immediately generated in the database. Instead, on the last day of each month at 23:00, an automated scheduler runs and pre-generates actual work orders for the following month across all companies.

This approach balances operational planning needs (users can see future schedules) with database efficiency (only current/next month orders exist in the database).

**Interactive Activity Management (Maintenance Module - Updated 05/11/2025)**: The Maintenance Plans page includes interactive activity management:

1. **Active Activities Modal**: The "Ativas" summary card is clickable and opens a comprehensive modal displaying all active maintenance activities with their details (name, type, frequency, equipment count, linked checklist).

2. **Activity Status Toggle**: Each activity in the modal includes action buttons to view details or inactivate/activate the activity. Inactive activities are excluded from automated monthly work order generation.

3. **Smart Filtering**: The automated scheduler (`generateMaintenanceWorkOrders` function) filters activities by `isActive: true` before generating monthly work orders, ensuring only active maintenance activities produce scheduled work.

### Authentication and Authorization

Supports Microsoft SSO (Entra ID) and email/password authentication. Security measures include JWT, Bcrypt for password hashing, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access for predefined roles with differentiated routing for web and mobile users.

**Module Access Control**: The system implements strict module-based access control for both web and mobile platforms. Each user (stored in `users.modules` array) and customer (stored in `customers.modules` array) has assigned modules (`clean`, `maintenance`, or both). The `ModuleContext` validates module access on every route, automatically correcting invalid module selections and enforcing restrictions. Mobile users see a visual module indicator in the header, and the sidebar dynamically shows/hides the module selector based on user permissions (hidden if only 1 module, shown as dropdown if 2+ modules). This ensures collaborators registered for maintenance only see maintenance data and cannot access cleaning module features, and vice versa.

### Dashboard

Provides analytical charts for work orders, including distribution by priority and location, average completion time, and activity trends, all powered by real-time data. Dashboard goals are integrated with visual indicators.

### User Management

Offers full CRUD operations for users, including client user creation and custom role assignment, with clear indicators for roles and mobile access.

## System Design Choices

The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning, schema pushing, and dependency installation. The Vite dev server is compatible with Replit's proxy. The system is designed to be modular, supporting new operational modules with distinct theming and data isolation. The term "Site" has been renamed to "Local" in the UI for clarity, while retaining "siteId" in the backend.

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