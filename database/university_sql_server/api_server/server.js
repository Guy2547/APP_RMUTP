/**
 * =============================================================================
 * RMUTP University SQL Server - OWASP-Hardened Node.js + Express REST Middleware
 * =============================================================================
 * มาตรฐานความปลอดภัย OWASP Top 10 & CWE Top 25:
 *   - CWE-89  : Parameterized Queries ($1, $2) + Column Whitelist + Transactions
 *   - CWE-285 / CWE-639 : JWT Authentication + RBAC + Strict Anti-IDOR Enforcement
 *   - CWE-312 / CWE-200 : ไม่เปิดเผย password_hash และใช้ PDPA Data Masking
 *   - CWE-20  / CWE-307 : Helmet Security Headers, CORS, Rate Limiting & Bounds Check
 *   - CWE-434 : ตรวจสอบนามสกุล/MIME/ขนาดไฟล์อัปโหลด + ป้องกัน Path Traversal
 *   - CWE-209 : Global Error Handler ซ่อน SQL Error & Stack Trace จาก Client
 * =============================================================================
 */

const crypto = require('node:crypto');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { Pool } = require('pg');

const app = express();

// -----------------------------------------------------------------------------
// 1. Security Headers, CORS & Body Size Limit (CWE-20 / OWASP A05)
// -----------------------------------------------------------------------------
app.use(helmet());
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS
      ? process.env.ALLOWED_ORIGINS.split(',')
      : true,
    methods: ['GET', 'POST', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    maxAge: 3600,
  })
);
app.use(express.json({ limit: '1mb' }));

// -----------------------------------------------------------------------------
// 2. Rate Limiting ป้องกัน Brute-Force และการยิงถล่ม (CWE-307)
// -----------------------------------------------------------------------------
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'คำขอมากเกินกำหนด กรุณารอสักครู่แล้วลองใหม่อีกครั้ง' },
});

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'มีการพยายามเข้าสู่ระบบผิดพลาดหลายครั้ง กรุณารอ 15 นาทีแล้วลองใหม่',
  },
});

const checkInLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  max: 15,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'ส่งคำขอเช็กชื่อบ่อยเกินไป กรุณารอสักครู่' },
});

app.use(generalLimiter);

// -----------------------------------------------------------------------------
// 3. PostgreSQL Connection Pool (Standard On-Premise University Server)
// -----------------------------------------------------------------------------
const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: Number.parseInt(process.env.PGPORT || '54325', 10),
  database: process.env.PGDATABASE || 'rmutp_university_db',
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  max: 20,
  idleTimeoutMillis: 30000,
});

// ใช้ Secret จาก Environment Variable (กรณี Dev ใน Docker มีค่า Random ประจำ Process สำรอง)
const JWT_SECRET =
  process.env.JWT_SECRET || crypto.randomBytes(32).toString('hex');

// -----------------------------------------------------------------------------
// 4. JWT Signing, Verification, RBAC & Anti-IDOR Middlewares (CWE-285 / CWE-639)
// -----------------------------------------------------------------------------
function toBase64Url(input) {
  return Buffer.from(input)
    .toString('base64')
    .replaceAll('=', '')
    .replaceAll('+', '-')
    .replaceAll('/', '_');
}

function base64UrlDecode(str) {
  const normalized = str.replaceAll('-', '+').replaceAll('_', '/');
  const padLength = (4 - (normalized.length % 4)) % 4;
  return Buffer.from(normalized + '='.repeat(padLength), 'base64').toString('utf8');
}

function computeJwtSignature(header, body) {
  const digest = crypto
    .createHmac('sha256', JWT_SECRET)
    .update(`${header}.${body}`)
    .digest();
  return toBase64Url(digest);
}

function signJwt(payload, expiresInSeconds = 12 * 3600) {
  const header = toBase64Url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const nowSeconds = Math.floor(Date.now() / 1000);
  const fullPayload = {
    ...payload,
    iat: nowSeconds,
    exp: nowSeconds + expiresInSeconds,
  };
  const body = toBase64Url(JSON.stringify(fullPayload));
  const signature = computeJwtSignature(header, body);
  return `${header}.${body}.${signature}`;
}

