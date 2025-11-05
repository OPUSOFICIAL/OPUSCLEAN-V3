import { useModule } from "@/contexts/ModuleContext";

/**
 * Hook para obter classes CSS dinâmicas baseadas no módulo ativo
 * Aplica o design ultra-moderno 2025 com glassmorphism e cores por módulo
 */
export function useModuleTheme() {
  const { currentModule } = useModule();
  
  const isClean = currentModule === 'clean';
  const isMaintenance = currentModule === 'maintenance';
  
  return {
    // Cores primárias do módulo
    primary: isClean ? 'blue' : 'orange',
    primaryHex: isClean ? '#3B82F6' : '#F97316',
    
    // Gradientes modernos
    gradients: {
      // Gradiente sutil para backgrounds
      subtle: isClean 
        ? 'bg-gradient-to-br from-blue-50/50 via-white to-slate-50' 
        : 'bg-gradient-to-br from-orange-50/50 via-white to-slate-50',
      
      // Gradiente para headers/títulos
      header: isClean
        ? 'bg-gradient-to-r from-blue-600 to-blue-700'
        : 'bg-gradient-to-r from-orange-600 to-orange-700',
        
      // Gradiente para cards especiais
      card: isClean
        ? 'bg-gradient-to-br from-white via-blue-50/20 to-slate-50/50'
        : 'bg-gradient-to-br from-white via-orange-50/20 to-slate-50/50',
        
      // Gradiente para stats cards
      stat: isClean
        ? 'bg-gradient-to-br from-blue-500 to-blue-600'
        : 'bg-gradient-to-br from-orange-500 to-orange-600',
    },
    
    // Sombras coloridas
    shadows: {
      // Sombra sutil para cards
      card: isClean
        ? 'shadow-lg shadow-blue-500/10 hover:shadow-blue-500/20'
        : 'shadow-lg shadow-orange-500/10 hover:shadow-orange-500/20',
        
      // Sombra para botões
      button: isClean
        ? 'shadow-md shadow-blue-600/30'
        : 'shadow-md shadow-orange-600/30',
        
      // Sombra intensa
      intense: isClean
        ? 'shadow-2xl shadow-blue-500/30'
        : 'shadow-2xl shadow-orange-500/30',
    },
    
    // Botões primários
    buttons: {
      primary: isClean
        ? 'bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white shadow-lg shadow-blue-600/30 hover:shadow-blue-600/50 transition-all duration-300 hover:scale-105'
        : 'bg-gradient-to-r from-orange-600 to-orange-700 hover:from-orange-700 hover:to-orange-800 text-white shadow-lg shadow-orange-600/30 hover:shadow-orange-600/50 transition-all duration-300 hover:scale-105',
        
      outline: isClean
        ? 'border-2 border-blue-200 hover:border-blue-400 hover:bg-blue-50/50 text-blue-700 transition-all duration-200'
        : 'border-2 border-orange-200 hover:border-orange-400 hover:bg-orange-50/50 text-orange-700 transition-all duration-200',
    },
    
    // Badges/Tags
    badges: {
      primary: isClean
        ? 'bg-blue-100 text-blue-700 border border-blue-200'
        : 'bg-orange-100 text-orange-700 border border-orange-200',
        
      light: isClean
        ? 'bg-blue-50 text-blue-600'
        : 'bg-orange-50 text-orange-600',
    },
    
    // Cards com glassmorphism
    cards: {
      // Card padrão ultra-moderno
      modern: `backdrop-blur-xl bg-white/80 border border-slate-200/60 rounded-2xl ${
        isClean 
          ? 'shadow-xl shadow-blue-500/10 hover:shadow-blue-500/20' 
          : 'shadow-xl shadow-orange-500/10 hover:shadow-orange-500/20'
      } transition-all duration-300 hover:scale-[1.01]`,
      
      // Card com gradiente sutil
      gradient: isClean
        ? 'backdrop-blur-xl bg-gradient-to-br from-white via-blue-50/30 to-slate-50/50 border border-blue-100 rounded-2xl shadow-xl shadow-blue-500/10 hover:shadow-blue-500/20 transition-all duration-300'
        : 'backdrop-blur-xl bg-gradient-to-br from-white via-orange-50/30 to-slate-50/50 border border-orange-100 rounded-2xl shadow-xl shadow-orange-500/10 hover:shadow-orange-500/20 transition-all duration-300',
        
      // Card de destaque
      featured: isClean
        ? 'relative overflow-hidden backdrop-blur-2xl bg-gradient-to-br from-blue-500/90 to-blue-600/90 text-white rounded-2xl shadow-2xl shadow-blue-500/30 border border-blue-400/20'
        : 'relative overflow-hidden backdrop-blur-2xl bg-gradient-to-br from-orange-500/90 to-orange-600/90 text-white rounded-2xl shadow-2xl shadow-orange-500/30 border border-orange-400/20',
    },
    
    // Cores de texto
    text: {
      primary: isClean ? 'text-blue-600' : 'text-orange-600',
      light: isClean ? 'text-blue-400' : 'text-orange-400',
      dark: isClean ? 'text-blue-800' : 'text-orange-800',
    },
    
    // Bordas
    borders: {
      primary: isClean ? 'border-blue-200' : 'border-orange-200',
      light: isClean ? 'border-blue-100' : 'border-orange-100',
      accent: isClean ? 'border-l-4 border-l-blue-500' : 'border-l-4 border-l-orange-500',
    },
    
    // Backgrounds
    backgrounds: {
      light: isClean ? 'bg-blue-50' : 'bg-orange-50',
      lighter: isClean ? 'bg-blue-50/50' : 'bg-orange-50/50',
      primary: isClean ? 'bg-blue-600' : 'bg-orange-600',
    },
    
    // Hover effects
    hover: {
      card: isClean
        ? 'hover:border-blue-300/60 hover:shadow-xl hover:shadow-blue-500/15'
        : 'hover:border-orange-300/60 hover:shadow-xl hover:shadow-orange-500/15',
    },
    
    // Animações especiais
    animations: {
      shimmer: 'relative overflow-hidden before:absolute before:inset-0 before:-translate-x-full before:animate-[shimmer_2s_infinite] before:bg-gradient-to-r before:from-transparent before:via-white/10 before:to-transparent',
      pulse: isClean
        ? 'animate-pulse bg-blue-100/50'
        : 'animate-pulse bg-orange-100/50',
    }
  };
}
