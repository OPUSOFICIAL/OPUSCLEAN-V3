# 🧪 Guia de Teste End-to-End - Sistema Offline

## ✅ Pré-requisitos

- Sistema rodando: `npm run dev` (porta 5000)
- Browser DevTools aberto (F12)
- Usuário autenticado no sistema
- Cliente/Customer selecionado

---

## 📋 Teste 1: Work Order Offline

### Objetivo
Validar criação de Work Order completamente offline com anexo de fotos.

### Passos

1. **Setup Offline Mode:**
   - Abrir DevTools → Network tab
   - Marcar "Offline" checkbox
   - Confirmar status offline: verificar indicador na UI

2. **Criar Work Order:**
   - Navegar para página de criação de WO mobile
   - Preencher campos obrigatórios:
     - Título
     - Descrição
     - Site
     - Zona
     - Equipamento (se necessário)
   - Clicar em "Anexar Fotos"
   - Selecionar 2-3 fotos do sistema

3. **Validar Storage Local:**
   - DevTools → Application → IndexedDB → `offline_work_orders`
   - Confirmar registro criado com:
     - `localId`: presente
     - `syncStatus`: "pending"
     - `createdOffline`: true
   - IndexedDB → `offline_attachments`
   - Confirmar fotos armazenadas com:
     - `dataUrl`: Base64 presente
     - `workOrderId`: localId da WO
     - `syncStatus`: "pending"

4. **Reconectar:**
   - DevTools → desmarcar "Offline"
   - Aguardar 2-3 segundos
   - Console deve mostrar: `[SYNC QUEUE] Auto-sync triggered by network reconnection`

5. **Validar Sync:**
   - Console logs: `[SYNC QUEUE] Phase 1: Syncing work orders...`
   - Console logs: `[SYNC QUEUE] Phase 3: Syncing attachments...`
   - Console logs: `[SYNC QUEUE] All phases completed`
   - Network tab: verificar requests POST `/api/sync/batch`

6. **Validar UI:**
   - Navegar para lista de Work Orders
   - Confirmar WO aparece com status correto
   - Abrir detalhes da WO
   - Confirmar fotos aparecem na galeria de attachments
   - Clicar em foto → deve abrir/baixar corretamente

### ✅ Resultado Esperado
- WO criada offline
- Fotos armazenadas em IndexedDB
- Sync automático ao reconectar
- Fotos aparecem na UI após sync
- Arquivos físicos salvos em `attached_assets/work_order_attachments/YYYY/MM/`

---

## 📋 Teste 2: Checklist Execution Offline

### Objetivo
Validar execução de checklist de manutenção offline com fotos.

### Passos

1. **Setup:**
   - Criar WO de manutenção (online)
   - Atribuir checklist template
   - Ir para página de execução mobile

2. **Offline Mode:**
   - DevTools → Network → "Offline"

3. **Executar Checklist:**
   - Preencher items do checklist
   - Para cada item:
     - Marcar status (OK/NOK/NA)
     - Adicionar observação
     - Anexar 1-2 fotos
   - Salvar execução

4. **Validar IndexedDB:**
   - `offline_checklist_executions`
     - `localId`: presente
     - `photos`: array de Base64
     - `syncStatus`: "pending"

5. **Reconectar e Sync:**
   - Desmarcar "Offline"
   - Aguardar sync automático
   - Verificar logs de sync

6. **Validar Backend:**
   - Buscar execução no DB: `maintenance_checklist_executions`
   - Confirmar `photos`: array de filenames (NÃO Base64)
   - Verificar arquivos físicos existem no filesystem

7. **Validar UI:**
   - Abrir histórico de execuções
   - Confirmar checklist aparece
   - Abrir detalhes → fotos devem carregar

### ✅ Resultado Esperado
- Checklist executado offline
- Fotos em IndexedDB como Base64
- Sync converte para arquivos físicos
- Database armazena apenas filenames
- UI mostra fotos corretamente

---

## 📋 Teste 3: QR Code Execution Offline

### Objetivo
Validar execução de tarefa via QR code offline com fotos.

### Passos

1. **Setup:**
   - Gerar QR code de equipamento (online)
   - Imprimir ou ter QR disponível

2. **Offline Mode:**
   - DevTools → "Offline"
   - Navegar para `/qr-execution`

3. **Escanear QR:**
   - Clicar em "Escanear QR Code"
   - Permitir câmera
   - Escanear QR code do equipamento

4. **Executar Tarefa:**
   - Preencher descrição da execução
   - Adicionar observações
   - Anexar 2-3 fotos
   - Clicar "Finalizar Execução"

5. **Validar Storage:**
   - IndexedDB → `offline_work_orders`
   - Confirmar WO criada com:
     - `equipmentId`: do QR
     - `type`: "qr_execution"
   - IndexedDB → `offline_attachments`
   - Confirmar fotos linkadas

6. **Reconectar:**
   - Desmarcar "Offline"
   - Aguardar sync