function verifyJwt(token) {
  const parts = String(token || '').split('.');
  if (parts.length !== 3) return null;
  const [header, body, sig] = parts;
  const expectedSig = computeJwtSignature(header, body);

  const sigBuf = Buffer.from(sig);
  const expectedBuf = Buffer.from(expectedSig);
  if (
    sigBuf.length !== expectedBuf.length ||
    !crypto.timingSafeEqual(sigBuf, expectedBuf)
  ) {
    return null;
  }

  const decoded = JSON.parse(base64UrlDecode(body));
  if (!decoded.exp || decoded.exp < Math.floor(Date.now() / 1000)) {
    return null;
  }
  return decoded;
}

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization || '';
  if (!authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบก่อนทำรายการ' });
  }
  const token = authHeader.slice(7).trim();
  const decoded = verifyJwt(token);
  if (!decoded) {
    return res
      .status(401)
      .json({ error: 'โทเค็นยืนยันตัวตนไม่ถูกต้องหรือหมดอายุแล้ว' });
  }
  req.user = decoded;
  return next();
}

function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res
        .status(403)
        .json({ error: 'คุณไม่มีสิทธิ์เข้าถึงหรือดำเนินการในส่วนนี้' });
    }
    return next();
  };
}

// Helper รันคำสั่งภายใต้ Database Transaction พร้อมตั้งค่า Audit Context
async function withTransaction(user, workFn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    if (user?.sub) {
      await client.query("SELECT set_config('app.current_user_id', $1, true)", [
        String(user.sub),
      ]);
    }
    const result = await workFn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

// -----------------------------------------------------------------------------
// 5. Resource & Column Whitelist (ห้ามเปิดเผย users / citizen_id ดิบ)
// -----------------------------------------------------------------------------
const RESOURCE_CONFIG = Object.freeze({
  // Views (อ่านอย่างเดียว)
  v_student_profiles: {
    table: 'public.v_student_profiles',
    columns: [
      'student_id', 'university_email', 'prefix_th', 'first_name_th', 'last_name_th',
      'full_name_th', 'full_name_en', 'citizen_id', 'birth_date', 'blood_group',
      'face_photo_url', 'student_card_url', 'faculty_code', 'faculty_name_th', 'campus',
      'department_code', 'department_name_th', 'degree_name_th', 'total_credits_required',
      'year_level', 'enrollment_year', 'education_status', 'gpax', 'current_term_gpa',
      'earned_credits', 'credits_progress_label', 'advisor_name', 'phone', 'personal_email',
      'line_id', 'current_address', 'permanent_address', 'subdistrict', 'district',
      'province', 'postal_code', 'emergency_contact_name', 'emergency_contact_relation',
      'emergency_contact_phone',
    ],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
  },
  v_student_timetable: {
    table: 'public.v_student_timetable',
    columns: [
      'student_id', 'term_label', 'code', 'name', 'credits', 'section', 'day_of_week',
      'time', 'room', 'teacher', 'status', 'course_summary', 'progress',
      'pending_assignments', 'quiz_score', 'lab_score', 'attendance_rate', 'is_lab',
    ],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
  },
  v_teacher_timetable: {
    table: 'public.v_teacher_timetable',
    columns: [
      'teacher_id', 'term_label', 'code', 'timetable_name', 'course_name', 'section',
      'day_of_week', 'time', 'room', 'student_count_label', 'enrolled_count',
      'max_students', 'status', 'course_summary', 'progress',
    ],
    readRoles: ['teacher', 'admin'],
  },
  v_teacher_grade_sheet: {
    table: 'public.v_teacher_grade_sheet',
    columns: [
      'enrollment_id', 'section_id', 'subject_code', 'subject_name', 'section_number',
      'id', 'name', 'full_name', 'midterm', 'final_exam', 'coursework', 'total',
      'grade_letter', 'status',
    ],
    readRoles: ['teacher', 'admin'],
  },
  v_student_grades: {
    table: 'public.v_student_grades',
    columns: [
      'student_id', 'term_label', 'is_current', 'subject_code', 'subject_name',
      'credits', 'letter', 'score', 'total_score', 'is_warning', 'grade_submit_status',
    ],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
  },
  v_student_financial_records: {
    table: 'public.v_student_financial_records',
    columns: [
      'invoice_no', 'student_id', 'student_name', 'term_label', 'tuition_fee',
      'university_fee', 'lab_equipment_fee', 'scholarship_discount', 'total_amount',
      'due_date', 'payment_status', 'invoice_pdf_url', 'receipt_no', 'payment_method',
      'bank_name', 'transaction_ref', 'amount_paid', 'paid_at', 'slip_image_url',
      'receipt_pdf_url', 'finance_officer_name',
    ],
    studentScoped: true,
    readRoles: ['student', 'admin'],
  },
  // Public/Catalog Tables
  faculties: {
    table: 'public.faculties',
    columns: ['id', 'code', 'name_th', 'name_en', 'campus', 'building', 'phone', 'website_url'],
    readRoles: ['student', 'teacher', 'admin'],
  },
  departments: {
    table: 'public.departments',
    columns: ['id', 'faculty_id', 'code', 'name_th', 'name_en', 'degree_name_th', 'total_credits_required'],
    readRoles: ['student', 'teacher', 'admin'],
  },
  academic_calendar_events: {
    table: 'public.academic_calendar_events',
    columns: ['id', 'term_id', 'title', 'date_display', 'event_type', 'start_date', 'end_date', 'description'],
    readRoles: ['student', 'teacher', 'admin'],
  },
  course_materials: {
    table: 'public.course_materials',
    columns: ['id', 'section_id', 'subject_code', 'title', 'file_type', 'file_size_label', 'file_url', 'updated_label'],
    readRoles: ['student', 'teacher', 'admin'],
  },
  assignments: {
    table: 'public.assignments',
    columns: ['id', 'section_id', 'subject_code', 'title', 'description', 'due_badge', 'due_date', 'max_score', 'submitted_count', 'total_students'],
    readRoles: ['student', 'teacher', 'admin'],
  },
  news_announcements: {
    table: 'public.news_announcements',
    columns: ['id', 'title', 'subtitle', 'news_type', 'detail', 'banner_image_url', 'button_label', 'min_gpa_required', 'author_teacher_id', 'view_count', 'published_at', 'expire_date'],
    insertColumns: ['title', 'subtitle', 'news_type', 'detail', 'button_label', 'author_teacher_id'],
    readRoles: ['student', 'teacher', 'admin'],
    writeRoles: ['teacher', 'admin'],
  },
  // Role/Owner-Protected Tables
  enrollments: {
    table: 'public.enrollments',
    columns: ['id', 'student_id', 'section_id', 'term_id', 'subject_code', 'enrollment_status', 'coursework_score', 'midterm_score', 'final_score', 'total_score', 'grade_letter', 'grade_submit_status'],
    updateColumns: ['coursework_score', 'midterm_score', 'final_score', 'grade_submit_status'],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
    writeRoles: ['teacher', 'admin'],
  },
  attendance_sessions: {
    table: 'public.attendance_sessions',
    columns: ['id', 'section_id', 'subject_code', 'session_date', 'week_number', 'room_code', 'open_time_label', 'opened_at', 'is_open', 'present_count', 'total_students'],
    updateColumns: ['is_open'],
    readRoles: ['student', 'teacher', 'admin'],
    writeRoles: ['teacher', 'admin'],
  },
  attendance_records: {
    table: 'public.attendance_records',
    columns: ['id', 'session_id', 'student_id', 'status', 'check_in_time', 'check_in_method', 'reminded_via_line', 'note'],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
  },
  service_requests: {
    table: 'public.service_requests',
    columns: ['request_code', 'student_id', 'category', 'title', 'description', 'room_location', 'status_student', 'status_teacher', 'chip_color_hex', 'progress', 'assigned_teacher_id', 'result_pdf_url', 'created_at'],
    insertColumns: ['request_code', 'student_id', 'category', 'title', 'description', 'status_student', 'status_teacher', 'chip_color_hex', 'progress', 'assigned_teacher_id'],
    updateColumns: ['status_student', 'status_teacher', 'chip_color_hex', 'progress'],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
    insertRoles: ['student', 'teacher', 'admin'],
    writeRoles: ['teacher', 'admin'],
  },
  notifications: {
    table: 'public.notifications',
    columns: ['id', 'student_id', 'title', 'subtitle', 'accent_color_hex', 'is_read', 'created_at'],
    studentScoped: true,
    readRoles: ['student', 'teacher', 'admin'],
  },
  audit_logs: {
    table: 'public.audit_logs',
    columns: ['id', 'actor_id', 'actor_role', 'action', 'target_table', 'target_record_id', 'old_data', 'new_data', 'created_at'],
    readRoles: ['teacher', 'admin'],
  },
});

function getResourceConfig(resourceName) {
  return Object.hasOwn(RESOURCE_CONFIG, resourceName)
    ? RESOURCE_CONFIG[resourceName]
    : null;
}

// -----------------------------------------------------------------------------
// 6. Health Check & Authentication Endpoints
// -----------------------------------------------------------------------------
app.get('/api/health', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT NOW() AS server_time');
    res.json({
      status: 'ok',
      mode: 'university_sql_server',
      server_time: result.rows[0].server_time,
    });
  } catch (err) {
    next(err);
  }
});

