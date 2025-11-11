# Guia de Implementação: Sistema Multi-Tenant com Subdomínios

## 📋 Resumo

Sistema que permite cada cliente ter:
- **Subdomínio próprio** (ex: tecnofibra.opus.com, faurecia.opus.com)
- **Logos customizadas** (login, sidebar, home)
- **Cores personalizadas** por módulo (clean/maintenance)

## ✅ Já Implementado

### 1. Schema do Banco de Dados
```sql
-- Campos adicionados à tabela customers:
ALTER TABLE customers ADD COLUMN subdomain VARCHAR UNIQUE;
ALTER TABLE customers ADD COLUMN home_logo TEXT;

-- Campos já existentes:
- login_logo TEXT
- sidebar_logo TEXT  
- sidebar_logo_collapsed TEXT
- module_colors JSONB
```

### 2. Estrutura de Dados
```typescript
// shared/schema.ts - customers table
{
  subdomain: "tecnofibra",           // Identificador único
  loginLogo: "/logos/tech-login.png",     
  sidebarLogo: "/logos/tech-sidebar.png",
  sidebarLogoCollapsed: "/logos/tech-icon.png",
  homeLogo: "/logos/tech-home.png",
  moduleColors: {
    clean: {
      primary: "#1e3a8a",    // Azul personalizado
      secondary: "#3b82f6",
      accent: "#60a5fa"
    },
    maintenance: {
      primary: "#ea580c",    // Laranja personalizado
      secondary: "#f97316",
      accent: "#fb923c"
    }
  }
}
```

## 🚀 Próximos Passos de Implementação

### Passo 1: API de Upload de Logos

```typescript
// server/routes.ts

import multer from 'multer';
import path from 'path';
import fs from 'fs/promises';

// Configurar storage de arquivos
const logoStorage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const dir = path.join('attached_assets', 'client-logos', req.params.customerId);
    await fs.mkdir(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const type = req.body.logoType; // 'login', 'sidebar', 'sidebarCollapsed', 'home'
    const ext = path.extname(file.originalname);
    cb(null, `${type}-${Date.now()}${ext}`);
  }
});

const upload = multer({ 
  storage: logoStorage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas'));
    }
  }
});

// Rota de upload
app.post("/api/customers/:customerId/branding/upload", 
  upload.single('logo'), 
  async (req, res) => {
    try {
      const { customerId } = req.params;
      const { logoType } = req.body; // 'login', 'sidebar', 'sidebarCollapsed', 'home'
      const logoPath = `/logos/${customerId}/${req.file.filename}`;
      
      // Atualizar no banco
      const fieldMap = {
        login: 'loginLogo',
        sidebar: 'sidebarLogo',
        sidebarCollapsed: 'sidebarLogoCollapsed',
        home: 'homeLogo'
      };
      
      await storage.updateCustomer(customerId, {
        [fieldMap[logoType]]: logoPath
      });
      
      res.json({ success: true, logoUrl: logoPath });
    } catch (error) {
      console.error('Upload error:', error);
      res.status(500).json({ message: 'Erro ao fazer upload' });
    }
});
```

### Passo 2: API de Detecção de Subdomínio

```typescript
// server/routes.ts

// Middleware para detectar subdomínio
const detectSubdomain = (req, res, next) => {
  const host = req.get('host');
  
  // Extrai subdomínio (ex: tecnofibra.opus.com -> tecnofibra)
  const parts = host.split('.');
  
  if (parts.length >= 3) {
    req.subdomain = parts[0];
  } else {
    req.subdomain = null; // Domínio principal
  }
  
  next();
};

app.use(detectSubdomain);

// Rota pública para buscar configurações por subdomínio
app.get("/api/public/branding/:subdomain", async (req, res) => {
  try {
    const customer = await db
      .select({
        name: customers.name,
        subdomain: customers.subdomain,
        loginLogo: customers.loginLogo,
        sidebarLogo: customers.sidebarLogo,
        sidebarLogoCollapsed: customers.sidebarLogoCollapsed,
        homeLogo: customers.homeLogo,
        moduleColors: customers.moduleColors
      })
      .from(customers)
      .where(eq(customers.subdomain, req.params.subdomain))
      .limit(1);
    
    if (customer.length === 0) {
      return res.status(404).json({ message: 'Cliente não encontrado' });
    }
    
    res.json(customer[0]);
  } catch (error) {
    console.error('Error fetching branding:', error);
    res.status(500).json({ message: 'Erro ao buscar configurações' });
  }
});

// Rota para atualizar branding
app.put("/api/customers/:customerId/branding", async (req, res) => {
  try {
    const { subdomain, moduleColors } = req.body;
    
    // Validar subdomain único
    if (subdomain) {
      const existing = await db
        .select()
        .from(customers)
        .where(and(
          eq(customers.subdomain, subdomain),
          ne(customers.id, req.params.customerId)
        ));
      
      if (existing.length > 0) {
        return res.status(400).json({ message: 'Subdomínio já está em uso' });
      }
    }
    
    await storage.updateCustomer(req.params.customerId, {
      subdomain,
      moduleColors
    });
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error updating branding:', error);
    res.status(500).json({ message: 'Erro ao atualizar' });
  }
});
```

