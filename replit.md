# Acelera it - Full Facilities - Project Summary

## Overview

Acelera it Full Facilities is a modular facilities management platform, currently encompassing Clean module for cleaning and Maintenance module for maintenance. It aims to streamline operations through web-based administration and mobile applications, offering features like scheduling, work order management, QR code-based task execution, and public service requests. Designed for multi-company, multi-site, and multi-zone environments, Acelera it provides real-time analytics and a scalable solution for modern facilities management.

## User Preferences

Preferred communication style: Simple, everyday language.

## Current Database State (November 2025)

**Status:** Database completely reset and clean (37 tables)

**Default Admin Credentials:**
- Email: `admin@opus.com`
- Password: `admin123`
- Modules: Clean + Maintenance
- Type: Administrator

**Database Backup:**
- Full dump available: `database_dump.sql` (2597 lines)
- Contains complete schema with 38 tables
- Includes all constraints, types, and relations
- Can be restored using: `psql $DATABASE_URL < database_dump.sql`

**Work Order Counters:**
- All customer counters reset to 0
- Next work orders will start at #1 for each customer

## System Architecture

### UI/UX Decisions

The system features a modern, predominantly white design with subtle gradients and glassmorphism effects for depth and sophistication. It utilizes `shadcn/ui` with Radix UI primitives and Tailwind CSS. Module-specific colors (blue for Clean, orange for Manutenção) are used for identification on focal elements like buttons and badges. The design is responsive, optimized for both desktop and mobile, with touch-friendly elements and streamlined navigation. The mobile dashboard highlights in-progress work orders with a distinct green-to-emerald gradient card and a dedicated statistics card.

**Landing Page**: Ultra-modern presentation page displayed before login, featuring dark glassmorphism aesthetics with animated gradient orbs (blue, purple, cyan), mouse parallax effects, floating particles, smooth Framer Motion animations, and interactive feature cards. The landing showcases the "Acelera it - Full Facilities" brand with a gradient text logo and provides an elegant entry point to the system.

### Technical Implementations

The frontend is built with React and TypeScript, using Wouter for routing and TanStack Query for data management, all powered by Vite. The backend is an Express.js server in TypeScript, following RESTful API principles with a layered architecture, utilizing Drizzle ORM for type-safe PostgreSQL interactions.

### Feature Specifications

**Multi-Tenancy**: Implements a hierarchical multi-tenancy model (Companies > Sites > Zones) with robust role-based access control and client/module-specific data isolation. Module-specific pages include verification to prevent cross-module access.

**Equipment Management (Maintenance Module)**: Supports direct equipment selection for checklist assignment and maintenance planning, allowing templates and plans to target single or multiple equipment items. All equipment management is customer and module-specific. Equipment history viewer feature allows users to view the complete service order history for each equipment with a "Visualizar" button (Eye icon) that opens a modal displaying all work orders associated with that equipment, including status, priority, dates, and observations.

**QR Code System**: Facilitates Execution QRs for internal staff work order management and Public QRs for end-users to submit service requests, automatically generating corrective work orders.

**Work Order Management**: Manages programmed, internal corrective, and public corrective work orders, tracking status, SLA, priority, assignments, and supporting comments with photo attachments. The Maintenance module uses a virtual calendar for future activity display and defers actual work order creation to a monthly automated scheduler for database efficiency. Interactive activity management allows toggling activity status, affecting future work order generation. Work order numbering is now customer-specific, managed by `customer_counters`. Mobile operators can view and resume paused work orders regardless of which collaborator originally paused them, enabling better team coordination. Work orders track multiple responsible collaborators (`assignedUserIds` array), automatically adding each collaborator who works on the order (start, pause, resume, complete) without duplicates, creating a complete work history.

**AI Integration (Chat Assistant)**: Comprehensive AI-powered chat assistant with function calling capabilities for administrative tasks. Supports multiple AI providers:
- **Groq (Llama 3)** - Free, ultra-fast, recommended for OPUS
  - Model: `llama-3-groq-8b-tool-use` (specialized for function calling)
  - Alternative: `llama-3.3-70b-versatile` (larger, more capable)
  - Rate limits: 30 RPM, 14,400 RPD
  - No cost, generous free tier
- **Google Gemini** - Free with limitations
  - Model: `gemini-2.0-flash-exp`
  - Rate limits: 15 RPM
  - Free tier available
- **OpenAI** - Paid, high-quality
  - Models: GPT-4o, GPT-4o-mini, GPT-4-turbo
  - Requires payment
- **Azure OpenAI** - Enterprise-grade
- **Cohere** - Alternative provider
- **HuggingFace** - Open-source models

**AI Function Calling**: The AI assistant has access to 5 administrative functions:
1. `search_work_orders` - Search and filter work orders
2. `get_work_order_details` - Get detailed information about specific work orders
3. `update_work_order_status` - Update work order status and assignments
4. `get_work_order_statistics` - Get statistics and metrics
5. `create_work_order` - Create new work orders programmatically

**Date Serialization Fix**: All Date objects in AI function responses are properly serialized to ISO strings before returning to prevent JSON serialization errors.

**Authentication and Authorization**: Supports Microsoft SSO (Entra ID) and email/password authentication. Security includes JWT, Bcrypt, rate limiting, data sanitization, CORS, Helmet.js, and SQL injection prevention. A custom role system provides granular, permission-based access. Strict module-based access control is implemented for both web and mobile platforms.

**Dashboard**: Provides analytical charts for work orders, including distribution by priority and location, average completion time, and activity trends, with integrated visual indicators for goals.

**User Management**: Offers full CRUD operations for users, including client user creation and custom role assignment, with clear indicators for roles and mobile access.