const handleLogin = async (req, res, next) => {
  try {
    const email = String(req.body.p_email || req.body.email || '').trim();
    const password = String(req.body.p_password || req.body.password || '');

    if (!email || !password || email.length > 150 || password.length > 128) {
      return res.status(400).json({ error: 'รูปแบบอีเมลหรือรหัสผ่านไม่ถูกต้อง' });
    }

    const result = await pool.query(
      'SELECT user_id, email, role, student_id, teacher_id, display_name, subtitle_info, gpax, current_term_gpa, earned_credits, total_credits_required FROM public.sp_authenticate_user($1, $2)',
      [email, password]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'อีเมลมหาวิทยาลัย หรือ รหัสผ่านไม่ถูกต้อง' });
    }

    const userRow = result.rows[0];
    const accessToken = signJwt({
      sub: userRow.user_id,
      email: userRow.email,
      role: userRow.role,
      student_id: userRow.student_id,
      teacher_id: userRow.teacher_id,
    });

    res.json([
      {
        ...userRow,
        access_token: accessToken,
      },
    ]);
  } catch (err) {
    next(err);
  }
};

app.post(
  ['/api/auth/login', '/api/rpc/sp_authenticate_user', '/rest/v1/rpc/sp_authenticate_user'],
  loginLimiter,
  handleLogin
);

