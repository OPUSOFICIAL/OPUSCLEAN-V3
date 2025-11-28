import * as SQLite from 'expo-sqlite';
import { WorkOrder, QRCodePoint, PendingSync, User } from '../types';

let db: SQLite.SQLiteDatabase | null = null;

export async function getDatabase(): Promise<SQLite.SQLiteDatabase> {
  if (db) return db;
  
  db = await SQLite.openDatabaseAsync('opus_facilities.db');
  await initializeDatabase(db);
  return db;
}

async function initializeDatabase(database: SQLite.SQLiteDatabase): Promise<void> {
  await database.execAsync(`
    PRAGMA journal_mode = WAL;
    
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL,
      name TEXT NOT NULL,
      email TEXT,
      role TEXT NOT NULL,
      userType TEXT NOT NULL,
      customerId TEXT,
      companyId TEXT NOT NULL,
      modules TEXT NOT NULL,
      token TEXT NOT NULL,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS work_orders (
      id TEXT PRIMARY KEY,
      workOrderNumber INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL,
      priority TEXT NOT NULL,
      module TEXT NOT NULL,
      customerId TEXT NOT NULL,
      siteId TEXT NOT NULL,
      siteName TEXT,
      zoneId TEXT NOT NULL,
      zoneName TEXT,
      scheduledDate TEXT NOT NULL,
      assignedUserId TEXT,
      assignedUserName TEXT,
      createdAt TEXT,
      updatedAt TEXT,
      offlineModified INTEGER DEFAULT 0,
      offlineAction TEXT,
      lastSyncAt TEXT
    );
    
    CREATE TABLE IF NOT EXISTS qr_codes (
      id TEXT PRIMARY KEY,
      code TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      description TEXT,
      zoneId TEXT NOT NULL,
      zoneName TEXT,
      siteId TEXT NOT NULL,
      siteName TEXT,
      customerId TEXT NOT NULL,
      isActive INTEGER DEFAULT 1
    );
    
    CREATE TABLE IF NOT EXISTS pending_sync (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      workOrderId TEXT NOT NULL,
      action TEXT NOT NULL,
      payload TEXT NOT NULL,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      attempts INTEGER DEFAULT 0
    );
    
    CREATE INDEX IF NOT EXISTS idx_work_orders_status ON work_orders(status);
    CREATE INDEX IF NOT EXISTS idx_work_orders_date ON work_orders(scheduledDate);
    CREATE INDEX IF NOT EXISTS idx_work_orders_customer ON work_orders(customerId);
    CREATE INDEX IF NOT EXISTS idx_qr_codes_customer ON qr_codes(customerId);
    CREATE INDEX IF NOT EXISTS idx_pending_sync_order ON pending_sync(workOrderId);
  `);
}

export async function saveUser(user: User): Promise<void> {
  const database = await getDatabase();
  await database.runAsync('DELETE FROM users');
  await database.runAsync(
    `INSERT INTO users (id, username, name, email, role, userType, customerId, companyId, modules, token)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    user.id,
    user.username,
    user.name,
    user.email || '',
    user.role,
    user.userType,
    user.customerId || '',
    user.companyId,
    JSON.stringify(user.modules),
    user.token
  );
}

export async function getUser(): Promise<User | null> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>('SELECT * FROM users LIMIT 1');
  if (!row) return null;
  
  return {
    ...row,
    modules: JSON.parse(row.modules || '[]'),
    customerId: row.customerId || null
  };
}

export async function clearUser(): Promise<void> {
  const database = await getDatabase();
  await database.runAsync('DELETE FROM users');
}

export async function saveWorkOrders(orders: WorkOrder[]): Promise<void> {
  const database = await getDatabase();
  
  await database.withTransactionAsync(async () => {
    for (const order of orders) {
      const existing = await database.getFirstAsync<any>(
        'SELECT offlineModified FROM work_orders WHERE id = ?',
        order.id
      );
      
      if (existing?.offlineModified) {
        continue;
      }
      
      await database.runAsync(
        `INSERT OR REPLACE INTO work_orders 
         (id, workOrderNumber, title, description, status, priority, module, customerId, 
          siteId, siteName, zoneId, zoneName, scheduledDate, assignedUserId, assignedUserName,
          createdAt, updatedAt, offlineModified, offlineAction, lastSyncAt)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        order.id,
        order.workOrderNumber,
        order.title,
        order.description || '',
        order.status,
        order.priority,
        order.module,
        order.customerId,
        order.siteId,
        order.siteName || '',
        order.zoneId,
        order.zoneName || '',
        order.scheduledDate,
        order.assignedUserId || '',
        order.assignedUserName || '',
        order.createdAt,
        order.updatedAt,
        0,
        null,
        new Date().toISOString()
      );
    }
  });
}

