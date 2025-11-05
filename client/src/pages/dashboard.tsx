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
  ClipboardList,
  Target,
  Award,
  Activity,
  Gauge,
  BarChart3,
  FileText,
  Users
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
      <div className="h-full bg-gray-50 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="w-12 h-12 border-3 border-gray-200 border-t-blue-600 rounded-full animate-spin mx-auto"></div>
          <p className="text-sm text-gray-600">Carregando dados...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-auto bg-gray-50">
      {/* Header Corporativo */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
              <p className="text-sm text-gray-500 mt-1">Visão geral das operações</p>
            </div>
            
            {/* Filtros e Ações */}
            <div className="flex items-center gap-3">
              <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
                <SelectTrigger className="w-40 bg-white">
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
                <SelectTrigger className="w-48 bg-white">
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
        {/* KPIs Principais - Design Corporativo */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Eficiência Operacional */}
          <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="p-3 bg-emerald-50 rounded-lg">
                  <Gauge className="w-6 h-6 text-emerald-600" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('eficiencia_operacional');
                  if (!goalValue) return null;
                  const currentValue = (stats as any)?.efficiency || 0;
                  const diff = currentValue - goalValue;
                  return diff >= 0 ? (
                    <Badge variant="outline" className="bg-emerald-50 text-emerald-700 border-emerald-200">
                      <TrendingUp className="w-3 h-3 mr-1" />
                      +{diff.toFixed(1)}%
                    </Badge>
                  ) : (
                    <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
                      <TrendingDown className="w-3 h-3 mr-1" />
                      {diff.toFixed(1)}%
                    </Badge>
                  );
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">Eficiência Operacional</p>
                <p className="text-3xl font-bold text-gray-900">{(stats as any)?.efficiency || 0}%</p>
                <div className="mt-3">
                  <Progress value={(stats as any)?.efficiency || 0} className="h-2" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('eficiencia_operacional');
                  if (!goalValue) return null;
                  return (
                    <p className="text-xs text-gray-500 mt-2">Meta: {goalValue}%</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>

          {/* SLA Compliance */}
          <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="p-3 bg-blue-50 rounded-lg">
                  <Clock className="w-6 h-6 text-blue-600" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('sla_compliance');
                  if (!goalValue) return null;
                  const currentValue = (stats as any)?.slaCompliance || 0;
                  const diff = currentValue - goalValue;
                  return diff >= 0 ? (
                    <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">
                      <TrendingUp className="w-3 h-3 mr-1" />
                      +{diff.toFixed(1)}%
                    </Badge>
                  ) : (
                    <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
                      <TrendingDown className="w-3 h-3 mr-1" />
                      {diff.toFixed(1)}%
                    </Badge>
                  );
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">SLA Compliance</p>
                <p className="text-3xl font-bold text-gray-900">{(stats as any)?.slaCompliance || 0}%</p>
                <div className="mt-3">
                  <Progress value={(stats as any)?.slaCompliance || 0} className="h-2" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('sla_compliance');
                  if (!goalValue) return null;
                  return (
                    <p className="text-xs text-gray-500 mt-2">Meta: {goalValue}%</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>

          {/* OS Concluídas */}
          <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="p-3 bg-purple-50 rounded-lg">
                  <CheckCircle className="w-6 h-6 text-purple-600" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('os_concluidas_mes');
                  const currentValue = (stats as any)?.completedWorkOrders || 0;
                  if (goalValue && goalValue > 0) {
                    const diff = currentValue - goalValue;
                    return diff >= 0 ? (
                      <Badge variant="outline" className="bg-emerald-50 text-emerald-700 border-emerald-200">
                        <TrendingUp className="w-3 h-3 mr-1" />
                        +{diff}
                      </Badge>
                    ) : (
                      <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
                        <TrendingDown className="w-3 h-3 mr-1" />
                        {diff}
                      </Badge>
                    );
                  }
                  return null;
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">OS Concluídas</p>
                <p className="text-3xl font-bold text-gray-900">{(stats as any)?.completedWorkOrders || 0}</p>
                <div className="mt-3">
                  <Progress value={(stats as any)?.efficiency || 0} className="h-2" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('os_concluidas_mes');
                  const totalOrders = ((stats as any)?.completedWorkOrders || 0) + ((stats as any)?.openWorkOrders || 0);
                  return goalValue ? (
                    <p className="text-xs text-gray-500 mt-2">Meta: {goalValue}</p>
                  ) : (
                    <p className="text-xs text-gray-500 mt-2">Total: {totalOrders}</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>

          {/* Índice de Qualidade */}
          <Card className="bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div className="p-3 bg-amber-50 rounded-lg">
                  <Award className="w-6 h-6 text-amber-600" />
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
                    <Badge variant="outline" className="bg-amber-50 text-amber-700 border-amber-200">
                      <TrendingUp className="w-3 h-3 mr-1" />
                      +{diff.toFixed(1)}
                    </Badge>
                  ) : goalValue && diff < 0 ? (
                    <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
                      <TrendingDown className="w-3 h-3 mr-1" />
                      {diff.toFixed(1)}
                    </Badge>
                  ) : null;
                })()}
              </div>
              <div>
                <p className="text-sm font-medium text-gray-600 mb-1">Índice de Qualidade</p>
                {(() => {
                  const completedOrders = (stats as any)?.completedWorkOrders || 0;
                  const qualityIndex = (stats as any)?.qualityIndex;
                  
                  if (completedOrders === 0 || qualityIndex === null || qualityIndex === undefined) {
                    return <p className="text-3xl font-bold text-gray-400">N/A</p>;
                  }
                  
                  return <p className="text-3xl font-bold text-gray-900">{qualityIndex}/10</p>;
                })()}
                <div className="mt-3">
                  <Progress value={((stats as any)?.completedWorkOrders || 0) > 0 ? ((stats as any)?.qualityIndex || 0) * 10 : 0} className="h-2" />
                </div>
                {(() => {
                  const goalValue = getGoalValue('indice_qualidade');
                  const ratedCount = (stats as any)?.ratedCount || 0;
                  const completedOrders = (stats as any)?.completedWorkOrders || 0;
                  
                  if (completedOrders === 0) {
                    return <p className="text-xs text-gray-500 mt-2">Sem avaliações</p>;
                  }
                  
                  return goalValue ? (
                    <p className="text-xs text-gray-500 mt-2">Meta: {goalValue}/10 • {ratedCount} avaliações</p>
                  ) : (
                    <p className="text-xs text-gray-500 mt-2">{ratedCount} avaliações</p>
                  );
                })()}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Seção de Gráficos */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Tendência de Performance */}
          <Card className="bg-white border border-gray-200 shadow-sm">
            <CardHeader className="border-b border-gray-100 pb-4">
              <CardTitle className="text-lg font-semibold text-gray-900 flex items-center">
                <Activity className="w-5 h-5 mr-2 text-blue-600" />
                Tendência de Performance
              </CardTitle>
            </CardHeader>
            <CardContent className="p-6">
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={(analytics as any)?.daily || []}>
                  <defs>
                    <linearGradient id="performanceGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#2563eb" stopOpacity={0.1}/>
                      <stop offset="95%" stopColor="#2563eb" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis 
                    dataKey="date" 
                    stroke="#9ca3af"
                    tick={{ fontSize: 12 }}
                    tickFormatter={(value) => {
                      if (!value) return '';
                      const date = new Date(value);
                      return `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}`;
                    }}
                  />
                  <YAxis stroke="#9ca3af" tick={{ fontSize: 12 }} />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e5e7eb',
                      borderRadius: '8px',
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                    }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="efficiency" 
                    stroke="#2563eb" 
                    strokeWidth={2}
                    fill="url(#performanceGradient)"
                    name="Eficiência %"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Distribuição de Status */}
          <Card className="bg-white border border-gray-200 shadow-sm">
            <CardHeader className="border-b border-gray-100 pb-4">
              <CardTitle className="text-lg font-semibold text-gray-900 flex items-center">
                <BarChart3 className="w-5 h-5 mr-2 text-purple-600" />
                Status das Ordens de Serviço
              </CardTitle>
            </CardHeader>
            <CardContent className="p-6">
              <div className="flex items-center justify-center">
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
                      innerRadius={60}
                      outerRadius={100}
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
                        border: '1px solid #e5e7eb',
                        borderRadius: '8px',
                        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                      }}
                    />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-6 space-y-2">
                {((analytics as any)?.statusBreakdown || []).map((item: any, index: number) => (
                  <div key={index} className="flex items-center justify-between text-sm">
                    <div className="flex items-center">
                      <div 
                        className="w-3 h-3 rounded-full mr-2" 
                        style={{ 
                          backgroundColor: 
                            item.status === 'concluida' ? '#10b981' :
                            item.status === 'em_andamento' ? '#3b82f6' :
                            item.status === 'aberta' ? '#f59e0b' :
                            item.status === 'vencida' ? '#ef4444' : '#6b7280'
                        }}
                      />
                      <span className="text-gray-700">
                        {item.status === 'concluida' ? 'Concluídas' : 
                         item.status === 'aberta' ? 'Abertas' : 
                         item.status === 'vencida' ? 'Vencidas' : item.status}
                      </span>
                    </div>
                    <span className="font-semibold text-gray-900">{item.count} ({item.percentage}%)</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Resumo de Locais */}
        <Card className="bg-white border border-gray-200 shadow-sm">
          <CardHeader className="border-b border-gray-100 pb-4">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg font-semibold text-gray-900 flex items-center">
                <Building className="w-5 h-5 mr-2 text-slate-600" />
                Resumo por Local
              </CardTitle>
              <Badge variant="outline" className="bg-gray-50">
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
                    className="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:shadow-sm transition-all cursor-pointer bg-white"
                    onClick={() => {
                      setSelectedSite(site.id);
                      queryClient.invalidateQueries({ 
                        queryKey: [`/api/customers/${activeClientId}/dashboard-stats`] 
                      });
                    }}
                    data-testid={`site-card-${site.id}`}
                  >
                    <div className="flex items-center justify-between mb-3">
                      <h4 className="font-semibold text-gray-900 text-sm">{site.name}</h4>
                      <Badge variant="outline" className="text-xs">
                        {(zones as any[] || []).filter((z: any) => z.siteId === site.id).length} zonas
                      </Badge>
                    </div>
                    
                    <div className="space-y-2">
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-gray-600">Taxa de Conclusão</span>
                        <span className={`font-semibold ${
                          taxaConclusao >= 80 ? 'text-emerald-600' :
                          taxaConclusao >= 60 ? 'text-blue-600' :
                          taxaConclusao >= 40 ? 'text-amber-600' : 'text-red-600'
                        }`}>
                          {taxaConclusao}%
                        </span>
                      </div>
                      <Progress value={taxaConclusao} className="h-1.5" />
                    </div>
                    
                    <div className="grid grid-cols-3 gap-2 mt-3">
                      <div className="text-center bg-emerald-50 rounded p-2">
                        <div className="text-sm font-bold text-emerald-700">{concluidas}</div>
                        <div className="text-xs text-emerald-600">OK</div>
                      </div>
                      <div className="text-center bg-amber-50 rounded p-2">
                        <div className="text-sm font-bold text-amber-700">{abertas}</div>
                        <div className="text-xs text-amber-600">Abertas</div>
                      </div>
                      <div className="text-center bg-red-50 rounded p-2">
                        <div className="text-sm font-bold text-red-700">{vencidas}</div>
                        <div className="text-xs text-red-600">Venc.</div>
                      </div>
                    </div>
                  </div>
                );
              })}
              
              {(sites as any[] || []).length === 0 && (
                <div className="col-span-full text-center py-12">
                  <Building className="w-12 h-12 text-gray-300 mx-auto mb-3" />
                  <p className="text-gray-500 text-sm">Nenhum local cadastrado</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Performance por Zona */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Top Zonas */}
          <Card className="bg-white border border-gray-200 shadow-sm">
            <CardHeader className="border-b border-gray-100 pb-4">
              <CardTitle className="text-lg font-semibold text-gray-900 flex items-center">
                <TrendingUp className="w-5 h-5 mr-2 text-emerald-600" />
                Top Zonas - Melhor Performance
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
                        <MapPin className="w-10 h-10 text-gray-300 mx-auto mb-2" />
                        <p className="text-gray-500 text-sm">Nenhuma zona com OSs</p>
                      </div>
                    );
                  }

                  return zonesWithStats.map((zone: any, index: number) => (
                    <div 
                      key={zone.id} 
                      className="flex items-center justify-between p-3 border border-gray-100 rounded-lg hover:border-emerald-200 hover:bg-emerald-50/30 transition-all"
                      data-testid={`top-zone-${zone.id}`}
                    >
                      <div className="flex items-center gap-3">
                        <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold text-white ${
                          index === 0 ? 'bg-amber-500' :
                          index === 1 ? 'bg-gray-400' :
                          index === 2 ? 'bg-orange-500' :
                          'bg-emerald-500'
                        }`}>
                          #{index + 1}
                        </div>
                        <div>
                          <div className="font-medium text-gray-900 text-sm">{zone.name}</div>
                          <div className="text-xs text-gray-500">
                            {zone.concluidas}/{zone.totalOS} OSs concluídas
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-xl font-bold text-emerald-600">{zone.taxa}%</div>
                      </div>
                    </div>
                  ));
                })()}
              </div>
            </CardContent>
          </Card>

          {/* Zonas de Atenção */}
          <Card className="bg-white border border-gray-200 shadow-sm">
            <CardHeader className="border-b border-gray-100 pb-4">
              <CardTitle className="text-lg font-semibold text-gray-900 flex items-center">
                <AlertTriangle className="w-5 h-5 mr-2 text-red-600" />
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
                        <CheckCircle className="w-10 h-10 text-emerald-400 mx-auto mb-2" />
                        <p className="text-emerald-600 font-medium text-sm">Tudo em dia!</p>
                        <p className="text-gray-500 text-xs mt-1">Nenhuma zona com OSs vencidas</p>
                      </div>
                    );
                  }

                  return zonesWithStats.map((zone: any) => (
                    <div 
                      key={zone.id} 
                      className="flex items-center justify-between p-3 border border-gray-100 rounded-lg hover:border-red-200 hover:bg-red-50/30 transition-all"
                      data-testid={`attention-zone-${zone.id}`}
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-red-100 flex items-center justify-center">
                          <AlertTriangle className="w-4 h-4 text-red-600" />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900 text-sm">{zone.name}</div>
                          <div className="text-xs text-gray-500">
                            {zone.vencidas} vencidas • {zone.abertas} abertas
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-xl font-bold text-red-600">{zone.vencidas}</div>
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
  );
}
