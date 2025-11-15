# 📱 Histórico de Versões do APK

## 🎯 **v1.0.5 - ATUAL (Novembro 2025)** ✅

### **Correções:**
- ✅ **Detecção de Capacitor** - URLs absolutas quando em APK
- ✅ **Login funciona** - Backend Neon reativado
- ✅ **Offline-first completo** - IndexedDB + Auto-sync
- ✅ **Preservação de horários** - completedAt mantido no sync
- ✅ **Auto-sync on reconnect** - Hook ativo no App.tsx

### **Features:**
- ✅ Login online obrigatório (1ª vez)
- ✅ Scanner QR online + cache
- ✅ Scanner QR offline (IndexedDB)
- ✅ Execução de O.S offline
- ✅ Fotos offline (base64)
- ✅ Auto-sync ao reconectar (~1-2 seg)
- ✅ Badge "Offline" laranja
- ✅ Toast de confirmação de sync

### **Arquivos Modificados:**
- `client/src/lib/queryClient.ts` - Detecção Capacitor + URLs absolutas
- `client/src/pages/mobile-qr-scanner.tsx` - URLs absolutas no scanner
- `client/src/App.tsx` - Hook `useSyncOnReconnect()` ativo

### **Documentação:**
- ✅ `HYBRID_ARCHITECTURE.md` - Arquitetura técnica
- ✅ `🚀_GUIA_COMPLETO_APK_OFFLINE.md` - Guia de compilação e testes
- ✅ `VERSAO_APK.md` - Este arquivo

---

## 📦 **v1.0.4 - Tentativa Híbrida (Novembro 2025)**

### **Mudanças:**
- Removido `server.url` do `capacitor.config.ts`
- Implementado detecção de Capacitor (parcial)
- Offline funcionava, mas login quebrava

### **Problema:**
- ❌ Login não funcionava (URLs relativas)
- ❌ Código não aplicado no APK (não recompilado)

---

## 📦 **v1.0.3 - Offline Puro (QUEBRADO)**

### **Mudanças:**
- Removido `server.url` completamente
- Assets locais (offline-first)

### **Problemas:**
- ❌ Login quebrado (sem URL do servidor)
- ❌ API calls falhavam
- ✅ Offline funcionava (mas não sincronizava)

---

## 📦 **v1.0.2 - Camera Fix**

### **Correções:**
- ✅ Permissões Android (CAMERA, READ_MEDIA_IMAGES)
- ✅ Câmera funcionando

### **Problemas:**
- ⚠️ Modo offline não funcionava totalmente

**Arquivos:**
- `android/app/src/main/AndroidManifest.xml` - Permissões adicionadas

---

## 📦 **v1.0.1 - Login Fix**

### **Correções:**
- ✅ Login funcionando
- ✅ Servidor URL configurado

### **Problemas:**
- ❌ Câmera não funcionava
- ❌ Assets remotos (lento)

**Arquivos:**
- `capacitor.config.ts` - `server.url` adicionado

---

## 📦 **v1.0.0 - Versão Inicial**

### **Features:**
- Login básico
- Scanner QR online
- Execução de O.S online

### **Problemas:**
- ❌ Login não funcionava
- ❌ Sem modo offline

---

## 🎯 **Roadmap Futuro:**

### **v1.1.0 - Melhorias de UX**
- [ ] Indicador de progresso de sync
- [ ] Lista de itens pendentes de sync
- [ ] Botão manual de sync
- [ ] Notificação de sync concluído

### **v1.2.0 - Performance**
- [ ] Compressão de fotos antes de salvar
- [ ] Limite de cache (limpar antigos)
- [ ] Background sync (ServiceWorker)

### **v2.0.0 - Produção**
- [ ] Multi-tenant (vários clientes)
- [ ] Assinatura de código
- [ ] Release build (signed APK)
- [ ] Google Play Store

---

**Última atualização:** Novembro 2025  
**Versão recomendada:** **v1.0.5** ✅
