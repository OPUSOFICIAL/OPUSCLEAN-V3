# Instruções para Gerar o APK - Acelera Facilities

## Configuração Atual
- **Modo:** LOCAL (assets embutidos no APK)
- **API de Produção:** `https://facilities.grupoopus.com`
- **Funcionamento Offline:** Sim (dados salvos em cache local)

## Credenciais de Teste
- **Usuário:** admin
- **Senha:** admin123

---

## PASSO 1: Baixar o Projeto

1. No Replit, clique nos três pontos (...) no painel de arquivos
2. Selecione "Download as zip"
3. Extraia o arquivo no seu computador

---

## PASSO 2: Compilar o Frontend

Abra o terminal na pasta do projeto e execute:

```bash
# Instalar dependências
npm install

# Compilar o frontend
npm run build
```

Isso vai gerar a pasta `dist/public` com os arquivos do app.

---

## PASSO 3: Sincronizar o Android

```bash
# Sincronizar com o projeto Android
npx cap sync android
```

Isso copia os arquivos compilados para dentro do projeto Android.

---

## PASSO 4: Abrir no Android Studio

```bash
# Abrir projeto no Android Studio (opcional)
npx cap open android
```

Ou abra manualmente a pasta `android/` no Android Studio.

---

## PASSO 5: Gerar o APK

No Android Studio:

1. Aguarde o Gradle sincronizar
2. Vá em: **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
3. O APK estará em: `android/app/build/outputs/apk/debug/app-debug.apk`

### Para APK de Produção (Assinado):

1. Vá em: **Build** → **Generate Signed Bundle / APK**
2. Selecione **APK**
3. Crie uma keystore ou use uma existente
4. O APK estará em: `android/app/build/outputs/apk/release/app-release.apk`

---

## Configurações do App

| Configuração | Valor |
|--------------|-------|
| App ID | com.acelerait.facilities |
| Nome | Acelera Facilities |
| Min SDK | 23 (Android 6.0) |
| Target SDK | 35 (Android 14) |
| Versão | 1.0 |
| API | https://facilities.grupoopus.com |

---

## Funcionalidades do APK

- Login com autenticação JWT
- Dashboard de ordens de serviço
- Criação e edição de OS
- QR Code scanner
- Gestão de locais e zonas
- Módulos Clean e Maintenance
- **Modo Offline:** Dados salvos localmente e sincronizados quando online

---

## Troubleshooting

### Erro: "SDK not found"
- Clique em "Install" quando o Android Studio pedir para baixar o SDK

### Erro: "Gradle sync failed"
- Verifique se o Android Studio está atualizado
- Tente: **File** → **Sync Project with Gradle Files**

### Erro: "Unable to resolve dependency"
- Verifique sua conexão de internet
- Tente: **File** → **Invalidate Caches / Restart**

### App não conecta à API
- Verifique se o servidor `https://facilities.grupoopus.com` está online
- O app precisa de internet para sincronizar dados

---

## Resumo dos Comandos

```bash
# No seu computador local:
npm install
npm run build
npx cap sync android
npx cap open android
```

Depois, no Android Studio:
**Build** → **Build APK(s)**
