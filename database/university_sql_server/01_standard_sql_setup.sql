-- =============================================================================
-- RMUTP CAMPUS APP - STANDARD UNIVERSITY ON-PREMISE SQL SERVER SCRIPT
-- ระบบที่ 2: สคริปต์ Pure Standard SQL (PostgreSQL มาตรฐาน 100%)
-- สำหรับติดตั้งบนเครื่องเซิร์ฟเวอร์จริงของมหาวิทยาลัย (โดยไม่พึ่งพา Supabase)
-- ทำงานร่วมกับ Node.js + Express REST API Middleware (Port 4000)
-- =============================================================================
-- =============================================================================
-- RMUTP CAMPUS APP - FULL SUPABASE CLOUD DATABASE SETUP (ALL-IN-ONE SCRIPT)
-- à¸¡à¸«à¸²à¸§à¸´à¸—à¸¢à¸²à¸¥à¸±à¸¢à¹€à¸—à¸„à¹‚à¸™à¹‚à¸¥à¸¢à¸µà¸£à¸²à¸Šà¸¡à¸‡à¸„à¸¥à¸žà¸£à¸°à¸™à¸„à¸£ (Rajamangala University of Technology Phra Nakhon)
-- =============================================================================
-- à¸§à¸´à¸˜à¸µà¹ƒà¸Šà¹‰à¸‡à¸²à¸™à¸šà¸™à¹€à¸§à¹‡à¸š Supabase Cloud:
--   1. à¹€à¸›à¸´à¸”à¹‚à¸›à¸£à¹€à¸ˆà¸à¸•à¹Œà¸‚à¸­à¸‡à¸„à¸¸à¸“à¸šà¸™ https://supabase.com/dashboard
--   2. à¸„à¸¥à¸´à¸à¹€à¸¡à¸™à¸¹à¸‹à¹‰à¸²à¸¢à¸¡à¸·à¸­ "SQL Editor" -> à¸à¸” "+ New query"
--   3. à¸à¹Šà¸­à¸›à¸›à¸µà¹‰à¹‚à¸„à¹‰à¸”à¹ƒà¸™à¹„à¸Ÿà¸¥à¹Œà¸™à¸µà¹‰à¸—à¸±à¹‰à¸‡à¸«à¸¡à¸”à¹„à¸›à¸§à¸²à¸‡ à¹à¸¥à¹‰à¸§à¸à¸”à¸›à¸¸à¹ˆà¸¡ "Run" à¹€à¸žà¸µà¸¢à¸‡à¸„à¸£à¸±à¹‰à¸‡à¹€à¸”à¸µà¸¢à¸§à¸ˆà¸š!
-- =============================================================================

-- à¹€à¸›à¸´à¸”à¹ƒà¸Šà¹‰à¸‡à¸²à¸™ Extensions à¸¡à¸²à¸•à¸£à¸à¸²à¸™
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- à¸ªà¹ˆà¸§à¸™à¸—à¸µà¹ˆ 1: à¹‚à¸„à¸£à¸‡à¸ªà¸£à¹‰à¸²à¸‡à¸•à¸²à¸£à¸²à¸‡à¸«à¸¥à¸±à¸ 22 à¸•à¸²à¸£à¸²à¸‡à¸•à¸²à¸¡à¸«à¸¥à¸±à¸ 3NF (Third Normal Form)
-- =============================================================================

-- 1. à¸•à¸²à¸£à¸²à¸‡à¸„à¸“à¸°à¸§à¸´à¸Šà¸² (Faculties)
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

-- 2. à¸•à¸²à¸£à¸²à¸‡à¸ à¸²à¸„à¸§à¸´à¸Šà¸² / à¸ªà¸²à¸‚à¸²à¸§à¸´à¸Šà¸² (Departments)
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

-- 3. à¸•à¸²à¸£à¸²à¸‡à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£à¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸² (Curriculums)
CREATE TABLE IF NOT EXISTS public.curriculums (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    department_id UUID NOT NULL REFERENCES public.departments(id) ON DELETE CASCADE,
    curriculum_code VARCHAR(30) UNIQUE NOT NULL,
    name_th VARCHAR(200) NOT NULL,
    revision_year INT NOT NULL DEFAULT 2565,
    total_credits INT NOT NULL DEFAULT 132,
    general_ed_credits INT NOT NULL DEFAULT 30,
    major_Required_credits INT NOT NULL DEFAULT 96,
    free_elective_credits INT NOT NULL DEFAULT 6,
    study_years INT NOT NULL DEFAULT 4,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. à¸•à¸²à¸£à¸²à¸‡à¸­à¸²à¸„à¸²à¸£à¹à¸¥à¸°à¸«à¹‰à¸­à¸‡à¹€à¸£à¸µà¸¢à¸™/à¸«à¹‰à¸­à¸‡à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£ (Buildings & Rooms)
CREATE TABLE IF NOT EXISTS public.buildings_rooms (
    room_code VARCHAR(30) PRIMARY KEY,
    building_no VARCHAR(20) NOT NULL,
    building_name_th VARCHAR(150) NOT NULL,
    campus VARCHAR(100) NOT NULL DEFAULT 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­',
    floor_no INT NOT NULL DEFAULT 1,
    room_type VARCHAR(30) NOT NULL DEFAULT 'lecture'
        CHECK (room_type IN ('lecture', 'computer_lab', 'engineering_lab', 'auditorium', 'online')),
    capacity INT NOT NULL DEFAULT 45,
    has_projector BOOLEAN NOT NULL DEFAULT TRUE,
    aircon_count INT NOT NULL DEFAULT 2,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. à¸•à¸²à¸£à¸²à¸‡à¸›à¸µà¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸²à¹à¸¥à¸°à¸ à¸²à¸„à¹€à¸£à¸µà¸¢à¸™ (Academic Terms)
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

-- 6. à¸•à¸²à¸£à¸²à¸‡à¸›à¸à¸´à¸—à¸´à¸™à¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸² (Academic Calendar Events)
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

-- 7. à¸•à¸²à¸£à¸²à¸‡à¸šà¸±à¸à¸Šà¸µà¸œà¸¹à¹‰à¹ƒà¸Šà¹‰à¸‡à¸²à¸™à¸«à¸¥à¸±à¸ (Users & Authentication)
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

-- 8. à¸•à¸²à¸£à¸²à¸‡à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œà¹à¸¥à¸°à¸šà¸¸à¸„à¸¥à¸²à¸à¸£ (Teachers)
CREATE TABLE IF NOT EXISTS public.teachers (
    teacher_id VARCHAR(20) PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    academic_rank VARCHAR(30) NOT NULL DEFAULT 'à¸­.',
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

-- 9. à¸•à¸²à¸£à¸²à¸‡à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸›à¸£à¸°à¸§à¸±à¸•à¸´à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¹€à¸Šà¸´à¸‡à¸¥à¸¶à¸ (Students)
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

-- 10. à¸•à¸²à¸£à¸²à¸‡à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¸•à¸²à¸¡à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£ (Subjects)
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

-- 11. à¸•à¸²à¸£à¸²à¸‡à¸à¸¥à¸¸à¹ˆà¸¡à¹€à¸£à¸µà¸¢à¸™ / à¸•à¸­à¸™à¹€à¸£à¸µà¸¢à¸™à¸—à¸µà¹ˆà¹€à¸›à¸´à¸”à¸ªà¸­à¸™à¹ƒà¸™à¹à¸•à¹ˆà¸¥à¸°à¹€à¸—à¸­à¸¡ (Course Sections)
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

-- 12. à¸•à¸²à¸£à¸²à¸‡à¸à¸²à¸£à¸¥à¸‡à¸—à¸°à¹€à¸šà¸µà¸¢à¸™à¹€à¸£à¸µà¸¢à¸™à¹à¸¥à¸°à¸œà¸¥à¸à¸²à¸£à¹€à¸£à¸µà¸¢à¸™à¸£à¸²à¸¢à¸§à¸´à¸Šà¸² (Enrollments & Grades)
CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    enrollment_status VARCHAR(20) NOT NULL DEFAULT 'enrolled'
        CHECK (enrollment_status IN ('enrolled', 'withdrawn', 'completed')),
    quiz_score NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (quiz_score >= 0),
    lab_score NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (lab_score >= 0),
    coursework_score INT NOT NULL DEFAULT 0 CHECK (coursework_score BETWEEN 0 AND 30),
    midterm_score INT NOT NULL DEFAULT 0 CHECK (midterm_score BETWEEN 0 AND 30),
    final_score INT NOT NULL DEFAULT 0 CHECK (final_score BETWEEN 0 AND 40),
    total_score INT NOT NULL DEFAULT 0 CHECK (total_score BETWEEN 0 AND 100),
    grade_letter VARCHAR(10),
    grade_display VARCHAR(25),
    grade_point NUMERIC(3, 2) CHECK (grade_point BETWEEN 0.00 AND 4.00),
    grade_submit_status VARCHAR(20) NOT NULL DEFAULT 'à¸£à¹ˆà¸²à¸‡'
        CHECK (grade_submit_status IN ('à¸£à¹ˆà¸²à¸‡', 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§')),
    is_warning BOOLEAN NOT NULL DEFAULT FALSE,
    attendance_rate NUMERIC(5, 2) NOT NULL DEFAULT 100.00,
    pending_assignments INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, section_id)
);

-- 13. à¸•à¸²à¸£à¸²à¸‡à¹€à¸­à¸à¸ªà¸²à¸£à¸›à¸£à¸°à¸à¸­à¸šà¸à¸²à¸£à¸ªà¸­à¸™ (Course Materials)
CREATE TABLE IF NOT EXISTS public.course_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    file_type VARCHAR(20) NOT NULL DEFAULT 'PDF',
    file_size_label VARCHAR(30) NOT NULL,
    file_url TEXT NOT NULL,
    updated_label VARCHAR(50) DEFAULT 'à¸­à¸±à¸›à¹€à¸”à¸•à¹€à¸¡à¸·à¹ˆà¸­à¸§à¸²à¸™',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. à¸•à¸²à¸£à¸²à¸‡à¸‡à¸²à¸™à¸—à¸µà¹ˆà¸ªà¸±à¹ˆà¸‡ / à¸à¸²à¸£à¸šà¹‰à¸²à¸™ (Assignments)
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

-- 15. à¸•à¸²à¸£à¸²à¸‡à¸à¸²à¸£à¸ªà¹ˆà¸‡à¸‡à¸²à¸™à¸‚à¸­à¸‡à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸² (Assignment Submissions)
CREATE TABLE IF NOT EXISTS public.assignment_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_name VARCHAR(200),
    status VARCHAR(20) NOT NULL DEFAULT 'submitted'
        CHECK (status IN ('pending', 'submitted', 'late', 'graded')),
    score NUMERIC(5, 2),
    teacher_feedback TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (assignment_id, student_id)
);

-- 16. à¸•à¸²à¸£à¸²à¸‡à¸à¸²à¸£à¹€à¸›à¸´à¸”à¸«à¹‰à¸­à¸‡à¹€à¸Šà¹‡à¸à¸Šà¸·à¹ˆà¸­à¹à¸•à¹ˆà¸¥à¸°à¸„à¸²à¸š (Attendance Sessions)
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    session_date DATE NOT NULL DEFAULT CURRENT_DATE,
    week_number INT NOT NULL DEFAULT 6,
    room_code VARCHAR(20) NOT NULL,
    qr_code_payload TEXT,
    open_time_label VARCHAR(50) DEFAULT '09:00â€“09:15',
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    present_count INT NOT NULL DEFAULT 0,
    total_students INT NOT NULL DEFAULT 40,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 17. à¸•à¸²à¸£à¸²à¸‡à¸šà¸±à¸™à¸—à¸¶à¸à¸à¸²à¸£à¹€à¸Šà¹‡à¸à¸Šà¸·à¹ˆà¸­à¸£à¸²à¸¢à¸šà¸¸à¸„à¸„à¸¥ (Attendance Records)
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

-- 18. à¸•à¸²à¸£à¸²à¸‡à¹ƒà¸šà¹à¸ˆà¹‰à¸‡à¸«à¸™à¸µà¹‰à¸„à¹ˆà¸²à¹€à¸—à¸­à¸¡à¹à¸¥à¸°à¸„à¹ˆà¸²à¸˜à¸£à¸£à¸¡à¹€à¸™à¸µà¸¢à¸¡ (Tuition Invoices)
CREATE TABLE IF NOT EXISTS public.tuition_invoices (
    invoice_no VARCHAR(30) PRIMARY KEY,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    tuition_fee NUMERIC(10, 2) NOT NULL DEFAULT 15000.00,
    university_fee NUMERIC(10, 2) NOT NULL DEFAULT 2000.00,
    lab_equipment_fee NUMERIC(10, 2) NOT NULL DEFAULT 1500.00,
    scholarship_discount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 18500.00,
    due_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'unpaid'
        CHECK (payment_status IN ('unpaid', 'verifying', 'paid', 'overdue', 'cancelled')),
    invoice_pdf_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, term_id)
);

-- 19. à¸•à¸²à¸£à¸²à¸‡à¹ƒà¸šà¹€à¸ªà¸£à¹‡à¸ˆà¸£à¸±à¸šà¹€à¸‡à¸´à¸™à¹à¸¥à¸°à¸«à¸¥à¸±à¸à¸à¸²à¸™à¸à¸²à¸£à¸Šà¸³à¸£à¸°à¹€à¸‡à¸´à¸™ (Payment Receipts)
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
    finance_officer_name VARCHAR(150) DEFAULT 'à¸à¸­à¸‡à¸„à¸¥à¸±à¸‡ à¸ªà¸³à¸™à¸±à¸à¸‡à¸²à¸™à¸­à¸˜à¸´à¸à¸²à¸£à¸šà¸”à¸µ à¸¡à¸—à¸£.à¸žà¸£à¸°à¸™à¸„à¸£',
    is_verified BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. à¸•à¸²à¸£à¸²à¸‡à¸„à¸³à¸£à¹‰à¸­à¸‡à¹à¸¥à¸°à¹à¸ˆà¹‰à¸‡à¹€à¸£à¸·à¹ˆà¸­à¸‡ (Service Requests)
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
    status_student VARCHAR(50) NOT NULL DEFAULT 'à¸£à¸­à¸”à¸³à¹€à¸™à¸´à¸™à¸à¸²à¸£',
    status_teacher VARCHAR(50) NOT NULL DEFAULT 'à¸£à¸­à¸­à¸™à¸¸à¸¡à¸±à¸•à¸´',
    chip_color_hex VARCHAR(10) NOT NULL DEFAULT '#FFC107',
    progress NUMERIC(3, 2) NOT NULL DEFAULT 0.30 CHECK (progress BETWEEN 0.00 AND 1.00),
    assigned_teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 21. à¸•à¸²à¸£à¸²à¸‡à¸‚à¹ˆà¸²à¸§à¸ªà¸²à¸£à¹à¸¥à¸°à¸›à¸£à¸°à¸à¸²à¸¨ (News Announcements)
CREATE TABLE IF NOT EXISTS public.news_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(250) NOT NULL,
    subtitle VARCHAR(150) NOT NULL,
    news_type VARCHAR(30) NOT NULL
        CHECK (news_type IN ('à¸—à¸¸à¸™', 'à¸à¸¶à¸à¸‡à¸²à¸™', 'à¸à¸´à¸ˆà¸à¸£à¸£à¸¡', 'à¸›à¸£à¸°à¸à¸²à¸¨')),
    detail TEXT NOT NULL,
    banner_image_url TEXT,
    button_label VARCHAR(50) NOT NULL DEFAULT 'à¸”à¸¹à¸£à¸²à¸¢à¸¥à¸°à¹€à¸­à¸µà¸¢à¸”',
    action_url TEXT,
    min_gpa_required NUMERIC(3, 2),
    author_teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    view_count INT NOT NULL DEFAULT 120,
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expire_date DATE
);

