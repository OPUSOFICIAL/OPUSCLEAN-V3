# Database Backup and Restore Guide

## Overview

This document explains how to backup and restore the OPUS database using PostgreSQL dump files.

## Current Backup

**File:** `database_dump.sql` (root directory)
- **Size:** 2597 lines
- **Tables:** 38 tables (complete schema)
- **Data:** Minimal (only admin user)
- **Date:** November 2025

## Creating a Backup

### Full Database Dump (Schema + Data)

```bash
pg_dump $DATABASE_URL --clean --no-owner --no-privileges > database_dump.sql
```

**Options explained:**
- `--clean` - Include DROP commands before CREATE
- `--no-owner` - Don't set ownership
- `--no-privileges` - Don't dump access privileges

### Schema Only (No Data)

```bash
pg_dump $DATABASE_URL --schema-only --clean --no-owner --no-privileges > schema_only.sql
```

### Data Only (No Schema)

```bash
pg_dump $DATABASE_URL --data-only --no-owner --no-privileges > data_only.sql
```

### Specific Tables Only

```bash
pg_dump $DATABASE_URL --table=work_orders --table=customers --clean --no-owner --no-privileges > specific_tables.sql
```

## Restoring a Backup

### Full Restore

```bash
psql $DATABASE_URL < database_dump.sql
```

### Restore with Progress

```bash
psql $DATABASE_URL -f database_dump.sql -v ON_ERROR_STOP=1
```

**Note:** This will stop on first error instead of continuing

### Restore Specific File

```bash
psql $DATABASE_URL < schema_only.sql
psql $DATABASE_URL < data_only.sql
```

## Common Scenarios

### 1. Reset Database to Clean State

```bash
# Restore the clean backup
psql $DATABASE_URL < database_dump.sql
```

This will:
- Drop all existing tables
- Recreate schema (37 tables)
- Insert admin user (`admin@opus.com` / `admin123`)

### 2. Create Backup Before Major Changes

```bash
# Create timestamped backup
pg_dump $DATABASE_URL --clean --no-owner --no-privileges > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 3. Export Production Data

```bash
# Export only customer data (no schema)
pg_dump $DATABASE_URL --data-only --table=customers --table=work_orders --table=users > production_data.sql
```

### 4. Clone Database

```bash
# Export from source
pg_dump $SOURCE_DATABASE_URL > clone.sql

# Import to destination
psql $DESTINATION_DATABASE_URL < clone.sql
```

## Database Schema Summary

The OPUS database contains **38 tables** organized into functional groups:

### Core System (7 tables)
- `companies` - OPUS organizations
- `customers` - Client accounts
- `customer_counters` - Work order numbering
- `users` - System users
- `custom_roles` - Permission roles
- `user_role_assignments` - User-role mappings
- `user_site_assignments` - User-site access

### Location Structure (3 tables)
- `sites` - Physical locations
- `zones` - Areas within sites
- `site_shifts` - Work shift configurations

### Work Orders (4 tables)
- `work_orders` - Main work order tracking
- `work_order_history` - Status change log
- `work_order_comments` - Comments with photos
- `pause_reasons` - Predefined pause reasons

### Clean Module (3 tables)
- `cleaning_activities` - Cleaning tasks
- `cleaning_plans` - Cleaning schedules
- `cleaning_plan_zones` - Zone assignments

### Maintenance Module (5 tables)
- `equipment` - Equipment registry
- `maintenance_activities` - Maintenance tasks
- `maintenance_plans` - Maintenance schedules
- `maintenance_plan_equipment` - Equipment assignments
- `maintenance_checklist_templates` - Checklists

### Services & Checklists (5 tables)
- `services` - Service definitions
- `service_types` - Service categories
- `checklist_templates` - Reusable checklists
- `checklist_template_items` - Checklist items
- `checklist_responses` - Execution responses

### QR Code System (2 tables)
- `qr_code_points` - QR code points
- `qr_codes` - Generated QR codes

### AI Integration (3 tables)
- `ai_integrations` - AI provider configs
- `chat_messages` - Chat history
- `chat_sessions` - Conversation sessions

### Configuration (6 tables)
- `sla_configs` - SLA rules
- `webhook_configs` - Webhook integrations
- `notification_settings` - User preferences
- `site_opening_hours` - Operating hours

## Verification After Restore

```sql
-- Check table count
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';

-- Check admin user exists
SELECT email, name, role FROM users WHERE email = 'admin@opus.com';

-- Check customer counters are reset
SELECT * FROM customer_counters;

-- Count all work orders
SELECT COUNT(*) FROM work_orders;
```

Expected results after restoring `database_dump.sql`:
- 38 tables
- 1 admin user
- 0 customer counters
- 0 work orders

## Automation Scripts

### Daily Backup Script

```bash
#!/bin/bash
# daily_backup.sh

DATE=$(date +%Y%m%d)
BACKUP_DIR="backups"
BACKUP_FILE="$BACKUP_DIR/opus_backup_$DATE.sql"

mkdir -p $BACKUP_DIR
pg_dump $DATABASE_URL --clean --no-owner --no-privileges > $BACKUP_FILE

# Keep only last 7 days
find $BACKUP_DIR -name "opus_backup_*.sql" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE"
```

### Quick Restore Script

```bash
#!/bin/bash
# quick_restore.sh

if [ -z "$1" ]; then
  echo "Usage: ./quick_restore.sh <backup_file.sql>"
  exit 1
fi

echo "⚠️  WARNING: This will REPLACE all data in the database!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

psql $DATABASE_URL < $1 -v ON_ERROR_STOP=1

echo "✅ Database restored from $1"
```

## Best Practices

1. **Always backup before major changes**
   - Before schema migrations
   - Before bulk data operations
   - Before testing destructive operations

2. **Use timestamped backups**
   - Include date/time in filename
   - Keep multiple versions
   - Rotate old backups

3. **Test restores periodically**
   - Verify backup integrity
   - Practice restore procedures
   - Confirm data completeness

4. **Separate production backups**
   - Never mix dev and production
   - Use different backup schedules
   - Store production backups securely

5. **Document restore procedures**
   - Keep this guide updated
   - Document custom scripts
   - Note any manual steps required

## Troubleshooting

### Error: "database does not exist"

```bash
# Create database first
createdb -U postgres opus_db

# Then restore
psql $DATABASE_URL < database_dump.sql
```

### Error: "permission denied"

```bash
# Use superuser or owner
psql -U postgres $DATABASE_URL < database_dump.sql
```

### Error: "relation already exists"

```bash
# Use --clean flag when creating dump
pg_dump $DATABASE_URL --clean > new_dump.sql
```

### Partial Restore Failed

```bash
# Restore schema first
psql $DATABASE_URL < schema_only.sql

# Then restore data
psql $DATABASE_URL < data_only.sql
```

## Additional Resources

- PostgreSQL Documentation: https://www.postgresql.org/docs/current/backup.html
- Drizzle ORM Migrations: https://orm.drizzle.team/docs/migrations
- OPUS Schema Definition: `shared/schema.ts`

## Current Database State

**Last Reset:** November 2025  
**Admin Credentials:** `admin@opus.com` / `admin123`  
**Work Order Counter:** Reset to 0 (next will be #1)  
**AI Integration:** Groq (Llama 3) ready for configuration  
**Status:** Clean slate, ready for testing
