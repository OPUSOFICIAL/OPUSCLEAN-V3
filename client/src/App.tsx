import { Switch, Route, useLocation, Redirect } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { ClientProvider, useClient } from "@/contexts/ClientContext";
import { ModuleProvider, useModule } from "@/contexts/ModuleContext";
import { BrandingProvider } from "@/contexts/BrandingContext";
import { NetworkProvider } from "@/contexts/NetworkContext";
import NotFound from "@/pages/not-found";
import Dashboard from "@/pages/dashboard";
import WorkOrders from "@/pages/work-orders";
import CleaningSchedule from "@/pages/cleaning-schedule";
import QrCodes from "@/pages/qr-codes";
import Sites from "@/pages/sites";
import FloorPlan from "@/pages/floor-plan";
import SystemUsers from "@/pages/system-users";
import Reports from "@/pages/reports";
import Checklists from "@/pages/checklists";
import Services from "@/pages/services";
import ServiceSettings from "@/pages/service-settings";
import AuditLogs from "@/pages/audit-logs";
import AdminMobile from "@/pages/admin-mobile";
import Customers from "@/pages/customers";
import Roles from "@/pages/roles";
import Equipment from "@/pages/equipment";
import MaintenancePlans from "@/pages/maintenance-plans";
import MaintenanceChecklistTemplates from "@/pages/maintenance-checklist-templates";
import AssetReport from "@/pages/asset-report";
import AiIntegrations from "@/pages/ai-integrations";
import TvMode from "@/pages/tv-mode";
import BrandingSettings from "@/pages/branding-settings";
import { useIsMobile } from "@/hooks/use-mobile";
import QrExecution from "@/pages/qr-execution";
import QrPublic from "@/pages/qr-public";
import Login from "@/pages/login";
import LoginMobile from "@/pages/login-mobile";
import ModuleSelection from "@/pages/module-selection";
import Landing from "@/pages/landing";
import MobileDashboard from "@/pages/mobile-dashboard";
import MobileQrScanner from "@/pages/mobile-qr-scanner";
import MobileWorkOrderExecute from "@/pages/mobile-work-order-execute";
import MobileWorkOrderDetails from "@/pages/mobile-work-order-details";
import QrTest from "@/pages/qr-test";
import Sidebar from "@/components/layout/sidebar";
import { useState } from "react";
import { useAuth, getAuthState } from "@/hooks/useAuth";
import { ProtectedRoute } from "@/components/ProtectedRoute";
import { usePermissions } from "@/hooks/usePermissions";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { ScrollToTop } from "@/components/ScrollToTop";
import { useSyncOnReconnect } from "@/hooks/use-sync-on-reconnect";
import { useWebSocket } from "@/hooks/useWebSocket";
import { useToast } from "@/hooks/use-toast";

// Component to initialize sync hooks
function SyncInitializer() {
  useSyncOnReconnect();
  return null;
}

// Component to initialize WebSocket connection for real-time updates
function WebSocketInitializer() {
  const { isAuthenticated } = useAuth();
  const { toast } = useToast();
  
  // Mapeamento de recursos para nomes amigáveis
  const getResourceLabel = (resource: string): string => {
    const labels: Record<string, string> = {
      'workorders': 'Ordem de Serviço',
      'customers': 'Cliente',
      'sites': 'Local',
      'zones': 'Zona',
      'users': 'Usuário',
      'roles': 'Função',
      'equipment': 'Equipamento',
      'qrcodes': 'QR Code',
      'services': 'Serviço',
      'checklists': 'Checklist',
      'maintenance-plans': 'Plano de Manutenção',
    };
    return labels[resource] || resource;
  };
  
  const { isConnected, connectionStatus, disconnect } = useWebSocket({
    enabled: isAuthenticated,
    onConnect: () => {
      console.log('[App] 🚀 WebSocket connected - real-time updates enabled');
    },
    onDisconnect: () => {
      console.log('[App] 🔌 WebSocket disconnected');
    },
    onMessage: (message) => {
      console.log('[App] 📩 WebSocket message:', message);
      
      // Detectar se a sessão foi invalidada (login em outro aparelho)
      if (message.type === 'session_invalidated') {
        console.log('[App] ⚠️ SESSÃO INVALIDADA - Executando logout forçado...');
        
        // STEP 1: Limpar localStorage IMEDIATAMENTE
        localStorage.removeItem('opus_clean_token');
        localStorage.removeItem('opus_clean_user');
        console.log('[App] ✅ localStorage limpo');
        
        // STEP 2: Desconectar WebSocket
        disconnect();
        console.log('[App] ✅ WebSocket desconectado');
        
        // STEP 3: Redirecionar IMEDIATAMENTE (SÍNCRONO - não esperar)
        console.log('[App] 🔄 Redirecionando para /login...');
        window.location.href = '/login';
        
        // STEP 4: Toast aparece durante redirect (mas não bloqueia)
        toast({
          title: "Sessão encerrada",
          description: message.message || "Essa conta foi logada em outro aparelho",
          variant: "destructive",
          duration: 1000,
        });
        
        return;
      }
      
      // Detectar force logout
      if (message.type === 'force_logout') {
        // Limpar localStorage PRIMEIRO
        localStorage.removeItem('opus_clean_token');
        localStorage.removeItem('opus_clean_user');
        
        // Desconectar WebSocket imediatamente
        disconnect();
        
        // Mostrar toast
        toast({
          title: "Desconectado",
          description: message.message || "Você foi desconectado pelo sistema",
          variant: "destructive",
          duration: 1500,
        });
        
        // Forçar navegação IMEDIATA para /login
        window.location.replace('/login');
        
        return;
      }
      
      // Mostrar toast sutil para atualizações em tempo real
      if (message.type && message.resource && (message.type === 'create' || message.type === 'update' || message.type === 'delete')) {
        const resourceLabel = getResourceLabel(message.resource);
        const actionLabels = {
          create: 'criado(a)',
          update: 'atualizado(a)',
          delete: 'excluído(a)',
        };
        const action = actionLabels[message.type as keyof typeof actionLabels] || message.type;
        
        toast({
          title: "Atualização em tempo real",
          description: `${resourceLabel} ${action}`,
          duration: 2000,
        });
      }
    }
  });

  // Show connection status in development
  if (import.meta.env.DEV && isAuthenticated) {
    console.log(`[WebSocket] Status: ${connectionStatus}, Connected: ${isConnected}`);
  }

  return null;
}