export async function getWorkOrders(): Promise<WorkOrder[]> {
  const database = await getDatabase();
  const rows = await database.getAllAsync<any>('SELECT * FROM work_orders ORDER BY scheduledDate ASC');
  
  return rows.map(row => ({
    ...row,
    offlineModified: Boolean(row.offlineModified),
    assignedUserId: row.assignedUserId || null,
    assignedUserName: row.assignedUserName || null,
    description: row.description || null,
    siteName: row.siteName || '',
    zoneName: row.zoneName || ''
  }));
}

export async function updateWorkOrderStatus(
  id: string, 
  status: 'completed' | 'paused', 
  notes?: string
): Promise<void> {
  const database = await getDatabase();
  
  await database.runAsync(
    `UPDATE work_orders 
     SET status = ?, offlineModified = 1, offlineAction = ?, updatedAt = ?
     WHERE id = ?`,
    status,
    status === 'completed' ? 'complete' : 'pause',
    new Date().toISOString(),
    id
  );
  
  await database.runAsync(
    `INSERT INTO pending_sync (workOrderId, action, payload, createdAt)
     VALUES (?, ?, ?, ?)`,
    id,
    status === 'completed' ? 'complete' : 'pause',
    JSON.stringify({ notes: notes || '' }),
    new Date().toISOString()
  );
}

export async function saveQRCodes(codes: QRCodePoint[]): Promise<void> {
  const database = await getDatabase();
  
  await database.withTransactionAsync(async () => {
    await database.runAsync('DELETE FROM qr_codes');
    
    for (const code of codes) {
      await database.runAsync(
        `INSERT INTO qr_codes (id, code, name, description, zoneId, zoneName, siteId, siteName, customerId, isActive)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        code.id,
        code.code,
        code.name,
        code.description || '',
        code.zoneId,
        code.zoneName || '',
        code.siteId,
        code.siteName || '',
        code.customerId,
        code.isActive ? 1 : 0
      );
    }
  });
}

export async function getQRCodes(): Promise<QRCodePoint[]> {
  const database = await getDatabase();
  const rows = await database.getAllAsync<any>('SELECT * FROM qr_codes WHERE isActive = 1');
  
  return rows.map(row => ({
    ...row,
    isActive: Boolean(row.isActive),
    description: row.description || null
  }));
}

export async function findQRCodeByCode(code: string): Promise<QRCodePoint | null> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>(
    'SELECT * FROM qr_codes WHERE code = ? AND isActive = 1',
    code
  );
  
  if (!row) return null;
  
  return {
    ...row,
    isActive: Boolean(row.isActive),
    description: row.description || null
  };
}

export async function getPendingSync(): Promise<PendingSync[]> {
  const database = await getDatabase();
  const rows = await database.getAllAsync<any>(
    'SELECT * FROM pending_sync ORDER BY createdAt ASC'
  );
  return rows;
}

export async function removePendingSync(id: number): Promise<void> {
  const database = await getDatabase();
  await database.runAsync('DELETE FROM pending_sync WHERE id = ?', id);
}

export async function removeCompletedWorkOrders(): Promise<void> {
  const database = await getDatabase();
  await database.runAsync(
    "DELETE FROM work_orders WHERE status = 'completed' AND offlineModified = 0"
  );
}

export async function clearAllData(): Promise<void> {
  const database = await getDatabase();
  await database.execAsync(`
    DELETE FROM users;
    DELETE FROM work_orders;
    DELETE FROM qr_codes;
    DELETE FROM pending_sync;
  `);
}
