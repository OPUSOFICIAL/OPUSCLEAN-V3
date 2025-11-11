import { useState, useEffect, useRef } from "react";
import { useLocation } from "wouter";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { Button } from "@/components/ui/button";
import { 
  ArrowRight, 
  Sparkles, 
  Shield, 
  Zap, 
  BarChart3,
  Clock,
  Users,
  CheckCircle2
} from "lucide-react";
import aceleraLogo from "@assets/acelera-logo.png";

export default function Landing() {
  const [, setLocation] = useLocation();
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const containerRef = useRef<HTMLDivElement>(null);

  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  const springConfig = { damping: 25, stiffness: 150 };
  const mouseXSpring = useSpring(mouseX, springConfig);
  const mouseYSpring = useSpring(mouseY, springConfig);

  const rotateX = useTransform(mouseYSpring, [-0.5, 0.5], ["2deg", "-2deg"]);
  const rotateY = useTransform(mouseXSpring, [-0.5, 0.5], ["-2deg", "2deg"]);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!containerRef.current) return;
      
      const rect = containerRef.current.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width;
      const y = (e.clientY - rect.top) / rect.height;
      
      setMousePosition({ x: e.clientX, y: e.clientY });
      mouseX.set(x - 0.5);
      mouseY.set(y - 0.5);
    };

    window.addEventListener("mousemove", handleMouseMove);
    return () => window.removeEventListener("mousemove", handleMouseMove);
  }, [mouseX, mouseY]);

  const features = [
    {
      icon: Shield,
      title: "Gestão Segura",
      description: "Controle total e segurança em todas as operações"
    },
    {
      icon: Zap,
      title: "Extremamente Rápido",
      description: "Performance otimizada para alta produtividade"
    },
    {
      icon: BarChart3,
      title: "Analytics Avançado",
      description: "Insights em tempo real para decisões inteligentes"
    },
    {
      icon: Clock,
      title: "Economia de Tempo",
      description: "Automatize processos e ganhe eficiência"
    },
    {
      icon: Users,
      title: "Multi-Equipes",
      description: "Gerencie múltiplas equipes e locais"
    },
    {
      icon: CheckCircle2,
      title: "Qualidade Garantida",
      description: "Checklists e validações inteligentes"
    }
  ];

  return (
    <div 
      ref={containerRef}
      className="relative min-h-screen w-full overflow-hidden bg-white"
      data-testid="landing-page"
    >
      {/* Subtle gradient background */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-50 via-white to-cyan-50" />

      {/* Animated gradient orbs */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute top-1/4 -left-1/4 w-[800px] h-[800px] rounded-full"
          style={{
            background: "radial-gradient(circle, rgba(59, 130, 246, 0.08) 0%, transparent 70%)",
            x: useTransform(mouseXSpring, [-0.5, 0.5], [-100, 100]),
            y: useTransform(mouseYSpring, [-0.5, 0.5], [-100, 100]),
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
            background: "radial-gradient(circle, rgba(56, 189, 248, 0.08) 0%, transparent 70%)",
            x: useTransform(mouseXSpring, [-0.5, 0.5], [100, -100]),
            y: useTransform(mouseYSpring, [-0.5, 0.5], [100, -100]),
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
            background: "radial-gradient(circle, rgba(96, 165, 250, 0.06) 0%, transparent 70%)",
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
      {[...Array(20)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-1 h-1 bg-blue-400 rounded-full"
          style={{
            left: `${Math.random() * 100}%`,
            top: `${Math.random() * 100}%`,
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
      <div className="relative z-10 min-h-screen flex flex-col">
        {/* Header */}
        <motion.header
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.6 }}
          className="container mx-auto px-6 py-6 flex justify-between items-center"
        >
          <div className="flex items-center gap-3">
            <img src={aceleraLogo} alt="Acelera" className="h-10" />
          </div>
          <Button 
            onClick={() => setLocation("/login")}
            variant="outline"
            className="border-blue-200 text-blue-700 hover:bg-blue-50"
            data-testid="button-login-header"
          >
            Entrar
          </Button>
        </motion.header>

        {/* Hero Section */}
        <div className="flex-1 container mx-auto px-6 py-20 flex flex-col items-center justify-center text-center">
          <motion.div
            initial={{ scale: 0.95, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="max-w-4xl mx-auto"
          >
            {/* Badge */}
            <motion.div
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-blue-100 to-cyan-100 border border-blue-200 mb-8"
            >
              <Sparkles className="w-4 h-4 text-blue-600" />
              <span className="text-sm font-medium text-blue-700">Plataforma Premium de Gestão</span>
            </motion.div>

            {/* Main Title */}
            <motion.h1
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="text-6xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-blue-600 via-blue-500 to-cyan-500 bg-clip-text text-transparent leading-tight"
            >
              Acelera it
            </motion.h1>
            
            <motion.p
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.5 }}
              className="text-2xl font-semibold text-slate-700 mb-4"
            >
              Full Facilities
            </motion.p>

            <motion.p
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.6 }}
              className="text-xl text-slate-600 mb-12 max-w-3xl mx-auto leading-relaxed"
            >
              Transforme a gestão de facilities com tecnologia de ponta. 
              Automatize processos, monitore em tempo real e eleve a excelência operacional.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.7 }}
              className="flex flex-wrap gap-4 justify-center"
            >
              <Button 
                onClick={() => setLocation("/login")}
                size="lg"
                className="relative overflow-hidden bg-gradient-to-br from-blue-500 via-blue-600 to-cyan-600 hover:from-blue-600 hover:via-blue-700 hover:to-cyan-700 text-white px-8 py-6 text-lg font-semibold group shadow-xl shadow-blue-300/50 border-0 transition-all duration-300 hover:shadow-2xl hover:shadow-blue-400/60 hover:scale-105"
                data-testid="button-start"
              >
                <span className="relative z-10 flex items-center">
                  Começar Agora
                  <ArrowRight className="ml-2 w-5 h-5 transition-transform group-hover:translate-x-1" />
                </span>
                {/* Shine effect */}
                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000" />
              </Button>
            </motion.div>
          </motion.div>

          {/* Features Grid */}
          <motion.div
            initial={{ y: 40, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.9 }}
            className="mt-24 w-full max-w-6xl"
          >
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {features.map((feature, index) => (
                <motion.div
                  key={feature.title}
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ duration: 0.6, delay: 0.9 + index * 0.1 }}
                  whileHover={{ 
                    scale: 1.03,
                    transition: { duration: 0.2 }
                  }}
                  style={{
                    rotateX,
                    rotateY,
                  }}
                  className="group relative overflow-hidden"
                >
                  {/* Card */}
                  <div className="relative h-full p-8 rounded-2xl bg-white border border-blue-100 shadow-lg shadow-blue-100/20 transition-all duration-500 hover:shadow-xl hover:shadow-blue-200/30">
                    {/* Gradient overlay on hover */}
                    <div className="absolute inset-0 bg-gradient-to-br from-blue-50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-2xl" />
                    
                    <div className="relative z-10">
                      {/* Icon */}
                      <div className="mb-4 inline-flex p-3 rounded-xl bg-gradient-to-br from-blue-100 to-cyan-100 text-blue-600 group-hover:scale-110 transition-transform duration-500">
                        <feature.icon className="w-6 h-6" />
                      </div>
                      
                      {/* Content */}
                      <h3 className="text-xl font-semibold text-slate-800 mb-2 group-hover:text-blue-700 transition-colors duration-300">
                        {feature.title}
                      </h3>
                      <p className="text-slate-600 leading-relaxed">
                        {feature.description}
                      </p>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </div>

        {/* Footer */}
        <motion.footer
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 1.2 }}
          className="container mx-auto px-6 py-8 text-center text-slate-500 text-sm border-t border-blue-100"
        >
          © 2025 Acelera it. Todos os direitos reservados.
        </motion.footer>
      </div>
    </div>
  );
}
