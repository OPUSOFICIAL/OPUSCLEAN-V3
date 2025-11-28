import { useState, useEffect, useCallback } from 'react';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';

export function useNetwork() {
  const [isOnline, setIsOnline] = useState(true);
  const [isChecking, setIsChecking] = useState(true);

  const checkNetwork = useCallback(async () => {
    try {
      const state = await NetInfo.fetch();
      setIsOnline(state.isConnected === true && state.isInternetReachable === true);
    } catch {
      setIsOnline(false);
    } finally {
      setIsChecking(false);
    }
  }, []);

  useEffect(() => {
    checkNetwork();

    const unsubscribe = NetInfo.addEventListener((state: NetInfoState) => {
      setIsOnline(state.isConnected === true && state.isInternetReachable === true);
    });

    return () => {
      unsubscribe();
    };
  }, [checkNetwork]);

  return {
    isOnline,
    isChecking,
    refresh: checkNetwork,
  };
}
