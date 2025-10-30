import { Switch, Route, useLocation, Redirect } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { ClientProvider, useClient } from "@/contexts/ClientContext";
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
import { useIsMobile } from "@/hooks/use-mobile";
import QrExecution from "@/pages/qr-execution";
import QrPublic from "@/pages/qr-public";
import Login from "@/pages/login";
import LoginMobile from "@/pages/login-mobile";
import MobileDashboard from "@/pages/mobile-dashboard";
import MobileQrScanner from "@/pages/mobile-qr-scanner";
import MobileWorkOrderExecute from "@/pages/mobile-work-order-execute";
import MobileWorkOrderDetails from "@/pages/mobile-work-order-details";
import QrTest from "@/pages/qr-test";
import Sidebar from "@/components/layout/sidebar";
import { useState, useEffect } from "react";
import { useAuth, getAuthState } from "@/hooks/useAuth";
import { ProtectedRoute } from "@/components/ProtectedRoute";
import { usePermissions } from "@/hooks/usePermissions";
import { ErrorBoundary } from "@/components/ErrorBoundary";

function AuthenticatedAdminRouter() {
  const { activeClientId, setActiveClientId, isLoading } = useClient();
  const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(false);
  const isMobile = useIsMobile();
  const { user } = useAuth();
  
  // Usar o companyId do usuário logado
  const companyId = user?.companyId || "company-opus-default";

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div>Carregando...</div>
      </div>
    );
  }

  // Se é mobile, mostrar interface móvel otimizada
  if (isMobile) {
    return <AdminMobile companyId={companyId} />;
  }

  // Interface desktop
  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar 
        selectedCompanyId={activeClientId}
        onCompanyChange={setActiveClientId}
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
          
          {/* Redirecionar rotas de login para dashboard se já autenticado */}
          <Route path="/login">
            <Redirect to="/" />
          </Route>
          <Route path="/login-mobile">
            <Redirect to="/" />
          </Route>
          
          {/* Redirecionar qualquer outra rota inválida para dashboard */}
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

  // Se não está autenticado, mostrar login
  if (!isAuthenticated || !user) {
    return (
      <Switch>
        <Route path="/qr-public/:code" component={QrPublic} />
        <Route path="/mobile/qr-scanner" component={MobileQrScanner} />
        <Route path="/login-mobile" component={LoginMobile} />
        <Route path="/login" component={Login} />
        <Route component={Login} />
      </Switch>
    );
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
        <ClientProvider>
          <TooltipProvider>
            <Toaster />
            <Router />
          </TooltipProvider>
        </ClientProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}

export default App;
