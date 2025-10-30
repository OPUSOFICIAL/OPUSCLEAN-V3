import { Request, Response, NextFunction } from 'express';
import { storage } from '../storage';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'kJsXXrXanldoNcZJG/iHeTEI8WdMch4PFWNIao1llTU=';

export type UserRole = 'admin' | 'gestor_cliente' | 'supervisor_site' | 'operador' | 'auditor';

export interface SessionUser {
  id: string;
  companyId: string;
  customerId?: string;
  username: string;
  email: string;
  name: string;
  role: UserRole;
  isActive: boolean;
}

declare global {
  namespace Express {
    interface Request {
      user?: SessionUser;
    }
  }
}

/**
 * Determina o role efetivo baseado nas permissões dos custom roles
 */
function getEffectiveRole(baseRole: UserRole, permissions: string[]): UserRole {
  // Se já tem role de admin na tabela users, manter
  if (baseRole === 'admin') {
    return 'admin';
  }
  
  // Mapear permissões para roles
  if (permissions.includes('customers_create') || permissions.includes('customers_edit') || permissions.includes('customers_delete')) {
    return 'admin';
  }
  
  if (permissions.includes('users_create') || permissions.includes('users_edit') || permissions.includes('users_delete')) {
    return 'gestor_cliente';
  }
  
  if (permissions.includes('workorders_create') || permissions.includes('workorders_edit') || permissions.includes('sites_create')) {
    return 'supervisor_site';
  }
  
  if (permissions.includes('audit_logs_view') || permissions.includes('reports_view')) {
    return 'auditor';
  }
  
  // Default: operador
  return baseRole;
}

/**
 * Helper function to extract user from Authorization header
 */
async function getUserFromToken(req: Request): Promise<SessionUser | null> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return null;
    }
    
    const token = authHeader.replace('Bearer ', '');
    
    // Try JWT first
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as any;
      const user = await storage.getUser(decoded.userId);
      if (!user || !user.isActive) {
        return null;
      }
      
      // Buscar custom roles e suas permissões do usuário
      const userRoles = await storage.getUserRoles(user.id);
      const permissions: string[] = [];
      
      for (const roleAssignment of userRoles) {
        const rolePerms = await storage.getRolePermissions(roleAssignment.roleId);
        permissions.push(...rolePerms.map((p: any) => p.permission).filter((p: string | null) => p !== null));
      }
      
      // Determinar role efetivo baseado nas permissões
      const effectiveRole = getEffectiveRole(user.role as UserRole, permissions);
      
      return {
        id: user.id,
        companyId: user.companyId || '',
        customerId: user.customerId || undefined,
        username: user.username,
        email: user.email,
        name: user.name,
        role: effectiveRole,
        isActive: user.isActive
      };
    } catch (jwtError) {
      // Fallback to old token format for backwards compatibility
      const parts = token.split('_');
      if (parts.length >= 2 && parts[0] === 'token') {
        const userId = parts[1];
        const user = await storage.getUser(userId);
        if (!user || !user.isActive) {
          return null;
        }
        
        // Buscar custom roles e suas permissões do usuário
        const userRoles = await storage.getUserRoles(user.id);
        const permissions: string[] = [];
        
        for (const roleAssignment of userRoles) {
          const rolePerms = await storage.getRolePermissions(roleAssignment.roleId);
          permissions.push(...rolePerms.map((p: any) => p.permission).filter((p: string | null) => p !== null));
        }
        
        // Determinar role efetivo baseado nas permissões
        const effectiveRole = getEffectiveRole(user.role as UserRole, permissions);
        
        return {
          id: user.id,
          companyId: user.companyId || '',
          customerId: user.customerId || undefined,
          username: user.username,
          email: user.email,
          name: user.name,
          role: effectiveRole,
          isActive: user.isActive
        };
      }
      return null;
    }
  } catch (error) {
    console.error('Error extracting user from token:', error);
    return null;
  }
}

/**
 * Middleware para verificar se o usuário está autenticado
 */
export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const user = await getUserFromToken(req);
  
  if (!user) {
    return res.status(401).json({ 
      error: 'Não autenticado',
      message: 'Você precisa estar logado para acessar este recurso.' 
    });
  }
  
  if (!user.isActive) {
    return res.status(403).json({ 
      error: 'Conta desativada',
      message: 'Sua conta está desativada. Entre em contato com o administrador.' 
    });
  }
  
  // Attach user to request
  req.user = user;
  next();
}

/**
 * Middleware para verificar se o usuário tem um dos roles permitidos
 */
