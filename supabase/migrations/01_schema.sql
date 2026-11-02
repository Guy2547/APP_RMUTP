-- =============================================================================
-- 01_schema.sql
-- โครงสร้างฐานข้อมูลมหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร (RMUTP Campus App)
-- ออกแบบตามหลักการ Normalization ระดับ 3NF (Third Normal Form)
-- =============================================================================

-- เปิดใช้งาน PostgreSQL Extensions มาตรฐานสำหรับสร้าง UUID และเข้ารหัสรหัสผ่าน (bcrypt)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- ส่วนที่ 1: โครงสร้างองค์กรและปฏิทินการศึกษา (Organization & Academic Calendar)
-- =============================================================================

-- 1. ตารางคณะวิชา (Faculties)
CREATE TABLE IF NOT EXISTS public.faculties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(15) UNIQUE NOT NULL,               -- เช่น 'ENG', 'BUS', 'SCI'
    name_th VARCHAR(150) NOT NULL,                  -- ชื่อคณะภาษาไทย
    name_en VARCHAR(150) NOT NULL,                  -- ชื่อคณะภาษาอังกฤษ
    campus VARCHAR(100) NOT NULL,                   -- ศูนย์พื้นที่ เช่น 'ศูนย์พระนครเหนือ'
    building VARCHAR(100),                          -- อาคารที่ตั้ง
    phone VARCHAR(30),                              -- เบอร์ติดต่อคณะ
    website_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. ตารางภาควิชา / สาขาวิชา (Departments)
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    faculty_id UUID NOT NULL REFERENCES public.faculties(id) ON DELETE CASCADE,
    code VARCHAR(15) UNIQUE NOT NULL,               -- เช่น 'ENGCE', 'ENGEE', 'ENGIE'
    name_th VARCHAR(150) NOT NULL,                  -- เช่น 'วิศวกรรมคอมพิวเตอร์'
    name_en VARCHAR(150) NOT NULL,                  -- เช่น 'Computer Engineering'
    degree_name_th VARCHAR(150) NOT NULL,           -- เช่น 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)'
    total_credits_required INT NOT NULL DEFAULT 132 CHECK (total_credits_required > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. ตารางปีการศึกษาและภาคเรียน (Academic Terms)
CREATE TABLE IF NOT EXISTS public.academic_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    academic_year INT NOT NULL CHECK (academic_year >= 2550), -- ปีการศึกษา พ.ศ. เช่น 2569
    semester INT NOT NULL CHECK (semester IN (1, 2, 3)),      -- 1=ภาคต้น, 2=ภาคปลาย, 3=ฤดูร้อน
    term_label VARCHAR(30) NOT NULL,                          -- เช่น '1/2569'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    midterm_start_date DATE,
    midterm_end_date DATE,
    final_start_date DATE,
    final_end_date DATE,
    grade_submit_deadline DATE,                               -- วันหมดเขตส่งเกรดของอาจารย์
    is_current BOOLEAN NOT NULL DEFAULT FALSE,                -- เป็นเทอมปัจจุบันหรือไม่
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (academic_year, semester)
);

-- 4. ตารางปฏิทินการศึกษา (Academic Calendar Events)
CREATE TABLE IF NOT EXISTS public.academic_calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,                    -- เช่น 'หมดเขตส่ง HW6', 'สอบกลางภาค'
    date_display VARCHAR(50) NOT NULL,              -- เช่น '23 ก.ย.', '13–17 ต.ค.'
    event_type VARCHAR(30) NOT NULL DEFAULT 'general'
        CHECK (event_type IN ('exam', 'deadline', 'scholarship', 'coop', 'activity', 'holiday', 'general')),
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- ส่วนที่ 2: ผู้ใช้งาน ประวัตินักศึกษา และอาจารย์ (Users, Students & Teachers)
-- =============================================================================

-- 5. ตารางบัญชีผู้ใช้งานหลัก (Users & Authentication)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(150) UNIQUE NOT NULL,             -- อีเมลมหาวิทยาลัย (@rmutp.ac.th)
    password_hash TEXT NOT NULL,                    -- รหัสผ่านที่เข้ารหัสแล้ว
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

