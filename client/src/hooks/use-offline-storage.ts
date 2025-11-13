import { useState, useEffect, useCallback } from 'react';
import { 
  offlineStorage, 
  OfflineWorkOrder, 
  OfflineChecklistExecution, 
  OfflineAttachment 
} from '@/lib/offline-storage';
import { useToast } from '@/hooks/use-toast';

export function useOfflineStorage() {
  const { toast } = useToast();
  const [isInitialized, setIsInitialized] = useState(false);
  const [stats, setStats] = useState({
    totalWorkOrders: 0,
    pendingWorkOrders: 0,
    totalExecutions: 0,
    pendingExecutions: 0,
    totalAttachments: 0,
    pendingAttachments: 0,
  });

  // Initialize and load stats
  useEffect(() => {
    const init = async () => {
      try {
        await offlineStorage['initPromise']; // Wait for DB initialization
        const currentStats = await offlineStorage.getStats();
        setStats(currentStats);
        setIsInitialized(true);
        console.log('[USE OFFLINE STORAGE] Initialized with stats:', currentStats);
      } catch (error) {
        console.error('[USE OFFLINE STORAGE] Failed to initialize:', error);
        toast({
          title: 'Erro',
          description: 'Falha ao inicializar armazenamento offline',
          variant: 'destructive',
        });
      }
    };

    init();
  }, [toast]);

  // Refresh stats
  const refreshStats = useCallback(async () => {
    try {
      const currentStats = await offlineStorage.getStats();
      setStats(currentStats);
      return currentStats;
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to refresh stats:', error);
      return stats;
    }
  }, [stats]);

  // Work Orders
  const createOfflineWorkOrder = useCallback(async (
    data: Omit<OfflineWorkOrder, 'localId' | 'createdAt' | 'updatedAt'>
  ) => {
    try {
      const workOrder = await offlineStorage.createWorkOrder(data);
      await refreshStats();
      
      toast({
        title: 'Salvo offline',
        description: 'Ordem de serviço criada localmente. Será sincronizada quando conectar.',
      });

      return workOrder;
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to create work order:', error);
      toast({
        title: 'Erro',
        description: 'Falha ao salvar ordem de serviço offline',
        variant: 'destructive',
      });
      throw error;
    }
  }, [toast, refreshStats]);

  const getOfflineWorkOrders = useCallback(async (customerId?: string) => {
    try {
      return await offlineStorage.getAllWorkOrders(customerId);
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to get work orders:', error);
      return [];
    }
  }, []);

  const updateOfflineWorkOrder = useCallback(async (
    localId: string,
    updates: Partial<OfflineWorkOrder>
  ) => {
    try {
      await offlineStorage.updateWorkOrder(localId, updates);
      await refreshStats();
      
      toast({
        title: 'Atualizado',
        description: 'Ordem de serviço atualizada localmente',
      });
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to update work order:', error);
      toast({
        title: 'Erro',
        description: 'Falha ao atualizar ordem de serviço',
        variant: 'destructive',
      });
      throw error;
    }
  }, [toast, refreshStats]);

  // Checklist Executions
  const createOfflineChecklistExecution = useCallback(async (
    data: Omit<OfflineChecklistExecution, 'localId' | 'createdAt' | 'updatedAt'>
  ) => {
    try {
      const execution = await offlineStorage.createChecklistExecution(data);
      await refreshStats();
      
      toast({
        title: 'Salvo offline',
        description: 'Execução de checklist salva localmente',
      });

      return execution;
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to create checklist execution:', error);
      toast({
        title: 'Erro',
        description: 'Falha ao salvar execução de checklist',
        variant: 'destructive',
      });
      throw error;
    }
  }, [toast, refreshStats]);

  const getOfflineChecklistExecutions = useCallback(async (workOrderId: string) => {
    try {
      return await offlineStorage.getChecklistExecutionsByWorkOrder(workOrderId);
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to get checklist executions:', error);
      return [];
    }
  }, []);

  // Attachments
  const createOfflineAttachment = useCallback(async (
    data: Omit<OfflineAttachment, 'localId' | 'createdAt' | 'updatedAt'>
  ) => {
    try {
      const attachment = await offlineStorage.createAttachment(data);
      await refreshStats();
      
      toast({
        title: 'Anexo salvo',
        description: 'Foto/documento salvo localmente',
      });

      return attachment;
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to create attachment:', error);
      toast({
        title: 'Erro',
        description: 'Falha ao salvar anexo',
        variant: 'destructive',
      });
      throw error;
    }
  }, [toast, refreshStats]);

  const getOfflineAttachments = useCallback(async (workOrderId: string) => {
    try {
      return await offlineStorage.getAttachmentsByWorkOrder(workOrderId);
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to get attachments:', error);
      return [];
    }
  }, []);

  // Sync Management
  const getPendingItems = useCallback(async () => {
    try {
      return await offlineStorage.getPendingItems();
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to get pending items:', error);
      return {
        workOrders: [],
        checklistExecutions: [],
        attachments: [],
      };
    }
  }, []);

  const markAsSynced = useCallback(async (
    type: 'work_order' | 'checklist_execution' | 'attachment',
    localId: string,
    serverId: string
  ) => {
    try {
      await offlineStorage.markAsSynced(type, localId, serverId);
      await refreshStats();
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to mark as synced:', error);
      throw error;
    }
  }, [refreshStats]);

  const markAsFailed = useCallback(async (
    type: 'work_order' | 'checklist_execution' | 'attachment',
    localId: string,
    error: string
  ) => {
    try {
      await offlineStorage.markAsFailed(type, localId, error);
      await refreshStats();
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to mark as failed:', error);
      throw error;
    }
  }, [refreshStats]);

  const clearSyncedData = useCallback(async () => {
    try {
      await offlineStorage.clearSyncedData();
      await refreshStats();
      
      toast({
        title: 'Dados limpos',
        description: 'Dados já sincronizados foram removidos do armazenamento local',
      });
    } catch (error) {
      console.error('[USE OFFLINE STORAGE] Failed to clear synced data:', error);
      toast({
        title: 'Erro',
        description: 'Falha ao limpar dados sincronizados',
        variant: 'destructive',
      });
      throw error;
    }
  }, [toast, refreshStats]);

  return {
    isInitialized,
    stats,
    refreshStats,
    
    // Work Orders
    createOfflineWorkOrder,
    getOfflineWorkOrders,
    updateOfflineWorkOrder,
    
    // Checklist Executions
    createOfflineChecklistExecution,
    getOfflineChecklistExecutions,
    
    // Attachments
    createOfflineAttachment,
    getOfflineAttachments,
    
    // Sync Management
    getPendingItems,
    markAsSynced,
    markAsFailed,
    clearSyncedData,
  };
}
