-- ============================================================================
-- OPUS Database Dump - Cleaning Activities (Atividades de Limpeza)
-- Generated: November 3, 2025
-- Module: OPUS Clean
-- ============================================================================

-- Cleaning Activities
-- Total: 20+ records (first 18 shown)
-- Module: clean (ALL)
-- Frequencies: diaria, semanal, mensal, anual, turno

-- Note: frequency_config contains JSON configuration
-- Example frequencies:
--   diaria: {"timesPerDay": 1}
--   semanal: {"weekDays": ["segunda"], "timesPerDay": 1}
--   mensal: {"monthDay": 1, "timesPerDay": 1}
--   turno: {"shifts": ["manha", "tarde", "noite"]}

-- Sample Activities (first 10)

-- Limpeza por Turno - Cabine RTM
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-turno-rtm-1759264329', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', '20864c38-1234-46e6-8581-46e3c55a9b87', 'Limpeza por Turno - Cabine RTM', 'Limpeza manhã, tarde e noite', 'turno', false, '2025-09-30 20:32:08.791088', '2025-09-30 20:32:08.791088', 'clean');

-- Cabine de Pintura Primer RTM - Semanal
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-1759872977850-wyex3v3sb', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', '20864c38-1234-46e6-8581-46e3c55a9b87', 'Cabine de Pintura Primer RTM', 'Plastificação dos carrinhos (remover e recolocar os plásticos); Limpeza interna das paredes e vidros das cabines do primer; Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do primer Troca de filtro da exaustão Limpeza do flash off do primer Limpeza estufa do primer Limpeza das luminárias do primer Aspiração da região superior (teto) da estufa do primer Limpeza (raspar) os rotores (4) da exaustão do primer e passar graxa patente Jateamento com lava jato e aplicação de graxa patente no transportador', 'semanal', true, '2025-10-07 18:36:17.858536', '2025-10-07 18:36:17.858536', 'clean');

-- Cabine de Pintura Final RTM - Semanal (Sexta)
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-1759873220782-9wdyrslvl', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', '20864c38-1234-46e6-8581-46e3c55a9b87', 'Cabine de Pintura Final RTM', 'Jateamento com lava jato e aplicação de graxa patente no transportador Limpeza interna das paredes e vidros das cabines do verniz Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine de pintura do verniz Troca de filtro da exaustão da cabine do verniz Limpeza do flash off do verniz Limpeza das liminárias do verniz Limpeza (raspar) os rotores (3) da exaustão do verniz e passar graxa patente', 'semanal', true, '2025-10-07 18:40:20.79229', '2025-10-07 18:40:20.79229', 'clean');

-- Cabine de Pintura Primer SMC - Semanal (Quarta)
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-1759879717135-p4iquwjki', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', '2ba21003-b82d-4950-8a6b-f504740960ea', 'Cabine de Pintura Primer SMC', 'Limpeza interna das paredes e vidros das cabines do primer Aplicação filme plástico pintavel 3M e aplicação de sabão da Gage na cabine estática SMC primer Troca de filtro da exaustão da cabine estática SMC primer Limpeza das liminárias da cabine estática SMC ptimer Limpeza (raspar) os rotores (2) da exaustão da estática SMC primer e passar graxa patente', 'semanal', true, '2025-10-07 20:28:37.143593', '2025-10-07 20:28:37.143593', 'clean');

-- Limpeza Diária - Banheiros
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-1761585757243-elx2y62kt', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'site-faurecia-vestiarios', 'zone-vest-fem', 'LOG - Limpeza de banheiros e vestiarios femininos', 'Limpeza dos vestiários e banheiros femininos da logística', 'diaria', true, '2025-10-27 14:22:37.251386', '2025-10-27 14:22:37.251386', 'clean'),
('ca-1761585870492-w7xqg80th', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'site-faurecia-vestiarios', 'zone-vest-fem', 'Scania - Limpeza de WC e vestiários femininos', 'Limpeza dos banheiros e vestiarios femininos Scania', 'diaria', true, '2025-10-27 14:24:30.502021', '2025-10-27 14:24:30.502021', 'clean'),
('ca-1761586116924-imqskabvg', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'site-faurecia-vestiarios', 'zone-vest-fem', 'Toyota - limpeza de WC e vestiarios femininos', 'Limpeza de banheiros e vestiários femininos - Toyota', 'diaria', true, '2025-10-27 14:28:36.932641', '2025-10-27 14:28:36.932641', 'clean'),
('ca-1761586621875-47moo9ok0', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'site-faurecia-vestiarios', 'zone-vest-masc-01', 'LOG - Limpeza de WC e vestiarios masculinos', 'Limpeza de WC e vestiários masculinos logística.', 'diaria', true, '2025-10-27 14:37:01.883481', '2025-10-27 14:37:01.883481', 'clean'),
('ca-1761587028027-knglqct7g', 'company-admin-default', '1cf0f4ad-e6ef-4266-ba98-ae8746378ad8', 'site-faurecia-vestiarios', 'zone-vest-masc-01', 'GM - Limpeza de WC e vestiários masculinos', 'Limpeza dos WC e vestiários GM masculino', 'diaria', true, '2025-10-27 14:43:48.037341', '2025-10-27 14:43:48.037341', 'clean');

-- Manutenção Anual
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-1760182900759-vyp6ush29', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', '20864c38-1234-46e6-8581-46e3c55a9b87', 'Cabine de Pintura Primer RTM', 'Troca de filtro multibolsa cabine do primer Troca de filtro plenuns cabine do primer - 2 cabines', 'anual', true, '2025-10-11 08:41:40.767373', '2025-10-11 08:41:40.767373', 'clean');

-- Manutenção Mensal
INSERT INTO cleaning_activities (id, company_id, service_id, site_id, zone_id, name, description, frequency, is_active, created_at, updated_at, module) VALUES
('ca-1759890045118-y0c75246f', 'company-admin-default', '0643fb68-262b-4f4b-bd6f-e6dc1c304a37', 'ff191700-ac34-4df7-accc-1d420568d645', '20864c38-1234-46e6-8581-46e3c55a9b87', 'Cabine de Pintura Final RTM', 'Limpeza do fosso da exaustão da base Limpeza externa das paredes e vidros das cabines da base Limpeza do fosso da exaustão do verniz Aspiração da região superior (teto) da estufa da pintura final Limpeza externa das paredes e vidros das cabines do verniz', 'mensal', true, '2025-10-07 23:20:45.126827', '2025-10-07 23:20:45.126827', 'clean');

-- Summary
-- Cleaning Activities: 20+ total
-- Module: clean (ALL)
-- Status: Most active
-- Frequencies:
--   - diaria (Daily): 5+
--   - semanal (Weekly): 10+
--   - mensal (Monthly): 1+
--   - anual (Annual): 3
--   - turno (Shift-based): 1
-- Customers: FAURECIA, TECNOFIBRA
-- Sites: Multiple production sites
