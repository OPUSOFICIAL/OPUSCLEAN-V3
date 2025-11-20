import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { MapPin, Building2, X, Wrench, AlertCircle } from "lucide-react";
import { useState, useEffect } from "react";
import { useToast } from "@/hooks/use-toast";
import { format, parseISO } from "date-fns";
import { Capacitor } from "@capacitor/core";

// Get API base URL for mobile
function getApiBaseUrl(): string {
  if (Capacitor.isNativePlatform()) {
    return import.meta.env.VITE_API_BASE_URL || 'https://52e46882-1982-4c39-ac76-706d618e696f-00-ga4lr9ry58vz.spock.replit.dev';
  }
  return '';
}

interface ServiceSelectionModalProps {
  isOpen: boolean;
  onClose: () => void;
  resolvedContext: any;
  scannedQrCode: string;
  onServiceSelect: (serviceId: string, checklistAnswers?: any, workOrderId?: string) => void;
}

// Helper para parsear data local sem conversão de timezone
const parseLocalDate = (dateString: string | null): Date | null => {
  if (!dateString) return null;
  
  // Se a data já tem horário, use parseISO normal
  if (dateString.includes('T') || dateString.includes(' ')) {
    return parseISO(dateString);
  }
  
  // Para datas sem horário (YYYY-MM-DD), criar data local
  const [year, month, day] = dateString.split('-').map(Number);
  return new Date(year, month - 1, day);
};

