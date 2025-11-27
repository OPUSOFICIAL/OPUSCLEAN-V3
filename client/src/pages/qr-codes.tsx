import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useState, useEffect } from "react";
import { useToast } from "@/hooks/use-toast";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { useModuleTheme } from "@/hooks/use-module-theme";
import { ModernCard, ModernCardHeader, ModernCardContent } from "@/components/ui/modern-card";
import { ModernPageHeader } from "@/components/ui/modern-page-header";
import QRCode from "qrcode";
import { 
  QrCode as QrCodeIcon, 
  Download, 
  Plus, 
  Trash2,
  FileText,
  Printer,
  Check,
  Copy,
  RefreshCw
} from "lucide-react";
import jsPDF from 'jspdf';
import { cn } from "@/lib/utils";
import aceleraLogo from "@assets/acelera-full-facilities-logo.png";

const QR_SIZES_CM = [3, 4, 5, 6, 7, 8, 10, 12, 15];
const cmToPixels = (cm: number) => Math.round(cm * 28.35);

const DEFAULT_MODULE_COLORS = {
  clean: { primary: '#1e3a8a', secondary: '#3b82f6', accent: '#60a5fa' },
  maintenance: { primary: '#FF9800', secondary: '#FB8C00', accent: '#FFB74D' }
};

const hexToRgb = (hex: string): { r: number; g: number; b: number } => {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? { r: parseInt(result[1], 16), g: parseInt(result[2], 16), b: parseInt(result[3], 16) }
    : { r: 30, g: 58, b: 138 };
};

const loadImage = (src: string): Promise<string> => {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => {
      const canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.drawImage(img, 0, 0);
        resolve(canvas.toDataURL('image/png'));
      } else {
        reject(new Error('Could not get canvas context'));
      }
    };
    img.onerror = reject;
    img.src = src;
  });
};

