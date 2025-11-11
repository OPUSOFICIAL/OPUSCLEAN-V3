import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { AlertCircle, Home } from "lucide-react";
import logoPath from "@assets/acelera-full-facilities-logo.png";

export default function SubdomainNotFound() {
  const [, setLocation] = useLocation();

  // Extrair subdomínio da URL para mostrar ao usuário
  const hostname = window.location.hostname;
  const parts = hostname.split('.');
  const subdomain = parts.length >= 3 ? parts[0] : '';

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white dark:from-slate-950 dark:to-slate-900 flex flex-col items-center justify-center px-6">
      {/* Logo */}
      <div className="mb-8">
        <img 
          src={logoPath}
          alt="Acelera Full Facilities Logo"
          className="h-32 w-auto object-contain"
          data-testid="img-logo-not-found"
        />
      </div>

      {/* Erro Icon */}
      <div className="flex items-center justify-center w-24 h-24 rounded-full bg-destructive/10 text-destructive mb-6">
        <AlertCircle className="w-12 h-12" />
      </div>

      {/* Mensagem de Erro */}
      <div className="max-w-md text-center space-y-4">
        <h1 className="text-3xl font-bold text-foreground" data-testid="text-not-found-title">
          Subdomínio Não Encontrado
        </h1>
        
        {subdomain && (
          <p className="text-lg text-muted-foreground" data-testid="text-subdomain-invalid">
            O subdomínio <span className="font-mono font-semibold text-foreground">{subdomain}</span> não existe ou não está configurado.
          </p>
        )}

        <p className="text-muted-foreground" data-testid="text-not-found-description">
          Verifique se o endereço está correto ou entre em contato com o administrador do sistema.
        </p>

        {/* CTAs */}
        <div className="flex flex-col sm:flex-row gap-3 mt-8 justify-center">
          <Button 
            onClick={() => {
              // Redirecionar para domínio principal (sem subdomain)
              const mainDomain = parts.length >= 3 ? parts.slice(1).join('.') : hostname;
              window.location.href = `${window.location.protocol}//${mainDomain}`;
            }}
            variant="default"
            size="lg"
            data-testid="button-go-to-main"
          >
            <Home className="mr-2 h-5 w-5" />
            Ir para Página Principal
          </Button>

          <Button 
            onClick={() => window.location.reload()}
            variant="outline"
            size="lg"
            data-testid="button-reload-page"
          >
            Recarregar Página
          </Button>
        </div>

        {/* Informações de Contato */}
        <div className="mt-12 pt-8 border-t border-border">
          <p className="text-sm text-muted-foreground" data-testid="text-contact-info">
            Precisa de ajuda? Entre em contato com o suporte técnico.
          </p>
        </div>
      </div>
    </div>
  );
}
