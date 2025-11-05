import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Checkbox } from "@/components/ui/checkbox";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { useModuleTheme } from "@/hooks/use-module-theme";
import { ModernCard, ModernCardHeader, ModernCardContent } from "@/components/ui/modern-card";
import { ModernPageHeader } from "@/components/ui/modern-page-header";
import { 
  Plus, 
  Eye, 
  Search, 
  Trash2, 
  Clock, 
  AlertTriangle, 
  CheckCircle2, 
  RefreshCw,
  Calendar,
  Filter,
  Edit,
  ChevronDown,
  X,
  MapPin,
  PauseCircle,
  ClipboardList,
  XCircle
} from "lucide-react";
import WorkOrderModal from "@/components/work-order-modal";
import CreateWorkOrderModal from "@/components/create-work-order-modal";
import { cn } from "@/lib/utils";

interface MultiSelectOption {
  value: string;
  label: string;
}

interface MultiSelectProps {
  options: MultiSelectOption[];
  selected: string[];
  onChange: (selected: string[]) => void;
  placeholder: string;
  testId?: string;
}

function MultiSelect({ options, selected, onChange, placeholder, testId }: MultiSelectProps) {
  const [open, setOpen] = useState(false);
  
  const toggleOption = (value: string) => {
    if (selected.includes(value)) {
      onChange(selected.filter(v => v !== value));
    } else {
      onChange([...selected, value]);
    }
  };

  const clearAll = () => {
    onChange([]);
  };

  const getDisplayText = () => {
    if (selected.length === 0) return placeholder;
    if (selected.length === 1) {
      const option = options.find(o => o.value === selected[0]);
      return option?.label || placeholder;
    }
    return `${selected.length} selecionados`;
  };

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className="w-[200px] justify-between font-normal"
          data-testid={testId}
        >
          <span className="truncate">{getDisplayText()}</span>
          <div className="flex items-center gap-1">
            {selected.length > 0 && (
              <X 
                className="h-4 w-4 opacity-50 hover:opacity-100" 
                onClick={(e) => {
                  e.stopPropagation();
                  clearAll();
                }}
              />
            )}
            <ChevronDown className="h-4 w-4 opacity-50" />
          </div>
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-[200px] p-2" align="start">
        <div className="space-y-2">
          {options.map((option) => (
            <div
              key={option.value}
              className="flex items-center space-x-2 hover:bg-gray-100 p-2 rounded cursor-pointer"
              onClick={() => toggleOption(option.value)}
              data-testid={`${testId}-option-${option.value}`}
            >
              <Checkbox
                checked={selected.includes(option.value)}
                onCheckedChange={() => toggleOption(option.value)}
              />
              <label className="text-sm cursor-pointer flex-1">
                {option.label}
              </label>
            </div>
          ))}
        </div>
      </PopoverContent>
    </Popover>
  );
}

