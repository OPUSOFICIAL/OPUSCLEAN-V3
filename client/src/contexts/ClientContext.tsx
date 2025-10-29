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
  
  // OPUS CLEAN é sempre a empresa prestadora (ID fixo)
  const OPUS_COMPANY_ID = "company-opus-default";

  // Se o usuário é customer_user, ele só vê seu próprio cliente
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;

  // Buscar todos os clientes da OPUS (apenas para admin/opus users)
  const { data: customers = [], isLoading: isLoadingCustomers } = useQuery({
    queryKey: ["/api/companies", OPUS_COMPANY_ID, "customers"],
    enabled: !isCustomerUser, // Só buscar se não for customer_user
  });

  // Buscar cliente ativo específico  
  const { data: activeClient } = useQuery({
    queryKey: ["/api/customers", activeClientId],
    enabled: !!activeClientId,
  });

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
    if (!isCustomerUser && !activeClientId && (customers as any[]).length > 0) {
      setActiveClientId((customers as any[])[0].id);
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