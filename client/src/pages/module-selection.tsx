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
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12 max-w-7xl mx-auto px-4">
            {/* OPUS Clean Card */}
            {availableModules.includes('clean') && (
              <div 
                onClick={() => !isLoading && handleModuleSelect('clean')}
                className="group relative h-full"
                data-testid="card-module-clean"
              >
                {/* Animated Background Gradient */}
                <div className="absolute inset-0 bg-gradient-to-br from-blue-600/20 via-blue-500/10 to-cyan-500/20 rounded-[2rem] blur-2xl opacity-60 group-hover:opacity-100 transition-all duration-700 group-hover:scale-110"></div>
                
                <Card className="relative overflow-hidden border border-white/20 rounded-[2rem] shadow-2xl hover:shadow-blue-500/40 transition-all duration-700 cursor-pointer bg-gradient-to-br from-slate-900/80 via-blue-900/60 to-slate-900/80 backdrop-blur-2xl transform group-hover:scale-[1.02] h-full">
                  {/* Mesh Pattern Overlay */}
                  <div className="absolute inset-0 opacity-5 mix-blend-overlay">
                    <div className="absolute inset-0" style={{
                      backgroundImage: `radial-gradient(circle at 2px 2px, white 1px, transparent 0)`,
                      backgroundSize: '40px 40px'
                    }}></div>
                  </div>
                  
                  {/* Shine Effect */}
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-1000">
                    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-blue-400/10 to-transparent -skew-x-12 translate-x-[-200%] group-hover:translate-x-[200%] transition-transform duration-2000"></div>
                  </div>
                  
                  <CardContent className="relative p-8 md:p-10 flex flex-col h-full min-h-[600px]">
                    {/* Top Decorative Element */}
                    <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-blue-500/10 to-transparent rounded-full blur-3xl"></div>
                    
                    {/* Icon */}
                    <div className="mb-8 flex justify-center relative z-10">
                      <div className="relative">
                        {/* Outer Ring */}
                        <div className="absolute -inset-4 bg-gradient-to-r from-blue-400 via-blue-500 to-cyan-400 rounded-full opacity-20 blur-xl group-hover:opacity-40 transition-all duration-700"></div>
                        {/* Icon Circle */}
                        <div className="relative w-28 h-28 rounded-full bg-gradient-to-br from-blue-400 via-blue-500 to-cyan-500 flex items-center justify-center shadow-2xl group-hover:shadow-blue-500/50 transition-all duration-500 group-hover:scale-110 border border-white/20">
                          <Building className="h-14 w-14 text-white drop-shadow-lg" strokeWidth={2} />
                        </div>
                      </div>
                    </div>

                    {/* Content */}
                    <div className="text-center mb-8 relative z-10">
                      <h2 className="text-4xl md:text-5xl font-extrabold bg-gradient-to-r from-blue-300 via-blue-200 to-cyan-300 bg-clip-text text-transparent mb-4 tracking-tight" data-testid="text-module-clean-title">
                        OPUS Clean
                      </h2>
                      <div className="flex items-center justify-center gap-2 mb-6">
                        <div className="h-px w-12 bg-gradient-to-r from-transparent to-blue-400"></div>
                        <div className="h-1.5 w-1.5 rounded-full bg-blue-400 animate-pulse"></div>
                        <div className="h-px w-12 bg-gradient-to-l from-transparent to-blue-400"></div>
                      </div>
                      <p className="text-lg text-blue-200/80 font-medium" data-testid="text-module-clean-description">
                        Gestão de Limpeza e Facilities
                      </p>
                    </div>

                    {/* Features List */}
                    <div className="flex-1 bg-white/5 backdrop-blur-sm rounded-3xl p-6 mb-8 border border-white/10 relative overflow-hidden">
                      <div className="absolute top-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-blue-400/50 to-transparent"></div>
                      <ul className="space-y-4">
                        <li className="flex items-center gap-3 text-white/90 group/item hover:text-white transition-colors">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-lg group-hover/item:scale-110 transition-transform">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Controle de ordens de serviço</span>
                        </li>
                        <li className="flex items-center gap-3 text-white/90 group/item hover:text-white transition-colors">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-lg group-hover/item:scale-110 transition-transform">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Gestão de equipes e turnos</span>
                        </li>
                        <li className="flex items-center gap-3 text-white/90 group/item hover:text-white transition-colors">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-lg group-hover/item:scale-110 transition-transform">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Relatórios e analytics</span>
                        </li>
                      </ul>
                    </div>

                    {/* Button */}
                    <div className="relative z-10">
                      <Button
                        disabled={isLoading}
                        className="w-full bg-gradient-to-r from-blue-500 via-blue-600 to-cyan-500 hover:from-blue-600 hover:via-blue-700 hover:to-cyan-600 text-white font-bold py-7 text-lg rounded-2xl shadow-2xl shadow-blue-500/30 hover:shadow-blue-500/50 transition-all duration-500 border border-white/20"
                        data-testid="button-select-clean"
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center">
                            <Loader2 className="mr-3 h-6 w-6 animate-spin" />
                            <span>Carregando...</span>
                          </div>
                        ) : (
                          <div className="flex items-center justify-center gap-3">
                            <span>Acessar OPUS Clean</span>
                            <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                            </svg>
                          </div>
                        )}
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            )}

            {/* OPUS Manutenção Card */}
            {availableModules.includes('maintenance') && (
              <div 
                onClick={() => !isLoading && handleModuleSelect('maintenance')}
                className="group relative h-full"
                data-testid="card-module-maintenance"
              >
                {/* Animated Background Gradient */}
                <div className="absolute inset-0 bg-gradient-to-br from-orange-600/20 via-orange-500/10 to-amber-500/20 rounded-[2rem] blur-2xl opacity-60 group-hover:opacity-100 transition-all duration-700 group-hover:scale-110"></div>
                
                <Card className="relative overflow-hidden border border-white/20 rounded-[2rem] shadow-2xl hover:shadow-orange-500/40 transition-all duration-700 cursor-pointer bg-gradient-to-br from-slate-900/80 via-orange-900/60 to-slate-900/80 backdrop-blur-2xl transform group-hover:scale-[1.02] h-full">
                  {/* Mesh Pattern Overlay */}
                  <div className="absolute inset-0 opacity-5 mix-blend-overlay">
                    <div className="absolute inset-0" style={{
                      backgroundImage: `radial-gradient(circle at 2px 2px, white 1px, transparent 0)`,
                      backgroundSize: '40px 40px'
                    }}></div>
                  </div>
                  
                  {/* Shine Effect */}
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-1000">
                    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-orange-400/10 to-transparent -skew-x-12 translate-x-[-200%] group-hover:translate-x-[200%] transition-transform duration-2000"></div>
                  </div>
                  
                  <CardContent className="relative p-8 md:p-10 flex flex-col h-full min-h-[600px]">
                    {/* Top Decorative Element */}
                    <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-orange-500/10 to-transparent rounded-full blur-3xl"></div>
                    
                    {/* Icon */}
                    <div className="mb-8 flex justify-center relative z-10">
                      <div className="relative">
                        {/* Outer Ring */}
                        <div className="absolute -inset-4 bg-gradient-to-r from-orange-400 via-orange-500 to-amber-400 rounded-full opacity-20 blur-xl group-hover:opacity-40 transition-all duration-700"></div>
                        {/* Icon Circle */}
                        <div className="relative w-28 h-28 rounded-full bg-gradient-to-br from-orange-400 via-orange-500 to-amber-500 flex items-center justify-center shadow-2xl group-hover:shadow-orange-500/50 transition-all duration-500 group-hover:scale-110 border border-white/20">
                          <Wrench className="h-14 w-14 text-white drop-shadow-lg" strokeWidth={2} />
                        </div>
                      </div>
                    </div>

                    {/* Content */}
                    <div className="text-center mb-8 relative z-10">
                      <h2 className="text-4xl md:text-5xl font-extrabold bg-gradient-to-r from-orange-300 via-orange-200 to-amber-300 bg-clip-text text-transparent mb-4 tracking-tight" data-testid="text-module-maintenance-title">
                        OPUS Manutenção
                      </h2>
                      <div className="flex items-center justify-center gap-2 mb-6">
                        <div className="h-px w-12 bg-gradient-to-r from-transparent to-orange-400"></div>
                        <div className="h-1.5 w-1.5 rounded-full bg-orange-400 animate-pulse"></div>
                        <div className="h-px w-12 bg-gradient-to-l from-transparent to-orange-400"></div>
                      </div>
                      <p className="text-lg text-orange-200/80 font-medium" data-testid="text-module-maintenance-description">
                        Gestão de Manutenção Preventiva e Corretiva
                      </p>
                    </div>

                    {/* Features List */}
                    <div className="flex-1 bg-white/5 backdrop-blur-sm rounded-3xl p-6 mb-8 border border-white/10 relative overflow-hidden">
                      <div className="absolute top-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-orange-400/50 to-transparent"></div>
                      <ul className="space-y-4">
                        <li className="flex items-center gap-3 text-white/90 group/item hover:text-white transition-colors">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-lg group-hover/item:scale-110 transition-transform">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Planos de manutenção</span>
                        </li>
                        <li className="flex items-center gap-3 text-white/90 group/item hover:text-white transition-colors">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-lg group-hover/item:scale-110 transition-transform">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Gestão de equipamentos</span>
                        </li>
                        <li className="flex items-center gap-3 text-white/90 group/item hover:text-white transition-colors">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-lg group-hover/item:scale-110 transition-transform">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Calendário de atividades</span>
                        </li>
                      </ul>
                    </div>

                    {/* Button */}
                    <div className="relative z-10">
                      <Button
                        disabled={isLoading}
                        className="w-full bg-gradient-to-r from-orange-500 via-orange-600 to-amber-500 hover:from-orange-600 hover:via-orange-700 hover:to-amber-600 text-white font-bold py-7 text-lg rounded-2xl shadow-2xl shadow-orange-500/30 hover:shadow-orange-500/50 transition-all duration-500 border border-white/20"
                        data-testid="button-select-maintenance"
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center">
                            <Loader2 className="mr-3 h-6 w-6 animate-spin" />
                            <span>Carregando...</span>
                          </div>
                        ) : (
                          <div className="flex items-center justify-center gap-3">
                            <span>Acessar OPUS Manutenção</span>
                            <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                            </svg>
                          </div>
                        )}
                      </Button>
                    </div>
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
