import { Switch, Route, useLocation, Redirect } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { ClientProvider, useClient } from "@/contexts/ClientContext";
import { ModuleProvider, useModule } from "@/contexts/ModuleContext";
import { BrandingProvider, useBranding } from "@/contexts/BrandingContext";
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
import CustomLanding from "@/pages/custom-landing";
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
  const { branding, isReady } = useBranding();

  // Se não está autenticado, mostrar landing/login
  if (!isAuthenticated || !user) {
    // Usar CustomLanding se houver branding de tenant, senão Landing padrão
    const LandingComponent = branding ? CustomLanding : Landing;
    
    return (
      <Switch>
        <Route path="/qr-public/:code" component={QrPublic} />
        <Route path="/mobile/qr-scanner" component={MobileQrScanner} />
        <Route path="/module-selection" component={ModuleSelection} />
        <Route path="/login-mobile" component={LoginMobile} />
        <Route path="/login" component={Login} />
        <Route path="/" component={LandingComponent} />
        <Route component={LandingComponent} />
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
        <BrandingProvider>
          <ClientProvider>
            <ModuleProvider>
              <TooltipProvider>
                <ScrollToTop />
                <Toaster />
                <Router />
              </TooltipProvider>
            </ModuleProvider>
          </ClientProvider>
        </BrandingProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}

export default App;
