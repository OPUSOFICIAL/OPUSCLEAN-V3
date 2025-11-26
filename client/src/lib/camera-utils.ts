import { Camera, CameraResultType, CameraSource, GalleryImageOptions } from '@capacitor/camera';

export interface CapturedPhoto {
  base64: string;
  format: string;
  dataUrl: string;
  originalSize?: number;
  compressedSize?: number;
}

interface CompressionOptions {
  maxWidth?: number;
  maxHeight?: number;
  quality?: number;
}

async function compressImage(
  base64: string, 
  format: string, 
  options: CompressionOptions = {}
): Promise<{ base64: string; originalSize: number; compressedSize: number }> {
  const {
    maxWidth = 1920,
    maxHeight = 1920,
    quality = 0.6
  } = options;

  return new Promise((resolve, reject) => {
    try {
      const img = new Image();
      const dataUrl = `data:image/${format};base64,${base64}`;
      
      img.onload = () => {
        let width = img.width;
        let height = img.height;
        
        // Calcular novo tamanho mantendo aspect ratio
        if (width > maxWidth || height > maxHeight) {
          const ratio = Math.min(maxWidth / width, maxHeight / height);
          width = width * ratio;
          height = height * ratio;
        }
        
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        
        const ctx = canvas.getContext('2d');
        if (!ctx) {
          reject(new Error('Failed to get canvas context'));
          return;
        }
        
        ctx.drawImage(img, 0, 0, width, height);
        
        const compressedDataUrl = canvas.toDataURL(`image/${format}`, quality);
        const compressedBase64 = compressedDataUrl.split(',')[1];
        
        const originalSize = base64.length;
        const compressedSize = compressedBase64.length;
        
        console.log('[COMPRESSION]', {
          original: `${(originalSize / 1024).toFixed(2)}KB`,
          compressed: `${(compressedSize / 1024).toFixed(2)}KB`,
          reduction: `${(((originalSize - compressedSize) / originalSize) * 100).toFixed(1)}%`,
          dimensions: `${width}x${height}`
        });
        
        resolve({ base64: compressedBase64, originalSize, compressedSize });
      };
      
      img.onerror = () => {
        reject(new Error('Failed to load image for compression'));
      };
      
      img.src = dataUrl;
    } catch (error) {
      console.error('[COMPRESSION] Error:', error);
      reject(error);
    }
  });
}

