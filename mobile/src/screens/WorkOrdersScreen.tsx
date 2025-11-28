import { useState, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  Alert,
} from 'react-native';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { WorkOrder, SyncStatus, User } from '../types';

interface WorkOrdersScreenProps {
  workOrders: WorkOrder[];
  isLoading: boolean;
  syncStatus: SyncStatus;
  user: User;
  onRefresh: () => Promise<void>;
  onCompleteOrder: (id: string, notes?: string) => Promise<boolean>;
  onPauseOrder: (id: string, notes?: string) => Promise<boolean>;
  onViewOrder: (order: WorkOrder) => void;
  onLogout: () => void;
  onForceSync: () => Promise<void>;
  onOpenScanner: () => void;
}

export function WorkOrdersScreen({
  workOrders,
  isLoading,
  syncStatus,
  user,
  onRefresh,
  onCompleteOrder,
  onPauseOrder,
  onViewOrder,
  onLogout,
  onForceSync,
  onOpenScanner,
}: WorkOrdersScreenProps) {
  const [refreshing, setRefreshing] = useState(false);

  const handleRefresh = async () => {
    setRefreshing(true);
    await onRefresh();
    setRefreshing(false);
  };

  const handleComplete = (order: WorkOrder) => {
    Alert.alert(
      'Concluir OS',
      `Deseja concluir a OS #${order.workOrderNumber}?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Concluir',
          onPress: async () => {
            const success = await onCompleteOrder(order.id);
            if (success) {
              Alert.alert('Sucesso', 'OS concluída com sucesso!');
            }
          },
        },
      ]
    );
  };

  const handlePause = (order: WorkOrder) => {
    Alert.alert(
      'Pausar OS',
      `Deseja pausar a OS #${order.workOrderNumber}?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Pausar',
          onPress: async () => {
            const success = await onPauseOrder(order.id);
            if (success) {
              Alert.alert('Sucesso', 'OS pausada com sucesso!');
            }
          },
        },
      ]
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open':
        return '#3B82F6';
      case 'in_progress':
        return '#F59E0B';
      case 'paused':
        return '#EF4444';
      case 'completed':
        return '#10B981';
      default:
        return '#6B7280';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'open':
        return 'Aberta';
      case 'in_progress':
        return 'Em Andamento';
      case 'paused':
        return 'Pausada';
      case 'completed':
        return 'Concluída';
      default:
        return status;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'urgent':
        return '#DC2626';
      case 'high':
        return '#F59E0B';
      case 'medium':
        return '#3B82F6';
      case 'low':
        return '#10B981';
      default:
        return '#6B7280';
    }
  };

  const renderWorkOrder = ({ item }: { item: WorkOrder }) => (
    <TouchableOpacity
      style={[
        styles.card,
        item.offlineModified && styles.cardModified,
      ]}
      onPress={() => onViewOrder(item)}
    >
      <View style={styles.cardHeader}>
        <View style={styles.orderInfo}>
          <Text style={styles.orderNumber}>OS #{item.workOrderNumber}</Text>
          {item.offlineModified && (
            <View style={styles.offlineBadge}>
              <Text style={styles.offlineBadgeText}>Pendente</Text>
            </View>
          )}
        </View>
        <View
          style={[
            styles.statusBadge,
            { backgroundColor: getStatusColor(item.status) + '20' },
          ]}
        >
          <Text style={[styles.statusText, { color: getStatusColor(item.status) }]}>
            {getStatusLabel(item.status)}
          </Text>
        </View>
      </View>

      <Text style={styles.title} numberOfLines={2}>
        {item.title}
      </Text>

      <View style={styles.details}>
        <Text style={styles.detailText}>
          {item.siteName} - {item.zoneName}
        </Text>
        <Text style={styles.detailText}>
          {format(new Date(item.scheduledDate), "dd/MM/yyyy", { locale: ptBR })}
        </Text>
      </View>

      <View style={styles.priorityContainer}>
        <View
          style={[styles.priorityDot, { backgroundColor: getPriorityColor(item.priority) }]}
        />
        <Text style={styles.priorityText}>
          {item.priority === 'urgent'
            ? 'Urgente'
            : item.priority === 'high'
            ? 'Alta'
            : item.priority === 'medium'
            ? 'Média'
            : 'Baixa'}
        </Text>
      </View>

      <View style={styles.actions}>
        {item.status !== 'completed' && (
          <>
            <TouchableOpacity
              style={[styles.actionButton, styles.completeButton]}
              onPress={() => handleComplete(item)}
            >
              <Text style={styles.actionButtonText}>Concluir</Text>
            </TouchableOpacity>
            {item.status !== 'paused' && (
              <TouchableOpacity
                style={[styles.actionButton, styles.pauseButton]}
                onPress={() => handlePause(item)}
              >
                <Text style={[styles.actionButtonText, styles.pauseButtonText]}>
                  Pausar
                </Text>
              </TouchableOpacity>
            )}
          </>
        )}
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View>
            <Text style={styles.greeting}>Ola, {user.name}</Text>
            <Text style={styles.headerSubtitle}>
              {workOrders.length} ordem{workOrders.length !== 1 ? 'ns' : ''} de servico
            </Text>
          </View>
          <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
            <Text style={styles.logoutText}>Sair</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.syncStatus}>
          <View style={styles.syncInfo}>
            <View
              style={[
                styles.onlineIndicator,
                { backgroundColor: syncStatus.isOnline ? '#10B981' : '#EF4444' },
              ]}
            />
            <Text style={styles.syncText}>
              {syncStatus.isOnline ? 'Online' : 'Offline'}
            </Text>
            {syncStatus.pendingChanges > 0 && (
              <Text style={styles.pendingText}>
                {syncStatus.pendingChanges} pendente{syncStatus.pendingChanges > 1 ? 's' : ''}
              </Text>
            )}
          </View>
          <TouchableOpacity
            style={[styles.syncButton, syncStatus.isSyncing && styles.syncButtonDisabled]}
            onPress={onForceSync}
            disabled={syncStatus.isSyncing}
          >
            <Text style={styles.syncButtonText}>
              {syncStatus.isSyncing ? 'Sincronizando...' : 'Sincronizar'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      <FlatList
        data={workOrders}
        renderItem={renderWorkOrder}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {isLoading ? 'Carregando...' : 'Nenhuma ordem de servico encontrada'}
            </Text>
          </View>
        }
      />

      <TouchableOpacity style={styles.scanButton} onPress={onOpenScanner}>
        <Text style={styles.scanButtonText}>Escanear QR Code</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  header: {
    backgroundColor: '#3B82F6',
    paddingTop: 50,
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 16,
  },
  greeting: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.8,
    marginTop: 4,
  },
  logoutButton: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  logoutText: {
    color: '#fff',
    fontWeight: '500',
  },
  syncStatus: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.1)',
    padding: 12,
    borderRadius: 8,
  },
  syncInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  onlineIndicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  syncText: {
    color: '#fff',
    fontWeight: '500',
  },
  pendingText: {
    color: '#fbbf24',
    marginLeft: 12,
    fontSize: 12,
  },
  syncButton: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 6,
  },
  syncButtonDisabled: {
    opacity: 0.5,
  },
  syncButtonText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '500',
  },
  list: {
    padding: 16,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  cardModified: {
    borderWidth: 2,
    borderColor: '#F59E0B',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  orderInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  orderNumber: {
    fontSize: 14,
    fontWeight: '600',
    color: '#3B82F6',
  },
  offlineBadge: {
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 4,
    marginLeft: 8,
  },
  offlineBadgeText: {
    fontSize: 10,
    color: '#D97706',
    fontWeight: '500',
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '500',
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1e293b',
    marginBottom: 8,
  },
  details: {
    marginBottom: 8,
  },
  detailText: {
    fontSize: 13,
    color: '#64748b',
    marginBottom: 2,
  },
  priorityContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  priorityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 6,
  },
  priorityText: {
    fontSize: 12,
    color: '#64748b',
  },
  actions: {
    flexDirection: 'row',
    gap: 8,
  },
  actionButton: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
  },
  completeButton: {
    backgroundColor: '#10B981',
  },
  pauseButton: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#F59E0B',
  },
  actionButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 14,
  },
  pauseButtonText: {
    color: '#F59E0B',
  },
  emptyContainer: {
    padding: 40,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#64748b',
    textAlign: 'center',
  },
  scanButton: {
    position: 'absolute',
    bottom: 24,
    left: 16,
    right: 16,
    backgroundColor: '#3B82F6',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  scanButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
