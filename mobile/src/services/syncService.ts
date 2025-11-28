import * as Network from 'expo-network';
import * as db from '../db/database';
import * as api from '../api/client';
import { SyncStatus, User } from '../types';

let isSyncing = false;
let syncInterval: ReturnType<typeof setInterval> | null = null;

export async function checkConnectivity(): Promise<boolean> {
  try {
    const state = await Network.getNetworkStateAsync();
    return state.isConnected === true && state.isInternetReachable === true;
  } catch {
    return false;
  }
}

export async function syncWithServer(user: User, customerId: string): Promise<SyncStatus> {
  const isOnline = await checkConnectivity();
  
  if (!isOnline) {
    const pendingSync = await db.getPendingSync();
    return {
      lastSync: null,
      pendingChanges: pendingSync.length,
      isOnline: false,
      isSyncing: false,
    };
  }

  if (isSyncing) {
    const pendingSync = await db.getPendingSync();
    return {
      lastSync: null,
      pendingChanges: pendingSync.length,
      isOnline: true,
      isSyncing: true,
    };
  }

  isSyncing = true;

  try {
    await pushPendingChanges(user);
    
    await pullFromServer(user, customerId);
    
    await db.removeCompletedWorkOrders();
    
    const pendingSync = await db.getPendingSync();
    
    return {
      lastSync: new Date().toISOString(),
      pendingChanges: pendingSync.length,
      isOnline: true,
      isSyncing: false,
    };
  } catch (error) {
    console.error('Erro na sincronização:', error);
    const pendingSync = await db.getPendingSync();
    return {
      lastSync: null,
      pendingChanges: pendingSync.length,
      isOnline: true,
      isSyncing: false,
    };
  } finally {
    isSyncing = false;
  }
}

async function pushPendingChanges(user: User): Promise<void> {
  const pendingSync = await db.getPendingSync();
  
  for (const item of pendingSync) {
    try {
      const payload = JSON.parse(item.payload);
      
      if (item.action === 'complete') {
        await api.completeWorkOrder(user.token, item.workOrderId, payload.notes);
      } else if (item.action === 'pause') {
        await api.pauseWorkOrder(user.token, item.workOrderId, payload.notes);
      }
      
      await db.removePendingSync(item.id);
      
      console.log(`Sincronizado: OS ${item.workOrderId} - ${item.action}`);
    } catch (error) {
      console.error(`Erro ao sincronizar OS ${item.workOrderId}:`, error);
    }
  }
}

async function pullFromServer(user: User, customerId: string): Promise<void> {
  const modules = user.modules || ['clean', 'maintenance'];
  
  for (const module of modules) {
    try {
      const workOrders = await api.fetchWorkOrders(user.token, customerId, module);
      await db.saveWorkOrders(workOrders);
      console.log(`Baixadas ${workOrders.length} OSs do módulo ${module}`);
    } catch (error) {
      console.error(`Erro ao baixar OSs do módulo ${module}:`, error);
    }
  }
  
  try {
    const qrCodes = await api.fetchQRCodes(user.token, customerId);
    await db.saveQRCodes(qrCodes);
    console.log(`Baixados ${qrCodes.length} QR codes`);
  } catch (error) {
    console.error('Erro ao baixar QR codes:', error);
  }
}

export function startAutoSync(
  user: User, 
  customerId: string, 
  onSyncComplete?: (status: SyncStatus) => void
): void {
  if (syncInterval) {
    clearInterval(syncInterval);
  }
  
  syncWithServer(user, customerId).then(onSyncComplete);
  
  syncInterval = setInterval(async () => {
    const status = await syncWithServer(user, customerId);
    onSyncComplete?.(status);
  }, 60000);
}

export function stopAutoSync(): void {
  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }
}

export async function forceSync(user: User, customerId: string): Promise<SyncStatus> {
  return syncWithServer(user, customerId);
}
