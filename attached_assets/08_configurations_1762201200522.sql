-- ============================================================================
-- OPUS Database Dump - System Configurations
-- Generated: November 3, 2025
-- ============================================================================

-- SLA Configs
-- Total: 0 records
-- Note: No SLA configurations defined yet
-- Module field: 'clean' or 'maintenance'

-- Dashboard Goals
-- Total: 2 records
INSERT INTO dashboard_goals (id, company_id, goal_type, goal_value, current_period, is_active, created_at, updated_at, module) VALUES
('6a972bd1-3c42-4905-ba78-e2b1e4220ce4', 'company-admin-default', 'eficiencia_operacional', 100.00, '2025-09', false, '2025-09-30 21:09:36.742578', '2025-09-30 21:09:38.627842', 'clean'),
('c3ab769c-4862-44ba-bf11-32e0fee8c13d', 'company-admin-default', 'eficiencia_operacional', 95.00, '2025-10', true, '2025-10-10 16:44:04.537352', '2025-10-10 16:44:04.537352', 'clean');

-- Equipment
-- Total: 0 records
-- Note: No equipment registered yet
-- Module field: 'maintenance' (default for equipment)

-- Maintenance Checklist Templates
-- Total: 0 records
-- Module field: 'maintenance'

-- Maintenance Plans
-- Total: 0 records
-- Module field: 'maintenance'

-- Summary
-- Dashboard Goals: 2 (1 active for Oct 2025, module='clean')
-- SLA Configs: 0
-- Equipment: 0
-- Maintenance Templates: 0
-- Maintenance Plans: 0

-- Note: Maintenance module (OPUS Manutenção) not yet in active use
-- Most configurations are for OPUS Clean module
