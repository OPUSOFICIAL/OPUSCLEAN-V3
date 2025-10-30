import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/hooks/useAuth';

interface Customer {
  id: string;
  name: string;
  isActive: boolean;
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
  const [activeClientId, setActiveClientId] = useState<string>("");
  const { user } = useAuth();
  
  // Usar o companyId do usuário logado ao invés de um valor fixo
  const companyId = user?.companyId || "company-opus-default";

  // Se o usuário é customer_user, ele só vê seu próprio cliente
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;

  // Buscar todos os clientes da empresa do usuário (apenas para admin/opus users)
  const { data: allCustomers = [], isLoading: isLoadingCustomers } = useQuery({
    queryKey: ["/api/companies", companyId, "customers"],
    enabled: !isCustomerUser && !!companyId, // Só buscar se não for customer_user e tiver companyId
  });

  // Filtrar apenas clientes ativos
  const customers = (allCustomers as Customer[]).filter(customer => customer.isActive);

  // Buscar cliente ativo específico  
  const { data: activeClient } = useQuery({
    queryKey: ["/api/customers", activeClientId],
    enabled: !!activeClientId,
  });

  // Resetar activeClientId quando o companyId mudar (quando user loga)
  useEffect(() => {
    if (companyId && !isCustomerUser) {
      setActiveClientId("");
    }
  }, [companyId]);

  // COMBINADO: Definir activeClientId corretamente baseado no tipo de usuário
  useEffect(() => {
    // Se é customer_user, SEMPRE usar o customerId dele (PRIORIDADE)
    if (isCustomerUser && userCustomerId) {
      if (activeClientId !== userCustomerId) {
        setActiveClientId(userCustomerId);
      }
      return; // Não executar lógica de admin
    }
    
    // Se é admin/opus_user e não tem cliente selecionado, selecionar o primeiro
    if (!isCustomerUser && !activeClientId && customers.length > 0) {
      setActiveClientId(customers[0].id);
    }
  }, [isCustomerUser, userCustomerId, activeClientId, customers]);

  // Para customer_user, isLoading só é false quando activeClientId está definido
  const isLoading = isCustomerUser 
    ? !activeClientId 
    : isLoadingCustomers;

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