import * as SQLite from 'expo-sqlite';
import { 
  WorkOrder, 
  QRCodePoint, 
  PendingSync, 
  User, 
  ChecklistTemplate, 
  ChecklistExecution,
  WorkOrderPhoto,
  WorkOrderComment
} from '../types';

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
      scheduledDate TEXT,
      dueDate TEXT,
      startedAt TEXT,
      completedAt TEXT,
      assignedUserId TEXT,
      assignedUserName TEXT,
      checklistTemplateId TEXT,
      serviceId TEXT,
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
    
    CREATE TABLE IF NOT EXISTS checklist_templates (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      items TEXT NOT NULL,
      customerId TEXT NOT NULL,
      module TEXT NOT NULL,
      lastSyncAt TEXT
    );
    
    CREATE TABLE IF NOT EXISTS checklist_executions (
      id TEXT PRIMARY KEY,
      workOrderId TEXT NOT NULL,
      checklistTemplateId TEXT NOT NULL,
      executedBy TEXT NOT NULL,
      executedByName TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      answers TEXT,
      executedAt TEXT,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      offlineCreated INTEGER DEFAULT 1,
      syncStatus TEXT DEFAULT 'pending'
    );
    
    CREATE TABLE IF NOT EXISTS work_order_photos (
      id TEXT PRIMARY KEY,
      workOrderId TEXT NOT NULL,
      checklistItemId TEXT,
      type TEXT NOT NULL,
      uri TEXT NOT NULL,
      base64 TEXT NOT NULL,
      fileName TEXT,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      syncStatus TEXT DEFAULT 'pending'
    );
    
    CREATE TABLE IF NOT EXISTS work_order_comments (
      id TEXT PRIMARY KEY,
      workOrderId TEXT NOT NULL,
      userId TEXT NOT NULL,
      userName TEXT,
      comment TEXT NOT NULL,
      photoIds TEXT,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      syncStatus TEXT DEFAULT 'pending'
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
    CREATE INDEX IF NOT EXISTS idx_checklist_executions_wo ON checklist_executions(workOrderId);
    CREATE INDEX IF NOT EXISTS idx_photos_wo ON work_order_photos(workOrderId);
    CREATE INDEX IF NOT EXISTS idx_comments_wo ON work_order_comments(workOrderId);
  `);
  
  await runMigrations(database);
}

async function runMigrations(database: SQLite.SQLiteDatabase): Promise<void> {
  try {
    await database.runAsync('ALTER TABLE work_orders ADD COLUMN dueDate TEXT');
  } catch (e) {
  }
  
  try {
    const tableInfo = await database.getAllAsync<any>('PRAGMA table_info(work_orders)');
    const scheduledDateCol = tableInfo.find((col: any) => col.name === 'scheduledDate');
    
    if (scheduledDateCol && scheduledDateCol.notnull === 1) {
      await database.execAsync(`
        BEGIN TRANSACTION;
        
        CREATE TABLE work_orders_new (
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
          scheduledDate TEXT,
          dueDate TEXT,
          startedAt TEXT,
          completedAt TEXT,
          assignedUserId TEXT,
          assignedUserName TEXT,
          checklistTemplateId TEXT,
          serviceId TEXT,
          createdAt TEXT,
          updatedAt TEXT,
          offlineModified INTEGER DEFAULT 0,
          offlineAction TEXT,
          lastSyncAt TEXT
        );
        
        INSERT INTO work_orders_new SELECT 
          id, workOrderNumber, title, description, status, priority, module, customerId,
          siteId, siteName, zoneId, zoneName, scheduledDate, 
          COALESCE((SELECT dueDate FROM work_orders AS wo2 WHERE wo2.id = work_orders.id), NULL),
          startedAt, completedAt, assignedUserId, assignedUserName, checklistTemplateId, 
          serviceId, createdAt, updatedAt, offlineModified, offlineAction, lastSyncAt
        FROM work_orders;
        
        DROP TABLE work_orders;
        ALTER TABLE work_orders_new RENAME TO work_orders;
        
        CREATE INDEX IF NOT EXISTS idx_work_orders_status ON work_orders(status);
        CREATE INDEX IF NOT EXISTS idx_work_orders_date ON work_orders(scheduledDate);
        CREATE INDEX IF NOT EXISTS idx_work_orders_customer ON work_orders(customerId);
        
        COMMIT;
      `);
    }
  } catch (e) {
    console.log('Migration to fix scheduledDate constraint skipped or failed:', e);
  }
}

// ============================================================================
// USER OPERATIONS
// ============================================================================

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

// ============================================================================
// WORK ORDER OPERATIONS
// ============================================================================

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
          siteId, siteName, zoneId, zoneName, scheduledDate, dueDate, startedAt, completedAt,
          assignedUserId, assignedUserName, checklistTemplateId, serviceId,
          createdAt, updatedAt, offlineModified, offlineAction, lastSyncAt)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
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
        order.scheduledDate || null,
        order.dueDate || null,
        order.startedAt || null,
        order.completedAt || null,
        order.assignedUserId || '',
        order.assignedUserName || '',
        order.checklistTemplateId || null,
        order.serviceId || null,
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
  const rows = await database.getAllAsync<any>('SELECT * FROM work_orders ORDER BY COALESCE(dueDate, scheduledDate, createdAt) ASC');
  
  return rows.map(row => ({
    ...row,
    offlineModified: Boolean(row.offlineModified),
    assignedUserId: row.assignedUserId || null,
    assignedUserName: row.assignedUserName || null,
    description: row.description || null,
    siteName: row.siteName || '',
    zoneName: row.zoneName || '',
    scheduledDate: row.scheduledDate || null,
    dueDate: row.dueDate || null,
    startedAt: row.startedAt || null,
    completedAt: row.completedAt || null,
    checklistTemplateId: row.checklistTemplateId || null,
    serviceId: row.serviceId || null,
  }));
}

export async function getWorkOrderById(id: string): Promise<WorkOrder | null> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>(
    'SELECT * FROM work_orders WHERE id = ?',
    id
  );
  
  if (!row) return null;
  
  return {
    ...row,
    offlineModified: Boolean(row.offlineModified),
    assignedUserId: row.assignedUserId || null,
    assignedUserName: row.assignedUserName || null,
    description: row.description || null,
    siteName: row.siteName || '',
    zoneName: row.zoneName || '',
    scheduledDate: row.scheduledDate || null,
    dueDate: row.dueDate || null,
    startedAt: row.startedAt || null,
    completedAt: row.completedAt || null,
    checklistTemplateId: row.checklistTemplateId || null,
    serviceId: row.serviceId || null,
  };
}

export async function updateWorkOrderStatus(
  id: string, 
  status: 'in_progress' | 'completed' | 'paused',
  action: 'start' | 'complete' | 'pause' | 'resume',
  payload?: any
): Promise<void> {
  const database = await getDatabase();
  const now = new Date().toISOString();
  
  let updateFields = 'status = ?, offlineModified = 1, offlineAction = ?, updatedAt = ?';
  const params: any[] = [status, action, now];
  
  if (action === 'start' || action === 'resume') {
    updateFields += ', startedAt = ?';
    params.push(now);
  } else if (action === 'complete') {
    updateFields += ', completedAt = ?';
    params.push(now);
  }
  
  params.push(id);
  
  await database.runAsync(
    `UPDATE work_orders SET ${updateFields} WHERE id = ?`,
    ...params
  );
  
  await database.runAsync(
    `INSERT INTO pending_sync (workOrderId, action, payload, createdAt)
     VALUES (?, ?, ?, ?)`,
    id,
    action,
    JSON.stringify(payload || {}),
    now
  );
}

export async function getWorkOrdersByZone(zoneId: string): Promise<WorkOrder[]> {
  const database = await getDatabase();
  const rows = await database.getAllAsync<any>(
    `SELECT * FROM work_orders 
     WHERE zoneId = ? AND status IN ('open', 'in_progress', 'paused')
     ORDER BY COALESCE(dueDate, scheduledDate, createdAt) ASC`,
    zoneId
  );
  
  return rows.map(row => ({
    ...row,
    offlineModified: Boolean(row.offlineModified),
    assignedUserId: row.assignedUserId || null,
    assignedUserName: row.assignedUserName || null,
    description: row.description || null,
    siteName: row.siteName || '',
    zoneName: row.zoneName || '',
    scheduledDate: row.scheduledDate || null,
    dueDate: row.dueDate || null,
    startedAt: row.startedAt || null,
    completedAt: row.completedAt || null,
    checklistTemplateId: row.checklistTemplateId || null,
    serviceId: row.serviceId || null,
  }));
}

// ============================================================================
// QR CODE OPERATIONS
// ============================================================================

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

// ============================================================================
// CHECKLIST OPERATIONS
// ============================================================================

export async function saveChecklistTemplate(template: ChecklistTemplate): Promise<void> {
  const database = await getDatabase();
  
  await database.runAsync(
    `INSERT OR REPLACE INTO checklist_templates 
     (id, name, description, items, customerId, module, lastSyncAt)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    template.id,
    template.name,
    template.description || '',
    JSON.stringify(template.items),
    template.customerId,
    template.module,
    new Date().toISOString()
  );
}

