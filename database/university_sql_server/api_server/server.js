/**
 * =============================================================================
 * RMUTP University SQL Server - Node.js + Express REST API Middleware
 * =============================================================================
 * ทำหน้าที่เป็นตัวกลาง (Middleware) กั้นระหว่างแอป Flutter กับฐานข้อมูล PostgreSQL
 * ของมหาวิทยาลัย เพื่อไม่ให้แอปมือถือเชื่อมต่อเข้าพอร์ต 5432 โดยตรงตามหลักความปลอดภัยสากล
 * และป้องกัน SQL Injection ด้วย Parameterized Queries ($1, $2, ...)
 * =============================================================================
 */

const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

// ตั้งค่าการเชื่อมต่อฐานข้อมูล PostgreSQL มาตรฐานของมหาวิทยาลัย
const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: parseInt(process.env.PGPORT || '54325', 10),
  database: process.env.PGDATABASE || 'rmutp_university_db',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
});

// -----------------------------------------------------------------------------
// 1. Health Check Endpoint (ตรวจสอบสถานะเซิร์ฟเวอร์มหาวิทยาลัย)
// -----------------------------------------------------------------------------
app.get('/api/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS server_time, current_database() AS db_name');
    res.json({
      status: 'ok',
      mode: 'university_sql_server',
      database: result.rows[0].db_name,
      server_time: result.rows[0].server_time,
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// -----------------------------------------------------------------------------
// 2. Authentication Endpoint (เรียกใช้ Stored Function sp_authenticate_user)
// -----------------------------------------------------------------------------
const handleLogin = async (req, res) => {
  try {
    const { p_email, p_password, email, password } = req.body;
    const targetEmail = p_email || email || '';
    const targetPass = p_password || password || '';

    const result = await pool.query(
      'SELECT * FROM public.sp_authenticate_user($1, $2)',
      [targetEmail, targetPass]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

app.post('/api/auth/login', handleLogin);
app.post('/api/rpc/sp_authenticate_user', handleLogin);
app.post('/rest/v1/rpc/sp_authenticate_user', handleLogin);

// -----------------------------------------------------------------------------
// 3. Generic REST Adapter สำหรับ Views และ Tables (รองรับทั้ง /api/:resource และ /rest/v1/:resource)
// -----------------------------------------------------------------------------
const ALLOWED_RESOURCES = new Set([
  'v_student_profiles',
  'v_student_timetable',
  'v_teacher_timetable',
  'v_teacher_grade_sheet',
  'v_student_grades',
  'v_student_financial_records',
  'faculties',
  'departments',
  'curriculums',
  'buildings_rooms',
  'academic_terms',
  'academic_calendar_events',
  'students',
  'teachers',
  'subjects',
  'course_sections',
  'enrollments',
  'course_materials',
  'assignments',
  'assignment_submissions',
  'attendance_sessions',
  'attendance_records',
  'tuition_invoices',
  'payment_receipts',
  'service_requests',
  'news_announcements',
  'notifications',
]);

// Helper แปลง Query String (เช่น ?student_id=eq.650602001) เป็น SQL Parameterized WHERE clause
function buildWhereClause(queryObj) {
  const clauses = [];
  const values = [];
  let orderClause = '';

  for (const [key, rawVal] of Object.entries(queryObj)) {
    if (key === 'select') continue;
    if (key === 'order') {
      const parts = String(rawVal).split('.');
      const col = parts[0].replace(/[^a-zA-Z0-9_]/g, '');
      const dir = parts[1] && parts[1].toLowerCase() === 'desc' ? 'DESC' : 'ASC';
      if (col) orderClause = ` ORDER BY ${col} ${dir}`;
      continue;
    }

    const col = key.replace(/[^a-zA-Z0-9_]/g, '');
    if (!col) continue;

    const strVal = String(rawVal);
    const val = strVal.startsWith('eq.') ? strVal.slice(3) : strVal;
    values.push(val);
    clauses.push(`${col} = $${values.length}`);
  }

  return {
    whereSql: clauses.length > 0 ? ` WHERE ${clauses.join(' AND ')}` : '',
    orderSql: orderClause,
    values,
  };
}

// GET ข้อมูลจาก Table หรือ View
app.get(['/api/:resource', '/rest/v1/:resource'], async (req, res) => {
  const { resource } = req.params;
  if (!ALLOWED_RESOURCES.has(resource)) {
    return res.status(400).json({ error: `Resource ${resource} is not allowed` });
  }

  try {
    const { whereSql, orderSql, values } = buildWhereClause(req.query);
    const sql = `SELECT * FROM public.${resource}${whereSql}${orderSql}`;
    const result = await pool.query(sql, values);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST เพิ่มข้อมูลใหม่ลงตาราง (เช่น ส่งการบ้าน, ส่งคำร้องใหม่, ลงประกาศข่าว)
app.post(['/api/:resource', '/rest/v1/:resource'], async (req, res) => {
  const { resource } = req.params;
  if (!ALLOWED_RESOURCES.has(resource)) {
    return res.status(400).json({ error: `Resource ${resource} is not allowed` });
  }

  try {
    const payload = req.body;
    const keys = Object.keys(payload).map((k) => k.replace(/[^a-zA-Z0-9_]/g, ''));
    const values = Object.values(payload);
    const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ');

    const sql = `INSERT INTO public.${resource} (${keys.join(', ')}) VALUES (${placeholders}) RETURNING *`;
    const result = await pool.query(sql, values);
    res.status(201).json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH อัปเดตข้อมูลในตาราง (เช่น อาจารย์บันทึกเกรด, เช็กชื่อ, อนุมัติคำร้อง)
app.patch(['/api/:resource', '/rest/v1/:resource'], async (req, res) => {
  const { resource } = req.params;
  if (!ALLOWED_RESOURCES.has(resource)) {
    return res.status(400).json({ error: `Resource ${resource} is not allowed` });
  }

  try {
    const payload = req.body;
    const setCols = [];
    const values = [];

    for (const [k, v] of Object.entries(payload)) {
      const col = k.replace(/[^a-zA-Z0-9_]/g, '');
      values.push(v);
      setCols.push(`${col} = $${values.length}`);
    }

    const whereParts = [];
    for (const [k, rawVal] of Object.entries(req.query)) {
      const col = k.replace(/[^a-zA-Z0-9_]/g, '');
      const strVal = String(rawVal);
      const val = strVal.startsWith('eq.') ? strVal.slice(3) : strVal;
      values.push(val);
      whereParts.push(`${col} = $${values.length}`);
    }

    const whereSql = whereParts.length > 0 ? ` WHERE ${whereParts.join(' AND ')}` : '';
    const sql = `UPDATE public.${resource} SET ${setCols.join(', ')}${whereSql} RETURNING *`;
    const result = await pool.query(sql, values);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = parseInt(process.env.PORT || '4000', 10);
app.listen(PORT, () => {
  console.log(`RMUTP University SQL Express Middleware running on http://localhost:${PORT}`);
});
