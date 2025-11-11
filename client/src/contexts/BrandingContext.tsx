import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';

interface BrandingConfig {
  name: string;
  subdomain: string | null;
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

interface BrandingContextType {
  branding: BrandingConfig | null;
  isLoading: boolean;
  refresh: () => Promise<void>;
}

const BrandingContext = createContext<BrandingContextType | null>(null);

export function BrandingProvider({ children }: { children: ReactNode }) {
  const [branding, setBranding] = useState<BrandingConfig | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadBranding = async () => {
    try {
      // Detectar subdomínio do hostname (compatível com qualquer domínio)
      const hostname = window.location.hostname;
      const parts = hostname.split('.');
      // Detectar se há subdomínio (3+ partes: subdominio.dominio.com)
      const subdomain = parts.length >= 3 && parts[0] !== 'www' ? parts[0] : null;

      if (subdomain) {
        console.log(`[BRANDING] Subdomínio detectado: ${subdomain} (domínio completo: ${hostname})`);
        // Buscar configurações do subdomínio
        const response = await fetch(`/api/public/branding/${subdomain}`);
        if (response.ok) {
          const data = await response.json();
          setBranding(data);
          console.log(`[BRANDING] Branding aplicado para cliente: ${data.name}`);

          // Aplicar cores customizadas via CSS variables
          if (data.moduleColors?.clean) {
            const root = document.documentElement;
            const colors = data.moduleColors.clean;
            
            // Converter HEX para HSL e aplicar
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
        }
      }
    } catch (error) {
      console.error('Error loading branding:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadBranding();
  }, []);

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
