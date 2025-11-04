-- ============================================================================
-- OPUS Database Dump - Users
-- Generated: November 3, 2025
-- Note: Passwords are hashed with Bcrypt and not included in this dump
-- ============================================================================

-- Users
-- Total: 22 records
-- Note: password_hash field excluded for security

INSERT INTO users (id, name, email, username, role, company_id, is_active) VALUES
-- Admin Users
('user-admin-opus', 'Administrador Sistema', 'admin@grupoopus.com', 'admin', 'admin', 'company-admin-default', true),
('10dbff4c-de78-41a4-a9f0-d9d28e62c8a3', 'thiago.lancelotti', 'thiago.lancelotti@grupoopus.com', 'thiago.lancelotti', 'admin', 'company-admin-default', true),

-- Operators - Active
('d0f1f357-cdda-49a8-874b-ddad849b0f66', 'João Operador', 'operador1@grupoopus.com', 'operador1', 'operador', 'company-admin-default', true),
('op-teste-1758573497.448657', 'Operador Teste', 'teste@operador.com', 'teste', 'operador', 'company-admin-default', true),
('user-CLIENTE-1759343961359', 'CLIENTE', 'CLIENTE', 'CLIENTE', 'operador', 'company-admin-default', true),
('user-cliente-1759348116705', 'cliente', 'cliente', 'cliente', 'operador', 'company-admin-default', true),
('user-manoel.mariano-1759521589871', 'manoel.mariano', 'manoel.mariano', 'manoel.mariano', 'operador', 'company-admin-default', true),
('user-marcelo.cananea-1760461316804', 'Marcelo', 'marcelo.cananea@grupoopus.com', 'marcelo.cananea', 'operador', 'company-admin-default', true),
('user-rita.caetano-1760548000058', 'Rita Caetano', 'rita.caetano@grupoopus.com', 'rita.caetano', 'operador', 'company-admin-default', true),
('user-valmir.vitor-1760549832765', 'Valmir Vitor', 'valmir.vitor@grupoopus.com', 'valmir.vitor', 'operador', 'company-admin-default', true),
('user-cristiane.aparecida-1760549898846', 'Cristiane Aparecida', 'cristiane.aparecida@grupoopus.com', 'cristiane.aparecida', 'operador', 'company-admin-default', true),
('user-andreia.nicolau-1760549944643', 'Andreia Nicolau', 'andreia.nicolau@grupoopus.com', 'andreia.nicolau', 'operador', 'company-admin-default', true),
('user-nubia.solange-1760549986782', 'Nubia Solange', 'nubia.solange@grupoopus.com', 'nubia.solange', 'operador', 'company-admin-default', true),
('user-valeria.pessoa-1760550018472', 'Valeria Pessoa', 'valeria.pessoa@grupoopus.com', 'valeria.pessoa', 'operador', 'company-admin-default', true),
('user-Eduardo.Santos-1760638771842', 'Eduardo Santos', 'eduardo.santos@tecnofibras.com.br', 'Eduardo.Santos', 'operador', 'company-admin-default', true),
('user-Admin Tecno-1761850618028', 'admin cliente', 'adminTesteCliente@gmail.com', 'Admin Tecno', 'operador', 'company-admin-default', true),
('user-cliente.teste-1761931497868', 'client', 'cliente@teste.com', 'cliente.teste', 'operador', 'company-admin-default', true),
('user-operador.teste2-1761934891110', 'Operador Teste2', 'OperadorTeste2', 'operador.teste2', 'operador', 'company-admin-default', true),

-- Users - Inactive
('edd03c06-0426-4b21-a04d-f0fa8e48614b', 'Novo Usuario', 'novo@opus.com', 'novouser', 'admin', 'company-admin-default', false),
('39752b08-e1a2-491e-881b-818f00af20ab', 'teste', 'teste@gmail.com', 'teste123', 'admin', 'company-admin-default', false),
('42f5fd80-cc79-4f2a-946e-91b8abb67da3', 'opus123', 'opus123@opus.com', 'opus123', 'admin', 'company-admin-default', false),
('840a9cf4-19c2-4547-bb60-58a6c40b2e4a', 'Marcos Mattos', 'marcos.mattos@grupoopus.com', 'marcos.mattos', 'operador', 'company-opus-default', false);

-- Summary
-- Total Users: 22
-- Active: 18
-- Inactive: 4
-- Roles:
--   - admin: 5 (2 active, 3 inactive)
--   - operador: 17 (16 active, 1 inactive)
