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
  // IMPORTANTE: activeClientId é apenas EM MEMÓRIA - não usar localStorage
  const [activeClientId, setActiveClientId] = useState<string>("");
  const [subdomainDetected, setSubdomainDetected] = useState(false);
  const { user } = useAuth();
  
  // Usar o companyId do usuário logado ao invés de um valor fixo
  const companyId = user?.companyId || "company-opus-default";

  // Se o usuário é customer_user, ele só vê seu próprio cliente
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;
  
  // Verificar se o usuário é admin (role admin ou gestor_cliente)
  const isAdmin = user?.role === 'admin' || user?.role === 'gestor_cliente';

  // Detectar subdomínio do hostname (SEM query params)
  const detectSubdomain = () => {
    // MODO NORMAL: Detectar apenas do hostname
    // NÃO usar query params para teste - branding é carregado do activeClient
    const hostname = window.location.hostname;
    const parts = hostname.split('.');
    // Se houver pelo menos 3 partes (subdominio.dominio.com) e não for www
    if (parts.length >= 3 && parts[0] !== 'www') {
      return parts[0];
    }
    return null;
  };

  // Buscar cliente por subdomínio (executa apenas uma vez ao carregar)
  // NOTA: Isso é para páginas públicas antes do login
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
          // NÃO salvar no localStorage - manter apenas em memória
        } else {
          console.log(`[CLIENT CONTEXT] Subdomínio ${subdomain} não encontrado`);
        }
      } catch (error) {
        console.error('[CLIENT CONTEXT] Erro ao buscar cliente por subdomínio:', error);
      }
    };

    fetchCustomerBySubdomain();
  }, []); // Executa apenas uma vez ao montar

  // Buscar clientes do usuário (funciona para admin e opus_user não-admin)
  // Usa /api/auth/my-customers que busca via userAllowedCustomers
  // IMPORTANTE: Permite customer_user admins também (role === 'admin')
  const { data: myCustomers = [], isLoading: isLoadingMyCustomers, isError: myCustomersError, error: myCustomersErrorDetail, refetch: refetchMyCustomers } = useQuery({
    queryKey: ["/api/auth/my-customers"],  // Simples - queryKey é apenas para cache, não para URL
    enabled: (!isCustomerUser || (isCustomerUser && isAdmin)) && !!user?.id,
    staleTime: 0,  // Não usar cache
    gcTime: 0,  // Desabilitar garbage collection também
    refetchOnWindowFocus: true,  // Refetch ao focar na janela
  });

  // Force refetch quando user muda (para garantir dados fresh)
  useEffect(() => {
    if ((!isCustomerUser || (isCustomerUser && isAdmin)) && user?.id) {
      console.log(`[CLIENT CONTEXT] 🔄 Forcing refetch myCustomers for:`, user.id, `isAdmin: ${isAdmin}`);
      refetchMyCustomers();
    }
  }, [user?.id, isCustomerUser, isAdmin, refetchMyCustomers]);

  // Debug log - MUITO VERBOSE
  useEffect(() => {
    if (!isCustomerUser) {
      console.log(`[CLIENT CONTEXT] 🔍 Query estado:`, {
        isCustomerUser,
        userId: user?.id,
        enabled: !isCustomerUser && !!user?.id,
        isLoading: isLoadingMyCustomers,
        isError: myCustomersError,
        dataLength: (myCustomers as any[])?.length || 0,
        data: myCustomers
      });
    }
  }, [myCustomers, isLoadingMyCustomers, myCustomersError, user?.id, isCustomerUser]);

  // Buscar clientes permitidos para usuários do sistema não-admin (fallback)
  const { data: allowedCustomers = [], isLoading: isLoadingAllowedCustomers } = useQuery({
    queryKey: ["/api/system-users", user?.id, "allowed-customers"],
    enabled: !isCustomerUser && !isAdmin && !!user?.id && (myCustomers as any[]).length === 0,
  });

  // Filtrar clientes baseado em permissões
  let customers: Customer[];
  if (isCustomerUser && !isAdmin) {
    // customer_user não-admin não vê lista de clientes
    customers = [];
  } else if (isAdmin) {
    // Admin (opus_user ou customer_user) vê seus clientes vinculados (via userAllowedCustomers)
    customers = (myCustomers as Customer[]);
    console.log(`[CLIENT CONTEXT] Admin customers received:`, customers.length, customers.map(c => ({ id: c.id, name: c.name })));
  } else {
    // Usuários não-admin veem apenas clientes permitidos e ativos
    const myCustomersArray = (myCustomers as unknown as Customer[]) || [];
    const allowedCustomersArray = (allowedCustomers as unknown as Customer[]) || [];
    const customersToUse = myCustomersArray.length > 0 ? myCustomersArray : allowedCustomersArray;
    const allowedCustomerIds = new Set(customersToUse.map(c => c.id));
    customers = customersToUse.filter(customer => allowedCustomerIds.has(customer.id));
  }

  // Buscar cliente ativo específico
  // Para customer_user: usa /api/auth/my-customer (sem permissão requerida)
  // Para opus_user: usa /api/customers/:id (requer permissão customers_view)
  const { data: activeClient } = useQuery({
    queryKey: isCustomerUser ? ["/api/auth/my-customer"] : ["/api/customers", activeClientId],
    enabled: isCustomerUser ? true : !!activeClientId,
  });

  // COMBINADO: Definir activeClientId corretamente baseado no tipo de usuário
  // IMPORTANTE: Usar apenas memória, sem localStorage
  useEffect(() => {
    // Se é customer_user, SEMPRE usar o customerId dele (PRIORIDADE)
    if (isCustomerUser && userCustomerId) {
      if (activeClientId !== userCustomerId) {
        console.log(`[CLIENT CONTEXT] 👤 Customer user - definindo activeClientId:`, userCustomerId);
        setActiveClientId(userCustomerId);
      }
      return; // Não executar lógica de admin
    }
    
    // Se é admin/opus_user e não tem cliente selecionado, usar primeiro da lista
    if (!isCustomerUser && !activeClientId && customers.length > 0) {
      console.log(`[CLIENT CONTEXT] 📋 Admin/opus_user - definindo primeiro cliente:`, customers[0].id);
      setActiveClientId(customers[0].id);
    }
  }, [isCustomerUser, userCustomerId, activeClientId, customers]);

  // Para customer_user, isLoading só é false quando activeClientId está definido
  // Para opus_user não-admin, considerar também o loading dos clientes permitidos
  const isLoading = isCustomerUser 
    ? !activeClientId 
    : (isLoadingMyCustomers || (!isAdmin && isLoadingAllowedCustomers));

  // Log quando activeClientId muda (sem sincronizar com localStorage)
  useEffect(() => {
    if (activeClientId) {
      console.log(`[CLIENT CONTEXT] ✅ Cliente ativo atualizado (em memória): ${activeClientId}`);
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
