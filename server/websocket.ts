import { WebSocketServer, WebSocket } from 'ws';
import { Server } from 'http';
import jwt from 'jsonwebtoken';
import { log } from './vite';

const JWT_SECRET = process.env.JWT_SECRET || 'kJsXXrXanldoNcZJG/iHeTEI8WdMch4PFWNIao1llTU=';

interface AuthenticatedWebSocket extends WebSocket {
  userId?: string;
  username?: string;
  customerId?: string;
  isAlive?: boolean;
}

interface BroadcastMessage {
  type: 'update' | 'delete' | 'create';
  resource: string;
  data?: any;
  id?: string;
  customerId?: string;
  companyId?: string;
}

let wss: WebSocketServer | null = null;
const clients = new Set<AuthenticatedWebSocket>();

export function setupWebSocket(server: Server) {
  wss = new WebSocketServer({ 
    server,
    path: '/ws',
    verifyClient: (info, callback) => {
      // Allow all connections initially, authenticate after connection
      callback(true);
    }
  });

  wss.on('connection', (ws: AuthenticatedWebSocket, req) => {
    ws.isAlive = true;
    
    // Extract token from query string
    const url = new URL(req.url || '', `http://${req.headers.host}`);
    const token = url.searchParams.get('token');
    
    if (token) {
      try {
        const decoded = jwt.verify(token, JWT_SECRET) as any;
        ws.userId = decoded.userId;
        ws.username = decoded.username;
        ws.customerId = decoded.customerId;
        
        log(`[WS] ✅ Client connected: ${ws.username} (${ws.userId})`);
        
        // Send welcome message
        ws.send(JSON.stringify({
          type: 'connected',
          message: 'WebSocket connected',
          userId: ws.userId,
          timestamp: new Date().toISOString()
        }));
      } catch (error) {
        log(`[WS] ❌ Invalid token`);
        ws.send(JSON.stringify({
          type: 'error',
          message: 'Invalid authentication token'
        }));
        ws.close();
        return;
      }
    } else {
      log(`[WS] ⚠️ Client connected without token`);
    }
    
    clients.add(ws);
    
    // Handle pong responses
    ws.on('pong', () => {
      ws.isAlive = true;
    });
    
    ws.on('message', (message) => {
      try {
        const data = JSON.parse(message.toString());
        
        // Handle ping/pong
        if (data.type === 'ping') {
          ws.send(JSON.stringify({ type: 'pong' }));
          return;
        }
        
        log(`[WS] 📩 Message from ${ws.username || 'unknown'}: ${message}`);
      } catch (error) {
        log(`[WS] ❌ Invalid message format`);
      }
    });
    
    ws.on('close', () => {
      clients.delete(ws);
      log(`[WS] 🔌 Client disconnected: ${ws.username || 'unknown'} (total: ${clients.size})`);
    });
    
    ws.on('error', (error) => {
      log(`[WS] ❌ WebSocket error: ${error.message}`);
      clients.delete(ws);
    });
  });

  // Heartbeat to detect broken connections
  const heartbeat = setInterval(() => {
    clients.forEach((ws) => {
      if (ws.isAlive === false) {
        clients.delete(ws);
        return ws.terminate();
      }
      
      ws.isAlive = false;
      ws.ping();
    });
  }, 30000); // Every 30 seconds

  wss.on('close', () => {
    clearInterval(heartbeat);
  });

  log('[WS] 🚀 WebSocket server initialized on /ws');
}

/**
 * Broadcast a message to all connected clients
 * Can filter by customerId or companyId
 */
export function broadcast(message: BroadcastMessage) {
  if (!wss) {
    log('[WS] ⚠️ WebSocket server not initialized');
    return;
  }

  log(`[WS] 📡 Broadcasting ${message.type} ${message.resource} (total clients: ${clients.size})`);

  const messageStr = JSON.stringify({
    ...message,
    timestamp: new Date().toISOString()
  });

  let sentCount = 0;
  
  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      // Filter by customer if specified
      if (message.customerId && client.customerId !== message.customerId) {
        return;
      }
      
      // Send to client
      client.send(messageStr);
      sentCount++;
    }
  });
  
  log(`[WS] ✅ Broadcast ${message.type} ${message.resource} sent to ${sentCount}/${clients.size} clients`);
}

/**
 * Broadcast to specific user
 */
export function broadcastToUser(userId: string, message: any) {
  if (!wss) {
    log('[WS] ⚠️ WebSocket server not initialized');
    return;
  }

  const messageStr = JSON.stringify({
    ...message,
    timestamp: new Date().toISOString()
  });

  let sent = false;
  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN && client.userId === userId) {
      client.send(messageStr);
      sent = true;
    }
  });
  
  if (sent) {
    log(`[WS] 📧 Message sent to user ${userId}`);
  }
}

/**
 * Get connected clients count
 */
export function getConnectedCount(): number {
  return clients.size;
}

/**
 * Get connected clients info
 */
export function getConnectedClients() {
  return Array.from(clients).map(ws => ({
    userId: ws.userId,
    username: ws.username,
    customerId: ws.customerId,
    isAlive: ws.isAlive
  }));
}
