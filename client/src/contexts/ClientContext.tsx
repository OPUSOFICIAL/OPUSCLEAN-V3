import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/hooks/useAuth';

interface Customer {
  id: string;
  name: string;
  isActive: boolean;
  modules: string[];
  loginLogo?: string | null;
  sidebarLogo?: string | null;
  sidebarLogoCollapsed?: string | null;
  moduleColors?: any;
}

interface ClientContextType {
  activeClientId: string;
  setActiveClientId: (clientId: string) => void;
  activeClient: Customer | null;
  customers: Customer[];
  isLoading: boolean;
}

const ClientContext = createContext<ClientContextType | undefined>(undefined);

interface ClientProviderProps {
  children: ReactNode;
}

export function ClientProvider({ children }: ClientProviderProps) {
  // Inicializar com valor do localStorage se existir
  const [activeClientId, setActiveClientId] = useState<string>(() => {
    return localStorage.getItem('opus:activeClientId') || "";
  });
  const [subdomainDetected, setSubdomainDetected] = useState(false);
  const { user } = useAuth();
  
  // Usar o companyId do usuário logado ao invés de um valor fixo
  const companyId = user?.companyId || "company-opus-default";

  // Se o usuário é customer_user, ele só vê seu próprio cliente
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;
  
  // Verificar se o usuário é admin (role admin ou gestor_cliente)
  const isAdmin = user?.role === 'admin' || user?.role === 'gestor_cliente';

  // Detectar subdomínio e buscar cliente automaticamente
  const detectSubdomain = () => {
    // MODO DE TESTE: Permitir simular subdomínio via query string
    const urlParams = new URLSearchParams(window.location.search);
    const testSubdomain = urlParams.get('test-subdomain');
    if (testSubdomain) {
      console.log(`[CLIENT CONTEXT] 🧪 MODO DE TESTE: Simulando subdomínio "${testSubdomain}"`);
      return testSubdomain;
    }

    // MODO NORMAL: Detectar do hostname
    const hostname = window.location.hostname;
    
    // CASO ESPECIAL: Localhost / IP
    // localhost, 127.0.0.1, 0.0.0.0, etc → sem subdomain
    if (hostname === 'localhost' || hostname.match(/^\d+\.\d+\.\d+\.\d+$/)) {
      return null;
    }
    
    // CASO ESPECIAL: Replit
    // URLs Replit: <instance-id>.janeway.replit.dev ou tenant.<instance-id>.janeway.replit.dev
    // Instance ID tem padrão: <uuid>-00-<hash>
    if (hostname.endsWith('.replit.dev')) {
      const parts = hostname.split('.');
      // Verificar se temos um tenant subdomain ANTES do instance ID
      // O instance ID sempre contém '-00-'
      const instanceIdIndex = parts.findIndex(part => part.includes('-00-'));
      
      if (instanceIdIndex > 0) {
        // Há algo antes do instance ID - é o tenant subdomain
        return parts[0];
      } else {
        // Só temos instance ID - sem tenant subdomain
        return null;
      }
    }
    
    // CASO GERAL: Domínios customizados
    // Detectar se há subdomínio (3+ partes: subdominio.dominio.com)
    const parts = hostname.split('.');
    if (parts.length >= 3 && parts[0] !== 'www') {
      return parts[0];
    }
    return null;
  };

  // Buscar cliente por subdomínio (executa apenas uma vez ao carregar)
  useEffect(() => {
    const fetchCustomerBySubdomain = async () => {
      const subdomain = detectSubdomain();
      
      if (!subdomain || subdomainDetected) {
        return; // Não há subdomínio ou já foi detectado
      }

      try {
        const response = await fetch(`/api/public/customer-by-subdomain/${subdomain}`);
        if (response.ok) {
          const customer = await response.json();
          console.log(`[CLIENT CONTEXT] Subdomínio detectado: ${subdomain}, cliente: ${customer.name}`);
          setActiveClientId(customer.id);
          setSubdomainDetected(true);
          // Salvar no localStorage para manter mesmo depois
          localStorage.setItem('opus:activeClientId', customer.id);
        } else {
          console.log(`[CLIENT CONTEXT] Subdomínio ${subdomain} não encontrado`);
        }
      } catch (error) {
        console.error('[CLIENT CONTEXT] Erro ao buscar cliente por subdomínio:', error);
      }
    };

    fetchCustomerBySubdomain();
  }, []); // Executa apenas uma vez ao montar

  // Buscar todos os clientes da empresa do usuário (apenas para admin/opus users)
  const { data: allCustomers = [], isLoading: isLoadingCustomers } = useQuery({
    queryKey: ["/api/companies", companyId, "customers"],
    enabled: !isCustomerUser && !!companyId, // Só buscar se não for customer_user e tiver companyId
  });

  // Buscar clientes permitidos para usuários do sistema não-admin
  const { data: allowedCustomers = [], isLoading: isLoadingAllowedCustomers } = useQuery({
    queryKey: ["/api/system-users", user?.id, "allowed-customers"],
    enabled: !isCustomerUser && !isAdmin && !!user?.id,
  });

  // Filtrar clientes baseado em permissões
  let customers: Customer[];
  if (isCustomerUser) {
    // customer_user não usa essa lista
    customers = [];
  } else if (isAdmin) {
    // Admin vê todos os clientes ativos
    customers = (allCustomers as Customer[]).filter(customer => customer.isActive);
  } else {
    // Usuários não-admin veem apenas clientes permitidos e ativos
    const allowedCustomerIds = new Set((allowedCustomers as Customer[]).map(c => c.id));
    customers = (allCustomers as Customer[])
      .filter(customer => customer.isActive && allowedCustomerIds.has(customer.id));
  }

  // Buscar cliente ativo específico  
  const { data: activeClient } = useQuery({
    queryKey: ["/api/customers", activeClientId],
    enabled: !!activeClientId,
  });

  // Resetar activeClientId quando o companyId mudar (quando user loga)
  // SOMENTE se não houver um cliente válido salvo no localStorage
  useEffect(() => {
    if (companyId && !isCustomerUser) {
      const savedClientId = localStorage.getItem('opus:activeClientId');
      // Só resetar se não houver cliente salvo no localStorage
      if (!savedClientId) {
        setActiveClientId("");
      }
    }
  }, [companyId, isCustomerUser]);

  // COMBINADO: Definir activeClientId corretamente baseado no tipo de usuário
  useEffect(() => {
    // Se é customer_user, SEMPRE usar o customerId dele (PRIORIDADE)
    if (isCustomerUser && userCustomerId) {
      if (activeClientId !== userCustomerId) {
        setActiveClientId(userCustomerId);
      }
      return; // Não executar lógica de admin
    }
    
    // Se é admin/opus_user e não tem cliente selecionado
    if (!isCustomerUser && !activeClientId && customers.length > 0) {
      // Verificar se o cliente do localStorage é válido antes de sobrescrever
      const savedClientId = localStorage.getItem('opus:activeClientId');
      const savedClientExists = savedClientId && customers.some(c => c.id === savedClientId);
      
      if (savedClientExists) {
        // Se existe um cliente válido salvo, usar ele
        setActiveClientId(savedClientId);
      } else {
        // Caso contrário, usar o primeiro da lista
        setActiveClientId(customers[0].id);
      }
    }
  }, [isCustomerUser, userCustomerId, activeClientId, customers]);

  // Para customer_user, isLoading só é false quando activeClientId está definido
  // Para opus_user não-admin, considerar também o loading dos clientes permitidos
  const isLoading = isCustomerUser 
    ? !activeClientId 
    : (isLoadingCustomers || (!isAdmin && isLoadingAllowedCustomers));

  // Sincronizar activeClientId com localStorage
  useEffect(() => {
    if (activeClientId) {
      localStorage.setItem('opus:activeClientId', activeClientId);
      console.log(`[CLIENT CONTEXT] Cliente ativo atualizado: ${activeClientId}`);
    }
  }, [activeClientId]);

  const value: ClientContextType = {
    activeClientId,
    setActiveClientId,
    activeClient: activeClient as Customer | null,
    customers: customers as Customer[],
    isLoading,
  };

  return (
    <ClientContext.Provider value={value}>
      {children}
    </ClientContext.Provider>
  );
}

export function useClient() {
  const context = useContext(ClientContext);
  if (context === undefined) {
    throw new Error('useClient must be used within a ClientProvider');
  }
  return context;
}