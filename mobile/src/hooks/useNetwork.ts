import { useState, useEffect, useCallback } from 'react';
import * as Network from 'expo-network';

export function useNetwork() {
  const [isOnline, setIsOnline] = useState(true);
  const [isChecking, setIsChecking] = useState(true);

  const checkNetwork = useCallback(async () => {
    try {
      const state = await Network.getNetworkStateAsync();
      setIsOnline(state.isConnected === true && state.isInternetReachable === true);
    } catch {
      setIsOnline(false);
    } finally {
      setIsChecking(false);
    }
  }, []);

  useEffect(() => {
    checkNetwork();

    const subscription = Network.addNetworkStateListener((state) => {
      setIsOnline(state.isConnected === true && state.isInternetReachable === true);
    });

    return () => {
      subscription.remove();
    };
  }, [checkNetwork]);

  return {
    isOnline,
    isChecking,
    refresh: checkNetwork,
  };
}