-- 22. à¸•à¸²à¸£à¸²à¸‡à¸à¸²à¸£à¹à¸ˆà¹‰à¸‡à¹€à¸•à¸·à¸­à¸™ (Notifications)
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

-- Indexes à¸ªà¸³à¸«à¸£à¸±à¸šà¹€à¸žà¸´à¹ˆà¸¡à¸„à¸§à¸²à¸¡à¹€à¸£à¹‡à¸§à¹ƒà¸™à¸à¸²à¸£ Query
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

-- =============================================================================
-- à¸ªà¹ˆà¸§à¸™à¸—à¸µà¹ˆ 2: Triggers & Stored Functions / RPC à¸ªà¸³à¸«à¸£à¸±à¸šà¸à¸²à¸£à¸„à¸³à¸™à¸§à¸“à¹€à¸à¸£à¸”à¹à¸¥à¸°à¸¥à¹‡à¸­à¸à¸­à¸´à¸™à¸ˆà¸£à¸´à¸‡
-- =============================================================================

-- 1. Trigger à¸„à¸³à¸™à¸§à¸“à¸„à¸°à¹à¸™à¸™à¸£à¸§à¸¡à¹à¸¥à¸°à¸•à¸±à¸”à¹€à¸à¸£à¸”à¸­à¸±à¸•à¹‚à¸™à¸¡à¸±à¸•à¸´ (A à¸–à¸¶à¸‡ F)
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
            NEW.grade_display := 'C+ (2.5) âš ï¸';
            NEW.is_warning := TRUE;
        ELSIF NEW.total_score >= 60 THEN
            NEW.grade_letter := 'C';
            NEW.grade_point := 2.00;
            NEW.grade_display := 'C (2.0) âš ï¸';
            NEW.is_warning := TRUE;
        ELSIF NEW.total_score >= 55 THEN
            NEW.grade_letter := 'D+';
            NEW.grade_point := 1.50;
            NEW.grade_display := 'D+ (1.5) âš ï¸';
            NEW.is_warning := TRUE;
        ELSIF NEW.total_score >= 50 THEN
            NEW.grade_letter := 'D';
            NEW.grade_point := 1.00;
            NEW.grade_display := 'D (1.0) âš ï¸';
            NEW.is_warning := TRUE;
        ELSE
            NEW.grade_letter := 'F';
            NEW.grade_point := 0.00;
            NEW.grade_display := 'F (0.0) âš ï¸';
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

-- 2. Stored Function à¸ªà¸³à¸«à¸£à¸±à¸šà¸•à¸£à¸§à¸ˆà¸ªà¸­à¸šà¸à¸²à¸£à¹€à¸‚à¹‰à¸²à¸ªà¸¹à¹ˆà¸£à¸°à¸šà¸šà¸”à¹‰à¸§à¸¢à¸­à¸µà¹€à¸¡à¸¥à¹à¸¥à¸°à¸£à¸«à¸±à¸ªà¸œà¹ˆà¸²à¸™à¸ˆà¸£à¸´à¸‡ (bcrypt verification)
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
    total_credits_required INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id AS user_id,
        u.email,
        u.role,
        s.student_id,
        t.teacher_id,
        CAST(
            CASE
                WHEN u.role = 'teacher' THEN COALESCE(t.academic_rank || t.first_name_th || ' ' || t.last_name_th, u.email)
                ELSE COALESCE(s.prefix_th || s.first_name_th || ' ' || s.last_name_th, u.email)
            END AS VARCHAR
        ) AS display_name,
        CAST(
            CASE
                WHEN u.role = 'teacher' THEN COALESCE(t.teacher_id || ' â€¢ à¸ à¸²à¸„à¸§à¸´à¸Šà¸²' || td.name_th, 'à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ')
                ELSE COALESCE(s.student_id || ' â€¢ ' || sd.name_th || ' à¸›à¸µ ' || s.year_level, 'à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²')
            END AS VARCHAR
        ) AS subtitle_info,
        COALESCE(s.gpax, 0.00) AS gpax,
        COALESCE(s.current_term_gpa, 0.00) AS current_term_gpa,
        COALESCE(s.earned_credits, 0) AS earned_credits,
        COALESCE(sd.total_credits_required, 132) AS total_credits_required
    FROM public.users u
    LEFT JOIN public.students s ON s.user_id = u.id
    LEFT JOIN public.departments sd ON s.department_id = sd.id
    LEFT JOIN public.teachers t ON t.user_id = u.id
    LEFT JOIN public.departments td ON t.department_id = td.id
    WHERE LOWER(TRIM(u.email)) = LOWER(TRIM(p_email))
      AND u.is_active = TRUE
      AND u.password_hash = crypt(p_password, u.password_hash);
END;
$$;

-- =============================================================================
-- à¸ªà¹ˆà¸§à¸™à¸—à¸µà¹ˆ 3: Views à¸ªà¸³à¹€à¸£à¹‡à¸ˆà¸£à¸¹à¸› 6 Views à¸ªà¸³à¸«à¸£à¸±à¸šà¹ƒà¸«à¹‰ Backend à¹à¸¥à¸° Flutter à¹€à¸£à¸µà¸¢à¸à¹ƒà¸Šà¹‰à¸‡à¸²à¸™
-- =============================================================================

-- View 1: à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¹‚à¸›à¸£à¹„à¸Ÿà¸¥à¹Œà¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¸‰à¸šà¸±à¸šà¹€à¸•à¹‡à¸¡
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
    s.citizen_id,
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

-- View 2: à¸•à¸²à¸£à¸²à¸‡à¹€à¸£à¸µà¸¢à¸™à¹à¸¥à¸°à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¸‚à¸­à¸‡à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¹ƒà¸™à¹€à¸—à¸­à¸¡à¸›à¸±à¸ˆà¸ˆà¸¸à¸šà¸±à¸™ (à¸£à¸­à¸‡à¸£à¸±à¸šà¸à¸²à¸£à¸à¸£à¸­à¸‡à¸•à¸²à¸¡à¸§à¸±à¸™ MON-FRI)
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

-- View 3: à¸•à¸²à¸£à¸²à¸‡à¸ªà¸­à¸™à¹à¸¥à¸°à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¸‚à¸­à¸‡à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œà¹ƒà¸™à¹€à¸—à¸­à¸¡à¸›à¸±à¸ˆà¸ˆà¸¸à¸šà¸±à¸™
CREATE OR REPLACE VIEW public.v_teacher_timetable
WITH (security_invoker = true)
AS
SELECT
    cs.teacher_id,
    tm.term_label,
    sub.subject_code AS code,
    ('à¸ªà¸­à¸™ ' || sub.name_th) AS timetable_name,
    sub.name_th AS course_name,
    cs.section_number AS section,
    cs.day_of_week,
    cs.time_display AS time,
    cs.room,
    (cs.enrolled_count || ' à¸„à¸™') AS student_count_label,
    cs.enrolled_count,
    cs.max_students,
    COALESCE(cs.status_teacher_badge, '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­') AS status,
    COALESCE(cs.course_summary_teacher, '') AS course_summary,
    cs.course_progress AS progress
FROM public.course_sections cs
JOIN public.subjects sub ON cs.subject_code = sub.subject_code
JOIN public.academic_terms tm ON cs.term_id = tm.id
WHERE tm.is_current = TRUE;

-- View 4: à¹ƒà¸šà¸à¸£à¸­à¸à¸„à¸°à¹à¸™à¸™à¹à¸¥à¸°à¸•à¸±à¸”à¹€à¸à¸£à¸”à¸ªà¸³à¸«à¸£à¸±à¸šà¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ (GradeSubmitScreen)
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

-- View 5: à¸œà¸¥à¸à¸²à¸£à¹€à¸£à¸µà¸¢à¸™à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¸‚à¸­à¸‡à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸² (GradesScreen)
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

-- View 6: à¸›à¸£à¸°à¸§à¸±à¸•à¸´à¸à¸²à¸£à¸Šà¸³à¸£à¸°à¹€à¸‡à¸´à¸™à¸„à¹ˆà¸²à¹€à¸—à¸­à¸¡à¹à¸¥à¸°à¹ƒà¸šà¹€à¸ªà¸£à¹‡à¸ˆà¸£à¸±à¸šà¹€à¸‡à¸´à¸™à¸‚à¸­à¸‡à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸² (e-Receipt)
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
-- à¸ªà¹ˆà¸§à¸™à¸—à¸µà¹ˆ 4: à¸•à¸±à¹‰à¸‡à¸„à¹ˆà¸² Supabase Storage Buckets à¸ªà¸³à¸«à¸£à¸±à¸šà¹€à¸à¹‡à¸šà¹„à¸Ÿà¸¥à¹Œà¹à¸¥à¸°à¸£à¸¹à¸›à¸ à¸²à¸ž
-- =============================================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'storage' AND table_name = 'buckets') THEN
        INSERT INTO storage.buckets (id, name, public)
        VALUES
            ('avatars', 'avatars', true),
            ('submissions', 'submissions', true),
            ('receipts', 'receipts', true),
            ('materials', 'materials', true)
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- =============================================================================
-- à¸ªà¹ˆà¸§à¸™à¸—à¸µà¹ˆ 5: à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸ªà¸¡à¸¡à¸•à¸´à¸£à¸°à¸”à¸±à¸šà¸¡à¸«à¸²à¸§à¸´à¸—à¸¢à¸²à¸¥à¸±à¸¢ (Seed Mock Data)
-- =============================================================================

