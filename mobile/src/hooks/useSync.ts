import { useState, useEffect, useCallback } from 'react';
import { User, SyncStatus } from '../types';
import * as syncService from '../services/syncService';
import { useNetwork } from './useNetwork';

export function useSync(user: User | null, customerId: string | null) {
  const { isOnline } = useNetwork();
  const [syncStatus, setSyncStatus] = useState<SyncStatus>({
    lastSync: null,
    pendingChanges: 0,
    isOnline: true,
    isSyncing: false,
  });

  useEffect(() => {
    if (user && customerId) {
      syncService.startAutoSync(user, customerId, (status) => {
        setSyncStatus(status);
      });

      return () => {
        syncService.stopAutoSync();
      };
    }
  }, [user, customerId]);

  useEffect(() => {
    setSyncStatus((prev) => ({ ...prev, isOnline }));
    
    if (isOnline && user && customerId) {
      syncService.forceSync(user, customerId).then(setSyncStatus);
    }
  }, [isOnline, user, customerId]);

  const forceSync = useCallback(async () => {
    if (user && customerId) {
      setSyncStatus((prev) => ({ ...prev, isSyncing: true }));
      const status = await syncService.forceSync(user, customerId);
      setSyncStatus(status);
      return status;
    }
    return syncStatus;
  }, [user, customerId, syncStatus]);

  return {
    syncStatus,
    forceSync,
  };
}
