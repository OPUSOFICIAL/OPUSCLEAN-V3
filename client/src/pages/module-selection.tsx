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
      handleModuleSelect(availableModules[0]);
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
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 flex items-center justify-center p-4">
      <div className="w-full max-w-4xl">
        {/* Header */}
        <div className="text-center mb-12" data-testid="header-module-selection">
          <h1 className="text-4xl font-bold text-slate-900 mb-3">
            Plataforma OPUS
          </h1>
          <p className="text-lg text-slate-600">
            Selecione o módulo que deseja acessar
          </p>
        </div>

        {/* Module Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* OPUS Clean Card */}
          {availableModules.includes('clean') && (
            <Card 
              className="border-2 border-slate-200 hover:border-blue-400 hover:shadow-xl transition-all duration-300 cursor-pointer group"
              data-testid="card-module-clean"
            >
              <CardContent className="p-8 text-center">
                {/* Icon */}
                <div className="mb-6 flex justify-center">
                  <div className="w-24 h-24 rounded-full bg-blue-100 group-hover:bg-blue-200 transition-colors duration-300 flex items-center justify-center">
                    <Building className="h-12 w-12 text-blue-600" />
                  </div>
                </div>

                {/* Title */}
                <h2 className="text-2xl font-bold text-blue-900 mb-3" data-testid="text-module-clean-title">
                  OPUS Clean
                </h2>

                {/* Description */}
                <p className="text-slate-600 mb-6" data-testid="text-module-clean-description">
                  Gestão de Limpeza e Facilities
                </p>

                {/* Button */}
                <Button
                  onClick={() => handleModuleSelect('clean')}
                  disabled={isLoading}
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-6 text-lg transition-colors duration-200"
                  data-testid="button-select-clean"
                >
                  {isLoading ? (
                    <>
                      <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                      Carregando...
                    </>
                  ) : (
                    'Acessar OPUS Clean'
                  )}
                </Button>
              </CardContent>
            </Card>
          )}

          {/* OPUS Manutenção Card */}
          {availableModules.includes('maintenance') && (
            <Card 
              className="border-2 border-slate-200 hover:border-orange-400 hover:shadow-xl transition-all duration-300 cursor-pointer group"
              data-testid="card-module-maintenance"
            >
              <CardContent className="p-8 text-center">
                {/* Icon */}
                <div className="mb-6 flex justify-center">
                  <div className="w-24 h-24 rounded-full bg-orange-100 group-hover:bg-orange-200 transition-colors duration-300 flex items-center justify-center">
                    <Wrench className="h-12 w-12 text-orange-600" />
                  </div>
                </div>

                {/* Title */}
                <h2 className="text-2xl font-bold text-orange-900 mb-3" data-testid="text-module-maintenance-title">
                  OPUS Manutenção
                </h2>

                {/* Description */}
                <p className="text-slate-600 mb-6" data-testid="text-module-maintenance-description">
                  Gestão de Manutenção
                </p>

                {/* Button */}
                <Button
                  onClick={() => handleModuleSelect('maintenance')}
                  disabled={isLoading}
                  className="w-full bg-orange-600 hover:bg-orange-700 text-white font-semibold py-6 text-lg transition-colors duration-200"
                  data-testid="button-select-maintenance"
                >
                  {isLoading ? (
                    <>
                      <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                      Carregando...
                    </>
                  ) : (
                    'Acessar OPUS Manutenção'
                  )}
                </Button>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Footer */}
        <div className="text-center text-sm text-slate-500" data-testid="text-footer">
          Sistema modular de gestão de facilities
        </div>
      </div>
    </div>
  );
}
