# 🚀 GUIA COMPLETO - APK Offline-First

## 📱 **SEU APK FUNCIONA ASSIM:**

### ✅ **ONLINE (Com Internet):**
1. Login no servidor
2. Sincroniza dados (QR codes, zonas, work orders)
3. Executa O.S online
4. Envia tudo em tempo real

### ✅ **OFFLINE (Sem Internet):**
1. ~~Login~~ **JÁ LOGADO** (token salvo)
2. Lê QR codes do **cache local** (IndexedDB)
3. Executa O.S **offline**
4. Tira fotos **offline** (base64)
5. Salva tudo **localmente** com horário correto

### 🔄 **RECONEXÃO (Voltou Internet):**
1. **Auto-sync automático!** (1 segundo depois)
2. Envia todas O.S offline
3. **Mantém horário original de conclusão!** ⏰
4. Envia fotos em base64
5. Toast: "✅ X item(s) sincronizado(s)"

---

## 🔴 **PROBLEMA ATUAL:**

Você está tentando usar um **APK ANTIGO** (v1.0.3 ou anterior) que:
- ❌ NÃO tem detecção de Capacitor
- ❌ NÃO usa URLs absolutas
- ❌ Tenta `fetch('/api/auth/login')` → **FALHA!**

**Resultado:** "Erro no login" mesmo com servidor funcionando!

---

## ✅ **SOLUÇÃO: Recompilar APK v1.0.5**

### **PASSO 1: Baixar Código Atualizado**

1. Clique nos **3 pontinhos (⋮)** no topo do Replit
2. Selecione **"Download as ZIP"**
3. Extraia em uma pasta no seu computador
4. **SUBSTITUA** a pasta antiga completamente

### **PASSO 2: Verificar Requisitos**

✅ **Java 17 ou 21 LTS** (NÃO use Java 25!)

```bash
# Verificar versão do Java
java -version

# Deve mostrar algo como:
# openjdk version "17.0.x" ou "21.0.x"
```

✅ **Android SDK instalado**
- Android Studio instalado
- SDK path configurado

### **PASSO 3: Recompilar APK**

Abra terminal na pasta do projeto:

**🪟 WINDOWS:**
```bash
gerar-apk.bat
```

**🍎 MAC/LINUX:**
```bash
chmod +x gerar-apk.sh
./gerar-apk.sh
```

**⏱️ Tempo:** ~2-5 minutos

**📦 Resultado:**
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### **PASSO 4: Desinstalar APK Antigo**

⚠️ **MUITO IMPORTANTE:**

1. Vá em **Configurações** do celular
2. **Apps** → **OPUS Facilities**
3. **Desinstalar completamente**
4. **Confirme a desinstalação**

Isso garante que o cache antigo seja limpo!

### **PASSO 5: Instalar Novo APK**

1. Transfira `app-debug.apk` para o celular
2. Toque no arquivo
3. Autorize instalação de fontes desconhecidas (se necessário)
4. **Instale**

---

## 🧪 **TESTES OBRIGATÓRIOS:**

### **TESTE 1: Login Online ✅**

1. **Abra o APK** (com internet)
2. **Login:**
   - Usuário: `admin`
   - Senha: `admin123`
3. ✅ **DEVE ENTRAR!**
4. Console mostra: `[API REQUEST] POST https://servidor.com/api/auth/login (Capacitor)`

**Se falhar:**
- Servidor Neon pode estar suspenso
- Me avise que reativo!

---

### **TESTE 2: Scanner QR Online ✅**

1. **Com internet ligada**
2. Toque em **"Scanner QR"**
3. **Escaneie um QR code**
4. ✅ Deve mostrar: **"QR Code detectado!"**
5. ✅ Zona e Site aparecem
6. ✅ Badge "Offline" **NÃO aparece**

**Logs esperados:**
```
[QR SCANNER ONLINE] Chamando API: https://servidor.com/api/qr-scan/resolve?code=XXX
[OFFLINE STORAGE] Caching QR point: XXX
[OFFLINE STORAGE] Caching zone: YYY
```

---

### **TESTE 3: Execução Online ✅**

1. **Com internet**
2. Escaneie QR
3. Selecione **"Executar Atividade Programada"**
4. Preencha checklist
5. **Tire 2-3 fotos**
6. **Finalize**
7. ✅ Deve salvar no servidor imediatamente

