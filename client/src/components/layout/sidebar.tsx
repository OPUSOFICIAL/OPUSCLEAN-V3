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
  TrendingUp
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
  const { currentModule, setModule, moduleConfig } = useModule();
  
  // Usuários do tipo customer_user não podem alterar o cliente
  const isCustomerUser = user?.userType === 'customer_user';

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

  // Criar menu baseado em permissões granulares
  const menuItems = [
    // Dashboard - sempre disponível se tiver acesso ao sistema
    ...(can.viewDashboard(activeClientId) ? [{ path: "/", label: "Dashboard", icon: Home }] : []),
    
    // Ordens de Serviço
    ...(can.viewWorkOrders(activeClientId) ? [{ path: "/workorders", label: "Ordens de Serviço", icon: ClipboardList }] : []),
    
    // Plano de Limpeza
    ...(can.viewSchedule(activeClientId) ? [{ path: "/schedule", label: "Plano de Limpeza", icon: Calendar }] : []),
    
    // Checklists
    ...(can.viewChecklists(activeClientId) ? [{ path: "/checklists", label: "Checklists", icon: Fan }] : []),
    
    // QR Codes
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
    <div className={`${isCollapsed ? 'w-16' : 'w-64'} bg-card border-r border-border flex flex-col transition-all duration-300`} data-testid="sidebar">
      {/* Header */}
      <div className={`${isCollapsed ? 'p-5' : 'py-8 px-6'} border-b border-border relative`}>
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
        <div className="px-6 pt-1 pb-3 border-b border-border">
          <label className="block text-sm font-medium text-foreground mb-2">Cliente Ativo</label>
          <Select value={activeClientId} onValueChange={setActiveClientId}>
            <SelectTrigger data-testid="company-selector">
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
        <div className="px-6 pt-1 pb-3 border-b border-border">
          <label className="block text-sm font-medium text-muted-foreground mb-2">Cliente</label>
          <div className="px-3 py-2 bg-muted rounded-md">
            <p className="text-sm font-medium text-foreground">{activeClient.name}</p>
          </div>
        </div>
      )}

      {/* Module/Platform Selector */}
      {!isCollapsed && (
        <div className="px-6 pt-1 pb-3 border-b border-border">
          <label className="block text-sm font-medium text-foreground mb-2">Plataforma</label>
          <Select value={currentModule} onValueChange={(value) => setModule(value as 'clean' | 'maintenance')}>
            <SelectTrigger data-testid="module-selector">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="clean">
                <span className="flex items-center gap-2">
                  <Building className="w-4 h-4 text-blue-600" />
                  {MODULE_CONFIGS.clean.displayName}
                </span>
              </SelectItem>
              <SelectItem value="maintenance">
                <span className="flex items-center gap-2">
                  <Cog className="w-4 h-4 text-orange-600" />
                  {MODULE_CONFIGS.maintenance.displayName}
                </span>
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-2">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location === item.path;
          
          return (
            <Link key={item.path} href={item.path}>
              <Button
                variant={isActive ? "default" : "ghost"}
                className={`w-full ${isCollapsed ? 'justify-center px-0' : 'justify-start space-x-3'} ${
                  isActive 
                    ? "bg-primary text-primary-foreground" 
                    : "hover:bg-accent hover:text-accent-foreground"
                }`}
                data-testid={`nav-${item.path.slice(1) || 'dashboard'}`}
                title={isCollapsed ? item.label : undefined}
              >
                <Icon className="w-5 h-5" />
                {!isCollapsed && <span>{item.label}</span>}
              </Button>
            </Link>
          );
        })}
      </nav>

      {/* User Profile */}
      <div className="p-4 border-t border-border">
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
