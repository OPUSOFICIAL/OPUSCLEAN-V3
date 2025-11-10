# OPUS - Documentation Index

## Project Overview

OPUS is a comprehensive facilities management platform supporting cleaning (OPUS Clean) and maintenance (OPUS Manutenção) operations with AI-powered chat assistance.

## Quick Links

### Getting Started
- [Project Summary](../replit.md) - Complete project overview and architecture
- [Database Backup Guide](database-backup.md) - How to backup and restore the database
- [Groq AI Models](groq-models.md) - AI model selection and configuration guide

### Current Status
- **Database:** Clean slate (37 tables, only admin user)
- **Admin Login:** `admin@opus.com` / `admin123`
- **Backup Available:** `database_dump.sql` (87KB, root directory)

## Documentation Files

### 1. Project Summary (`../replit.md`)
Main project documentation covering:
- System architecture and technical stack
- Feature specifications (work orders, AI, multi-tenancy)
- Database schema (38 tables)
- External dependencies
- User preferences and design guidelines
- Recent changes and testing workflow

### 2. Database Backup Guide (`database-backup.md`)
Complete guide for database operations:
- Creating backups (full, schema-only, data-only)
- Restoring databases
- Common scenarios and troubleshooting
- Automation scripts
- Best practices
- Current database state

### 3. Groq AI Models (`groq-models.md`)
AI integration documentation:
- Available Groq models and capabilities
- Model selection guide
- Rate limits and pricing
- Function calling specifications
- Testing and validation procedures
- Comparison with other providers

## Key Features

### 🏢 Multi-Tenancy
- Hierarchical structure: Companies → Customers → Sites → Zones
- Module-specific data isolation (Clean vs Maintenance)
- Role-based access control (RBAC)
- Customer-specific work order numbering

### 📋 Work Order Management
- Programmed and corrective work orders
- SLA tracking and priority management
- Status history and comments with photos
- Multi-collaborator tracking
- Mobile operator support

### 🤖 AI Assistant
- Multiple providers: Groq (free), Google Gemini (free), OpenAI (paid)
- Function calling for administrative tasks
- Chat history and context management
- Real-time work order queries and updates

### 📱 QR Code System
- Execution QRs for internal work orders
- Public QRs for service requests
- Automatic work order generation

### 🔧 Maintenance Module
- Equipment registry and tracking
- Maintenance plans and activities
- Checklist templates
- Virtual calendar (future implementation)

### 🧹 Cleaning Module
- Cleaning activities and schedules
- Zone-based planning
- Recurring task management

### 🔐 Authentication
- Microsoft SSO (Entra ID)
- Email/password login
- JWT tokens
- Session management

## Technology Stack

### Frontend
- **Framework:** React 18 + TypeScript
- **Routing:** Wouter
- **State Management:** TanStack Query
- **UI Components:** shadcn/ui (Radix UI primitives)
- **Styling:** Tailwind CSS
- **Forms:** React Hook Form + Zod validation
- **Icons:** Lucide React, React Icons

### Backend
- **Framework:** Express.js + TypeScript
- **Database:** PostgreSQL (Neon hosting)
- **ORM:** Drizzle ORM
- **Authentication:** Passport.js (Local + OpenID)
- **Security:** Helmet, CORS, Rate Limiting
- **AI Integration:** Groq, OpenAI, Google Generative AI

### Development Tools
- **Build Tool:** Vite
- **Package Manager:** npm
- **Environment:** Replit (cloud-based)
- **Database Migrations:** Drizzle Kit

## Database Schema

The OPUS database consists of **38 tables** organized into functional groups:

| Group | Tables | Purpose |
|-------|--------|---------|
| Core System | 7 | Companies, customers, users, roles |
| Location | 3 | Sites, zones, shifts |
| Work Orders | 4 | Orders, history, comments, pauses |
| Clean Module | 3 | Activities, plans, zone assignments |
| Maintenance | 5 | Equipment, activities, plans, checklists |
| Services | 5 | Service definitions and checklists |
| QR Codes | 2 | QR code points and generation |
| AI Integration | 3 | AI configs, chat messages, sessions |
| Configuration | 6 | SLAs, webhooks, notifications, hours |

