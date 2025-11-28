import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';
import * as FileSystem from 'expo-file-system';
import { CapturedPhoto } from '../types';

const MAX_WIDTH = 1920;
const MAX_HEIGHT = 1920;
const COMPRESSION_QUALITY = 0.6;

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

export async function requestCameraPermission(): Promise<boolean> {
  const { status } = await ImagePicker.requestCameraPermissionsAsync();
  return status === 'granted';
}

export async function requestMediaLibraryPermission(): Promise<boolean> {
  const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
  return status === 'granted';
}

async function compressImage(uri: string): Promise<{ uri: string; base64: string; width: number; height: number }> {
  const manipulatedImage = await ImageManipulator.manipulateAsync(
    uri,
    [{ resize: { width: MAX_WIDTH, height: MAX_HEIGHT } }],
    {
      compress: COMPRESSION_QUALITY,
      format: ImageManipulator.SaveFormat.JPEG,
      base64: true,
    }
  );

  return {
    uri: manipulatedImage.uri,
    base64: manipulatedImage.base64 || '',
    width: manipulatedImage.width,
    height: manipulatedImage.height,
  };
}

export async function takePhoto(): Promise<CapturedPhoto | null> {
  const hasPermission = await requestCameraPermission();
  if (!hasPermission) {
    throw new Error('Permissao de camera negada');
  }

  const result = await ImagePicker.launchCameraAsync({
    mediaTypes: 'images',
    allowsEditing: false,
    quality: 0.8,
  });

  if (result.canceled || !result.assets || result.assets.length === 0) {
    return null;
  }

  const asset = result.assets[0];
  const compressed = await compressImage(asset.uri);

  return {
    id: generateId(),
    uri: compressed.uri,
    base64: compressed.base64,
    width: compressed.width,
    height: compressed.height,
    createdAt: new Date().toISOString(),
  };
}

export async function pickFromGallery(): Promise<CapturedPhoto | null> {
  const hasPermission = await requestMediaLibraryPermission();
  if (!hasPermission) {
    throw new Error('Permissao de galeria negada');
  }

  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: 'images',
    allowsEditing: false,
    quality: 0.8,
  });

  if (result.canceled || !result.assets || result.assets.length === 0) {
    return null;
  }

  const asset = result.assets[0];
  const compressed = await compressImage(asset.uri);

  return {
    id: generateId(),
    uri: compressed.uri,
    base64: compressed.base64,
    width: compressed.width,
    height: compressed.height,
    createdAt: new Date().toISOString(),
  };
}

export async function pickMultipleFromGallery(maxCount: number = 10): Promise<CapturedPhoto[]> {
  const hasPermission = await requestMediaLibraryPermission();
  if (!hasPermission) {
    throw new Error('Permissao de galeria negada');
  }

  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: 'images',
    allowsMultipleSelection: true,
    selectionLimit: maxCount,
    quality: 0.8,
  });

  if (result.canceled || !result.assets || result.assets.length === 0) {
    return [];
  }

  const photos: CapturedPhoto[] = [];
  
  for (const asset of result.assets) {
    try {
      const compressed = await compressImage(asset.uri);
      photos.push({
        id: generateId(),
        uri: compressed.uri,
        base64: compressed.base64,
        width: compressed.width,
        height: compressed.height,
        createdAt: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Erro ao comprimir imagem:', error);
    }
  }

  return photos;
}

export function getBase64DataUrl(base64: string): string {
  return `data:image/jpeg;base64,${base64}`;
}

export async function getFileSize(uri: string): Promise<number> {
  try {
    const info = await FileSystem.getInfoAsync(uri);
    return (info as any).size || 0;
  } catch {
    return 0;
  }
}
