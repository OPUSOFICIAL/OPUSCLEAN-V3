# Configuração do APK Android - OPUS Facilities

## ⚠️ IMPORTANTE: Atualizar URL do Servidor Após Migração

Quando você migra o projeto para um novo ambiente Replit, **a URL do servidor muda automaticamente**. O APK Android precisa saber a nova URL para se conectar ao backend.

## Como Atualizar a URL do Servidor para o APK

### Opção 1: Usando Variável de Ambiente (Recomendado)

1. Verifique a URL atual do seu Replit:
   ```bash
   echo $REPLIT_DOMAINS
   ```
   
2. Adicione a variável de ambiente ao arquivo `.env` (ou crie se não existir):
   ```bash
   VITE_API_BASE_URL=https://SEU-REPLIT-URL-AQUI.replit.dev
   ```

3. Rebuild do APK:
   ```bash
   npm run build:android
   ```

### Opção 2: Atualizar Diretamente no Código

Se você não quiser usar variáveis de ambiente, pode atualizar diretamente nos arquivos:

**Arquivos que precisam ser atualizados:**

1. `client/src/lib/queryClient.ts` (linha ~13):
   ```typescript
   return import.meta.env.VITE_API_BASE_URL || 'https://SUA-URL-AQUI.replit.dev';
   ```

2. `client/src/pages/mobile-qr-scanner.tsx` (linha ~24):
   ```typescript
   return import.meta.env.VITE_API_BASE_URL || 'https://SUA-URL-AQUI.replit.dev';
   ```

## URL Atual do Servidor

```
https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev
```

## Como Gerar o APK

Depois de atualizar a URL, siga estes passos:

### No Mac/Linux:
```bash
chmod +x gerar-apk.sh
./gerar-apk.sh
```

### No Windows:
```bash
gerar-apk.bat
```

### Manualmente:
```bash
npm run build:android
npx cap sync android
cd android
./gradlew assembleDebug
```

O APK será gerado em:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

## Testando a Conexão

Após instalar o novo APK:

1. Faça login no app
2. Tente escanear um QR code
3. Verifique se as ordens de serviço aparecem
4. Se não aparecer nada, verifique:
   - A URL está correta?
   - Você rebuilou o APK após mudar a URL?
   - O servidor está online?

## Solução de Problemas

### ❌ QR code não mostra ordens de serviço

**Causa:** URL desatualizada no APK

**Solução:**
1. Verifique a URL atual: `echo $REPLIT_DOMAINS`
2. Atualize a URL nos arquivos mencionados acima
3. Rebuild o APK
4. Reinstale o APK no dispositivo

### ❌ Erro de autenticação

**Causa:** Token expirado ou servidor inacessível

**Solução:**
1. Faça logout e login novamente no app
2. Verifique se o servidor está online
3. Teste a URL no navegador: `https://SUA-URL/api/companies/company-opus-default/customers`

### ❌ Serviços aparecem mas O.S. não aparecem

**Causa:** Filtros ou permissões incorretas

**Solução:**
1. Verifique se o usuário tem acesso ao módulo correto (clean ou maintenance)
2. Verifique se existem O.S. pendentes para aquela zona
3. Verifique os logs do servidor para ver se há erros

## Checklist Antes de Gerar o APK

- [ ] URL do servidor está atualizada
- [ ] Servidor está online e acessível
- [ ] Testou no navegador web antes de gerar o APK
- [ ] Fez `npm run build:android`
- [ ] Fez `npx cap sync android`
- [ ] Gerou o APK com sucesso
- [ ] Testou o APK em um dispositivo Android

## Suporte

Se você ainda tiver problemas:

1. Verifique os logs do servidor em `/tmp/logs/`
2. Verifique os logs do browser console
3. Use o scanner de QR code no navegador web primeiro para isolar o problema
4. Certifique-se de que há O.S. pendentes no sistema para teste
