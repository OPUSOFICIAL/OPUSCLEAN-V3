-- ============================================================================
-- OPUS Database Dump - Sites (Locais) and Zones
-- Generated: November 3, 2025
-- ============================================================================

-- Sites (Locais)
-- Total: 7 records
-- Module: ALL 'clean'
INSERT INTO sites (id, company_id, customer_id, name, address, description, floor_plan_image_url, is_active, created_at, updated_at, module) VALUES
('ff191700-ac34-4df7-accc-1d420568d645', 'company-admin-default', '7913bae1-bdca-4fb4-9465-99a4754995b2', 'Fabrica Central', 'Joinville', NULL, NULL, true, '2025-09-29 12:03:00.214659', '2025-09-29 12:03:15.394842', 'clean'),
('site-faurecia-vestiarios', 'company-admin-default', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'VESTIÁRIOS', 'Faurecia - Vestiários', NULL, NULL, true, '2025-10-03 20:36:46.827984', '2025-10-03 20:36:46.827984', 'clean'),
('site-faurecia-ambulatorio', 'company-admin-default', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'AMBULATÓRIO', 'Faurecia - Ambulatório', NULL, NULL, true, '2025-10-03 20:36:46.827984', '2025-10-03 20:36:46.827984', 'clean'),
('site-faurecia-refeitorio', 'company-admin-default', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'REFEITÓRIO', 'Faurecia - Refeitório', NULL, NULL, true, '2025-10-03 20:36:46.827984', '2025-10-03 20:36:46.827984', 'clean'),
('site-faurecia-portaria', 'company-admin-default', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'PORTARIA', 'Faurecia - Portaria', NULL, NULL, true, '2025-10-03 20:36:46.827984', '2025-10-03 20:36:46.827984', 'clean'),
('site-faurecia-administrativo', 'company-admin-default', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'ADMINISTRATIVO', 'Faurecia - Administrativo', NULL, NULL, true, '2025-10-03 20:36:46.827984', '2025-10-03 20:36:46.827984', 'clean'),
('site-faurecia-producao', 'company-admin-default', '43538320-fe1b-427c-9cb9-6b7ab06c1247', 'PRODUÇÃO', 'Faurecia - Produção', NULL, NULL, true, '2025-10-03 20:36:46.827984', '2025-10-03 20:36:46.827984', 'clean');

-- Zones
-- Total: 28 records
-- Module: ALL 'clean'
-- Note: First 10 zones shown (see database for full list)

-- Zones - Fabrica Central (TECNOFIBRA)
INSERT INTO zones (id, site_id, name, description, area_m2, capacity, category, position_x, position_y, size_scale, color, is_active, created_at, updated_at, module) VALUES
('a415c33b-c0ac-4a79-87c3-38a7c36d0cfa', 'ff191700-ac34-4df7-accc-1d420568d645', 'Cabine Pintura SMC', NULL, NULL, NULL, 'producao', 36.78, 58.44, 1.21, NULL, true, '2025-09-29 12:03:55.125574', '2025-10-20 10:36:21.252153', 'clean'),
('20864c38-1234-46e6-8581-46e3c55a9b87', 'ff191700-ac34-4df7-accc-1d420568d645', 'Cabine Pintura RTM', NULL, NULL, NULL, 'producao', 52.56, 57.57, 1.21, NULL, true, '2025-09-29 12:04:15.692157', '2025-10-20 10:36:21.235424', 'clean'),
('2d9936f6-6093-4885-b0bf-cf655f559dbc', 'ff191700-ac34-4df7-accc-1d420568d645', 'Cabine Pintura Estatica', NULL, 12.00, NULL, 'producao', 19.55, 37.26, 1.42, NULL, true, '2025-09-29 12:06:02.8882', '2025-10-20 10:36:21.249322', 'clean'),
('2ba21003-b82d-4950-8a6b-f504740960ea', 'ff191700-ac34-4df7-accc-1d420568d645', 'Cabine Estática SMC Fante', NULL, 20.00, NULL, 'producao', 67.95, 30.05, 1.42, NULL, true, '2025-09-29 12:06:20.732367', '2025-10-20 10:36:21.227876', 'clean');

-- Zones - FAURECIA - Banheiros
INSERT INTO zones (id, site_id, name, description, area_m2, capacity, category, position_x, position_y, size_scale, color, is_active, created_at, updated_at, module) VALUES
('zone-ref-fem-coz', 'site-faurecia-refeitorio', 'BANHEIRO FEMININO COZINHA', NULL, NULL, NULL, 'banheiro', NULL, NULL, NULL, NULL, true, '2025-10-03 20:36:59.907585', '2025-10-03 20:36:59.907585', 'clean'),
('zone-port-masc', 'site-faurecia-portaria', 'BANHEIRO MASCULINO PORTARIA', NULL, NULL, NULL, 'banheiro', NULL, NULL, NULL, NULL, true, '2025-10-03 20:36:59.907585', '2025-10-03 20:36:59.907585', 'clean'),
('zone-port-fem', 'site-faurecia-portaria', 'BANHEIRO FEMININO PORTARIA', NULL, NULL, NULL, 'banheiro', NULL, NULL, NULL, NULL, true, '2025-10-03 20:36:59.907585', '2025-10-03 20:36:59.907585', 'clean'),
('zone-vest-masc-01', 'site-faurecia-vestiarios', 'VESTIÁRIO MASCULINO -01', NULL, NULL, NULL, 'banheiro', NULL, NULL, NULL, NULL, true, '2025-10-03 20:36:59.907585', '2025-10-03 20:36:59.907585', 'clean'),
('zone-vest-masc-02', 'site-faurecia-vestiarios', 'VESTIÁRIO MASCULINO -02', NULL, NULL, NULL, 'banheiro', NULL, NULL, NULL, NULL, true, '2025-10-03 20:36:59.907585', '2025-10-03 20:36:59.907585', 'clean'),
('zone-vest-fem', 'site-faurecia-vestiarios', 'VESTIÁRIO FEMININO', NULL, NULL, NULL, 'banheiro', NULL, NULL, NULL, NULL, true, '2025-10-03 20:36:59.907585', '2025-10-03 20:36:59.907585', 'clean');

-- Summary
-- Sites: 7 (ALL active, ALL module='clean')
-- Zones: 28 (ALL active, ALL module='clean')
-- Categories: banheiro, producao
