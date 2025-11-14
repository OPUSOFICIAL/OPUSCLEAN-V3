import { Camera, CameraResultType, CameraSource, GalleryImageOptions } from '@capacitor/camera';

export interface CapturedPhoto {
  base64: string;
  format: string;
  dataUrl: string;
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
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Camera,
    });

    if (!image.base64String) {
      throw new Error('Failed to capture image');
    }

    const format = image.format || 'jpeg';
    const dataUrl = `data:image/${format};base64,${image.base64String}`;

    return {
      base64: image.base64String,
      format,
      dataUrl,
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
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Photos,
    });

    if (!image.base64String) {
      throw new Error('Failed to select image');
    }

    const format = image.format || 'jpeg';
    const dataUrl = `data:image/${format};base64,${image.base64String}`;

    return {
      base64: image.base64String,
      format,
      dataUrl,
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
  try {
    const image = await Camera.getPhoto({
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Prompt,
    });

    if (!image.base64String) {
      throw new Error('Failed to capture/select image');
    }

    const format = image.format || 'jpeg';
    const dataUrl = `data:image/${format};base64,${image.base64String}`;

    return {
      base64: image.base64String,
      format,
      dataUrl,
    };
  } catch (error) {
    console.warn('[CAMERA] Native prompt unavailable, falling back to file input:', error);
    
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

export async function pickMultipleImages(options?: { limit?: number; quality?: number }): Promise<CapturedPhoto[]> {
  try {
    const galleryOptions: GalleryImageOptions = {
      quality: options?.quality || 90,
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
        const dataUrl = `data:image/${format};base64,${base64}`;

        return {
          base64,
          format,
          dataUrl,
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
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'image/*';
  if (multiple) {
    input.multiple = true;
  }

  let hasInteracted = false;

  input.onchange = async (e: Event) => {
    hasInteracted = true;
    const target = e.target as HTMLInputElement;
    const files = target.files;
    
    if (!files || files.length === 0) {
      onPhotosSelected([]);
      return;
    }

    try {
      const photos = await Promise.all(
        Array.from(files).map(async (file) => {
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
          const dataUrl = `data:image/${format};base64,${base64}`;

          return { base64, format, dataUrl };
        })
      );

      onPhotosSelected(photos);
    } catch (error) {
      console.error('[CAMERA FALLBACK] Error converting files:', error);
      onPhotosSelected([]);
    }
  };

  window.addEventListener('focus', () => {
    setTimeout(() => {
      if (!hasInteracted) {
        console.log('[CAMERA FALLBACK] User cancelled file selection');
        if (onCancel) {
          onCancel();
        } else {
          onPhotosSelected([]);
        }
      }
    }, 300);
  }, { once: true });

  input.click();
}
