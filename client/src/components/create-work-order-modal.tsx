import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";
import { useModule } from "@/contexts/ModuleContext";
import { X, Save, Calendar, Timer, MapPin, User, Settings, AlertCircle, CheckSquare } from "lucide-react";

interface CreateWorkOrderModalProps {
  customerId: string;
  onClose: () => void;
  onSuccess: () => void;
}

export default function CreateWorkOrderModal({ customerId, onClose, onSuccess }: CreateWorkOrderModalProps) {
  const { currentModule } = useModule();
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    type: "corretiva_interna",
    priority: "media",
    zoneId: "",
    assignedUserId: "unassigned",
    // Campos específicos do Clean
    serviceId: "",
    // Campos específicos do Manutenção
    equipmentId: "",
    maintenanceChecklistTemplateId: "",
    // Datas
    scheduledDate: "",
    dueDate: "",
    // Campos opcionais de horário
    startTime: "",
    endTime: ""
  });
  
  const { toast } = useToast();

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", customerId, "sites", { module: currentModule }],
    enabled: !!customerId,
  });

  const { data: users } = useQuery({
    queryKey: ["/api/customers", customerId, "users"],
    enabled: !!customerId,
  });

  // Serviços para módulo Clean
  const { data: services } = useQuery({
    queryKey: ["/api/customers", customerId, "service-types", { module: currentModule }],
    enabled: !!customerId && currentModule === 'clean',
  });

  // Equipamentos para módulo Manutenção
  const { data: equipmentList } = useQuery({
    queryKey: ["/api/customers", customerId, "equipment"],
    enabled: !!customerId && currentModule === 'maintenance',
  });

  // Templates de checklist de manutenção
  const { data: maintenanceChecklistTemplates } = useQuery({
    queryKey: ["/api/customers", customerId, "maintenance-checklist-templates"],
    enabled: !!customerId && currentModule === 'maintenance',
  });

  // Filtrar equipamentos pela zona selecionada
  const filteredEquipment = (equipmentList as any[] || []).filter((eq: any) => 
    formData.zoneId ? eq.zoneId === formData.zoneId : true
  );

  // Filtrar checklists pelo equipamento selecionado
  const filteredChecklists = (maintenanceChecklistTemplates as any[] || []).filter((template: any) => {
    if (!formData.equipmentId) return true;
    // Checklist deve ter o equipmentId no array de equipmentIds
    return template.equipmentIds && Array.isArray(template.equipmentIds) && 
           template.equipmentIds.includes(formData.equipmentId);
  });

  // Buscar dados do customer para pegar o companyId
  const { data: customer } = useQuery({
    queryKey: ["/api/customers", customerId],
    enabled: !!customerId,
  });

  // Carregar todas as zones de todos os sites (filtrado por módulo)
  const { data: allZones } = useQuery({
    queryKey: ["/api/customers", customerId, "all-zones", { module: currentModule }],
    queryFn: async () => {
      if (!sites || !Array.isArray(sites)) return [];
      
      const zonePromises = sites.map(async (site: any) => {
        const response = await apiRequest("GET", `/api/sites/${site.id}/zones?module=${currentModule}`);
        const zones = await response.json() as any[];
        return zones.map(zone => ({
          ...zone,
          siteName: site.name
        }));
      });
      
      const allSitesZones = await Promise.all(zonePromises);
      return allSitesZones.flat();
    },
    enabled: !!sites && Array.isArray(sites),
  });


  const createWorkOrderMutation = useMutation({
    mutationFn: async (data: any) => {
      // Preparar dados para envio - converter strings de data para Date objects ou null
      const submitData: any = {
        title: data.title,
        description: data.description || null,
        type: data.type,
        priority: data.priority,
        status: "aberta",
        zoneId: data.zoneId,
        companyId: (customer as any)?.companyId || "company-opus-default",
        assignedUserId: data.assignedUserId === "unassigned" ? null : data.assignedUserId,
        scheduledDate: data.scheduledDate || null,
        dueDate: data.dueDate || null,
        scheduledStartAt: null,
        scheduledEndAt: null,
        module: currentModule, // Incluir o módulo atual
      };

      // Campos específicos do módulo Clean
      if (currentModule === 'clean') {
        submitData.serviceId = data.serviceId || null;
      }

      // Campos específicos do módulo Manutenção
      if (currentModule === 'maintenance') {
        submitData.equipmentId = data.equipmentId || null;
        submitData.maintenanceChecklistTemplateId = data.maintenanceChecklistTemplateId || null;
      }
      
      // Calcular scheduledStartAt e scheduledEndAt se tiver horários
      if (data.scheduledDate && data.startTime) {
        const baseDate = new Date(data.scheduledDate);
        const [hours, minutes] = data.startTime.split(':');
        baseDate.setHours(parseInt(hours), parseInt(minutes), 0, 0);
        submitData.scheduledStartAt = baseDate.toISOString();
      }
      
      if (data.scheduledDate && data.endTime) {
        const endDate = new Date(data.scheduledDate);
        const [hours, minutes] = data.endTime.split(':');
        endDate.setHours(parseInt(hours), parseInt(minutes), 0, 0);
        submitData.scheduledEndAt = endDate.toISOString();
      }
      
      return await apiRequest("POST", "/api/work-orders", submitData);
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço criada com sucesso!" });
      onSuccess();
    },
    onError: (error: any) => {
      let errorMessage = "Erro ao criar ordem de serviço";
      let errorDetails = "Verifique se todos os campos obrigatórios foram preenchidos corretamente.";
      
      // Tentar extrair mensagem do erro
      if (error?.message) {
        // Se a mensagem for um JSON string, fazer parse
        if (error.message.startsWith('{')) {
          try {
            const parsed = JSON.parse(error.message);
            errorMessage = parsed.message || errorMessage;
            errorDetails = parsed.details || errorDetails;
          } catch (e) {
            errorMessage = error.message;
          }
        } else {
          errorMessage = error.message;
        }
      }
      
      // Se já tiver details separado, usar ele
      if (error?.details) {
        errorDetails = error.details;
      }
      
      toast({ 
        title: errorMessage,
        description: errorDetails,
        variant: "destructive" 
      });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validação básica
    if (!formData.title || !formData.zoneId) {
      toast({
        title: "Campos obrigatórios",
        description: "Preencha o título e selecione um local",
        variant: "destructive"
      });
      return;
    }

    // Validação específica por módulo
    if (currentModule === 'clean' && !formData.serviceId) {
      toast({
        title: "Campos obrigatórios",
        description: "Selecione um tipo de serviço",
        variant: "destructive"
      });
      return;
    }

    if (currentModule === 'maintenance' && !formData.equipmentId) {
      toast({
        title: "Campos obrigatórios",
        description: "Selecione um equipamento",
        variant: "destructive"
      });
      return;
    }

    createWorkOrderMutation.mutate(formData);
  };

  const handleChange = (field: string, value: string) => {
    // Se mudar a zona, resetar equipamento e checklist
    if (field === 'zoneId' && currentModule === 'maintenance') {
      setFormData(prev => ({ 
        ...prev, 
        [field]: value,
        equipmentId: "", // Resetar equipamento
        maintenanceChecklistTemplateId: "" // Resetar checklist
      }));
      return;
    }
    
    // Se mudar o equipamento, resetar checklist
    if (field === 'equipmentId' && currentModule === 'maintenance') {
      setFormData(prev => ({ 
        ...prev, 
        [field]: value,
        maintenanceChecklistTemplateId: "" // Resetar checklist
      }));
      return;
    }
    
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <Dialog open={true} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto" data-testid="create-work-order-modal">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold">Nova Ordem de Serviço</DialogTitle>
          <DialogDescription>
            Preencha as informações para criar uma nova ordem de serviço
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Informações Básicas */}
          <div className="space-y-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <h4 className="font-semibold text-blue-900 flex items-center gap-2">
              <Settings className="w-4 h-4" />
              Informações Básicas
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="title">Título *</Label>
                <Input
                  id="title"
                  placeholder="Ex: Limpeza do banheiro masculino"
                  value={formData.title}
                  onChange={(e) => handleChange("title", e.target.value)}
                  data-testid="input-title"
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="type">Tipo de OS</Label>
                <Select value={formData.type} onValueChange={(value) => handleChange("type", value)}>
                  <SelectTrigger data-testid="select-type">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="programada">Programada</SelectItem>
                    <SelectItem value="corretiva_interna">Corretiva Interna</SelectItem>
                    <SelectItem value="corretiva_publica">Corretiva Pública</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="priority">Prioridade</Label>
                <Select value={formData.priority} onValueChange={(value) => handleChange("priority", value)}>
                  <SelectTrigger data-testid="select-priority">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="baixa">Baixa</SelectItem>
                    <SelectItem value="media">Média</SelectItem>
                    <SelectItem value="alta">Alta</SelectItem>
                    <SelectItem value="critica">Crítica</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="assigned">Responsável</Label>
                <Select value={formData.assignedUserId} onValueChange={(value) => handleChange("assignedUserId", value)}>
                  <SelectTrigger data-testid="select-assigned-user">
                    <SelectValue placeholder="Selecione um responsável" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="unassigned">Não atribuído</SelectItem>
                    {(users as any[] || [])
                      .filter((user: any) => user.role === "operador" || user.role === "supervisor_site")
                      .map((user: any) => (
                        <SelectItem key={user.id} value={user.id}>
                          <div className="flex items-center gap-2">
                            <User className="w-4 h-4" />
                            {user.name}
                          </div>
                        </SelectItem>
                      ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Descrição</Label>
              <Textarea
                id="description"
                placeholder="Descreva detalhes sobre a ordem de serviço..."
                value={formData.description}
                onChange={(e) => handleChange("description", e.target.value)}
                data-testid="textarea-description"
                rows={3}
              />
            </div>
          </div>

          {/* Local e Campos Específicos do Módulo */}
          <div className={`space-y-4 p-4 rounded-lg border ${
            currentModule === 'maintenance' ? 'bg-orange-50 border-orange-200' : 'bg-green-50 border-green-200'
          }`}>
            <h4 className={`font-semibold flex items-center gap-2 ${
              currentModule === 'maintenance' ? 'text-orange-900' : 'text-green-900'
            }`}>
              <MapPin className="w-4 h-4" />
              {currentModule === 'maintenance' ? 'Local e Equipamento' : 'Local e Serviços'}
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Local (sempre presente) */}
              <div className="space-y-2">
                <Label htmlFor="zone">Local *</Label>
                <Select value={formData.zoneId} onValueChange={(value) => handleChange("zoneId", value)}>
                  <SelectTrigger data-testid="select-zone">
                    <SelectValue placeholder="Selecione um local" />
                  </SelectTrigger>
                  <SelectContent>
                    {!allZones ? (
                      <SelectItem value="loading" disabled>Carregando locais...</SelectItem>
                    ) : Array.isArray(allZones) && allZones.length > 0 ? (
                      allZones.map((zone: any) => (
                        <SelectItem key={zone.id} value={zone.id}>
                          <div>
                            <div className="font-medium">{zone.name}</div>
                            <div className="text-xs text-gray-500">{zone.siteName}</div>
                          </div>
                        </SelectItem>
                      ))
                    ) : (
                      <SelectItem value="no-zones" disabled>Nenhum local cadastrado</SelectItem>
                    )}
                  </SelectContent>
                </Select>
              </div>

              {/* Campos específicos do módulo CLEAN */}
              {currentModule === 'clean' && (
                <div className="space-y-2">
                  <Label htmlFor="service">Tipo de Serviço *</Label>
                  <Select value={formData.serviceId} onValueChange={(value) => handleChange("serviceId", value)}>
                    <SelectTrigger data-testid="select-service">
                      <SelectValue placeholder="Selecione um serviço" />
                    </SelectTrigger>
                    <SelectContent>
                      {(services as any[] || []).map((service: any) => (
                        <SelectItem key={service.id} value={service.id}>
                          <div>
                            <div className="font-medium">{service.name}</div>
                            <div className="text-xs text-gray-500">{service.description}</div>
                          </div>
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              )}

              {/* Campos específicos do módulo MANUTENÇÃO */}
              {currentModule === 'maintenance' && (
                <>
                  <div className="space-y-2">
                    <Label htmlFor="equipment">Equipamento *</Label>
                    <Select 
                      value={formData.equipmentId} 
                      onValueChange={(value) => handleChange("equipmentId", value)}
                      disabled={!formData.zoneId}
                    >
                      <SelectTrigger data-testid="select-equipment">
                        <SelectValue placeholder={!formData.zoneId ? "Primeiro selecione um local" : "Selecione um equipamento"} />
                      </SelectTrigger>
                      <SelectContent>
                        {!equipmentList ? (
                          <SelectItem value="loading" disabled>Carregando equipamentos...</SelectItem>
                        ) : filteredEquipment.length > 0 ? (
                          filteredEquipment
                            .filter((eq: any) => eq.status === 'operacional')
                            .map((equipment: any) => (
                              <SelectItem key={equipment.id} value={equipment.id}>
                                <div>
                                  <div className="font-medium">{equipment.name}</div>
                                  <div className="text-xs text-gray-500">
                                    {equipment.manufacturer} - {equipment.model}
                                  </div>
                                </div>
                              </SelectItem>
                            ))
                        ) : formData.zoneId ? (
                          <SelectItem value="no-equipment" disabled>Nenhum equipamento neste local</SelectItem>
                        ) : (
                          <SelectItem value="no-zone" disabled>Selecione um local primeiro</SelectItem>
                        )}
                      </SelectContent>
                    </Select>
                    {formData.zoneId && filteredEquipment.length === 0 && (
                      <p className="text-xs text-orange-600">Não há equipamentos cadastrados neste local</p>
                    )}
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="checklist">Checklist de Manutenção (Opcional)</Label>
                    <Select 
                      value={formData.maintenanceChecklistTemplateId || "none"} 
                      onValueChange={(value) => handleChange("maintenanceChecklistTemplateId", value === "none" ? "" : value)}
                      disabled={!formData.equipmentId}
                    >
                      <SelectTrigger data-testid="select-maintenance-checklist">
                        <SelectValue placeholder={!formData.equipmentId ? "Primeiro selecione um equipamento" : "Selecione um checklist"} />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="none">Nenhum</SelectItem>
                        {filteredChecklists.length > 0 ? (
                          filteredChecklists.map((template: any) => (
                            <SelectItem key={template.id} value={template.id}>
                              <div>
                                <div className="font-medium">{template.name}</div>
                                <div className="text-xs text-gray-500">{template.description}</div>
                              </div>
                            </SelectItem>
                          ))
                        ) : formData.equipmentId ? (
                          <SelectItem value="no-checklist" disabled>Nenhum checklist para este equipamento</SelectItem>
                        ) : null}
                      </SelectContent>
                    </Select>
                    {formData.equipmentId && filteredChecklists.length === 0 && (
                      <p className="text-xs text-orange-600">Não há checklists disponíveis para este equipamento</p>
                    )}
                  </div>
                </>
              )}
            </div>
          </div>


          {/* Datas de Planejamento */}
          <div className="space-y-4 p-4 bg-amber-50 rounded-lg border border-amber-200">
            <h4 className="font-semibold text-amber-900 flex items-center gap-2">
              <Calendar className="w-4 h-4" />
              Datas de Planejamento
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="scheduledDate">Data Agendada</Label>
                <Input
                  id="scheduledDate"
                  type="date"
                  value={formData.scheduledDate}
                  onChange={(e) => handleChange("scheduledDate", e.target.value)}
                  data-testid="input-scheduled-date"
                />
              </div>

              {/* Campos opcionais de horário */}
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

              <div className="space-y-2">
                <Label htmlFor="dueDate">Data Limite</Label>
                <Input
                  id="dueDate"
                  type="date"
                  value={formData.dueDate}
                  onChange={(e) => handleChange("dueDate", e.target.value)}
                  data-testid="input-due-date"
                />
              </div>
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-4 border-t">
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
              disabled={createWorkOrderMutation.isPending}
              data-testid="button-create"
            >
              <Save className="w-4 h-4 mr-2" />
              {createWorkOrderMutation.isPending ? "Criando..." : "Criar OS"}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}