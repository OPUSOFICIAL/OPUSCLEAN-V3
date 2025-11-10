# OPUS - Project Summary

## Overview

OPUS is a modular facilities management platform, currently encompassing OPUS Clean for cleaning and OPUS Manutenção for maintenance. It aims to streamline operations through web-based administration and mobile applications, offering features like scheduling, work order management, QR code-based task execution, and public service requests. Designed for multi-company, multi-site, and multi-zone environments, OPUS provides real-time analytics and a scalable solution for modern facilities management.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### UI/UX Decisions

The system features a modern, predominantly white design with subtle gradients and glassmorphism effects for depth and sophistication. It utilizes `shadcn/ui` with Radix UI primitives and Tailwind CSS. Module-specific colors (blue for Clean, orange for Manutenção) are used for identification on focal elements like buttons and badges. The design is responsive, optimized for both desktop and mobile, with touch-friendly elements and streamlined navigation. The mobile dashboard highlights in-progress work orders with a distinct green-to-emerald gradient card and a dedicated statistics card.

### Technical Implementations

The frontend is built with React and TypeScript, using Wouter for routing and TanStack Query for data management, all powered by Vite. The backend is an Express.js server in TypeScript, following RESTful API principles with a layered architecture, utilizing Drizzle ORM for type-safe PostgreSQL interactions.

### Feature Specifications

**Multi-Tenancy**: Implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with robust role-based access control and client/module-specific data isolation. Module-specific pages include verification to prevent cross-module access.

**Equipment Management (Maintenance Module)**: Supports direct equipment selection for checklist assignment and maintenance planning, allowing templates and plans to target single or multiple equipment items. All equipment management is customer and module-specific.

**QR Code System**: Facilitates Execution QRs for internal staff work order management and Public QRs for end-users to submit service requests, automatically generating corrective work orders.

**Work Order Management**: Manages programmed, internal corrective, and public corrective work orders, tracking status, SLA, priority, assignments, and supporting comments with photo attachments. The Maintenance module uses a virtual calendar for future activity display and defers actual work order creation to a monthly automated scheduler for database efficiency. Interactive activity management allows toggling activity status, affecting future work order generation. Work order numbering is now customer-specific, managed by `customer_counters`.

**Authentication and Authorization**: Supports Microsoft SSO (Entra ID) and email/password authentication. Security includes JWT, Bcrypt, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access. Strict module-based access control is implemented for both web and mobile platforms.

**Dashboard**: Provides analytical charts for work orders, including distribution by priority and location, average completion time, and activity trends, with integrated visual indicators for goals.

**User Management**: Offers full CRUD operations for users, including client user creation and custom role assignment, with clear indicators for roles and mobile access.

### System Design Choices

The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning, schema pushing, and dependency installation. It's designed to be modular, supporting new operational modules with distinct theming and data isolation. The term "Site" is presented as "Local" in the UI.

## External Dependencies

-   **Database**: PostgreSQL, Neon (hosting), Drizzle ORM.
-   **UI Components**: Radix UI, shadcn/ui, Tailwind CSS.
-   **Development Tools**: Vite, TypeScript, TanStack Query, Wouter.
-   **Security & Authentication**: jsonwebtoken (JWT), Helmet, CORS, Express Rate Limit, Bcrypt, Microsoft Entra ID.