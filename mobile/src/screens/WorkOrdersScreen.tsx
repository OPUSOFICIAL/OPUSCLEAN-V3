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
    return new Date(wo.dueDate || wo.scheduledDate || wo.createdAt);
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
          Prazo: {format(new Date(item.dueDate || item.scheduledDate || item.createdAt), "dd/MM/yyyy", { locale: ptBR })}
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
      {/* Header - Azul escuro como na web */}
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
              {/* Botao de modulo Clean como na web */}
              <View style={styles.moduleButton}>
                <Text style={styles.moduleIcon}>📋</Text>
                <Text style={styles.moduleText}>Clean</Text>
                <Text style={styles.moduleRefresh}>🔄</Text>
              </View>
              <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
                <Text style={styles.logoutIcon}>→</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      </View>

      <ScrollView 
        style={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={handleRefresh} colors={['#4F46E5']} />}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Em Execucao Card - Destaque */}
        <View style={[
          styles.inProgressSection,
          inProgressOrders.length > 0 ? styles.inProgressActive : styles.inProgressEmpty
        ]}>
          <View style={styles.inProgressSectionHeader}>
            <Text style={styles.inProgressSectionIcon}>⚡</Text>
            <Text style={styles.inProgressSectionTitle}>Minhas Execucoes</Text>
            <View style={styles.inProgressSectionBadge}>
              <Text style={styles.inProgressSectionBadgeText}>{inProgressOrders.length}</Text>
            </View>
          </View>

          {inProgressOrders.length === 0 ? (
            <View style={styles.inProgressEmptyContent}>
              <View style={styles.playIconContainer}>
                <Text style={styles.playIcon}>▶</Text>
              </View>
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
            <Text style={styles.filterIcon}>⏷</Text>
            <Text style={styles.filterTitle}>Filtrar por Data</Text>
          </View>
          <View style={styles.filterButtons}>
            {[
              { key: 'hoje', label: 'Hoje', icon: '📅' },
              { key: 'ontem', label: 'Ontem', icon: '🕐' },
              { key: 'semana', label: 'Esta Semana', icon: '📅' },
              { key: 'todos', label: 'Todas', icon: '📅' },
            ].map(({ key, label, icon }) => (
              <TouchableOpacity
                key={key}
                style={[
                  styles.filterButton,
                  dateFilter === key && styles.filterButtonActive
                ]}
                onPress={() => setDateFilter(key as DateFilter)}
              >
                <Text style={[
                  styles.filterButtonIcon,
                  dateFilter === key && styles.filterButtonIconActive
                ]}>
                  {icon}
                </Text>
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

        {/* Stats Cards - Com icones em circulos como na web */}
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <View style={[styles.statIconCircle, { backgroundColor: '#FEE2E2' }]}>
              <Text style={styles.statIconText}>⚠️</Text>
            </View>
            <Text style={styles.statValue}>{statusCounts.available}</Text>
            <Text style={styles.statLabel}>Disponiveis</Text>
          </View>
          <View style={styles.statCard}>
            <View style={[styles.statIconCircle, { backgroundColor: '#DBEAFE' }]}>
              <Text style={styles.statIconText}>📋</Text>
            </View>
            <Text style={styles.statValue}>{statusCounts.pending}</Text>
            <Text style={styles.statLabel}>Pendentes</Text>
          </View>
        </View>
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <View style={[styles.statIconCircle, { backgroundColor: '#FEF3C7' }]}>
              <Text style={styles.statIconText}>⏱️</Text>
            </View>
            <Text style={styles.statValue}>{statusCounts.paused}</Text>
            <Text style={styles.statLabel}>Pausadas</Text>
          </View>
          <View style={styles.statCard}>
            <View style={[styles.statIconCircle, { backgroundColor: '#D1FAE5' }]}>
              <Text style={styles.statIconText}>✓</Text>
            </View>
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
    color: '#fff',
  },
  userRole: {
    fontSize: 13,
    color: 'rgba(255,255,255,0.8)',
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
    backgroundColor: '#fff',
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
    color: '#0D9488',
  },
  moduleRefresh: {
    fontSize: 12,
    color: '#0D9488',
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
    width: 36,
    height: 36,
    borderRadius: 8,
    backgroundColor: 'rgba(255,255,255,0.15)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoutIcon: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
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
    backgroundColor: '#94A3B8',
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
  playIconContainer: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  playIcon: {
    fontSize: 28,
    color: 'rgba(255,255,255,0.9)',
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
    color: '#6B7280',
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
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    paddingHorizontal: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    backgroundColor: '#fff',
    gap: 6,
  },
  filterButtonActive: {
    backgroundColor: '#4F46E5',
    borderColor: '#4F46E5',
  },
  filterButtonIcon: {
    fontSize: 14,
  },
  filterButtonIconActive: {
    opacity: 1,
  },
  filterButtonText: {
    fontSize: 13,
    fontWeight: '500',
    color: '#374151',
  },
  filterButtonTextActive: {
    color: '#fff',
  },

  // Stats Grid - Circulos coloridos como na web
  statsGrid: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  statIconCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  statIconText: {
    fontSize: 20,
  },
  statValue: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1E293B',
    marginBottom: 2,
  },
  statLabel: {
    fontSize: 12,
    color: '#64748B',
    fontWeight: '500',
  },

  // Sections
  section: {
    marginTop: 8,
    marginBottom: 16,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    paddingHorizontal: 4,
  },
  sectionIcon: {
    fontSize: 18,
    marginRight: 8,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1E293B',
    flex: 1,
  },
  sectionBadge: {
    backgroundColor: '#E2E8F0',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 10,
  },
  sectionBadgeText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#475569',
  },
  emptySection: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  emptySectionText: {
    fontSize: 14,
    color: '#94A3B8',
  },
  moreText: {
    textAlign: 'center',
    color: '#4F46E5',
    marginTop: 8,
    fontWeight: '500',
  },

  // Cards
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
    borderWidth: 1,
    borderColor: '#F1F5F9',
  },
  cardModified: {
    borderColor: '#FCD34D',
    borderWidth: 2,
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
    gap: 8,
  },
  orderNumberBadge: {
    backgroundColor: '#EEF2FF',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  orderNumberText: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#4F46E5',
  },
  offlineBadge: {
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
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
    fontSize: 11,
    fontWeight: '600',
  },
  cardTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: '#1E293B',
    marginBottom: 10,
    lineHeight: 20,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  locationIcon: {
    fontSize: 14,
    marginRight: 6,
    opacity: 0.8,
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
    marginRight: 6,
    opacity: 0.8,
  },
  dateText: {
    fontSize: 13,
    color: '#64748B',
  },
  priorityRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  priorityDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 6,
  },
  priorityText: {
    fontSize: 12,
    color: '#64748B',
    fontWeight: '500',
  },
  startedRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#F1F5F9',
  },
  startedIcon: {
    fontSize: 12,
    marginRight: 6,
  },
  startedText: {
    fontSize: 12,
    color: '#10B981',
    fontWeight: '500',
  },
  actions: {
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#F1F5F9',
  },
  actionButton: {
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
  },
  viewButton: {
    backgroundColor: '#EEF2FF',
  },
  viewButtonText: {
    color: '#4F46E5',
    fontWeight: '600',
    fontSize: 14,
  },

  // Bottom
  bottomSpacer: {
    height: 80,
  },
  scanButton: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
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
    elevation: 4,
  },
  scanButtonIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  scanButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
