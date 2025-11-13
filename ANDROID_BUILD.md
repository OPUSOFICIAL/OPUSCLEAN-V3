# 📱 OPUS Facilities - Guia de Build Android

## 🎯 Visão Geral

Este guia explica como gerar o APK Android do aplicativo OPUS Facilities usando Capacitor.

## ⚠️ IMPORTANTE - Scripts de Build

Existem **dois scripts diferentes** dependendo do que você está fazendo:

### 📱 Para Gerar APK Android:
```bash
npm run build:android
```
**O que faz:** Build apenas do frontend (Vite) - sem passos de banco de dados.

### 🌐 Para Deploy Web (Produção):
```bash
npm run build
```
**O que faz:** Build completo (frontend + backend + database push + seed).

**⚠️ Cuidado:** NÃO use `npm run build` para gerar APK - ele inclui passos de banco de dados que podem travar!

## 📋 Pré-requisitos

### No Ambiente Replit (Desenvolvimento)

Já está tudo configurado! ✅

### Para Build Local (Opcional)

Se você quiser fazer o build localmente no seu computador:

1. **Android Studio** (recomendado) ou **Android SDK Command Line Tools**
2. **JDK 17** ou superior
3. **Gradle** (incluído no projeto Android)

## 🚀 Comandos Rápidos

### 1. Build do Frontend
```bash
npm run build:android
```

Isso gera os arquivos otimizados em `dist/public/`.

### 2. Sincronizar com Android
```bash
npx cap sync android
```

Isso copia os arquivos web para o projeto Android e atualiza dependências nativas.

### 3. Abrir no Android Studio
```bash
npx cap open android
```

Isso abre o projeto Android no Android Studio para desenvolvimento/debug.

## 📦 Gerando o APK

### Opção 1: Via Android Studio (Recomendado)

1. Execute `npx cap open android`
2. No Android Studio:
   - **Build > Build Bundle(s) / APK(s) > Build APK(s)**
3. Aguarde a compilação (pode levar alguns minutos na primeira vez)
4. O APK será salvo em: `android/app/build/outputs/apk/debug/app-debug.apk`

### Opção 2: Via Linha de Comando

```bash
cd android
./gradlew assembleDebug
```

O APK estará em: `android/app/build/outputs/apk/debug/app-debug.apk`

### Para APK Release (Produção)

```bash
cd android
./gradlew assembleRelease
```

⚠️ **Nota:** APK release precisa de assinatura (keystore). Veja seção "Assinatura de APK" abaixo.

## 📱 Instalando o APK no Dispositivo

### Via USB (ADB)

1. Habilite **Depuração USB** no seu Android:
   - Configurações > Sobre o telefone > Toque 7x em "Número da versão"
   - Configurações > Opções do desenvolvedor > Ativar "Depuração USB"

2. Conecte o dispositivo via USB

3. Instale o APK:
```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### Via Download Direto

1. Baixe o APK para o dispositivo
2. Abra o arquivo APK no gerenciador de arquivos
3. Permita instalação de fontes desconhecidas se solicitado
4. Toque em "Instalar"

## 🔑 Assinatura de APK (Release)

Para distribuir o app na Play Store ou gerar APK release, você precisa assinar:

### 1. Criar Keystore

```bash
keytool -genkey -v -keystore opus-facilities.keystore -alias opus-release -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configurar Gradle

Crie `android/keystore.properties`:

```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=opus-release
storeFile=../opus-facilities.keystore
```

### 3. Atualizar `android/app/build.gradle`

Adicione antes de `android { }`:

```gradle
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dentro de `android { }`, adicione:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 4. Gerar Release APK Assinado

```bash
cd android
./gradlew assembleRelease
```

APK assinado: `android/app/build/outputs/apk/release/app-release.apk`

## 🔧 Configuração de Servidor para Desenvolvimento

### Modo Offline-First (Padrão)

O app funciona 100% offline por padrão! Não precisa configurar servidor.

### Conectar a Servidor de Desenvolvimento

Se quiser testar com servidor ao vivo, edite `capacitor.config.ts`:

```typescript
server: {
  url: 'https://SEU_DOMINIO_REPLIT.replit.dev',
  cleartext: true,
}
```

Depois execute:
```bash
npx cap sync android
```

⚠️ **Importante:** Remova essa configuração antes de fazer build de produção!

## 📊 Testando Funcionalidades Offline

### Fluxo de Teste

1. **Instale o APK** no dispositivo
2. **Faça login** com conexão (sincroniza dados iniciais)
3. **Ative Modo Avião** ou desconecte WiFi
4. **Teste offline:**
   - Criar ordem de serviço via QR
   - Executar checklist
   - Adicionar fotos
   - Ver dados salvos localmente
5. **Reconecte** à internet
6. **Verifique sincronização** automática (1 segundo após reconexão)

### Indicadores Visuais

- 🟢 **Online:** Badge verde no header
- 🔴 **Offline:** Badge vermelho + contador de itens pendentes
- ⏳ **Sincronizando:** Loading indicator

## 🐛 Troubleshooting

### Erro: "SDK not found"

Instale Android SDK:
```bash
# Linux/Mac
brew install android-sdk
# ou baixe do site oficial
```

### Erro: "Gradle build failed"

1. Limpe o cache:
```bash
cd android
./gradlew clean
```

2. Tente novamente:
```bash
./gradlew assembleDebug
```

### APK não instala no dispositivo

- Verifique se "Fontes desconhecidas" está habilitado
- Use `adb logcat` para ver erros detalhados
- Certifique-se que o dispositivo tem espaço suficiente

### App crasheia ao abrir

1. Verifique logs:
```bash
adb logcat | grep -i opus
```

2. Certifique-se que o build foi feito corretamente:
```bash
npm run build:android
npx cap sync android
```

## 📚 Recursos Adicionais

- [Documentação Capacitor](https://capacitorjs.com/docs)
- [Workflow de Desenvolvimento](https://capacitorjs.com/docs/basics/workflow)
- [Guia de Plugins](https://capacitorjs.com/docs/plugins)
- [Configuração Android](https://capacitorjs.com/docs/android/configuration)

## 🎯 Próximos Passos

1. ✅ Capacitor configurado
2. ⏳ Adicionar plugins nativos (Camera, Network)
3. ⏳ Testar sincronização offline completa
4. ⏳ Otimizar build para produção
5. ⏳ Preparar para Play Store

---

**Desenvolvido por:** Acelera it  
**Versão:** 1.0.0  
**Última atualização:** Novembro 2025
