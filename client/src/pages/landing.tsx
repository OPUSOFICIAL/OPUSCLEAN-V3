import { useLocation } from "wouter";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { 
  ArrowRight, 
  Building2, 
  Wrench,
  ClipboardCheck, 
  TrendingUp, 
  Shield, 
  Users,
  BarChart3,
  Clock,
  CheckCircle2,
  Zap,
  MapPin
} from "lucide-react";
import aceleraLogo from "@assets/acelera-full-facilities-logo.png";

export default function Landing() {
  const [, setLocation] = useLocation();

  const stats = [
    { value: "45%", label: "Redução de Custos" },
    { value: "3x", label: "Mais Produtividade" },
    { value: "99%", label: "Uptime Garantido" },
    { value: "24/7", label: "Suporte Enterprise" }
  ];

  const features = [
    {
      icon: Building2,
      title: "Gestão de Facilities",
      description: "Controle completo de múltiplos locais, zonas e equipamentos em uma única plataforma"
    },
    {
      icon: Wrench,
      title: "Manutenção Inteligente",
      description: "Preventiva e corretiva automatizada com notificações e SLA tracking"
    },
    {
      icon: ClipboardCheck,
      title: "Ordens de Serviço",
      description: "Gestão end-to-end com QR codes, fotos, assinaturas e histórico completo"
    },
    {
      icon: TrendingUp,
      title: "Analytics em Tempo Real",
      description: "Dashboards personalizados com métricas de desempenho e ROI"
    },
    {
      icon: Users,
      title: "Gestão de Equipes",
      description: "Controle de colaboradores, turnos, permissões e produtividade"
    },
    {
      icon: Shield,
      title: "Segurança Enterprise",
      description: "SSO, autenticação multi-fator e controle granular de acessos"
    }
  ];

  const benefits = [
    { icon: Clock, text: "Reduza tempo de resposta em até 60%" },
    { icon: BarChart3, text: "Aumente eficiência operacional em 45%" },
    { icon: Zap, text: "Automatize 80% dos processos manuais" },
    { icon: CheckCircle2, text: "Conformidade e auditoria garantidas" }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 via-white to-slate-50">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-slate-200 shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <img src={aceleraLogo} alt="Acelera it" className="h-24" />
            <Button 
              onClick={() => setLocation("/login")}
              variant="outline"
              className="border-slate-300 text-slate-700 hover:bg-slate-50"
              data-testid="button-login-header"
            >
              Acessar Sistema
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-6 py-20">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Left Content */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
          >
            <div className="inline-flex items-center gap-2 px-4 py-2 bg-blue-50 border border-blue-200 rounded-full mb-6">
              <Building2 className="w-4 h-4 text-blue-600" />
              <span className="text-sm font-semibold text-blue-700">Plataforma Enterprise de Facilities Management</span>
            </div>

            <h1 className="text-5xl lg:text-6xl font-bold text-slate-900 mb-6 leading-tight">
              Transforme a Gestão de <span className="text-blue-600">Facilities</span> da sua Empresa
            </h1>

            <p className="text-xl text-slate-600 mb-8 leading-relaxed">
              Plataforma completa para gerenciamento de limpeza, manutenção e facilities. 
              Automatize processos, reduza custos e aumente a eficiência operacional.
            </p>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-10">
              {stats.map((stat, index) => (
                <motion.div
                  key={stat.label}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: 0.2 + index * 0.1 }}
                  className="text-center"
                >
                  <div className="text-3xl font-bold text-blue-600 mb-1">{stat.value}</div>
                  <div className="text-sm text-slate-600 font-medium">{stat.label}</div>
                </motion.div>
              ))}
            </div>

            {/* CTA */}
            <div className="flex flex-wrap gap-4">
              <Button 
                onClick={() => setLocation("/login")}
                size="lg"
                className="bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-700 hover:to-blue-600 text-white font-bold px-8 py-7 text-lg rounded-xl shadow-lg shadow-blue-200 hover:shadow-xl hover:shadow-blue-300 transition-all duration-300 group"
                data-testid="button-start"
              >
                Começar Agora
                <ArrowRight className="ml-2 w-5 h-5 transition-transform group-hover:translate-x-1" />
              </Button>
              <Button 
                onClick={() => setLocation("/login")}
                size="lg"
                variant="outline"
                className="border-2 border-slate-300 text-slate-700 hover:bg-slate-50 font-semibold px-8 py-7 text-lg rounded-xl"
              >
                Ver Demonstração
              </Button>
            </div>
          </motion.div>

          {/* Right Content - Dashboard Preview */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative"
          >
            <div className="relative rounded-2xl border-2 border-slate-200 bg-white shadow-2xl p-6 overflow-hidden">
              {/* Mock Dashboard */}
              <div className="space-y-4">
                <div className="flex items-center justify-between border-b border-slate-200 pb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center">
                      <Building2 className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <div className="text-sm font-semibold text-slate-900">Dashboard Facilities</div>
                      <div className="text-xs text-slate-500">Visão Geral</div>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <div className="w-2 h-2 rounded-full bg-emerald-500"></div>
                    <div className="w-2 h-2 rounded-full bg-slate-300"></div>
                    <div className="w-2 h-2 rounded-full bg-slate-300"></div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-gradient-to-br from-emerald-50 to-white border border-emerald-200 rounded-lg p-4">
                    <div className="text-xs text-emerald-700 font-medium mb-1">OSs Concluídas</div>
                    <div className="text-2xl font-bold text-emerald-600">487</div>
                    <div className="text-xs text-emerald-600 mt-1">↑ 23% vs mês anterior</div>
                  </div>
                  <div className="bg-gradient-to-br from-blue-50 to-white border border-blue-200 rounded-lg p-4">
                    <div className="text-xs text-blue-700 font-medium mb-1">Locais Ativos</div>
                    <div className="text-2xl font-bold text-blue-600">24</div>
                    <div className="text-xs text-blue-600 mt-1">100% cobertura</div>
                  </div>
                </div>

                <div className="bg-gradient-to-br from-slate-50/80 to-white rounded-lg p-4 border border-slate-200">
                  <div className="flex justify-between items-center mb-4">
                    <div className="text-xs font-semibold text-slate-700">Performance por Local</div>
                    <div className="text-xs text-slate-500">Este mês</div>
                  </div>
                  <div className="space-y-3">
                    {[
                      { name: 'Local 1', value: 85 },
                      { name: 'Local 2', value: 72 },
                      { name: 'Local 3', value: 93 }
                    ].map((local, i) => (
                      <div key={i} className="space-y-1.5">
                        <div className="flex items-center justify-between">
                          <div className="text-xs font-medium text-slate-700">{local.name}</div>
                          <div className="text-xs font-bold text-slate-900">{local.value}%</div>
                        </div>
                        <div className="relative h-2.5 bg-gradient-to-r from-slate-100 to-slate-200 rounded-full overflow-hidden shadow-inner">
                          <div 
                            className={`absolute h-full rounded-full transition-all duration-700 ease-out ${
                              local.value >= 80 ? 'bg-gradient-to-r from-emerald-400 via-emerald-500 to-emerald-600' :
                              local.value >= 60 ? 'bg-gradient-to-r from-blue-400 via-blue-500 to-blue-600' :
                              'bg-gradient-to-r from-amber-400 via-amber-500 to-amber-600'
                            }`}
                            style={{ width: `${local.value}%` }}
                          >
                            <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent"></div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
            
            {/* Decorative Element */}
            <div className="absolute -bottom-6 -right-6 w-48 h-48 bg-gradient-to-br from-blue-500/10 to-cyan-500/10 rounded-full blur-3xl"></div>
          </motion.div>
        </div>
      </section>

      {/* Benefits Bar */}
      <section className="bg-gradient-to-r from-blue-600 to-blue-500 py-12">
        <div className="container mx-auto px-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {benefits.map((benefit, index) => (
              <motion.div
                key={benefit.text}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="flex items-center gap-4"
              >
                <div className="w-12 h-12 rounded-lg bg-white/20 flex items-center justify-center flex-shrink-0">
                  <benefit.icon className="w-6 h-6 text-white" />
                </div>
                <p className="text-white font-medium text-sm leading-tight">{benefit.text}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="container mx-auto px-6 py-24">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl font-bold text-slate-900 mb-4">
            Tudo que você precisa para gerenciar suas Facilities
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto">
            Solução completa e integrada para gestão de facilities, manutenção e limpeza em ambientes corporativos
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
            >
              <Card className="p-8 h-full border-2 border-slate-200 hover:border-blue-300 hover:shadow-xl transition-all duration-300 bg-white">
                <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center mb-6 shadow-lg shadow-blue-200">
                  <feature.icon className="w-7 h-7 text-white" />
                </div>
                <h3 className="text-xl font-bold text-slate-900 mb-3">{feature.title}</h3>
                <p className="text-slate-600 leading-relaxed">{feature.description}</p>
              </Card>
            </motion.div>
          ))}
        </div>
      </section>

      {/* CTA Final */}
      <section className="bg-gradient-to-br from-slate-900 to-slate-800 py-20">
        <div className="container mx-auto px-6 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >
            <h2 className="text-4xl font-bold text-white mb-6">
              Pronto para transformar sua gestão de facilities?
            </h2>
            <p className="text-xl text-slate-300 mb-10 max-w-2xl mx-auto">
              Junte-se a centenas de empresas que já otimizaram suas operações com o Acelera it Full Facilities
            </p>
            <Button 
              onClick={() => setLocation("/login")}
              size="lg"
              className="bg-white text-blue-600 hover:bg-slate-100 font-bold px-10 py-7 text-lg rounded-xl shadow-2xl"
            >
              Começar Gratuitamente
              <ArrowRight className="ml-2 w-5 h-5" />
            </Button>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-white border-t border-slate-200 py-8">
        <div className="container mx-auto px-6 text-center">
          <p className="text-slate-600">© 2025 Acelera it Full Facilities. Todos os direitos reservados.</p>
        </div>
      </footer>
    </div>
  );
}
