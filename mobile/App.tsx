import { useState, useEffect, useCallback } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { View, StyleSheet, Alert } from 'react-native';

import { LoginScreen } from './src/screens/LoginScreen';
import { CustomerSelectScreen } from './src/screens/CustomerSelectScreen';
import { WorkOrdersScreen } from './src/screens/WorkOrdersScreen';
import { useAuth } from './src/hooks/useAuth';
import { useWorkOrders } from './src/hooks/useWorkOrders';
import { useSync } from './src/hooks/useSync';
import { WorkOrder } from './src/types';

export default function App() {
  const { user, isLoading, error, login, logout, isAuthenticated } = useAuth();
  const [selectedCustomerId, setSelectedCustomerId] = useState<string | null>(null);
  const { workOrders, isLoading: ordersLoading, refresh, completeWorkOrder, pauseWorkOrder } = useWorkOrders();
  const { syncStatus, forceSync } = useSync(user, selectedCustomerId);

  useEffect(() => {
    if (user?.customerId) {
      setSelectedCustomerId(user.customerId);
    }
  }, [user]);

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
            setSelectedCustomerId(null);
            await logout();
          },
        },
      ]
    );
  }, [logout]);

  const handleSelectCustomer = useCallback((customerId: string) => {
    setSelectedCustomerId(customerId);
  }, []);

  const handleViewOrder = useCallback((order: WorkOrder) => {
    Alert.alert(
      `OS #${order.workOrderNumber}`,
      `${order.title}\n\nLocal: ${order.siteName} - ${order.zoneName}\n\nDescricao: ${order.description || 'Sem descricao'}`,
      [{ text: 'Fechar' }]
    );
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

  return (
    <SafeAreaProvider>
      <StatusBar style="light" />
      <WorkOrdersScreen
        workOrders={workOrders}
        isLoading={ordersLoading}
        syncStatus={syncStatus}
        user={user!}
        onRefresh={handleRefresh}
        onCompleteOrder={completeWorkOrder}
        onPauseOrder={pauseWorkOrder}
        onViewOrder={handleViewOrder}
        onLogout={handleLogout}
        onForceSync={handleForceSync}
      />
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
