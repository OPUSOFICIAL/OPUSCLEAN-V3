import { useState, useEffect } from "react";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { login, setAuthState } from "@/lib/auth";
import { useIsMobile } from "@/hooks/use-mobile";
import { User, Lock, Eye, EyeOff } from "lucide-react";
import opusLogo from "@assets/ChatGPT Image 8 de set. de 2025, 18_10_10_1757366528566.png";

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

  // Redirecionar automaticamente para versão móvel se detectar dispositivo móvel
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
      
      // Aguardar para garantir que o estado foi salvo no localStorage
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Redirecionar baseado no role do usuário usando wouter
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
    <div className="min-h-screen w-full bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 flex items-center justify-center p-2 sm:p-4 overflow-x-hidden">
      {/* Container principal */}
      <div className="w-full max-w-5xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-0 bg-white rounded-2xl shadow-2xl overflow-hidden min-h-[500px]">
        
        {/* Lado esquerdo - Hero Section */}
        <div className="relative bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900 p-4 lg:p-8 flex flex-col justify-center items-center text-white overflow-hidden">
          {/* Background pattern */}
          <div className="absolute inset-0 opacity-10">
            <svg className="w-full h-full" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse">
                  <path d="M 10 0 L 0 0 0 10" fill="none" stroke="currentColor" strokeWidth="0.5"/>
                </pattern>
              </defs>
              <rect width="100" height="100" fill="url(#grid)" />
            </svg>
          </div>
          
          {/* Content */}
          <div className="relative z-10 text-center space-y-4">
            {/* Logo */}
            <div className="mb-6">
              <div className="w-32 h-32 mx-auto bg-white/95 rounded-2xl p-4 shadow-xl">
                <img 
                  src={opusLogo} 
                  alt="OPUS" 
                  className="w-full h-full object-contain"
                />
              </div>
            </div>
            
            {/* Hero Text */}
            <div className="space-y-3">
              <p className="text-lg text-slate-300 max-w-sm mx-auto leading-relaxed">
                Plataforma inteligente para gestão completa de facilities e infraestrutura corporativa
              </p>
            </div>
            
            {/* Features */}
            <div className="grid grid-cols-1 gap-3 mt-6 text-left max-w-sm mx-auto">
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-blue-400 rounded-full"></div>
                <span className="text-sm text-slate-300">Gestão em tempo real</span>
              </div>
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-blue-400 rounded-full"></div>
                <span className="text-sm text-slate-300">Relatórios inteligentes</span>
              </div>
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-blue-400 rounded-full"></div>
                <span className="text-sm text-slate-300">Controle multi-site</span>
              </div>
            </div>
          </div>
          
          {/* Decorative elements */}
          <div className="absolute top-10 right-10 w-32 h-32 bg-blue-500/20 rounded-full blur-2xl"></div>
          <div className="absolute bottom-10 left-10 w-24 h-24 bg-indigo-500/20 rounded-full blur-2xl"></div>
        </div>

        {/* Lado direito - Login Form */}
        <div className="p-6 lg:p-8 flex flex-col justify-center">
          <div className="w-full max-w-sm mx-auto space-y-6">
            
            {/* Header */}
            <div className="text-center space-y-1">
              <h2 className="text-2xl font-bold text-slate-900">Entrar</h2>
              <p className="text-sm text-slate-600">Acesse sua conta para continuar</p>
            </div>

            {/* Login Form */}
            <Card className="border-0 shadow-none">
              <CardContent className="p-0">
                <form onSubmit={handleLogin} className="space-y-4">
                  
                  {/* Username Field */}
                  <div className="space-y-2">
                    <label htmlFor="username" className="text-sm font-medium text-slate-900">
                      Usuário
                    </label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-slate-400" />
                      <Input
                        id="username"
                        data-testid="input-username"
                        type="text"
                        placeholder="Digite seu usuário"
                        value={credentials.username}
                        onChange={(e) => setCredentials(prev => ({ ...prev, username: e.target.value }))}
                        className="pl-11 h-10 border-slate-200 focus:border-blue-500 focus:ring-blue-500 bg-slate-50 focus:bg-white transition-all duration-200"
                        required
                      />
                    </div>
                  </div>

                  {/* Password Field */}
                  <div className="space-y-2">
                    <label htmlFor="password" className="text-sm font-medium text-slate-900">
                      Senha
                    </label>
                    <div className="relative">
                      <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-slate-400" />
                      <Input
                        id="password"
                        data-testid="input-password"
                        type={showPassword ? "text" : "password"}
                        placeholder="Digite sua senha"
                        value={credentials.password}
                        onChange={(e) => setCredentials(prev => ({ ...prev, password: e.target.value }))}
                        className="pl-11 pr-11 h-10 border-slate-200 focus:border-blue-500 focus:ring-blue-500 bg-slate-50 focus:bg-white transition-all duration-200"
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
                    <label className="flex items-center space-x-2 cursor-pointer">
                      <input type="checkbox" className="rounded border-slate-300 text-blue-600 focus:ring-blue-500" />
                      <span className="text-sm text-slate-600">Lembrar-me</span>
                    </label>
                    <a href="#" className="text-sm text-blue-600 hover:text-blue-800 font-medium">
                      Esqueceu a senha?
                    </a>
                  </div>

                  {/* Login Button */}
                  <Button 
                    type="submit" 
                    data-testid="button-login"
                    className="w-full h-10 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-semibold rounded-lg shadow-lg hover:shadow-xl transform hover:scale-[1.02] transition-all duration-200" 
                    disabled={isLoading}
                  >
                    {isLoading ? (
                      <div className="flex items-center space-x-2">
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                        <span>Entrando...</span>
                      </div>
                    ) : (
                      "Entrar"
                    )}
                  </Button>

                </form>
              </CardContent>
            </Card>

            {/* Footer */}
            <div className="text-center space-y-4">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-slate-200"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-white text-slate-500">Precisa de ajuda?</span>
                </div>
              </div>
              
              <p className="text-xs text-slate-500">
                © 2025 OPUS. Todos os direitos reservados.
              </p>
            </div>

          </div>
        </div>

      </div>
    </div>
  );
}