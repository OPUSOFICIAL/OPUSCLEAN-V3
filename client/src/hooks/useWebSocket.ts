import { useEffect, useRef, useState, useCallback } from 'react';
import { queryClient } from '@/lib/queryClient';

interface WebSocketMessage {
  type: 'connected' | 'update' | 'delete' | 'create' | 'pong' | 'error';
  resource?: string;
  data?: any;
  id?: string;
  customerId?: string;
  companyId?: string;
  message?: string;
  timestamp?: string;
}

interface UseWebSocketOptions {
  enabled?: boolean;
  onMessage?: (message: WebSocketMessage) => void;
  onConnect?: () => void;
  onDisconnect?: () => void;
  onError?: (error: Event) => void;
}

export function useWebSocket(options: UseWebSocketOptions = {}) {
  const {
    enabled = true,
    onMessage,
    onConnect,
    onDisconnect,
    onError
  } = options;

  const [isConnected, setIsConnected] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState<'connecting' | 'connected' | 'disconnected' | 'error'>('disconnected');
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const pingIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const reconnectAttemptsRef = useRef(0);

  const getWebSocketUrl = useCallback(() => {
    const token = localStorage.getItem('opus_clean_token');
    if (!token) return null;

    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const host = window.location.host;
    return `${protocol}//${host}/ws?token=${encodeURIComponent(token)}`;
  }, []);

  const connect = useCallback(() => {
    if (!enabled) return;
    
    const url = getWebSocketUrl();
    if (!url) {
      console.log('[WS Client] No token available, skipping connection');
      return;
    }

    if (wsRef.current?.readyState === WebSocket.OPEN) {
      console.log('[WS Client] Already connected');
      return;
    }

    try {
      console.log('[WS Client] Connecting...');
      setConnectionStatus('connecting');
      
      const ws = new WebSocket(url);
      wsRef.current = ws;

      ws.onopen = () => {
        console.log('[WS Client] ✅ Connected to WebSocket server');
        setIsConnected(true);
        setConnectionStatus('connected');
        reconnectAttemptsRef.current = 0;
        
        // Start ping interval
        if (pingIntervalRef.current) {
          clearInterval(pingIntervalRef.current);
        }
        pingIntervalRef.current = setInterval(() => {
          if (ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: 'ping' }));
          }
        }, 25000); // Ping every 25 seconds
        
        onConnect?.();
      };

      ws.onmessage = (event) => {
        try {
          const message: WebSocketMessage = JSON.parse(event.data);
          console.log('[WS Client] 📩 Message received:', message);

          // Handle pong
          if (message.type === 'pong') {
            return;
          }

          // Call custom handler
          onMessage?.(message);

          // Auto-invalidate React Query cache based on resource
          if (message.resource && (message.type === 'update' || message.type === 'create' || message.type === 'delete')) {
            invalidateQueriesByResource(message.resource, message);
          }
        } catch (error) {
          console.error('[WS Client] ❌ Error parsing message:', error);
        }
      };

      ws.onerror = (error) => {
        console.error('[WS Client] ❌ WebSocket error:', error);
        setConnectionStatus('error');
        onError?.(error);
      };

      ws.onclose = () => {
        console.log('[WS Client] 🔌 Disconnected from WebSocket server');
        setIsConnected(false);
        setConnectionStatus('disconnected');
        
        // Clear ping interval
        if (pingIntervalRef.current) {
          clearInterval(pingIntervalRef.current);
          pingIntervalRef.current = null;
        }
        
        onDisconnect?.();
        
        // Attempt to reconnect with exponential backoff
        if (enabled) {
          const delay = Math.min(1000 * Math.pow(2, reconnectAttemptsRef.current), 30000);
          reconnectAttemptsRef.current++;
          
          console.log(`[WS Client] 🔄 Reconnecting in ${delay}ms (attempt ${reconnectAttemptsRef.current})...`);
          
          reconnectTimeoutRef.current = setTimeout(() => {
            connect();
          }, delay);
        }
      };
    } catch (error) {
      console.error('[WS Client] ❌ Error creating WebSocket:', error);
      setConnectionStatus('error');
    }
  }, [enabled, getWebSocketUrl, onConnect, onDisconnect, onError, onMessage]);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    
    if (pingIntervalRef.current) {
      clearInterval(pingIntervalRef.current);
      pingIntervalRef.current = null;
    }
    
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
    
    setIsConnected(false);
    setConnectionStatus('disconnected');
  }, []);

  const send = useCallback((data: any) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(data));
      return true;
    }
    console.warn('[WS Client] ⚠️ Cannot send message: WebSocket not connected');
    return false;
  }, []);

  // Connect on mount, disconnect on unmount
  useEffect(() => {
    if (enabled) {
      connect();
    }

    return () => {
      disconnect();
    };
  }, [enabled, connect, disconnect]);

  // Reconnect when token changes
  useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'opus_clean_token') {
        console.log('[WS Client] 🔑 Token changed, reconnecting...');
        disconnect();
        if (enabled && e.newValue) {
          setTimeout(connect, 1000);
        }
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, [enabled, connect, disconnect]);

  return {
    isConnected,
    connectionStatus,
    send,
    reconnect: connect,
    disconnect
  };
}

