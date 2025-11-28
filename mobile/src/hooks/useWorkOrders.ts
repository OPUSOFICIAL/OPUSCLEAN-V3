import { useState, useEffect, useCallback } from 'react';
import { WorkOrder } from '../types';
import * as db from '../db/database';

export function useWorkOrders() {
  const [workOrders, setWorkOrders] = useState<WorkOrder[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const loadWorkOrders = useCallback(async () => {
    try {
      const orders = await db.getWorkOrders();
      setWorkOrders(orders);
    } catch (err) {
      console.error('Erro ao carregar OSs:', err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadWorkOrders();
  }, [loadWorkOrders]);

  const completeWorkOrder = useCallback(async (id: string, notes?: string) => {
    try {
      await db.updateWorkOrderStatus(id, 'completed', notes);
      await loadWorkOrders();
      return true;
    } catch (err) {
      console.error('Erro ao concluir OS:', err);
      return false;
    }
  }, [loadWorkOrders]);

  const pauseWorkOrder = useCallback(async (id: string, notes?: string) => {
    try {
      await db.updateWorkOrderStatus(id, 'paused', notes);
      await loadWorkOrders();
      return true;
    } catch (err) {
      console.error('Erro ao pausar OS:', err);
      return false;
    }
  }, [loadWorkOrders]);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    await loadWorkOrders();
  }, [loadWorkOrders]);

  const getOrdersByStatus = useCallback((status: string) => {
    return workOrders.filter((o) => o.status === status);
  }, [workOrders]);

  const getOrdersByDate = useCallback((date: string) => {
    return workOrders.filter((o) => o.scheduledDate.startsWith(date));
  }, [workOrders]);

  return {
    workOrders,
    isLoading,
    refresh,
    completeWorkOrder,
    pauseWorkOrder,
    getOrdersByStatus,
    getOrdersByDate,
  };
}