export default function WorkOrders() {
  const { activeClientId } = useClient();
  const { currentModule } = useModule();
  const theme = useModuleTheme();
  const [selectedWorkOrder, setSelectedWorkOrder] = useState<string | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [statusFilter, setStatusFilter] = useState<string[]>([]);
  const [zoneFilter, setZoneFilter] = useState<string[]>([]);
  const [typeFilter, setTypeFilter] = useState<string>("todos");
  const [searchTerm, setSearchTerm] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [lastUpdate, setLastUpdate] = useState(new Date());
  const [isRefreshing, setIsRefreshing] = useState(false);
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: workOrders, isLoading, refetch } = useQuery({
    queryKey: ["/api/customers", activeClientId, "work-orders", { module: currentModule, includeAll: 'true' }],
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

  const deleteWorkOrderMutation = useMutation({
    mutationFn: async (workOrderId: string) => {
      return await apiRequest("DELETE", `/api/customers/${activeClientId}/work-orders/${workOrderId}`);
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço deletada com sucesso" });
      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "work-orders"] });
    },
    onError: () => {
      toast({ 
        title: "Erro ao deletar ordem de serviço", 
        variant: "destructive" 
      });
    },
  });

  const cancelWorkOrderMutation = useMutation({
    mutationFn: async (workOrderId: string) => {
      return await apiRequest("PUT", `/api/work-orders/${workOrderId}`, {
        status: 'cancelada'
      });
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço cancelada com sucesso" });
      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "work-orders"] });
    },
    onError: () => {
      toast({ 
        title: "Erro ao cancelar ordem de serviço", 
        variant: "destructive" 
      });
    },
  });

  const handleDeleteWorkOrder = (workOrderId: string, workOrderTitle: string) => {
    if (window.confirm(`Tem certeza que deseja deletar a OS "${workOrderTitle}"? Esta ação não pode ser desfeita.`)) {
      deleteWorkOrderMutation.mutate(workOrderId);
    }
  };

  const handleCancelWorkOrder = (workOrderId: string, workOrderTitle: string) => {
    if (window.confirm(`Tem certeza que deseja cancelar a OS "${workOrderTitle}"?`)) {
      cancelWorkOrderMutation.mutate(workOrderId);
    }
  };

  const handleRefresh = () => {
    setIsRefreshing(true);
    refetch();
    setLastUpdate(new Date());
    setTimeout(() => setIsRefreshing(false), 1000);
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "aberta":
        return <Badge className="bg-blue-600 text-white border-0">Aberta</Badge>;
      case "em_execucao":
        return <Badge className="bg-yellow-600 text-white border-0">Em Execução</Badge>;
      case "pausada":
        return <Badge className="bg-orange-600 text-white border-0">Pausada</Badge>;
      case "vencida":
        return <Badge className="bg-red-600 text-white border-0">Vencida</Badge>;
      case "concluida":
        return <Badge className="bg-green-600 text-white border-0">Concluída</Badge>;
      case "cancelada":
        return <Badge className="bg-gray-500 text-white border-0">Cancelada</Badge>;
      default:
        return <Badge className="bg-blue-600 text-white border-0">Aberta</Badge>;
    }
  };

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "critica":
        return <Badge className="bg-red-500 text-white border-0">Crítica</Badge>;
      case "alta":
        return <Badge className="bg-orange-500 text-white border-0">Alta</Badge>;
      case "media":
        return <Badge className="bg-yellow-500 text-white border-0">Média</Badge>;
      default:
        return <Badge className="bg-blue-500 text-white border-0">Baixa</Badge>;
    }
  };

  const getTypeLabel = (orderType: string) => {
    switch (orderType) {
      case "programada":
        return "Programada";
      case "corretiva_interna":
        return "Corretiva Interna";
      case "corretiva_publica":
        return "Corretiva Pública";
      default:
        return "N/A";
    }
  };

  const filteredWorkOrders = (workOrders as any[])?.filter((wo: any) => {
    const matchesStatus = statusFilter.length === 0 || statusFilter.includes(wo.status);
    const matchesZone = zoneFilter.length === 0 || zoneFilter.includes(wo.zoneId);
    const matchesType = typeFilter === "todos" || wo.type === typeFilter;
    
    const matchesSearch = wo.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         wo.number?.toString().includes(searchTerm) ||
                         wo.id?.toString().includes(searchTerm);
    
    let matchesDateRange = true;
    if (startDate || endDate) {
      const scheduledDate = wo.scheduledDate ? new Date(wo.scheduledDate) : null;
      if (scheduledDate) {
        if (startDate) {
          const start = new Date(startDate);
          start.setHours(0, 0, 0, 0);
          if (scheduledDate < start) matchesDateRange = false;
        }
        if (endDate) {
          const end = new Date(endDate);
          end.setHours(23, 59, 59, 999);
          if (scheduledDate > end) matchesDateRange = false;
        }
      } else {
        matchesDateRange = false;
      }
    }
    
    return matchesStatus && matchesZone && matchesType && matchesSearch && matchesDateRange;
  }).sort((a: any, b: any) => {
    if (a.scheduledDate && b.scheduledDate) {
      return new Date(a.scheduledDate).getTime() - new Date(b.scheduledDate).getTime();
    }
    if (a.scheduledDate) return -1;
    if (b.scheduledDate) return 1;
    return 0;
  }) || [];

  const totalAbertas = (workOrders as any[])?.filter((wo: any) => 
    wo.status === 'aberta' || wo.status === 'atrasada'
  ).length || 0;
  
  const totalVencidas = (workOrders as any[])?.filter((wo: any) => 
    wo.status === 'vencida'
  ).length || 0;
  
  const totalPausadas = (workOrders as any[])?.filter((wo: any) => 
    wo.status === 'pausada'
  ).length || 0;
  
  const totalConcluidas = (workOrders as any[])?.filter((wo: any) => 
    wo.status === 'concluida'
  ).length || 0;

  // Descrição dinâmica baseada no módulo
  const headerDescription = currentModule === 'maintenance' 
    ? "Gerenciamento de ordens de serviço de manutenção" 
    : "Gerenciamento de ordens de serviço de limpeza";

  if (isLoading) {
    return (
      <div className={cn("flex-1 flex items-center justify-center", theme.gradients.page)}>
        <div className="text-center">
          <div className={cn(
            "w-16 h-16 border-4 border-t-transparent rounded-full animate-spin mx-auto mb-4",
            theme.borders.primary
          )}></div>
          <p className="text-slate-600 font-medium">Carregando ordens de serviço...</p>
        </div>
      </div>
    );
  }

  const getZoneName = (zoneId: string) => {
    const zone = (zones as any[])?.find((z: any) => z.id === zoneId);
    return zone?.name || "N/A";
  };

  const getUserName = (userId: string) => {
    const user = (users as any[])?.find((u: any) => u.id === userId);
    return user?.name || "Não atribuído";
  };

  // Formata data sem problemas de timezone
  const formatDateOnly = (dateString: string | null | undefined) => {
    if (!dateString) return '-';
    // Se já é uma string no formato YYYY-MM-DD, formata diretamente
    const match = dateString.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (match) {
      const [, year, month, day] = match;
      return `${day}/${month}/${year}`;
    }
    // Fallback para conversão normal
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  return (
    <>
      <ModernPageHeader 
        title="Ordens de Serviço"
        description={headerDescription}
        icon={ClipboardList}
        actions={
          <>
            <Button 
              onClick={handleRefresh}
              className={cn("flex items-center gap-2", theme.buttons.primary)}
              size="sm"
              disabled={isRefreshing}
              data-testid="button-refresh"
            >
              <RefreshCw className={cn("w-4 h-4", isRefreshing && "animate-spin")} />
              Atualizar
            </Button>
            <Button 
              onClick={() => setShowCreateModal(true)} 
              className={theme.buttons.primary}
              data-testid="button-create-work-order"
            >
              <Plus className="w-4 h-4 mr-2" />
              Nova OS
            </Button>
          </>
        }
      />
      
      <main className={cn("flex-1 overflow-auto p-6", theme.gradients.page)}>
        <div className="max-w-7xl mx-auto space-y-6">
          {/* Estatísticas e Filtros Integrados */}
          <ModernCard variant="gradient">
            <ModernCardContent>
              {/* Cards de Estatísticas */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <div className="flex items-center gap-4">
                  <div className={cn("w-14 h-14 rounded-xl flex items-center justify-center", 
                    currentModule === 'maintenance' ? 'bg-orange-50' : 'bg-blue-50'
                  )}>
                    <Clock className={cn("w-7 h-7", 
                      currentModule === 'maintenance' ? 'text-orange-600' : 'text-blue-600'
                    )} />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground font-medium">Abertas</p>
                    <p className={cn("text-3xl font-bold", 
                      currentModule === 'maintenance' ? 'text-orange-600' : 'text-blue-600'
                    )}>
                      {totalAbertas}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div className="w-14 h-14 bg-red-50 rounded-xl flex items-center justify-center">
                    <AlertTriangle className="w-7 h-7 text-red-600" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground font-medium">Vencidas</p>
                    <p className="text-3xl font-bold text-red-600">
                      {totalVencidas}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div className={cn("w-14 h-14 rounded-xl flex items-center justify-center",
                    currentModule === 'maintenance' ? 'bg-orange-50' : 'bg-blue-50'
                  )}>
                    <PauseCircle className={cn("w-7 h-7",
                      currentModule === 'maintenance' ? 'text-orange-600' : 'text-blue-600'
                    )} />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground font-medium">Pausadas</p>
                    <p className="text-3xl font-bold text-foreground">
                      {totalPausadas}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div className="w-14 h-14 bg-green-50 rounded-xl flex items-center justify-center">
                    <CheckCircle2 className="w-7 h-7 text-green-600" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground font-medium">Concluídas</p>
                    <p className="text-3xl font-bold text-green-600">
                      {totalConcluidas}
                    </p>
                  </div>
                </div>
              </div>

              {/* Filters Row */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 pt-4 border-t">
                <Select 
                  value={statusFilter.length === 0 ? "todos" : statusFilter.length === 1 ? statusFilter[0] : "multiplos"}
                  onValueChange={(value) => {
                    if (value === "todos") {
                      setStatusFilter([]);
                    } else {
                      setStatusFilter([value]);
                    }
                  }}
                >
                  <SelectTrigger className="w-full" data-testid="select-status-filter">
                    <SelectValue placeholder="Todos os Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todos">Todos os Status</SelectItem>
                    <SelectItem value="aberta">Abertas</SelectItem>
                    <SelectItem value="em_execucao">Em Execução</SelectItem>
                    <SelectItem value="pausada">Pausadas</SelectItem>
                    <SelectItem value="vencida">Vencidas</SelectItem>
                    <SelectItem value="concluida">Concluídas</SelectItem>
                    <SelectItem value="cancelada">Canceladas</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={zoneFilter.length === 0 ? "todas" : zoneFilter.length === 1 ? zoneFilter[0] : "multiplas"}
                  onValueChange={(value) => {
                    if (value === "todas") {
                      setZoneFilter([]);
                    } else {
                      setZoneFilter([value]);
                    }
                  }}
                >
                  <SelectTrigger className="w-full" data-testid="select-zone-filter">
                    <SelectValue placeholder="Todas as Zonas" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todas">Todas as Zonas</SelectItem>
                    {(zones as any[] || []).map((zone: any) => (
                      <SelectItem key={zone.id} value={zone.id}>
                        {zone.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                <Select value={typeFilter} onValueChange={setTypeFilter}>
                  <SelectTrigger className="w-full">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todos">Todos os Tipos</SelectItem>
                    <SelectItem value="programada">Programada</SelectItem>
                    <SelectItem value="corretiva_interna">Corretiva Interna</SelectItem>
                    <SelectItem value="corretiva_publica">Corretiva Pública</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </ModernCardContent>
          </ModernCard>

          {/* Tabela de Ordens de Serviço */}
          <ModernCard>
            <ModernCardHeader icon={<ClipboardList className={cn("w-5 h-5", theme.text.primary)} />}>
              Lista de Ordens de Serviço
            </ModernCardHeader>
            <ModernCardContent>
              
              {filteredWorkOrders.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-gray-500">Nenhuma ordem de serviço encontrada</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-200">
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">ID</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Tipo</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Local</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Título</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Responsável</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Prioridade</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Status</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Data Agendada</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Criada em</th>
                        <th className="text-left py-3 px-4 text-sm font-semibold text-gray-600">Ações</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredWorkOrders.map((wo: any) => (
                        <tr 
                          key={wo.id} 
                          className="border-b border-gray-100 hover:bg-gray-50 transition-colors"
                          data-testid={`row-work-order-${wo.id}`}
                        >
                          <td className="py-3 px-4 text-sm font-medium text-gray-900" data-testid={`text-id-${wo.id}`}>
                            #{wo.number || wo.id?.slice(0, 3)}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-600" data-testid={`text-type-${wo.id}`}>
                            {getTypeLabel(wo.type)}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-600" data-testid={`text-zone-${wo.id}`}>
                            {getZoneName(wo.zoneId)}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-900" data-testid={`text-title-${wo.id}`}>
                            {wo.title || 'Sem título'}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-600" data-testid={`text-operator-${wo.id}`}>
                            {getUserName(wo.assignedUserId)}
                          </td>
                          <td className="py-3 px-4" data-testid={`badge-priority-${wo.id}`}>
                            {getPriorityBadge(wo.priority)}
                          </td>
                          <td className="py-3 px-4" data-testid={`badge-status-${wo.id}`}>
                            {getStatusBadge(wo.status)}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-600" data-testid={`text-date-${wo.id}`}>
                            {formatDateOnly(wo.scheduledDate)}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-600" data-testid={`text-created-${wo.id}`}>
                            {wo.createdAt ? new Date(wo.createdAt).toLocaleDateString('pt-BR') : '-'}
                          </td>
                          <td className="py-3 px-4">
                            <div className="flex items-center gap-2">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => setSelectedWorkOrder(wo.id)}
                                className={cn(
                                  "hover:scale-110 transition-transform",
                                  theme.text.primary,
                                  `hover:${theme.backgrounds.light}`
                                )}
                                data-testid={`button-view-${wo.id}`}
                              >
                                <Eye className="w-4 h-4" />
                              </Button>
                              {wo.status !== 'cancelada' && wo.status !== 'concluida' && (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => handleCancelWorkOrder(wo.id, wo.title)}
                                  className="text-orange-600 hover:text-orange-700 hover:bg-orange-50 hover:scale-110 transition-transform"
                                  data-testid={`button-cancel-${wo.id}`}
                                  title="Cancelar OS"
                                >
                                  <XCircle className="w-4 h-4" />
                                </Button>
                              )}
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleDeleteWorkOrder(wo.id, wo.title)}
                                className="text-red-600 hover:text-red-700 hover:bg-red-50 hover:scale-110 transition-transform"
                                data-testid={`button-delete-${wo.id}`}
                              >
                                <Trash2 className="w-4 h-4" />
                              </Button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </ModernCardContent>
          </ModernCard>
        </div>
      </main>

      {selectedWorkOrder && (
        <WorkOrderModal
          workOrderId={selectedWorkOrder}
          onClose={() => setSelectedWorkOrder(null)}
        />
      )}
      {showCreateModal && activeClientId && (
        <CreateWorkOrderModal
          customerId={activeClientId}
          onClose={() => setShowCreateModal(false)}
          onSuccess={() => {
            setShowCreateModal(false);
            queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "work-orders"] });
          }}
        />
      )}
    </>
  );
}