-- 6. ตารางข้อมูลอาจารย์และบุคลากร (Teachers)
CREATE TABLE IF NOT EXISTS public.teachers (
    teacher_id VARCHAR(20) PRIMARY KEY,             -- รหัสอาจารย์ เช่น 'T-1024'
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    academic_rank VARCHAR(30) NOT NULL DEFAULT 'อ.', -- ตำแหน่งทางวิชาการ เช่น 'อ.', 'ผศ.', 'รศ.ดร.'
    first_name_th VARCHAR(100) NOT NULL,
    last_name_th VARCHAR(100) NOT NULL,
    first_name_en VARCHAR(100),
    last_name_en VARCHAR(100),
    face_photo_url TEXT,                            -- รูปถ่ายหน้าตรงอาจารย์
    faculty_id UUID NOT NULL REFERENCES public.faculties(id),
    department_id UUID NOT NULL REFERENCES public.departments(id),
    office_room VARCHAR(50),                        -- ห้องพักอาจารย์
    phone VARCHAR(30),
    line_id VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. ตารางข้อมูลประวัตินักศึกษาเชิงลึก (Students)
CREATE TABLE IF NOT EXISTS public.students (
    student_id VARCHAR(15) PRIMARY KEY,             -- รหัสนักศึกษา เช่น '650602001'
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    prefix_th VARCHAR(20) NOT NULL,                 -- คำนำหน้า เช่น 'นาย', 'น.ส.'
    first_name_th VARCHAR(100) NOT NULL,
    last_name_th VARCHAR(100) NOT NULL,
    first_name_en VARCHAR(100),
    last_name_en VARCHAR(100),
    citizen_id VARCHAR(13) UNIQUE,                  -- เลขบัตรประชาชน 13 หลัก
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    blood_group VARCHAR(5) CHECK (blood_group IN ('A', 'B', 'O', 'AB')),
    
    -- รูปภาพยืนยันตัวตน
    face_photo_url TEXT,                            -- ลิงก์รูปถ่ายหน้าตรงนักศึกษา (สำหรับแสดงบนบัตร/โปรไฟล์)
    student_card_url TEXT,                          -- ลิงก์รูปบัตรนักศึกษาดิจิทัล
    
    -- ข้อมูลการศึกษา
    faculty_id UUID NOT NULL REFERENCES public.faculties(id),
    department_id UUID NOT NULL REFERENCES public.departments(id),
    advisor_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    enrollment_year INT NOT NULL,                   -- ปีที่เข้าศึกษา พ.ศ. เช่น 2565
    year_level INT NOT NULL DEFAULT 1 CHECK (year_level BETWEEN 1 AND 8),
    education_status VARCHAR(25) NOT NULL DEFAULT 'studying'
        CHECK (education_status IN ('studying', 'on_leave', 'probation', 'graduated', 'retired')),
    gpax NUMERIC(3, 2) NOT NULL DEFAULT 0.00 CHECK (gpax BETWEEN 0.00 AND 4.00),
    current_term_gpa NUMERIC(3, 2) NOT NULL DEFAULT 0.00 CHECK (current_term_gpa BETWEEN 0.00 AND 4.00),
    earned_credits INT NOT NULL DEFAULT 0 CHECK (earned_credits >= 0),

    -- ข้อมูลการติดต่อและที่อยู่ (Contact & Address)
    phone VARCHAR(20),
    personal_email VARCHAR(150),
    line_id VARCHAR(50),
    current_address TEXT,                           -- ที่อยู่ปัจจุบัน / หอพัก
    permanent_address TEXT,                         -- ที่อยู่ตามทะเบียนบ้าน
    subdistrict VARCHAR(100),                       -- แขวง/ตำบล
    district VARCHAR(100),                          -- เขต/อำเภอ
    province VARCHAR(100),                          -- จังหวัด
    postal_code VARCHAR(10),                        -- รหัสไปรษณีย์

    -- ข้อมูลผู้ปกครอง / ผู้ติดต่อฉุกเฉิน (Emergency Contact)
    emergency_contact_name VARCHAR(150),
    emergency_contact_relation VARCHAR(50),
    emergency_contact_phone VARCHAR(20),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- ส่วนที่ 3: รายวิชา กลุ่มเรียน ตารางเรียน และการลงทะเบียน (Courses & Enrollments)
-- =============================================================================

-- 8. ตารางรายวิชาตามหลักสูตร (Subjects)
CREATE TABLE IF NOT EXISTS public.subjects (
    subject_code VARCHAR(15) PRIMARY KEY,           -- รหัสวิชา เช่น 'ENGCE302', 'GEN101'
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    name_th VARCHAR(150) NOT NULL,                  -- ชื่อวิชาภาษาไทย เช่น 'ระบบฐานข้อมูล'
    name_en VARCHAR(150) NOT NULL,                  -- ชื่อวิชาภาษาอังกฤษ เช่น 'Database Systems'
    credits INT NOT NULL DEFAULT 3 CHECK (credits > 0),
    lecture_hours INT NOT NULL DEFAULT 3,
    lab_hours INT NOT NULL DEFAULT 0,
    self_study_hours INT NOT NULL DEFAULT 6,
    is_lab BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. ตารางกลุ่มเรียน / ตอนเรียนที่เปิดสอนในแต่ละเทอม (Course Sections)
CREATE TABLE IF NOT EXISTS public.course_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    section_number VARCHAR(20) NOT NULL,            -- เช่น 'Sec.1', 'Sec.2'
    teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    day_of_week VARCHAR(10) NOT NULL                -- 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
        CHECK (day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN')),
    start_time TIME NOT NULL,                       -- เช่น '09:00'
    end_time TIME NOT NULL,                         -- เช่น '12:00'
    time_display VARCHAR(30) NOT NULL,              -- เช่น '09:00–12:00'
    room VARCHAR(100) NOT NULL,                     -- เช่น 'ห้อง 1604', 'Lab 1502'
    max_students INT NOT NULL DEFAULT 40,
    enrolled_count INT NOT NULL DEFAULT 0,
    course_progress INT NOT NULL DEFAULT 0 CHECK (course_progress BETWEEN 0 AND 100),
    status_student_badge VARCHAR(100),              -- เช่น 'เช็คชื่อแล้ว', 'เริ่มบ่ายนี้'
    status_teacher_badge VARCHAR(100),              -- เช่น '+ เปิดเช็คชื่อ'
    course_summary_student VARCHAR(150),            -- เช่น 'งานค้าง 1 • คะแนนเก็บ 28/40'
    course_summary_teacher VARCHAR(150),            -- เช่น 'ส่งแล้ว 28/40 • รอตรวจ 8 • รอส่งเกรด'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (subject_code, term_id, section_number)
);

-- 10. ตารางการลงทะเบียนเรียนและผลการเรียนรายวิชา (Enrollments & Grades)
CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    subject_code VARCHAR(15) NOT NULL REFERENCES public.subjects(subject_code) ON DELETE CASCADE,
    
    enrollment_status VARCHAR(20) NOT NULL DEFAULT 'enrolled'
        CHECK (enrollment_status IN ('enrolled', 'withdrawn', 'completed')),
    
    -- คะแนนย่อยในระหว่างเรียน (Sub-scores)
    quiz_score NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (quiz_score >= 0),     -- สอบย่อย เช่น 12/15
    lab_score NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (lab_score >= 0),       -- คะแนน Lab เช่น 16/25
    
    -- คะแนนหลักสำหรับตัดเกรด (รวม 100 คะแนน ตามหน้า GradeSubmitScreen)
    coursework_score INT NOT NULL DEFAULT 0 CHECK (coursework_score BETWEEN 0 AND 30), -- คะแนนเก็บ (/30)
    midterm_score INT NOT NULL DEFAULT 0 CHECK (midterm_score BETWEEN 0 AND 30),       -- สอบกลางภาค (/30)
    final_score INT NOT NULL DEFAULT 0 CHECK (final_score BETWEEN 0 AND 40),           -- สอบปลายภาค (/40)
    total_score INT NOT NULL DEFAULT 0 CHECK (total_score BETWEEN 0 AND 100),          -- คะแนนรวม (/100)
    
    -- เกรดที่ได้
    grade_letter VARCHAR(10),                       -- 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'
    grade_display VARCHAR(25),                      -- เช่น 'A (4.0)', 'C+ (2.5) ⚠️'
    grade_point NUMERIC(3, 2) CHECK (grade_point BETWEEN 0.00 AND 4.00),
    grade_submit_status VARCHAR(20) NOT NULL DEFAULT 'ร่าง'
        CHECK (grade_submit_status IN ('ร่าง', 'ส่งแล้ว', 'ประกาศผลแล้ว')),
    is_warning BOOLEAN NOT NULL DEFAULT FALSE,      -- แจ้งเตือนเมื่อเกรดฉุด GPA (เช่น C+ ลงไป)
    attendance_rate NUMERIC(5, 2) NOT NULL DEFAULT 100.00, -- เปอร์เซ็นต์การเข้าเรียน เช่น 92.00
    pending_assignments INT NOT NULL DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, section_id)
);

-- =============================================================================
-- ส่วนที่ 4: เอกสารการสอน การบ้าน และการส่งงาน (Materials & Assignments)
-- =============================================================================

-- 11. ตารางเอกสารประกอบการสอน (Course Materials)
CREATE TABLE IF NOT EXISTS public.course_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,                    -- เช่น 'สไลด์ Lec 6 — Normalization'
    file_type VARCHAR(20) NOT NULL DEFAULT 'PDF',   -- 'PDF', 'PPTX', 'DOCX', 'ZIP'
    file_size_label VARCHAR(30) NOT NULL,           -- เช่น '2.4 MB'
    file_url TEXT NOT NULL,                         -- ลิงก์ดาวน์โหลดไฟล์
    updated_label VARCHAR(50) DEFAULT 'อัปเดตเมื่อวาน',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. ตารางงานที่สั่ง / การบ้าน (Assignments)
CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,                    -- เช่น 'HW6: ออกแบบ ER + Normalization'
    description TEXT,                               -- เช่น 'แนบ PDF/รูป • ส่งได้ถึง 23 ก.ย. 23:59'
    due_badge VARCHAR(50),                          -- เช่น 'ส่งใน 2 วัน'
    due_date TIMESTAMPTZ NOT NULL,
    max_score NUMERIC(5, 2) NOT NULL DEFAULT 10.00,
    submitted_count INT NOT NULL DEFAULT 0,         -- จำนวนคนที่ส่งแล้ว เช่น 28
    total_students INT NOT NULL DEFAULT 40,         -- จำนวนคนทั้งหมด เช่น 40
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. ตารางการส่งงานของนักศึกษา (Assignment Submissions)
CREATE TABLE IF NOT EXISTS public.assignment_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,                         -- ลิงก์ไฟล์ PDF/รูปภาพที่นักศึกษาส่ง
    file_name VARCHAR(200),
    status VARCHAR(20) NOT NULL DEFAULT 'submitted'
        CHECK (status IN ('pending', 'submitted', 'late', 'graded')),
    score NUMERIC(5, 2),
    teacher_feedback TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (assignment_id, student_id)
);

