import { Switch, Route, useLocation, Redirect } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { ClientProvider, useClient } from "@/contexts/ClientContext";
import { ModuleProvider, useModule } from "@/contexts/ModuleContext";
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
import ModuleSelector from "@/pages/module-selector";
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

function ModuleRouteHandler({ params }: { params: { module: string } }) {
  const { setModule } = useModule();
  const { activeClientId, isLoading: clientLoading } = useClient();
  const { user } = useAuth();
  const [, setLocation] = useLocation();

  const companyId = user?.companyId || "company-opus-default";
  const moduleParam = params.module;

  useEffect(() => {
    if (moduleParam === 'clean' || moduleParam === 'maintenance') {
      setModule(moduleParam);
    } else {
      setLocation('/');
    }
  }, [moduleParam, setModule, setLocation]);

  if (moduleParam !== 'clean' && moduleParam !== 'maintenance') {
    return <Redirect to="/" />;
  }

  if (clientLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div>Carregando...</div>
      </div>
    );
  }

  return (
    <Switch>
      <Route path="/:module/dashboard" component={() => <Dashboard />} />
      <Route path="/:module/workorders" component={() => <WorkOrders />} />
      <Route path="/:module/schedule" component={() => <CleaningSchedule />} />
      <Route path="/:module/checklists" component={() => <Checklists />} />
      <Route path="/:module/services" component={() => <Services customerId={activeClientId} />} />
      <Route path="/:module/service-settings" component={() => <ServiceSettings />} />
      <Route path="/:module/qrcodes" component={() => <QrCodes />} />
      <Route path="/:module/sites" component={() => <Sites customerId={activeClientId} />} />
      <Route path="/:module/floor-plan" component={() => <FloorPlan />} />
      <Route path="/:module/users" component={() => <SystemUsers />} />
      <Route path="/:module/customers" component={() => <Customers companyId={companyId} />} />
      <Route path="/:module/roles" component={() => <Roles />} />
      <Route path="/:module/reports" component={() => <Reports />} />
      <Route path="/:module/audit-logs" component={() => <AuditLogs companyId={companyId} />} />
      <Route>
        <Redirect to={`/${moduleParam}/dashboard`} />
      </Route>
    </Switch>
  );
}

function AuthenticatedAdminRouter() {
  const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(false);
  const isMobile = useIsMobile();
  const { user } = useAuth();
  
  const companyId = user?.companyId || "company-opus-default";

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
          <Route path="/" component={ModuleSelector} />
          <Route path="/:module/:rest*">
            {(params) => <ModuleRouteHandler params={params} />}
          </Route>
          
          {/* Redirects para rotas antigas (sem módulo) -> /clean/... */}
          <Route path="/dashboard">
            <Redirect to="/clean/dashboard" />
          </Route>
          <Route path="/workorders">
            <Redirect to="/clean/workorders" />
          </Route>
          <Route path="/schedule">
            <Redirect to="/clean/schedule" />
          </Route>
          <Route path="/checklists">
            <Redirect to="/clean/checklists" />
          </Route>
          <Route path="/services">
            <Redirect to="/clean/services" />
          </Route>
          <Route path="/service-settings">
            <Redirect to="/clean/service-settings" />
          </Route>
          <Route path="/qrcodes">
            <Redirect to="/clean/qrcodes" />
          </Route>
          <Route path="/sites">
            <Redirect to="/clean/sites" />
          </Route>
          <Route path="/floor-plan">
            <Redirect to="/clean/floor-plan" />
          </Route>
          <Route path="/users">
            <Redirect to="/clean/users" />
          </Route>
          <Route path="/customers">
            <Redirect to="/clean/customers" />
          </Route>
          <Route path="/roles">
            <Redirect to="/clean/roles" />
          </Route>
          <Route path="/reports">
            <Redirect to="/clean/reports" />
          </Route>
          <Route path="/audit-logs">
            <Redirect to="/clean/audit-logs" />
          </Route>
          
          {/* Redirecionar rotas de login para home se já autenticado */}
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
        <ModuleProvider>
          <ClientProvider>
            <TooltipProvider>
              <Toaster />
              <Router />
            </TooltipProvider>
          </ClientProvider>
        </ModuleProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}

export default App;