export default function QrCodes() {
  const { activeClientId, activeClient } = useClient();
  const { currentModule } = useModule();
  const theme = useModuleTheme();
  const [selectedSite, setSelectedSite] = useState("");
  const [selectedZone, setSelectedZone] = useState("");
  const [pointName, setPointName] = useState("");
  const [pointCode, setPointCode] = useState("");
  const [qrSizeCm, setQrSizeCm] = useState(5);
  const [qrCodeImages, setQrCodeImages] = useState<{[key: string]: string}>({});
  const [selectedQrCodes, setSelectedQrCodes] = useState<string[]>([]);
  const [isGeneratingPDF, setIsGeneratingPDF] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [moduleColor, setModuleColor] = useState({ r: 30, g: 58, b: 138 });
  
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Update moduleColor whenever activeClient or currentModule changes
  useEffect(() => {
    const moduleColors = activeClient?.moduleColors;
    const moduleKey = currentModule as 'clean' | 'maintenance';
    
    let color = DEFAULT_MODULE_COLORS[moduleKey]?.primary || DEFAULT_MODULE_COLORS.clean.primary;
    
    if (moduleColors?.[moduleKey]?.primary) {
      color = moduleColors[moduleKey].primary;
    }
    
    setModuleColor(hexToRgb(color));
    console.log(`[QR PDF] Cor do módulo ${moduleKey} atualizada:`, hexToRgb(color));
  }, [activeClient, currentModule]);

  const { data: sites } = useQuery({
    queryKey: ["/api/customers", activeClientId, "sites", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const { data: zones } = useQuery({
    queryKey: ["/api/sites", selectedSite, "zones", { module: currentModule }],
    enabled: !!selectedSite,
  });

  const { data: qrPoints, isLoading } = useQuery({
    queryKey: ["/api/customers", activeClientId, "qr-points", { module: currentModule }],
    enabled: !!activeClientId,
  });

  const createQrPointMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("POST", `/api/customers/${activeClientId}/qr-points`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "qr-points"] });
      toast({ title: "✅ QR Code criado com sucesso!" });
      setSelectedSite("");
      setSelectedZone("");
      setPointName("");
      setPointCode("");
      setQrSizeCm(5);
    },
    onError: () => {
      toast({ 
        title: "Erro ao criar QR Code", 
        description: "Tente novamente",
        variant: "destructive" 
      });
    },
  });

  // Resetar zona quando mudar o site
  useEffect(() => {
    setSelectedZone("");
  }, [selectedSite]);

  const handleCreateQrPoint = () => {
    if (!selectedZone || !pointName) {
      toast({ 
        title: "Preencha todos os campos obrigatórios", 
        description: "Local e nome são obrigatórios",
        variant: "destructive" 
      });
      return;
    }

    createQrPointMutation.mutate({
      zoneId: selectedZone,
      type: "execucao",
      name: pointName,
      sizeCm: qrSizeCm,
      module: currentModule,
      ...(pointCode ? { code: pointCode } : {}),
    });
  };

  const handleRefresh = async () => {
    setIsRefreshing(true);
    toast({ title: "🔄 Atualizando lista..." });
    await queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "qr-points"] });
    // Pequeno delay para garantir que a animação seja visível
    setTimeout(() => {
      setIsRefreshing(false);
    }, 500);
  };

  const generateQrCodeUrl = (type: string, code: string) => {
    if (type === 'execucao') return code;
    const baseUrl = window.location.origin;
    return `${baseUrl}/qr-public/${code}`;
  };

  const generateQrCodeImage = async (url: string, sizeCm: number): Promise<string> => {
    const sizePixels = cmToPixels(sizeCm);
    try {
      return await QRCode.toDataURL(url, {
        width: sizePixels,
        margin: 2,
        color: { dark: '#000000', light: '#FFFFFF' }
      });
    } catch (error) {
      console.error('Erro ao gerar QR code:', error);
      return '';
    }
  };

  useEffect(() => {
    const generateAllQrCodes = async () => {
      if (!qrPoints || (qrPoints as any[]).length === 0) return;

      const newQrImages: {[key: string]: string} = {};
      
      for (const point of qrPoints as any[]) {
        const url = generateQrCodeUrl(point.type, point.code);
        const sizeCm = point.sizeCm || 5;
        const qrCodeDataUrl = await generateQrCodeImage(url, sizeCm);
        if (qrCodeDataUrl) {
          newQrImages[point.id] = qrCodeDataUrl;
        }
      }
      
      setQrCodeImages(newQrImages);
    };

    generateAllQrCodes();
  }, [qrPoints]);

  const getModuleColor = (): { r: number; g: number; b: number } => {
    const moduleColors = activeClient?.moduleColors;
    const moduleKey = currentModule as 'clean' | 'maintenance';
    
    if (moduleColors?.[moduleKey]?.primary) {
      return hexToRgb(moduleColors[moduleKey].primary);
    }
    
    return hexToRgb(DEFAULT_MODULE_COLORS[moduleKey]?.primary || DEFAULT_MODULE_COLORS.clean.primary);
  };

  const downloadPDF = async (point: any) => {
    const url = generateQrCodeUrl(point.type, point.code);
    const sizeCm = point.sizeCm || 5;
    const qrCodeDataUrl = await generateQrCodeImage(url, sizeCm);
    
    const pdf = new jsPDF();
    const pageWidth = 210;
    const pageHeight = 297;
    
    const qrSizeMM = sizeCm * 10;
    const borderMM = 8;
    const padding = 6;
    
    // Dimensões melhoradas
    const qrWithBorderWidthMM = qrSizeMM + (borderMM * 2);
    const headerHeightMM = 28;
    const qrWithBorderHeightMM = qrSizeMM + (borderMM * 2) + headerHeightMM;
    const qrX = (pageWidth - qrWithBorderWidthMM) / 2;
    const qrY = 35;
    
    // Background colorido com bordas arredondadas
    pdf.setFillColor(moduleColor.r, moduleColor.g, moduleColor.b);
    pdf.roundedRect(qrX, qrY, qrWithBorderWidthMM, qrWithBorderHeightMM, 3, 3, 'F');
    
    // Header com logo
    const headerBgY = qrY;
    const headerBgHeight = headerHeightMM;
    
    // Logo e texto no header
    try {
      const logoDataUrl = await loadImage(aceleraLogo);
      const logoMaxWidth = qrWithBorderWidthMM - (padding * 2);
      const logoMaxHeight = headerBgHeight - (padding * 2);
      const logoHeight = logoMaxHeight * 0.8;
      const logoWidth = logoHeight * 4;
      const logoX = qrX + (qrWithBorderWidthMM - Math.min(logoWidth, logoMaxWidth)) / 2;
      const logoY = headerBgY + padding;
      pdf.addImage(logoDataUrl, 'PNG', logoX, logoY, Math.min(logoWidth, logoMaxWidth), logoHeight);
      console.log('[QR PDF] Logo adicionada com sucesso ao header');
    } catch (error) {
      console.log('[QR PDF] Usando texto em vez de logo');
      pdf.setTextColor(255, 255, 255);
      pdf.setFontSize(10);
      pdf.setFont('helvetica', 'bold');
      pdf.text('ACELERA FULL FACILITIES', qrX + qrWithBorderWidthMM / 2, headerBgY + headerBgHeight / 2 + 2, { align: 'center' });
    }
    
    // QR Code em fundo branco
    const qrInnerY = qrY + headerHeightMM;
    pdf.setFillColor(255, 255, 255);
    pdf.rect(qrX + borderMM - 1, qrInnerY + borderMM - 1, qrSizeMM + 2, qrSizeMM + 2);
    
    pdf.addImage(qrCodeDataUrl, 'PNG', qrX + borderMM, qrInnerY + borderMM, qrSizeMM, qrSizeMM);
    
    // Informações abaixo do QR
    const infoStartY = qrY + qrWithBorderHeightMM + 10;
    const lineHeight = 6;
    
    // Nome do ponto
    pdf.setTextColor(30, 41, 59);
    pdf.setFontSize(16);
    pdf.setFont('helvetica', 'bold');
    pdf.text(point.name, pageWidth / 2, infoStartY, { align: 'center' });
    
    // Código
    pdf.setTextColor(80, 92, 110);
    pdf.setFontSize(11);
    pdf.setFont('helvetica', 'normal');
    pdf.text(`Código: ${point.code}`, pageWidth / 2, infoStartY + lineHeight + 3, { align: 'center' });
    
    // Zona/Local
    if (point.zoneName) {
      pdf.setTextColor(120, 130, 145);
      pdf.setFontSize(10);
      pdf.setFont('helvetica', 'italic');
      pdf.text(`Local: ${point.zoneName}`, pageWidth / 2, infoStartY + (lineHeight + 3) * 2, { align: 'center' });
    }
    
    // Separador visual inferior
    pdf.setDrawColor(moduleColor.r, moduleColor.g, moduleColor.b);
    pdf.setLineWidth(0.5);
    const separatorY = pageHeight - 15;
    pdf.line(20, separatorY, pageWidth - 20, separatorY);
    
    pdf.setTextColor(150, 160, 170);
    pdf.setFontSize(8);
    pdf.setFont('helvetica', 'normal');
    pdf.text('Acelera Full Facilities', pageWidth / 2, separatorY + 5, { align: 'center' });
    
    pdf.save(`qr_${point.name.replace(/\s+/g, '_')}_${sizeCm}cm.pdf`);
  };

  const downloadMultiplePDF = async () => {
    if (selectedQrCodes.length === 0) {
      toast({ title: "Selecione QR codes para imprimir", variant: "destructive" });
      return;
    }

    setIsGeneratingPDF(true);
    const selectedPoints = (qrPoints as any[]).filter(point => selectedQrCodes.includes(point.id));
    const pdf = new jsPDF();
    
    const pageWidth = 210;
    const pageHeight = 297;
    const margin = 8;
    const spacing = 5;
    
    const moduleColor = getModuleColor();
    
    let logoDataUrl: string | null = null;
    try {
      logoDataUrl = await loadImage(aceleraLogo);
    } catch (error) {
      console.warn('Could not load logo for PDF');
    }
    
    let currentY = margin;
    let currentX = margin;
    let maxRowHeight = 0;
    const borderMM = 6;
    const logoHeaderMM = 8;
    const textHeight = 18;
    
    for (let i = 0; i < selectedPoints.length; i++) {
      const point = selectedPoints[i];
      const sizeCm = point.sizeCm || 5;
      const qrSizeMM = sizeCm * 10;
      const qrWithBorderWidthMM = qrSizeMM + (borderMM * 2);
      const qrWithBorderHeightMM = qrSizeMM + (borderMM * 2) + logoHeaderMM;
      const totalItemHeight = qrWithBorderHeightMM + textHeight;
      
      if (currentX + qrWithBorderWidthMM > pageWidth - margin && currentX > margin) {
        currentY += maxRowHeight + spacing;
        currentX = margin;
        maxRowHeight = 0;
      }
      
      if (currentY + totalItemHeight > pageHeight - margin) {
        pdf.addPage();
        currentY = margin;
        currentX = margin;
        maxRowHeight = 0;
      }
      
      const url = generateQrCodeUrl(point.type, point.code);
      const qrCodeDataUrl = await generateQrCodeImage(url, sizeCm);
      
      pdf.setFillColor(moduleColor.r, moduleColor.g, moduleColor.b);
      pdf.roundedRect(currentX, currentY, qrWithBorderWidthMM, qrWithBorderHeightMM, 3, 3, 'F');
      
      if (logoDataUrl) {
        const logoWidth = qrWithBorderWidthMM - 6;
        const logoHeight = logoWidth / 4;
        const logoX = currentX + (qrWithBorderWidthMM - logoWidth) / 2;
        const logoY = currentY + 1.5;
        pdf.addImage(logoDataUrl, 'PNG', logoX, logoY, logoWidth, Math.min(logoHeight, 6));
      } else {
        pdf.setTextColor(255, 255, 255);
        pdf.setFontSize(5);
        pdf.setFont('helvetica', 'bold');
        pdf.text('ACELERA', currentX + qrWithBorderWidthMM / 2, currentY + 5, { align: 'center' });
      }
      
      pdf.setFillColor(255, 255, 255);
      pdf.roundedRect(currentX + borderMM, currentY + logoHeaderMM + 1, qrSizeMM, qrSizeMM, 1, 1, 'F');
      
      pdf.addImage(qrCodeDataUrl, 'PNG', currentX + borderMM, currentY + logoHeaderMM + 1, qrSizeMM, qrSizeMM);
      
      const textY = currentY + qrWithBorderHeightMM + 4;
      
      pdf.setTextColor(30, 41, 59);
      pdf.setFontSize(7);
      pdf.setFont('helvetica', 'bold');
      const maxNameWidth = qrWithBorderWidthMM - 2;
      const nameParts = pdf.splitTextToSize(point.name, maxNameWidth);
      pdf.text(nameParts[0], currentX + qrWithBorderWidthMM / 2, textY, { align: 'center' });
      
      pdf.setTextColor(100, 116, 139);
      pdf.setFontSize(6);
      pdf.setFont('helvetica', 'normal');
      pdf.text(`${point.code}`, currentX + qrWithBorderWidthMM / 2, textY + 5, { align: 'center' });
      
      currentX += qrWithBorderWidthMM + spacing;
      maxRowHeight = Math.max(maxRowHeight, totalItemHeight);
    }
    
    pdf.save(`qr_codes_multiplos_${selectedPoints.length}_itens.pdf`);
    toast({ title: `${selectedPoints.length} QR codes baixados em PDF` });
    setIsGeneratingPDF(false);
  };

  const deleteQrPointMutation = useMutation({
    mutationFn: async (id: string) => {
      return await apiRequest("DELETE", `/api/qr-points/${id}`);
    },
    onSuccess: () => {
      toast({ title: "QR Code excluído com sucesso" });
      queryClient.invalidateQueries({ queryKey: ["/api/customers", activeClientId, "qr-points"] });
    },
  });

  const toggleSelection = (id: string) => {
    setSelectedQrCodes(prev => 
      prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
    );
  };

  const toggleSelectAll = () => {
    if (selectedQrCodes.length === (qrPoints as any[])?.length) {
      setSelectedQrCodes([]);
    } else {
      setSelectedQrCodes((qrPoints as any[])?.map(p => p.id) || []);
    }
  };

  return (
    <>
      <ModernPageHeader 
        title="QR Codes"
        description="Gerencie códigos QR para execução e serviços públicos"
        icon={QrCodeIcon}
        stats={[
          { 
            label: "Total de QR Codes", 
            value: (qrPoints as any[])?.length || 0,
            icon: QrCodeIcon
          }
        ]}
        actions={
          <Button 
            onClick={handleRefresh}
            className={cn("flex items-center gap-2", theme.buttons.primary)}
            style={theme.buttons.primaryStyle}
            size="sm"
            disabled={isRefreshing}
            data-testid="button-refresh-header"
          >
            <RefreshCw className={cn("w-4 h-4", isRefreshing && "animate-spin")} />
            Atualizar
          </Button>
        }
      />
      
      <div className={cn("flex-1 overflow-y-auto p-4 md:p-6 space-y-6", theme.gradients.section)}>
        <ModernCard variant="default">
          <ModernCardHeader icon={<Plus className="w-6 h-6" />}>
            Criar Novo QR Code
          </ModernCardHeader>
          <ModernCardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Coluna Esquerda - Informações Principais */}
              <div className="space-y-5">
                <div>
                  <label className="text-sm font-semibold mb-2 flex items-center gap-2 text-gray-700">
                    <div className={cn("w-6 h-6 rounded-full flex items-center justify-center", theme.backgrounds.light)}>
                      <span className={cn("text-xs font-bold", theme.text.primary)}>1</span>
                    </div>
                    Local <span className="text-red-500">*</span>
                  </label>
                  <Select value={selectedSite} onValueChange={setSelectedSite}>
                    <SelectTrigger 
                      data-testid="select-site"
                      className={`h-12 ${!selectedSite ? 'border-orange-300 bg-orange-50/30' : 'border-green-300 bg-green-50/30'}`}
                    >
                      <SelectValue placeholder="Selecione o local" />
                    </SelectTrigger>
                    <SelectContent>
                      {(sites as any[])?.map((site: any) => (
                        <SelectItem key={site.id} value={site.id}>
                          {site.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  {!selectedSite && (
                    <p className="text-xs text-orange-600 mt-1">Escolha o local onde o QR será instalado</p>
                  )}
                </div>

                <div>
                  <label className="text-sm font-semibold mb-2 flex items-center gap-2 text-gray-700">
                    <div className={cn("w-6 h-6 rounded-full flex items-center justify-center", theme.backgrounds.light)}>
                      <span className={cn("text-xs font-bold", theme.text.primary)}>2</span>
                    </div>
                    Zona <span className="text-red-500">*</span>
                  </label>
                  <Select value={selectedZone} onValueChange={setSelectedZone} disabled={!selectedSite}>
                    <SelectTrigger 
                      data-testid="select-zone"
                      className={`h-12 ${!selectedZone && selectedSite ? 'border-orange-300 bg-orange-50/30' : selectedZone ? 'border-green-300 bg-green-50/30' : ''}`}
                    >
                      <SelectValue placeholder={selectedSite ? "Selecione a zona" : "Selecione o local primeiro"} />
                    </SelectTrigger>
                    <SelectContent>
                      {(zones as any[])?.map((zone: any) => (
                        <SelectItem key={zone.id} value={zone.id}>
                          {zone.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  {!selectedSite && (
                    <p className="text-xs text-gray-500 mt-1">Primeiro selecione um local</p>
                  )}
                  {selectedSite && !selectedZone && (
                    <p className="text-xs text-orange-600 mt-1">Escolha a zona específica dentro do local</p>
                  )}
                </div>

                <div>
                  <label className="text-sm font-semibold mb-2 flex items-center gap-2 text-gray-700">
                    <div className={cn("w-6 h-6 rounded-full flex items-center justify-center", theme.backgrounds.light)}>
                      <span className={cn("text-xs font-bold", theme.text.primary)}>3</span>
                    </div>
                    Nome do Ponto <span className="text-red-500">*</span>
                  </label>
                  <Input
                    placeholder="Ex: Sala de Reunião 1"
                    value={pointName}
                    onChange={(e) => setPointName(e.target.value)}
                    data-testid="input-point-name"
                    className={`h-12 ${!pointName ? 'border-orange-300 bg-orange-50/30' : 'border-green-300 bg-green-50/30'}`}
                  />
                  {!pointName && (
                    <p className="text-xs text-orange-600 mt-1">Digite um nome descritivo para o ponto</p>
                  )}
                </div>
              </div>

              {/* Coluna Direita - Detalhes Opcionais */}
              <div className="space-y-5">
                <div>
                  <label className="text-sm font-semibold mb-2 flex items-center gap-2 text-gray-700">
                    <FileText className="w-4 h-4 text-gray-500" />
                    Código Personalizado <span className="text-gray-400 text-xs">(opcional)</span>
                  </label>
                  <Input
                    placeholder="Ex: SR-001, QR-123"
                    value={pointCode}
                    onChange={(e) => setPointCode(e.target.value)}
                    data-testid="input-point-code"
                    className="h-12 border-gray-300"
                  />
                  <p className="text-xs text-gray-500 mt-1">Deixe em branco para gerar automaticamente</p>
                </div>

                <div>
                  <label className="text-sm font-semibold mb-2 flex items-center gap-2 text-gray-700">
                    <QrCodeIcon className="w-4 h-4 text-gray-500" />
                    Tamanho do QR Code
                  </label>
                  <Select value={String(qrSizeCm)} onValueChange={(v) => setQrSizeCm(Number(v))}>
                    <SelectTrigger data-testid="select-size" className="h-12">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {QR_SIZES_CM.map(size => (
                        <SelectItem key={size} value={String(size)}>
                          {size} cm {size === 5 && '(recomendado)'} {size >= 10 && '(grande)'}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <p className="text-xs text-gray-500 mt-1">5 cm é ideal para a maioria dos casos</p>
                </div>

                <div className="pt-4">
                  <Button 
                    onClick={handleCreateQrPoint} 
                    className={cn("w-full h-14 text-base font-semibold", theme.buttons.primary)}
                    style={theme.buttons.primaryStyle}
                    disabled={createQrPointMutation.isPending}
                    data-testid="button-create-qr"
                  >
                    {createQrPointMutation.isPending ? (
                      <>
                        <div className="w-5 h-5 mr-3 border-2 border-white border-t-transparent rounded-full animate-spin" />
                        Gerando QR Code...
                      </>
                    ) : (
                      <>
                        <QrCodeIcon className="w-5 h-5 mr-3" />
                        Criar QR Code
                      </>
                    )}
                  </Button>
                  {(!selectedSite || !selectedZone || !pointName) && (
                    <p className="text-xs text-center text-orange-600 mt-2 font-medium">
                      ⚠️ Preencha todos os campos obrigatórios (*)
                    </p>
                  )}
                </div>
              </div>
            </div>
          </ModernCardContent>
        </ModernCard>

        {selectedQrCodes.length > 0 && (
          <Card className={cn(theme.backgrounds.light, theme.borders.primary)}>
            <CardContent className="py-4">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">
                  {selectedQrCodes.length} selecionado{selectedQrCodes.length > 1 ? 's' : ''}
                </span>
                <div className="flex gap-2">
                  <Button 
                    variant="outline" 
                    size="sm" 
                    onClick={() => setSelectedQrCodes([])}
                    disabled={isGeneratingPDF}
                  >
                    Limpar
                  </Button>
                  <Button 
                    variant="default"
                    size="sm" 
                    onClick={downloadMultiplePDF}
                    disabled={isGeneratingPDF}
                    className={theme.buttons.primary}
                    style={theme.buttons.primaryStyle}
                  >
                    {isGeneratingPDF ? (
                      <>
                        <div className="w-4 h-4 mr-2 border-2 border-white border-t-transparent rounded-full animate-spin" />
                        Gerando PDF...
                      </>
                    ) : (
                      <>
                        <Printer className="w-4 h-4 mr-2" />
                        Baixar PDF
                      </>
                    )}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>QR Codes Cadastrados</CardTitle>
              <div className="flex gap-2">
                <Button
                  onClick={handleRefresh}
                  className={cn("flex items-center gap-2", theme.buttons.primary)}
                  style={theme.buttons.primaryStyle}
                  size="sm"
                  disabled={isRefreshing}
                  data-testid="button-refresh-qr"
                >
                  <RefreshCw className={cn("w-4 h-4", isRefreshing && "animate-spin")} />
                  Atualizar
                </Button>
                {(qrPoints as any[])?.length > 0 && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={toggleSelectAll}
                    data-testid="button-select-all"
                  >
                    {selectedQrCodes.length === (qrPoints as any[])?.length ? (
                    <>
                      <Copy className="w-4 h-4 mr-2" />
                      Desmarcar Todos
                    </>
                  ) : (
                    <>
                      <Check className="w-4 h-4 mr-2" />
                      Selecionar Todos
                    </>
                  )}
                </Button>
                )}
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-center text-muted-foreground py-8">Carregando...</p>
            ) : (qrPoints as any[])?.length === 0 ? (
              <p className="text-center text-muted-foreground py-8">Nenhum QR code cadastrado</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {(qrPoints as any[])?.map((point: any) => {
                  const sizeCm = point.sizeCm || 5;
                  const isSelected = selectedQrCodes.includes(point.id);
                  
                  return (
                    <Card 
                      key={point.id} 
                      className={cn(
                        "relative transition-all duration-200",
                        isSelected && "ring-2 ring-offset-2",
                        isSelected && theme.borders.primary
                      )}
                    >
                      <CardContent className="p-6">
                        {/* Checkbox */}
                        <button
                          onClick={() => toggleSelection(point.id)}
                          data-testid={`checkbox-qr-${point.id}`}
                          className={cn(
                            "absolute top-4 left-4 w-7 h-7 rounded-md border-2 flex items-center justify-center transition-all duration-200 hover:scale-110",
                            isSelected 
                              ? "border-transparent shadow-lg"
                              : 'border-gray-400 bg-white hover:border-gray-600 hover:bg-gray-50'
                          )}
                          style={isSelected ? {
                            background: 'linear-gradient(135deg, var(--module-primary), var(--module-secondary))'
                          } : undefined}
                        >
                          {isSelected && <Check className="w-5 h-5 text-white font-bold" />}
                        </button>

                        {/* Badge Tipo */}
                        <Badge className={cn("absolute top-4 right-4", theme.backgrounds.primary)}>
                          Execução
                        </Badge>

                        {/* QR Code com borda dinâmica */}
                        <div className="flex justify-center my-4">
                          <div className="relative">
                            <div className={cn("p-4 rounded-2xl", theme.backgrounds.primary)}>
                              {qrCodeImages[point.id] && (
                                <div className="bg-white p-2">
                                  <img 
                                    src={qrCodeImages[point.id]} 
                                    alt={point.name}
                                    className="w-32 h-32"
                                  />
                                </div>
                              )}
                            </div>
                          </div>
                        </div>

                        {/* Badge Execução */}
                        <div className="flex justify-center mb-3">
                          <Badge className={cn(theme.badges.light, "px-4 py-1")}>
                            ⚡ Execução
                          </Badge>
                        </div>

                        {/* Informações */}
                        <div className="text-center space-y-1 mb-4">
                          <h3 className="font-bold text-base">{point.name}</h3>
                          <p className="text-sm text-muted-foreground">Código: {point.code}</p>
                          {point.zoneName && (
                            <>
                              <p className="text-xs text-muted-foreground">Local: {point.zoneName}</p>
                              {point.siteName && (
                                <p className="text-xs text-muted-foreground">
                                  Endereço: {point.siteName}
                                </p>
                              )}
                            </>
                          )}
                        </div>

                        {/* Botões */}
                        <Button 
                          variant="default"
                          className={cn("w-full", theme.buttons.primary)}
                          style={theme.buttons.primaryStyle}
                          size="sm"
                          onClick={() => downloadPDF(point)}
                        >
                          <FileText className="w-4 h-4 mr-2" />
                          Baixar PDF
                        </Button>

                        {/* Ações extras */}
                        <div className="grid grid-cols-2 gap-2 mt-2">
                          <Button 
                            variant="ghost" 
                            size="sm"
                            onClick={() => {
                              navigator.clipboard.writeText(point.code);
                              toast({ title: "Código copiado!" });
                            }}
                          >
                            <Copy className="w-4 h-4 mr-1" />
                            Copiar
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="sm"
                            className="text-red-600 hover:text-red-700"
                            onClick={() => deleteQrPointMutation.mutate(point.id)}
                          >
                            <Trash2 className="w-4 h-4 mr-1" />
                            Excluir
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  );
                })}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </>
  );
}