// -----------------------------------------------------------------------------
// 7. Business Logic RPC Endpoints (Transaction + Anti-IDOR + Input Validation)
// -----------------------------------------------------------------------------

// เช็กชื่อเข้าเรียน (ใช้เวลา Server เท่านั้น + Rate Limited + Transaction)
app.post(
  ['/api/attendance/check-in', '/api/rpc/sp_check_in_attendance', '/rest/v1/rpc/sp_check_in_attendance'],
  requireAuth,
  requireRole('student'),
  checkInLimiter,
  async (req, res, next) => {
    try {
      const sessionId = String(
        req.body.p_session_id || '77777777-7777-7777-7777-777777777701'
      );
      const method = String(req.body.p_method || 'qr_scan');
      // Anti-IDOR: บังคับใช้ student_id จาก JWT ที่ Verify แล้วเท่านั้น
      const requestedSid = req.body.p_student_id;
      if (requestedSid && requestedSid !== req.user.student_id) {
        return res.status(403).json({ error: 'ไม่อนุญาตให้เช็กชื่อแทนผู้อื่น' });
      }

      const rows = await withTransaction(req.user, async (client) => {
        const result = await client.query(
          'SELECT * FROM public.sp_check_in_attendance($1::uuid, $2::varchar, $3::varchar)',
          [sessionId, req.user.student_id, method]
        );
        return result.rows;
      });

      res.json(rows);
    } catch (err) {
      if (err.message?.includes('closed')) {
        return res.status(400).json({ error: 'อาจารย์ปิดรับเช็กชื่อแล้ว' });
      }
      if (err.message?.includes('Duplicate')) {
        return res.status(409).json({ error: 'คุณได้เช็กชื่อในคาบนี้ไปแล้ว' });
      }
      next(err);
    }
  }
);