async function webPathToBase64(webPath: string, format: string): Promise<string> {
  try {
    const response = await fetch(webPath);
    const blob = await response.blob();
    
    return new Promise<string>((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => {
        const dataUrl = reader.result as string;
        const base64 = dataUrl.split(',')[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  } catch (error) {
    console.error('[CAMERA] Error converting webPath to base64:', error);
    throw error;
  }
}

export async function takePictureWithCamera(): Promise<CapturedPhoto> {
  try {
    const image = await Camera.getPhoto({
      quality: 60,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Camera,
    });

    if (!image.base64String) {
      throw new Error('Failed to capture image');
    }

    const format = image.format || 'jpeg';
    
    const compressed = await compressImage(image.base64String, format, {
      maxWidth: 1920,
      maxHeight: 1920,
      quality: 0.6
    });
    
    const dataUrl = `data:image/${format};base64,${compressed.base64}`;

    return {
      base64: compressed.base64,
      format,
      dataUrl,
      originalSize: compressed.originalSize,
      compressedSize: compressed.compressedSize,
    };
  } catch (error) {
    console.warn('[CAMERA] Native camera unavailable, falling back to file input:', error);
    
    return new Promise<CapturedPhoto>((resolve, reject) => {
      createFileInputFallback(
        false,
        (photos) => {
          if (photos.length > 0) {
            resolve(photos[0]);
          } else {
            reject(new Error('No photo selected'));
          }
        },
        () => reject(new Error('User cancelled photo selection'))
      );
    });
  }
}

export async function selectFromGallery(): Promise<CapturedPhoto> {
  try {
    const image = await Camera.getPhoto({
      quality: 60,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Photos,
    });

    if (!image.base64String) {
      throw new Error('Failed to select image');
    }

    const format = image.format || 'jpeg';
    
    const compressed = await compressImage(image.base64String, format, {
      maxWidth: 1920,
      maxHeight: 1920,
      quality: 0.6
    });
    
    const dataUrl = `data:image/${format};base64,${compressed.base64}`;

    return {
      base64: compressed.base64,
      format,
      dataUrl,
      originalSize: compressed.originalSize,
      compressedSize: compressed.compressedSize,
    };
  } catch (error) {
    console.warn('[CAMERA] Native gallery unavailable, falling back to file input:', error);
    
    return new Promise<CapturedPhoto>((resolve, reject) => {
      createFileInputFallback(
        false,
        (photos) => {
          if (photos.length > 0) {
            resolve(photos[0]);
          } else {
            reject(new Error('No photo selected'));
          }
        },
        () => reject(new Error('User cancelled photo selection'))
      );
    });
  }
}

export async function promptForPicture(): Promise<CapturedPhoto> {
  console.log('[PROMPT_FOR_PICTURE] Starting photo capture/selection');
  try {
    const image = await Camera.getPhoto({
      quality: 60,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Prompt,
    });

    if (!image.base64String) {
      throw new Error('Failed to capture/select image');
    }

    const format = image.format || 'jpeg';
    
    const compressed = await compressImage(image.base64String, format, {
      maxWidth: 1920,
      maxHeight: 1920,
      quality: 0.6
    });
    
    const dataUrl = `data:image/${format};base64,${compressed.base64}`;

    return {
      base64: compressed.base64,
      format,
      dataUrl,
      originalSize: compressed.originalSize,
      compressedSize: compressed.compressedSize,
    };
  } catch (error) {
    console.warn('[CAMERA] Native prompt unavailable, falling back to file input:', error);
    console.log('[PROMPT_FOR_PICTURE] Showing file picker fallback');
    
    return new Promise<CapturedPhoto>((resolve, reject) => {
      try {
        createFileInputFallback(
          false,
          (photos) => {
            console.log('[PROMPT_FOR_PICTURE] Photos received:', photos.length);
            if (photos.length > 0) {
              console.log('[PROMPT_FOR_PICTURE] Resolving with first photo');
              resolve(photos[0]);
            } else {
              console.log('[PROMPT_FOR_PICTURE] No photos selected');
              reject(new Error('No photo selected'));
            }
          },
          () => {
            console.log('[PROMPT_FOR_PICTURE] User cancelled');
            reject(new Error('User cancelled photo selection'));
          }
        );
      } catch (fallbackError) {
        console.error('[PROMPT_FOR_PICTURE] Fallback error:', fallbackError);
        reject(fallbackError);
      }
    });
  }
}

export async function pickMultipleImages(options?: { limit?: number; quality?: number }): Promise<CapturedPhoto[]> {
  try {
    const galleryOptions: GalleryImageOptions = {
      quality: options?.quality || 60,
      limit: options?.limit || 10,
      correctOrientation: true,
    };

    const result = await Camera.pickImages(galleryOptions);

    if (!result?.photos || result.photos.length === 0) {
      return [];
    }

    const convertedPhotos = await Promise.all(
      result.photos.map(async (photo) => {
        const format = photo.format || 'jpeg';
        const base64 = await webPathToBase64(photo.webPath, format);
        
        const compressed = await compressImage(base64, format, {
          maxWidth: 1920,
          maxHeight: 1920,
          quality: 0.6
        });
        
        const dataUrl = `data:image/${format};base64,${compressed.base64}`;

        return {
          base64: compressed.base64,
          format,
          dataUrl,
          originalSize: compressed.originalSize,
          compressedSize: compressed.compressedSize,
        };
      })
    );

    return convertedPhotos;
  } catch (error) {
    console.warn('[CAMERA] Native plugin unavailable, falling back to file input:', error);
    
    return new Promise<CapturedPhoto[]>((resolve, reject) => {
      createFileInputFallback(
        true,
        (photos) => {
          if (photos.length > 0) {
            resolve(photos);
          } else {
            reject(new Error('No photos selected'));
          }
        },
        () => reject(new Error('User cancelled photo selection'))
      );
    });
  }
}

export function createFileInputFallback(
  multiple: boolean = false,
  onPhotosSelected: (photos: CapturedPhoto[]) => void,
  onCancel?: () => void
): void {
  console.log('[FILE_INPUT_FALLBACK] Creating file input picker, multiple:', multiple);
  
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'image/*';
  if (multiple) {
    input.multiple = true;
  }

  let hasInteracted = false;

  input.onchange = async (e: Event) => {
    console.log('[FILE_INPUT_FALLBACK] onChange triggered');
    hasInteracted = true;
    const target = e.target as HTMLInputElement;
    const files = target.files;
    
    if (!files || files.length === 0) {
      console.log('[FILE_INPUT_FALLBACK] No files selected');
      onPhotosSelected([]);
      return;
    }

    console.log('[FILE_INPUT_FALLBACK] Files selected:', files.length);

    try {
      const photos = await Promise.all(
        Array.from(files).map(async (file) => {
          console.log('[FILE_INPUT_FALLBACK] Processing file:', file.name, file.type);
          const base64 = await new Promise<string>((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => {
              const dataUrl = reader.result as string;
              resolve(dataUrl.split(',')[1]);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
          });

          const format = file.type.split('/')[1] || 'jpeg';
          
          const compressed = await compressImage(base64, format, {
            maxWidth: 1920,
            maxHeight: 1920,
            quality: 0.6
          });
          
          const dataUrl = `data:image/${format};base64,${compressed.base64}`;

          return { 
            base64: compressed.base64, 
            format, 
            dataUrl,
            originalSize: compressed.originalSize,
            compressedSize: compressed.compressedSize,
          };
        })
      );

      console.log('[FILE_INPUT_FALLBACK] Photos processed:', photos.length);
      onPhotosSelected(photos);
    } catch (error) {
      console.error('[FILE_INPUT_FALLBACK] Error converting files:', error);
      onPhotosSelected([]);
    }
  };

  input.onerror = (error) => {
    console.error('[FILE_INPUT_FALLBACK] Input error:', error);
    if (onCancel) onCancel();
  };

  window.addEventListener('focus', () => {
    setTimeout(() => {
      if (!hasInteracted) {
        console.log('[FILE_INPUT_FALLBACK] User cancelled file selection (focus event)');
        if (onCancel) {
          onCancel();
        } else {
          onPhotosSelected([]);
        }
      }
    }, 300);
  }, { once: true });

  console.log('[FILE_INPUT_FALLBACK] Triggering file picker click()');
  try {
    input.click();
  } catch (clickError) {
    console.error('[FILE_INPUT_FALLBACK] Error triggering click:', clickError);
    if (onCancel) onCancel();
  }
}
