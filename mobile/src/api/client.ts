import { User, WorkOrder, QRCodePoint, ChecklistTemplate, CapturedPhoto, ChecklistAnswer } from '../types';

// URL de produção fixo - NÃO usar variável de ambiente para evitar problemas de build
const API_URL = 'https://facilities.grupoopus.com';

// Log da URL em uso para debug
console.log('[API CLIENT] URL configurada:', API_URL);

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

  const fullUrl = `${API_URL}${endpoint}`;
  console.log(`[API REQUEST] ${options.method || 'GET'} ${fullUrl}`);

  const response = await fetch(fullUrl, {
    ...options,
    headers,
  });

  console.log(`[API RESPONSE] ${response.status} ${fullUrl}`);

  if (!response.ok) {
    const error: ApiError = {
      message: 'Erro na requisicao',
      status: response.status,
    };
    
    try {
      const data = await response.json();
      error.message = data.message || error.message;
      console.log(`[API ERROR] ${response.status}: ${error.message}`);
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

function mapStatusToEnglish(status: string): 'open' | 'in_progress' | 'paused' | 'completed' | 'cancelled' {
  const statusMap: Record<string, 'open' | 'in_progress' | 'paused' | 'completed' | 'cancelled'> = {
    'aberta': 'open',
    'open': 'open',
    'em_andamento': 'in_progress',
    'in_progress': 'in_progress',
    'pausada': 'paused',
    'paused': 'paused',
    'concluida': 'completed',
    'completed': 'completed',
    'cancelada': 'cancelled',
    'cancelled': 'cancelled',
    'vencida': 'open',
  };
  return statusMap[status] || 'open';
}

export async function fetchWorkOrders(
  token: string,
  customerId: string,
  module: string
): Promise<WorkOrder[]> {
  // Buscar todas as O.S. sem filtro de data - o filtro é feito localmente na tela
  console.log(`[FETCH WORK ORDERS] Buscando todas as O.S. do cliente ${customerId}`);
  
  const response = await apiRequest<any>(
    `/api/customers/${customerId}/work-orders?module=${module}`,
    { method: 'GET' },
    token
  );

  const orders = Array.isArray(response) ? response : (response.data || []);

  return orders
    .filter((o: any) => {
      const mappedStatus = mapStatusToEnglish(o.status);
      return mappedStatus === 'open' || mappedStatus === 'in_progress' || mappedStatus === 'paused';
    })
    .map((order: any) => ({
      id: order.id,
      workOrderNumber: order.workOrderNumber || order.number || 0,
      title: order.title,
      description: order.description,
      status: mapStatusToEnglish(order.status),
      priority: order.priority,
      module: order.module,
      customerId: order.customerId,
      siteId: order.siteId,
      siteName: order.site?.name || order.siteName || '',
      zoneId: order.zoneId,
      zoneName: order.zone?.name || order.zoneName || '',
      scheduledDate: order.scheduledDate || null,
      dueDate: order.dueDate || null,
      startedAt: order.startedAt || null,
      completedAt: order.completedAt || null,
      assignedUserId: order.assignedUserId || null,
      assignedUserIds: order.assignedUserIds || null,
      assignedUserName: order.assignedUser?.name || order.assignedUserName || null,
      checklistTemplateId: order.checklistTemplateId || order.serviceChecklistId || null,
      serviceId: order.serviceId || null,
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

export async function fetchChecklistTemplate(
  token: string,
  templateId: string
): Promise<ChecklistTemplate | null> {
  try {
    const template = await apiRequest<any>(
      `/api/checklists/${templateId}`,
      { method: 'GET' },
      token
    );

    return {
      id: template.id,
      name: template.name,
      description: template.description,
      items: template.items || [],
      customerId: template.customerId,
      module: template.module,
    };
  } catch (error) {
    console.log('Checklist template nao encontrado:', templateId);
    return null;
  }
}

export async function startWorkOrder(
  token: string,
  workOrderId: string
): Promise<void> {
  await apiRequest(
    `/api/work-orders/${workOrderId}/start`,
    {
      method: 'POST',
    },
    token
  );
}

export async function completeWorkOrder(
  token: string,
  workOrderId: string,
  data?: {
    notes?: string;
    checklistAnswers?: Record<string, ChecklistAnswer>;
    photos?: { base64: string; type: string; checklistItemId?: string }[];
  }
): Promise<void> {
  await apiRequest(
    `/api/work-orders/${workOrderId}/complete`,
    {
      method: 'POST',
      body: JSON.stringify(data || {}),
    },
    token
  );
}

export async function pauseWorkOrder(
  token: string,
  workOrderId: string,
  data?: {
    reason: string;
    photos?: { base64: string }[];
  }
): Promise<void> {
  await apiRequest(
    `/api/work-orders/${workOrderId}/pause`,
    {
      method: 'POST',
      body: JSON.stringify(data || {}),
    },
    token
  );
}

export async function resumeWorkOrder(
  token: string,
  workOrderId: string
): Promise<void> {
  await apiRequest(
    `/api/work-orders/${workOrderId}/resume`,
    {
      method: 'POST',
    },
    token
  );
}

export async function uploadWorkOrderPhoto(
  token: string,
  workOrderId: string,
  photoBase64: string,
  type: 'checklist' | 'pause' | 'completion' | 'comment',
  checklistItemId?: string
): Promise<{ id: string }> {
  return apiRequest<{ id: string }>(
    `/api/work-orders/${workOrderId}/photos`,
    {
      method: 'POST',
      body: JSON.stringify({
        base64: photoBase64,
        type,
        checklistItemId,
      }),
    },
    token
  );
}

export async function submitChecklistExecution(
  token: string,
  workOrderId: string,
  checklistTemplateId: string,
  answers: Record<string, ChecklistAnswer>
): Promise<{ id: string }> {
  const answersForApi = Object.entries(answers).map(([itemId, answer]) => ({
    itemId,
    type: answer.type,
    value: answer.value,
    photoIds: answer.photos?.map(p => p.id) || [],
  }));

  return apiRequest<{ id: string }>(
    `/api/work-orders/${workOrderId}/checklist`,
    {
      method: 'POST',
      body: JSON.stringify({
        checklistTemplateId,
        answers: answersForApi,
      }),
    },
    token
  );
}

export async function addWorkOrderComment(
  token: string,
  workOrderId: string,
  comment: string,
  photoIds?: string[]
): Promise<{ id: string }> {
  return apiRequest<{ id: string }>(
    `/api/work-orders/${workOrderId}/comments`,
    {
      method: 'POST',
      body: JSON.stringify({
        comment,
        photoIds: photoIds || [],
      }),
    },
    token
  );
}

export async function fetchCustomers(token: string): Promise<any[]> {
  return apiRequest<any[]>('/api/auth/my-customers', { method: 'GET' }, token);
}