function AuthenticatedAdminRouter() {
  const { activeClientId, isLoading } = useClient();
  const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(false);
  const isMobile = useIsMobile();
  const { user } = useAuth();
  
  const companyId = user?.companyId || "company-opus-default";

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div>Carregando...</div>
      </div>
    );
  }

  if (isMobile) {
    return <AdminMobile companyId={companyId} />;
  }

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar 
        isCollapsed={sidebarCollapsed}
        onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
      />
      <div className="flex-1 flex flex-col min-h-screen overflow-y-auto">
        <Switch>
          <Route path="/" component={() => <Dashboard />} />
          <Route path="/workorders" component={() => <WorkOrders />} />
          <Route path="/schedule" component={() => <CleaningSchedule />} />
          <Route path="/checklists" component={() => <Checklists />} />
          <Route path="/services" component={() => <Services customerId={activeClientId} />} />
          <Route path="/service-settings" component={() => <ServiceSettings />} />
          <Route path="/qrcodes" component={() => <QrCodes />} />
          <Route path="/sites" component={() => <Sites customerId={activeClientId} />} />
          <Route path="/floor-plan" component={() => <FloorPlan />} />
          <Route path="/users" component={() => <SystemUsers />} />
          <Route path="/customers" component={() => <Customers companyId={companyId} />} />
          <Route path="/roles" component={() => <Roles />} />
          <Route path="/reports" component={() => <Reports />} />
          <Route path="/audit-logs" component={() => <AuditLogs companyId={companyId} />} />
          <Route path="/ai-integrations" component={() => <AiIntegrations />} />
          <Route path="/branding-settings" component={() => <BrandingSettings />} />
          
          {/* Maintenance Module Routes */}
          <Route path="/equipment" component={() => <Equipment customerId={activeClientId} />} />
          <Route path="/maintenance-plans" component={() => <MaintenancePlans />} />
          <Route path="/maintenance-checklist-templates" component={() => <MaintenanceChecklistTemplates customerId={activeClientId} />} />
          <Route path="/asset-report" component={() => <AssetReport customerId={activeClientId} />} />
          
          {/* TV Mode Dashboard */}
          <Route path="/tv-mode" component={() => <TvMode />} />
          
          {/* Redirecionar rotas de login para dashboard se já autenticado */}
          <Route path="/login">
            <Redirect to="/" />
          </Route>
          <Route path="/login-mobile">
            <Redirect to="/" />
          </Route>
          
          {/* Redirecionar qualquer outra rota inválida para home */}
          <Route>
            <Redirect to="/" />
          </Route>
        </Switch>
      </div>
    </div>
  );
}

function MobileRouter() {
  return (
    <Switch>
      <Route path="/mobile" component={MobileDashboard} />
      <Route path="/mobile/qr-scanner" component={MobileQrScanner} />
      <Route path="/mobile/qr-test" component={QrTest} />
      <Route path="/mobile/work-order-details/:id" component={MobileWorkOrderDetails} />
      <Route path="/mobile/work-order/:id" component={MobileWorkOrderExecute} />
      <Route path="/qr-public/:code" component={QrPublic} />
      <Route component={() => <MobileDashboard />} />
    </Switch>
  );
}

function Router() {
  const { user, isAuthenticated } = useAuth();
  const { isMobileOnlyUser, isLoading } = usePermissions();
  const [location] = useLocation();

  // Se não está autenticado, mostrar landing/login
  if (!isAuthenticated || !user) {
    return (
      <Switch>
        <Route path="/qr-public/:code" component={QrPublic} />
        <Route path="/mobile/qr-scanner" component={MobileQrScanner} />
        <Route path="/module-selection" component={ModuleSelection} />
        <Route path="/login-mobile" component={LoginMobile} />
        <Route path="/login" component={Login} />
        <Route path="/" component={Landing} />
        <Route component={Landing} />
      </Switch>
    );
  }

  // Module selection page - no sidebar, accessible when authenticated
  if (location === "/module-selection") {
    return <ModuleSelection />;
  }

  // Aguardar carregamento das permissões antes de rotear
  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div>Carregando permissões...</div>
      </div>
    );
  }

  // Se é colaborador (operador com apenas permissões mobile), mostrar interface móvel
  if (isMobileOnlyUser) {
    return <MobileRouter />;
  }

  // Se é admin/supervisor/cliente, mostrar interface administrativa web
  return <AuthenticatedAdminRouter />;
}

function App() {
  return (
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <NetworkProvider>
          <ClientProvider>
            <ModuleProvider>
              <BrandingProvider>
                <TooltipProvider>
                  <SyncInitializer />
                  <WebSocketInitializer />
                  <ScrollToTop />
                  <Toaster />
                  <Router />
                </TooltipProvider>
              </BrandingProvider>
            </ModuleProvider>
          </ClientProvider>
        </NetworkProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}

export default App;