/**
 * Invalidate React Query cache based on the resource that changed
 */
function invalidateQueriesByResource(resource: string, message: WebSocketMessage) {
  console.log(`[WS Client] 🔄 Invalidating queries for resource: ${resource}`);

  switch (resource) {
    // Work Orders
    case 'workorders':
    case 'workorder':
      queryClient.invalidateQueries({ queryKey: ['/api/workorders'] });
      queryClient.invalidateQueries({ queryKey: ['/api/customers'] });
      if (message.customerId) {
        queryClient.invalidateQueries({ queryKey: [`/api/customers/${message.customerId}/workorders`] });
      }
      break;

    // Customers
    case 'customers':
    case 'customer':
      queryClient.invalidateQueries({ queryKey: ['/api/customers'] });
      queryClient.invalidateQueries({ queryKey: ['/api/companies'] });
      break;

    // Users
    case 'users':
    case 'user':
      queryClient.invalidateQueries({ queryKey: ['/api/users'] });
      if (message.customerId) {
        queryClient.invalidateQueries({ queryKey: [`/api/customers/${message.customerId}/users`] });
      }
      break;

    // Sites
    case 'sites':
    case 'site':
      queryClient.invalidateQueries({ queryKey: ['/api/sites'] });
      if (message.customerId) {
        queryClient.invalidateQueries({ queryKey: [`/api/customers/${message.customerId}/sites`] });
      }
      break;

    // Zones
    case 'zones':
    case 'zone':
      queryClient.invalidateQueries({ queryKey: ['/api/zones'] });
      break;

    // QR Codes
    case 'qrcodes':
    case 'qrcode':
      queryClient.invalidateQueries({ queryKey: ['/api/qrcodes'] });
      queryClient.invalidateQueries({ queryKey: ['/api/zones'] });
      break;

    // Checklists
    case 'checklists':
    case 'checklist':
      queryClient.invalidateQueries({ queryKey: ['/api/checklists'] });
      queryClient.invalidateQueries({ queryKey: ['/api/workorders'] });
      break;

    // Roles
    case 'roles':
    case 'role':
      queryClient.invalidateQueries({ queryKey: ['/api/roles'] });
      break;

    // Dashboard
    case 'dashboard':
      queryClient.invalidateQueries({ queryKey: ['/api/dashboard'] });
      queryClient.invalidateQueries({ queryKey: ['/api/customers'] });
      break;

    // Equipment (Maintenance)
    case 'equipment':
      queryClient.invalidateQueries({ queryKey: ['/api/equipment'] });
      if (message.customerId) {
        queryClient.invalidateQueries({ queryKey: [`/api/customers/${message.customerId}/equipment`] });
      }
      break;

    // Maintenance Plans
    case 'maintenance-plans':
    case 'maintenance-plan':
      queryClient.invalidateQueries({ queryKey: ['/api/maintenance-plans'] });
      queryClient.invalidateQueries({ queryKey: ['/api/equipment'] });
      break;

    // Maintenance Checklists
    case 'maintenance-checklists':
    case 'maintenance-checklist':
      queryClient.invalidateQueries({ queryKey: ['/api/maintenance-checklists'] });
      queryClient.invalidateQueries({ queryKey: ['/api/workorders'] });
      break;

    // Generic invalidation for unknown resources
    default:
      console.warn(`[WS Client] ⚠️ Unknown resource type: ${resource}`);
      // Invalidate all queries as fallback
      queryClient.invalidateQueries();
      break;
  }
}
