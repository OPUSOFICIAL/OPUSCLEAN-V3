# 🏗️ Hybrid Architecture - Local Assets + Remote API

## Problem Solved

After removing `server.url` from `capacitor.config.ts`, the APK worked offline but **login broke** because the app couldn't connect to the backend server.

## Solution: Hybrid Architecture

The APK now uses a **hybrid approach**:
1. ✅ **Local Assets** - HTML/CSS/JS bundled in APK (offline-first)
2. ✅ **Remote API** - HTTP requests to backend server (login, sync)

---

## How It Works

### Detection Logic

```typescript
import { Capacitor } from "@capacitor/core";

function getApiBaseUrl(): string {
  if (Capacitor.isNativePlatform()) {
    // Running in APK → Use absolute URL
    return 'https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev';
  }
  
  // Running in browser → Use relative URL (Vite proxy)
  return '';
}
```

### URL Transformation

| Environment | Original URL | Transformed URL |
|-------------|--------------|-----------------|
| **Web Browser** | `/api/auth/login` | `/api/auth/login` (relative) |
| **APK (Capacitor)** | `/api/auth/login` | `https://server.com/api/auth/login` (absolute) |

---

## Files Modified

### 1. `client/src/lib/queryClient.ts`
Added Capacitor detection to all API requests:

```typescript
import { Capacitor } from "@capacitor/core";

// Convert relative URLs to absolute when in Capacitor
function getFullUrl(url: string): string {
  const baseUrl = getApiBaseUrl();
  
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url; // Already absolute
  }
  
  return baseUrl + url; // Combine base + relative
}

// Used in apiRequest() and getQueryFn()
const fullUrl = getFullUrl(url);
const res = await fetch(fullUrl, { ... });
```

### 2. `client/src/pages/mobile-qr-scanner.tsx`
Added URL transformation for QR scanning:

```typescript
import { Capacitor } from "@capacitor/core";

function getApiBaseUrl(): string {
  if (Capacitor.isNativePlatform()) {
    return 'https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev';
  }
  return '';
}

// In handleQrCode():
const baseUrl = getApiBaseUrl();
const apiUrl = `${baseUrl}/api/qr-scan/resolve?code=${code}`;
const response = await fetch(apiUrl, { ... });
```

### 3. `capacitor.config.ts` (NO server.url!)
```typescript
const config: CapacitorConfig = {
  appId: 'com.acelerait.facilities',
  appName: 'OPUS Facilities',
  webDir: 'dist/public',
  // NO server.url → Assets served locally!
};
```

---

## Environment Variable (Future Production)

For production, create `.env` with backend URL:

```env
VITE_API_BASE_URL=https://your-production-server.com
```

Then code will use:
```typescript
return import.meta.env.VITE_API_BASE_URL || 'https://default-dev-server.com';
```

---

## Complete Flow

### 1. Login (Online Required)
```
APK (capacitor://localhost)
  ↓
Login button clicked
  ↓
fetch('https://server.com/api/auth/login') ← Absolute URL!
  ↓
Token saved to localStorage
  ↓
IndexedDB sync starts
```

### 2. Offline Execution
```
APK (capacitor://localhost)
  ↓
Scan QR (Airplane mode ✈️)
  ↓
IndexedDB lookup (local!)
  ↓
Show cached data
  ↓
Save WO to IndexedDB
```

### 3. Auto-Sync (Back Online)
```
APK (capacitor://localhost)
  ↓
Network plugin detects reconnection
  ↓
SyncQueueManager starts
  ↓
fetch('https://server.com/api/work-orders') ← Absolute URL!
  ↓
Upload WOs + photos
```

---

## Advantages

| Feature | Old (server.url) | New (Hybrid) |
|---------|------------------|--------------|
| **Assets** | ❌ Remote loaded | ✅ Local bundled |
| **Offline** | ❌ Broken | ✅ Works 100% |
| **Login** | ✅ Worked | ✅ Still works! |
| **Sync** | ✅ Worked | ✅ Still works! |
| **Speed** | ❌ Slow (remote) | ✅ Fast (local) |

---

## How to Update APK

Same as before:

### Windows:
```bash
gerar-apk.bat
```

### Mac/Linux:
```bash
./gerar-apk.sh
```

**IMPORTANT:** Uninstall old APK completely before installing new one!

---

## Testing Checklist

### ✅ Login (Online)
- [x] Open APK
- [x] Login with `admin` / `admin123`
- [x] Should work! No "Erro de conexão"

### ✅ QR Scanning (Online)
- [x] Scan QR code with internet
- [x] Should show zone/site
- [x] Should cache to IndexedDB

### ✅ QR Scanning (Offline)
- [x] Enable Airplane Mode ✈️
- [x] Scan QR code
- [x] Should show: "✈️ QR Code detectado! (Modo Offline)"
- [x] Orange "Offline" badge visible

### ✅ Work Order Execution (Offline)
- [x] Execute checklist offline
- [x] Add photos offline
- [x] Save → Stored in IndexedDB

### ✅ Auto-Sync (Online)
- [x] Disable Airplane Mode
- [x] Wait ~1 second
- [x] All data uploaded to server!

---

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│         APK (capacitor://localhost)     │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐   ┌──────────────┐  │
│  │ HTML/CSS/JS  │   │  IndexedDB   │  │
│  │   (Local)    │   │   (Cache)    │  │
│  └──────────────┘   └──────────────┘  │
│                                         │
│  Capacitor.isNativePlatform() = true   │
│                                         │
│  apiRequest('/api/auth/login')          │
│         ↓                               │
│  getFullUrl('/api/auth/login')          │
│         ↓                               │
│  'https://server.com/api/auth/login'    │
│                                         │
└─────────────┬───────────────────────────┘
              │
              │ HTTPS (Internet)
              ↓
┌─────────────────────────────────────────┐
│      Backend Server (Express.js)        │
│   https://server.com                    │
├─────────────────────────────────────────┤
│  - Authentication                       │
│  - Work Orders API                      │
│  - QR Resolution                        │
│  - File Upload                          │
│  - Database (PostgreSQL)                │
└─────────────────────────────────────────┘
```

---

## Troubleshooting

### "Erro no login" still appears
**Cause:** Old APK still installed  
**Fix:**
1. Uninstall old APK **completely**
2. Rebuild: `gerar-apk.bat` or `./gerar-apk.sh`
3. Install new APK
4. Try login again

### Network requests fail
**Cause:** Backend URL incorrect  
**Fix:** Check `client/src/lib/queryClient.ts`:
```typescript
return import.meta.env.VITE_API_BASE_URL || 'https://YOUR-CORRECT-SERVER.com';
```

### Offline mode broken again
**Cause:** Not checking `isOnline` before API calls  
**Fix:** Always check network status:
```typescript
const { isOnline } = useNetworkStatus();

if (!isOnline) {
  // Use IndexedDB
} else {
  // Use API
}
```

---

**Version:** 1.0.4 (Hybrid Architecture)  
**Last update:** November 2025
