-- ============================================================================
-- OPUS Database Dump - Work Orders Summary
-- Generated: November 3, 2025
-- Note: Full work orders data not included (697 records)
-- ============================================================================

-- Work Orders Statistics
-- Total: 697 records
-- Module: clean (ALL)

-- Status Distribution:
--   aberta (Open): 685 work orders
--   concluida (Completed): 12 work orders

-- Work Order Types:
--   - programada (Programmed): Generated from cleaning activities
--   - corretiva_interna (Internal Corrective): Manually created
--   - corretiva_publica (Public Corrective): From public QR codes

-- Priority Levels:
--   - baixa (Low)
--   - media (Medium)
--   - alta (High)
--   - urgente (Urgent)

-- Work Order Fields:
--   - number (sequential counter)
--   - company_id
--   - module ('clean' or 'maintenance')
--   - zone_id (linked to zones)
--   - service_id (type of service)
--   - cleaning_activity_id (for programmed orders)
--   - checklist_template_id
--   - qr_code_point_id
--   - status (aberta, em_progresso, concluida, cancelada)
--   - priority (baixa, media, alta, urgente)
--   - scheduled_date
--   - assigned_to (user_id of operator)
--   - completed_by (user_id who completed)
--   - completed_at
--   - rating (1-5 stars)
--   - rated_by
--   - sla_deadline
--   - origin (sistema, qr_code_execucao, qr_code_publico, manual)
--   - created_at, updated_at

-- Related Tables:
--   - work_order_comments: Comments and photos attached to work orders
--   - work_order_checklist_executions: Completed checklists

-- Key Metrics (as of dump date):
--   - Open Orders: 685 (98.3%)
--   - Completed Orders: 12 (1.7%)
--   - Completion Rate: 1.7%
--   - Average per day: ~20 orders (based on creation period)

-- Most Active Sites:
--   1. Fabrica Central (TECNOFIBRA)
--   2. FAURECIA sites (Vestiários, Produção, Administrativo)

-- Most Common Services:
--   1. Higienização de Cabine
--   2. Limpeza Rotina
--   3. Reposição de Suprimentos

-- Note: For complete work order data export, use:
-- SELECT * FROM work_orders ORDER BY created_at DESC;
-- SELECT * FROM work_order_comments ORDER BY created_at DESC;
