import Constants from 'expo-constants';
import { User, WorkOrder, QRCodePoint } from '../types';

const API_URL = Constants.expoConfig?.extra?.apiUrl || 'https://facilities.grupoopus.com';

interface LoginResponse {
  user: Omit<User, 'token'>;
  token: string;
}

interface ApiError {
  message: string;
  status: number;
}

async function apiRequest<T>(
  endpoint: string,
  options: RequestInit = {},
  token?: string
): Promise<T> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...options.headers as Record<string, string>,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error: ApiError = {
      message: 'Erro na requisição',
      status: response.status,
    };
    
    try {
      const data = await response.json();
      error.message = data.message || error.message;
    } catch {}
    
    throw error;
  }

  return response.json();
}

export async function login(username: string, password: string): Promise<User> {
  const response = await apiRequest<LoginResponse>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username, password }),
  });

  return {
    ...response.user,
    token: response.token,
  };
}

export async function fetchWorkOrders(
  token: string,
  customerId: string,
  module: string
): Promise<WorkOrder[]> {
  const today = new Date();
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  
  const todayStr = today.toISOString().split('T')[0];
  const tomorrowStr = tomorrow.toISOString().split('T')[0];
  
  const orders = await apiRequest<any[]>(
    `/api/customers/${customerId}/work-orders?module=${module}&startDate=${todayStr}&endDate=${tomorrowStr}`,
    { method: 'GET' },
    token
  );

  return orders
    .filter((o: any) => o.status === 'open' || o.status === 'in_progress' || o.status === 'paused')
    .map((order: any) => ({
      id: order.id,
      workOrderNumber: order.workOrderNumber,
      title: order.title,
      description: order.description,
      status: order.status,
      priority: order.priority,
      module: order.module,
      customerId: order.customerId,
      siteId: order.siteId,
      siteName: order.site?.name || '',
      zoneId: order.zoneId,
      zoneName: order.zone?.name || '',
      scheduledDate: order.scheduledDate,
      assignedUserId: order.assignedUserId,
      assignedUserName: order.assignedUser?.name || null,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      offlineModified: false,
      offlineAction: null,
      lastSyncAt: null,
    }));
}

export async function fetchQRCodes(
  token: string,
  customerId: string
): Promise<QRCodePoint[]> {
  const codes = await apiRequest<any[]>(
    `/api/customers/${customerId}/qr-codes`,
    { method: 'GET' },
    token
  );

  return codes.map((code: any) => ({
    id: code.id,
    code: code.code,
    name: code.name,
    description: code.description,
    zoneId: code.zoneId,
    zoneName: code.zone?.name || '',
    siteId: code.siteId,
    siteName: code.site?.name || '',
    customerId: code.customerId,
    isActive: code.isActive,
  }));
}

export async function completeWorkOrder(
  token: string,
  workOrderId: string,
  notes?: string
): Promise<void> {
  await apiRequest(
    `/api/work-orders/${workOrderId}/complete`,
    {
      method: 'POST',
      body: JSON.stringify({ notes }),
    },
    token
  );
}

export async function pauseWorkOrder(
  token: string,
  workOrderId: string,
  notes?: string
): Promise<void> {
  await apiRequest(
    `/api/work-orders/${workOrderId}/pause`,
    {
      method: 'POST',
      body: JSON.stringify({ notes }),
    },
    token
  );
}

export async function fetchCustomers(token: string): Promise<any[]> {
  return apiRequest<any[]>('/api/auth/my-customers', { method: 'GET' }, token);
}
