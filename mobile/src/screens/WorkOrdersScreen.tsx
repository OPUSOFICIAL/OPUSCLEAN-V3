import { useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  Alert,
  ScrollView,
} from 'react-native';
import { format, isToday, isYesterday, subDays, isWithinInterval, startOfDay, endOfDay } from 'date-fns';
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

type DateFilter = 'hoje' | 'ontem' | 'semana' | 'todos';

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
  const [dateFilter, setDateFilter] = useState<DateFilter>('todos');

  const handleRefresh = async () => {
    setRefreshing(true);
    await onRefresh();
    setRefreshing(false);
  };

  const getOrderDate = useCallback((wo: WorkOrder, useCompletionDate: boolean = false): Date => {
    if (useCompletionDate && wo.completedAt) {
      return new Date(wo.completedAt);
    }
    return new Date(wo.scheduledDate || wo.createdAt);
  }, []);

  const filterByDate = useCallback((orders: WorkOrder[], filter: DateFilter, useCompletionDate: boolean = false): WorkOrder[] => {
    const today = new Date();
    
    switch (filter) {
      case 'hoje':
        return orders.filter(wo => {
          const date = getOrderDate(wo, useCompletionDate);
          return isToday(date);
        });
      case 'ontem':
        return orders.filter(wo => {
          const date = getOrderDate(wo, useCompletionDate);
          return isYesterday(date);
        });
      case 'semana':
        const weekAgo = subDays(today, 7);
        return orders.filter(wo => {
          const date = getOrderDate(wo, useCompletionDate);
          return isWithinInterval(date, { start: startOfDay(weekAgo), end: endOfDay(today) });
        });
      case 'todos':
      default:
        return orders;
    }
  }, [getOrderDate]);

  const filteredOrders = useMemo(() => 
    filterByDate(workOrders, dateFilter), 
    [workOrders, dateFilter, filterByDate]
  );

  const inProgressOrders = useMemo(() => 
    filteredOrders
      .filter(wo => wo.status === 'in_progress' && wo.assignedUserId === user.id)
      .sort((a, b) => b.workOrderNumber - a.workOrderNumber),
    [filteredOrders, user.id]
  );

  const availableOrders = useMemo(() => 
    filteredOrders
      .filter(wo => !wo.assignedUserId && wo.status === 'open')
      .sort((a, b) => b.workOrderNumber - a.workOrderNumber),
    [filteredOrders]
  );

  const myPendingOrders = useMemo(() => 
    filteredOrders
      .filter(wo => wo.assignedUserId === user.id && wo.status === 'open')
      .sort((a, b) => b.workOrderNumber - a.workOrderNumber),
    [filteredOrders, user.id]
  );

  const pausedOrders = useMemo(() => 
    filteredOrders
      .filter(wo => wo.status === 'paused' && wo.assignedUserId === user.id)
      .sort((a, b) => b.workOrderNumber - a.workOrderNumber),
    [filteredOrders, user.id]
  );

  const completedOrders = useMemo(() => 
    filterByDate(workOrders, dateFilter, true)
      .filter(wo => wo.status === 'completed' && wo.assignedUserId === user.id)
      .sort((a, b) => b.workOrderNumber - a.workOrderNumber),
    [workOrders, dateFilter, filterByDate, user.id]
  );

  const statusCounts = useMemo(() => ({
    inProgress: inProgressOrders.length,
    available: availableOrders.length,
    pending: myPendingOrders.length,
    paused: pausedOrders.length,
    completed: completedOrders.length,
  }), [inProgressOrders, availableOrders, myPendingOrders, pausedOrders, completedOrders]);

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

  const renderWorkOrderCard = (item: WorkOrder, showActions: boolean = true) => (
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
              <Text style={styles.offlineBadgeText}>Pendente</Text>
            </View>
          )}
        </View>
        <View style={[styles.statusBadge, { backgroundColor: getStatusColor(item.status) + '20' }]}>
          <Text style={[styles.statusText, { color: getStatusColor(item.status) }]}>
            {getStatusLabel(item.status)}
          </Text>
        </View>
      </View>

      <Text style={styles.title} numberOfLines={2}>{item.title}</Text>

      <View style={styles.locationRow}>
        <Text style={styles.locationIcon}>📍</Text>
        <Text style={styles.locationText}>{item.siteName} - {item.zoneName}</Text>
      </View>

      <View style={styles.dateRow}>
        <Text style={styles.dateIcon}>📅</Text>
        <Text style={styles.dateText}>
          Prazo: {format(new Date(item.scheduledDate), "dd/MM/yyyy", { locale: ptBR })}
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

      {showActions && item.status !== 'completed' && (
        <View style={styles.actions}>
          <TouchableOpacity
            style={[styles.actionButton, styles.viewButton]}
            onPress={() => onViewOrder(item)}
          >
            <Text style={styles.viewButtonText}>Ver Detalhes</Text>
          </TouchableOpacity>
        </View>
      )}
    </TouchableOpacity>
  );

  const renderInProgressCard = (item: WorkOrder) => (
    <TouchableOpacity
      key={item.id}
      style={styles.inProgressCard}
      onPress={() => onViewOrder(item)}
    >
      <View style={styles.inProgressHeader}>
        <View style={styles.inProgressBadge}>
          <Text style={styles.inProgressBadgeText}>OS #{item.workOrderNumber}</Text>
        </View>
        <View style={[styles.priorityDot, { backgroundColor: getPriorityColor(item.priority) }]} />
      </View>
      <Text style={styles.inProgressTitle} numberOfLines={2}>{item.title}</Text>
      <View style={styles.inProgressLocation}>
        <Text style={styles.inProgressLocationIcon}>📍</Text>
        <Text style={styles.inProgressLocationText}>{item.siteName} - {item.zoneName}</Text>
      </View>
      <View style={styles.inProgressDate}>
        <Text style={styles.inProgressDateIcon}>📅</Text>
        <Text style={styles.inProgressDateText}>
          Prazo: {format(new Date(item.scheduledDate), "dd/MM/yyyy", { locale: ptBR })}
        </Text>
      </View>
      {item.startedAt && (
        <View style={styles.inProgressStarted}>
          <Text style={styles.inProgressStartedIcon}>⏱️</Text>
          <Text style={styles.inProgressStartedText}>
            Iniciado: {format(new Date(item.startedAt), "dd/MM HH:mm", { locale: ptBR })}
          </Text>
        </View>
      )}
    </TouchableOpacity>
  );

  const renderSection = (sectionTitle: string, orders: WorkOrder[], emptyMessage: string, icon: string) => (
    <View style={styles.section}>
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionIcon}>{icon}</Text>
        <Text style={styles.sectionTitle}>{sectionTitle}</Text>
        <View style={styles.sectionBadge}>
          <Text style={styles.sectionBadgeText}>{orders.length}</Text>
        </View>
      </View>
      {orders.length === 0 ? (
        <View style={styles.emptySection}>
          <Text style={styles.emptySectionText}>{emptyMessage}</Text>
        </View>
      ) : (
        orders.slice(0, 5).map(order => renderWorkOrderCard(order))
      )}
      {orders.length > 5 && (
        <Text style={styles.moreText}>+ {orders.length - 5} mais...</Text>
      )}
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
              <Text style={styles.greeting}>Ola, {user.name}</Text>
              <Text style={styles.orderCount}>
                {workOrders.length} ordem{workOrders.length !== 1 ? 'ns' : ''} de servico
              </Text>
            </View>
          )}
          {!onBack && (
            <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
              <Text style={styles.logoutText}>Sair</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Sync Status */}
        <View style={styles.syncStatus}>
          <View style={styles.syncInfo}>
            <View style={[styles.onlineIndicator, { backgroundColor: syncStatus.isOnline ? '#10B981' : '#EF4444' }]} />
            <Text style={styles.syncText}>{syncStatus.isOnline ? 'Online' : 'Offline'}</Text>
            {syncStatus.pendingChanges > 0 && (
              <Text style={styles.pendingText}>{syncStatus.pendingChanges} pendente{syncStatus.pendingChanges > 1 ? 's' : ''}</Text>
            )}
          </View>
          <TouchableOpacity
            style={[styles.syncButton, syncStatus.isSyncing && styles.syncButtonDisabled]}
            onPress={onForceSync}
            disabled={syncStatus.isSyncing}
          >
            <Text style={styles.syncButtonText}>{syncStatus.isSyncing ? 'Sincronizando...' : 'Sincronizar'}</Text>
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView 
        style={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Em Execucao Card - Destaque */}
        <View style={[
          styles.inProgressSection,
          inProgressOrders.length > 0 ? styles.inProgressActive : styles.inProgressEmpty
        ]}>
          <View style={styles.inProgressSectionHeader}>
            <Text style={styles.inProgressSectionIcon}>⚡</Text>
            <Text style={styles.inProgressSectionTitle}>
              {inProgressOrders.length > 0 ? 'Em Execucao Agora' : 'Minhas Execucoes'}
            </Text>
            <View style={styles.inProgressSectionBadge}>
              <Text style={styles.inProgressSectionBadgeText}>{inProgressOrders.length}</Text>
            </View>
          </View>

          {inProgressOrders.length === 0 ? (
            <View style={styles.inProgressEmptyContent}>
              <Text style={styles.inProgressEmptyIcon}>▶️</Text>
              <Text style={styles.inProgressEmptyTitle}>Nenhuma O.S em execucao</Text>
              <Text style={styles.inProgressEmptySubtitle}>Escaneie um QR Code para iniciar uma tarefa</Text>
            </View>
          ) : (
            <View style={styles.inProgressList}>
              <Text style={styles.inProgressListTitle}>
                Voce iniciou {inProgressOrders.length} {inProgressOrders.length === 1 ? 'tarefa' : 'tarefas'}:
              </Text>
              {inProgressOrders.map(order => renderInProgressCard(order))}
            </View>
          )}
        </View>

        {/* Filtros de Data */}
        <View style={styles.filterCard}>
          <View style={styles.filterHeader}>
            <Text style={styles.filterIcon}>🗓️</Text>
            <Text style={styles.filterTitle}>Filtrar por Data</Text>
          </View>
          <View style={styles.filterButtons}>
            {[
              { key: 'hoje', label: 'Hoje' },
              { key: 'ontem', label: 'Ontem' },
              { key: 'semana', label: 'Esta Semana' },
              { key: 'todos', label: 'Todas' },
            ].map(({ key, label }) => (
              <TouchableOpacity
                key={key}
                style={[
                  styles.filterButton,
                  dateFilter === key && styles.filterButtonActive
                ]}
                onPress={() => setDateFilter(key as DateFilter)}
              >
                <Text style={[
                  styles.filterButtonText,
                  dateFilter === key && styles.filterButtonTextActive
                ]}>
                  {label}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Stats Cards */}
        <View style={styles.statsGrid}>
          <View style={[styles.statCard, styles.statCardAvailable]}>
            <Text style={styles.statIcon}>📂</Text>
            <Text style={styles.statValue}>{statusCounts.available}</Text>
            <Text style={styles.statLabel}>Disponiveis</Text>
          </View>
          <View style={[styles.statCard, styles.statCardPending]}>
            <Text style={styles.statIcon}>📋</Text>
            <Text style={styles.statValue}>{statusCounts.pending}</Text>
            <Text style={styles.statLabel}>Pendentes</Text>
          </View>
        </View>
        <View style={styles.statsGrid}>
          <View style={[styles.statCard, styles.statCardPaused]}>
            <Text style={styles.statIcon}>⏸️</Text>
            <Text style={styles.statValue}>{statusCounts.paused}</Text>
            <Text style={styles.statLabel}>Pausadas</Text>
          </View>
          <View style={[styles.statCard, styles.statCardCompleted]}>
            <Text style={styles.statIcon}>✅</Text>
            <Text style={styles.statValue}>{statusCounts.completed}</Text>
            <Text style={styles.statLabel}>Concluidas</Text>
          </View>
        </View>

        {/* Sections */}
        {renderSection('Disponiveis', availableOrders, 'Nenhuma O.S disponivel', '📂')}
        {renderSection('Minhas Pendentes', myPendingOrders, 'Nenhuma O.S pendente atribuida a voce', '📋')}
        {renderSection('Pausadas', pausedOrders, 'Nenhuma O.S pausada', '⏸️')}
        {renderSection('Concluidas', completedOrders, 'Nenhuma O.S concluida', '✅')}

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
    backgroundColor: '#EEF2FF',
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
  userInfo: {
    flex: 1,
  },
  greeting: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#fff',
  },
  orderCount: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
    marginTop: 4,
  },
  backButton: {
    paddingVertical: 8,
    paddingRight: 16,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '500',
  },
  logoutButton: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  logoutText: {
    color: '#fff',
    fontWeight: '600',
  },
  syncStatus: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.15)',
    padding: 12,
    borderRadius: 10,
  },
  syncInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  onlineIndicator: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 8,
  },
  syncText: {
    color: '#fff',
    fontWeight: '600',
  },
  pendingText: {
    color: '#FCD34D',
    marginLeft: 12,
    fontSize: 12,
    fontWeight: '500',
  },
  syncButton: {
    backgroundColor: 'rgba(255,255,255,0.25)',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 8,
  },
  syncButtonDisabled: {
    opacity: 0.5,
  },
  syncButtonText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '600',
  },
  content: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
  },

  // Em Execucao Section
  inProgressSection: {
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
  },
  inProgressActive: {
    backgroundColor: '#10B981',
  },
  inProgressEmpty: {
    backgroundColor: '#9CA3AF',
  },
  inProgressSectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  inProgressSectionIcon: {
    fontSize: 20,
    marginRight: 8,
  },
  inProgressSectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    flex: 1,
  },
  inProgressSectionBadge: {
    backgroundColor: 'rgba(255,255,255,0.3)',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  inProgressSectionBadgeText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
  inProgressEmptyContent: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  inProgressEmptyIcon: {
    fontSize: 40,
    marginBottom: 12,
    opacity: 0.8,
  },
  inProgressEmptyTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
    marginBottom: 4,
  },
  inProgressEmptySubtitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.8)',
  },
  inProgressList: {
    gap: 12,
  },
  inProgressListTitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.9)',
    marginBottom: 8,
  },
  inProgressCard: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.3)',
  },
  inProgressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  inProgressBadge: {
    backgroundColor: 'rgba(255,255,255,0.4)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  inProgressBadgeText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 12,
  },
  inProgressTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  inProgressLocation: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  inProgressLocationIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  inProgressLocationText: {
    fontSize: 13,
    color: 'rgba(255,255,255,0.9)',
  },
  inProgressDate: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  inProgressDateIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  inProgressDateText: {
    fontSize: 13,
    color: 'rgba(255,255,255,0.9)',
  },
  inProgressStarted: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255,255,255,0.2)',
  },
  inProgressStartedIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  inProgressStartedText: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.8)',
  },

  // Filter Card
  filterCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  filterHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  filterIcon: {
    fontSize: 16,
    marginRight: 8,
  },
  filterTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#374151',
  },
  filterButtons: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  filterButton: {
    flex: 1,
    minWidth: '45%',
    paddingVertical: 10,
    paddingHorizontal: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    alignItems: 'center',
  },
  filterButtonActive: {
    backgroundColor: '#3B82F6',
    borderColor: '#3B82F6',
  },
  filterButtonText: {
    fontSize: 13,
    fontWeight: '500',
    color: '#4B5563',
  },
  filterButtonTextActive: {
    color: '#fff',
  },

  // Stats Grid
  statsGrid: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 16,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 14,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  statCardAvailable: {
    borderTopWidth: 3,
    borderTopColor: '#F97316',
  },
  statCardPending: {
    borderTopWidth: 3,
    borderTopColor: '#3B82F6',
  },
  statCardPaused: {
    borderTopWidth: 3,
    borderTopColor: '#F59E0B',
  },
  statCardCompleted: {
    borderTopWidth: 3,
    borderTopColor: '#10B981',
  },
  statIcon: {
    fontSize: 20,
    marginBottom: 6,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1F2937',
  },
  statLabel: {
    fontSize: 11,
    color: '#6B7280',
    marginTop: 2,
  },

  // Sections
  section: {
    marginBottom: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionIcon: {
    fontSize: 18,
    marginRight: 8,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1F2937',
    flex: 1,
  },
  sectionBadge: {
    backgroundColor: '#E5E7EB',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  sectionBadgeText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#4B5563',
  },
  emptySection: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 24,
    alignItems: 'center',
  },
  emptySectionText: {
    fontSize: 14,
    color: '#9CA3AF',
  },
  moreText: {
    textAlign: 'center',
    color: '#3B82F6',
    fontSize: 14,
    fontWeight: '500',
    marginTop: 8,
  },

  // Work Order Card
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 10,
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
    marginBottom: 10,
  },
  orderInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  orderNumberBadge: {
    backgroundColor: '#EFF6FF',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  orderNumberText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#3B82F6',
  },
  offlineBadge: {
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 4,
    marginLeft: 8,
  },
  offlineBadgeText: {
    fontSize: 10,
    color: '#D97706',
    fontWeight: '600',
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
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1F2937',
    marginBottom: 10,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  locationIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  locationText: {
    fontSize: 13,
    color: '#6B7280',
  },
  dateRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  dateIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  dateText: {
    fontSize: 13,
    color: '#6B7280',
  },
  priorityRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  priorityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 6,
  },
  priorityText: {
    fontSize: 12,
    color: '#6B7280',
  },
  startedRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#F3F4F6',
  },
  startedIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  startedText: {
    fontSize: 12,
    color: '#9CA3AF',
  },
  actions: {
    marginTop: 8,
  },
  actionButton: {
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  viewButton: {
    backgroundColor: '#3B82F6',
  },
  viewButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 14,
  },

  // Bottom
  bottomSpacer: {
    height: 100,
  },
  scanButton: {
    position: 'absolute',
    bottom: 24,
    left: 16,
    right: 16,
    backgroundColor: '#3B82F6',
    paddingVertical: 16,
    borderRadius: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#3B82F6',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  scanButtonIcon: {
    fontSize: 18,
    marginRight: 10,
  },
  scanButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
});
