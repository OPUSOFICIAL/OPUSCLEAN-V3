import { createContext, useContext, useState, useEffect, useRef, type ReactNode } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/hooks/useAuth';
import { detectSubdomain, getPersistedSubdomain, persistSubdomain } from '@/lib/subdomain-detector';

interface Customer {
  id: string;
  name: string;
  subdomain?: string | null;
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
  activeSubdomain: string | null;
  subdomainCustomer: Customer | null;
  isSubdomainLoading: boolean;
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
  const [activeSubdomain, setActiveSubdomain] = useState<string | null>(() => {
    return getPersistedSubdomain();
  });
  const [subdomainCustomer, setSubdomainCustomer] = useState<Customer | null>(null);
  const [isSubdomainLoading, setIsSubdomainLoading] = useState(true);
  const subdomainFetchedRef = useRef<string | null>(null);
  const { user } = useAuth();
  
  // Usar o companyId do usuário logado ao invés de um valor fixo
  const companyId = user?.companyId || "company-opus-default";

  // Se o usuário é customer_user, ele só vê seu próprio cliente
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;
  
  // Verificar se o usuário é admin (role admin ou gestor_cliente)
  const isAdmin = user?.role === 'admin' || user?.role === 'gestor_cliente';

  // Detect and fetch subdomain customer on mount and URL changes
  useEffect(() => {
    const fetchSubdomainCustomer = async () => {
      const detection = detectSubdomain();
      console.log('[CLIENT CONTEXT] 🔍 Subdomain detection:', detection);
      
      if (!detection.subdomain) {
        setIsSubdomainLoading(false);
        return;
      }
      
      // Skip if we already fetched this subdomain
      if (subdomainFetchedRef.current === detection.subdomain) {
        return;
      }
      
      setActiveSubdomain(detection.subdomain);
      setIsSubdomainLoading(true);

      try {
        const response = await fetch(`/api/public/customer-by-subdomain/${detection.subdomain}`);
        if (response.ok) {
          const customer = await response.json();
          console.log(`[CLIENT CONTEXT] ✅ Subdomain customer found: ${customer.name} (${customer.id})`);
          setSubdomainCustomer(customer);
          subdomainFetchedRef.current = detection.subdomain;
          
          // Persist subdomain for session continuity
          persistSubdomain(detection.subdomain);
          
          // Auto-set activeClientId if not already set
          if (!activeClientId) {
            setActiveClientId(customer.id);
            localStorage.setItem('opus:activeClientId', customer.id);
          }
        } else {
          console.log(`[CLIENT CONTEXT] ❌ Subdomain ${detection.subdomain} not found`);
          setSubdomainCustomer(null);
        }
      } catch (error) {
        console.error('[CLIENT CONTEXT] Error fetching subdomain customer:', error);
        setSubdomainCustomer(null);
      } finally {
        setIsSubdomainLoading(false);
      }
    };

    fetchSubdomainCustomer();
  }, []); // Run once on mount

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

  // COMBINADO: Definir activeClientId corretamente baseado no tipo de usuário e subdomain
  useEffect(() => {
    // Se é customer_user, SEMPRE usar o customerId dele (PRIORIDADE)
    if (isCustomerUser && userCustomerId) {
      if (activeClientId !== userCustomerId) {
        setActiveClientId(userCustomerId);
      }
      return; // Não executar lógica de admin
    }
    
    // Priority 1: If subdomain customer is loaded, use it
    if (subdomainCustomer && customers.length > 0) {
      const subdomainClientValid = customers.some(c => c.id === subdomainCustomer.id);
      if (subdomainClientValid && activeClientId !== subdomainCustomer.id) {
        console.log(`[CLIENT CONTEXT] 🎯 Auto-selecting subdomain customer: ${subdomainCustomer.name}`);
        setActiveClientId(subdomainCustomer.id);
        return;
      }
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
  }, [isCustomerUser, userCustomerId, activeClientId, customers, subdomainCustomer]);

  // Para customer_user, isLoading só é false quando activeClientId está definido
  // Para opus_user não-admin, considerar também o loading dos clientes permitidos
  const isLoading = isCustomerUser 
    ? !activeClientId 
    : (isLoadingMyCustomers || (!isAdmin && isLoadingAllowedCustomers));

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
    activeSubdomain,
    subdomainCustomer,
    isSubdomainLoading,
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