-- =============================================================================
-- ส่วนที่ 5: ระบบเช็กชื่อเข้าเรียน (Attendance Sessions & Records)
-- =============================================================================

-- 14. ตารางการเปิดห้องเช็กชื่อแต่ละคาบ (Attendance Sessions)
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES public.course_sections(id) ON DELETE CASCADE,
    session_date DATE NOT NULL DEFAULT CURRENT_DATE,
    week_number INT NOT NULL DEFAULT 1,
    room_code VARCHAR(20) NOT NULL,                 -- รหัสห้องเช็กชื่อ เช่น 'DB-0921'
    qr_code_payload TEXT,                           -- ข้อมูลสำหรับสร้าง QR Code
    open_time_label VARCHAR(50) DEFAULT '09:00–09:15',
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    present_count INT NOT NULL DEFAULT 0,
    total_students INT NOT NULL DEFAULT 40,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. ตารางบันทึกการเช็กชื่อรายบุคคล (Attendance Records)
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    status VARCHAR(15) NOT NULL DEFAULT 'absent'
        CHECK (status IN ('present', 'late', 'absent', 'leave')),
    check_in_time VARCHAR(10),                      -- เวลาที่กดเช็กชื่อ เช่น '09:03', '09:04'
    check_in_method VARCHAR(20) DEFAULT 'qr_scan'
        CHECK (check_in_method IN ('qr_scan', 'room_code', 'teacher_manual')),
    reminded_via_line BOOLEAN NOT NULL DEFAULT FALSE,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (session_id, student_id)
);

