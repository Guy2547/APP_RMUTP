-- =============================================================================
-- RMUTP CAMPUS APP - HARDENED SUPABASE CLOUD DATABASE SETUP (OWASP & CWE)
-- มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร (Rajamangala University of Technology Phra Nakhon)
-- =============================================================================
-- ยึดมาตรฐานความปลอดภัย OWASP Top 10 & CWE Top 25:
--   1. CWE-89  : Parameterized Stored Procedures & Atomic Transactions
--   2. CWE-285 / CWE-639 : Strict RLS + Session Verification + Anti-IDOR
--   3. CWE-312 / CWE-200 : bcrypt (cost 10), SHA-256 Session Hash, PDPA Citizen ID Masking
--   4. CWE-20  : Strict CHECK Constraints on all scores, sizes, and MIME types
--   5. CWE-434 : Private Storage Buckets (submissions, receipts) & Safe File Renaming
--   6. CWE-778 : Immutable Audit Logs Table & Automatic Triggers
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- ส่วนที่ 1: โครงสร้างตารางหลัก 23 ตาราง + ตาราง Session & Audit Trail (3NF)
-- =============================================================================

-- 1. ตารางคณะวิชา (Faculties)
CREATE TABLE IF NOT EXISTS public.faculties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(15) UNIQUE NOT NULL,
    name_th VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    campus VARCHAR(100) NOT NULL,
    building VARCHAR(100),
    phone VARCHAR(30),
    website_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. ตารางภาควิชา / สาขาวิชา (Departments)
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    faculty_id UUID NOT NULL REFERENCES public.faculties(id) ON DELETE CASCADE,
    code VARCHAR(15) UNIQUE NOT NULL,
    name_th VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    degree_name_th VARCHAR(150) NOT NULL,
    total_credits_required INT NOT NULL DEFAULT 132 CHECK (total_credits_required > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. ตารางหลักสูตรการศึกษา (Curriculums)
CREATE TABLE IF NOT EXISTS public.curriculums (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    department_id UUID NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
    curriculum_code VARCHAR(30) UNIQUE NOT NULL,
    name_th VARCHAR(200) NOT NULL,
    revision_year INT NOT NULL DEFAULT 2565,
    total_credits INT NOT NULL DEFAULT 132,
    general_ed_credits INT NOT NULL DEFAULT 30,
    major_required_credits INT NOT NULL DEFAULT 96,
    free_elective_credits INT NOT NULL DEFAULT 6,
    study_years INT NOT NULL DEFAULT 4,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. ตารางอาคารและห้องเรียน/ห้องปฏิบัติการ (Buildings & Rooms)
CREATE TABLE IF NOT EXISTS public.buildings_rooms (
    room_code VARCHAR(30) PRIMARY KEY,
    building_no VARCHAR(20) NOT NULL,
    building_name_th VARCHAR(150) NOT NULL,
    campus VARCHAR(100) NOT NULL DEFAULT 'ศูนย์พระนครเหนือ',
    floor_no INT NOT NULL DEFAULT 1,
    room_type VARCHAR(30) NOT NULL DEFAULT 'lecture'
        CHECK (room_type IN ('lecture', 'computer_lab', 'engineering_lab', 'auditorium', 'online')),
    capacity INT NOT NULL DEFAULT 45,
    has_projector BOOLEAN NOT NULL DEFAULT TRUE,
    aircon_count INT NOT NULL DEFAULT 2,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. ตารางปีการศึกษาและภาคเรียน (Academic Terms)
CREATE TABLE IF NOT EXISTS public.academic_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    academic_year INT NOT NULL CHECK (academic_year >= 2550),
    semester INT NOT NULL CHECK (semester IN (1, 2, 3)),
    term_label VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    midterm_start_date DATE,
    midterm_end_date DATE,
    final_start_date DATE,
    final_end_date DATE,
    grade_submit_deadline DATE,
    is_current BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (academic_year, semester)
);

-- 6. ตารางปฏิทินการศึกษา (Academic Calendar Events)
CREATE TABLE IF NOT EXISTS public.academic_calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    date_display VARCHAR(50) NOT NULL,
    event_type VARCHAR(30) NOT NULL DEFAULT 'general'
        CHECK (event_type IN ('exam', 'deadline', 'scholarship', 'coop', 'activity', 'holiday', 'general')),
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. ตารางบัญชีผู้ใช้งานหลัก (Users & Authentication)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'student'
        CHECK (role IN ('student', 'teacher', 'staff', 'admin')),
    preferred_language VARCHAR(5) NOT NULL DEFAULT 'th'
        CHECK (preferred_language IN ('th', 'en')),
    notification_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. ตารางข้อมูลอาจารย์และบุคลากร (Teachers)
CREATE TABLE IF NOT EXISTS public.teachers (
    teacher_id VARCHAR(20) PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    academic_rank VARCHAR(30) NOT NULL DEFAULT 'อ.',
    first_name_th VARCHAR(100) NOT NULL,
    last_name_th VARCHAR(100) NOT NULL,
    first_name_en VARCHAR(100),
    last_name_en VARCHAR(100),
    face_photo_url TEXT,
    faculty_id UUID NOT NULL REFERENCES public.faculties(id),
    department_id UUID NOT NULL REFERENCES public.departments(id),
    office_room VARCHAR(50),
    phone VARCHAR(30),
    line_id VARCHAR(50),
    advisor_class_year INT DEFAULT 2,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. ตารางข้อมูลประวัตินักศึกษาเชิงลึก (Students)
CREATE TABLE IF NOT EXISTS public.students (
    student_id VARCHAR(15) PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    prefix_th VARCHAR(20) NOT NULL,
    first_name_th VARCHAR(100) NOT NULL,
    last_name_th VARCHAR(100) NOT NULL,
    first_name_en VARCHAR(100),
    last_name_en VARCHAR(100),
    citizen_id VARCHAR(13) UNIQUE,
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    blood_group VARCHAR(5) CHECK (blood_group IN ('A', 'B', 'O', 'AB')),
    face_photo_url TEXT,
    student_card_url TEXT,
    faculty_id UUID NOT NULL REFERENCES public.faculties(id),
    department_id UUID NOT NULL REFERENCES public.departments(id),
    curriculum_id UUID REFERENCES public.curriculums(id) ON DELETE SET NULL,
    advisor_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    enrollment_year INT NOT NULL,
    year_level INT NOT NULL DEFAULT 2 CHECK (year_level BETWEEN 1 AND 8),
    education_status VARCHAR(25) NOT NULL DEFAULT 'studying'
        CHECK (education_status IN ('studying', 'on_leave', 'probation', 'graduated', 'retired')),
    gpax NUMERIC(3, 2) NOT NULL DEFAULT 0.00 CHECK (gpax BETWEEN 0.00 AND 4.00),
    current_term_gpa NUMERIC(3, 2) NOT NULL DEFAULT 0.00 CHECK (current_term_gpa BETWEEN 0.00 AND 4.00),
    earned_credits INT NOT NULL DEFAULT 0 CHECK (earned_credits >= 0),
    phone VARCHAR(20),
    personal_email VARCHAR(150),
    line_id VARCHAR(50),
    current_address TEXT,
    permanent_address TEXT,
    subdistrict VARCHAR(100),
    district VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(10),
    emergency_contact_name VARCHAR(150),
    emergency_contact_relation VARCHAR(50),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. ตารางรายวิชาตามหลักสูตร (Subjects)
CREATE TABLE IF NOT EXISTS public.subjects (
    subject_code VARCHAR(15) PRIMARY KEY,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    name_th VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    credits INT NOT NULL DEFAULT 3 CHECK (credits > 0),
    lecture_hours INT NOT NULL DEFAULT 3,
    lab_hours INT NOT NULL DEFAULT 0,
    self_study_hours INT NOT NULL DEFAULT 6,
    is_lab BOOLEAN NOT NULL DEFAULT FALSE,
    prerequisite_code VARCHAR(15),
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. ตารางกลุ่มเรียน / ตอนเรียนที่เปิดสอนในแต่ละเทอม (Course Sections)
CREATE TABLE IF NOT EXISTS public.course_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    section_number VARCHAR(20) NOT NULL,
    teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    day_of_week VARCHAR(10) NOT NULL
        CHECK (day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    time_display VARCHAR(30) NOT NULL,
    room VARCHAR(100) NOT NULL,
    max_students INT NOT NULL DEFAULT 40,
    enrolled_count INT NOT NULL DEFAULT 0,
    course_progress INT NOT NULL DEFAULT 0 CHECK (course_progress BETWEEN 0 AND 100),
    status_student_badge VARCHAR(100),
    status_teacher_badge VARCHAR(100),
    course_summary_student VARCHAR(150),
    course_summary_teacher VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (subject_code, term_id, section_number)
);

-- 12. ตารางการลงทะเบียนเรียนและผลการเรียนรายวิชา (Enrollments & Grades)
CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    enrollment_status VARCHAR(20) NOT NULL DEFAULT 'enrolled'
        CHECK (enrollment_status IN ('enrolled', 'withdrawn', 'completed')),
    quiz_score NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (quiz_score BETWEEN 0 AND 15),
    lab_score NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (lab_score BETWEEN 0 AND 25),
    coursework_score INT NOT NULL DEFAULT 0 CHECK (coursework_score BETWEEN 0 AND 30),
    midterm_score INT NOT NULL DEFAULT 0 CHECK (midterm_score BETWEEN 0 AND 30),
    final_score INT NOT NULL DEFAULT 0 CHECK (final_score BETWEEN 0 AND 40),
    total_score INT NOT NULL DEFAULT 0 CHECK (total_score BETWEEN 0 AND 100),
    grade_letter VARCHAR(10),
    grade_display VARCHAR(25),
    grade_point NUMERIC(3, 2) CHECK (grade_point BETWEEN 0.00 AND 4.00),
    grade_submit_status VARCHAR(20) NOT NULL DEFAULT 'ร่าง'
        CHECK (grade_submit_status IN ('ร่าง', 'ส่งแล้ว', 'ประกาศผลแล้ว')),
    is_warning BOOLEAN NOT NULL DEFAULT FALSE,
    attendance_rate NUMERIC(5, 2) NOT NULL DEFAULT 100.00,
    pending_assignments INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, section_id)
);

-- 13. ตารางเอกสารประกอบการสอน (Course Materials)
CREATE TABLE IF NOT EXISTS public.course_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    file_type VARCHAR(20) NOT NULL DEFAULT 'PDF',
    file_size_label VARCHAR(30) NOT NULL,
    file_url TEXT NOT NULL,
    updated_label VARCHAR(50) DEFAULT 'อัปเดตเมื่อวาน',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. ตารางงานที่สั่ง / การบ้าน (Assignments)
CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_badge VARCHAR(50),
    due_date TIMESTAMPTZ NOT NULL,
    max_score NUMERIC(5, 2) NOT NULL DEFAULT 10.00,
    submitted_count INT NOT NULL DEFAULT 0,
    total_students INT NOT NULL DEFAULT 40,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. ตารางการส่งงานของนักศึกษา (Assignment Submissions - รองรับการตรวจสอบขนาด/MIME ไฟล์)
CREATE TABLE IF NOT EXISTS public.assignment_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_name VARCHAR(200),
    file_size_bytes INT NOT NULL DEFAULT 204800 CHECK (file_size_bytes > 0 AND file_size_bytes <= 5242880),
    mime_type VARCHAR(100) NOT NULL DEFAULT 'application/pdf'
        CHECK (mime_type IN (
            'application/pdf',
            'image/png',
            'image/jpeg',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        )),
    status VARCHAR(20) NOT NULL DEFAULT 'submitted'
        CHECK (status IN ('pending', 'submitted', 'late', 'graded')),
    score NUMERIC(5, 2) CHECK (score IS NULL OR score >= 0),
    teacher_feedback TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (assignment_id, student_id)
);

-- กรณีตารางเดิมถูกสร้างไว้แล้ว ให้เพิ่มคอลัมน์และข้อจำกัด Input Validation อย่างปลอดภัย
ALTER TABLE public.enrollments DROP CONSTRAINT IF EXISTS enrollments_quiz_score_check;
ALTER TABLE public.enrollments ADD CONSTRAINT enrollments_quiz_score_check CHECK (quiz_score BETWEEN 0 AND 15);
ALTER TABLE public.enrollments DROP CONSTRAINT IF EXISTS enrollments_lab_score_check;
ALTER TABLE public.enrollments ADD CONSTRAINT enrollments_lab_score_check CHECK (lab_score BETWEEN 0 AND 25);

ALTER TABLE public.assignment_submissions
    ADD COLUMN IF NOT EXISTS file_size_bytes INT NOT NULL DEFAULT 204800 CHECK (file_size_bytes > 0 AND file_size_bytes <= 5242880);
ALTER TABLE public.assignment_submissions
    ADD COLUMN IF NOT EXISTS mime_type VARCHAR(100) NOT NULL DEFAULT 'application/pdf'
        CHECK (mime_type IN (
            'application/pdf',
            'image/png',
            'image/jpeg',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ));

-- 16. ตารางการเปิดห้องเช็กชื่อแต่ละคาบ (Attendance Sessions)
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    session_date DATE NOT NULL DEFAULT CURRENT_DATE,
    week_number INT NOT NULL DEFAULT 6,
    room_code VARCHAR(20) NOT NULL,
    qr_code_payload TEXT,
    open_time_label VARCHAR(50) DEFAULT '09:00–09:15',
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    present_count INT NOT NULL DEFAULT 0,
    total_students INT NOT NULL DEFAULT 40,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 17. ตารางบันทึกการเช็กชื่อรายบุคคล (Attendance Records)
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    status VARCHAR(15) NOT NULL DEFAULT 'absent'
        CHECK (status IN ('present', 'late', 'absent', 'leave')),
    check_in_time VARCHAR(10),
    check_in_method VARCHAR(20) DEFAULT 'qr_scan'
        CHECK (check_in_method IN ('qr_scan', 'room_code', 'teacher_manual')),
    reminded_via_line BOOLEAN NOT NULL DEFAULT FALSE,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (session_id, student_id)
);

-- 18. ตารางใบแจ้งหนี้ค่าเทอมและค่าธรรมเนียม (Tuition Invoices)
CREATE TABLE IF NOT EXISTS public.tuition_invoices (
    invoice_no VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    tuition_fee NUMERIC(10, 2) NOT NULL DEFAULT 15000.00 CHECK (tuition_fee >= 0),
    university_fee NUMERIC(10, 2) NOT NULL DEFAULT 2000.00 CHECK (university_fee >= 0),
    lab_equipment_fee NUMERIC(10, 2) NOT NULL DEFAULT 1500.00 CHECK (lab_equipment_fee >= 0),
    scholarship_discount NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (scholarship_discount >= 0),
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 18500.00 CHECK (total_amount >= 0),
    due_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'unpaid'
        CHECK (payment_status IN ('unpaid', 'verifying', 'paid', 'overdue', 'cancelled')),
    invoice_pdf_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, term_id)
);

