# 📱 Como Gerar o APK no Seu Computador

## ⚡ Opção Rápida (Recomendada)

### 1️⃣ Baixar Projeto Atualizado

Baixe TODO o projeto desta Replit para o seu computador:
- Clique em **"⋮"** (três pontos) no canto superior direito
- Selecione **"Download as ZIP"**
- Extraia o ZIP em uma pasta no seu PC

### 2️⃣ Instalar Dependências

```bash
# No terminal/prompt de comando:
cd [PASTA-DO-PROJETO]
npm install
```

### 3️⃣ Gerar APK

**Windows:**
```bash
npm run build:android
npx cap sync android
cd android
gradlew.bat assembleDebug
```

**Mac/Linux:**
```bash
npm run build:android
npx cap sync android
cd android
./gradlew assembleDebug
```

### 4️⃣ Localizar APK

O APK estará em:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

## 📋 Pré-requisitos

Se der erro, instale:

### ✅ Node.js
- Baixe: https://nodejs.org/
- Versão: 18 ou superior

### ✅ JDK (Java Development Kit)
- Baixe: https://adoptium.net/
- Versão: 17 ou superior
- Configure JAVA_HOME (o instalador geralmente faz isso)

### ✅ Android SDK (Automático)
O Gradle baixa automaticamente na primeira vez!

## 🚀 Testando Offline

Depois de instalar o APK no celular:

1. **Login online** (sincroniza dados)
2. **Modo avião** (testa offline)
3. **Escanear QR** → Deve mostrar atividade programada
4. **Executar checklist** + fotos
5. **Reconectar** → Auto-sync automático!

## 🐛 Problemas Comuns

### "JAVA_HOME not found"
- Windows: Painel de Controle → Sistema → Variáveis de Ambiente
- Adicione: `JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.x.x`

### "SDK not found"
- O Gradle baixa automaticamente
- Se falhar, instale Android Studio: https://developer.android.com/studio

### "npm not found"
- Instale Node.js: https://nodejs.org/

---

## 📦 APK Atual

**Versão:** 1.0.0  
**Features offline:**
- ✅ QR scan offline
- ✅ Scheduled work orders em cache
- ✅ Checklist templates em cache
- ✅ Photo capture nativo
- ✅ Auto-sync quando reconecta
- ✅ Priorização determinística (scheduledStartAt → createdAt → id)

**Banco de dados offline:**
- IndexedDB v4
- Stores: qrPoints, zones, scheduledWorkOrders, checklistTemplates
- Sync queue com exponential backoff
- Parent-child ID linkage automático
