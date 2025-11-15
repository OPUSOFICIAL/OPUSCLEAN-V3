# 🔍 DEBUG COMPLETO DO APK

## 🎯 **O QUE VERIFICAR AGORA:**

Você compilou o APK novo, mas o erro persiste. Vamos descobrir exatamente o que está acontecendo!

---

## 📱 **PASSO 1: Verificar Logs do APK**

### **Chrome Remote Debugging:**

1. **No PC:** Abra Chrome
2. Digite na barra: `chrome://inspect`
3. **Conecte** o celular via USB
4. **Ative** "Depuração USB" no Android:
   - Configurações → Sobre o telefone → Toque 7x em "Número da versão"
   - Configurações → Opções do desenvolvedor → Depuração USB ✅
5. No Chrome: Clique em **"Inspect"** no OPUS Facilities
6. **Abra a aba Console**

---

## 🧪 **PASSO 2: Teste Com Logs**

### **TESTE 1: Verificar Detecção de Rede**

1. Abra o APK
2. Login: `admin` / `admin123`
3. **Olhe no console do Chrome** (chrome://inspect)
4. **Procure por:**

```
[NETWORK] Initial status: online  ← DEVE APARECER!
```

**Se NÃO aparecer:**
- ❌ Plugin Network não está funcionando
- ❌ Permissão não foi aplicada

**Se aparecer "online":**
- ✅ Plugin funcionando!

---

### **TESTE 2: Verificar Modo Offline**

1. **ATIVE MODO AVIÃO** ✈️
2. Aguarde 2 segundos
3. **Olhe no console:**

```
[NETWORK] Status changed: { connected: false, connectionType: 'none' }
```

**Se NÃO aparecer:**
- ❌ Listener de rede não funciona
- ❌ APK antigo ainda instalado

**Se aparecer:**
- ✅ Detecção de rede funcionando!

---

### **TESTE 3: Scanner QR Online**

1. **Desligue modo avião**
2. Toque em **"Scanner QR"**
3. **Escaneie um QR code**
4. **Olhe no console:**

```
[QR SCANNER ONLINE] Chamando API: https://servidor.com/api/qr-scan/resolve?code=XXX
```

**Se NÃO aparecer:**
- ❌ Scanner não está detectando como online
- ❌ isOnline está false quando deveria ser true

**Se aparecer mas der erro:**
- Copie o **erro completo** e me mande!

---

### **TESTE 4: Scanner QR Offline**

1. **ATIVE MODO AVIÃO** ✈️
2. Aguarde 2 segundos
3. Badge "Offline" **deve aparecer** 🟠
4. **Escaneie um QR code** (já escaneado antes)
5. **Olhe no console:**

```
[QR SCANNER OFFLINE] Buscando QR code do cache: XXX
[OFFLINE STORAGE] QR point encontrado no cache: XXX
```

**Se aparecer:**
- ✅ Modo offline funcionando!
- ✅ Cache funciona!

**Se NÃO aparecer:**
- ❌ isOnline está true (deveria ser false)
- ❌ QR nunca foi escaneado online (não está no cache)

---

## 🐛 **POSSÍVEIS CAUSAS DO ERRO:**

### **1. APK Antigo Ainda Instalado**

**Sintoma:**
- Logs `[NETWORK]` **NÃO aparecem**
- Badge "Offline" **nunca aparece**

**Solução:**
```bash
# No celular:
1. Configurações → Apps → OPUS Facilities
2. Armazenamento → Limpar dados
3. Desinstalar COMPLETAMENTE
4. Reiniciar celular
5. Reinstalar APK novo
```

---

### **2. Plugin Network Não Sincronizado**

**Sintoma:**
- Logs `[NETWORK]` **NÃO aparecem**
- Erro ao importar `@capacitor/network`

**Solução:**
```bash
# No PC, na pasta do projeto:
npx cap sync android
cd android && ./gradlew clean
./gradlew assembleDebug
```

---

### **3. Token Expirado**

**Sintoma:**
- Logs `[NETWORK]` aparecem
- Erro: "Não autenticado" (401)

**Solução:**
```bash
# No APK:
1. Faça logout
2. Faça login novamente
3. Tente escanear QR
```

---

### **4. URL do Servidor Incorreta**

**Sintoma:**
- Logs `[NETWORK]` aparecem
- Erro: "Failed to fetch" ou "net::ERR_CONNECTION_REFUSED"

**Solução:**
Verifique se o servidor está respondendo:

```bash
# No navegador do PC, acesse:
https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev/api/health

# Se NÃO carregar:
- Servidor Neon está suspenso
- Me avise que reativo!
```

---

### **5. QR Code Não Cadastrado**

**Sintoma:**
- Logs `[NETWORK]` aparecem
- Erro: "QR Code não encontrado" (404)

**Solução:**
Use um QR code válido cadastrado no sistema!

**QR codes de teste disponíveis:**
- Acesse o dashboard web
- Admin → Pontos QR
- Veja os códigos cadastrados

---

## 📋 **CHECKLIST DE DEBUG:**

Marque conforme testa:

**Logs de Rede:**
- [ ] `[NETWORK] Initial status: online` aparece ao abrir app
- [ ] `[NETWORK] Status changed: ...` aparece ao ativar modo avião
- [ ] Badge "Offline" aparece em modo avião 🟠

**Scanner QR Online:**
- [ ] `[QR SCANNER ONLINE] Chamando API: ...` aparece
- [ ] QR code é detectado
- [ ] Modal de seleção de serviço abre

**Scanner QR Offline:**
- [ ] `[QR SCANNER OFFLINE] Buscando QR code do cache: ...` aparece
- [ ] QR code é encontrado no cache
- [ ] Toast: "✈️ QR Code detectado! (Modo Offline)"

**Erros:**
- [ ] Erro mostra mensagem específica (não genérica)
- [ ] Console mostra `[QR SCANNER ERROR]` com detalhes

---

## 🎯 **O QUE ME ENVIAR:**

Se o erro persistir, me envie:

### **1. Screenshot do Console** (chrome://inspect)

Com os logs de:
- `[NETWORK] ...`
- `[QR SCANNER ...]`
- `[QR SCANNER ERROR] ...`

### **2. Responda:**

**a) Badge "Offline" aparece em modo avião?**
- [ ] SIM
- [ ] NÃO

**b) Qual mensagem de erro aparece ao escanear QR?**
- Copie exatamente: "_______________________"

**c) Logs `[NETWORK]` aparecem no console?**
- [ ] SIM - mostre screenshot
- [ ] NÃO - APK antigo ainda

---

## ⚡ **TESTE RÁPIDO (30 segundos):**

```
1. Abra APK
2. Ative modo avião ✈️
3. Vá no Scanner QR
4. Badge "Offline" aparece? ← RESPOSTA AQUI!
```

**Se SIM:** Detecção funciona! O erro é outra coisa.  
**Se NÃO:** APK antigo ou plugin não funciona.

---

## 🔧 **RECOMPILAR COM LIMPEZA TOTAL:**

Se nada funcionar, faça limpeza completa:

```bash
# 1. Limpar cache Android
cd android
./gradlew clean

# 2. Rebuild completo
cd ..
npm run build:android
npx cap sync android

# 3. Compilar APK
cd android
./gradlew assembleDebug

# 4. APK estará em:
# android/app/build/outputs/apk/debug/app-debug.apk
```

---

**Me responda com os resultados dos testes!** 🔍
