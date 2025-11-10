import { useState, useEffect } from "react";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { login, setAuthState } from "@/lib/auth";
import { useIsMobile } from "@/hooks/use-mobile";
import { User, Lock, Eye, EyeOff, Building2, Settings, TrendingUp, Shield, CheckCircle2 } from "lucide-react";
import aceleraLogo from "@assets/imagem_2025-11-10_010501695-Photoroom_1762805733799.png";

export default function Login() {
  const [, setLocation] = useLocation();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [credentials, setCredentials] = useState({
    username: "",
    password: ""
  });
  const { toast } = useToast();
  const isMobile = useIsMobile();

  useEffect(() => {
    if (isMobile) {
      setLocation("/login-mobile");
    }
  }, [isMobile, setLocation]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      const { user, token } = await login(credentials);
      setAuthState(user, token);
      
      toast({
        title: "Login realizado com sucesso",
        description: `Bem-vindo, ${user.name}!`,
      });
      
      await new Promise(resolve => setTimeout(resolve, 500));
      
      try {
        const modulesResponse = await fetch("/api/auth/user-modules", {
          headers: {
            "Authorization": `Bearer ${token}`,
          },
        });
        const modulesData = await modulesResponse.json();
        const availableModules = modulesData.modules || [];
        
        if (availableModules.length > 1) {
          setLocation("/module-selection");
          return;
        }
      } catch (error) {
        console.error("Error checking available modules:", error);
      }
      
      if (user.role === 'operador') {
        setLocation("/mobile");
      } else {
        setLocation("/");
      }
    } catch (error) {
      toast({
        title: "Erro no login",
        description: "Verifique suas credenciais e tente novamente.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Branding & Visual */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900 relative overflow-hidden">
        {/* Animated Background Elements */}
        <div className="absolute inset-0">
          {/* Grid Pattern */}
          <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImdyaWQiIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTSAxMCAwIEwgMCAwIDAgMTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0id2hpdGUiIHN0cm9rZS1vcGFjaXR5PSIwLjA1IiBzdHJva2Utd2lkdGg9IjEiLz48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InVybCgjZ3JpZCkiLz48L3N2Zz4=')] opacity-30"></div>
          
          {/* Gradient Orbs */}
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse"></div>
          <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-pulse" style={{ animationDelay: '2s' }}></div>
        </div>

        {/* Content */}
        <div className="relative z-10 flex flex-col justify-center px-16 w-full">
          {/* Logo */}
          <div className="mb-12">
            <img 
              src={aceleraLogo} 
              alt="Acelera Full Facilities" 
              className="h-[400px] drop-shadow-2xl mt-[-40px] mb-[-40px]"
            />
            <h1 className="text-5xl font-bold text-white mb-4 leading-tight">
              Gestão Inteligente de Facilities
            </h1>
            <p className="text-xl text-blue-100 leading-relaxed">
              Plataforma completa para otimizar operações, reduzir custos e elevar a excelência na gestão de facilities e infraestrutura corporativa
            </p>
          </div>

          {/* Features */}
          <div className="space-y-6">
            <div className="flex items-start space-x-4 group">
              <div className="p-3 bg-white/10 backdrop-blur-sm rounded-lg group-hover:bg-white/20 transition-all duration-300">
                <Building2 className="w-6 h-6 text-blue-200" />
              </div>
              <div>
                <h3 className="text-white font-semibold mb-1">Multi-Site Management</h3>
                <p className="text-blue-100 text-sm">Gerencie múltiplos locais, zonas e equipes em uma única plataforma integrada</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 group">
              <div className="p-3 bg-white/10 backdrop-blur-sm rounded-lg group-hover:bg-white/20 transition-all duration-300">
                <TrendingUp className="w-6 h-6 text-blue-200" />
              </div>
              <div>
                <h3 className="text-white font-semibold mb-1">Analytics em Tempo Real</h3>
                <p className="text-blue-100 text-sm">Dashboards inteligentes com métricas e KPIs para decisões estratégicas</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 group">
              <div className="p-3 bg-white/10 backdrop-blur-sm rounded-lg group-hover:bg-white/20 transition-all duration-300">
                <Settings className="w-6 h-6 text-blue-200" />
              </div>
              <div>
                <h3 className="text-white font-semibold mb-1">Manutenção Inteligente</h3>
                <p className="text-blue-100 text-sm">Planejamento preventivo e corretivo com gestão completa de ordens de serviço</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 group">
              <div className="p-3 bg-white/10 backdrop-blur-sm rounded-lg group-hover:bg-white/20 transition-all duration-300">
                <Shield className="w-6 h-6 text-blue-200" />
              </div>
              <div>
                <h3 className="text-white font-semibold mb-1">Segurança & Compliance</h3>
                <p className="text-blue-100 text-sm">Controles de acesso, auditoria e conformidade com padrões internacionais</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      {/* Right Side - Login Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8 bg-slate-50">
        <div className="w-full max-w-md">
          {/* Mobile Logo */}
          <div className="lg:hidden mb-8 text-center">
            <img 
              src={aceleraLogo} 
              alt="Acelera Full Facilities" 
              className="h-12 mx-auto mb-4"
            />
          </div>

          <Card className="border-0 shadow-2xl">
            <CardContent className="p-8">
              {/* Header */}
              <div className="text-center mb-8">
                <h2 className="text-3xl font-bold text-slate-900 mb-2">Bem-vindo</h2>
                <p className="text-slate-600">Acesse sua conta para continuar</p>
              </div>

              {/* Login Form */}
              <form onSubmit={handleLogin} className="space-y-6">
                {/* Username Field */}
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Usuário
                  </label>
                  <div className="relative">
                    <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-slate-400" />
                    <Input
                      type="text"
                      data-testid="input-username"
                      placeholder="Digite seu usuário"
                      value={credentials.username}
                      onChange={(e) => setCredentials({ ...credentials, username: e.target.value })}
                      className="pl-10 h-12 bg-white border-slate-200 focus:border-blue-500 focus:ring-blue-500"
                      required
                    />
                  </div>
                </div>

                {/* Password Field */}
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Senha
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-slate-400" />
                    <Input
                      type={showPassword ? "text" : "password"}
                      data-testid="input-password"
                      placeholder="Digite sua senha"
                      value={credentials.password}
                      onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                      className="pl-10 pr-12 h-12 bg-white border-slate-200 focus:border-blue-500 focus:ring-blue-500"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                      tabIndex={-1}
                    >
                      {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                    </button>
                  </div>
                </div>

                {/* Remember me & Forgot password */}
                <div className="flex items-center justify-between">
                  <label className="flex items-center space-x-2 cursor-pointer group">
                    <input 
                      type="checkbox" 
                      className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500 cursor-pointer" 
                    />
                    <span className="text-sm text-slate-600 group-hover:text-slate-900 transition-colors">Lembrar-me</span>
                  </label>
                  <a href="#" className="text-sm text-blue-600 hover:text-blue-700 font-medium transition-colors">
                    Esqueceu a senha?
                  </a>
                </div>

                {/* Login Button */}
                <Button 
                  type="submit" 
                  data-testid="button-login"
                  className="w-full h-12 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-semibold shadow-lg hover:shadow-xl transition-all duration-200" 
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <div className="flex items-center space-x-2">
                      <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                      <span>Entrando...</span>
                    </div>
                  ) : (
                    <div className="flex items-center justify-center space-x-2">
                      <span>Entrar</span>
                      <CheckCircle2 className="w-5 h-5" />
                    </div>
                  )}
                </Button>
              </form>

              {/* Divider */}
              <div className="relative my-8">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-slate-200"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-white text-slate-500">Precisa de ajuda?</span>
                </div>
              </div>

              {/* Support */}
              <div className="text-center">
                <p className="text-sm text-slate-600">
                  Entre em contato com o{" "}
                  <a href="#" className="text-blue-600 hover:text-blue-700 font-medium">
                    suporte técnico
                  </a>
                </p>
              </div>
            </CardContent>
          </Card>

          {/* Footer */}
          <div className="text-center mt-8">
            <p className="text-xs text-slate-500">
              © 2025 Acelera Full Facilities. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
