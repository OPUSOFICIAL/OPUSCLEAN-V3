import type { CapacitorConfig } from '@capacitor/cli';

// URL do servidor Replit (produção)
const REPLIT_SERVER_URL = 'https://b33715f7-23a2-49e4-bc36-d68327f21b3d-00-1ehjl4tukkmmt.picard.replit.dev';

const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'Acelera Facilities',
  webDir: 'dist/public',
  // REMOTE MODE: Carrega a aplicação diretamente do servidor Replit
  // Isso permite usar o APK sem precisar fazer build local
  server: {
    // URL do servidor remoto - carrega a aplicação web diretamente
    url: REPLIT_SERVER_URL,
    cleartext: false, // Força HTTPS
    // Permite navegação para estes domínios
    allowNavigation: [
      'replit.dev',
      '*.replit.dev',
      '*.picard.replit.dev',
      'facilities.grupoopus.com',
      '*.grupoopus.com',
    ],
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
