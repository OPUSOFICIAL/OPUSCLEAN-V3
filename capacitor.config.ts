import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'Acelera Facilities',
  webDir: 'dist/public',
  // Conexão com backend Replit - API completa
  // O app mobile conecta via HTTPS ao servidor Replit
  server: {
    // Permite acesso a qualquer host HTTPS
    allowNavigation: [
      'replit.dev',
      '*.replit.dev',
      'picard.replit.dev',
      'facilities.grupoopus.com',
    ],
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#ffffff',
      androidScaleType: 'CENTER_CROP',
      showSpinner: false,
    },
  },
  android: {
    allowMixedContent: false,
    captureInput: true,
    webContentsDebuggingEnabled: true, // Para debug - desativar em produção final
  },
};

export default config;
