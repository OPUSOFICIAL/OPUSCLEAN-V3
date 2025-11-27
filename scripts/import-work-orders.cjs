const fs = require('fs');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const columns = [
  'id', 'number', 'company_id', 'module', 'zone_id', 'service_id', 
  'cleaning_activity_id', 'maintenance_activity_id', 'checklist_template_id',
  'maintenance_checklist_template_id', 'equipment_id', 'maintenance_plan_equipment_id',
  'type', 'status', 'priority', 'title', 'description', 'assigned_user_id',
  'origin', 'qr_code_point_id', 'requester_name', 'requester_contact',
  'scheduled_date', 'due_date', 'scheduled_start_at', 'scheduled_end_at',
  'started_at', 'completed_at', 'estimated_hours', 'sla_start_minutes',
  'sla_complete_minutes', 'observations', 'checklist_data', 'attachments',
  'customer_rating', 'customer_rating_comment', 'rated_at', 'rated_by',
  'created_at', 'updated_at', 'cancellation_reason', 'cancelled_at', 'cancelled_by',
  'customer_id', 'assigned_user_ids', 'local_id', 'sync_status', 'created_offline',
  'last_sync_attempt', 'sync_retry_count', 'sync_error', 'synced_at'
];

async function importWorkOrders() {
  const client = await pool.connect();
  
  try {
    const data = fs.readFileSync('/tmp/work_orders_dump.tsv', 'utf8');
    const lines = data.split('\n').filter(line => line.trim() && !line.startsWith('\\'));
    
    console.log(`Found ${lines.length} work orders to process`);
    
    const existingIds = await client.query('SELECT id FROM work_orders');
    const existingIdSet = new Set(existingIds.rows.map(r => r.id));
    console.log(`Existing work orders in database: ${existingIdSet.size}`);
    
    let inserted = 0;
    let skipped = 0;
    let errors = 0;
    
    for (const line of lines) {
      const values = line.split('\t');
      const id = values[0];
      
      if (existingIdSet.has(id)) {
        skipped++;
        continue;
      }
      
      const record = {};
      columns.forEach((col, idx) => {
        let val = values[idx];
        if (val === '\\N' || val === undefined || val === '') {
          val = null;
        }
        record[col] = val;
      });
      
      if (!record.sync_status) record.sync_status = 'synced';
      if (!record.created_offline) record.created_offline = false;
      if (!record.sync_retry_count) record.sync_retry_count = 0;
      
      try {
        const insertCols = Object.keys(record).filter(k => record[k] !== null);
        const insertVals = insertCols.map(k => record[k]);
        const placeholders = insertCols.map((_, i) => `$${i + 1}`);
        
        const query = `
          INSERT INTO work_orders (${insertCols.join(', ')})
          VALUES (${placeholders.join(', ')})
          ON CONFLICT (id) DO NOTHING
        `;
        
        await client.query(query, insertVals);
        inserted++;
        
        if (inserted % 100 === 0) {
          console.log(`Inserted ${inserted} work orders...`);
        }
      } catch (err) {
        errors++;
        if (errors <= 5) {
          console.error(`Error inserting work order ${id}:`, err.message);
        }
      }
    }
    
    console.log(`\nImport complete:`);
    console.log(`  - Inserted: ${inserted}`);
    console.log(`  - Skipped (already exists): ${skipped}`);
    console.log(`  - Errors: ${errors}`);
    
    const finalCount = await client.query('SELECT COUNT(*) FROM work_orders');
    console.log(`  - Total work orders in database: ${finalCount.rows[0].count}`);
    
  } finally {
    client.release();
    await pool.end();
  }
}

importWorkOrders().catch(console.error);