// ส่งการบ้าน (ตรวจสอบไฟล์/MIME/ขนาด <= 5MB + Transaction + เทียบเวลา Server)
const ALLOWED_EXT = /\.(pdf|png|jpg|jpeg|docx)$/i;
const ALLOWED_MIMES = new Set([
  'application/pdf',
  'image/png',
  'image/jpeg',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
]);

app.post(
  ['/api/assignments/submit', '/api/rpc/sp_submit_assignment', '/rest/v1/rpc/sp_submit_assignment'],
  requireAuth,
  requireRole('student'),
  async (req, res, next) => {
    try {
      const assignmentId = String(
        req.body.p_assignment_id || '66666666-6666-6666-6666-666666666601'
      );
      const filename = String(req.body.p_original_filename || '').trim();
      const fileSize = Number.parseInt(req.body.p_file_size_bytes || '256000', 10);
      const mimeType = String(req.body.p_mime_type || 'application/pdf').trim();

      if (!ALLOWED_EXT.test(filename) || filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        return res.status(400).json({ error: 'นามสกุลไฟล์หรือชื่อไฟล์ไม่ปลอดภัย อนุญาตเฉพาะ .pdf, .png, .jpg, .docx' });
      }
      if (!ALLOWED_MIMES.has(mimeType)) {
        return res.status(400).json({ error: 'ประเภท MIME ของไฟล์ไม่ได้รับอนุญาต' });
      }
      if (Number.isNaN(fileSize) || fileSize <= 0 || fileSize > 5242880) {
        return res.status(400).json({ error: 'ขนาดไฟล์ต้องไม่เกิน 5 MB' });
      }

      const rows = await withTransaction(req.user, async (client) => {
        const result = await client.query(
          'SELECT * FROM public.sp_submit_assignment($1::uuid, $2::varchar, $3::varchar, $4::int, $5::varchar)',
          [assignmentId, req.user.student_id, filename, fileSize, mimeType]
        );
        return result.rows;
      });

      res.json(rows);
    } catch (err) {
      next(err);
    }
  }
);

// อาจารย์บันทึก/ส่งเกรดทั้งห้องแบบ Transaction + ตรวจสอบขอบเขตคะแนน + Audit Log
app.post(
  ['/api/grades/submit', '/api/rpc/sp_submit_section_grades', '/rest/v1/rpc/sp_submit_section_grades'],
  requireAuth,
  requireRole('teacher', 'admin'),
  async (req, res, next) => {
    try {
      const subjectCode = String(req.body.p_subject_code || '').trim();
      const grades = req.body.p_grades;
      const submitFinal = Boolean(req.body.p_submit_final);

      if (!subjectCode || !Array.isArray(grades)) {
        return res.status(400).json({ error: 'ข้อมูลคะแนนไม่ถูกต้อง' });
      }

      for (const g of grades) {
        const mid = Number(g.midterm);
        const fin = Number(g.final_exam);
        const cw = Number(g.coursework);
        if (
          Number.isNaN(mid) || mid < 0 || mid > 30 ||
          Number.isNaN(fin) || fin < 0 || fin > 40 ||
          Number.isNaN(cw) || cw < 0 || cw > 30
        ) {
          return res.status(400).json({ error: 'คะแนนต้องอยู่ในช่วงที่กำหนด (เก็บ 0-30, กลางภาค 0-30, ปลายภาค 0-40)' });
        }
      }

      const updatedCount = await withTransaction(req.user, async (client) => {
        const result = await client.query(
          'SELECT public.sp_submit_section_grades($1::varchar, $2::varchar, $3::jsonb, $4::boolean) AS updated_count',
          [req.user.teacher_id || 'ADMIN', subjectCode, JSON.stringify(grades), submitFinal]
        );
        return result.rows[0].updated_count;
      });

      res.json({ updated_count: updatedCount });
    } catch (err) {
      next(err);
    }
  }
);

// -----------------------------------------------------------------------------
// 8. Protected Parameterized Query Builder & Generic REST Adapter
// -----------------------------------------------------------------------------
function stripEqPrefix(rawVal) {
  const strVal = String(rawVal);
  return strVal.startsWith('eq.') ? strVal.slice(3) : strVal;
}

