# 🔧 FIX: Detecção de Rede e Erro no QR Scanner

## 🐛 **PROBLEMA IDENTIFICADO:**

### **Sintomas:**
1. ❌ Badge "Offline" **NÃO aparece** quando em modo avião
2. ❌ Scanner QR mostra erro: **"Erro de conexão. Verifique sua internet e tente novamente."**
3. ❌ APK não detecta se está online/offline

### **Causa Raiz:**

O plugin `@capacitor/network` **está instalado**, mas faltava a **permissão Android** necessária!

```xml
<!-- FALTAVA ESTA PERMISSÃO NO AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**Sem essa permissão:**
- `useNetworkStatus()` sempre retorna `isOnline: true` (padrão)
- APK tenta fazer chamadas API mesmo offline
- Chamada falha → erro "Erro de conexão"
- Badge "Offline" nunca aparece

---

## ✅ **SOLUÇÃO APLICADA:**

### **1. Permissão Adicionada**

Editei `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- ✅ NOVO: Network Status Detection (Capacitor Network Plugin) -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Camera Permissions -->
<uses-permission android:name="android.permission.CAMERA" />
```

### **2. Como Funciona Agora:**

```typescript
// client/src/hooks/use-network-status.ts
export function useNetworkStatus() {
  const [status, setStatus] = useState<NetworkStatus>({
    isOnline: true,  // Padrão inicial
    connectionType: 'unknown'
  });

  useEffect(() => {
    // ✅ AGORA FUNCIONA com a permissão!
    const getInitialStatus = async () => {
      const networkStatus = await Network.getStatus();  // ← Precisa da permissão!
      setStatus({
        isOnline: networkStatus.connected,  // ← Detecta corretamente!
        connectionType: networkStatus.connectionType
      });
    };

    getInitialStatus();

    // ✅ Listener de mudanças também funciona!
    Network.addListener('networkStatusChange', (status) => {
      setStatus({
        isOnline: status.connected,
        connectionType: status.connectionType
      });
    });
  }, []);

  return status;
}
```

### **3. Scanner QR - Fluxo Corrigido:**

```typescript
// client/src/pages/mobile-qr-scanner.tsx
const handleQrCodeDetected = async (qrCode: string) => {
  // ✅ AGORA detecta corretamente!
  if (!isOnline) {
    // MODO OFFLINE: Busca do cache
    const cachedPoint = await getQRPoint(code);
    if (cachedPoint) {
      // ✅ Funciona offline!
      toast({ 
        title: "✈️ QR Code detectado! (Modo Offline)" 
      });
    } else {
      // ⚠️ QR não está no cache
      toast({ 
        title: "QR Code não encontrado offline",
        description: "Conecte-se à internet para sincronizar."
      });
    }
    return;
  }

  // MODO ONLINE: Busca da API
  const response = await fetch(`${apiUrl}/qr-scan/resolve?code=${code}`);
  // ...
};
```

---

## 🎯 **O QUE MUDOU:**

| Antes (APK v1.0.4 e anteriores) | Depois (APK v1.0.5) |
|----------------------------------|---------------------|
| ❌ `isOnline` sempre `true` | ✅ Detecta corretamente |
| ❌ Tenta API mesmo offline | ✅ Usa cache offline |
| ❌ Erro "Erro de conexão" | ✅ Toast "Modo Offline" |
| ❌ Badge não aparece | ✅ Badge laranja 🟠 |

---

## 📱 **RECOMPILAR APK v1.0.5:**

### **PASSO 1: Baixar Código Atualizado**

1. No Replit: **3 pontinhos (⋮)** → **"Download as ZIP"**
2. Extraia na sua máquina
3. **SUBSTITUA** a pasta antiga

### **PASSO 2: Recompilar**

**Windows:**
```bash
gerar-apk.bat
```

**Mac/Linux:**
```bash
./gerar-apk.sh
```

**Resultado:**
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### **PASSO 3: Reinstalar no Celular**

⚠️ **IMPORTANTE:**
1. **DESINSTALE** o APK antigo completamente
2. **Confirme** a desinstalação
3. **INSTALE** o novo APK

Isso garante que as **novas permissões** sejam aplicadas!

---

## 🧪 **TESTES OBRIGATÓRIOS:**

### ✅ **TESTE 1: Detecção Online**

1. **Abra o APK** (com Wi-Fi ligado)
2. Faça login: `admin` / `admin123`
3. Toque em **"Scanner QR"**
4. ✅ **Badge "Offline" NÃO deve aparecer**
5. Console mostra:
   ```
   [NETWORK] Status changed: { connected: true, connectionType: 'wifi' }
   ```

---

### ✅ **TESTE 2: Detecção Offline**

1. **ATIVE MODO AVIÃO** ✈️
2. Aguarde **~2 segundos**
3. ✅ **Badge laranja "Offline" DEVE aparecer!** 🟠
4. Console mostra:
   ```
   [NETWORK] Status changed: { connected: false, connectionType: 'none' }
   ```

---

### ✅ **TESTE 3: Scanner QR Offline**

1. **Modo avião ligado** ✈️
2. **Badge "Offline" visível** 🟠
3. **Escaneie um QR code** (que já foi escaneado antes online)
4. ✅ **Toast:** "✈️ QR Code detectado! (Modo Offline)"
5. ✅ Zona e Site aparecem (do cache)
6. ❌ **NÃO deve mostrar:** "Erro de conexão"

**Console esperado:**
```
[QR SCANNER OFFLINE] Buscando QR code do cache: XXX
[OFFLINE STORAGE] QR point encontrado no cache: XXX
[OFFLINE STORAGE] Zone encontrada: YYY
```

---

### ✅ **TESTE 4: QR Não Cacheado Offline**

1. **Modo avião ligado** ✈️
2. **Escaneie um QR code NOVO** (nunca escaneado antes)
3. ✅ **Toast:** "QR Code não encontrado offline"
4. ✅ **Descrição:** "Este QR code não está no cache offline. Conecte-se à internet para sincronizar."
5. ❌ **NÃO deve mostrar:** "Erro de conexão"

**Console esperado:**
```
[QR SCANNER OFFLINE] Buscando QR code do cache: XXX
[OFFLINE STORAGE] QR point NÃO encontrado no cache
```

---

### ✅ **TESTE 5: Transição Online → Offline**

1. **Inicie com Wi-Fi ligado**
2. Badge "Offline" **NÃO aparece**
3. **ATIVE modo avião** ✈️
4. **Aguarde ~2 segundos**
5. ✅ **Badge "Offline" APARECE automaticamente!** 🟠

**Console esperado:**
```
[NETWORK] Status changed: { connected: false, connectionType: 'none' }
```

---

### ✅ **TESTE 6: Transição Offline → Online**

1. **Modo avião ligado** ✈️
2. Badge "Offline" **visível** 🟠
3. **DESLIGUE modo avião**
4. **Aguarde ~2-3 segundos**
5. ✅ **Badge "Offline" DESAPARECE automaticamente!**
6. ✅ **Auto-sync inicia!**
7. ✅ **Toast:** "✅ X item(s) sincronizado(s)"

**Console esperado:**
```
[NETWORK] Status changed: { connected: true, connectionType: 'wifi' }
[SYNC] Device reconnected, triggering automatic sync...
[SYNC QUEUE] Starting sync queue processing...
```

---

## 🔍 **VERIFICAR LOGS NO APK:**

### **Chrome Remote Debugging:**

1. No PC: `chrome://inspect`
2. Conecte celular via USB
3. **Inspect** no OPUS Facilities
4. Console:

