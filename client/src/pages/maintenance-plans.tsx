import { ModernCard, ModernCardContent, ModernCardHeader } from "@/components/ui/modern-card";
import { ModernPageHeader } from "@/components/ui/modern-page-header";
import { useModuleTheme } from "@/hooks/use-module-theme";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { useQuery } from "@tanstack/react-query";
import { useState, useMemo } from "react";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { useLocation } from "wouter";
import { cn } from "@/lib/utils";
import { 
  Plus, 
  Calendar, 
  Clock, 
  MapPin,
  Eye,
  Edit,
  Copy,
  Trash2,
  ChevronLeft,
  ChevronRight,
  User,
  Timer,
  Save,
  Settings,
  Wrench,
  RefreshCw,
  CalendarRange
} from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { useEffect } from "react";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Checkbox } from "@/components/ui/checkbox";
import { ChevronDown } from "lucide-react";

export default function MaintenancePlans() {
  const { activeClientId } = useClient();
  const { currentModule } = useModule();
  const theme = useModuleTheme();
  const queryClient = useQueryClient();
  const { toast } = useToast();
  const [, setLocation] = useLocation();

  const [viewMode, setViewMode] = useState<"monthly" | "list">("monthly");
  const [siteFilter, setSiteFilter] = useState("todos");
  const [currentDate, setCurrentDate] = useState(new Date());
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showDayDetailsModal, setShowDayDetailsModal] = useState(false);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [selectedActivities, setSelectedActivities] = useState<any[]>([]);
  const [showActivityDetailsModal, setShowActivityDetailsModal] = useState(false);
  const [showEditActivityModal, setShowEditActivityModal] = useState(false);
  const [selectedActivity, setSelectedActivity] = useState<any>(null);
  const [selectedForDeletion, setSelectedForDeletion] = useState<string[]>([]);

  const { data: activities, isLoading } = useQuery({
    queryKey: ["/api/customers", activeClientId, "maintenance-activities"],
    enabled: !!activeClientId,
  });

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", activeClientId, "sites", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: zones } = useQuery({
    queryKey: ["/api/customers", activeClientId, "zones", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: users } = useQuery({
    queryKey: ["/api/customers", activeClientId, "users"],
    enabled: !!activeClientId,
  });

  const { data: equipment } = useQuery({
    queryKey: ["/api/customers", activeClientId, "equipment"],
    enabled: !!activeClientId,
  });

  // Redirect if not in maintenance module
  useEffect(() => {
    if (currentModule !== 'maintenance') {
      setLocation('/');
    }
  }, [currentModule, setLocation]);

  // Mutation to delete maintenance activity
  const deleteMaintenanceActivityMutation = useMutation({
    mutationFn: async (activityId: string) => {
      await apiRequest('DELETE', `/api/maintenance-activities/${activityId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "maintenance-activities"] });
      toast({
        title: "Atividade excluída",
        description: "A atividade de manutenção foi removida com sucesso.",
      });
    },
    onError: () => {
      toast({
        title: "Erro",
        description: "Não foi possível excluir a atividade.",
        variant: "destructive",
      });
    },
  });

  const handleDeleteActivity = async (activity: any) => {
    if (confirm(`Deseja realmente excluir a atividade "${activity.name}"? Esta ação não pode ser desfeita.`)) {
      await deleteMaintenanceActivityMutation.mutateAsync(activity.id);
    }
  };

  // Mutation para gerar OSs manualmente (teste)
  const generateWorkOrdersMutation = useMutation({
    mutationFn: async () => {
      const response = await apiRequest('POST', '/api/scheduler/regenerate-monthly-maintenance', {});
      return response;
    },
    onSuccess: (data: any) => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "work-orders"] });
      toast({
        title: "OSs geradas com sucesso!",
        description: `${data.totalGenerated} ordens de serviço foram criadas para o próximo mês.`,
      });
    },
    onError: () => {
      toast({
        title: "Erro ao gerar OSs",
        description: "Ocorreu um erro ao gerar as ordens de serviço.",
        variant: "destructive",
      });
    },
  });

  const getFrequencyBadge = (frequency: string) => {
    switch (frequency) {
      case "diaria":
        return <Badge className="bg-chart-2/10 text-chart-2">Diária</Badge>;
      case "semanal":
        return <Badge className="bg-chart-4/10 text-chart-4">Semanal</Badge>;
      case "mensal":
        return <Badge className="bg-primary/10 text-primary">Mensal</Badge>;
      case "trimestral":
        return <Badge className="bg-indigo-100/80 text-indigo-700">Trimestral</Badge>;
      case "semestral":
        return <Badge className="bg-violet-100/80 text-violet-700">Semestral</Badge>;
      case "anual":
        return <Badge className="bg-rose-100/80 text-rose-700">Anual</Badge>;
      case "turno":
        return <Badge className="bg-chart-1/10 text-chart-1">Por Turno</Badge>;
      default:
        return <Badge variant="outline">Personalizada</Badge>;
    }
  };

  const getTypeBadge = (type: string) => {
    switch (type) {
      case "preventiva":
        return <Badge className="bg-green-100/80 text-green-700">Preventiva</Badge>;
      case "preditiva":
        return <Badge className="bg-blue-100/80 text-blue-700">Preditiva</Badge>;
      case "corretiva":
        return <Badge className="bg-orange-100/80 text-orange-700">Corretiva</Badge>;
      default:
        return <Badge variant="outline">Não definido</Badge>;
    }
  };

  // Função para gerar o calendário mensal
  const generateMonthCalendar = () => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const firstDayOfWeek = firstDay.getDay(); // 0 = domingo
    const daysInMonth = lastDay.getDate();
    
    const calendar = [];
    let day = 1;
    
    // Criar as semanas do mês
    for (let week = 0; week < 6; week++) {
      const weekDays = [];
      
      for (let dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        if (week === 0 && dayOfWeek < firstDayOfWeek) {
          // Dias vazios antes do primeiro dia do mês
          weekDays.push(null);
        } else if (day > daysInMonth) {
          // Dias vazios depois do último dia do mês
          weekDays.push(null);
        } else {
          // Dias válidos do mês
          weekDays.push(day);
          day++;
        }
      }
      
      calendar.push(weekDays);
      
      // Se todos os dias do mês já foram adicionados, parar
      if (day > daysInMonth) break;
    }
    
    return calendar;
  };

  // Função para obter zona por ID
  const getZoneName = (zoneId: string) => {
    const zone = (zones as any[] || []).find((z: any) => z.id === zoneId);
    return zone?.name || 'Local não encontrado';
  };

  // Função para obter responsável por ID
  const getAssignedUserName = (userId: string) => {
    const user = (users as any[] || []).find((u: any) => u.id === userId);
    return user?.name || 'Não atribuído';
  };

  // Função para obter SLA baseado no tipo de atividade
  const getSLAForActivity = (activity: any) => {
    return `${activity.slaMinutes || 60}min`;
  };

  // Função para obter equipamentos relacionados a uma zona
  const getEquipmentForZone = (zoneId: string) => {
    return (equipment as any[] || []).filter((e: any) => e.zoneId === zoneId);
  };

  // Função para obter nomes dos equipamentos por IDs
  const getEquipmentNames = (equipmentIds: string[]) => {
    if (!equipmentIds || equipmentIds.length === 0) return [];
    return (equipment as any[] || [])
      .filter((e: any) => equipmentIds.includes(e.id))
      .map((e: any) => e.name);
  };

  // Função para calcular próxima data de execução
  const getNextExecutionDate = (activity: any) => {
    const now = new Date();
    const lastExecution = activity.lastExecutedAt ? new Date(activity.lastExecutedAt) : null;
    
    if (!lastExecution) return 'Nunca executado';
    
    let nextDate = new Date(lastExecution);
    
    switch (activity.frequency) {
      case 'diaria':
        nextDate.setDate(nextDate.getDate() + 1);
        break;
      case 'semanal':
        nextDate.setDate(nextDate.getDate() + 7);
        break;
      case 'mensal':
        nextDate.setMonth(nextDate.getMonth() + 1);
        break;
      case 'trimestral':
        nextDate.setMonth(nextDate.getMonth() + 3);
        break;
      case 'semestral':
        nextDate.setMonth(nextDate.getMonth() + 6);
        break;
      case 'anual':
        nextDate.setFullYear(nextDate.getFullYear() + 1);
        break;
      default:
        return 'Frequência personalizada';
    }
    
    return nextDate.toLocaleDateString('pt-BR');
  };

  // Função para obter atividades de um dia específico
  const getActivitiesForDay = (day: number) => {
    if (!activities) return [];
    
    return (activities as any[]).filter((activity: any) => {
      if (activity.frequency === 'diaria') return true;
      if (activity.frequency === 'semanal') {
        const dayOfWeek = new Date(currentDate.getFullYear(), currentDate.getMonth(), day).getDay();
        const weekDays = activity.frequencyConfig?.weekDays || [];
        const dayMap: Record<string, number> = {
          'domingo': 0, 'segunda': 1, 'terca': 2, 'quarta': 3,
          'quinta': 4, 'sexta': 5, 'sabado': 6
        };
        return weekDays.some((d: string) => dayMap[d] === dayOfWeek);
      }
      if (activity.frequency === 'mensal') {
        return day === (activity.frequencyConfig?.monthDay || 1);
      }
      if (activity.frequency === 'trimestral') {
        const startDate = new Date(activity.startDate);
        const currentMonth = currentDate.getMonth();
        const startMonth = startDate.getMonth();
        const monthDiff = (currentMonth - startMonth + 12) % 12;
        return monthDiff % 3 === 0 && day === (activity.frequencyConfig?.monthDay || 1);
      }
      if (activity.frequency === 'semestral') {
        const startDate = new Date(activity.startDate);
        const currentMonth = currentDate.getMonth();
        const startMonth = startDate.getMonth();
        const monthDiff = (currentMonth - startMonth + 12) % 12;
        return monthDiff % 6 === 0 && day === (activity.frequencyConfig?.monthDay || 1);
      }
      if (activity.frequency === 'anual') {
        const startDate = new Date(activity.startDate);
        const currentMonth = currentDate.getMonth();
        const startMonth = startDate.getMonth();
        return currentMonth === startMonth && day === (activity.frequencyConfig?.monthDay || 1);
      }
      return false;
    });
  };

  // Função para navegar pelos meses
  const navigateMonth = (direction: 'prev' | 'next') => {
    setCurrentDate(prev => {
      const newDate = new Date(prev);
      if (direction === 'prev') {
        newDate.setMonth(prev.getMonth() - 1);
      } else {
        newDate.setMonth(prev.getMonth() + 1);
      }
      return newDate;
    });
  };

  // Função para abrir detalhes do dia
  const openDayDetails = (day: number) => {
    const dayActivities = getActivitiesForDay(day);
    setSelectedDay(day);
    setSelectedActivities(dayActivities);
    setShowDayDetailsModal(true);
  };

  // Função para formatar data selecionada
  const getSelectedDateFormatted = () => {
    if (!selectedDay) return '';
    const date = new Date(currentDate.getFullYear(), currentDate.getMonth(), selectedDay);
    return date.toLocaleDateString('pt-BR', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  if (isLoading) {
    return (
      <>
        <ModernPageHeader 
          title="Plano de Manutenção" 
          description="Gerenciamento de atividades programadas"
          icon={CalendarRange}
        />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center space-y-4">
            <div className="w-16 h-16 border-4 border-orange-100 border-t-orange-600 rounded-full animate-spin mx-auto"></div>
            <p className="text-gray-600">Carregando plano de manutenção...</p>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <ModernPageHeader 
        title="Plano de Manutenção" 
        description="Gerenciamento de atividades de manutenção programadas"
        icon={CalendarRange}
        actions={
          <div className="flex items-center gap-2">
            <Select value={viewMode} onValueChange={(value: "monthly" | "list") => setViewMode(value)}>
              <SelectTrigger className="w-32" data-testid="select-view-mode">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="monthly">📆 Mensal</SelectItem>
                <SelectItem value="list">📋 Lista</SelectItem>
              </SelectContent>
            </Select>
            <Button 
              onClick={() => generateWorkOrdersMutation.mutate()}
              variant="outline"
              disabled={generateWorkOrdersMutation.isPending}
              data-testid="button-generate-work-orders"
              className={cn("flex items-center gap-2", theme.buttons.outline)}
            >
              <Settings className="w-4 h-4" />
              {generateWorkOrdersMutation.isPending ? 'Gerando...' : 'Gerar OSs'}
            </Button>
            <Button 
              onClick={() => setShowCreateModal(true)}
              className={theme.buttons.primary}
              data-testid="button-create-activity"
            >
              <Plus className="w-4 h-4 mr-2" />
              Nova Atividade
            </Button>
          </div>
        }
      />
      
      <div className={cn("flex-1 overflow-y-auto p-4 md:p-6 space-y-6", theme.gradients.subtle)}>
        {/* Filters and Stats Combined */}
        <ModernCard variant="default">
          <ModernCardContent>
            {/* Stats Row */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
              <div className="flex items-center gap-3">
                <div className={cn("w-10 h-10 rounded-lg flex items-center justify-center", theme.backgrounds.light)}>
                  <Wrench className={cn("w-5 h-5", theme.text.primary)} />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Ativas</p>
                  <p className="text-xl font-bold text-foreground">
                    {(activities as any[])?.filter((a: any) => a.isActive).length || 0}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-green-50 rounded-lg flex items-center justify-center">
                  <Clock className="w-5 h-5 text-green-600" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Preventivas</p>
                  <p className="text-xl font-bold text-green-600">
                    {(activities as any[])?.filter((a: any) => a.type === 'preventiva').length || 0}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-50 rounded-lg flex items-center justify-center">
                  <Timer className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Preditivas</p>
                  <p className="text-xl font-bold text-blue-600">
                    {(activities as any[])?.filter((a: any) => a.type === 'preditiva').length || 0}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gray-50 rounded-lg flex items-center justify-center">
                  <MapPin className="w-5 h-5 text-gray-600" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Equipamentos</p>
                  <p className="text-xl font-bold text-foreground">
                    {new Set((activities as any[])?.flatMap((a: any) => a.equipmentIds || [])).size || 0}
                  </p>
                </div>
              </div>
            </div>

            {/* Filters Row */}
            <div className="flex flex-wrap gap-3 pt-4 border-t">
              <Select value={siteFilter} onValueChange={setSiteFilter}>
                <SelectTrigger className="w-44" data-testid="select-site-filter">
                  <SelectValue placeholder="Filtrar por local" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="todos">Todos os Locais</SelectItem>
                  {(sites as any[])?.map((site: any) => (
                    <SelectItem key={site.id} value={site.id}>
                      {site.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              
              <Select defaultValue="todas">
                <SelectTrigger className="w-44">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="todas">Todas Frequências</SelectItem>
                  <SelectItem value="diaria">Diária</SelectItem>
                  <SelectItem value="semanal">Semanal</SelectItem>
                  <SelectItem value="mensal">Mensal</SelectItem>
                  <SelectItem value="trimestral">Trimestral</SelectItem>
                  <SelectItem value="semestral">Semestral</SelectItem>
                  <SelectItem value="anual">Anual</SelectItem>
                  <SelectItem value="turno">Por Turno</SelectItem>
                </SelectContent>
              </Select>

              <Select defaultValue="todos">
                <SelectTrigger className="w-44">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="todos">Todos os Tipos</SelectItem>
                  <SelectItem value="preventiva">Preventiva</SelectItem>
                  <SelectItem value="preditiva">Preditiva</SelectItem>
                  <SelectItem value="corretiva">Corretiva</SelectItem>
                </SelectContent>
              </Select>

              <Select defaultValue="ativas">
                <SelectTrigger className="w-44">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ativas">Ativas</SelectItem>
                  <SelectItem value="inativas">Inativas</SelectItem>
                  <SelectItem value="todas">Todas</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </ModernCardContent>
        </ModernCard>

        {/* Calendar Views or Activities List */}
        {viewMode === "monthly" ? (
          <ModernCard variant="default">
            <ModernCardHeader icon={<Calendar className="w-5 h-5" />}>
              <div className="flex items-center justify-between w-full">
                <span>Calendário de Manutenção</span>
                <div className="flex items-center gap-2">
                  <Button 
                    variant="ghost" 
                    size="icon"
                    onClick={() => navigateMonth('prev')}
                    className="h-8 w-8 hover:bg-muted rounded-lg"
                    data-testid="button-prev-month"
                  >
                    <ChevronLeft className="w-4 h-4" />
                  </Button>
                  <div className="px-4 py-1 bg-muted/50 rounded-lg">
                    <span className="font-semibold text-sm">
                      {currentDate.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' }).replace(/^\w/, c => c.toUpperCase())}
                    </span>
                  </div>
                  <Button 
                    variant="ghost" 
                    size="icon"
                    onClick={() => navigateMonth('next')}
                    className="h-8 w-8 hover:bg-muted rounded-lg"
                    data-testid="button-next-month"
                  >
                    <ChevronRight className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </ModernCardHeader>

            <ModernCardContent>
              {/* Legenda compacta e moderna */}
              <div className="flex flex-wrap gap-2 mb-6 p-3 bg-white rounded-xl border border-slate-200 shadow-sm">
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-green-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Diária</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-blue-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Semanal</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-orange-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Turno</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-purple-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Mensal</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-indigo-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Trimestral</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-violet-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Semestral</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 bg-rose-500 rounded-full shadow-sm"></div>
                  <span className="text-xs font-medium text-slate-600">Anual</span>
                </div>
              </div>

              {/* Cabeçalho da semana moderno */}
              <div className="grid grid-cols-7 gap-3 mb-3">
                {['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'].map(day => (
                  <div key={day} className="py-2 text-center font-semibold text-xs uppercase tracking-wider text-slate-500">
                    {day}
                  </div>
                ))}
              </div>

              {/* Calendário moderno */}
              <div className="grid grid-cols-7 gap-3">
                {generateMonthCalendar().map((week, weekIndex) => 
                  week.map((day, dayIndex) => {
                    const dayActivities = day ? getActivitiesForDay(day) : [];
                    const isToday = day && 
                      day === new Date().getDate() && 
                      currentDate.getMonth() === new Date().getMonth() && 
                      currentDate.getFullYear() === new Date().getFullYear();
                    
                    return (
                      <div 
                        key={`${weekIndex}-${dayIndex}`} 
                        className={`rounded-xl p-3 min-h-28 transition-all duration-300 ${
                          day 
                            ? `bg-white border ${
                                isToday 
                                  ? 'border-orange-400 shadow-lg ring-2 ring-orange-200' 
                                  : 'border-slate-200 hover:border-orange-300'
                              } hover:shadow-lg cursor-pointer transform hover:-translate-y-0.5`
                            : 'bg-slate-50/50 border border-transparent pointer-events-none'
                        }`}
                        onClick={() => day && openDayDetails(day)}
                        data-testid={day ? `calendar-day-${day}` : `calendar-empty-${weekIndex}-${dayIndex}`}
                      >
                        {day && (
                          <>
                            <div className="flex items-center justify-between mb-2">
                              <span className={`text-base font-bold ${
                                isToday ? 'text-orange-600' : 'text-slate-700'
                              }`}>
                                {day}
                              </span>
                              {dayActivities.length > 0 && (
                                <span className="flex items-center justify-center w-5 h-5 text-[10px] font-bold bg-gradient-to-br from-orange-500 to-orange-600 text-white rounded-full shadow-sm">
                                  {dayActivities.length}
                                </span>
                              )}
                            </div>
                            <div className="space-y-1.5">
                              {dayActivities.slice(0, 2).map((activity: any, idx: number) => {
                                // Gradientes por frequência
                                const frequencyGradient = 
                                  activity.frequency === 'diaria' ? 'bg-gradient-to-r from-green-500 to-emerald-600' :
                                  activity.frequency === 'semanal' ? 'bg-gradient-to-r from-blue-500 to-cyan-600' :
                                  activity.frequency === 'turno' ? 'bg-gradient-to-r from-orange-500 to-amber-600' :
                                  activity.frequency === 'mensal' ? 'bg-gradient-to-r from-purple-500 to-fuchsia-600' :
                                  activity.frequency === 'trimestral' ? 'bg-gradient-to-r from-indigo-500 to-blue-700' :
                                  activity.frequency === 'semestral' ? 'bg-gradient-to-r from-violet-500 to-purple-700' :
                                  activity.frequency === 'anual' ? 'bg-gradient-to-r from-rose-500 to-pink-600' :
                                  'bg-gradient-to-r from-slate-500 to-slate-600';
                                
                                return (
                                  <div
                                    key={idx}
                                    className={`text-[10px] px-2 py-1 rounded-md text-white ${frequencyGradient} truncate font-medium shadow-md`}
                                    title={activity.name}
                                  >
                                    {activity.name.length > 15 ? activity.name.substring(0, 15) + '...' : activity.name}
                                  </div>
                                );
                              })}
                              {dayActivities.length > 2 && (
                                <div 
                                  className="text-[10px] text-orange-600 bg-orange-50 px-2 py-1 rounded-md text-center cursor-pointer hover:bg-orange-100 font-medium transition-colors"
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    openDayDetails(day);
                                  }}
                                >
                                  +{dayActivities.length - 2} mais
                                </div>
                              )}
                            </div>
                          </>
                        )}
                      </div>
                    );
                  })
                )}
              </div>
            </ModernCardContent>
          </ModernCard>
        ) : (
          // List View
          <ModernCard variant="default">
            <ModernCardHeader icon={<Calendar className="w-5 h-5" />}>
              Lista de Atividades de Manutenção
            </ModernCardHeader>
            <ModernCardContent>
              {(activities as any[])?.length === 0 ? (
                <div className="text-center py-12 text-gray-500">
                  <Wrench className="w-16 h-16 mx-auto mb-4 opacity-30" />
                  <p className="text-lg font-medium">Nenhuma atividade cadastrada</p>
                  <p className="text-sm mt-1">Clique em "Nova Atividade" para começar</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {(activities as any[])?.map((activity: any) => (
                    <Card key={activity.id} className="hover:shadow-md transition-shadow">
                      <CardContent className="p-4">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-2">
                              <h3 className="font-bold text-lg">{activity.name}</h3>
                              {getTypeBadge(activity.type)}
                              {getFrequencyBadge(activity.frequency)}
                              {!activity.isActive && (
                                <Badge variant="secondary">Inativa</Badge>
                              )}
                            </div>
                            {activity.description && (
                              <p className="text-sm text-gray-600 mb-3">{activity.description}</p>
                            )}
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm mb-3">
                              <div className="flex items-center gap-2">
                                <MapPin className="w-4 h-4 text-gray-400" />
                                <span className="text-gray-600">
                                  {getZoneName(activity.zoneId)}
                                </span>
                              </div>
                              <div className="flex items-center gap-2">
                                <User className="w-4 h-4 text-gray-400" />
                                <span className="text-gray-600">
                                  {getAssignedUserName(activity.assignedUserId || '')}
                                </span>
                              </div>
                              <div className="flex items-center gap-2">
                                <Clock className="w-4 h-4 text-gray-400" />
                                <span className="text-gray-600">SLA: {getSLAForActivity(activity)}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <Timer className="w-4 h-4 text-gray-400" />
                                <span className="text-gray-600">
                                  Próxima: {getNextExecutionDate(activity)}
                                </span>
                              </div>
                            </div>
                            {activity.equipmentIds && activity.equipmentIds.length > 0 && (
                              <div className="flex items-center gap-2 flex-wrap">
                                <span className="text-xs text-gray-500">Equipamentos:</span>
                                {getEquipmentNames(activity.equipmentIds).map((name: string, idx: number) => (
                                  <Badge key={idx} variant="outline" className="text-xs">
                                    {name}
                                  </Badge>
                                ))}
                              </div>
                            )}
                          </div>
                          <div className="flex gap-2 ml-4">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => {
                                setSelectedActivity(activity);
                                setShowActivityDetailsModal(true);
                              }}
                              data-testid={`button-view-${activity.id}`}
                            >
                              <Eye className="w-4 h-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => {
                                setSelectedActivity(activity);
                                setShowEditActivityModal(true);
                              }}
                              data-testid={`button-edit-${activity.id}`}
                            >
                              <Edit className="w-4 h-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleDeleteActivity(activity)}
                              data-testid={`button-delete-${activity.id}`}
                            >
                              <Trash2 className="w-4 h-4 text-destructive" />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </ModernCardContent>
          </ModernCard>
        )}

        {/* Modal de Detalhes do Dia */}
        <Dialog open={showDayDetailsModal} onOpenChange={setShowDayDetailsModal}>
          <DialogContent className="max-w-3xl max-h-[85vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="text-xl font-bold flex items-center gap-2">
                <Calendar className="w-5 h-5 text-orange-600" />
                Atividades do dia {selectedDay && selectedDay.toString().padStart(2, '0')}
              </DialogTitle>
              <DialogDescription className="text-base">
                {getSelectedDateFormatted()}
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-3">
              {selectedActivities.length > 0 ? (
                selectedActivities.map((activity: any, index: number) => (
                  <Card 
                    key={activity.id} 
                    className={`hover:shadow-md transition-all duration-200 ${
                      selectedForDeletion.includes(activity.id) ? 'ring-2 ring-destructive' : ''
                    }`}
                  >
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex items-start gap-3 flex-1">
                          <input
                            type="checkbox"
                            checked={selectedForDeletion.includes(activity.id)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setSelectedForDeletion(prev => [...prev, activity.id]);
                              } else {
                                setSelectedForDeletion(prev => prev.filter(id => id !== activity.id));
                              }
                            }}
                            className="mt-1.5"
                            data-testid={`checkbox-activity-${activity.id}`}
                          />
                          <div className="flex-1">
                            <div className="flex items-center gap-2 flex-wrap mb-2">
                              <h4 className="font-bold text-base">{activity.name}</h4>
                              {getTypeBadge(activity.type)}
                              {getFrequencyBadge(activity.frequency)}
                            </div>
                            {activity.description && (
                              <p className="text-sm text-gray-600 mb-2">{activity.description}</p>
                            )}
                            <div className="grid grid-cols-2 gap-2 text-sm text-gray-500 mb-2">
                              <div className="flex items-center gap-1">
                                <MapPin className="w-3 h-3" />
                                <span>{getZoneName(activity.zoneId)}</span>
                              </div>
                              <div className="flex items-center gap-1">
                                <User className="w-3 h-3" />
                                <span>{getAssignedUserName(activity.assignedUserId || '')}</span>
                              </div>
                              <div className="flex items-center gap-1">
                                <Clock className="w-3 h-3" />
                                <span>SLA: {getSLAForActivity(activity)}</span>
                              </div>
                              {activity.startTime && (
                                <div className="flex items-center gap-1">
                                  <Timer className="w-3 h-3" />
                                  <span>{activity.startTime}</span>
                                </div>
                              )}
                            </div>
                            {activity.equipmentIds && activity.equipmentIds.length > 0 && (
                              <div className="flex items-center gap-1 flex-wrap">
                                <span className="text-xs text-gray-500">Equipamentos:</span>
                                {getEquipmentNames(activity.equipmentIds).map((name: string, idx: number) => (
                                  <Badge key={idx} variant="outline" className="text-xs">
                                    {name}
                                  </Badge>
                                ))}
                              </div>
                            )}
                          </div>
                        </div>
                        <div className="flex gap-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedActivity(activity);
                              setShowDayDetailsModal(false);
                              setShowActivityDetailsModal(true);
                            }}
                            title="Ver detalhes"
                            data-testid={`button-view-day-activity-${activity.id}`}
                          >
                            <Eye className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedActivity(activity);
                              setShowDayDetailsModal(false);
                              setShowEditActivityModal(true);
                            }}
                            title="Editar"
                            data-testid={`button-edit-day-activity-${activity.id}`}
                          >
                            <Edit className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDeleteActivity(activity)}
                            title="Deletar"
                            data-testid={`button-delete-day-activity-${activity.id}`}
                          >
                            <Trash2 className="w-4 h-4 text-destructive" />
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <div className="text-center py-12 text-gray-500">
                  <Calendar className="w-16 h-16 mx-auto mb-4 opacity-30" />
                  <p className="text-lg font-medium mb-2">
                    Este dia não possui atividades de manutenção agendadas.
                  </p>
                  <Button 
                    onClick={() => {
                      setShowDayDetailsModal(false);
                      setShowCreateModal(true);
                    }}
                    data-testid="button-create-activity-for-day"
                    size="sm"
                  >
                    <Plus className="w-4 h-4 mr-2" />
                    Criar Atividade
                  </Button>
                </div>
              )}
            </div>

            <div className="flex items-center justify-between mt-4 pt-3 border-t text-sm">
              <div className="text-gray-500">
                {selectedActivities.length > 0 && (
                  `Total: ${selectedActivities.reduce((acc, activity) => acc + (activity.estimatedDuration || 30), 0)}min`
                )}
              </div>
              <div className="flex gap-2 flex-wrap">
                {selectedActivities.length > 0 && (
                  <>
                    <Button 
                      variant="destructive" 
                      size="sm"
                      onClick={async () => {
                        if (window.confirm(`Tem certeza que deseja deletar TODAS as ${selectedActivities.length} atividade(s) deste dia?`)) {
                          try {
                            const allIds = selectedActivities.map(a => a.id);
                            await Promise.all(
                              allIds.map(id => apiRequest('DELETE', `/api/maintenance-activities/${id}`))
                            );
                            toast({
                              title: "Atividades Deletadas",
                              description: `${selectedActivities.length} atividade(s) foram removidas com sucesso!`,
                            });
                            queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "maintenance-activities"] });
                            setSelectedForDeletion([]);
                            setShowDayDetailsModal(false);
                          } catch (error) {
                            toast({
                              title: "Erro ao Deletar",
                              description: "Não foi possível deletar as atividades",
                              variant: "destructive"
                            });
                          }
                        }
                      }}
                      data-testid="button-delete-all-day"
                    >
                      <Trash2 className="w-4 h-4 mr-1" />
                      Deletar Todas ({selectedActivities.length})
                    </Button>
                    
                    {selectedForDeletion.length > 0 && (
                      <Button 
                        variant="destructive" 
                        size="sm"
                        onClick={async () => {
                          if (window.confirm(`Tem certeza que deseja deletar ${selectedForDeletion.length} atividade(s) selecionada(s)?`)) {
                            try {
                              await Promise.all(
                                selectedForDeletion.map(id => apiRequest('DELETE', `/api/maintenance-activities/${id}`))
                              );
                              toast({
                                title: "Atividades Deletadas",
                                description: `${selectedForDeletion.length} atividade(s) selecionada(s) foram removidas com sucesso!`,
                              });
                              queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "maintenance-activities"] });
                              setSelectedForDeletion([]);
                            } catch (error) {
                              toast({
                                title: "Erro ao Deletar",
                                description: "Não foi possível deletar as atividades selecionadas",
                                variant: "destructive"
                              });
                            }
                          }
                        }}
                        data-testid="button-delete-selected"
                      >
                        <Trash2 className="w-4 h-4 mr-1" />
                        Deletar Selecionadas ({selectedForDeletion.length})
                      </Button>
                    )}
                  </>
                )}
                
                <Button variant="outline" size="sm" onClick={() => setShowDayDetailsModal(false)}>
                  Fechar
                </Button>
                
                {selectedActivities.length > 0 && (
                  <Button 
                    size="sm"
                    onClick={() => {
                      setShowDayDetailsModal(false);
                      setShowCreateModal(true);
                    }}
                    data-testid="button-add-more-activities"
                  >
                    <Plus className="w-4 h-4 mr-1" />
                    Nova Atividade
                  </Button>
                )}
              </div>
            </div>
          </DialogContent>
        </Dialog>

        {/* Modal de Criação de Atividade */}
        {showCreateModal && (
          <CreateMaintenanceActivityModal
            activeClientId={activeClientId}
            onClose={() => setShowCreateModal(false)}
            onSuccess={() => {
              setShowCreateModal(false);
              queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "maintenance-activities"] });
            }}
          />
        )}

        {/* Modal de Detalhes da Atividade */}
        <Dialog open={showActivityDetailsModal} onOpenChange={setShowActivityDetailsModal}>
          <DialogContent className="max-w-md max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle className="text-lg font-semibold">Detalhes da Atividade</DialogTitle>
              <DialogDescription>
                Informações completas sobre a atividade selecionada.
              </DialogDescription>
            </DialogHeader>
            {selectedActivity && (
              <div className="space-y-4">
                <div>
                  <h3 className="font-semibold text-gray-900">{selectedActivity.name}</h3>
                  {selectedActivity.description && (
                    <p className="text-sm text-gray-600 mt-1">{selectedActivity.description}</p>
                  )}
                </div>
                
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="font-medium text-gray-700">Tipo:</span>
                    <p className="text-gray-600 mt-1">{getTypeBadge(selectedActivity.type)}</p>
                  </div>
                  <div>
                    <span className="font-medium text-gray-700">Frequência:</span>
                    <p className="text-gray-600 mt-1">{getFrequencyBadge(selectedActivity.frequency)}</p>
                  </div>
                  <div>
                    <span className="font-medium text-gray-700">Status:</span>
                    <p className="text-gray-600">{selectedActivity.isActive ? 'Ativa' : 'Inativa'}</p>
                  </div>
                  <div>
                    <span className="font-medium text-gray-700">Local:</span>
                    <p className="text-gray-600">{getZoneName(selectedActivity.zoneId)}</p>
                  </div>
                  <div>
                    <span className="font-medium text-gray-700">SLA:</span>
                    <p className="text-gray-600">{getSLAForActivity(selectedActivity)}</p>
                  </div>
                  <div className="col-span-2">
                    <span className="font-medium text-gray-700">Responsável:</span>
                    <p className="text-gray-600">{getAssignedUserName(selectedActivity.assignedUserId || '')}</p>
                  </div>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Modal de Edição da Atividade */}
        <Dialog open={showEditActivityModal} onOpenChange={setShowEditActivityModal}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle className="text-lg font-semibold">Editar Atividade</DialogTitle>
              <DialogDescription>
                Modifique as informações da atividade abaixo.
              </DialogDescription>
            </DialogHeader>
            {selectedActivity && (
              <div className="space-y-4">
                <div>
                  <Label htmlFor="edit-name">Nome da Atividade</Label>
                  <Input 
                    id="edit-name"
                    defaultValue={selectedActivity.name}
                    className="mt-1"
                  />
                </div>
                
                <div>
                  <Label htmlFor="edit-description">Descrição</Label>
                  <Textarea 
                    id="edit-description"
                    defaultValue={selectedActivity.description || ''}
                    className="mt-1"
                  />
                </div>

                <div>
                  <Label htmlFor="edit-type">Tipo de Manutenção</Label>
                  <Select defaultValue={selectedActivity.type}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="preventiva">Preventiva</SelectItem>
                      <SelectItem value="preditiva">Preditiva</SelectItem>
                      <SelectItem value="corretiva">Corretiva</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div>
                  <Label htmlFor="edit-frequency">Frequência</Label>
                  <Select defaultValue={selectedActivity.frequency}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="diaria">Diária</SelectItem>
                      <SelectItem value="semanal">Semanal</SelectItem>
                      <SelectItem value="mensal">Mensal</SelectItem>
                      <SelectItem value="trimestral">Trimestral</SelectItem>
                      <SelectItem value="semestral">Semestral</SelectItem>
                      <SelectItem value="anual">Anual</SelectItem>
                      <SelectItem value="turno">Por Turno</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="flex justify-end gap-2 pt-4">
                  <Button 
                    type="button" 
                    variant="outline" 
                    onClick={() => setShowEditActivityModal(false)}
                  >
                    Cancelar
                  </Button>
                  <Button 
                    type="button"
                    onClick={() => {
                      toast({
                        title: "Em Desenvolvimento",
                        description: "Funcionalidade de edição será implementada em breve",
                      });
                      setShowEditActivityModal(false);
                    }}
                  >
                    Salvar Alterações
                  </Button>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>
      </div>
    </>
  );
}

// MultiSelect Component
function MultiSelect({
  label,
  options,
  value,
  onChange,
  placeholder,
  disabled,
  required,
  "data-testid": dataTestId,
}: {
  label: string;
  options: { value: string; label: string }[];
  value: string[];
  onChange: (vals: string[]) => void;
  placeholder?: string;
  disabled?: boolean;
  required?: boolean;
  "data-testid"?: string;
}) {
  const [open, setOpen] = useState(false);
  
  const toggleOption = (optionValue: string) => {
    if (value.includes(optionValue)) {
      onChange(value.filter(v => v !== optionValue));
    } else {
      onChange([...value, optionValue]);
    }
  };

  const selectedLabels = options
    .filter(opt => value.includes(opt.value))
    .map(opt => opt.label)
    .join(", ");

  return (
    <div className="space-y-2">
      <Label>{label} {required && "*"}</Label>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="w-full justify-between"
            disabled={disabled}
            data-testid={dataTestId}
          >
            <span className="truncate">
              {selectedLabels || placeholder || "Selecione..."}
            </span>
            <ChevronDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-full p-0" align="start">
          <div className="max-h-64 overflow-auto p-2">
            {options.length === 0 ? (
              <div className="p-2 text-sm text-muted-foreground">
                {placeholder || "Sem opções"}
              </div>
            ) : (
              <div className="space-y-1">
                {options.map((option) => (
                  <div
                    key={option.value}
                    className="flex items-center space-x-2 p-2 hover:bg-accent rounded-sm cursor-pointer"
                    onClick={() => toggleOption(option.value)}
                  >
                    <Checkbox
                      checked={value.includes(option.value)}
                      onCheckedChange={() => toggleOption(option.value)}
                    />
                    <label className="flex-1 cursor-pointer text-sm">
                      {option.label}
                    </label>
                  </div>
                ))}
              </div>
            )}
          </div>
        </PopoverContent>
      </Popover>
      <div className="text-xs text-slate-500">
        {value?.length ? `${value.length} selecionado(s)` : "Nenhum selecionado"}
      </div>
    </div>
  );
}

// Componente de Modal para Criação de Atividade de Manutenção
interface CreateMaintenanceActivityModalProps {
  activeClientId: string;
  onClose: () => void;
  onSuccess: () => void;
}

function CreateMaintenanceActivityModal({ activeClientId, onClose, onSuccess }: CreateMaintenanceActivityModalProps) {
  const { currentModule } = useModule();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    type: "preventiva",
    frequency: "mensal",
    startDate: "",
    frequencyConfig: {
      weekDays: [] as string[],
      monthDay: 1,
      turnShifts: [] as string[],
      timesPerDay: 1
    },
    equipmentIds: [] as string[],
    siteIds: [] as string[],
    zoneIds: [] as string[],
    checklistTemplateId: "",
    startTime: "",
    endTime: "",
    isActive: true
  });

  const { data: equipment } = useQuery({
    queryKey: ["/api/customers", activeClientId, "equipment"],
    enabled: !!activeClientId,
  });

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", activeClientId, "sites", { module: currentModule }],
    enabled: !!activeClientId,
  });

  // Fetch zones based on selected sites
  const { data: zones = [] } = useQuery({
    queryKey: ["/api/zones", (formData.siteIds || []).join(","), { module: currentModule }],
    enabled: Array.isArray(formData.siteIds) && formData.siteIds.length > 0,
    queryFn: async () => {
      const ids = formData.siteIds;
      if (!ids || ids.length === 0) return [];
      const qs = new URLSearchParams();
      qs.set("siteIds", ids.join(","));
      qs.set("module", currentModule);
      const res = await fetch(`/api/zones?${qs.toString()}`);
      if (!res.ok) throw new Error('Failed to fetch zones');
      return res.json();
    },
  });

  const { data: checklistTemplates } = useQuery({
    queryKey: ["/api/customers", activeClientId, "maintenance-checklist-templates"],
    enabled: !!activeClientId,
  });

  // Filtrar zonas baseado nos sites selecionados
  const filteredZones = useMemo(() => {
    if (!formData.siteIds || formData.siteIds.length === 0 || !zones) return [];
    return (zones as any[]).filter((zone: any) => formData.siteIds.includes(zone.siteId));
  }, [zones, formData.siteIds]);

  // Filtrar checklists baseado nos equipamentos selecionados (interseção)
  // Só mostra checklists que estão vinculados a TODOS os equipamentos selecionados
  const availableChecklistTemplates = useMemo(() => {
    // Se nenhum equipamento selecionado, não mostrar checklists
    if (!formData.equipmentIds || formData.equipmentIds.length === 0) {
      return [];
    }
    
    if (!checklistTemplates || !Array.isArray(checklistTemplates)) {
      return [];
    }

    // Filtrar checklists que contêm TODOS os equipamentos selecionados
    return (checklistTemplates as any[]).filter((template: any) => {
      if (!template.equipmentIds || !Array.isArray(template.equipmentIds)) {
        return false;
      }
      
      // Verifica se o template contém TODOS os equipamentos selecionados
      return formData.equipmentIds.every((equipId: string) => 
        template.equipmentIds.includes(equipId)
      );
    });
  }, [checklistTemplates, formData.equipmentIds]);

  const handleChange = (field: string, value: any) => {
    setFormData(prev => {
      const newData = { ...prev, [field]: value };
      
      // Limpar checklist quando equipamentos mudam (será necessário reselecionar)
      if (field === 'equipmentIds') {
        newData.checklistTemplateId = "";
      }
      
      // Limpar zonas quando sites mudam
      if (field === 'siteIds') {
        newData.zoneIds = [];
      }
      
      // Reset frequency config quando muda frequência
      if (field === 'frequency') {
        newData.frequencyConfig = {
          weekDays: [],
          monthDay: 1,
          turnShifts: [],
          timesPerDay: 1
        };
      }
      
      return newData;
    });
  };

  const handleFrequencyConfigChange = (configField: string, value: any) => {
    setFormData(prev => ({
      ...prev,
      frequencyConfig: {
        ...prev.frequencyConfig,
        [configField]: value
      }
    }));
  };

  const createActivityMutation = useMutation({
    mutationFn: async (data: any) => {
      const site = (sites as any[])?.find(s => data.siteIds?.includes(s.id));
      const companyId = site?.companyId || "company-opus-default";
      const submitData = {
        ...data,
        companyId,
        activeClientId,
        checklistTemplateId: data.checklistTemplateId || null,
        equipmentIds: data.equipmentIds || [],
      };
      return { activity: await apiRequest("POST", "/api/maintenance-activities", submitData), companyId };
    },
    onSuccess: async (result: any) => {
      toast({ 
        title: "Plano de Manutenção Criado!", 
        description: "As ordens de serviço serão geradas automaticamente no final de cada mês." 
      });
      
      queryClient.invalidateQueries({ 
        queryKey: ["/api/customers", activeClientId, "maintenance-activities"] 
      });
      
      onSuccess();
    },
    onError: () => {
      toast({ 
        title: "Erro ao criar atividade de manutenção", 
        variant: "destructive" 
      });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validate required fields
    if (!formData.name || !formData.startDate) {
      toast({
        title: "Campos obrigatórios",
        description: "Preencha todos os campos obrigatórios",
        variant: "destructive"
      });
      return;
    }

    // Validate sites and zones
    if (!formData.siteIds || formData.siteIds.length === 0) {
      toast({
        title: "Locais obrigatórios",
        description: "Selecione ao menos um local",
        variant: "destructive"
      });
      return;
    }

    if (!formData.zoneIds || formData.zoneIds.length === 0) {
      toast({
        title: "Zonas obrigatórias",
        description: "Selecione ao menos uma zona",
        variant: "destructive"
      });
      return;
    }

    // Validate checklist
    if (!formData.checklistTemplateId) {
      toast({
        title: "Checklist obrigatório",
        description: "Selecione um checklist para o plano de manutenção",
        variant: "destructive"
      });
      return;
    }

    // Validate equipment selection
    if (!formData.equipmentIds || formData.equipmentIds.length === 0) {
      toast({
        title: "Equipamentos obrigatórios",
        description: "Selecione ao menos um equipamento",
        variant: "destructive"
      });
      return;
    }

    // Validar configuração de frequência
    if (formData.frequency === "diaria" && formData.frequencyConfig.timesPerDay < 1) {
      toast({
        title: "Frequência diária inválida",
        description: "Informe quantas vezes por dia a atividade deve ser realizada",
        variant: "destructive"
      });
      return;
    }

    if (formData.frequency === "semanal" && formData.frequencyConfig.weekDays.length === 0) {
      toast({
        title: "Dias da semana obrigatórios",
        description: "Selecione pelo menos um dia da semana",
        variant: "destructive"
      });
      return;
    }

    if (formData.frequency === "turno" && formData.frequencyConfig.turnShifts.length === 0) {
      toast({
        title: "Turnos obrigatórios", 
        description: "Selecione pelo menos um turno",
        variant: "destructive"
      });
      return;
    }

    createActivityMutation.mutate(formData);
  };

  return (
    <Dialog open={true} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto" data-testid="create-activity-modal">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold">Nova Atividade de Manutenção</DialogTitle>
          <DialogDescription>
            Preencha as informações para criar uma nova atividade de manutenção programada
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Informações Básicas */}
          <div className="space-y-4 p-4 bg-orange-50 rounded-lg border border-orange-200">
            <h4 className="font-semibold text-orange-900 flex items-center gap-2">
              <Settings className="w-4 h-4" />
              Informações Básicas
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="name">Nome da Atividade *</Label>
                <Input
                  id="name"
                  placeholder="Ex: Manutenção preventiva HVAC"
                  value={formData.name}
                  onChange={(e) => handleChange("name", e.target.value)}
                  data-testid="input-name"
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="type">Tipo de Manutenção *</Label>
                <Select value={formData.type} onValueChange={(value) => handleChange("type", value)}>
                  <SelectTrigger data-testid="select-type">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="preventiva">Preventiva</SelectItem>
                    <SelectItem value="preditiva">Preditiva</SelectItem>
                    <SelectItem value="corretiva">Corretiva</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="frequency">Frequência</Label>
                <Select value={formData.frequency} onValueChange={(value) => handleChange("frequency", value)}>
                  <SelectTrigger data-testid="select-frequency">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="diaria">Diária</SelectItem>
                    <SelectItem value="semanal">Semanal</SelectItem>
                    <SelectItem value="mensal">Mensal</SelectItem>
                    <SelectItem value="trimestral">Trimestral</SelectItem>
                    <SelectItem value="semestral">Semestral</SelectItem>
                    <SelectItem value="anual">Anual</SelectItem>
                    <SelectItem value="turno">Por Turno</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="startDate">Data de Início *</Label>
                <Input
                  id="startDate"
                  type="date"
                  value={formData.startDate}
                  onChange={(e) => handleChange("startDate", e.target.value)}
                  data-testid="input-start-date"
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="startTime">Horário de Início (opcional)</Label>
                <Input
                  id="startTime"
                  type="time"
                  placeholder="Ex: 08:00"
                  value={formData.startTime}
                  onChange={(e) => handleChange("startTime", e.target.value)}
                  data-testid="input-start-time"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="endTime">Horário de Fim (opcional)</Label>
                <Input
                  id="endTime"
                  type="time"
                  placeholder="Ex: 18:00"
                  value={formData.endTime}
                  onChange={(e) => handleChange("endTime", e.target.value)}
                  data-testid="input-end-time"
                />
              </div>

              <div className="md:col-span-2 space-y-2">
                <Label htmlFor="description">Descrição</Label>
                <Textarea
                  id="description"
                  placeholder="Descreva detalhes da atividade de manutenção..."
                  value={formData.description}
                  onChange={(e) => handleChange("description", e.target.value)}
                  data-testid="textarea-description"
                  rows={3}
                />
              </div>

              {/* Configuração de Frequência */}
              {formData.frequency === "diaria" && (
                <div key="daily-config" className="space-y-2">
                  <Label htmlFor="timesPerDay">Quantas vezes por dia? *</Label>
                  <Select 
                    key="times-per-day-select"
                    value={formData.frequencyConfig.timesPerDay.toString()} 
                    onValueChange={(value) => handleFrequencyConfigChange("timesPerDay", parseInt(value))}
                  >
                    <SelectTrigger data-testid="select-times-per-day">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="1">1 vez por dia</SelectItem>
                      <SelectItem value="2">2 vezes por dia</SelectItem>
                      <SelectItem value="3">3 vezes por dia</SelectItem>
                      <SelectItem value="4">4 vezes por dia</SelectItem>
                      <SelectItem value="5">5 vezes por dia</SelectItem>
                      <SelectItem value="6">6 vezes por dia</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              )}

              {formData.frequency === "semanal" && (
                <div key="weekly-config" className="md:col-span-2 space-y-2">
                  <Label>Dias da Semana *</Label>
                  <div className="grid grid-cols-4 gap-2">
                    {[
                      { value: 'domingo', label: 'Domingo' },
                      { value: 'segunda', label: 'Segunda' },
                      { value: 'terca', label: 'Terça' },
                      { value: 'quarta', label: 'Quarta' },
                      { value: 'quinta', label: 'Quinta' },
                      { value: 'sexta', label: 'Sexta' },
                      { value: 'sabado', label: 'Sábado' }
                    ].map(day => (
                      <label key={day.value} className="flex items-center gap-2 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={formData.frequencyConfig.weekDays.includes(day.value)}
                          onChange={(e) => {
                            const currentDays = formData.frequencyConfig.weekDays;
                            if (e.target.checked) {
                              handleFrequencyConfigChange("weekDays", [...currentDays, day.value]);
                            } else {
                              handleFrequencyConfigChange("weekDays", currentDays.filter(d => d !== day.value));
                            }
                          }}
                          className="rounded"
                          data-testid={`checkbox-weekday-${day.value}`}
                        />
                        <span className="text-sm">{day.label}</span>
                      </label>
                    ))}
                  </div>
                </div>
              )}

              {formData.frequency === "mensal" && (
                <div key="monthly-config" className="space-y-2">
                  <Label htmlFor="monthDay">Dia do Mês *</Label>
                  <Select 
                    value={formData.frequencyConfig.monthDay.toString()} 
                    onValueChange={(value) => handleFrequencyConfigChange("monthDay", parseInt(value))}
                  >
                    <SelectTrigger data-testid="select-month-day">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {Array.from({ length: 31 }, (_, i) => i + 1).map(day => (
                        <SelectItem key={day} value={day.toString()}>
                          Dia {day}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              )}

              {formData.frequency === "turno" && (
                <div key="shift-config" className="md:col-span-2 space-y-2">
                  <Label>Turnos *</Label>
                  <div className="grid grid-cols-3 gap-2">
                    {[
                      { value: 'manha', label: 'Manhã' },
                      { value: 'tarde', label: 'Tarde' },
                      { value: 'noite', label: 'Noite' }
                    ].map(shift => (
                      <label key={shift.value} className="flex items-center gap-2 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={formData.frequencyConfig.turnShifts.includes(shift.value)}
                          onChange={(e) => {
                            const currentShifts = formData.frequencyConfig.turnShifts;
                            if (e.target.checked) {
                              handleFrequencyConfigChange("turnShifts", [...currentShifts, shift.value]);
                            } else {
                              handleFrequencyConfigChange("turnShifts", currentShifts.filter(s => s !== shift.value));
                            }
                          }}
                          className="rounded"
                          data-testid={`checkbox-shift-${shift.value}`}
                        />
                        <span className="text-sm">{shift.label}</span>
                      </label>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Local e Equipamento */}
          <div className="space-y-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <h4 className="font-semibold text-blue-900 flex items-center gap-2">
              <MapPin className="w-4 h-4" />
              Local e Equipamento
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <MultiSelect
                  label="Local"
                  options={(sites as any[])?.map((site: any) => ({
                    value: site.id,
                    label: site.name
                  })) || []}
                  value={formData.siteIds}
                  onChange={(value) => handleChange("siteIds", value)}
                  placeholder="Selecione um ou mais locais"
                  required
                  data-testid="multiselect-sites"
                />
              </div>

              <div className="space-y-2">
                <MultiSelect
                  label="Zona"
                  options={filteredZones?.map((zone: any) => ({
                    value: zone.id,
                    label: zone.name
                  })) || []}
                  value={formData.zoneIds}
                  onChange={(value) => handleChange("zoneIds", value)}
                  placeholder={formData.siteIds.length > 0 ? "Selecione uma ou mais zonas" : "Selecione ao menos um local"}
                  disabled={!formData.siteIds || formData.siteIds.length === 0}
                  required
                  data-testid="multiselect-zones"
                />
              </div>

              <div className="md:col-span-2 space-y-2">
                <MultiSelect
                  label="Equipamentos"
                  options={(equipment as any[])?.map((equip: any) => ({
                    value: equip.id,
                    label: equip.name
                  })) || []}
                  value={formData.equipmentIds}
                  onChange={(value) => handleChange("equipmentIds", value)}
                  placeholder="Selecione um ou mais equipamentos"
                  required
                  data-testid="multiselect-equipment"
                />
              </div>

              <div className="md:col-span-2 space-y-2">
                <Label htmlFor="checklist">Checklist (obrigatório)</Label>
                <Select 
                  value={formData.checklistTemplateId} 
                  onValueChange={(value) => handleChange("checklistTemplateId", value)}
                  disabled={!formData.equipmentIds || formData.equipmentIds.length === 0}
                >
                  <SelectTrigger data-testid="select-checklist">
                    <SelectValue 
                      placeholder={
                        !formData.equipmentIds || formData.equipmentIds.length === 0
                          ? "Selecione equipamentos primeiro"
                          : availableChecklistTemplates.length === 0
                          ? "Nenhum checklist disponível para os equipamentos selecionados"
                          : "Selecione um checklist"
                      } 
                    />
                  </SelectTrigger>
                  <SelectContent>
                    {availableChecklistTemplates.map((template: any) => (
                      <SelectItem key={template.id} value={template.id}>
                        {template.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>

          {/* Botões de Ação */}
          <div className="flex justify-end gap-3 pt-4 border-t">
            <Button 
              type="button" 
              variant="outline" 
              onClick={onClose}
              data-testid="button-cancel"
            >
              Cancelar
            </Button>
            <Button 
              type="submit" 
              disabled={createActivityMutation.isPending}
              data-testid="button-submit"
            >
              {createActivityMutation.isPending ? (
                <>
                  <Clock className="w-4 h-4 mr-2 animate-spin" />
                  Criando...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4 mr-2" />
                  Criar Atividade
                </>
              )}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