-- 1. à¸„à¸“à¸°à¸§à¸´à¸Šà¸² (4 à¸„à¸“à¸°à¸«à¸¥à¸±à¸à¸‚à¸­à¸‡ à¸¡à¸—à¸£.à¸žà¸£à¸°à¸™à¸„à¸£)
INSERT INTO public.faculties (id, code, name_th, name_en, campus, building, phone, website_url)
VALUES
    ('11111111-1111-1111-1111-111111111101', 'ENG', 'à¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ', 'Faculty of Engineering', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 'à¸­à¸²à¸„à¸²à¸£ 16 (à¸•à¸¶à¸à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ)', '02-665-3777 à¸•à¹ˆà¸­ 7000', 'https://eng.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111102', 'BUS', 'à¸„à¸“à¸°à¸šà¸£à¸´à¸«à¸²à¸£à¸˜à¸¸à¸£à¸à¸´à¸ˆ', 'Faculty of Business Administration', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸“à¸´à¸Šà¸¢à¸à¸²à¸£à¸žà¸£à¸°à¸™à¸„à¸£', 'à¸­à¸²à¸„à¸²à¸£ 1', '02-665-3555', 'https://bus.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111103', 'SCI', 'à¸„à¸“à¸°à¸§à¸´à¸—à¸¢à¸²à¸¨à¸²à¸ªà¸•à¸£à¹Œà¹à¸¥à¸°à¹€à¸—à¸„à¹‚à¸™à¹‚à¸¥à¸¢à¸µ', 'Faculty of Science and Technology', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 'à¸­à¸²à¸„à¸²à¸£à¹€à¸­à¸™à¸à¸›à¸£à¸°à¸ªà¸‡à¸„à¹Œ', '02-665-3777 à¸•à¹ˆà¸­ 6500', 'https://sci.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111104', 'ARC', 'à¸„à¸“à¸°à¸ªà¸–à¸²à¸›à¸±à¸•à¸¢à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œà¹à¸¥à¸°à¸à¸²à¸£à¸­à¸­à¸à¹à¸šà¸š', 'Faculty of Architecture and Design', 'à¸¨à¸¹à¸™à¸¢à¹Œà¹€à¸—à¹€à¸§à¸¨à¸£à¹Œ', 'à¸­à¸²à¸„à¸²à¸£à¸­à¸­à¸à¹à¸šà¸š', '02-665-3777 à¸•à¹ˆà¸­ 5000', 'https://arch.rmutp.ac.th')
ON CONFLICT (code) DO NOTHING;

-- 2. à¸ à¸²à¸„à¸§à¸´à¸Šà¸² / à¸ªà¸²à¸‚à¸²à¸§à¸´à¸Šà¸² (6 à¸ªà¸²à¸‚à¸²)
INSERT INTO public.departments (id, faculty_id, code, name_th, name_en, degree_name_th, total_credits_required)
VALUES
    ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'ENGCE', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œ', 'Computer Engineering', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• (à¸§à¸¨.à¸š.)', 132),
    ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111101', 'ENGEE', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¹„à¸Ÿà¸Ÿà¹‰à¸²', 'Electrical Engineering', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• (à¸§à¸¨.à¸š.)', 135),
    ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111101', 'ENGIE', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸­à¸¸à¸•à¸ªà¸²à¸«à¸à¸²à¸£', 'Industrial Engineering', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• (à¸§à¸¨.à¸š.)', 132),
    ('22222222-2222-2222-2222-222222222204', '11111111-1111-1111-1111-111111111102', 'BUSIS', 'à¸£à¸°à¸šà¸šà¸ªà¸²à¸£à¸ªà¸™à¹€à¸—à¸¨à¸—à¸²à¸‡à¸˜à¸¸à¸£à¸à¸´à¸ˆ', 'Business Information Systems', 'à¸šà¸£à¸´à¸«à¸²à¸£à¸˜à¸¸à¸£à¸à¸´à¸ˆà¸šà¸±à¸“à¸‘à¸´à¸• (à¸šà¸˜.à¸š.)', 126),
    ('22222222-2222-2222-2222-222222222205', '11111111-1111-1111-1111-111111111103', 'SCICS', 'à¸§à¸´à¸—à¸¢à¸²à¸à¸²à¸£à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œ', 'Computer Science', 'à¸§à¸´à¸—à¸¢à¸²à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• (à¸§à¸—.à¸š.)', 128),
    ('22222222-2222-2222-2222-222222222206', '11111111-1111-1111-1111-111111111103', 'SCIDS', 'à¸§à¸´à¸—à¸¢à¸²à¸à¸²à¸£à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¹à¸¥à¸°à¸ªà¸²à¸£à¸ªà¸™à¹€à¸—à¸¨', 'Data Science and Information', 'à¸§à¸´à¸—à¸¢à¸²à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• (à¸§à¸—.à¸š.)', 128)
ON CONFLICT (code) DO NOTHING;

-- 3. à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£à¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸² (Curriculums)
INSERT INTO public.curriculums (id, department_id, curriculum_code, name_th, revision_year, total_credits)
VALUES
    ('29999999-2999-2999-2999-299999999901', '22222222-2222-2222-2222-222222222201', 'B.Eng-CE-2565', 'à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• à¸ªà¸²à¸‚à¸²à¸§à¸´à¸Šà¸²à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œ (à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£à¸›à¸£à¸±à¸šà¸›à¸£à¸¸à¸‡ à¸ž.à¸¨. 2565)', 2565, 132),
    ('29999999-2999-2999-2999-299999999902', '22222222-2222-2222-2222-222222222205', 'B.Sc-CS-2565', 'à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£à¸§à¸´à¸—à¸¢à¸²à¸¨à¸²à¸ªà¸•à¸£à¸šà¸±à¸“à¸‘à¸´à¸• à¸ªà¸²à¸‚à¸²à¸§à¸´à¸Šà¸²à¸§à¸´à¸—à¸¢à¸²à¸à¸²à¸£à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œ (à¸ž.à¸¨. 2565)', 2565, 128)
ON CONFLICT (curriculum_code) DO NOTHING;

-- 4. à¸­à¸²à¸„à¸²à¸£à¹à¸¥à¸°à¸«à¹‰à¸­à¸‡à¹€à¸£à¸µà¸¢à¸™ (Buildings & Rooms)
INSERT INTO public.buildings_rooms (room_code, building_no, building_name_th, campus, floor_no, room_type, capacity)
VALUES
    ('à¸«à¹‰à¸­à¸‡ 1604', '16', 'à¸­à¸²à¸„à¸²à¸£à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ 16', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 6, 'lecture', 45),
    ('à¸«à¹‰à¸­à¸‡ 1602', '16', 'à¸­à¸²à¸„à¸²à¸£à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ 16', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 6, 'lecture', 45),
    ('à¸«à¹‰à¸­à¸‡ 1605', '16', 'à¸­à¸²à¸„à¸²à¸£à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ 16', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 6, 'lecture', 45),
    ('Lab 1502', '15', 'à¸­à¸²à¸„à¸²à¸£à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œà¹à¸¥à¸°à¹€à¸„à¸£à¸·à¸­à¸‚à¹ˆà¸²à¸¢ 15', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 5, 'computer_lab', 40),
    ('Lab 1504', '15', 'à¸­à¸²à¸„à¸²à¸£à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œà¹à¸¥à¸°à¹€à¸„à¸£à¸·à¸­à¸‚à¹ˆà¸²à¸¢ 15', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 5, 'computer_lab', 40),
    ('à¸«à¹‰à¸­à¸‡ 1201', '12', 'à¸­à¸²à¸„à¸²à¸£à¹€à¸£à¸µà¸¢à¸™à¸£à¸§à¸¡à¸§à¸´à¸—à¸¢à¸²à¸¨à¸²à¸ªà¸•à¸£à¹Œ', 'à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸£à¸°à¸™à¸„à¸£à¹€à¸«à¸™à¸·à¸­', 2, 'lecture', 60),
    ('à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œ MS Teams', 'ONLINE', 'à¸£à¸°à¸šà¸šà¸«à¹‰à¸­à¸‡à¹€à¸£à¸µà¸¢à¸™à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œ Microsoft Teams', 'à¸—à¸¸à¸à¸¨à¸¹à¸™à¸¢à¹Œà¸žà¸·à¹‰à¸™à¸—à¸µà¹ˆ', 1, 'online', 200)
ON CONFLICT (room_code) DO NOTHING;

-- 5. à¸›à¸µà¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸²à¹à¸¥à¸°à¸ à¸²à¸„à¹€à¸£à¸µà¸¢à¸™ (Academic Terms)
INSERT INTO public.academic_terms (id, academic_year, semester, term_label, start_date, end_date, midterm_start_date, midterm_end_date, final_start_date, final_end_date, grade_submit_deadline, is_current)
VALUES
    ('33333333-3333-3333-3333-333333333301', 2568, 2, '2/2568', '2025-11-15', '2026-03-31', '2026-01-12', '2026-01-16', '2026-03-16', '2026-03-27', '2026-04-05', FALSE),
    ('33333333-3333-3333-3333-333333333302', 2569, 1, '1/2569', '2026-06-15', '2026-10-31', '2026-10-13', '2026-10-17', '2026-10-26', '2026-10-30', '2026-09-30', TRUE)
ON CONFLICT (academic_year, semester) DO NOTHING;

-- 6. à¸›à¸à¸´à¸—à¸´à¸™à¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸² (Academic Calendar Events)
DELETE FROM public.academic_calendar_events WHERE term_id = '33333333-3333-3333-3333-333333333302';
INSERT INTO public.academic_calendar_events (term_id, title, date_display, event_type, start_date, end_date, description)
VALUES
    ('33333333-3333-3333-3333-333333333302', 'à¸«à¸¡à¸”à¹€à¸‚à¸•à¸ªà¹ˆà¸‡ HW6', '23 à¸.à¸¢.', 'deadline', '2026-09-23', '2026-09-23', 'à¸à¸³à¸«à¸™à¸”à¸ªà¹ˆà¸‡à¸à¸²à¸£à¸šà¹‰à¸²à¸™ HW6 à¸§à¸´à¸Šà¸² ENGCE302 à¸£à¸°à¸šà¸šà¸à¸²à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥ à¸ à¸²à¸¢à¹ƒà¸™à¹€à¸§à¸¥à¸² 23:59 à¸™.'),
    ('33333333-3333-3333-3333-333333333302', 'à¸›à¸´à¸”à¸£à¸±à¸šà¸—à¸¸à¸™ / à¸–à¸­à¸™à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²', '30 à¸.à¸¢.', 'scholarship', '2026-09-30', '2026-09-30', 'à¸§à¸±à¸™à¸ªà¸¸à¸”à¸—à¹‰à¸²à¸¢à¸‚à¸­à¸‡à¸à¸²à¸£à¸¢à¸·à¹ˆà¸™à¸‚à¸­à¸—à¸¸à¸™à¹€à¸£à¸µà¸¢à¸™à¸”à¸µà¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸¯ à¹à¸¥à¸°à¸à¸²à¸£à¸–à¸­à¸™à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¸•à¸´à¸” W'),
    ('33333333-3333-3333-3333-333333333302', 'à¸ªà¸±à¸¡à¸ à¸²à¸©à¸“à¹Œà¸ªà¸«à¸à¸´à¸ˆ', '5 à¸•.à¸„.', 'coop', '2026-10-05', '2026-10-05', 'à¸ªà¸±à¸¡à¸ à¸²à¸©à¸“à¹Œà¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¸ªà¸«à¸à¸´à¸ˆà¸¨à¸¶à¸à¸©à¸² à¸“ à¸¨à¸¹à¸™à¸¢à¹Œà¸ªà¸«à¸à¸´à¸ˆà¸¨à¸¶à¸à¸©à¸²à¹à¸¥à¸°à¸žà¸±à¸’à¸™à¸²à¸­à¸²à¸Šà¸µà¸ž'),
    ('33333333-3333-3333-3333-333333333302', 'à¸ªà¸­à¸šà¸à¸¥à¸²à¸‡à¸ à¸²à¸„', '13â€“17 à¸•.à¸„.', 'exam', '2026-10-13', '2026-10-17', 'à¸ªà¸±à¸›à¸”à¸²à¸«à¹Œà¸à¸²à¸£à¸ªà¸­à¸šà¸à¸¥à¸²à¸‡à¸ à¸²à¸„à¹€à¸£à¸µà¸¢à¸™à¸—à¸µà¹ˆ 1 à¸›à¸µà¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸² 2569');

