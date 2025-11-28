import { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import { QRCodePoint, WorkOrder } from '../types';
import * as db from '../db/database';

interface QRScannerScreenProps {
  workOrders: WorkOrder[];
  onScanComplete: (order: WorkOrder | null, qrCode: QRCodePoint | null) => void;
  onClose: () => void;
}

export function QRScannerScreen({
  workOrders,
  onScanComplete,
  onClose,
}: QRScannerScreenProps) {
  const [permission, requestPermission] = useCameraPermissions();
  const [scanned, setScanned] = useState(false);

  useEffect(() => {
    if (permission && !permission.granted && permission.canAskAgain) {
      requestPermission();
    }
  }, [permission, requestPermission]);

  const handleBarCodeScanned = async ({ type, data }: { type: string; data: string }) => {
    if (scanned) return;
    setScanned(true);

    try {
      const qrCode = await db.findQRCodeByCode(data);
      
      if (!qrCode) {
        Alert.alert(
          'QR Code nao encontrado',
          'Este QR code nao esta cadastrado no sistema ou nao esta autorizado para este cliente.',
          [
            {
              text: 'Tentar novamente',
              onPress: () => setScanned(false),
            },
            {
              text: 'Cancelar',
              onPress: onClose,
              style: 'cancel',
            },
          ]
        );
        return;
      }

      const matchingOrders = workOrders.filter(
        (order) => order.zoneId === qrCode.zoneId && order.status !== 'completed'
      );

      if (matchingOrders.length === 0) {
        Alert.alert(
          'Nenhuma OS encontrada',
          `QR Code: ${qrCode.name}\nLocal: ${qrCode.siteName} - ${qrCode.zoneName}\n\nNenhuma ordem de servico pendente para esta zona.`,
          [
            {
              text: 'Tentar novamente',
              onPress: () => setScanned(false),
            },
            {
              text: 'Fechar',
              onPress: onClose,
            },
          ]
        );
        return;
      }

      if (matchingOrders.length === 1) {
        onScanComplete(matchingOrders[0], qrCode);
      } else {
        Alert.alert(
          `${matchingOrders.length} OSs encontradas`,
          `QR Code: ${qrCode.name}\nZona: ${qrCode.zoneName}\n\nEncontradas ${matchingOrders.length} ordens de servico nesta zona.`,
          [
            {
              text: 'Ver lista',
              onPress: () => onScanComplete(null, qrCode),
            },
            {
              text: 'Cancelar',
              onPress: () => setScanned(false),
            },
          ]
        );
      }
    } catch (error) {
      console.error('Erro ao processar QR code:', error);
      Alert.alert('Erro', 'Ocorreu um erro ao processar o QR code.', [
        {
          text: 'Tentar novamente',
          onPress: () => setScanned(false),
        },
      ]);
    }
  };

  if (!permission) {
    return (
      <View style={styles.container}>
        <Text style={styles.permissionText}>Verificando permissao da camera...</Text>
      </View>
    );
  }

  if (!permission.granted) {
    return (
      <View style={styles.container}>
        <View style={styles.permissionContainer}>
          <Text style={styles.permissionTitle}>Permissao da Camera</Text>
          <Text style={styles.permissionText}>
            Para escanear QR codes, precisamos de acesso a camera do seu dispositivo.
          </Text>
          <TouchableOpacity style={styles.permissionButton} onPress={requestPermission}>
            <Text style={styles.permissionButtonText}>Permitir Acesso</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.cancelButton} onPress={onClose}>
            <Text style={styles.cancelButtonText}>Cancelar</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <CameraView
        style={styles.camera}
        barcodeScannerSettings={{
          barcodeTypes: ['qr'],
        }}
        onBarcodeScanned={scanned ? undefined : handleBarCodeScanned}
      >
        <View style={styles.overlay}>
          <View style={styles.header}>
            <TouchableOpacity style={styles.closeButton} onPress={onClose}>
              <Text style={styles.closeButtonText}>X</Text>
            </TouchableOpacity>
            <Text style={styles.headerTitle}>Escanear QR Code</Text>
            <View style={styles.placeholder} />
          </View>

          <View style={styles.scanArea}>
            <View style={styles.cornerTopLeft} />
            <View style={styles.cornerTopRight} />
            <View style={styles.cornerBottomLeft} />
            <View style={styles.cornerBottomRight} />
          </View>

          <View style={styles.instructions}>
            <Text style={styles.instructionText}>
              Posicione o QR code dentro da area marcada
            </Text>
            {scanned && (
              <Text style={styles.processingText}>Processando...</Text>
            )}
          </View>
        </View>
      </CameraView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  camera: {
    flex: 1,
  },
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.3)',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 50,
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.3)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  headerTitle: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  placeholder: {
    width: 40,
  },
  scanArea: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  cornerTopLeft: {
    position: 'absolute',
    top: '25%',
    left: '15%',
    width: 40,
    height: 40,
    borderTopWidth: 4,
    borderLeftWidth: 4,
    borderColor: '#3B82F6',
    borderRadius: 4,
  },
  cornerTopRight: {
    position: 'absolute',
    top: '25%',
    right: '15%',
    width: 40,
    height: 40,
    borderTopWidth: 4,
    borderRightWidth: 4,
    borderColor: '#3B82F6',
    borderRadius: 4,
  },
  cornerBottomLeft: {
    position: 'absolute',
    bottom: '25%',
    left: '15%',
    width: 40,
    height: 40,
    borderBottomWidth: 4,
    borderLeftWidth: 4,
    borderColor: '#3B82F6',
    borderRadius: 4,
  },
  cornerBottomRight: {
    position: 'absolute',
    bottom: '25%',
    right: '15%',
    width: 40,
    height: 40,
    borderBottomWidth: 4,
    borderRightWidth: 4,
    borderColor: '#3B82F6',
    borderRadius: 4,
  },
  instructions: {
    padding: 24,
    alignItems: 'center',
  },
  instructionText: {
    color: '#fff',
    fontSize: 16,
    textAlign: 'center',
    opacity: 0.9,
  },
  processingText: {
    color: '#3B82F6',
    fontSize: 16,
    fontWeight: '600',
    marginTop: 12,
  },
  permissionContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
    backgroundColor: '#f8fafc',
  },
  permissionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 16,
  },
  permissionText: {
    fontSize: 16,
    color: '#64748b',
    textAlign: 'center',
    marginBottom: 24,
  },
  permissionButton: {
    backgroundColor: '#3B82F6',
    paddingHorizontal: 32,
    paddingVertical: 14,
    borderRadius: 8,
    marginBottom: 12,
  },
  permissionButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  cancelButton: {
    paddingHorizontal: 32,
    paddingVertical: 14,
  },
  cancelButtonText: {
    color: '#64748b',
    fontSize: 16,
  },
});
