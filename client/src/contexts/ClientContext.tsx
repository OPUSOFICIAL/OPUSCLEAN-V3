import { createContext, useContext, useState, useEffect, useRef, ReactNode } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/hooks/useAuth';
import { detectSubdomain, isValidUUID, isValidSubdomain } from '@/lib/subdomain-detector';

interface Customer {
  id: string;
  name: string;
  isActive: boolean;
  modules: string[];
  subdomain?: string | null;
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
  clientSource: 'query_param' | 'subdomain' | 'user_login' | 'none';
}

const ClientContext = createContext<ClientContextType | undefined>(undefined);

interface ClientProviderProps {
  children: ReactNode;
}

export function ClientProvider({ children }: ClientProviderProps) {
  // IMPORTANTE: activeClientId é mantido apenas em MEMÓRIA (useState)
  const [activeClientId, setActiveClientId] = useState<string>("");
  const [clientSource, setClientSource] = useState<'query_param' | 'subdomain' | 'user_login' | 'none'>('none');
  const [queryDetected, setQueryDetected] = useState(false);
  const queryLockRef = useRef(false); // Previne override do query param pelo login
  
  const { user } = useAuth();
  
  // Usar o companyId do usuário logado ao invés de um valor fixo
  const companyId = user?.companyId || "company-opus-default";

  // Se o usuário é customer_user, ele só vê seu próprio cliente
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;
  
  // Verificar se o usuário é admin (role admin ou gestor_cliente)
  const isAdmin = user?.role === 'admin' || user?.role === 'gestor_cliente';

  // PRIORIDADE 1: Detectar cliente via query param ou subdomínio (executa uma vez)
  useEffect(() => {
    const fetchCustomerFromDetection = async () => {
      if (queryDetected) return; // Já foi detectado
      
      const detection = detectSubdomain();
      console.log('[CLIENT CONTEXT] 🔍 Detecção:', detection);
      
      // Se detectou via query param com ID
      if (detection.source === 'query_param_id' && detection.customerId) {
        if (!isValidUUID(detection.customerId)) {
          console.warn('[CLIENT CONTEXT] ⚠️ customerId inválido:', detection.customerId);
          setQueryDetected(true);
          return;
        }
        
        try {
          // Buscar cliente por ID (API pública para pre-login)
          const response = await fetch(`/api/public/customer-by-id/${detection.customerId}`);
          if (response.ok) {
            const customer = await response.json();
            console.log('[CLIENT CONTEXT] ✅ Cliente encontrado via query param ID:', customer.name);
            setActiveClientId(customer.id);
            setClientSource('query_param');
            queryLockRef.current = true; // Lock para não ser sobrescrito pelo login
          } else {
            console.warn('[CLIENT CONTEXT] ⚠️ Cliente não encontrado para ID:', detection.customerId);
          }
        } catch (error) {
          console.error('[CLIENT CONTEXT] Erro ao buscar cliente por ID:', error);
        }
        setQueryDetected(true);
        return;
      }
      
      // Se detectou via query param com slug (?cliente=)
      if (detection.source === 'query_param_slug' && detection.clienteSlug) {
        if (!isValidSubdomain(detection.clienteSlug)) {
          console.warn('[CLIENT CONTEXT] ⚠️ cliente slug inválido:', detection.clienteSlug);
          setQueryDetected(true);
          return;
        }
        
        try {
          const response = await fetch(`/api/public/customer-by-subdomain/${detection.clienteSlug}`);
          if (response.ok) {
            const customer = await response.json();
            console.log('[CLIENT CONTEXT] ✅ Cliente encontrado via query param slug:', customer.name);
            setActiveClientId(customer.id);
            setClientSource('query_param');
            queryLockRef.current = true;
          } else {
            console.warn('[CLIENT CONTEXT] ⚠️ Cliente não encontrado para slug:', detection.clienteSlug);
          }
        } catch (error) {
          console.error('[CLIENT CONTEXT] Erro ao buscar cliente por slug:', error);
        }
        setQueryDetected(true);
        return;
      }
      
      // Se detectou via subdomínio
      if (detection.source === 'subdomain' && detection.subdomain) {
        try {
          const response = await fetch(`/api/public/customer-by-subdomain/${detection.subdomain}`);
          if (response.ok) {
            const customer = await response.json();
            console.log('[CLIENT CONTEXT] ✅ Cliente encontrado via subdomínio:', customer.name);
            setActiveClientId(customer.id);
            setClientSource('subdomain');
            // Não lock - pode ser sobrescrito pelo login
          } else {
            console.warn('[CLIENT CONTEXT] ⚠️ Cliente não encontrado para subdomínio:', detection.subdomain);
          }
        } catch (error) {
          console.error('[CLIENT CONTEXT] Erro ao buscar cliente por subdomínio:', error);
        }
        setQueryDetected(true);
        return;
      }
      
      // Nenhuma detecção
      console.log('[CLIENT CONTEXT] ℹ️ Nenhum cliente detectado via query/subdomínio');
      setQueryDetected(true);
    };

    fetchCustomerFromDetection();
  }, []); // Executa apenas uma vez ao montar

  // Buscar clientes do usuário (funciona para admin e opus_user não-admin)
  const { data: myCustomers = [], isLoading: isLoadingMyCustomers, refetch: refetchMyCustomers } = useQuery({
    queryKey: ["/api/auth/my-customers"],
    enabled: (!isCustomerUser || (isCustomerUser && isAdmin)) && !!user?.id,
    staleTime: 0,
    gcTime: 0,
    refetchOnWindowFocus: true,
  });

  // Force refetch quando user muda
  useEffect(() => {
    if ((!isCustomerUser || (isCustomerUser && isAdmin)) && user?.id) {
      console.log(`[CLIENT CONTEXT] 🔄 Forcing refetch myCustomers for:`, user.id);
      refetchMyCustomers();
    }
  }, [user?.id, isCustomerUser, isAdmin, refetchMyCustomers]);

  // Buscar clientes permitidos para usuários do sistema não-admin (fallback)
  const { data: allowedCustomers = [], isLoading: isLoadingAllowedCustomers } = useQuery({
    queryKey: ["/api/system-users", user?.id, "allowed-customers"],
    enabled: !isCustomerUser && !isAdmin && !!user?.id && (myCustomers as any[]).length === 0,
  });

  // Filtrar clientes baseado em permissões
  let customers: Customer[];
  if (isCustomerUser && !isAdmin) {
    customers = [];
  } else if (isAdmin) {
    customers = (myCustomers as Customer[]);
    console.log(`[CLIENT CONTEXT] Admin customers received:`, customers.length, customers.map(c => ({ id: c.id, name: c.name })));
  } else {
    const myCustomersArray = (myCustomers as unknown as Customer[]) || [];
    const allowedCustomersArray = (allowedCustomers as unknown as Customer[]) || [];
    const customersToUse = myCustomersArray.length > 0 ? myCustomersArray : allowedCustomersArray;
    const allowedCustomerIds = new Set(customersToUse.map(c => c.id));
    customers = customersToUse.filter(customer => allowedCustomerIds.has(customer.id));
  }

  // Buscar cliente ativo específico
  const { data: activeClient } = useQuery({
    queryKey: isCustomerUser ? ["/api/auth/my-customer"] : ["/api/customers", activeClientId],
    enabled: isCustomerUser ? true : !!activeClientId,
  });

  // PRIORIDADE 2: Definir activeClientId baseado no usuário logado
  // MAS NÃO sobrescrever se veio de query param (queryLockRef)
  useEffect(() => {
    // Se cliente foi definido via query param, não sobrescrever
    if (queryLockRef.current) {
      console.log('[CLIENT CONTEXT] 🔒 Cliente locked via query param, não sobrescrevendo');
      return;
    }
    
    // Se é customer_user, SEMPRE usar o customerId dele
    if (isCustomerUser && userCustomerId) {
      if (activeClientId !== userCustomerId) {
        console.log(`[CLIENT CONTEXT] 👤 Customer user - definindo activeClientId:`, userCustomerId);
        setActiveClientId(userCustomerId);
        setClientSource('user_login');
      }
      return;
    }
    
    // Se é admin/opus_user e não tem cliente selecionado, usar primeiro da lista
    if (!isCustomerUser && !activeClientId && customers.length > 0) {
      console.log(`[CLIENT CONTEXT] 📋 Admin/opus_user - definindo primeiro cliente:`, customers[0].id);
      setActiveClientId(customers[0].id);
      setClientSource('user_login');
    }
  }, [isCustomerUser, userCustomerId, activeClientId, customers]);

  // Para customer_user, isLoading só é false quando activeClientId está definido
  const isLoading = isCustomerUser 
    ? !activeClientId 
    : (isLoadingMyCustomers || (!isAdmin && isLoadingAllowedCustomers));

  // Log quando activeClientId muda (em memória)
  useEffect(() => {
    if (activeClientId) {
      console.log(`[CLIENT CONTEXT] ✅ Cliente ativo em MEMÓRIA: ${activeClientId} (fonte: ${clientSource})`);
    }
  }, [activeClientId, clientSource]);

  const value: ClientContextType = {
    activeClientId,
    setActiveClientId: (id: string) => {
      // Se usuário muda manualmente, liberar o lock
      queryLockRef.current = false;
      setActiveClientId(id);
      setClientSource('user_login');
    },
    activeClient: activeClient as Customer | null,
    customers: customers as Customer[],
    isLoading,
    clientSource,
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
