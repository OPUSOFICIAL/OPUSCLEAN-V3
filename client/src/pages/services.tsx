import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { 
  Settings, 
  Plus, 
  Edit, 
  Trash2, 
  Clock, 
  AlertTriangle,
  Wrench,
  Users,
  Building,
  Zap
} from "lucide-react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useToast } from "@/hooks/use-toast";
import { apiRequest } from "@/lib/queryClient";

interface ServicesProps {
  customerId: string;
}

const serviceFormSchema = z.object({
  name: z.string().min(1, "Nome é obrigatório"),
  description: z.string().optional(),
  categoryId: z.string().min(1, "Categoria é obrigatória"),
  typeId: z.string().min(1, "Tipo é obrigatório"),
  estimatedDurationMinutes: z.number().min(1).optional(),
  priority: z.enum(["baixa", "media", "alta", "critica"]).default("media"),
});

type ServiceFormData = z.infer<typeof serviceFormSchema>;

const categoryLabels = {
  // Hard Services
  manutencao_eletrica: "Manutenção Elétrica",
  manutencao_hidraulica: "Manutenção Hidráulica", 
  climatizacao_hvac: "Climatização (HVAC)",
  elevadores_equipamentos: "Elevadores e Equipamentos",
  sistemas_seguranca_fisica: "Sistemas de Segurança Física",
  manutencao_preventiva: "Manutenção Preventiva",
  manutencao_corretiva: "Manutenção Corretiva",
  sistema_incendio: "Sistema de Incêndio",
  telecomunicacoes_dados: "Telecomunicações e Dados",
  infraestrutura_predial: "Infraestrutura Predial",
  automacao_predial: "Automação Predial",
  // Soft Services
  limpeza_conservacao: "Limpeza e Conservação",
  portaria_recepcao: "Portaria e Recepção",
  jardinagem_paisagismo: "Jardinagem e Paisagismo",
  seguranca_patrimonial: "Segurança Patrimonial",
  servicos_administrativos: "Serviços Administrativos",
  gestao_residuos: "Gestão de Resíduos",
  controle_pragas: "Controle de Pragas",
  catering_alimentacao: "Catering e Alimentação",
  decoracao_ambientacao: "Decoração e Ambientação",
  correio_interno: "Correio Interno",
  atendimento_telefone: "Atendimento Telefônico"
};

const typeLabels = {
  hard_service: "Hard Service",
  soft_service: "Soft Service"
};

const priorityLabels = {
  baixa: "Baixa",
  media: "Média", 
  alta: "Alta",
  critica: "Crítica"
};