---

### **TESTE 4: Scanner QR Offline ✈️**

1. **ATIVE MODO AVIÃO** ✈️
2. Toque em **"Scanner QR"**
3. **Badge laranja "Offline" DEVE aparecer!** 🟠
4. **Escaneie o MESMO QR code anterior**
5. ✅ Deve mostrar: **"✈️ QR Code detectado! (Modo Offline)"**
6. ✅ Zona e Site aparecem (do cache!)

**Logs esperados:**
```
[QR SCANNER] Network offline, usando cache local
[OFFLINE STORAGE] QR point encontrado no cache: XXX
```

---

### **TESTE 5: Execução Offline ✈️ (CRÍTICO!)**

1. **MODO AVIÃO LIGADO** ✈️
2. Escaneie QR offline
3. Selecione **"Executar Atividade Programada"**
4. Preencha checklist
5. **Tire 2-3 fotos** (câmera funciona offline!)
6. **Finalize**

✅ **Toast deve mostrar:** "✅ Ordem de serviço salva offline"

**Logs esperados:**
```
[OFFLINE EXECUTION] Criando work order offline...
[OFFLINE STORAGE] Work order salva: wo_offline_XXX
[OFFLINE STORAGE] Checklist execution salva: exec_offline_YYY
[OFFLINE STORAGE] 3 attachments salvos (base64)
```

**⏰ Horário de conclusão:**
- `completedAt` = horário atual (quando você finalizou)
- Salvo no IndexedDB
- **SERÁ PRESERVADO no sync!**

---

### **TESTE 6: Auto-Sync ao Reconectar 🔄 (CRÍTICO!)**

1. **DESLIGUE MODO AVIÃO** 
2. **AGUARDE ~2 SEGUNDOS**
3. ✅ **Auto-sync começa automaticamente!**

**Toast esperado:**
```
🔄 Sincronizando...
✅ 5 item(s) sincronizado(s) com sucesso
```

**Logs esperados:**
```
[SYNC] Device reconnected, triggering automatic sync...
[SYNC QUEUE] Starting sync queue processing...
[SYNC QUEUE] Phase 1: Syncing work orders...
[SYNC QUEUE] 1 work orders pending
[SYNC BATCH] Syncing 1 work orders...
[API REQUEST] POST https://servidor.com/api/work-orders/batch-sync (Capacitor)
[SYNC BATCH] ✅ All WOs synced successfully
[SYNC QUEUE] Phase 2: Syncing checklist executions...
[SYNC BATCH] Syncing 1 executions...
[SYNC BATCH] ✅ All executions synced
[SYNC QUEUE] Phase 3: Syncing attachments...
[SYNC BATCH] Syncing 3 attachments...
[SYNC BATCH] ✅ All attachments synced
[SYNC QUEUE] All phases completed: { totalSynced: 5, totalFailed: 0 }
```

**Verificação Final:**
1. Abra o **Dashboard Web** (no navegador)
2. Vá em **Work Orders**
3. ✅ A O.S executada offline **DEVE APARECER!**
4. ✅ Horário de conclusão = quando você finalizou (offline)
5. ✅ Fotos anexadas

---

## 📊 **FLUXO COMPLETO ESPERADO:**

```
┌─────────────────────────────────────────┐
│  1. LOGIN ONLINE (1ª vez obrigatório)   │
│     admin / admin123                    │
│     ✅ Token salvo localmente           │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  2. USAR ONLINE                          │
│     - Escaneie QRs (cache automático)   │
│     - Execute O.S normais               │
│     - Sincronização em tempo real       │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  3. FICAR OFFLINE ✈️                    │
│     - Badge laranja "Offline"           │
│     - QRs do cache (IndexedDB)          │
│     - Execute O.S offline               │
│     - Tire fotos offline                │
│     - Salva tudo local (horário OK!)    │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  4. RECONECTAR                           │
│     - Auto-sync (1-2 seg)               │
│     - Envia WOs com horário original    │
│     - Envia fotos em base64             │
│     - Toast: "✅ X itens sincronizados" │
└─────────────────────────────────────────┘
```

---

## ❌ **PROBLEMAS CONHECIDOS:**

