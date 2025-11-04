import Header from "@/components/layout/header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { 
  Calendar, 
  ChevronLeft,
  ChevronRight,
  Wrench,
  MapPin,
  Clock
} from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

export default function MaintenanceSchedule() {
  const { activeClientId } = useClient();
  const { currentModule } = useModule();

  // Calendário de Manutenção é exclusivo do módulo OPUS Manutenção
  if (currentModule !== 'maintenance') {
    return (
      <div className="h-full bg-gradient-to-br from-orange-50 via-amber-50 to-yellow-50 flex items-center justify-center p-6">
        <Card className="max-w-md">
          <CardHeader>
            <CardTitle className="text-center">Funcionalidade Não Disponível</CardTitle>
          </CardHeader>
          <CardContent className="text-center space-y-4">
            <Calendar className="w-16 h-16 mx-auto text-slate-400" />
            <p className="text-slate-600">
              O calendário de manutenção está disponível apenas no módulo <strong>OPUS Manutenção</strong>.
            </p>
            <p className="text-sm text-slate-500">
              Alterne para OPUS Manutenção usando o seletor de plataforma na barra lateral.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const [currentDate, setCurrentDate] = useState(new Date());
  const [showDayDetailsModal, setShowDayDetailsModal] = useState(false);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [selectedPlans, setSelectedPlans] = useState<any[]>([]);

  // Buscar planos de manutenção
  const { data: plans, isLoading } = useQuery({
    queryKey: ["/api/customers", activeClientId, "maintenance-activities"],
    enabled: !!activeClientId,
  });

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", activeClientId, "sites", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: zones } = useQuery({
    queryKey: ["/api/customers", activeClientId, "zones", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: equipment } = useQuery({
    queryKey: ["/api/customers", activeClientId, "equipment"],
    enabled: !!activeClientId,
  });

  // Função para gerar calendário do mês
  const generateMonthCalendar = () => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const firstDayOfWeek = firstDay.getDay();
    const daysInMonth = lastDay.getDate();
    
    const calendar = [];
    let day = 1;
    
    for (let week = 0; week < 6; week++) {
      const weekDays = [];
      
      for (let dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        if (week === 0 && dayOfWeek < firstDayOfWeek) {
          weekDays.push(null);
        } else if (day > daysInMonth) {
          weekDays.push(null);
        } else {
          weekDays.push(day);
          day++;
        }
      }
      
      calendar.push(weekDays);
      if (day > daysInMonth) break;
    }
    
    return calendar;
  };

  // Função para obter planos de um dia específico (VIRTUAL - não busca OSs do banco)
  const getPlansForDay = (day: number) => {
    if (!plans) return [];
    
    return (plans as any[]).filter((plan: any) => {
      if (!plan.isActive) return false;
      
      const checkDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), day);
      const planStartDate = new Date(plan.startDate);
      
      // Se o plano ainda não começou, não mostrar
      if (checkDate < planStartDate) return false;
      
      // Se o plano já terminou, não mostrar
      if (plan.endDate && checkDate > new Date(plan.endDate)) return false;
      
      // Verificar frequência
      if (plan.frequency === 'diaria') return true;
      
      if (plan.frequency === 'semanal') {
        const dayOfWeek = checkDate.getDay();
        const weekDays = plan.frequencyConfig?.weekDays || [];
        const dayMap: Record<string, number> = {
          'domingo': 0, 'segunda': 1, 'terca': 2, 'quarta': 3,
          'quinta': 4, 'sexta': 5, 'sabado': 6
        };
        return weekDays.some((d: string) => dayMap[d] === dayOfWeek);
      }
      
      if (plan.frequency === 'mensal') {
        return day === (plan.frequencyConfig?.monthDay || 1);
      }
      
      if (plan.frequency === 'turno') {
        // Turnos são diários
        return true;
      }
      
      return false;
    });
  };

  // Função para navegar entre meses
  const navigateMonth = (direction: 'prev' | 'next') => {
    setCurrentDate(prev => {
      const newDate = new Date(prev);
      if (direction === 'prev') {
        newDate.setMonth(prev.getMonth() - 1);
      } else {
        newDate.setMonth(prev.getMonth() + 1);
      }
      return newDate;
    });
  };

  // Função para abrir detalhes do dia
  const openDayDetails = (day: number) => {
    const dayPlans = getPlansForDay(day);
    setSelectedDay(day);
    setSelectedPlans(dayPlans);
    setShowDayDetailsModal(true);
  };

  // Função para obter nome da zona
  const getZoneName = (zoneIds: string[]) => {
    if (!zones || !zoneIds || zoneIds.length === 0) return 'Sem zona';
    const zoneNames = zoneIds.map(id => {
      const zone = (zones as any[]).find((z: any) => z.id === id);
      return zone?.name || '';
    }).filter(Boolean);
    return zoneNames.length > 0 ? zoneNames.join(', ') : 'Sem zona';
  };

  const calendar = generateMonthCalendar();
  const weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  const monthName = currentDate.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });

  if (isLoading) {
    return (
      <div className="h-full bg-gradient-to-br from-orange-50 via-amber-50 to-yellow-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-600 mx-auto"></div>
          <p className="mt-4 text-slate-600">Carregando calendário...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full bg-gradient-to-br from-orange-50 via-amber-50 to-yellow-50">
      <Header 
        title="Calendário de Manutenção"
        subtitle="Visualize os planos de manutenção programados"
      />
      
      <div className="p-6 space-y-6 overflow-auto" style={{ height: 'calc(100% - 73px)' }}>
        {/* Header do Calendário */}
        <Card>
          <CardHeader className="bg-gradient-to-r from-orange-500 to-amber-500 text-white">
            <div className="flex items-center justify-between">
              <CardTitle className="capitalize flex items-center gap-2">
                <Calendar className="w-5 h-5" />
                {monthName}
              </CardTitle>
              <div className="flex gap-2">
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => navigateMonth('prev')}
                  data-testid="button-prev-month"
                >
                  <ChevronLeft className="w-4 h-4" />
                </Button>
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => setCurrentDate(new Date())}
                  data-testid="button-today"
                >
                  Hoje
                </Button>
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => navigateMonth('next')}
                  data-testid="button-next-month"
                >
                  <ChevronRight className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            {/* Cabeçalho dos dias da semana */}
            <div className="grid grid-cols-7 border-b">
              {weekDays.map(day => (
                <div key={day} className="p-3 text-center font-semibold text-sm text-slate-600 border-r last:border-r-0">
                  {day}
                </div>
              ))}
            </div>
            
            {/* Grade do calendário */}
            <div>
              {calendar.map((week, weekIndex) => (
                <div key={weekIndex} className="grid grid-cols-7 border-b last:border-b-0">
                  {week.map((day, dayIndex) => {
                    const dayPlans = day ? getPlansForDay(day) : [];
                    const isToday = day && 
                      day === new Date().getDate() && 
                      currentDate.getMonth() === new Date().getMonth() && 
                      currentDate.getFullYear() === new Date().getFullYear();
                    
                    return (
                      <div
                        key={dayIndex}
                        className={`min-h-[100px] border-r last:border-r-0 p-2 ${
                          day ? 'cursor-pointer hover:bg-orange-50 transition-colors' : 'bg-slate-50'
                        } ${isToday ? 'bg-orange-100' : ''}`}
                        onClick={() => day && openDayDetails(day)}
                        data-testid={day ? `calendar-day-${day}` : undefined}
                      >
                        {day && (
                          <>
                            <div className={`text-sm font-semibold mb-1 ${isToday ? 'text-orange-600' : 'text-slate-600'}`}>
                              {day}
                            </div>
                            <div className="space-y-1">
                              {dayPlans.slice(0, 3).map((plan: any, index: number) => (
                                <div
                                  key={index}
                                  className="text-xs bg-orange-200 text-orange-800 px-2 py-1 rounded truncate"
                                  title={plan.name}
                                >
                                  {plan.name}
                                </div>
                              ))}
                              {dayPlans.length > 3 && (
                                <div className="text-xs text-orange-600 font-medium">
                                  +{dayPlans.length - 3} mais
                                </div>
                              )}
                            </div>
                          </>
                        )}
                      </div>
                    );
                  })}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Modal de Detalhes do Dia */}
        <Dialog open={showDayDetailsModal} onOpenChange={setShowDayDetailsModal}>
          <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>
                Planos de Manutenção - {selectedDay && `Dia ${selectedDay} de ${monthName}`}
              </DialogTitle>
            </DialogHeader>
            
            <div className="space-y-4">
              {selectedPlans.length === 0 ? (
                <div className="text-center py-8 text-slate-500">
                  <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
                  <p>Nenhum plano de manutenção agendado para este dia</p>
                </div>
              ) : (
                selectedPlans.map((plan: any) => (
                  <Card key={plan.id} className="border-orange-200">
                    <CardHeader className="bg-orange-50 pb-3">
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <CardTitle className="text-lg text-orange-900 flex items-center gap-2">
                            <Wrench className="w-4 h-4" />
                            {plan.name}
                          </CardTitle>
                          {plan.description && (
                            <p className="text-sm text-slate-600 mt-1">{plan.description}</p>
                          )}
                        </div>
                        <Badge variant="outline" className="bg-orange-100 text-orange-700 border-orange-300">
                          {plan.frequency === 'diaria' ? 'Diária' : 
                           plan.frequency === 'semanal' ? 'Semanal' : 
                           plan.frequency === 'mensal' ? 'Mensal' : 
                           plan.frequency === 'turno' ? 'Por Turno' : plan.frequency}
                        </Badge>
                      </div>
                    </CardHeader>
                    <CardContent className="pt-4 space-y-2">
                      <div className="flex items-center gap-2 text-sm text-slate-600">
                        <MapPin className="w-4 h-4 text-orange-500" />
                        <span>{getZoneName(plan.zoneIds)}</span>
                      </div>
                      {plan.startTime && (
                        <div className="flex items-center gap-2 text-sm text-slate-600">
                          <Clock className="w-4 h-4 text-orange-500" />
                          <span>Horário: {plan.startTime}</span>
                        </div>
                      )}
                      <div className="text-xs text-slate-500 mt-2 p-2 bg-amber-50 rounded border border-amber-200">
                        ℹ️ As ordens de serviço serão criadas automaticamente no final do mês
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
