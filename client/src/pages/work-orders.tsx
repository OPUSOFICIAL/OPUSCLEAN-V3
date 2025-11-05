import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Checkbox } from "@/components/ui/checkbox";
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
  ClipboardList
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
  const [searchTerm, setSearchTerm] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [lastUpdate, setLastUpdate] = useState(new Date());
  const [isRefreshing, setIsRefreshing] = useState(false);
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: workOrders, isLoading, refetch } = useQuery({
    queryKey: ["/api/customers", activeClientId, "work-orders", { module: currentModule }],
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

  const handleDeleteWorkOrder = (workOrderId: string, workOrderTitle: string) => {
    if (window.confirm(`Tem certeza que deseja deletar a OS "${workOrderTitle}"? Esta ação não pode ser desfeita.`)) {
      deleteWorkOrderMutation.mutate(workOrderId);
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
    
    return matchesStatus && matchesZone && matchesSearch && matchesDateRange;
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
      <div className={cn("flex-1 flex items-center justify-center", theme.gradients.subtle)}>
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
        stats={[
          { label: "Abertas", value: totalAbertas, icon: Clock },
          { label: "Vencidas", value: totalVencidas, icon: AlertTriangle },
          { label: "Pausadas", value: totalPausadas, icon: PauseCircle },
          { label: "Concluídas", value: totalConcluidas, icon: CheckCircle2 }
        ]}
        actions={
          <>
            <Button 
              variant="outline" 
              size="sm" 
              onClick={handleRefresh}
              className={cn("flex items-center gap-2", theme.buttons.outline)}
              data-testid="button-refresh"
            >
              <RefreshCw className={`w-4 h-4 transition-transform duration-1000 ${isRefreshing ? 'rotate-360' : ''}`} />
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
      
      <main className={cn("flex-1 overflow-auto p-6", theme.gradients.subtle)}>
        <div className="max-w-7xl mx-auto space-y-6">
          {/* Info de última atualização */}
          <div className={cn(
            "backdrop-blur-xl bg-white/60 rounded-lg px-4 py-2 w-fit border",
            theme.borders.light
          )}>
            <span className="text-sm text-slate-600 flex items-center gap-2">
              <Clock className="w-3.5 h-3.5" />
              Última atualização: {lastUpdate.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
            </span>
          </div>

          {/* Busca e Filtros */}
          <ModernCard variant="gradient">
            <ModernCardHeader icon={<Search className={cn("w-5 h-5", theme.text.primary)} />}>
              Buscar e Filtrar
            </ModernCardHeader>
            <ModernCardContent>
              {/* Busca */}
              <div className="mb-6">
                <div className="relative">
                  <Search className={cn("absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5", theme.text.light)} />
                  <Input
                    placeholder="Digite o número da OS, título ou descrição..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className={cn(
                      "pl-12 h-12 bg-white/80 backdrop-blur-sm border-2 text-base shadow-sm transition-all duration-200",
                      theme.borders.light,
                      "focus:border-current focus:ring-2 focus:ring-opacity-20"
                    )}
                    style={{
                      borderColor: searchTerm ? theme.primaryHex : undefined,
                      outlineColor: theme.primaryHex + '33'
                    }}
                    data-testid="input-search-work-orders"
                  />
                </div>
              </div>

              {/* Filtros Rápidos */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                <div>
                  <label className={cn("text-xs font-semibold uppercase tracking-wide mb-2 block flex items-center gap-2", theme.text.dark)}>
                    <Filter className={cn("w-3.5 h-3.5", theme.text.primary)} />
                    Status
                  </label>
                  <MultiSelect
                    options={[
                      { value: "aberta", label: "Abertas" },
                      { value: "em_execucao", label: "Em Execução" },
                      { value: "pausada", label: "Pausadas" },
                      { value: "vencida", label: "Vencidas" },
                      { value: "concluida", label: "Concluídas" },
                      { value: "cancelada", label: "Canceladas" }
                    ]}
                    selected={statusFilter}
                    onChange={setStatusFilter}
                    placeholder="Todos os Status"
                    testId="select-status-filter"
                  />
                </div>
                
                <div>
                  <label className={cn("text-xs font-semibold uppercase tracking-wide mb-2 block flex items-center gap-2", theme.text.dark)}>
                    <MapPin className={cn("w-3.5 h-3.5", theme.text.primary)} />
                    Zonas
                  </label>
                  <MultiSelect
                    options={(zones as any[] || []).map((zone: any) => ({
                      value: zone.id,
                      label: zone.name
                    }))}
                    selected={zoneFilter}
                    onChange={setZoneFilter}
                    placeholder="Todas as Zonas"
                    testId="select-zone-filter"
                  />
                </div>
              </div>

              {/* Filtro de Período */}
              <div className={cn(
                "backdrop-blur-sm bg-white/60 border rounded-lg p-4",
                theme.borders.light
              )}>
                <label className={cn("text-xs font-semibold uppercase tracking-wide mb-3 block flex items-center gap-2", theme.text.dark)}>
                  <Calendar className={cn("w-3.5 h-3.5", theme.text.primary)} />
                  Filtrar por Período de Agendamento
                </label>
                <div className="flex flex-wrap items-center gap-4">
                  <div className="flex items-center gap-3 flex-1 min-w-[200px]">
                    <span className="text-sm font-medium text-slate-600 whitespace-nowrap">De:</span>
                    <Input
                      type="date"
                      value={startDate}
                      onChange={(e) => setStartDate(e.target.value)}
                      className="flex-1 border-slate-300 focus:ring-2 focus:ring-opacity-20 shadow-sm"
                      data-testid="input-start-date"
                    />
                  </div>
                  <div className="flex items-center gap-3 flex-1 min-w-[200px]">
                    <span className="text-sm font-medium text-slate-600 whitespace-nowrap">Até:</span>
                    <Input
                      type="date"
                      value={endDate}
                      onChange={(e) => setEndDate(e.target.value)}
                      className="flex-1 border-slate-300 focus:ring-2 focus:ring-opacity-20 shadow-sm"
                      data-testid="input-end-date"
                    />
                  </div>
                </div>
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