-- 7. à¸šà¸±à¸à¸Šà¸µà¸œà¸¹à¹‰à¹ƒà¸Šà¹‰ (Users - à¸£à¸«à¸±à¸ªà¸œà¹ˆà¸²à¸™à¸—à¸¸à¸à¸„à¸™à¸„à¸·à¸­ password123 à¹€à¸‚à¹‰à¸²à¸£à¸«à¸±à¸ªà¸”à¹‰à¸§à¸¢ bcrypt)
INSERT INTO public.users (id, email, password_hash, role, preferred_language, notification_enabled)
VALUES
    -- à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ 4 à¸—à¹ˆà¸²à¸™
    ('44444444-4444-4444-4444-444444444401', 'surachai.w@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444402', 'naphat.c@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444403', 'kittipong.t@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444404', 'praewpan.s@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'teacher', 'th', TRUE),
    -- à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸² 12 à¸„à¸™ (à¸£à¸«à¸±à¸ª 650602001 à¸–à¸¶à¸‡ 650602012)
    ('44444444-4444-4444-4444-444444444411', 's650602001@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444412', 's650602002@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444413', 's650602003@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444414', 's650602004@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444415', 's650602005@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444416', 's650602006@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444417', 's650602007@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444418', 's650602008@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444419', 's650602009@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444420', 's650602010@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444421', 's650602011@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444422', 's650602012@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE)
ON CONFLICT (email) DO NOTHING;

-- 8. à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ (Teachers)
INSERT INTO public.teachers (teacher_id, user_id, academic_rank, first_name_th, last_name_th, first_name_en, last_name_en, face_photo_url, faculty_id, department_id, office_room, phone, line_id)
VALUES
    ('T-1024', '44444444-4444-4444-4444-444444444401', 'à¸­.', 'à¸ªà¸¸à¸£à¸Šà¸±à¸¢', 'à¸§à¸‡à¸¨à¹Œà¹ƒà¸«à¸à¹ˆ', 'Surachai', 'Wongyai', 'https://ui-avatars.com/api/?name=Surachai+W&background=652D91&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'à¸«à¹‰à¸­à¸‡à¸žà¸±à¸à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ 1608', '081-234-5678', '@aj_surachai'),
    ('T-1025', '44444444-4444-4444-4444-444444444402', 'à¸œà¸¨.', 'à¸™à¸ à¸±à¸ª', 'à¹€à¸ˆà¸£à¸´à¸à¸œà¸¥', 'Naphat', 'Charoenphon', 'https://ui-avatars.com/api/?name=Naphat+C&background=652D91&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'à¸«à¹‰à¸­à¸‡à¸žà¸±à¸à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ 1504', '089-876-5432', '@aj_naphat'),
    ('T-1026', '44444444-4444-4444-4444-444444444403', 'à¸£à¸¨.à¸”à¸£.', 'à¸à¸´à¸•à¸•à¸´à¸žà¸‡à¸¨à¹Œ', 'à¸˜à¸µà¸£à¹€à¸¡à¸˜', 'Kittipong', 'Theerameth', 'https://ui-avatars.com/api/?name=Kittipong+T&background=2A114B&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'à¸«à¹‰à¸­à¸‡à¸žà¸±à¸à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ 1610', '081-555-7890', '@aj_kittipong'),
    ('T-1027', '44444444-4444-4444-4444-444444444404', 'à¸­.à¸”à¸£.', 'à¹à¸žà¸£à¸§à¸žà¸£à¸£à¸“', 'à¸¨à¸´à¸£à¸´à¸à¸¸à¸¥', 'Praewpan', 'Sirikul', 'https://ui-avatars.com/api/?name=Praewpan+S&background=431B6E&color=fff&size=256', '11111111-1111-1111-1111-111111111103', '22222222-2222-2222-2222-222222222205', 'à¸«à¹‰à¸­à¸‡à¸žà¸±à¸à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ SC-302', '086-444-3210', '@aj_praewpan')
ON CONFLICT (teacher_id) DO NOTHING;

-- 9. à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸›à¸£à¸°à¸§à¸±à¸•à¸´à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¹€à¸Šà¸´à¸‡à¸¥à¸¶à¸ 12 à¸„à¸™ (Students)
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
    ('650602001', '44444444-4444-4444-4444-444444444411', 'à¸™.à¸ª.', 'à¸¡à¸´à¸™à¸•à¸£à¸²', 'à¹ƒà¸ˆà¸”à¸µ', 'Mintra', 'Jaidee', '1100501234501', '2004-05-14', 'female', 'O', 'https://ui-avatars.com/api/?name=Mintra+J&background=F6DC04&color=2A114B&size=256', 'https://rmutp.ac.th/storage/v1/object/public/avatars/card_650602001.png', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.42, 3.55, 87, '092-345-6789', 'mintra.jaidee@gmail.com', 'mintra_ce65', 'à¸«à¸­à¸žà¸±à¸à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¹€à¸„à¸µà¸¢à¸‡à¸¡à¸­ à¸«à¹‰à¸­à¸‡ 402 à¸‹.à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡ 11', '99/12 à¸«à¸¡à¸¹à¹ˆ 4 à¸–.à¸žà¸´à¸šà¸¹à¸¥à¸ªà¸‡à¸„à¸£à¸²à¸¡', 'à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10800', 'à¸™à¸²à¸‡à¸ªà¸¡à¸¨à¸£à¸µ à¹ƒà¸ˆà¸”à¸µ', 'à¸¡à¸²à¸£à¸”à¸²', '081-999-8877'),
    ('650602002', '44444444-4444-4444-4444-444444444412', 'à¸™à¸²à¸¢', 'à¸ à¸¹à¸£à¸´', 'à¸žà¸±à¸’à¸™à¸²à¸à¸¸à¸¥', 'Phuri', 'Phattanakul', '1100501234502', '2004-08-21', 'male', 'A', 'https://ui-avatars.com/api/?name=Phuri+P&background=652D91&color=fff&size=256', 'https://rmutp.ac.th/storage/v1/object/public/avatars/card_650602002.png', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.15, 3.20, 87, '095-111-2233', 'phuri.dev@gmail.com', 'phuri_ce65', 'à¸„à¸­à¸™à¹‚à¸”à¹€à¸”à¸­à¸°à¸—à¸£à¸µ à¸­à¸´à¸™à¹€à¸•à¸­à¸£à¹Œà¹€à¸Šà¸™à¸ˆà¹Œ à¸Šà¸±à¹‰à¸™ 12', '45/8 à¸–.à¸›à¸£à¸°à¸Šà¸²à¸£à¸²à¸©à¸Žà¸£à¹Œà¸ªà¸²à¸¢ 1', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10800', 'à¸™à¸²à¸¢à¸§à¸´à¸Šà¸±à¸¢ à¸žà¸±à¸’à¸™à¸²à¸à¸¸à¸¥', 'à¸šà¸´à¸”à¸²', '086-555-4433'),
    ('650602003', '44444444-4444-4444-4444-444444444413', 'à¸™.à¸ª.', 'à¸à¸±à¸™à¸¢à¸²', 'à¸£à¸±à¸•à¸™à¹‚à¸Šà¸•à¸´', 'Kanya', 'Rattanachot', '1100501234503', '2004-11-03', 'female', 'B', 'https://ui-avatars.com/api/?name=Kanya+R&background=E91E63&color=fff&size=256', 'https://rmutp.ac.th/storage/v1/object/public/avatars/card_650602003.png', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 2.65, 2.75, 84, '098-765-4321', 'kanya.rat@gmail.com', 'kanya_ce65', '120/5 à¸‹.à¸ˆà¸£à¸±à¸à¸ªà¸™à¸´à¸—à¸§à¸‡à¸¨à¹Œ 96/1', '120/5 à¸‹.à¸ˆà¸£à¸±à¸à¸ªà¸™à¸´à¸—à¸§à¸‡à¸¨à¹Œ 96/1', 'à¸šà¸²à¸‡à¸­à¹‰à¸­', 'à¸šà¸²à¸‡à¸žà¸¥à¸±à¸”', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10700', 'à¸™à¸²à¸‡à¸à¸±à¸¥à¸¢à¸² à¸£à¸±à¸•à¸™à¹‚à¸Šà¸•à¸´', 'à¸¡à¸²à¸£à¸”à¸²', '089-123-4567'),
    ('650602004', '44444444-4444-4444-4444-444444444414', 'à¸™à¸²à¸¢', 'à¸˜à¸™à¸ à¸±à¸—à¸£', 'à¸¨à¸£à¸µà¸ªà¸¸à¸§à¸£à¸£à¸“', 'Thanaphat', 'Srisuwan', '1100501234504', '2004-02-19', 'male', 'O', 'https://ui-avatars.com/api/?name=Thanaphat+S&background=1E88E5&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.68, 3.75, 87, '081-222-3344', 'thanaphat.s@gmail.com', 'thana_ce65', '88/4 à¸‹.à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡ 7', '88/4 à¸‹.à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡ 7', 'à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10800', 'à¸™à¸²à¸¢à¸ªà¸¡à¸Šà¸²à¸¢ à¸¨à¸£à¸µà¸ªà¸¸à¸§à¸£à¸£à¸“', 'à¸šà¸´à¸”à¸²', '081-222-0000'),
    ('650602005', '44444444-4444-4444-4444-444444444415', 'à¸™.à¸ª.', 'à¸žà¸´à¸¡à¸Šà¸™à¸', 'à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¸±à¸ªà¸”à¸´à¹Œ', 'Pimchanok', 'Wongsawat', '1100501234505', '2004-04-10', 'female', 'A', 'https://ui-avatars.com/api/?name=Pimchanok+W&background=8E24AA&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.50, 3.60, 87, '082-333-4455', 'pimchanok.w@gmail.com', 'pim_ce65', '42/1 à¸–.à¸à¸£à¸¸à¸‡à¹€à¸—à¸ž-à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', '42/1 à¸–.à¸à¸£à¸¸à¸‡à¹€à¸—à¸ž-à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10800', 'à¸™à¸²à¸‡à¸›à¸£à¸²à¸“à¸µ à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¸±à¸ªà¸”à¸´à¹Œ', 'à¸¡à¸²à¸£à¸”à¸²', '082-333-0000'),
    ('650602006', '44444444-4444-4444-4444-444444444416', 'à¸™à¸²à¸¢', 'à¸“à¸±à¸à¸§à¸¸à¸’à¸´', 'à¹€à¸ˆà¸£à¸´à¸à¸ªà¸¸à¸‚', 'Nattawut', 'Charoensuk', '1100501234506', '2004-07-25', 'male', 'AB', 'https://ui-avatars.com/api/?name=Nattawut+C&background=00897B&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 2.95, 3.00, 87, '083-444-5566', 'nattawut.c@gmail.com', 'nat_ce65', '15/9 à¸–.à¸•à¸´à¸§à¸²à¸™à¸™à¸—à¹Œ', '15/9 à¸–.à¸•à¸´à¸§à¸²à¸™à¸™à¸—à¹Œ', 'à¸•à¸¥à¸²à¸”à¸‚à¸§à¸±à¸', 'à¹€à¸¡à¸·à¸­à¸‡à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', 'à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', '11000', 'à¸™à¸²à¸¢à¹€à¸ˆà¸£à¸´à¸ à¹€à¸ˆà¸£à¸´à¸à¸ªà¸¸à¸‚', 'à¸šà¸´à¸”à¸²', '083-444-0000'),
    ('650602007', '44444444-4444-4444-4444-444444444417', 'à¸™.à¸ª.', 'à¸Šà¸¥à¸˜à¸´à¸Šà¸²', 'à¸­à¸ à¸´à¸£à¸±à¸à¸©à¹Œ', 'Chonthicha', 'Apirak', '1100501234507', '2004-09-12', 'female', 'B', 'https://ui-avatars.com/api/?name=Chonthicha+A&background=F4511E&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 3.25, 3.30, 87, '084-555-6677', 'chonthicha.a@gmail.com', 'chon_ce65', '77/3 à¸–.à¸™à¸„à¸£à¸­à¸´à¸™à¸—à¸£à¹Œ', '77/3 à¸–.à¸™à¸„à¸£à¸­à¸´à¸™à¸—à¸£à¹Œ', 'à¸šà¸²à¸‡à¸‚à¸¸à¸™à¸à¸­à¸‡', 'à¸šà¸²à¸‡à¸à¸£à¸§à¸¢', 'à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', '11130', 'à¸™à¸²à¸‡à¸™à¸´à¸•à¸¢à¸² à¸­à¸ à¸´à¸£à¸±à¸à¸©à¹Œ', 'à¸¡à¸²à¸£à¸”à¸²', '084-555-0000'),
    ('650602008', '44444444-4444-4444-4444-444444444418', 'à¸™à¸²à¸¢', 'à¸¨à¸¸à¸ à¸à¸£', 'à¹€à¸à¸µà¸¢à¸£à¸•à¸´à¸„à¸¸à¸“', 'Supakorn', 'Kiatkhun', '1100501234508', '2004-01-30', 'male', 'O', 'https://ui-avatars.com/api/?name=Supakorn+K&background=3949AB&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 2.80, 2.85, 84, '085-666-7788', 'supakorn.k@gmail.com', 'supa_ce65', '33/2 à¸‹.à¸›à¸£à¸°à¸Šà¸²à¸Šà¸·à¹ˆà¸™ 12', '33/2 à¸‹.à¸›à¸£à¸°à¸Šà¸²à¸Šà¸·à¹ˆà¸™ 12', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10800', 'à¸™à¸²à¸¢à¹€à¸à¸µà¸¢à¸£à¸•à¸´ à¹€à¸à¸µà¸¢à¸£à¸•à¸´à¸„à¸¸à¸“', 'à¸šà¸´à¸”à¸²', '085-666-0000'),
    ('650602009', '44444444-4444-4444-4444-444444444419', 'à¸™.à¸ª.', 'à¸›à¸ à¸²à¸§à¸£à¸´à¸™à¸—à¹Œ', 'à¹€à¸¥à¸´à¸¨à¸ªà¸à¸¸à¸¥', 'Paphawarin', 'Lertsakul', '1100501234509', '2004-06-18', 'female', 'A', 'https://ui-avatars.com/api/?name=Paphawarin+L&background=D81B60&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 3.82, 3.90, 87, '086-777-8899', 'paphawarin.l@gmail.com', 'papha_ce65', '50/6 à¸–.à¸£à¸±à¸Šà¸”à¸²à¸ à¸´à¹€à¸©à¸', '50/6 à¸–.à¸£à¸±à¸Šà¸”à¸²à¸ à¸´à¹€à¸©à¸', 'à¸¥à¸²à¸”à¸¢à¸²à¸§', 'à¸ˆà¸•à¸¸à¸ˆà¸±à¸à¸£', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10900', 'à¸™à¸²à¸‡à¸§à¸£à¸£à¸“à¸² à¹€à¸¥à¸´à¸¨à¸ªà¸à¸¸à¸¥', 'à¸¡à¸²à¸£à¸”à¸²', '086-777-0000'),
    ('650602010', '44444444-4444-4444-4444-444444444420', 'à¸™à¸²à¸¢', 'à¸à¸´à¸•à¸•à¸´à¸žà¸±à¸’à¸™à¹Œ', 'à¸˜à¸™à¸²à¸à¸¸à¸¥', 'Kittiphat', 'Thanakul', '1100501234510', '2004-12-05', 'male', 'B', 'https://ui-avatars.com/api/?name=Kittiphat+T&background=5E35B1&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 2.45, 2.50, 81, '087-888-9900', 'kittiphat.t@gmail.com', 'kitti_ce65', '19/4 à¸‹.à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡ 19', '19/4 à¸‹.à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡ 19', 'à¸§à¸‡à¸¨à¹Œà¸ªà¸§à¹ˆà¸²à¸‡', 'à¸šà¸²à¸‡à¸‹à¸·à¹ˆà¸­', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10800', 'à¸™à¸²à¸¢à¸˜à¸™à¸² à¸˜à¸™à¸²à¸à¸¸à¸¥', 'à¸šà¸´à¸”à¸²', '087-888-0000'),
    ('650602011', '44444444-4444-4444-4444-444444444421', 'à¸™.à¸ª.', 'à¸“à¸±à¸à¸“à¸´à¸Šà¸²', 'à¸žà¸‡à¸¨à¹Œà¹„à¸žà¸šà¸¹à¸¥à¸¢à¹Œ', 'Natnicha', 'Pongpaiboon', '1100501234511', '2004-03-22', 'female', 'O', 'https://ui-avatars.com/api/?name=Natnicha+P&background=039BE5&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1025', 2565, 2, 'studying', 3.35, 3.40, 87, '088-999-0011', 'natnicha.p@gmail.com', 'natni_ce65', '64/2 à¸–.à¸žà¸´à¸šà¸¹à¸¥à¸ªà¸‡à¸„à¸£à¸²à¸¡', '64/2 à¸–.à¸žà¸´à¸šà¸¹à¸¥à¸ªà¸‡à¸„à¸£à¸²à¸¡', 'à¸ªà¸§à¸™à¹ƒà¸«à¸à¹ˆ', 'à¹€à¸¡à¸·à¸­à¸‡à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', 'à¸™à¸™à¸—à¸šà¸¸à¸£à¸µ', '11000', 'à¸™à¸²à¸‡à¸™à¸´à¸ à¸² à¸žà¸‡à¸¨à¹Œà¹„à¸žà¸šà¸¹à¸¥à¸¢à¹Œ', 'à¸¡à¸²à¸£à¸”à¸²', '088-999-0000'),
    ('650602012', '44444444-4444-4444-4444-444444444422', 'à¸™à¸²à¸¢', 'à¸ à¸±à¸—à¸£à¸žà¸¥', 'à¸­à¸±à¸¨à¸§à¹€à¸¡à¸˜à¸µ', 'Phattharaphon', 'Asawamethee', '1100501234512', '2004-10-15', 'male', 'A', 'https://ui-avatars.com/api/?name=Phattharaphon+A&background=43A047&color=fff&size=256', NULL, '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', '29999999-2999-2999-2999-299999999901', 'T-1024', 2565, 2, 'studying', 3.10, 3.15, 87, '089-000-1122', 'phattharaphon.a@gmail.com', 'phat_ce65', '102/7 à¸–.à¸ªà¸²à¸¡à¹€à¸ªà¸™', '102/7 à¸–.à¸ªà¸²à¸¡à¹€à¸ªà¸™', 'à¸§à¸Šà¸´à¸£à¸žà¸¢à¸²à¸šà¸²à¸¥', 'à¸”à¸¸à¸ªà¸´à¸•', 'à¸à¸£à¸¸à¸‡à¹€à¸—à¸žà¸¡à¸«à¸²à¸™à¸„à¸£', '10300', 'à¸™à¸²à¸¢à¹€à¸¡à¸˜à¸µ à¸­à¸±à¸¨à¸§à¹€à¸¡à¸˜à¸µ', 'à¸šà¸´à¸”à¸²', '089-000-0000')
ON CONFLICT (student_id) DO NOTHING;

-- 10. à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¸•à¸²à¸¡à¸«à¸¥à¸±à¸à¸ªà¸¹à¸•à¸£ (Subjects - à¸„à¸£à¸­à¸šà¸„à¸¥à¸¸à¸¡à¸„à¸£à¸šà¸—à¸¸à¸à¸§à¸±à¸™ à¸ˆà¸±à¸™à¸—à¸£à¹Œ-à¸¨à¸¸à¸à¸£à¹Œ à¹à¸¥à¸°à¸§à¸´à¸Šà¸²à¹€à¸—à¸­à¸¡à¸à¹ˆà¸­à¸™)
INSERT INTO public.subjects (subject_code, department_id, name_th, name_en, credits, lecture_hours, lab_hours, self_study_hours, is_lab, prerequisite_code, description)
VALUES
    ('ENGCE302', '22222222-2222-2222-2222-222222222201', 'à¸£à¸°à¸šà¸šà¸à¸²à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥', 'Database Systems', 3, 2, 2, 5, FALSE, 'ENGCE301', 'à¸à¸²à¸£à¸­à¸­à¸à¹à¸šà¸šà¸à¸²à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¹€à¸Šà¸´à¸‡à¸ªà¸±à¸¡à¸žà¸±à¸™à¸˜à¹Œ ER Diagram, Normalization 3NF, SQL à¹à¸¥à¸°à¸à¸²à¸£à¸ˆà¸±à¸”à¸à¸²à¸£à¸˜à¸¸à¸£à¸à¸£à¸£à¸¡'),
    ('ENGCE305', '22222222-2222-2222-2222-222222222201', 'à¹€à¸„à¸£à¸·à¸­à¸‚à¹ˆà¸²à¸¢à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œ', 'Computer Networks', 3, 2, 2, 5, TRUE, NULL, 'à¸ªà¸–à¸²à¸›à¸±à¸•à¸¢à¸à¸£à¸£à¸¡à¹€à¸„à¸£à¸·à¸­à¸‚à¹ˆà¸²à¸¢ OSI Model, TCP/IP, Routing, Switching à¹à¸¥à¸°à¸„à¸§à¸²à¸¡à¸›à¸¥à¸­à¸”à¸ à¸±à¸¢à¹€à¸„à¸£à¸·à¸­à¸‚à¹ˆà¸²à¸¢'),
    ('ENGCE306', '22222222-2222-2222-2222-222222222201', 'à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸‹à¸­à¸Ÿà¸•à¹Œà¹à¸§à¸£à¹Œ', 'Software Engineering', 3, 3, 0, 6, FALSE, 'ENGCE301', 'à¸à¸£à¸°à¸šà¸§à¸™à¸à¸²à¸£à¸žà¸±à¸’à¸™à¸²à¸‹à¸­à¸Ÿà¸•à¹Œà¹à¸§à¸£à¹Œ Agile, Scrum, Requirements, UML Design à¹à¸¥à¸°à¸à¸²à¸£à¸—à¸”à¸ªà¸­à¸šà¸£à¸°à¸šà¸š'),
    ('ENGCE307', '22222222-2222-2222-2222-222222222201', 'à¹„à¸¡à¹‚à¸„à¸£à¸„à¸­à¸™à¹‚à¸—à¸£à¸¥à¹€à¸¥à¸­à¸£à¹Œà¹à¸¥à¸°à¸£à¸°à¸šà¸šà¸à¸±à¸‡à¸•à¸±à¸§', 'Microcontrollers and Embedded Systems', 3, 2, 2, 5, TRUE, NULL, 'à¸à¸²à¸£à¹€à¸‚à¸µà¸¢à¸™à¹‚à¸›à¸£à¹à¸à¸£à¸¡à¸„à¸§à¸šà¸„à¸¸à¸¡à¹„à¸¡à¹‚à¸„à¸£à¸„à¸­à¸™à¹‚à¸—à¸£à¸¥à¹€à¸¥à¸­à¸£à¹Œ ARM/ESP32 à¸à¸²à¸£à¹€à¸Šà¸·à¹ˆà¸­à¸¡à¸•à¹ˆà¸­à¹€à¸‹à¸™à¹€à¸‹à¸­à¸£à¹Œà¹à¸¥à¸° IoT'),
    ('ENGCE308', '22222222-2222-2222-2222-222222222201', 'à¸›à¸±à¸à¸à¸²à¸›à¸£à¸°à¸”à¸´à¸©à¸à¹Œà¹€à¸šà¸·à¹‰à¸­à¸‡à¸•à¹‰à¸™', 'Introduction to Artificial Intelligence', 3, 3, 0, 6, FALSE, 'MATH201', 'à¹à¸™à¸§à¸„à¸´à¸”à¸›à¸±à¸à¸à¸²à¸›à¸£à¸°à¸”à¸´à¸©à¸à¹Œ Machine Learning, Neural Networks à¹à¸¥à¸°à¸à¸²à¸£à¸›à¸£à¸°à¸¢à¸¸à¸à¸•à¹Œà¹ƒà¸Šà¹‰à¸‡à¸²à¸™'),
    ('GEN101', NULL, 'à¸ à¸²à¸©à¸²à¸­à¸±à¸‡à¸à¸¤à¸©à¹€à¸žà¸·à¹ˆà¸­à¸­à¸²à¸Šà¸µà¸ž', 'English for Careers', 3, 3, 0, 6, FALSE, NULL, 'à¸—à¸±à¸à¸©à¸°à¸à¸²à¸£à¸ªà¸·à¹ˆà¸­à¸ªà¸²à¸£à¸ à¸²à¸©à¸²à¸­à¸±à¸‡à¸à¸¤à¸©à¹ƒà¸™à¸à¸²à¸£à¸—à¸³à¸‡à¸²à¸™ à¸à¸²à¸£à¹€à¸‚à¸µà¸¢à¸™à¹€à¸£à¸‹à¸¹à¹€à¸¡à¹ˆ à¹à¸¥à¸°à¸à¸²à¸£à¸ªà¸±à¸¡à¸ à¸²à¸©à¸“à¹Œà¸‡à¸²à¸™'),
    ('ENGCE301', '22222222-2222-2222-2222-222222222201', 'à¹‚à¸„à¸£à¸‡à¸ªà¸£à¹‰à¸²à¸‡à¸‚à¹‰à¸­à¸¡à¸¹à¸¥', 'Data Structures', 3, 2, 2, 5, FALSE, NULL, 'à¹‚à¸„à¸£à¸‡à¸ªà¸£à¹‰à¸²à¸‡à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸žà¸·à¹‰à¸™à¸à¸²à¸™ Array, Linked List, Stack, Queue, Tree, Graph à¹à¸¥à¸°à¸­à¸±à¸¥à¸à¸­à¸£à¸´à¸—à¸¶à¸¡'),
    ('ENGCE303', '22222222-2222-2222-2222-222222222201', 'à¸£à¸°à¸šà¸šà¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£', 'Operating Systems', 3, 3, 0, 6, FALSE, NULL, 'à¸à¸²à¸£à¸ˆà¸±à¸”à¸à¸²à¸£à¹‚à¸›à¸£à¹€à¸‹à¸ª à¹€à¸˜à¸£à¸” à¸«à¸™à¹ˆà¸§à¸¢à¸„à¸§à¸²à¸¡à¸ˆà¸³ à¸£à¸°à¸šà¸šà¹„à¸Ÿà¸¥à¹Œ à¹à¸¥à¸° Deadlock'),
    ('MATH201', NULL, 'à¸ªà¸–à¸´à¸•à¸´à¸§à¸´à¸¨à¸§à¸°', 'Engineering Statistics', 3, 3, 0, 6, FALSE, NULL, 'à¸„à¸§à¸²à¸¡à¸™à¹ˆà¸²à¸ˆà¸°à¹€à¸›à¹‡à¸™ à¸•à¸±à¸§à¹à¸›à¸£à¸ªà¸¸à¹ˆà¸¡ à¸à¸²à¸£à¹à¸ˆà¸à¹à¸ˆà¸‡à¸„à¸§à¸²à¸¡à¸™à¹ˆà¸²à¸ˆà¸°à¹€à¸›à¹‡à¸™ à¹à¸¥à¸°à¸à¸²à¸£à¸—à¸”à¸ªà¸­à¸šà¸ªà¸¡à¸¡à¸•à¸´à¸à¸²à¸™à¸—à¸²à¸‡à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡')
ON CONFLICT (subject_code) DO NOTHING;

-- 11. à¸à¸¥à¸¸à¹ˆà¸¡à¹€à¸£à¸µà¸¢à¸™à¸—à¸µà¹ˆà¹€à¸›à¸´à¸”à¸ªà¸­à¸™ (Course Sections - à¸¡à¸µà¸„à¸£à¸šà¸ˆà¸±à¸™à¸—à¸£à¹Œà¸–à¸¶à¸‡à¸¨à¸¸à¸à¸£à¹Œ MON, TUE, WED, THU, FRI)
INSERT INTO public.course_sections (
    id, subject_code, term_id, section_number, teacher_id, day_of_week,
    start_time, end_time, time_display, room, max_students, enrolled_count,
    course_progress, status_student_badge, status_teacher_badge,
    course_summary_student, course_summary_teacher
)
VALUES
    -- à¸§à¸±à¸™à¸ˆà¸±à¸™à¸—à¸£à¹Œ (MON)
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1024', 'MON', '09:00', '12:00', '09:00â€“12:00', 'à¸«à¹‰à¸­à¸‡ 1604', 40, 12, 70, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¹à¸¥à¹‰à¸§', '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­', 'à¸‡à¸²à¸™à¸„à¹‰à¸²à¸‡ 1 â€¢ à¸„à¸°à¹à¸™à¸™à¹€à¸à¹‡à¸š 27/30', 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§ 8/12 â€¢ à¸£à¸­à¸•à¸£à¸§à¸ˆ 4 â€¢ à¸£à¸­à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”'),
    ('55555555-5555-5555-5555-555555555502', 'ENGCE305', '33333333-3333-3333-3333-333333333302', 'Sec.2', 'T-1025', 'MON', '13:00', '16:00', '13:00â€“16:00', 'Lab 1502', 40, 12, 45, 'à¹€à¸£à¸´à¹ˆà¸¡à¸šà¹ˆà¸²à¸¢à¸™à¸µà¹‰', '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­', 'à¸‡à¸²à¸™à¸„à¹‰à¸²à¸‡ 1 â€¢ Lab à¸ªà¸±à¸›à¸”à¸²à¸«à¹Œ 6', 'à¸¢à¸±à¸‡à¹„à¸¡à¹ˆà¹€à¸£à¸´à¹ˆà¸¡à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸” â€¢ 12 à¸„à¸™'),
    -- à¸§à¸±à¸™à¸­à¸±à¸‡à¸„à¸²à¸£ (TUE)
    ('55555555-5555-5555-5555-555555555504', 'ENGCE306', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1024', 'TUE', '09:00', '12:00', '09:00â€“12:00', 'à¸«à¹‰à¸­à¸‡ 1602', 40, 12, 60, 'à¸ªà¹ˆà¸‡ Sprint 2 à¹à¸¥à¹‰à¸§', '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­', 'à¹„à¸¡à¹ˆà¸¡à¸µà¸‡à¸²à¸™à¸„à¹‰à¸²à¸‡ â€¢ à¹‚à¸›à¸£à¹€à¸ˆà¸à¸•à¹Œà¸à¸¥à¸¸à¹ˆà¸¡', 'à¸•à¸£à¸§à¸ˆ Sprint 2 à¹à¸¥à¹‰à¸§ â€¢ 12 à¸„à¸™'),
    -- à¸§à¸±à¸™à¸žà¸¸à¸˜ (WED)
    ('55555555-5555-5555-5555-555555555503', 'GEN101', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1027', 'WED', '16:30', '18:00', '16:30â€“18:00', 'à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œ MS Teams', 60, 12, 55, 'à¹€à¸£à¸µà¸¢à¸™à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œ', '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­', 'à¹„à¸¡à¹ˆà¸¡à¸µà¸‡à¸²à¸™à¸„à¹‰à¸²à¸‡ â€¢ à¹€à¸£à¸µà¸¢à¸™à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œ', 'à¹€à¸£à¸µà¸¢à¸™à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œà¸£à¸§à¸¡'),
    -- à¸§à¸±à¸™à¸žà¸¤à¸«à¸±à¸ªà¸šà¸”à¸µ (THU)
    ('55555555-5555-5555-5555-555555555505', 'ENGCE307', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1026', 'THU', '13:00', '16:00', '13:00â€“16:00', 'Lab 1504', 40, 12, 50, 'à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£ IoT', '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­', 'à¹€à¸•à¸£à¸µà¸¢à¸¡à¸šà¸­à¸£à¹Œà¸” ESP32', 'à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£à¸ªà¸±à¸›à¸”à¸²à¸«à¹Œà¸—à¸µà¹ˆ 6'),
    -- à¸§à¸±à¸™à¸¨à¸¸à¸à¸£à¹Œ (FRI)
    ('55555555-5555-5555-5555-555555555506', 'ENGCE308', '33333333-3333-3333-3333-333333333302', 'Sec.1', 'T-1026', 'FRI', '09:00', '12:00', '09:00â€“12:00', 'à¸«à¹‰à¸­à¸‡ 1605', 40, 12, 65, 'à¸šà¸£à¸£à¸¢à¸²à¸¢à¸›à¸à¸•à¸´', '+ à¹€à¸›à¸´à¸”à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­', 'à¸­à¹ˆà¸²à¸™à¸šà¸—à¸„à¸§à¸²à¸¡ ML à¸¥à¹ˆà¸§à¸‡à¸«à¸™à¹‰à¸²', 'à¸ªà¸­à¸™à¸ªà¸±à¸›à¸”à¸²à¸«à¹Œà¸—à¸µà¹ˆ 6'),
    -- à¸£à¸²à¸¢à¸§à¸´à¸Šà¸²à¹€à¸—à¸­à¸¡à¸—à¸µà¹ˆà¸œà¹ˆà¸²à¸™à¸¡à¸² (2/2568)
    ('55555555-5555-5555-5555-555555555511', 'ENGCE301', '33333333-3333-3333-3333-333333333301', 'Sec.1', 'T-1024', 'TUE', '09:00', '12:00', '09:00â€“12:00', 'à¸«à¹‰à¸­à¸‡ 1602', 40, 12, 100, 'à¸ˆà¸šà¸£à¸²à¸¢à¸§à¸´à¸Šà¸²', 'à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”à¹à¸¥à¹‰à¸§', 'à¹€à¸à¸£à¸” A', 'à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”à¹à¸¥à¹‰à¸§'),
    ('55555555-5555-5555-5555-555555555512', 'ENGCE303', '33333333-3333-3333-3333-333333333301', 'Sec.1', 'T-1025', 'THU', '13:00', '16:00', '13:00â€“16:00', 'à¸«à¹‰à¸­à¸‡ 1605', 40, 12, 100, 'à¸ˆà¸šà¸£à¸²à¸¢à¸§à¸´à¸Šà¸²', 'à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”à¹à¸¥à¹‰à¸§', 'à¹€à¸à¸£à¸” B+', 'à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”à¹à¸¥à¹‰à¸§'),
    ('55555555-5555-5555-5555-555555555513', 'MATH201', '33333333-3333-3333-3333-333333333301', 'Sec.1', 'T-1027', 'FRI', '09:00', '12:00', '09:00â€“12:00', 'à¸«à¹‰à¸­à¸‡ 1201', 50, 12, 100, 'à¸ˆà¸šà¸£à¸²à¸¢à¸§à¸´à¸Šà¸²', 'à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”à¹à¸¥à¹‰à¸§', 'à¹€à¸à¸£à¸” C+', 'à¸ªà¹ˆà¸‡à¹€à¸à¸£à¸”à¹à¸¥à¹‰à¸§')
ON CONFLICT (subject_code, term_id, section_number) DO NOTHING;

-- 12. à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸à¸²à¸£à¸¥à¸‡à¸—à¸°à¹€à¸šà¸µà¸¢à¸™à¹€à¸£à¸µà¸¢à¸™à¹à¸¥à¸°à¸„à¸°à¹à¸™à¸™à¸‚à¸­à¸‡à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¸—à¸±à¹‰à¸‡ 12 à¸„à¸™ (Enrollments)
INSERT INTO public.enrollments (
    student_id, section_id, term_id, subject_code, enrollment_status,
    quiz_score, lab_score, coursework_score, midterm_score, final_score,
    grade_submit_status, attendance_rate, pending_assignments
)
VALUES
    -- à¸§à¸´à¸Šà¸² ENGCE302 à¸£à¸°à¸šà¸šà¸à¸²à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥ (à¸„à¸£à¸šà¸—à¸±à¹‰à¸‡ 12 à¸„à¸™ à¸ªà¸³à¸«à¸£à¸±à¸šà¸«à¸™à¹‰à¸²à¸•à¸±à¸”à¹€à¸à¸£à¸”à¸­à¸²à¸ˆà¸²à¸£à¸¢à¹Œ)
    ('650602001', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.0, 16.0, 27, 26, 33, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 92.00, 1),
    ('650602002', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 11.0, 14.0, 24, 22, 28, 'à¸£à¹ˆà¸²à¸‡', 88.00, 1),
    ('650602003', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 9.0, 11.0, 20, 15, 22, 'à¸£à¹ˆà¸²à¸‡', 75.00, 2),
    ('650602004', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 14.0, 20.0, 29, 28, 36, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 100.00, 0),
    ('650602005', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 13.0, 18.0, 26, 25, 31, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 95.00, 0),
    ('650602006', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 10.5, 15.0, 23, 20, 26, 'à¸£à¹ˆà¸²à¸‡', 85.00, 1),
    ('650602007', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.0, 17.0, 25, 24, 29, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 92.00, 0),
    ('650602008', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 10.0, 13.0, 21, 19, 24, 'à¸£à¹ˆà¸²à¸‡', 80.00, 1),
    ('650602009', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 14.5, 22.0, 29, 29, 37, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 100.00, 0),
    ('650602010', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 8.0, 10.0, 18, 14, 19, 'à¸£à¹ˆà¸²à¸‡', 70.00, 2),
    ('650602011', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.5, 17.5, 26, 23, 29, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 94.00, 0),
    ('650602012', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 11.5, 16.0, 24, 21, 27, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 90.00, 0),

    -- à¸•à¸²à¸£à¸²à¸‡à¹€à¸£à¸µà¸¢à¸™à¸„à¸£à¸šà¸—à¸±à¹‰à¸‡à¸ªà¸±à¸›à¸”à¸²à¸«à¹Œ (à¸ˆà¸±à¸™à¸—à¸£à¹Œ-à¸¨à¸¸à¸à¸£à¹Œ) à¸‚à¸­à¸‡ 650602001 (à¸¡à¸´à¸™à¸•à¸£à¸²) à¹à¸¥à¸° 650602002 (à¸ à¸¹à¸£à¸´)
    ('650602001', '55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333302', 'ENGCE305', 'enrolled', 13.0, 18.0, 25, 24, 26, 'à¸£à¹ˆà¸²à¸‡', 95.00, 1),
    ('650602001', '55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333302', 'ENGCE306', 'enrolled', 14.0, 20.0, 28, 25, 30, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 96.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333302', 'GEN101', 'enrolled', 14.0, 0.0, 25, 22, 25, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 100.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555505', '33333333-3333-3333-3333-333333333302', 'ENGCE307', 'enrolled', 12.0, 19.0, 26, 24, 28, 'à¸£à¹ˆà¸²à¸‡', 92.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555506', '33333333-3333-3333-3333-333333333302', 'ENGCE308', 'enrolled', 13.5, 17.0, 27, 26, 30, 'à¸£à¹ˆà¸²à¸‡', 96.00, 0),

    ('650602002', '55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333302', 'ENGCE305', 'enrolled', 12.0, 16.0, 23, 21, 27, 'à¸£à¹ˆà¸²à¸‡', 90.00, 1),
    ('650602002', '55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333302', 'ENGCE306', 'enrolled', 12.0, 18.0, 25, 23, 28, 'à¸ªà¹ˆà¸‡à¹à¸¥à¹‰à¸§', 92.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333302', 'GEN101', 'enrolled', 13.0, 0.0, 24, 21, 25, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 95.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555505', '33333333-3333-3333-3333-333333333302', 'ENGCE307', 'enrolled', 11.0, 17.0, 24, 22, 26, 'à¸£à¹ˆà¸²à¸‡', 88.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555506', '33333333-3333-3333-3333-333333333302', 'ENGCE308', 'enrolled', 12.0, 16.0, 24, 22, 25, 'à¸£à¹ˆà¸²à¸‡', 90.00, 0),

    -- à¸œà¸¥à¸à¸²à¸£à¹€à¸£à¸µà¸¢à¸™à¹€à¸—à¸­à¸¡à¸à¹ˆà¸­à¸™ (2/2568)
    ('650602001', '55555555-5555-5555-5555-555555555511', '33333333-3333-3333-3333-333333333301', 'ENGCE301', 'completed', 14.0, 22.0, 28, 27, 34, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 96.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555512', '33333333-3333-3333-3333-333333333301', 'ENGCE303', 'completed', 12.5, 20.0, 25, 23, 29, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 90.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555513', '33333333-3333-3333-3333-333333333301', 'MATH201', 'completed', 10.0, 0.0, 21, 19, 26, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 85.00, 0),

    ('650602002', '55555555-5555-5555-5555-555555555511', '33333333-3333-3333-3333-333333333301', 'ENGCE301', 'completed', 13.0, 20.0, 26, 24, 28, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 92.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555512', '33333333-3333-3333-3333-333333333301', 'ENGCE303', 'completed', 12.0, 18.0, 24, 22, 26, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 88.00, 0),
    ('650602002', '55555555-5555-5555-5555-555555555513', '33333333-3333-3333-3333-333333333301', 'MATH201', 'completed', 11.0, 0.0, 22, 20, 24, 'à¸›à¸£à¸°à¸à¸²à¸¨à¸œà¸¥à¹à¸¥à¹‰à¸§', 86.00, 0)
ON CONFLICT (student_id, section_id) DO NOTHING;

-- 13. à¹€à¸­à¸à¸ªà¸²à¸£à¸›à¸£à¸°à¸à¸­à¸šà¸à¸²à¸£à¸ªà¸­à¸™ (Course Materials)
DELETE FROM public.course_materials WHERE section_id = '55555555-5555-5555-5555-555555555501';
INSERT INTO public.course_materials (section_id, subject_code, title, file_type, file_size_label, file_url, updated_label)
VALUES
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', 'à¸ªà¹„à¸¥à¸”à¹Œ Lec 6 â€” Normalization (1NF, 2NF, 3NF, BCNF)', 'PDF', '2.4 MB', 'https://rmutp.ac.th/storage/v1/object/public/materials/ENGCE302_Lec6_Normalization.pdf', 'à¸­à¸±à¸›à¹€à¸”à¸•à¹€à¸¡à¸·à¹ˆà¸­à¸§à¸²à¸™'),
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', 'à¸ªà¹„à¸¥à¸”à¹Œ Lec 5 â€” ER Diagram & Relational Mapping', 'PDF', '3.1 MB', 'https://rmutp.ac.th/storage/v1/object/public/materials/ENGCE302_Lec5_ERD.pdf', 'à¸ªà¸±à¸›à¸”à¸²à¸«à¹Œà¸—à¸µà¹ˆà¹à¸¥à¹‰à¸§'),
    ('55555555-5555-5555-5555-555555555501', 'ENGCE302', 'à¸„à¸¹à¹ˆà¸¡à¸·à¸­à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸à¸²à¸£ SQL & PostgreSQL Stored Procedures', 'PDF', '1.9 MB', 'https://rmutp.ac.th/storage/v1/object/public/materials/ENGCE302_Lab_PostgreSQL.pdf', '3 à¸§à¸±à¸™à¸—à¸µà¹ˆà¹à¸¥à¹‰à¸§');

-- 14. à¸à¸²à¸£à¸šà¹‰à¸²à¸™ / à¸‡à¸²à¸™à¸—à¸µà¹ˆà¸ªà¸±à¹ˆà¸‡ (Assignments)
INSERT INTO public.assignments (id, section_id, subject_code, title, description, due_badge, due_date, max_score, submitted_count, total_students)
VALUES
    ('66666666-6666-6666-6666-666666666601', '55555555-5555-5555-5555-555555555501', 'ENGCE302', 'HW6: à¸­à¸­à¸à¹à¸šà¸š ER + Normalization 3NF', 'à¹à¸™à¸š PDF/à¸£à¸¹à¸› â€¢ à¸ªà¹ˆà¸‡à¹„à¸”à¹‰à¸–à¸¶à¸‡ 23 à¸.à¸¢. 23:59', 'à¸ªà¹ˆà¸‡à¹ƒà¸™ 2 à¸§à¸±à¸™', '2026-09-23 23:59:00+07', 10.00, 9, 12),
    ('66666666-6666-6666-6666-666666666602', '55555555-5555-5555-5555-555555555502', 'ENGCE305', 'Lab 6 Report: VLAN & OSPF Routing', 'à¹à¸™à¸šà¹„à¸Ÿà¸¥à¹Œ .pkt à¹à¸¥à¸°à¸£à¸²à¸¢à¸‡à¸²à¸™ PDF', 'à¸ªà¹ˆà¸‡à¹ƒà¸™ 5 à¸§à¸±à¸™', '2026-09-26 23:59:00+07', 15.00, 7, 12)
ON CONFLICT (id) DO NOTHING;

-- 15. à¸›à¸£à¸°à¸§à¸±à¸•à¸´à¸à¸²à¸£à¸ªà¹ˆà¸‡à¸‡à¸²à¸™à¸‚à¸­à¸‡à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸² (Assignment Submissions)
INSERT INTO public.assignment_submissions (assignment_id, student_id, file_url, file_name, status, score, teacher_feedback)
VALUES
    ('66666666-6666-6666-6666-666666666601', '650602001', 'https://rmutp.ac.th/storage/v1/object/public/submissions/650602001_HW6_ER_3NF.pdf', '650602001_HW6_ER_3NF.pdf', 'submitted', 9.50, 'à¹à¸¢à¸à¸•à¸²à¸£à¸²à¸‡ 3NF à¹„à¸”à¹‰à¸–à¸¹à¸à¸•à¹‰à¸­à¸‡à¸„à¸£à¸šà¸–à¹‰à¸§à¸™')
ON CONFLICT (assignment_id, student_id) DO NOTHING;

-- 16. à¸à¸²à¸£à¹€à¸›à¸´à¸”à¸«à¹‰à¸­à¸‡à¹€à¸Šà¹‡à¸à¸Šà¸·à¹ˆà¸­ (Attendance Sessions)
INSERT INTO public.attendance_sessions (id, section_id, subject_code, session_date, week_number, room_code, qr_code_payload, open_time_label, is_open, present_count, total_students)
VALUES
    ('77777777-7777-7777-7777-777777777701', '55555555-5555-5555-5555-555555555501', 'ENGCE302', CURRENT_DATE, 6, 'DB-0921', 'RMUTP-ATTENDANCE|ENGCE302|SEC1|DB-0921', '09:00â€“09:15', TRUE, 9, 12)
ON CONFLICT (id) DO NOTHING;

-- 17. à¸šà¸±à¸™à¸—à¸¶à¸à¸à¸²à¸£à¹€à¸Šà¹‡à¸à¸Šà¸·à¹ˆà¸­à¸£à¸²à¸¢à¸šà¸¸à¸„à¸„à¸¥à¸—à¸±à¹‰à¸‡ 12 à¸„à¸™ (Attendance Records)
INSERT INTO public.attendance_records (session_id, student_id, status, check_in_time, check_in_method, reminded_via_line, note)
VALUES
    ('77777777-7777-7777-7777-777777777701', '650602001', 'present', '09:03', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602002', 'present', '09:04', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602003', 'absent', NULL, 'teacher_manual', FALSE, 'à¸¢à¸±à¸‡à¹„à¸¡à¹ˆà¸¡à¸²à¹€à¸£à¸µà¸¢à¸™'),
    ('77777777-7777-7777-7777-777777777701', '650602004', 'present', '09:01', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602005', 'present', '09:02', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602006', 'late', '09:18', 'room_code', FALSE, 'à¸¡à¸²à¸ªà¸²à¸¢ 3 à¸™à¸²à¸—à¸µ'),
    ('77777777-7777-7777-7777-777777777701', '650602007', 'present', '09:05', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602008', 'absent', NULL, 'teacher_manual', FALSE, 'à¸¢à¸±à¸‡à¹„à¸¡à¹ˆà¸¡à¸²à¹€à¸£à¸µà¸¢à¸™'),
    ('77777777-7777-7777-7777-777777777701', '650602009', 'present', '09:00', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602010', 'absent', NULL, 'teacher_manual', FALSE, 'à¸¢à¸±à¸‡à¹„à¸¡à¹ˆà¸¡à¸²à¹€à¸£à¸µà¸¢à¸™'),
    ('77777777-7777-7777-7777-777777777701', '650602011', 'present', '09:06', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²'),
    ('77777777-7777-7777-7777-777777777701', '650602012', 'present', '09:07', 'qr_scan', FALSE, 'à¹€à¸Šà¹‡à¸„à¸Šà¸·à¹ˆà¸­à¸•à¸£à¸‡à¹€à¸§à¸¥à¸²')
ON CONFLICT (session_id, student_id) DO NOTHING;

-- 18. à¹ƒà¸šà¹à¸ˆà¹‰à¸‡à¸«à¸™à¸µà¹‰à¸„à¹ˆà¸²à¹€à¸—à¸­à¸¡ (Tuition Invoices)
INSERT INTO public.tuition_invoices (
    invoice_no, student_id, term_id, tuition_fee, university_fee, lab_equipment_fee,
    scholarship_discount, total_amount, due_date, payment_status, invoice_pdf_url
)
VALUES
    ('INV-2569-1-650602001', '650602001', '33333333-3333-3333-3333-333333333302', 15000.00, 2000.00, 1500.00, 0.00, 18500.00, '2026-06-30', 'paid', 'https://rmutp.ac.th/storage/v1/object/public/receipts/INV-2569-1-650602001.pdf'),
    ('INV-2568-2-650602001', '650602001', '33333333-3333-3333-3333-333333333301', 15000.00, 2000.00, 1500.00, 5000.00, 13500.00, '2025-11-30', 'paid', 'https://rmutp.ac.th/storage/v1/object/public/receipts/INV-2568-2-650602001.pdf'),
    ('INV-2569-1-650602002', '650602002', '33333333-3333-3333-3333-333333333302', 15000.00, 2000.00, 1500.00, 0.00, 18500.00, '2026-06-30', 'paid', 'https://rmutp.ac.th/storage/v1/object/public/receipts/INV-2569-1-650602002.pdf'),
    ('INV-2569-1-650602003', '650602003', '33333333-3333-3333-3333-333333333302', 15000.00, 2000.00, 1500.00, 0.00, 18500.00, '2026-06-30', 'verifying', 'https://rmutp.ac.th/storage/v1/object/public/receipts/INV-2569-1-650602003.pdf')
ON CONFLICT (invoice_no) DO NOTHING;

-- 19. à¹ƒà¸šà¹€à¸ªà¸£à¹‡à¸ˆà¸£à¸±à¸šà¹€à¸‡à¸´à¸™à¸­à¸´à¹€à¸¥à¹‡à¸à¸—à¸£à¸­à¸™à¸´à¸à¸ªà¹Œ (Payment Receipts)
INSERT INTO public.payment_receipts (
    receipt_no, invoice_no, student_id, payment_method, bank_name,
    transaction_ref, amount_paid, paid_at, slip_image_url, receipt_pdf_url, finance_officer_name, is_verified
)
VALUES
    ('RCP-2569-00891', 'INV-2569-1-650602001', '650602001', 'qr_promptpay', 'à¸˜à¸™à¸²à¸„à¸²à¸£à¸à¸£à¸¸à¸‡à¹„à¸—à¸¢ (KTB)', 'KTB2026062009154421', 18500.00, '2026-06-20 09:15:44+07', 'https://rmutp.ac.th/storage/v1/object/public/receipts/slip_650602001_2569_1.jpg', 'https://rmutp.ac.th/storage/v1/object/public/receipts/RCP-2569-00891.pdf', 'à¸à¸­à¸‡à¸„à¸¥à¸±à¸‡ à¸ªà¸³à¸™à¸±à¸à¸‡à¸²à¸™à¸­à¸˜à¸´à¸à¸²à¸£à¸šà¸”à¸µ à¸¡à¸—à¸£.à¸žà¸£à¸°à¸™à¸„à¸£', TRUE),
    ('RCP-2568-04512', 'INV-2568-2-650602001', '650602001', 'mobile_banking', 'à¸˜à¸™à¸²à¸„à¸²à¸£à¸à¸ªà¸´à¸à¸£à¹„à¸—à¸¢ (KBANK)', 'KBANK2025111814221099', 13500.00, '2025-11-18 14:22:10+07', 'https://rmutp.ac.th/storage/v1/object/public/receipts/slip_650602001_2568_2.jpg', 'https://rmutp.ac.th/storage/v1/object/public/receipts/RCP-2568-04512.pdf', 'à¸à¸­à¸‡à¸„à¸¥à¸±à¸‡ à¸ªà¸³à¸™à¸±à¸à¸‡à¸²à¸™à¸­à¸˜à¸´à¸à¸²à¸£à¸šà¸”à¸µ à¸¡à¸—à¸£.à¸žà¸£à¸°à¸™à¸„à¸£', TRUE),
    ('RCP-2569-00945', 'INV-2569-1-650602002', '650602002', 'qr_promptpay', 'à¸˜à¸™à¸²à¸„à¸²à¸£à¹„à¸—à¸¢à¸žà¸²à¸“à¸´à¸Šà¸¢à¹Œ (SCB)', 'SCB2026062211053310', 18500.00, '2026-06-22 11:05:33+07', 'https://rmutp.ac.th/storage/v1/object/public/receipts/slip_650602002_2569_1.jpg', 'https://rmutp.ac.th/storage/v1/object/public/receipts/RCP-2569-00945.pdf', 'à¸à¸­à¸‡à¸„à¸¥à¸±à¸‡ à¸ªà¸³à¸™à¸±à¸à¸‡à¸²à¸™à¸­à¸˜à¸´à¸à¸²à¸£à¸šà¸”à¸µ à¸¡à¸—à¸£.à¸žà¸£à¸°à¸™à¸„à¸£', TRUE)
ON CONFLICT (receipt_no) DO NOTHING;

-- 20. à¸„à¸³à¸£à¹‰à¸­à¸‡à¹à¸¥à¸°à¹à¸ˆà¹‰à¸‡à¹€à¸£à¸·à¹ˆà¸­à¸‡ (Service Requests)
INSERT INTO public.service_requests (
    request_code, student_id, category, title, description, room_location,
    attachment_image_url, result_pdf_url, status_student, status_teacher,
    chip_color_hex, progress, assigned_teacher_id
)
VALUES
    ('#RQ-1042', '650602001', 'document', 'à¸‚à¸­à¹ƒà¸šà¸£à¸±à¸šà¸£à¸­à¸‡ ENG', 'à¸‚à¸­à¹ƒà¸šà¸£à¸±à¸šà¸£à¸­à¸‡à¸à¸²à¸£à¹€à¸›à¹‡à¸™à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¸‰à¸šà¸±à¸šà¸ à¸²à¸©à¸²à¸­à¸±à¸‡à¸à¸¤à¸© à¹€à¸žà¸·à¹ˆà¸­à¹ƒà¸Šà¹‰à¸¢à¸·à¹ˆà¸™à¸ªà¸¡à¸±à¸„à¸£à¹‚à¸„à¸£à¸‡à¸à¸²à¸£à¹à¸¥à¸à¹€à¸›à¸¥à¸µà¹ˆà¸¢à¸™à¹à¸¥à¸°à¸—à¸¸à¸™à¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸²', NULL, 'https://rmutp.ac.th/storage/v1/object/public/receipts/fee_slip_1042.jpg', NULL, 'à¸£à¸­à¸”à¸³à¹€à¸™à¸´à¸™à¸à¸²à¸£', 'à¸£à¸­à¸­à¸™à¸¸à¸¡à¸±à¸•à¸´', '#FFC107', 0.40, 'T-1024'),
    ('#RQ-1039', '650602001', 'repair', 'à¹à¸­à¸£à¹Œà¸«à¹‰à¸­à¸‡ 1604 à¹„à¸¡à¹ˆà¹€à¸¢à¹‡à¸™', 'à¹€à¸„à¸£à¸·à¹ˆà¸­à¸‡à¸›à¸£à¸±à¸šà¸­à¸²à¸à¸²à¸¨à¸•à¸±à¸§à¸£à¸´à¸¡à¸«à¸™à¹‰à¸²à¸•à¹ˆà¸²à¸‡à¹ƒà¸™à¸«à¹‰à¸­à¸‡à¹€à¸£à¸µà¸¢à¸™ 1604 à¸¡à¸µà¹à¸•à¹ˆà¸¥à¸¡à¸­à¸­à¸à¹à¸¥à¸°à¸¡à¸µà¸™à¹‰à¸³à¸«à¸¢à¸”à¸£à¸°à¸«à¸§à¹ˆà¸²à¸‡à¹€à¸£à¸µà¸¢à¸™à¸§à¸´à¸Šà¸²à¸à¸²à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥', 'à¸«à¹‰à¸­à¸‡ 1604 à¸­à¸²à¸„à¸²à¸£à¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ', 'https://rmutp.ac.th/storage/v1/object/public/submissions/ac_room1604.jpg', NULL, 'à¸Šà¹ˆà¸²à¸‡à¸£à¸±à¸šà¹€à¸£à¸·à¹ˆà¸­à¸‡', 'à¸ªà¹ˆà¸‡à¸•à¹ˆà¸­à¸Šà¹ˆà¸²à¸‡à¹à¸¥à¹‰à¸§', '#2196F3', 0.70, 'T-1024'),
    ('#RQ-1031', '650602001', 'document', 'à¸‚à¸­ transcript', 'à¸‚à¸­à¹ƒà¸šà¹à¸ªà¸”à¸‡à¸œà¸¥à¸à¸²à¸£à¸¨à¸¶à¸à¸©à¸² (Transcript) à¸‰à¸šà¸±à¸šà¹„à¸¡à¹ˆà¹€à¸›à¹‡à¸™à¸—à¸²à¸‡à¸à¸²à¸£ à¸•à¸±à¹‰à¸‡à¹à¸•à¹ˆà¸Šà¸±à¹‰à¸™à¸›à¸µà¸—à¸µà¹ˆ 1 à¸–à¸¶à¸‡à¸›à¸±à¸ˆà¸ˆà¸¸à¸šà¸±à¸™', NULL, NULL, 'https://rmutp.ac.th/storage/v1/object/public/receipts/Transcript_650602001.pdf', 'à¹€à¸ªà¸£à¹‡à¸ˆà¹à¸¥à¹‰à¸§ â€¢ à¹‚à¸«à¸¥à¸” PDF', 'à¹€à¸ªà¸£à¹‡à¸ˆà¸ªà¸´à¹‰à¸™', '#4CAF50', 1.00, 'T-1024'),
    ('#RQ-1045', '650602002', 'document', 'à¸‚à¸­à¸«à¸™à¸±à¸‡à¸ªà¸·à¸­à¸ªà¹ˆà¸‡à¸•à¸±à¸§à¸ªà¸«à¸à¸´à¸ˆà¸¨à¸¶à¸à¸©à¸²', 'à¸‚à¸­à¸«à¸™à¸±à¸‡à¸ªà¸·à¸­à¸‚à¸­à¸„à¸§à¸²à¸¡à¸­à¸™à¸¸à¹€à¸„à¸£à¸²à¸°à¸«à¹Œà¸£à¸±à¸šà¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¹€à¸‚à¹‰à¸²à¸›à¸à¸´à¸šà¸±à¸•à¸´à¸‡à¸²à¸™à¸ªà¸«à¸à¸´à¸ˆà¸¨à¸¶à¸à¸©à¸² à¸šà¸£à¸´à¸©à¸±à¸— à¹‚à¸•à¹‚à¸¢à¸•à¹‰à¸² à¸—à¸¹à¹‚à¸Š', NULL, NULL, NULL, 'à¸£à¸­à¸”à¸³à¹€à¸™à¸´à¸™à¸à¸²à¸£', 'à¸£à¸­à¸­à¸™à¸¸à¸¡à¸±à¸•à¸´', '#FFC107', 0.35, 'T-1024')
ON CONFLICT (request_code) DO NOTHING;

-- 21. à¸‚à¹ˆà¸²à¸§à¸ªà¸²à¸£à¹à¸¥à¸°à¸›à¸£à¸°à¸à¸²à¸¨ (News Announcements)
DELETE FROM public.news_announcements;
INSERT INTO public.news_announcements (title, subtitle, news_type, detail, banner_image_url, button_label, min_gpa_required, author_teacher_id, view_count, expire_date)
VALUES
    ('à¸—à¸¸à¸™à¹€à¸£à¸µà¸¢à¸™à¸”à¸µà¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸¯ 5,000 à¸šà¸²à¸— (20 à¸—à¸¸à¸™)', 'à¸—à¸¸à¸™ â€¢ à¸›à¸´à¸”à¸£à¸±à¸š 30 à¸.à¸¢.', 'à¸—à¸¸à¸™', 'GPA â‰¥ 3.00 â€¢ à¹à¸™à¸šà¸—à¸£à¸²à¸™à¸ªà¸„à¸£à¸´à¸›à¸•à¹Œ â€¢ à¸ªà¸¡à¸±à¸„à¸£à¸­à¸­à¸™à¹„à¸¥à¸™à¹Œà¸œà¹ˆà¸²à¸™à¸£à¸°à¸šà¸šà¸à¸´à¸ˆà¸à¸²à¸£à¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸² à¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ à¸¡à¸—à¸£.à¸žà¸£à¸°à¸™à¸„à¸£', 'https://rmutp.ac.th/storage/v1/object/public/materials/scholarship_eng_2569.jpg', 'à¸”à¸¹à¸£à¸²à¸¢à¸¥à¸°à¹€à¸­à¸µà¸¢à¸”', 3.00, 'T-1024', 185, '2026-09-30'),
    ('à¸à¸¶à¸à¸‡à¸²à¸™/à¸ªà¸«à¸à¸´à¸ˆ Toyota Tsusho â€” à¸£à¸±à¸šà¸ªà¸«à¸à¸´à¸ˆ IT 10 à¸­à¸±à¸•à¸£à¸²', 'à¸à¸¶à¸à¸‡à¸²à¸™/à¸ªà¸«à¸à¸´à¸ˆ â€¢ à¸ªà¸¡à¸±à¸„à¸£à¸”à¹ˆà¸§à¸™', 'à¸à¸¶à¸à¸‡à¸²à¸™', 'à¸ªà¸±à¸¡à¸ à¸²à¸©à¸“à¹Œ 5 à¸•.à¸„. à¸—à¸µà¹ˆà¸¨à¸¹à¸™à¸¢à¹Œà¸ªà¸«à¸à¸´à¸ˆ â€¢ à¸£à¸±à¸šà¸™à¸±à¸à¸¨à¸¶à¸à¸©à¸²à¸ªà¸²à¸‚à¸²à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸„à¸­à¸¡à¸žà¸´à¸§à¹€à¸•à¸­à¸£à¹Œà¹à¸¥à¸° IT à¸¡à¸µà¹€à¸šà¸µà¹‰à¸¢à¹€à¸¥à¸µà¹‰à¸¢à¸‡à¸•à¸¥à¸­à¸”à¹‚à¸„à¸£à¸‡à¸à¸²à¸£', 'https://rmutp.ac.th/storage/v1/object/public/materials/coop_toyota_tsusho.jpg', 'à¸”à¸¹à¸£à¸²à¸¢à¸¥à¸°à¹€à¸­à¸µà¸¢à¸”', 2.50, 'T-1025', 127, '2026-10-05'),
    ('RMUTP Freshmen Day + à¸Šà¸¡à¸£à¸¡à¸«à¸¸à¹ˆà¸™à¸¢à¸™à¸•à¹Œ', 'à¸à¸´à¸ˆà¸à¸£à¸£à¸¡ â€¢ 27 à¸.à¸¢.', 'à¸à¸´à¸ˆà¸à¸£à¸£à¸¡', 'à¹€à¸›à¸´à¸”à¸£à¸²à¸¢à¸¥à¸°à¹€à¸­à¸µà¸¢à¸”à¸à¸´à¸ˆà¸à¸£à¸£à¸¡à¸•à¹‰à¸­à¸™à¸£à¸±à¸šà¸™à¹‰à¸­à¸‡à¹ƒà¸«à¸¡à¹ˆà¹à¸¥à¸°à¸šà¸¹à¸˜à¹à¸ªà¸”à¸‡à¸œà¸¥à¸‡à¸²à¸™à¸Šà¸¡à¸£à¸¡à¸«à¸¸à¹ˆà¸™à¸¢à¸™à¸•à¹Œ à¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡à¸¨à¸²à¸ªà¸•à¸£à¹Œ à¸£à¸±à¸šà¸Šà¸±à¹ˆà¸§à¹‚à¸¡à¸‡à¸à¸´à¸ˆà¸à¸£à¸£à¸¡ 6 à¸Šà¸¡.', 'https://rmutp.ac.th/storage/v1/object/public/materials/freshmen_robotics.jpg', 'à¸”à¸¹à¸£à¸²à¸¢à¸¥à¸°à¹€à¸­à¸µà¸¢à¸”', NULL, 'T-1024', 312, '2026-09-27');

-- 22. à¸à¸²à¸£à¹à¸ˆà¹‰à¸‡à¹€à¸•à¸·à¸­à¸™ (Notifications)
DELETE FROM public.notifications;
INSERT INTO public.notifications (user_id, student_id, title, subtitle, accent_color_hex, is_read)
VALUES
    ('44444444-4444-4444-4444-444444444411', '650602001', 'HW6 à¹ƒà¸à¸¥à¹‰à¸„à¸£à¸šà¸à¸³à¸«à¸™à¸”', 'ENGCE302 â€” à¸ªà¹ˆà¸‡à¹ƒà¸™ 2 à¸§à¸±à¸™ (23 à¸.à¸¢. 23:59)', '#F44336', FALSE),
    ('44444444-4444-4444-4444-444444444411', '650602001', 'à¸—à¸¸à¸™à¸„à¸“à¸°à¸§à¸´à¸¨à¸§à¸¯ à¸›à¸´à¸”à¸£à¸±à¸š 30 à¸.à¸¢.', 'à¸„à¸¸à¸“à¸ªà¸¡à¸šà¸±à¸•à¸´à¸œà¹ˆà¸²à¸™ à¸à¸”à¸ªà¸¡à¸±à¸„à¸£à¹„à¸”à¹‰à¹€à¸¥à¸¢', '#F6DC04', FALSE),
    ('44444444-4444-4444-4444-444444444411', '650602001', 'à¹€à¸¥à¸·à¹ˆà¸­à¸™à¸«à¹‰à¸­à¸‡ ENGCE305 â†’ Lab 1502', 'à¸ˆà¸²à¸ à¸­.à¸™à¸ à¸±à¸ª à¹€à¸¡à¸·à¹ˆà¸­ 1 à¸Šà¸¡.à¸à¹ˆà¸­à¸™', '#652D91', FALSE),
    ('44444444-4444-4444-4444-444444444412', '650602002', 'HW6 à¹ƒà¸à¸¥à¹‰à¸„à¸£à¸šà¸à¸³à¸«à¸™à¸”', 'ENGCE302 â€” à¸ªà¹ˆà¸‡à¹ƒà¸™ 2 à¸§à¸±à¸™ (23 à¸.à¸¢. 23:59)', '#F44336', FALSE);

-- =============================================================================
-- à¸ªà¹ˆà¸§à¸™à¸—à¸µà¹ˆ 6: à¸„à¸§à¸²à¸¡à¸›à¸¥à¸­à¸”à¸ à¸±à¸¢à¸¡à¸²à¸•à¸£à¸à¸²à¸™à¸ªà¸²à¸à¸¥ (Row Level Security & Column Security)
-- =============================================================================
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

-- à¸›à¹‰à¸­à¸‡à¸à¸±à¸™à¸à¸²à¸£à¸”à¸¶à¸‡à¸„à¸­à¸¥à¸±à¸¡à¸™à¹Œ password_hash à¸­à¸­à¸à¹„à¸›à¸œà¹ˆà¸²à¸™ API à¹‚à¸”à¸¢à¹€à¸”à¹‡à¸”à¸‚à¸²à¸”
REVOKE SELECT (password_hash) ON public.users FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.sp_authenticate_user(TEXT, TEXT) TO anon, authenticated;

-- à¸ªà¸£à¹‰à¸²à¸‡ RLS Policies à¹ƒà¸«à¹‰à¹à¸­à¸›à¹€à¸‚à¹‰à¸²à¸–à¸¶à¸‡à¹„à¸”à¹‰à¸•à¸²à¸¡à¸šà¸—à¸šà¸²à¸—
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
        'payment_receipts', 'service_requests', 'news_announcements', 'notifications'
    ]
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "rmutp_app_policy_%I" ON public.%I;', tbl, tbl);
        EXECUTE format('CREATE POLICY "rmutp_app_policy_%I" ON public.%I FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);', tbl, tbl);
    END LOOP;
END $$;

