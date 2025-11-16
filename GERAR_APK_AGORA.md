# 📱 GERAR APK - OPUS Facilities
## Passo a Passo Completo

---

## ✅ Correções Aplicadas Nesta Versão

1. **Mobile Dashboard**: Agora mostra todas as O.S. disponíveis (77 ordens de serviço)
   - Corrigido: URLs absolutas no APK vs. relativas no navegador
   
2. **QR Execution**: Endpoint implementado para buscar work orders por localização
   - Procura work orders agendadas para a zona escaneada

---

## 🌐 URL Atual do Servidor

```
https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev
```

Esta URL já está configurada no código e será usada automaticamente pelo APK.

---

## 🔧 PASSO 1: Baixar o Código

**Opção A - Download ZIP (Mais Fácil):**
1. No Replit, clique nos 3 pontinhos (⋮) ao lado de "Files"
2. Selecione **"Download as ZIP"**
3. Extraia o arquivo ZIP no seu computador

**Opção B - Git Clone:**
```bash
git clone https://replit.com/@seu-usuario/opus-facilities.git
cd opus-facilities
```

---

## 🔧 PASSO 2: Instalar Dependências

```bash
npm install
```

---

## 🔧 PASSO 3: Gerar o APK

### **No Mac/Linux:**

```bash
# Dar permissão ao script
chmod +x gerar-apk.sh

# Executar
./gerar-apk.sh
```

### **No Windows:**

```bash
gerar-apk.bat
```

### **Manualmente (todos os sistemas):**

```bash
# 1. Build da aplicação web
npm run build:android

# 2. Sincronizar com Capacitor
npx cap sync android

# 3. Compilar o APK
cd android
./gradlew assembleDebug
```

---

## 📦 PASSO 4: Localizar o APK

O APK será gerado em:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

**Tamanho aproximado:** 40-60 MB

---

## 📱 PASSO 5: Instalar no Android

1. **Transfira o APK para seu celular:**
   - Via cabo USB
   - Via Google Drive/Dropbox
   - Via WhatsApp/Email

2. **No celular Android:**
   - Abra o arquivo `app-debug.apk`
   - Permita instalação de fontes desconhecidas (se solicitado)
   - Toque em **"Instalar"**

3. **Abra o app "OPUS Facilities"**

---

## 🧪 PASSO 6: Testar o APK

### ✅ Teste 1: Login
- Usuário: `joao.geral`
- Senha: `joao123`

### ✅ Teste 2: Dashboard Mobile
- Deve mostrar **"77 Disponíveis"** (ou o número atual de O.S. não atribuídas)
- Clique em "Disponíveis" para ver a lista completa

### ✅ Teste 3: QR Code Scanner
- Abra o scanner QR
- Escaneie um QR code de ponto de execução
- Deve mostrar se há serviços agendados para aquele local

---

## ⚠️ Requisitos do Sistema

### **No seu computador:**
- ✅ Node.js 18+ instalado
- ✅ JDK 17+ instalado
- ✅ Android SDK instalado
- ✅ Gradle (incluído com Android SDK)

### **No celular:**
- ✅ Android 5.0 (API 21) ou superior
- ✅ Câmera (para scanner QR)
- ✅ Conexão com internet

---

## 🐛 Problemas Comuns

### Erro: "JAVA_HOME not set"
```bash
# Mac/Linux
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Windows
set JAVA_HOME=C:\Program Files\Java\jdk-17
```

### Erro: "Android SDK not found"
```bash
# Defina a variável ANDROID_HOME
export ANDROID_HOME=~/Android/Sdk  # Mac/Linux
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk  # Windows
```

### APK não instala no celular
- Vá em **Configurações → Segurança**
- Habilite **"Fontes Desconhecidas"** ou **"Instalar apps desconhecidos"**

---

## 📊 O Que Esperar no APK

### ✅ Funcionando:
- ✅ Login com usuários do sistema
- ✅ Dashboard mobile mostrando O.S. disponíveis (77)
- ✅ Lista de work orders disponíveis
- ✅ Scanner QR code
- ✅ Detecção de localização via QR
- ✅ Modo offline (IndexedDB)

### 🔄 Em desenvolvimento:
- Execução completa de checklist offline
- Anexo de fotos offline
- Sincronização batch completa

---

## 🎯 Próximos Testes

Depois de instalar o APK:

1. **Teste de conectividade:**
   - O app deve conectar ao servidor automaticamente
   - Dashboard deve carregar as 77 O.S.

2. **Teste de QR:**
   - Escaneie um QR code válido
   - Verifique se mostra work orders agendadas

3. **Teste offline:**
   - Desative Wi-Fi e dados móveis
   - Tente executar um serviço
   - Reative internet e verifique sincronização

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs do Android Studio
2. Teste primeiro no navegador Chrome: https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev
3. Confirme que o servidor está rodando

---

**Última atualização:** 16/11/2025
**Versão:** 1.2.0 - Dashboard Mobile + QR Execution