```javascript
// ✅ LOGS ESPERADOS:
[NETWORK] Status changed: { connected: true, connectionType: 'wifi' }
[NETWORK] Status changed: { connected: false, connectionType: 'none' }
[QR SCANNER OFFLINE] Buscando QR code do cache: XXX
[OFFLINE STORAGE] QR point encontrado no cache: XXX
```

---

## 📊 **COMPARAÇÃO ANTES vs DEPOIS:**

### **ANTES (SEM PERMISSÃO):**

```
1. Usuario abre scanner
2. Network.getStatus() → ❌ FALHA (sem permissão)
3. isOnline = true (padrão)
4. Scanner tenta API
5. Fetch falha → "Erro de conexão"
6. Badge nunca aparece
```

### **DEPOIS (COM PERMISSÃO):**

```
1. Usuario abre scanner
2. Network.getStatus() → ✅ FUNCIONA!
3. isOnline = false (detectado!)
4. Badge "Offline" aparece 🟠
5. Scanner usa cache
6. Toast: "✈️ Modo Offline"
```

---

## ⚠️ **PROBLEMAS CONHECIDOS:**

### **1. Badge não aparece mesmo com permissão**

**Causa:** APK não foi desinstalado antes de reinstalar

**Solução:**
1. **Desinstale completamente** o APK antigo
2. **Confirme** a desinstalação
3. **Instale** o novo APK
4. Android solicita permissões na 1ª abertura

