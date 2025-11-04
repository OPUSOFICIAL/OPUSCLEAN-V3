-- ============================================================================
-- OPUS Database Dump - QR Codes and Checklist Templates
-- Generated: November 3, 2025
-- ============================================================================

-- QR Code Points
-- Total: 26 records
-- Types: execucao (ALL)
-- Module: clean (ALL)

-- Sample QR Codes (first 10 shown)
INSERT INTO qr_code_points (id, zone_id, service_id, code, type, name, description, is_active, created_at, updated_at, size_cm, equipment_id, module) VALUES
('qr-zone-vest-masc-01', 'zone-vest-masc-01', NULL, 'zone-vest-masc-01', 'execucao', 'VESTIÁRIO MASCULINO -01', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-vest-masc-02', 'zone-vest-masc-02', NULL, 'zone-vest-masc-02', 'execucao', 'VESTIÁRIO MASCULINO -02', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-vest-fem', 'zone-vest-fem', NULL, 'zone-vest-fem', 'execucao', 'VESTIÁRIO FEMININO', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-amb-banheiro', 'zone-amb-banheiro', NULL, 'zone-amb-banheiro', 'execucao', 'BANHEIRO AMBULATÓRIO', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-ref-fem-coz', 'zone-ref-fem-coz', NULL, 'zone-ref-fem-coz', 'execucao', 'BANHEIRO FEMININO COZINHA', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-port-masc', 'zone-port-masc', NULL, 'zone-port-masc', 'execucao', 'BANHEIRO MASCULINO PORTARIA', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-port-fem', 'zone-port-fem', NULL, 'zone-port-fem', 'execucao', 'BANHEIRO FEMININO PORTARIA', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-adm-masc', 'zone-adm-masc', NULL, 'zone-adm-masc', 'execucao', 'BANHEIRO ADM MASCULINO', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-adm-fem-corp', 'zone-adm-fem-corp', NULL, 'zone-adm-fem-corp', 'execucao', 'BANHEIRO FEMININO CORPORATIVO', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean'),
('qr-zone-adm-acess-01', 'zone-adm-acess-01', NULL, 'zone-adm-acess-01', 'execucao', 'BANHEIRO CORPORATIVO ACESSÍVEL 01', NULL, true, '2025-10-03 20:50:40.044676', '2025-10-03 20:50:40.044676', 5, NULL, 'clean');

-- Checklist Templates
-- Total: 4 records
-- Module: clean (ALL)
-- Note: items field contains JSON and is truncated for readability

-- Template 1: RTM
INSERT INTO checklist_templates (id, company_id, service_id, site_id, name, description, created_at, updated_at, zone_id, module) VALUES
('checklist-1759332028080-yP1zdZiE7V', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', 'RTM', NULL, '2025-10-01 15:20:28.153116', '2025-10-31 16:08:39.403698', '20864c38-1234-46e6-8581-46e3c55a9b87', 'clean');
-- Items: 4 (photo, text, photo, checkbox)

-- Template 2: PINTURA SMC
INSERT INTO checklist_templates (id, company_id, service_id, site_id, name, description, created_at, updated_at, zone_id, module) VALUES
('checklist-1760640725459-vyFf79rK0p', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', 'PINTURA SMC', 'Atividades a serem realizadas na cabine de pintura SMC', '2025-10-16 15:52:05.462372', '2025-10-31 19:41:40.146258', 'a415c33b-c0ac-4a79-87c3-38a7c36d0cfa', 'clean');
-- Items: 1 (text)

-- Template 3: Limpeza de banheiros e vestiarios - Femininos
INSERT INTO checklist_templates (id, company_id, service_id, name, description, created_at, updated_at, module) VALUES
('checklist-1761585131363-ksHIlM6w8O', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'Limpeza de banheiros e vestiarios - Femininos', 'Limpeza convencional de banheiros e vestiarios.', '2025-10-27 14:12:11.365306', '2025-10-27 14:12:11.365306', 'clean');
-- Items: 1 (checkbox with 6 options)

-- Template 4: CWC feminino - Tech center
INSERT INTO checklist_templates (id, company_id, service_id, name, created_at, updated_at, module) VALUES
('checklist-1761594742714-2NXCD3KFSb', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'CWC feminino - Tech center', '2025-10-27 16:52:22.715867', '2025-10-27 16:52:22.715867', 'clean');
-- Items: 1 (checkbox with 6 options)

-- Summary
-- QR Code Points: 26 (ALL active, ALL type='execucao', ALL module='clean')
-- Checklist Templates: 4 (ALL module='clean')
-- Note: 22 additional QR codes exist (see full database export)
