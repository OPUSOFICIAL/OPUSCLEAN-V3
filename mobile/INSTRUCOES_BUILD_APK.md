# OPUS Facilities - Instrucoes para Gerar APK

## Opcao 1: Build LOCAL no seu PC (Recomendado)

### Pre-requisitos para Build Local

1. **Node.js 18 ou 20 LTS** - https://nodejs.org/ (NAO use Node 22+)
2. **Java JDK 17** - https://adoptium.net/ (Temurin 17)
3. **Android Studio** - https://developer.android.com/studio
   - Instale o Android SDK (API 34/35)
   - Configure a variavel ANDROID_HOME

### Configuracao das Variaveis de Ambiente

#### Windows

Adicione ao PATH do sistema:
```
JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17.x.x.x-hotspot
ANDROID_HOME = C:\Users\SEU_USUARIO\AppData\Local\Android\Sdk
```

Adicione ao PATH:
```
%JAVA_HOME%\bin
%ANDROID_HOME%\platform-tools
```

#### Mac/Linux

Adicione ao `.bashrc` ou `.zshrc`:
```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Passo a Passo - Build Local

1. **Baixar o projeto** do Replit (Menu → Download as zip)

2. **Extrair e entrar na pasta mobile:**
```bash
cd mobile
npm install
```

3. **Gerar o projeto Android nativo:**
```bash
npx expo prebuild --platform android --clean
```

4. **Compilar o APK de Debug (para testes):**
```bash
cd android
./gradlew assembleDebug
```

No Windows, use:
```bash
cd android
gradlew.bat assembleDebug
```

5. **O APK estara em:**
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### Build de Release (Producao)

Para gerar um APK de producao assinado:

1. **Gere uma keystore:**
```bash
keytool -genkeypair -v -storetype PKCS12 -keystore my-upload-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

2. **Mova a keystore para android/app/**

3. **Edite android/gradle.properties:**
```properties
MYAPP_UPLOAD_STORE_FILE=my-upload-key.keystore
MYAPP_UPLOAD_KEY_ALIAS=my-key-alias
MYAPP_UPLOAD_STORE_PASSWORD=sua_senha
MYAPP_UPLOAD_KEY_PASSWORD=sua_senha
```

4. **Compile o release:**
```bash
cd android
./gradlew assembleRelease
```

5. **APK gerado em:**
```
android/app/build/outputs/apk/release/app-release.apk
```

---

## Opcao 2: Build na Nuvem (Alternativa sem Android Studio)

### Pre-requisitos

1. **Node.js 18+** - https://nodejs.org/
2. **Conta Expo** - Criar em https://expo.dev/signup (gratis)

### Passo a Passo

1. **Baixar o projeto** do Replit

2. **Preparar o projeto:**
```bash
cd mobile
npm install
npm install -g eas-cli
```

3. **Login no Expo:**
```bash
eas login
```

4. **Configurar o projeto:**
```bash
eas build:configure
```

5. **Gerar APK na nuvem:**
```bash
eas build --platform android --profile preview
```

O APK sera gerado nos servidores do Expo (5-15 min) e voce recebera um link para download.

---

## Instalar no Celular

1. Transfira o arquivo `.apk` para o celular
2. Abra o arquivo no celular
3. Permita instalacao de fontes desconhecidas se solicitado
4. Instale e abra o app

---

## Funcionalidades do App

### Telas Disponveis

1. **Login**: Autenticacao com usuario e senha
2. **Selecao de Cliente**: Para usuarios multi-cliente
3. **Lista de OSs**: Ordens de servico do dia
4. **Execucao de OS**: 
   - Checklist dinamico (boolean, texto, select, checkbox, foto)
   - Captura de fotos com compressao automatica
   - Pausar/retomar com motivo e fotos
5. **Scanner QR**: Identificacao de pontos/zonas

### Funcionalidades Offline

O app funciona 100% offline:

#### Quando ONLINE:
- Sincroniza automaticamente a cada 1 minuto
- Baixa OSs abertas/pausadas de hoje e amanha
- Baixa QR codes e checklists do cliente
- Envia alteracoes pendentes para o servidor

#### Quando OFFLINE:
- Exibe OSs salvas localmente
- Permite concluir ou pausar OSs
- Captura fotos e preenche checklists
- Armazena tudo para sincronizar depois
- Mostra indicador "Offline" e contagem de pendentes

#### Ao Voltar ONLINE:
- Sincroniza automaticamente
- Envia OSs concluidas/pausadas com fotos
- Envia execucoes de checklists
- Exclui OSs concluidas do banco local
- Atualiza lista com dados do servidor

---

## Solucao de Problemas

### "SDK location not found"

Crie um arquivo `android/local.properties`:
```
sdk.dir=C:\\Users\\SEU_USUARIO\\AppData\\Local\\Android\\Sdk
```

### "JAVA_HOME is set to an invalid directory"

Verifique se o JDK 17 esta instalado e a variavel esta correta.

### Erro de memoria durante build

Edite `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
```

### "Build failed"
- Verifique se tem Node.js 18+
- Execute `npm install` novamente
- Limpe cache: `cd android && ./gradlew clean`

### "Login invalido no app"
- Verifique se esta usando as credenciais corretas
- Certifique-se de que o servidor esta acessivel
- Verifique sua conexao com a internet

### "App nao abre"
- Desinstale versoes anteriores
- Limpe cache do celular
- Reinstale o APK

---

## Configuracao do Servidor

Por padrao, o app se conecta a:
```
https://facilities.grupoopus.com
```

Para alterar, edite o arquivo `app.json`:
```json
{
  "expo": {
    "extra": {
      "apiUrl": "https://SEU_SERVIDOR.com"
    }
  }
}
```

---

## Suporte

- Servidor de producao: https://facilities.grupoopus.com
- Documentacao Expo: https://docs.expo.dev
- Documentacao Android: https://developer.android.com/studio/build
