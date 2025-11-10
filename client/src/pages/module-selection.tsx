import { useEffect, useState } from "react";
import { useLocation } from "wouter";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Building, Wrench, Loader2, Sparkles } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { useModule } from "@/contexts/ModuleContext";
import { useAuth } from "@/hooks/useAuth";
import aceleraLogo from "@assets/imagem_2025-11-10_010501695-Photoroom_1762805733799.png";

interface Customer {
  id: string;
  name: string;
  isActive: boolean;
  modules: string[];
}

export default function ModuleSelection() {
  const [, setLocation] = useLocation();
  const { setModule } = useModule();
  const [isLoading, setIsLoading] = useState(false);
  const { user } = useAuth();

  const companyId = user?.companyId || "company-opus-default";
  const isCustomerUser = user?.userType === 'customer_user';
  const userCustomerId = user?.customerId;

  const { data: modulesData, isLoading: isLoadingModules } = useQuery<{ modules: string[]; defaultModule: string }>({
    queryKey: ["/api/auth/user-modules"],
  });

  const { data: allCustomers = [], isLoading: isLoadingCustomers } = useQuery<Customer[]>({
    queryKey: ["/api/companies", companyId, "customers"],
    enabled: !isCustomerUser && !!companyId,
  });

  const availableModules = modulesData?.modules || [];
  const activeCustomers = (allCustomers as Customer[]).filter(c => c.isActive);

  useEffect(() => {
    if (availableModules.length === 1) {
      const module = availableModules[0] as 'clean' | 'maintenance';
      handleModuleSelect(module);
    }
  }, [availableModules]);

  useEffect(() => {
    if (!user) {
      setLocation("/login");
    }
  }, [user, setLocation]);

  const handleModuleSelect = async (module: 'clean' | 'maintenance') => {
    setIsLoading(true);
    setModule(module);
    
    if (isCustomerUser && userCustomerId) {
      localStorage.setItem('opus:activeClientId', userCustomerId);
      setTimeout(() => setLocation("/"), 300);
      return;
    }

    const customersWithModule = activeCustomers.filter(customer => 
      customer.modules.includes(module)
    );

    if (customersWithModule.length > 0) {
      const selectedCustomer = customersWithModule[0];
      localStorage.setItem('opus:activeClientId', selectedCustomer.id);
      console.log(`[MODULE SELECTION] Módulo ${module} selecionado. Cliente ativo: ${selectedCustomer.name}`);
    } else {
      console.warn(`[MODULE SELECTION] Nenhum cliente encontrado com o módulo ${module}`);
    }
    
    setTimeout(() => {
      setLocation("/");
    }, 300);
  };

  if (isLoadingModules) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-blue-400 mx-auto mb-4" />
          <p className="text-white/80">Carregando módulos...</p>
        </div>
      </div>
    );
  }

  if (availableModules.length === 1) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-blue-400 mx-auto mb-4" />
          <p className="text-white/80">Redirecionando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900 relative overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0">
        {/* Grid Pattern */}
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImdyaWQiIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTSAxMCAwIEwgMCAwIDAgMTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0id2hpdGUiIHN0cm9rZS1vcGFjaXR5PSIwLjA1IiBzdHJva2Utd2lkdGg9IjEiLz48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InVybCgjZ3JpZCkiLz48L3N2Zz4=')] opacity-30"></div>
        
        {/* Gradient Orbs */}
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse" style={{ animationDelay: '2s' }}></div>
        <div className="absolute top-1/2 left-1/2 w-96 h-96 bg-indigo-500 rounded-full mix-blend-multiply filter blur-3xl opacity-10 animate-pulse" style={{ animationDelay: '4s' }}></div>
      </div>

      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col items-center justify-center p-4 md:p-8">
        <div className="w-full max-w-6xl">
          {/* Header with Logo */}
          <div className="text-center mb-12" data-testid="header-module-selection">
            <img 
              src={aceleraLogo} 
              alt="Acelera Full Facilities" 
              className="h-24 mx-auto mb-8 drop-shadow-2xl"
            />
            <h1 className="text-4xl md:text-5xl font-bold text-white mb-4 tracking-tight flex items-center justify-center gap-3">
              <Sparkles className="w-10 h-10 text-blue-400" />
              Escolha seu Módulo
              <Sparkles className="w-10 h-10 text-blue-400" />
            </h1>
            <p className="text-xl text-blue-100">
              Selecione qual área você deseja acessar
            </p>
          </div>

          {/* Module Cards Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12 max-w-5xl mx-auto">
            {/* OPUS Clean Card */}
            {availableModules.includes('clean') && (
              <div 
                onClick={() => !isLoading && handleModuleSelect('clean')}
                className="group relative transform transition-all duration-300 hover:scale-105"
                data-testid="card-module-clean"
              >
                <Card className="relative overflow-hidden border-0 shadow-2xl hover:shadow-blue-500/50 transition-all duration-500 cursor-pointer bg-white/95 backdrop-blur-sm">
                  {/* Animated Gradient Background */}
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 via-blue-600/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                  
                  {/* Shine Effect */}
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700">
                    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent skew-x-12 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000"></div>
                  </div>
                  
                  <CardContent className="relative p-10 md:p-12 text-center">
                    {/* Icon */}
                    <div className="mb-8 flex justify-center">
                      <div className="w-32 h-32 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 group-hover:from-blue-500 group-hover:to-blue-700 transition-all duration-500 flex items-center justify-center shadow-lg group-hover:shadow-2xl group-hover:shadow-blue-500/50">
                        <Building className="h-16 w-16 text-white" strokeWidth={2.5} />
                      </div>
                    </div>

                    {/* Title */}
                    <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-blue-600 to-blue-800 bg-clip-text text-transparent mb-4" data-testid="text-module-clean-title">
                      OPUS Clean
                    </h2>

                    {/* Description */}
                    <p className="text-lg text-slate-600 mb-8 font-medium" data-testid="text-module-clean-description">
                      Gestão de Limpeza e Facilities
                    </p>

                    {/* Features List */}
                    <ul className="text-sm text-slate-600 space-y-2 mb-8 text-left">
                      <li className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-blue-500"></div>
                        Controle de ordens de serviço
                      </li>
                      <li className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-blue-500"></div>
                        Gestão de equipes e turnos
                      </li>
                      <li className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-blue-500"></div>
                        Relatórios e analytics
                      </li>
                    </ul>

                    {/* Button */}
                    <Button
                      disabled={isLoading}
                      className="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold py-7 text-lg shadow-lg hover:shadow-xl transition-all duration-300"
                      data-testid="button-select-clean"
                    >
                      {isLoading ? (
                        <>
                          <Loader2 className="mr-2 h-6 w-6 animate-spin" />
                          Carregando...
                        </>
                      ) : (
                        'Acessar OPUS Clean →'
                      )}
                    </Button>
                  </CardContent>
                </Card>
              </div>
            )}

            {/* OPUS Manutenção Card */}
            {availableModules.includes('maintenance') && (
              <div 
                onClick={() => !isLoading && handleModuleSelect('maintenance')}
                className="group relative transform transition-all duration-300 hover:scale-105"
                data-testid="card-module-maintenance"
              >
                <Card className="relative overflow-hidden border-0 shadow-2xl hover:shadow-orange-500/50 transition-all duration-500 cursor-pointer bg-white/95 backdrop-blur-sm">
                  {/* Animated Gradient Background */}
                  <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 via-orange-600/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                  
                  {/* Shine Effect */}
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700">
                    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent skew-x-12 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000"></div>
                  </div>
                  
                  <CardContent className="relative p-10 md:p-12 text-center">
                    {/* Icon */}
                    <div className="mb-8 flex justify-center">
                      <div className="w-32 h-32 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 group-hover:from-orange-500 group-hover:to-orange-700 transition-all duration-500 flex items-center justify-center shadow-lg group-hover:shadow-2xl group-hover:shadow-orange-500/50">
                        <Wrench className="h-16 w-16 text-white" strokeWidth={2.5} />
                      </div>
                    </div>

                    {/* Title */}
                    <h2 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-orange-600 to-orange-800 bg-clip-text text-transparent mb-4" data-testid="text-module-maintenance-title">
                      OPUS Manutenção
                    </h2>

                    {/* Description */}
                    <p className="text-lg text-slate-600 mb-8 font-medium" data-testid="text-module-maintenance-description">
                      Gestão de Manutenção Preventiva e Corretiva
                    </p>

                    {/* Features List */}
                    <ul className="text-sm text-slate-600 space-y-2 mb-8 text-left">
                      <li className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-orange-500"></div>
                        Planos de manutenção
                      </li>
                      <li className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-orange-500"></div>
                        Gestão de equipamentos
                      </li>
                      <li className="flex items-center gap-2">
                        <div className="w-1.5 h-1.5 rounded-full bg-orange-500"></div>
                        Calendário de atividades
                      </li>
                    </ul>

                    {/* Button */}
                    <Button
                      disabled={isLoading}
                      className="w-full bg-gradient-to-r from-orange-600 to-orange-700 hover:from-orange-700 hover:to-orange-800 text-white font-bold py-7 text-lg shadow-lg hover:shadow-xl transition-all duration-300"
                      data-testid="button-select-maintenance"
                    >
                      {isLoading ? (
                        <>
                          <Loader2 className="mr-2 h-6 w-6 animate-spin" />
                          Carregando...
                        </>
                      ) : (
                        'Acessar OPUS Manutenção →'
                      )}
                    </Button>
                  </CardContent>
                </Card>
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="text-center space-y-4">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-white/20"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-4 text-white/70">Sistema modular de gestão de facilities</span>
              </div>
            </div>
            
            <p className="text-xs text-white/50">
              © 2025 Acelera Full Facilities. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
