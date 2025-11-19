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

**Permission System Refactoring (Nov 19, 2025):**
- **FASE 1 COMPLETA**: Foundation for granular permission-based access control
  - `getUserPermissions(userId)`: Helper that consolidates all user permissions from custom roles
  - `requirePermission(permission)`: Middleware for endpoint-level permission checks
  - `validatePermissionsByUserType()`: Function to validate permission compatibility with userType
  - OPUS_ONLY_PERMISSIONS: Constants defining permissions exclusive to opus_user (customers_*, opus_users_*, roles_manage)
  - CLIENT_ALLOWED_PERMISSIONS: All other permissions allowed for customer_user
  - Test endpoints: `/api/auth/my-permissions`, `/api/test/permissions/*` for validation
  - Detailed console logs for permission checks and denials
  - Both systems coexist: Old role-based (enum) + New permission-based (granular)
- **FASE 2 COMPLETA**: UserType validation in custom roles endpoints
  - POST `/api/roles`: Validates permissions when creating custom roles (blocks OPUS permissions for customer_user)
  - PATCH `/api/roles/:id`: Validates permissions when editing custom roles
  - POST `/api/users/:userId/roles`: Validates role assignment compatibility with target user's userType
  - Comprehensive error messages with invalidPermissions array and helpful hints
  - Audit logs: `[ROLE CREATE DENIED]`, `[ROLE UPDATE DENIED]`, `[ROLE ASSIGNMENT DENIED]`
  - Security: customer_user cannot escalate privileges or assign OPUS-only permissions
  - Documentation: `FASE_2_VALIDACAO_PERMISSOES.md`
- **FASE 3 COMPLETA**: Frontend filtering of OPUS-only permissions
  - Added `userType` field to User interface (`client/src/hooks/useAuth.ts`)
  - OPUS_ONLY_PERMISSIONS constants mirrored in frontend (`client/src/pages/roles.tsx`)
  - Dynamic permission filtering: opus_user sees all 45 permissions, customer_user sees only 36 (excludes OPUS permissions)
  - Improved UX: customer_user cannot see or select permissions they cannot use
  - Layered security: Backend validation (FASE 2) + Frontend filtering (FASE 3)
  - Documentation: `FASE_3_FRONTEND_FILTRO_PERMISSOES.md`
- **Query Optimization Fix**: Changed TanStack Query staleTime from 0 to 5 minutes
  - Eliminated infinite query loops causing excessive database logs
  - Permissions data cached for 5 minutes, auto-invalidated on mutations
  - Reduced database load and improved frontend performance

**Enhanced Shift-Based Scheduling (Nov 17, 2025):**
- Shift activities (cleaning & maintenance) now support **weekday filtering** in addition to shift selection
- Users can configure activities to occur on specific days (e.g., "morning shift only on Mon/Wed/Fri")
- Frontend calendar displays shift activities only on selected weekdays
- Backend work order generation creates orders only for selected weekday+shift combinations
- Form validation requires at least one weekday selection for shift-based activities
- Fully implemented in both Clean and Maintenance modules with consistency
- Retrocompatible: Activities without weekday configuration work as before (all days)
- Documentation: `MELHORIA_TURNOS_COM_DIAS_DA_SEMANA.md`

**Full-Featured Edit Forms (Nov 17, 2025):**
- Activity edit forms now use the same complete form as creation, just pre-filled with existing values
- Both Clean (`cleaning-schedule.tsx`) and Maintenance (`maintenance-plans.tsx`) modules updated
- `CreateCleaningActivityModal` and `CreateMaintenanceActivityModal` components now support optional `editingActivity` prop for edit mode
- When `editingActivity` is provided, form auto-populates with existing data via `useEffect`
- Edit mode uses dedicated `updateActivityMutation` (PUT request) instead of create mutation
- Modal titles and button labels dynamically adapt based on mode (Create vs Edit)
- Removed limited/stub edit modals and replaced with full-featured form experience
- Pattern: Single reusable component for both create and edit operations