-- =============================================================================
-- ส่วนที่ 6: การเงิน ค่าเทอม และใบเสร็จรับเงิน (Tuition Invoices & Receipts)
-- =============================================================================

-- 16. ตารางใบแจ้งหนี้ค่าเทอมและค่าธรรมเนียม (Tuition Invoices)
CREATE TABLE IF NOT EXISTS public.tuition_invoices (
    invoice_no VARCHAR(30) PRIMARY KEY,             -- เช่น 'INV-2569-1-650602001'
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
    tuition_fee NUMERIC(10, 2) NOT NULL DEFAULT 15000.00,      -- ค่าหน่วยกิต/เหมาจ่าย
    university_fee NUMERIC(10, 2) NOT NULL DEFAULT 2000.00,    -- ค่าบำรุงมหาวิทยาลัย
    lab_equipment_fee NUMERIC(10, 2) NOT NULL DEFAULT 1500.00, -- ค่าธรรมเนียมปฏิบัติการคอมพิวเตอร์
    scholarship_discount NUMERIC(10, 2) NOT NULL DEFAULT 0.00, -- ส่วนลดทุนการศึกษา
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 18500.00,     -- ยอดสุทธิที่ต้องชำระ
    due_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'unpaid'
        CHECK (payment_status IN ('unpaid', 'verifying', 'paid', 'overdue', 'cancelled')),
    invoice_pdf_url TEXT,                           -- ลิงก์ใบแจ้งหนี้ PDF
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, term_id)
);

