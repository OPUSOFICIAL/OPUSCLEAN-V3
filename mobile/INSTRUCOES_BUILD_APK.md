# Acelera Facilities - Instrucoes para Gerar APK

## Expo SDK 54 | React Native 0.81 | React 19

Este projeto usa as versoes mais recentes do Expo, garantindo:
- Suporte a 16KB page size (obrigatorio Google Play a partir de Nov/2025)
- Builds iOS 10x mais rapidos
- React 19 com melhorias de performance
- Kotlin 2.0 e Android 16 support

---

## Opcao 1: Build LOCAL no seu PC (Recomendado)

### Pre-requisitos

1. **Node.js 20 LTS** - https://nodejs.org/
   - NAO use Node 18 (end of life) ou Node 22+ (experimental)
   
2. **Java JDK 17** - https://adoptium.net/ (Temurin 17)

3. **Android Studio** - https://developer.android.com/studio
   - Abra o Android Studio
   - Va em Tools > SDK Manager
   - Instale: Android SDK 35, Build Tools 35.0.0, NDK 27.1.x

### Configuracao das Variaveis de Ambiente

#### Windows (PowerShell como Admin)

```powershell
# Definir variaveis de ambiente permanentemente
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot", "User")
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")

# Adicionar ao PATH
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$newPath = "$currentPath;%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools"
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
```

Reinicie o terminal depois!

#### Mac/Linux

Adicione ao `~/.bashrc` ou `~/.zshrc`:
```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin
```

Execute: `source ~/.bashrc`

### Passo a Passo Completo

**1. Baixar o projeto do Replit:**
- Clique nos 3 pontinhos no topo > "Download as zip"
- Extraia o zip

**2. Abrir terminal na pasta mobile:**
```bash
cd caminho/para/pasta/mobile
```

**3. Limpar e instalar dependencias:**
```bash
# Remover arquivos antigos se existirem
rm -rf node_modules package-lock.json android ios .expo

# Instalar dependencias
npm install

# Corrigir versoes automaticamente
npx expo install --fix
```

**4. Gerar projeto Android nativo (Expo SDK 54):**
```bash
npx expo prebuild --platform android --clean
```

Isso cria a pasta `android/` com todo o codigo nativo, incluindo:
- Kotlin 2.0.21 configurado automaticamente
- NDK 27 para suporte a 16KB page size
- AGP 8.5+ para Android 16
- New Architecture habilitada

**IMPORTANTE:** Os arquivos `android/gradle.properties` e `android/build.gradle` que estao no repositorio servem apenas como referencia. O comando `expo prebuild --clean` regenera tudo usando as configuracoes do `app.json`.

**5. Compilar o APK:**

**Windows:**
```bash
cd android
.\gradlew.bat clean
.\gradlew.bat assembleRelease
```

**Mac/Linux:**
```bash
cd android
./gradlew clean
./gradlew assembleRelease
```

**6. APK gerado em:**
```
android/app/build/outputs/apk/release/app-release.apk
```

---

## Solucao de Problemas Comuns

### Erro: "SDK location not found"

Crie o arquivo `android/local.properties`:
```properties
sdk.dir=C:\\Users\\SEU_USUARIO\\AppData\\Local\\Android\\Sdk
```

No Mac:
```properties
sdk.dir=/Users/SEU_USUARIO/Library/Android/sdk
```

### Erro: "JAVA_HOME is set to an invalid directory"

Verifique o caminho correto do Java:

**Windows:**
```powershell
where java
```

**Mac/Linux:**
```bash
which java
/usr/libexec/java_home -V
```

### Erro: "compileReleaseKotlin FAILED" ou versao do Kotlin

O Expo SDK 54 usa **Kotlin 2.0.21** por padrao. Isso ja esta configurado em:
- `app.json` (expo-build-properties)
- `android/gradle.properties`

Se houver conflito:
1. Apague a pasta android: `rm -rf android`
2. Rode: `npx expo prebuild --platform android --clean`
3. Compile novamente

### Erro de memoria durante build

O projeto ja esta configurado com memoria aumentada em `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
```

### Erro: "Unable to find expo package"

Execute:
```bash
npx expo install --fix
```

---

## Build de Release (Producao)

Para gerar APK assinado para distribuir na Play Store:

**1. Gerar keystore:**
```bash
keytool -genkeypair -v -storetype PKCS12 -keystore acelera-facilities.keystore -alias acelera-key -keyalg RSA -keysize 2048 -validity 10000
```
Guarde a senha que voce definir!

**2. Mover keystore:**
```bash
mv acelera-facilities.keystore android/app/
```

**3. Configurar em `android/gradle.properties`:**
```properties
MYAPP_UPLOAD_STORE_FILE=acelera-facilities.keystore
MYAPP_UPLOAD_KEY_ALIAS=acelera-key
MYAPP_UPLOAD_STORE_PASSWORD=SUA_SENHA
MYAPP_UPLOAD_KEY_PASSWORD=SUA_SENHA
```

**4. Editar `android/app/build.gradle`:**

Procure a secao `android {` e adicione dentro dela:
```gradle
signingConfigs {
    release {
        storeFile file(MYAPP_UPLOAD_STORE_FILE)
        storePassword MYAPP_UPLOAD_STORE_PASSWORD
        keyAlias MYAPP_UPLOAD_KEY_ALIAS
        keyPassword MYAPP_UPLOAD_KEY_PASSWORD
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

**5. Compilar release:**
```bash
cd android
./gradlew assembleRelease
```

**6. APK em:**
```
android/app/build/outputs/apk/release/app-release.apk
```

---

## Opcao 2: Build na Nuvem (EAS Build)

Se nao quiser instalar Android Studio no PC:

```bash
cd mobile
rm -rf node_modules package-lock.json
npm install

# Instalar e logar no EAS
npm install -g eas-cli
eas login

# Build na nuvem
eas build --platform android --profile preview --clear-cache
```

O APK sera gerado na nuvem (5-15 min) e voce recebe link para download.

---

## Instalar no Celular

1. Transfira o `.apk` para o celular (email, drive, cabo USB)
2. Abra o arquivo no celular
3. Permita "Fontes desconhecidas" se solicitado
4. Instale e abra o app
5. Faca login com suas credenciais

---

## Servidor

O app conecta automaticamente em:
```
https://facilities.grupoopus.com
```

Para alterar, edite `app.json` > `extra.apiUrl`

---

## Funcionalidades Offline

O app funciona 100% offline:
- Sincroniza automaticamente quando online
- Armazena OSs localmente em SQLite
- Permite concluir/pausar OSs offline
- Envia tudo ao servidor quando reconectar

---

## Especificacoes Tecnicas

| Item | Versao |
|------|--------|
| Expo SDK | 54 |
| React Native | 0.81.2 |
| React | 19.1.0 |
| Kotlin | 2.0.21 |
| compileSdkVersion | 35 |
| targetSdkVersion | 35 |
| minSdkVersion | 24 |
| Java | 17 |
| Node.js | 20+ |

---

## Recursos do App

- Login com autenticacao JWT
- Lista de Ordens de Servico
- Execucao de OS com checklist dinamico
- Tipos de checklist: boolean, text, number, select, checkbox, photo
- Pausar/Retomar OS com motivo e fotos
- Scanner QR para identificar pontos/zonas
- Upload de fotos com compressao automatica
- Sincronizacao offline-first com SQLite
- Fila de pendencias para envio quando online
