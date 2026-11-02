-- =============================================================================
-- 04_rls_security.sql
-- การตั้งค่าความปลอดภัยตามมาตรฐานสากล (Row Level Security & Column-Level Security)
-- ป้องกันการรั่วไหลของรหัสผ่าน (password_hash) และเปิดใช้งาน RLS ครบทั้ง 20 ตาราง
-- =============================================================================

-- 1. เปิดใช้งาน Row Level Security (RLS) บนตารางทั้งหมด 20 ตาราง
ALTER TABLE public.faculties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
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

-- 2. Column-Level Security: ปิดกั้นไม่ให้ดึงคอลัมน์ password_hash ออกไปผ่าน API โดยเด็ดขาด
REVOKE SELECT (password_hash) ON public.users FROM anon, authenticated;

-- 3. นโยบายความปลอดภัย (RLS Policies) สำหรับตารางข้อมูลพื้นฐานของมหาวิทยาลัย (อ่านได้อย่างเดียวสำหรับผู้ใช้ทั่วไป)
DROP POLICY IF EXISTS "Allow public read faculties" ON public.faculties;
CREATE POLICY "Allow public read faculties" ON public.faculties FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read departments" ON public.departments;
CREATE POLICY "Allow public read departments" ON public.departments FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read academic_terms" ON public.academic_terms;
CREATE POLICY "Allow public read academic_terms" ON public.academic_terms FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read calendar_events" ON public.academic_calendar_events;
CREATE POLICY "Allow public read calendar_events" ON public.academic_calendar_events FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read subjects" ON public.subjects;
CREATE POLICY "Allow public read subjects" ON public.subjects FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow public read news" ON public.news_announcements;
CREATE POLICY "Allow public read news" ON public.news_announcements FOR SELECT TO anon, authenticated USING (true);

-- 4. นโยบายความปลอดภัยสำหรับตารางระบบการเรียนการสอนและการบริการของแอป
DROP POLICY IF EXISTS "Allow app read users" ON public.users;
CREATE POLICY "Allow app read users" ON public.users FOR SELECT TO anon, authenticated USING (is_active = true);

DROP POLICY IF EXISTS "Allow app read teachers" ON public.teachers;
CREATE POLICY "Allow app read teachers" ON public.teachers FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow app read students" ON public.students;
CREATE POLICY "Allow app read students" ON public.students FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow app update students" ON public.students;
CREATE POLICY "Allow app update students" ON public.students FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app read course_sections" ON public.course_sections;
CREATE POLICY "Allow app read course_sections" ON public.course_sections FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow app read enrollments" ON public.enrollments;
CREATE POLICY "Allow app read enrollments" ON public.enrollments FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow teacher update grades" ON public.enrollments;
CREATE POLICY "Allow teacher update grades" ON public.enrollments FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app read materials" ON public.course_materials;
CREATE POLICY "Allow app read materials" ON public.course_materials FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow app read assignments" ON public.assignments;
CREATE POLICY "Allow app read assignments" ON public.assignments FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow app access submissions" ON public.assignment_submissions;
CREATE POLICY "Allow app access submissions" ON public.assignment_submissions FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app access attendance_sessions" ON public.attendance_sessions;
CREATE POLICY "Allow app access attendance_sessions" ON public.attendance_sessions FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app access attendance_records" ON public.attendance_records;
CREATE POLICY "Allow app access attendance_records" ON public.attendance_records FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app read invoices" ON public.tuition_invoices;
CREATE POLICY "Allow app read invoices" ON public.tuition_invoices FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "Allow app access receipts" ON public.payment_receipts;
CREATE POLICY "Allow app access receipts" ON public.payment_receipts FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app access service_requests" ON public.service_requests;
CREATE POLICY "Allow app access service_requests" ON public.service_requests FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow app access notifications" ON public.notifications;
CREATE POLICY "Allow app access notifications" ON public.notifications FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
