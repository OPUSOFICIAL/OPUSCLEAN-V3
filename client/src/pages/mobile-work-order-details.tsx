import { useState, useEffect } from "react";
import { useRoute, useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, MapPin, Building2, Clock, CheckCircle, AlertCircle, Calendar, User } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

export default function MobileWorkOrderDetails() {
  const [, params] = useRoute("/mobile/work-order-details/:id");
  const [, setLocation] = useLocation();
  const { toast } = useToast();
  
  const [workOrder, setWorkOrder] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (params?.id) {
      loadWorkOrder(params.id);
    }
  }, [params?.id]);

  const loadWorkOrder = async (id: string) => {
    setIsLoading(true);
    try {
      const response = await fetch(`/api/work-orders/${id}`);
      if (!response.ok) throw new Error('Work order não encontrada');
      const data = await response.json();
      setWorkOrder(data);
    } catch (error) {
      console.error('Erro ao carregar work order:', error);
      toast({
        title: "Erro",
        description: "Não foi possível carregar a ordem de serviço.",
        variant: "destructive",
      });
      setLocation('/mobile');
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open': return 'bg-blue-500';
      case 'in_progress': return 'bg-yellow-500';
      case 'completed': return 'bg-green-500';
      case 'cancelled': return 'bg-gray-500';
      default: return 'bg-gray-500';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'open': return 'Disponível';
      case 'in_progress': return 'Em Andamento';
      case 'completed': return 'Concluída';
      case 'cancelled': return 'Cancelada';
      default: return status;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'urgent': return 'bg-red-500';
      case 'high': return 'bg-orange-500';
      case 'medium': return 'bg-yellow-500';
      case 'low': return 'bg-green-500';
      default: return 'bg-gray-500';
    }
  };

  const getPriorityLabel = (priority: string) => {
    switch (priority) {
      case 'urgent': return 'Urgente';
      case 'high': return 'Alta';
      case 'medium': return 'Média';
      case 'low': return 'Baixa';
      default: return priority;
    }
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Carregando...</p>
        </div>
      </div>
    );
  }

  if (!workOrder) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <p className="text-gray-600">Ordem de serviço não encontrada</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 pb-20">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 shadow-lg">
        <div className="flex items-center mb-4">
          <Button
            variant="ghost"
            size="icon"
            className="text-white hover:bg-white/20"
            onClick={() => setLocation('/mobile')}
            data-testid="button-back"
          >
            <ArrowLeft className="h-6 w-6" />
          </Button>
          <h1 className="text-2xl font-bold ml-4">Detalhes da OS</h1>
        </div>
      </div>

      <div className="p-6 space-y-4">
        {/* Work Order Info */}
        <Card>
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <CardTitle className="text-xl">{workOrder.title}</CardTitle>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <span className="font-semibold">OS #{workOrder.workOrderNumber}</span>
                </div>
              </div>
              <Badge className={`${getStatusColor(workOrder.status)} text-white`}>
                {getStatusLabel(workOrder.status)}
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Description */}
            {workOrder.description && (
              <div>
                <p className="text-sm font-medium text-gray-700 mb-1">Descrição:</p>
                <p className="text-sm text-gray-600">{workOrder.description}</p>
              </div>
            )}

            {/* Location */}
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <Building2 className="w-4 h-4" />
              <span>{workOrder.site?.name || 'Site não especificado'}</span>
            </div>

            {workOrder.zone && (
              <div className="flex items-center gap-2 text-sm text-gray-600">
                <MapPin className="w-4 h-4" />
                <span>{workOrder.zone.name}</span>
              </div>
            )}

            {/* Priority */}
            <div className="flex items-center gap-2">
              <span className="text-sm text-gray-700">Prioridade:</span>
              <Badge className={`${getPriorityColor(workOrder.priority)} text-white`}>
                {getPriorityLabel(workOrder.priority)}
              </Badge>
            </div>

            {/* Dates */}
            <div className="space-y-2">
              <div className="flex items-center gap-2 text-sm">
                <Calendar className="w-4 h-4 text-gray-500" />
                <span className="text-gray-700">Criada em:</span>
                <span className="text-gray-600">{formatDate(workOrder.createdAt)}</span>
              </div>
              
              <div className="flex items-center gap-2 text-sm">
                <Clock className="w-4 h-4 text-gray-500" />
                <span className="text-gray-700">Prazo:</span>
                <span className="text-gray-600">{formatDate(workOrder.dueDate)}</span>
              </div>

              {workOrder.completedAt && (
                <div className="flex items-center gap-2 text-sm">
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  <span className="text-gray-700">Concluída em:</span>
                  <span className="text-gray-600">{formatDate(workOrder.completedAt)}</span>
                </div>
              )}
            </div>

            {/* Operator */}
            {workOrder.assignedOperator && (
              <div className="flex items-center gap-2 text-sm">
                <User className="w-4 h-4 text-gray-500" />
                <span className="text-gray-700">Operador:</span>
                <span className="text-gray-600">{workOrder.assignedOperator.name}</span>
              </div>
            )}

            {/* Type */}
            <div className="flex items-center gap-2 text-sm">
              <span className="text-gray-700">Tipo:</span>
              <span className="text-gray-600 capitalize">{workOrder.type.replace('_', ' ')}</span>
            </div>
          </CardContent>
        </Card>

        {/* Info: Execution only via QR Code */}
        <Card className="bg-blue-50 border-blue-200">
          <CardContent className="pt-6">
            <div className="text-center text-blue-700">
              <CheckCircle className="w-12 h-12 mx-auto mb-3 text-blue-600" />
              <p className="font-semibold mb-2">Execução via QR Code</p>
              <p className="text-sm">
                Para executar esta ordem de serviço, escaneie o QR Code do local usando o scanner.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
