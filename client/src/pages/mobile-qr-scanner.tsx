import { useState, useRef, useEffect } from "react";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft, Camera, Flashlight, FlashlightOff, RotateCcw } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import QrScanner from "qr-scanner";
import ServiceSelectionModal from "@/components/ServiceSelectionModal";

const COMPANY_ID = "company-opus-default";

export default function MobileQrScanner() {
  const [, setLocation] = useLocation();
  const { toast } = useToast();
  
  // QR Scanner States
  const videoRef = useRef<HTMLVideoElement>(null);
  const qrScannerRef = useRef<QrScanner | null>(null);
  const [hasCamera, setHasCamera] = useState(true);
  const [isScanning, setIsScanning] = useState(false);
  const [cameras, setCameras] = useState<QrScanner.Camera[]>([]);
  const [selectedCameraId, setSelectedCameraId] = useState<string>("");
  const [flashOn, setFlashOn] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);

  // Modal States
  const [showServiceModal, setShowServiceModal] = useState(false);
  const [resolvedContext, setResolvedContext] = useState<any>(null);
  const [scannedQrCode, setScannedQrCode] = useState<string>("");

  useEffect(() => {
    initializeCamera();
    return () => {
      stopScanner();
    };
  }, []);

  const initializeCamera = async () => {
    try {
      const hasPermission = await QrScanner.hasCamera();
      setHasCamera(hasPermission);
      
      if (hasPermission) {
        const availableCameras = await QrScanner.listCameras();
        setCameras(availableCameras);
        
        const backCamera = availableCameras.find(camera => 
          camera.label.toLowerCase().includes('back') || 
          camera.label.toLowerCase().includes('rear') ||
          camera.label.toLowerCase().includes('environment')
        );
        
        const cameraToUse = backCamera || availableCameras[0];
        if (cameraToUse) {
          setSelectedCameraId(cameraToUse.id);
          await startScanner(cameraToUse.id);
        }
      }
    } catch (error) {
      console.error("Erro ao inicializar câmera:", error);
      setHasCamera(false);
    }
  };

  const startScanner = async (cameraId?: string) => {
    if (!videoRef.current) return;

    try {
      stopScanner();

      const scanner = new QrScanner(
        videoRef.current,
        (result) => {
          if (!isProcessing) {
            handleQrCodeDetected(result.data);
          }
        },
        {
          preferredCamera: cameraId || selectedCameraId,
          highlightScanRegion: true,
          highlightCodeOutline: true,
          maxScansPerSecond: 1,
          returnDetailedScanResult: true,
        }
      );

      qrScannerRef.current = scanner;
      await scanner.start();
      setIsScanning(true);
    } catch (error) {
      console.error("Erro ao iniciar scanner:", error);
      setHasCamera(false);
      toast({
        title: "Erro no scanner",
        description: "Não foi possível iniciar o scanner QR.",
        variant: "destructive",
      });
    }
  };

  const stopScanner = () => {
    if (qrScannerRef.current) {
      qrScannerRef.current.stop();
      qrScannerRef.current.destroy();
      qrScannerRef.current = null;
    }
    setIsScanning(false);
  };

  const handleQrCodeDetected = async (qrCode: string) => {
    if (isProcessing) return;
    
    setIsProcessing(true);
    stopScanner();
    setScannedQrCode(qrCode);
    
    // Extrair código da URL se necessário
    let extractedCode = qrCode;
    if (qrCode.includes('replit.dev/qr-execution/') || qrCode.includes('/qr-execution/')) {
      const match = qrCode.match(/\/qr-execution\/([^\/\?]+)/);
      if (match) {
        extractedCode = match[1];
      }
    }

    try {
      // Adicionar token de autenticação
      const token = localStorage.getItem("opus_clean_token");
      const headers: Record<string, string> = {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
      };
      
      if (token) {
        headers["Authorization"] = `Bearer ${token}`;
      }
      
      const response = await fetch(`/api/qr-scan/resolve?code=${encodeURIComponent(extractedCode)}`, {
        cache: 'no-store',
        headers
      });
      
      if (response.ok) {
        const resolved = await response.json();
        
        // Verificar se tem customer
        if (!resolved.customer) {
          throw new Error('QR code sem cliente associado');
        }
        
        setResolvedContext(resolved);
        setShowServiceModal(true);
        
        toast({
          title: "QR Code detectado!",
          description: `${resolved.zone.name} - ${resolved.site.name}`,
        });
      } else {
        throw new Error('QR code não encontrado ou inativo');
      }
    } catch (error) {
      console.error("Erro ao processar QR code:", error);
      toast({
        title: "QR Code inválido",
        description: "O QR code não pôde ser processado. Tente novamente.",
        variant: "destructive",
      });
      
      setIsProcessing(false);
      setTimeout(() => startScanner(), 2000);
    }
  };

  const handleServiceSelection = async (serviceId: string, checklistAnswers?: any, workOrderId?: string) => {
    console.log('[QR SCANNER] handleServiceSelection chamado:', { serviceId, workOrderId, hasResolvedContext: !!resolvedContext });
    
    if (!resolvedContext) {
      console.error('[QR SCANNER] Erro: resolvedContext está vazio!');
      return;
    }

    try {
      // Se está selecionando uma work order existente
      if (workOrderId) {
        console.log('[QR SCANNER] Selecionando work order existente:', workOrderId);
        setShowServiceModal(false);
        setLocation(`/mobile/work-order/${workOrderId}`);
        return;
      }

      // Criar nova work order
      const customerId = resolvedContext.customer.id;
      const qrModule = resolvedContext.qrPoint?.module || 'clean';
      const workOrderData = {
        companyId: COMPANY_ID,
        module: qrModule,
        siteId: resolvedContext.site.id,
        zoneId: resolvedContext.zone.id,
        serviceId: serviceId,
        orderType: 'corretiva_interna',
        priority: 'media',
        title: `Serviço via QR - ${resolvedContext.zone.name}`,
        description: `Work order criada via QR Code: ${scannedQrCode}`,
        origin: 'QR Scanner Mobile',
        qrCodePointId: resolvedContext.qrPoint?.id,
        checklistData: checklistAnswers || null
      };
      
      console.log('[QR SCANNER] Criando work order com módulo:', qrModule);

      console.log('[QR SCANNER] Criando nova work order para customer:', customerId, workOrderData);

      const response = await fetch(`/api/customers/${customerId}/work-orders`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(workOrderData),
      });

      console.log('[QR SCANNER] Response status:', response.status);

      if (response.ok) {
        const workOrder = await response.json();
        console.log('[QR SCANNER] Work order criada:', workOrder);
        
        toast({
          title: "Work Order Criada!",
          description: `OS #${workOrder.number} criada com sucesso`,
        });

        setShowServiceModal(false);
        console.log('[QR SCANNER] Navegando para:', `/mobile/work-order/${workOrder.id}`);
        setLocation(`/mobile/work-order/${workOrder.id}`);
      } else {
        const errorData = await response.text();
        console.error('[QR SCANNER] Erro na resposta:', response.status, errorData);
        throw new Error(`Erro ao criar work order: ${response.status}`);
      }
    } catch (error) {
      console.error("[QR SCANNER] Erro ao processar serviço:", error);
      toast({
        title: "Erro",
        description: "Não foi possível criar a work order.",
        variant: "destructive",
      });
    }
  };

  const handleModalClose = () => {
    setShowServiceModal(false);
    setResolvedContext(null);
    setScannedQrCode("");
    setIsProcessing(false);
    setTimeout(() => startScanner(), 500);
  };

  const toggleFlash = async () => {
    if (qrScannerRef.current) {
      try {
        if (flashOn) {
          await qrScannerRef.current.turnFlashOff();
          setFlashOn(false);
        } else {
          await qrScannerRef.current.turnFlashOn();
          setFlashOn(true);
        }
      } catch (error) {
        toast({
          title: "Flash não disponível",
          description: "O flash não está disponível neste dispositivo.",
          variant: "destructive",
        });
      }
    }
  };

  const switchCamera = async () => {
    if (cameras.length <= 1) return;
    
    const currentIndex = cameras.findIndex(camera => camera.id === selectedCameraId);
    const nextIndex = (currentIndex + 1) % cameras.length;
    const nextCamera = cameras[nextIndex];
    
    setSelectedCameraId(nextCamera.id);
    await startScanner(nextCamera.id);
    
    toast({
      title: "Câmera alterada",
      description: nextCamera.label,
    });
  };

  if (!hasCamera) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
        <div className="max-w-md mx-auto">
          <div className="flex items-center justify-between mb-6">
            <Button 
              variant="ghost" 
              onClick={() => setLocation("/mobile")}
              className="p-2"
              data-testid="button-back"
            >
              <ArrowLeft className="w-6 h-6" />
            </Button>
            <h1 className="text-xl font-bold">Scanner QR</h1>
            <div></div>
          </div>

          <Card className="bg-white/80 backdrop-blur-sm border-white/20">
            <CardContent className="p-6 text-center">
              <Camera className="w-16 h-16 text-slate-400 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-slate-900 mb-2">
                Câmera não disponível
              </h3>
              <p className="text-slate-600 mb-4">
                Não foi possível acessar a câmera do dispositivo. Verifique as permissões.
              </p>
              <Button onClick={initializeCamera} className="w-full" data-testid="button-retry-camera">
                Tentar Novamente
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black relative">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-50 bg-black/50 backdrop-blur-sm">
        <div className="flex items-center justify-between p-4">
          <Button 
            variant="ghost" 
            onClick={() => setLocation("/mobile")}
            className="p-2 text-white hover:bg-white/20"
            data-testid="button-back-scanner"
          >
            <ArrowLeft className="w-6 h-6" />
          </Button>
          <h1 className="text-xl font-bold text-white">Scanner QR</h1>
          <div className="flex space-x-2">
            {cameras.length > 1 && (
              <Button 
                variant="ghost" 
                onClick={switchCamera}
                className="p-2 text-white hover:bg-white/20"
                data-testid="button-switch-camera"
              >
                <RotateCcw className="w-6 h-6" />
              </Button>
            )}
            <Button 
              variant="ghost" 
              onClick={toggleFlash}
              className="p-2 text-white hover:bg-white/20"
              data-testid="button-toggle-flash"
            >
              {flashOn ? <FlashlightOff className="w-6 h-6" /> : <Flashlight className="w-6 h-6" />}
            </Button>
          </div>
        </div>
      </div>

      {/* Camera View */}
      <div className="relative w-full h-screen">
        <video 
          ref={videoRef}
          className="w-full h-full object-cover"
          playsInline
          muted
        />
        
        {/* Scanning Overlay */}
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <div className="relative">
            {/* Scanning frame */}
            <div className="w-64 h-64 border-2 border-white/50 rounded-2xl relative">
              {/* Corner indicators */}
              <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-white rounded-tl-2xl"></div>
              <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-white rounded-tr-2xl"></div>
              <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-white rounded-bl-2xl"></div>
              <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-white rounded-br-2xl"></div>
              
              {/* Scanning line animation */}
              {isScanning && !isProcessing && (
                <div className="absolute top-0 left-0 right-0 h-1 bg-white animate-pulse"></div>
              )}
            </div>
            
            {/* Instructions */}
            <p className="text-white text-center mt-6 bg-black/50 px-4 py-2 rounded-lg">
              {isProcessing ? "Processando QR..." : isScanning ? "Posicione o QR code dentro da área" : "Iniciando scanner..."}
            </p>
          </div>
        </div>
      </div>

      {/* Service Selection Modal */}
      {showServiceModal && resolvedContext && (
        <ServiceSelectionModal
          isOpen={showServiceModal}
          onClose={handleModalClose}
          resolvedContext={resolvedContext}
          scannedQrCode={scannedQrCode}
          onServiceSelect={handleServiceSelection}
        />
      )}
    </div>
  );
}