### System Design Choices

The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning, schema pushing, and dependency installation. It's designed to be modular, supporting new operational modules with distinct theming and data isolation. The term "Site" is presented as "Local" in the UI.

## Database Schema (37 Tables)

### Core Tables
- `companies` - OPUS companies/organizations
- `customers` - Customer/client accounts
- `customer_counters` - Customer-specific work order numbering
- `users` - System users with role-based access
- `custom_roles` - Custom permission roles
- `user_role_assignments` - User-role associations
- `user_site_assignments` - User-site access control

### Location & Structure
- `sites` - Physical locations (presented as "Locais")
- `zones` - Areas within sites
- `site_shifts` - Work shifts configuration

### Work Orders & Execution
- `work_orders` - Main work order tracking
- `work_order_history` - Status change history
- `work_order_comments` - Comments with photo attachments
- `pause_reasons` - Predefined pause reasons

### Clean Module
- `cleaning_activities` - Cleaning tasks and schedules
- `cleaning_plans` - Cleaning service plans
- `cleaning_plan_zones` - Zone assignments for plans

### Maintenance Module
- `equipment` - Equipment/asset registry
- `maintenance_activities` - Maintenance tasks
- `maintenance_plans` - Maintenance schedules
- `maintenance_plan_equipment` - Equipment assignments
- `maintenance_checklist_templates` - Reusable checklists

### Services & Checklists
- `services` - Service definitions
- `service_types` - Service categories
- `checklist_templates` - Reusable checklist templates
- `checklist_template_items` - Checklist item definitions
- `checklist_responses` - Execution responses

### QR Code System
- `qr_code_points` - QR code points (execution & public)
- `qr_codes` - Generated QR codes

### AI Integration
- `ai_integrations` - AI provider configurations
- `chat_messages` - Chat history and context
- `chat_sessions` - Chat conversation sessions

### Configuration & Settings
- `sla_configs` - SLA rules and thresholds
- `webhook_configs` - Webhook integrations
- `notification_settings` - User notification preferences
- `site_opening_hours` - Operating hours per site

## External Dependencies

### Database & Storage
- **PostgreSQL** - Primary database (Neon hosting)
- **Drizzle ORM** - Type-safe database queries
- **Drizzle Kit** - Schema migrations and management

### UI Components & Styling
- **Radix UI** - Headless component primitives
- **shadcn/ui** - Pre-built accessible components
- **Tailwind CSS** - Utility-first styling
- **Lucide React** - Icon library
- **React Icons** - Company logos (Simple Icons)
- **Framer Motion** - Animations

### Frontend Framework
- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Wouter** - Lightweight routing
- **TanStack Query** - Data fetching and caching
- **React Hook Form** - Form management
- **Zod** - Schema validation

### Backend & API
- **Express.js** - Web framework
- **TypeScript** - Server-side type safety
- **Passport.js** - Authentication middleware
- **Passport Local** - Email/password auth
- **OpenID Client** - Microsoft SSO (Entra ID)
- **JWT** - Token-based authentication
- **Bcrypt.js** - Password hashing

### Security & Middleware
- **Helmet.js** - Security headers
- **CORS** - Cross-origin resource sharing
- **Express Rate Limit** - API rate limiting
- **Express Session** - Session management
- **Connect PG Simple** - PostgreSQL session store

### AI & Chat
- **Groq SDK** - Llama 3 integration (free, ultra-fast)
- **Google Generative AI** - Gemini integration (free tier)
- **OpenAI SDK** - GPT models (paid)
- **Zod** - Function calling schema validation

### Utilities
- **date-fns** - Date manipulation
- **nanoid** - Unique ID generation
- **QRCode** - QR code generation
- **QR Scanner** - QR code reading
- **jsPDF** - PDF generation
- **jsPDF AutoTable** - PDF tables
- **html2canvas** - Screenshot capture
- **XLSX** - Excel file handling
- **Memoizee** - Function memoization

### Development Tools
- **Drizzle Kit** - Database schema management
- **TypeScript ESBuild** - Fast compilation
- **Autoprefixer** - CSS vendor prefixes
- **PostCSS** - CSS processing

## Key Documentation Files

- `docs/groq-models.md` - Groq (Llama 3) model documentation and selection guide
- `database_dump.sql` - Complete database backup (schema + data)
- `replit.md` - This project summary

## Testing Workflow (Fresh Start)

1. **Login**: Use `admin@opus.com` / `admin123`
2. **Create Client**: Add a test customer
3. **Create Site**: Add a physical location
4. **Create Zones**: Add areas within the site
5. **Configure AI**: Set up Groq integration with API key
6. **Create Work Orders**: Test manual creation with hierarchical form
7. **Test Chat AI**: Interact with AI assistant using administrative functions
8. **Test Mobile**: Access mobile endpoints for operator workflows

## Recent Changes (November 2025)

- ✅ Implemented complete Groq (Llama 3) integration as free AI provider
- ✅ Added AI provider configuration UI with test functionality
- ✅ Fixed Date serialization bug in AI function responses
- ✅ Database completely reset (all 37 tables cleaned)
- ✅ Admin user recreated with default credentials
- ✅ Work order counters reset to start from #1
- ✅ Created comprehensive Groq models documentation
- ✅ Database dump created for backup and migration

## Known Issues & Future Improvements

- LSP diagnostics in `server/storage.ts` (38 warnings) - non-blocking, related to type inference
- Monthly scheduler implementation pending (generates next month's work orders)
- Plan-based work order generation (from start date to end of current month)
- Virtual calendar activity display for maintenance module
