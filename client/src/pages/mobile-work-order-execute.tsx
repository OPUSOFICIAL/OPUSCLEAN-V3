import { useState, useEffect } from "react";
import { useRoute, useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { ArrowLeft, CheckCircle, MapPin, Building2, AlertCircle, Camera, X, PauseCircle } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

export default function MobileWorkOrderExecute() {
  const [, params] = useRoute("/mobile/work-order/:id");
  const [, setLocation] = useLocation();
  const { toast } = useToast();
  
  const [workOrder, setWorkOrder] = useState<any>(null);
  const [checklist, setChecklist] = useState<any>(null);
  const [answers, setAnswers] = useState<Record<string, any>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isPauseModalOpen, setIsPauseModalOpen] = useState(false);
  const [pauseReason, setPauseReason] = useState("");
  const [pausePhoto, setPausePhoto] = useState<any>(null);
  const [isPausing, setIsPausing] = useState(false);
  const [currentUser, setCurrentUser] = useState<any>(null);

  useEffect(() => {
    // Carregar usuário do localStorage
    const authStr = localStorage.getItem('opus_clean_auth');
    if (authStr) {
      const authData = JSON.parse(authStr);
      setCurrentUser(authData.user);
    }
    
    if (params?.id) {
      loadWorkOrder(params.id);
    }
  }, [params?.id]);

  const loadWorkOrder = async (id: string) => {
    setIsLoading(true);
    try {
      // Buscar work order
      console.log('[MOBILE] Loading work order:', id);
      const woResponse = await fetch(`/api/work-orders/${id}`);
      console.log('[MOBILE] Work order response status:', woResponse.status);
      if (!woResponse.ok) throw new Error('Work order não encontrada');
      const woData = await woResponse.json();
      console.log('[MOBILE] Work order data COMPLETA:', JSON.stringify(woData, null, 2));
      console.log('[MOBILE] workOrder.number:', woData.number);
      console.log('[MOBILE] workOrder.site:', woData.site);
      console.log('[MOBILE] workOrder.zone:', woData.zone);
      
      // Se a OS está aberta ou pausada, iniciar execução
      if (woData.status === 'aberta' || woData.status === 'pausada') {
        try {
          const authStr = localStorage.getItem('opus_clean_auth');
          if (authStr) {
            const authData = JSON.parse(authStr);
            const user = authData.user;
            
            if (user?.id) {
              // Mudar status para em_execucao e registrar início
              const updateResponse = await fetch(`/api/work-orders/${id}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                  assignedUserId: user.id,
                  status: 'em_execucao',
                  startedAt: woData.status === 'aberta' ? new Date().toISOString() : woData.startedAt,
                }),
              });
              
              if (updateResponse.ok) {
                const updatedWo = await updateResponse.json();
                woData.assignedUserId = updatedWo.assignedUserId;
                woData.status = updatedWo.status;
                woData.startedAt = updatedWo.startedAt;
                
                // Buscar comentários anteriores para determinar se é "iniciou" ou "retomou"
                let actionText = 'iniciou'; // Padrão: primeira vez
                try {
                  const commentsResponse = await fetch(`/api/work-orders/${id}/comments`);
                  if (commentsResponse.ok) {
                    const existingComments = await commentsResponse.json();
                    // Verificar se já existe comentário de início/retomada anterior
                    const hasStartedBefore = existingComments.some((c: any) => 
                      c.comment.includes('iniciou a execução') || 
                      c.comment.includes('retomou a execução')
                    );
                    // Se já foi iniciada antes, usar "retomou"
                    if (hasStartedBefore) {
                      actionText = 'retomou';
                    }
                  }
                } catch (err) {
                  console.error('Erro ao verificar histórico:', err);
                }
                
                // Criar comentário de início/retomada
                await fetch(`/api/work-orders/${id}/comments`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({
                    userId: user.id,
                    comment: `⏯️ ${user.name} ${actionText} a execução da OS`,
                  }),
                });
              }
            }
          }
        } catch (assignError) {
          console.error('Erro ao iniciar OS:', assignError);
        }
      }
      
      setWorkOrder(woData);

      // Buscar checklist - rota diferente para Clean vs Maintenance
      let checklistData = null;
      
      if (woData.module === 'maintenance' && woData.maintenanceChecklistTemplateId) {
        // Para manutenção: buscar do maintenance_checklist_templates
        const checklistResponse = await fetch(`/api/maintenance-checklist-templates/${woData.maintenanceChecklistTemplateId}`);
        if (checklistResponse.ok) {
          checklistData = await checklistResponse.json();
        }
      } else if (woData.module === 'clean' && woData.serviceId) {
        // Para clean: buscar do service_types
        const checklistResponse = await fetch(`/api/services/${woData.serviceId}/checklist`);
        if (checklistResponse.ok) {
          checklistData = await checklistResponse.json();
        }
      }
      
      if (checklistData) {
        setChecklist(checklistData);
        
        // Inicializar respostas
        const initialAnswers: Record<string, any> = {};
        if (checklistData?.items) {
          checklistData.items.forEach((item: any) => {
            if (item.type === 'boolean') {
              initialAnswers[item.id] = undefined;
            } else if (item.type === 'photo') {
              initialAnswers[item.id] = [];
            } else if (item.type === 'checkbox') {
              initialAnswers[item.id] = [];
            } else {
              initialAnswers[item.id] = '';
            }
          });
        }
        setAnswers(initialAnswers);
      }
    } catch (error) {
      console.error('Erro ao carregar work order:', error);
      toast({
        title: "Erro",
        description: "Não foi possível carregar a ordem de serviço.",
        variant: "destructive",
      });
      setLocation('/mobile');
    } finally {
      setIsLoading(false);
    }
  };

  const handlePhotoUpload = (itemId: string, files: FileList | null) => {
    if (!files || files.length === 0) return;
    
    const currentPhotos = answers[itemId] || [];
    const newPhotos = Array.from(files).map(file => ({
      file,
      preview: URL.createObjectURL(file),
      name: file.name
    }));
    
    setAnswers(prev => ({
      ...prev,
      [itemId]: [...currentPhotos, ...newPhotos]
    }));
  };

  const removePhoto = (itemId: string, index: number) => {
    const currentPhotos = answers[itemId] || [];
    const updatedPhotos = currentPhotos.filter((_: any, i: number) => i !== index);
    
    // Liberar URL do preview
    if (currentPhotos[index]?.preview) {
      URL.revokeObjectURL(currentPhotos[index].preview);
    }
    
    setAnswers(prev => ({
      ...prev,
      [itemId]: updatedPhotos
    }));
  };

  const validateChecklist = () => {
    if (!checklist?.items) return true;
    
    for (const item of checklist.items) {
      if (item.required) {
        const answer = answers[item.id];
        
        if (item.type === 'boolean' && answer === undefined) {
          return false;
        }
        if (item.type === 'text' && (!answer || answer.trim() === '')) {
          return false;
        }
        if (item.type === 'photo') {
          const photos = answer || [];
          const minCount = item.validation?.photoMinCount || 0;
          if (photos.length < minCount) {
            return false;
          }
        }
      }
    }
    return true;
  };

  const convertPhotosToBase64 = async (photos: any[]): Promise<string[]> => {
    const promises = photos.map((photo) => {
      return new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.onerror = reject;
        reader.readAsDataURL(photo.file);
      });
    });
    return Promise.all(promises);
  };

  const handlePausePhotoUpload = (files: FileList | null) => {
    if (!files || files.length === 0) return;
    
    const file = files[0];
    setPausePhoto({
      file,
      preview: URL.createObjectURL(file),
      name: file.name
    });
  };

  const handlePause = async () => {
    if (!pauseReason.trim()) {
      toast({
        title: "Motivo obrigatório",
        description: "Por favor, informe o motivo da pausa.",
        variant: "destructive",
      });
      return;
    }

    setIsPausing(true);
    try {
      // Converter foto para base64 se houver
      let photoBase64 = null;
      if (pausePhoto) {
        photoBase64 = await new Promise<string>((resolve, reject) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result as string);
          reader.onerror = reject;
          reader.readAsDataURL(pausePhoto.file);
        });
      }

      // Atualizar status da OS para pausada
      const response = await fetch(`/api/work-orders/${workOrder.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          status: 'pausada',
        }),
      });

      if (!response.ok) {
        throw new Error('Erro ao pausar ordem de serviço');
      }

      // Criar comentário com motivo e foto
      await fetch(`/api/work-orders/${workOrder.id}/comments`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: currentUser?.id,
          comment: `⏸️ ${currentUser?.name || 'Operador'} pausou a OS\n\n📝 Motivo: ${pauseReason}`,
          attachments: photoBase64 ? [photoBase64] : null,
        }),
      });

      toast({
        title: "✅ OS Pausada",
        description: "A ordem de serviço foi pausada com sucesso.",
      });

      // Voltar para o scanner
      setTimeout(() => {
        setLocation('/mobile/qr-scanner');
      }, 1500);
    } catch (error) {
      console.error('Erro ao pausar OS:', error);
      toast({
        title: "Erro",
        description: "Não foi possível pausar a ordem de serviço.",
        variant: "destructive",
      });
    } finally {
      setIsPausing(false);
      setIsPauseModalOpen(false);
      setPauseReason("");
      setPausePhoto(null);
    }
  };

  const handleFinish = async () => {
    if (!validateChecklist()) {
      toast({
        title: "Checklist incompleto",
        description: "Preencha todos os itens obrigatórios antes de finalizar.",
        variant: "destructive",
      });
      return;
    }

    setIsSubmitting(true);
    try {
      // Converter fotos para base64 para salvar
      const checklistAnswers: Record<string, any> = {};
      
      if (checklist?.items) {
        for (const item of checklist.items) {
          if (item.type === 'photo' && answers[item.id]?.length > 0) {
            // Converter fotos para base64
            const base64Photos = await convertPhotosToBase64(answers[item.id]);
            checklistAnswers[item.id] = {
              type: 'photo',
              photos: base64Photos,
              count: base64Photos.length
            };
          } else {
            // Outros tipos de resposta
            checklistAnswers[item.id] = answers[item.id];
          }
        }
      }

      // Atualizar work order para concluída
      console.log('[FINISH] Enviando PATCH para finalizar OS:', workOrder.id);
      console.log('[FINISH] Dados do checklist:', checklistAnswers);
      
      const response = await fetch(`/api/work-orders/${workOrder.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          status: 'concluida',
          completedAt: new Date().toISOString(),
          checklistData: checklist ? checklistAnswers : null,
        }),
      });

      console.log('[FINISH] Response status:', response.status);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('[FINISH] Erro na resposta:', errorText);
        throw new Error(`Erro ao finalizar: ${response.status} - ${errorText}`);
      }

      // Criar comentário automático com resumo da finalização e fotos
      try {
        // Coletar todas as fotos do checklist
        const allPhotos: string[] = [];
        let checklistSummary = '✅ OS Finalizada!\n\n📋 Checklist:\n';
        
        if (checklist?.items) {
          for (const item of checklist.items) {
            if (item.type === 'photo' && checklistAnswers[item.id]?.photos) {
              allPhotos.push(...checklistAnswers[item.id].photos);
              checklistSummary += `• ${item.title}: ${checklistAnswers[item.id].count} foto(s) anexada(s)\n`;
            } else if (item.type === 'checkbox') {
              const checked = checklistAnswers[item.id] ? '✓' : '✗';
              checklistSummary += `${checked} ${item.title}\n`;
            } else if (item.type === 'text' && checklistAnswers[item.id]) {
              checklistSummary += `• ${item.title}: ${checklistAnswers[item.id]}\n`;
            }
          }
        }

        // Criar comentário com o resumo e fotos
        await fetch(`/api/work-orders/${workOrder.id}/comments`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            userId: currentUser?.id,
            comment: checklistSummary,
            attachments: allPhotos,
          }),
        });
      } catch (commentError) {
        console.error('Erro ao criar comentário de finalização:', commentError);
        // Não bloquear a finalização se comentário falhar
      }

      toast({
        title: "✅ OS Finalizada!",
        description: `OS #${workOrder.number} foi concluída com sucesso. Fotos e dados salvos.`,
      });

      // Voltar para a página inicial do colaborador
      setTimeout(() => {
        setLocation('/mobile');
      }, 1500);
    } catch (error) {
      console.error('Erro ao finalizar work order:', error);
      console.error('Tipo do erro:', typeof error);
      console.error('Erro stringified:', JSON.stringify(error));
      console.error('Erro message:', error instanceof Error ? error.message : 'Sem mensagem');
      console.error('Erro stack:', error instanceof Error ? error.stack : 'Sem stack');
      
      toast({
        title: "Erro",
        description: error instanceof Error ? error.message : "Não foi possível finalizar a ordem de serviço.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-slate-600">Carregando ordem de serviço...</p>
        </div>
      </div>
    );
  }

  if (!workOrder) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
        <Card className="max-w-md mx-auto mt-8">
          <CardContent className="p-6 text-center">
            <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold mb-2">Ordem não encontrada</h3>
            <Button onClick={() => setLocation('/mobile')} className="mt-4">
              Voltar
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-4xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Button 
              variant="ghost" 
              onClick={() => setLocation('/mobile/qr-scanner')}
              className="p-2"
              data-testid="button-back"
            >
              <ArrowLeft className="w-6 h-6" />
            </Button>
            <div className="flex-1 text-center">
              <h1 className="text-xl font-bold text-slate-900">Executar OS</h1>
              <p className="text-sm text-slate-600">OS #{workOrder.number}</p>
            </div>
            <div className="w-10"></div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-4xl mx-auto p-4 space-y-4">
        {/* Informações da OS */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Detalhes da Ordem</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div>
              <p className="text-sm text-slate-600 mb-1">Título</p>
              <p className="font-semibold text-slate-900">{workOrder.title}</p>
            </div>
            
            {workOrder.description && (
              <div>
                <p className="text-sm text-slate-600 mb-1">Descrição</p>
                <p className="text-slate-700">{workOrder.description}</p>
              </div>
            )}

            <div className="flex flex-wrap gap-2">
              {workOrder.site?.name && (
                <Badge variant="outline" className="flex items-center gap-1">
                  <Building2 className="w-3 h-3" />
                  {workOrder.site.name}
                </Badge>
              )}
              {workOrder.zone?.name && (
                <Badge variant="outline" className="flex items-center gap-1">
                  <MapPin className="w-3 h-3" />
                  {workOrder.zone.name}
                </Badge>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Checklist */}
        {checklist && checklist.items && checklist.items.length > 0 ? (
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <CheckCircle className="w-5 h-5 text-blue-600" />
                Checklist de Execução
              </CardTitle>
              <p className="text-sm text-slate-600 mt-1">
                {checklist.description || 'Preencha todos os itens obrigatórios'}
              </p>
            </CardHeader>
            <CardContent className="space-y-4">
              {checklist.items.map((item: any, index: number) => (
                <div 
                  key={item.id} 
                  className="p-4 border rounded-lg bg-slate-50"
                  data-testid={`checklist-item-${index}`}
                >
                  <div className="flex items-start gap-3">
                    <div className="flex-shrink-0 w-6 h-6 rounded-full bg-blue-600 text-white flex items-center justify-center text-sm font-semibold">
                      {index + 1}
                    </div>
                    <div className="flex-1 space-y-2">
                      <div className="flex items-start justify-between gap-2">
                        <div className="flex-1">
                          <p className="font-medium text-slate-900">
                            {item.label}
                            {item.required && (
                              <span className="text-red-500 ml-1">*</span>
                            )}
                          </p>
                          {item.description && (
                            <p className="text-sm text-slate-600 mt-1">{item.description}</p>
                          )}
                        </div>
                      </div>

                      {item.type === 'boolean' ? (
                        <div className="flex gap-3 mt-2">
                          <Button
                            type="button"
                            variant={answers[item.id] === true ? "default" : "outline"}
                            className={`flex-1 ${
                              answers[item.id] === true 
                                ? 'bg-green-600 hover:bg-green-700' 
                                : 'border-slate-300'
                            }`}
                            onClick={() => setAnswers(prev => ({ ...prev, [item.id]: true }))}
                            data-testid={`button-yes-${item.id}`}
                          >
                            SIM
                          </Button>
                          <Button
                            type="button"
                            variant={answers[item.id] === false ? "default" : "outline"}
                            className={`flex-1 ${
                              answers[item.id] === false 
                                ? 'bg-red-600 hover:bg-red-700' 
                                : 'border-slate-300'
                            }`}
                            onClick={() => setAnswers(prev => ({ ...prev, [item.id]: false }))}
                            data-testid={`button-no-${item.id}`}
                          >
                            NÃO
                          </Button>
                        </div>
                      ) : item.type === 'photo' ? (
                        <div className="mt-2 space-y-3">
                          {/* Info sobre requisitos */}
                          <div className="text-xs text-slate-600 flex items-center gap-2">
                            <Camera className="w-4 h-4" />
                            <span>
                              {item.validation?.photoMinCount && item.validation?.photoMaxCount 
                                ? `Envie entre ${item.validation.photoMinCount} e ${item.validation.photoMaxCount} fotos`
                                : item.validation?.photoMinCount
                                ? `Envie no mínimo ${item.validation.photoMinCount} foto(s)`
                                : item.validation?.photoMaxCount
                                ? `Envie no máximo ${item.validation.photoMaxCount} foto(s)`
                                : 'Envie suas fotos'
                              }
                            </span>
                          </div>

                          {/* Preview das fotos */}
                          {answers[item.id] && answers[item.id].length > 0 && (
                            <div className="grid grid-cols-3 gap-2">
                              {answers[item.id].map((photo: any, photoIndex: number) => (
                                <div key={photoIndex} className="relative aspect-square">
                                  <img 
                                    src={photo.preview} 
                                    alt={`Foto ${photoIndex + 1}`}
                                    className="w-full h-full object-cover rounded-lg border-2 border-slate-200"
                                  />
                                  <Button
                                    type="button"
                                    variant="destructive"
                                    size="icon"
                                    className="absolute -top-2 -right-2 h-6 w-6 rounded-full"
                                    onClick={() => removePhoto(item.id, photoIndex)}
                                  >
                                    <X className="w-3 h-3" />
                                  </Button>
                                </div>
                              ))}
                            </div>
                          )}

                          {/* Botão de upload */}
                          {(!item.validation?.photoMaxCount || 
                            (answers[item.id]?.length || 0) < item.validation.photoMaxCount) && (
                            <label className="block">
                              <input
                                type="file"
                                accept="image/*"
                                multiple
                                capture="environment"
                                className="hidden"
                                onChange={(e) => handlePhotoUpload(item.id, e.target.files)}
                                data-testid={`photo-input-${item.id}`}
                              />
                              <div className="flex items-center justify-center gap-2 p-4 border-2 border-dashed border-blue-300 rounded-lg bg-blue-50 hover:bg-blue-100 cursor-pointer transition-colors">
                                <Camera className="w-5 h-5 text-blue-600" />
                                <span className="text-sm font-medium text-blue-600">
                                  {answers[item.id]?.length > 0 ? 'Adicionar mais fotos' : 'Tirar/Selecionar fotos'}
                                </span>
                              </div>
                            </label>
                          )}

                          {/* Contador */}
                          <p className="text-xs text-center text-slate-500">
                            {answers[item.id]?.length || 0} foto(s) adicionada(s)
                          </p>
                        </div>
                      ) : (
                        <Textarea
                          placeholder="Digite sua resposta..."
                          value={answers[item.id] || ''}
                          onChange={(e) => 
                            setAnswers(prev => ({ ...prev, [item.id]: e.target.value }))
                          }
                          className="mt-2"
                          rows={3}
                          data-testid={`textarea-${item.id}`}
                        />
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>
        ) : (
          <Card>
            <CardContent className="p-6 text-center text-slate-600">
              <CheckCircle className="w-12 h-12 text-slate-400 mx-auto mb-2" />
              <p>Esta ordem não possui checklist</p>
            </CardContent>
          </Card>
        )}

        {/* Botões de Ação */}
        <Card className="sticky bottom-4 shadow-lg">
          <CardContent className="p-4 space-y-3">
            <Button
              onClick={() => setIsPauseModalOpen(true)}
              disabled={isSubmitting || isPausing}
              variant="outline"
              className="w-full border-orange-500 text-orange-600 hover:bg-orange-50 py-6 text-lg font-semibold"
              data-testid="button-pause-wo"
            >
              <PauseCircle className="w-5 h-5 mr-2" />
              Pausar Ordem de Serviço
            </Button>
            
            <Button
              onClick={handleFinish}
              disabled={isSubmitting || isPausing}
              className="w-full bg-green-600 hover:bg-green-700 text-white py-6 text-lg font-semibold"
              data-testid="button-finish-wo"
            >
              {isSubmitting ? (
                <>
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                  Finalizando...
                </>
              ) : (
                <>
                  <CheckCircle className="w-5 h-5 mr-2" />
                  Finalizar Ordem de Serviço
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Modal de Pausa */}
        <Dialog open={isPauseModalOpen} onOpenChange={setIsPauseModalOpen}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle className="flex items-center gap-2">
                <PauseCircle className="w-5 h-5 text-orange-600" />
                Pausar Ordem de Serviço
              </DialogTitle>
              <DialogDescription>
                Informe o motivo da pausa. Você ou outro operador poderá retomar depois.
              </DialogDescription>
            </DialogHeader>
            
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="pause-reason">Motivo da Pausa *</Label>
                <Textarea
                  id="pause-reason"
                  placeholder="Ex: Falta de material, equipamento quebrado, intervalo..."
                  value={pauseReason}
                  onChange={(e) => setPauseReason(e.target.value)}
                  rows={4}
                  data-testid="textarea-pause-reason"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="pause-photo">Foto (opcional)</Label>
                {pausePhoto ? (
                  <div className="relative">
                    <img 
                      src={pausePhoto.preview} 
                      alt="Foto da pausa"
                      className="w-full h-48 object-cover rounded-lg border"
                    />
                    <Button
                      type="button"
                      variant="destructive"
                      size="icon"
                      className="absolute top-2 right-2"
                      onClick={() => {
                        URL.revokeObjectURL(pausePhoto.preview);
                        setPausePhoto(null);
                      }}
                    >
                      <X className="w-4 h-4" />
                    </Button>
                  </div>
                ) : (
                  <label className="block">
                    <input
                      type="file"
                      accept="image/*"
                      capture="environment"
                      className="hidden"
                      onChange={(e) => handlePausePhotoUpload(e.target.files)}
                      data-testid="input-pause-photo"
                    />
                    <div className="flex items-center justify-center gap-2 p-6 border-2 border-dashed border-slate-300 rounded-lg bg-slate-50 hover:bg-slate-100 cursor-pointer">
                      <Camera className="w-5 h-5 text-slate-600" />
                      <span className="text-sm text-slate-600">Tirar/Anexar Foto</span>
                    </div>
                  </label>
                )}
              </div>

              <div className="flex gap-2 pt-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => {
                    setIsPauseModalOpen(false);
                    setPauseReason("");
                    if (pausePhoto) {
                      URL.revokeObjectURL(pausePhoto.preview);
                      setPausePhoto(null);
                    }
                  }}
                  disabled={isPausing}
                  className="flex-1"
                  data-testid="button-cancel-pause"
                >
                  Cancelar
                </Button>
                <Button
                  onClick={handlePause}
                  disabled={isPausing || !pauseReason.trim()}
                  className="flex-1 bg-orange-600 hover:bg-orange-700"
                  data-testid="button-confirm-pause"
                >
                  {isPausing ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Pausando...
                    </>
                  ) : (
                    "Confirmar Pausa"
                  )}
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
