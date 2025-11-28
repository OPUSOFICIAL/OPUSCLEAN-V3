import type { CapacitorConfig } from '@capacitor/cli';

// URL da API de produção
const PRODUCTION_API_URL = 'https://facilities.grupoopus.com';

const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'Acelera Facilities',
  webDir: 'dist/public',
  // MODO LOCAL: Assets embutidos no APK, apenas chamadas API vão para o servidor
  // NÃO definimos server.url para que o app carregue os assets locais
  server: {
    // Permite chamadas à API de produção
    allowNavigation: [
      'facilities.grupoopus.com',
      '*.grupoopus.com',
    ],
    // Configurações de hostname para o servidor local
    androidScheme: 'https',
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#1e3a8a',
      androidScaleType: 'CENTER_CROP',
      showSpinner: true,
      spinnerColor: '#ffffff',
    },
  },
  android: {
    allowMixedContent: false,
    captureInput: true,
    webContentsDebuggingEnabled: true,
  },
};

export default config;
