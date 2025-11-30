import { useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  ScrollView,
  Dimensions,
} from 'react-native';
import { format, isToday } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { LinearGradient } from 'expo-linear-gradient';
import { WorkOrder, SyncStatus, User } from '../types';

const { width } = Dimensions.get('window');

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

  // Helper: verificar se O.S. está atribuída ao usuário
  const isAssignedToMe = (wo: WorkOrder) => {
    if (wo.assignedUserId === user.id) return true;
    if (wo.assignedUserIds && wo.assignedUserIds.includes(user.id)) return true;
    return false;
  };

  // Helper: verificar se O.S. NÃO está atribuída a ninguém
  const isNotAssigned = (wo: WorkOrder) => {
    return !wo.assignedUserId && (!wo.assignedUserIds || wo.assignedUserIds.length === 0);
  };

  // O.S. Disponíveis (não atribuídas, abertas)
  const allAvailableOrders = useMemo(() => {
    return workOrders
      .filter(wo => isNotAssigned(wo) && wo.status === 'open')
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
        const isActive = wo.status !== 'completed' && wo.status !== 'cancelled';
        return isAssignedToMe(wo) && isActive;
      })
      .sort((a, b) => {
        const statusOrder = { 'in_progress': 0, 'paused': 1, 'open': 2 };
        const aOrder = statusOrder[a.status as keyof typeof statusOrder] ?? 3;
        const bOrder = statusOrder[b.status as keyof typeof statusOrder] ?? 3;
        if (aOrder !== bOrder) return aOrder - bOrder;
        return b.workOrderNumber - a.workOrderNumber;
      });
  }, [workOrders, user.id]);

  // Minhas em Execução
  const myInProgressOrders = useMemo(() => {
    return workOrders.filter(wo => 
      isAssignedToMe(wo) && wo.status === 'in_progress'
    );
  }, [workOrders, user.id]);

  // Minhas Pausadas
  const myPausedOrders = useMemo(() => {
    return workOrders.filter(wo => 
      isAssignedToMe(wo) && wo.status === 'paused'
    );
  }, [workOrders, user.id]);

  // Minhas Concluídas (do mês atual)
  const myCompletedOrders = useMemo(() => {
    const today = new Date();
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    return workOrders.filter(wo => {
      if (!isAssignedToMe(wo)) return false;
      if (wo.status !== 'completed') return false;
      if (!wo.completedAt) return false;
      const completedDate = new Date(wo.completedAt);
      return completedDate >= firstDayOfMonth;
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

  const renderWorkOrderCard = (item: WorkOrder) => {
    const isAvailable = activeFilter === 'pendentes_dia';
    const cardColors = isAvailable 
      ? { bg: '#FFF7ED', border: '#FDBA74', badge: '#EA580C', badgeBg: '#FED7AA', button: '#EA580C' }
      : { bg: '#EFF6FF', border: '#93C5FD', badge: '#2563EB', badgeBg: '#DBEAFE', button: '#2563EB' };

    return (
      <View 
        key={item.id} 
        style={[styles.workOrderCard, { backgroundColor: cardColors.bg, borderColor: cardColors.border }]}
      >
        <View style={styles.cardHeader}>
          <View style={styles.cardHeaderLeft}>
            <View style={[styles.osBadge, { backgroundColor: cardColors.badge }]}>
              <Text style={styles.osBadgeText}>OS #{item.workOrderNumber}</Text>
            </View>
          </View>
          <View style={styles.cardHeaderRight}>
            <View style={[styles.priorityDot, { backgroundColor: getPriorityColor(item.priority) }]} />
            <View style={[styles.statusBadge, { backgroundColor: cardColors.badgeBg, borderColor: cardColors.border }]}>
              <Text style={[styles.statusBadgeText, { color: cardColors.badge }]}>
                {isAvailable ? 'Disponivel' : getStatusLabel(item.status)}
              </Text>
            </View>
          </View>
        </View>

        <Text style={[styles.cardTitle, { color: isAvailable ? '#9A3412' : '#1E3A8A' }]}>
          {item.title}
        </Text>

        <View style={styles.locationRow}>
          <Text style={styles.locationIcon}>📍</Text>
          <Text style={[styles.locationText, { color: isAvailable ? '#C2410C' : '#1D4ED8' }]}>
            {item.siteName} - {item.zoneName}
          </Text>
        </View>

        <Text style={[styles.cardDescription, { color: isAvailable ? '#9A3412' : '#1E40AF' }]}>
          {item.description}
        </Text>

        <View style={styles.cardFooter}>
          <View style={styles.dueDateRow}>
            <Text style={styles.dueDateIcon}>⏰</Text>
            <Text style={[styles.dueDateText, { color: isAvailable ? '#C2410C' : '#1D4ED8' }]}>
              Prazo: {format(new Date(item.dueDate || item.scheduledDate || item.createdAt), "dd/MM/yyyy", { locale: ptBR })}
            </Text>
          </View>
          <Text style={[styles.typeText, { color: isAvailable ? '#C2410C' : '#1D4ED8' }]}>
            Programada
          </Text>
        </View>

        <TouchableOpacity
          style={[styles.detailsButton, { backgroundColor: cardColors.button }]}
          onPress={() => onViewOrder(item)}
        >
          <Text style={styles.detailsButtonText}>Ver Detalhes</Text>
        </TouchableOpacity>
      </View>
    );
  };

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <View style={styles.emptyIcon}>
        <Text style={styles.emptyIconText}>✓</Text>
      </View>
      <Text style={styles.emptyTitle}>
        {activeFilter === 'pendentes_dia' 
          ? 'Nenhuma O.S. disponivel hoje!'
          : 'Nenhuma O.S. atribuida a voce!'}
      </Text>
      <Text style={styles.emptySubtitle}>
        {activeFilter === 'pendentes_dia'
          ? 'Nao ha ordens de servico disponiveis para hoje.'
          : 'Voce nao tem ordens de servico atribuidas no momento.'}
      </Text>
    </View>
  );

  return (
    <View style={styles.container}>
      {/* Header com Gradiente */}
      <LinearGradient
        colors={['#1E3A5F', '#0D9488']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.header}
      >
        <View style={styles.headerContent}>
          <View style={styles.headerLeft}>
            <Text style={styles.userName}>{user.name}</Text>
            <Text style={styles.userRole}>Colaborador</Text>
          </View>
          <View style={styles.headerRight}>
            <TouchableOpacity style={styles.moduleButton}>
              <Text style={styles.moduleIcon}>📋</Text>
              <Text style={styles.moduleText}>Clean</Text>
              <TouchableOpacity style={styles.syncButton} onPress={onForceSync}>
                <Text style={styles.syncIcon}>🔄</Text>
              </TouchableOpacity>
            </TouchableOpacity>
            <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
              <Text style={styles.logoutIcon}>➡️</Text>
            </TouchableOpacity>
          </View>
        </View>
      </LinearGradient>

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
        {/* Card Minhas Execuções */}
        <LinearGradient
          colors={['#3B82F6', '#06B6D4']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.executionsCard}
        >
          <View style={styles.executionsHeader}>
            <Text style={styles.executionsIcon}>⚡</Text>
            <Text style={styles.executionsTitle}>Minhas Execucoes</Text>
            <View style={styles.executionsBadge}>
              <Text style={styles.executionsBadgeText}>{myInProgressOrders.length}</Text>
            </View>
          </View>

          {myInProgressOrders.length === 0 ? (
            <View style={styles.executionsEmpty}>
              <View style={styles.executionsEmptyIcon}>
                <Text style={styles.executionsEmptyIconText}>▶</Text>
              </View>
              <Text style={styles.executionsEmptyTitle}>Nenhuma O.S em execucao</Text>
              <Text style={styles.executionsEmptySubtitle}>Escaneie um QR Code para iniciar uma tarefa</Text>
            </View>
          ) : (
            myInProgressOrders.map((wo) => (
              <TouchableOpacity 
                key={wo.id} 
                style={styles.executionItem}
                onPress={() => onViewOrder(wo)}
              >
                <View style={styles.executionItemLeft}>
                  <Text style={styles.executionItemBadge}>OS #{wo.workOrderNumber}</Text>
                  <Text style={styles.executionItemTitle} numberOfLines={1}>{wo.title}</Text>
                  <View style={styles.executionItemLocation}>
                    <Text style={styles.executionItemLocationIcon}>📍</Text>
                    <Text style={styles.executionItemLocationText}>{wo.siteName} - {wo.zoneName}</Text>
                  </View>
                </View>
                <Text style={styles.executionItemArrow}>▶</Text>
              </TouchableOpacity>
            ))
          )}
        </LinearGradient>

        {/* Filtros */}
        <View style={styles.filtersContainer}>
          <TouchableOpacity
            style={[
              styles.filterButton,
              activeFilter === 'pendentes_dia' && styles.filterButtonActive
            ]}
            onPress={() => setActiveFilter('pendentes_dia')}
          >
            <Text style={styles.filterIcon}>📅</Text>
            <Text style={[
              styles.filterText,
              activeFilter === 'pendentes_dia' && styles.filterTextActive
            ]}>
              Pendentes Hoje
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.filterButton,
              activeFilter === 'minhas_os' && styles.filterButtonActive
            ]}
            onPress={() => setActiveFilter('minhas_os')}
          >
            <Text style={styles.filterIcon}>👤</Text>
            <Text style={[
              styles.filterText,
              activeFilter === 'minhas_os' && styles.filterTextActive
            ]}>
              Minhas O.S.
            </Text>
          </TouchableOpacity>
        </View>

        {/* Cards de Estatísticas */}
        <View style={styles.statsGrid}>
          <View style={styles.statsRow}>
            <TouchableOpacity 
              style={styles.statCard}
              onPress={() => setActiveFilter('pendentes_dia')}
            >
              <View style={[styles.statIcon, { backgroundColor: '#FFF7ED' }]}>
                <Text style={styles.statIconText}>⚠️</Text>
              </View>
              <Text style={styles.statNumber}>{pendentesHoje.length}</Text>
              <Text style={styles.statLabel}>Disponiveis</Text>
            </TouchableOpacity>

            <TouchableOpacity 
              style={styles.statCard}
              onPress={() => setActiveFilter('minhas_os')}
            >
              <View style={[styles.statIcon, { backgroundColor: '#EFF6FF' }]}>
                <Text style={styles.statIconText}>📋</Text>
              </View>
              <Text style={styles.statNumber}>{minhasOS.length}</Text>
              <Text style={styles.statLabel}>Pendentes</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.statsRow}>
            <View style={styles.statCard}>
              <View style={[styles.statIcon, { backgroundColor: '#FFFBEB' }]}>
                <Text style={styles.statIconText}>⏸️</Text>
              </View>
              <Text style={styles.statNumber}>{myPausedOrders.length}</Text>
              <Text style={styles.statLabel}>Pausadas</Text>
            </View>

            <View style={styles.statCard}>
              <View style={[styles.statIcon, { backgroundColor: '#ECFDF5' }]}>
                <Text style={styles.statIconText}>✅</Text>
              </View>
              <Text style={styles.statNumber}>{myCompletedOrders.length}</Text>
              <Text style={styles.statLabel}>Concluidas</Text>
            </View>
          </View>
        </View>

        {/* Botão QR Code */}
        <LinearGradient
          colors={['#4F46E5', '#6366F1']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={styles.qrButton}
        >
          <TouchableOpacity style={styles.qrButtonInner} onPress={onOpenScanner}>
            <View style={styles.qrIconContainer}>
              <Text style={styles.qrIcon}>📷</Text>
            </View>
            <View style={styles.qrTextContainer}>
              <Text style={styles.qrTitle}>Escanear QR Code</Text>
              <Text style={styles.qrSubtitle}>Iniciar nova ordem de servico</Text>
            </View>
          </TouchableOpacity>
        </LinearGradient>

        {/* Título da Lista */}
        <View style={styles.listHeader}>
          <Text style={styles.listHeaderIcon}>
            {activeFilter === 'pendentes_dia' ? '⚠️' : '👤'}
          </Text>
          <Text style={[
            styles.listHeaderTitle,
            { color: activeFilter === 'pendentes_dia' ? '#9A3412' : '#1E3A8A' }
          ]}>
            {activeFilter === 'pendentes_dia' 
              ? `OS Disponiveis Hoje (${currentList.length})`
              : `Minhas O.S. (${currentList.length})`
            }
          </Text>
        </View>

        {/* Lista de O.S. */}
        {currentList.length === 0 ? (
          renderEmptyState()
        ) : (
          currentList.map(order => renderWorkOrderCard(order))
        )}

        {/* Spacer */}
        <View style={styles.bottomSpacer} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F1F5F9',
  },
  header: {
    paddingTop: 50,
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerLeft: {},
  userName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  userRole: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.8)',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  moduleButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
    gap: 4,
  },
  moduleIcon: {
    fontSize: 14,
  },
  moduleText: {
    color: '#FFFFFF',
    fontWeight: '600',
    fontSize: 14,
  },
  syncButton: {
    marginLeft: 4,
  },
  syncIcon: {
    fontSize: 12,
  },
  logoutButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoutIcon: {
    fontSize: 16,
  },
  content: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    gap: 16,
  },
  executionsCard: {
    borderRadius: 16,
    padding: 16,
  },
  executionsHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  executionsIcon: {
    fontSize: 20,
    marginRight: 8,
  },
  executionsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FFFFFF',
    flex: 1,
  },
  executionsBadge: {
    backgroundColor: 'rgba(255,255,255,0.3)',
    width: 28,
    height: 28,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
  },
  executionsBadgeText: {
    color: '#FFFFFF',
    fontWeight: 'bold',
    fontSize: 14,
  },
  executionsEmpty: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  executionsEmptyIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  executionsEmptyIconText: {
    fontSize: 24,
    color: 'rgba(255,255,255,0.7)',
  },
  executionsEmptyTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  executionsEmptySubtitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.7)',
    textAlign: 'center',
  },
  executionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 12,
    padding: 12,
    marginTop: 8,
  },
  executionItemLeft: {
    flex: 1,
  },
  executionItemBadge: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#FFFFFF',
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 4,
    alignSelf: 'flex-start',
    marginBottom: 4,
  },
  executionItemTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  executionItemLocation: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  executionItemLocationIcon: {
    fontSize: 10,
    marginRight: 4,
  },
  executionItemLocationText: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.8)',
  },
  executionItemArrow: {
    fontSize: 18,
    color: 'rgba(255,255,255,0.7)',
  },
  filtersContainer: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 4,
    gap: 4,
  },
  filterButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    borderRadius: 8,
    gap: 8,
  },
  filterButtonActive: {
    backgroundColor: '#3B82F6',
  },
  filterIcon: {
    fontSize: 16,
  },
  filterText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#64748B',
  },
  filterTextActive: {
    color: '#FFFFFF',
  },
  statsGrid: {
    gap: 12,
  },
  statsRow: {
    flexDirection: 'row',
    gap: 12,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
  },
  statIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  statIconText: {
    fontSize: 18,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1E293B',
  },
  statLabel: {
    fontSize: 12,
    color: '#64748B',
  },
  qrButton: {
    borderRadius: 12,
    overflow: 'hidden',
  },
  qrButtonInner: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    gap: 12,
  },
  qrIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  qrIcon: {
    fontSize: 24,
  },
  qrTextContainer: {
    flex: 1,
  },
  qrTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  qrSubtitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.8)',
  },
  listHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginTop: 8,
  },
  listHeaderIcon: {
    fontSize: 20,
  },
  listHeaderTitle: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  workOrderCard: {
    borderRadius: 12,
    borderWidth: 1,
    padding: 16,
    marginTop: 8,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  cardHeaderLeft: {},
  cardHeaderRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  osBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  osBadgeText: {
    color: '#FFFFFF',
    fontWeight: 'bold',
    fontSize: 12,
  },
  priorityDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
    borderWidth: 1,
  },
  statusBadgeText: {
    fontSize: 11,
    fontWeight: '600',
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 6,
  },
  locationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  locationIcon: {
    fontSize: 12,
    marginRight: 4,
  },
  locationText: {
    fontSize: 13,
  },
  cardDescription: {
    fontSize: 14,
    marginBottom: 12,
    lineHeight: 20,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  dueDateRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dueDateIcon: {
    fontSize: 12,
    marginRight: 4,
  },
  dueDateText: {
    fontSize: 13,
  },
  typeText: {
    fontSize: 12,
    fontWeight: '500',
  },
  detailsButton: {
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  detailsButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
  emptyState: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 32,
    alignItems: 'center',
    marginTop: 8,
  },
  emptyIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#DCFCE7',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  emptyIconText: {
    fontSize: 28,
    color: '#22C55E',
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1E293B',
    textAlign: 'center',
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#64748B',
    textAlign: 'center',
  },
  bottomSpacer: {
    height: 20,
  },
});
