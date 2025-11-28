export interface User {
  id: string;
  username: string;
  name: string;
  email: string;
  role: string;
  userType: string;
  customerId: string | null;
  companyId: string;
  modules: string[];
  token: string;
}

export interface WorkOrder {
  id: string;
  workOrderNumber: number;
  title: string;
  description: string | null;
  status: 'open' | 'in_progress' | 'paused' | 'completed' | 'cancelled';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  module: 'clean' | 'maintenance';
  customerId: string;
  siteId: string;
  siteName: string;
  zoneId: string;
  zoneName: string;
  scheduledDate: string;
  assignedUserId: string | null;
  assignedUserName: string | null;
  createdAt: string;
  updatedAt: string;
  offlineModified: boolean;
  offlineAction: 'complete' | 'pause' | null;
  lastSyncAt: string | null;
}

export interface QRCodePoint {
  id: string;
  code: string;
  name: string;
  description: string | null;
  zoneId: string;
  zoneName: string;
  siteId: string;
  siteName: string;
  customerId: string;
  isActive: boolean;
}

export interface PendingSync {
  id: number;
  workOrderId: string;
  action: 'complete' | 'pause';
  payload: string;
  createdAt: string;
  attempts: number;
}

export interface SyncStatus {
  lastSync: string | null;
  pendingChanges: number;
  isOnline: boolean;
  isSyncing: boolean;
}