-- 19. ตารางใบเสร็จรับเงินและหลักฐานการชำระเงิน (Payment Receipts)
CREATE TABLE IF NOT EXISTS public.payment_receipts (
    receipt_no VARCHAR(30) PRIMARY KEY,
    invoice_no VARCHAR(30) NOT NULL REFERENCES public.tuition_invoices(invoice_no) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    payment_method VARCHAR(30) NOT NULL DEFAULT 'qr_promptpay'
        CHECK (payment_method IN ('qr_promptpay', 'mobile_banking', 'bank_counter', 'credit_card', 'scholarship')),
    bank_name VARCHAR(100),
    transaction_ref VARCHAR(100) UNIQUE,
    amount_paid NUMERIC(10, 2) NOT NULL CHECK (amount_paid >= 0),
    paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    slip_image_url TEXT,
    receipt_pdf_url TEXT NOT NULL,
    finance_officer_name VARCHAR(150) DEFAULT 'กองคลัง สำนักงานอธิการบดี มทร.พระนคร',
    is_verified BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. ตารางคำร้องและแจ้งเรื่อง (Service Requests)
CREATE TABLE IF NOT EXISTS public.service_requests (
    request_code VARCHAR(20) PRIMARY KEY,
    student_id VARCHAR(15) REFERENCES public.students(student_id) ON DELETE CASCADE,
    category VARCHAR(20) NOT NULL DEFAULT 'document'
        CHECK (category IN ('document', 'repair', 'complaint', 'other')),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    room_location VARCHAR(100),
    attachment_image_url TEXT,
    result_pdf_url TEXT,
    status_student VARCHAR(50) NOT NULL DEFAULT 'รอดำเนินการ',
    status_teacher VARCHAR(50) NOT NULL DEFAULT 'รออนุมัติ',
    chip_color_hex VARCHAR(10) NOT NULL DEFAULT '#FFC107',
    progress NUMERIC(3, 2) NOT NULL DEFAULT 0.30 CHECK (progress BETWEEN 0.00 AND 1.00),
    assigned_teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 21. ตารางข่าวสารและประกาศ (News Announcements)
CREATE TABLE IF NOT EXISTS public.news_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(250) NOT NULL,
    subtitle VARCHAR(150) NOT NULL,
    news_type VARCHAR(30) NOT NULL
        CHECK (news_type IN ('ทุน', 'ฝึกงาน', 'กิจกรรม', 'ประกาศ')),
    detail TEXT NOT NULL,
    banner_image_url TEXT,
    button_label VARCHAR(50) NOT NULL DEFAULT 'ดูรายละเอียด',
    action_url TEXT,
    min_gpa_required NUMERIC(3, 2),
    author_teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    view_count INT NOT NULL DEFAULT 120,
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expire_date DATE
);

-- 22. ตารางการแจ้งเตือน (Notifications)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    student_id VARCHAR(15) REFERENCES public.students(student_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(250) NOT NULL,
    accent_color_hex VARCHAR(10) NOT NULL DEFAULT '#652D91',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 23. ตารางบันทึกประวัติการแก้ไขสำคัญ (Audit Trail - CWE-778)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id VARCHAR(50),
    actor_role VARCHAR(20),
    action VARCHAR(50) NOT NULL,
    target_table VARCHAR(50) NOT NULL,
    target_record_id VARCHAR(100) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 24. ตารางเก็บ Session Token ที่เข้ารหัส SHA-256 สำหรับยืนยันตัวตนผ่าน RLS & Anti-IDOR
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token_hash TEXT UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL,
    student_id VARCHAR(15),
    teacher_id VARCHAR(20),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes สำหรับเพิ่มความเร็วในการ Query
CREATE INDEX IF NOT EXISTS idx_students_department ON public.students(department_id);
CREATE INDEX IF NOT EXISTS idx_students_advisor ON public.students(advisor_id);
CREATE INDEX IF NOT EXISTS idx_sections_term_subject ON public.course_sections(term_id, subject_code);
CREATE INDEX IF NOT EXISTS idx_sections_day ON public.course_sections(day_of_week);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_term ON public.enrollments(student_id, term_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_section ON public.enrollments(section_id);
CREATE INDEX IF NOT EXISTS idx_attendance_session ON public.attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student ON public.attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_invoices_student ON public.tuition_invoices(student_id);
CREATE INDEX IF NOT EXISTS idx_receipts_student ON public.payment_receipts(student_id);
CREATE INDEX IF NOT EXISTS idx_requests_student ON public.service_requests(student_id);
CREATE INDEX IF NOT EXISTS idx_notifications_student ON public.notifications(student_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_target ON public.audit_logs(target_table, target_record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON public.user_sessions(token_hash);

-- =============================================================================
-- ส่วนที่ 2: ฟังก์ชันความปลอดภัย PDPA Masking, Session Context, Audit Triggers & RPC
-- =============================================================================

-- 1. ฟังก์ชันปกปิดเลขบัตรประชาชนตามหลัก PDPA (1-xxxx-xxxxx-xx-x)
CREATE OR REPLACE FUNCTION public.fn_mask_citizen_id(p_cid VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
BEGIN
    IF p_cid IS NULL OR LENGTH(TRIM(p_cid)) < 13 THEN
        RETURN 'x-xxxx-xxxxx-xx-x';
    END IF;
    RETURN SUBSTRING(p_cid, 1, 1) || '-xxxx-xxxxx-' || SUBSTRING(p_cid, 11, 2) || '-' || SUBSTRING(p_cid, 13, 1);
END;
$$;

-- ฟังก์ชันอ่าน citizen_id แบบ Masked โดยไม่เปิดสิทธิ์คอลัมน์ดิบให้ anon/authenticated
CREATE OR REPLACE FUNCTION public.fn_get_masked_citizen_id(p_student_id VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_cid TEXT;
BEGIN
    SELECT citizen_id INTO v_cid FROM public.students WHERE student_id = p_student_id;
    RETURN public.fn_mask_citizen_id(v_cid);
END;
$$;

-- 2. ฟังก์ชันตรวจสอบ Session ปัจจุบัน (รองรับทั้ง auth.uid() ของ Supabase Auth และ x-session-token)
CREATE OR REPLACE FUNCTION public.fn_current_actor_id()
RETURNS UUID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_auth_uid UUID;
    v_headers_raw TEXT;
    v_token TEXT;
    v_token_hash TEXT;
    v_user_id UUID;
BEGIN
    BEGIN
        v_auth_uid := auth.uid();
    EXCEPTION WHEN OTHERS THEN
        v_auth_uid := NULL;
    END;

    IF v_auth_uid IS NOT NULL THEN
        RETURN v_auth_uid;
    END IF;

    BEGIN
        v_headers_raw := current_setting('request.headers', true);
        IF v_headers_raw IS NOT NULL AND v_headers_raw <> '' THEN
            v_token := v_headers_raw::jsonb ->> 'x-session-token';
            IF v_token IS NOT NULL AND v_token <> '' THEN
                v_token_hash := encode(digest(v_token, 'sha256'), 'hex');
                SELECT us.user_id INTO v_user_id
                FROM public.user_sessions us
                WHERE us.token_hash = v_token_hash
                  AND us.expires_at > NOW()
                LIMIT 1;
                RETURN v_user_id;
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;

    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_current_actor_role()
RETURNS VARCHAR
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid UUID;
    v_role TEXT;
BEGIN
    v_uid := public.fn_current_actor_id();
    IF v_uid IS NULL THEN
        RETURN NULL;
    END IF;
    SELECT u.role INTO v_role FROM public.users u WHERE u.id = v_uid AND u.is_active = TRUE;
    RETURN v_role;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_current_student_id()
RETURNS VARCHAR
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid UUID;
    v_sid TEXT;
BEGIN
    v_uid := public.fn_current_actor_id();
    IF v_uid IS NULL THEN
        RETURN NULL;
    END IF;
    SELECT s.student_id INTO v_sid FROM public.students s WHERE s.user_id = v_uid;
    RETURN v_sid;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_current_teacher_id()
RETURNS VARCHAR
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_uid UUID;
    v_tid TEXT;
BEGIN
    v_uid := public.fn_current_actor_id();
    IF v_uid IS NULL THEN
        RETURN NULL;
    END IF;
    SELECT t.teacher_id INTO v_tid FROM public.teachers t WHERE t.user_id = v_uid;
    RETURN v_tid;
END;
$$;

-- 3. Trigger คำนวณคะแนนรวมและตัดเกรดอัตโนมัติ (A ถึง F)
CREATE OR REPLACE FUNCTION public.fn_auto_calculate_grade()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    NEW.total_score := COALESCE(NEW.coursework_score, 0) + COALESCE(NEW.midterm_score, 0) + COALESCE(NEW.final_score, 0);
    NEW.updated_at := NOW();

    IF (NEW.total_score > 0 OR NEW.grade_letter IS NULL) THEN
        IF NEW.total_score >= 80 THEN
            NEW.grade_letter := 'A';
            NEW.grade_point := 4.00;
            NEW.grade_display := 'A (4.0)';
            NEW.is_warning := FALSE;
        ELSIF NEW.total_score >= 75 THEN
            NEW.grade_letter := 'B+';
            NEW.grade_point := 3.50;
            NEW.grade_display := 'B+ (3.5)';
            NEW.is_warning := FALSE;
        ELSIF NEW.total_score >= 70 THEN
            NEW.grade_letter := 'B';
            NEW.grade_point := 3.00;
            NEW.grade_display := 'B (3.0)';
            NEW.is_warning := FALSE;
        ELSIF NEW.total_score >= 65 THEN
            NEW.grade_letter := 'C+';
            NEW.grade_point := 2.50;
            NEW.grade_display := 'C+ (2.5) ⚠️';
            NEW.is_warning := TRUE;
        ELSIF NEW.total_score >= 60 THEN
            NEW.grade_letter := 'C';
            NEW.grade_point := 2.00;
            NEW.grade_display := 'C (2.0) ⚠️';
            NEW.is_warning := TRUE;
        ELSIF NEW.total_score >= 55 THEN
            NEW.grade_letter := 'D+';
            NEW.grade_point := 1.50;
            NEW.grade_display := 'D+ (1.5) ⚠️';
            NEW.is_warning := TRUE;
        ELSIF NEW.total_score >= 50 THEN
            NEW.grade_letter := 'D';
            NEW.grade_point := 1.00;
            NEW.grade_display := 'D (1.0) ⚠️';
            NEW.is_warning := TRUE;
        ELSE
            NEW.grade_letter := 'F';
            NEW.grade_point := 0.00;
            NEW.grade_display := 'F (0.0) ⚠️';
            NEW.is_warning := TRUE;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_auto_calculate_grade ON public.enrollments;
CREATE TRIGGER trg_auto_calculate_grade
BEFORE INSERT OR UPDATE OF coursework_score, midterm_score, final_score
ON public.enrollments
FOR EACH ROW
EXECUTE FUNCTION public.fn_auto_calculate_grade();

-- 4. Trigger บันทึก Audit Trail อัตโนมัติเมื่อมีการแก้คะแนน/เกรด หรืออนุมัติคำร้อง
CREATE OR REPLACE FUNCTION public.fn_write_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_actor_id TEXT;
    v_actor_role TEXT;
    v_record_id TEXT;
BEGIN
    v_actor_id := COALESCE(public.fn_current_teacher_id(), public.fn_current_student_id(), public.fn_current_actor_id()::TEXT, 'SYSTEM');
    v_actor_role := COALESCE(public.fn_current_actor_role(), 'system');

    IF TG_TABLE_NAME = 'enrollments' THEN
        v_record_id := NEW.student_id || ':' || NEW.subject_code;
        INSERT INTO public.audit_logs (actor_id, actor_role, action, target_table, target_record_id, old_data, new_data)
        VALUES (
            v_actor_id, v_actor_role, 'UPDATE_GRADE', 'enrollments', v_record_id,
            jsonb_build_object(
                'coursework_score', OLD.coursework_score,
                'midterm_score', OLD.midterm_score,
                'final_score', OLD.final_score,
                'total_score', OLD.total_score,
                'grade_letter', OLD.grade_letter,
                'grade_submit_status', OLD.grade_submit_status
            ),
            jsonb_build_object(
                'coursework_score', NEW.coursework_score,
                'midterm_score', NEW.midterm_score,
                'final_score', NEW.final_score,
                'total_score', NEW.total_score,
                'grade_letter', NEW.grade_letter,
                'grade_submit_status', NEW.grade_submit_status
            )
        );
    ELSIF TG_TABLE_NAME = 'service_requests' THEN
        v_record_id := NEW.request_code;
        INSERT INTO public.audit_logs (actor_id, actor_role, action, target_table, target_record_id, old_data, new_data)
        VALUES (
            v_actor_id, v_actor_role, 'UPDATE_REQUEST_STATUS', 'service_requests', v_record_id,
            jsonb_build_object('status_student', OLD.status_student, 'status_teacher', OLD.status_teacher),
            jsonb_build_object('status_student', NEW.status_student, 'status_teacher', NEW.status_teacher)
        );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_audit_enrollments_changes ON public.enrollments;
CREATE TRIGGER trg_audit_enrollments_changes
AFTER UPDATE OF midterm_score, final_score, coursework_score, grade_submit_status
ON public.enrollments
FOR EACH ROW
EXECUTE FUNCTION public.fn_write_audit_log();

DROP TRIGGER IF EXISTS trg_audit_service_requests_changes ON public.service_requests;
CREATE TRIGGER trg_audit_service_requests_changes
AFTER UPDATE OF status_student, status_teacher
ON public.service_requests
FOR EACH ROW
EXECUTE FUNCTION public.fn_write_audit_log();

-- 5. Stored Function สำหรับตรวจสอบการเข้าสู่ระบบและออก Session Token (bcrypt >= 10)
DROP FUNCTION IF EXISTS public.sp_authenticate_user(TEXT, TEXT);
CREATE OR REPLACE FUNCTION public.sp_authenticate_user(
    p_email TEXT,
    p_password TEXT
)
RETURNS TABLE (
    user_id UUID,
    email VARCHAR,
    role VARCHAR,
    student_id VARCHAR,
    teacher_id VARCHAR,
    display_name VARCHAR,
    subtitle_info VARCHAR,
    gpax NUMERIC,
    current_term_gpa NUMERIC,
    earned_credits INT,
    total_credits_required INT,
    session_token TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_user RECORD;
    v_raw_token TEXT;
    v_token_hash TEXT;
BEGIN
    SELECT
        u.id AS uid,
        u.email AS uemail,
        u.role AS urole,
        s.student_id AS sid,
        t.teacher_id AS tid,
        CAST(
            CASE
                WHEN u.role = 'teacher' THEN COALESCE(t.academic_rank || t.first_name_th || ' ' || t.last_name_th, u.email)
                ELSE COALESCE(s.prefix_th || s.first_name_th || ' ' || s.last_name_th, u.email)
            END AS VARCHAR
        ) AS dname,
        CAST(
            CASE
                WHEN u.role = 'teacher' THEN COALESCE(t.teacher_id || ' • ภาควิชา' || td.name_th, 'อาจารย์')
                ELSE COALESCE(s.student_id || ' • ' || sd.name_th || ' ปี ' || s.year_level, 'นักศึกษา')
            END AS VARCHAR
        ) AS sinfo,
        COALESCE(s.gpax, 0.00) AS sgpax,
        COALESCE(s.current_term_gpa, 0.00) AS sterm_gpa,
        COALESCE(s.earned_credits, 0) AS searned,
        COALESCE(sd.total_credits_required, 132) AS sreq
    INTO v_user
    FROM public.users u
    LEFT JOIN public.students s ON s.user_id = u.id
    LEFT JOIN public.departments sd ON s.department_id = sd.id
    LEFT JOIN public.teachers t ON t.user_id = u.id
    LEFT JOIN public.departments td ON t.department_id = td.id
    WHERE LOWER(TRIM(u.email)) = LOWER(TRIM(p_email))
      AND u.is_active = TRUE
      AND u.password_hash = crypt(p_password, u.password_hash)
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- สร้าง Cryptographically Secure Session Token (เก็บค่า Hash SHA-256 ลงฐานข้อมูล)
    v_raw_token := encode(gen_random_bytes(32), 'hex');
    v_token_hash := encode(digest(v_raw_token, 'sha256'), 'hex');

    DELETE FROM public.user_sessions WHERE expires_at < NOW();

    INSERT INTO public.user_sessions (user_id, token_hash, role, student_id, teacher_id, expires_at)
    VALUES (v_user.uid, v_token_hash, v_user.urole, v_user.sid, v_user.tid, NOW() + INTERVAL '12 hours');

    UPDATE public.users SET last_login_at = NOW() WHERE id = v_user.uid;

    INSERT INTO public.audit_logs (actor_id, actor_role, action, target_table, target_record_id, new_data)
    VALUES (
        COALESCE(v_user.sid, v_user.tid, v_user.uid::TEXT),
        v_user.urole,
        'USER_LOGIN',
        'users',
        v_user.uid::TEXT,
        jsonb_build_object('email', v_user.uemail, 'login_at', NOW())
    );

    RETURN QUERY SELECT
        v_user.uid,
        v_user.uemail,
        v_user.urole,
        v_user.sid,
        v_user.tid,
        v_user.dname,
        v_user.sinfo,
        v_user.sgpax,
        v_user.sterm_gpa,
        v_user.searned,
        v_user.sreq,
        v_raw_token;
END;
$$;

-- 6. Stored Procedure เช็กชื่อเข้าเรียนด้วยเวลา Server/Database จริง (ป้องกันปรับเวลามือถือโกง & เช็กซ้ำ)
CREATE OR REPLACE FUNCTION public.sp_check_in_attendance(
    p_session_id UUID,
    p_student_id VARCHAR DEFAULT NULL,
    p_method VARCHAR DEFAULT 'qr_scan'
)
RETURNS TABLE (
    student_id VARCHAR,
    status VARCHAR,
    check_in_time VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_actor_sid VARCHAR(15);
    v_target_sid VARCHAR(15);
    v_session RECORD;
    v_existing_status TEXT;
    v_now_bkk TIMESTAMP;
    v_time_str VARCHAR(10);
    v_new_status VARCHAR(15);
BEGIN
    v_actor_sid := public.fn_current_student_id();

    -- Anti-IDOR: หากล็อกอินผ่าน Session นักศึกษา ห้ามส่ง student_id ของคนอื่น
    IF v_actor_sid IS NOT NULL THEN
        IF p_student_id IS NOT NULL AND p_student_id <> v_actor_sid THEN
            RAISE EXCEPTION 'Forbidden: IDOR check-in blocked';
        END IF;
        v_target_sid := v_actor_sid;
    ELSE
        IF p_student_id IS NULL THEN
            RAISE EXCEPTION 'Unauthorized: Missing student identity';
        END IF;
        v_target_sid := p_student_id;
    END IF;

    IF p_method NOT IN ('qr_scan', 'room_code') THEN
        p_method := 'qr_scan';
    END IF;

    -- Lock แถวคาบเช็กชื่อเพื่อป้องกัน Race Condition
    SELECT * INTO v_session
    FROM public.attendance_sessions s
    WHERE s.id = p_session_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Attendance session not found';
    END IF;

    IF v_session.is_open IS NOT TRUE THEN
        RAISE EXCEPTION 'Attendance room is closed';
    END IF;

    -- ใช้เวลาจาก Database Server เท่านั้น (Asia/Bangkok)
    v_now_bkk := NOW() AT TIME ZONE 'Asia/Bangkok';
    v_time_str := TO_CHAR(v_now_bkk, 'HH24:MI');

    -- ป้องกันการเช็กชื่อซ้ำหากเช็กไปแล้ว
    SELECT ar.status INTO v_existing_status
    FROM public.attendance_records ar
    WHERE ar.session_id = p_session_id AND ar.student_id = v_target_sid;

    IF v_existing_status IN ('present', 'late') THEN
        RAISE EXCEPTION 'Duplicate check-in is not allowed';
    END IF;

    -- ตัดสินสถานะ มาตรงเวลา / มาสาย โดยเทียบกับเวลาที่เปิดห้องของ Server (+15 นาที)
    IF NOW() > (v_session.opened_at + INTERVAL '15 minutes') THEN
        v_new_status := 'late';
    ELSE
        v_new_status := 'present';
    END IF;

    INSERT INTO public.attendance_records (session_id, student_id, status, check_in_time, check_in_method, note)
    VALUES (p_session_id, v_target_sid, v_new_status, v_time_str, p_method, 'เช็คชื่อผ่านเวลา Server: ' || v_time_str)
    ON CONFLICT (session_id, student_id)
    DO UPDATE SET
        status = EXCLUDED.status,
        check_in_time = EXCLUDED.check_in_time,
        check_in_method = EXCLUDED.check_in_method,
        note = EXCLUDED.note;

    UPDATE public.attendance_sessions
    SET present_count = (
        SELECT COUNT(*) FROM public.attendance_records ar
        WHERE ar.session_id = p_session_id AND ar.status IN ('present', 'late')
    )
    WHERE id = p_session_id;

    INSERT INTO public.audit_logs (actor_id, actor_role, action, target_table, target_record_id, new_data)
    VALUES (
        v_target_sid, 'student', 'CHECK_IN', 'attendance_records',
        p_session_id::TEXT || ':' || v_target_sid,
        jsonb_build_object('status', v_new_status, 'server_time', v_time_str, 'method', p_method)
    );

    RETURN QUERY SELECT v_target_sid, v_new_status, v_time_str;
END;
$$;

-- 7. Stored Procedure ส่งการบ้าน (ตรวจสอบไฟล์ นามสกุล MIME, ป้องกัน Path Traversal, เทียบเวลา Server)
CREATE OR REPLACE FUNCTION public.sp_submit_assignment(
    p_assignment_id UUID,
    p_student_id VARCHAR DEFAULT NULL,
    p_original_filename VARCHAR DEFAULT 'homework.pdf',
    p_file_size_bytes INT DEFAULT 256000,
    p_mime_type VARCHAR DEFAULT 'application/pdf'
)
RETURNS TABLE (
    submission_id UUID,
    saved_file_name VARCHAR,
    submission_status VARCHAR,
    submitted_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_actor_sid VARCHAR(15);
    v_target_sid VARCHAR(15);
    v_due_date TIMESTAMPTZ;
    v_ext VARCHAR(20);
    v_safe_name VARCHAR(200);
    v_file_url TEXT;
    v_status VARCHAR(20);
    v_sub_id UUID;
    v_sub_at TIMESTAMPTZ;
BEGIN
    v_actor_sid := public.fn_current_student_id();

    IF v_actor_sid IS NOT NULL THEN
        IF p_student_id IS NOT NULL AND p_student_id <> v_actor_sid THEN
            RAISE EXCEPTION 'Forbidden: IDOR assignment submission blocked';
        END IF;
        v_target_sid := v_actor_sid;
    ELSE
        IF p_student_id IS NULL THEN
            RAISE EXCEPTION 'Unauthorized: Missing student identity';
        END IF;
        v_target_sid := p_student_id;
    END IF;

    -- ตรวจสอบขนาดไฟล์ไม่เกิน 5 MB (5,242,880 bytes)
    IF p_file_size_bytes IS NULL OR p_file_size_bytes <= 0 OR p_file_size_bytes > 5242880 THEN
        RAISE EXCEPTION 'File size must be between 1 byte and 5 MB';
    END IF;

    -- ตรวจสอบ MIME Type ที่อนุญาตเท่านั้น
    IF p_mime_type NOT IN (
        'application/pdf',
        'image/png',
        'image/jpeg',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ) THEN
        RAISE EXCEPTION 'Disallowed MIME type: %', p_mime_type;
    END IF;

    -- ตรวจสอบนามสกุลไฟล์ (ห้าม .exe, .sh, .js, .php และป้องกัน Path Traversal)
    v_ext := LOWER(COALESCE(SUBSTRING(p_original_filename FROM '(\.[a-zA-Z0-9]+)$'), ''));
    IF v_ext NOT IN ('.pdf', '.png', '.jpg', '.jpeg', '.docx') THEN
        RAISE EXCEPTION 'Disallowed file extension: %', v_ext;
    END IF;

    SELECT a.due_date INTO v_due_date FROM public.assignments a WHERE a.id = p_assignment_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Assignment not found';
    END IF;

    -- ตั้งชื่อไฟล์ใหม่ด้วย รหัส นศ. + Timestamp + UUID สุ่ม ป้องกัน Path Traversal และชื่อซ้ำ
    v_safe_name := v_target_sid || '_' || EXTRACT(EPOCH FROM NOW())::BIGINT || '_' || SUBSTRING(uuid_generate_v4()::TEXT, 1, 8) || v_ext;
    v_file_url := '/storage/v1/object/authenticated/submissions/' || v_safe_name;

    -- ตัดสินสถานะ ส่งตรงเวลา / ส่งสาย ด้วยเวลาของ Database Server เท่านั้น
    v_status := CASE WHEN NOW() > v_due_date THEN 'late' ELSE 'submitted' END;

    INSERT INTO public.assignment_submissions (
        assignment_id, student_id, file_url, file_name, file_size_bytes, mime_type, status, submitted_at
    )
    VALUES (
        p_assignment_id, v_target_sid, v_file_url, v_safe_name, p_file_size_bytes, p_mime_type, v_status, NOW()
    )
    ON CONFLICT (assignment_id, student_id)
    DO UPDATE SET
        file_url = EXCLUDED.file_url,
        file_name = EXCLUDED.file_name,
        file_size_bytes = EXCLUDED.file_size_bytes,
        mime_type = EXCLUDED.mime_type,
        status = EXCLUDED.status,
        submitted_at = NOW()
    RETURNING id, assignment_submissions.submitted_at INTO v_sub_id, v_sub_at;

    INSERT INTO public.audit_logs (actor_id, actor_role, action, target_table, target_record_id, new_data)
    VALUES (
        v_target_sid, 'student', 'SUBMIT_ASSIGNMENT', 'assignment_submissions',
        v_sub_id::TEXT,
        jsonb_build_object('file_name', v_safe_name, 'mime_type', p_mime_type, 'size', p_file_size_bytes, 'status', v_status)
    );

    RETURN QUERY SELECT v_sub_id, v_safe_name, v_status, v_sub_at;
END;
$$;

-- 8. Stored Procedure สำหรับอาจารย์บันทึก/ส่งเกรดทั้งห้องแบบ Transaction + คำนวณ GPAX
CREATE OR REPLACE FUNCTION public.sp_submit_section_grades(
    p_teacher_id VARCHAR,
    p_subject_code VARCHAR,
    p_grades JSONB,
    p_submit_final BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_actor_role TEXT;
    v_actor_tid TEXT;
    v_item JSONB;
    v_sid TEXT;
    v_mid INT;
    v_fin INT;
    v_cw INT;
    v_updated_count INT := 0;
BEGIN
    v_actor_role := public.fn_current_actor_role();
    v_actor_tid := public.fn_current_teacher_id();

    -- Anti-IDOR & RBAC: เฉพาะอาจารย์หรือแอดมินเท่านั้น
    IF v_actor_role IS NOT NULL AND v_actor_role NOT IN ('teacher', 'admin') THEN
        RAISE EXCEPTION 'Forbidden: Only teachers or admins can submit grades';
    END IF;
    IF v_actor_tid IS NOT NULL AND p_teacher_id IS NOT NULL AND p_teacher_id <> v_actor_tid THEN
        RAISE EXCEPTION 'Forbidden: Cannot submit grades on behalf of another teacher';
    END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_grades)
    LOOP
        v_sid := v_item ->> 'student_id';
        v_mid := (v_item ->> 'midterm')::INT;
        v_fin := (v_item ->> 'final_exam')::INT;
        v_cw := (v_item ->> 'coursework')::INT;

        -- ตรวจสอบขอบเขตคะแนน Input Validation
        IF v_mid < 0 OR v_mid > 30 OR v_fin < 0 OR v_fin > 40 OR v_cw < 0 OR v_cw > 30 THEN
            RAISE EXCEPTION 'Invalid score bounds for student %', v_sid;
        END IF;

        UPDATE public.enrollments e
        SET
            midterm_score = v_mid,
            final_score = v_fin,
            coursework_score = v_cw,
            grade_submit_status = CASE WHEN p_submit_final THEN 'ส่งแล้ว' ELSE e.grade_submit_status END
        WHERE e.student_id = v_sid
          AND e.subject_code = p_subject_code;

        -- อัปเดต GPAX ใหม่ของนักศึกษาให้สอดคล้องใน Transaction เดียวกัน
        UPDATE public.students s
        SET gpax = COALESCE((
            SELECT ROUND(AVG(e2.grade_point), 2)
            FROM public.enrollments e2
            WHERE e2.student_id = v_sid AND e2.grade_point IS NOT NULL
        ), s.gpax)
        WHERE s.student_id = v_sid;

        v_updated_count := v_updated_count + 1;
    END LOOP;

    RETURN v_updated_count;
END;
$$;

-- =============================================================================
-- ส่วนที่ 3: Views สำเร็จรูป 6 Views (PDPA Masked & security_invoker = true)
-- =============================================================================

-- View 1: ข้อมูลโปรไฟล์นักศึกษาฉบับเต็ม (ปิดบังเลขบัตรประชาชนตามหลัก PDPA)
CREATE OR REPLACE VIEW public.v_student_profiles
WITH (security_invoker = true)
AS
SELECT
    s.student_id,
    u.email AS university_email,
    s.prefix_th,
    s.first_name_th,
    s.last_name_th,
    (s.prefix_th || s.first_name_th || ' ' || s.last_name_th) AS full_name_th,
    (s.first_name_en || ' ' || s.last_name_en) AS full_name_en,
    public.fn_get_masked_citizen_id(s.student_id) AS citizen_id,
    s.birth_date,
    s.blood_group,
    s.face_photo_url,
    s.student_card_url,
    f.code AS faculty_code,
    f.name_th AS faculty_name_th,
    f.campus,
    d.code AS department_code,
    d.name_th AS department_name_th,
    d.degree_name_th,
    d.total_credits_required,
    s.year_level,
    s.enrollment_year,
    s.education_status,
    s.gpax,
    s.current_term_gpa,
    s.earned_credits,
    (s.earned_credits || '/' || d.total_credits_required) AS credits_progress_label,
    (t.academic_rank || t.first_name_th || ' ' || t.last_name_th) AS advisor_name,
    s.phone,
    s.personal_email,
    s.line_id,
    s.current_address,
    s.permanent_address,
    s.subdistrict,
    s.district,
    s.province,
    s.postal_code,
    s.emergency_contact_name,
    s.emergency_contact_relation,
    s.emergency_contact_phone
FROM public.students s
JOIN public.users u ON s.user_id = u.id
JOIN public.faculties f ON s.faculty_id = f.id
JOIN public.departments d ON s.department_id = d.id
LEFT JOIN public.teachers t ON s.advisor_id = t.teacher_id;

-- View 2: ตารางเรียนและรายวิชาของนักศึกษาในเทอมปัจจุบัน
CREATE OR REPLACE VIEW public.v_student_timetable
WITH (security_invoker = true)
AS
SELECT
    e.student_id,
    tm.term_label,
    sub.subject_code AS code,
    sub.name_th AS name,
    sub.credits,
    cs.section_number AS section,
    cs.day_of_week,
    cs.time_display AS time,
    cs.room,
    COALESCE(t.academic_rank || t.first_name_th, '-') AS teacher,
    COALESCE(cs.status_student_badge, '-') AS status,
    COALESCE(cs.course_summary_student, '-') AS course_summary,
    cs.course_progress AS progress,
    e.pending_assignments,
    e.quiz_score,
    e.lab_score,
    e.attendance_rate,
    sub.is_lab
FROM public.enrollments e
JOIN public.course_sections cs ON e.section_id = cs.id
JOIN public.subjects sub ON e.subject_code = sub.subject_code
JOIN public.academic_terms tm ON e.term_id = tm.id
LEFT JOIN public.teachers t ON cs.teacher_id = t.teacher_id
WHERE tm.is_current = TRUE;

-- View 3: ตารางสอนและรายวิชาของอาจารย์ในเทอมปัจจุบัน
CREATE OR REPLACE VIEW public.v_teacher_timetable
WITH (security_invoker = true)
AS
SELECT
    cs.teacher_id,
    tm.term_label,
    sub.subject_code AS code,
    ('สอน ' || sub.name_th) AS timetable_name,
    sub.name_th AS course_name,
    cs.section_number AS section,
    cs.day_of_week,
    cs.time_display AS time,
    cs.room,
    (cs.enrolled_count || ' คน') AS student_count_label,
    cs.enrolled_count,
    cs.max_students,
    COALESCE(cs.status_teacher_badge, '+ เปิดเช็คชื่อ') AS status,
    COALESCE(cs.course_summary_teacher, '') AS course_summary,
    cs.course_progress AS progress
FROM public.course_sections cs
JOIN public.subjects sub ON cs.subject_code = sub.subject_code
JOIN public.academic_terms tm ON cs.term_id = tm.id
WHERE tm.is_current = TRUE;

-- View 4: ใบกรอกคะแนนและตัดเกรดสำหรับอาจารย์ (GradeSubmitScreen)
CREATE OR REPLACE VIEW public.v_teacher_grade_sheet
WITH (security_invoker = true)
AS
SELECT
    e.id AS enrollment_id,
    cs.id AS section_id,
    cs.subject_code,
    sub.name_th AS subject_name,
    cs.section_number,
    e.student_id AS id,
    s.first_name_th AS name,
    (s.prefix_th || s.first_name_th || ' ' || s.last_name_th) AS full_name,
    e.midterm_score AS midterm,
    e.final_score AS final_exam,
    e.coursework_score AS coursework,
    e.total_score AS total,
    e.grade_letter,
    e.grade_submit_status AS status
FROM public.enrollments e
JOIN public.students s ON e.student_id = s.student_id
JOIN public.course_sections cs ON e.section_id = cs.id
JOIN public.subjects sub ON cs.subject_code = sub.subject_code
JOIN public.academic_terms tm ON e.term_id = tm.id
WHERE tm.is_current = TRUE
ORDER BY e.student_id ASC;

-- View 5: ผลการเรียนรายวิชาของนักศึกษา (GradesScreen)
CREATE OR REPLACE VIEW public.v_student_grades
WITH (security_invoker = true)
AS
SELECT
    e.student_id,
    tm.term_label,
    tm.is_current,
    sub.subject_code,
    sub.name_th AS subject_name,
    sub.credits,
    COALESCE(e.grade_display, e.grade_letter || ' (' || e.grade_point || ')') AS letter,
    COALESCE(e.grade_point, 0.00) AS score,
    e.total_score,
    e.is_warning,
    e.grade_submit_status
FROM public.enrollments e
JOIN public.subjects sub ON e.subject_code = sub.subject_code
JOIN public.academic_terms tm ON e.term_id = tm.id
ORDER BY tm.academic_year DESC, tm.semester DESC, sub.subject_code ASC;

-- View 6: ประวัติการชำระเงินค่าเทอมและใบเสร็จรับเงินของนักศึกษา (e-Receipt)
CREATE OR REPLACE VIEW public.v_student_financial_records
WITH (security_invoker = true)
AS
SELECT
    inv.invoice_no,
    inv.student_id,
    (s.prefix_th || s.first_name_th || ' ' || s.last_name_th) AS student_name,
    tm.term_label,
    inv.tuition_fee,
    inv.university_fee,
    inv.lab_equipment_fee,
    inv.scholarship_discount,
    inv.total_amount,
    inv.due_date,
    inv.payment_status,
    inv.invoice_pdf_url,
    rcp.receipt_no,
    rcp.payment_method,
    rcp.bank_name,
    rcp.transaction_ref,
    rcp.amount_paid,
    rcp.paid_at,
    rcp.slip_image_url,
    rcp.receipt_pdf_url,
    rcp.finance_officer_name
FROM public.tuition_invoices inv
JOIN public.students s ON inv.student_id = s.student_id
JOIN public.academic_terms tm ON inv.term_id = tm.id
LEFT JOIN public.payment_receipts rcp ON inv.invoice_no = rcp.invoice_no
ORDER BY inv.due_date DESC;

-- =============================================================================
-- ส่วนที่ 4: ตั้งค่า Supabase Storage Buckets (Private สำหรับ submissions & receipts)
-- =============================================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'buckets') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES
            ('avatars', 'avatars', true, 5242880, ARRAY['image/png', 'image/jpeg']),
            ('materials', 'materials', true, 10485760, ARRAY['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
            ('submissions', 'submissions', false, 5242880, ARRAY['application/pdf', 'image/png', 'image/jpeg', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
            ('receipts', 'receipts', false, 5242880, ARRAY['application/pdf', 'image/png', 'image/jpeg'])
        ON CONFLICT (id) DO UPDATE SET
            public = EXCLUDED.public,
            file_size_limit = EXCLUDED.file_size_limit,
            allowed_mime_types = EXCLUDED.allowed_mime_types;
    END IF;
END $$;

-- ป้องกันคนนอกเข้าถึงไฟล์ใน Private Buckets (submissions & receipts)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'objects') THEN
        DROP POLICY IF EXISTS "rmutp_private_submissions_select" ON storage.objects;
        CREATE POLICY "rmutp_private_submissions_select" ON storage.objects
            FOR SELECT TO authenticated
            USING (
                bucket_id IN ('submissions', 'receipts')
                AND (
                    owner = auth.uid()
                    OR public.fn_current_actor_role() IN ('teacher', 'admin')
                )
            );
    END IF;
END $$;

-- =============================================================================
-- ส่วนที่ 5: ข้อมูลสมมติระดับมหาวิทยาลัย (Seed Mock Data - bcrypt Salt Rounds = 10)
-- =============================================================================

-- 1. คณะวิชา (4 คณะหลักของ มทร.พระนคร)
INSERT INTO public.faculties (id, code, name_th, name_en, campus, building, phone, website_url)
VALUES
    ('11111111-1111-1111-1111-111111111101', 'ENG', 'คณะวิศวกรรมศาสตร์', 'Faculty of Engineering', 'ศูนย์พระนครเหนือ', 'อาคาร 16 (ตึกวิศวกรรมศาสตร์)', '02-665-3777 ต่อ 7000', 'https://eng.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111102', 'BUS', 'คณะบริหารธุรกิจ', 'Faculty of Business Administration', 'ศูนย์พณิชยการพระนคร', 'อาคาร 1', '02-665-3555', 'https://bus.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111103', 'SCI', 'คณะวิทยาศาสตร์และเทคโนโลยี', 'Faculty of Science and Technology', 'ศูนย์พระนครเหนือ', 'อาคารเอนกประสงค์', '02-665-3777 ต่อ 6500', 'https://sci.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111104', 'ARC', 'คณะสถาปัตยกรรมศาสตร์และการออกแบบ', 'Faculty of Architecture and Design', 'ศูนย์เทเวศร์', 'อาคารออกแบบ', '02-665-3777 ต่อ 5000', 'https://arch.rmutp.ac.th')
ON CONFLICT (code) DO NOTHING;

-- 2. ภาควิชา / สาขาวิชา (6 สาขา)
INSERT INTO public.departments (id, faculty_id, code, name_th, name_en, degree_name_th, total_credits_required)
VALUES
    ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'ENGCE', 'วิศวกรรมคอมพิวเตอร์', 'Computer Engineering', 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)', 132),
    ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111101', 'ENGEE', 'วิศวกรรมไฟฟ้า', 'Electrical Engineering', 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)', 135),
    ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111101', 'ENGIE', 'วิศวกรรมอุตสาหการ', 'Industrial Engineering', 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)', 132),
    ('22222222-2222-2222-2222-222222222204', '11111111-1111-1111-1111-111111111102', 'BUSIS', 'ระบบสารสนเทศทางธุรกิจ', 'Business Information Systems', 'บริหารธุรกิจบัณฑิต (บธ.บ.)', 126),
    ('22222222-2222-2222-2222-222222222205', '11111111-1111-1111-1111-111111111103', 'SCICS', 'วิทยาการคอมพิวเตอร์', 'Computer Science', 'วิทยาศาสตรบัณฑิต (วท.บ.)', 128),
    ('22222222-2222-2222-2222-222222222206', '11111111-1111-1111-1111-111111111103', 'SCIDS', 'วิทยาการข้อมูลและสารสนเทศ', 'Data Science and Information', 'วิทยาศาสตรบัณฑิต (วท.บ.)', 128)
ON CONFLICT (code) DO NOTHING;

-- 3. หลักสูตรการศึกษา (Curriculums)
INSERT INTO public.curriculums (id, department_id, curriculum_code, name_th, revision_year, total_credits)
VALUES
    ('29999999-2999-2999-2999-299999999901', '22222222-2222-2222-2222-222222222201', 'B.Eng-CE-2565', 'หลักสูตรวิศวกรรมศาสตรบัณฑิต สาขาวิชาวิศวกรรมคอมพิวเตอร์ (หลักสูตรปรับปรุง พ.ศ. 2565)', 2565, 132),
    ('29999999-2999-2999-2999-299999999902', '22222222-2222-2222-2222-222222222205', 'B.Sc-CS-2565', 'หลักสูตรวิทยาศาสตรบัณฑิต สาขาวิชาวิทยาการคอมพิวเตอร์ (พ.ศ. 2565)', 2565, 128)
ON CONFLICT (curriculum_code) DO NOTHING;

-- 4. อาคารและห้องเรียน (Buildings & Rooms)
INSERT INTO public.buildings_rooms (room_code, building_no, building_name_th, campus, floor_no, room_type, capacity)
VALUES
    ('ห้อง 1604', '16', 'อาคารวิศวกรรมศาสตร์ 16', 'ศูนย์พระนครเหนือ', 6, 'lecture', 45),
    ('ห้อง 1602', '16', 'อาคารวิศวกรรมศาสตร์ 16', 'ศูนย์พระนครเหนือ', 6, 'lecture', 45),
    ('ห้อง 1605', '16', 'อาคารวิศวกรรมศาสตร์ 16', 'ศูนย์พระนครเหนือ', 6, 'lecture', 45),
    ('Lab 1502', '15', 'อาคารปฏิบัติการคอมพิวเตอร์และเครือข่าย 15', 'ศูนย์พระนครเหนือ', 5, 'computer_lab', 40),
    ('Lab 1504', '15', 'อาคารปฏิบัติการคอมพิวเตอร์และเครือข่าย 15', 'ศูนย์พระนครเหนือ', 5, 'computer_lab', 40),
    ('ห้อง 1201', '12', 'อาคารเรียนรวมวิทยาศาสตร์', 'ศูนย์พระนครเหนือ', 2, 'lecture', 60),
    ('ออนไลน์ MS Teams', 'ONLINE', 'ระบบห้องเรียนออนไลน์ Microsoft Teams', 'ทุกศูนย์พื้นที่', 1, 'online', 200)
ON CONFLICT (room_code) DO NOTHING;

-- 5. ปีการศึกษาและภาคเรียน (Academic Terms)
INSERT INTO public.academic_terms (id, academic_year, semester, term_label, start_date, end_date, midterm_start_date, midterm_end_date, final_start_date, final_end_date, grade_submit_deadline, is_current)
VALUES
    ('33333333-3333-3333-3333-333333333301', 2568, 2, '2/2568', '2025-11-15', '2026-03-31', '2026-01-12', '2026-01-16', '2026-03-16', '2026-03-27', '2026-04-05', FALSE),
    ('33333333-3333-3333-3333-333333333302', 2569, 1, '1/2569', '2026-06-15', '2026-10-31', '2026-10-13', '2026-10-17', '2026-10-26', '2026-10-30', '2026-09-30', TRUE)
ON CONFLICT (academic_year, semester) DO NOTHING;

-- 6. ปฏิทินการศึกษา (Academic Calendar Events)
DELETE FROM public.academic_calendar_events WHERE term_id = '33333333-3333-3333-3333-333333333302';
INSERT INTO public.academic_calendar_events (term_id, title, date_display, event_type, start_date, end_date, description)
VALUES
    ('33333333-3333-3333-3333-333333333302', 'หมดเขตส่ง HW6', '23 ก.ย.', 'deadline', '2026-09-23', '2026-09-23', 'กำหนดส่งการบ้าน HW6 วิชา ENGCE302 ระบบฐานข้อมูล ภายในเวลา 23:59 น.'),
    ('33333333-3333-3333-3333-333333333302', 'ปิดรับทุน / ถอนรายวิชา', '30 ก.ย.', 'scholarship', '2026-09-30', '2026-09-30', 'วันสุดท้ายของการยื่นขอทุนเรียนดีคณะวิศวฯ และการถอนรายวิชาติด W'),
    ('33333333-3333-3333-3333-333333333302', 'สัมภาษณ์สหกิจ', '5 ต.ค.', 'coop', '2026-10-05', '2026-10-05', 'สัมภาษณ์นักศึกษาสหกิจศึกษา ณ ศูนย์สหกิจศึกษาและพัฒนาอาชีพ'),
    ('33333333-3333-3333-3333-333333333302', 'สอบกลางภาค', '13–17 ต.ค.', 'exam', '2026-10-13', '2026-10-17', 'สัปดาห์การสอบกลางภาคเรียนที่ 1 ปีการศึกษา 2569');

-- 7. บัญชีผู้ใช้ (Users - รหัสผ่านทุกคนคือ password123 เข้ารหัสด้วย bcrypt Salt Rounds = 10)
INSERT INTO public.users (id, email, password_hash, role, preferred_language, notification_enabled)
VALUES
    ('44444444-4444-4444-4444-444444444401', 'surachai.w@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444402', 'naphat.c@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444403', 'kittipong.t@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444404', 'praewpan.s@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444411', 's650602001@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444412', 's650602002@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444413', 's650602003@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444414', 's650602004@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444415', 's650602005@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444416', 's650602006@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444417', 's650602007@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444418', 's650602008@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444419', 's650602009@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444420', 's650602010@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444421', 's650602011@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444422', 's650602012@rmutp.ac.th', crypt('password123', gen_salt('bf', 10)), 'student', 'th', TRUE)
ON CONFLICT (email) DO NOTHING;

-- 8. ข้อมูลอาจารย์ (Teachers)
INSERT INTO public.teachers (teacher_id, user_id, academic_rank, first_name_th, last_name_th, first_name_en, last_name_en, face_photo_url, faculty_id, department_id, office_room, phone, line_id)
VALUES
    ('T-1024', '44444444-4444-4444-4444-444444444401', 'อ.', 'สุรชัย', 'วงศ์ใหญ่', 'Surachai', 'Wongyai', 'https://ui-avatars.com/api/?name=Surachai+W&background=652D91&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'ห้องพักอาจารย์ 1608', '081-234-5678', '@aj_surachai'),
    ('T-1025', '44444444-4444-4444-4444-444444444402', 'ผศ.', 'นภัส', 'เจริญผล', 'Naphat', 'Charoenphon', 'https://ui-avatars.com/api/?name=Naphat+C&background=652D91&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'ห้องพักอาจารย์ 1504', '089-876-5432', '@aj_naphat'),
    ('T-1026', '44444444-4444-4444-4444-444444444403', 'รศ.ดร.', 'กิตติพงศ์', 'ธีรเมธ', 'Kittipong', 'Theerameth', 'https://ui-avatars.com/api/?name=Kittipong+T&background=2A114B&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'ห้องพักอาจารย์ 1610', '081-555-7890', '@aj_kittipong'),
    ('T-1027', '44444444-4444-4444-4444-444444444404', 'อ.ดร.', 'แพรวพรรณ', 'ศิริกุล', 'Praewpan', 'Sirikul', 'https://ui-avatars.com/api/?name=Praewpan+S&background=431B6E&color=fff&size=256', '11111111-1111-1111-1111-111111111103', '22222222-2222-2222-2222-222222222205', 'ห้องพักอาจารย์ SC-302', '086-444-3210', '@aj_praewpan')
ON CONFLICT (teacher_id) DO NOTHING;

-- 9. ข้อมูลประวัตินักศึกษาเชิงลึก 12 คน (Students)
INSERT INTO public.students (
    student_id, user_id, prefix_th, first_name_th, last_name_th, first_name_en, last_name_en,
    citizen_id, birth_date, gender, blood_group, face_photo_url, student_card_url,
    faculty_id, department_id, curriculum_id, advisor_id, enrollment_year, year_level, education_status,
    gpax, current_term_gpa, earned_credits,
    phone, personal_email, line_id, current_address, permanent_address,
    subdistrict, district, province, postal_code,
    emergency_contact_name, emergency_contact_relation, emergency_contact_phone
)
VALUES
    ('650602001', '44444444-4444-4444-4444-444444444411', 'น.ส.', 'มินตรา', 'ใจดี', 'Mintra', 'Jaidee', '1100501234501', '2004-05-14', 'female', 'O', 'https://ui-avatars.com/api/?name=Mintra+J&background=F6DC04&color=2A114B&size=256', '/storage/v1/object/public/avatars/card_650602001.png', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.42, 3.55, 87, '092-345-6789', 'mintra.jaidee@gmail.com', 'mintra_ce65', 'หอพักนักศึกษาเคียงมอ ห้อง 402 ซ.วงศ์สว่าง 11', '99/12 หมู่ 4 ถ.พิบูลสงคราม', 'วงศ์สว่าง', 'บางซื่อ', 'กรุงเทพมหานคร', '10800', 'นางสมศรี ใจดี', 'มารดา', '081-999-8877'),
    ('650602002', '44444444-4444-4444-4444-444444444412', 'นาย', 'ภูริ', 'พัฒนากุล', 'Phuri', 'Phattanakul', '1100501234502', '2004-08-21', 'male', 'A', 'https://ui-avatars.com/api/?name=Phuri+P&background=652D91&color=fff&size=256', '/storage/v1/object/public/avatars/card_650602002.png', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.15, 3.20, 87, '095-111-2233', 'phuri.dev@gmail.com', 'phuri_ce65', 'คอนโดเดอะทรี อินเตอร์เชนจ์ ชั้น 12', '45/8 ถ.ประชาราษฎร์สาย 1', 'บางซื่อ', 'บางซื่อ', 'กรุงเทพมหานคร', '10800', 'นายวิชัย พัฒนากุล', 'บิดา', '086-555-4433'),
    ('650602003', '44444444-4444-4444-4444-444444444413', 'น.ส.', 'กันยา', 'รัตนโชติ', 'Kanya', 'Rattanachot', '1100501234503', '2004-11-03', 'female', 'B', 'https://ui-avatars.com/api/?name=Kanya+R&background=E91E63&color=fff&size=256', '/storage/v1/object/public/avatars/card_650602003.png', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 2.65, 2.75, 84, '098-765-4321', 'kanya.rat@gmail.com', 'kanya_ce65', '120/5 ซ.จรัญสนิทวงศ์ 96/1', '120/5 ซ.จรัญสนิทวงศ์ 96/1', 'บางอ้อ', 'บางพลัด', 'กรุงเทพมหานคร', '10700', 'นางกัลยา รัตนโชติ', 'มารดา', '089-123-4567'),
    ('650602004', '44444444-4444-4444-4444-444444444414', 'นาย', 'ธนภัทร', 'ศรีสุวรรณ', 'Thanaphat', 'Srisuwan', '1100501234504', '2004-02-19', 'male', 'O', 'https://ui-avatars.com/api/?name=Thanaphat+S&background=1E88E5&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.68, 3.75, 87, '081-222-3344', 'thanaphat.s@gmail.com', 'thana_ce65', '88/4 ซ.วงศ์สว่าง 7', '88/4 ซ.วงศ์สว่าง 7', 'วงศ์สว่าง', 'บางซื่อ', 'กรุงเทพมหานคร', '10800', 'นายสมชาย ศรีสุวรรณ', 'บิดา', '081-222-0000'),
    ('650602005', '44444444-4444-4444-4444-444444444415', 'น.ส.', 'พิมชนก', 'วงศ์สวัสดิ์', 'Pimchanok', 'Wongsawat', '1100501234505', '2004-04-10', 'female', 'A', 'https://ui-avatars.com/api/?name=Pimchanok+W&background=8E24AA&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.50, 3.60, 87, '082-333-4455', 'pimchanok.w@gmail.com', 'pim_ce65', '42/1 ถ.กรุงเทพ-นนทบุรี', '42/1 ถ.กรุงเทพ-นนทบุรี', 'บางซื่อ', 'บางซื่อ', 'กรุงเทพมหานคร', '10800', 'นางปราณี วงศ์สวัสดิ์', 'มารดา', '082-333-0000'),
    ('650602006', '44444444-4444-4444-4444-444444444416', 'นาย', 'ณัฐวุฒิ', 'เจริญสุข', 'Nattawut', 'Charoensuk', '1100501234506', '2004-07-25', 'male', 'AB', 'https://ui-avatars.com/api/?name=Nattawut+C&background=00897B&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 2.95, 3.00, 87, '083-444-5566', 'nattawut.c@gmail.com', 'nat_ce65', '15/9 ถ.ติวานนท์', '15/9 ถ.ติวานนท์', 'ตลาดขวัญ', 'เมืองนนทบุรี', 'นนทบุรี', '11000', 'นายเจริญ เจริญสุข', 'บิดา', '083-444-0000'),
    ('650602007', '44444444-4444-4444-4444-444444444417', 'น.ส.', 'ชลธิชา', 'อภิรักษ์', 'Chonthicha', 'Apirak', '1100501234507', '2004-09-12', 'female', 'B', 'https://ui-avatars.com/api/?name=Chonthicha+A&background=F4511E&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 3.25, 3.30, 87, '084-555-6677', 'chonthicha.a@gmail.com', 'chon_ce65', '77/3 ถ.นครอินทร์', '77/3 ถ.นครอินทร์', 'บางขุนกอง', 'บางกรวย', 'นนทบุรี', '11130', 'นางนิตยา อภิรักษ์', 'มารดา', '084-555-0000'),
    ('650602008', '44444444-4444-4444-4444-444444444418', 'นาย', 'ศุภกร', 'เกียรติคุณ', 'Supakorn', 'Kiatkhun', '1100501234508', '2004-01-30', 'male', 'O', 'https://ui-avatars.com/api/?name=Supakorn+K&background=3949AB&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 2.80, 2.85, 84, '085-666-7788', 'supakorn.k@gmail.com', 'supa_ce65', '33/2 ซ.ประชาชื่น 12', '33/2 ซ.ประชาชื่น 12', 'บางซื่อ', 'บางซื่อ', 'กรุงเทพมหานคร', '10800', 'นายเกียรติ เกียรติคุณ', 'บิดา', '085-666-0000'),
    ('650602009', '44444444-4444-4444-4444-444444444419', 'น.ส.', 'ปภาวรินท์', 'เลิศสกุล', 'Paphawarin', 'Lertsakul', '1100501234509', '2004-06-18', 'female', 'A', 'https://ui-avatars.com/api/?name=Paphawarin+L&background=D81B60&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 3.82, 3.90, 87, '086-777-8899', 'paphawarin.l@gmail.com', 'papha_ce65', '50/6 ถ.รัชดาภิเษก', '50/6 ถ.รัชดาภิเษก', 'ลาดยาว', 'จตุจักร', 'กรุงเทพมหานคร', '10900', 'นางวรรณา เลิศสกุล', 'มารดา', '086-777-0000'),
    ('650602010', '44444444-4444-4444-4444-444444444420', 'นาย', 'กิตติพัฒน์', 'ธนากุล', 'Kittiphat', 'Thanakul', '1100501234510', '2004-12-05', 'male', 'B', 'https://ui-avatars.com/api/?name=Kittiphat+T&background=5E35B1&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 2.45, 2.50, 81, '087-888-9900', 'kittiphat.t@gmail.com', 'kitti_ce65', '19/4 ซ.วงศ์สว่าง 19', '19/4 ซ.วงศ์สว่าง 19', 'วงศ์สว่าง', 'บางซื่อ', 'กรุงเทพมหานคร', '10800', 'นายธนา ธนากุล', 'บิดา', '087-888-0000'),
    ('650602011', '44444444-4444-4444-4444-444444444421', 'น.ส.', 'ณัฐณิชา', 'พงศ์ไพบูลย์', 'Natnicha', 'Pongpaiboon', '1100501234511', '2004-03-22', 'female', 'O', 'https://ui-avatars.com/api/?name=Natnicha+P&background=039BE5&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 3.35, 3.40, 87, '088-999-0011', 'natnicha.p@gmail.com', 'natni_ce65', '64/2 ถ.พิบูลสงคราม', '64/2 ถ.พิบูลสงคราม', 'สวนใหญ่', 'เมืองนนทบุรี', 'นนทบุรี', '11000', 'นางนิภา พงศ์ไพบูลย์', 'มารดา', '088-999-0000'),
    ('650602012', '44444444-4444-4444-4444-444444444422', 'นาย', 'ภัทรพล', 'อัศวเมธี', 'Phattharaphon', 'Asawamethee', '1100501234512', '2004-10-15', 'male', 'A', 'https://ui-avatars.com/api/?name=Phattharaphon+A&background=43A047&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.10, 3.15, 87, '089-000-1122', 'phattharaphon.a@gmail.com', 'phat_ce65', '102/7 ถ.สามเสน', '102/7 ถ.สามเสน', 'วชิรพยาบาล', 'ดุสิต', 'กรุงเทพมหานคร', '10300', 'นายเมธี อัศวเมธี', 'บิดา', '089-000-0000')
ON CONFLICT (student_id) DO NOTHING;

-- 10. รายวิชาตามหลักสูตร (Subjects)
INSERT INTO public.subjects (subject_code, department_id, name_th, name_en, credits, lecture_hours, lab_hours, self_study_hours, is_lab, prerequisite_code, description)
VALUES
    ('ENGCE302', '22222222-2222-2222-2222-222222222201', 'ระบบฐานข้อมูล', 'Database Systems', 3, 2, 2, 5, FALSE, 'ENGCE301', 'การออกแบบฐานข้อมูลเชิงสัมพันธ์ ER Diagram, Normalization 3NF, SQL และการจัดการธุรกรรม'),
    ('ENGCE305', '22222222-2222-2222-2222-222222222201', 'เครือข่ายคอมพิวเตอร์', 'Computer Networks', 3, 2, 2, 5, TRUE, NULL, 'สถาปัตยกรรมเครือข่าย OSI Model, TCP/IP, Routing, Switching และความปลอดภัยเครือข่าย'),
    ('ENGCE306', '22222222-2222-2222-2222-222222222201', 'วิศวกรรมซอฟต์แวร์', 'Software Engineering', 3, 3, 0, 6, FALSE, 'ENGCE301', 'กระบวนการพัฒนาซอฟต์แวร์ Agile, Scrum, Requirements, UML Design และการทดสอบระบบ'),
    ('ENGCE307', '22222222-2222-2222-2222-222222222201', 'ไมโครคอนโทรลเลอร์และระบบฝังตัว', 'Microcontrollers and Embedded Systems', 3, 2, 2, 5, TRUE, NULL, 'การเขียนโปรแกรมควบคุมไมโครคอนโทรลเลอร์ ARM/ESP32 การเชื่อมต่อเซนเซอร์และ IoT'),
    ('ENGCE308', '22222222-2222-2222-2222-222222222201', 'ปัญญาประดิษฐ์เบื้องต้น', 'Introduction to Artificial Intelligence', 3, 3, 0, 6, FALSE, 'MATH201', 'แนวคิดปัญญาประดิษฐ์ Machine Learning, Neural Networks และการประยุกต์ใช้งาน'),
    ('GEN101', NULL, 'ภาษาอังกฤษเพื่ออาชีพ', 'English for Careers', 3, 3, 0, 6, FALSE, NULL, 'ทักษะการสื่อสารภาษาอังกฤษในการทำงาน การเขียนเรซูเม่ และการสัมภาษณ์งาน'),
    ('ENGCE301', '22222222-2222-2222-2222-222222222201', 'โครงสร้างข้อมูล', 'Data Structures', 3, 2, 2, 5, FALSE, NULL, 'โครงสร้างข้อมูลพื้นฐาน Array, Linked List, Stack, Queue, Tree, Graph และอัลกอริทึม'),
    ('ENGCE303', '22222222-2222-2222-2222-222222222201', 'ระบบปฏิบัติการ', 'Operating Systems', 3, 3, 0, 6, FALSE, NULL, 'การจัดการโปรเซส เธรด หน่วยความจำ ระบบไฟล์ และ Deadlock'),
    ('MATH201', NULL, 'สถิติวิศวะ', 'Engineering Statistics', 3, 3, 0, 6, FALSE, NULL, 'ความน่าจะเป็น ตัวแปรสุ่ม การแจกแจงความน่าจะเป็น และการทดสอบสมมติฐานทางวิศวกรรม')
ON CONFLICT (subject_code) DO NOTHING;

-- 11. กลุ่มเรียนที่เปิดสอน (Course Sections)
INSERT INTO public.course_sections (
    id, subject_code, term_id, section_number, teacher_id, day_of_week,
    start_time, end_time, time_display, room, max_students, enrolled_count,
    course_progress, status_student_badge, status_teacher_badge,
    course_summary_student, course_summary_teacher
)
VALUES
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1024', 'MON', '09:00', '12:00', '09:00–12:00', 'ห้อง 1604', 40, 12, 70, 'เช็คชื่อแล้ว', '+ เปิดเช็คชื่อ', 'งานค้าง 1 • คะแนนเก็บ 27/30', 'ส่งแล้ว 8/12 • รอตรวจ 4 • รอส่งเกรด'),
    ('55555555-5555-5555-5555-555555555502', 'ENGCE305', '33333333-3333-3333-3333-333333333302', 'Sec.2', 'T-1025', 'MON', '13:00', '16:00', '13:00–16:00', 'Lab 1502', 40, 12, 45, 'เริ่มบ่ายนี้', '+ เปิดเช็คชื่อ', 'งานค้าง 1 • Lab สัปดาห์ 6', 'ยังไม่เริ่มส่งเกรด • 12 คน'),
    ('55555555-5555-5555-5555-555555555504', 'ENGCE306', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1024', 'TUE', '09:00', '12:00', '09:00–12:00', 'ห้อง 1602', 40, 12, 60, 'ส่ง Sprint 2 แล้ว', '+ เปิดเช็คชื่อ', 'ไม่มีงานค้าง • โปรเจกต์กลุ่ม', 'ตรวจ Sprint 2 แล้ว • 12 คน'),
    ('55555555-5555-5555-5555-555555555503', 'GEN101', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1027', 'WED', '16:30', '18:00', '16:30–18:00', 'ออนไลน์ MS Teams', 60, 12, 55, 'เรียนออนไลน์', '+ เปิดเช็คชื่อ', 'ไม่มีงานค้าง • เรียนออนไลน์', 'เรียนออนไลน์รวม'),
    ('55555555-5555-5555-5555-555555555505', 'ENGCE307', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1026', 'THU', '13:00', '16:00', '13:00–16:00', 'Lab 1504', 40, 12, 50, 'ปฏิบัติการ IoT', '+ เปิดเช็คชื่อ', 'เตรียมบอร์ด ESP32', 'ปฏิบัติการสัปดาห์ที่ 6'),
    ('55555555-5555-5555-5555-555555555506', 'ENGCE308', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1026', 'FRI', '09:00', '12:00', '09:00–12:00', 'ห้อง 1605', 40, 12, 65, 'บรรยายปกติ', '+ เปิดเช็คชื่อ', 'อ่านบทความ ML ล่วงหน้า', 'สอนสัปดาห์ที่ 6'),
    ('55555555-5555-5555-5555-555555555511', 'ENGCE301', '33333333-3333-3333-3333-333333333301', 'Sec.1', 'T-1024', 'TUE', '09:00', '12:00', '09:00–12:00', 'ห้อง 1602', 40, 12, 100, 'จบรายวิชา', 'ส่งเกรดแล้ว', 'เกรด A', 'ส่งเกรดแล้ว'),
    ('55555555-5555-5555-5555-555555555512', 'ENGCE303', '33333333-3333-3333-3333-333333333301', 'Sec.1', 'T-1025', 'THU', '13:00', '16:00', '13:00–16:00', 'ห้อง 1605', 40, 12, 100, 'จบรายวิชา', 'ส่งเกรดแล้ว', 'เกรด B+', 'ส่งเกรดแล้ว'),
    ('55555555-5555-5555-5555-555555555513', 'MATH201', '33333333-3333-3333-3333-333333333301', 'Sec.1', 'T-1027', 'FRI', '09:00', '12:00', '09:00–12:00', 'ห้อง 1201', 50, 12, 100, 'จบรายวิชา', 'ส่งเกรดแล้ว', 'เกรด C+', 'ส่งเกรดแล้ว')
ON CONFLICT (subject_code, term_id, section_number) DO NOTHING;

-- 12. การลงทะเบียนเรียนและคะแนน (Enrollments)
INSERT INTO public.enrollments (
    student_id, section_id, term_id, subject_code, enrollment_status,
    quiz_score, lab_score, coursework_score, midterm_score, final_score,
    grade_submit_status, attendance_rate, pending_assignments
)
VALUES
    ('650602001', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.0, 16.0, 27, 26, 33, 'ส่งแล้ว', 92.00, 1),
    ('650602002', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 11.0, 14.0, 24, 22, 28, 'ร่าง', 88.00, 1),
    ('650602003', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 9.0, 11.0, 20, 15, 22, 'ร่าง', 75.00, 2),
    ('650602004', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 14.0, 20.0, 29, 28, 36, 'ส่งแล้ว', 100.00, 0),
    ('650602005', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 13.0, 18.0, 26, 25, 31, 'ส่งแล้ว', 95.00, 0),
    ('650602006', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 10.5, 15.0, 23, 20, 26, 'ร่าง', 85.00, 1),
    ('650602007', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.0, 17.0, 25, 24, 29, 'ส่งแล้ว', 92.00, 0),
    ('650602008', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 10.0, 13.0, 21, 19, 24, 'ร่าง', 80.00, 1),
    ('650602009', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 14.5, 22.0, 29, 29, 37, 'ส่งแล้ว', 100.00, 0),
    ('650602010', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 8.0, 10.0, 18, 14, 19, 'ร่าง', 70.00, 2),
    ('650602011', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.5, 17.5, 26, 23, 29, 'ส่งแล้ว', 94.00, 0),
    ('650602012', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 11.5, 16.0, 24, 21, 27, 'ส่งแล้ว', 90.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333302', 'ENGCE305', 'enrolled', 13.0, 18.0, 25, 24, 26, 'ร่าง', 95.00, 1),
    ('650602001', '55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333302', 'ENGCE306', 'enrolled', 14.0, 20.0, 28, 25, 30, 'ส่งแล้ว', 96.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333302', 'GEN101', 'enrolled', 14.0, 0.0, 25, 22, 25, 'ประกาศผลแล้ว', 100.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555505', '33333333-3333-3333-3333-333333333302', 'ENGCE307', 'enrolled', 12.0, 19.0, 26, 24, 28, 'ร่าง', 92.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555506', '33333333-3333-3333-3333-333333333302', 'ENGCE308', 'enrolled', 13.5, 17.0, 27, 26, 30, 'ร่าง', 96.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333302', 'ENGCE305', 'enrolled', 12.0, 16.0, 23, 21, 27, 'ร่าง', 90.00, 1),
    ('650602002', '55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333302', 'ENGCE306', 'enrolled', 12.0, 18.0, 25, 23, 28, 'ส่งแล้ว', 92.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333302', 'GEN101', 'enrolled', 13.0, 0.0, 24, 21, 25, 'ประกาศผลแล้ว', 95.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555505', '33333333-3333-3333-3333-333333333302', 'ENGCE307', 'enrolled', 11.0, 17.0, 24, 22, 26, 'ร่าง', 88.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555506', '33333333-3333-3333-3333-333333333302', 'ENGCE308', 'enrolled', 12.0, 16.0, 24, 22, 25, 'ร่าง', 90.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555511', '33333333-3333-3333-3333-333333333301', 'ENGCE301', 'completed', 14.0, 22.0, 28, 27, 34, 'ประกาศผลแล้ว', 96.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555512', '33333333-3333-3333-3333-333333333301', 'ENGCE303', 'completed', 12.5, 20.0, 25, 23, 29, 'ประกาศผลแล้ว', 90.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555513', '33333333-3333-3333-3333-333333333301', 'MATH201', 'completed', 10.0, 0.0, 21, 19, 26, 'ประกาศผลแล้ว', 85.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555511', '33333333-3333-3333-3333-333333333301', 'ENGCE301', 'completed', 13.0, 20.0, 26, 24, 28, 'ประกาศผลแล้ว', 92.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555512', '33333333-3333-3333-3333-333333333301', 'ENGCE303', 'completed', 12.0, 18.0, 24, 22, 26, 'ประกาศผลแล้ว', 88.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555513', '33333333-3333-3333-3333-333333333301', 'MATH201', 'completed', 11.0, 0.0, 22, 20, 24, 'ประกาศผลแล้ว', 86.00, 0)
ON CONFLICT (student_id, section_id) DO NOTHING;

-- 13. เอกสารประกอบการสอน (Course Materials)
DELETE FROM public.course_materials WHERE section_id = '55555555-5555-5555-5555-555555555501';
INSERT INTO public.course_materials (section_id, subject_code, title, file_type, file_size_label, file_url, updated_label)
VALUES
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', 'สไลด์ Lec 6 — Normalization (1NF, 2NF, 3NF, BCNF)', 'PDF', '2.4 MB', '/storage/v1/object/public/materials/ENGCE302_Lec6_Normalization.pdf', 'อัปเดตเมื่อวาน'),
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', 'สไลด์ Lec 5 — ER Diagram & Relational Mapping', 'PDF', '3.1 MB', '/storage/v1/object/public/materials/ENGCE302_Lec5_ERD.pdf', 'สัปดาห์ที่แล้ว'),
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', 'คู่มือปฏิบัติการ SQL & PostgreSQL Stored Procedures', 'PDF', '1.9 MB', '/storage/v1/object/public/materials/ENGCE302_Lab_PostgreSQL.pdf', '3 วันที่แล้ว');

-- 14. การบ้าน / งานที่สั่ง (Assignments)
INSERT INTO public.assignments (id, section_id, subject_code, title, description, due_badge, due_date, max_score, submitted_count, total_students)
VALUES
    ('66666666-6666-6666-6666-666666666601', '55555555-5555-5555-5555-555555555501', 'ENGCE302', 'HW6: ออกแบบ ER + Normalization 3NF', 'แนบ PDF/รูป • ส่งได้ถึง 23 ก.ย. 23:59', 'ส่งใน 2 วัน', '2026-09-23 23:59:00+07', 10.00, 9, 12),
    ('66666666-6666-6666-6666-666666666602', '55555555-5555-5555-5555-555555555502', 'ENGCE305', 'Lab 6 Report: VLAN & OSPF Routing', 'แนบไฟล์ .pkt และรายงาน PDF', 'ส่งใน 5 วัน', '2026-09-26 23:59:00+07', 15.00, 7, 12)
ON CONFLICT (id) DO NOTHING;

-- 15. ประวัติการส่งงานของนักศึกษา (Assignment Submissions)
INSERT INTO public.assignment_submissions (assignment_id, student_id, file_url, file_name, file_size_bytes, mime_type, status, score, teacher_feedback)
VALUES
    ('66666666-6666-6666-6666-666666666601', '650602001', '/storage/v1/object/authenticated/submissions/650602001_HW6_ER_3NF.pdf', '650602001_HW6_ER_3NF.pdf', 312400, 'application/pdf', 'submitted', 9.50, 'แยกตาราง 3NF ได้ถูกต้องครบถ้วน')
ON CONFLICT (assignment_id, student_id) DO NOTHING;

-- 16. การเปิดห้องเช็กชื่อ (Attendance Sessions)
INSERT INTO public.attendance_sessions (id, section_id, subject_code, session_date, week_number, room_code, qr_code_payload, open_time_label, is_open, present_count, total_students)
VALUES
    ('77777777-7777-7777-7777-777777777701', '55555555-5555-5555-5555-555555555501', 'ENGCE302', CURRENT_DATE, 6, 'DB-0921', 'RMUTP-ATTENDANCE|ENGCE302|SEC1|DB-0921', '09:00–09:15', TRUE, 9, 12)
ON CONFLICT (id) DO NOTHING;

-- 17. บันทึกการเช็กชื่อรายบุคคล (Attendance Records)
INSERT INTO public.attendance_records (session_id, student_id, status, check_in_time, check_in_method, reminded_via_line, note)
VALUES
    ('77777777-7777-7777-7777-777777777701', '650602001', 'present', '09:03', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602002', 'present', '09:04', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602003', 'absent', NULL, 'teacher_manual', FALSE, 'ยังไม่มาเรียน'),
    ('77777777-7777-7777-7777-777777777701', '650602004', 'present', '09:01', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602005', 'present', '09:02', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602006', 'late', '09:18', 'room_code', FALSE, 'มาสาย 3 นาที'),
    ('77777777-7777-7777-7777-777777777701', '650602007', 'present', '09:05', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602008', 'absent', NULL, 'teacher_manual', FALSE, 'ยังไม่มาเรียน'),
    ('77777777-7777-7777-7777-777777777701', '650602009', 'present', '09:00', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602010', 'absent', NULL, 'teacher_manual', FALSE, 'ยังไม่มาเรียน'),
    ('77777777-7777-7777-7777-777777777701', '650602011', 'present', '09:06', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602012', 'present', '09:07', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา')
ON CONFLICT (session_id, student_id) DO NOTHING;

-- 18. ใบแจ้งหนี้ค่าเทอม (Tuition Invoices)
INSERT INTO public.tuition_invoices (
    invoice_no, student_id, term_id, tuition_fee, university_fee, lab_equipment_fee,
    scholarship_discount, total_amount, due_date, payment_status, invoice_pdf_url
)
VALUES
    ('INV-2569-1-650602001', '650602001', '33333333-3333-3333-3333-333333333302', 15000.00, 2000.00, 1500.00, 0.00, 18500.00, '2026-06-30', 'paid', '/storage/v1/object/authenticated/receipts/INV-2569-1-650602001.pdf'),
    ('INV-2568-2-650602001', '650602001', '33333333-3333-3333-3333-333333333301', 15000.00, 2000.00, 1500.00, 5000.00, 13500.00, '2025-11-30', 'paid', '/storage/v1/object/authenticated/receipts/INV-2568-2-650602001.pdf'),
    ('INV-2569-1-650602002', '650602002', '33333333-3333-3333-3333-333333333302', 15000.00, 2000.00, 1500.00, 0.00, 18500.00, '2026-06-30', 'paid', '/storage/v1/object/authenticated/receipts/INV-2569-1-650602002.pdf'),
    ('INV-2569-1-650602003', '650602003', '33333333-3333-3333-3333-333333333302', 15000.00, 2000.00, 1500.00, 0.00, 18500.00, '2026-06-30', 'verifying', '/storage/v1/object/authenticated/receipts/INV-2569-1-650602003.pdf')
ON CONFLICT (invoice_no) DO NOTHING;

-- 19. ใบเสร็จรับเงินอิเล็กทรอนิกส์ (Payment Receipts)
INSERT INTO public.payment_receipts (
    receipt_no, invoice_no, student_id, payment_method, bank_name,
    transaction_ref, amount_paid, paid_at, slip_image_url, receipt_pdf_url, finance_officer_name, is_verified
)
VALUES
    ('RCP-2569-00891', 'INV-2569-1-650602001', '650602001', 'qr_promptpay', 'ธนาคารกรุงไทย (KTB)', 'KTB2026062009154421', 18500.00, '2026-06-20 09:15:44+07', '/storage/v1/object/authenticated/receipts/slip_650602001_2569_1.jpg', '/storage/v1/object/authenticated/receipts/RCP-2569-00891.pdf', 'กองคลัง สำนักงานอธิการบดี มทร.พระนคร', TRUE),
    ('RCP-2568-04512', 'INV-2568-2-650602001', '650602001', 'mobile_banking', 'ธนาคารกสิกรไทย (KBANK)', 'KBANK2025111814221099', 13500.00, '2025-11-18 14:22:10+07', '/storage/v1/object/authenticated/receipts/slip_650602001_2568_2.jpg', '/storage/v1/object/authenticated/receipts/RCP-2568-04512.pdf', 'กองคลัง สำนักงานอธิการบดี มทร.พระนคร', TRUE),
    ('RCP-2569-00945', 'INV-2569-1-650602002', '650602002', 'qr_promptpay', 'ธนาคารไทยพาณิชย์ (SCB)', 'SCB2026062211053310', 18500.00, '2026-06-22 11:05:33+07', '/storage/v1/object/authenticated/receipts/slip_650602002_2569_1.jpg', '/storage/v1/object/authenticated/receipts/RCP-2569-00945.pdf', 'กองคลัง สำนักงานอธิการบดี มทร.พระนคร', TRUE)
ON CONFLICT (receipt_no) DO NOTHING;

-- 20. คำร้องและแจ้งเรื่อง (Service Requests)
INSERT INTO public.service_requests (
    request_code, student_id, category, title, description, room_location,
    attachment_image_url, result_pdf_url, status_student, status_teacher,
    chip_color_hex, progress, assigned_teacher_id
)
VALUES
    ('#RQ-1042', '650602001', 'document', 'ขอใบรับรอง ENG', 'ขอใบรับรองการเป็นนักศึกษาฉบับภาษาอังกฤษ เพื่อใช้ยื่นสมัครโครงการแลกเปลี่ยนและทุนการศึกษา', NULL, '/storage/v1/object/authenticated/receipts/fee_slip_1042.jpg', NULL, 'รอดำเนินการ', 'รออนุมัติ', '#FFC107', 0.40, 'T-1024'),
    ('#RQ-1039', '650602001', 'repair', 'แอร์ห้อง 1604 ไม่เย็น', 'เครื่องปรับอากาศตัวริมหน้าต่างในห้องเรียน 1604 มีแต่ลมออกและมีน้ำหยดระหว่างเรียนวิชาฐานข้อมูล', 'ห้อง 1604 อาคารคณะวิศวกรรมศาสตร์', '/storage/v1/object/authenticated/submissions/ac_room1604.jpg', NULL, 'ช่างรับเรื่อง', 'ส่งต่อช่างแล้ว', '#2196F3', 0.70, 'T-1024'),
    ('#RQ-1031', '650602001', 'document', 'ขอ transcript', 'ขอใบแสดงผลการศึกษา (Transcript) ฉบับไม่เป็นทางการ ตั้งแต่ชั้นปีที่ 1 ถึงปัจจุบัน', NULL, NULL, '/storage/v1/object/authenticated/receipts/Transcript_650602001.pdf', 'เสร็จแล้ว • โหลด PDF', 'เสร็จสิ้น', '#4CAF50', 1.00, 'T-1024'),
    ('#RQ-1045', '650602002', 'document', 'ขอหนังสือส่งตัวสหกิจศึกษา', 'ขอหนังสือขอความอนุเคราะห์รับนักศึกษาเข้าปฏิบัติงานสหกิจศึกษา บริษัท โตโยต้า ทูโช', NULL, NULL, NULL, 'รอดำเนินการ', 'รออนุมัติ', '#FFC107', 0.35, 'T-1024')
ON CONFLICT (request_code) DO NOTHING;

-- 21. ข่าวสารและประกาศ (News Announcements)
DELETE FROM public.news_announcements;
INSERT INTO public.news_announcements (title, subtitle, news_type, detail, banner_image_url, button_label, min_gpa_required, author_teacher_id, view_count, expire_date)
VALUES
    ('ทุนเรียนดีคณะวิศวฯ 5,000 บาท (20 ทุน)', 'ทุน • ปิดรับ 30 ก.ย.', 'ทุน', 'GPA ≥ 3.00 • แนบทรานสคริปต์ • สมัครออนไลน์ผ่านระบบกิจการนักศึกษา คณะวิศวกรรมศาสตร์ มทร.พระนคร', '/storage/v1/object/public/materials/scholarship_eng_2569.jpg', 'ดูรายละเอียด', 3.00, 'T-1024', 185, '2026-09-30'),
    ('ฝึกงาน/สหกิจ Toyota Tsusho — รับสหกิจ IT 10 อัตรา', 'ฝึกงาน/สหกิจ • สมัครด่วน', 'ฝึกงาน', 'สัมภาษณ์ 5 ต.ค. ที่ศูนย์สหกิจ • รับนักศึกษาสาขาวิศวกรรมคอมพิวเตอร์และ IT มีเบี้ยเลี้ยงตลอดโครงการ', '/storage/v1/object/public/materials/coop_toyota_tsusho.jpg', 'ดูรายละเอียด', 2.50, 'T-1025', 127, '2026-10-05'),
    ('RMUTP Freshmen Day + ชมรมหุ่นยนต์', 'กิจกรรม • 27 ก.ย.', 'กิจกรรม', 'เปิดรายละเอียดกิจกรรมต้อนรับน้องใหม่และบูธแสดงผลงานชมรมหุ่นยนต์ คณะวิศวกรรมศาสตร์ รับชั่วโมงกิจกรรม 6 ชม.', '/storage/v1/object/public/materials/freshmen_robotics.jpg', 'ดูรายละเอียด', NULL, 'T-1024', 312, '2026-09-27');

-- 22. การแจ้งเตือน (Notifications)
DELETE FROM public.notifications;
INSERT INTO public.notifications (user_id, student_id, title, subtitle, accent_color_hex, is_read)
VALUES
    ('44444444-4444-4444-4444-444444444411', '650602001', 'HW6 ใกล้ครบกำหนด', 'ENGCE302 — ส่งใน 2 วัน (23 ก.ย. 23:59)', '#F44336', FALSE),
    ('44444444-4444-4444-4444-444444444411', '650602001', 'ทุนคณะวิศวฯ ปิดรับ 30 ก.ย.', 'คุณสมบัติผ่าน กดสมัครได้เลย', '#F6DC04', FALSE),
    ('44444444-4444-4444-4444-444444444411', '650602001', 'เลื่อนห้อง ENGCE305 → Lab 1502', 'จาก อ.นภัส เมื่อ 1 ชม.ก่อน', '#652D91', FALSE),
    ('44444444-4444-4444-4444-444444444412', '650602002', 'HW6 ใกล้ครบกำหนด', 'ENGCE302 — ส่งใน 2 วัน (23 ก.ย. 23:59)', '#F44336', FALSE);

-- =============================================================================
-- ส่วนที่ 6: ความปลอดภัยมาตรฐานสากล (Strict RLS, Anti-IDOR, Column Security)
-- =============================================================================

-- เปิดใช้งาน RLS ครบทุกตาราง (24 ตารางรวม user_sessions และ audit_logs)
ALTER TABLE public.faculties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curriculums ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buildings_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tuition_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- Column-Level Security: ป้องกันการดึงคอลัมน์รหัสผ่านและเลขบัตร ปชช. ดิบออกไปผ่าน API โดยเด็ดขาด
REVOKE SELECT (password_hash) ON public.users FROM anon, authenticated;
REVOKE SELECT (citizen_id) ON public.students FROM anon, authenticated;

-- อนุญาตเรียกใช้งาน RPC ตรวจสอบสิทธิ์และ Business Logic ที่ปลอดภัย
GRANT EXECUTE ON FUNCTION public.sp_authenticate_user(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.sp_check_in_attendance(UUID, VARCHAR, VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.sp_submit_assignment(UUID, VARCHAR, VARCHAR, INT, VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.sp_submit_section_grades(VARCHAR, VARCHAR, JSONB, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fn_get_masked_citizen_id(VARCHAR) TO anon, authenticated;

-- ล้าง Policy เก่าที่ไม่ปลอดภัยออกทั้งหมดก่อนสร้าง Policy ใหม่ที่รัดกุม
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'faculties', 'departments', 'curriculums', 'buildings_rooms',
        'academic_terms', 'academic_calendar_events', 'users', 'teachers',
        'students', 'subjects', 'course_sections', 'enrollments',
        'course_materials', 'assignments', 'assignment_submissions',
        'attendance_sessions', 'attendance_records', 'tuition_invoices',
        'payment_receipts', 'service_requests', 'news_announcements',
        'notifications', 'audit_logs', 'user_sessions'
    ]
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "rmutp_app_policy_%I" ON public.%I;', tbl, tbl);
    END LOOP;
END $$;

-- A. ตารางข้อมูลสาธารณะของมหาวิทยาลัย (อ่านได้ทั่วไป, แก้ไขได้เฉพาะอาจารย์/แอดมิน)
DO $$
DECLARE
    pub_tbl TEXT;
BEGIN
    FOREACH pub_tbl IN ARRAY ARRAY[
        'faculties', 'departments', 'curriculums', 'buildings_rooms',
        'academic_terms', 'academic_calendar_events', 'subjects',
        'course_sections', 'course_materials', 'assignments'
    ]
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "public_read_%I" ON public.%I;', pub_tbl, pub_tbl);
        EXECUTE format('CREATE POLICY "public_read_%I" ON public.%I FOR SELECT TO anon, authenticated USING (true);', pub_tbl, pub_tbl);
    END LOOP;
END $$;

DROP POLICY IF EXISTS "public_read_news" ON public.news_announcements;
CREATE POLICY "public_read_news" ON public.news_announcements FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "teacher_insert_news" ON public.news_announcements;
CREATE POLICY "teacher_insert_news" ON public.news_announcements FOR INSERT TO anon, authenticated
    WITH CHECK (public.fn_current_actor_role() IN ('teacher', 'admin'));

-- B. ตาราง users (เห็นเฉพาะบัญชีตัวเองเท่านั้น, ปิดกั้นไม่ให้ anon อ่านตาราง users โดยตรง)
DROP POLICY IF EXISTS "users_self_select" ON public.users;
CREATE POLICY "users_self_select" ON public.users FOR SELECT TO anon, authenticated
    USING (id = public.fn_current_actor_id() OR public.fn_current_actor_role() = 'admin');

-- C. ตาราง teachers (อ่านข้อมูลติดต่ออาจารย์ได้เฉพาะผู้ที่ล็อกอินแล้ว)
DROP POLICY IF EXISTS "teachers_auth_select" ON public.teachers;
CREATE POLICY "teachers_auth_select" ON public.teachers FOR SELECT TO anon, authenticated
    USING (public.fn_current_actor_id() IS NOT NULL);

-- D. ตาราง students (นักศึกษาดู/แก้ได้เฉพาะของตัวเอง, อาจารย์/แอดมินดูได้เพื่อสอนและที่ปรึกษา)
DROP POLICY IF EXISTS "students_self_or_teacher_select" ON public.students;
CREATE POLICY "students_self_or_teacher_select" ON public.students FOR SELECT TO anon, authenticated
    USING (
        user_id = public.fn_current_actor_id()
        OR public.fn_current_actor_role() IN ('teacher', 'admin')
    );
DROP POLICY IF EXISTS "students_self_update" ON public.students;
CREATE POLICY "students_self_update" ON public.students FOR UPDATE TO anon, authenticated
    USING (user_id = public.fn_current_actor_id())
    WITH CHECK (user_id = public.fn_current_actor_id());

-- E. ตาราง enrollments (นักศึกษาดูเกรดตัวเองเท่านั้น, อาจารย์ดู/ตัดเกรดในรายวิชาที่เปิดสอน)
DROP POLICY IF EXISTS "enrollments_anti_idor_select" ON public.enrollments;
CREATE POLICY "enrollments_anti_idor_select" ON public.enrollments FOR SELECT TO anon, authenticated
    USING (
        student_id = public.fn_current_student_id()
        OR public.fn_current_actor_role() IN ('teacher', 'admin')
    );
DROP POLICY IF EXISTS "enrollments_teacher_update" ON public.enrollments;
CREATE POLICY "enrollments_teacher_update" ON public.enrollments FOR UPDATE TO anon, authenticated
    USING (public.fn_current_actor_role() IN ('teacher', 'admin'))
    WITH CHECK (public.fn_current_actor_role() IN ('teacher', 'admin'));

-- F. ตาราง assignment_submissions (นักศึกษาดู/ส่งงานของตัวเองเท่านั้น)
DROP POLICY IF EXISTS "submissions_anti_idor_select" ON public.assignment_submissions;
CREATE POLICY "submissions_anti_idor_select" ON public.assignment_submissions FOR SELECT TO anon, authenticated
    USING (
        student_id = public.fn_current_student_id()
        OR public.fn_current_actor_role() IN ('teacher', 'admin')
    );
DROP POLICY IF EXISTS "submissions_student_insert" ON public.assignment_submissions;
CREATE POLICY "submissions_student_insert" ON public.assignment_submissions FOR INSERT TO anon, authenticated
    WITH CHECK (student_id = public.fn_current_student_id());

-- G. ตาราง attendance_sessions & attendance_records
DROP POLICY IF EXISTS "attendance_sessions_auth_select" ON public.attendance_sessions;
CREATE POLICY "attendance_sessions_auth_select" ON public.attendance_sessions FOR SELECT TO anon, authenticated
    USING (public.fn_current_actor_id() IS NOT NULL);
DROP POLICY IF EXISTS "attendance_sessions_teacher_write" ON public.attendance_sessions;
CREATE POLICY "attendance_sessions_teacher_write" ON public.attendance_sessions FOR UPDATE TO anon, authenticated
    USING (public.fn_current_actor_role() IN ('teacher', 'admin'))
    WITH CHECK (public.fn_current_actor_role() IN ('teacher', 'admin'));

DROP POLICY IF EXISTS "attendance_records_anti_idor_select" ON public.attendance_records;
CREATE POLICY "attendance_records_anti_idor_select" ON public.attendance_records FOR SELECT TO anon, authenticated
    USING (
        student_id = public.fn_current_student_id()
        OR public.fn_current_actor_role() IN ('teacher', 'admin')
    );

-- H. ตารางการเงิน (tuition_invoices & payment_receipts: ห้ามดูใบเสร็จเพื่อนเด็ดขาด)
DROP POLICY IF EXISTS "invoices_anti_idor_select" ON public.tuition_invoices;
CREATE POLICY "invoices_anti_idor_select" ON public.tuition_invoices FOR SELECT TO anon, authenticated
    USING (
        student_id = public.fn_current_student_id()
        OR public.fn_current_actor_role() = 'admin'
    );
DROP POLICY IF EXISTS "receipts_anti_idor_select" ON public.payment_receipts;
CREATE POLICY "receipts_anti_idor_select" ON public.payment_receipts FOR SELECT TO anon, authenticated
    USING (
        student_id = public.fn_current_student_id()
        OR public.fn_current_actor_role() = 'admin'
    );

-- I. ตาราง service_requests (นักศึกษาสร้าง/ดูคำร้องตัวเอง, อาจารย์ดู/อนุมัติคำร้อง)
DROP POLICY IF EXISTS "requests_anti_idor_select" ON public.service_requests;
CREATE POLICY "requests_anti_idor_select" ON public.service_requests FOR SELECT TO anon, authenticated
    USING (
        student_id = public.fn_current_student_id()
        OR public.fn_current_actor_role() IN ('teacher', 'admin')
    );
DROP POLICY IF EXISTS "requests_student_insert" ON public.service_requests;
CREATE POLICY "requests_student_insert" ON public.service_requests FOR INSERT TO anon, authenticated
    WITH CHECK (student_id = public.fn_current_student_id());
DROP POLICY IF EXISTS "requests_teacher_update" ON public.service_requests;
CREATE POLICY "requests_teacher_update" ON public.service_requests FOR UPDATE TO anon, authenticated
    USING (public.fn_current_actor_role() IN ('teacher', 'admin'))
    WITH CHECK (public.fn_current_actor_role() IN ('teacher', 'admin'));

-- J. ตาราง notifications (เห็นเฉพาะของตัวเอง)
DROP POLICY IF EXISTS "notifications_anti_idor_select" ON public.notifications;
CREATE POLICY "notifications_anti_idor_select" ON public.notifications FOR SELECT TO anon, authenticated
    USING (
        user_id = public.fn_current_actor_id()
        OR student_id = public.fn_current_student_id()
    );

-- K. ตาราง audit_logs (ห้ามแก้ไขหรือลบโดยเด็ดขาด — ดูได้เฉพาะอาจารย์/แอดมิน)
DROP POLICY IF EXISTS "audit_logs_admin_select" ON public.audit_logs;
CREATE POLICY "audit_logs_admin_select" ON public.audit_logs FOR SELECT TO anon, authenticated
    USING (public.fn_current_actor_role() IN ('teacher', 'admin'));
