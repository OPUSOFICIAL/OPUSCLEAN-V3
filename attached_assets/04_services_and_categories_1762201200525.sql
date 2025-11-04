-- ============================================================================
-- OPUS Database Dump - Services, Types and Categories
-- Generated: November 3, 2025
-- ============================================================================

-- Service Types
-- Total: 3 records
INSERT INTO service_types (id, name, code, customer_id, module) VALUES
('st-emergency', 'Emergência', 'EMERG_SVC', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'clean'),
('st-preventive', 'Preventivo', 'PREV_SVC', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'clean'),
('fd87bcf6-fc20-4157-84db-bda39a303069', 'Preventiva', 'PVT', '7913bae1-bdca-4fb4-9465-99a4754995b2', 'clean');

-- Service Categories
-- Total: 2 records
INSERT INTO service_categories (id, name, code, type_id, module) VALUES
('be576348-675a-4b59-a7fa-715bbb0e0f15', 'Limpeza Tecnica', 'LPT', 'fd87bcf6-fc20-4157-84db-bda39a303069', 'clean'),
('81b4f31a-3f7b-4db0-a5af-f88189a961a8', 'Limpeza', '1', 'st-preventive', 'clean');

-- Services
-- Total: 3 records
INSERT INTO services (id, name, description, estimated_duration_minutes, priority, requirements, is_active, created_at, updated_at, customer_id, category_id, type_id, module) VALUES
('service-3', 'Reposição de Suprimentos', 'Reposição de papel, sabão e materiais de higiene', 15, 'media', NULL, true, '2025-09-20 15:14:25.875852', '2025-10-01 01:21:32.882015', '43538320-fe1b-427c-9cb9-6b7ab06c1247', '81b4f31a-3f7b-4db0-a5af-f88189a961a8', 'st-preventive', 'clean'),
('0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'Higienização de Cabine', NULL, 480, 'alta', NULL, true, '2025-09-29 11:50:25.144325', '2025-09-29 11:53:39.923771', '7913bae1-bdca-4fb4-9465-99a4754995b2', 'be576348-675a-4b59-a7fa-715bbb0e0f15', 'fd87bcf6-fc20-4157-84db-bda39a303069', 'clean'),
('1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'Limpeza Rotina', NULL, 30, 'media', NULL, true, '2025-10-01 01:21:20.474254', '2025-10-01 01:21:20.474254', '43538320-fe1b-427c-9cb9-6b7ab06c1247', '81b4f31a-3f7b-4db0-a5af-f88189a961a8', 'st-preventive', 'clean');

-- Summary
-- Service Types: 3 (ALL module='clean')
-- Service Categories: 2 (ALL module='clean')
-- Services: 3 (ALL active, ALL module='clean')
