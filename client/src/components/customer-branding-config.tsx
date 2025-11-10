import { useState, useRef } from "react";
import { useMutation } from "@tanstack/react-query";
import { Palette, Upload, X, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import { queryClient, apiRequest } from "@/lib/queryClient";
import type { Customer } from "@shared/schema";

interface CustomerBrandingConfigProps {
  customer: Customer;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

interface ModuleColors {
  clean?: {
    primary?: string;
    secondary?: string;
    accent?: string;
  };
  maintenance?: {
    primary?: string;
    secondary?: string;
    accent?: string;
  };
}

export function CustomerBrandingConfig({ customer, open, onOpenChange }: CustomerBrandingConfigProps) {
  const { toast } = useToast();
  const [moduleColors, setModuleColors] = useState<ModuleColors>((customer.moduleColors as ModuleColors) || {});
  const [uploadingLogo, setUploadingLogo] = useState<string | null>(null);
  
  const loginLogoRef = useRef<HTMLInputElement>(null);
  const sidebarLogoRef = useRef<HTMLInputElement>(null);
  const sidebarCollapsedRef = useRef<HTMLInputElement>(null);

  const uploadLogoMutation = useMutation({
    mutationFn: async ({ logoType, file }: { logoType: string; file: File }) => {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = async () => {
          try {
            const base64Data = reader.result as string;
            const response = await apiRequest("POST", `/api/customers/${customer.id}/upload-logo`, {
              logoType,
              imageData: base64Data,
              fileName: file.name,
            });
            resolve(response);
          } catch (error) {
            reject(error);
          }
        };
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
    },
    onSuccess: (data: any, variables) => {
      updateBrandingMutation.mutate({
        [variables.logoType]: data.path,
      });
    },
    onError: () => {
      setUploadingLogo(null);
      toast({
        title: "Erro ao fazer upload da logo",
        variant: "destructive",
      });
    },
  });

  const updateBrandingMutation = useMutation({
    mutationFn: async (brandingData: any) => {
      return await apiRequest("PUT", `/api/customers/${customer.id}/branding`, brandingData);
    },
    onSuccess: () => {
      // Invalidar cache da lista de clientes
      queryClient.invalidateQueries({ queryKey: ["/api/companies"] });
      // Invalidar cache do cliente específico para recarregar com as novas cores
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customer.id] });
      setUploadingLogo(null);
      toast({
        title: "Configuração de branding atualizada!",
        description: "As novas cores serão aplicadas automaticamente.",
      });
    },
    onError: () => {
      setUploadingLogo(null);
      toast({
        title: "Erro ao atualizar branding",
        variant: "destructive",
      });
    },
  });

  const handleFileSelect = (logoType: string, event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      toast({
        title: "Arquivo inválido",
        description: "Por favor, selecione uma imagem.",
        variant: "destructive",
      });
      return;
    }

    setUploadingLogo(logoType);
    uploadLogoMutation.mutate({ logoType, file });
  };

  const handleColorChange = (module: 'clean' | 'maintenance', colorType: 'primary' | 'secondary' | 'accent', value: string) => {
    setModuleColors(prev => ({
      ...prev,
      [module]: {
        ...(prev[module] || {}),
        [colorType]: value,
      },
    }));
  };

  const handleSaveColors = () => {
    updateBrandingMutation.mutate({ moduleColors });
  };

  const clearLogo = (logoType: 'loginLogo' | 'sidebarLogo' | 'sidebarLogoCollapsed') => {
    updateBrandingMutation.mutate({ [logoType]: null });
  };

  const getLogoPreview = (logoType: 'loginLogo' | 'sidebarLogo' | 'sidebarLogoCollapsed') => {
    const logoPath = customer[logoType];
    if (!logoPath) return null;
    
    return logoPath;
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Configuração de Branding - {customer.name}</DialogTitle>
          <DialogDescription>
            Configure as logos e cores personalizadas para este cliente
          </DialogDescription>
        </DialogHeader>

        <Tabs defaultValue="logos" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="logos">Logos</TabsTrigger>
            <TabsTrigger value="colors">Cores dos Módulos</TabsTrigger>
          </TabsList>

          <TabsContent value="logos" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Logo da Tela de Login</CardTitle>
                <CardDescription>
                  Logo exibida na tela de login (recomendado: 400x200px)
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                {getLogoPreview('loginLogo') && (
                  <div className="relative inline-block">
                    <img
                      src={getLogoPreview('loginLogo')!}
                      alt="Login Logo Preview"
                      className="max-h-24 border rounded"
                    />
                    <Button
                      size="icon"
                      variant="destructive"
                      className="absolute -top-2 -right-2 h-6 w-6"
                      onClick={() => clearLogo('loginLogo')}
                    >
                      <X className="h-3 w-3" />
                    </Button>
                  </div>
                )}
                <div>
                  <input
                    ref={loginLogoRef}
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => handleFileSelect('loginLogo', e)}
                    data-testid="input-upload-login-logo"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => loginLogoRef.current?.click()}
                    disabled={uploadingLogo === 'loginLogo'}
                    data-testid="button-upload-login-logo"
                  >
                    <Upload className="mr-2 h-4 w-4" />
                    {uploadingLogo === 'loginLogo' ? 'Enviando...' : 'Enviar Logo de Login'}
                  </Button>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Logo do Sidebar (Expandido)</CardTitle>
                <CardDescription>
                  Logo exibida no sidebar quando expandido (recomendado: 200x100px)
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                {getLogoPreview('sidebarLogo') && (
                  <div className="relative inline-block">
                    <img
                      src={getLogoPreview('sidebarLogo')!}
                      alt="Sidebar Logo Preview"
                      className="max-h-20 border rounded"
                    />
                    <Button
                      size="icon"
                      variant="destructive"
                      className="absolute -top-2 -right-2 h-6 w-6"
                      onClick={() => clearLogo('sidebarLogo')}
                    >
                      <X className="h-3 w-3" />
                    </Button>
                  </div>
                )}
                <div>
                  <input
                    ref={sidebarLogoRef}
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => handleFileSelect('sidebarLogo', e)}
                    data-testid="input-upload-sidebar-logo"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => sidebarLogoRef.current?.click()}
                    disabled={uploadingLogo === 'sidebarLogo'}
                    data-testid="button-upload-sidebar-logo"
                  >
                    <Upload className="mr-2 h-4 w-4" />
                    {uploadingLogo === 'sidebarLogo' ? 'Enviando...' : 'Enviar Logo do Sidebar'}
                  </Button>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Logo do Sidebar (Colapsado)</CardTitle>
                <CardDescription>
                  Logo exibida no sidebar quando colapsado (recomendado: 64x64px, ícone quadrado)
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                {getLogoPreview('sidebarLogoCollapsed') && (
                  <div className="relative inline-block">
                    <img
                      src={getLogoPreview('sidebarLogoCollapsed')!}
                      alt="Sidebar Collapsed Logo Preview"
                      className="max-h-16 border rounded"
                    />
                    <Button
                      size="icon"
                      variant="destructive"
                      className="absolute -top-2 -right-2 h-6 w-6"
                      onClick={() => clearLogo('sidebarLogoCollapsed')}
                    >
                      <X className="h-3 w-3" />
                    </Button>
                  </div>
                )}
                <div>
                  <input
                    ref={sidebarCollapsedRef}
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => handleFileSelect('sidebarLogoCollapsed', e)}
                    data-testid="input-upload-sidebar-collapsed-logo"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => sidebarCollapsedRef.current?.click()}
                    disabled={uploadingLogo === 'sidebarLogoCollapsed'}
                    data-testid="button-upload-sidebar-collapsed-logo"
                  >
                    <Upload className="mr-2 h-4 w-4" />
                    {uploadingLogo === 'sidebarLogoCollapsed' ? 'Enviando...' : 'Enviar Logo Colapsada'}
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="colors" className="space-y-4">
            {customer.modules?.includes('clean') && (
              <Card>
                <CardHeader>
                  <CardTitle className="text-base flex items-center gap-2">
                    <Palette className="h-4 w-4" />
                    Cores do Módulo Clean
                  </CardTitle>
                  <CardDescription>
                    Cores personalizadas para o módulo de limpeza
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-3 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="clean-primary">Cor Primária</Label>
                      <div className="flex gap-2">
                        <Input
                          id="clean-primary"
                          type="color"
                          value={moduleColors.clean?.primary || '#3b82f6'}
                          onChange={(e) => handleColorChange('clean', 'primary', e.target.value)}
                          className="h-10"
                          data-testid="input-clean-primary-color"
                        />
                        <Input
                          type="text"
                          value={moduleColors.clean?.primary || '#3b82f6'}
                          onChange={(e) => handleColorChange('clean', 'primary', e.target.value)}
                          className="flex-1"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="clean-secondary">Cor Secundária</Label>
                      <div className="flex gap-2">
                        <Input
                          id="clean-secondary"
                          type="color"
                          value={moduleColors.clean?.secondary || '#60a5fa'}
                          onChange={(e) => handleColorChange('clean', 'secondary', e.target.value)}
                          className="h-10"
                          data-testid="input-clean-secondary-color"
                        />
                        <Input
                          type="text"
                          value={moduleColors.clean?.secondary || '#60a5fa'}
                          onChange={(e) => handleColorChange('clean', 'secondary', e.target.value)}
                          className="flex-1"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="clean-accent">Cor de Destaque</Label>
                      <div className="flex gap-2">
                        <Input
                          id="clean-accent"
                          type="color"
                          value={moduleColors.clean?.accent || '#1e40af'}
                          onChange={(e) => handleColorChange('clean', 'accent', e.target.value)}
                          className="h-10"
                          data-testid="input-clean-accent-color"
                        />
                        <Input
                          type="text"
                          value={moduleColors.clean?.accent || '#1e40af'}
                          onChange={(e) => handleColorChange('clean', 'accent', e.target.value)}
                          className="flex-1"
                        />
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}

            {customer.modules?.includes('maintenance') && (
              <Card>
                <CardHeader>
                  <CardTitle className="text-base flex items-center gap-2">
                    <Palette className="h-4 w-4" />
                    Cores do Módulo Manutenção
                  </CardTitle>
                  <CardDescription>
                    Cores personalizadas para o módulo de manutenção
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-3 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="maintenance-primary">Cor Primária</Label>
                      <div className="flex gap-2">
                        <Input
                          id="maintenance-primary"
                          type="color"
                          value={moduleColors.maintenance?.primary || '#f97316'}
                          onChange={(e) => handleColorChange('maintenance', 'primary', e.target.value)}
                          className="h-10"
                          data-testid="input-maintenance-primary-color"
                        />
                        <Input
                          type="text"
                          value={moduleColors.maintenance?.primary || '#f97316'}
                          onChange={(e) => handleColorChange('maintenance', 'primary', e.target.value)}
                          className="flex-1"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="maintenance-secondary">Cor Secundária</Label>
                      <div className="flex gap-2">
                        <Input
                          id="maintenance-secondary"
                          type="color"
                          value={moduleColors.maintenance?.secondary || '#fb923c'}
                          onChange={(e) => handleColorChange('maintenance', 'secondary', e.target.value)}
                          className="h-10"
                          data-testid="input-maintenance-secondary-color"
                        />
                        <Input
                          type="text"
                          value={moduleColors.maintenance?.secondary || '#fb923c'}
                          onChange={(e) => handleColorChange('maintenance', 'secondary', e.target.value)}
                          className="flex-1"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="maintenance-accent">Cor de Destaque</Label>
                      <div className="flex gap-2">
                        <Input
                          id="maintenance-accent"
                          type="color"
                          value={moduleColors.maintenance?.accent || '#c2410c'}
                          onChange={(e) => handleColorChange('maintenance', 'accent', e.target.value)}
                          className="h-10"
                          data-testid="input-maintenance-accent-color"
                        />
                        <Input
                          type="text"
                          value={moduleColors.maintenance?.accent || '#c2410c'}
                          onChange={(e) => handleColorChange('maintenance', 'accent', e.target.value)}
                          className="flex-1"
                        />
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}

            <div className="flex justify-end">
              <Button
                onClick={handleSaveColors}
                disabled={updateBrandingMutation.isPending}
                data-testid="button-save-module-colors"
              >
                <Check className="mr-2 h-4 w-4" />
                Salvar Cores
              </Button>
            </div>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}