-- 17. ตารางใบเสร็จรับเงินและหลักฐานการชำระเงิน (Payment Receipts)
CREATE TABLE IF NOT EXISTS public.payment_receipts (
    receipt_no VARCHAR(30) PRIMARY KEY,             -- เลขที่ใบเสร็จ เช่น 'RCP-2569-00891'
    invoice_no VARCHAR(30) NOT NULL REFERENCES public.tuition_invoices(invoice_no) ON DELETE CASCADE,
    student_id VARCHAR(15) NOT NULL REFERENCES public.students(student_id) ON DELETE CASCADE,
    payment_method VARCHAR(30) NOT NULL DEFAULT 'qr_promptpay'
        CHECK (payment_method IN ('qr_promptpay', 'mobile_banking', 'bank_counter', 'credit_card', 'scholarship')),
    bank_name VARCHAR(100),                         -- เช่น 'ธนาคารกรุงไทย (KTB)'
    transaction_ref VARCHAR(100) UNIQUE,            -- รหัสอ้างอิงสลิปธนาคาร
    amount_paid NUMERIC(10, 2) NOT NULL CHECK (amount_paid >= 0),
    paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    slip_image_url TEXT,                            -- รูปภาพสลิปโอนเงินที่นักศึกษาอัปโหลด
    receipt_pdf_url TEXT NOT NULL,                  -- ลิงก์ไฟล์ใบเสร็จรับเงินอิเล็กทรอนิกส์ (e-Receipt PDF)
    finance_officer_name VARCHAR(150) DEFAULT 'กองคลัง มทร.พระนคร',
    is_verified BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- ส่วนที่ 7: ระบบยื่นคำร้อง ขอเอกสาร และแจ้งซ่อม (Service Requests)
-- =============================================================================

-- 18. ตารางคำร้องและแจ้งเรื่อง (Service Requests)
CREATE TABLE IF NOT EXISTS public.service_requests (
    request_code VARCHAR(20) PRIMARY KEY,           -- รหัสคำร้อง เช่น '#RQ-1042', '#RQ-1039'
    student_id VARCHAR(15) REFERENCES public.students(student_id) ON DELETE CASCADE,
    category VARCHAR(20) NOT NULL DEFAULT 'document'
        CHECK (category IN ('document', 'repair', 'complaint', 'other')),
    title VARCHAR(200) NOT NULL,                    -- เช่น 'ขอใบรับรอง ENG', 'แอร์ห้อง 1604 ไม่เย็น'
    description TEXT,
    room_location VARCHAR(100),                     -- เช่น 'ห้อง 1604' (กรณีแจ้งซ่อม)
    attachment_image_url TEXT,                      -- รูปภาพประกอบคำร้อง หรือใบเสร็จค่าธรรมเนียม
    result_pdf_url TEXT,                            -- ลิงก์เอกสาร PDF เมื่อดำเนินการเสร็จ (เช่น Transcript)
    status_student VARCHAR(50) NOT NULL DEFAULT 'รอดำเนินการ', -- สถานะฝั่งนักศึกษา
    status_teacher VARCHAR(50) NOT NULL DEFAULT 'รออนุมัติ',     -- สถานะฝั่งอาจารย์/เจ้าหน้าที่
    chip_color_hex VARCHAR(10) NOT NULL DEFAULT '#FFC107',     -- สีป้ายสถานะ
    progress NUMERIC(3, 2) NOT NULL DEFAULT 0.20 CHECK (progress BETWEEN 0.00 AND 1.00),
    assigned_teacher_id VARCHAR(20) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- ส่วนที่ 8: ข่าวสาร ทุนการศึกษา และการแจ้งเตือน (News & Notifications)
-- =============================================================================

-- 19. ตารางข่าวสารและประกาศ (News Announcements)
CREATE TABLE IF NOT EXISTS public.news_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(250) NOT NULL,                    -- เช่น 'ทุนเรียนดีคณะวิศวฯ 5,000 บาท (20 ทุน)'
    subtitle VARCHAR(150) NOT NULL,                 -- เช่น 'ทุน • ปิดรับ 30 ก.ย.'
    news_type VARCHAR(30) NOT NULL                  -- 'ทุน', 'ฝึกงาน', 'กิจกรรม'
        CHECK (news_type IN ('ทุน', 'ฝึกงาน', 'กิจกรรม', 'ประกาศ')),
    detail TEXT NOT NULL,                           -- รายละเอียดข่าว
    banner_image_url TEXT,                          -- รูปแบนเนอร์ข่าว
    button_label VARCHAR(50) NOT NULL DEFAULT 'ดูรายละเอียด',
    action_url TEXT,
    min_gpa_required NUMERIC(3, 2),                 -- เกรดขั้นต่ำกรณีสมัครทุน
    published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expire_date DATE
);

-- 20. ตารางการแจ้งเตือน (Notifications)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE, -- NULL = แจ้งเตือนทุกคน
    title VARCHAR(200) NOT NULL,                    -- เช่น 'HW6 ใกล้ครบกำหนด'
    subtitle VARCHAR(250) NOT NULL,                 -- เช่น 'ENGCE302 — ส่งใน 2 วัน (23 ก.ย. 23:59)'
    accent_color_hex VARCHAR(10) NOT NULL DEFAULT '#652D91',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- ส่วนที่ 9: Indexes สำหรับเพิ่มประสิทธิภาพการค้นหา (Performance Indexes)
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_students_department ON public.students(department_id);
CREATE INDEX IF NOT EXISTS idx_students_advisor ON public.students(advisor_id);
CREATE INDEX IF NOT EXISTS idx_sections_term_subject ON public.course_sections(term_id, subject_code);
CREATE INDEX IF NOT EXISTS idx_sections_teacher ON public.course_sections(teacher_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_term ON public.enrollments(student_id, term_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_section ON public.enrollments(section_id);
CREATE INDEX IF NOT EXISTS idx_attendance_session ON public.attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student ON public.attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_invoices_student ON public.tuition_invoices(student_id);
CREATE INDEX IF NOT EXISTS idx_receipts_student ON public.payment_receipts(student_id);
CREATE INDEX IF NOT EXISTS idx_requests_student ON public.service_requests(student_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);

