# Acelera it - Full Facilities - Project Summary

## Overview
Acelera it Full Facilities is a modular platform designed to streamline facilities management, specifically for Clean and Maintenance operations. It offers web administration and mobile applications for scheduling, work order management, QR code-based task execution, and public service requests. The platform supports multi-company, multi-site, and multi-zone environments, providing real-time analytics, focusing on efficiency, cost reduction, and productivity.

## User Preferences
Preferred communication style: Simple, everyday language.

## System Architecture

### UI/UX Decisions
The system features an enterprise-grade, corporate design utilizing `shadcn/ui` with Radix UI and Tailwind CSS. It emphasizes professionalism with module-specific colors (blue for Clean, orange for Maintenance), responsive design, and a corporate SaaS aesthetic for pre-login pages. Visual elements include custom branding, Lucide React icons, Framer Motion animations, and full-width layouts.

### Technical Implementations
The frontend uses React, TypeScript, Wouter for routing, and TanStack Query for data management. The backend is an Express.js server in TypeScript with Drizzle ORM for PostgreSQL. Key features include a hierarchical multi-tenancy model with role-based access control, comprehensive equipment management, QR code-based task execution, robust work order management with virtual calendars and automated scheduling. Authentication supports Microsoft SSO and email/password, secured with JWT and Bcrypt. An AI integration configuration page is present, with chat assistant functionality under development. A TV Mode Dashboard provides real-time, gamified metrics. User management offers full CRUD and custom role assignments. Recent enhancements include a granular permission system with user type validation and frontend filtering, enhanced shift-based scheduling with weekday filtering, and full-featured edit forms using reusable components. The custom roles system features automatic creation of 3 default client roles upon customer provisioning: "Operador" (mobile-only, 4 permissions), "Cliente" (web, 8 permissions), and "Administrador" (web, 38 client permissions). Roles are associated with the customer's company via `companyId` reference, following the hierarchical structure: Companies → Customers → Roles. The roles interface includes per-category "Select All" checkboxes with smart state indicators showing partial selections. Admin OPUS users have automatic access to view and manage all roles without explicit permission checks. 

**Real-Time Updates**: The system now implements WebSocket-based real-time updates for instant reactivity across all clients. The WebSocket server runs on the same HTTP server at the `/ws` path, using JWT token-based authentication. When any data changes (customers, work orders, roles, users, sites, etc.), the backend broadcasts update notifications to all connected clients via WebSocket. The frontend automatically invalidates React Query cache and re-fetches affected data, ensuring all users see changes immediately without manual page refreshes. The WebSocket client includes automatic reconnection with exponential backoff, heartbeat/ping-pong to detect broken connections, and integrates seamlessly with React Query for cache invalidation. This replaces the previous 5-minute stale time approach and eliminates the need for manual polling. The implementation is located in `server/websocket.ts` (server), `client/src/hooks/useWebSocket.ts` (client hook), and broadcasts are added to all major CRUD endpoints in `server/routes.ts`.

Performance optimizations include database indexing, parallel query execution, and accurate real-time data reporting. Photo uploads are optimized with automatic image compression and smaller batch sizes for improved performance on slow connections. An offline-first Android APK is supported by a comprehensive sync infrastructure, utilizing IndexedDB for offline storage, a priority-based sync queue, and robust error handling.

### System Design Choices
The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning and a modular design for future expansion. It includes an adaptive subdomain-based branding system that dynamically applies client branding (logos and module colors) based on the subdomain, with robust fallback mechanisms and asset serving.

## External Dependencies

### Database & Storage
- PostgreSQL (Neon hosting)
- Drizzle ORM
- Drizzle Kit

### UI Components & Styling
- Radix UI
- shadcn/ui
- Tailwind CSS
- Lucide React
- React Icons
- Framer Motion

### Mobile (Android APK)
- Capacitor 7 (Core, CLI, Android)
- IndexedDB v4
- @capacitor/network
- @capacitor/camera
- `client/src/lib/camera-utils.ts`
- `client/src/hooks/use-network-status.ts`
- SyncQueueManager

### Frontend Framework
- React 18
- TypeScript
- Vite
- Wouter
- TanStack Query
- React Hook Form
- Zod

### Backend & API
- Express.js
- TypeScript
- WebSocket (ws) - Real-time updates
- Passport.js
- Passport Local
- OpenID Client
- JWT
- Bcrypt.js

### Security & Middleware
- Helmet.js
- CORS
- Express Rate Limit
- Express Session
- Connect PG Simple

### AI & Chat
- Groq SDK
- Google Generative AI
- OpenAI SDK
- Zod

### Utilities
- date-fns
- nanoid
- QRCode
- QR Scanner
- jsPDF
- jsPDF AutoTable
- html2canvas
- XLSX
- Memoizee