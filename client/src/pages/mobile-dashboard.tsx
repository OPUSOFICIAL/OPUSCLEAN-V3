import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { getAuthState, canOnlyViewOwnWorkOrders } from "@/lib/auth";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { QrCode, ClipboardList, Clock, CheckCircle, AlertCircle, Camera, User, LogOut, MapPin, Calendar, Filter, Play, Zap } from "lucide-react";
import { useLocation } from "wouter";
import { useToast } from "@/hooks/use-toast";
import { logout } from "@/lib/auth";
import { queryClient } from "@/lib/queryClient";
import { useModule } from "@/contexts/ModuleContext";
import { MobileHeader } from "@/components/mobile-header";
import PullToRefresh from "react-simple-pull-to-refresh";
import { Capacitor } from "@capacitor/core";

interface WorkOrder {
  id: string;
  number: number;
  title: string;
  description: string;
  status: string;
  priority: string;
  type: string;
  assignedUserId: string | null;
  siteName: string;
  zoneName: string;
  dueDate: string;
  createdAt: string;
  startedAt?: string;
  completedAt?: string;
}

export default function MobileDashboard() {
  const { currentModule } = useModule();
  const [, setLocation] = useLocation();
  const { toast } = useToast();
  const { user } = getAuthState();
  const [dateFilter, setDateFilter] = useState<'hoje' | 'ontem' | 'semana' | 'todos'>('todos');
  const [isRefreshing, setIsRefreshing] = useState(false);
  
  // Get customerId - some users may not have customerId, use assignedClientId as fallback
  const effectiveCustomerId = user ? ((user as any).customerId || (user as any).assignedClientId) : null;
  
  // Get current location context from localStorage (set by QR scanner)
  const currentLocation = JSON.parse(localStorage.getItem('current-location') || 'null');
  
  // Helper function to fetch work orders with specific params
  const fetchWorkOrders = async (assignedToValue: string) => {
    const params = new URLSearchParams();
    
    if (currentModule) {
      params.append('module', currentModule);
    }
    if (currentLocation?.zoneId) {
      params.append('zoneId', currentLocation.zoneId);
    }
    params.append('assignedTo', assignedToValue);
    
    let url = `/api/customers/${effectiveCustomerId}/work-orders?${params.toString()}`;
    
    if (Capacitor.isNativePlatform()) {
      const baseUrl = import.meta.env.VITE_API_BASE_URL || 'https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev';
      url = baseUrl + url;
    }
    
    const token = localStorage.getItem("opus_clean_token");
    const headers: Record<string, string> = {};
    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }
    
    const response = await fetch(url, {
      headers,
      credentials: "include"
    });
    
    if (!response.ok) throw new Error('Failed to fetch work orders');
    return response.json();
  };
  
  // Query 1: Minhas (atribuídas ao usuário)
  const { data: myResponse, isLoading: isLoadingMy, refetch: refetchMy } = useQuery({
    queryKey: ["/api/customers", effectiveCustomerId, "work-orders-my", { module: currentModule, userId: user?.id, zoneId: currentLocation?.zoneId }],
    enabled: !!effectiveCustomerId && !!user,
    queryFn: () => fetchWorkOrders(user!.id),
    staleTime: 30000
  });
  
  // Query 2: Disponíveis (não atribuídas)
  const { data: availableResponse, isLoading: isLoadingAvailable, refetch: refetchAvailable } = useQuery({
    queryKey: ["/api/customers", effectiveCustomerId, "work-orders-available", { module: currentModule, zoneId: currentLocation?.zoneId }],
    enabled: !!effectiveCustomerId && !!user,
    queryFn: () => fetchWorkOrders('nao_atribuido'),
    staleTime: 30000
  });
  
  // AUTO-REFETCH quando location muda (após escanear QR code)
  useEffect(() => {
    if (currentLocation?.zoneId) {
      console.log('[MOBILE DASHBOARD] 🔍 Zona alterada para:', currentLocation.zoneId, '- Refetchando queries...');
      refetchMy();
      refetchAvailable();
    }
  }, [currentLocation?.zoneId, refetchMy, refetchAvailable]);
  
  const isLoading = isLoadingAvailable || isLoadingMy;
  
  // Dados das queries separados
  const myData = (myResponse?.data || []) as WorkOrder[];
  const availableData = (availableResponse?.data || []) as WorkOrder[];
  
  // Contar manualmente de myData pq precisa filtrar por status específico
  const myPendingCount = myData.filter((wo: WorkOrder) => wo.status === 'aberta' || wo.status === 'vencida').length;
  const myPausedCount = myData.filter((wo: WorkOrder) => wo.status === 'pausada').length;
  const myCompletedCount = myData.filter((wo: WorkOrder) => wo.status === 'concluida').length;
  
  // Status counts: Disponíveis = abertas não atribuídas, Pendentes = minhas abertas, Pausadas = minhas pausadas, Concluídas = minhas concluídas
  const statusCounts = {
    abertas: availableResponse?.statusCounts?.abertas || 0,  // TODAS as abertas sem atribuição (para card de Disponíveis)
    pendentes: myPendingCount,  // Minhas abertas/vencidas (para card de Pendentes)
    vencidas: 0,
    pausadas: myPausedCount,
    concluidas: myCompletedCount
  };
  
  // Combinar dados: disponíveis + minhas para exibição nos cards
  const allWorkOrders = [
    ...availableData,
    ...myData
  ];
  
  const workOrders = allWorkOrders;
  
  // Verificar se o usuário é colaborador
  if (!user || !canOnlyViewOwnWorkOrders(user)) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <p className="text-slate-600">Redirecionando...</p>
        </div>
      </div>
    );
  }

  // If no customer assigned, show error
  if (!effectiveCustomerId) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
        <Card className="max-w-md">
          <CardContent className="p-6 text-center">
            <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
            <h2 className="text-xl font-bold text-slate-900 mb-2">Acesso Negado</h2>
            <p className="text-slate-600">
              Seu usuário não está associado a nenhum cliente. Entre em contato com o administrador.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Função para filtrar OS por data
  const filterWorkOrdersByDate = (orders: WorkOrder[]) => {
    const today = new Date();
    const yesterday = new Date();
    yesterday.setDate(today.getDate() - 1);
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(today.getDate() - 7);

    switch (dateFilter) {
      case 'hoje':
        return orders.filter(wo => {
          const orderDate = new Date(wo.dueDate || wo.createdAt);
          return orderDate.toDateString() === today.toDateString();
        });
      case 'ontem':
        return orders.filter(wo => {
          const orderDate = new Date(wo.dueDate || wo.createdAt);
          return orderDate.toDateString() === yesterday.toDateString();
        });
      case 'semana':
        return orders.filter(wo => {
          const orderDate = new Date(wo.dueDate || wo.createdAt);
          return orderDate >= oneWeekAgo && orderDate <= today;
        });
      case 'todos':
      default:
        return orders;
    }
  };

  const filteredWorkOrders = filterWorkOrdersByDate(workOrders);

  // Separar as OS em categorias
  const availableOrders = filteredWorkOrders.filter(wo => 
    !wo.assignedUserId && wo.status !== 'concluida' && wo.status !== 'cancelada' && wo.status !== 'pausada'
  );
  
  // 🔥 ATUALIZADO: Minhas em Execução - O.S que o colaborador trabalhou
  const myInProgressOrders = filteredWorkOrders.filter(wo => {
    const assignedIds = (wo as any).assignedUserIds || [];
    const isAssignedToMe = assignedIds.includes(user.id) || wo.assignedUserId === user.id;
    return isAssignedToMe && wo.status === 'em_execucao';
  });
  
  const myPendingOrders = filteredWorkOrders.filter(wo => {
    const assignedIds = (wo as any).assignedUserIds || [];
    const isAssignedToMe = assignedIds.includes(user.id) || wo.assignedUserId === user.id;
    return isAssignedToMe && 
      wo.status !== 'concluida' && 
      wo.status !== 'cancelada' && 
      wo.status !== 'pausada' && 
      wo.status !== 'em_execucao'; // Excluir as que já estão em execução
  });
  
  const myPausedOrders = filteredWorkOrders.filter(wo => 
    wo.status === 'pausada'
  );
  
  const myCompletedOrders = filteredWorkOrders.filter(wo => {
    const assignedIds = (wo as any).assignedUserIds || [];
    const isAssignedToMe = assignedIds.includes(user.id) || wo.assignedUserId === user.id;
    return isAssignedToMe && wo.status === 'concluida';
  });

  const handleRefresh = async () => {
    setIsRefreshing(true);
    // Invalidar ambas as queries
    await Promise.all([
      queryClient.invalidateQueries({ 
        queryKey: ["/api/customers", effectiveCustomerId, "work-orders-available"] 
      }),
      queryClient.invalidateQueries({ 
        queryKey: ["/api/customers", effectiveCustomerId, "work-orders-my"] 
      })
    ]);
    setTimeout(() => setIsRefreshing(false), 1000);
    toast({
      title: "Atualizado!",
      description: "Lista de ordens de serviço atualizada.",
    });
  };

  const handleLogout = async () => {
    try {
      await logout();
      setLocation("/login");
      toast({
        title: "Logout realizado",
        description: "Você foi desconectado com sucesso.",
      });
    } catch (error) {
      toast({
        title: "Erro no logout",
        description: "Houve um problema ao fazer logout.",
        variant: "destructive",
      });
    }
  };

  const handleQrScanner = () => {
    setLocation("/mobile/qr-scanner");
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'aberta': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'em_andamento': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'concluida': return 'bg-green-100 text-green-800 border-green-200';
      case 'pausada': return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'cancelada': return 'bg-red-100 text-red-800 border-red-200';
      case 'vencida': return 'bg-red-100 text-red-800 border-red-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority.toLowerCase()) {
      case 'baixa': return 'bg-green-500';
      case 'media': return 'bg-yellow-500';
      case 'alta': return 'bg-orange-500';
      case 'critica': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  // Formata DATE (scheduledDate, dueDate) - apenas data, sem hora
  const formatDate = (dateString: string) => {
    if (!dateString) return '-';
    const match = dateString.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (match) {
      const [, year, month, day] = match;
      return `${day}/${month}/${year}`;
    }
    return dateString;
  };

  // Formata TIMESTAMP (createdAt, completedAt, startedAt) - data e hora
  const formatDateTime = (dateString: string) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };


  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="w-16 h-16 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-600">Carregando suas ordens de serviço...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 overflow-x-hidden">
      {/* Header Mobile com indicador de módulo */}
      <MobileHeader
        title={user.name}
        subtitle="Colaborador"
        actions={
          <Button 
            variant="ghost" 
            size="sm"
            onClick={handleLogout}
            className="text-white hover:bg-white/20"
          >
            <LogOut className="w-5 h-5" />
          </Button>
        }
      />

      <PullToRefresh onRefresh={handleRefresh}>
        <div className="p-4 space-y-6">
        {/* 🔥 CARD PERMANENTE: Minhas O.S em Execução - SEMPRE VISÍVEL */}
        <Card className={`border-0 shadow-2xl ${
          myInProgressOrders.length > 0 
            ? 'bg-gradient-to-r from-green-500 to-emerald-600 text-white' 
            : 'bg-gradient-to-r from-slate-400 to-slate-500 text-white'
        }`}>
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-white font-bold flex items-center gap-2">
                <Zap className="w-6 h-6" />
                {myInProgressOrders.length > 0 ? '🔥 Em Execução Agora' : 'Minhas Execuções'}
              </CardTitle>
              <Badge className="bg-white/30 text-white border-white/50 font-bold px-3 py-1 text-base">
                {myInProgressOrders.length}
              </Badge>
            </div>
          </CardHeader>
          <CardContent>
            {myInProgressOrders.length === 0 ? (
              <div className="text-center py-6">
                <div className="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-3">
                  <Play className="w-8 h-8 text-white/80" />
                </div>
                <p className="text-white/90 font-medium mb-1">Nenhuma O.S em execução</p>
                <p className="text-white/70 text-sm">Escaneie um QR Code para iniciar uma tarefa</p>
              </div>
            ) : (
              <div className="space-y-3">
                <p className="text-white/90 text-sm font-medium mb-3">
                  Você iniciou {myInProgressOrders.length} {myInProgressOrders.length === 1 ? 'tarefa' : 'tarefas'}:
                </p>
                {myInProgressOrders.map((wo) => (
                  <div
                    key={wo.id}
                    onClick={() => setLocation(`/mobile/work-order-details/${wo.id}`)}
                    className="bg-white/20 backdrop-blur-md rounded-lg p-4 cursor-pointer hover:bg-white/30 transition-all active:scale-95 border border-white/30"
                    data-testid={`card-in-progress-${wo.id}`}
                  >
                    <div className="flex items-start justify-between gap-3 mb-2">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <Badge className="bg-white/40 text-white border-white/60 font-bold text-xs">
                            OS #{wo.number}
                          </Badge>
                          <div className={`w-2 h-2 rounded-full ${getPriorityColor(wo.priority)} animate-pulse`}></div>
                        </div>
                        <h3 className="text-white font-bold text-base break-words">{wo.title}</h3>
                        <div className="flex items-center space-x-2 text-sm text-white/90 mt-1">
                          <MapPin className="w-3 h-3" />
                          <span>{wo.siteName} - {wo.zoneName}</span>
                        </div>
                      </div>
                      <Play className="w-6 h-6 text-white/80 flex-shrink-0" />
                    </div>
                    <div className="flex items-center justify-between text-xs text-white/90 mt-2">
                      <div className="flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        <span>Prazo: {formatDate(wo.dueDate)}</span>
                      </div>
                      <span className="capitalize bg-white/20 px-2 py-0.5 rounded">{wo.type.replace('_', ' ')}</span>
                    </div>
                    {wo.startedAt && (
                      <div className="flex items-center gap-1 text-xs text-white/80 mt-2 pt-2 border-t border-white/20">
                        <Clock className="w-3 h-3" />
                        <span>Iniciado: {formatDateTime(wo.startedAt)}</span>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Filtros de Data */}
        <Card className="bg-white/80 backdrop-blur-sm border-white/20">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-semibold text-slate-700 flex items-center gap-2">
              <Filter className="w-4 h-4" />
              Filtrar por Data
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-0">
            <div className="grid grid-cols-2 gap-2">
              <Button
                variant={dateFilter === 'hoje' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setDateFilter('hoje')}
                className={`text-xs ${dateFilter === 'hoje' 
                  ? 'bg-blue-600 text-white hover:bg-blue-700' 
                  : 'border-blue-200 text-blue-700 hover:bg-blue-50'
                }`}
                data-testid="filter-hoje"
              >
                <Calendar className="w-3 h-3 mr-1" />
                Hoje
              </Button>
              
              <Button
                variant={dateFilter === 'ontem' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setDateFilter('ontem')}
                className={`text-xs ${dateFilter === 'ontem' 
                  ? 'bg-blue-600 text-white hover:bg-blue-700' 
                  : 'border-blue-200 text-blue-700 hover:bg-blue-50'
                }`}
                data-testid="filter-ontem"
              >
                <Clock className="w-3 h-3 mr-1" />
                Ontem
              </Button>
              
              <Button
                variant={dateFilter === 'semana' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setDateFilter('semana')}
                className={`text-xs ${dateFilter === 'semana' 
                  ? 'bg-blue-600 text-white hover:bg-blue-700' 
                  : 'border-blue-200 text-blue-700 hover:bg-blue-50'
                }`}
                data-testid="filter-semana"
              >
                <Calendar className="w-3 h-3 mr-1" />
                Esta Semana
              </Button>
              
              <Button
                variant={dateFilter === 'todos' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setDateFilter('todos')}
                className={`text-xs ${dateFilter === 'todos' 
                  ? 'bg-blue-600 text-white hover:bg-blue-700' 
                  : 'border-blue-200 text-blue-700 hover:bg-blue-50'
                }`}
                data-testid="filter-todos"
              >
                <ClipboardList className="w-3 h-3 mr-1" />
                Todas
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Location Context */}
        {currentLocation && (
          <Card className="bg-blue-50 border-blue-200">
            <CardContent className="p-4">
              <div className="flex items-center space-x-3">
                <MapPin className="w-5 h-5 text-blue-600" />
                <div>
                  <p className="text-sm font-medium text-blue-900">Local Ativo</p>
                  <p className="text-xs text-blue-700">{currentLocation.zoneName}</p>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      localStorage.removeItem('current-location');
                      window.location.reload();
                    }}
                    className="text-xs text-blue-600 hover:text-blue-700 p-0 h-auto mt-1"
                  >
                    Ver todas as OS
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Stats Cards */}
        <div className="space-y-3">
          {/* Card Especial: Em Execução */}
          {myInProgressOrders.length > 0 && (
            <Card 
              className="bg-gradient-to-r from-green-500 to-emerald-600 text-white border-0 shadow-xl cursor-pointer hover:shadow-2xl transition-all active:scale-95"
              onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
              data-testid="card-em-execucao"
            >
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-14 h-14 bg-white/30 rounded-full flex items-center justify-center">
                      <Zap className="w-7 h-7 text-white" />
                    </div>
                    <div>
                      <p className="text-3xl font-bold">{myInProgressOrders.length}</p>
                      <p className="text-sm font-medium opacity-90">🔥 Em Execução</p>
                    </div>
                  </div>
                  <Play className="w-8 h-8 text-white/70" />
                </div>
              </CardContent>
            </Card>
          )}
          
          {/* Grid de Cards Normais */}
          <div className="grid grid-cols-2 gap-3">
            <Card 
              className="bg-white/80 backdrop-blur-sm border-white/20 cursor-pointer hover:shadow-lg transition-shadow active:scale-95"
              onClick={() => {
                document.getElementById('disponiveis-section')?.scrollIntoView({ 
                  behavior: 'smooth', 
                  block: 'start' 
                });
              }}
              data-testid="card-disponiveis"
            >
              <CardContent className="p-3">
                <div className="flex flex-col items-center justify-center space-y-1">
                  <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
                    <AlertCircle className="w-5 h-5 text-orange-600" />
                  </div>
                  <p className="text-xl font-bold text-slate-900">{statusCounts.abertas}</p>
                  <p className="text-xs text-slate-600 text-center">Disponíveis</p>
                </div>
              </CardContent>
            </Card>

            <Card 
              className="bg-white/80 backdrop-blur-sm border-white/20 cursor-pointer hover:shadow-lg transition-shadow active:scale-95"
              onClick={() => {
                document.getElementById('pendentes-section')?.scrollIntoView({ 
                  behavior: 'smooth', 
                  block: 'start' 
                });
              }}
              data-testid="card-pendentes"
            >
              <CardContent className="p-3">
                <div className="flex flex-col items-center justify-center space-y-1">
                  <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                    <ClipboardList className="w-5 h-5 text-blue-600" />
                  </div>
                  <p className="text-xl font-bold text-slate-900">{statusCounts.pendentes}</p>
                  <p className="text-xs text-slate-600 text-center">Pendentes</p>
                </div>
              </CardContent>
            </Card>

            <Card 
              className="bg-white/80 backdrop-blur-sm border-white/20 cursor-pointer hover:shadow-lg transition-shadow active:scale-95"
              onClick={() => {
                document.getElementById('pausadas-section')?.scrollIntoView({ 
                  behavior: 'smooth', 
                  block: 'start' 
                });
              }}
              data-testid="card-pausadas"
            >
              <CardContent className="p-3">
                <div className="flex flex-col items-center justify-center space-y-1">
                  <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
                    <Clock className="w-5 h-5 text-amber-600" />
                  </div>
                  <p className="text-xl font-bold text-slate-900">{statusCounts.pausadas}</p>
                  <p className="text-xs text-slate-600 text-center">Pausadas</p>
                </div>
              </CardContent>
            </Card>
            
            <Card 
              className="bg-white/80 backdrop-blur-sm border-white/20 cursor-pointer hover:shadow-lg transition-shadow active:scale-95"
              onClick={() => {
                document.getElementById('concluidas-section')?.scrollIntoView({ 
                  behavior: 'smooth', 
                  block: 'start' 
                });
              }}
              data-testid="card-concluidas"
            >
              <CardContent className="p-3">
                <div className="flex flex-col items-center justify-center space-y-1">
                  <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
                    <CheckCircle className="w-5 h-5 text-emerald-600" />
                  </div>
                  <p className="text-xl font-bold text-slate-900">{statusCounts.concluidas}</p>
                  <p className="text-xs text-slate-600 text-center">Concluídas</p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* QR Scanner Button */}
        <Card className="bg-gradient-to-r from-blue-600 to-indigo-700 text-white border-0 shadow-xl">
          <CardContent className="p-6">
            <Button 
              onClick={handleQrScanner}
              data-testid="button-qr-scanner"
              className="w-full bg-white/20 hover:bg-white/30 text-white border-white/30 h-16 text-lg font-semibold"
              size="lg"
            >
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-white/30 rounded-full flex items-center justify-center">
                  <QrCode className="w-6 h-6" />
                </div>
                <div className="text-left">
                  <div className="text-lg font-bold">Escanear QR Code</div>
                  <div className="text-sm opacity-90">Iniciar nova ordem de serviço</div>
                </div>
              </div>
            </Button>
          </CardContent>
        </Card>

        {/* Work Orders List - Minhas Pendentes */}
        <div className="space-y-4" id="pendentes-section">
          <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
            <ClipboardList className="w-6 h-6" />
            Minhas Pendentes
          </h2>

          {myPendingOrders.length === 0 ? (
            <Card className="bg-white/80 backdrop-blur-sm border-white/20">
              <CardContent className="p-6 text-center">
                <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-slate-900 mb-2">
                  Tudo em dia!
                </h3>
                <p className="text-slate-600">
                  Você não tem ordens de serviço pendentes no momento.
                </p>
              </CardContent>
            </Card>
          ) : (
            myPendingOrders.map((workOrder) => (
              <Card key={workOrder.id} className="bg-white/80 backdrop-blur-sm border-white/20 shadow-lg">
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="space-y-1 flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge variant="outline" className="bg-blue-600 text-white border-blue-700 font-bold">
                          OS #{workOrder.number}
                        </Badge>
                      </div>
                      <CardTitle className="text-lg break-words">{workOrder.title}</CardTitle>
                      <div className="flex items-center space-x-2 text-sm text-slate-600">
                        <MapPin className="w-4 h-4" />
                        <span>{workOrder.siteName} - {workOrder.zoneName}</span>
                      </div>
                    </div>
                    <div className="flex flex-col items-end space-y-2">
                      <div className={`w-3 h-3 rounded-full ${getPriorityColor(workOrder.priority)}`}></div>
                      <Badge variant="outline" className={getStatusColor(workOrder.status)}>
                        {workOrder.status.replace('_', ' ')}
                      </Badge>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="pt-0">
                  <p className="text-slate-700 mb-3">{workOrder.description}</p>
                  <div className="flex items-center justify-between text-sm text-slate-500">
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4" />
                      <span>Prazo: {formatDate(workOrder.dueDate)}</span>
                    </div>
                    <span className="font-medium capitalize">{workOrder.type.replace('_', ' ')}</span>
                  </div>
                  <Button 
                    className="w-full mt-4" 
                    data-testid={`button-view-order-${workOrder.id}`}
                    onClick={() => setLocation(`/mobile/work-order-details/${workOrder.id}`)}
                  >
                    Ver Detalhes
                  </Button>
                </CardContent>
              </Card>
            ))
          )}
        </div>

        {/* Work Orders List - Disponíveis */}
        {availableOrders.length > 0 && (
          <div className="space-y-4" id="disponiveis-section">
            <h2 className="text-xl font-bold text-orange-900 flex items-center gap-2">
              <AlertCircle className="w-6 h-6" />
              OS Disponíveis ({availableOrders.length})
            </h2>

            {availableOrders.map((workOrder) => (
              <Card key={workOrder.id} className="bg-orange-50/80 backdrop-blur-sm border-orange-200 shadow-lg">
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="space-y-1 flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge variant="outline" className="bg-orange-600 text-white border-orange-700 font-bold">
                          OS #{workOrder.number}
                        </Badge>
                      </div>
                      <CardTitle className="text-lg text-orange-900 break-words">{workOrder.title}</CardTitle>
                      <div className="flex items-center space-x-2 text-sm text-orange-700">
                        <MapPin className="w-4 h-4" />
                        <span>{workOrder.siteName} - {workOrder.zoneName}</span>
                      </div>
                    </div>
                    <div className="flex flex-col items-end space-y-2">
                      <div className={`w-3 h-3 rounded-full ${getPriorityColor(workOrder.priority)}`}></div>
                      <Badge variant="outline" className="bg-orange-100 text-orange-800 border-orange-200">
                        Disponível
                      </Badge>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="pt-0">
                  <p className="text-orange-800 mb-3">{workOrder.description}</p>
                  <div className="flex items-center justify-between text-sm text-orange-600 mb-3">
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4" />
                      <span>Prazo: {formatDate(workOrder.dueDate)}</span>
                    </div>
                    <span className="font-medium capitalize">{workOrder.type.replace('_', ' ')}</span>
                  </div>
                  <Button 
                    className="w-full bg-orange-600 hover:bg-orange-700" 
                    data-testid={`button-view-order-${workOrder.id}`}
                    onClick={() => setLocation(`/mobile/work-order-details/${workOrder.id}`)}
                  >
                    Ver Detalhes
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Work Orders List - Pausadas */}
        {myPausedOrders.length > 0 && (
          <div className="space-y-4" id="pausadas-section">
            <h2 className="text-xl font-bold text-amber-900 flex items-center gap-2">
              <Clock className="w-6 h-6" />
              OSs Pausadas ({myPausedOrders.length})
            </h2>

            {myPausedOrders.map((workOrder) => (
              <Card key={workOrder.id} className="bg-amber-50/80 backdrop-blur-sm border-amber-200 shadow-lg">
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="space-y-1 flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge variant="outline" className="bg-amber-600 text-white border-amber-700 font-bold">
                          OS #{workOrder.number}
                        </Badge>
                      </div>
                      <CardTitle className="text-lg text-amber-900 break-words">{workOrder.title}</CardTitle>
                      <div className="flex items-center space-x-2 text-sm text-amber-700">
                        <MapPin className="w-4 h-4" />
                        <span>{workOrder.siteName} - {workOrder.zoneName}</span>
                      </div>
                    </div>
                    <div className="flex flex-col items-end space-y-2">
                      <div className={`w-3 h-3 rounded-full ${getPriorityColor(workOrder.priority)}`}></div>
                      <Badge variant="outline" className="bg-amber-100 text-amber-800 border-amber-200">
                        Pausada
                      </Badge>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="pt-0">
                  <p className="text-amber-800 mb-3">{workOrder.description}</p>
                  <div className="flex items-center justify-between text-sm text-amber-600 mb-3">
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4" />
                      <span>Prazo: {formatDate(workOrder.dueDate)}</span>
                    </div>
                    <span className="font-medium capitalize">{workOrder.type.replace('_', ' ')}</span>
                  </div>
                  <Button 
                    className="w-full bg-amber-600 hover:bg-amber-700" 
                    data-testid={`button-view-order-${workOrder.id}`}
                    onClick={() => setLocation(`/mobile/work-order-details/${workOrder.id}`)}
                  >
                    Retomar OS
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Work Orders List - Minhas Concluídas */}
        {myCompletedOrders.length > 0 && (
          <div className="space-y-4" id="concluidas-section">
            <h2 className="text-xl font-bold text-emerald-900 flex items-center gap-2">
              <CheckCircle className="w-6 h-6" />
              Minhas Concluídas ({myCompletedOrders.length})
            </h2>

            {myCompletedOrders.map((workOrder) => (
              <Card key={workOrder.id} className="bg-emerald-50/80 backdrop-blur-sm border-emerald-200 shadow-lg">
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="space-y-1 flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge variant="outline" className="bg-emerald-600 text-white border-emerald-700 font-bold">
                          OS #{workOrder.number}
                        </Badge>
                      </div>
                      <CardTitle className="text-lg text-emerald-900 break-words">{workOrder.title}</CardTitle>
                      <div className="flex items-center space-x-2 text-sm text-emerald-700">
                        <MapPin className="w-4 h-4" />
                        <span>{workOrder.siteName} - {workOrder.zoneName}</span>
                      </div>
                    </div>
                    <Badge variant="outline" className="bg-green-100 text-green-800 border-green-200">
                      Concluída
                    </Badge>
                  </div>
                </CardHeader>
                <CardContent className="pt-0">
                  <p className="text-emerald-800 mb-3 text-sm">{workOrder.description}</p>
                  <div className="flex items-center justify-between text-sm text-emerald-600">
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4" />
                      <span>Concluída em: {formatDateTime(workOrder.completedAt || workOrder.createdAt)}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
      </PullToRefresh>
    </div>
  );
}