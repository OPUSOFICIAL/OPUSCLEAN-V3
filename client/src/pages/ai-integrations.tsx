import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { getAuthState } from "@/lib/auth";
import { ModernPageHeader } from "@/components/ui/modern-page-header";
import { ModernCard, ModernCardHeader, ModernCardContent } from "@/components/ui/modern-card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { queryClient, apiRequest } from "@/lib/queryClient";
import { 
  Bot, Plus, Edit, Trash2, TestTube, Loader2, 
  Check, X, Brain, Sparkles, Shield, Key,
  AlertCircle, CheckCircle2, XCircle, Clock, Cloud
} from "lucide-react";
import { SiOpenai, SiGoogle } from "react-icons/si";

type AiProvider = 'openai' | 'anthropic' | 'google' | 'azure_openai' | 'cohere' | 'huggingface' | 'custom';
type IntegrationStatus = 'ativa' | 'inativa' | 'erro';

interface AiIntegration {
  id: string;
  companyId: string;
  provider: AiProvider;
  name: string;
  apiKey: string;
  model?: string;
  endpoint?: string;
  status: IntegrationStatus;
  isDefault: boolean;
  lastTestedAt?: string;
  lastErrorMessage?: string;
  createdAt: string;
  updatedAt: string;
}

const providerOptions = [
  { value: 'openai', label: 'OpenAI', icon: SiOpenai, color: 'text-emerald-600' },
  { value: 'anthropic', label: 'Anthropic (Claude)', icon: Brain, color: 'text-orange-600' },
  { value: 'google', label: 'Google AI', icon: SiGoogle, color: 'text-blue-600' },
  { value: 'azure_openai', label: 'Azure OpenAI', icon: Cloud, color: 'text-sky-600' },
  { value: 'cohere', label: 'Cohere', icon: Sparkles, color: 'text-purple-600' },
  { value: 'huggingface', label: 'HuggingFace', icon: Bot, color: 'text-yellow-600' },
  { value: 'custom', label: 'Custom Endpoint', icon: Shield, color: 'text-gray-600' }
];

