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
import { Loader2, Upload, Check, X, Save } from 'lucide-react';

export default function BrandingSettings() {
  const { activeClientId } = useClient();
  const { branding, refresh } = useBranding();
  const { toast } = useToast();
  
  const [subdomain, setSubdomain] = useState('');
  const [isSaving, setIsSaving] = useState(false);
  
  // Estado para armazenar arquivos selecionados antes de salvar
  const [pendingLogos, setPendingLogos] = useState<Record<string, { file: File; preview: string } | null>>({
    loginLogo: null,
    sidebarLogo: null,
    sidebarLogoCollapsed: null,
    homeLogo: null
  });

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

  const handleFileSelect = (logoType: string, file: File | null) => {
    if (!file) {
      setPendingLogos(prev => ({ ...prev, [logoType]: null }));
      return;
    }

    // Criar preview da imagem
    const reader = new FileReader();
    reader.onload = (e) => {
      setPendingLogos(prev => ({
        ...prev,
        [logoType]: {
          file,
          preview: e.target?.result as string
        }
      }));
    };
    reader.readAsDataURL(file);
  };

  const handleRemovePending = (logoType: string) => {
    setPendingLogos(prev => ({ ...prev, [logoType]: null }));
  };

  const handleSaveAll = async () => {
    setIsSaving(true);

    try {
      // 1. Salvar subdomínio se mudou
      if (subdomain !== customer?.subdomain) {
        await apiRequest('PUT', `/api/customers/${activeClientId}/branding`, { subdomain });
      }

      // 2. Upload de cada logo pendente
      const logoTypes = Object.keys(pendingLogos) as Array<keyof typeof pendingLogos>;
      
      for (const logoType of logoTypes) {
        const pending = pendingLogos[logoType];
        if (!pending) continue;

        // Upload da imagem
        const reader = new FileReader();
        const imageData = await new Promise<string>((resolve, reject) => {
          reader.onload = (e) => resolve(e.target?.result as string);
          reader.onerror = reject;
          reader.readAsDataURL(pending.file);
        });

        const uploadResponse = await apiRequest('POST', `/api/customers/${activeClientId}/upload-logo`, {
          logoType,
          imageData,
          fileName: pending.file.name
        });
        
        const uploadResult = await uploadResponse.json();
        
        // Atualizar branding com caminho da logo
        await apiRequest('PUT', `/api/customers/${activeClientId}/branding`, {
          [logoType]: uploadResult.path
        });
      }

      // 3. Limpar logos pendentes e atualizar
      setPendingLogos({
        loginLogo: null,
        sidebarLogo: null,
        sidebarLogoCollapsed: null,
        homeLogo: null
      });

      await queryClient.invalidateQueries({ queryKey: ['/api/customers', activeClientId] });
      refresh();

      toast({ 
        title: '✓ Configurações salvas!',
        description: 'Todas as alterações foram aplicadas com sucesso.'
      });
    } catch (error: any) {
      toast({
        title: 'Erro ao salvar',
        description: error.message || 'Tente novamente',
        variant: 'destructive'
      });
    } finally {
      setIsSaving(false);
    }
  };

  const hasChanges = () => {
    const hasSubdomainChange = subdomain !== customer?.subdomain;
    const hasPendingLogos = Object.values(pendingLogos).some(logo => logo !== null);
    return hasSubdomainChange || hasPendingLogos;
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
        </CardContent>
      </Card>

      {/* Logos */}
      <Card>
        <CardHeader>
          <CardTitle>Logos Personalizadas</CardTitle>
          <CardDescription>
            Selecione as imagens desejadas. Clique em "Salvar" no final para aplicar todas as mudanças.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Logo Login */}
          <LogoUploader
            label="Logo da Tela de Login"
            description="Exibida na tela de autenticação (recomendado: 200x60px)"
            logoType="loginLogo"
            currentLogo={customer?.loginLogo}
            pendingLogo={pendingLogos.loginLogo}
            onFileSelect={(file) => handleFileSelect('loginLogo', file)}
            onRemovePending={() => handleRemovePending('loginLogo')}
          />

          {/* Logo Sidebar */}
          <LogoUploader
            label="Logo da Sidebar (Expandida)"
            description="Exibida quando a barra lateral está aberta (recomendado: 150x40px)"
            logoType="sidebarLogo"
            currentLogo={customer?.sidebarLogo}
            pendingLogo={pendingLogos.sidebarLogo}
            onFileSelect={(file) => handleFileSelect('sidebarLogo', file)}
            onRemovePending={() => handleRemovePending('sidebarLogo')}
          />

          {/* Logo Sidebar Collapsed */}
          <LogoUploader
            label="Logo da Sidebar (Colapsada)"
            description="Logo exibida na barra lateral quando colapsada (recomendado: 80x80px)"
            logoType="sidebarLogoCollapsed"
            currentLogo={customer?.sidebarLogoCollapsed}
            pendingLogo={pendingLogos.sidebarLogoCollapsed}
            onFileSelect={(file) => handleFileSelect('sidebarLogoCollapsed', file)}
            onRemovePending={() => handleRemovePending('sidebarLogoCollapsed')}
          />

          {/* Logo Home */}
          <LogoUploader
            label="Logo da Tela Inicial"
            description="Exibida na página principal do sistema (recomendado: 300x100px)"
            logoType="homeLogo"
            currentLogo={customer?.homeLogo}
            pendingLogo={pendingLogos.homeLogo}
            onFileSelect={(file) => handleFileSelect('homeLogo', file)}
            onRemovePending={() => handleRemovePending('homeLogo')}
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

      {/* Botão Salvar no final */}
      <div className="flex justify-end">
        <Button
          size="lg"
          onClick={handleSaveAll}
          disabled={!hasChanges() || isSaving}
          data-testid="button-save-all"
        >
          {isSaving ? (
            <>
              <Loader2 className="mr-2 h-5 w-5 animate-spin" />
              Salvando...
            </>
          ) : (
            <>
              <Save className="mr-2 h-5 w-5" />
              Salvar
            </>
          )}
        </Button>
      </div>
    </div>
  );
}

