import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';

export interface CapturedPhoto {
  base64: string;
  format: string;
  dataUrl: string;
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
    console.error('[CAMERA] Error taking picture:', error);
    throw error;
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
    console.error('[CAMERA] Error selecting from gallery:', error);
    throw error;
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
    console.error('[CAMERA] Error prompting for picture:', error);
    throw error;
  }
}
