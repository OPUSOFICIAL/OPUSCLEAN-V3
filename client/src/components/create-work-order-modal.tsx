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
import { X, Save, Calendar, Timer, MapPin, User, Settings, AlertCircle, CheckSquare } from "lucide-react";

interface CreateWorkOrderModalProps {
  customerId: string;
  onClose: () => void;
  onSuccess: () => void;
}

export default function CreateWorkOrderModal({ customerId, onClose, onSuccess }: CreateWorkOrderModalProps) {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    type: "corretiva_interna",
    priority: "media",
    zoneId: "",
    assignedUserId: "unassigned",
    serviceId: "",
    scheduledDate: "",
    dueDate: "",
    // Campos opcionais de horário
    startTime: "",
    endTime: ""
  });
  
  const { toast } = useToast();

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", customerId, "sites"],
    enabled: !!customerId,
  });

  const { data: users } = useQuery({
    queryKey: ["/api/customers", customerId, "users"],
    enabled: !!customerId,
  });

  const { data: services } = useQuery({
    queryKey: ["/api/customers", customerId, "services"],
    enabled: !!customerId,
  });

  // Buscar dados do customer para pegar o companyId
  const { data: customer } = useQuery({
    queryKey: ["/api/customers", customerId],
    enabled: !!customerId,
  });

  // Carregar todas as zones de todos os sites
  const { data: allZones } = useQuery({
    queryKey: ["/api/customers", customerId, "all-zones"],
    queryFn: async () => {
      if (!sites || !Array.isArray(sites)) return [];
      
      const zonePromises = sites.map(async (site: any) => {
        const response = await apiRequest("GET", `/api/sites/${site.id}/zones`);
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
      // Calcular scheduledStartAt com horário personalizado se fornecido
      let scheduledStartAt = new Date().toISOString();
      let scheduledEndAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
      
      if (data.scheduledDate) {
        const baseDate = new Date(data.scheduledDate);
        
        if (data.startTime) {
          const [hours, minutes] = data.startTime.split(':');
          baseDate.setHours(parseInt(hours), parseInt(minutes), 0, 0);
          scheduledStartAt = baseDate.toISOString();
        }
        
        if (data.endTime) {
          const endDate = new Date(data.scheduledDate);
          const [hours, minutes] = data.endTime.split(':');
          endDate.setHours(parseInt(hours), parseInt(minutes), 0, 0);
          scheduledEndAt = endDate.toISOString();
        }
      }
      
      const submitData = {
        ...data,
        companyId: (customer as any)?.companyId || "company-opus-default",
        status: "aberta",
        assignedUserId: data.assignedUserId === "unassigned" ? null : data.assignedUserId,
        serviceId: data.serviceId || null,
        scheduledDate: data.scheduledDate ? new Date(data.scheduledDate).toISOString() : null,
        dueDate: data.dueDate ? new Date(data.dueDate).toISOString() : null,
        scheduledStartAt,
        scheduledEndAt,
      };
      return await apiRequest("POST", "/api/work-orders", submitData);
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço criada com sucesso!" });
      onSuccess();
    },
    onError: (error: any) => {
      const errorMessage = error?.message || "Erro ao criar ordem de serviço";
      const errorDetails = error?.details || "Verifique se todos os campos obrigatórios foram preenchidos corretamente.";
      
      toast({ 
        title: errorMessage,
        description: errorDetails,
        variant: "destructive" 
      });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.title || !formData.zoneId || !formData.serviceId) {
      toast({
        title: "Campos obrigatórios",
        description: "Preencha o título, selecione um local e um serviço",
        variant: "destructive"
      });
      return;
    }

    createWorkOrderMutation.mutate(formData);
  };

  const handleChange = (field: string, value: string) => {
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

          {/* Local e Serviços */}
          <div className="space-y-4 p-4 bg-green-50 rounded-lg border border-green-200">
            <h4 className="font-semibold text-green-900 flex items-center gap-2">
              <MapPin className="w-4 h-4" />
              Local e Serviços
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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

              <div className="space-y-2">
                <Label htmlFor="service">Serviço *</Label>
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