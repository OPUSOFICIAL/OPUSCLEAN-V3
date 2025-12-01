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
  
  console.log(`[SYNC] ========================================`);
  console.log(`[SYNC] INICIANDO PULL FROM SERVER`);
  console.log(`[SYNC] User ID: ${user.id}`);
  console.log(`[SYNC] User Name: ${user.name}`);
  console.log(`[SYNC] Customer ID: ${customerId}`);
  console.log(`[SYNC] Modulos: ${modules.join(', ')}`);
  console.log(`[SYNC] Token valido: ${user.token ? 'SIM' : 'NAO'}`);
  console.log(`[SYNC] ========================================`);
  
  let totalOrders = 0;
  
  for (const module of modules) {
    try {
      console.log(`[SYNC] [${module.toUpperCase()}] Buscando OSs...`);
      const workOrders = await api.fetchWorkOrders(user.token, customerId, module, user.id);
      console.log(`[SYNC] [${module.toUpperCase()}] Recebidas ${workOrders.length} OSs`);
      
      if (workOrders.length > 0) {
        // Log detalhado das OSs recebidas
        console.log(`[SYNC] [${module.toUpperCase()}] Detalhes das OSs:`);
        workOrders.forEach((wo, idx) => {
          console.log(`[SYNC]   ${idx + 1}. OS #${wo.workOrderNumber} - ${wo.status} - ${wo.title?.substring(0, 30)}...`);
        });
        
        await db.saveWorkOrders(workOrders);
        console.log(`[SYNC] [${module.toUpperCase()}] Salvas ${workOrders.length} OSs no SQLite`);
        totalOrders += workOrders.length;
        
        // Baixar checklists
        let checklistCount = 0;
        for (const order of workOrders) {
          if (order.checklistTemplateId) {
            try {
              const template = await api.fetchChecklistTemplate(user.token, order.checklistTemplateId);
              if (template) {
                await db.saveChecklistTemplate(template);
                checklistCount++;
              }
            } catch (error) {
              console.log(`[SYNC] Checklist ${order.checklistTemplateId} nao encontrado`);
            }
          }
        }
        console.log(`[SYNC] [${module.toUpperCase()}] Baixados ${checklistCount} checklists`);
      }
    } catch (error: any) {
      console.error(`[SYNC] [${module.toUpperCase()}] ERRO ao baixar OSs:`, error?.message || error);
    }
  }
  
  // Verificar quantas OSs estao no banco local
  try {
    const localOrders = await db.getWorkOrders();
    console.log(`[SYNC] Total de OSs no banco local apos sync: ${localOrders.length}`);
    if (localOrders.length > 0) {
      console.log(`[SYNC] Exemplo de OS local: OS #${localOrders[0].workOrderNumber} - ${localOrders[0].status}`);
    }
  } catch (err) {
    console.error('[SYNC] Erro ao verificar banco local:', err);
  }
  
  try {
    const qrCodes = await api.fetchQRCodes(user.token, customerId);
    await db.saveQRCodes(qrCodes);
    console.log(`[SYNC] Baixados ${qrCodes.length} QR codes`);
  } catch (error: any) {
    console.error('[SYNC] Erro ao baixar QR codes:', error?.message || error);
  }
  
  console.log(`[SYNC] ========================================`);
  console.log(`[SYNC] PULL CONCLUIDO - Total: ${totalOrders} OSs`);
  console.log(`[SYNC] ========================================`);
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
