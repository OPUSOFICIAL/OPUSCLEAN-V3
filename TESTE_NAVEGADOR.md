# 🧪 TESTE RÁPIDO NO NAVEGADOR

Execute este teste ANTES de gerar o APK para garantir que tudo está funcionando.

---

## 🌐 PASSO 1: LIMPAR CACHE DO INDEXEDDB

Abra o Console do navegador (F12) e execute:

```javascript
// Deletar banco antigo
indexedDB.deleteDatabase('AceleraOfflineDB');

// Recarregar página
location.reload();
```

---

## 🔐 PASSO 2: FAZER LOGIN

1. Acesse: https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev/login-mobile

2. Use um dos usuários operadores:
   - **Usuário:** `joao.geral`
   - **Senha:** [você precisa saber a senha]

3. Se não souber a senha, crie um novo operador no admin ou redefina a senha.

---

## 📷 PASSO 3: SIMULAR SCANNER QR

Como o navegador não tem scanner QR físico, vamos simular:

### Opção A: Usar URL direta
```
https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev/qr-execution/03b5c9ac-4151-4d14-9957-a2aea6131e56
```

### Opção B: Console do navegador
1. Vá para `/mobile` (dashboard)
2. Abra Console (F12)
3. Execute:
```javascript
// Simular scan de QR code
window.location.href = '/qr-execution/03b5c9ac-4151-4d14-9957-a2aea6131e56';
```

---

## ✅ PASSO 4: VERIFICAR MODAL DE SERVIÇOS

✅ **Deve aparecer:**
- Modal com título "Selecionar Serviço"
- Lista de serviços disponíveis
- Lista de work orders abertas
- Filtros: Hoje | Próximas | Todas | Pausadas

✅ **Selecionar uma work order:**
- Clicar em uma das O.S. listadas
- Botão "Executar Ordem de Serviço" deve aparecer

---

## 🔧 PASSO 5: EXECUTAR ORDEM DE SERVIÇO

1. Clicar em "Executar Ordem de Serviço"
2. ✅ Página de execução abre
3. ✅ Status muda para "Em Execução"
4. ✅ Checklist carrega

---

## 📸 PASSO 6: PREENCHER CHECKLIST

### Campos Booleanos (Sim/Não)
- Clicar em "✓" (Sim) ou "✗" (Não)

### Campos de Texto
- Digitar observações

### Campos de Foto
1. Clicar em "📷 Tirar Foto"
2. **No navegador:** Selecionar arquivo de imagem
3. **No APK:** Câmera nativa abre
4. ✅ Miniatura aparece

---

## ✅ PASSO 7: CONCLUIR CHECKLIST

1. Preencher TODOS os campos obrigatórios (marcados com *)
2. Clicar em "Concluir Checklist"
3. ✅ Se faltar campo: Toast de erro
4. ✅ Se tudo OK: Checklist enviada

---

## ✅ PASSO 8: CONCLUIR ORDEM DE SERVIÇO

1. Clicar em "Concluir Ordem de Serviço"
2. ✅ Status muda para "Concluída"
3. ✅ Redireciona para dashboard
4. ✅ O.S. desaparece da lista de abertas

---

## 🧪 PASSO 9: TESTAR MODO OFFLINE (SIMULADO)

### 9.1 Popular o Cache (ONLINE)
1. Fazer login
2. Escanear QR code
3. Modal abre → Dados são salvos no IndexedDB automaticamente

### 9.2 Simular Offline (Console)
```javascript
// Desativar fetch (simula offline)
const originalFetch = window.fetch;
window.fetch = () => Promise.reject(new Error('Offline'));

// Agora tente escanear novamente
window.location.href = '/qr-execution/03b5c9ac-4151-4d14-9957-a2aea6131e56';
```

### 9.3 Verificar Cache
```javascript
// Ver dados no IndexedDB
const db = await indexedDB.open('AceleraOfflineDB', 6);
db.transaction(['qrPoints'], 'readonly')
  .objectStore('qrPoints')
  .getAll()
  .onsuccess = (e) => console.log('QR Points:', e.target.result);
```

### 9.4 Restaurar Online
```javascript
// Restaurar fetch
window.fetch = originalFetch;
location.reload();
```

---

## 📊 VERIFICAR CONSOLE DO NAVEGADOR

Durante os testes, verifique o console para logs:

```
✅ [OFFLINE STORAGE] Database opened successfully
✅ [QR SCANNER] Processando QR code: { extractedCode: '...', isOnline: true }
✅ [SERVICE MODAL] Serviços disponíveis: 2 Total: 2
✅ [MOBILE] Work order data COMPLETA: {...}
✅ [CHECKLIST] Validação passou: true
✅ [SYNC] Auto-sync sincronizando...
```

---

## ❌ POSSÍVEIS ERROS E SOLUÇÕES

### Erro: "Token inválido" ou "401 Unauthorized"
**Solução:** Fazer logout e login novamente

### Erro: "QR Code não encontrado"
**Solução:** Verificar se o código QR está correto no banco de dados

### Erro: "Checklist não encontrada"
**Solução:** Verificar se a work order tem `serviceId` ou `checklistTemplateId`

### Erro: "IndexedDB version conflict"
**Solução:** Deletar banco e recarregar:
```javascript
indexedDB.deleteDatabase('AceleraOfflineDB');
location.reload();
```

---

## ✅ CHECKLIST DE VALIDAÇÃO

- [ ] Login funciona
- [ ] Modal de serviços abre
- [ ] Work orders listam
- [ ] Página de execução abre
- [ ] Checklist carrega
- [ ] Campos aparecem corretamente
- [ ] Validação de campos obrigatórios funciona
- [ ] Foto pode ser anexada
- [ ] Checklist pode ser concluída
- [ ] O.S. pode ser concluída
- [ ] Redireciona para dashboard
- [ ] Console sem erros críticos

---

## 🚀 PRÓXIMO PASSO

Se **TODOS os testes passarem**, você pode gerar o APK com confiança:

```bash
npm run build:android
npx cap sync android
cd android
./gradlew assembleDebug
```

**APK em:** `android/app/build/outputs/apk/debug/app-debug.apk`

---

**Última atualização:** 17 de Novembro de 2025
