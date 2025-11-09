import { createContext, useContext, useState, useEffect } from 'react';
import { useLocation } from 'wouter';
import { useUserModules } from '@/hooks/useUserModules';
import { useClient } from './ClientContext';
import { queryClient } from '@/lib/queryClient';

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
  allowedModules: ModuleType[];
  canAccessModule: (module: ModuleType) => boolean;
  hasMultipleModules: boolean;
}

const ModuleContext = createContext<ModuleContextType | undefined>(undefined);

export function ModuleProvider({ children }: { children: React.ReactNode }) {
  const { 
    allowedModules, 
    defaultModule, 
    canAccessModule, 
    getValidModule,
    hasMultipleModules,
    isLoading 
  } = useUserModules();

  // Inicializar com null e esperar os dados carregarem
  const [currentModule, setCurrentModule] = useState<ModuleType | null>(null);

  const moduleConfig = currentModule ? MODULE_CONFIGS[currentModule] : MODULE_CONFIGS.clean;
  
  // Importar ClientContext para sincronizar módulo com cliente
  const { activeClient, customers, setActiveClientId } = useClient();
  
  // Hook de navegação para redirecionamento automático
  const [, setLocation] = useLocation();

  // Inicializar o módulo apenas DEPOIS que os dados do usuário carregarem
  useEffect(() => {
    if (!isLoading && currentModule === null) {
      // Se não tem módulos configurados, forçar 'clean' como padrão seguro
      const safeDefaultModule = allowedModules.length > 0 ? defaultModule : 'clean';
      
      // Primeira inicialização - usar localStorage ou defaultModule
      const stored = localStorage.getItem('opus:currentModule');
      const storedModule = (stored === 'clean' || stored === 'maintenance') ? stored : null;
      
      // Validar se o módulo salvo é permitido
      if (storedModule && allowedModules.length > 0 && canAccessModule(storedModule)) {
        console.log(`[MODULE] Inicializando com módulo salvo: ${storedModule}`);
        setCurrentModule(storedModule);
      } else {
        console.log(`[MODULE] Inicializando com módulo padrão: ${safeDefaultModule}`);
        setCurrentModule(safeDefaultModule);
      }
    }
  }, [isLoading, allowedModules, currentModule, canAccessModule, defaultModule]);

  // Sincronizar módulo quando o cliente mudar
  useEffect(() => {
    if (!activeClient || !currentModule) return;
    
    const clientModules = activeClient.modules || [];
    
    // Se o cliente só tem um módulo e é diferente do atual, trocar automaticamente
    if (clientModules.length === 1) {
      const clientModule = clientModules[0] as ModuleType;
      
      // Verificar se o usuário pode acessar esse módulo e se é diferente do atual
      if (canAccessModule(clientModule) && clientModule !== currentModule) {
        console.log(`[MODULE] Cliente "${activeClient.name}" possui apenas módulo "${clientModule}", trocando automaticamente...`);
        setCurrentModule(clientModule);
        
        // Redirecionar para a tela inicial
        console.log(`[MODULE] Redirecionando para tela inicial do módulo "${clientModule}"...`);
        setLocation('/');
      }
    }
    // Se o cliente tem múltiplos módulos mas o módulo atual não é suportado pelo cliente
    else if (clientModules.length > 1 && !clientModules.includes(currentModule)) {
      // Trocar para o primeiro módulo do cliente que o usuário pode acessar
      const validModule = clientModules.find(m => canAccessModule(m as ModuleType));
      if (validModule) {
        console.log(`[MODULE] Módulo atual não suportado pelo cliente, trocando para "${validModule}"...`);
        setCurrentModule(validModule as ModuleType);
        
        // Redirecionar para a tela inicial
        console.log(`[MODULE] Redirecionando para tela inicial do módulo "${validModule}"...`);
        setLocation('/');
      }
    }
  }, [activeClient, currentModule, canAccessModule, setLocation]);

  useEffect(() => {
    if (currentModule) {
      localStorage.setItem('opus:currentModule', currentModule);
      
      document.documentElement.setAttribute('data-module', currentModule);
      
      document.documentElement.style.setProperty('--module-primary', moduleConfig.primaryColor);
      document.documentElement.style.setProperty('--module-secondary', moduleConfig.secondaryColor);
      document.documentElement.style.setProperty('--module-accent', moduleConfig.accentColor);
    }
  }, [currentModule, moduleConfig]);

  const setModule = (module: ModuleType) => {
    // Validar se o usuário pode acessar o módulo antes de trocar
    if (canAccessModule(module)) {
      setCurrentModule(module);
      
      // Invalidar cache de dados dependentes de módulo
      queryClient.invalidateQueries({ 
        predicate: (query) => {
          const key = query.queryKey;
          // Invalidar queries que contêm "service-types", "service-categories", "dashboard-goals", etc
          return key.some(part => 
            typeof part === 'string' && (
              part.includes('service-types') || 
              part.includes('service-categories') ||
              part.includes('dashboard-goals')
            )
          );
        }
      });
      
      // Verificar se o cliente atual possui o módulo selecionado
      const currentClientHasModule = activeClient?.modules?.includes(module);
      
      // Só trocar de cliente se o cliente atual NÃO possuir o módulo
      if (!currentClientHasModule && customers && customers.length > 0) {
        const firstClientWithModule = customers.find(
          customer => customer.isActive && customer.modules?.includes(module)
        );
        
        if (firstClientWithModule) {
          console.log(`[MODULE] Cliente atual não possui módulo "${module}", trocando para: ${firstClientWithModule.name}`);
          setActiveClientId(firstClientWithModule.id);
          setLocation('/');
        }
      } else if (currentClientHasModule) {
        console.log(`[MODULE] Cliente atual "${activeClient?.name}" possui módulo "${module}", mantendo cliente ativo`);
      }
    } else {
      console.warn(`[MODULE] Tentativa de acesso negada ao módulo: ${module}`);
      // Se tentou acessar módulo não autorizado, forçar defaultModule
      setCurrentModule(defaultModule);
    }
  };

  const getModuleRoute = (path: string) => {
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    return `/${currentModule}${cleanPath}`;
  };

  // Se ainda está carregando, não renderizar nada
  if (isLoading || currentModule === null) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    );
  }

  return (
    <ModuleContext.Provider
      value={{
        currentModule,
        moduleConfig,
        setModule,
        getModuleRoute,
        allowedModules,
        canAccessModule,
        hasMultipleModules,
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