export default function Services({ customerId }: ServicesProps) {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingService, setEditingService] = useState<any>(null);
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: services = [], isLoading } = useQuery<any[]>({
    queryKey: ["/api/customers", customerId, "services"],
    enabled: !!customerId,
  });

  // Get service types from database
  const { data: serviceTypes = [] } = useQuery<any[]>({
    queryKey: ["/api/customers", customerId, "service-types"],
    enabled: !!customerId,
  });

  // Get service categories from database
  const { data: serviceCategories = [] } = useQuery<any[]>({
    queryKey: ["/api/customers", customerId, "service-categories"],
    enabled: !!customerId,
  });

  const form = useForm<ServiceFormData>({
    resolver: zodResolver(serviceFormSchema),
    defaultValues: {
      name: "",
      description: "",
      priority: "media",
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: ServiceFormData) => {
      return apiRequest("POST", `/api/services`, { ...data, customerId });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customerId, "services"] });
      setIsDialogOpen(false);
      form.reset();
      toast({
        title: "Serviço criado",
        description: "O serviço foi criado com sucesso.",
      });
    },
    onError: () => {
      toast({
        title: "Erro",
        description: "Falha ao criar serviço.",
        variant: "destructive",
      });
    },
  });

  const updateMutation = useMutation({
    mutationFn: async (data: ServiceFormData) => {
      return apiRequest("PUT", `/api/services/${editingService.id}`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customerId, "services"] });
      setIsDialogOpen(false);
      setEditingService(null);
      form.reset();
      toast({
        title: "Serviço atualizado",
        description: "O serviço foi atualizado com sucesso.",
      });
    },
    onError: () => {
      toast({
        title: "Erro",
        description: "Falha ao atualizar serviço.",
        variant: "destructive",
      });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (serviceId: string) => {
      return apiRequest("DELETE", `/api/services/${serviceId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customerId, "services"] });
      toast({
        title: "Serviço excluído",
        description: "O serviço foi excluído com sucesso.",
      });
    },
    onError: () => {
      toast({
        title: "Erro",
        description: "Falha ao excluir serviço.",
        variant: "destructive",
      });
    },
  });

  const handleSubmit = (data: ServiceFormData) => {
    if (editingService) {
      updateMutation.mutate(data);
    } else {
      createMutation.mutate(data);
    }
  };

  const handleEdit = (service: any) => {
    setEditingService(service);
    form.reset({
      name: service.name,
      description: service.description || "",
      categoryId: service.categoryId,
      typeId: service.typeId,
      estimatedDurationMinutes: service.estimatedDurationMinutes || undefined,
      priority: service.priority,
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (serviceId: string) => {
    if (confirm("Tem certeza que deseja excluir este serviço?")) {
      deleteMutation.mutate(serviceId);
    }
  };

  const getCategoryIcon = (category: string) => {
    const hardServiceCategories = ["manutencao_eletrica", "manutencao_hidraulica", "climatizacao", "elevadores", "sistemas_seguranca"];
    
    if (hardServiceCategories.includes(category)) {
      switch (category) {
        case "manutencao_eletrica": return <Zap className="w-4 h-4" />;
        case "sistemas_seguranca": return <AlertTriangle className="w-4 h-4" />;
        default: return <Wrench className="w-4 h-4" />;
      }
    } else {
      switch (category) {
        case "portaria_recepcao": return <Users className="w-4 h-4" />;
        case "jardinagem_paisagismo": return <Building className="w-4 h-4" />;
        default: return <Settings className="w-4 h-4" />;
      }
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "critica": return "bg-red-100 text-red-800";
      case "alta": return "bg-orange-100 text-orange-800";
      case "media": return "bg-yellow-100 text-yellow-800";
      case "baixa": return "bg-green-100 text-green-800";
      default: return "bg-gray-100 text-gray-800";
    }
  };

  const getTypeColor = (type: string) => {
    return type === "hard_service" ? "bg-blue-100 text-blue-800" : "bg-purple-100 text-purple-800";
  };

  if (isLoading) {
    return <div className="p-3 md:p-6">Carregando serviços...</div>;
  }

  return (
    <div className="p-3 md:p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Serviços de Facilities</h1>
          <p className="text-gray-600">Gerencie os serviços oferecidos pela empresa</p>
        </div>
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button 
              data-testid="button-add-service"
              onClick={() => {
                setEditingService(null);
                form.reset();
              }}
            >
              <Plus className="w-4 h-4 mr-2" />
              Novo Serviço
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl max-h-[80vh] overflow-auto">
            <DialogHeader>
              <DialogTitle>
                {editingService ? "Editar Serviço" : "Novo Serviço"}
              </DialogTitle>
            </DialogHeader>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nome</FormLabel>
                      <FormControl>
                        <Input {...field} placeholder="Nome do serviço" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="typeId"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Tipo</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Selecione o tipo" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {serviceTypes.map((type: any) => (
                            <SelectItem key={type.id} value={type.id}>
                              {type.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="categoryId"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Categoria</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Selecione a categoria" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {serviceCategories.map((category: any) => (
                            <SelectItem key={category.id} value={category.id}>
                              {category.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="priority"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Prioridade</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Selecione a prioridade" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="baixa">Baixa</SelectItem>
                          <SelectItem value="media">Média</SelectItem>
                          <SelectItem value="alta">Alta</SelectItem>
                          <SelectItem value="critica">Crítica</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="estimatedDurationMinutes"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Duração Estimada (minutos)</FormLabel>
                      <FormControl>
                        <Input 
                          type="number" 
                          {...field} 
                          onChange={(e) => field.onChange(e.target.value ? parseInt(e.target.value) : undefined)}
                          value={field.value || ""}
                          placeholder="120"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="description"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Descrição</FormLabel>
                      <FormControl>
                        <Textarea {...field} placeholder="Descrição do serviço" rows={3} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <div className="flex gap-2 pt-4">
                  <Button 
                    type="submit" 
                    data-testid="button-save-service"
                    disabled={createMutation.isPending || updateMutation.isPending}
                  >
                    {createMutation.isPending || updateMutation.isPending ? "Salvando..." : "Salvar"}
                  </Button>
                  <Button 
                    type="button" 
                    variant="outline" 
                    onClick={() => setIsDialogOpen(false)}
                  >
                    Cancelar
                  </Button>
                </div>
              </form>
            </Form>
          </DialogContent>
        </Dialog>
      </div>

      {services.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-16">
            <Settings className="w-12 h-12 text-gray-400 mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Nenhum serviço cadastrado</h3>
            <p className="text-gray-600 text-center mb-4">
              Comece criando seus primeiros serviços de facilities
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {services.map((service: any) => (
            <Card key={service.id} className="hover:shadow-lg transition-shadow">
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="p-2 rounded-lg bg-blue-50">
                      {getCategoryIcon(service.category)}
                    </div>
                    <div>
                      <CardTitle className="text-lg">{service.name}</CardTitle>
                    </div>
                  </div>
                  <div className="flex space-x-1">
                    <Button 
                      variant="ghost" 
                      size="sm"
                      data-testid={`button-edit-service-${service.id}`}
                      onClick={() => handleEdit(service)}
                    >
                      <Edit className="w-4 h-4" />
                    </Button>
                    <Button 
                      variant="ghost" 
                      size="sm"
                      data-testid={`button-delete-service-${service.id}`}
                      onClick={() => handleDelete(service.id)}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                {service.description && (
                  <p className="text-sm text-gray-600">{service.description}</p>
                )}
                
                <div className="flex flex-wrap gap-2">
                  {/* Bolinha do Tipo com texto */}
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 bg-purple-500 rounded-full flex items-center justify-center text-white text-xs font-bold">
                      T
                    </div>
                    <Badge className="bg-purple-100 text-purple-800">
                      {serviceTypes.find(t => t.id === service.typeId)?.name || 'Tipo'}
                    </Badge>
                  </div>
                  
                  {/* Bolinha da Categoria com texto */}
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 bg-slate-500 rounded-full flex items-center justify-center text-white text-xs font-bold">
                      C
                    </div>
                    <Badge variant="outline">
                      {serviceCategories.find(c => c.id === service.categoryId)?.name || 'Categoria'}
                    </Badge>
                  </div>
                  
                  <Badge className={getPriorityColor(service.priority)}>
                    {priorityLabels[service.priority as keyof typeof priorityLabels]}
                  </Badge>
                </div>

                {service.estimatedDurationMinutes && (
                  <div className="flex items-center text-sm text-gray-600">
                    <Clock className="w-4 h-4 mr-2" />
                    {service.estimatedDurationMinutes} min
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}