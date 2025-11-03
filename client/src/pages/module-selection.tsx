import { useEffect, useState } from "react";
import { useLocation } from "wouter";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Building, Wrench, Loader2 } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { useModule } from "@/contexts/ModuleContext";
import { getAuthState } from "@/lib/auth";

export default function ModuleSelection() {
  const [, setLocation] = useLocation();
  const { setModule } = useModule();
  const [isLoading, setIsLoading] = useState(false);

  // Get available modules for the user
  const { data: modulesData, isLoading: isLoadingModules } = useQuery<{ modules: string[] }>({
    queryKey: ["/api/auth/available-modules"],
  });

  const availableModules = modulesData?.modules || [];

  useEffect(() => {
    // If user only has access to one module, redirect automatically
    if (availableModules.length === 1) {
      const module = availableModules[0] as 'clean' | 'maintenance';
      handleModuleSelect(module);
    }
  }, [availableModules]);

  // Check if user is authenticated
  useEffect(() => {
    const auth = getAuthState();
    if (!auth) {
      setLocation("/login");
    }
  }, [setLocation]);

  const handleModuleSelect = (module: 'clean' | 'maintenance') => {
    setIsLoading(true);
    setModule(module);
    
    // Small delay for better UX
    setTimeout(() => {
      setLocation("/");
    }, 300);
  };

  if (isLoadingModules) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-slate-600">Carregando módulos...</p>
        </div>
      </div>
    );
  }

  // If user only has one module, show loading while redirecting
  if (availableModules.length === 1) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-slate-600">Redirecionando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-slate-100 to-slate-200 flex items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-6xl">
        {/* Header */}
        <div className="text-center mb-16" data-testid="header-module-selection">
          <h1 className="text-5xl md:text-6xl font-bold text-slate-900 mb-4 tracking-tight">
            Plataforma OPUS
          </h1>
          <p className="text-xl text-slate-600 font-medium">
            Selecione o módulo que deseja acessar
          </p>
        </div>

        {/* Module Cards Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12 max-w-5xl mx-auto">
          {/* OPUS Clean Card */}
          {availableModules.includes('clean') && (
            <div 
              onClick={() => !isLoading && handleModuleSelect('clean')}
              className="group relative"
              data-testid="card-module-clean"
            >
              <Card className="relative overflow-hidden border-2 border-slate-200 hover:border-blue-400 shadow-lg hover:shadow-2xl transition-all duration-500 cursor-pointer bg-white">
                {/* Gradient Background Effect */}
                <div className="absolute inset-0 bg-gradient-to-br from-blue-50/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                
                <CardContent className="relative p-10 md:p-12 text-center">
                  {/* Icon */}
                  <div className="mb-8 flex justify-center">
                    <div className="w-32 h-32 rounded-full bg-gradient-to-br from-blue-100 to-blue-200 group-hover:from-blue-200 group-hover:to-blue-300 transition-all duration-500 flex items-center justify-center shadow-md group-hover:shadow-xl group-hover:scale-110">
                      <Building className="h-16 w-16 text-blue-600" strokeWidth={2.5} />
                    </div>
                  </div>

                  {/* Title */}
                  <h2 className="text-3xl md:text-4xl font-bold text-blue-900 mb-4" data-testid="text-module-clean-title">
                    OPUS Clean
                  </h2>

                  {/* Description */}
                  <p className="text-lg text-slate-600 mb-8 font-medium" data-testid="text-module-clean-description">
                    Gestão de Limpeza e Facilities
                  </p>

                  {/* Button */}
                  <Button
                    disabled={isLoading}
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-7 text-lg rounded-xl shadow-md hover:shadow-xl transition-all duration-300 transform hover:scale-105"
                    data-testid="button-select-clean"
                  >
                    {isLoading ? (
                      <>
                        <Loader2 className="mr-2 h-6 w-6 animate-spin" />
                        Carregando...
                      </>
                    ) : (
                      'Acessar OPUS Clean'
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
              className="group relative"
              data-testid="card-module-maintenance"
            >
              <Card className="relative overflow-hidden border-2 border-slate-200 hover:border-orange-400 shadow-lg hover:shadow-2xl transition-all duration-500 cursor-pointer bg-white">
                {/* Gradient Background Effect */}
                <div className="absolute inset-0 bg-gradient-to-br from-orange-50/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                
                <CardContent className="relative p-10 md:p-12 text-center">
                  {/* Icon */}
                  <div className="mb-8 flex justify-center">
                    <div className="w-32 h-32 rounded-full bg-gradient-to-br from-orange-100 to-orange-200 group-hover:from-orange-200 group-hover:to-orange-300 transition-all duration-500 flex items-center justify-center shadow-md group-hover:shadow-xl group-hover:scale-110">
                      <Wrench className="h-16 w-16 text-orange-600" strokeWidth={2.5} />
                    </div>
                  </div>

                  {/* Title */}
                  <h2 className="text-3xl md:text-4xl font-bold text-orange-900 mb-4" data-testid="text-module-maintenance-title">
                    OPUS Manutenção
                  </h2>

                  {/* Description */}
                  <p className="text-lg text-slate-600 mb-8 font-medium" data-testid="text-module-maintenance-description">
                    Gestão de Manutenção
                  </p>

                  {/* Button */}
                  <Button
                    disabled={isLoading}
                    className="w-full bg-orange-600 hover:bg-orange-700 text-white font-bold py-7 text-lg rounded-xl shadow-md hover:shadow-xl transition-all duration-300 transform hover:scale-105"
                    data-testid="button-select-maintenance"
                  >
                    {isLoading ? (
                      <>
                        <Loader2 className="mr-2 h-6 w-6 animate-spin" />
                        Carregando...
                      </>
                    ) : (
                      'Acessar OPUS Manutenção'
                    )}
                  </Button>
                </CardContent>
              </Card>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="text-center text-base text-slate-500 font-medium" data-testid="text-footer">
          Sistema modular de gestão de facilities
        </div>
      </div>
    </div>
  );
}
