import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useState, useEffect } from "react";
import { useToast } from "@/hooks/use-toast";
import { useParams, useLocation } from "wouter";
import { useModule } from "@/contexts/ModuleContext";
import { useNetwork } from "@/contexts/NetworkContext";
import { useOfflineStorage } from "@/hooks/use-offline-storage";
import { nanoid } from "nanoid";
import { 
  QrCode, 
  Camera, 
  CheckCircle, 
  AlertTriangle, 
  Clock, 
  Upload,
  ArrowLeft,
  User,
  MapPin,
  FileText,
  WifiOff
} from "lucide-react";

export default function QrExecution() {
  const { currentModule } = useModule();
  const { code } = useParams<{ code: string }>();
  const [, setLocation] = useLocation();
  const [observations, setObservations] = useState("");
  const [checklistItems, setChecklistItems] = useState<Record<string, any>>({});
  const [photos, setPhotos] = useState<File[]>([]);
  const [isCompleting, setIsCompleting] = useState(false);
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const { isOnline } = useNetwork();
  const { 
    createOfflineWorkOrder,
    createOfflineChecklistExecution,
    createOfflineAttachment 
  } = useOfflineStorage();

  // Get QR point data and check for scheduled activities
  const { data: qrData, isLoading, error } = useQuery({
    queryKey: ["/api/qr-execution", code],
    enabled: !!code,
  });

  // Get zone details
  const { data: zone } = useQuery({
    queryKey: ["/api/zones", (qrData as any)?.point?.zoneId, { module: currentModule }],
    enabled: !!(qrData as any)?.point?.zoneId,
  });

  // Mock current user - in real app this would come from auth context
  const currentUser = {
    id: "user-1",
    name: "Carlos Oliveira",
    role: "operador"
  };

  const createWorkOrderMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("POST", "/api/work-orders", data);
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço criada com sucesso" });
      queryClient.invalidateQueries({ queryKey: ["/api/work-orders"] });
    },
    onError: () => {
      toast({ 
        title: "Erro ao criar ordem de serviço", 
        variant: "destructive" 
      });
    },
  });

  const updateWorkOrderMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("PUT", `/api/work-orders/${data.id}`, data);
    },
    onSuccess: () => {
      toast({ title: "Ordem de serviço atualizada com sucesso" });
      queryClient.invalidateQueries({ queryKey: ["/api/work-orders"] });
      setLocation("/mobile");
    },
    onError: () => {
      toast({ 
        title: "Erro ao atualizar ordem de serviço", 
        variant: "destructive" 
      });
    },
  });

  const handleChecklistChange = (itemId: string, value: any) => {
    setChecklistItems(prev => ({
      ...prev,
      [itemId]: value
    }));
  };

  const handlePhotoUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files || []);
    setPhotos(prev => [...prev, ...files]);
  };

  const handleCreateCorrectiveOrder = async () => {
    if (!zone || !(qrData as any)?.point) return;

    const workOrderData = {
      companyId: (qrData as any)?.company?.id || 'company-opus-default',
      customerId: (qrData as any)?.customer?.id || (qrData as any)?.point?.customerId,
      zoneId: zone?.id,
      type: "internal_corrective" as const, // Canonical enum key
      priority: "media" as const,
      title: `Limpeza Corretiva - ${zone?.name || 'Local'}`,
      description: observations || "Solicitação via QR Code de execução",
      assignedUserId: currentUser.id,
      origin: "QR Execução",
      module: currentModule,
      status: "pendente" as const,
    };

    if (isOnline) {
      // Online: Use mutation normal
      createWorkOrderMutation.mutate(workOrderData);
    } else {
      // Offline: Save to IndexedDB
      // Validate required fields
      if (!workOrderData.customerId) {
        toast({
          title: "Erro de validação",
          description: "Cliente não identificado. Não é possível criar OS offline.",
          variant: "destructive",
        });
        return;
      }

      try {
        const localId = nanoid();
        await createOfflineWorkOrder({
          localId,
          ...workOrderData,
          syncStatus: 'pending',
          createdOffline: true,
          syncRetryCount: 0,
        });

        // Save photos as attachments if any
        if (photos.length > 0) {
          const photoPromises = photos.map(async (file, index) => {
            const base64 = await new Promise<string>((resolve) => {
              const reader = new FileReader();
              reader.onloadend = () => resolve(reader.result as string);
              reader.readAsDataURL(file);
            });

            await createOfflineAttachment({
              workOrderId: localId, // Use localId
              type: 'photo',
              url: base64,
              fileName: file.name || `photo_${Date.now()}_${index}.jpg`,
              mimeType: file.type || 'image/jpeg',
              uploadedBy: currentUser.id,
              syncStatus: 'pending',
              createdOffline: true,
              syncRetryCount: 0,
            });
          });

          await Promise.all(photoPromises);
        }

        toast({
          title: "📥 OS Salva Offline",
          description: "Será sincronizada automaticamente quando houver conexão",
        });

        // Clear form and redirect
        setObservations("");
        setPhotos([]);
        setTimeout(() => setLocation("/mobile"), 500);
      } catch (error) {
        console.error('[QR EXECUTION] Erro ao salvar OS offline:', error);
        toast({
          title: "Erro ao salvar offline",
          description: "Não foi possível salvar a OS localmente",
          variant: "destructive",
        });
      }
    }
  };

  const handleCompleteWorkOrder = async () => {
    if (!(qrData as any)?.scheduledWorkOrder) return;
    const workOrder = (qrData as any).scheduledWorkOrder;

    setIsCompleting(true);

    if (isOnline) {
      // Online: Use mutation normal
      updateWorkOrderMutation.mutate({
        id: workOrder.id,
        status: "concluida",
        completedAt: new Date().toISOString(),
        checklistData: checklistItems,
        attachments: photos.map(p => p.name)
      });
    } else {
      // Offline: Save checklist execution + attachments
      try {
        const completedAt = new Date().toISOString();

        // 1. Create checklist execution
        await createOfflineChecklistExecution({
          workOrderId: workOrder.id, // serverId
          checklistTemplateId: workOrder.checklistTemplateId || 'manual',
          executedBy: currentUser.id,
          status: 'completed',
          itemsData: checklistItems,
          executedAt: completedAt,
          syncStatus: 'pending',
          createdOffline: true,
          syncRetryCount: 0,
        });

        // 2. Save photos as attachments
        if (photos.length > 0) {
          const photoPromises = photos.map(async (file, index) => {
            const base64 = await new Promise<string>((resolve) => {
              const reader = new FileReader();
              reader.onloadend = () => resolve(reader.result as string);
              reader.readAsDataURL(file);
            });

            await createOfflineAttachment({
              workOrderId: workOrder.id, // serverId
              type: 'photo',
              url: base64,
              fileName: file.name || `qr_photo_${Date.now()}_${index}.jpg`,
              mimeType: file.type || 'image/jpeg',
              uploadedBy: currentUser.id,
              syncStatus: 'pending',
              createdOffline: true,
              syncRetryCount: 0,
            });
          });

          await Promise.all(photoPromises);
        }

        console.log('[QR EXECUTION] OS salva offline, aguardando sync para marcar como concluída');

        toast({
          title: "📥 OS Salva Offline",
          description: "Será sincronizada automaticamente quando houver conexão",
        });

        // Clear form and redirect
        setChecklistItems({});
        setPhotos([]);
        setIsCompleting(false);
        setTimeout(() => setLocation("/mobile"), 500);
      } catch (error) {
        console.error('[QR EXECUTION] Erro ao salvar execução offline:', error);
        toast({
          title: "Erro ao salvar offline",
          description: "Não foi possível salvar a execução localmente",
          variant: "destructive",
        });
        setIsCompleting(false);
      }
    }
  };

  useEffect(() => {
    // Store QR scan data for offline sync
    if (qrData) {
      localStorage.setItem(`qr-scan-${code}`, JSON.stringify({
        timestamp: new Date().toISOString(),
        userId: currentUser.id,
        qrData
      }));
      
      // Store current location context for work order filtering
      const locationContext = {
        zoneId: (qrData as any).point?.zoneId,
        zoneName: zone?.name || (qrData as any)?.point?.name,
        siteName: (qrData as any).site?.name,
        timestamp: new Date().toISOString()
      };
      localStorage.setItem('current-location', JSON.stringify(locationContext));
    }
  }, [qrData, code, currentUser.id, zone]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <QrCode className="w-12 h-12 text-muted-foreground mx-auto mb-4 animate-pulse" />
          <p className="text-muted-foreground">Carregando informações do QR Code...</p>
        </div>
      </div>
    );
  }

  if (error || !(qrData as any)?.point) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardContent className="pt-6 text-center">
            <AlertTriangle className="w-12 h-12 text-destructive mx-auto mb-4" />
            <h1 className="text-xl font-bold text-foreground mb-2">QR Code Inválido</h1>
            <p className="text-muted-foreground mb-4">
              Este QR Code não foi encontrado ou não é válido para execução.
            </p>
            <Button onClick={() => setLocation("/mobile")} data-testid="button-back-to-mobile">
              <ArrowLeft className="w-4 h-4 mr-2" />
              Voltar ao App
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Mobile Header */}
      <div className="bg-card border-b border-border p-4 sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <Button 
            variant="ghost" 
            size="sm"
            onClick={() => setLocation("/mobile")}
            data-testid="button-back"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Voltar
          </Button>
          <div className="text-center">
            <h1 className="text-lg font-bold text-foreground">QR Execução</h1>
            <p className="text-xs text-muted-foreground">#{code}</p>
          </div>
          <div className="w-16"></div>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* Location Info */}
        <Card>
          <CardContent className="p-4">
            <div className="flex items-start space-x-3">
              <MapPin className="w-5 h-5 text-primary mt-1" />
              <div className="flex-1">
                <h2 className="text-lg font-semibold text-foreground">{zone?.name || (qrData as any)?.point?.name}</h2>
                <p className="text-sm text-muted-foreground">{(qrData as any)?.point?.description}</p>
                {zone?.areaM2 && (
                  <p className="text-xs text-muted-foreground mt-1">Área: {zone?.areaM2}m²</p>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Operator Info */}
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-3">
              <User className="w-5 h-5 text-muted-foreground" />
              <div>
                <p className="text-sm font-medium text-foreground">{currentUser.name}</p>
                <p className="text-xs text-muted-foreground">Operador • {new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Scheduled Activity or Corrective Option */}
        {(qrData as any).hasScheduledActivity && (qrData as any).scheduledWorkOrder ? (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <CheckCircle className="w-5 h-5 text-chart-2" />
                <span>Atividade Programada</span>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="bg-chart-2/5 border border-chart-2/20 rounded-lg p-3">
                <h3 className="font-medium text-foreground mb-1">{(qrData as any).scheduledWorkOrder.title}</h3>
                <p className="text-sm text-muted-foreground">{(qrData as any).scheduledWorkOrder.description}</p>
                <div className="flex items-center space-x-4 mt-2 text-xs text-muted-foreground">
                  <span className="flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>SLA: {(qrData as any).scheduledWorkOrder.slaCompleteMinutes || 60} min</span>
                  </span>
                  <Badge className="bg-chart-4/10 text-chart-4">
                    {(qrData as any).scheduledWorkOrder.priority || 'Média'}
                  </Badge>
                </div>
              </div>

              {/* Checklist */}
              {(qrData as any).checklist && (
                <div className="space-y-3">
                  <h4 className="font-medium text-foreground">Checklist</h4>
                  {(qrData as any).checklist.map((item: any, index: number) => (
                    <div key={index} className="flex items-center space-x-3 p-3 border border-border rounded-lg">
                      <Checkbox 
                        checked={checklistItems[item.id] || false}
                        onCheckedChange={(checked) => handleChecklistChange(item.id, checked)}
                        data-testid={`checkbox-${item.id}`}
                      />
                      <span className="flex-1 text-sm text-foreground">{item.label}</span>
                      {item.required && (
                        <span className="text-xs text-destructive">*</span>
                      )}
                    </div>
                  ))}
                </div>
              )}

              {/* Photo Upload */}
              <div className="border-2 border-dashed border-border rounded-lg p-4">
                <input
                  type="file"
                  accept="image/*"
                  multiple
                  onChange={handlePhotoUpload}
                  className="hidden"
                  id="photo-upload"
                />
                <label htmlFor="photo-upload" className="cursor-pointer">
                  <div className="text-center">
                    <Camera className="w-8 h-8 text-muted-foreground mx-auto mb-2" />
                    <p className="text-sm text-muted-foreground">Anexar fotos</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      {photos.length > 0 ? `${photos.length} foto(s) selecionada(s)` : "Toque para adicionar fotos"}
                    </p>
                  </div>
                </label>
              </div>

              {/* Complete Button */}
              <Button 
                onClick={handleCompleteWorkOrder}
                disabled={updateWorkOrderMutation.isPending || isCompleting}
                className="w-full h-12"
                data-testid="button-complete-work-order"
              >
                {isCompleting ? (
                  "Concluindo..."
                ) : (
                  <>
                    <CheckCircle className="w-4 h-4 mr-2" />
                    Concluir Atividade
                  </>
                )}
              </Button>
            </CardContent>
          </Card>
        ) : (
          // No scheduled activity - offer corrective option
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <AlertTriangle className="w-5 h-5 text-chart-4" />
                <span>Nenhuma Atividade Programada</span>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm text-muted-foreground">
                Não há atividades programadas para este local no momento. 
                Você pode abrir uma ordem de serviço corretiva se necessário.
              </p>

              {/* Observations for corrective */}
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">
                  Motivo da Limpeza Corretiva
                </label>
                <Textarea
                  placeholder="Descreva o que foi observado que requer limpeza..."
                  value={observations}
                  onChange={(e) => setObservations(e.target.value)}
                  className="min-h-[120px] max-h-[200px] overflow-y-auto resize-none"
                  data-testid="textarea-corrective-reason"
                />
              </div>

              {/* Photo Upload for corrective */}
              <div className="border-2 border-dashed border-border rounded-lg p-4">
                <input
                  type="file"
                  accept="image/*"
                  multiple
                  onChange={handlePhotoUpload}
                  className="hidden"
                  id="corrective-photo-upload"
                />
                <label htmlFor="corrective-photo-upload" className="cursor-pointer">
                  <div className="text-center">
                    <Camera className="w-8 h-8 text-muted-foreground mx-auto mb-2" />
                    <p className="text-sm text-muted-foreground">Anexar fotos (opcional)</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      {photos.length > 0 ? `${photos.length} foto(s) selecionada(s)` : "Evidências da necessidade de limpeza"}
                    </p>
                  </div>
                </label>
              </div>

              {/* Create Corrective Button */}
              <Button 
                onClick={handleCreateCorrectiveOrder}
                disabled={!observations.trim() || createWorkOrderMutation.isPending}
                className="w-full h-12"
                variant="outline"
                data-testid="button-create-corrective"
              >
                {createWorkOrderMutation.isPending ? (
                  "Criando..."
                ) : (
                  <>
                    <FileText className="w-4 h-4 mr-2" />
                    Abrir OS Corretiva
                  </>
                )}
              </Button>
            </CardContent>
          </Card>
        )}

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-3">
          <Button 
            variant="outline"
            onClick={() => setLocation("/mobile")}
            data-testid="button-back-to-app"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Voltar ao App
          </Button>
          
          <Button 
            variant="outline"
            onClick={() => {
              // In real app, would open QR scanner
              toast({ title: "Scanner QR aberto" });
            }}
            data-testid="button-scan-another"
          >
            <QrCode className="w-4 h-4 mr-2" />
            Escanear Outro
          </Button>
        </div>
      </div>
    </div>
  );
}
