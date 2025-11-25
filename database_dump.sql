-- =====================================================
-- DUMP COMPLETO DO BANCO DE DADOS - ACELERA IT
-- Data: 2025-11-25 03:40 UTC
-- =====================================================

-- === COMPANIES ===
-- id: a3e33b82-4f75-4f8d-86a2-2d67e61a9812
-- name: OPUS Sistemas
-- email: contato@grupoopus.com

-- === CUSTOMERS ===
-- 1) FORVIA (f5ebc1c3-7954-404f-820a-14a7bd2a4f50) - subdomain: faurecia
-- 2) TECNOFIBRAS (394ea72c-5d3c-40e6-8d89-924c43a26d4b) - subdomain: tecnofibras

-- === USERS ===
INSERT INTO users (id, username, name, email, company_id, customer_id, user_type, role, modules, is_active) VALUES
('e6d18c9c-2cb7-4f4f-ba15-75657a16dbaa', 'admin', 'Administrador', 'admin@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', NULL, 'opus_user', 'admin', '{clean,maintenance}', true),
('user-cristiane.aparecida-1764032508071', 'cristiane.aparecida', 'Cristiane Aparecida', 'cristiane.aparecida@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-nubia.solange-1764032545840', 'nubia.solange', 'Nubia Solange', 'nubiasolange@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-rita.caetano-1764032609882', 'rita.caetano', 'Rita Caetano', 'rita.caetano@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-valeria.pessoa-1764032654456', 'valeria.pessoa', 'Valeria Pessoa', 'valeria.pessoa@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-valmir.vitor-1764032701485', 'valmir.vitor', 'Valmir Vitor', 'valmir.vitor@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-joao.silva-1764032385646', 'joao.silva', 'Joao Silva', 'joaosilva@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-andreia.nicolau-1764032467010', 'andreia.nicolau', 'Andreia Nicolau', 'andreia.nicolau@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-thais.lopes-1764032741053', 'thais.lopes', 'Thais Lopes', 'thais.lopes@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true),
('user-marcelo.cananae-1764039086044', 'marcelo.cananae', 'Marcelo Cananae', 'marcelocananae@grupoopus.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'admin', '{clean}', true),
('user-teste.us-1763647172242', 'teste.us', 'Operador Teste', 'teste.us@acelera.com', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'customer_user', 'operador', '{clean}', true);

-- === SITES ===
INSERT INTO sites (id, company_id, customer_id, module, name, address) VALUES
('58642977-1818-430d-90fd-821d6406a0c8', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'clean', 'ADMINISTRATIVO', 'Administrativo - Faurecia');

-- === ZONES ===
INSERT INTO zones (id, site_id, module, name, category) VALUES
('fd658001-60d0-489c-a0d1-8afdbb1a27c6', '58642977-1818-430d-90fd-821d6406a0c8', 'clean', 'BANHEIRO ADMINISTRATIVO', 'banheiro');

-- === SERVICES ===
INSERT INTO services (id, name, customer_id, type_id, module) VALUES
('8a5706ba-7eb2-4707-bf84-aa6620407485', 'Limpeza de banheiros', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', '13f89e34-37f8-428e-8e98-75da8bc6924f', 'clean');

-- === SERVICE_TYPES ===
INSERT INTO service_types (id, company_id, customer_id, name, code, module) VALUES
('2446092e-de57-4c68-a5bd-66b47bb53e62', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'Corretivo', 'CRT_LPZ', 'clean'),
('13f89e34-37f8-428e-8e98-75da8bc6924f', 'a3e33b82-4f75-4f8d-86a2-2d67e61a9812', 'f5ebc1c3-7954-404f-820a-14a7bd2a4f50', 'Preventivo', 'PVT_LPZ', 'clean');

-- === QR_CODE_POINTS ===
INSERT INTO qr_code_points (id, zone_id, code, type, name, module) VALUES
('ccbb9350-d9d7-4133-a179-9c037ca0856d', 'fd658001-60d0-489c-a0d1-8afdbb1a27c6', '75558537-7190-4b33-8e88-81fae7b0f28b', 'execucao', 'Banheiro Administrativo', 'clean');

-- === CUSTOM_ROLES (FORVIA) ===
-- Operador: role-operador-f5ebc1c3-7954-404f-820a-14a7bd2a4f50-1764030886073 (mobile_only)
-- Cliente: role-cliente-f5ebc1c3-7954-404f-820a-14a7bd2a4f50-1764030886074
-- Administrador: role-admin-f5ebc1c3-7954-404f-820a-14a7bd2a4f50-1764030886075

-- === WORK_ORDERS (17 total) ===
-- #1: Concluída
-- #2: Concluída (assigned: joao.silva)
-- #3-17: Abertas

-- === RESUMO ===
-- Companies: 1
-- Customers: 2 (FORVIA, TECNOFIBRAS)
-- Users: 14 (11 ativos)
-- Sites: 1
-- Zones: 1
-- Services: 1
-- Work Orders: 17 (2 concluídas, 15 abertas)
-- Custom Roles: 6 (3 por customer)