export async function getChecklistTemplate(id: string): Promise<ChecklistTemplate | null> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>(
    'SELECT * FROM checklist_templates WHERE id = ?',
    id
  );
  
  if (!row) return null;
  
  return {
    ...row,
    items: JSON.parse(row.items || '[]'),
    description: row.description || null
  };
}

export async function saveChecklistExecution(execution: ChecklistExecution): Promise<void> {
  const database = await getDatabase();
  
  await database.runAsync(
    `INSERT OR REPLACE INTO checklist_executions 
     (id, workOrderId, checklistTemplateId, executedBy, executedByName, status, answers, executedAt, createdAt, offlineCreated, syncStatus)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    execution.id,
    execution.workOrderId,
    execution.checklistTemplateId,
    execution.executedBy,
    execution.executedByName || '',
    execution.status,
    JSON.stringify(execution.answers),
    execution.executedAt,
    execution.createdAt,
    execution.offlineCreated ? 1 : 0,
    execution.syncStatus
  );
  
  if (execution.offlineCreated && execution.syncStatus === 'pending') {
    await database.runAsync(
      `INSERT INTO pending_sync (workOrderId, action, payload, createdAt)
       VALUES (?, ?, ?, ?)`,
      execution.workOrderId,
      'checklist',
      JSON.stringify({ checklistExecutionId: execution.id }),
      new Date().toISOString()
    );
  }
}

export async function getChecklistExecutionByWorkOrder(workOrderId: string): Promise<ChecklistExecution | null> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>(
    'SELECT * FROM checklist_executions WHERE workOrderId = ? ORDER BY createdAt DESC LIMIT 1',
    workOrderId
  );
  
  if (!row) return null;
  
  return {
    ...row,
    answers: JSON.parse(row.answers || '{}'),
    offlineCreated: Boolean(row.offlineCreated)
  };
}

// ============================================================================
// PHOTO OPERATIONS
// ============================================================================

export async function savePhoto(photo: WorkOrderPhoto): Promise<void> {
  const database = await getDatabase();
  
  await database.runAsync(
    `INSERT INTO work_order_photos 
     (id, workOrderId, checklistItemId, type, uri, base64, fileName, createdAt, syncStatus)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    photo.id,
    photo.workOrderId,
    photo.checklistItemId || null,
    photo.type,
    photo.uri,
    photo.base64,
    photo.fileName || '',
    photo.createdAt,
    photo.syncStatus
  );
  
  if (photo.syncStatus === 'pending') {
    await database.runAsync(
      `INSERT INTO pending_sync (workOrderId, action, payload, createdAt)
       VALUES (?, ?, ?, ?)`,
      photo.workOrderId,
      'photo',
      JSON.stringify({ photoId: photo.id }),
      new Date().toISOString()
    );
  }
}

