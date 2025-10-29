import React from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useClient } from "@/contexts/ClientContext";
import { useLocation } from "wouter";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";
import { 
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  AreaChart,
  Area
} from 'recharts';
import { 
  TrendingUp, 
  TrendingDown, 
  Users, 
  Clock, 
  CheckCircle, 
  AlertTriangle,
  MapPin,
  Calendar,
  Filter,
  RefreshCcw,
  Download,
  Building,
  ClipboardList,
  Target,
  Zap,
  Award,
  Activity,
  Eye,
  Plus,
  ArrowUpRight,
  ArrowDownRight,
  Gauge,
  BarChart3
} from "lucide-react";

export default function Dashboard() {
  const [selectedPeriod, setSelectedPeriod] = React.useState<string>("total");
  const [selectedSite, setSelectedSite] = React.useState<string>("todos");
  const [isRefreshing, setIsRefreshing] = React.useState(false);
  const queryClient = useQueryClient();
  const [, navigate] = useLocation();

  const { activeClientId } = useClient();

  // Queries
  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: [`/api/customers/${activeClientId}/dashboard-stats/${selectedPeriod}/${selectedSite}`],
    enabled: !!activeClientId,
  });

  const { data: analytics, isLoading: analyticsLoading } = useQuery({
    queryKey: [`/api/customers/${activeClientId}/analytics/${selectedPeriod}/${selectedSite}`],
    enabled: !!activeClientId,
  });

  const { data: workOrders } = useQuery({
    queryKey: ["/api/customers", activeClientId, "work-orders"],
    enabled: !!activeClientId,
  });

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", activeClientId, "sites"],
    enabled: !!activeClientId,
  });

  const { data: goals } = useQuery({
    queryKey: ["/api/customers", activeClientId, "dashboard-goals"],
    enabled: !!activeClientId,
  });

  const { data: zones } = useQuery({
    queryKey: ["/api/customers", activeClientId, "zones"],
    enabled: !!activeClientId,
  });

  // Helper function to get goal value by type
  const getGoalValue = (goalType: string): number | null => {
    if (!goals) return null;
    const goal = (goals as any[]).find((g: any) => g.goalType === goalType);
    return goal ? parseFloat(goal.goalValue) : null;
  };


  if (statsLoading) {
    return (
      <div className="h-full bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="relative">
            <div className="w-16 h-16 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto"></div>
            <div className="absolute inset-0 w-16 h-16 border-4 border-transparent border-t-blue-400 rounded-full animate-ping mx-auto"></div>
          </div>
          <div className="space-y-2">
            <h3 className="text-lg font-semibold text-slate-700">Carregando Analytics</h3>
            <p className="text-sm text-slate-500">Preparando seus dados em tempo real...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-auto bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50">
      {/* Modern Header with Glassmorphism */}
      <div className="bg-white/80 backdrop-blur-xl border-b border-white/20 shadow-lg shadow-blue-500/5 sticky top-0 z-50">
        <div className="px-4 md:px-8 py-4 md:py-6">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div className="flex items-center space-x-3 md:space-x-6">
              <div className="flex items-center space-x-3 md:space-x-4">
                <div className="relative">
                  <div className="w-12 h-12 bg-gradient-to-br from-blue-600 via-blue-700 to-indigo-800 rounded-2xl flex items-center justify-center shadow-lg">
                    <Activity className="w-7 h-7 text-white" />
                  </div>
                  <div className="absolute -top-1 -right-1 w-4 h-4 bg-green-500 rounded-full border-2 border-white animate-pulse"></div>
                </div>
                <div>
                  <h1 className="text-xl md:text-2xl lg:text-3xl font-bold bg-gradient-to-r from-slate-900 via-blue-900 to-indigo-900 bg-clip-text text-transparent">
                    Dashboard
                  </h1>
                  <div className="text-xs md:text-sm text-slate-600 flex items-center space-x-2">
                    <span className="hidden sm:inline">Monitoramento em tempo real</span>
                    <span className="sm:hidden">Live</span>
                    <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                    <span className="text-green-600 font-medium hidden sm:inline">Live</span>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Enhanced Filter Controls */}
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-4">
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 bg-white/60 backdrop-blur-sm rounded-xl p-2 border border-white/20">
                <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
                  <SelectTrigger className="w-full sm:w-36 border-0 bg-transparent">
                    <Calendar className="w-4 h-4 mr-2 text-blue-600" />
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="hoje">Hoje</SelectItem>
                    <SelectItem value="ontem">Ontem</SelectItem>
                    <SelectItem value="semana">Esta Semana</SelectItem>
                    <SelectItem value="mes">Este Mês</SelectItem>
                    <SelectItem value="total">Total</SelectItem>
                  </SelectContent>
                </Select>

                <Select value={selectedSite} onValueChange={setSelectedSite}>
                  <SelectTrigger className="w-full sm:w-48 border-0 bg-transparent">
                    <Building className="w-4 h-4 mr-2 text-blue-600" />
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todos">Todos os Locais</SelectItem>
                    {(sites as any[] || []).map((site: any) => (
                      <SelectItem key={site.id} value={site.id}>
                        {site.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
                <Button 
                  variant="outline" 
                  size="sm" 
                  className="bg-white/60 backdrop-blur-sm border-white/20"
                  onClick={() => {
                    setIsRefreshing(true);
                    if (activeClientId) {
                      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId] });
                    }
                    setTimeout(() => setIsRefreshing(false), 1000);
                  }}
                  data-testid="button-refresh"
                >
                  <RefreshCcw className={`w-4 h-4 mr-2 transition-transform duration-700 ${isRefreshing ? 'animate-spin' : ''}`} />
                  <span className="hidden sm:inline">Atualizar</span>
                  <span className="sm:hidden">Sync</span>
                </Button>
                <Button 
                  variant="outline" 
                  size="sm" 
                  className="bg-white/60 backdrop-blur-sm border-white/20"
                  onClick={() => {
                    const exportData = {
                      periodo: selectedPeriod,
                      local: selectedSite === 'todos' ? 'Todos os Locais' : (sites as any[] || []).find((s: any) => s.id === selectedSite)?.name || 'N/A',
                      data_export: new Date().toLocaleString('pt-BR'),
                      kpis: {
                        eficiencia: (stats as any)?.efficiency || 0,
                        sla_compliance: (stats as any)?.slaCompliance || 0,
                        os_abertas: (stats as any)?.openWorkOrders || 0,
                        os_concluidas: (stats as any)?.completedWorkOrders || 0,
                        os_vencidas: (stats as any)?.overdueWorkOrders || 0,
                        area_limpa: (stats as any)?.areaCleanedToday || 0,
                        operadores_ativos: (stats as any)?.activeOperators || 0,
                        indice_qualidade: (stats as any)?.qualityIndex || 0
                      }
                    };
                    
                    const csvContent = `data:text/csv;charset=utf-8,` +
                      `Período,${exportData.periodo}\n` +
                      `Local,${exportData.local}\n` +
                      `Data de Exportação,${exportData.data_export}\n` +
                      `\n` +
                      `Métrica,Valor\n` +
                      `Eficiência Operacional,${exportData.kpis.eficiencia}%\n` +
                      `SLA Compliance,${exportData.kpis.sla_compliance}%\n` +
                      `OS Abertas,${exportData.kpis.os_abertas}\n` +
                      `OS Concluídas,${exportData.kpis.os_concluidas}\n` +
                      `OS Vencidas,${exportData.kpis.os_vencidas}\n` +
                      `Área Limpa (m²),${exportData.kpis.area_limpa}\n` +
                      `Operadores Ativos,${exportData.kpis.operadores_ativos}\n` +
                      `Índice de Qualidade,${exportData.kpis.indice_qualidade}/10`;
                    
                    const encodedUri = encodeURI(csvContent);
                    const link = document.createElement("a");
                    link.setAttribute("href", encodedUri);
                    link.setAttribute("download", `dashboard_${selectedPeriod}_${new Date().toISOString().split('T')[0]}.csv`);
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                  }}
                  data-testid="button-exportar"
                >
                  <Download className="w-4 h-4 mr-2" />
                  <span className="hidden sm:inline">Exportar</span>
                  <span className="sm:hidden">CSV</span>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-3 md:p-5 lg:p-6 space-y-5 md:space-y-6">
        {/* KPI Grid - Enhanced with animations */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
          {/* Eficiência Operacional */}
          <Card className="relative overflow-hidden bg-gradient-to-br from-emerald-50 via-green-50 to-emerald-100 border-0 shadow-xl shadow-emerald-500/10 hover:shadow-emerald-500/20 transition-all duration-500 hover:scale-105">
            <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-500/10 rounded-full -translate-y-16 translate-x-16"></div>
            <CardContent className="p-6 relative">
              <div className="flex items-start justify-between">
                <div className="space-y-3">
                  <div className="flex items-center space-x-2">
                    <Target className="w-5 h-5 text-emerald-600" />
                    <p className="text-sm font-medium text-emerald-700">Eficiência Operacional</p>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-baseline space-x-3">
                      <span className="text-4xl font-bold text-emerald-900">{(stats as any)?.efficiency || 0}%</span>
                      {(() => {
                        const goalValue = getGoalValue('eficiencia_operacional');
                        if (!goalValue) return null;
                        const currentValue = (stats as any)?.efficiency || 0;
                        const diff = currentValue - goalValue;
                        return diff > 0 ? (
                          <div className="flex items-center text-sm text-emerald-600 bg-emerald-100 px-2 py-1 rounded-full">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +{diff.toFixed(1)}%
                          </div>
                        ) : diff < 0 ? (
                          <div className="flex items-center text-sm text-red-600 bg-red-100 px-2 py-1 rounded-full">
                            <TrendingDown className="w-3 h-3 mr-1" />
                            {diff.toFixed(1)}%
                          </div>
                        ) : null;
                      })()}
                    </div>
                    <Progress value={(stats as any)?.efficiency || 0} className="h-2 bg-emerald-200" />
                    {(() => {
                      const goalValue = getGoalValue('eficiencia_operacional');
                      if (!goalValue) return null;
                      const currentValue = (stats as any)?.efficiency || 0;
                      return (
                        <p className="text-xs text-emerald-600">
                          Meta: {goalValue}% • {currentValue >= goalValue ? 'Superado! 🎯' : 'Abaixo da meta'}
                        </p>
                      );
                    })()}
                  </div>
                </div>
                <div className="w-14 h-14 bg-emerald-500 rounded-2xl flex items-center justify-center shadow-lg">
                  <Gauge className="w-7 h-7 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* SLA Compliance */}
          <Card className="relative overflow-hidden bg-gradient-to-br from-blue-50 via-sky-50 to-blue-100 border-0 shadow-xl shadow-blue-500/10 hover:shadow-blue-500/20 transition-all duration-500 hover:scale-105">
            <div className="absolute top-0 right-0 w-32 h-32 bg-blue-500/10 rounded-full -translate-y-16 translate-x-16"></div>
            <CardContent className="p-6 relative">
              <div className="flex items-start justify-between">
                <div className="space-y-3">
                  <div className="flex items-center space-x-2">
                    <Clock className="w-5 h-5 text-blue-600" />
                    <p className="text-sm font-medium text-blue-700">SLA Compliance</p>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-baseline space-x-3">
                      <span className="text-4xl font-bold text-blue-900">{(stats as any)?.slaCompliance || 0}%</span>
                      {(() => {
                        const goalValue = getGoalValue('sla_compliance');
                        if (!goalValue) return null;
                        const currentValue = (stats as any)?.slaCompliance || 0;
                        const diff = currentValue - goalValue;
                        return diff > 0 ? (
                          <div className="flex items-center text-sm text-blue-600 bg-blue-100 px-2 py-1 rounded-full">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +{diff.toFixed(1)}%
                          </div>
                        ) : diff < 0 ? (
                          <div className="flex items-center text-sm text-red-600 bg-red-100 px-2 py-1 rounded-full">
                            <TrendingDown className="w-3 h-3 mr-1" />
                            {diff.toFixed(1)}%
                          </div>
                        ) : null;
                      })()}
                    </div>
                    <Progress value={(stats as any)?.slaCompliance || 0} className="h-2 bg-blue-200" />
                    {(() => {
                      const goalValue = getGoalValue('sla_compliance');
                      if (!goalValue) return null;
                      const currentValue = (stats as any)?.slaCompliance || 0;
                      return (
                        <p className="text-xs text-blue-600">
                          Meta: {goalValue}% • {currentValue >= goalValue ? 'Superado! 🎯' : 'Dentro do prazo: ' + ((stats as any)?.completedWorkOrders || 0) + ' OS'}
                        </p>
                      );
                    })()}
                  </div>
                </div>
                <div className="w-14 h-14 bg-blue-500 rounded-2xl flex items-center justify-center shadow-lg">
                  <CheckCircle className="w-7 h-7 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Ordens de Serviço */}
          <Card className="relative overflow-hidden bg-gradient-to-br from-purple-50 via-violet-50 to-purple-100 border-0 shadow-xl shadow-purple-500/10 hover:shadow-purple-500/20 transition-all duration-500 hover:scale-105">
            <div className="absolute top-0 right-0 w-32 h-32 bg-purple-500/10 rounded-full -translate-y-16 translate-x-16"></div>
            <CardContent className="p-6 relative">
              <div className="flex items-start justify-between">
                <div className="space-y-3">
                  <div className="flex items-center space-x-2">
                    <ClipboardList className="w-5 h-5 text-purple-600" />
                    <p className="text-sm font-medium text-purple-700">OS Concluídas</p>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-baseline space-x-3">
                      <span className="text-4xl font-bold text-purple-900">{(stats as any)?.completedWorkOrders || 0}</span>
                      {(() => {
                        const goalValue = getGoalValue('os_concluidas_mes');
                        const currentValue = (stats as any)?.completedWorkOrders || 0;
                        if (goalValue && goalValue > 0) {
                          const diff = currentValue - goalValue;
                          return diff >= 0 ? (
                            <div className="flex items-center text-sm text-green-600 bg-green-100 px-2 py-1 rounded-full">
                              <TrendingUp className="w-3 h-3 mr-1" />
                              +{diff}
                            </div>
                          ) : (
                            <div className="flex items-center text-sm text-red-600 bg-red-100 px-2 py-1 rounded-full">
                              <TrendingDown className="w-3 h-3 mr-1" />
                              {diff}
                            </div>
                          );
                        }
                        return null;
                      })()}
                    </div>
                    <Progress value={(stats as any)?.efficiency || 0} className="h-2 bg-purple-200" />
                    {(() => {
                      const goalValue = getGoalValue('os_concluidas_mes');
                      const currentValue = (stats as any)?.completedWorkOrders || 0;
                      const totalOrders = currentValue + ((stats as any)?.openWorkOrders || 0);
                      return (
                        <p className="text-xs text-purple-600">
                          {goalValue ? `Meta: ${goalValue} • ${currentValue >= goalValue ? 'Superado! 🎯' : 'de ' + totalOrders + ' total'}` : `de ${totalOrders} total`}
                        </p>
                      );
                    })()}
                  </div>
                </div>
                <div className="w-14 h-14 bg-purple-500 rounded-2xl flex items-center justify-center shadow-lg">
                  <Activity className="w-7 h-7 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Qualidade */}
          <Card className="relative overflow-hidden bg-gradient-to-br from-orange-50 via-amber-50 to-orange-100 border-0 shadow-xl shadow-orange-500/10 hover:shadow-orange-500/20 transition-all duration-500 hover:scale-105">
            <div className="absolute top-0 right-0 w-32 h-32 bg-orange-500/10 rounded-full -translate-y-16 translate-x-16"></div>
            <CardContent className="p-6 relative">
              <div className="flex items-start justify-between">
                <div className="space-y-3">
                  <div className="flex items-center space-x-2">
                    <Award className="w-5 h-5 text-orange-600" />
                    <p className="text-sm font-medium text-orange-700">Índice de Qualidade</p>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-baseline space-x-3">
                      {(() => {
                        const completedOrders = (stats as any)?.completedWorkOrders || 0;
                        const qualityIndex = (stats as any)?.qualityIndex;
                        
                        if (completedOrders === 0 || qualityIndex === null || qualityIndex === undefined) {
                          return <span className="text-4xl font-bold text-orange-400">N/A</span>;
                        }
                        
                        const goalValue = getGoalValue('indice_qualidade');
                        const diff = goalValue ? qualityIndex - goalValue : 0;
                        
                        return (
                          <>
                            <span className="text-4xl font-bold text-orange-900">{qualityIndex}/10</span>
                            {goalValue && diff > 0 ? (
                              <div className="flex items-center text-sm text-orange-600 bg-orange-100 px-2 py-1 rounded-full">
                                <TrendingUp className="w-3 h-3 mr-1" />
                                +{diff.toFixed(1)}
                              </div>
                            ) : goalValue && diff < 0 ? (
                              <div className="flex items-center text-sm text-red-600 bg-red-100 px-2 py-1 rounded-full">
                                <TrendingDown className="w-3 h-3 mr-1" />
                                {diff.toFixed(1)}
                              </div>
                            ) : null}
                          </>
                        );
                      })()}
                    </div>
                    <Progress value={((stats as any)?.completedWorkOrders || 0) > 0 ? ((stats as any)?.qualityIndex || 0) * 10 : 0} className="h-2 bg-orange-200" />
                    {(() => {
                      const goalValue = getGoalValue('indice_qualidade');
                      const completedOrders = (stats as any)?.completedWorkOrders || 0;
                      const currentValue = (stats as any)?.qualityIndex;
                      const ratedCount = (stats as any)?.ratedCount || 0;
                      
                      if (!goalValue || completedOrders === 0 || currentValue === null || currentValue === undefined) {
                        return (
                          <p className="text-xs text-orange-600">
                            Meta: {goalValue}/10 • Sem avaliações ainda
                          </p>
                        );
                      }
                      
                      return (
                        <p className="text-xs text-orange-600">
                          Meta: {goalValue}/10 • Baseado em {ratedCount} avaliação{ratedCount !== 1 ? 'ões' : ''}
                        </p>
                      );
                    })()}
                  </div>
                </div>
                <div className="w-14 h-14 bg-orange-500 rounded-2xl flex items-center justify-center shadow-lg">
                  <Award className="w-7 h-7 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Analytics Dashboard - Modern BI Style */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 lg:gap-6">
          {/* Performance Trends */}
          <Card className="bg-gradient-to-br from-blue-50/80 via-white to-indigo-50/80 border border-blue-100 shadow-2xl hover:shadow-3xl transition-all duration-300 backdrop-blur-sm">
            <CardHeader className="pb-6 border-b border-blue-100/50">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg">
                    <TrendingUp className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-gray-900">Performance</h3>
                    <p className="text-sm text-gray-600">Tendências de eficiência</p>
                  </div>
                </div>
                <div className="flex items-center space-x-2 px-3 py-2 bg-green-100 text-green-700 rounded-full text-sm font-semibold">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span>Em crescimento</span>
                </div>
              </div>
            </CardHeader>
            <CardContent className="p-6">
              <div className="h-72">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart 
                    data={(analytics as any)?.daily || []} 
                    margin={{ top: 20, right: 20, left: 0, bottom: 20 }}
                  >
                    <defs>
                      <linearGradient id="performanceGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.4}/>
                        <stop offset="50%" stopColor="#3b82f6" stopOpacity={0.1}/>
                        <stop offset="95%" stopColor="#3b82f6" stopOpacity={0.05}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="2 2" stroke="#e1e7ef" strokeOpacity={0.7} />
                    <XAxis 
                      dataKey="date" 
                      axisLine={false}
                      tickLine={false}
                      tick={{ fontSize: 12, fill: '#6b7280' }}
                      tickFormatter={(value) => {
                        if (!value) return '';
                        const date = new Date(value);
                        return `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}`;
                      }}
                    />
                    <YAxis 
                      axisLine={false}
                      tickLine={false}
                      tick={{ fontSize: 12, fill: '#6b7280' }}
                      domain={['dataMin - 5', 'dataMax + 5']}
                    />
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'rgba(255,255,255,0.98)',
                        border: '1px solid rgba(0,0,0,0.1)',
                        borderRadius: '12px',
                        boxShadow: '0 10px 40px rgba(0,0,0,0.15)',
                        backdropFilter: 'blur(20px)',
                        transform: 'translateY(120px)',
                        color: '#1e293b'
                      }}
                      labelStyle={{ color: '#374151', fontWeight: 'bold' }}
                      wrapperStyle={{ 
                        outline: 'none',
                        pointerEvents: 'none',
                        color: '#1e293b'
                      }}
                      labelFormatter={(value) => {
                        if (!value) return '';
                        const date = new Date(value);
                        return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`;
                      }}
                    />
                    <Area 
                      type="monotone" 
                      dataKey="efficiency" 
                      stroke="#3b82f6" 
                      strokeWidth={3}
                      fill="url(#performanceGradient)"
                      name="Eficiência %"
                      dot={{ fill: '#3b82f6', strokeWidth: 2, r: 4 }}
                      activeDot={{ r: 6, stroke: '#3b82f6', strokeWidth: 2 }}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>

          {/* Work Orders Status */}
          <Card className="bg-gradient-to-br from-purple-50/80 via-white to-violet-50/80 border border-purple-100 shadow-2xl hover:shadow-3xl transition-all duration-300 backdrop-blur-sm animate-fade-in">
            <CardHeader className="pb-6 border-b border-purple-100/50">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg animate-pulse-slow">
                    <Activity className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-gray-900">Status das OS</h3>
                    <p className="text-sm text-gray-600">Distribuição atual • Tempo real</p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  <span className="text-xs text-gray-500 font-medium">Live</span>
                </div>
              </div>
            </CardHeader>
            <CardContent className="p-6">
              <div className="grid grid-cols-5 gap-6 items-center">
                {/* Interactive Donut Chart */}
                <div className="col-span-2 flex justify-center">
                  <div className="relative group w-[200px] h-[200px]">
                    <ResponsiveContainer width={200} height={200}>
                      <PieChart>
                        <Pie
                          data={(analytics as any)?.statusBreakdown?.map((item: any) => ({
                            name: item.status === 'concluida' ? 'Concluídas' : 
                                  item.status === 'aberta' ? 'Abertas' : 
                                  item.status === 'vencida' ? 'Vencidas' : item.status,
                            value: item.count,
                            percentage: item.percentage
                          })) || []}
                          cx={100}
                          cy={100}
                          innerRadius={55}
                          outerRadius={85}
                          paddingAngle={2}
                          dataKey="value"
                          animationBegin={0}
                          animationDuration={1000}
                          animationEasing="ease-out"
                        >
                          {((analytics as any)?.statusBreakdown || []).map((entry: any, index: number) => (
                            <Cell 
                              key={`cell-${index}`} 
                              fill={
                                entry.status === 'concluida' ? '#22c55e' :
                                entry.status === 'em_andamento' ? '#3b82f6' :
                                entry.status === 'aberta' ? '#f59e0b' :
                                entry.status === 'vencida' ? '#ef4444' : '#6b7280'
                              }
                              stroke="white"
                              strokeWidth={3}
                              style={{
                                filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.1))',
                                transition: 'all 0.3s ease',
                                transformOrigin: 'center',
                              }}
                              onMouseEnter={(e) => {
                                const target = e.target as HTMLElement;
                                target.style.filter = 'drop-shadow(0 4px 8px rgba(0,0,0,0.2)) brightness(1.1)';
                                target.style.transform = 'scale(1.05)';
                                target.style.cursor = 'pointer';
                              }}
                              onMouseLeave={(e) => {
                                const target = e.target as HTMLElement;
                                target.style.filter = 'drop-shadow(0 2px 4px rgba(0,0,0,0.1))';
                                target.style.transform = 'scale(1)';
                              }}
                            />
                          ))}
                        </Pie>
                        <Tooltip 
                          contentStyle={{
                            backgroundColor: 'rgba(255,255,255,0.98)',
                            border: '1px solid rgba(0,0,0,0.1)',
                            borderRadius: '12px',
                            boxShadow: '0 8px 32px rgba(0,0,0,0.12)',
                            backdropFilter: 'blur(20px)',
                            padding: '12px 16px',
                            fontSize: '14px',
                            fontWeight: '500',
                            color: '#1e293b',
                            transform: 'translateY(120px)'
                          }}
                          formatter={(value, name) => [`${value} unidades`, name]}
                          labelFormatter={() => ''}
                          wrapperStyle={{ 
                            outline: 'none',
                            pointerEvents: 'none',
                            color: '#1e293b'
                          }}
                          labelStyle={{
                            color: '#1e293b'
                          }}
                        />
                      </PieChart>
                    </ResponsiveContainer>
                    
                    {/* Texto no Centro do Donut */}
                    <div 
                      className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 pointer-events-none"
                    >
                      <div className="text-center">
                        <div className="text-4xl font-bold text-gray-900 leading-none">
                          {((analytics as any)?.statusBreakdown || []).reduce((total: number, item: any) => total + item.count, 0)}
                        </div>
                        <div className="text-sm text-gray-500 font-medium leading-none mt-1">Total OS</div>
                      </div>
                    </div>
                    
                    {/* Subtle Glow Effect */}
                    <div className="absolute inset-0 rounded-full bg-gradient-to-r from-blue-400/10 via-purple-400/10 to-green-400/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-xl -z-10"></div>
                  </div>
                </div>

                {/* Interactive Legend */}
                <div className="col-span-3 space-y-3">
                  {((analytics as any)?.statusBreakdown || []).map((item: any, index: number) => (
                    <div 
                      key={index} 
                      className="group p-4 rounded-xl bg-white/70 backdrop-blur-sm border border-gray-100 hover:border-gray-300 hover:shadow-lg hover:bg-white/90 transition-all duration-300 cursor-pointer transform hover:scale-[1.02] active:scale-[0.98]"
                      onClick={() => {
                        // Add click interaction for future filtering
                        console.log(`Selected: ${item.status}`);
                      }}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-4">
                          <div className="relative">
                            <div 
                              className="w-5 h-5 rounded-full shadow-lg ring-3 ring-white transition-all duration-300 group-hover:scale-110 group-hover:shadow-xl" 
                              style={{ backgroundColor: 
                                item.status === 'concluida' ? '#22c55e' :
                                item.status === 'em_andamento' ? '#3b82f6' :
                                item.status === 'aberta' ? '#f59e0b' :
                                item.status === 'vencida' ? '#ef4444' : '#6b7280'
                              }}
                            />
                            <div 
                              className="absolute inset-0 rounded-full opacity-0 group-hover:opacity-20 transition-opacity duration-300"
                              style={{ backgroundColor: 
                                item.status === 'concluida' ? '#22c55e' :
                                item.status === 'em_andamento' ? '#3b82f6' :
                                item.status === 'aberta' ? '#f59e0b' :
                                item.status === 'vencida' ? '#ef4444' : '#6b7280'
                              }}
                            />
                          </div>
                          <div className="transition-all duration-300 group-hover:translate-x-1">
                            <div className="text-sm font-bold text-gray-800 group-hover:text-gray-900">
                              {item.status === 'concluida' ? 'Concluídas' : 
                               item.status === 'aberta' ? 'Abertas' : 
                               item.status === 'vencida' ? 'Vencidas' : item.status}
                            </div>
                            <div className="text-xs text-gray-500 group-hover:text-gray-600">
                              {item.percentage}% do total
                            </div>
                          </div>
                        </div>
                        <div className="text-right transform transition-all duration-300 group-hover:scale-105">
                          <div className="text-xl font-bold text-gray-900 group-hover:text-gray-800">
                            {item.count}
                          </div>
                          <div className="text-xs text-gray-500 font-medium group-hover:text-gray-600">
                            unidades
                          </div>
                        </div>
                      </div>
                      
                      {/* Progress bar indicator */}
                      <div className="mt-3 w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
                        <div 
                          className="h-full rounded-full transition-all duration-500 ease-out transform origin-left scale-x-0 group-hover:scale-x-100"
                          style={{ 
                            backgroundColor: 
                              item.status === 'concluida' ? '#22c55e' :
                              item.status === 'em_andamento' ? '#3b82f6' :
                              item.status === 'aberta' ? '#f59e0b' :
                              item.status === 'vencida' ? '#ef4444' : '#6b7280',
                            width: `${item.percentage}%`
                          }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Additional Analytics Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* OS por Prioridade */}
          <Card className="bg-white/70 backdrop-blur-sm border-0 shadow-xl">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-gradient-to-br from-purple-600 to-pink-600 rounded-lg flex items-center justify-center">
                  <Target className="w-4 h-4 text-white" />
                </div>
                <span className="text-xl">OS por Prioridade</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={((analytics as any)?.priorityBreakdown || []).map((item: any) => ({
                  name: item.priority === 'critica' ? 'Crítica' : 
                        item.priority === 'alta' ? 'Alta' : 
                        item.priority === 'media' ? 'Média' : 
                        item.priority === 'baixa' ? 'Baixa' : item.priority,
                  value: item.count
                }))}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="name" stroke="#64748b" fontSize={12} />
                  <YAxis stroke="#64748b" fontSize={12} />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'rgba(255,255,255,0.98)',
                      border: '1px solid rgba(0,0,0,0.1)',
                      borderRadius: '12px',
                      padding: '12px'
                    }}
                  />
                  <Bar dataKey="value" radius={[8, 8, 0, 0]}>
                    {((analytics as any)?.priorityBreakdown || []).map((item: any, index: number) => (
                      <Cell 
                        key={`cell-${index}`} 
                        fill={item.priority === 'critica' ? '#dc2626' : 
                              item.priority === 'alta' ? '#f59e0b' : 
                              item.priority === 'media' ? '#3b82f6' : '#22c55e'
                        } 
                      />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* OS por Zona */}
          <Card className="bg-white/70 backdrop-blur-sm border-0 shadow-xl">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-gradient-to-br from-cyan-600 to-blue-600 rounded-lg flex items-center justify-center">
                  <MapPin className="w-4 h-4 text-white" />
                </div>
                <span className="text-xl">OS por Local</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart 
                  data={(analytics as any)?.locationBreakdown || []}
                  layout="vertical"
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis type="number" stroke="#64748b" fontSize={12} />
                  <YAxis dataKey="location" type="category" stroke="#64748b" fontSize={12} width={120} />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'rgba(255,255,255,0.98)',
                      border: '1px solid rgba(0,0,0,0.1)',
                      borderRadius: '12px',
                      padding: '12px'
                    }}
                  />
                  <Bar dataKey="count" fill="#06b6d4" radius={[0, 8, 8, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Tempo Médio e Taxa de Conclusão */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Tempo Médio de Conclusão */}
          <Card className="bg-white/70 backdrop-blur-sm border-0 shadow-xl">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-gradient-to-br from-green-600 to-emerald-600 rounded-lg flex items-center justify-center">
                  <Clock className="w-4 h-4 text-white" />
                </div>
                <span className="text-xl">Tempo Médio de Conclusão</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="text-center p-6 bg-gradient-to-br from-green-50 to-emerald-50 rounded-xl">
                  <div className="text-5xl font-bold text-green-700 mb-2">
                    {(() => {
                      const minutes = (analytics as any)?.averageExecutionTime || 0;
                      const hours = Math.floor(minutes / 60);
                      const mins = minutes % 60;
                      return hours > 0 ? `${hours}h ${mins}min` : `${mins}min`;
                    })()}
                  </div>
                  <div className="text-sm text-green-600 font-medium">Tempo médio</div>
                  <div className="text-xs text-gray-500 mt-1">Baseado em OSs concluídas</div>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div className="p-4 bg-blue-50 rounded-lg">
                    <div className="text-2xl font-bold text-blue-700">
                      {(analytics as any)?.completedWorkOrders || 0}
                    </div>
                    <div className="text-xs text-blue-600 font-medium mt-1">OSs Concluídas</div>
                  </div>
                  
                  <div className="p-4 bg-purple-50 rounded-lg">
                    <div className="text-2xl font-bold text-purple-700">
                      {(analytics as any)?.averageExecutionTimeChange || '0%'}
                    </div>
                    <div className="text-xs text-purple-600 font-medium mt-1">Variação Tempo</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* OS por Dia da Semana */}
          <Card className="bg-white/70 backdrop-blur-sm border-0 shadow-xl">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-gradient-to-br from-orange-600 to-red-600 rounded-lg flex items-center justify-center">
                  <Calendar className="w-4 h-4 text-white" />
                </div>
                <span className="text-xl">Atividade por Dia da Semana</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={(analytics as any)?.weekdayBreakdown || []}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="day" stroke="#64748b" fontSize={12} />
                  <YAxis stroke="#64748b" fontSize={12} />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'rgba(255,255,255,0.98)',
                      border: '1px solid rgba(0,0,0,0.1)',
                      borderRadius: '12px',
                      padding: '12px'
                    }}
                  />
                  <Bar dataKey="count" fill="#f97316" radius={[8, 8, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}