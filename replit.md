# Acelera it - Full Facilities - Project Summary

## Overview

Acelera it Full Facilities is a modular platform for facilities management, currently supporting Clean and Maintenance modules. It aims to streamline operations through web administration and mobile applications, offering features like scheduling, work order management, QR code-based task execution, and public service requests. Designed for multi-company, multi-site, and multi-zone environments, it provides real-time analytics and a scalable solution for modern facilities management.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### UI/UX Decisions

The system features an **enterprise-grade, corporate design** targeting B2B clients in the facilities management industry. The design emphasizes professionalism, trust, and measurable ROI, utilizing `shadcn/ui` with Radix UI primitives and Tailwind CSS. Module-specific colors (blue for Clean, orange for Maintenance) are used for focal elements. The design is responsive, optimized for desktop and mobile, with touch-friendly elements.

**Pre-Login Pages Design Philosophy**:
- **Landing Page**: Corporate SaaS aesthetic with facilities management focus
  - Fixed frosted glass top bar (bg-white/80 backdrop-blur-lg) with Acelera Full Facilities logo (100px height with negative margins) and "Acessar Sistema" button
  - Hero section with strong value proposition: "Transforme a Gestão de Facilities da sua Empresa"
  - ROI-focused metrics (45% cost reduction, 3x productivity, 99% uptime, 24/7 support)
  - **Interactive dashboard carousel** with auto-advancing slides (4 seconds) showing different system views:
    - Dashboard Facilities (Overview with OSs and performance metrics)
    - Manutenção (Work orders with status tracking)
    - Analytics (Performance charts and SLA metrics)
    - Calendário (Scheduled maintenance and activities)
  - Clickable navigation dots for manual slide control
  - Smooth AnimatePresence transitions between slides
  - Business-focused benefits highlighting operational efficiency
  - Features section with facilities-specific icons (Building2, Wrench, ClipboardCheck, TrendingUp)
  - Professional color scheme: slate/gray with blue accents
  - Clean gradient backgrounds (slate-50 to white)
  - Trust-building elements and enterprise messaging

- **Login Page**: Minimalist corporate design
  - Simple top bar with only "Voltar" button (logo removed for cleaner design)
  - Large centered Acelera Full Facilities logo (200px height) above form
  - Clean white card with subtle shadows
  - Direct email/password login (Microsoft SSO removed)
  - Professional form styling with icon-enhanced inputs
  - Security messaging: "Plataforma Enterprise Segura"
  - Minimal decorative elements (subtle gradient orbs)

- **Module Selection**: Professional module cards with ROI emphasis
  - Large centered Acelera Full Facilities logo (128px height) at top
  - Side-by-side cards for Clean and Maintenance modules
  - Each card features: module icon, title, subtitle, ROI metrics, feature list
  - Clean module: 45% cost reduction, 3x efficiency
  - Maintenance module: 60% less downtime, 2.5x asset lifespan
  - Feature lists with checkmarks highlighting operational benefits
  - Gradient buttons matching module colors

**Visual Elements**:
- Acelera Full Facilities logo (attached_assets/acelera-full-facilities-logo.png) with triangular "A" symbol and blue detail
- Logo sizes: Landing top bar (100px with negative margins), Login center (200px), Module selection (128px)
- Icons from lucide-react representing facilities operations (Building2, Wrench, ClipboardCheck, Users, TrendingUp, Shield)
- Custom Microsoft logo SVG for SSO
- Framer Motion animations for professional, subtle transitions
- Card-based layouts with hover effects
- Gradient buttons: from-blue-600 to-blue-500 (Clean), from-orange-600 to-orange-500 (Maintenance)

**Layout**: All internal pages use full-width layout (`w-full px-6`) instead of constrained max-width (`max-w-7xl`), allowing content to expand to the full available width between sidebar and screen edge, eliminating white space on larger displays.

### Technical Implementations

The frontend uses React and TypeScript, with Wouter for routing and TanStack Query for data management, built with Vite. The backend is an Express.js server in TypeScript, following RESTful API principles with Drizzle ORM for type-safe PostgreSQL interactions.

### Feature Specifications

**Multi-Tenancy**: Implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with robust role-based access control and client/module-specific data isolation.

**Equipment Management (Maintenance Module)**: Supports direct equipment selection for checklist assignment and maintenance planning. Includes an equipment history viewer for work order history.

**QR Code System**: Facilitates Execution QRs for staff work order management and Public QRs for end-users to submit service requests, automatically generating corrective work orders.

**Work Order Management**: Manages programmed, internal corrective, and public corrective work orders, tracking status, SLA, priority, assignments, comments with photo attachments, and multiple responsible collaborators. The Maintenance module uses a virtual calendar for future activity display and a monthly automated scheduler for work order creation. Work order numbering is customer-specific.

**AI Integration**: AI integration configuration page allows OPUS users to configure AI providers (OpenAI, Google Gemini, Groq, Azure OpenAI, Cohere, etc.) for future use. The chat assistant functionality is currently in development and has been temporarily disabled. A development notice is displayed on the AI Integrations page informing users that the assistant will be available soon.

**Authentication and Authorization**: Supports Microsoft SSO (Entra ID) and email/password authentication. Security includes JWT, Bcrypt, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access with strict module-based access control.

**Dashboard**: Provides analytical charts for work orders, including distribution by priority and location, average completion time, and activity trends.

**TV Mode Dashboard**: Real-time dashboard specifically designed for public display (TV screens) showing live metrics and gamified leaderboards. Features auto-refresh every 10 seconds, displaying work order statistics (resolved vs unresolved) via donut chart and a top 10 collaborators leaderboard ranked by completed work orders. Filtered by active client and module. Accessible at `/tv-mode`.

**User Management**: Offers full CRUD operations for users, including client user creation and custom role assignment.

### System Design Choices

The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning, schema pushing, and dependency installation. It's designed to be modular, supporting new operational modules with distinct theming and data isolation. The term "Site" is presented as "Local" in the UI.

## External Dependencies

### Database & Storage
- **PostgreSQL** (Neon hosting)
- **Drizzle ORM**
- **Drizzle Kit**

### UI Components & Styling
- **Radix UI**
- **shadcn/ui**
- **Tailwind CSS**
- **Lucide React**
- **React Icons**
- **Framer Motion**

### Frontend Framework
- **React 18**
- **TypeScript**
- **Vite**
- **Wouter**
- **TanStack Query**
- **React Hook Form**
- **Zod**

### Backend & API
- **Express.js**
- **TypeScript**
- **Passport.js**
- **Passport Local**
- **OpenID Client**
- **JWT**
- **Bcrypt.js**

### Security & Middleware
- **Helmet.js**
- **CORS**
- **Express Rate Limit**
- **Express Session**
- **Connect PG Simple**

### AI & Chat
- **Groq SDK**
- **Google Generative AI**
- **OpenAI SDK**
- **Zod** (for function calling schema validation)

### Utilities
- **date-fns**
- **nanoid**
- **QRCode**
- **QR Scanner**
- **jsPDF**
- **jsPDF AutoTable**
- **html2canvas**
- **XLSX**
- **Memoizee**