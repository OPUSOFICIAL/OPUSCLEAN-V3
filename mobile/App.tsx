import { useState, useEffect, useCallback } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Alert } from 'react-native';

import { LoginScreen } from './src/screens/LoginScreen';
import { CustomerSelectScreen } from './src/screens/CustomerSelectScreen';
import { WorkOrdersScreen } from './src/screens/WorkOrdersScreen';
import { QRScannerScreen } from './src/screens/QRScannerScreen';
import { WorkOrderExecuteScreen } from './src/screens/WorkOrderExecuteScreen';
import { useAuth } from './src/hooks/useAuth';
import { useWorkOrders } from './src/hooks/useWorkOrders';
import { useSync } from './src/hooks/useSync';
import { WorkOrder, QRCodePoint, ChecklistTemplate, ChecklistAnswer, CapturedPhoto, WorkOrderPhoto } from './src/types';
import * as db from './src/db/database';
import * as api from './src/api/client';
import { checkConnectivity } from './src/services/syncService';

type Screen = 'workOrders' | 'scanner' | 'execute' | 'zoneOrders';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

export default function App() {
  const { user, isLoading, error, login, logout, isAuthenticated } = useAuth();
  const [selectedCustomerId, setSelectedCustomerId] = useState<string | null>(null);
  const [currentScreen, setCurrentScreen] = useState<Screen>('workOrders');
  const [selectedWorkOrder, setSelectedWorkOrder] = useState<WorkOrder | null>(null);
  const [selectedChecklist, setSelectedChecklist] = useState<ChecklistTemplate | null>(null);
  const [scannedQRCode, setScannedQRCode] = useState<QRCodePoint | null>(null);
  const [zoneWorkOrders, setZoneWorkOrders] = useState<WorkOrder[]>([]);
  const [isOnline, setIsOnline] = useState(true);
  
  const { workOrders, isLoading: ordersLoading, refresh } = useWorkOrders();
  const { syncStatus, forceSync } = useSync(user, selectedCustomerId);

  useEffect(() => {
    if (user?.customerId) {
      setSelectedCustomerId(user.customerId);
    }
  }, [user]);

  useEffect(() => {
    if (syncStatus.lastSync && !syncStatus.isSyncing) {
      refresh();
    }
  }, [syncStatus.lastSync, syncStatus.isSyncing]);

  useEffect(() => {
    const checkNetwork = async () => {
      const online = await checkConnectivity();
      setIsOnline(online);
    };
    checkNetwork();
    const interval = setInterval(checkNetwork, 10000);
    return () => clearInterval(interval);
  }, []);

  const handleLogin = async (username: string, password: string): Promise<boolean> => {
    return await login(username, password);
  };

  const handleLogout = useCallback(async () => {
    Alert.alert(
      'Sair',
      'Deseja realmente sair do aplicativo?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Sair',
          style: 'destructive',
          onPress: async () => {
            try {
              setCurrentScreen('workOrders');
              setSelectedWorkOrder(null);
              setSelectedChecklist(null);
              setScannedQRCode(null);
              setZoneWorkOrders([]);
              await logout();
              setSelectedCustomerId(null);
            } catch (error) {
              console.error('Erro no logout:', error);
              setSelectedCustomerId(null);
            }
          },
        },
      ]
    );
  }, [logout]);

  const handleSelectCustomer = useCallback((customerId: string) => {
    setSelectedCustomerId(customerId);
  }, []);

  const handleOpenScanner = useCallback(() => {
    setCurrentScreen('scanner');
  }, []);

  const handleCloseScanner = useCallback(() => {
    setCurrentScreen('workOrders');
  }, []);

  const handleScanComplete = useCallback(async (order: WorkOrder | null, qrCode: QRCodePoint | null) => {
    if (order) {
      await openWorkOrderExecution(order);
    } else if (qrCode) {
      setScannedQRCode(qrCode);
      const orders = await db.getWorkOrdersByZone(qrCode.zoneId);
      setZoneWorkOrders(orders);
      
      if (orders.length === 0) {
        Alert.alert(
          'Nenhuma OS',
          `Nenhuma OS pendente para a zona: ${qrCode.zoneName}`,
          [{ text: 'OK', onPress: () => setCurrentScreen('workOrders') }]
        );
      } else if (orders.length === 1) {
        await openWorkOrderExecution(orders[0]);
      } else {
        setCurrentScreen('zoneOrders');
      }
    } else {
      setCurrentScreen('workOrders');
    }
  }, []);

  const openWorkOrderExecution = async (order: WorkOrder) => {
    setSelectedWorkOrder(order);
    
    let checklist: ChecklistTemplate | null = null;
    
    if (order.checklistTemplateId) {
      checklist = await db.getChecklistTemplate(order.checklistTemplateId);
      
      if (!checklist && isOnline && user) {
        try {
          checklist = await api.fetchChecklistTemplate(user.token, order.checklistTemplateId);
          if (checklist) {
            await db.saveChecklistTemplate(checklist);
          }
        } catch (error) {
          console.log('Nao foi possivel carregar checklist:', error);
        }
      }
    }
    
    setSelectedChecklist(checklist);
    
    if (order.status === 'open') {
      await db.updateWorkOrderStatus(order.id, 'in_progress', 'start');
      order.status = 'in_progress';
    }
    
    setCurrentScreen('execute');
  };

  const handleViewOrder = useCallback(async (order: WorkOrder) => {
    await openWorkOrderExecution(order);
  }, [isOnline, user]);

  const handleCompleteWorkOrder = async (
    answers: Record<string, ChecklistAnswer>, 
    photos: CapturedPhoto[]
  ): Promise<boolean> => {
    if (!selectedWorkOrder || !user) return false;

    try {
      for (const photo of photos) {
        const photoRecord: WorkOrderPhoto = {
          id: generateId(),
          workOrderId: selectedWorkOrder.id,
          checklistItemId: null,
          type: 'completion',
          uri: photo.uri,
          base64: photo.base64,
          fileName: `completion_${Date.now()}.jpg`,
          createdAt: new Date().toISOString(),
          syncStatus: 'pending',
        };
        await db.savePhoto(photoRecord);
      }

      if (selectedChecklist) {
        const execution = {
          id: generateId(),
          workOrderId: selectedWorkOrder.id,
          checklistTemplateId: selectedChecklist.id,
          executedBy: user.id,
          executedByName: user.name,
          status: 'completed' as const,
          answers,
          executedAt: new Date().toISOString(),
          createdAt: new Date().toISOString(),
          offlineCreated: true,
          syncStatus: 'pending' as const,
        };
        await db.saveChecklistExecution(execution);
      }

      await db.updateWorkOrderStatus(
        selectedWorkOrder.id, 
        'completed', 
        'complete',
        { notes: '', answers }
      );

      await refresh();
      
      if (isOnline) {
        forceSync();
      }

      return true;
    } catch (error) {
      console.error('Erro ao concluir OS:', error);
      return false;
    }
  };

  const handlePauseWorkOrder = async (
    reason: string, 
    photos: CapturedPhoto[]
  ): Promise<boolean> => {
    if (!selectedWorkOrder || !user) return false;

    try {
      for (const photo of photos) {
        const photoRecord: WorkOrderPhoto = {
          id: generateId(),
          workOrderId: selectedWorkOrder.id,
          checklistItemId: null,
          type: 'pause',
          uri: photo.uri,
          base64: photo.base64,
          fileName: `pause_${Date.now()}.jpg`,
          createdAt: new Date().toISOString(),
          syncStatus: 'pending',
        };
        await db.savePhoto(photoRecord);
      }

      await db.updateWorkOrderStatus(
        selectedWorkOrder.id, 
        'paused', 
        'pause',
        { reason, notes: reason }
      );

      await refresh();
      
      if (isOnline) {
        forceSync();
      }

      return true;
    } catch (error) {
      console.error('Erro ao pausar OS:', error);
      return false;
    }
  };

  const handleResumeWorkOrder = async (): Promise<boolean> => {
    if (!selectedWorkOrder || !user) return false;

    try {
      await db.updateWorkOrderStatus(
        selectedWorkOrder.id, 
        'in_progress', 
        'resume'
      );

      const updatedOrder = await db.getWorkOrderById(selectedWorkOrder.id);
      if (updatedOrder) {
        setSelectedWorkOrder(updatedOrder);
      }

      await refresh();
      
      if (isOnline) {
        forceSync();
      }

      return true;
    } catch (error) {
      console.error('Erro ao retomar OS:', error);
      return false;
    }
  };

  const handleBackFromExecution = useCallback(() => {
    setSelectedWorkOrder(null);
    setSelectedChecklist(null);
    setCurrentScreen('workOrders');
  }, []);

  const handleRefresh = useCallback(async () => {
    await refresh();
    if (user && selectedCustomerId) {
      await forceSync();
    }
  }, [refresh, forceSync, user, selectedCustomerId]);

  const handleForceSync = useCallback(async () => {
    if (user && selectedCustomerId) {
      const status = await forceSync();
      if (status.lastSync) {
        Alert.alert('Sucesso', 'Sincronizacao concluida!');
      } else if (!status.isOnline) {
        Alert.alert('Offline', 'Voce esta offline. As alteracoes serao sincronizadas quando a conexao for restabelecida.');
      }
    }
  }, [forceSync, user, selectedCustomerId]);

  const handleQuickComplete = useCallback(async (orderId: string): Promise<boolean> => {
    const order = workOrders.find(o => o.id === orderId);
    if (!order) return false;
    
    await openWorkOrderExecution(order);
    return true;
  }, [workOrders]);

  const handleQuickPause = useCallback(async (orderId: string): Promise<boolean> => {
    const order = workOrders.find(o => o.id === orderId);
    if (!order) return false;
    
    await openWorkOrderExecution(order);
    return true;
  }, [workOrders]);

  if (!isAuthenticated) {
    return (
      <SafeAreaProvider>
        <StatusBar style="light" />
        <LoginScreen
          onLogin={handleLogin}
          isLoading={isLoading}
          error={error}
        />
      </SafeAreaProvider>
    );
  }

  if (!selectedCustomerId) {
    return (
      <SafeAreaProvider>
        <StatusBar style="light" />
        <CustomerSelectScreen
          user={user!}
          onSelectCustomer={handleSelectCustomer}
          onLogout={handleLogout}
        />
      </SafeAreaProvider>
    );
  }

  if (currentScreen === 'scanner') {
    return (
      <SafeAreaProvider>
        <StatusBar style="light" />
        <QRScannerScreen
          workOrders={workOrders}
          onScanComplete={handleScanComplete}
          onClose={handleCloseScanner}
        />
      </SafeAreaProvider>
    );
  }

  if (currentScreen === 'execute' && selectedWorkOrder && user) {
    return (
      <SafeAreaProvider>
        <StatusBar style="light" />
        <WorkOrderExecuteScreen
          workOrder={selectedWorkOrder}
          checklist={selectedChecklist}
          user={user}
          isOnline={isOnline}
          onComplete={handleCompleteWorkOrder}
          onPause={handlePauseWorkOrder}
          onResume={handleResumeWorkOrder}
          onBack={handleBackFromExecution}
        />
      </SafeAreaProvider>
    );
  }

  if (currentScreen === 'zoneOrders' && scannedQRCode) {
    return (
      <SafeAreaProvider>
        <StatusBar style="light" />
        <WorkOrdersScreen
          workOrders={zoneWorkOrders}
          isLoading={false}
          syncStatus={syncStatus}
          user={user!}
          onRefresh={handleRefresh}
          onCompleteOrder={handleQuickComplete}
          onPauseOrder={handleQuickPause}
          onViewOrder={handleViewOrder}
          onLogout={handleLogout}
          onForceSync={handleForceSync}
          onOpenScanner={handleOpenScanner}
          title={`OSs - ${scannedQRCode.zoneName}`}
          onBack={() => setCurrentScreen('workOrders')}
        />
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      <StatusBar style="light" />
      <WorkOrdersScreen
        workOrders={workOrders}
        isLoading={ordersLoading}
        syncStatus={syncStatus}
        user={user!}
        onRefresh={handleRefresh}
        onCompleteOrder={handleQuickComplete}
        onPauseOrder={handleQuickPause}
        onViewOrder={handleViewOrder}
        onLogout={handleLogout}
        onForceSync={handleForceSync}
        onOpenScanner={handleOpenScanner}
      />
    </SafeAreaProvider>
  );
}
