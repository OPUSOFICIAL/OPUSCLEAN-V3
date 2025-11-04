# Overview

OPUS is a modular facilities management platform designed to streamline operations and enhance efficiency. It currently includes OPUS Clean for cleaning and facilities management and OPUS Manutenção for maintenance management. The platform offers web-based administration and mobile applications, supporting scheduling, work order management, QR code-based task execution, and public service requests. OPUS is built to serve multiple companies, sites, and zones, providing real-time analytics through a modern full-stack architecture, with the vision of offering a comprehensive, scalable solution for modern facilities management.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## UI/UX Decisions

The system utilizes a consistent brand identity with a navy and slate blue palette. The frontend employs shadcn/ui with Radix UI primitives and Tailwind CSS for a responsive design, featuring gradient cards, color-coded charts, and streamlined navigation. Mobile interfaces are optimized for touch-friendly elements, including sticky headers and pull-to-refresh functionality.

## Technical Implementations

### Frontend

Developed with React and TypeScript, using Wouter for routing and TanStack Query for data management. Vite handles development and build processes.

### Backend

An Express.js server, written in TypeScript, follows RESTful API principles. It features a layered architecture and uses Drizzle ORM for type-safe interactions with PostgreSQL.

## Feature Specifications

### Multi-Tenancy

The platform implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with robust role-based access controls and client-specific, module-isolated data filtering. Each module (OPUS Clean, OPUS Manutenção) has completely isolated data for sites, zones, work orders, QR codes, and configuration tables (service categories, checklist templates, SLA configs, equipment, maintenance checklist templates, maintenance plans).

**Module-Specific Page Protection**: All module-specific pages include built-in verification to prevent cross-module access. Pages exclusive to OPUS Clean cannot be accessed when OPUS Manutenção is active, and vice versa. Users attempting to access restricted pages see a friendly error message directing them to switch modules.

### Equipment Tag System (Maintenance Module)

The Maintenance module uses a flexible tag-based system for equipment identification and checklist assignment. Equipment can be linked to multiple tags (e.g., "Coffee Machine", "AC Unit"). 

**Maintenance Checklist Templates** can be configured in two ways:
1. **Tag-based**: Templates target all equipment with selected tags, enabling efficient maintenance management across similar equipment types
2. **Equipment-specific**: Templates target a single specific equipment by ID

This dual approach allows both broad equipment categorization through tags and precise individual equipment targeting. Tags are customer-specific and module-specific, managed through the Equipment Tags configuration page accessible via the Settings page under the "Tags" tab.

### QR Code System

Supports two types of QR codes: Execution QRs for internal staff work order management and Public QRs for end-users to submit service requests, which automatically generate corrective work orders.

### Work Order Management

Manages programmed, internal corrective, and public corrective work orders. It tracks status, SLA compliance, priority, operator assignments, allows comments with photo attachments, and supports re-opening. All analytics are derived from real-time PostgreSQL data.

**Automated Monthly Work Order Generation (Maintenance Module)**: To optimize database performance, the system uses a dual approach for work order visibility and persistence:

1. **Virtual Calendar Display**: The maintenance schedule calendar (`/maintenance-schedule`) shows all future planned maintenance activities by calculating them on-the-fly based on maintenance plan frequency settings. This provides complete visibility of upcoming work without database overhead.

2. **Deferred Database Creation**: When a maintenance plan is created, NO work orders are immediately generated in the database. Instead, on the last day of each month at 23:00, an automated scheduler runs and pre-generates actual work orders for the following month across all companies.

This approach balances operational planning needs (users can see future schedules) with database efficiency (only current/next month orders exist in the database).

### Authentication and Authorization

Supports Microsoft SSO (Entra ID) and email/password authentication. Security measures include JWT, Bcrypt for password hashing, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access for predefined roles with differentiated routing for web and mobile users.

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