7. **Validar Resultado:**
   - Verificar WO no backend
   - Confirmar attachments salvos fisicamente
   - UI mostra execução com fotos

### ✅ Resultado Esperado
- QR execution funciona offline
- Fotos anexadas corretamente
- Sync bem-sucedido
- Arquivos físicos no servidor

---

## 📋 Teste 4: Batch Upload Online

### Objetivo
Validar que batch upload elimina overhead de múltiplos requests.

### Passos

1. **Online Mode:**
   - Garantir conexão ativa

2. **Criar WO com Fotos:**
   - Navegar para criação de WO
   - Anexar 5 fotos
   - DevTools → Network tab → limpar logs
   - Submeter formulário

3. **Validar Network:**
   - Filtrar por "attachments"
   - Deve haver **APENAS 1 REQUEST**:
     - `POST /api/attachments/upload-base64-batch`
   - Payload deve conter: `{ attachments: [{base64, format}, ...] }`
   - Response deve ter: `{ filenames: [...], urls: [...] }`

4. **Validar Database:**
   - Buscar WO no DB
   - Confirmar attachments linkados
   - Verificar `fileUrl` contém filenames (NÃO Base64)

### ✅ Resultado Esperado
- Batch upload: N fotos = 1 request
- Performance melhorada vs. N requests
- Database correto

---

## 📋 Teste 5: Sincronização Sequencial

### Objetivo
Validar ordem correta de sync (WO → Checklist → Attachments).

### Passos

1. **Criar Dados Offline:**
   - Offline mode
   - Criar WO com fotos
   - Executar checklist com fotos
   - Total: 1 WO + 1 Checklist + múltiplas fotos

2. **Validar IndexedDB:**
   - Confirmar 3 stores têm dados pending

3. **Reconectar:**
   - Desmarcar "Offline"
   - Abrir Console

4. **Monitorar Logs:**
   - `[SYNC QUEUE] Phase 1: Syncing work orders...`
   - `[SYNC QUEUE] Phase 2: Syncing checklist executions...`
   - `[SYNC QUEUE] Phase 3: Syncing attachments...`
   - `[SYNC QUEUE] All phases completed`

5. **Validar ID Mapping:**
   - Attachments devem referenciar serverId da WO (não localId)
   - Checklist deve referenciar serverId da WO

### ✅ Resultado Esperado
- Sync sequencial correto
- Parent entities antes de children
- ID mapping automático
- Nenhum erro de foreign key

---

## 🔍 Checklist Geral de Validação

### Backend
- [ ] Nenhum Base64 armazenado no database
- [ ] Apenas filenames em `fileUrl` column
- [ ] Arquivos físicos em `attached_assets/work_order_attachments/YYYY/MM/`
- [ ] Formato de arquivos: `.jpg`, `.jpeg`, `.png`
- [ ] Foreign keys corretas (WO ← Attachments)

### Frontend
- [ ] IndexedDB armazena Base64 offline
- [ ] Sync queue processa em ordem
- [ ] UI mostra indicador de sync em progresso
- [ ] Fotos carregam após sync
- [ ] Nenhum erro no console
- [ ] Network status detectado corretamente

### Performance
- [ ] Batch upload usa 1 request para N fotos
- [ ] Sync não trava UI
- [ ] Fotos aparecem rapidamente após sync
- [ ] Nenhum memory leak

### Edge Cases
- [ ] Sync interrompido → retry funciona
- [ ] Offline novamente durante sync → resume após
- [ ] Fotos grandes (>5MB) → compressão funciona
- [ ] Múltiplos dispositivos → conflitos resolvidos

---

## 🚨 Troubleshooting

### Problema: Sync não dispara automaticamente
**Solução:**
- Verificar `useNetworkStatus()` hook
- Console deve mostrar: `[NETWORK] Status changed: online`
- Forçar sync manual: chamar `syncQueueManager.syncAll()`

### Problema: Fotos não aparecem após sync
**Solução:**
- Verificar DB: `fileUrl` deve ter caminho relativo
- Verificar filesystem: arquivo existe?
- Verificar Network tab: request GET `/api/attachments/:filename` retorna 200

### Problema: Erro "Work order not found" durante sync
**Solução:**
- Sync sequencial falhou
- Phase 1 (WO) deve completar antes Phase 3 (Attachments)
- Verificar logs de erro no backend

### Problema: Base64 no database
**Solução:**
- Bug no `syncBatch()` → deve chamar `saveWorkOrderAttachmentFile()`
- Verificar código em `server/storage.ts` linhas 7955-7974

---

## ✅ Critérios de Sucesso Final

1. ✅ Todos os 5 testes passam sem erros
2. ✅ Nenhum Base64 inline no database
3. ✅ Arquivos físicos salvos corretamente
4. ✅ Sync automático funciona
5. ✅ UI mostra fotos após sync
6. ✅ Performance: batch upload usa 1 request
7. ✅ Ordem de sync correta (WO → Checklist → Attachments)

**Quando todos os critérios forem atendidos, Task 9 está COMPLETA!**