**Performance Optimizations (Nov 17, 2025):**
- **Database Indexes**: Added indexes on frequently queried columns for faster report generation
  - work_orders: `customerId`, `module`, `status`, `zoneId` (indexed individually)
  - zones: `siteId`, `module` (indexed individually)
  - sites: `customerId`, `module` (indexed individually)
- **Parallel Query Execution**: Refactored report functions to use `Promise.all` for parallelizing independent queries
  - `getGeneralReport`: Parallel fetching of zones and users data
  - `getOperatorPerformance`: Parallel fetching of zones and users data
  - Reduces overall query execution time by running independent operations concurrently
- **Real Data Integrity**: All reports use 100% authentic data with no simulations
  - Quality Index: Calculated from actual checklist ratings
  - Resource Utilization: Based on real operator assignments
  - Completion Times: Derived from actual timestamps (startedAt → completedAt)
  - SLA Metrics: Calculated from real scheduled vs completed dates
- **Applied**: Database schema changes pushed via `drizzle-kit push`

**Photo Upload Optimization (Nov 18, 2025):**
- **Automatic Image Compression**: All photos automatically compressed before upload using Canvas API
  - Resolution: Max 1920x1920 pixels (maintains aspect ratio)
  - Quality: 60% (reduced from 90%)
  - Size reduction: 75-85% smaller files
  - Compression function in `client/src/lib/camera-utils.ts`
- **Reduced Capture Quality**: Camera capture quality reduced from 90% to 60%
- **Smaller Batch Sizes**: Sync batch size reduced from 50 to 5 photos per upload
  - More reliable uploads on poor connections
  - Faster recovery from errors
  - Better progress feedback
- **Universal Application**: Compression applied to all capture methods
  - Camera capture
  - Gallery selection
  - Multiple image selection
  - Web fallback (file input)
- **Performance Impact**: 5-9x faster upload times on 2G/3G connections
- **Monitoring**: Detailed compression logs in console (original size, compressed size, reduction %)
- **Documentation**: `OTIMIZACAO_FOTOS_CONEXAO_LENTA.md`

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
- Hybrid architecture: Local assets (no server.url) + Absolute API URLs (Capacitor.isNativePlatform detection)
- API requests auto-detect environment: Relative URLs in browser, absolute URLs in APK
- QR scanner with offline detection: Uses IndexedDB when offline, absolute API when online
- Visual offline indicator: Orange "Offline" badge in scanner header when disconnected
- Mobile Dashboard fix (Nov 2025): Auto-detects APK vs browser environment using Capacitor.isNativePlatform()
  - APK: Uses absolute URLs (hardcoded Replit URL with fallback to VITE_API_BASE_URL)
  - Browser: Uses relative URLs for same-origin requests
  - Fixes "0 Available Work Orders" issue in APK
- **CRITICAL FIX (17 Nov 2025):** Fixed "Não foi possível carregar a ordem de serviço" error
  - Root cause: VITE_REPLIT_DOMAINS not configured, causing empty base URL
  - Solution: Hardcoded Replit URL in `mobile-work-order-execute.tsx` and `mobile-work-order-details.tsx`
  - Pattern: `import.meta.env.VITE_API_BASE_URL || 'https://52e46882-...-ga4lr9ry58vz.spock.replit.dev'`
  - When migrating Replit: Update hardcoded URL in both files
  - See: `CORRECAO_URGENTE_APK.md` for full details
- QR Execution endpoint: Traverses hierarchy (QR Point → Zone → Site → Customer) to fetch scheduled work orders
  - Returns work orders filtered by zone and status (excludes completed/cancelled)
  - Security: Operators see only their assigned + unassigned work orders
- See: `HYBRID_ARCHITECTURE.md` for technical architecture details
- See: `GERAR_APK_AGORA.md` for latest APK generation instructions

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