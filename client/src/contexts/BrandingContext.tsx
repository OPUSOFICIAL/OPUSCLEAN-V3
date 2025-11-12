import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { detectSubdomain, isValidSubdomain } from '@/lib/subdomain-detector';
import { useClient } from '@/contexts/ClientContext';

interface BrandingConfig {
  name: string;
  subdomain: string | null;
  loginLogo: string | null;
  sidebarLogo: string | null;
  sidebarLogoCollapsed: string | null;
  homeLogo: string | null;
  favicon: string | null;
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

interface BrandingContextType {
  branding: BrandingConfig | null;
  isLoading: boolean;
  refresh: () => Promise<void>;
}

const BrandingContext = createContext<BrandingContextType | null>(null);

export function BrandingProvider({ children }: { children: ReactNode }) {
  const [branding, setBranding] = useState<BrandingConfig | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  
  // Get active client from ClientContext to update branding when client changes
  const { activeClient } = useClient();

  const loadBranding = async () => {
    try {
      // Adaptive subdomain detection
      const detection = detectSubdomain();
      const subdomain = detection.subdomain;
      
      console.log('[BRANDING] 🔍 Detecção:', detection);
      console.log('[BRANDING] 📍 Subdomain:', subdomain);
      console.log('[BRANDING] ✅ Válido?', subdomain ? isValidSubdomain(subdomain) : false);

      // Reset branding state first (to clear previous tenant data)
      setBranding(null);
      resetCSSVariables();

      if (subdomain && isValidSubdomain(subdomain)) {
        console.log('[BRANDING] 🌐 Buscando branding para:', subdomain);
        // Fetch customer branding via public API
        const response = await fetch(`/api/public/customer-by-subdomain/${subdomain}`);
        console.log('[BRANDING] 📡 Resposta API:', response.status);
        
        if (response.ok) {
          const customerData = await response.json();
          console.log('[BRANDING] ✨ Dados recebidos:', customerData);
          
          // Build branding config
          const brandingConfig: BrandingConfig = {
            name: customerData.name,
            subdomain: customerData.subdomain,
            loginLogo: customerData.loginLogo,
            sidebarLogo: customerData.sidebarLogo,
            sidebarLogoCollapsed: customerData.sidebarLogoCollapsed,
            homeLogo: customerData.homeLogo,
            favicon: customerData.favicon,
            moduleColors: customerData.moduleColors,
          };
          
          setBranding(brandingConfig);
          console.log('[BRANDING] 🎨 Branding configurado:', {
            logos: {
              login: brandingConfig.loginLogo,
              sidebar: brandingConfig.sidebarLogo,
              sidebarCollapsed: brandingConfig.sidebarLogoCollapsed,
              home: brandingConfig.homeLogo
            },
            colors: brandingConfig.moduleColors
          });

          // Apply module colors dynamically via CSS variables
          if (customerData.moduleColors) {
            const root = document.documentElement;
            
            // Apply clean module colors if available
            if (customerData.moduleColors.clean) {
              const colors = customerData.moduleColors.clean;
              if (colors.primary) {
                const hsl = hexToHSL(colors.primary);
                root.style.setProperty('--primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
              }
              if (colors.secondary) {
                const hsl = hexToHSL(colors.secondary);
                root.style.setProperty('--secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
              }
              if (colors.accent) {
                const hsl = hexToHSL(colors.accent);
                root.style.setProperty('--accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
              }
            }
            
            // Apply maintenance module colors if available
            if (customerData.moduleColors.maintenance) {
              const colors = customerData.moduleColors.maintenance;
              if (colors.primary) {
                const hsl = hexToHSL(colors.primary);
                root.style.setProperty('--maintenance-primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
              }
              if (colors.secondary) {
                const hsl = hexToHSL(colors.secondary);
                root.style.setProperty('--maintenance-secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
              }
              if (colors.accent) {
                const hsl = hexToHSL(colors.accent);
                root.style.setProperty('--maintenance-accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
              }
            }
          }
        } else if (response.status === 404) {
          // No branding found for this subdomain - reset to defaults
          console.warn(`[BRANDING] No branding found for subdomain: ${subdomain}`);
        }
      }
    } catch (error) {
      console.error('[BRANDING] Error loading branding:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Reset CSS variables to defaults (to prevent mixed branding)
  const resetCSSVariables = () => {
    const root = document.documentElement;
    // Remove any custom color overrides
    root.style.removeProperty('--primary');
    root.style.removeProperty('--secondary');
    root.style.removeProperty('--accent');
    root.style.removeProperty('--maintenance-primary');
    root.style.removeProperty('--maintenance-secondary');
    root.style.removeProperty('--maintenance-accent');
  };

  useEffect(() => {
    loadBranding();
  }, []);

  // Update branding when active client changes (for dropdown changes)
  useEffect(() => {
    if (activeClient) {
      console.log('[BRANDING] 🔄 Cliente ativo mudou, atualizando branding:', activeClient.name);
      applyClientBranding(activeClient);
    }
  }, [activeClient?.id]); // React when client ID changes

  // Apply favicon dynamically when branding changes
  useEffect(() => {
    if (branding?.favicon) {
      console.log('[BRANDING] 🎨 Aplicando favicon:', branding.favicon);
      
      // Remove existing favicon link tags
      const existingFavicons = document.querySelectorAll('link[rel*="icon"]');
      existingFavicons.forEach(favicon => favicon.remove());
      
      // Create new favicon link element
      const link = document.createElement('link');
      link.rel = 'icon';
      link.type = 'image/png';
      link.href = branding.favicon;
      
      // Append to head
      document.head.appendChild(link);
    } else {
      console.log('[BRANDING] ℹ️ Nenhum favicon personalizado, mantendo padrão');
    }
  }, [branding?.favicon]);

  // Apply branding from activeClient data (for dropdown changes)
  const applyClientBranding = (client: any) => {
    // Build branding config from client data
    const brandingConfig: BrandingConfig = {
      name: client.name,
      subdomain: client.subdomain || null,
      loginLogo: client.loginLogo || null,
      sidebarLogo: client.sidebarLogo || null,
      sidebarLogoCollapsed: client.sidebarLogoCollapsed || null,
      homeLogo: client.homeLogo || null,
      favicon: client.favicon || null,
      moduleColors: client.moduleColors || null,
    };
    
    setBranding(brandingConfig);
    console.log('[BRANDING] 🎨 Branding atualizado do cliente ativo:', {
      logos: {
        login: brandingConfig.loginLogo,
        sidebar: brandingConfig.sidebarLogo,
        sidebarCollapsed: brandingConfig.sidebarLogoCollapsed,
        home: brandingConfig.homeLogo,
        favicon: brandingConfig.favicon
      },
      colors: brandingConfig.moduleColors
    });

    // Apply module colors dynamically
    if (client.moduleColors) {
      const root = document.documentElement;
      
      if (client.moduleColors.clean) {
        const colors = client.moduleColors.clean;
        if (colors.primary) {
          const hsl = hexToHSL(colors.primary);
          root.style.setProperty('--primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        }
        if (colors.secondary) {
          const hsl = hexToHSL(colors.secondary);
          root.style.setProperty('--secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        }
        if (colors.accent) {
          const hsl = hexToHSL(colors.accent);
          root.style.setProperty('--accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        }
      }
      
      if (client.moduleColors.maintenance) {
        const colors = client.moduleColors.maintenance;
        if (colors.primary) {
          const hsl = hexToHSL(colors.primary);
          root.style.setProperty('--maintenance-primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        }
        if (colors.secondary) {
          const hsl = hexToHSL(colors.secondary);
          root.style.setProperty('--maintenance-secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        }
        if (colors.accent) {
          const hsl = hexToHSL(colors.accent);
          root.style.setProperty('--maintenance-accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        }
      }
    }
  };

  return (
    <BrandingContext.Provider value={{ branding, isLoading, refresh: loadBranding }}>
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
