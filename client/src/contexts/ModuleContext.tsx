import { createContext, useContext, useState, useEffect } from 'react';

export type ModuleType = 'clean' | 'maintenance';

interface ModuleConfig {
  id: ModuleType;
  name: string;
  displayName: string;
  primaryColor: string;
  secondaryColor: string;
  accentColor: string;
  description: string;
  icon: string;
}

export const MODULE_CONFIGS: Record<ModuleType, ModuleConfig> = {
  clean: {
    id: 'clean',
    name: 'clean',
    displayName: 'OPUS Clean',
    primaryColor: '#1e3a8a',
    secondaryColor: '#3b82f6',
    accentColor: '#60a5fa',
    description: 'Gestão de Limpeza e Facilities',
    icon: '🧹',
  },
  maintenance: {
    id: 'maintenance',
    name: 'maintenance',
    displayName: 'OPUS Manutenção',
    primaryColor: '#FF9800',
    secondaryColor: '#FB8C00',
    accentColor: '#FFB74D',
    description: 'Gestão de Manutenção',
    icon: '🔧',
  },
};

interface ModuleContextType {
  currentModule: ModuleType;
  moduleConfig: ModuleConfig;
  setModule: (module: ModuleType) => void;
  getModuleRoute: (path: string) => string;
}

const ModuleContext = createContext<ModuleContextType | undefined>(undefined);

export function ModuleProvider({ children }: { children: React.ReactNode }) {
  const [currentModule, setCurrentModule] = useState<ModuleType>(() => {
    const stored = localStorage.getItem('opus:currentModule');
    return (stored === 'clean' || stored === 'maintenance') ? stored : 'clean';
  });

  const moduleConfig = MODULE_CONFIGS[currentModule];

  useEffect(() => {
    localStorage.setItem('opus:currentModule', currentModule);
    
    document.documentElement.setAttribute('data-module', currentModule);
    
    document.documentElement.style.setProperty('--module-primary', moduleConfig.primaryColor);
    document.documentElement.style.setProperty('--module-secondary', moduleConfig.secondaryColor);
    document.documentElement.style.setProperty('--module-accent', moduleConfig.accentColor);
  }, [currentModule, moduleConfig]);

  const setModule = (module: ModuleType) => {
    setCurrentModule(module);
  };

  const getModuleRoute = (path: string) => {
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    return `/${currentModule}${cleanPath}`;
  };

  return (
    <ModuleContext.Provider
      value={{
        currentModule,
        moduleConfig,
        setModule,
        getModuleRoute,
      }}
    >
      {children}
    </ModuleContext.Provider>
  );
}

export function useModule() {
  const context = useContext(ModuleContext);
  if (!context) {
    throw new Error('useModule must be used within ModuleProvider');
  }
  return context;
}
