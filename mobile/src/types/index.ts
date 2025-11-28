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
  startedAt: string | null;
  completedAt: string | null;
  assignedUserId: string | null;
  assignedUserName: string | null;
  checklistTemplateId: string | null;
  serviceId: string | null;
  createdAt: string;
  updatedAt: string;
  offlineModified: boolean;
  offlineAction: 'complete' | 'pause' | 'resume' | 'start' | null;
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

export interface ChecklistTemplate {
  id: string;
  name: string;
  description: string | null;
  items: ChecklistItem[];
  customerId: string;
  module: 'clean' | 'maintenance';
}

export interface ChecklistItem {
  id: string;
  label: string;
  type: 'boolean' | 'text' | 'number' | 'select' | 'checkbox' | 'photo';
  required: boolean;
  order: number;
  options?: string[];
  validation?: {
    photoMinCount?: number;
    photoMaxCount?: number;
    min?: number;
    max?: number;
  };
}

export interface ChecklistExecution {
  id: string;
  workOrderId: string;
  checklistTemplateId: string;
  executedBy: string;
  executedByName: string;
  status: 'pending' | 'completed';
  answers: Record<string, ChecklistAnswer>;
  executedAt: string | null;
  createdAt: string;
  offlineCreated: boolean;
  syncStatus: 'pending' | 'synced' | 'failed';
}

export interface ChecklistAnswer {
  itemId: string;
  type: string;
  value: any;
  photos?: CapturedPhoto[];
}

export interface CapturedPhoto {
  id: string;
  uri: string;
  base64: string;
  width: number;
  height: number;
  createdAt: string;
}

export interface WorkOrderPhoto {
  id: string;
  workOrderId: string;
  checklistItemId: string | null;
  type: 'checklist' | 'pause' | 'completion' | 'comment';
  uri: string;
  base64: string;
  fileName: string;
  createdAt: string;
  syncStatus: 'pending' | 'synced' | 'failed';
}

export interface WorkOrderComment {
  id: string;
  workOrderId: string;
  userId: string;
  userName: string;
  comment: string;
  photoIds: string[];
  createdAt: string;
  syncStatus: 'pending' | 'synced' | 'failed';
}

export interface PendingSync {
  id: number;
  workOrderId: string;
  action: 'complete' | 'pause' | 'resume' | 'start' | 'checklist' | 'photo' | 'comment';
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

export type WorkOrderStatus = 'open' | 'in_progress' | 'paused' | 'completed' | 'cancelled';
export type Priority = 'low' | 'medium' | 'high' | 'urgent';
