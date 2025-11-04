import Header from "@/components/layout/header";
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
  X
} from "lucide-react";
import WorkOrderModal from "@/components/work-order-modal";
import CreateWorkOrderModal from "@/components/create-work-order-modal";

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
  
  const totalConcluidas = (workOrders as any[])?.filter((wo: any) => 
    wo.status === 'concluida'
  ).length || 0;

  // Descrição dinâmica baseada no módulo
  const headerDescription = currentModule === 'maintenance' 
    ? "Gerenciamento de ordens de serviço de manutenção" 
    : "Gerenciamento de ordens de serviço de limpeza";

  if (isLoading) {
    return (
      <>
        <Header title="Ordens de Serviço" description={headerDescription} />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
            <p className="text-gray-600">Carregando...</p>
          </div>
        </div>
      </>
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
      <Header 
        title="Ordens de Serviço" 
        description={headerDescription} 
      />
      
      <main className="flex-1 overflow-auto p-6 bg-gray-50">
        <div className="max-w-7xl mx-auto space-y-6">
          {/* Header com última atualização */}
          <div className="flex items-center justify-between">
            <div className="text-sm text-gray-600">
              Última atualização: {lastUpdate.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
            </div>
            <div className="flex items-center gap-3">
              <Button 
                variant="outline" 
                size="sm" 
                onClick={handleRefresh}
                className="flex items-center gap-2"
                data-testid="button-refresh"
              >
                <RefreshCw className={`w-4 h-4 transition-transform duration-1000 ${isRefreshing ? 'rotate-360' : ''}`} />
                Atualizar
              </Button>
              <Button 
                onClick={() => setShowCreateModal(true)} 
                className="bg-blue-600 hover:bg-blue-700"
                data-testid="button-create-work-order"
              >
                <Plus className="w-4 h-4 mr-2" />
                Nova OS
              </Button>
            </div>
          </div>

          {/* Busca e Filtros */}
          <Card className="bg-white shadow-sm">
            <CardContent className="pt-6">
              <div className="flex gap-4 items-center mb-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                  <Input
                    placeholder="Buscar por ID ou descrição..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10"
                    data-testid="input-search-work-orders"
                  />
                </div>
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

              {/* Filtro de Data */}
              <div className="flex items-center gap-4">
                <Filter className="w-4 h-4 text-blue-600" />
                <span className="text-sm font-medium text-blue-600">Data Agendada:</span>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-gray-600">De:</span>
                  <Input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-[160px]"
                    data-testid="input-start-date"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-gray-600">Até:</span>
                  <Input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-[160px]"
                    data-testid="input-end-date"
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Cards de Estatísticas */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Total Abertas */}
            <Card className="bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200" data-testid="card-stat-abertas">
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-blue-700 mb-1 uppercase">Total Abertas</p>
                    <p className="text-4xl font-bold text-blue-900" data-testid="text-total-abertas">{totalAbertas}</p>
                    <p className="text-sm text-blue-600 mt-1">Ordens pendentes</p>
                  </div>
                  <div className="w-16 h-16 bg-blue-500 rounded-2xl flex items-center justify-center">
                    <Clock className="w-8 h-8 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Vencidas */}
            <Card className="bg-gradient-to-br from-red-50 to-red-100 border-red-200" data-testid="card-stat-vencidas">
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-red-700 mb-1 uppercase">Vencidas</p>
                    <p className="text-4xl font-bold text-red-900" data-testid="text-total-vencidas">{totalVencidas}</p>
                    <p className="text-sm text-red-600 mt-1">Fora do prazo</p>
                  </div>
                  <div className="w-16 h-16 bg-red-500 rounded-2xl flex items-center justify-center">
                    <AlertTriangle className="w-8 h-8 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Concluídas */}
            <Card className="bg-gradient-to-br from-green-50 to-green-100 border-green-200" data-testid="card-stat-concluidas">
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-green-700 mb-1 uppercase">Concluídas</p>
                    <p className="text-4xl font-bold text-green-900" data-testid="text-total-concluidas">{totalConcluidas}</p>
                    <p className="text-sm text-green-600 mt-1">Finalizadas</p>
                  </div>
                  <div className="w-16 h-16 bg-green-600 rounded-2xl flex items-center justify-center">
                    <CheckCircle2 className="w-8 h-8 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Tabela de Ordens de Serviço */}
          <Card className="bg-white shadow-sm">
            <CardContent className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-4">Lista de Ordens de Serviço</h2>
              
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
                                className="text-blue-600 hover:text-blue-700 hover:bg-blue-50"
                                data-testid={`button-view-${wo.id}`}
                              >
                                <Eye className="w-4 h-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleDeleteWorkOrder(wo.id, wo.title)}
                                className="text-red-600 hover:text-red-700 hover:bg-red-50"
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
            </CardContent>
          </Card>
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
