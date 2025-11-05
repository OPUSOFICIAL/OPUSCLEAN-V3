import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { getAuthState, canOnlyViewOwnWorkOrders } from "@/lib/auth";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { QrCode, ClipboardList, Clock, CheckCircle, AlertCircle, Camera, User, LogOut, MapPin, Calendar, Filter, RefreshCw } from "lucide-react";
import { useLocation } from "wouter";
import { useToast } from "@/hooks/use-toast";
import { logout } from "@/lib/auth";
import { queryClient } from "@/lib/queryClient";
import { useModule } from "@/contexts/ModuleContext";
import { MobileHeader } from "@/components/mobile-header";

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
  
  // Buscar as OS - o hook precisa ser chamado antes de qualquer return
  const { data: workOrders = [], isLoading } = useQuery({
    queryKey: ["/api/customers", effectiveCustomerId, "work-orders", { module: currentModule, userId: user?.id, zoneId: currentLocation?.zoneId }],
    enabled: !!effectiveCustomerId && !!user,
    queryFn: async () => {
      const params = new URLSearchParams();
      
      // Add module filter
      if (currentModule) {
        params.append('module', currentModule);
      }
      
      // If we have a current location (from QR scan), filter by zone
      if (currentLocation?.zoneId) {
        params.append('zoneId', currentLocation.zoneId);
      }
      
      // If user is an operator, filter by assignedTo
      if (user?.id) {
        params.append('assignedTo', user.id);
      }
      
      const url = `/api/customers/${effectiveCustomerId}/work-orders?${params.toString()}`;
      
      const response = await fetch(url);
      if (!response.ok) throw new Error('Failed to fetch work orders');
      return response.json();
    }
  });
  
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
  
  const myPendingOrders = filteredWorkOrders.filter(wo => 
    wo.assignedUserId === user.id && wo.status !== 'concluida' && wo.status !== 'cancelada' && wo.status !== 'pausada'
  );
  
  const myPausedOrders = filteredWorkOrders.filter(wo => 
    wo.status === 'pausada'
  );
  
  const myCompletedOrders = filteredWorkOrders.filter(wo => 
    wo.assignedUserId === user.id && wo.status === 'concluida'
  );

  const handleRefresh = async () => {
    setIsRefreshing(true);
    await queryClient.invalidateQueries({ 
      queryKey: ["/api/customers", effectiveCustomerId, "work-orders"] 
    });
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
          <>
            <Button 
              variant="ghost" 
              size="sm"
              onClick={handleRefresh}
              className="text-white hover:bg-white/20"
              data-testid="button-refresh-mobile"
            >
              <RefreshCw className={`w-5 h-5 transition-transform duration-1000 ${isRefreshing ? 'rotate-360' : ''}`} />
            </Button>
            <Button 
              variant="ghost" 
              size="sm"
              onClick={handleLogout}
              className="text-white hover:bg-white/20"
            >
              <LogOut className="w-5 h-5" />
            </Button>
          </>
        }
      />

      <div className="p-4 space-y-6">
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
                <p className="text-xl font-bold text-slate-900">{availableOrders.length}</p>
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
                <p className="text-xl font-bold text-slate-900">{myPendingOrders.length}</p>
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
                <p className="text-xl font-bold text-slate-900">{myPausedOrders.length}</p>
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
                <p className="text-xl font-bold text-slate-900">{myCompletedOrders.length}</p>
                <p className="text-xs text-slate-600 text-center">Concluídas</p>
              </div>
            </CardContent>
          </Card>
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
                      <span>Concluída em: {formatDateTime(workOrder.createdAt)}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}