### Passo 3: Frontend - Context de Branding

```typescript
// client/src/contexts/BrandingContext.tsx

import { createContext, useContext, useState, useEffect } from 'react';

interface BrandingConfig {
  subdomain: string;
  loginLogo: string | null;
  sidebarLogo: string | null;
  sidebarLogoCollapsed: string | null;
  homeLogo: string | null;
  moduleColors: {
    clean?: {
      primary: string;
      secondary: string;
      accent: string;
    };
    maintenance?: {
      primary: string;
      secondary: string;
      accent: string;
    };
  } | null;
}

const BrandingContext = createContext<BrandingConfig | null>(null);

export function BrandingProvider({ children }: { children: React.ReactNode }) {
  const [branding, setBranding] = useState<BrandingConfig | null>(null);
  
  useEffect(() => {
    // Detectar subdomínio do hostname
    const hostname = window.location.hostname;
    const parts = hostname.split('.');
    const subdomain = parts.length >= 3 ? parts[0] : null;
    
    if (subdomain) {
      // Buscar configurações do subdomínio
      fetch(`/api/public/branding/${subdomain}`)
        .then(res => res.json())
        .then(data => {
          setBranding(data);
          
          // Aplicar cores customizadas
          if (data.moduleColors?.clean) {
            document.documentElement.style.setProperty(
              '--color-primary', 
              data.moduleColors.clean.primary
            );
          }
        })
        .catch(err => console.error('Error loading branding:', err));
    }
  }, []);
  
  return (
    <BrandingContext.Provider value={branding}>
      {children}
    </BrandingContext.Provider>
  );
}

export const useBranding = () => useContext(BrandingContext);
```

### Passo 4: Tela de Administração de Branding

```typescript
// client/src/pages/branding-settings.tsx

import { useState } from 'react';
import { useClient } from '@/contexts/ClientContext';
import { useBranding } from '@/contexts/BrandingContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export default function BrandingSettings() {
  const { activeClientId } = useClient();
  const branding = useBranding();
  const [subdomain, setSubdomain] = useState(branding?.subdomain || '');
  const [uploading, setUploading] = useState(false);
  
  const handleLogoUpload = async (logoType: string, file: File) => {
    setUploading(true);
    const formData = new FormData();
    formData.append('logo', file);
    formData.append('logoType', logoType);
    
    try {
      const response = await fetch(
        `/api/customers/${activeClientId}/branding/upload`,
        {
          method: 'POST',
          body: formData
        }
      );
      
      if (response.ok) {
        toast({ title: 'Logo atualizada com sucesso!' });
        window.location.reload(); // Recarregar para mostrar nova logo
      }
    } catch (error) {
      toast({ title: 'Erro ao fazer upload', variant: 'destructive' });
    } finally {
      setUploading(false);
    }
  };
  
  const handleSaveSubdomain = async () => {
    try {
      await fetch(`/api/customers/${activeClientId}/branding`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ subdomain })
      });
      
      toast({ title: 'Subdomínio salvo com sucesso!' });
    } catch (error) {
      toast({ title: 'Erro ao salvar', variant: 'destructive' });
    }
  };
  
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Personalização da Marca</h1>
      
      {/* Subdomínio */}
      <Card>
        <CardHeader>
          <CardTitle>Subdomínio</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="text-sm font-medium">Seu subdomínio</label>
            <div className="flex gap-2">
              <Input 
                value={subdomain}
                onChange={(e) => setSubdomain(e.target.value)}
                placeholder="tecnofibra"
              />
              <span className="flex items-center">.opus.com</span>
            </div>
            <p className="text-sm text-muted-foreground mt-1">
              Seu acesso será: {subdomain || 'seudominio'}.opus.com
            </p>
          </div>
          <Button onClick={handleSaveSubdomain}>Salvar Subdomínio</Button>
        </CardContent>
      </Card>
      
      {/* Logos */}
      <Card>
        <CardHeader>
          <CardTitle>Logos Personalizadas</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Logo Login */}
          <div>
            <label className="text-sm font-medium">Logo da Tela de Login</label>
            <Input 
              type="file"
              accept="image/*"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleLogoUpload('login', file);
              }}
              disabled={uploading}
            />
            {branding?.loginLogo && (
              <img src={branding.loginLogo} alt="Login logo" className="mt-2 h-16" />
            )}
          </div>
          
          {/* Logo Sidebar */}
          <div>
            <label className="text-sm font-medium">Logo da Sidebar</label>
            <Input 
              type="file"
              accept="image/*"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleLogoUpload('sidebar', file);
              }}
              disabled={uploading}
            />
            {branding?.sidebarLogo && (
              <img src={branding.sidebarLogo} alt="Sidebar logo" className="mt-2 h-12" />
            )}
          </div>
          
          {/* Logo Home */}
          <div>
            <label className="text-sm font-medium">Logo da Tela Inicial</label>
            <Input 
              type="file"
              accept="image/*"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleLogoUpload('home', file);
              }}
              disabled={uploading}
            />
            {branding?.homeLogo && (
              <img src={branding.homeLogo} alt="Home logo" className="mt-2 h-20" />
            )}
          </div>
        </CardContent>
      </Card>
      
      {/* Cores */}
      <Card>
        <CardHeader>
          <CardTitle>Cores Personalizadas</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            Em desenvolvimento - seletor de cores por módulo
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
```

