import { useModuleTheme } from "@/hooks/use-module-theme";
import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";

interface ModernPageHeaderProps {
  title: string;
  description?: string;
  icon?: LucideIcon;
  actions?: React.ReactNode;
  stats?: Array<{
    label: string;
    value: string | number;
    icon?: LucideIcon;
    trend?: 'up' | 'down';
  }>;
}

/**
 * Header de página ultra-moderno 2025 com gradientes e glassmorphism
 */
export function ModernPageHeader({ 
  title, 
  description, 
  icon: Icon, 
  actions,
  stats 
}: ModernPageHeaderProps) {
  const theme = useModuleTheme();
  
  return (
    <div className={cn(
      "relative overflow-hidden",
      theme.gradients.page
    )}>
      {/* Conteúdo */}
      <div className="relative px-6 py-8">
        <div className="max-w-7xl mx-auto">
          {/* Título e ações */}
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-4">
              {Icon && (
                <div className={cn(
                  "p-3 rounded-2xl backdrop-blur-xl",
                  theme.gradients.stat,
                  theme.shadows.button,
                  "text-white"
                )}>
                  <Icon className="w-8 h-8" />
                </div>
              )}
              <div>
                <h1 className={cn(
                  "text-4xl font-bold bg-clip-text text-transparent",
                  theme.gradients.header
                )}>
                  {title}
                </h1>
                {description && (
                  <p className="text-slate-600 mt-1 text-lg">
                    {description}
                  </p>
                )}
              </div>
            </div>
            
            {actions && (
              <div className="flex items-center gap-3">
                {actions}
              </div>
            )}
          </div>
          
          {/* Stats cards */}
          {stats && stats.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {stats.map((stat, idx) => {
                const StatIcon = stat.icon;
                return (
                  <div
                    key={idx}
                    className={cn(
                      "backdrop-blur-xl bg-white/80 rounded-xl p-4 border",
                      theme.borders.light,
                      theme.shadows.card,
                      "transition-all duration-300 hover:scale-105"
                    )}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm text-slate-600 font-medium">
                        {stat.label}
                      </span>
                      {StatIcon && (
                        <StatIcon className={cn("w-4 h-4", theme.text.primary)} />
                      )}
                    </div>
                    <div className="flex items-end gap-2">
                      <span className={cn(
                        "text-2xl font-bold",
                        theme.text.dark
                      )}>
                        {stat.value}
                      </span>
                      {stat.trend && (
                        <span className={cn(
                          "text-xs font-medium",
                          stat.trend === 'up' ? 'text-green-600' : 'text-red-600'
                        )}>
                          {stat.trend === 'up' ? '↑' : '↓'}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
