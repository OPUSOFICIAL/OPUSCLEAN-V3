# OPUS Facilities - Instrucoes para Gerar APK

## Pre-requisitos

1. **Node.js 18+** - https://nodejs.org/
2. **Git** - https://git-scm.com/
3. **Conta Expo** - Criar em https://expo.dev/signup (gratis)

## Passo a Passo

### 1. Baixar o Projeto

1. No Replit, clique nos 3 pontos no canto superior direito
2. Selecione "Download as zip"
3. Extraia o arquivo em uma pasta no seu computador

### 2. Preparar o Projeto Mobile

Abra o terminal/cmd na pasta extraida e execute:

```bash
# Entrar na pasta mobile
cd mobile

# Instalar dependencias
npm install

# Instalar Expo CLI e EAS CLI globalmente
npm install -g expo-cli eas-cli
```

### 3. Login no Expo

```bash
# Fazer login na sua conta Expo
eas login
```

### 4. Configurar o Projeto (primeira vez)

```bash
# Configurar o projeto no EAS
eas build:configure
```

Quando perguntado, selecione:
- Platform: Android
- Build type: APK

### 5. Gerar o APK

**Opcao A - Build na Nuvem (Recomendado):**
```bash
eas build --platform android --profile apk
```

Isso vai:
1. Enviar o codigo para os servidores do Expo
2. Compilar o APK na nuvem
3. Fornecer um link para download quando pronto (5-15 min)

**Opcao B - Build Local (Requer Android Studio):**
```bash
# Gerar projeto nativo
npx expo prebuild

# Entrar na pasta android
cd android

# Gerar APK debug
./gradlew assembleDebug

# O APK estara em: android/app/build/outputs/apk/debug/app-debug.apk
```

### 6. Instalar no Celular

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
