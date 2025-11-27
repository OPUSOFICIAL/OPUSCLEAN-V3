# Instruções para Gerar o APK - Acelera Facilities

## Resumo
O projeto Android está configurado para carregar a aplicação diretamente do servidor Replit.
O APK conectará automaticamente ao banco de dados atual.

## URL do Servidor
```
https://b33715f7-23a2-49e4-bc36-d68327f21b3d-00-1ehjl4tukkmmt.picard.replit.dev
```

## Opção 1: Compilar no Android Studio (Recomendado)

### Pré-requisitos
- Android Studio (versão mais recente)
- JDK 17 ou superior
- Android SDK (API 35)

### Passos

1. **Baixe o projeto Android**
   - Faça download do arquivo `android-project.tar.gz` deste projeto
   - Ou copie a pasta `android/` inteira

2. **Abra no Android Studio**
   ```bash
   # Extraia o arquivo
   tar -xzvf android-project.tar.gz
   
   # Abra o Android Studio e selecione:
   # File > Open > Selecione a pasta "android"
   ```

3. **Aguarde o Gradle sincronizar**
   - O Android Studio vai baixar todas as dependências automaticamente
   - Isso pode levar alguns minutos na primeira vez

4. **Gere o APK Debug (para testes)**
   - Menu: Build > Build Bundle(s) / APK(s) > Build APK(s)
   - O APK será gerado em: `android/app/build/outputs/apk/debug/app-debug.apk`

5. **Gere o APK Release (para produção)**
   - Menu: Build > Generate Signed Bundle / APK
   - Selecione APK
   - Crie ou use uma keystore existente
   - O APK será gerado em: `android/app/build/outputs/apk/release/app-release.apk`

## Opção 2: Compilar via Linha de Comando

```bash
# Entre na pasta android
cd android

# Dê permissão ao gradlew
chmod +x gradlew

# Compile APK Debug
./gradlew assembleDebug

# APK estará em: app/build/outputs/apk/debug/app-debug.apk
```

## Configurações do App

| Configuração | Valor |
|--------------|-------|
| App ID | com.acelerait.facilities |
| Nome | Acelera Facilities |
| Min SDK | 23 (Android 6.0) |
| Target SDK | 35 (Android 14) |
| Versão | 1.0 |

## Credenciais de Teste

- **Usuário:** admin
- **Senha:** admin123

## Funcionalidades do APK

O APK terá as mesmas funcionalidades da versão web:
- Login com autenticação JWT
- Dashboard de ordens de serviço
- Criação e edição de OS
- QR Code scanner
- Gestão de locais e zonas
- Módulos Clean e Maintenance
- Sincronização em tempo real

## Troubleshooting

### Erro de conexão
- Verifique se o dispositivo tem acesso à internet
- Certifique-se que o servidor Replit está rodando

### Tela branca
- Aguarde alguns segundos para carregar
- Verifique a conexão de rede

### Erro de certificado SSL
- O app está configurado para aceitar certificados do Replit
- Se persistir, verifique o arquivo `network_security_config.xml`

## Suporte

Para alterar a URL do servidor, edite o arquivo:
- `capacitor.config.ts` - linha com `REPLIT_SERVER_URL`
- Execute `npx cap sync android` após a alteração