export default function AiIntegrationsPage() {
  const { user } = getAuthState();
  const { toast } = useToast();
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingIntegration, setEditingIntegration] = useState<AiIntegration | null>(null);
  const [testingId, setTestingId] = useState<string | null>(null);

  // Form state
  const [formData, setFormData] = useState({
    provider: 'openai' as AiProvider,
    name: '',
    apiKey: '',
    model: '',
    endpoint: '',
    isDefault: false
  });

  // Fetch integrations
  const { data: integrations = [], isLoading } = useQuery<AiIntegration[]>({
    queryKey: ['/api/ai-integrations'],
    enabled: (user as any)?.userType === 'opus_user'
  });

  // Create mutation
  const createMutation = useMutation({
    mutationFn: async (data: typeof formData) => {
      return apiRequest('/api/ai-integrations', 'POST', data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/ai-integrations'] });
      toast({ 
        title: "Integração criada", 
        description: "A integração AI foi criada com sucesso."
      });
      closeDialog();
    },
    onError: (error: any) => {
      toast({ 
        title: "Erro ao criar", 
        description: error.message || "Não foi possível criar a integração.",
        variant: "destructive"
      });
    }
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string, data: Partial<typeof formData> }) => {
      return apiRequest(`/api/ai-integrations/${id}`, 'PUT', data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/ai-integrations'] });
      toast({ 
        title: "Integração atualizada", 
        description: "A integração AI foi atualizada com sucesso."
      });
      closeDialog();
    },
    onError: (error: any) => {
      toast({ 
        title: "Erro ao atualizar", 
        description: error.message || "Não foi possível atualizar a integração.",
        variant: "destructive"
      });
    }
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiRequest(`/api/ai-integrations/${id}`, 'DELETE');
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/ai-integrations'] });
      toast({ 
        title: "Integração removida", 
        description: "A integração AI foi removida com sucesso."
      });
    },
    onError: (error: any) => {
      toast({ 
        title: "Erro ao remover", 
        description: error.message || "Não foi possível remover a integração.",
        variant: "destructive"
      });
    }
  });

  // Test mutation
  const testMutation = useMutation({
    mutationFn: async (id: string) => {
      setTestingId(id);
      const response = await apiRequest(`/api/ai-integrations/${id}/test`, 'POST', {});
      return response as unknown as { success: boolean; message: string };
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['/api/ai-integrations'] });
      toast({ 
        title: data.success ? "Conexão bem-sucedida" : "Falha na conexão", 
        description: data.message,
        variant: data.success ? "default" : "destructive"
      });
      setTestingId(null);
    },
    onError: (error: any) => {
      toast({ 
        title: "Erro ao testar", 
        description: error.message || "Não foi possível testar a conexão.",
        variant: "destructive"
      });
      setTestingId(null);
    }
  });

  const openCreateDialog = () => {
    setEditingIntegration(null);
    setFormData({
      provider: 'openai',
      name: '',
      apiKey: '',
      model: '',
      endpoint: '',
      isDefault: false
    });
    setIsDialogOpen(true);
  };

  const openEditDialog = (integration: AiIntegration) => {
    setEditingIntegration(integration);
    setFormData({
      provider: integration.provider,
      name: integration.name,
      apiKey: '',
      model: integration.model || '',
      endpoint: integration.endpoint || '',
      isDefault: integration.isDefault
    });
    setIsDialogOpen(true);
  };

  const closeDialog = () => {
    setIsDialogOpen(false);
    setEditingIntegration(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingIntegration) {
      const updateData: any = { ...formData };
      if (!formData.apiKey) {
        delete updateData.apiKey;
      }
      updateMutation.mutate({ id: editingIntegration.id, data: updateData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const getStatusBadge = (status: IntegrationStatus) => {
    const variants = {
      ativa: { variant: "default" as const, icon: CheckCircle2, text: "Ativa", className: "bg-green-600 hover:bg-green-700" },
      inativa: { variant: "secondary" as const, icon: Clock, text: "Inativa", className: "" },
      erro: { variant: "destructive" as const, icon: XCircle, text: "Erro", className: "" }
    };
    const config = variants[status];
    const Icon = config.icon;
    return (
      <Badge variant={config.variant} className={`flex items-center gap-1 ${config.className}`}>
        <Icon className="h-3 w-3" />
        {config.text}
      </Badge>
    );
  };

  const getProviderIcon = (provider: AiProvider) => {
    const option = providerOptions.find(opt => opt.value === provider);
    if (!option) return <Bot className="h-5 w-5 text-gray-500" />;
    const Icon = option.icon;
    return <Icon className={`h-5 w-5 ${option.color}`} />;
  };

  const getProviderLabel = (provider: AiProvider) => {
    return providerOptions.find(opt => opt.value === provider)?.label || provider;
  };

  // Access control check
  if ((user as any)?.userType !== 'opus_user') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white via-gray-50 to-white p-6">
        <ModernCard variant="glass" className="max-w-2xl mx-auto mt-20">
          <ModernCardContent className="text-center py-12">
            <Shield className="h-16 w-16 text-gray-400 mx-auto mb-4" />
            <h2 className="text-2xl font-bold text-gray-900 mb-2">Acesso Restrito</h2>
            <p className="text-gray-600">
              Esta funcionalidade está disponível apenas para usuários OPUS.
            </p>
          </ModernCardContent>
        </ModernCard>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-gray-50 to-white">
      <ModernPageHeader
        title="Integrações AI"
        description="Configure e gerencie integrações com provedores de inteligência artificial"
        icon={Brain}
      />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header Actions */}
        <div className="flex justify-between items-center mb-6">
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <Shield className="h-4 w-4" />
            <span>Apenas usuários OPUS</span>
          </div>
          <Button 
            onClick={openCreateDialog}
            className="flex items-center gap-2"
            data-testid="button-add-integration"
          >
            <Plus className="h-4 w-4" />
            Nova Integração
          </Button>
        </div>

        {/* Integrations Grid */}
        {isLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
          </div>
        ) : integrations.length === 0 ? (
          <ModernCard variant="glass" className="text-center py-16">
            <ModernCardContent>
              <Bot className="h-16 w-16 text-gray-300 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">
                Nenhuma integração configurada
              </h3>
              <p className="text-gray-600 mb-6">
                Configure sua primeira integração AI para começar
              </p>
              <Button onClick={openCreateDialog}>
                <Plus className="h-4 w-4 mr-2" />
                Adicionar Integração
              </Button>
            </ModernCardContent>
          </ModernCard>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {integrations.map((integration) => (
              <ModernCard 
                key={integration.id} 
                variant="glass"
                className="relative"
                data-testid={`card-integration-${integration.id}`}
              >
                {integration.isDefault && (
                  <div className="absolute top-3 right-3">
                    <Badge variant="default" className="flex items-center gap-1">
                      <Check className="h-3 w-3" />
                      Padrão
                    </Badge>
                  </div>
                )}
                
                <ModernCardHeader className="pb-3">
                  <div className="flex items-start gap-3">
                    <div className="p-2 rounded-lg bg-white shadow-sm border">
                      {getProviderIcon(integration.provider)}
                    </div>
                    <div className="flex-1">
                      <h3 className="font-semibold text-gray-900" data-testid={`text-name-${integration.id}`}>
                        {integration.name}
                      </h3>
                      <p className="text-sm text-gray-600">
                        {getProviderLabel(integration.provider)}
                      </p>
                    </div>
                  </div>
                </ModernCardHeader>

                <ModernCardContent className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-600">Status</span>
                    {getStatusBadge(integration.status)}
                  </div>

                  {integration.model && (
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-600">Modelo</span>
                      <span className="text-sm font-medium text-gray-900">
                        {integration.model}
                      </span>
                    </div>
                  )}

                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-600">API Key</span>
                    <code className="text-xs bg-gray-100 px-2 py-1 rounded font-mono">
                      {integration.apiKey}
                    </code>
                  </div>

                  {integration.lastTestedAt && (
                    <div className="text-xs text-gray-500">
                      Último teste: {new Date(integration.lastTestedAt).toLocaleString('pt-BR')}
                    </div>
                  )}

                  {integration.lastErrorMessage && (
                    <div className="flex items-start gap-2 text-xs text-red-600 bg-red-50 p-2 rounded">
                      <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
                      <span>{integration.lastErrorMessage}</span>
                    </div>
                  )}

                  <div className="flex gap-2 pt-3 border-t">
                    <Button 
                      size="sm" 
                      variant="outline" 
                      className="flex-1"
                      onClick={() => testMutation.mutate(integration.id)}
                      disabled={testingId === integration.id}
                      data-testid={`button-test-${integration.id}`}
                    >
                      {testingId === integration.id ? (
                        <Loader2 className="h-3 w-3 animate-spin" />
                      ) : (
                        <TestTube className="h-3 w-3" />
                      )}
                    </Button>
                    <Button 
                      size="sm" 
                      variant="outline" 
                      className="flex-1"
                      onClick={() => openEditDialog(integration)}
                      data-testid={`button-edit-${integration.id}`}
                    >
                      <Edit className="h-3 w-3" />
                    </Button>
                    <Button 
                      size="sm" 
                      variant="outline" 
                      className="flex-1 text-red-600 hover:bg-red-50"
                      onClick={() => {
                        if (confirm('Deseja realmente remover esta integração?')) {
                          deleteMutation.mutate(integration.id);
                        }
                      }}
                      data-testid={`button-delete-${integration.id}`}
                    >
                      <Trash2 className="h-3 w-3" />
                    </Button>
                  </div>
                </ModernCardContent>
              </ModernCard>
            ))}
          </div>
        )}
      </div>

      {/* Create/Edit Dialog */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Brain className="h-5 w-5" />
              {editingIntegration ? 'Editar Integração' : 'Nova Integração AI'}
            </DialogTitle>
            <DialogDescription>
              {editingIntegration 
                ? 'Atualize as configurações da integração AI'
                : 'Configure uma nova integração com provedor de inteligência artificial'
              }
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="provider">Provedor *</Label>
                <Select 
                  value={formData.provider} 
                  onValueChange={(value: AiProvider) => setFormData(prev => ({ ...prev, provider: value }))}
                  disabled={!!editingIntegration}
                >
                  <SelectTrigger data-testid="select-provider">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {providerOptions.map(option => {
                      const Icon = option.icon;
                      return (
                        <SelectItem key={option.value} value={option.value}>
                          <div className="flex items-center gap-2">
                            <Icon className={`h-4 w-4 ${option.color}`} />
                            {option.label}
                          </div>
                        </SelectItem>
                      );
                    })}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="name">Nome da Integração *</Label>
                <Input
                  id="name"
                  placeholder="Ex: OpenAI GPT-4"
                  value={formData.name}
                  onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                  required
                  data-testid="input-name"
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="apiKey" className="flex items-center gap-2">
                <Key className="h-4 w-4" />
                API Key {editingIntegration ? '(deixe em branco para manter)' : '*'}
              </Label>
              <Input
                id="apiKey"
                type="password"
                placeholder="sk-..."
                value={formData.apiKey}
                onChange={(e) => setFormData(prev => ({ ...prev, apiKey: e.target.value }))}
                required={!editingIntegration}
                data-testid="input-apikey"
              />
              <p className="text-xs text-gray-500">
                A chave API será criptografada e armazenada com segurança
              </p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="model">Modelo (opcional)</Label>
              <Input
                id="model"
                placeholder="Ex: gpt-4, claude-3-opus, gemini-pro"
                value={formData.model}
                onChange={(e) => setFormData(prev => ({ ...prev, model: e.target.value }))}
                data-testid="input-model"
              />
            </div>

            {formData.provider === 'custom' && (
              <div className="space-y-2">
                <Label htmlFor="endpoint">Endpoint Personalizado *</Label>
                <Input
                  id="endpoint"
                  placeholder="https://api.exemplo.com/v1"
                  value={formData.endpoint}
                  onChange={(e) => setFormData(prev => ({ ...prev, endpoint: e.target.value }))}
                  required
                  data-testid="input-endpoint"
                />
              </div>
            )}

            <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div className="space-y-0.5">
                <Label htmlFor="isDefault" className="text-sm font-medium">
                  Definir como padrão
                </Label>
                <p className="text-xs text-gray-500">
                  Esta integração será usada como padrão para novos recursos AI
                </p>
              </div>
              <Switch
                id="isDefault"
                checked={formData.isDefault}
                onCheckedChange={(checked) => setFormData(prev => ({ ...prev, isDefault: checked }))}
                data-testid="switch-default"
              />
            </div>

            <DialogFooter>
              <Button type="button" variant="outline" onClick={closeDialog}>
                Cancelar
              </Button>
              <Button 
                type="submit" 
                disabled={createMutation.isPending || updateMutation.isPending}
                data-testid="button-submit"
              >
                {(createMutation.isPending || updateMutation.isPending) ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Salvando...
                  </>
                ) : (
                  <>
                    <Check className="h-4 w-4 mr-2" />
                    {editingIntegration ? 'Atualizar' : 'Criar'} Integração
                  </>
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