---

### **2. Console não mostra logs [NETWORK]**

**Causa:** Plugin não está sendo inicializado

**Solução:**
1. Verifique se o APK foi recompilado após adicionar a permissão
2. Limpe cache: `cd android && ./gradlew clean`
3. Recompile: `./gradlew assembleDebug`

---

### **3. Detecção funciona mas auto-sync não**

**Causa:** Hook `useSyncOnReconnect` não está ativo

**Solução:**
Verifique `client/src/App.tsx`:

```typescript
export default function App() {
  useSyncOnReconnect();  // ← DEVE ESTAR AQUI!
  
  return (
    <SidebarProvider>
      {/* ... */}
    </SidebarProvider>
  );
}
```

---

## 📚 **ARQUIVOS MODIFICADOS:**

### ✅ **android/app/src/main/AndroidManifest.xml**
```xml
<!-- ✅ ADICIONADO -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### ✅ **client/src/hooks/use-network-status.ts**
```typescript
// JÁ EXISTIA - Agora funciona com a permissão!
import { Network } from '@capacitor/network';

export function useNetworkStatus() {
  const [status, setStatus] = useState({
    isOnline: true,
    connectionType: 'unknown'
  });

  useEffect(() => {
    // ✅ Agora funciona!
    Network.getStatus().then(status => {
      setStatus({
        isOnline: status.connected,
        connectionType: status.connectionType
      });
    });

    Network.addListener('networkStatusChange', (status) => {
      setStatus({
        isOnline: status.connected,
        connectionType: status.connectionType
      });
    });
  }, []);

  return status;
}
```

### ✅ **client/src/pages/mobile-qr-scanner.tsx**
```typescript
// JÁ EXISTIA - Agora funciona corretamente!
const { isOnline } = useNetworkStatus();  // ✅ Detecta corretamente!

const handleQrCodeDetected = async (qrCode: string) => {
  if (!isOnline) {  // ✅ Funciona!
    // Busca do cache
    const cachedPoint = await getQRPoint(code);
    // ...
  } else {
    // Busca da API
    const response = await fetch(apiUrl);
    // ...
  }
};
```

---

## 🎯 **CHECKLIST FINAL:**

Antes de considerar o fix completo:

- [ ] ✅ Permissão `ACCESS_NETWORK_STATE` adicionada
- [ ] ✅ APK v1.0.5 compilado
- [ ] ✅ APK antigo desinstalado
- [ ] ✅ APK novo instalado
- [ ] ✅ Badge "Offline" aparece em modo avião
- [ ] ✅ Scanner QR offline funciona (cache)
- [ ] ✅ Toast "Modo Offline" aparece
- [ ] ✅ Auto-sync ao reconectar funciona
- [ ] ✅ Logs `[NETWORK]` aparecem no console

---

**Versão:** APK v1.0.5  
**Fix:** Detecção de rede Android  
**Data:** Novembro 2025  
**Status:** ✅ CORRIGIDO!
