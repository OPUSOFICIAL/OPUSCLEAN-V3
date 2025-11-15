# Acelera it - Full Facilities - Project Summary

## Overview

Acelera it Full Facilities is a modular platform for facilities management, currently supporting Clean and Maintenance modules. It aims to streamline operations through web administration and mobile applications, offering features like scheduling, work order management, QR code-based task execution, and public service requests. Designed for multi-company, multi-site, and multi-zone environments, it provides real-time analytics and a scalable solution for modern facilities management, focusing on efficiency, cost reduction, and increased productivity.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### UI/UX Decisions

The system features an enterprise-grade, corporate design using `shadcn/ui` with Radix UI primitives and Tailwind CSS. It emphasizes professionalism and ROI, utilizing module-specific colors (blue for Clean, orange for Maintenance) and responsive design. Pre-login pages feature a corporate SaaS aesthetic with interactive dashboards, minimalist login, and professional module selection cards highlighting ROI. Visual elements include custom branding, Lucide React icons, Framer Motion animations, and full-width layouts for internal pages.

### Technical Implementations

The frontend uses React and TypeScript with Wouter for routing and TanStack Query for data management. The backend is an Express.js server in TypeScript, using Drizzle ORM for PostgreSQL. Key features include a hierarchical multi-tenancy model with role-based access control, comprehensive equipment management, QR code-based task execution and service requests, and robust work order management with virtual calendars and automated scheduling. Authentication supports Microsoft SSO and email/password, secured with JWT, Bcrypt, and other best practices. An AI integration configuration page is present, with chat assistant functionality under development. A TV Mode Dashboard provides real-time, gamified metrics. User management offers full CRUD and custom role assignments.

An offline sync infrastructure supports an offline-first Android APK with batch synchronization. This includes database schema enhancements for sync metadata, security hardening with serializable transactions and UPSERT-based idempotency, and secure batch API endpoints. The frontend utilizes IndexedDB for offline storage, a priority-based sync queue with exponential backoff, and automatic parent-child ID linkage. Pages like `mobile-work-order-execute.tsx` and `qr-execution.tsx` are adapted for offline use, validating fields and saving to IndexedDB when disconnected. A singleton `SyncQueueManager` ensures a 3-phase sequential batching strategy for work orders, checklist executions, and attachments, with robust error handling and auto-sync on reconnection.

### System Design Choices

The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning and modular design for future expansion. It includes an adaptive subdomain-based branding system that dynamically applies client branding (logos and module colors) based on the subdomain, with robust fallback mechanisms and asset serving.

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
- Offline-first architecture with IndexedDB v4
- Native plugins: @capacitor/network@7.0.2 (network detection), @capacitor/camera@7.0.2 (native camera/gallery)
- Camera utils: `client/src/lib/camera-utils.ts` (single/multiple photos, automatic web fallback)
- Network hook: `client/src/hooks/use-network-status.ts` (real-time connectivity status)
- SyncQueueManager: Auto-sync on reconnection via Network plugin
- Build config: `ANDROID_BUILD.md`, `GERAR_APK.md`, `📱_COMO_GERAR_APK.txt`, `CAMERA_FIX.md`, `OFFLINE_FIX.md`
- APK generation: MUST compile locally (requires Android SDK not available on Replit)
- Build scripts: `gerar-apk.sh` (Mac/Linux), `gerar-apk.bat` (Windows)
- Build steps: `npm run build:android` → `npx cap sync android` → `./gradlew assembleDebug`
- Platform added: `android/` (native Android project)
- IndexedDB stores: qrPoints, zones, scheduledWorkOrders, checklistTemplates
- OfflineExecutionNormalizer: Deterministic WO prioritization (scheduledStartAt → createdAt → id)
- Android permissions configured: CAMERA, READ/WRITE_EXTERNAL_STORAGE, READ_MEDIA_IMAGES (Android 13+)
- Capacitor config: NO server.url (truly offline-first with local bundled assets via capacitor:// protocol)
- QR scanner with offline detection: Uses IndexedDB when offline, API when online
- Visual offline indicator: Orange "Offline" badge in scanner header when disconnected

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
- Zod (for function calling schema validation)

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