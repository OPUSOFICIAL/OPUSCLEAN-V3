-- ========================================
-- RESUMO DO BANCO DE DADOS OPUS FACILITIES
-- Data: $(date +"%Y-%m-%d %H:%M:%S")
-- ========================================

-- Contagem de registros por tabela:
SELECT 'companies' AS tabela, COUNT(*) AS registros FROM companies
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sites', COUNT(*) FROM sites
UNION ALL SELECT 'zones', COUNT(*) FROM zones
UNION ALL SELECT 'qr_code_points', COUNT(*) FROM qr_code_points
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'equipment', COUNT(*) FROM equipment
UNION ALL SELECT 'work_orders', COUNT(*) FROM work_orders
UNION ALL SELECT 'scheduled_work_orders', COUNT(*) FROM scheduled_work_orders
UNION ALL SELECT 'checklist_templates', COUNT(*) FROM checklist_templates
UNION ALL SELECT 'cleaning_activities', COUNT(*) FROM cleaning_activities
UNION ALL SELECT 'maintenance_activities', COUNT(*) FROM maintenance_activities
UNION ALL SELECT 'services', COUNT(*) FROM services
UNION ALL SELECT 'ai_integrations', COUNT(*) FROM ai_integrations
UNION ALL SELECT 'chat_conversations', COUNT(*) FROM chat_conversations
UNION ALL SELECT 'chat_messages', COUNT(*) FROM chat_messages
ORDER BY registros DESC;
