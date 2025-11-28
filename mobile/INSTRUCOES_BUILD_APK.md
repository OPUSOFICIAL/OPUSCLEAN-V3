# OPUS Facilities - Instrucoes para Gerar APK

## Opcao 1: Build LOCAL no seu PC (Recomendado)

### Pre-requisitos para Build Local

1. **Node.js 18 ou 20 LTS** - https://nodejs.org/ (NAO use Node 22+)
2. **Java JDK 17** - https://adoptium.net/ (Temurin 17)
3. **Android Studio** - https://developer.android.com/studio
   - Instale o Android SDK (API 34)
   - Configure a variavel ANDROID_HOME

### Passo a Passo - Build Local

1. **Baixar o projeto** do Replit (Menu → Download as zip)

2. **Extrair e entrar na pasta mobile:**
```bash
cd mobile
npm install
```

3. **Gerar o projeto Android nativo:**
```bash
npx expo prebuild --platform android
```

4. **Compilar o APK:**
```bash
cd android
./gradlew assembleRelease
```

No Windows, use:
```bash
cd android
gradlew.bat assembleRelease
```

5. **O APK estara em:**
```
android/app/build/outputs/apk/release/app-release.apk
```

6. **Transferir para o celular e instalar**

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

4. **Gerar APK na nuvem:**
```bash
eas build --platform android --profile apk
```

O APK sera gerado nos servidores do Expo (5-15 min) e voce recebera um link para download.

---

## Instalar no Celular

1. Transfira o arquivo `.apk` para o celular
2. Abra o arquivo no celular
3. Permita instalacao de fontes desconhecidas se solicitado
4. Instale e abra o app

## Credenciais de Teste

- **Usuario:** admin
- **Senha:** admin123

## Funcionalidades Offline

O app funciona da seguinte forma:

### Quando ONLINE:
- Sincroniza automaticamente a cada 1 minuto
- Baixa OSs abertas/pausadas de hoje e amanha
- Baixa QR codes do cliente
- Envia alteracoes pendentes para o servidor

### Quando OFFLINE:
- Exibe OSs salvas localmente
- Permite concluir ou pausar OSs
- Armazena alteracoes para sincronizar depois
- Mostra indicador "Offline" e contagem de pendentes

### Ao Voltar ONLINE:
- Sincroniza automaticamente
- Envia OSs concluidas/pausadas
- Exclui OSs concluidas do banco local
- Atualiza lista com dados do servidor

## Solucao de Problemas

### "Build failed"
- Verifique se tem Node.js 18+
- Execute `npm install` novamente
- Tente `eas build --clear-cache --platform android`

### "Login invalido no app"
- Verifique se esta usando as credenciais corretas
- Certifique-se de que o servidor esta acessivel
- Verifique sua conexao com a internet

### "App nao abre"
- Desinstale versoes anteriores
- Limpe cache do celular
- Reinstale o APK

## Suporte

- Servidor de producao: https://facilities.grupoopus.com
- O app conecta automaticamente ao servidor de producao
