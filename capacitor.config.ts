import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'OPUS Facilities',
  webDir: 'dist/public',
  // Server config removed for offline-first operation
  // Assets are bundled locally and served via capacitor:// protocol
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
