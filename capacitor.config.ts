import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'OPUS Facilities',
  webDir: 'dist/public',
  // OFFLINE-FIRST: Assets are bundled and served locally via capacitor://
  // API calls use relative paths (/api/*) which resolve to bundled backend
  // or use full URL when needed (login, sync)
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#ffffff',
      androidScaleType: 'CENTER_CROP',
      showSpinner: false,
    },
  },
};

export default config;