function parseOrderClause(rawOrder, allowedCols) {
  if (!rawOrder) return '';
  const [rawCol, rawDir] = String(rawOrder).split('.');
  const safeCol = allowedCols.find((col) => col === rawCol);
  if (!safeCol) return '';
  const dir = rawDir?.toLowerCase() === 'desc' ? 'DESC' : 'ASC';
  return ` ORDER BY ${safeCol} ${dir}`;
}

function buildSafeWhereClause(queryObj, allowedCols, forcedFilter = {}) {
  const clauses = [];
  const values = [];

  // บังคับใช้ค่าตัวกรองจาก JWT (Anti-IDOR) และใช้ชื่อคอลัมน์จาก Whitelist เท่านั้น
  for (const col of allowedCols) {
    if (Object.hasOwn(forcedFilter, col)) {
      values.push(forcedFilter[col]);
      clauses.push(`${col} = $${values.length}`);
      continue;
    }
    if (Object.hasOwn(queryObj, col)) {
      values.push(stripEqPrefix(queryObj[col]));
      clauses.push(`${col} = $${values.length}`);
    }
  }

  return {
    whereSql: clauses.length > 0 ? ` WHERE ${clauses.join(' AND ')}` : '',
    orderSql: parseOrderClause(queryObj.order, allowedCols),
    values,
  };
}

function validateEnrollmentScores(body) {
  for (const field of ['midterm_score', 'coursework_score', 'final_score']) {
    if (body[field] === undefined) continue;
    const val = Number(body[field]);
    const max = field === 'final_score' ? 40 : 30;
    if (Number.isNaN(val) || val < 0 || val > max) {
      return `คะแนน ${field} ต้องอยู่ระหว่าง 0 ถึง ${max}`;
    }
  }
  return null;
}

function buildPatchParts(body, queryObj, cfg) {
  const setCols = [];
  const values = [];
  for (const col of cfg.updateColumns) {
    if (!Object.hasOwn(body, col)) continue;
    values.push(body[col]);
    setCols.push(`${col} = $${values.length}`);
  }

  const whereParts = [];
  for (const col of cfg.columns) {
    if (!Object.hasOwn(queryObj, col)) continue;
    values.push(stripEqPrefix(queryObj[col]));
    whereParts.push(`${col} = $${values.length}`);
  }

  return { setCols, whereParts, values };
}