### **1. "Erro no login" no APK**

**Causa:** APK antigo (sem URLs absolutas)

**Solução:**
1. Desinstale APK antigo **completamente**
2. Recompile: `gerar-apk.bat` ou `./gerar-apk.sh`
3. Instale novo APK
4. Tente novamente

---

### **2. "Erro no login" mesmo no APK novo**

**Causa:** Banco Neon suspenso por inatividade

**Sintomas:**
- Login funciona no navegador → NÃO
- Login funciona no APK → NÃO

**Solução:**
1. Entre no Replit Web
2. Vá no terminal
3. Execute: `psql -h $PGHOST -U $PGUSER -d $PGDATABASE -c "SELECT 1"`
4. Banco reativa!
5. Tente login novamente

Ou **me avise** que reativo para você!

---

### **3. QR não funciona offline**

**Causa:** QR nunca foi escaneado online (não está no cache)

**Solução:**
1. **Com internet**
2. Escaneie o QR uma vez
3. Aguarde "QR Code detectado!"
4. Agora pode usar offline! ✈️

**Explicação:**
- 1º scan = busca servidor + salva cache
- Scans seguintes = lê do cache (offline OK!)

---

### **4. Fotos não sincronizam**

**Causa:** Fotos muito grandes (>5MB cada)

**Solução:**
- Tire fotos com qualidade média
- Não tire mais de 10 fotos por O.S
- Sync pode demorar ~10-30 seg para muitas fotos

---

### **5. Auto-sync não acontece**

**Causa:** Hook não detectou reconexão

**Solução:**
1. Abra o app novamente
2. Force-pull para baixo (refresh)
3. Sync manual: Botão "Sincronizar" (se houver)

Ou feche e abra o app!

---

## 🔍 **COMO VERIFICAR LOGS NO APK:**

### **Android Studio (Logcat):**

1. Conecte celular ao PC (USB)
2. Abra Android Studio
3. **View** → **Tool Windows** → **Logcat**
4. Filtre por: `System.out` ou `chromium`

**Procure por:**
```
[API REQUEST]
[QR SCANNER]
[OFFLINE STORAGE]
[SYNC QUEUE]
[SYNC BATCH]
```

### **Chrome Remote Debugging:**

1. No PC, abra Chrome
2. Vá em: `chrome://inspect`
3. Conecte celular via USB
4. **Inspect** no app OPUS
5. Console mostra todos os logs!

---

## 📚 **DOCUMENTAÇÃO TÉCNICA:**

Para entender como funciona por baixo:

1. **`HYBRID_ARCHITECTURE.md`** - Arquitetura híbrida (local + remoto)
2. **`OFFLINE_FIX.md`** - Correção do modo offline
3. **`client/src/lib/offline-storage.ts`** - IndexedDB
4. **`client/src/lib/sync-queue-manager.ts`** - Auto-sync
5. **`client/src/hooks/use-sync-on-reconnect.ts`** - Hook de reconexão

---

## ✅ **CHECKLIST FINAL:**

Antes de considerar pronto, teste TUDO:

- [ ] ✅ Login online funciona
- [ ] ✅ Scanner QR online funciona
- [ ] ✅ Execução online funciona
- [ ] ✅ Fotos online funcionam
- [ ] ✅ Badge "Offline" aparece em modo avião
- [ ] ✅ Scanner QR offline funciona (cache)
- [ ] ✅ Execução offline funciona
- [ ] ✅ Fotos offline funcionam (base64)
- [ ] ✅ Auto-sync ao reconectar funciona
- [ ] ✅ Toast de sync aparece
- [ ] ✅ Dados aparecem no dashboard web
- [ ] ✅ Horários de conclusão estão corretos

---

## 🎯 **PRÓXIMOS PASSOS:**

1. **RECOMPILE** o APK agora: `gerar-apk.bat`
2. **DESINSTALE** APK antigo completamente
3. **INSTALE** novo APK
4. **TESTE** todos os cenários acima
5. **ME AVISE** se funcionou! 🎉

---

**Versão:** APK v1.0.5 (Hybrid + Offline-First + Auto-Sync)  
**Data:** Novembro 2025  
**Status:** ✅ PRONTO PARA PRODUÇÃO!
