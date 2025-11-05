import React from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
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
  Area,
  RadialBarChart,
  RadialBar,
  Legend
} from 'recharts';
import { 
  TrendingUp, 
  TrendingDown, 
  Clock, 
  CheckCircle, 
  AlertTriangle,
  MapPin,
  Calendar,
  RefreshCcw,
  Download,
  Building,
  ClipboardList,
  Target,
  Award,
  Activity,
  Gauge,
  BarChart3,
  Sparkles,
  Zap,
  Star,
  TrendingUpIcon
} from "lucide-react";

export default function Dashboard() {
  const [selectedPeriod, setSelectedPeriod] = React.useState<string>("total");
  const [selectedSite, setSelectedSite] = React.useState<string>("todos");
  const [isRefreshing, setIsRefreshing] = React.useState(false);
  const queryClient = useQueryClient();
  const [, navigate] = useLocation();

  const { activeClientId } = useClient();
  const { currentModule } = useModule();

  // Queries
  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: [`/api/customers/${activeClientId}/dashboard-stats/${selectedPeriod}/${selectedSite}?module=${currentModule}`],
    enabled: !!activeClientId,
  });

  const { data: analytics, isLoading: analyticsLoading } = useQuery({
    queryKey: [`/api/customers/${activeClientId}/analytics/${selectedPeriod}/${selectedSite}?module=${currentModule}`],
    enabled: !!activeClientId,
  });

  const { data: workOrders } = useQuery({
    queryKey: ["/api/customers", activeClientId, "work-orders", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", activeClientId, "sites", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: goals } = useQuery({
    queryKey: ["/api/customers", activeClientId, "dashboard-goals"],
    enabled: !!activeClientId,
  });

  const { data: zones } = useQuery({
    queryKey: ["/api/customers", activeClientId, "zones", { module: currentModule }],
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
      <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e3a8a] to-[#0f172a] flex items-center justify-center">
        <div className="text-center space-y-6">
          <div className="relative">
            <div className="w-20 h-20 border-4 border-blue-500/30 border-t-blue-500 rounded-full animate-spin mx-auto"></div>
            <div className="absolute inset-0 w-20 h-20 border-4 border-blue-400/20 border-t-blue-400 rounded-full animate-spin mx-auto" style={{ animationDirection: 'reverse', animationDuration: '1.5s' }}></div>
          </div>
          <p className="text-lg font-semibold text-white/90">Carregando dados...</p>
          <div className="flex items-center justify-center gap-2">
            <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
            <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
            <div className="w-2 h-2 bg-cyan-500 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e3a8a] to-[#0f172a] overflow-auto">
      {/* Modern Header with Navy Theme */}
      <div className="sticky top-0 z-50 backdrop-blur-2xl bg-[#1e3a8a]/80 border-b border-blue-400/20 shadow-2xl shadow-blue-900/20">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/10 via-cyan-500/10 to-blue-600/10"></div>
        <div className="relative max-w-[1600px] mx-auto px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-6">
              <div className="relative group">
                <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-cyan-600 rounded-2xl blur-xl opacity-60 group-hover:opacity-100 transition-opacity"></div>
                <div className="relative w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-600 via-blue-500 to-cyan-600 flex items-center justify-center shadow-2xl shadow-blue-500/50 transform group-hover:scale-110 transition-transform">
                  <Sparkles className="w-8 h-8 text-white animate-pulse" />
                </div>
              </div>
              <div>
                <h1 className="text-3xl font-black bg-gradient-to-r from-white via-blue-100 to-cyan-100 bg-clip-text text-transparent">
                  Dashboard
                </h1>
                <p className="text-sm text-blue-200/70 font-medium">Real-time Analytics & Insights</p>
              </div>
            </div>
            
            <div className="flex items-center gap-4">
              <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
                <SelectTrigger className="w-44 bg-white/10 backdrop-blur-xl border-blue-400/30 text-white hover:bg-white/20 transition-all hover:border-blue-400/50">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-slate-900 border-blue-400/20">
                  <SelectItem value="hoje">Hoje</SelectItem>
                  <SelectItem value="ontem">Ontem</SelectItem>
                  <SelectItem value="semana">Esta Semana</SelectItem>
                  <SelectItem value="mes">Este Mês</SelectItem>
                  <SelectItem value="total">Total</SelectItem>
                </SelectContent>
              </Select>

              <Select value={selectedSite} onValueChange={setSelectedSite}>
                <SelectTrigger className="w-52 bg-white/10 backdrop-blur-xl border-blue-400/30 text-white hover:bg-white/20 transition-all hover:border-cyan-400/50">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-slate-900 border-blue-400/20">
                  <SelectItem value="todos">Todos os Locais</SelectItem>
                  {(sites as any[] || []).map((site: any) => (
                    <SelectItem key={site.id} value={site.id}>
                      {site.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              <Button 
                variant="outline" 
                size="sm"
                className="bg-white/10 backdrop-blur-xl border-blue-400/30 text-white hover:bg-blue-500/30 hover:border-blue-400/50 transition-all group"
                onClick={() => {
                  setIsRefreshing(true);
                  if (activeClientId) {
                    queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId] });
                  }
                  setTimeout(() => setIsRefreshing(false), 1000);
                }}
                data-testid="button-refresh"
              >
                <RefreshCcw className={`w-4 h-4 mr-2 ${isRefreshing ? 'animate-spin' : 'group-hover:rotate-180'} transition-transform duration-500`} />
                Atualizar
              </Button>

              <Button 
                variant="outline" 
                size="sm"
                className="bg-gradient-to-r from-blue-500/30 to-cyan-500/30 backdrop-blur-xl border-blue-400/40 text-white hover:from-blue-500/40 hover:to-cyan-500/40 transition-all"
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
                Exportar
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-[1600px] mx-auto p-8 space-y-8">
        {/* Modern KPI Cards with Better Contrast */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Eficiência Operacional */}
          <div className="group relative">
            <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/30 to-teal-600/30 rounded-3xl blur-2xl opacity-40 group-hover:opacity-60 transition-opacity"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-xl border-0 shadow-2xl shadow-emerald-500/20 hover:shadow-emerald-500/40 transition-all duration-500 hover:-translate-y-2">
              <div className="absolute top-0 right-0 w-40 h-40 bg-gradient-to-br from-emerald-400/20 to-transparent rounded-full blur-3xl"></div>
              <CardContent className="relative p-8">
                <div className="flex items-start justify-between mb-6">
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 shadow-lg shadow-emerald-500/50 group-hover:scale-110 group-hover:rotate-6 transition-all duration-500">
                    <Zap className="w-8 h-8 text-white" />
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('eficiencia_operacional');
                    if (!goalValue) return null;
                    const currentValue = (stats as any)?.efficiency || 0;
                    const diff = currentValue - goalValue;
                    return diff >= 0 ? (
                      <Badge className="bg-emerald-100 text-emerald-700 border-0 text-xs px-3 py-1 font-semibold">
                        <TrendingUp className="w-3 h-3 mr-1" />
                        +{diff.toFixed(1)}%
                      </Badge>
                    ) : (
                      <Badge className="bg-red-100 text-red-700 border-0 text-xs px-3 py-1 font-semibold">
                        <TrendingDown className="w-3 h-3 mr-1" />
                        {diff.toFixed(1)}%
                      </Badge>
                    );
                  })()}
                </div>
                <div>
                  <p className="text-sm font-bold text-emerald-600 mb-3 uppercase tracking-wider">Eficiência Operacional</p>
                  <p className="text-5xl font-black text-slate-900 mb-6">
                    {(stats as any)?.efficiency || 0}%
                  </p>
                  <div className="relative">
                    <div className="h-3 bg-slate-100 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-gradient-to-r from-emerald-500 to-teal-600 rounded-full shadow-lg shadow-emerald-500/50 transition-all duration-1000"
                        style={{ width: `${(stats as any)?.efficiency || 0}%` }}
                      ></div>
                    </div>
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('eficiencia_operacional');
                    if (!goalValue) return null;
                    return (
                      <p className="text-xs text-slate-500 mt-4 font-medium">Meta: {goalValue}%</p>
                    );
                  })()}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* SLA Compliance */}
          <div className="group relative">
            <div className="absolute inset-0 bg-gradient-to-br from-blue-500/30 to-cyan-600/30 rounded-3xl blur-2xl opacity-40 group-hover:opacity-60 transition-opacity"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-xl border-0 shadow-2xl shadow-blue-500/20 hover:shadow-blue-500/40 transition-all duration-500 hover:-translate-y-2">
              <div className="absolute top-0 right-0 w-40 h-40 bg-gradient-to-br from-blue-400/20 to-transparent rounded-full blur-3xl"></div>
              <CardContent className="relative p-8">
                <div className="flex items-start justify-between mb-6">
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-blue-500 to-cyan-600 shadow-lg shadow-blue-500/50 group-hover:scale-110 group-hover:rotate-6 transition-all duration-500">
                    <Clock className="w-8 h-8 text-white" />
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('sla_compliance');
                    if (!goalValue) return null;
                    const currentValue = (stats as any)?.slaCompliance || 0;
                    const diff = currentValue - goalValue;
                    return diff >= 0 ? (
                      <Badge className="bg-blue-100 text-blue-700 border-0 text-xs px-3 py-1 font-semibold">
                        <TrendingUp className="w-3 h-3 mr-1" />
                        +{diff.toFixed(1)}%
                      </Badge>
                    ) : (
                      <Badge className="bg-red-100 text-red-700 border-0 text-xs px-3 py-1 font-semibold">
                        <TrendingDown className="w-3 h-3 mr-1" />
                        {diff.toFixed(1)}%
                      </Badge>
                    );
                  })()}
                </div>
                <div>
                  <p className="text-sm font-bold text-blue-600 mb-3 uppercase tracking-wider">SLA Compliance</p>
                  <p className="text-5xl font-black text-slate-900 mb-6">
                    {(stats as any)?.slaCompliance || 0}%
                  </p>
                  <div className="relative">
                    <div className="h-3 bg-slate-100 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-gradient-to-r from-blue-500 to-cyan-600 rounded-full shadow-lg shadow-blue-500/50 transition-all duration-1000"
                        style={{ width: `${(stats as any)?.slaCompliance || 0}%` }}
                      ></div>
                    </div>
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('sla_compliance');
                    if (!goalValue) return null;
                    return (
                      <p className="text-xs text-slate-500 mt-4 font-medium">Meta: {goalValue}%</p>
                    );
                  })()}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* OS Concluídas */}
          <div className="group relative">
            <div className="absolute inset-0 bg-gradient-to-br from-purple-500/30 to-pink-600/30 rounded-3xl blur-2xl opacity-40 group-hover:opacity-60 transition-opacity"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-xl border-0 shadow-2xl shadow-purple-500/20 hover:shadow-purple-500/40 transition-all duration-500 hover:-translate-y-2">
              <div className="absolute top-0 right-0 w-40 h-40 bg-gradient-to-br from-purple-400/20 to-transparent rounded-full blur-3xl"></div>
              <CardContent className="relative p-8">
                <div className="flex items-start justify-between mb-6">
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-purple-500 to-pink-600 shadow-lg shadow-purple-500/50 group-hover:scale-110 group-hover:rotate-6 transition-all duration-500">
                    <CheckCircle className="w-8 h-8 text-white" />
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('os_concluidas_mes');
                    const currentValue = (stats as any)?.completedWorkOrders || 0;
                    if (goalValue && goalValue > 0) {
                      const diff = currentValue - goalValue;
                      return diff >= 0 ? (
                        <Badge className="bg-purple-100 text-purple-700 border-0 text-xs px-3 py-1 font-semibold">
                          <TrendingUp className="w-3 h-3 mr-1" />
                          +{diff}
                        </Badge>
                      ) : (
                        <Badge className="bg-red-100 text-red-700 border-0 text-xs px-3 py-1 font-semibold">
                          <TrendingDown className="w-3 h-3 mr-1" />
                          {diff}
                        </Badge>
                      );
                    }
                    return null;
                  })()}
                </div>
                <div>
                  <p className="text-sm font-bold text-purple-600 mb-3 uppercase tracking-wider">OS Concluídas</p>
                  <p className="text-5xl font-black text-slate-900 mb-6">
                    {(stats as any)?.completedWorkOrders || 0}
                  </p>
                  <div className="relative">
                    <div className="h-3 bg-slate-100 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-gradient-to-r from-purple-500 to-pink-600 rounded-full shadow-lg shadow-purple-500/50 transition-all duration-1000"
                        style={{ width: `${Math.min((stats as any)?.efficiency || 0, 100)}%` }}
                      ></div>
                    </div>
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('os_concluidas_mes');
                    const totalOrders = ((stats as any)?.completedWorkOrders || 0) + ((stats as any)?.openWorkOrders || 0);
                    return goalValue ? (
                      <p className="text-xs text-slate-500 mt-4 font-medium">Meta: {goalValue}</p>
                    ) : (
                      <p className="text-xs text-slate-500 mt-4 font-medium">Total: {totalOrders}</p>
                    );
                  })()}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Índice de Qualidade */}
          <div className="group relative">
            <div className="absolute inset-0 bg-gradient-to-br from-amber-500/30 to-orange-600/30 rounded-3xl blur-2xl opacity-40 group-hover:opacity-60 transition-opacity"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-xl border-0 shadow-2xl shadow-amber-500/20 hover:shadow-amber-500/40 transition-all duration-500 hover:-translate-y-2">
              <div className="absolute top-0 right-0 w-40 h-40 bg-gradient-to-br from-amber-400/20 to-transparent rounded-full blur-3xl"></div>
              <CardContent className="relative p-8">
                <div className="flex items-start justify-between mb-6">
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-amber-500 to-orange-600 shadow-lg shadow-amber-500/50 group-hover:scale-110 group-hover:rotate-6 transition-all duration-500">
                    <Star className="w-8 h-8 text-white" />
                  </div>
                  {(() => {
                    const completedOrders = (stats as any)?.completedWorkOrders || 0;
                    const qualityIndex = (stats as any)?.qualityIndex;
                    
                    if (completedOrders === 0 || qualityIndex === null || qualityIndex === undefined) {
                      return null;
                    }
                    
                    const goalValue = getGoalValue('indice_qualidade');
                    const diff = goalValue ? qualityIndex - goalValue : 0;
                    
                    return goalValue && diff >= 0 ? (
                      <Badge className="bg-amber-100 text-amber-700 border-0 text-xs px-3 py-1 font-semibold">
                        <TrendingUp className="w-3 h-3 mr-1" />
                        +{diff.toFixed(1)}
                      </Badge>
                    ) : goalValue && diff < 0 ? (
                      <Badge className="bg-red-100 text-red-700 border-0 text-xs px-3 py-1 font-semibold">
                        <TrendingDown className="w-3 h-3 mr-1" />
                        {diff.toFixed(1)}
                      </Badge>
                    ) : null;
                  })()}
                </div>
                <div>
                  <p className="text-sm font-bold text-amber-600 mb-3 uppercase tracking-wider">Índice de Qualidade</p>
                  {(() => {
                    const completedOrders = (stats as any)?.completedWorkOrders || 0;
                    const qualityIndex = (stats as any)?.qualityIndex;
                    
                    if (completedOrders === 0 || qualityIndex === null || qualityIndex === undefined) {
                      return <p className="text-5xl font-black text-slate-400 mb-6">N/A</p>;
                    }
                    
                    return (
                      <p className="text-5xl font-black text-slate-900 mb-6">
                        {qualityIndex}<span className="text-3xl text-slate-500">/10</span>
                      </p>
                    );
                  })()}
                  <div className="relative">
                    <div className="h-3 bg-slate-100 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-gradient-to-r from-amber-500 to-orange-600 rounded-full shadow-lg shadow-amber-500/50 transition-all duration-1000"
                        style={{ width: `${((stats as any)?.completedWorkOrders || 0) > 0 ? ((stats as any)?.qualityIndex || 0) * 10 : 0}%` }}
                      ></div>
                    </div>
                  </div>
                  {(() => {
                    const goalValue = getGoalValue('indice_qualidade');
                    const ratedCount = (stats as any)?.ratedCount || 0;
                    const completedOrders = (stats as any)?.completedWorkOrders || 0;
                    
                    if (completedOrders === 0) {
                      return <p className="text-xs text-slate-500 mt-4 font-medium">Sem avaliações</p>;
                    }
                    
                    return goalValue ? (
                      <p className="text-xs text-slate-500 mt-4 font-medium">Meta: {goalValue}/10 • {ratedCount} avaliações</p>
                    ) : (
                      <p className="text-xs text-slate-500 mt-4 font-medium">{ratedCount} avaliações</p>
                    );
                  })()}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Charts Section */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Performance Trend */}
          <div className="group relative">
            <div className="absolute inset-0 bg-gradient-to-br from-blue-500/20 to-cyan-500/20 rounded-3xl blur-2xl"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-2xl border-0 shadow-2xl hover:shadow-blue-500/20 transition-all duration-500">
              <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-blue-500/10 to-transparent rounded-full blur-3xl"></div>
              <CardHeader className="border-b border-slate-100 pb-6">
                <CardTitle className="text-xl font-bold text-slate-900 flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-600 shadow-lg shadow-blue-500/50">
                    <Activity className="w-5 h-5 text-white" />
                  </div>
                  Tendência de Performance
                </CardTitle>
              </CardHeader>
              <CardContent className="p-8">
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={(analytics as any)?.daily || []}>
                    <defs>
                      <linearGradient id="performanceGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                        <stop offset="95%" stopColor="#06b6d4" stopOpacity={0.05}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                    <XAxis 
                      dataKey="date" 
                      stroke="#64748b"
                      tick={{ fontSize: 12, fill: '#475569' }}
                      tickFormatter={(value) => {
                        if (!value) return '';
                        const date = new Date(value);
                        return `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}`;
                      }}
                    />
                    <YAxis stroke="#64748b" tick={{ fontSize: 12, fill: '#475569' }} />
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'rgba(255,255,255,0.98)',
                        backdropFilter: 'blur(16px)',
                        border: '1px solid #e2e8f0',
                        borderRadius: '12px',
                        boxShadow: '0 10px 40px rgba(0,0,0,0.1)'
                      }}
                    />
                    <Area 
                      type="monotone" 
                      dataKey="efficiency" 
                      stroke="#3b82f6"
                      strokeWidth={3}
                      fill="url(#performanceGradient)"
                      name="Eficiência %"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>

          {/* Status Distribution */}
          <div className="group relative">
            <div className="absolute inset-0 bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-3xl blur-2xl"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-2xl border-0 shadow-2xl hover:shadow-purple-500/20 transition-all duration-500">
              <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-purple-500/10 to-transparent rounded-full blur-3xl"></div>
              <CardHeader className="border-b border-slate-100 pb-6">
                <CardTitle className="text-xl font-bold text-slate-900 flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-gradient-to-br from-purple-500 to-pink-600 shadow-lg shadow-purple-500/50">
                    <BarChart3 className="w-5 h-5 text-white" />
                  </div>
                  Distribuição de Status
                </CardTitle>
              </CardHeader>
              <CardContent className="p-8">
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={(analytics as any)?.statusBreakdown?.map((item: any) => ({
                        name: item.status === 'concluida' ? 'Concluídas' : 
                              item.status === 'aberta' ? 'Abertas' : 
                              item.status === 'vencida' ? 'Vencidas' : item.status,
                        value: item.count,
                        percentage: item.percentage
                      })) || []}
                      cx="50%"
                      cy="50%"
                      innerRadius={70}
                      outerRadius={110}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {((analytics as any)?.statusBreakdown || []).map((entry: any, index: number) => (
                        <Cell 
                          key={`cell-${index}`} 
                          fill={
                            entry.status === 'concluida' ? '#10b981' :
                            entry.status === 'em_andamento' ? '#3b82f6' :
                            entry.status === 'aberta' ? '#f59e0b' :
                            entry.status === 'vencida' ? '#ef4444' : '#6b7280'
                          }
                          className="hover:opacity-80 transition-opacity cursor-pointer"
                        />
                      ))}
                    </Pie>
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'rgba(255,255,255,0.98)',
                        backdropFilter: 'blur(16px)',
                        border: '1px solid #e2e8f0',
                        borderRadius: '12px',
                        boxShadow: '0 10px 40px rgba(0,0,0,0.1)'
                      }}
                    />
                  </PieChart>
                </ResponsiveContainer>
                <div className="mt-8 grid grid-cols-2 gap-4">
                  {((analytics as any)?.statusBreakdown || []).map((item: any, index: number) => (
                    <div key={index} className="flex items-center gap-3 p-4 rounded-xl bg-slate-50 border border-slate-100 hover:bg-slate-100 transition-all">
                      <div 
                        className="w-4 h-4 rounded-full flex-shrink-0 shadow-lg" 
                        style={{ 
                          backgroundColor: 
                            item.status === 'concluida' ? '#10b981' :
                            item.status === 'em_andamento' ? '#3b82f6' :
                            item.status === 'aberta' ? '#f59e0b' :
                            item.status === 'vencida' ? '#ef4444' : '#6b7280'
                        }}
                      />
                      <div className="flex-1 min-w-0">
                        <p className="text-xs text-slate-600 truncate font-medium">
                          {item.status === 'concluida' ? 'Concluídas' : 
                           item.status === 'aberta' ? 'Abertas' : 
                           item.status === 'vencida' ? 'Vencidas' : item.status}
                        </p>
                        <p className="text-lg font-bold text-slate-900">{item.count}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Sites Overview */}
        <div className="relative">
          <div className="absolute inset-0 bg-gradient-to-br from-slate-500/20 to-blue-500/20 rounded-3xl blur-2xl"></div>
          <Card className="relative overflow-hidden bg-white/95 backdrop-blur-2xl border-0 shadow-2xl">
            <div className="absolute top-0 right-0 w-96 h-96 bg-gradient-to-br from-blue-500/10 to-transparent rounded-full blur-3xl"></div>
            <CardHeader className="border-b border-slate-100 pb-6">
              <div className="flex items-center justify-between">
                <CardTitle className="text-xl font-bold text-slate-900 flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-gradient-to-br from-slate-600 to-blue-600 shadow-lg shadow-slate-500/50">
                    <Building className="w-5 h-5 text-white" />
                  </div>
                  Performance por Local
                </CardTitle>
                <Badge className="bg-slate-100 text-slate-700 border-0 px-4 py-2">
                  {(sites as any[] || []).length} {(sites as any[] || []).length === 1 ? 'Local' : 'Locais'}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="p-8">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {(sites as any[] || []).map((site: any) => {
                  const siteWorkOrders = (workOrders as any[] || []).filter((wo: any) => wo.siteId === site.id);
                  const totalOS = siteWorkOrders.length;
                  const concluidas = siteWorkOrders.filter((wo: any) => wo.status === 'concluida').length;
                  const abertas = siteWorkOrders.filter((wo: any) => wo.status === 'aberta').length;
                  const vencidas = siteWorkOrders.filter((wo: any) => wo.status === 'vencida').length;
                  const taxaConclusao = totalOS > 0 ? Math.round((concluidas / totalOS) * 100) : 0;
                  
                  return (
                    <div 
                      key={site.id}
                      className="group relative cursor-pointer"
                      onClick={() => {
                        setSelectedSite(site.id);
                        queryClient.invalidateQueries({ 
                          queryKey: [`/api/customers/${activeClientId}/dashboard-stats`] 
                        });
                      }}
                      data-testid={`site-card-${site.id}`}
                    >
                      <div className={`absolute inset-0 rounded-2xl blur-xl opacity-30 group-hover:opacity-50 transition-opacity ${
                        taxaConclusao >= 80 ? 'bg-gradient-to-br from-emerald-500 to-teal-500' :
                        taxaConclusao >= 60 ? 'bg-gradient-to-br from-blue-500 to-cyan-500' :
                        taxaConclusao >= 40 ? 'bg-gradient-to-br from-amber-500 to-orange-500' :
                        'bg-gradient-to-br from-red-500 to-pink-500'
                      }`}></div>
                      <div className="relative p-6 rounded-2xl bg-white/90 backdrop-blur-xl border border-slate-200 hover:bg-white transition-all duration-500 hover:-translate-y-2 hover:shadow-xl">
                        <div className="flex items-start justify-between mb-5">
                          <div className="flex-1">
                            <h4 className="font-bold text-slate-900 mb-2 text-lg">
                              {site.name}
                            </h4>
                            <p className="text-sm text-slate-500 font-medium">
                              {(zones as any[] || []).filter((z: any) => z.siteId === site.id).length} zonas
                            </p>
                          </div>
                          <div className={`p-3 rounded-xl shadow-lg ${
                            taxaConclusao >= 80 ? 'bg-gradient-to-br from-emerald-500 to-teal-600 shadow-emerald-500/50' :
                            taxaConclusao >= 60 ? 'bg-gradient-to-br from-blue-500 to-cyan-600 shadow-blue-500/50' :
                            taxaConclusao >= 40 ? 'bg-gradient-to-br from-amber-500 to-orange-600 shadow-amber-500/50' :
                            'bg-gradient-to-br from-red-500 to-pink-600 shadow-red-500/50'
                          }`}>
                            <Building className="w-5 h-5 text-white" />
                          </div>
                        </div>
                        
                        <div className="space-y-3 mb-5">
                          <div className="flex items-center justify-between text-sm">
                            <span className="text-slate-600 font-medium">Taxa de Conclusão</span>
                            <span className={`font-bold text-lg ${
                              taxaConclusao >= 80 ? 'text-emerald-600' :
                              taxaConclusao >= 60 ? 'text-blue-600' :
                              taxaConclusao >= 40 ? 'text-amber-600' : 'text-red-600'
                            }`}>
                              {taxaConclusao}%
                            </span>
                          </div>
                          <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                            <div 
                              className={`h-full rounded-full shadow-md transition-all duration-1000 ${
                                taxaConclusao >= 80 ? 'bg-gradient-to-r from-emerald-500 to-teal-600' :
                                taxaConclusao >= 60 ? 'bg-gradient-to-r from-blue-500 to-cyan-600' :
                                taxaConclusao >= 40 ? 'bg-gradient-to-r from-amber-500 to-orange-600' :
                                'bg-gradient-to-r from-red-500 to-pink-600'
                              }`}
                              style={{ width: `${taxaConclusao}%` }}
                            ></div>
                          </div>
                        </div>
                        
                        <div className="grid grid-cols-3 gap-3">
                          <div className="text-center bg-emerald-50 rounded-xl p-3 border border-emerald-100">
                            <div className="text-2xl font-black text-emerald-600">{concluidas}</div>
                            <div className="text-xs text-emerald-600 font-semibold mt-1">OK</div>
                          </div>
                          <div className="text-center bg-amber-50 rounded-xl p-3 border border-amber-100">
                            <div className="text-2xl font-black text-amber-600">{abertas}</div>
                            <div className="text-xs text-amber-600 font-semibold mt-1">Abertas</div>
                          </div>
                          <div className="text-center bg-red-50 rounded-xl p-3 border border-red-100">
                            <div className="text-2xl font-black text-red-600">{vencidas}</div>
                            <div className="text-xs text-red-600 font-semibold mt-1">Venc.</div>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
                
                {(sites as any[] || []).length === 0 && (
                  <div className="col-span-full text-center py-16">
                    <Building className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                    <p className="text-slate-500 text-lg font-medium">Nenhum local cadastrado</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Zone Performance */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Top Zones */}
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/20 to-teal-500/20 rounded-3xl blur-2xl"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-2xl border-0 shadow-2xl">
              <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-emerald-500/10 to-transparent rounded-full blur-3xl"></div>
              <CardHeader className="border-b border-slate-100 pb-6">
                <CardTitle className="text-xl font-bold text-slate-900 flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 shadow-lg shadow-emerald-500/50">
                    <TrendingUp className="w-5 h-5 text-white" />
                  </div>
                  Top Zonas
                </CardTitle>
              </CardHeader>
              <CardContent className="p-8">
                <div className="space-y-4">
                  {(() => {
                    const zonesWithStats = (zones as any[] || []).map((zone: any) => {
                      const zoneWorkOrders = (workOrders as any[] || []).filter((wo: any) => wo.zoneId === zone.id);
                      const total = zoneWorkOrders.length;
                      const concluidas = zoneWorkOrders.filter((wo: any) => wo.status === 'concluida').length;
                      const taxa = total > 0 ? Math.round((concluidas / total) * 100) : 0;
                      return { ...zone, totalOS: total, concluidas, taxa };
                    })
                    .filter(z => z.totalOS > 0)
                    .sort((a, b) => b.taxa - a.taxa)
                    .slice(0, 5);

                    if (zonesWithStats.length === 0) {
                      return (
                        <div className="text-center py-12">
                          <MapPin className="w-14 h-14 text-slate-300 mx-auto mb-3" />
                          <p className="text-slate-500 text-lg font-medium">Nenhuma zona com OSs</p>
                        </div>
                      );
                    }

                    return zonesWithStats.map((zone: any, index: number) => (
                      <div 
                        key={zone.id} 
                        className="group flex items-center justify-between p-5 rounded-2xl bg-slate-50 border border-slate-100 hover:bg-white hover:border-emerald-200 hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
                        data-testid={`top-zone-${zone.id}`}
                      >
                        <div className="flex items-center gap-4">
                          <div className={`relative w-14 h-14 rounded-xl flex items-center justify-center text-lg font-black text-white shadow-xl ${
                            index === 0 ? 'bg-gradient-to-br from-amber-400 via-yellow-500 to-amber-600' :
                            index === 1 ? 'bg-gradient-to-br from-slate-300 via-slate-400 to-slate-500' :
                            index === 2 ? 'bg-gradient-to-br from-orange-400 via-amber-500 to-orange-600' :
                            'bg-gradient-to-br from-emerald-500 to-teal-600'
                          }`}>
                            <span>#{index + 1}</span>
                          </div>
                          <div>
                            <div className="font-bold text-slate-900 text-lg mb-1">{zone.name}</div>
                            <div className="text-sm text-slate-500 font-medium">
                              {zone.concluidas}/{zone.totalOS} OSs concluídas
                            </div>
                          </div>
                        </div>
                        <div className="text-3xl font-black text-emerald-600">
                          {zone.taxa}%
                        </div>
                      </div>
                    ));
                  })()}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Attention Zones */}
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-br from-red-500/20 to-pink-500/20 rounded-3xl blur-2xl"></div>
            <Card className="relative overflow-hidden bg-white/95 backdrop-blur-2xl border-0 shadow-2xl">
              <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-red-500/10 to-transparent rounded-full blur-3xl"></div>
              <CardHeader className="border-b border-slate-100 pb-6">
                <CardTitle className="text-xl font-bold text-slate-900 flex items-center gap-3">
                  <div className="p-3 rounded-xl bg-gradient-to-br from-red-500 to-pink-600 shadow-lg shadow-red-500/50">
                    <AlertTriangle className="w-5 h-5 text-white" />
                  </div>
                  Zonas de Atenção
                </CardTitle>
              </CardHeader>
              <CardContent className="p-8">
                <div className="space-y-4">
                  {(() => {
                    const zonesWithStats = (zones as any[] || []).map((zone: any) => {
                      const zoneWorkOrders = (workOrders as any[] || []).filter((wo: any) => wo.zoneId === zone.id);
                      const total = zoneWorkOrders.length;
                      const vencidas = zoneWorkOrders.filter((wo: any) => wo.status === 'vencida').length;
                      const abertas = zoneWorkOrders.filter((wo: any) => wo.status === 'aberta').length;
                      return { ...zone, totalOS: total, vencidas, abertas };
                    })
                    .filter(z => z.vencidas > 0)
                    .sort((a, b) => b.vencidas - a.vencidas)
                    .slice(0, 5);

                    if (zonesWithStats.length === 0) {
                      return (
                        <div className="text-center py-12">
                          <div className="relative inline-block">
                            <div className="absolute inset-0 bg-emerald-500 rounded-full blur-xl opacity-30"></div>
                            <CheckCircle className="relative w-14 h-14 text-emerald-500 mx-auto mb-4" />
                          </div>
                          <p className="text-emerald-600 font-bold text-xl mb-2">Tudo em dia!</p>
                          <p className="text-slate-500 text-sm font-medium">Nenhuma zona com OSs vencidas</p>
                        </div>
                      );
                    }

                    return zonesWithStats.map((zone: any) => (
                      <div 
                        key={zone.id} 
                        className="group flex items-center justify-between p-5 rounded-2xl bg-slate-50 border border-slate-100 hover:bg-white hover:border-red-200 hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
                        data-testid={`attention-zone-${zone.id}`}
                      >
                        <div className="flex items-center gap-4">
                          <div className="relative w-14 h-14 rounded-xl bg-gradient-to-br from-red-500 to-pink-600 shadow-xl flex items-center justify-center">
                            <AlertTriangle className="w-7 h-7 text-white" />
                          </div>
                          <div>
                            <div className="font-bold text-slate-900 text-lg mb-1">{zone.name}</div>
                            <div className="text-sm text-slate-500 font-medium">
                              {zone.vencidas} vencidas • {zone.abertas} abertas
                            </div>
                          </div>
                        </div>
                        <div className="text-3xl font-black text-red-600">
                          {zone.vencidas}
                        </div>
                      </div>
                    ));
                  })()}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
