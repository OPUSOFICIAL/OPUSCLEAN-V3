import { useState, useEffect } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { useClient } from '@/contexts/ClientContext';
import { useBranding } from '@/contexts/BrandingContext';
import { queryClient, apiRequest } from '@/lib/queryClient';
import { useToast } from '@/hooks/use-toast';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardHeader, CardTitle, CardContent, CardDescription } from '@/components/ui/card';
import { Loader2, Upload, Check } from 'lucide-react';

export default function BrandingSettings() {
  const { activeClientId } = useClient();
  const { branding, refresh } = useBranding();
  const { toast } = useToast();
  
  const [subdomain, setSubdomain] = useState('');
  const [uploading, setUploading] = useState<string | null>(null);

  // Query customer data
  const { data: customer } = useQuery<any>({
    queryKey: ['/api/customers', activeClientId],
    enabled: !!activeClientId
  });

  // Sync subdomain state with customer data
  useEffect(() => {
    if (customer?.subdomain) {
      setSubdomain(customer.subdomain);
    }
  }, [customer]);

  // Update branding mutation
  const updateBrandingMutation = useMutation({
    mutationFn: async (data: { subdomain?: string; moduleColors?: any }) => {
      return await apiRequest('PUT', `/api/customers/${activeClientId}/branding`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/customers', activeClientId] });
      refresh();
      toast({ title: 'Configurações salvas com sucesso!' });
    },
    onError: (error: any) => {
      toast({
        title: 'Erro ao salvar',
        description: error.message || 'Tente novamente',
        variant: 'destructive'
      });
    }
  });

  // Upload logo mutation
  const uploadLogoMutation = useMutation({
    mutationFn: async ({ logoType, file }: { logoType: string; file: File }) => {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = async (e) => {
          try {
            const imageData = e.target?.result as string;
            const uploadResponse = await apiRequest('POST', `/api/customers/${activeClientId}/upload-logo`, {
              logoType,
              imageData,
              fileName: file.name
            });
            
            const uploadResult = await uploadResponse.json();
            
            // Update branding with new logo path
            await apiRequest('PUT', `/api/customers/${activeClientId}/branding`, {
              [logoType]: uploadResult.path
            });
            
            resolve(uploadResult);
          } catch (error) {
            reject(error);
          }
        };
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/customers', activeClientId] });
      refresh();
      setUploading(null);
      toast({ title: 'Logo atualizada com sucesso!' });
    },
    onError: (error: any) => {
      setUploading(null);
      toast({
        title: 'Erro ao fazer upload',
        description: error.message || 'Tente novamente',
        variant: 'destructive'
      });
    }
  });

  const handleLogoUpload = (logoType: string, file: File | null) => {
    if (!file) return;
    setUploading(logoType);
    uploadLogoMutation.mutate({ logoType, file });
  };

  const handleSaveSubdomain = () => {
    updateBrandingMutation.mutate({ subdomain });
  };

  if (!activeClientId) {
    return (
      <div className="flex items-center justify-center h-full">
        <p className="text-muted-foreground">Selecione um cliente para configurar</p>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-6 space-y-6 max-w-4xl" data-testid="page-branding-settings">
      <div>
        <h1 className="text-3xl font-bold" data-testid="text-page-title">Personalização da Marca</h1>
        <p className="text-muted-foreground mt-1">Configure logos, cores e subdomínio do seu cliente</p>
      </div>

      {/* Subdomínio */}
      <Card>
        <CardHeader>
          <CardTitle>Subdomínio Personalizado</CardTitle>
          <CardDescription>
            Defina um endereço único para seu cliente acessar o sistema
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="subdomain">Seu subdomínio</Label>
            <div className="flex gap-2">
              <Input
                id="subdomain"
                data-testid="input-subdomain"
                value={subdomain}
                onChange={(e) => setSubdomain(e.target.value)}
                placeholder="minha-empresa"
                className="flex-1"
              />
              <span className="flex items-center text-muted-foreground">.opus.com</span>
            </div>
            <p className="text-sm text-muted-foreground">
              Acesso será: <strong>{subdomain || 'seu-subdominio'}.opus.com</strong>
            </p>
          </div>
          <Button
            onClick={handleSaveSubdomain}
            disabled={updateBrandingMutation.isPending}
            data-testid="button-save-subdomain"
          >
            {updateBrandingMutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Salvar Subdomínio
          </Button>
        </CardContent>
      </Card>

      {/* Logos */}
      <Card>
        <CardHeader>
          <CardTitle>Logos Personalizadas</CardTitle>
          <CardDescription>
            Faça upload das logos que serão exibidas nas diferentes telas do sistema
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Logo Login */}
          <LogoUploader
            label="Logo da Tela de Login"
            description="Exibida na tela de autenticação (recomendado: 200x60px)"
            logoType="loginLogo"
            currentLogo={customer?.loginLogo}
            uploading={uploading === 'loginLogo'}
            onUpload={(file) => handleLogoUpload('loginLogo', file)}
          />

          {/* Logo Sidebar */}
          <LogoUploader
            label="Logo da Sidebar (Expandida)"
            description="Exibida quando a barra lateral está aberta (recomendado: 150x40px)"
            logoType="sidebarLogo"
            currentLogo={customer?.sidebarLogo}
            uploading={uploading === 'sidebarLogo'}
            onUpload={(file) => handleLogoUpload('sidebarLogo', file)}
          />

          {/* Logo Sidebar Collapsed */}
          <LogoUploader
            label="Logo da Sidebar (Recolhida)"
            description="Ícone exibido quando a barra está recolhida (recomendado: 40x40px)"
            logoType="sidebarLogoCollapsed"
            currentLogo={customer?.sidebarLogoCollapsed}
            uploading={uploading === 'sidebarLogoCollapsed'}
            onUpload={(file) => handleLogoUpload('sidebarLogoCollapsed', file)}
          />

          {/* Logo Home */}
          <LogoUploader
            label="Logo da Tela Inicial"
            description="Exibida na página principal do sistema (recomendado: 300x100px)"
            logoType="homeLogo"
            currentLogo={customer?.homeLogo}
            uploading={uploading === 'homeLogo'}
            onUpload={(file) => handleLogoUpload('homeLogo', file)}
          />
        </CardContent>
      </Card>

      {/* Cores (placeholder para futura implementação) */}
      <Card>
        <CardHeader>
          <CardTitle>Cores Personalizadas</CardTitle>
          <CardDescription>
            Defina o esquema de cores para cada módulo do sistema
          </CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            Seletor de cores em desenvolvimento. Em breve você poderá personalizar as cores dos módulos Clean e Maintenance.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}

// Componente auxiliar para upload de logo
function LogoUploader({
  label,
  description,
  logoType,
  currentLogo,
  uploading,
  onUpload
}: {
  label: string;
  description: string;
  logoType: string;
  currentLogo?: string | null;
  uploading: boolean;
  onUpload: (file: File | null) => void;
}) {
  return (
    <div className="space-y-2" data-testid={`logo-uploader-${logoType}`}>
      <Label htmlFor={logoType}>{label}</Label>
      <p className="text-xs text-muted-foreground">{description}</p>
      
      <div className="flex items-center gap-4">
        <Input
          id={logoType}
          type="file"
          accept="image/*"
          onChange={(e) => onUpload(e.target.files?.[0] || null)}
          disabled={uploading}
          className="flex-1"
          data-testid={`input-upload-${logoType}`}
        />
        {uploading && <Loader2 className="h-5 w-5 animate-spin text-muted-foreground" />}
        {!uploading && currentLogo && <Check className="h-5 w-5 text-green-600" />}
      </div>
      
      {currentLogo && (
        <div className="mt-2 p-4 border rounded-md bg-muted/30">
          <p className="text-xs text-muted-foreground mb-2">Preview atual:</p>
          <img
            src={currentLogo}
            alt={label}
            className="max-h-20 object-contain"
            data-testid={`img-preview-${logoType}`}
          />
        </div>
      )}
    </div>
  );
}
