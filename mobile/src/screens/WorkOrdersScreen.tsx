import { useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  ScrollView,
} from 'react-native';
import { format, isToday } from 'date-fns';
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
  title?: string;
  onBack?: () => void;
}

type FilterType = 'pendentes_dia' | 'minhas_os';

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
  title,
  onBack,
}: WorkOrdersScreenProps) {
  const [refreshing, setRefreshing] = useState(false);
  const [activeFilter, setActiveFilter] = useState<FilterType>('pendentes_dia');

  const handleRefresh = async () => {
    setRefreshing(true);
    await onRefresh();
    setRefreshing(false);
  };

  // O.S. Disponíveis (não atribuídas, abertas)
  const allAvailableOrders = useMemo(() => {
    return workOrders
      .filter(wo => !wo.assignedUserId && wo.status === 'open')
      .sort((a, b) => b.workOrderNumber - a.workOrderNumber);
  }, [workOrders]);

  // Pendentes Hoje - O.S. DISPONÍVEIS (não atribuídas) com data de hoje
  const pendentesHoje = useMemo(() => {
    return allAvailableOrders
      .filter(wo => {
        const orderDate = new Date(wo.dueDate || wo.scheduledDate || wo.createdAt);
        return isToday(orderDate);
      });
  }, [allAvailableOrders]);

  // Minhas O.S. - Todas atribuidas ao operador (qualquer status exceto concluida/cancelada)
  const minhasOS = useMemo(() => {
    return workOrders
      .filter(wo => {
        const isAssignedToMe = wo.assignedUserId === user.id;
        const isActive = wo.status !== 'completed' && wo.status !== 'cancelled';
        return isAssignedToMe && isActive;
      })
      .sort((a, b) => {
        const statusOrder = { 'in_progress': 0, 'paused': 1, 'open': 2 };
        const aOrder = statusOrder[a.status as keyof typeof statusOrder] ?? 3;
        const bOrder = statusOrder[b.status as keyof typeof statusOrder] ?? 3;
        if (aOrder !== bOrder) return aOrder - bOrder;
        return b.workOrderNumber - a.workOrderNumber;
      });
  }, [workOrders, user.id]);

  // Lista atual baseada no filtro
  const currentList = activeFilter === 'pendentes_dia' ? pendentesHoje : minhasOS;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open': return '#3B82F6';
      case 'in_progress': return '#10B981';
      case 'paused': return '#F59E0B';
      case 'completed': return '#6B7280';
      default: return '#6B7280';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'open': return 'Aberta';
      case 'in_progress': return 'Em Execucao';
      case 'paused': return 'Pausada';
      case 'completed': return 'Concluida';
      default: return status;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'urgent': return '#DC2626';
      case 'high': return '#F59E0B';
      case 'medium': return '#3B82F6';
      case 'low': return '#10B981';
      default: return '#6B7280';
    }
  };

  const getPriorityLabel = (priority: string) => {
    switch (priority) {
      case 'urgent': return 'Urgente';
      case 'high': return 'Alta';
      case 'medium': return 'Media';
      case 'low': return 'Baixa';
      default: return priority;
    }
  };

  const renderWorkOrderCard = (item: WorkOrder) => (
    <TouchableOpacity
      key={item.id}
      style={[
        styles.card,
        item.offlineModified && styles.cardModified,
      ]}
      onPress={() => onViewOrder(item)}
    >
      <View style={styles.cardHeader}>
        <View style={styles.orderInfo}>
          <View style={styles.orderNumberBadge}>
            <Text style={styles.orderNumberText}>OS #{item.workOrderNumber}</Text>
          </View>
          {item.offlineModified && (
            <View style={styles.offlineBadge}>
              <Text style={styles.offlineBadgeText}>Pendente Sync</Text>
            </View>
          )}
        </View>
        <View style={[styles.statusBadge, { backgroundColor: getStatusColor(item.status) + '20' }]}>
          <Text style={[styles.statusText, { color: getStatusColor(item.status) }]}>
            {getStatusLabel(item.status)}
          </Text>
        </View>
      </View>

      <Text style={styles.cardTitle} numberOfLines={2}>{item.title}</Text>

      <View style={styles.locationRow}>
        <Text style={styles.locationIcon}>📍</Text>
        <Text style={styles.locationText}>{item.siteName} - {item.zoneName}</Text>
      </View>

      <View style={styles.dateRow}>
        <Text style={styles.dateIcon}>📅</Text>
        <Text style={styles.dateText}>
          Prazo: {format(new Date(item.dueDate || item.scheduledDate || item.createdAt), "dd/MM/yyyy", { locale: ptBR })}
        </Text>
      </View>

      <View style={styles.priorityRow}>
        <View style={[styles.priorityDot, { backgroundColor: getPriorityColor(item.priority) }]} />
        <Text style={styles.priorityText}>{getPriorityLabel(item.priority)}</Text>
      </View>

      {item.startedAt && (
        <View style={styles.startedRow}>
          <Text style={styles.startedIcon}>⏱️</Text>
          <Text style={styles.startedText}>
            Iniciado: {format(new Date(item.startedAt), "dd/MM HH:mm", { locale: ptBR })}
          </Text>
        </View>
      )}

      <View style={styles.actions}>
        <TouchableOpacity
          style={[styles.actionButton, styles.viewButton]}
          onPress={() => onViewOrder(item)}
        >
          <Text style={styles.viewButtonText}>Ver Detalhes</Text>
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyIcon}>📋</Text>
      <Text style={styles.emptyTitle}>
        {activeFilter === 'pendentes_dia' 
          ? 'Nenhuma O.S. pendente para hoje'
          : 'Nenhuma O.S. atribuida a voce'}
      </Text>
      <Text style={styles.emptySubtitle}>
        {activeFilter === 'pendentes_dia'
          ? 'Todas as ordens de servico de hoje foram concluidas ou nao ha ordens para hoje'
          : 'Escaneie um QR Code para iniciar uma nova tarefa'}
      </Text>
    </View>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          {onBack ? (
            <TouchableOpacity style={styles.backButton} onPress={onBack}>
              <Text style={styles.backButtonText}>← Voltar</Text>
            </TouchableOpacity>
          ) : (
            <View style={styles.userInfo}>
              <Text style={styles.greeting}>{user.name}</Text>
              <Text style={styles.userRole}>Colaborador</Text>
            </View>
          )}
          {!onBack && (
            <View style={styles.headerActions}>
              <View style={styles.moduleButton}>
                <Text style={styles.moduleIcon}>📋</Text>
                <Text style={styles.moduleText}>Clean</Text>
              </View>
              <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
                <Text style={styles.logoutIcon}>→</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </View>

      {/* Filtros Simplificados */}
      <View style={styles.filterContainer}>
        <TouchableOpacity
          style={[
            styles.filterTab,
            activeFilter === 'pendentes_dia' && styles.filterTabActive
          ]}
          onPress={() => setActiveFilter('pendentes_dia')}
        >
          <Text style={styles.filterTabIcon}>📅</Text>
          <Text style={[
            styles.filterTabText,
            activeFilter === 'pendentes_dia' && styles.filterTabTextActive
          ]}>
            Pendentes Hoje
          </Text>
          <View style={[
            styles.filterBadge,
            activeFilter === 'pendentes_dia' && styles.filterBadgeActive
          ]}>
            <Text style={[
              styles.filterBadgeText,
              activeFilter === 'pendentes_dia' && styles.filterBadgeTextActive
            ]}>
              {pendentesHoje.length}
            </Text>
          </View>
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.filterTab,
            activeFilter === 'minhas_os' && styles.filterTabActive
          ]}
          onPress={() => setActiveFilter('minhas_os')}
        >
          <Text style={styles.filterTabIcon}>👤</Text>
          <Text style={[
            styles.filterTabText,
            activeFilter === 'minhas_os' && styles.filterTabTextActive
          ]}>
            Minhas O.S.
          </Text>
          <View style={[
            styles.filterBadge,
            activeFilter === 'minhas_os' && styles.filterBadgeActive
          ]}>
            <Text style={[
              styles.filterBadgeText,
              activeFilter === 'minhas_os' && styles.filterBadgeTextActive
            ]}>
              {minhasOS.length}
            </Text>
          </View>
        </TouchableOpacity>
      </View>

      {/* Lista de O.S. */}
      <ScrollView
        style={styles.content}
        refreshControl={
          <RefreshControl 
            refreshing={refreshing} 
            onRefresh={handleRefresh} 
            colors={['#4F46E5']} 
          />
        }
        contentContainerStyle={styles.scrollContent}
      >
        {currentList.length === 0 ? (
          renderEmptyState()
        ) : (
          currentList.map(order => renderWorkOrderCard(order))
        )}

        {/* Spacer for scan button */}
        <View style={styles.bottomSpacer} />
      </ScrollView>

      {/* Scan Button */}
      <TouchableOpacity style={styles.scanButton} onPress={onOpenScanner}>
        <Text style={styles.scanButtonIcon}>📷</Text>
        <Text style={styles.scanButtonText}>Escanear QR Code</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F1F5F9',
  },
  header: {
    backgroundColor: '#1E3A5F',
    paddingTop: 50,
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  userInfo: {
    flex: 1,
  },
  greeting: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  userRole: {
    fontSize: 14,
    color: '#94A3B8',
    marginTop: 2,
  },
  headerActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  moduleButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
    gap: 6,
  },
  moduleIcon: {
    fontSize: 14,
  },
  moduleText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1E3A5F',
  },
  logoutButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoutIcon: {
    fontSize: 18,
    color: '#FFFFFF',
  },
  backButton: {
    paddingVertical: 8,
  },
  backButtonText: {
    fontSize: 16,
    color: '#FFFFFF',
  },
  filterContainer: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    marginHorizontal: 16,
    marginTop: 16,
    borderRadius: 12,
    padding: 6,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  filterTab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 8,
    borderRadius: 8,
    gap: 6,
  },
  filterTabActive: {
    backgroundColor: '#4F46E5',
  },
  filterTabIcon: {
    fontSize: 16,
  },
  filterTabText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#64748B',
  },
  filterTabTextActive: {
    color: '#FFFFFF',
  },
  filterBadge: {
    backgroundColor: '#E2E8F0',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 10,
    minWidth: 24,
    alignItems: 'center',
  },
  filterBadgeActive: {
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
  },
  filterBadgeText: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#64748B',
  },
  filterBadgeTextActive: {
    color: '#FFFFFF',
  },
  content: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 100,
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: 16,
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#334155',
    textAlign: 'center',
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#64748B',
    textAlign: 'center',
    paddingHorizontal: 32,
  },
  card: {
    backgroundColor: '#FFFFFF',
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
    marginBottom: 12,
  },
  orderInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  orderNumberBadge: {
    backgroundColor: '#1E3A5F',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  orderNumberText: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  offlineBadge: {
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 4,
  },
  offlineBadgeText: {
    fontSize: 10,
    fontWeight: '600',
    color: '#D97706',
  },
  statusBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '600',
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1E293B',
    marginBottom: 12,
    lineHeight: 22,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  locationIcon: {
    fontSize: 14,
    marginRight: 8,
  },
  locationText: {
    fontSize: 13,
    color: '#64748B',
    flex: 1,
  },
  dateRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  dateIcon: {
    fontSize: 14,
    marginRight: 8,
  },
  dateText: {
    fontSize: 13,
    color: '#64748B',
  },
  priorityRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  priorityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  priorityText: {
    fontSize: 13,
    color: '#64748B',
  },
  startedRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#E2E8F0',
  },
  startedIcon: {
    fontSize: 14,
    marginRight: 8,
  },
  startedText: {
    fontSize: 13,
    color: '#10B981',
    fontWeight: '500',
  },
  actions: {
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#E2E8F0',
  },
  actionButton: {
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
  },
  viewButton: {
    backgroundColor: '#4F46E5',
  },
  viewButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  bottomSpacer: {
    height: 20,
  },
  scanButton: {
    position: 'absolute',
    bottom: 24,
    left: 16,
    right: 16,
    backgroundColor: '#4F46E5',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    borderRadius: 12,
    shadowColor: '#4F46E5',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
    gap: 8,
  },
  scanButtonIcon: {
    fontSize: 20,
  },
  scanButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
});