// Componente auxiliar para upload de logo
function LogoUploader({
  label,
  description,
  logoType,
  currentLogo,
  pendingLogo,
  onFileSelect,
  onRemovePending
}: {
  label: string;
  description: string;
  logoType: string;
  currentLogo?: string | null;
  pendingLogo: { file: File; preview: string } | null;
  onFileSelect: (file: File | null) => void;
  onRemovePending: () => void;
}) {
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    onFileSelect(file);
  };

  return (
    <div className="space-y-3 p-4 border rounded-lg" data-testid={`logo-uploader-${logoType}`}>
      <div className="flex items-start justify-between">
        <div>
          <Label htmlFor={logoType} className="text-base font-medium">{label}</Label>
          <p className="text-xs text-muted-foreground mt-1">{description}</p>
        </div>
        
        {!pendingLogo && currentLogo && (
          <div className="flex items-center gap-2 text-sm text-green-600">
            <Check className="h-4 w-4" />
            <span>Salva</span>
          </div>
        )}
      </div>
      
      <div className="flex items-center gap-3">
        <Button
          type="button"
          variant="outline"
          size="default"
          onClick={() => document.getElementById(logoType)?.click()}
          data-testid={`button-select-${logoType}`}
          className="min-w-[140px]"
        >
          <Upload className="mr-2 h-4 w-4" />
          {currentLogo || pendingLogo ? 'Trocar Logo' : 'Escolher Arquivo'}
        </Button>
        
        <Input
          id={logoType}
          type="file"
          accept="image/*"
          onChange={handleFileChange}
          className="hidden"
          data-testid={`input-upload-${logoType}`}
        />
        
        {pendingLogo && (
          <>
            <div className="flex items-center gap-2 px-3 py-2 bg-blue-50 dark:bg-blue-950/20 border border-blue-200 dark:border-blue-800 rounded-md flex-1">
              <Check className="h-4 w-4 text-blue-600" />
              <span className="text-sm text-blue-700 dark:text-blue-300">
                <strong>{pendingLogo.file.name}</strong> (não salvo)
              </span>
            </div>
            
            <Button
              type="button"
              variant="ghost"
              size="icon"
              onClick={onRemovePending}
              data-testid={`button-remove-${logoType}`}
            >
              <X className="h-4 w-4" />
            </Button>
          </>
        )}
      </div>
      
      {/* Preview da nova imagem selecionada */}
      {pendingLogo && (
        <div className="mt-3 p-4 border-2 border-dashed border-blue-300 rounded-md bg-blue-50 dark:bg-blue-950/20">
          <p className="text-xs text-blue-700 dark:text-blue-300 font-medium mb-2">
            Nova imagem selecionada (não salva):
          </p>
          <img
            src={pendingLogo.preview}
            alt="Preview nova logo"
            className="max-h-24 object-contain"
            data-testid={`img-pending-preview-${logoType}`}
          />
        </div>
      )}
      
      {/* Preview da logo atual salva */}
      {currentLogo && !pendingLogo && (
        <div className="mt-3 p-4 border rounded-md bg-muted/30">
          <p className="text-xs text-muted-foreground mb-2 font-medium">Logo atual:</p>
          <img
            src={currentLogo}
            alt={label}
            className="max-h-24 object-contain"
            data-testid={`img-preview-${logoType}`}
          />
        </div>
      )}
    </div>
  );
}