export async function getPhotosByWorkOrder(workOrderId: string): Promise<WorkOrderPhoto[]> {
  const database = await getDatabase();
  const rows = await database.getAllAsync<any>(
    'SELECT * FROM work_order_photos WHERE workOrderId = ? ORDER BY createdAt ASC',
    workOrderId
  );
  
  return rows.map(row => ({
    ...row,
    checklistItemId: row.checklistItemId || null,
    fileName: row.fileName || ''
  }));
}

export async function getPhotoById(id: string): Promise<WorkOrderPhoto | null> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>(
    'SELECT * FROM work_order_photos WHERE id = ?',
    id
  );
  
  if (!row) return null;
  
  return {
    ...row,
    checklistItemId: row.checklistItemId || null,
    fileName: row.fileName || ''
  };
}

export async function updatePhotoSyncStatus(id: string, status: 'pending' | 'synced' | 'failed'): Promise<void> {
  const database = await getDatabase();
  await database.runAsync(
    'UPDATE work_order_photos SET syncStatus = ? WHERE id = ?',
    status,
    id
  );
}

// ============================================================================
// COMMENT OPERATIONS
// ============================================================================

export async function saveComment(comment: WorkOrderComment): Promise<void> {
  const database = await getDatabase();
  
  await database.runAsync(
    `INSERT INTO work_order_comments 
     (id, workOrderId, userId, userName, comment, photoIds, createdAt, syncStatus)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    comment.id,
    comment.workOrderId,
    comment.userId,
    comment.userName || '',
    comment.comment,
    JSON.stringify(comment.photoIds || []),
    comment.createdAt,
    comment.syncStatus
  );
  
  if (comment.syncStatus === 'pending') {
    await database.runAsync(
      `INSERT INTO pending_sync (workOrderId, action, payload, createdAt)
       VALUES (?, ?, ?, ?)`,
      comment.workOrderId,
      'comment',
      JSON.stringify({ commentId: comment.id }),
      new Date().toISOString()
    );
  }
}

export async function getCommentsByWorkOrder(workOrderId: string): Promise<WorkOrderComment[]> {
  const database = await getDatabase();
  const rows = await database.getAllAsync<any>(
    'SELECT * FROM work_order_comments WHERE workOrderId = ? ORDER BY createdAt ASC',
    workOrderId
  );
  
  return rows.map(row => ({
    ...row,
    userName: row.userName || '',
    photoIds: JSON.parse(row.photoIds || '[]')
  }));
}

// ============================================================================
// SYNC OPERATIONS
// ============================================================================

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

export async function incrementPendingSyncAttempts(id: number): Promise<void> {
  const database = await getDatabase();
  await database.runAsync(
    'UPDATE pending_sync SET attempts = attempts + 1 WHERE id = ?',
    id
  );
}

export async function removeCompletedWorkOrders(): Promise<void> {
  const database = await getDatabase();
  await database.runAsync(
    "DELETE FROM work_orders WHERE status = 'completed' AND offlineModified = 0"
  );
}

export async function markWorkOrderSynced(id: string): Promise<void> {
  const database = await getDatabase();
  await database.runAsync(
    `UPDATE work_orders 
     SET offlineModified = 0, offlineAction = NULL, lastSyncAt = ?
     WHERE id = ?`,
    new Date().toISOString(),
    id
  );
}

export async function getPendingSyncCount(): Promise<number> {
  const database = await getDatabase();
  const row = await database.getFirstAsync<any>('SELECT COUNT(*) as count FROM pending_sync');
  return row?.count || 0;
}

// ============================================================================
// CLEANUP OPERATIONS
// ============================================================================

export async function clearAllData(): Promise<void> {
  const database = await getDatabase();
  await database.execAsync(`
    DELETE FROM users;
    DELETE FROM work_orders;
    DELETE FROM qr_codes;
    DELETE FROM checklist_templates;
    DELETE FROM checklist_executions;
    DELETE FROM work_order_photos;
    DELETE FROM work_order_comments;
    DELETE FROM pending_sync;
  `);
}

export async function clearSyncedData(): Promise<void> {
  const database = await getDatabase();
  await database.execAsync(`
    DELETE FROM work_order_photos WHERE syncStatus = 'synced';
    DELETE FROM work_order_comments WHERE syncStatus = 'synced';
    DELETE FROM checklist_executions WHERE syncStatus = 'synced';
  `);
}
