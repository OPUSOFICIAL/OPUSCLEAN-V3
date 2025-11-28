# Acelera Facilities - Instrucoes para Gerar APK

## Opcao 1: Build LOCAL no seu PC (Recomendado)

### Pre-requisitos

1. **Node.js 18 ou 20 LTS** - https://nodejs.org/ (NAO use Node 22+)
2. **Java JDK 17** - https://adoptium.net/ (Temurin 17)
3. **Android Studio** - https://developer.android.com/studio
   - Abra o Android Studio
   - Vá em Tools → SDK Manager
   - Instale: Android SDK 34 ou 35, Build Tools 35.0.0

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
- Clique nos 3 pontinhos no topo → "Download as zip"
- Extraia o zip

**2. Abrir terminal na pasta mobile:**
```bash
cd caminho/para/pasta/mobile
```

**3. Limpar e instalar dependencias:**
```bash
# Remover arquivos antigos se existirem
rm -rf node_modules package-lock.json android ios

# Instalar dependencias
npm install

# Corrigir versoes (IMPORTANTE!)
npx expo install --fix
```

**4. Gerar projeto Android nativo:**
```bash
npx expo prebuild --platform android --clean
```

Isso cria a pasta `android/` com todo o codigo nativo.

**5. Compilar o APK:**

**Windows:**
```bash
cd android
.\gradlew.bat assembleDebug
```

**Mac/Linux:**
```bash
cd android
./gradlew assembleDebug
```

**6. APK gerado em:**
```
android/app/build/outputs/apk/debug/app-debug.apk
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

### Erro: "compileReleaseKotlin FAILED"

O plugin `expo-build-properties` ja esta configurado no `app.json` com:
- kotlinVersion: 1.9.24
- compileSdkVersion: 35

Se ainda der erro, limpe e reconstrua:
```bash
cd android
./gradlew clean
cd ..
npx expo prebuild --platform android --clean
cd android
./gradlew assembleDebug
```

### Erro de memoria durante build

Edite `android/gradle.properties` e adicione:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
org.gradle.daemon=true
org.gradle.parallel=true
```

### Erro: "Unable to find expo package"

Execute novamente:
```bash
npx expo install --fix
```

---

## Build de Release (Producao)

Para gerar APK assinado para distribuir:

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

Se nao quiser instalar Android Studio:

```bash
cd mobile
rm -rf node_modules package-lock.json
npm install
npm install -g eas-cli
eas login
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

Para alterar, edite `app.json` → `extra.apiUrl`

---

## Funcionalidades Offline

O app funciona 100% offline:
- Sincroniza automaticamente quando online
- Armazena OSs localmente em SQLite
- Permite concluir/pausar OSs offline
- Envia tudo ao servidor quando reconectar
