import { useState, useEffect } from "react";
import { useLocation } from "wouter";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import { useToast } from "@/hooks/use-toast";
import { login, setAuthState } from "@/lib/auth";
import { useIsMobile } from "@/hooks/use-mobile";
import { useBranding } from "@/contexts/BrandingContext";
import { LogoImage } from "@/components/logo-image";
import { Mail, Lock, Eye, EyeOff, ArrowRight, Building2 } from "lucide-react";
import aceleraLogo from "@assets/acelera-full-facilities-logo.png";

// Microsoft logo SVG component
const MicrosoftIcon = () => (
  <svg width="20" height="20" viewBox="0 0 23 23" fill="currentColor">
    <path d="M0 0h11v11H0z" fill="#f25022"/>
    <path d="M12 0h11v11H12z" fill="#00a4ef"/>
    <path d="M0 12h11v11H0z" fill="#ffb900"/>
    <path d="M12 12h11v11H12z" fill="#7fba00"/>
  </svg>
);

export default function Login() {
  const [, setLocation] = useLocation();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [credentials, setCredentials] = useState({
    username: "",
    password: ""
  });
  const { toast } = useToast();
  const isMobile = useIsMobile();
  const { branding, isLoading: isBrandingLoading } = useBranding();

  useEffect(() => {
    if (isMobile) {
      setLocation("/login-mobile");
    }
  }, [isMobile, setLocation]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

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
      setIsSubmitting(false);
    }
  };

  const handleMicrosoftLogin = () => {
    window.location.href = "/api/auth/microsoft";
  };

  // Show loading state while branding is being detected
  if (isBrandingLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-slate-600">Carregando...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen w-full relative overflow-hidden bg-gradient-to-br from-slate-50 via-white to-slate-100">
      {/* Top Bar */}
      <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-200">
        <div className="container mx-auto px-6 py-4">
          <Button
            onClick={() => setLocation("/")}
            variant="ghost"
            className="text-slate-700 hover:text-slate-900 gap-2"
            data-testid="button-back-landing"
          >
            <ArrowRight className="w-4 h-4 rotate-180" />
            <span>Voltar</span>
          </Button>
        </div>
      </header>

      {/* Decorative Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute -top-40 -right-40 w-80 h-80 rounded-full opacity-10"
          style={{
            background: "radial-gradient(circle, rgba(59, 130, 246, 0.4) 0%, transparent 70%)",
          }}
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.1, 0.15, 0.1],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        <motion.div
          className="absolute -bottom-40 -left-40 w-96 h-96 rounded-full opacity-10"
          style={{
            background: "radial-gradient(circle, rgba(59, 130, 246, 0.3) 0%, transparent 70%)",
          }}
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.1, 0.15, 0.1],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
      </div>

      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col items-center justify-start p-6 pt-12">
        <div className="w-full max-w-md">
          {/* Logo and Title */}
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="text-center mb-8"
          >
            <LogoImage
              src={branding?.loginLogo}
              fallbackSrc={aceleraLogo}
              alt={branding?.name || "Acelera Full Facilities"}
              className="h-[200px] mx-auto mb-6"
              data-testid="img-login-logo"
            />
            <h1 className="text-3xl font-bold text-slate-900 mb-2">
              Bem-vindo de volta
            </h1>
            <p className="text-slate-600">
              Acesse sua plataforma de facilities management
            </p>
          </motion.div>

          {/* Login Card */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="bg-white rounded-2xl shadow-2xl border border-slate-200 p-8"
          >
            {/* Login Form */}
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">
                  Email ou Usuário
                </label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                  <Input
                    type="text"
                    value={credentials.username}
                    onChange={(e) => setCredentials({ ...credentials, username: e.target.value })}
                    className="pl-11 h-12 border-2 border-slate-300 focus:border-blue-500"
                    placeholder="seu@email.com"
                    required
                    data-testid="input-username"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">
                  Senha
                </label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                  <Input
                    type={showPassword ? "text" : "password"}
                    value={credentials.password}
                    onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                    className="pl-11 pr-11 h-12 border-2 border-slate-300 focus:border-blue-500"
                    placeholder="••••••••"
                    required
                    data-testid="input-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                    data-testid="button-toggle-password"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Checkbox
                    id="remember"
                    checked={rememberMe}
                    onCheckedChange={(checked) => setRememberMe(checked as boolean)}
                    data-testid="checkbox-remember"
                  />
                  <label 
                    htmlFor="remember" 
                    className="text-sm text-slate-600 cursor-pointer select-none"
                  >
                    Lembrar de mim
                  </label>
                </div>
                <button
                  type="button"
                  className="text-sm text-blue-600 hover:text-blue-700 font-semibold"
                  data-testid="link-forgot-password"
                >
                  Esqueci minha senha
                </button>
              </div>

              <Button
                type="submit"
                disabled={isSubmitting}
                className="w-full h-12 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 text-white font-bold text-base shadow-lg shadow-blue-200 hover:shadow-xl transition-all"
                data-testid="button-login"
              >
                {isSubmitting ? (
                  <div className="flex items-center justify-center gap-2">
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    Entrando...
                  </div>
                ) : (
                  <div className="flex items-center justify-center gap-2">
                    Acessar Plataforma
                    <ArrowRight className="w-5 h-5" />
                  </div>
                )}
              </Button>
            </form>

            {/* Footer Links */}
            <div className="mt-6 pt-6 border-t border-slate-200 text-center">
              <p className="text-sm text-slate-600">
                Não tem uma conta?{" "}
                <button 
                  className="text-blue-600 hover:text-blue-700 font-semibold"
                  onClick={() => toast({ title: "Entre em contato com o administrador" })}
                  data-testid="link-signup"
                >
                  Solicite acesso
                </button>
              </p>
            </div>
          </motion.div>

          {/* Security Badge */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="mt-6 text-center"
          >
            <div className="inline-flex items-center gap-2 text-sm text-slate-500">
              <Building2 className="w-4 h-4" />
              <span>Plataforma Enterprise Segura | SSO Disponível</span>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
