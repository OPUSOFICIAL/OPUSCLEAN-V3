-- ============================================================================
-- OPUS Database Dump - Companies and Customers
-- Generated: November 3, 2025
-- ============================================================================

-- Companies
-- Total: 2 records
INSERT INTO companies (id, name, cnpj, email, phone, address, is_active, created_at, updated_at) VALUES
('company-admin-default', 'GRUPO OPUS', NULL, NULL, NULL, NULL, true, '2025-09-10 20:41:19.301367', '2025-09-10 20:41:19.301367'),
('company-opus-default', 'Grupo OPUS', '12.345.678/0001-90', 'contato@grupoopus.com.br', '(11) 3000-0000', 'Av. Paulista, 1000 - São Paulo, SP', true, '2025-10-19 17:58:47.078825', '2025-10-19 17:58:47.078825');

-- Customers
-- Total: 4 records
INSERT INTO customers (id, company_id, name, email, phone, document, address, city, state, zip_code, contact_person, notes, is_active, created_at, updated_at) VALUES
('43538320-fe1b-427c-9cb9-6b7ab06c1247', 'company-admin-default', 'FAURECIA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true, '2025-09-15 19:03:55.605952', '2025-09-15 19:03:55.605952'),
('7913bae1-bdca-4fb4-9465-99a4754995b2', 'company-admin-default', 'TECNOFIBRA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true, '2025-09-28 16:31:54.577274', '2025-09-28 16:31:54.577274'),
('20ae7c09-3fe9-4db9-a136-2992bac29e10', 'company-admin-default', 'teste', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-09-30 20:01:52.200153', '2025-09-30 20:01:54.962302'),
('customer-teste-default', 'company-opus-default', 'Cliente Teste', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true, '2025-10-19 17:58:47.081652', '2025-10-19 17:58:47.081652');

-- Summary
-- Companies: 2 (2 active)
-- Customers: 4 (3 active, 1 inactive)
