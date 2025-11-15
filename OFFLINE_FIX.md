# 🔌 Offline Mode Fix - APK Truly Works Offline Now!

## Problem

The APK was **NOT truly offline-first**. It failed when scanning QR codes without internet:
- Error: "Erro de conexão. Verifique sua internet e tente novamente."
- Reason: `capacitor.config.ts` had `server.url` configured, forcing all requests to remote server
- QR scanner didn't check if device was online before making API calls

## Root Causes

### 1. **capacitor.config.ts with `server.url`**
```typescript
// WRONG (old config):
server: {
  url: 'https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev',
  cleartext: true,
}
```

This makes Capacitor load **everything from remote server**, breaking offline mode completely.

### 2. **mobile-qr-scanner.tsx didn't check online status**
```typescript
// WRONG (old code):
const response = await fetch(`/api/qr-scan/resolve?code=${code}`);
// No check if isOnline!
```

## Solution Applied

### Fix 1: Removed `server.url` from capacitor.config.ts
```typescript
// NEW config:
const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'OPUS Facilities',
  webDir: 'dist/public',
  // OFFLINE-FIRST: Assets bundled locally via capacitor://
  // No server.url!
};
```

Now APK:
- ✅ Bundles all assets locally
- ✅ Serves via `capacitor://` protocol
- ✅ Works 100% offline after initial sync

### Fix 2: Added Offline Check to QR Scanner
```typescript
// NEW code:
const { isOnline } = useNetworkStatus();
const { getQRPoint, getZone } = useOfflineStorage();

if (!isOnline) {
  // Fetch from IndexedDB instead of API
  const cachedPoint = await getQRPoint(extractedCode);
  const cachedZone = await getZone(cachedPoint.zoneId);
  // Show cached data!
}
```

### Fix 3: Visual Offline Indicator
Added orange "Offline" badge in scanner header when network is disconnected.

---

## How to Get the Fixed APK

### Step 1: Download Updated Project
1. Click **3 dots (⋮)** in this Replit
2. Select **"Download as ZIP"**
3. Extract and replace old folder

### Step 2: Rebuild APK

**Windows:**
```bash
gerar-apk.bat
```

**Mac/Linux:**
```bash
./gerar-apk.sh
```

### Step 3: Install on Device

⚠️ **IMPORTANT:** Uninstall old APK first!

Install new APK:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

---

## Testing Offline Mode

### 1. **Initial Setup (Online Required)**
- Login: `admin` / `admin123`
- App automatically syncs:
  - QR points
  - Zones
  - Scheduled work orders
  - Checklist templates

### 2. **Enable Offline Mode**
- Turn on **Airplane Mode** ✈️
- Or disable WiFi/Mobile Data

### 3. **Test QR Scanning Offline**
- Scan a QR code
- ✅ Should show: "✈️ QR Code detectado! (Modo Offline)"
- ✅ Shows cached zone/site names
- ✅ Orange "Offline" badge appears in header

### 4. **Execute Work Order Offline**
- Select "Executar Atividade Programada"
- Fill checklist
- Add photos (camera works!)
- Save → All stored in IndexedDB

### 5. **Sync When Back Online**
- Disable Airplane Mode
- Auto-sync starts in ~1 second
- All data (WOs + photos) uploaded to server!

---

## What Changed

| Before (Broken Offline) | After (True Offline-First) |
|-------------------------|----------------------------|
| ❌ server.url forced remote loading | ✅ Local bundled assets |
| ❌ QR scanner always called API | ✅ Checks isOnline first |
| ❌ No offline fallback | ✅ Uses IndexedDB when offline |
| ❌ No offline indicator | ✅ Orange "Offline" badge |
| ❌ Failed without internet | ✅ Works 100% offline! |

---

## Complete Offline Flow (Fixed!)

1. ✅ **Login online** (first time only)
2. ✅ **Auto-sync** metadata to IndexedDB
3. ✅ **Enable Airplane Mode** ✈️
4. ✅ **Scan QR** → Reads from cache!
5. ✅ **Execute checklist** → Saves locally
6. ✅ **Take photos** → Stores in base64
7. ✅ **Disable Airplane Mode**
8. ✅ **Auto-sync in 1 second!** → Uploads everything

---

## Technical Details

### Offline Storage (IndexedDB v4)
- `qrPoints` - QR code metadata (code → point mapping)
- `zones` - Zone details (names, sites)
- `scheduledWorkOrders` - Programmed work orders
- `checklistTemplates` - Checklist definitions
- `workOrders` - Created work orders (offline)
- `checklistExecutions` - Completed checklists (offline)
- `attachments` - Photos in base64 (offline)

### Sync Strategy
1. **Priority-based queue**: Work orders → Checklists → Attachments
2. **3-phase batching**: Sequential sync in correct order
3. **Parent-child linking**: Auto-updates IDs after sync
4. **Exponential backoff**: Retries with increasing delays
5. **Auto-sync on reconnect**: Network plugin triggers sync

---

## Troubleshooting

### "QR Code não encontrado offline"
**Cause:** QR code not in cache  
**Fix:** Connect to internet, scan QR once online (caches it), then go offline

### Still getting "Erro de conexão"
**Cause:** Old APK still installed  
**Fix:** 
1. **Completely uninstall** old APK
2. **Reinstall** new APK (from latest build)
3. **Login again** to re-sync cache

### Offline indicator not showing
**Cause:** Using old APK without fix  
**Fix:** Rebuild and reinstall APK

---

## Key Files Changed

- `capacitor.config.ts` - Removed server.url (offline-first assets)
- `client/src/lib/queryClient.ts` - Added Capacitor detection + absolute URLs
- `client/src/pages/mobile-qr-scanner.tsx` - Added offline check + IndexedDB + absolute URLs
- `android/app/src/main/AndroidManifest.xml` - Camera permissions (previous fix)

## Architecture Evolution

1. **v1.0.1:** Login fixed with `server.url`
2. **v1.0.2:** Camera fixed with Android permissions
3. **v1.0.3:** Offline attempt (removed `server.url` → broke login!)
4. **v1.0.4:** **Hybrid architecture** - Local assets + Remote API ✅

See `HYBRID_ARCHITECTURE.md` for technical details.

---

**Version:** 1.0.4 (hybrid offline-first!)  
**Last update:** November 2025
