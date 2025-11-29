import NetInfo from '@react-native-community/netinfo';
import * as db from '../db/database';
import * as api from '../api/client';
import { SyncStatus, User, ChecklistAnswer, CapturedPhoto } from '../types';

let isSyncing = false;
let syncInterval: ReturnType<typeof setInterval> | null = null;

export async function checkConnectivity(): Promise<boolean> {
  try {
    const state = await NetInfo.fetch();
    return state.isConnected === true && state.isInternetReachable === true;
  } catch {
    return false;
  }
}

export async function syncWithServer(user: User, customerId: string): Promise<SyncStatus> {
  const isOnline = await checkConnectivity();
  
  if (!isOnline) {
    const pendingCount = await db.getPendingSyncCount();
    return {
      lastSync: null,
      pendingChanges: pendingCount,
      isOnline: false,
      isSyncing: false,
    };
  }

  if (isSyncing) {
    const pendingCount = await db.getPendingSyncCount();
    return {
      lastSync: null,
      pendingChanges: pendingCount,
      isOnline: true,
      isSyncing: true,
    };
  }

  isSyncing = true;

  try {
    await pushPendingChanges(user);
    await pullFromServer(user, customerId);
    await db.removeCompletedWorkOrders();
    await db.clearSyncedData();
    
    const pendingCount = await db.getPendingSyncCount();
    
    return {
      lastSync: new Date().toISOString(),
      pendingChanges: pendingCount,
      isOnline: true,
      isSyncing: false,
    };
  } catch (error) {
    console.error('Erro na sincronizacao:', error);
    const pendingCount = await db.getPendingSyncCount();
    return {
      lastSync: null,
      pendingChanges: pendingCount,
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
    if (item.attempts >= 5) {
      console.log(`Pulando item com muitas tentativas: ${item.id}`);
      continue;
    }

    try {
      const payload = JSON.parse(item.payload);
      
      switch (item.action) {
        case 'start':
          await api.startWorkOrder(user.token, item.workOrderId);
          break;
          
        case 'complete':
          await syncCompleteAction(user.token, item.workOrderId, payload);
          break;
          
        case 'pause':
          await syncPauseAction(user.token, item.workOrderId, payload);
          break;
          
        case 'resume':
          await api.resumeWorkOrder(user.token, item.workOrderId);
          break;
          
        case 'photo':
          await syncPhotoAction(user.token, item.workOrderId, payload);
          break;
          
        case 'checklist':
          await syncChecklistAction(user.token, item.workOrderId, payload);
          break;
          
        case 'comment':
          await syncCommentAction(user.token, item.workOrderId, payload);
          break;
      }
      
      await db.removePendingSync(item.id);
      await db.markWorkOrderSynced(item.workOrderId);
      
      console.log(`Sincronizado: OS ${item.workOrderId} - ${item.action}`);
    } catch (error) {
      console.error(`Erro ao sincronizar OS ${item.workOrderId}:`, error);
      await db.incrementPendingSyncAttempts(item.id);
    }
  }
}

async function syncCompleteAction(
  token: string, 
  workOrderId: string, 
  payload: any
): Promise<void> {
  const photos = await db.getPhotosByWorkOrder(workOrderId);
  const photosToUpload = photos
    .filter(p => p.syncStatus === 'pending')
    .map(p => ({
      base64: p.base64,
      type: p.type,
      checklistItemId: p.checklistItemId || undefined,
    }));

  await api.completeWorkOrder(token, workOrderId, {
    notes: payload.notes,
    checklistAnswers: payload.answers,
    photos: photosToUpload,
  });

  for (const photo of photos.filter(p => p.syncStatus === 'pending')) {
    await db.updatePhotoSyncStatus(photo.id, 'synced');
  }
}

async function syncPauseAction(
  token: string, 
  workOrderId: string, 
  payload: any
): Promise<void> {
  const photos = await db.getPhotosByWorkOrder(workOrderId);
  const pausePhotos = photos
    .filter(p => p.type === 'pause' && p.syncStatus === 'pending')
    .map(p => ({ base64: p.base64 }));

  await api.pauseWorkOrder(token, workOrderId, {
    reason: payload.reason || payload.notes || '',
    photos: pausePhotos,
  });

  for (const photo of photos.filter(p => p.type === 'pause' && p.syncStatus === 'pending')) {
    await db.updatePhotoSyncStatus(photo.id, 'synced');
  }
}

async function syncPhotoAction(
  token: string, 
  workOrderId: string, 
  payload: any
): Promise<void> {
  const photo = await db.getPhotoById(payload.photoId);
  if (!photo) return;

  await api.uploadWorkOrderPhoto(
    token,
    workOrderId,
    photo.base64,
    photo.type as 'checklist' | 'pause' | 'completion' | 'comment',
    photo.checklistItemId || undefined
  );

  await db.updatePhotoSyncStatus(photo.id, 'synced');
}

async function syncChecklistAction(
  token: string, 
  workOrderId: string, 
  payload: any
): Promise<void> {
  const execution = await db.getChecklistExecutionByWorkOrder(workOrderId);
  if (!execution) return;

  await api.submitChecklistExecution(
    token,
    workOrderId,
    execution.checklistTemplateId,
    execution.answers
  );
}

async function syncCommentAction(
  token: string, 
  workOrderId: string, 
  payload: any
): Promise<void> {
  const comments = await db.getCommentsByWorkOrder(workOrderId);
  const comment = comments.find(c => c.id === payload.commentId);
  if (!comment) return;

  const uploadedPhotoIds: string[] = [];
  
  for (const photoId of comment.photoIds) {
    const photo = await db.getPhotoById(photoId);
    if (photo && photo.syncStatus === 'pending') {
      const result = await api.uploadWorkOrderPhoto(
        token,
        workOrderId,
        photo.base64,
        'comment'
      );
      uploadedPhotoIds.push(result.id);
      await db.updatePhotoSyncStatus(photo.id, 'synced');
    }
  }

  await api.addWorkOrderComment(
    token,
    workOrderId,
    comment.comment,
    uploadedPhotoIds
  );
}

async function pullFromServer(user: User, customerId: string): Promise<void> {
  const modules = user.modules || ['clean', 'maintenance'];
  
  console.log(`[SYNC] Iniciando pull - User: ${user.username}, Customer: ${customerId}, Modules: ${modules.join(',')}`);
  
  for (const module of modules) {
    try {
      console.log(`[SYNC] Buscando OSs do modulo ${module}...`);
      const workOrders = await api.fetchWorkOrders(user.token, customerId, module);
      console.log(`[SYNC] Recebidas ${workOrders.length} OSs do modulo ${module}`);
      
      if (workOrders.length > 0) {
        await db.saveWorkOrders(workOrders);
        console.log(`[SYNC] Salvas ${workOrders.length} OSs no banco local`);
        
        for (const order of workOrders) {
          if (order.checklistTemplateId) {
            try {
              const template = await api.fetchChecklistTemplate(user.token, order.checklistTemplateId);
              if (template) {
                await db.saveChecklistTemplate(template);
              }
            } catch (error) {
              console.log('Nao foi possivel baixar checklist:', order.checklistTemplateId);
            }
          }
        }
      }
      
      console.log(`[SYNC] Processadas ${workOrders.length} OSs do modulo ${module}`);
    } catch (error) {
      console.error(`[SYNC] Erro ao baixar OSs do modulo ${module}:`, error);
    }
  }
  
  try {
    const qrCodes = await api.fetchQRCodes(user.token, customerId);
    await db.saveQRCodes(qrCodes);
    console.log(`[SYNC] Baixados ${qrCodes.length} QR codes`);
  } catch (error) {
    console.error('[SYNC] Erro ao baixar QR codes:', error);
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