export default function ServiceSelectionModal({
  isOpen,
  onClose,
  resolvedContext,
  scannedQrCode,
  onServiceSelect,
}: ServiceSelectionModalProps) {
  const { toast } = useToast();
  const [services, setServices] = useState<any[]>([]);
  const [selectedService, setSelectedService] = useState<string>("");
  const [isLoadingServices, setIsLoadingServices] = useState(true);
  const [availableWorkOrders, setAvailableWorkOrders] = useState<any[]>([]);
  const [isLoadingWorkOrders, setIsLoadingWorkOrders] = useState(false);
  const [dateFilter, setDateFilter] = useState<'today' | 'upcoming' | 'all' | 'paused'>('today');
  const [selectedWorkOrder, setSelectedWorkOrder] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen && resolvedContext?.customer?.id) {
      loadServices();
    }
  }, [isOpen, resolvedContext]);

  useEffect(() => {
    if (selectedService && resolvedContext?.zone?.id) {
      loadWorkOrdersForService(selectedService);
    } else {
      setAvailableWorkOrders([]);
      setSelectedWorkOrder(null);
    }
  }, [selectedService, resolvedContext]);

  const loadServices = async () => {
    setIsLoadingServices(true);
    try {
      const module = resolvedContext?.qrPoint?.module || 'clean';
      const baseUrl = getApiBaseUrl();
      
      // Carregar apenas serviços (não precisamos filtrar por work orders)
      const servicesResponse = await fetch(`${baseUrl}/api/customers/${resolvedContext.customer.id}/services?module=${module}`);
      
      if (servicesResponse.ok) {
        const allServices = await servicesResponse.json();
        
        // Mostrar TODOS os serviços do módulo atual
        const filteredServices = allServices.filter((s: any) => s.module === module);
        
        console.log('[SERVICE MODAL] Serviços disponíveis:', filteredServices.length, 'Total:', allServices.length);
        setServices(filteredServices || []);
      }
    } catch (error) {
      console.error('Erro ao carregar serviços:', error);
    } finally {
      setIsLoadingServices(false);
    }
  };

  const loadWorkOrdersForService = async (serviceId: string) => {
    setIsLoadingWorkOrders(true);
    setSelectedWorkOrder(null);
    try {
      const module = resolvedContext?.qrPoint?.module || 'clean';
      const baseUrl = getApiBaseUrl();
      const response = await fetch(`${baseUrl}/api/customers/${resolvedContext.customer.id}/work-orders?module=${module}`);
      if (response.ok) {
        const workOrdersResponse = await response.json();
        
        // Extrair work orders da estrutura paginada { data: [...], pagination: {...} }
        const allWorkOrders = workOrdersResponse.data || workOrdersResponse;
        
        // Filtrar work orders da zona atual e módulo correto que estão pendentes ou pausadas
        // NOTA: Removida filtragem por serviceId para permitir que colaborador veja todas as OS pendentes
        // independente do service (resolve problema de OS clean linkadas a services maintenance)
        const filtered = allWorkOrders.filter((wo: any) => 
          wo.zoneId === resolvedContext.zone.id &&
          wo.module === module &&
          (wo.status === 'aberta' || wo.status === 'em_execucao' || wo.status === 'pausada')
        );
        
        console.log('[SERVICE MODAL] Work orders filtradas - Zona:', resolvedContext.zone.name, 'Módulo:', module, 'Total:', filtered.length);
        setAvailableWorkOrders(filtered);
      }
    } catch (error) {
      console.error('Erro ao carregar work orders:', error);
    } finally {
      setIsLoadingWorkOrders(false);
    }
  };

  const filteredWorkOrders = availableWorkOrders.filter((wo) => {
    if (dateFilter === 'paused') {
      return wo.status === 'pausada';
    } else if (dateFilter === 'today') {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const scheduledDate = parseLocalDate(wo.scheduledDate);
      return scheduledDate && scheduledDate.toDateString() === today.toDateString();
    } else if (dateFilter === 'upcoming') {
      const scheduledDate = parseLocalDate(wo.scheduledDate);
      return scheduledDate && scheduledDate >= new Date();
    }
    return true;
  });

  const selectedServiceData = services.find(s => s.id === selectedService);

  const handleExecuteExisting = () => {
    if (!selectedWorkOrder) {
      toast({
        title: "Selecione uma OS",
        description: "Escolha uma ordem de serviço para executar",
        variant: "destructive",
      });
      return;
    }
    console.log("✅ Executando OS existente:", selectedWorkOrder);
    onServiceSelect(selectedService, undefined, selectedWorkOrder);
  };

  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 z-[9999] flex items-center justify-center p-4"
      style={{ 
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        backdropFilter: 'blur(8px)'
      }}
    >
      <Card className="w-full max-w-lg max-h-[90vh] bg-white shadow-2xl flex flex-col">
        <CardHeader className="relative pb-4 flex-shrink-0">
          <Button
            variant="ghost"
            size="icon"
            className="absolute right-4 top-4"
            onClick={onClose}
            data-testid="button-close-modal"
          >
            <X className="w-5 h-5" />
          </Button>
          
          <CardTitle className="text-2xl font-bold text-slate-900">
            Executar Serviço
          </CardTitle>
          
          <div className="mt-4 space-y-2">
            <div className="flex items-center gap-2 text-sm text-slate-600">
              <Building2 className="w-4 h-4" />
              <span className="font-medium">{resolvedContext?.site?.name}</span>
            </div>
            <div className="flex items-center gap-2 text-sm text-slate-600">
              <MapPin className="w-4 h-4" />
              <span className="font-medium">{resolvedContext?.zone?.name}</span>
            </div>
            {resolvedContext?.qrPoint && (
              <Badge variant="outline" className="text-xs">
                Ponto: {resolvedContext.qrPoint.name || resolvedContext.qrPoint.code}
              </Badge>
            )}
          </div>
        </CardHeader>

        <CardContent className="space-y-6 overflow-y-auto flex-1">
          {/* Selecionar Serviço */}
          <div className="space-y-3">
            <h3 className="font-semibold text-slate-900">
              Selecione o Serviço
            </h3>
            
            {isLoadingServices ? (
              <div className="text-center py-4 text-slate-500">
                Carregando serviços...
              </div>
            ) : services.length === 0 ? (
              <div className="text-center py-4 text-slate-500">
                Nenhum serviço disponível
              </div>
            ) : (
              <Select value={selectedService} onValueChange={setSelectedService}>
                <SelectTrigger data-testid="select-service" className="w-full">
                  <SelectValue placeholder="Escolha o tipo de serviço" />
                </SelectTrigger>
                <SelectContent className="z-[99999]">
                  {services.map((service) => (
                    <SelectItem key={service.id} value={service.id}>
                      {service.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            )}
          </div>

          {/* Mostrar lista de work orders após selecionar serviço */}
          {selectedService && (
            <div className="space-y-4 border-t pt-4">
              {isLoadingWorkOrders ? (
                <div className="text-center py-4 text-slate-500">
                  Buscando ordens de serviço...
                </div>
              ) : availableWorkOrders.length === 0 ? (
                <div className="border rounded-lg p-6 bg-blue-50 border-blue-200 text-center space-y-4">
                  <AlertCircle className="w-12 h-12 text-blue-500 mx-auto" />
                  <div>
                    <h4 className="font-semibold text-slate-900 mb-1">
                      Nenhuma OS Disponível
                    </h4>
                    <p className="text-sm text-slate-600">
                      Não há ordens de serviço pendentes neste local ({resolvedContext?.zone?.name}).
                    </p>
                    <p className="text-sm text-slate-600 mt-2">
                      Você pode criar uma nova ordem de serviço corretiva de <strong>{selectedServiceData?.name}</strong> agora.
                    </p>
                  </div>
                  <Button
                    onClick={() => onServiceSelect(selectedService)}
                    className="w-full bg-blue-600 hover:bg-blue-700"
                    data-testid="button-create-corrective-os"
                  >
                    <Wrench className="w-4 h-4 mr-2" />
                    Criar Nova OS Corretiva
                  </Button>
                </div>
              ) : (
                <div className="border rounded-lg p-4 space-y-3 bg-amber-50 border-amber-200">
                  <div className="flex items-center gap-2">
                    <Wrench className="w-5 h-5 text-amber-600" />
                    <h4 className="font-semibold text-slate-900">
                      Selecione a Ordem de Serviço
                    </h4>
                  </div>
                  
                  <p className="text-sm text-slate-600">
                    Encontramos {availableWorkOrders.length} ordem(ns) pendente(s) em <strong>{resolvedContext?.zone?.name}</strong>
                  </p>
                  
                  {/* Filtros por data */}
                  <Tabs value={dateFilter} onValueChange={(v) => setDateFilter(v as any)} className="w-full">
                    <TabsList className="grid w-full grid-cols-4">
                      <TabsTrigger value="today" className="text-xs">
                        Hoje
                      </TabsTrigger>
                      <TabsTrigger value="upcoming" className="text-xs">
                        Próximos
                      </TabsTrigger>
                      <TabsTrigger value="paused" className="text-xs">
                        Pausadas
                      </TabsTrigger>
                      <TabsTrigger value="all" className="text-xs">
                        Todos
                      </TabsTrigger>
                    </TabsList>
                  </Tabs>
                  
                  {/* Lista de OS */}
                  {filteredWorkOrders.length === 0 ? (
                    <div className="text-center py-6 text-slate-500 text-sm">
                      {dateFilter === 'today' && 'Nenhuma ordem agendada para hoje'}
                      {dateFilter === 'upcoming' && 'Nenhuma ordem agendada'}
                      {dateFilter === 'paused' && 'Nenhuma ordem pausada'}
                      {dateFilter === 'all' && 'Nenhuma ordem pendente'}
                    </div>
                  ) : (
                    <div className="space-y-2 max-h-64 overflow-y-auto">
                      {filteredWorkOrders.map((wo) => {
                        const isSelected = selectedWorkOrder === wo.id;
                        const scheduledDate = parseLocalDate(wo.scheduledDate);
                        const isToday = scheduledDate && 
                          scheduledDate.toDateString() === new Date().toDateString();
                        
                        return (
                          <button
                            key={wo.id}
                            onClick={() => setSelectedWorkOrder(wo.id)}
                            className={`w-full text-left p-3 rounded-lg border-2 transition-all ${
                              isSelected 
                                ? 'border-amber-600 bg-white shadow-md' 
                                : 'border-slate-200 bg-white hover:border-amber-300'
                            }`}
                            data-testid={`wo-card-${wo.id}`}
                          >
                            <div className="flex items-start justify-between gap-2">
                              <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-2 mb-1 flex-wrap">
                                  <span className="font-semibold text-slate-900">
                                    OS #{wo.number}
                                  </span>
                                  {wo.status === 'pausada' && (
                                    <Badge className="bg-orange-600 text-white text-xs">
                                      ⏸ PAUSADA
                                    </Badge>
                                  )}
                                  {isToday && (
                                    <Badge className="bg-green-600 text-white text-xs">
                                      HOJE
                                    </Badge>
                                  )}
                                  {wo.priority === 'alta' && (
                                    <Badge variant="destructive" className="text-xs">
                                      Urgente
                                    </Badge>
                                  )}
                                </div>
                                <p className="text-sm text-slate-600 truncate">
                                  {wo.title}
                                </p>
                                {scheduledDate && (
                                  <p className="text-xs text-slate-500 mt-1">
                                    Agendada: {format(scheduledDate, 'dd/MM/yyyy HH:mm')}
                                  </p>
                                )}
                              </div>
                              {isSelected && (
                                <div className="flex-shrink-0">
                                  <div className="w-6 h-6 rounded-full bg-amber-600 flex items-center justify-center">
                                    <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                  </div>
                                </div>
                              )}
                            </div>
                          </button>
                        );
                      })}
                    </div>
                  )}
                  
                  <div className="grid grid-cols-2 gap-3">
                    <Button
                      onClick={handleExecuteExisting}
                      disabled={!selectedWorkOrder}
                      className="bg-amber-600 hover:bg-amber-700 disabled:opacity-50"
                      data-testid="button-execute-existing"
                    >
                      <Wrench className="w-4 h-4 mr-2" />
                      Executar OS
                    </Button>
                    <Button
                      onClick={() => onServiceSelect(selectedService)}
                      variant="outline"
                      className="border-blue-600 text-blue-600 hover:bg-blue-50"
                      data-testid="button-create-new-os"
                    >
                      Criar Nova OS
                    </Button>
                  </div>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
