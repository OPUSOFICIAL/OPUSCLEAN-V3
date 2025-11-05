import { useModule } from "@/contexts/ModuleContext";

/**
 * Hook para obter classes CSS dinâmicas baseadas no módulo ativo
 * Design predominantemente BRANCO com cor do módulo como identificação sutil
 */
export function useModuleTheme() {
  const { currentModule } = useModule();
  
  const isClean = currentModule === 'clean';
  const isMaintenance = currentModule === 'maintenance';
  
  return {
    // Cores primárias do módulo (apenas para identificação)
    primary: isClean ? 'blue' : 'orange',
    primaryHex: isClean ? '#3B82F6' : '#F97316',
    
    // Gradientes MODERNOS - predominantemente branco com detalhes sofisticados
    gradients: {
      // Gradiente sutil para backgrounds de páginas
      page: 'bg-gradient-to-br from-white via-slate-50/40 to-slate-100/20',
      
      // Gradiente muito leve para sections
      section: 'bg-gradient-to-b from-white to-slate-50/30',
      
      // Gradiente para headers (cor do módulo)
      header: isClean
        ? 'bg-gradient-to-r from-blue-600 to-blue-700'
        : 'bg-gradient-to-r from-orange-600 to-orange-700',
        
      // Gradiente sutil para cards especiais (glassmorphism)
      glass: isClean
        ? 'bg-gradient-to-br from-white/95 via-blue-50/30 to-white/90 backdrop-blur-sm'
        : 'bg-gradient-to-br from-white/95 via-orange-50/30 to-white/90 backdrop-blur-sm',
        
      // Gradiente para cards destacados (muito sutil)
      cardAccent: isClean
        ? 'bg-gradient-to-br from-white to-blue-50/20'
        : 'bg-gradient-to-br from-white to-orange-50/20',
        
      // Gradiente para stats cards (cor do módulo)
      stat: isClean
        ? 'bg-gradient-to-br from-blue-500 to-blue-600'
        : 'bg-gradient-to-br from-orange-500 to-orange-600',
        
      // Gradiente para hover effects
      hover: isClean
        ? 'hover:bg-gradient-to-br hover:from-white hover:to-blue-50/30'
        : 'hover:bg-gradient-to-br hover:from-white hover:to-orange-50/30',
    },
    
    // Sombras neutras (sem cor)
    shadows: {
      // Sombra sutil para cards - CINZA, não colorida
      card: 'shadow-lg shadow-slate-200/50 hover:shadow-slate-300/60',
        
      // Sombra para botões - apenas no hover
      button: isClean
        ? 'hover:shadow-md hover:shadow-blue-500/20'
        : 'hover:shadow-md hover:shadow-orange-500/20',
        
      // Sombra intensa - CINZA
      intense: 'shadow-xl shadow-slate-300/40',
    },
    
    // Botões - cor do módulo apenas no primário
    buttons: {
      primary: isClean
        ? 'bg-blue-600 hover:bg-blue-700 text-white transition-all duration-200'
        : 'bg-orange-600 hover:bg-orange-700 text-white transition-all duration-200',
        
      outline: isClean
        ? 'border border-blue-600 hover:bg-blue-50 text-blue-600 transition-all duration-200'
        : 'border border-orange-600 hover:bg-orange-50 text-orange-600 transition-all duration-200',
    },
    
    // Badges/Tags - cor sutil do módulo
    badges: {
      primary: isClean
        ? 'bg-blue-50 text-blue-700 border border-blue-200'
        : 'bg-orange-50 text-orange-700 border border-orange-200',
        
      light: isClean
        ? 'bg-blue-50/50 text-blue-600'
        : 'bg-orange-50/50 text-orange-600',
    },
    
    // Cards MODERNOS com gradientes sutis
    cards: {
      // Card padrão - BRANCO limpo com borda sutil
      modern: 'bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-all duration-200',
      
      // Card com gradiente muito sutil
      gradient: isClean
        ? 'bg-gradient-to-br from-white to-blue-50/20 border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-all duration-300'
        : 'bg-gradient-to-br from-white to-orange-50/20 border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-all duration-300',
        
      // Card glassmorphism - moderno e sofisticado
      glass: isClean
        ? 'bg-gradient-to-br from-white/95 via-blue-50/20 to-white/90 backdrop-blur-sm border border-slate-200/60 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300'
        : 'bg-gradient-to-br from-white/95 via-orange-50/20 to-white/90 backdrop-blur-sm border border-slate-200/60 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300',
        
      // Card de destaque - cor do módulo
      featured: isClean
        ? 'bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-xl shadow-lg border border-blue-400/20'
        : 'bg-gradient-to-br from-orange-500 to-orange-600 text-white rounded-xl shadow-lg border border-orange-400/20',
    },
    
    // Cores de texto - cor do módulo para destaques
    text: {
      primary: isClean ? 'text-blue-600' : 'text-orange-600',
      light: isClean ? 'text-blue-500' : 'text-orange-500',
      dark: isClean ? 'text-blue-700' : 'text-orange-700',
    },
    
    // Bordas - cor do módulo apenas para destaque
    borders: {
      primary: isClean ? 'border-blue-500' : 'border-orange-500',
      light: isClean ? 'border-blue-200' : 'border-orange-200',
      accent: isClean ? 'border-l-4 border-l-blue-500' : 'border-l-4 border-l-orange-500',
    },
    
    // Backgrounds - cor do módulo muito sutil
    backgrounds: {
      light: isClean ? 'bg-blue-50/50' : 'bg-orange-50/50',
      lighter: isClean ? 'bg-blue-50/30' : 'bg-orange-50/30',
      primary: isClean ? 'bg-blue-600' : 'bg-orange-600',
    },
    
    // Hover effects - neutro
    hover: {
      card: 'hover:border-slate-300 hover:shadow-md',
    },
    
    // Animações especiais
    animations: {
      shimmer: 'relative overflow-hidden before:absolute before:inset-0 before:-translate-x-full before:animate-[shimmer_2s_infinite] before:bg-gradient-to-r before:from-transparent before:via-white/10 before:to-transparent',
      pulse: isClean
        ? 'animate-pulse bg-blue-100/30'
        : 'animate-pulse bg-orange-100/30',
    }
  };
}
