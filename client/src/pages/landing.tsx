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
      className="relative min-h-screen w-full overflow-hidden bg-gradient-to-br from-slate-950 via-blue-950 to-indigo-950"
      data-testid="landing-page"
    >
      {/* Animated gradient orbs */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute top-1/4 -left-1/4 w-[800px] h-[800px] rounded-full opacity-20"
          style={{
            background: "radial-gradient(circle, rgba(59, 130, 246, 0.5) 0%, transparent 70%)",
            x: useTransform(mouseXSpring, [-0.5, 0.5], [-100, 100]),
            y: useTransform(mouseYSpring, [-0.5, 0.5], [-100, 100]),
          }}
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.2, 0.3, 0.2],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        
        <motion.div
          className="absolute bottom-1/4 -right-1/4 w-[600px] h-[600px] rounded-full opacity-20"
          style={{
            background: "radial-gradient(circle, rgba(168, 85, 247, 0.5) 0%, transparent 70%)",
            x: useTransform(mouseXSpring, [-0.5, 0.5], [100, -100]),
            y: useTransform(mouseYSpring, [-0.5, 0.5], [100, -100]),
          }}
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.2, 0.3, 0.2],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />

        <motion.div
          className="absolute top-1/2 left-1/2 w-[400px] h-[400px] rounded-full opacity-10"
          style={{
            background: "radial-gradient(circle, rgba(34, 211, 238, 0.5) 0%, transparent 70%)",
            x: useTransform(mouseXSpring, [-0.5, 0.5], [-50, 50]),
            y: useTransform(mouseYSpring, [-0.5, 0.5], [50, -50]),
          }}
          animate={{
            scale: [1, 1.3, 1],
            opacity: [0.1, 0.2, 0.1],
          }}
          transition={{
            duration: 6,
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
            opacity: [0, 1, 0],
          }}
          transition={{
            duration: 3 + Math.random() * 2,
            repeat: Infinity,
            delay: Math.random() * 2,
          }}
        />
      ))}

      {/* Main content */}
      <div className="relative z-10 flex flex-col items-center justify-center min-h-screen px-4 py-12">
        {/* Logo and brand */}
        <motion.div
          initial={{ opacity: 0, y: -50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-8"
        >
          <motion.div
            className="inline-flex items-center justify-center mb-4"
            style={{ rotateX, rotateY }}
          >
            <div className="relative">
              <motion.div
                className="absolute inset-0 blur-3xl opacity-50"
                animate={{
                  background: [
                    "radial-gradient(circle, rgba(59, 130, 246, 0.8) 0%, transparent 70%)",
                    "radial-gradient(circle, rgba(168, 85, 247, 0.8) 0%, transparent 70%)",
                    "radial-gradient(circle, rgba(59, 130, 246, 0.8) 0%, transparent 70%)",
                  ]
                }}
                transition={{ duration: 4, repeat: Infinity }}
              />
              <h1 className="relative text-7xl md:text-8xl font-black text-transparent bg-clip-text bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400">
                Acelera it
              </h1>
            </div>
          </motion.div>
          
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3, duration: 0.8 }}
            className="text-xl md:text-2xl text-blue-200 font-light tracking-wide"
          >
            Full Facilities
          </motion.p>
        </motion.div>

        {/* Hero text */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5, duration: 0.8 }}
          className="text-center max-w-4xl mb-12"
        >
          <h2 className="text-4xl md:text-6xl font-bold text-white mb-6 leading-tight">
            Transforme a Gestão de
            <span className="block mt-2 text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-blue-600">
              Facilities em Excelência
            </span>
          </h2>
          <p className="text-lg md:text-xl text-slate-300 leading-relaxed">
            Plataforma completa para gerenciamento de limpeza e manutenção.
            Controle total, eficiência máxima e resultados mensuráveis.
          </p>
        </motion.div>

        {/* CTA Buttons */}
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.7, duration: 0.5 }}
          className="flex flex-col sm:flex-row gap-4 mb-16"
        >
          <motion.div
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <Button
              size="lg"
              onClick={() => setLocation("/login")}
              className="group relative px-8 py-6 text-lg font-semibold bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 border-0 shadow-2xl shadow-blue-500/50"
              data-testid="button-login"
            >
              <span className="relative z-10 flex items-center gap-2">
                Entrar no Sistema
                <ArrowRight className="w-5 h-5 transition-transform group-hover:translate-x-1" />
              </span>
              <motion.div
                className="absolute inset-0 rounded-md opacity-0 group-hover:opacity-100"
                style={{
                  background: "radial-gradient(circle at center, rgba(255,255,255,0.2) 0%, transparent 70%)",
                }}
                transition={{ duration: 0.3 }}
              />
            </Button>
          </motion.div>

          <motion.div
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <Button
              size="lg"
              variant="outline"
              className="px-8 py-6 text-lg font-semibold bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20"
            >
              <Sparkles className="w-5 h-5 mr-2" />
              Saiba Mais
            </Button>
          </motion.div>
        </motion.div>

        {/* Features grid */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9, duration: 0.8 }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl w-full"
        >
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1 + index * 0.1, duration: 0.5 }}
              whileHover={{ scale: 1.05, y: -5 }}
              className="group relative"
            >
              <div className="relative h-full p-6 rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 hover:border-white/20 transition-all duration-300">
                {/* Glow effect on hover */}
                <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-blue-500/0 to-purple-500/0 group-hover:from-blue-500/10 group-hover:to-purple-500/10 transition-all duration-300" />
                
                <div className="relative z-10">
                  <div className="inline-flex p-3 rounded-xl bg-gradient-to-br from-blue-500/20 to-purple-500/20 mb-4 group-hover:scale-110 transition-transform duration-300">
                    <feature.icon className="w-6 h-6 text-blue-300" />
                  </div>
                  
                  <h3 className="text-xl font-semibold text-white mb-2">
                    {feature.title}
                  </h3>
                  
                  <p className="text-slate-400 text-sm leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Footer text */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5, duration: 0.8 }}
          className="mt-16 text-center"
        >
          <p className="text-slate-500 text-sm">
            © 2025 Acelera it. Plataforma de gestão de facilities de última geração.
          </p>
        </motion.div>
      </div>

      {/* Mesh gradient overlay */}
      <div 
        className="absolute inset-0 opacity-30 pointer-events-none"
        style={{
          backgroundImage: `
            linear-gradient(to right, rgba(59, 130, 246, 0.1) 1px, transparent 1px),
            linear-gradient(to bottom, rgba(59, 130, 246, 0.1) 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px'
        }}
      />
    </div>
  );
}