### Passo 5: Aplicar Logos nas Telas

```typescript
// Login Page
import { useBranding } from '@/contexts/BrandingContext';

export default function LoginPage() {
  const branding = useBranding();
  
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="w-full max-w-md p-8">
        {/* Logo customizada ou padrão */}
        <img 
          src={branding?.loginLogo || '/default-logo.png'}
          alt="Logo"
          className="h-16 mx-auto mb-8"
        />
        {/* Resto do formulário */}
      </div>
    </div>
  );
}

// Sidebar
export function AppSidebar() {
  const branding = useBranding();
  
  return (
    <Sidebar>
      <SidebarHeader>
        <img 
          src={branding?.sidebarLogo || '/default-sidebar-logo.png'}
          alt="Logo"
          className="h-10"
        />
      </SidebarHeader>
      {/* Resto da sidebar */}
    </Sidebar>
  );
}
```

## 🔧 Configuração para Produção (VM)

### 1. Nginx - Configuração de Subdomínios

```nginx
# /etc/nginx/sites-available/opus

server {
    listen 80;
    server_name *.opus.com opus.com;
    
    # Redirecionar para HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name *.opus.com opus.com;
    
    ssl_certificate /etc/letsencrypt/live/opus.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/opus.com/privkey.pem;
    
    # Passar subdomínio para aplicação
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Servir logos estáticas
    location /logos/ {
        alias /var/www/opus/attached_assets/client-logos/;
        expires 30d;
    }
}
```

### 2. DNS - Configuração de Wildcard

```
# Adicionar registro DNS wildcard
*.opus.com   A   SEU_IP_DO_SERVIDOR
opus.com     A   SEU_IP_DO_SERVIDOR
```

### 3. SSL - Certificado Wildcard

```bash
# Instalar certbot
sudo apt-get install certbot python3-certbot-nginx

# Gerar certificado wildcard (requer validação DNS)
sudo certbot certonly --manual --preferred-challenges dns \
  -d opus.com -d '*.opus.com'

# Renovar automaticamente
sudo crontab -e
# Adicionar linha:
0 0 1 * * /usr/bin/certbot renew --quiet
```

## 📝 Exemplo de Uso

### Criar Cliente com Subdomínio

```sql
-- Inserir cliente TECNOFIBRA
UPDATE customers 
SET 
  subdomain = 'tecnofibra',
  login_logo = '/logos/tecnofibra/login-1234567890.png',
  sidebar_logo = '/logos/tecnofibra/sidebar-1234567890.png',
  home_logo = '/logos/tecnofibra/home-1234567890.png',
  module_colors = '{
    "clean": {
      "primary": "#1e40af",
      "secondary": "#3b82f6",
      "accent": "#60a5fa"
    },
    "maintenance": {
      "primary": "#ea580c",
      "secondary": "#f97316",
      "accent": "#fb923c"
    }
  }'::jsonb
WHERE id = '7913bae1-bdca-4fb4-9465-99a4754995b2';

-- Cliente acessa: https://tecnofibra.opus.com
```

## 🔐 Segurança

1. **Validação de subdomínio**: Apenas caracteres alfanuméricos e hífen
2. **Upload de arquivo**: Validar tipo MIME, tamanho máximo
3. **Isolamento**: Cada cliente só vê/edita seus próprios dados
4. **CORS**: Configurar para aceitar apenas subdomínios válidos

## 📊 Próximas Melhorias

1. **Storage em Cloud** (S3, Cloudflare R2) para logos
2. **CDN** para servir logos mais rápido
3. **Cache** de configurações de branding
4. **Tema dark/light** por cliente
5. **Favicon customizado** por cliente
6. **Editor visual** de cores (color picker)

---

**Status Atual**: Schema pronto ✅ | Implementação completa: aguardando desenvolvimento
