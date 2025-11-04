import { useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import opusLogo from "@assets/ChatGPT Image 8 de set. de 2025, 18_10_10_1757366528566.png";
import { 
  Building, 
  Calendar, 
  ChartBar, 
  ClipboardList, 
  Home, 
  QrCode, 
  Users, 
  LogOut,
  Fan,
  Map,
  Menu,
  X,
  ChevronLeft,
  Settings,
  Shield,
  Cog,
  Activity,
  TrendingUp,
  Wrench,
  List,
  CalendarCheck,
  Tag
} from "lucide-react";
import { Link, useLocation } from "wouter";
import { useQuery } from "@tanstack/react-query";
import { logout } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/useAuth";
import { usePermissions } from "@/hooks/usePermissions";
import { useClient } from "@/contexts/ClientContext";
import { useModule, MODULE_CONFIGS } from "@/contexts/ModuleContext";

interface SidebarProps {
  isCollapsed: boolean;
  onToggleCollapse: () => void;
}

export default function Sidebar({ isCollapsed, onToggleCollapse }: SidebarProps) {
  const [location, setLocation] = useLocation();
  const { toast } = useToast();
  const { user, canManageClients } = useAuth();
  const { can } = usePermissions();
  const { activeClientId, setActiveClientId, activeClient, customers } = useClient();
  const { currentModule, setModule, moduleConfig, allowedModules, hasMultipleModules } = useModule();
  
  // Usuários do tipo customer_user não podem alterar o cliente
  const isCustomerUser = user?.userType === 'customer_user';
  
  // Calcular módulos permitidos baseado na interseção entre módulos do usuário e do cliente ativo
  const clientModules = (activeClient?.modules || []) as ('clean' | 'maintenance')[];
  const effectiveAllowedModules = allowedModules.filter(module => clientModules.includes(module));
  const effectiveHasMultipleModules = effectiveAllowedModules.length > 1;

  // Auto-corrigir módulo quando cliente ativo mudar
  useEffect(() => {
    if (activeClient && effectiveAllowedModules.length > 0) {
      // Se o módulo atual não está disponível para o cliente ativo, trocar para o primeiro disponível
      if (!effectiveAllowedModules.includes(currentModule)) {
        const newModule = effectiveAllowedModules[0];
        console.log(`[SIDEBAR] Módulo ${currentModule} não disponível para cliente ${activeClient.name}. Trocando para ${newModule}`);
        setModule(newModule);
      }
    }
  }, [activeClient, effectiveAllowedModules, currentModule, setModule]);

  const handleLogout = async () => {
    try {
      await logout();
      toast({
        title: "Logout realizado",
        description: "Você foi desconectado com sucesso.",
      });
      // Forçar recarregamento da página para voltar ao login
      window.location.reload();
    } catch (error) {
      toast({
        title: "Erro no logout",
        description: "Houve um problema ao fazer logout.",
        variant: "destructive",
      });
    }
  };

  // Criar menu baseado em permissões granulares e módulo atual
  const menuItems = [
    // Dashboard - sempre disponível se tiver acesso ao sistema
    ...(can.viewDashboard(activeClientId) ? [{ path: "/", label: "Dashboard", icon: Home }] : []),
    
    // Ordens de Serviço
    ...(can.viewWorkOrders(activeClientId) ? [{ path: "/workorders", label: "Ordens de Serviço", icon: ClipboardList }] : []),
    
    // OPUS Clean - Menu items específicos
    ...(currentModule === 'clean' && can.viewSchedule(activeClientId) ? [{ path: "/schedule", label: "Plano de Limpeza", icon: Calendar }] : []),
    ...(currentModule === 'clean' && can.viewChecklists(activeClientId) ? [{ path: "/checklists", label: "Checklists", icon: Fan }] : []),
    
    // OPUS Manutenção - Menu items específicos
    ...(currentModule === 'maintenance' && can.viewQRCodes(activeClientId) ? [{ path: "/equipment", label: "Equipamentos", icon: Wrench }] : []),
    ...(currentModule === 'maintenance' && can.viewSchedule(activeClientId) ? [{ path: "/maintenance-plans", label: "Planos de Manutenção", icon: CalendarCheck }] : []),
    ...(currentModule === 'maintenance' && can.viewChecklists(activeClientId) ? [{ path: "/maintenance-checklist-templates", label: "Templates de Checklist", icon: List }] : []),
    
    // QR Codes - disponível em ambos os módulos
    ...(can.viewQRCodes(activeClientId) ? [{ path: "/qrcodes", label: "QR Codes", icon: QrCode }] : []),
    
    // Planta dos Locais
    ...(can.viewFloorPlan(activeClientId) ? [{ path: "/floor-plan", label: "Planta dos Locais", icon: Map }] : []),
    
    // Relatórios
    ...(can.viewReports(activeClientId) ? [{ path: "/reports", label: "Relatórios", icon: ChartBar }] : []),
    
    // Usuários OPUS (apenas para quem tem permissão)
    ...(can.viewOpusUsers() ? [{ path: "/users", label: "Usuários OPUS", icon: Users }] : []),
    
    // Clientes (apenas admin)
    ...(can.viewCustomers() ? [{ path: "/customers", label: "Clientes", icon: Building }] : []),
    
    // Configurações do Sistema (contexto específico de cliente)
    ...(activeClientId && can.viewServiceSettings(activeClientId) ? [{ path: "/service-settings", label: "Configurações", icon: Cog }] : []),
    
    // Funções (apenas super admin)
    ...(can.manageRoles() ? [{ path: "/roles", label: "Funções", icon: Shield }] : []),
  ];

  return (
    <div className={`${isCollapsed ? 'w-16' : 'w-64'} bg-gradient-to-b from-slate-50 via-white to-slate-50/50 border-r border-slate-200 shadow-lg flex flex-col transition-all duration-300`} data-testid="sidebar">
      {/* Header */}
      <div className={`${isCollapsed ? 'p-5' : 'py-8 px-6'} border-b border-slate-200 relative bg-gradient-to-br from-white to-slate-100`}>
        <div className="flex items-center justify-between">
          <div className={`flex items-center ${isCollapsed ? 'justify-center w-full' : 'justify-start'}`}>
            <img 
              src={opusLogo} 
              alt="OPUS CLEAN" 
              className={`${isCollapsed ? 'h-12 w-auto' : 'h-16 w-auto max-w-full'} object-contain transition-all duration-300`}
            />
          </div>
          {!isCollapsed && (
            <Button
              variant="ghost"
              size="sm"
              onClick={onToggleCollapse}
              className="h-8 w-8 p-0 flex-shrink-0 hover:bg-primary/10 border border-border/50"
              data-testid="toggle-sidebar"
            >
              <ChevronLeft className={`w-4 h-4 transition-transform text-foreground ${isCollapsed ? 'rotate-180' : ''}`} />
            </Button>
          )}
          {isCollapsed && (
            <div className="absolute top-2 right-2">
              <Button
                variant="ghost"
                size="sm"
                onClick={onToggleCollapse}
                className="h-6 w-6 p-0 flex-shrink-0 hover:bg-primary/10 border border-border/50"
                data-testid="toggle-sidebar"
              >
                <ChevronLeft className={`w-3 h-3 transition-transform text-foreground rotate-180`} />
              </Button>
            </div>
          )}
        </div>
      </div>

      {/* Company Selector - apenas para admin/opus users */}
      {!isCollapsed && !isCustomerUser && customers.length > 0 && (
        <div className="px-6 pt-1 pb-3 border-b border-slate-200 bg-gradient-to-br from-slate-50 to-white">
          <label className="block text-sm font-semibold text-slate-700 mb-2">Cliente Ativo</label>
          <Select value={activeClientId} onValueChange={setActiveClientId}>
            <SelectTrigger data-testid="company-selector" className="bg-white shadow-sm border-slate-300 hover:border-slate-400 transition-colors">
              <SelectValue placeholder="Selecione um cliente" />
            </SelectTrigger>
            <SelectContent>
              {customers.map((customer) => (
                <SelectItem key={customer.id} value={customer.id}>
                  {customer.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}
      
      {/* Nome do Cliente fixo para customer_user */}
      {!isCollapsed && isCustomerUser && activeClient && (
        <div className="px-6 pt-1 pb-3 border-b border-slate-200 bg-gradient-to-br from-slate-50 to-white">
          <label className="block text-sm font-semibold text-slate-500 mb-2">Cliente</label>
          <div className="px-3 py-2 bg-gradient-to-br from-blue-50 to-slate-50 border border-blue-200 rounded-md shadow-sm">
            <p className="text-sm font-medium text-slate-700">{activeClient.name}</p>
          </div>
        </div>
      )}

      {/* Module/Platform Selector - mostrar se o USUÁRIO tem múltiplos módulos */}
      {!isCollapsed && hasMultipleModules && (
        <div className="px-6 pt-1 pb-3 border-b border-slate-200 bg-gradient-to-br from-slate-50 to-white">
          <label className="block text-sm font-semibold text-slate-700 mb-2">Plataforma</label>
          <Select value={currentModule} onValueChange={(value) => setModule(value as 'clean' | 'maintenance')}>
            <SelectTrigger data-testid="module-selector" className="bg-white shadow-sm border-slate-300 hover:border-slate-400 transition-colors">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="clean" disabled={!effectiveAllowedModules.includes('clean')}>
                <span className="flex items-center gap-2">
                  <Building className="w-4 h-4 text-blue-600" />
                  {MODULE_CONFIGS.clean.displayName}
                </span>
              </SelectItem>
              <SelectItem value="maintenance" disabled={!effectiveAllowedModules.includes('maintenance')}>
                <span className="flex items-center gap-2">
                  <Cog className="w-4 h-4 text-orange-600" />
                  {MODULE_CONFIGS.maintenance.displayName}
                </span>
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
      )}
      
      {/* Module Indicator - para usuários com módulo único */}
      {!isCollapsed && !hasMultipleModules && (
        <div className="px-6 pt-1 pb-3 border-b border-slate-200 bg-gradient-to-br from-slate-50 to-white">
          <label className="block text-sm font-semibold text-slate-500 mb-2">Plataforma</label>
          <div className={`px-3 py-2 border rounded-md shadow-sm ${
            currentModule === 'maintenance'
              ? 'bg-gradient-to-br from-orange-50 to-amber-50 border-orange-200'
              : 'bg-gradient-to-br from-blue-50 to-slate-50 border-blue-200'
          }`}>
            <div className="flex items-center gap-2">
              {currentModule === 'maintenance' ? (
                <Cog className="w-4 h-4 text-orange-600" />
              ) : (
                <Building className="w-4 h-4 text-blue-600" />
              )}
              <p className="text-sm font-medium text-slate-700">
                {MODULE_CONFIGS[currentModule].displayName}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-2">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location === item.path;
          
          // Gradiente baseado no módulo ativo
          const activeGradient = currentModule === 'maintenance'
            ? 'bg-gradient-to-r from-orange-500 to-amber-600 text-white shadow-md hover:shadow-lg'
            : 'bg-gradient-to-r from-blue-600 to-cyan-600 text-white shadow-md hover:shadow-lg';
          
          return (
            <Link key={item.path} href={item.path}>
              <Button
                variant={isActive ? "default" : "ghost"}
                className={`w-full ${isCollapsed ? 'justify-center px-0' : 'justify-start space-x-3'} transition-all duration-200 ${
                  isActive 
                    ? activeGradient
                    : "hover:bg-slate-100 hover:text-slate-900"
                }`}
                data-testid={`nav-${item.path.slice(1) || 'dashboard'}`}
                title={isCollapsed ? item.label : undefined}
              >
                <Icon className="w-5 h-5" />
                {!isCollapsed && <span className="font-medium">{item.label}</span>}
              </Button>
            </Link>
          );
        })}
      </nav>

      {/* User Profile */}
      <div className="p-4 border-t border-slate-200 bg-gradient-to-br from-slate-50 to-white">
        {isCollapsed ? (
          <div className="flex justify-center">
            <div className="w-8 h-8 bg-secondary rounded-full flex items-center justify-center">
              <span className="text-sm font-medium text-secondary-foreground">AD</span>
            </div>
          </div>
        ) : (
          <div className="flex items-center space-x-3 p-2">
            <div className="w-8 h-8 bg-secondary rounded-full flex items-center justify-center">
              <span className="text-sm font-medium text-secondary-foreground">AD</span>
            </div>
            <div className="flex-1">
              <p className="text-sm font-medium text-foreground">Administrador</p>
              <p className="text-xs text-muted-foreground">Admin</p>
            </div>
            <Button 
              variant="ghost" 
              size="sm" 
              onClick={handleLogout}
              data-testid="logout-button"
              title="Sair"
            >
              <LogOut className="w-4 h-4" />
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}
