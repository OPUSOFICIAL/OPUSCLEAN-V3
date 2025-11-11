import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';

interface BrandingConfig {
  name: string;
  subdomain: string | null;
  
  // Logos
  loginLogo: string | null;
  sidebarLogo: string | null;
  sidebarLogoCollapsed: string | null;
  homeLogo: string | null;
  faviconUrl: string | null;
  
  // Global Colors
  primaryColor: string | null;
  secondaryColor: string | null;
  accentColor: string | null;
  
  // Module-specific colors (fallback)
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
  
  // Landing Page
  landingTitle: string | null;
  landingSubtitle: string | null;
  landingHeroImage: string | null;
  
  // SEO
  metaDescription: string | null;
  updatedAt: Date | null;
}

interface BrandingContextType {
  branding: BrandingConfig | null;
  isLoading: boolean;
  isReady: boolean;
  brandingNotFound: boolean;
  refresh: () => Promise<void>;
}

const BrandingContext = createContext<BrandingContextType | null>(null);

export function BrandingProvider({ children }: { children: ReactNode }) {
  const [branding, setBranding] = useState<BrandingConfig | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isReady, setIsReady] = useState(false);
  const [brandingNotFound, setBrandingNotFound] = useState(false);

  const loadBranding = async () => {
    try {
      // MODO DE TESTE: Permitir simular subdomínio via query string
      const urlParams = new URLSearchParams(window.location.search);
      const testSubdomain = urlParams.get('test-subdomain');
      const hostname = window.location.hostname;
      let subdomain: string | null = null;

      if (testSubdomain) {
        console.log(`[BRANDING] 🧪 MODO DE TESTE: Simulando subdomínio "${testSubdomain}"`);
        subdomain = testSubdomain;
      } else {
        // MODO NORMAL: Detectar subdomínio do hostname (compatível com qualquer domínio)
        
        // CASO ESPECIAL: Localhost / IP
        // localhost, 127.0.0.1, 0.0.0.0, etc → sem subdomain
        if (hostname === 'localhost' || hostname.match(/^\d+\.\d+\.\d+\.\d+$/)) {
          subdomain = null;
          console.log(`[BRANDING] 🔧 Localhost/IP detectado: sem tenant subdomain`);
        }
        // CASO ESPECIAL: Replit
        // URLs Replit: <instance-id>.janeway.replit.dev ou tenant.<instance-id>.janeway.replit.dev
        // Instance ID tem padrão: <uuid>-00-<hash>
        else if (hostname.endsWith('.replit.dev')) {
          const parts = hostname.split('.');
          // Verificar se temos um tenant subdomain ANTES do instance ID
          // Exemplo: tecnofibra.0f28...-00-hash.janeway.replit.dev
          // parts = ['tecnofibra', '0f28...-00-hash', 'janeway', 'replit', 'dev']
          // O instance ID sempre contém '-00-'
          const instanceIdIndex = parts.findIndex(part => part.includes('-00-'));
          
          if (instanceIdIndex > 0) {
            // Há algo antes do instance ID - é o tenant subdomain
            subdomain = parts[0];
            console.log(`[BRANDING] 🔧 Replit: Tenant detectado antes do instance ID: ${subdomain}`);
          } else {
            // Só temos instance ID - sem tenant subdomain
            subdomain = null;
            console.log(`[BRANDING] 🔧 Replit: Sem tenant subdomain (apenas instance ID)`);
          }
        } else {
          // CASO GERAL: Domínios customizados
          // Detectar se há subdomínio (3+ partes: subdominio.dominio.com)
          const parts = hostname.split('.');
          subdomain = parts.length >= 3 && parts[0] !== 'www' ? parts[0] : null;
        }
      }

      if (subdomain) {
        console.log(`[BRANDING] Subdomínio detectado: ${subdomain} (domínio completo: ${hostname})`);
        // Buscar configurações do subdomínio via API pública
        const response = await fetch(`/api/public/branding/${subdomain}`);
        if (response.ok) {
          const data = await response.json();
          setBranding(data);
          console.log(`[BRANDING] ✓ Branding carregado para: ${data.name}`);

          // Aplicar cores globais via CSS variables (prioridade sobre module colors)
          const root = document.documentElement;
          
          // Aplicar cada cor individualmente com fallback para module colors
          // PRIMARY
          if (data.primaryColor) {
            const hsl = hexToHSL(data.primaryColor);
            root.style.setProperty('--primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
          } else if (data.moduleColors?.clean?.primary) {
            const hsl = hexToHSL(data.moduleColors.clean.primary);
            root.style.setProperty('--primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
          } else {
            // Resetar para valor padrão se nenhuma cor global ou module estiver definida
            root.style.removeProperty('--primary');
          }

          // SECONDARY
          if (data.secondaryColor) {
            const hsl = hexToHSL(data.secondaryColor);
            root.style.setProperty('--secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
          } else if (data.moduleColors?.clean?.secondary) {
            const hsl = hexToHSL(data.moduleColors.clean.secondary);
            root.style.setProperty('--secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
          } else {
            root.style.removeProperty('--secondary');
          }

          // ACCENT
          if (data.accentColor) {
            const hsl = hexToHSL(data.accentColor);
            root.style.setProperty('--accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
          } else if (data.moduleColors?.clean?.accent) {
            const hsl = hexToHSL(data.moduleColors.clean.accent);
            root.style.setProperty('--accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
          } else {
            root.style.removeProperty('--accent');
          }

          // Aplicar meta tags dinâmicas
          if (data.metaDescription) {
            let metaDesc = document.querySelector('meta[name="description"]');
            if (!metaDesc) {
              metaDesc = document.createElement('meta');
              metaDesc.setAttribute('name', 'description');
              document.head.appendChild(metaDesc);
            }
            metaDesc.setAttribute('content', data.metaDescription);
          }

          if (data.faviconUrl) {
            let favicon = document.querySelector('link[rel="icon"]');
            if (!favicon) {
              favicon = document.createElement('link');
              favicon.setAttribute('rel', 'icon');
              document.head.appendChild(favicon);
            }
            favicon.setAttribute('href', data.faviconUrl);
          }

          // Aplicar título da página
          if (data.landingTitle) {
            document.title = data.landingTitle;
          } else {
            document.title = `${data.name} - Portal`;
          }
        } else if (response.status === 404) {
          console.warn(`[BRANDING] ⚠️  Subdomínio "${subdomain}" não encontrado`);
          setBrandingNotFound(true);
        }
      } else {
        // Não há subdomínio, ambiente padrão
        setBrandingNotFound(false);
      }
    } catch (error) {
      console.error('[BRANDING] ❌ Erro ao carregar branding:', error);
    } finally {
      setIsLoading(false);
      setIsReady(true);
    }
  };

  useEffect(() => {
    loadBranding();
  }, []);

  return (
    <BrandingContext.Provider value={{ branding, isLoading, isReady, brandingNotFound, refresh: loadBranding }}>
      {children}
    </BrandingContext.Provider>
  );
}

export const useBranding = () => {
  const context = useContext(BrandingContext);
  if (!context) {
    throw new Error('useBranding must be used within BrandingProvider');
  }
  return context;
};

// Helper: Converter HEX para HSL
function hexToHSL(hex: string): { h: number; s: number; l: number } {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  if (!result) return { h: 0, s: 0, l: 0 };

  let r = parseInt(result[1], 16) / 255;
  let g = parseInt(result[2], 16) / 255;
  let b = parseInt(result[3], 16) / 255;

  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h = 0;
  let s = 0;
  const l = (max + min) / 2;

  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

    switch (max) {
      case r:
        h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
        break;
      case g:
        h = ((b - r) / d + 2) / 6;
        break;
      case b:
        h = ((r - g) / d + 4) / 6;
        break;
    }
  }

  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100)
  };
}
