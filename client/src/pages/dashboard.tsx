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
  Area
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
  Target,
  Award,
  Activity,
  Gauge,
  BarChart3,
  Zap,
  Star
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
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="relative">
            <div className="w-16 h-16 border-4 border-blue-100 border-t-blue-600 rounded-full animate-spin mx-auto"></div>
          </div>
          <p className="text-sm font-medium text-slate-600">Carregando dados...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Clean Modern Header */}
      <div className="bg-white border-b border-slate-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-5">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-slate-900">Dashboard</h1>
              <p className="text-sm text-slate-500 mt-0.5">Visão geral e métricas em tempo real</p>
            </div>
            
            <div className="flex items-center gap-3">
              <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
                <SelectTrigger className="w-40 h-9">
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
                <SelectTrigger className="w-48 h-9">
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

              <Button 
                variant="outline" 
                size="sm"
                className="h-9"
                onClick={() => {
                  setIsRefreshing(true);
                  if (activeClientId) {
                    queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId] });
                  }
                  setTimeout(() => setIsRefreshing(false), 1000);
                }}
                data-testid="button-refresh"
              >
                <RefreshCcw className={`w-4 h-4 mr-2 ${isRefreshing ? 'animate-spin' : ''}`} />
                Atualizar
              </Button>

              <Button 
                variant="outline" 
                size="sm"
                className="h-9"
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
      <div className="max-w-7xl mx-auto p-6 space-y-6">
        {/* Clean KPI Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
          {/* Eficiência Operacional */}
          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-600 flex items-center justify-center shadow-sm">
                  <Zap className="w-6 h-6 text-white" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('eficiencia_operacional');
                  if (!goalValue) return null;
                  const currentValue = (stats as any)?.efficiency || 0;
                  const diff = currentValue - goalValue;
                  return diff >= 0 ? (
                    <Badge variant="secondary" className="bg-emerald-50 text-emerald-700 hover:bg-emerald-50 border-0">
                      <TrendingUp className="w-3 h-3 mr-1" />
                      +{diff.toFixed(1)}%
                    </Badge>
                  ) : (
                    <Badge variant="secondary" className="bg-red-50 text-red-700 hover:bg-red-50 border-0">
                      <TrendingDown className="w-3 h-3 mr-1" />
                      {diff.toFixed(1)}%
                    </Badge>
                  );
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600 mb-2">Eficiência Operacional</p>
                <p className="text-3xl font-bold text-slate-900 mb-4">
                  {(stats as any)?.efficiency || 0}%
                </p>
                <Progress value={(stats as any)?.efficiency || 0} className="h-1.5" />
                {(() => {
                  const goalValue = getGoalValue('eficiencia_operacional');
                  if (!goalValue) return null;
                  return (
                    <p className="text-xs text-slate-500 mt-3">Meta: {goalValue}%</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>

          {/* SLA Compliance */}
          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-sm">
                  <Clock className="w-6 h-6 text-white" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('sla_compliance');
                  if (!goalValue) return null;
                  const currentValue = (stats as any)?.slaCompliance || 0;
                  const diff = currentValue - goalValue;
                  return diff >= 0 ? (
                    <Badge variant="secondary" className="bg-blue-50 text-blue-700 hover:bg-blue-50 border-0">
                      <TrendingUp className="w-3 h-3 mr-1" />
                      +{diff.toFixed(1)}%
                    </Badge>
                  ) : (
                    <Badge variant="secondary" className="bg-red-50 text-red-700 hover:bg-red-50 border-0">
                      <TrendingDown className="w-3 h-3 mr-1" />
                      {diff.toFixed(1)}%
                    </Badge>
                  );
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600 mb-2">SLA Compliance</p>
                <p className="text-3xl font-bold text-slate-900 mb-4">
                  {(stats as any)?.slaCompliance || 0}%
                </p>
                <Progress value={(stats as any)?.slaCompliance || 0} className="h-1.5" />
                {(() => {
                  const goalValue = getGoalValue('sla_compliance');
                  if (!goalValue) return null;
                  return (
                    <p className="text-xs text-slate-500 mt-3">Meta: {goalValue}%</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>

          {/* OS Concluídas */}
          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center shadow-sm">
                  <CheckCircle className="w-6 h-6 text-white" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('os_concluidas_mes');
                  const currentValue = (stats as any)?.completedWorkOrders || 0;
                  if (goalValue && goalValue > 0) {
                    const diff = currentValue - goalValue;
                    return diff >= 0 ? (
                      <Badge variant="secondary" className="bg-purple-50 text-purple-700 hover:bg-purple-50 border-0">
                        <TrendingUp className="w-3 h-3 mr-1" />
                        +{diff}
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="bg-red-50 text-red-700 hover:bg-red-50 border-0">
                        <TrendingDown className="w-3 h-3 mr-1" />
                        {diff}
                      </Badge>
                    );
                  }
                  return null;
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600 mb-2">OS Concluídas</p>
                <p className="text-3xl font-bold text-slate-900 mb-4">
                  {(stats as any)?.completedWorkOrders || 0}
                </p>
                <Progress value={(stats as any)?.efficiency || 0} className="h-1.5" />
                {(() => {
                  const goalValue = getGoalValue('os_concluidas_mes');
                  const totalOrders = ((stats as any)?.completedWorkOrders || 0) + ((stats as any)?.openWorkOrders || 0);
                  return goalValue ? (
                    <p className="text-xs text-slate-500 mt-3">Meta: {goalValue}</p>
                  ) : (
                    <p className="text-xs text-slate-500 mt-3">Total: {totalOrders}</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>

          {/* Índice de Qualidade */}
          <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-500 to-amber-600 flex items-center justify-center shadow-sm">
                  <Star className="w-6 h-6 text-white" />
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
                    <Badge variant="secondary" className="bg-amber-50 text-amber-700 hover:bg-amber-50 border-0">
                      <TrendingUp className="w-3 h-3 mr-1" />
                      +{diff.toFixed(1)}
                    </Badge>
                  ) : goalValue && diff < 0 ? (
                    <Badge variant="secondary" className="bg-red-50 text-red-700 hover:bg-red-50 border-0">
                      <TrendingDown className="w-3 h-3 mr-1" />
                      {diff.toFixed(1)}
                    </Badge>
                  ) : null;
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-slate-600 mb-2">Índice de Qualidade</p>
                {(() => {
                  const completedOrders = (stats as any)?.completedWorkOrders || 0;
                  const qualityIndex = (stats as any)?.qualityIndex;
                  
                  if (completedOrders === 0 || qualityIndex === null || qualityIndex === undefined) {
                    return <p className="text-3xl font-bold text-slate-400 mb-4">N/A</p>;
                  }
                  
                  return (
                    <p className="text-3xl font-bold text-slate-900 mb-4">
                      {qualityIndex}<span className="text-xl text-slate-500">/10</span>
                    </p>
                  );
                })()}
                <Progress value={((stats as any)?.completedWorkOrders || 0) > 0 ? ((stats as any)?.qualityIndex || 0) * 10 : 0} className="h-1.5" />
                {(() => {
                  const goalValue = getGoalValue('indice_qualidade');
                  const ratedCount = (stats as any)?.ratedCount || 0;
                  const completedOrders = (stats as any)?.completedWorkOrders || 0;
                  
                  if (completedOrders === 0) {
                    return <p className="text-xs text-slate-500 mt-3">Sem avaliações</p>;
                  }
                  
                  return goalValue ? (
                    <p className="text-xs text-slate-500 mt-3">Meta: {goalValue}/10 • {ratedCount} avaliações</p>
                  ) : (
                    <p className="text-xs text-slate-500 mt-3">{ratedCount} avaliações</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {/* Performance Trend */}
          <Card className="border-0 shadow-sm">
            <CardHeader className="border-b border-slate-100">
              <CardTitle className="text-base font-semibold text-slate-900 flex items-center gap-2">
                <Activity className="w-4 h-4 text-slate-600" />
                Tendência de Performance
              </CardTitle>
            </CardHeader>
            <CardContent className="p-6">
              <ResponsiveContainer width="100%" height={280}>
                <AreaChart data={(analytics as any)?.daily || []}>
                  <defs>
                    <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.1}/>
                      <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                  <XAxis 
                    dataKey="date" 
                    stroke="#94a3b8"
                    tick={{ fontSize: 12, fill: '#64748b' }}
                    axisLine={{ stroke: '#e2e8f0' }}
                    tickFormatter={(value) => {
                      if (!value) return '';
                      const date = new Date(value);
                      return `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}`;
                    }}
                  />
                  <YAxis 
                    stroke="#94a3b8" 
                    tick={{ fontSize: 12, fill: '#64748b' }}
                    axisLine={{ stroke: '#e2e8f0' }}
                  />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '8px',
                      boxShadow: '0 4px 12px rgba(0,0,0,0.08)'
                    }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="efficiency" 
                    stroke="#3b82f6" 
                    strokeWidth={2}
                    fill="url(#areaGradient)"
                    name="Eficiência %"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Status Distribution */}
          <Card className="border-0 shadow-sm">
            <CardHeader className="border-b border-slate-100">
              <CardTitle className="text-base font-semibold text-slate-900 flex items-center gap-2">
                <BarChart3 className="w-4 h-4 text-slate-600" />
                Distribuição de Status
              </CardTitle>
            </CardHeader>
            <CardContent className="p-6">
              <ResponsiveContainer width="100%" height={280}>
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
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={2}
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
                      />
                    ))}
                  </Pie>
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '8px',
                      boxShadow: '0 4px 12px rgba(0,0,0,0.08)'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
              <div className="mt-6 grid grid-cols-2 gap-3">
                {((analytics as any)?.statusBreakdown || []).map((item: any, index: number) => (
                  <div key={index} className="flex items-center gap-2">
                    <div 
                      className="w-3 h-3 rounded-full flex-shrink-0" 
                      style={{ 
                        backgroundColor: 
                          item.status === 'concluida' ? '#10b981' :
                          item.status === 'em_andamento' ? '#3b82f6' :
                          item.status === 'aberta' ? '#f59e0b' :
                          item.status === 'vencida' ? '#ef4444' : '#6b7280'
                      }}
                    />
                    <span className="text-xs text-slate-600">
                      {item.status === 'concluida' ? 'Concluídas' : 
                       item.status === 'aberta' ? 'Abertas' : 
                       item.status === 'vencida' ? 'Vencidas' : item.status}: {item.count}
                    </span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Sites Overview */}
        <Card className="border-0 shadow-sm">
          <CardHeader className="border-b border-slate-100">
            <div className="flex items-center justify-between">
              <CardTitle className="text-base font-semibold text-slate-900 flex items-center gap-2">
                <Building className="w-4 h-4 text-slate-600" />
                Performance por Local
              </CardTitle>
              <Badge variant="secondary" className="bg-slate-100 text-slate-700 hover:bg-slate-100">
                {(sites as any[] || []).length} {(sites as any[] || []).length === 1 ? 'Local' : 'Locais'}
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
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
                    className="p-4 rounded-lg border border-slate-200 hover:border-blue-300 hover:shadow-sm transition-all cursor-pointer bg-white"
                    onClick={() => {
                      setSelectedSite(site.id);
                      queryClient.invalidateQueries({ 
                        queryKey: [`/api/customers/${activeClientId}/dashboard-stats`] 
                      });
                    }}
                    data-testid={`site-card-${site.id}`}
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1">
                        <h4 className="font-semibold text-slate-900 mb-1">{site.name}</h4>
                        <p className="text-xs text-slate-500">
                          {(zones as any[] || []).filter((z: any) => z.siteId === site.id).length} zonas
                        </p>
                      </div>
                      <Badge variant="secondary" className={`${
                        taxaConclusao >= 80 ? 'bg-emerald-50 text-emerald-700' :
                        taxaConclusao >= 60 ? 'bg-blue-50 text-blue-700' :
                        taxaConclusao >= 40 ? 'bg-amber-50 text-amber-700' : 'bg-red-50 text-red-700'
                      } hover:${
                        taxaConclusao >= 80 ? 'bg-emerald-50' :
                        taxaConclusao >= 60 ? 'bg-blue-50' :
                        taxaConclusao >= 40 ? 'bg-amber-50' : 'bg-red-50'
                      }`}>
                        {taxaConclusao}%
                      </Badge>
                    </div>
                    
                    <Progress value={taxaConclusao} className="h-1.5 mb-3" />
                    
                    <div className="grid grid-cols-3 gap-2">
                      <div className="text-center bg-slate-50 rounded-md p-2">
                        <div className="text-lg font-bold text-emerald-600">{concluidas}</div>
                        <div className="text-xs text-slate-600">OK</div>
                      </div>
                      <div className="text-center bg-slate-50 rounded-md p-2">
                        <div className="text-lg font-bold text-amber-600">{abertas}</div>
                        <div className="text-xs text-slate-600">Abertas</div>
                      </div>
                      <div className="text-center bg-slate-50 rounded-md p-2">
                        <div className="text-lg font-bold text-red-600">{vencidas}</div>
                        <div className="text-xs text-slate-600">Venc.</div>
                      </div>
                    </div>
                  </div>
                );
              })}
              
              {(sites as any[] || []).length === 0 && (
                <div className="col-span-full text-center py-12">
                  <Building className="w-12 h-12 text-slate-300 mx-auto mb-3" />
                  <p className="text-slate-500 text-sm">Nenhum local cadastrado</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Zone Performance */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {/* Top Zones */}
          <Card className="border-0 shadow-sm">
            <CardHeader className="border-b border-slate-100">
              <CardTitle className="text-base font-semibold text-slate-900 flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-slate-600" />
                Top Zonas
              </CardTitle>
            </CardHeader>
            <CardContent className="p-6">
              <div className="space-y-3">
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
                      <div className="text-center py-8">
                        <MapPin className="w-10 h-10 text-slate-300 mx-auto mb-2" />
                        <p className="text-slate-500 text-sm">Nenhuma zona com OSs</p>
                      </div>
                    );
                  }

                  return zonesWithStats.map((zone: any, index: number) => (
                    <div 
                      key={zone.id} 
                      className="flex items-center justify-between p-4 rounded-lg bg-slate-50 hover:bg-slate-100 transition-colors"
                      data-testid={`top-zone-${zone.id}`}
                    >
                      <div className="flex items-center gap-3">
                        <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-sm font-bold text-white ${
                          index === 0 ? 'bg-amber-500' :
                          index === 1 ? 'bg-slate-400' :
                          index === 2 ? 'bg-orange-500' :
                          'bg-emerald-500'
                        }`}>
                          #{index + 1}
                        </div>
                        <div>
                          <div className="font-medium text-slate-900 text-sm">{zone.name}</div>
                          <div className="text-xs text-slate-500">
                            {zone.concluidas}/{zone.totalOS} OSs concluídas
                          </div>
                        </div>
                      </div>
                      <div className="text-xl font-bold text-emerald-600">{zone.taxa}%</div>
                    </div>
                  ));
                })()}
              </div>
            </CardContent>
          </Card>

          {/* Attention Zones */}
          <Card className="border-0 shadow-sm">
            <CardHeader className="border-b border-slate-100">
              <CardTitle className="text-base font-semibold text-slate-900 flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 text-slate-600" />
                Zonas de Atenção
              </CardTitle>
            </CardHeader>
            <CardContent className="p-6">
              <div className="space-y-3">
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
                      <div className="text-center py-8">
                        <CheckCircle className="w-10 h-10 text-emerald-500 mx-auto mb-2" />
                        <p className="text-emerald-600 font-medium text-sm">Tudo em dia!</p>
                        <p className="text-slate-500 text-xs mt-1">Nenhuma zona com OSs vencidas</p>
                      </div>
                    );
                  }

                  return zonesWithStats.map((zone: any) => (
                    <div 
                      key={zone.id} 
                      className="flex items-center justify-between p-4 rounded-lg bg-slate-50 hover:bg-slate-100 transition-colors"
                      data-testid={`attention-zone-${zone.id}`}
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-red-500 flex items-center justify-center">
                          <AlertTriangle className="w-4 h-4 text-white" />
                        </div>
                        <div>
                          <div className="font-medium text-slate-900 text-sm">{zone.name}</div>
                          <div className="text-xs text-slate-500">
                            {zone.vencidas} vencidas • {zone.abertas} abertas
                          </div>
                        </div>
                      </div>
                      <div className="text-xl font-bold text-red-600">{zone.vencidas}</div>
                    </div>
                  ));
                })()}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
