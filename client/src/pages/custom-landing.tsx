import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Building2, CheckCircle2, TrendingUp, Shield } from "lucide-react";
import { useBranding } from "@/contexts/BrandingContext";
import logoPath from "@assets/acelera-full-facilities-logo.png";

export default function CustomLanding() {
  const [, setLocation] = useLocation();
  const { branding, isLoading } = useBranding();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-background">
        <div className="text-muted-foreground">Carregando...</div>
      </div>
    );
  }

  const landingTitle = branding?.landingTitle || "Gestão de Facilities Inteligente";
  const landingSubtitle = branding?.landingSubtitle || "Otimize operações, reduza custos e aumente a eficiência da sua empresa";
  const heroImage = branding?.landingHeroImage || null;
  const displayLogo = branding?.homeLogo || branding?.loginLogo || logoPath;

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white dark:from-slate-950 dark:to-slate-900">
      {/* Fixed Frosted Glass Top Bar */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 dark:bg-slate-950/80 backdrop-blur-lg border-b border-border">
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
          <div className="flex items-center -my-4">
            <img 
              src={displayLogo} 
              alt={branding?.name || "Logo"}
              className="h-24 w-auto object-contain"
              data-testid="img-logo-top-bar"
            />
          </div>
          <Button 
            onClick={() => setLocation("/login")}
            variant="default"
            size="default"
            data-testid="button-access-system"
          >
            Acessar Sistema
          </Button>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative pt-32 pb-20 px-6">
        {heroImage && (
          <div className="absolute inset-0 overflow-hidden">
            <img 
              src={heroImage}
              alt="Hero"
              className="w-full h-full object-cover"
              data-testid="img-hero-background"
            />
            <div className="absolute inset-0 bg-gradient-to-b from-slate-900/80 via-slate-900/70 to-slate-900/90" />
          </div>
        )}
        
        <div className={`relative max-w-7xl mx-auto text-center ${heroImage ? 'text-white' : ''}`}>
          <h1 className="text-5xl md:text-6xl font-bold mb-6" data-testid="text-landing-title">
            {landingTitle}
          </h1>
          <p className={`text-xl md:text-2xl mb-10 max-w-3xl mx-auto ${heroImage ? 'text-gray-200' : 'text-muted-foreground'}`} data-testid="text-landing-subtitle">
            {landingSubtitle}
          </p>
          <Button 
            onClick={() => setLocation("/login")}
            size="lg"
            variant={heroImage ? "default" : "default"}
            className="text-lg px-8 py-6"
            data-testid="button-start-now"
          >
            Começar Agora
          </Button>
        </div>
      </section>

      {/* ROI Metrics */}
      <section className="py-16 px-6 bg-white dark:bg-slate-900/50">
        <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8">
          <div className="text-center" data-testid="metric-cost-reduction">
            <div className="text-4xl md:text-5xl font-bold text-primary mb-2">45%</div>
            <div className="text-sm text-muted-foreground">Redução de Custos</div>
          </div>
          <div className="text-center" data-testid="metric-productivity">
            <div className="text-4xl md:text-5xl font-bold text-primary mb-2">3x</div>
            <div className="text-sm text-muted-foreground">Aumento de Produtividade</div>
          </div>
          <div className="text-center" data-testid="metric-uptime">
            <div className="text-4xl md:text-5xl font-bold text-primary mb-2">99%</div>
            <div className="text-sm text-muted-foreground">Disponibilidade</div>
          </div>
          <div className="text-center" data-testid="metric-support">
            <div className="text-4xl md:text-5xl font-bold text-primary mb-2">24/7</div>
            <div className="text-sm text-muted-foreground">Suporte Técnico</div>
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="py-20 px-6">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-16" data-testid="text-benefits-title">
            Benefícios para sua Operação
          </h2>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="text-center" data-testid="benefit-efficiency">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 text-primary mb-4">
                <Building2 className="w-8 h-8" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Gestão Centralizada</h3>
              <p className="text-muted-foreground">
                Controle todas as operações de múltiplos locais em uma única plataforma
              </p>
            </div>

            <div className="text-center" data-testid="benefit-automation">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 text-primary mb-4">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Automação Inteligente</h3>
              <p className="text-muted-foreground">
                Agendamento automático, notificações e relatórios sem esforço manual
              </p>
            </div>

            <div className="text-center" data-testid="benefit-analytics">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 text-primary mb-4">
                <TrendingUp className="w-8 h-8" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Analytics em Tempo Real</h3>
              <p className="text-muted-foreground">
                Dashboards e KPIs para decisões baseadas em dados concretos
              </p>
            </div>

            <div className="text-center" data-testid="benefit-security">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 text-primary mb-4">
                <Shield className="w-8 h-8" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Segurança Enterprise</h3>
              <p className="text-muted-foreground">
                Proteção de dados com criptografia e controle de acesso granular
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Final */}
      <section className="py-20 px-6 bg-gradient-to-r from-primary/10 via-primary/5 to-primary/10">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-6" data-testid="text-cta-title">
            Pronto para Transformar sua Gestão?
          </h2>
          <p className="text-xl text-muted-foreground mb-8" data-testid="text-cta-description">
            Junte-se a centenas de empresas que já otimizaram suas operações
          </p>
          <Button 
            onClick={() => setLocation("/login")}
            size="lg"
            variant="default"
            className="text-lg px-10 py-6"
            data-testid="button-access-platform"
          >
            Acessar Plataforma
          </Button>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 px-6 border-t border-border bg-white dark:bg-slate-900/50">
        <div className="max-w-7xl mx-auto text-center text-sm text-muted-foreground">
          <p data-testid="text-footer">
            © {new Date().getFullYear()} {branding?.name || "Acelera Full Facilities"}. Todos os direitos reservados.
          </p>
        </div>
      </footer>
    </div>
  );
}