**Total:** 38 tables

Full schema available in: `shared/schema.ts`

## Getting Started

### 1. Initial Setup

```bash
# Database is already clean and ready
# Admin user already created

# Login credentials:
Email: admin@opus.com
Password: admin123
```

### 2. Configure Your Environment

1. **Create a Client (Customer)**
   - Navigate to Clientes page
   - Add your first customer

2. **Add a Site (Location)**
   - Navigate to Sites page
   - Create a site for your customer
   - Choose module (Clean or Maintenance)

3. **Define Zones**
   - Navigate to Zones page
   - Add zones within your site

4. **Configure AI Integration**
   - Navigate to `/ai-integrations`
   - Add Groq API key (free)
   - Select model: `llama-3-groq-8b-tool-use`
   - Test connection
   - Set as default

### 3. Start Using OPUS

- Create work orders manually
- Use AI chat for administrative queries
- View dashboard analytics
- Manage users and permissions

## Development Workflow

### Making Changes

```bash
# Install packages
npm install <package-name>

# Push schema changes
npm run db:push

# Run development server (already running)
npm run dev
```

### Database Operations

```bash
# Create backup
pg_dump $DATABASE_URL --clean --no-owner --no-privileges > my_backup.sql

# Restore backup
psql $DATABASE_URL < my_backup.sql

# Reset to clean state
psql $DATABASE_URL < database_dump.sql
```

### Testing

```bash
# Run tests (when available)
npm test

# Lint code
npm run lint

# Type check
npm run typecheck
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login with email/password
- `POST /api/auth/logout` - Logout current session
- `GET /api/auth/user` - Get current user info

### Work Orders
- `GET /api/work-orders` - List work orders
- `POST /api/work-orders` - Create work order
- `PATCH /api/work-orders/:id` - Update work order
- `GET /api/work-orders/:id` - Get work order details

### AI Chat
- `POST /api/chat` - Send chat message
- `GET /api/chat/sessions` - List chat sessions
- `DELETE /api/chat/sessions/:id` - Delete chat session

### Customers & Sites
- `GET /api/customers` - List customers
- `POST /api/customers` - Create customer
- `GET /api/sites` - List sites
- `POST /api/sites` - Create site

## Troubleshooting

### Common Issues

**Issue:** Can't login  
**Solution:** Verify credentials: `admin@opus.com` / `admin123`

**Issue:** Database connection error  
**Solution:** Check `DATABASE_URL` environment variable

**Issue:** AI chat not working  
**Solution:** Configure AI integration in `/ai-integrations`

**Issue:** Work orders not appearing  
**Solution:** Check module filter and customer selection

### Database Issues

**Issue:** Schema mismatch  
**Solution:** Run `npm run db:push --force`

**Issue:** Need to reset database  
**Solution:** `psql $DATABASE_URL < database_dump.sql`

## Support & Resources

- **Project Repository:** Current Replit project
- **Database Schema:** `shared/schema.ts`
- **API Routes:** `server/routes.ts`
- **Frontend Pages:** `client/src/pages/`

## Recent Updates (November 2025)

- ✅ Complete database reset (all 37 tables cleaned)
- ✅ Groq (Llama 3) integration implemented
- ✅ AI function calling with 5 administrative tools
- ✅ Date serialization bug fixed in AI responses
- ✅ Database backup created (`database_dump.sql`)
- ✅ Documentation updated and organized

## Next Steps

### For Developers
1. Implement monthly work order scheduler
2. Add plan-based work order generation
3. Create virtual calendar for maintenance module
4. Build mobile operator app
5. Add report generation features

### For Administrators
1. Create customer accounts
2. Configure sites and zones
3. Set up AI integration with Groq
4. Create work order templates
5. Invite team members

## License & Contact

This is a proprietary facilities management platform. All rights reserved.

---

**Last Updated:** November 2025  
**Version:** 1.0.0  
**Status:** Development - Clean Database Ready for Testing
