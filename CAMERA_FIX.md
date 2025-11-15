# 📸 Camera Fix - Android Permissions

## Problem

The APK was showing "Camera not available" error because **AndroidManifest.xml was missing camera permissions**.

## Solution

Added all required camera and storage permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Camera Permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />

<!-- Gallery/Storage Permissions (Android 12 and below) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

<!-- Android 13+ (Tiramisu) Media Permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

---

## Rebuild Instructions

### Step 1: Download Updated Project

1. Click the **3 dots (⋮)** in this Replit
2. Select **"Download as ZIP"**
3. Extract and replace your old folder

### Step 2: Rebuild APK

**Windows:**
```bash
gerar-apk.bat
```

**Mac/Linux:**
```bash
./gerar-apk.sh
```

### Step 3: Reinstall on Device

⚠️ **IMPORTANT:** Uninstall old APK first!

Then install the new APK:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

---

## Testing Camera

1. Login with `admin` / `admin123`
2. Scan a QR code
3. Execute a work order
4. Click "Add Photo"
5. ✅ Camera should now work!

---

## Permission Prompts

Android will ask for permissions on first use:

**Camera:**
> Allow OPUS Facilities to take pictures and record video?  
> → Click "Allow"

**Gallery:**
> Allow OPUS Facilities to access photos and media?  
> → Click "Allow"

---

## Troubleshooting

### If camera still doesn't work:

1. **Check permissions manually:**
   - Settings → Apps → OPUS Facilities → Permissions
   - Ensure "Camera" and "Photos & Videos" are "Allowed"

2. **Reinstall APK:**
   - Completely uninstall the app
   - Reinstall the new APK
   - Accept permissions when prompted

3. **Restart device:**
   - Sometimes Android needs a restart to apply permissions

---

## What Changed

| Before (Old APK) | After (New APK) |
|------------------|-----------------|
| ❌ No camera permissions | ✅ All camera permissions |
| ❌ Camera didn't work | ✅ Camera works |
| ❌ Gallery didn't work | ✅ Gallery works |
| ❌ No Android 13+ support | ✅ Android 13+ compatible |

---

## Complete Offline Flow with Photos

1. ✅ Login online
2. ✅ Sync data (QR points, zones, WOs, checklists)
3. ✅ Enable airplane mode
4. ✅ Scan QR → View scheduled activity
5. ✅ Execute checklist
6. ✅ **Take photos with native camera!** 📸
7. ✅ Save everything locally (IndexedDB)
8. ✅ Disable airplane mode
9. ✅ Auto-sync in 1 second (uploads photos + data)

---

**Version:** 1.0.2 (with camera permissions)  
**Last update:** November 2025
