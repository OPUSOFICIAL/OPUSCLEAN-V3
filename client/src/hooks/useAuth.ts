import { useState, useEffect } from 'react';

export interface User {
  id: string;
  companyId: string;
  customerId?: string; // Para customer_user, vincula com cliente
  username: string;
  email: string;
  name: string;
  role: 'admin' | 'gestor_cliente' | 'supervisor_site' | 'operador' | 'auditor';
  userType?: 'opus_user' | 'customer_user';
  isActive: boolean;
}

// Funções de permissão baseadas no role
export function isAdmin(user: User | null): boolean {
  return user?.role === 'admin';
}

export function canManageClients(user: User | null): boolean {
  return user?.role === 'admin'; // Apenas admin pode gerenciar clientes
}

export function canViewAllCompanies(user: User | null): boolean {
  return user?.role === 'admin'; // Apenas admin vê todos os clientes
}

export function canManageUsers(user: User | null): boolean {
  return user?.role === 'admin' || user?.role === 'gestor_cliente';
}

export function canOnlyViewOwnWorkOrders(user: User | null): boolean {
  return user?.role === 'operador';
}

export function canManageWorkOrders(user: User | null): boolean {
  return user?.role === 'admin' || 
         user?.role === 'gestor_cliente' || 
         user?.role === 'supervisor_site';
}

export function canDeleteWorkOrders(user: User | null): boolean {
  return user?.role === 'admin'; // Apenas admin pode excluir OS
}

export function canViewReports(user: User | null): boolean {
  return user?.role === 'admin' || 
         user?.role === 'gestor_cliente' || 
         user?.role === 'auditor';
}

export function getAuthState() {
  try {
    const authStr = localStorage.getItem('acelera_auth');
    if (!authStr) {
      return { isAuthenticated: false, user: null };
    }
    
    const authData = JSON.parse(authStr);
    return { isAuthenticated: !!authData.user, user: authData.user };
  } catch (error) {
    console.error('Erro ao ler estado de autenticação:', error);
    return { isAuthenticated: false, user: null };
  }
}

export function useAuth() {
  const [authState, setAuthState] = useState(() => getAuthState());

  useEffect(() => {
    const checkAuth = () => {
      const newState = getAuthState();
      if (newState.isAuthenticated !== authState.isAuthenticated ||
          newState.user?.id !== authState.user?.id) {
        setAuthState(newState);
      }
    };

    // Verificar mudanças a cada 5 segundos
    const interval = setInterval(checkAuth, 5000);
    
    return () => clearInterval(interval);
  }, [authState]);

  return {
    user: authState.user,
    isAuthenticated: authState.isAuthenticated,
    isAdmin: isAdmin(authState.user),
    canManageClients: canManageClients(authState.user),
    canViewAllCompanies: canViewAllCompanies(authState.user),
    canManageUsers: canManageUsers(authState.user),
    canOnlyViewOwnWorkOrders: canOnlyViewOwnWorkOrders(authState.user),
    canManageWorkOrders: canManageWorkOrders(authState.user),
    canDeleteWorkOrders: canDeleteWorkOrders(authState.user),
    canViewReports: canViewReports(authState.user),
  };
}