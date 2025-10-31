import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useState, useEffect } from "react";
import { useToast } from "@/hooks/use-toast";
import { X, Check, TriangleAlert, Clock, Camera, MapPin, User, AlertCircle, Calendar, Timer, Eye, Star } from "lucide-react";
import { Input } from "@/components/ui/input";
import { format } from "date-fns";
import { ptBR } from "date-fns/locale";

interface WorkOrderModalProps {
  workOrderId: string;
  onClose: () => void;
}

export default function WorkOrderModal({ workOrderId, onClose }: WorkOrderModalProps) {
  const [formData, setFormData] = useState({
    status: "",
    assignedUserId: "",
    priority: "",
    observations: "",
    scheduledDate: "",
    dueDate: ""
  });
  const [checklistItems, setChecklistItems] = useState<any[]>([]);
  const [photos, setPhotos] = useState<File[]>([]);
  const [photoPreviewUrls, setPhotoPreviewUrls] = useState<string[]>([]);
  const [newComment, setNewComment] = useState("");
  const [commentPhotos, setCommentPhotos] = useState<File[]>([]);
  const [commentPhotoPreviewUrls, setCommentPhotoPreviewUrls] = useState<string[]>([]);
  const [selectedRating, setSelectedRating] = useState<number | null>(null);
  const [ratingComment, setRatingComment] = useState("");
  
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Função para calcular tempo real de execução
  const calculateExecutionTime = () => {
    if (!(workOrder as any)?.startedAt) {
      return "Não iniciada";
    }

    const startedAt = new Date((workOrder as any).startedAt);
    const endTime = (workOrder as any)?.completedAt 
      ? new Date((workOrder as any).completedAt) 
      : new Date();

    // Calcular períodos de pausa a partir dos comentários
    let totalPauseTime = 0;
    if (comments && Array.isArray(comments)) {
      let lastPauseTime: Date | null = null;
      
      for (const comment of comments as any[]) {
        const commentText = comment.comment || "";
        
        // Detectar quando foi pausada
        if (commentText.includes("⏸️") && commentText.includes("pausou a OS")) {
          lastPauseTime = new Date(comment.createdAt);
        }
        
        // Detectar quando foi retomada
        if (commentText.includes("▶️") && commentText.includes("retomou a execução") && lastPauseTime) {
          const resumeTime = new Date(comment.createdAt);
          const pauseDuration = resumeTime.getTime() - lastPauseTime.getTime();
          totalPauseTime += pauseDuration;
          lastPauseTime = null;
        }
      }
      
      // Se ainda está pausada, calcular até agora
      if (lastPauseTime && (workOrder as any)?.status === 'pausada') {
        const pauseDuration = new Date().getTime() - lastPauseTime.getTime();
        totalPauseTime += pauseDuration;
      }
    }

    // Tempo total menos pausas
    const totalTime = endTime.getTime() - startedAt.getTime() - totalPauseTime;
    
    // Converter para horas e minutos
    const hours = Math.floor(totalTime / (1000 * 60 * 60));
    const minutes = Math.floor((totalTime % (1000 * 60 * 60)) / (1000 * 60));
    
    if (hours > 0) {
      return `${hours}h ${minutes}min`;
    } else {
      return `${minutes}min`;
    }
  };
  
  // Get current user
  const authStr = localStorage.getItem('opus_clean_auth');
  const currentUser = authStr ? JSON.parse(authStr).user : null;

  // Get work order details
  const { data: workOrder, isLoading } = useQuery({
    queryKey: ["/api/work-orders", workOrderId],
    enabled: !!workOrderId,
  });

  // Get company users for assignment
  const { data: users } = useQuery({
    queryKey: ["/api/companies", (workOrder as any)?.companyId, "users"],
    enabled: !!(workOrder as any)?.companyId,
  });

  // Get zones to find zone name
  const { data: zones } = useQuery({
    queryKey: ["/api/companies", (workOrder as any)?.companyId, "zones"],
    enabled: !!(workOrder as any)?.companyId,
  });

  // Get checklist template for this work order
  const { data: checklistTemplate } = useQuery({
    queryKey: ["/api/companies", (workOrder as any)?.companyId, "checklist-templates"],
    enabled: !!(workOrder as any)?.companyId,
  });

  // Get SLA config for work order type
  const { data: slaConfigs } = useQuery({
    queryKey: ["/api/companies", (workOrder as any)?.companyId, "sla-configs"],
    enabled: !!(workOrder as any)?.companyId,
  });

  // Get services and service categories
  const { data: services } = useQuery({
    queryKey: ["/api/companies", (workOrder as any)?.companyId, "services"],
    enabled: !!(workOrder as any)?.companyId,
  });

  // Get work order comments
  const { data: comments } = useQuery({
    queryKey: ["/api/work-orders", workOrderId, "comments"],
    enabled: !!workOrderId,
  });

  // Initialize form data when workOrder loads
  useEffect(() => {
    if (workOrder) {
      setFormData({
        status: (workOrder as any).status || "aberta",
        assignedUserId: (workOrder as any).assignedUserId || "unassigned",
        priority: (workOrder as any).priority || "media",
        observations: (workOrder as any).observations || "",
        scheduledDate: (workOrder as any).scheduledDate ? new Date((workOrder as any).scheduledDate).toISOString().split('T')[0] : "",
        dueDate: (workOrder as any).dueDate ? new Date((workOrder as any).dueDate).toISOString().split('T')[0] : ""
      });

      // Initialize checklist items from the work order or template
      const items = (workOrder as any).checklistData || 
                   (checklistTemplate as any[])?.[0]?.items || 
                   [];
      
      // Ensure items is always an array
      const itemsArray = Array.isArray(items) ? items : [];
      
      setChecklistItems(itemsArray.map((item: any, index: number) => ({
        ...item,
        id: item.id || `item-${index}`,
        completed: (workOrder as any).checklistProgress?.[item.id] || false
      })));
    }
  }, [workOrder, checklistTemplate]);

  const updateWorkOrderMutation = useMutation({
    mutationFn: async (data: any) => {
      const updateData = {
        ...data,
        assignedUserId: data.assignedUserId === "unassigned" ? null : data.assignedUserId,
        checklistProgress: checklistItems.reduce((acc, item) => {
          acc[item.id] = item.completed;
          return acc;
        }, {} as Record<string, boolean>),
        scheduledDate: data.scheduledDate ? new Date(data.scheduledDate).toISOString() : null,
        dueDate: data.dueDate ? new Date(data.dueDate).toISOString() : null,
        estimatedHours: data.estimatedHours ? parseFloat(data.estimatedHours) : null
      };
      
      // Remove empty strings to avoid database constraints
      Object.keys(updateData).forEach(key => {
        if (updateData[key] === "") {
          updateData[key] = null;
        }
      });
      
      return await apiRequest("PUT", `/api/work-orders/${workOrderId}`, updateData);
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço atualizada com sucesso!" });
      queryClient.invalidateQueries({ queryKey: ["/api/work-orders"] });
      onClose();
    },
    onError: () => {
      toast({ 
        title: "Erro ao atualizar ordem de serviço", 
        variant: "destructive" 
      });
    },
  });

  const addCommentMutation = useMutation({
    mutationFn: async (commentData: any) => {
      return await apiRequest("POST", `/api/work-orders/${workOrderId}/comments`, commentData);
    },
    onSuccess: () => {
      toast({ title: "Comentário adicionado!" });
      queryClient.invalidateQueries({ queryKey: ["/api/work-orders", workOrderId, "comments"] });
      setNewComment("");
      setCommentPhotos([]);
      setCommentPhotoPreviewUrls([]);
    },
    onError: () => {
      toast({ 
        title: "Erro ao adicionar comentário", 
        variant: "destructive" 
      });
    },
  });

  const submitRatingMutation = useMutation({
    mutationFn: async (ratingData: { rating: number; comment: string; userId: string }) => {
      return await apiRequest("POST", `/api/work-orders/${workOrderId}/rating`, ratingData);
    },
    onSuccess: () => {
      toast({ 
        title: "Avaliação enviada com sucesso!",
        description: "Obrigado pelo seu feedback.",
      });
      queryClient.invalidateQueries({ queryKey: ["/api/work-orders", workOrderId] });
      setSelectedRating(null);
      setRatingComment("");
    },
    onError: () => {
      toast({ 
        title: "Erro ao enviar avaliação", 
        variant: "destructive" 
      });
    },
  });

  const handleSave = () => {
    updateWorkOrderMutation.mutate(formData);
  };

  const handleSubmitRating = () => {
    if (!selectedRating || !currentUser) return;
    
    submitRatingMutation.mutate({
      rating: selectedRating,
      comment: ratingComment,
      userId: currentUser.id,
    });
  };

  const handleAddComment = async () => {
    if (!newComment.trim() && commentPhotos.length === 0) return;
    
    // Convert photos to base64 for storage
    const attachments = await Promise.all(
      commentPhotos.map(file => {
        return new Promise((resolve) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve({ url: reader.result, type: file.type, name: file.name });
          reader.readAsDataURL(file);
        });
      })
    );

    addCommentMutation.mutate({
      userId: "admin-user-default", // TODO: Get from session
      comment: newComment || "Anexo(s) adicionado(s)",
      attachments: attachments.length > 0 ? attachments : undefined,
    });
  };

  const handleCommentPhotoSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    
    const validFiles = files.filter(file => {
      if (file.size > 5 * 1024 * 1024) {
        toast({
          title: `Arquivo ${file.name} é muito grande`,
          description: "O tamanho máximo é 5MB",
          variant: "destructive"
        });
        return false;
      }
      return true;
    });

    setCommentPhotos(prev => [...prev, ...validFiles]);

    validFiles.forEach(file => {
      const reader = new FileReader();
      reader.onloadend = () => {
        setCommentPhotoPreviewUrls(prev => [...prev, reader.result as string]);
      };
      reader.readAsDataURL(file);
    });

    e.target.value = '';
  };

  const handleRemoveCommentPhoto = (index: number) => {
    setCommentPhotos(prev => prev.filter((_, i) => i !== index));
    setCommentPhotoPreviewUrls(prev => prev.filter((_, i) => i !== index));
  };

  const handleChecklistChange = (itemId: string, completed: boolean) => {
    setChecklistItems(prev => 
      prev.map(item => 
        item.id === itemId ? { ...item, completed } : item
      )
    );
  };

  const handlePhotoSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    
    // Validate file size (max 5MB per file)
    const validFiles = files.filter(file => {
      if (file.size > 5 * 1024 * 1024) {
        toast({
          title: `Arquivo ${file.name} é muito grande`,
          description: "O tamanho máximo é 5MB",
          variant: "destructive"
        });
        return false;
      }
      return true;
    });

    // Add to photos array
    setPhotos(prev => [...prev, ...validFiles]);

    // Create preview URLs
    validFiles.forEach(file => {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPhotoPreviewUrls(prev => [...prev, reader.result as string]);
      };
      reader.readAsDataURL(file);
    });

    // Reset input
    e.target.value = '';
  };

  const handleRemovePhoto = (index: number) => {
    setPhotos(prev => prev.filter((_, i) => i !== index));
    setPhotoPreviewUrls(prev => prev.filter((_, i) => i !== index));
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "vencida":
        return <Badge variant="destructive">Vencida</Badge>;
      case "concluida":
        return <Badge className="bg-green-100 text-green-800">Concluída</Badge>;
      default:
        return <Badge variant="outline">Aberta</Badge>;
    }
  };

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case "critica":
        return <Badge variant="destructive">Crítica</Badge>;
      case "alta":
        return <Badge className="bg-orange-100 text-orange-800">Alta</Badge>;
      case "media":
        return <Badge className="bg-yellow-100 text-yellow-800">Média</Badge>;
      default:
        return <Badge variant="outline">Baixa</Badge>;
    }
  };

  const getZoneName = () => {
    const zone = (zones as any[] || []).find((z: any) => z.id === (workOrder as any)?.zoneId);
    return zone?.name || 'Local não encontrado';
  };

  if (isLoading) {
    return (
      <Dialog open={true} onOpenChange={onClose}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <div className="flex items-center justify-center p-8">
            <div className="text-center space-y-2">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="text-sm text-muted-foreground">Carregando ordem de serviço...</p>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    );
  }

  return (
    <Dialog open={true} onOpenChange={onClose}>
      <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto" data-testid="work-order-modal">
        <DialogHeader>
          <div>
            <DialogTitle className="text-2xl font-bold text-foreground">
              OS #{(workOrder as any)?.number || workOrderId.slice(0, 8)}
            </DialogTitle>
            <DialogDescription className="text-base">
              {(workOrder as any)?.title || "Ordem de Serviço"}
            </DialogDescription>
            <div className="flex items-center gap-4 mt-2">
              <div className="flex items-center gap-1 text-sm text-muted-foreground">
                <MapPin className="w-4 h-4" />
                {getZoneName()}
              </div>
              <div className="flex items-center gap-1 text-sm text-muted-foreground">
                <Clock className="w-4 h-4" />
                Criada em {(workOrder as any)?.createdAt ? new Date((workOrder as any).createdAt).toLocaleDateString('pt-BR') : "--"}
              </div>
            </div>
          </div>
        </DialogHeader>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Work Order Details */}
          <div className="space-y-6">
            <div className="flex items-center gap-4">
              <div className="space-y-1">
                <span className="text-sm font-medium">Status</span>
                <div>{getStatusBadge((workOrder as any)?.status)}</div>
              </div>
              <div className="space-y-1">
                <span className="text-sm font-medium">Prioridade</span>
                <div>{getPriorityBadge((workOrder as any)?.priority)}</div>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">Alterar Status</label>
                <Select value={formData.status} onValueChange={(value) => setFormData(prev => ({...prev, status: value}))}>
                  <SelectTrigger data-testid="select-status">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="aberta">Aberta</SelectItem>
                    <SelectItem value="concluida">Concluída</SelectItem>
                    <SelectItem value="vencida">Vencida</SelectItem>
                    <SelectItem value="cancelada">Cancelada</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">Responsável</label>
                <Select value={formData.assignedUserId} onValueChange={(value) => setFormData(prev => ({...prev, assignedUserId: value}))}>
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
              
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">Prioridade</label>
                <Select value={formData.priority} onValueChange={(value) => setFormData(prev => ({...prev, priority: value}))}>
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
              
              {/* Date Configuration Section */}
              <div className="space-y-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
                <h4 className="font-semibold text-blue-900 flex items-center gap-2">
                  <Calendar className="w-4 h-4" />
                  Configurações de Data
                </h4>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Data Agendada</label>
                    <Input 
                      type="date"
                      value={formData.scheduledDate}
                      onChange={(e) => setFormData(prev => ({...prev, scheduledDate: e.target.value}))}
                      data-testid="input-scheduled-date"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">Data Limite</label>
                    <Input 
                      type="date"
                      value={formData.dueDate}
                      onChange={(e) => setFormData(prev => ({...prev, dueDate: e.target.value}))}
                      data-testid="input-due-date"
                    />
                  </div>
                  
                  {/* Datas de Execução - Apenas visualização */}
                  {((workOrder as any)?.startedAt || (workOrder as any)?.completedAt) && (
                    <div className="col-span-2 p-3 bg-gray-50 rounded-lg border">
                      <h5 className="font-medium text-gray-700 flex items-center gap-2 mb-3">
                        <Eye className="w-4 h-4" />
                        Status de Execução (Operador App)
                      </h5>
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <span className="text-gray-600">Iniciado em:</span>
                          <p className="font-medium">
                            {(workOrder as any)?.startedAt 
                              ? format(new Date((workOrder as any).startedAt), "dd/MM/yyyy HH:mm", { locale: ptBR })
                              : "Não iniciado"
                            }
                          </p>
                        </div>
                        <div>
                          <span className="text-gray-600">Concluído em:</span>
                          <p className="font-medium">
                            {(workOrder as any)?.completedAt 
                              ? format(new Date((workOrder as any).completedAt), "dd/MM/yyyy HH:mm", { locale: ptBR })
                              : "Não concluído"
                            }
                          </p>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-2 flex items-center gap-2">
                    <Timer className="w-4 h-4" />
                    Tempo Real de Execução
                  </label>
                  <div className="px-3 py-2 bg-slate-50 border border-slate-200 rounded-md text-sm font-medium text-slate-900">
                    {calculateExecutionTime()}
                  </div>
                  <p className="text-xs text-slate-500 mt-1">
                    Tempo que a OS ficou em execução (pausas descontadas)
                  </p>
                </div>
              </div>

              {/* SLA and Service Information */}
              <div className="space-y-4 p-4 bg-green-50 rounded-lg border border-green-200">
                <h4 className="font-semibold text-green-900 flex items-center gap-2">
                  <AlertCircle className="w-4 h-4" />
                  Informações de SLA e Serviços
                </h4>
                
                {Array.isArray(slaConfigs) && slaConfigs.length > 0 && (
                  <div>
                    <span className="text-sm font-medium">SLA Configurado:</span>
                    <div className="mt-1 text-sm text-green-800">
                      {slaConfigs.map((sla: any) => (
                        <div key={sla.id} className="bg-white p-2 rounded border">
                          <div>{sla.serviceType} - {sla.priority}</div>
                          <div className="text-xs">Tempo limite: {sla.responseTimeHours}h</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
                
                {Array.isArray(services) && services.length > 0 && (
                  <div>
                    <span className="text-sm font-medium">Serviços Relacionados:</span>
                    <div className="mt-1 text-sm">
                      {services.filter((service: any) => 
                        service.zoneId === (workOrder as any)?.zoneId
                      ).map((service: any) => (
                        <div key={service.id} className="bg-white p-2 rounded border mb-1">
                          <div className="font-medium">{service.name}</div>
                          <div className="text-xs text-gray-600">{service.description}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
              
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">Observações</label>
                <Textarea 
                  className="h-32" 
                  placeholder="Adicione observações sobre esta OS..."
                  value={formData.observations}
                  onChange={(e) => setFormData(prev => ({...prev, observations: e.target.value}))}
                  data-testid="textarea-observations"
                />
              </div>
            </div>
          </div>
          
          {/* Dynamic Checklist */}
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-foreground">Checklist</h3>
              <span className="text-sm text-muted-foreground">
                {checklistItems.filter(item => item.completed).length} de {checklistItems.length} completos
              </span>
            </div>
            
            {checklistItems.length > 0 ? (
              <div className="space-y-3">
                {checklistItems.map((item, index) => (
                  <div key={item.id} className={`flex items-center space-x-3 p-4 border rounded-lg transition-colors ${
                    item.completed ? 'bg-green-50 border-green-200' : 'border-gray-200 hover:border-gray-300'
                  }`}>
                    <Checkbox 
                      checked={item.completed}
                      onCheckedChange={(checked) => handleChecklistChange(item.id, !!checked)}
                      data-testid={`checkbox-${index}`}
                    />
                    <div className="flex-1">
                      <span className={`text-sm ${item.completed ? 'line-through text-muted-foreground' : 'text-foreground'}`}>
                        {item.label || item.name}
                      </span>
                      {item.description && (
                        <p className="text-xs text-muted-foreground mt-1">{item.description}</p>
                      )}
                    </div>
                    {item.completed ? (
                      <Check className="w-5 h-5 text-green-600" />
                    ) : item.required ? (
                      <AlertCircle className="w-5 h-5 text-orange-500" />
                    ) : (
                      <Clock className="w-5 h-5 text-muted-foreground" />
                    )}
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-8 text-muted-foreground">
                <AlertCircle className="w-8 h-8 mx-auto mb-2" />
                <p>Nenhum checklist disponível para esta OS</p>
                <p className="text-sm">Configure um template de checklist no sistema</p>
              </div>
            )}
            
            {/* Dados da Finalização (se OS está concluída e tem checklistData) */}
            {(workOrder as any)?.status === 'concluida' && (workOrder as any)?.checklistData && (
              <div className="mt-6 space-y-4 border-t pt-4">
                <h3 className="text-lg font-semibold text-green-700 flex items-center gap-2">
                  <Check className="w-5 h-5" />
                  Dados da Finalização
                </h3>
                
                <div className="bg-green-50 border border-green-200 rounded-lg p-4 space-y-3">
                  {Object.entries((workOrder as any).checklistData).map(([itemId, answer]: [string, any]) => {
                    // Encontrar o item do template para pegar o título
                    const templateItem = (checklistTemplate as any[])?.[0]?.items?.find((t: any) => t.id === itemId);
                    const itemTitle = templateItem?.title || templateItem?.label || itemId;
                    
                    return (
                      <div key={itemId} className="space-y-2">
                        <p className="font-medium text-sm text-gray-700">{itemTitle}</p>
                        
                        {/* Se for foto */}
                        {answer?.type === 'photo' && answer?.photos && (
                          <div className="flex gap-2 flex-wrap">
                            {answer.photos.map((photo: string, idx: number) => (
                              <img 
                                key={idx}
                                src={photo} 
                                alt={`${itemTitle} - Foto ${idx + 1}`}
                                className="w-24 h-24 object-cover rounded border border-green-300"
                              />
                            ))}
                            <span className="text-xs text-green-700 self-center">
                              {answer.count} foto(s)
                            </span>
                          </div>
                        )}
                        
                        {/* Se for checkbox */}
                        {typeof answer === 'boolean' && (
                          <span className={`text-sm ${answer ? 'text-green-700' : 'text-gray-500'}`}>
                            {answer ? '✓ Sim' : '✗ Não'}
                          </span>
                        )}
                        
                        {/* Se for texto */}
                        {typeof answer === 'string' && (
                          <p className="text-sm text-gray-600 bg-white p-2 rounded border border-green-200">
                            {answer}
                          </p>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Comments Section */}
            <div className="mt-6 space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">Comentários</h3>
                <Badge variant="outline">{(comments as any[])?.length || 0}</Badge>
              </div>
              
              {/* Comments List */}
              <div className="space-y-3 max-h-64 overflow-y-auto">
                {(comments as any[])  && (comments as any[]).length > 0 ? (
                  (comments as any[]).map((comment: any) => (
                    <div key={comment.id} className="border rounded-lg p-4 space-y-2">
                      <div className="flex items-start justify-between">
                        <div className="flex items-center space-x-2">
                          <User className="w-4 h-4 text-muted-foreground" />
                          <span className="text-sm font-medium">
                            {(users as any[] || []).find((u: any) => u.id === comment.userId)?.name || 'Usuário'}
                          </span>
                          {comment.isReopenRequest && (
                            <Badge variant="destructive" className="text-xs">Reabertura</Badge>
                          )}
                        </div>
                        <span className="text-xs text-muted-foreground">
                          {format(new Date(comment.createdAt), "dd/MM/yyyy HH:mm", { locale: ptBR })}
                        </span>
                      </div>
                      <p className="text-sm text-gray-700">{comment.comment}</p>
                      {comment.attachments && comment.attachments.length > 0 && (
                        <div className="flex gap-2 mt-2">
                          {comment.attachments.map((att: any, idx: number) => (
                            <img 
                              key={idx}
                              src={att.url || att} 
                              alt={`Anexo ${idx + 1}`}
                              className="w-20 h-20 object-cover rounded border"
                            />
                          ))}
                        </div>
                      )}
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-muted-foreground text-center py-4">
                    Nenhum comentário ainda
                  </p>
                )}
              </div>

              {/* Add Comment */}
              <div className="border-t pt-4 space-y-3">
                <Textarea
                  placeholder="Adicionar comentário..."
                  value={newComment}
                  onChange={(e) => setNewComment(e.target.value)}
                  className="min-h-[80px]"
                  data-testid="textarea-new-comment"
                />
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <input
                      type="file"
                      id="comment-photo-upload"
                      accept="image/jpeg,image/png,image/jpg"
                      multiple
                      className="hidden"
                      onChange={handleCommentPhotoSelect}
                    />
                    <label 
                      htmlFor="comment-photo-upload"
                      className="cursor-pointer"
                    >
                      <Button variant="outline" size="sm" type="button" asChild>
                        <span>
                          <Camera className="w-4 h-4 mr-2" />
                          Anexar Fotos
                        </span>
                      </Button>
                    </label>
                    {commentPhotos.length > 0 && (
                      <span className="text-sm text-muted-foreground">
                        {commentPhotos.length} foto(s) selecionada(s)
                      </span>
                    )}
                  </div>
                  <Button 
                    onClick={handleAddComment}
                    disabled={!newComment.trim() && commentPhotos.length === 0}
                    size="sm"
                    data-testid="button-add-comment"
                  >
                    Enviar Comentário
                  </Button>
                </div>

                {/* Comment Photo Previews */}
                {commentPhotoPreviewUrls.length > 0 && (
                  <div className="flex gap-2 flex-wrap">
                    {commentPhotoPreviewUrls.map((url, index) => (
                      <div key={index} className="relative group">
                        <img 
                          src={url} 
                          alt={`Preview ${index + 1}`}
                          className="w-16 h-16 object-cover rounded border"
                        />
                        <Button
                          type="button"
                          variant="destructive"
                          size="sm"
                          className="absolute -top-2 -right-2 opacity-0 group-hover:opacity-100 transition-opacity h-6 w-6 p-0"
                          onClick={() => handleRemoveCommentPhoto(index)}
                        >
                          <X className="w-3 h-3" />
                        </Button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Rating Section - Only for completed work orders and customer users */}
            {(workOrder as any)?.status === 'concluida' && 
             currentUser?.userType === 'customer_user' && 
             !(workOrder as any)?.customerRating && (
              <div className="mt-6 p-6 border-2 border-orange-300 rounded-lg bg-gradient-to-r from-orange-50 to-amber-50">
                <div className="flex items-center gap-2 mb-4">
                  <Star className="w-5 h-5 text-orange-600" />
                  <h3 className="text-lg font-semibold text-orange-900">Avalie este Serviço</h3>
                </div>
                <p className="text-sm text-gray-600 mb-4">
                  Como você avalia a qualidade do serviço realizado? (1 = Péssimo, 10 = Excelente)
                </p>
                
                {/* Rating Buttons */}
                <div className="grid grid-cols-5 sm:grid-cols-10 gap-2 mb-4">
                  {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((rating) => (
                    <Button
                      key={rating}
                      type="button"
                      variant={selectedRating === rating ? "default" : "outline"}
                      className={`h-12 font-bold text-lg ${
                        selectedRating === rating 
                          ? rating <= 4 
                            ? 'bg-red-600 hover:bg-red-700' 
                            : rating <= 7 
                            ? 'bg-yellow-600 hover:bg-yellow-700' 
                            : 'bg-green-600 hover:bg-green-700'
                          : 'hover:bg-gray-100'
                      }`}
                      onClick={() => setSelectedRating(rating)}
                      data-testid={`button-rating-${rating}`}
                    >
                      {rating}
                    </Button>
                  ))}
                </div>

                {/* Optional Comment */}
                <Textarea
                  placeholder="Comentário (opcional)"
                  value={ratingComment}
                  onChange={(e) => setRatingComment(e.target.value)}
                  className="mb-4"
                  rows={3}
                  data-testid="textarea-rating-comment"
                />

                <Button
                  onClick={handleSubmitRating}
                  disabled={!selectedRating || submitRatingMutation.isPending}
                  className="w-full bg-orange-600 hover:bg-orange-700 text-white font-semibold py-3"
                  data-testid="button-submit-rating"
                >
                  {submitRatingMutation.isPending ? "Enviando..." : "Enviar Avaliação"}
                </Button>
              </div>
            )}

            {/* Show existing rating if already rated */}
            {(workOrder as any)?.status === 'concluida' && 
             (workOrder as any)?.customerRating && (
              <div className="mt-6 p-6 border-2 border-green-300 rounded-lg bg-gradient-to-r from-green-50 to-emerald-50">
                <div className="flex items-center gap-2 mb-2">
                  <Star className="w-5 h-5 text-green-600 fill-green-600" />
                  <h3 className="text-lg font-semibold text-green-900">Avaliação Registrada</h3>
                </div>
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-3xl font-bold text-green-700">
                    {(workOrder as any).customerRating}/10
                  </span>
                  <span className="text-sm text-gray-600">
                    em {format(new Date((workOrder as any).ratedAt), "dd/MM/yyyy HH:mm", { locale: ptBR })}
                  </span>
                </div>
                {(workOrder as any).customerRatingComment && (
                  <p className="text-sm text-gray-700 mt-2 p-3 bg-white rounded border border-green-200">
                    "{(workOrder as any).customerRatingComment}"
                  </p>
                )}
              </div>
            )}
          </div>
          </div>
        
        <div className="flex items-center justify-end space-x-4 mt-8 pt-6 border-t">
          <Button variant="outline" onClick={onClose} data-testid="button-cancel">
            Cancelar
          </Button>
          <Button 
            onClick={handleSave}
            disabled={updateWorkOrderMutation.isPending}
            data-testid="button-save"
            className="bg-blue-600 hover:bg-blue-700"
          >
            {updateWorkOrderMutation.isPending ? "Salvando..." : "Salvar Alterações"}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}