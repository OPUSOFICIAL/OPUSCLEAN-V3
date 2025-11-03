# Overview

OPUS CLEAN is a comprehensive cleaning and facilities management system for multi-tenant, multi-site operations. It offers web-based administration and mobile applications for managing cleaning schedules, work orders, QR code-based task execution, and public service requests. The system supports multiple companies, sites, and zones, aiming to streamline facilities management, enhance operational efficiency, and provide real-time analytics through a modern full-stack architecture.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## UI/UX Decisions

The system features a consistent brand identity using navy blue and slate blue. The frontend leverages shadcn/ui with Radix UI primitives and Tailwind CSS for responsive, intuitive design, including gradient cards, color-coded charts, and streamlined navigation. Mobile interfaces are optimized with sticky headers, pull-to-refresh, and touch-friendly elements.

## Technical Implementations

### Frontend

Built with React and TypeScript, using Wouter for routing and TanStack Query for data management. Vite handles development and builds.

### Backend

An Express.js server with TypeScript follows RESTful API principles. It uses a layered architecture and Drizzle ORM for type-safe PostgreSQL queries.

## Feature Specifications

### Multi-Tenancy

Implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with role-based access controls and client filtering for data segregation.

### QR Code System

Supports two types:
-   **Execution QRs**: For internal staff to manage work orders with checklists.
-   **Public QRs**: For end-users to submit service requests, generating corrective work orders.

### Work Order Management

Manages programmed, internal corrective, and public corrective work orders. It tracks status, SLA compliance, priority, operator assignments, commenting with photo attachments, and re-opening capabilities. All analytics use real-time PostgreSQL data.

### Authentication and Authorization

Supports Microsoft SSO (Entra ID) and email/password authentication. Security features include JWT, Bcrypt, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access control for predefined roles (Administrador, Cliente, Operador) with differentiated routing for web and mobile users.

### Dashboard

Provides analytical charts for work orders, including distribution by priority and location, average completion time, and activity trends, all powered by real-time data. Dashboard goals are integrated with visual indicators.

### User Management

Offers full CRUD operations for users, including client user creation and custom role assignment, with clear indicators for roles and mobile access.

## System Design Choices

The project is configured for the Replit cloud environment, with PostgreSQL provisioning, schema pushing, and dependency installation. The Vite dev server is compatible with Replit's proxy.

# Recent Changes

## November 3, 2025 - Relatório de Produtividade com Dados Reais
**Problema identificado**: Todos os dados do relatório de produtividade estavam mockados/aleatórios, gerando valores diferentes a cada exportação.

**Implementação de cálculos reais**:

### Métricas de Produtividade (100% reais):
- **OS por Dia**: Conta work orders concluídas no período / número de dias
- **Tempo Médio de Conclusão**: Calcula média real de `(completedAt - startedAt)` em minutos
- **Área Limpa por Hora**: Usa área real das zonas (`areaM2`) dividido por horas trabalhadas
- **Tarefas por Operador**: Total de WOs concluídas / número de operadores ativos
- **Score de Qualidade**: Baseado em % de work orders completadas dentro do prazo (SLA compliance)

### Métricas de Eficiência (baseadas em dados reais):
- **Utilização de Recursos**: % de operadores que têm work orders atribuídas
- **Uptime de Equipamentos**: % de work orders completadas no prazo
- **Desperdício de Material**: % de work orders atrasadas
- **Consumo de Energia**: Estimativa baseada em horas trabalhadas × 15 kWh
- **Eficiência de Custo**: Baseado em SLA compliance (WOs no prazo)

### Tendências Mensais (reais dos últimos 6 meses):
- **Produtividade**: % de conclusão por mês
- **Eficiência**: % de work orders no prazo por mês
- Calculado com agrupamento real por mês/ano

**Resultado**: Relatórios agora exibem dados consistentes e calculados do PostgreSQL, sem valores aleatórios.

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