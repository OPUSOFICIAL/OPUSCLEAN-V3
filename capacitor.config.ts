import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'OPUS Facilities',
  webDir: 'dist/public',
  // Server URL for API requests (login, sync, etc)
  server: {
    url: 'https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev',
    cleartext: true,
  },
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
