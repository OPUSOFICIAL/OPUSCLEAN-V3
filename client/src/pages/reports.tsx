import Header from "@/components/layout/header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { Skeleton } from "@/components/ui/skeleton";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { useToast } from "@/hooks/use-toast";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";
import { 
  Download, 
  FileText, 
  TrendingUp, 
  Clock, 
  Target,
  Users,
  MapPin,
  Calendar,
  BarChart3,
  PieChart,
  AlertCircle,
  FileSpreadsheet,
  Download as DownloadIcon,
  RefreshCw,
  Activity,
  Timer,
  CheckCircle2,
  Building2,
  Zap
} from "lucide-react";

// Types for report data
interface MetricsData {
  completedWorkOrders?: number;
  completedWorkOrdersChange?: string;
  averageSLA?: number;
  averageSLAChange?: string;
  totalAreaCleaned?: number;
  totalAreaCleanedChange?: string;
  averageExecutionTime?: number;
  averageExecutionTimeChange?: string;
  period?: string;
}

interface WorkOrderStatusData {
  status: string;
  label: string;
  count: number;
  color: string;
}

interface SLAPerformanceData {
  totalSLA?: number;
  categories?: {
    category: string;
    label: string;
    percentage: number;
  }[];
}

export default function Reports() {
  const { activeClientId } = useClient();
  const { currentModule } = useModule();
  const [dateRange, setDateRange] = useState("30");
  const [selectedReportType, setSelectedReportType] = useState<string | null>(null);
  const [isGenerating, setIsGenerating] = useState<string | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // API Queries with proper array-based keys
  const { data: reportsMetrics, isLoading: isLoadingMetrics, error: errorMetrics, refetch: refetchMetrics } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "metrics", { period: dateRange, module: currentModule }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/metrics?period=${dateRange}&module=${currentModule}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: workOrdersStatus, isLoading: isLoadingStatus, error: errorStatus, refetch: refetchStatus } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "work-orders-status", { period: dateRange, module: currentModule }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/work-orders-status?period=${dateRange}&module=${currentModule}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: slaPerformance, isLoading: isLoadingSLA, error: errorSLA, refetch: refetchSLA } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "sla-performance", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/sla-performance?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  // NOVAS QUERIES ESPECÍFICAS PARA CADA TIPO DE RELATÓRIO
  const { data: generalReport, isLoading: isLoadingGeneral, refetch: refetchGeneral } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "general", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/general?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: slaAnalysis, isLoading: isLoadingSLAAnalysis, refetch: refetchSLAAnalysis } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "sla-analysis", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/sla-analysis?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: productivityReport, isLoading: isLoadingProductivity, refetch: refetchProductivity } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "productivity", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/productivity?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: operatorPerformance, isLoading: isLoadingOperators, refetch: refetchOperators } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "operators", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/operators?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: locationAnalysis, isLoading: isLoadingLocations, refetch: refetchLocations } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "locations", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/locations?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  const { data: temporalAnalysis, isLoading: isLoadingTemporal, refetch: refetchTemporal } = useQuery({
    queryKey: ["/api/customers", activeClientId, "reports", "temporal", { period: dateRange }],
    queryFn: () => fetch(`/api/customers/${activeClientId}/reports/temporal?period=${dateRange}`).then(res => res.json()),
    enabled: !!activeClientId,
  });

  // Helper function to safely access nested properties
  const safeGet = (obj: any, key: string, defaultValue: any = 0) => {
    return obj && typeof obj === 'object' && key in obj ? obj[key] : defaultValue;
  };

  // Refresh all data
  const refreshData = async () => {
    setIsRefreshing(true);
    try {
      await Promise.all([
        refetchMetrics(),
        refetchStatus(),
        refetchSLA(),
        refetchGeneral(),
        refetchSLAAnalysis(),
        refetchProductivity(),
        refetchOperators(),
        refetchLocations(),
        refetchTemporal()
      ]);
      toast({
        title: "✅ Dados atualizados!",
        description: "Todas as informações foram atualizadas com sucesso.",
      });
    } catch (error) {
      toast({
        title: "❌ Erro ao atualizar",
        description: "Não foi possível atualizar os dados. Tente novamente.",
        variant: "destructive",
      });
    } finally {
      setIsRefreshing(false);
    }
  };

  // Generate and download report
  const generateReport = async (reportType: string, format: 'pdf' | 'csv' | 'excel') => {
    setIsGenerating(`${reportType}-${format}`);
    
    try {
      // Get the appropriate data based on report type
      let reportData: any = {};
      let filename = `relatorio-${reportType}-${dateRange}dias`;

      switch (reportType) {
        case 'geral':
          reportData = {
            metrics: reportsMetrics || {},
            workOrders: workOrdersStatus || [],
            slaData: slaPerformance || {},
            generalData: generalReport || {},
            period: `${dateRange} dias`,
            generatedAt: new Date().toISOString(),
            reportType: 'Relatório Geral'
          };
          break;
        case 'sla':
          reportData = {
            slaData: slaPerformance || {},
            slaAnalysisData: slaAnalysis || {},
            period: `${dateRange} dias`,
            generatedAt: new Date().toISOString(),
            reportType: 'Relatório de SLA'
          };
          break;
        case 'produtividade':
          reportData = {
            ...(productivityReport || {}),
            period: `${dateRange} dias`,
            generatedAt: new Date().toISOString(),
            reportType: 'Relatório de Produtividade'
          };
          break;
        case 'operadores':
          reportData = {
            ...(operatorPerformance || {}),
            period: `${dateRange} dias`,
            generatedAt: new Date().toISOString(),
            reportType: 'Relatório de Operadores'
          };
          break;
        case 'locais':
          reportData = {
            ...(locationAnalysis || {}),
            period: `${dateRange} dias`,
            generatedAt: new Date().toISOString(),
            reportType: 'Relatório por Locais'
          };
          break;
        case 'temporal':
          reportData = {
            ...(temporalAnalysis || {}),
            period: `${dateRange} dias`,
            generatedAt: new Date().toISOString(),
            reportType: 'Relatório Temporal'
          };
          break;
      }

      if (format === 'csv') {
        generateCSV(reportData, filename);
      } else if (format === 'excel') {
        generateExcel(reportData, filename);
      } else {
        generatePDF(reportData, filename);
      }

      toast({
        title: "✅ Relatório gerado com sucesso!",
        description: `${reportType.charAt(0).toUpperCase() + reportType.slice(1)} em formato ${format.toUpperCase()} baixado.`,
      });

    } catch (error) {
      console.error('Erro ao gerar relatório:', error);
      toast({
        title: "❌ Erro ao gerar relatório",
        description: "Ocorreu um erro ao gerar o relatório. Tente novamente.",
        variant: "destructive",
      });
    } finally {
      setIsGenerating(null);
    }
  };

  // Generate CSV content and download
  const generateCSV = (data: any, filename: string) => {
    let csv = `Relatório,${data.reportType}\n`;
    csv += `Período,${data.period}\n`;
    csv += `Gerado em,${new Date(data.generatedAt).toLocaleString('pt-BR')}\n\n`;

    // Relatório de Produtividade
    if (data.productivity) {
      csv += "MÉTRICAS DE PRODUTIVIDADE\n";
      csv += `Métrica,Valor\n`;
      csv += `OS por Dia,${safeGet(data.productivity, 'workOrdersPerDay', 0)}\n`;
      csv += `Tempo Médio de Conclusão (min),${safeGet(data.productivity, 'averageCompletionTime', 0)}\n`;
      csv += `Área Limpa por Hora (m²/h),${safeGet(data.productivity, 'areaCleanedPerHour', 0)}\n`;
      csv += `Tarefas por Operador,${safeGet(data.productivity, 'tasksPerOperator', 0)}\n`;
      csv += `Score de Qualidade (%),${safeGet(data.productivity, 'qualityScore', 0)}\n\n`;
      
      csv += "MÉTRICAS DE EFICIÊNCIA\n";
      csv += `Métrica,Valor\n`;
      csv += `Utilização de Recursos (%),${safeGet(data.efficiency, 'resourceUtilization', 0)}\n`;
      csv += `Uptime de Equipamentos (%),${safeGet(data.efficiency, 'equipmentUptime', 0)}\n`;
      csv += `Desperdício de Material (%),${safeGet(data.efficiency, 'materialWaste', 0)}\n`;
      csv += `Consumo de Energia (kWh),${safeGet(data.efficiency, 'energyConsumption', 0)}\n`;
      csv += `Eficiência de Custo (%),${safeGet(data.efficiency, 'costEfficiency', 0)}\n\n`;
      
      if (data.trends && Array.isArray(data.trends)) {
        csv += "TENDÊNCIAS MENSAIS\n";
        csv += "Mês,Produtividade (%),Eficiência (%)\n";
        data.trends.forEach((trend: any) => {
          csv += `${trend.month},${trend.productivity},${trend.efficiency}\n`;
        });
      }
    }

    // Relatório de Operadores
    if (data.operators) {
      if (data.operators.topPerformers && Array.isArray(data.operators.topPerformers)) {
        csv += "TOP PERFORMERS\n";
        csv += "Operador,Rank,Pontuação,Melhoria\n";
        data.operators.topPerformers.forEach((performer: any) => {
          csv += `${performer.name},${performer.rank},${performer.score},${performer.improvement}\n`;
        });
        csv += "\n";
      }
      
      if (data.operators.operators && Array.isArray(data.operators.operators)) {
        csv += "OPERADORES INDIVIDUAIS\n";
        csv += "Nome,Tarefas,Eficiência (%),Qualidade,Pontualidade (%),Experiência,Certificação\n";
        data.operators.operators.slice(0, 10).forEach((op: any) => {
          csv += `${op.name},${op.tasksCompleted},${op.efficiency},${op.qualityScore},${op.punctuality},${op.experienceLevel},${op.certification}\n`;
        });
      }
    }

    // Relatório de Locais
    if (data.locations) {
      if (data.locations.sites && Array.isArray(data.locations.sites)) {
        csv += "SITES\n";
        csv += "Nome,Zonas,OS Total,Concluídas,Eficiência (%),Área (m²),Utilização (%)\n";
        data.locations.sites.forEach((site: any) => {
          csv += `${site.name},${site.totalZones},${site.totalWorkOrders},${site.completedWorkOrders},${site.efficiency},${site.area},${site.utilizationRate}\n`;
        });
        csv += "\n";
      }
      
      if (data.locations.zones && Array.isArray(data.locations.zones)) {
        csv += "ZONAS\n";
        csv += "Nome,Site,OS Total,Concluídas,Tempo Médio (min),Prioridade,Última Limpeza\n";
        data.locations.zones.forEach((zone: any) => {
          csv += `${zone.name},${zone.siteName},${zone.totalWorkOrders},${zone.completedWorkOrders},${zone.averageTime},${zone.priority},${zone.lastCleaning}\n`;
        });
      }
    }

    // Relatório Temporal
    if (data.temporal) {
      if (data.temporal.historicalTrends && Array.isArray(data.temporal.historicalTrends)) {
        csv += "TENDÊNCIAS HISTÓRICAS\n";
        csv += "Período,OS Concluídas,SLA (%),Eficiência (%)\n";
        data.temporal.historicalTrends.forEach((trend: any) => {
          csv += `${trend.period},${trend.workOrders},${trend.sla},${trend.efficiency}\n`;
        });
      }
    }

    // Dados gerais (para relatórios que ainda usam o formato antigo)
    if (data.metrics) {
      csv += "MÉTRICAS GERAIS\n";
      csv += `Métrica,Valor\n`;
      csv += `OS Concluídas,${safeGet(data.metrics, 'completedWorkOrders', 0)}\n`;
      csv += `SLA Médio,${safeGet(data.metrics, 'averageSLA', 0)}%\n`;
      csv += `Área Limpa (m²),${safeGet(data.metrics, 'totalAreaCleaned', 0)}\n`;
      csv += `Tempo Médio (min),${safeGet(data.metrics, 'averageExecutionTime', 0)}\n\n`;
    }

    if (data.workOrders && Array.isArray(data.workOrders)) {
      csv += "ORDENS DE SERVIÇO POR STATUS\n";
      csv += "Status,Quantidade\n";
      data.workOrders.forEach((wo: WorkOrderStatusData) => {
        csv += `${wo.label || wo.status},${wo.count}\n`;
      });
      csv += "\n";
    }

    if (data.slaData && safeGet(data.slaData, 'categories', null)) {
      csv += "PERFORMANCE SLA\n";
      csv += "Categoria,Percentual\n";
      safeGet(data.slaData, 'categories', []).forEach((cat: any) => {
        csv += `${cat.label},${cat.percentage}%\n`;
      });
    }

    downloadFile(csv, `${filename}.csv`, 'text/csv');
  };

  // Generate real Excel file and download
  const generateExcel = (data: any, filename: string) => {
    const workbook = XLSX.utils.book_new();

    // Create summary sheet
    const summaryData: any[][] = [
      ['GRUPO OPUS - RELATÓRIO DE LIMPEZA'],
      [''],
      ['Tipo', data.reportType],
      ['Período', data.period],
      ['Gerado em', new Date(data.generatedAt).toLocaleString('pt-BR')],
      ['']
    ];

    // Relatório de Produtividade
    if (data.productivity) {
      summaryData.push(['MÉTRICAS DE PRODUTIVIDADE']);
      summaryData.push(['']);
      summaryData.push(['Métrica', 'Valor']);
      summaryData.push(['OS por Dia', safeGet(data.productivity, 'workOrdersPerDay', 0)]);
      summaryData.push(['Tempo Médio de Conclusão (min)', safeGet(data.productivity, 'averageCompletionTime', 0)]);
      summaryData.push(['Área Limpa por Hora (m²/h)', safeGet(data.productivity, 'areaCleanedPerHour', 0)]);
      summaryData.push(['Tarefas por Operador', safeGet(data.productivity, 'tasksPerOperator', 0)]);
      summaryData.push(['Score de Qualidade (%)', safeGet(data.productivity, 'qualityScore', 0)]);
      summaryData.push(['']);
      summaryData.push(['MÉTRICAS DE EFICIÊNCIA']);
      summaryData.push(['']);
      summaryData.push(['Métrica', 'Valor']);
      summaryData.push(['Utilização de Recursos (%)', safeGet(data.efficiency, 'resourceUtilization', 0)]);
      summaryData.push(['Uptime de Equipamentos (%)', safeGet(data.efficiency, 'equipmentUptime', 0)]);
      summaryData.push(['Desperdício de Material (%)', safeGet(data.efficiency, 'materialWaste', 0)]);
      summaryData.push(['Consumo de Energia (kWh)', safeGet(data.efficiency, 'energyConsumption', 0)]);
      summaryData.push(['Eficiência de Custo (%)', safeGet(data.efficiency, 'costEfficiency', 0)]);
      
      const summarySheet = XLSX.utils.aoa_to_sheet(summaryData);
      XLSX.utils.book_append_sheet(workbook, summarySheet, "Resumo");
      
      // Tendências mensais
      if (data.trends && Array.isArray(data.trends)) {
        const trendsData: any[][] = [
          ['TENDÊNCIAS MENSAIS'],
          [''],
          ['Mês', 'Produtividade (%)', 'Eficiência (%)']
        ];
        data.trends.forEach((trend: any) => {
          trendsData.push([trend.month, trend.productivity, trend.efficiency]);
        });
        const trendsSheet = XLSX.utils.aoa_to_sheet(trendsData);
        XLSX.utils.book_append_sheet(workbook, trendsSheet, "Tendências Mensais");
      }
    }
    // Relatório de Operadores
    else if (data.operators) {
      if (data.operators.topPerformers && Array.isArray(data.operators.topPerformers)) {
        const topPerformersData: any[][] = [
          ['TOP PERFORMERS'],
          [''],
          ['Operador', 'Rank', 'Pontuação', 'Melhoria']
        ];
        data.operators.topPerformers.forEach((performer: any) => {
          topPerformersData.push([performer.name, performer.rank, performer.score, performer.improvement]);
        });
        const topPerformersSheet = XLSX.utils.aoa_to_sheet(topPerformersData);
        XLSX.utils.book_append_sheet(workbook, topPerformersSheet, "Top Performers");
      }
      
      if (data.operators.operators && Array.isArray(data.operators.operators)) {
        const operatorsData: any[][] = [
          ['OPERADORES INDIVIDUAIS'],
          [''],
          ['Nome', 'Tarefas', 'Eficiência (%)', 'Qualidade', 'Pontualidade (%)', 'Experiência', 'Certificação']
        ];
        data.operators.operators.forEach((op: any) => {
          operatorsData.push([op.name, op.tasksCompleted, op.efficiency, op.qualityScore, op.punctuality, op.experienceLevel, op.certification]);
        });
        const operatorsSheet = XLSX.utils.aoa_to_sheet(operatorsData);
        XLSX.utils.book_append_sheet(workbook, operatorsSheet, "Operadores");
      }
      
      const summarySheet = XLSX.utils.aoa_to_sheet([['Relatório de Operadores']]);
      XLSX.utils.book_append_sheet(workbook, summarySheet, "Resumo");
    }
    // Relatório de Locais
    else if (data.locations) {
      if (data.locations.sites && Array.isArray(data.locations.sites)) {
        const sitesData: any[][] = [
          ['LOCAIS'],
          [''],
          ['Nome', 'Zonas', 'OS Total', 'Concluídas', 'Eficiência (%)', 'Área (m²)', 'Utilização (%)']
        ];
        data.locations.sites.forEach((site: any) => {
          sitesData.push([site.name, site.totalZones, site.totalWorkOrders, site.completedWorkOrders, site.efficiency, site.area, site.utilizationRate]);
        });
        const sitesSheet = XLSX.utils.aoa_to_sheet(sitesData);
        XLSX.utils.book_append_sheet(workbook, sitesSheet, "Locais");
      }
      
      if (data.locations.zones && Array.isArray(data.locations.zones)) {
        const zonesData: any[][] = [
          ['ZONAS'],
          [''],
          ['Nome', 'Local', 'OS Total', 'Concluídas', 'Tempo Médio (min)', 'Prioridade', 'Última Limpeza']
        ];
        data.locations.zones.forEach((zone: any) => {
          zonesData.push([zone.name, zone.siteName, zone.totalWorkOrders, zone.completedWorkOrders, zone.averageTime, zone.priority, zone.lastCleaning]);
        });
        const zonesSheet = XLSX.utils.aoa_to_sheet(zonesData);
        XLSX.utils.book_append_sheet(workbook, zonesSheet, "Zonas");
      }
      
      const summarySheet = XLSX.utils.aoa_to_sheet([['Relatório por Locais']]);
      XLSX.utils.book_append_sheet(workbook, summarySheet, "Resumo");
    }
    // Dados gerais (para relatórios que ainda usam o formato antigo)
    else {
      summaryData.push(['RESUMO EXECUTIVO']);
      summaryData.push(['']);
      summaryData.push(['Métrica', 'Valor']);
      if (data.metrics) {
        summaryData.push(['OS Concluídas', safeGet(data.metrics, 'completedWorkOrders', 0)]);
        summaryData.push(['SLA Médio (%)', safeGet(data.metrics, 'averageSLA', 0)]);
        summaryData.push(['Área Limpa (m²)', safeGet(data.metrics, 'totalAreaCleaned', 0)]);
        summaryData.push(['Tempo Médio (min)', safeGet(data.metrics, 'averageExecutionTime', 0)]);
      }
      
      const summarySheet = XLSX.utils.aoa_to_sheet(summaryData);
      XLSX.utils.book_append_sheet(workbook, summarySheet, "Resumo");

      // Create work orders sheet if data exists
      if (data.workOrders && Array.isArray(data.workOrders)) {
        const workOrdersData = [
          ['ORDENS DE SERVIÇO POR STATUS'],
          [''],
          ['Status', 'Quantidade']
        ];
        
        data.workOrders.forEach((wo: WorkOrderStatusData) => {
          workOrdersData.push([wo.label || wo.status, wo.count.toString()]);
        });

        const workOrdersSheet = XLSX.utils.aoa_to_sheet(workOrdersData);
        XLSX.utils.book_append_sheet(workbook, workOrdersSheet, "Ordens de Serviço");
      }

      // Create SLA sheet if data exists
      if (data.slaData && safeGet(data.slaData, 'categories', null)) {
        const slaData = [
          ['PERFORMANCE SLA'],
          [''],
          ['SLA Total (%)', safeGet(data.slaData, 'totalSLA', 0)],
          [''],
          ['Categoria', 'Percentual (%)']
        ];
        
        safeGet(data.slaData, 'categories', []).forEach((cat: any) => {
          slaData.push([cat.label, cat.percentage]);
        });

        const slaSheet = XLSX.utils.aoa_to_sheet(slaData);
        XLSX.utils.book_append_sheet(workbook, slaSheet, "SLA Performance");
      }
    }

    // Download the Excel file
    XLSX.writeFile(workbook, `${filename}.xlsx`);
  };

  // Generate real PDF and download
  const generatePDF = (data: any, filename: string) => {
    const doc = new jsPDF();
    
    // Header
    doc.setFontSize(20);
    doc.setTextColor(30, 58, 138); // Navy blue
    doc.text('GRUPO OPUS', 20, 20);
    doc.setFontSize(16);
    doc.text(data.reportType, 20, 30);
    
    // Report info
    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    doc.text(`Período: ${data.period}`, 20, 45);
    doc.text(`Gerado em: ${new Date(data.generatedAt).toLocaleString('pt-BR')}`, 20, 50);
    
    let yPosition = 65;

    // KPI Summary
    if (data.metrics) {
      doc.setFontSize(14);
      doc.setTextColor(30, 58, 138);
      doc.text('RESUMO EXECUTIVO', 20, yPosition);
      yPosition += 10;

      const kpiData = [
        ['Métrica', 'Valor'],
        ['OS Concluídas', safeGet(data.metrics, 'completedWorkOrders', 0).toString()],
        ['SLA Médio', `${safeGet(data.metrics, 'averageSLA', 0)}%`],
        ['Área Limpa', `${safeGet(data.metrics, 'totalAreaCleaned', 0)} m²`],
        ['Tempo Médio', `${safeGet(data.metrics, 'averageExecutionTime', 0)} min`]
      ];

      autoTable(doc, {
        head: [kpiData[0]],
        body: kpiData.slice(1),
        startY: yPosition,
        theme: 'grid',
        headStyles: { fillColor: [30, 58, 138] },
        margin: { left: 20 }
      });

      yPosition = (doc as any).lastAutoTable.finalY + 15;
    }

    // Work Orders Table
    if (data.workOrders && Array.isArray(data.workOrders) && data.workOrders.length > 0) {
      doc.setFontSize(14);
      doc.setTextColor(30, 58, 138);
      doc.text('ORDENS DE SERVIÇO', 20, yPosition);
      yPosition += 10;

      const workOrdersTableData = data.workOrders.map((wo: WorkOrderStatusData) => [
        wo.label || wo.status,
        wo.count.toString()
      ]);

      autoTable(doc, {
        head: [['Status', 'Quantidade']],
        body: workOrdersTableData,
        startY: yPosition,
        theme: 'grid',
        headStyles: { fillColor: [30, 58, 138] },
        margin: { left: 20 }
      });

      yPosition = (doc as any).lastAutoTable.finalY + 15;
    }

    // SLA Performance
    if (data.slaData && safeGet(data.slaData, 'categories', null)) {
      doc.setFontSize(14);
      doc.setTextColor(30, 58, 138);
      doc.text('PERFORMANCE SLA', 20, yPosition);
      yPosition += 5;

      doc.setFontSize(12);
      doc.setTextColor(0, 0, 0);
      doc.text(`SLA Total: ${safeGet(data.slaData, 'totalSLA', 0)}%`, 20, yPosition + 10);
      yPosition += 20;

      const slaTableData = safeGet(data.slaData, 'categories', []).map((cat: any) => [
        cat.label,
        `${cat.percentage}%`
      ]);

      autoTable(doc, {
        head: [['Categoria', 'Percentual']],
        body: slaTableData,
        startY: yPosition,
        theme: 'grid',
        headStyles: { fillColor: [30, 58, 138] },
        margin: { left: 20 }
      });
    }

    // Footer
    const pageCount = doc.getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(128, 128, 128);
      doc.text(`Página ${i} de ${pageCount}`, doc.internal.pageSize.width - 40, doc.internal.pageSize.height - 10);
      doc.text('Relatório gerado automaticamente pelo sistema OPUS CLEAN', 20, doc.internal.pageSize.height - 10);
    }

    // Save the PDF
    doc.save(`${filename}.pdf`);
  };

  // Download file helper
  const downloadFile = (content: string, filename: string, mimeType: string) => {
    const blob = new Blob([content], { type: mimeType });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  };

  // Report type definitions
  const reportTypes = [
    {
      id: "geral",
      title: "Relatório Geral",
      description: "Visão completa das operações com todos os KPIs principais",
      icon: FileText,
      color: "bg-blue-500",
      gradient: "from-blue-50 to-blue-100"
    },
    {
      id: "sla",
      title: "Análise de SLA",
      description: "Performance detalhada de cumprimento de prazos",
      icon: Target,
      color: "bg-green-500",
      gradient: "from-green-50 to-green-100"
    },
    {
      id: "produtividade",
      title: "Produtividade",
      description: "Métricas de eficiência e produtividade operacional",
      icon: TrendingUp,
      color: "bg-purple-500",
      gradient: "from-purple-50 to-purple-100"
    },
    {
      id: "operadores",
      title: "Performance de Operadores",
      description: "Análise individual e comparativa dos operadores",
      icon: Users,
      color: "bg-orange-500",
      gradient: "from-orange-50 to-orange-100"
    },
    {
      id: "locais",
      title: "Análise por Locais",
      description: "Distribuição e performance por zona e site",
      icon: MapPin,
      color: "bg-indigo-500",
      gradient: "from-indigo-50 to-indigo-100"
    },
    {
      id: "temporal",
      title: "Análise Temporal",
      description: "Tendências e padrões ao longo do tempo",
      icon: Clock,
      color: "bg-red-500",
      gradient: "from-red-50 to-red-100"
    }
  ];

  // KPI Cards
  const kpiCards = [
    {
      title: "OS Concluídas",
      value: safeGet(reportsMetrics, 'completedWorkOrders', 0).toLocaleString(),
      change: safeGet(reportsMetrics, 'completedWorkOrdersChange', '0%'),
      trend: safeGet(reportsMetrics, 'completedWorkOrdersChange', '0%').startsWith('+') ? "up" : "down",
      icon: CheckCircle2,
      color: "text-green-600",
      bgColor: "bg-green-50",
      borderColor: "border-green-200"
    },
    {
      title: "SLA Médio",
      value: `${safeGet(reportsMetrics, 'averageSLA', 0)}%`,
      change: safeGet(reportsMetrics, 'averageSLAChange', '0%'),
      trend: safeGet(reportsMetrics, 'averageSLAChange', '0%').startsWith('+') ? "up" : "down",
      icon: Target,
      color: "text-blue-600",
      bgColor: "bg-blue-50",
      borderColor: "border-blue-200"
    },
    {
      title: "Área Limpa (m²)",
      value: safeGet(reportsMetrics, 'totalAreaCleaned', 0).toLocaleString(),
      change: safeGet(reportsMetrics, 'totalAreaCleanedChange', '0%'),
      trend: safeGet(reportsMetrics, 'totalAreaCleanedChange', '0%').startsWith('+') ? "up" : "down",
      icon: Building2,
      color: "text-purple-600",
      bgColor: "bg-purple-50",
      borderColor: "border-purple-200"
    },
    {
      title: "Tempo Médio (min)",
      value: safeGet(reportsMetrics, 'averageExecutionTime', 0).toString(),
      change: safeGet(reportsMetrics, 'averageExecutionTimeChange', '0%'),
      trend: safeGet(reportsMetrics, 'averageExecutionTimeChange', '0%').startsWith('+') ? "up" : "down",
      icon: Timer,
      color: "text-orange-600",
      bgColor: "bg-orange-50",
      borderColor: "border-orange-200"
    }
  ];

  // COMPONENTES DE VISUALIZAÇÃO ESPECÍFICOS PARA CADA TIPO DE RELATÓRIO

  const GeneralReportView = ({ data }: { data: any }) => (
    <Card className="border-0 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <FileText className="w-5 h-5 text-blue-600" />
          <span>Relatório Geral - Visão Completa das Operações</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Overview */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📊 Visão Geral</h3>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Total de OS:</span>
                <span className="font-semibold">{data.overview?.totalWorkOrders || 0}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Concluídas:</span>
                <span className="font-semibold text-green-600">{data.overview?.completedWorkOrders || 0}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Pendentes:</span>
                <span className="font-semibold text-amber-600">{data.overview?.pendingWorkOrders || 0}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Taxa de Conclusão:</span>
                <span className="font-semibold text-blue-600">{data.overview?.completionRate || 0}%</span>
              </div>
            </div>
          </div>

          {/* Efficiency */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">⚡ Eficiência</h3>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Eficiência Geral:</span>
                <span className="font-semibold">{data.efficiency?.overallEfficiency || 0}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Índice de Qualidade:</span>
                <span className="font-semibold">{data.efficiency?.qualityIndex || 0}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Utilização de Recursos:</span>
                <span className="font-semibold">{data.efficiency?.resourceUtilization || 0}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Tempo Médio:</span>
                <span className="font-semibold">{data.efficiency?.averageCompletionTime || 0} min</span>
              </div>
            </div>
          </div>

          {/* Financial */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">💰 Financeiro</h3>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Custo Total:</span>
                <span className="font-semibold">R$ {(data.financial?.totalCost || 0).toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Custo por OS:</span>
                <span className="font-semibold">R$ {(data.financial?.costPerWorkOrder || 0).toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Utilização do Orçamento:</span>
                <span className="font-semibold">{data.financial?.budgetUtilization || 0}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Economia:</span>
                <span className="font-semibold text-green-600">R$ {(data.financial?.savings || 0).toFixed(2)}</span>
              </div>
            </div>
          </div>

          {/* Compliance */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">🎯 Compliance</h3>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">SLA Compliance:</span>
                <span className="font-semibold">{data.compliance?.slaCompliance || 0}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Incidentes de Segurança:</span>
                <span className="font-semibold">{data.compliance?.safetyIncidents || 0}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Score de Qualidade:</span>
                <span className="font-semibold">{data.compliance?.qualityScore || 0}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Score de Auditoria:</span>
                <span className="font-semibold">{data.compliance?.auditScore || 0}%</span>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const SLAAnalysisView = ({ data }: { data: any }) => (
    <Card className="border-0 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <Target className="w-5 h-5 text-green-600" />
          <span>Análise de SLA - Performance de Cumprimento de Prazos</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* SLA Breakdown */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📋 Breakdown por Categoria</h3>
            <div className="space-y-3">
              {data.slaBreakdown?.map((item: any, index: number) => (
                <div key={index} className="bg-slate-50 p-4 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-medium">{item.category}</span>
                    <span className="text-lg font-bold text-green-600">{item.percentage}%</span>
                  </div>
                  <div className="text-sm text-slate-600">
                    {item.met} de {item.total} cumpridos
                  </div>
                  <div className="w-full bg-slate-200 rounded-full h-2 mt-2">
                    <div 
                      className="bg-green-500 h-2 rounded-full" 
                      style={{ width: `${item.percentage}%` }}
                    ></div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Time Distribution */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">⏱️ Distribuição de Tempo</h3>
            <div className="space-y-3">
              {data.timeDistribution?.map((item: any, index: number) => (
                <div key={index} className="bg-slate-50 p-4 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-medium">{item.range}</span>
                    <span className="text-lg font-bold text-blue-600">{item.percentage}%</span>
                  </div>
                  <div className="text-sm text-slate-600">
                    {item.count} ordens de serviço
                  </div>
                  <div className="w-full bg-slate-200 rounded-full h-2 mt-2">
                    <div 
                      className="bg-blue-500 h-2 rounded-full" 
                      style={{ width: `${item.percentage}%` }}
                    ></div>
                  </div>
                </div>
              ))}
            </div>
            <div className="bg-amber-50 p-4 rounded-lg mt-4">
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Tempo Médio de Resposta:</span>
                <span className="font-semibold">{data.averageResponseTime || "N/A"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-slate-600">Alertas Críticos:</span>
                <span className="font-semibold text-red-600">{data.criticalAlerts || 0}</span>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const ProductivityReportView = ({ data }: { data: any }) => (
    <Card className="border-0 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <TrendingUp className="w-5 h-5 text-purple-600" />
          <span>Produtividade - Métricas de Eficiência Operacional</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Productivity Metrics */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📈 Métricas de Produtividade</h3>
            <div className="space-y-3">
              {[
                { label: "OS por Dia", value: data.productivity?.workOrdersPerDay, unit: "" },
                { label: "Tempo Médio de Conclusão", value: data.productivity?.averageCompletionTime, unit: " min" },
                { label: "Área Limpa por Hora", value: data.productivity?.areaCleanedPerHour, unit: " m²/h" },
                { label: "Tarefas por Operador", value: data.productivity?.tasksPerOperator, unit: "" },
                { label: "Score de Qualidade", value: data.productivity?.qualityScore, unit: "%" }
              ].map((metric, index) => (
                <div key={index} className="bg-purple-50 p-3 rounded-lg">
                  <div className="flex justify-between">
                    <span className="text-sm text-slate-600">{metric.label}:</span>
                    <span className="font-semibold text-purple-700">{metric.value || 0}{metric.unit}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Efficiency Metrics */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">⚡ Métricas de Eficiência</h3>
            <div className="space-y-3">
              {[
                { label: "Utilização de Recursos", value: data.efficiency?.resourceUtilization, unit: "%" },
                { label: "Uptime de Equipamentos", value: data.efficiency?.equipmentUptime, unit: "%" },
                { label: "Desperdício de Material", value: data.efficiency?.materialWaste, unit: "%" },
                { label: "Consumo de Energia", value: data.efficiency?.energyConsumption, unit: " kWh" },
                { label: "Eficiência de Custo", value: data.efficiency?.costEfficiency, unit: "%" }
              ].map((metric, index) => (
                <div key={index} className="bg-green-50 p-3 rounded-lg">
                  <div className="flex justify-between">
                    <span className="text-sm text-slate-600">{metric.label}:</span>
                    <span className="font-semibold text-green-700">{metric.value || 0}{metric.unit}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Trends */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📊 Tendências Mensais</h3>
            <div className="space-y-3">
              {data.trends?.map((trend: any, index: number) => (
                <div key={index} className="bg-slate-50 p-3 rounded-lg">
                  <div className="text-sm font-medium text-slate-800 mb-2">{trend.month}</div>
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <div className="flex justify-between">
                      <span className="text-slate-600">Produtividade:</span>
                      <span className="font-semibold">{trend.productivity}%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Eficiência:</span>
                      <span className="font-semibold">{trend.efficiency}%</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const OperatorPerformanceView = ({ data }: { data: any }) => (
    <Card className="border-0 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <Users className="w-5 h-5 text-orange-600" />
          <span>Performance de Operadores - Análise Individual</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Team Stats */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">👥 Estatísticas da Equipe</h3>
            <div className="space-y-3">
              {[
                { label: "Total de Operadores", value: data.teamStats?.totalOperators },
                { label: "Eficiência Média", value: `${data.teamStats?.averageEfficiency || 0}%` },
                { label: "Top Performer", value: data.teamStats?.topPerformer || "N/A" },
                { label: "Precisam Melhoria", value: data.teamStats?.improvementNeeded },
                { label: "Treinamento Concluído", value: data.teamStats?.trainingCompleted }
              ].map((stat, index) => (
                <div key={index} className="bg-orange-50 p-3 rounded-lg">
                  <div className="flex justify-between">
                    <span className="text-sm text-slate-600">{stat.label}:</span>
                    <span className="font-semibold text-orange-700">{stat.value}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Rankings */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">🏆 Ranking</h3>
            <div className="space-y-3">
              {data.rankings?.map((rank: any, index: number) => (
                <div key={index} className="bg-slate-50 p-4 rounded-lg">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center space-x-2">
                      <span className="text-lg font-bold text-slate-700">#{rank.position}</span>
                      <span className="font-medium">{rank.operator}</span>
                    </div>
                    <span className="text-lg font-bold text-blue-600">{rank.score}</span>
                  </div>
                  <div className="text-sm text-slate-600">
                    Melhoria: <span className={`font-semibold ${rank.improvement.startsWith('+') ? 'text-green-600' : 'text-red-600'}`}>
                      {rank.improvement}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Individual Operators */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">👤 Operadores Individuais</h3>
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {data.operators?.slice(0, 5).map((op: any, index: number) => (
                <div key={index} className="bg-slate-50 p-3 rounded-lg">
                  <div className="font-medium text-slate-800 mb-2">{op.name}</div>
                  <div className="grid grid-cols-2 gap-1 text-xs">
                    <div className="flex justify-between">
                      <span className="text-slate-600">Tarefas:</span>
                      <span className="font-semibold">{op.tasksCompleted}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Eficiência:</span>
                      <span className="font-semibold">{op.efficiency}%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Qualidade:</span>
                      <span className="font-semibold">{op.qualityScore}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Pontualidade:</span>
                      <span className="font-semibold">{op.punctuality}%</span>
                    </div>
                  </div>
                  <div className="mt-2 flex justify-between items-center">
                    <span className="text-xs text-slate-600">{op.experienceLevel}</span>
                    <span className={`text-xs px-2 py-1 rounded ${op.certification === 'Ativo' ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}`}>
                      {op.certification}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const LocationAnalysisView = ({ data }: { data: any }) => (
    <Card className="border-0 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <MapPin className="w-5 h-5 text-indigo-600" />
          <span>Análise por Locais - Distribuição por Zona e Site</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Sites */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">🏢 Sites</h3>
            <div className="space-y-3">
              {data.sites?.map((site: any, index: number) => (
                <div key={index} className="bg-indigo-50 p-4 rounded-lg">
                  <div className="font-medium text-slate-800 mb-2">{site.name}</div>
                  <div className="grid grid-cols-2 gap-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-slate-600">Zonas:</span>
                      <span className="font-semibold">{site.totalZones}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">OS Total:</span>
                      <span className="font-semibold">{site.totalWorkOrders}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Concluídas:</span>
                      <span className="font-semibold text-green-600">{site.completedWorkOrders}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Eficiência:</span>
                      <span className="font-semibold text-blue-600">{site.efficiency}%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Área:</span>
                      <span className="font-semibold">{site.area} m²</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Utilização:</span>
                      <span className="font-semibold">{site.utilizationRate}%</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Zones */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📍 Zonas</h3>
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {data.zones?.map((zone: any, index: number) => (
                <div key={index} className="bg-slate-50 p-3 rounded-lg">
                  <div className="font-medium text-slate-800 mb-1">{zone.name}</div>
                  <div className="text-xs text-slate-600 mb-2">{zone.siteName}</div>
                  <div className="grid grid-cols-2 gap-1 text-xs">
                    <div className="flex justify-between">
                      <span className="text-slate-600">OS Total:</span>
                      <span className="font-semibold">{zone.totalWorkOrders}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Concluídas:</span>
                      <span className="font-semibold">{zone.completedWorkOrders}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Tempo Médio:</span>
                      <span className="font-semibold">{zone.averageTime} min</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Prioridade:</span>
                      <span className={`font-semibold ${zone.priority === 'Alta' ? 'text-red-600' : zone.priority === 'Média' ? 'text-amber-600' : 'text-green-600'}`}>
                        {zone.priority}
                      </span>
                    </div>
                  </div>
                  <div className="mt-2 text-xs text-slate-600">
                    Última limpeza: {zone.lastCleaning}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  const TemporalAnalysisView = ({ data }: { data: any }) => (
    <Card className="border-0 shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <Clock className="w-5 h-5 text-red-600" />
          <span>Análise Temporal - Tendências e Padrões</span>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Historical Trends */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📈 Tendências Históricas</h3>
            <div className="space-y-3">
              {data.trends?.map((trend: any, index: number) => (
                <div key={index} className="bg-red-50 p-4 rounded-lg">
                  <div className="font-medium text-slate-800 mb-2">{trend.period}</div>
                  <div className="space-y-1 text-sm">
                    <div className="flex justify-between">
                      <span className="text-slate-600">Work Orders:</span>
                      <span className="font-semibold">{trend.workOrders}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Eficiência:</span>
                      <span className="font-semibold text-blue-600">{trend.efficiency}%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Custo:</span>
                      <span className="font-semibold">R$ {trend.cost}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Weekly Patterns */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">📅 Padrões Semanais</h3>
            <div className="space-y-3">
              {data.patterns?.map((pattern: any, index: number) => (
                <div key={index} className="bg-slate-50 p-3 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-medium text-slate-800">{pattern.day}</span>
                    <span className="text-sm font-semibold text-blue-600">{pattern.avgWorkOrders} OS</span>
                  </div>
                  <div className="text-xs text-slate-600">
                    Pico: {pattern.peak}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Forecasts */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-800">🔮 Previsões</h3>
            <div className="space-y-3">
              {data.forecasts?.map((forecast: any, index: number) => (
                <div key={index} className="bg-green-50 p-4 rounded-lg">
                  <div className="font-medium text-slate-800 mb-2">{forecast.period}</div>
                  <div className="space-y-1 text-sm">
                    <div className="flex justify-between">
                      <span className="text-slate-600">Previsão:</span>
                      <span className="font-semibold text-green-600">{forecast.predicted} OS</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-600">Confiança:</span>
                      <span className="font-semibold">{forecast.confidence}%</span>
                    </div>
                  </div>
                  <div className="w-full bg-slate-200 rounded-full h-2 mt-2">
                    <div 
                      className="bg-green-500 h-2 rounded-full" 
                      style={{ width: `${forecast.confidence}%` }}
                    ></div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  return (
    <>
      <Header 
        title="Relatórios e Analytics" 
        description="Dashboard completo com análises e geração de relatórios personalizados"
      >
        <div className="flex items-center space-x-3">
          <Select value={dateRange} onValueChange={setDateRange}>
            <SelectTrigger className="w-40" data-testid="select-date-range">
              <Calendar className="w-4 h-4 mr-2" />
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7">Últimos 7 dias</SelectItem>
              <SelectItem value="30">Últimos 30 dias</SelectItem>
              <SelectItem value="90">Últimos 90 dias</SelectItem>
              <SelectItem value="365">Último ano</SelectItem>
            </SelectContent>
          </Select>
          <Button 
            variant="outline" 
            onClick={refreshData}
            disabled={isRefreshing}
            data-testid="button-refresh-data"
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${isRefreshing ? 'animate-spin' : ''}`} />
            {isRefreshing ? 'Atualizando...' : 'Atualizar'}
          </Button>
        </div>
      </Header>
      
      <main className="flex-1 overflow-auto p-6 bg-gradient-to-br from-slate-50 to-blue-50">
        {/* KPI Dashboard */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold text-slate-900">Dashboard de KPIs</h2>
            <Badge variant="outline" className="text-slate-600">
              Últimos {dateRange} dias
            </Badge>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {isLoadingMetrics ? (
              Array.from({ length: 4 }).map((_, i) => (
                <Card key={i} className="border-0 shadow-lg">
                  <CardContent className="p-6">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <Skeleton className="h-4 w-24 mb-3" />
                        <Skeleton className="h-8 w-20 mb-2" />
                        <Skeleton className="h-3 w-32" />
                      </div>
                      <Skeleton className="w-12 h-12 rounded-full" />
                    </div>
                  </CardContent>
                </Card>
              ))
            ) : errorMetrics ? (
              <div className="col-span-full">
                <Alert variant="destructive">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>
                    Erro ao carregar métricas: {errorMetrics.message}
                  </AlertDescription>
                </Alert>
              </div>
            ) : (
              kpiCards.map((kpi) => {
                const Icon = kpi.icon;
                return (
                  <Card key={kpi.title} className={`border-0 shadow-lg hover:shadow-xl transition-all duration-300 ${kpi.borderColor} border-l-4`}>
                    <CardContent className="p-6">
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <p className="text-sm font-medium text-slate-600 mb-1">{kpi.title}</p>
                          <p className="text-3xl font-bold text-slate-900 mb-2" data-testid={`kpi-value-${kpi.title.toLowerCase().replace(/\s+/g, '-')}`}>
                            {kpi.value}
                          </p>
                          <div className="flex items-center">
                            <TrendingUp className={`w-3 h-3 mr-1 ${kpi.trend === 'up' ? 'text-green-500' : 'text-red-500'}`} />
                            <p className={`text-xs font-medium ${kpi.trend === 'up' ? 'text-green-600' : 'text-red-600'}`}>
                              {kpi.change} vs. período anterior
                            </p>
                          </div>
                        </div>
                        <div className={`w-14 h-14 ${kpi.bgColor} rounded-xl flex items-center justify-center`}>
                          <Icon className={`w-7 h-7 ${kpi.color}`} />
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                );
              })
            )}
          </div>
        </div>

        <Separator className="my-8" />

        {/* Report Generation Section */}
        <div className="mb-8">
          <div className="text-center mb-8">
            <h2 className="text-3xl font-bold text-slate-900 mb-2">Geração de Relatórios</h2>
            <p className="text-slate-600 max-w-2xl mx-auto">
              Selecione o tipo de relatório e formato desejado para gerar análises detalhadas dos dados
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {reportTypes.map((report) => {
              const Icon = report.icon;
              const isSelected = selectedReportType === report.id;
              
              return (
                <Card 
                  key={report.id} 
                  className={`cursor-pointer transition-all duration-300 border-0 shadow-lg hover:shadow-xl transform hover:-translate-y-1 ${
                    isSelected ? "ring-2 ring-blue-500 shadow-2xl scale-105" : ""
                  }`}
                  onClick={() => setSelectedReportType(isSelected ? null : report.id)}
                >
                  <CardContent className="p-6">
                    <div className={`w-full h-32 rounded-lg bg-gradient-to-br ${report.gradient} mb-4 flex items-center justify-center`}>
                      <Icon className={`w-12 h-12 text-white p-2 ${report.color} rounded-lg`} />
                    </div>
                    
                    <h3 className="text-lg font-bold text-slate-900 mb-2">
                      {report.title}
                    </h3>
                    <p className="text-sm text-slate-600 mb-4 leading-relaxed">
                      {report.description}
                    </p>
                    
                    {isSelected && (
                      <div className="space-y-3 mt-4 pt-4 border-t border-slate-200">
                        <p className="text-xs font-semibold text-slate-700 uppercase tracking-wide">
                          Escolha o formato:
                        </p>
                        <div className="grid grid-cols-3 gap-2">
                          <Button 
                            size="sm" 
                            variant="outline"
                            className="flex-1 text-xs py-2"
                            onClick={(e) => {
                              e.stopPropagation();
                              generateReport(report.id, 'pdf');
                            }}
                            disabled={isGenerating === `${report.id}-pdf`}
                            data-testid={`button-generate-${report.id}-pdf`}
                          >
                            {isGenerating === `${report.id}-pdf` ? (
                              <RefreshCw className="w-3 h-3 mr-1 animate-spin" />
                            ) : (
                              <FileText className="w-3 h-3 mr-1" />
                            )}
                            PDF
                          </Button>
                          <Button 
                            size="sm" 
                            variant="outline"
                            className="flex-1 text-xs py-2"
                            onClick={(e) => {
                              e.stopPropagation();
                              generateReport(report.id, 'csv');
                            }}
                            disabled={isGenerating === `${report.id}-csv`}
                            data-testid={`button-generate-${report.id}-csv`}
                          >
                            {isGenerating === `${report.id}-csv` ? (
                              <RefreshCw className="w-3 h-3 mr-1 animate-spin" />
                            ) : (
                              <FileSpreadsheet className="w-3 h-3 mr-1" />
                            )}
                            CSV
                          </Button>
                          <Button 
                            size="sm" 
                            variant="outline"
                            className="flex-1 text-xs py-2"
                            onClick={(e) => {
                              e.stopPropagation();
                              generateReport(report.id, 'excel');
                            }}
                            disabled={isGenerating === `${report.id}-excel`}
                            data-testid={`button-generate-${report.id}-excel`}
                          >
                            {isGenerating === `${report.id}-excel` ? (
                              <RefreshCw className="w-3 h-3 mr-1 animate-spin" />
                            ) : (
                              <FileSpreadsheet className="w-3 h-3 mr-1" />
                            )}
                            Excel
                          </Button>
                        </div>
                      </div>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>

          {/* VISUALIZAÇÕES ESPECÍFICAS PARA CADA TIPO DE RELATÓRIO */}
          {selectedReportType && (
            <div className="mt-8">
              {selectedReportType === 'geral' && generalReport && (
                <GeneralReportView data={generalReport} />
              )}
              {selectedReportType === 'sla' && slaAnalysis && (
                <SLAAnalysisView data={slaAnalysis} />
              )}
              {selectedReportType === 'produtividade' && productivityReport && (
                <ProductivityReportView data={productivityReport} />
              )}
              {selectedReportType === 'operadores' && operatorPerformance && (
                <OperatorPerformanceView data={operatorPerformance} />
              )}
              {selectedReportType === 'locais' && locationAnalysis && (
                <LocationAnalysisView data={locationAnalysis} />
              )}
              {selectedReportType === 'temporal' && temporalAnalysis && (
                <TemporalAnalysisView data={temporalAnalysis} />
              )}
            </div>
          )}
        </div>

        <Separator className="my-8" />

        {/* Analytics Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Work Orders Chart */}
          <Card className="border-0 shadow-lg">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center space-x-2">
                  <BarChart3 className="w-5 h-5" />
                  <span>Ordens de Serviço por Status</span>
                </CardTitle>
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={() => generateReport('geral', 'csv')}
                  data-testid="button-export-work-orders-csv"
                >
                  <Download className="w-4 h-4 mr-2" />
                  Exportar
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {isLoadingStatus ? (
                  <div className="space-y-3">
                    {Array.from({ length: 4 }).map((_, i) => (
                      <div key={i} className="flex items-center justify-between p-4 bg-slate-50 rounded-lg">
                        <div className="flex items-center space-x-3">
                          <Skeleton className="w-4 h-4 rounded" />
                          <Skeleton className="h-4 w-24" />
                        </div>
                        <Skeleton className="h-4 w-8" />
                      </div>
                    ))}
                  </div>
                ) : errorStatus ? (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>
                      Erro ao carregar dados de status: {errorStatus.message}
                    </AlertDescription>
                  </Alert>
                ) : workOrdersStatus && Array.isArray(workOrdersStatus) && workOrdersStatus.length > 0 ? (
                  workOrdersStatus.map((status: WorkOrderStatusData) => (
                    <div key={status.status} className="flex items-center justify-between p-4 bg-slate-50 rounded-lg hover:bg-slate-100 transition-colors" data-testid={`status-item-${status.status}`}>
                      <div className="flex items-center space-x-3">
                        <div className={`w-4 h-4 ${status.color} rounded-full`}></div>
                        <span className="text-sm font-medium text-slate-700">{status.label}</span>
                      </div>
                      <Badge variant="secondary" className="font-bold" data-testid={`status-count-${status.status}`}>
                        {status.count}
                      </Badge>
                    </div>
                  ))
                ) : (
                  <div className="text-center py-8">
                    <Activity className="w-12 h-12 text-slate-300 mx-auto mb-2" />
                    <p className="text-sm text-slate-500">Nenhum dado disponível</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* SLA Performance Chart */}
          <Card className="border-0 shadow-lg">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center space-x-2">
                  <Target className="w-5 h-5" />
                  <span>Performance de SLA</span>
                </CardTitle>
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={() => generateReport('sla', 'csv')}
                  data-testid="button-export-sla-csv"
                >
                  <Download className="w-4 h-4 mr-2" />
                  Exportar
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                {isLoadingSLA ? (
                  <div>
                    <div className="text-center mb-6">
                      <Skeleton className="h-16 w-24 mx-auto mb-2" />
                      <Skeleton className="h-4 w-20 mx-auto" />
                    </div>
                    <div className="space-y-4">
                      {Array.from({ length: 3 }).map((_, i) => (
                        <div key={i} className="flex items-center justify-between">
                          <Skeleton className="h-4 w-20" />
                          <div className="flex items-center space-x-2">
                            <Skeleton className="w-24 h-3 rounded-full" />
                            <Skeleton className="h-4 w-10" />
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ) : errorSLA ? (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>
                      Erro ao carregar dados de SLA: {errorSLA.message}
                    </AlertDescription>
                  </Alert>
                ) : (
                  <div>
                    <div className="text-center mb-6 p-6 bg-gradient-to-r from-green-50 to-blue-50 rounded-lg">
                      <div className="text-5xl font-bold text-green-600 mb-2" data-testid="sla-total-average">
                        {safeGet(slaPerformance, 'totalSLA', 0)}%
                      </div>
                      <div className="text-sm font-medium text-slate-600">SLA Médio Geral</div>
                    </div>
                    
                    <div className="space-y-4">
                      {slaPerformance && safeGet(slaPerformance, 'categories', null) && Array.isArray(safeGet(slaPerformance, 'categories', [])) ? (
                        safeGet(slaPerformance, 'categories', []).map((category: any) => (
                          <div key={category.category} className="flex items-center justify-between p-3 bg-slate-50 rounded-lg" data-testid={`sla-category-${category.category}`}>
                            <span className="text-sm font-medium text-slate-700">{category.label}</span>
                            <div className="flex items-center space-x-3">
                              <div className="w-32 h-3 bg-slate-200 rounded-full overflow-hidden">
                                <div 
                                  className={`h-full rounded-full transition-all duration-500 ${
                                    category.category === 'onTime' ? 'bg-green-500' :
                                    category.category === 'atRisk' ? 'bg-yellow-500' :
                                    'bg-red-500'
                                  }`}
                                  style={{ width: `${Math.min(category.percentage, 100)}%` }}
                                ></div>
                              </div>
                              <Badge variant="outline" className="font-bold" data-testid={`sla-percentage-${category.category}`}>
                                {category.percentage}%
                              </Badge>
                            </div>
                          </div>
                        ))
                      ) : (
                        <div className="text-center py-8">
                          <Target className="w-12 h-12 text-slate-300 mx-auto mb-2" />
                          <p className="text-sm text-slate-500">Nenhum dado disponível</p>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Quick Export Options */}
        <Card className="border-0 shadow-lg">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Zap className="w-5 h-5 text-blue-600" />
              <span>Exportação Rápida</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Relatório Completo PDF */}
              <div className="group">
                <Button 
                  className="w-full h-20 flex flex-col items-center justify-center space-y-3 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1"
                  onClick={() => generateReport('geral', 'pdf')}
                  disabled={isGenerating === 'geral-pdf'}
                  data-testid="button-quick-export-all-pdf"
                >
                  {isGenerating === 'geral-pdf' ? (
                    <RefreshCw className="w-6 h-6 animate-spin" />
                  ) : (
                    <FileText className="w-6 h-6" />
                  )}
                  <span className="text-sm font-medium">
                    {isGenerating === 'geral-pdf' ? 'Gerando...' : 'Relatório Completo PDF'}
                  </span>
                </Button>
              </div>
              
              {/* Análise SLA CSV */}
              <div className="group">
                <Button 
                  variant="outline"
                  className="w-full h-20 flex flex-col items-center justify-center space-y-3 border-2 border-green-200 hover:border-green-400 hover:bg-green-50 text-green-700 hover:text-green-800 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1"
                  onClick={() => generateReport('sla', 'csv')}
                  disabled={isGenerating === 'sla-csv'}
                  data-testid="button-quick-export-sla-csv"
                >
                  {isGenerating === 'sla-csv' ? (
                    <RefreshCw className="w-6 h-6 animate-spin" />
                  ) : (
                    <Target className="w-6 h-6" />
                  )}
                  <span className="text-sm font-medium">
                    {isGenerating === 'sla-csv' ? 'Gerando...' : 'Análise SLA CSV'}
                  </span>
                </Button>
              </div>
              
              {/* Produtividade Excel */}
              <div className="group">
                <Button 
                  variant="outline"
                  className="w-full h-20 flex flex-col items-center justify-center space-y-3 border-2 border-purple-200 hover:border-purple-400 hover:bg-purple-50 text-purple-700 hover:text-purple-800 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1"
                  onClick={() => generateReport('produtividade', 'excel')}
                  disabled={isGenerating === 'produtividade-excel'}
                  data-testid="button-quick-export-productivity-excel"
                >
                  {isGenerating === 'produtividade-excel' ? (
                    <RefreshCw className="w-6 h-6 animate-spin" />
                  ) : (
                    <TrendingUp className="w-6 h-6" />
                  )}
                  <span className="text-sm font-medium">
                    {isGenerating === 'produtividade-excel' ? 'Gerando...' : 'Produtividade Excel'}
                  </span>
                </Button>
              </div>
            </div>
            
            {/* Informações adicionais */}
            <div className="mt-6 p-4 bg-gradient-to-r from-slate-50 to-blue-50 rounded-lg border border-slate-200">
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <Download className="w-4 h-4 text-blue-600" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-slate-900">Downloads Instantâneos</p>
                  <p className="text-xs text-slate-600">Relatórios baseados nos dados dos últimos {dateRange} dias • Geração automática com dados reais</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </main>
    </>
  );
}