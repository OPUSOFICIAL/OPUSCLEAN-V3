import { useEffect, useState } from "react";
import { useLocation } from "wouter";
import { motion } from "framer-motion";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Building, Wrench, Loader2, Sparkles, ArrowRight } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { useModule } from "@/contexts/ModuleContext";
import { useAuth } from "@/hooks/useAuth";
import aceleraLogo from "@assets/acelera-logo.png";

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
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-cyan-50 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-slate-700">Carregando módulos...</p>
        </div>
      </div>
    );
  }

  if (availableModules.length === 1) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-cyan-50 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-slate-700">Redirecionando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white relative overflow-hidden">
      {/* Subtle gradient background */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-50 via-white to-cyan-50" />

      {/* Animated gradient orbs */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute top-1/4 -left-1/4 w-[800px] h-[800px] rounded-full"
          style={{
            background: "radial-gradient(circle, rgba(59, 130, 246, 0.08) 0%, transparent 70%)",
          }}
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        
        <motion.div
          className="absolute bottom-1/4 -right-1/4 w-[600px] h-[600px] rounded-full"
          style={{
            background: "radial-gradient(circle, rgba(251, 146, 60, 0.08) 0%, transparent 70%)",
          }}
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />

        <motion.div
          className="absolute top-1/2 left-1/2 w-[400px] h-[400px] rounded-full"
          style={{
            background: "radial-gradient(circle, rgba(34, 211, 238, 0.06) 0%, transparent 70%)",
          }}
          animate={{
            scale: [1, 1.3, 1],
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{
            duration: 7,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
      </div>

      {/* Floating particles */}
      {[...Array(15)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-1 h-1 rounded-full"
          style={{
            left: `${Math.random() * 100}%`,
            top: `${Math.random() * 100}%`,
            backgroundColor: i % 2 === 0 ? 'rgba(59, 130, 246, 0.4)' : 'rgba(251, 146, 60, 0.4)'
          }}
          animate={{
            y: [0, -30, 0],
            opacity: [0, 0.6, 0],
          }}
          transition={{
            duration: 3 + Math.random() * 2,
            repeat: Infinity,
            delay: Math.random() * 2,
          }}
        />
      ))}

      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col items-center justify-center p-4 md:p-8">
        <div className="w-full max-w-6xl">
          {/* Header with Logo */}
          <motion.div
            initial={{ y: -20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.6 }}
            className="text-center mb-12"
            data-testid="header-module-selection"
          >
            <img 
              src={aceleraLogo} 
              alt="Acelera Full Facilities" 
              className="h-24 mx-auto mb-8 drop-shadow-lg"
            />
            <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-blue-600 to-blue-500 bg-clip-text text-transparent mb-4 tracking-tight flex items-center justify-center gap-3">
              <Sparkles className="w-10 h-10 text-blue-500" />
              Escolha seu Módulo
              <Sparkles className="w-10 h-10 text-blue-500" />
            </h1>
            <p className="text-xl text-slate-600">
              Selecione qual área você deseja acessar
            </p>
          </motion.div>

          {/* Module Cards Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12 max-w-7xl mx-auto px-4">
            {/* Clean Module Card */}
            {availableModules.includes('clean') && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
                onClick={() => !isLoading && handleModuleSelect('clean')}
                className="group relative h-full cursor-pointer"
                data-testid="card-module-clean"
              >
                <Card className="relative overflow-hidden border-2 border-blue-200 rounded-3xl shadow-xl hover:shadow-2xl hover:shadow-blue-200/50 transition-all duration-500 bg-white transform hover:scale-[1.02] h-full">
                  {/* Gradient overlay on hover */}
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-50 to-cyan-50 opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-3xl" />
                  
                  <CardContent className="relative p-8 md:p-10 flex flex-col h-full min-h-[500px]">
                    {/* Icon */}
                    <div className="mb-8 flex justify-center relative z-10">
                      <div className="relative">
                        <div className="absolute -inset-4 bg-gradient-to-r from-blue-400 to-cyan-400 rounded-full opacity-20 blur-xl group-hover:opacity-40 transition-all duration-700"></div>
                        <div className="relative w-28 h-28 rounded-full bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center shadow-lg group-hover:shadow-xl group-hover:shadow-blue-300 transition-all duration-500 group-hover:scale-110">
                          <Building className="h-14 w-14 text-white drop-shadow-lg" strokeWidth={2} />
                        </div>
                      </div>
                    </div>

                    {/* Content */}
                    <div className="text-center mb-8 relative z-10">
                      <h2 className="text-4xl md:text-5xl font-extrabold bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent mb-4 tracking-tight" data-testid="text-module-clean-title">
                        Acelera Clean
                      </h2>
                      <div className="flex items-center justify-center gap-2 mb-6">
                        <div className="h-px w-12 bg-gradient-to-r from-transparent to-blue-400"></div>
                        <div className="h-1.5 w-1.5 rounded-full bg-blue-500 animate-pulse"></div>
                        <div className="h-px w-12 bg-gradient-to-l from-transparent to-blue-400"></div>
                      </div>
                      <p className="text-lg text-slate-600 font-medium" data-testid="text-module-clean-description">
                        Gestão de Limpeza e Facilities
                      </p>
                    </div>

                    {/* Features List */}
                    <div className="flex-1 bg-blue-50/50 rounded-2xl p-6 mb-8 border border-blue-100">
                      <ul className="space-y-4">
                        <li className="flex items-center gap-3 text-slate-700">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Controle de ordens de serviço</span>
                        </li>
                        <li className="flex items-center gap-3 text-slate-700">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Gestão de equipes e turnos</span>
                        </li>
                        <li className="flex items-center gap-3 text-slate-700">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md">
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
                        className="w-full bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 text-white font-bold py-7 text-lg rounded-2xl shadow-lg shadow-blue-200 hover:shadow-xl hover:shadow-blue-300 transition-all duration-500 group"
                        data-testid="button-select-clean"
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center">
                            <Loader2 className="mr-3 h-6 w-6 animate-spin" />
                            <span>Carregando...</span>
                          </div>
                        ) : (
                          <div className="flex items-center justify-center gap-3">
                            <span>Acessar Acelera Clean</span>
                            <ArrowRight className="w-5 h-5 transition-transform group-hover:translate-x-1" />
                          </div>
                        )}
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            )}

            {/* Maintenance Module Card */}
            {availableModules.includes('maintenance') && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.3 }}
                onClick={() => !isLoading && handleModuleSelect('maintenance')}
                className="group relative h-full cursor-pointer"
                data-testid="card-module-maintenance"
              >
                <Card className="relative overflow-hidden border-2 border-orange-200 rounded-3xl shadow-xl hover:shadow-2xl hover:shadow-orange-200/50 transition-all duration-500 bg-white transform hover:scale-[1.02] h-full">
                  {/* Gradient overlay on hover */}
                  <div className="absolute inset-0 bg-gradient-to-br from-orange-50 to-amber-50 opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-3xl" />
                  
                  <CardContent className="relative p-8 md:p-10 flex flex-col h-full min-h-[500px]">
                    {/* Icon */}
                    <div className="mb-8 flex justify-center relative z-10">
                      <div className="relative">
                        <div className="absolute -inset-4 bg-gradient-to-r from-orange-400 to-amber-400 rounded-full opacity-20 blur-xl group-hover:opacity-40 transition-all duration-700"></div>
                        <div className="relative w-28 h-28 rounded-full bg-gradient-to-br from-orange-500 to-amber-500 flex items-center justify-center shadow-lg group-hover:shadow-xl group-hover:shadow-orange-300 transition-all duration-500 group-hover:scale-110">
                          <Wrench className="h-14 w-14 text-white drop-shadow-lg" strokeWidth={2} />
                        </div>
                      </div>
                    </div>

                    {/* Content */}
                    <div className="text-center mb-8 relative z-10">
                      <h2 className="text-4xl md:text-5xl font-extrabold bg-gradient-to-r from-orange-600 to-amber-600 bg-clip-text text-transparent mb-4 tracking-tight" data-testid="text-module-maintenance-title">
                        Acelera Manutenção
                      </h2>
                      <div className="flex items-center justify-center gap-2 mb-6">
                        <div className="h-px w-12 bg-gradient-to-r from-transparent to-orange-400"></div>
                        <div className="h-1.5 w-1.5 rounded-full bg-orange-500 animate-pulse"></div>
                        <div className="h-px w-12 bg-gradient-to-l from-transparent to-orange-400"></div>
                      </div>
                      <p className="text-lg text-slate-600 font-medium" data-testid="text-module-maintenance-description">
                        Gestão de Manutenção Preventiva e Corretiva
                      </p>
                    </div>

                    {/* Features List */}
                    <div className="flex-1 bg-orange-50/50 rounded-2xl p-6 mb-8 border border-orange-100">
                      <ul className="space-y-4">
                        <li className="flex items-center gap-3 text-slate-700">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-md">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Planos de manutenção</span>
                        </li>
                        <li className="flex items-center gap-3 text-slate-700">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-md">
                            <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                          </div>
                          <span className="font-semibold text-base">Gestão de equipamentos</span>
                        </li>
                        <li className="flex items-center gap-3 text-slate-700">
                          <div className="flex-shrink-0 w-7 h-7 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-md">
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
                        className="w-full bg-gradient-to-r from-orange-600 to-orange-500 hover:from-orange-700 hover:to-orange-600 text-white font-bold py-7 text-lg rounded-2xl shadow-lg shadow-orange-200 hover:shadow-xl hover:shadow-orange-300 transition-all duration-500 group"
                        data-testid="button-select-maintenance"
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center">
                            <Loader2 className="mr-3 h-6 w-6 animate-spin" />
                            <span>Carregando...</span>
                          </div>
                        ) : (
                          <div className="flex items-center justify-center gap-3">
                            <span>Acessar Acelera Manutenção</span>
                            <ArrowRight className="w-5 h-5 transition-transform group-hover:translate-x-1" />
                          </div>
                        )}
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            )}
          </div>

          {/* Footer */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.5 }}
            className="text-center space-y-4"
          >
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-blue-200"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-4 bg-white text-slate-600">Sistema modular de gestão de facilities</span>
              </div>
            </div>
            
            <p className="text-xs text-slate-500">
              © 2025 Acelera it. Todos os direitos reservados.
            </p>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