// GET Resource (ต้องยืนยัน JWT + เช็ก Role + เช็ก Anti-IDOR ทุกครั้ง)
app.get(['/api/:resource', '/rest/v1/:resource'], requireAuth, async (req, res, next) => {
  const cfg = getResourceConfig(req.params.resource);
  if (!cfg) {
    return res.status(404).json({ error: 'ไม่พบทรัพยากรที่ร้องขอ' });
  }
  if (!cfg.readRoles.includes(req.user.role)) {
    return res.status(403).json({ error: 'คุณไม่มีสิทธิ์ดูข้อมูลส่วนนี้' });
  }

  // Anti-IDOR: ถ้านักศึกษาพยายามส่ง student_id คนอื่นใน Query ให้บล็อกทันที
  const forcedFilter = {};
  if (req.user.role === 'student' && cfg.studentScoped) {
    const reqSid = req.query.student_id ? stripEqPrefix(req.query.student_id) : null;
    if (reqSid && reqSid !== req.user.student_id) {
      return res.status(403).json({ error: 'ไม่อนุญาตให้เข้าถึงข้อมูลของนักศึกษาท่านอื่น (IDOR Blocked)' });
    }
    forcedFilter.student_id = req.user.student_id;
  }

  try {
    const selectCols = cfg.columns.join(', ');
    const { whereSql, orderSql, values } = buildSafeWhereClause(
      req.query,
      cfg.columns,
      forcedFilter
    );
    const sql = `SELECT ${selectCols} FROM ${cfg.table}${whereSql}${orderSql}`;
    const result = await pool.query(sql, values);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

// POST Resource (ภายใต้ Transaction + Whitelist Columns + Anti-IDOR)
app.post(['/api/:resource', '/rest/v1/:resource'], requireAuth, async (req, res, next) => {
  const cfg = getResourceConfig(req.params.resource);
  if (!cfg?.insertColumns) {
    return res.status(403).json({ error: 'ไม่อนุญาตให้สร้างข้อมูลในตารางนี้โดยตรง' });
  }

  const permittedRoles = cfg.insertRoles || cfg.writeRoles || [];
  if (!permittedRoles.includes(req.user.role)) {
    return res.status(403).json({ error: 'คุณไม่มีสิทธิ์เพิ่มข้อมูลในส่วนนี้' });
  }

  try {
    const body = { ...req.body };
    if (req.user.role === 'student' && cfg.studentScoped) {
      if (body.student_id && body.student_id !== req.user.student_id) {
        return res.status(403).json({ error: 'ไม่อนุญาตให้ส่งคำร้องแทนผู้อื่น' });
      }
      body.student_id = req.user.student_id;
    }
    if (cfg.table === 'public.news_announcements' && req.user.teacher_id) {
      body.author_teacher_id = req.user.teacher_id;
    }

    const keys = cfg.insertColumns.filter((col) => Object.hasOwn(body, col));
    if (keys.length === 0) {
      return res.status(400).json({ error: 'ไม่มีฟิลด์ที่ได้รับอนุญาตให้บันทึก' });
    }

    const values = keys.map((k) => body[k]);
    const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ');
    const returnCols = cfg.columns.join(', ');

    const rows = await withTransaction(req.user, async (client) => {
      const sql = `INSERT INTO ${cfg.table} (${keys.join(', ')}) VALUES (${placeholders}) RETURNING ${returnCols}`;
      const result = await client.query(sql, values);
      return result.rows;
    });

    res.status(201).json(rows);
  } catch (err) {
    next(err);
  }
});

// PATCH Resource (เฉพาะ Role ที่ได้รับอนุญาต + Transaction + Input Validation)
app.patch(['/api/:resource', '/rest/v1/:resource'], requireAuth, async (req, res, next) => {
  const cfg = getResourceConfig(req.params.resource);
  if (!cfg?.updateColumns) {
    return res.status(403).json({ error: 'ไม่อนุญาตให้แก้ไขข้อมูลในตารางนี้โดยตรง' });
  }

  const permittedRoles = cfg.writeRoles || [];
  if (!permittedRoles.includes(req.user.role)) {
    return res.status(403).json({ error: 'เฉพาะอาจารย์หรือผู้ดูแลระบบเท่านั้นที่แก้ไขข้อมูลส่วนนี้ได้' });
  }

  try {
    const body = { ...req.body };
    if (cfg.table === 'public.enrollments') {
      const scoreError = validateEnrollmentScores(body);
      if (scoreError) {
        return res.status(400).json({ error: scoreError });
      }
    }

    const { setCols, whereParts, values } = buildPatchParts(body, req.query, cfg);
    if (setCols.length === 0) {
      return res.status(400).json({ error: 'ไม่มีฟิลด์ที่ได้รับอนุญาตให้แก้ไข' });
    }
    if (whereParts.length === 0) {
      return res.status(400).json({ error: 'ต้องระบุเงื่อนไขในการแก้ไขข้อมูลเพื่อความปลอดภัย' });
    }

    const returnCols = cfg.columns.join(', ');
    const rows = await withTransaction(req.user, async (client) => {
      const sql = `UPDATE ${cfg.table} SET ${setCols.join(', ')} WHERE ${whereParts.join(' AND ')} RETURNING ${returnCols}`;
      const result = await client.query(sql, values);
      return result.rows;
    });

    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// -----------------------------------------------------------------------------
// 9. Global Error Handler (CWE-209: ห้ามพ่น SQL Error หรือ Stack Trace กลับให้ Client)
// -----------------------------------------------------------------------------
app.use((err, req, res, _next) => {
  console.error('[RMUTP API Internal Error]', {
    path: req.path,
    method: req.method,
    message: err.message,
  });
  res.status(500).json({
    error: 'เกิดข้อผิดพลาดภายในระบบฐานข้อมูล กรุณาลองใหม่อีกครั้ง',
  });
});

const PORT = Number.parseInt(process.env.PORT || '4000', 10);
app.listen(PORT, () => {
  console.log(`RMUTP Hardened University Express API running on port ${PORT}`);
});
