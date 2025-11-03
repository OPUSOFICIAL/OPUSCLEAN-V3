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