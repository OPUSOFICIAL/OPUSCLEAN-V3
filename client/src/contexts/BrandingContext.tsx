import { createContext, useContext, useState, useEffect, useRef, type ReactNode } from 'react';
import { detectSubdomain, isValidSubdomain, isValidUUID } from '@/lib/subdomain-detector';
import { useClient } from '@/contexts/ClientContext';
import { useAuth } from '@/hooks/useAuth';

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
  // Branding é armazenado em MEMÓRIA (useState), não localStorage
  const [branding, setBranding] = useState<BrandingConfig | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  
  // Get active client from ClientContext
  const { activeClient, activeClientId, clientSource } = useClient();
  const { isAuthenticated } = useAuth();
  
  // Track which client's branding was last applied
  const appliedClientIdRef = useRef<string | null>(null);

  // Load branding from query param or subdomain (for public pages)
  const loadBrandingFromDetection = async () => {
    try {
      const detection = detectSubdomain();
      console.log('[BRANDING] 🔍 Detecção:', detection);
      
      // Priority 1: Query param with customer ID
      if (detection.source === 'query_param_id' && detection.customerId) {
        if (isValidUUID(detection.customerId)) {
          console.log('[BRANDING] 🔑 Carregando branding via query param ID:', detection.customerId);
          const response = await fetch(`/api/public/customer-by-id/${detection.customerId}`);
          if (response.ok) {
            const customerData = await response.json();
            console.log('[BRANDING] ✅ Branding carregado (query param ID):', customerData.name);
            applyBrandingData(customerData);
            appliedClientIdRef.current = customerData.id;
            return true;
          }
        }
      }
      
      // Priority 2: Query param with slug (?cliente=)
      if (detection.source === 'query_param_slug' && detection.clienteSlug) {
        if (isValidSubdomain(detection.clienteSlug)) {
          console.log('[BRANDING] 🔑 Carregando branding via query param slug:', detection.clienteSlug);
          const response = await fetch(`/api/public/customer-by-subdomain/${detection.clienteSlug}`);
          if (response.ok) {
            const customerData = await response.json();
            console.log('[BRANDING] ✅ Branding carregado (query param slug):', customerData.name);
            applyBrandingData(customerData);
            appliedClientIdRef.current = customerData.id;
            return true;
          }
        }
      }

      // Priority 3: Subdomain
      if (detection.source === 'subdomain' && detection.subdomain) {
        if (isValidSubdomain(detection.subdomain)) {
          console.log('[BRANDING] 🌐 Carregando branding via subdomínio:', detection.subdomain);
          const response = await fetch(`/api/public/customer-by-subdomain/${detection.subdomain}`);
          if (response.ok) {
            const customerData = await response.json();
            console.log('[BRANDING] ✅ Branding carregado (subdomínio):', customerData.name);
            applyBrandingData(customerData);
            appliedClientIdRef.current = customerData.id;
            return true;
          }
        }
      }
      
      return false;
    } catch (error) {
      console.error('[BRANDING] Erro ao carregar branding:', error);
      return false;
    }
  };

  // Load branding from customer ID (for logged-in users)
  const loadBrandingFromCustomerId = async (customerId: string) => {
    try {
      console.log('[BRANDING] 🔄 Carregando branding do cliente:', customerId);
      
      // Try authenticated API first
      const token = localStorage.getItem('opus_clean_token');
      if (token) {
        const response = await fetch(`/api/customers/${customerId}`, {
          headers: { 'Authorization': `Bearer ${token}` },
        });
        
        if (response.ok) {
          const customerData = await response.json();
          console.log('[BRANDING] ✅ Branding carregado (auth):', customerData.name);
          applyBrandingData(customerData);
          appliedClientIdRef.current = customerId;
          return true;
        }
      }
      
      // Fallback to public API
      console.log('[BRANDING] ⚠️ Fallback para API pública');
      const response = await fetch(`/api/public/customer-by-id/${customerId}`);
      if (response.ok) {
        const customerData = await response.json();
        console.log('[BRANDING] ✅ Branding carregado (público):', customerData.name);
        applyBrandingData(customerData);
        appliedClientIdRef.current = customerId;
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[BRANDING] Erro ao carregar branding do cliente:', error);
      return false;
    }
  };

  // Apply branding data to state (MEMORY) and CSS variables
  const applyBrandingData = (customerData: any) => {
    const brandingConfig: BrandingConfig = {
      name: customerData.name,
      subdomain: customerData.subdomain || null,
      loginLogo: customerData.loginLogo || null,
      sidebarLogo: customerData.sidebarLogo || null,
      sidebarLogoCollapsed: customerData.sidebarLogoCollapsed || null,
      homeLogo: customerData.homeLogo || null,
      favicon: customerData.favicon || null,
      moduleColors: customerData.moduleColors || null,
    };
    
    // Store in MEMORY (React state)
    setBranding(brandingConfig);
    
    console.log('[BRANDING] 🎨 Branding salvo em MEMÓRIA:', {
      name: brandingConfig.name,
      logos: {
        login: !!brandingConfig.loginLogo,
        sidebar: !!brandingConfig.sidebarLogo,
        sidebarCollapsed: !!brandingConfig.sidebarLogoCollapsed,
        home: !!brandingConfig.homeLogo,
        favicon: !!brandingConfig.favicon,
      },
      colors: brandingConfig.moduleColors
    });

    // Apply module colors to CSS variables
    applyModuleColors(customerData.moduleColors);
    setIsLoading(false);
  };

  // Apply module colors to CSS variables
  const applyModuleColors = (moduleColors: any) => {
    if (!moduleColors) return;
    
    const root = document.documentElement;
    
    if (moduleColors.clean) {
      const colors = moduleColors.clean;
      if (colors.primary) {
        const hsl = hexToHSL(colors.primary);
        root.style.setProperty('--primary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        root.style.setProperty('--module-primary', colors.primary);
      }
      if (colors.secondary) {
        const hsl = hexToHSL(colors.secondary);
        root.style.setProperty('--secondary', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        root.style.setProperty('--module-secondary', colors.secondary);
      }
      if (colors.accent) {
        const hsl = hexToHSL(colors.accent);
        root.style.setProperty('--accent', `${hsl.h} ${hsl.s}% ${hsl.l}%`);
        root.style.setProperty('--module-accent', colors.accent);
      }
    }
    
    if (moduleColors.maintenance) {
      const colors = moduleColors.maintenance;
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
  };

  // Reset CSS variables to defaults
  const resetCSSVariables = () => {
    const root = document.documentElement;
    root.style.removeProperty('--primary');
    root.style.removeProperty('--secondary');
    root.style.removeProperty('--accent');
    root.style.removeProperty('--module-primary');
    root.style.removeProperty('--module-secondary');
    root.style.removeProperty('--module-accent');
    root.style.removeProperty('--maintenance-primary');
    root.style.removeProperty('--maintenance-secondary');
    root.style.removeProperty('--maintenance-accent');
  };

  // Main branding loader
  const loadBranding = async () => {
    setIsLoading(true);
    resetCSSVariables();
    
    // If authenticated and has activeClientId, load from customer
    if (isAuthenticated && activeClientId) {
      console.log('[BRANDING] 👤 Usuário autenticado, carregando branding:', activeClientId);
      const loaded = await loadBrandingFromCustomerId(activeClientId);
      if (loaded) return;
    }
    
    // Try detection (query param or subdomain)
    const detected = await loadBrandingFromDetection();
    if (detected) return;
    
    // No branding found - use defaults
    console.log('[BRANDING] ℹ️ Nenhum branding encontrado, usando padrão');
    setBranding(null);
    setIsLoading(false);
  };

  // Initial load on mount
  useEffect(() => {
    loadBranding();
  }, []);

  // Reload branding when activeClientId changes
  // BUT keep existing branding if it matches (avoid 401s before login)
  useEffect(() => {
    if (activeClientId && activeClientId !== appliedClientIdRef.current) {
      console.log('[BRANDING] 🔄 Cliente ativo mudou:', activeClientId, '(fonte:', clientSource, ')');
      
      // If we already have branding for this client (from query param), don't reload
      if (branding && appliedClientIdRef.current === activeClientId) {
        console.log('[BRANDING] ✅ Branding já aplicado, mantendo em memória');
        return;
      }
      
      loadBrandingFromCustomerId(activeClientId);
    }
  }, [activeClientId, clientSource, branding]);

  // React to activeClient data changes (React Query fresh data)
  useEffect(() => {
    if (activeClient && activeClient.id && activeClient.id !== appliedClientIdRef.current) {
      console.log('[BRANDING] 🔄 Dados do cliente recebidos:', activeClient.name);
      applyBrandingData(activeClient);
      appliedClientIdRef.current = activeClient.id;
    }
  }, [activeClient?.id, activeClient?.moduleColors, activeClient?.loginLogo, activeClient?.sidebarLogo]);

  // Apply favicon dynamically
  useEffect(() => {
    if (branding?.favicon) {
      console.log('[BRANDING] 🖼️ Aplicando favicon:', branding.favicon);
      const existingFavicons = document.querySelectorAll('link[rel*="icon"]');
      existingFavicons.forEach(favicon => favicon.remove());
      
      const link = document.createElement('link');
      link.rel = 'icon';
      link.type = 'image/png';
      link.href = branding.favicon;
      document.head.appendChild(link);
    }
  }, [branding?.favicon]);

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

// Helper: Convert HEX to HSL
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
