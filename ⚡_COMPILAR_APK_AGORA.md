# ⚡ COMPILAR APK v1.0.5 AGORA!

## 🔴 **SITUAÇÃO ATUAL:**

Você está usando um **APK ANTIGO** que:
- ❌ NÃO tem permissão `ACCESS_NETWORK_STATE`
- ❌ NÃO detecta online/offline
- ❌ Sempre mostra "Erro de conexão" no scanner QR

**O código está PRONTO** ✅  
**Mas você precisa RECOMPILAR!** ⚡

---

## 🚀 **PASSO A PASSO RÁPIDO:**

### **1️⃣ BAIXAR CÓDIGO (1 minuto)**

1. Abra o Replit no navegador
2. **⋮** (3 pontinhos) → **"Download as ZIP"**
3. Extraia o ZIP
4. **SUBSTITUA** a pasta antiga completamente

### **2️⃣ RECOMPILAR (3-5 minutos)**

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

**⏱️ Aguarde:** ~3-5 minutos

**📦 APK gerado em:**
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### **3️⃣ DESINSTALAR APK ANTIGO (30 segundos)**

⚠️ **MUITO IMPORTANTE:**

1. No celular: **Configurações**
2. **Apps** → **OPUS Facilities**
3. **DESINSTALAR**
4. **CONFIRME**

### **4️⃣ INSTALAR APK NOVO (30 segundos)**

1. Transfira `app-debug.apk` para o celular
2. Toque no arquivo
3. Autorize instalação
4. **Instale**

---

## ✅ **TESTE RÁPIDO (1 minuto):**

### **TESTE 1: Login**
1. Abra o APK
2. Login: `admin` / `admin123`
3. ✅ **DEVE ENTRAR!**

### **TESTE 2: Badge Offline**
1. Toque em **"Scanner QR"**
2. **ATIVE MODO AVIÃO** ✈️
3. Aguarde 2 segundos
4. ✅ **Badge laranja "Offline" DEVE APARECER!** 🟠

Se o badge aparecer, o fix funcionou! 🎉

### **TESTE 3: Scanner QR**

**QR Code para testar:**
```
QR-COND-CEU-AZUL-001
```

Ou use qualquer QR code do sistema!

---

## 🔍 **COMO SABER SE FUNCIONOU:**

### ✅ **FUNCIONOU:**
- Badge "Offline" aparece em modo avião 🟠
- Scanner mostra: "✈️ QR Code detectado! (Modo Offline)"
- Console mostra: `[NETWORK] Status changed: { connected: false }`

### ❌ **NÃO FUNCIONOU (APK antigo ainda):**
- Badge nunca aparece
- Erro: "Erro de conexão. Verifique sua internet"
- Console não mostra logs `[NETWORK]`

---

## 🐛 **SE O ERRO PERSISTIR:**

### **Problema 1: Badge não aparece**

**Causa:** APK antigo ainda instalado

**Solução:**
1. **DESINSTALE** completamente
2. **CONFIRME** a desinstalação
3. **Reinstale** APK novo
4. Permissões são aplicadas só na 1ª instalação!

### **Problema 2: Erro ao compilar**

**Causa:** Java incorreto

**Solução:**
```bash
java -version
# DEVE mostrar Java 17 ou 21 (NÃO 25!)
```

Se Java 25:
1. Desinstale Java 25
2. Instale Java 17 LTS
3. Recompile

### **Problema 3: APK não instala**

**Causa:** Assinatura diferente

**Solução:**
1. **DESINSTALE** APK antigo COMPLETAMENTE
2. **Reinicie** o celular
3. **Instale** APK novo

---

## 📊 **RESUMO:**

| Passo | Tempo | Status |
|-------|-------|--------|
| 1. Baixar código | 1 min | ⏳ FAZER |
| 2. Recompilar | 3-5 min | ⏳ FAZER |
| 3. Desinstalar antigo | 30 seg | ⏳ FAZER |
| 4. Instalar novo | 30 seg | ⏳ FAZER |
| 5. Testar | 1 min | ⏳ FAZER |

**TOTAL:** ~6-8 minutos ⏱️

---

## 💡 **POR QUE PRECISO RECOMPILAR?**

### **ANTES (código no Replit):**
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
✅ <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />  ← NOVO!
```

### **AGORA (seu APK instalado):**
```xml
<!-- AndroidManifest.xml do APK antigo -->
<uses-permission android:name="android.permission.INTERNET" />
❌ FALTA: ACCESS_NETWORK_STATE  ← POR ISSO O ERRO!
```

**Quando você recompilar:**
- Código atualizado → Compilador lê novo AndroidManifest.xml
- Gera APK com a permissão ✅
- Android aplica permissão ao instalar ✅
- Hook `useNetworkStatus()` funciona! ✅

---

## 🎯 **FAÇA AGORA:**

1. ⬇️ **BAIXE** o projeto (ZIP)
2. 🔨 **COMPILE:** `gerar-apk.bat` ou `./gerar-apk.sh`
3. 🗑️ **DESINSTALE** APK antigo
4. 📱 **INSTALE** APK v1.0.5
5. ✅ **TESTE** badge offline

**Depois me avise se o badge apareceu!** 🎉

---

**Tempo total:** ~6-8 minutos  
**Dificuldade:** Fácil  
**Necessário?** **SIM!** É a ÚNICA solução! ⚡