export function requireRole(allowedRoles: UserRole[]) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const user = await getUserFromToken(req);
    
    if (!user) {
      return res.status(401).json({ 
        error: 'Não autenticado',
        message: 'Você precisa estar logado para acessar este recurso.' 
      });
    }
    
    if (!allowedRoles.includes(user.role)) {
      console.warn(`[ACCESS DENIED] User ${user.id} (${user.role}) tentou acessar recurso que requer: ${allowedRoles.join(', ')}`);
      return res.status(403).json({ 
        error: 'Acesso negado',
        message: `Apenas usuários com as seguintes funções podem acessar: ${allowedRoles.join(', ')}.`,
        requiredRoles: allowedRoles,
        userRole: user.role
      });
    }
    
    // Attach user to request
    req.user = user;
    next();
  };
}

/**
 * Middleware para verificar se o usuário é admin
 */
export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  return requireRole(['admin'])(req, res, next);
}

/**
 * Middleware para verificar se o usuário pode gerenciar clientes (apenas admin)
 */
export function requireManageClients(req: Request, res: Response, next: NextFunction) {
  return requireRole(['admin'])(req, res, next);
}

/**
 * Middleware para verificar se o usuário pode gerenciar usuários (admin ou gestor_cliente)
 */
export function requireManageUsers(req: Request, res: Response, next: NextFunction) {
  return requireRole(['admin', 'gestor_cliente'])(req, res, next);
}

/**
 * Middleware para verificar se o usuário pode gerenciar work orders
 * (admin, gestor_cliente ou supervisor_site)
 */
export function requireManageWorkOrders(req: Request, res: Response, next: NextFunction) {
  return requireRole(['admin', 'gestor_cliente', 'supervisor_site'])(req, res, next);
}

/**
 * Middleware para verificar se o usuário pode visualizar relatórios
 * (admin, gestor_cliente ou auditor)
 */
export function requireViewReports(req: Request, res: Response, next: NextFunction) {
  return requireRole(['admin', 'gestor_cliente', 'auditor'])(req, res, next);
}

/**
 * Middleware para validar que o usuário só acessa dados do seu próprio cliente
 * (exceto admin que pode acessar tudo)
 */
export async function requireOwnCustomer(req: Request, res: Response, next: NextFunction) {
  const user = await getUserFromToken(req);
  
  if (!user) {
    return res.status(401).json({ 
      error: 'Não autenticado' 
    });
  }
  
  // Admin pode acessar qualquer cliente
  if (user.role === 'admin') {
    req.user = user;
    return next();
  }
  
  // Pegar customerId do parâmetro da rota ou do body
  const requestedCustomerId = req.params.customerId || req.body.customerId;
  
  if (!requestedCustomerId) {
    return res.status(400).json({ 
      error: 'Cliente não especificado',
      message: 'É necessário especificar o ID do cliente.' 
    });
  }
  
  // Verificar se o usuário pertence ao cliente solicitado
  if (user.customerId !== requestedCustomerId) {
    console.warn(`[ACCESS DENIED] User ${user.id} tentou acessar dados do cliente ${requestedCustomerId} mas pertence a ${user.customerId}`);
    return res.status(403).json({ 
      error: 'Acesso negado',
      message: 'Você não tem permissão para acessar dados deste cliente.',
      userCustomerId: user.customerId,
      requestedCustomerId
    });
  }
  
  req.user = user;
  next();
}

/**
 * Middleware para validar que o usuário só acessa suas próprias work orders
 * (usado para operadores que só podem ver suas próprias OSs)
 */
export async function requireOwnWorkOrders(req: Request, res: Response, next: NextFunction) {
  const user = await getUserFromToken(req);
  
  if (!user) {
    return res.status(401).json({ 
      error: 'Não autenticado' 
    });
  }
  
  // Admin, gestor e supervisor podem ver todas as OSs
  if (['admin', 'gestor_cliente', 'supervisor_site'].includes(user.role)) {
    req.user = user;
    return next();
  }
  
  // Operadores só podem ver suas próprias OSs
  // Isso será validado na query do banco de dados
  req.user = user;
  next();
}

/**
 * Função helper para logar tentativas de acesso negado
 * (pode ser expandida para salvar em audit_logs)
 */
export function logAccessDenied(
  userId: string, 
  resource: string, 
  action: string, 
  reason: string
) {
  console.warn(`[ACCESS DENIED] User ${userId} tentou ${action} em ${resource}. Motivo: ${reason}`);
  // TODO: Salvar em audit_logs no banco de dados
}
