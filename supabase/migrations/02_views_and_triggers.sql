-- =============================================================================
-- 02_views_and_triggers.sql
-- Stored Functions, Triggers (คำนวณเกรดอัตโนมัติ) และ Views สำหรับ Backend / Flutter
-- ยึดมาตรฐานความปลอดภัย PostgreSQL 15+ (SET search_path & security_invoker = true)
-- =============================================================================

-- 1. ฟังก์ชันและ Trigger คำนวณคะแนนรวมและตัดเกรดอัตโนมัติ (ตามเกณฑ์ มทร.พระนคร)
CREATE OR REPLACE FUNCTION public.fn_auto_calculate_grade()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    -- คำนวณคะแนนรวมจาก คะแนนเก็บ (30) + กลางภาค (30) + ปลายภาค (40)
    NEW.total_score := COALESCE(NEW.coursework_score, 0) + COALESCE(NEW.midterm_score, 0) + COALESCE(NEW.final_score, 0);
    NEW.updated_at := NOW();

    -- กรณีมีการกรอกคะแนนสอบหรือยังไม่ได้กำหนดเกรดเอง ให้คำนวณเกรดตามเกณฑ์มาตรฐาน
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

-- =============================================================================
-- 2. Views สำหรับให้ฝั่ง Backend และแอป Flutter ดึงข้อมูลไปใช้ได้ทันที (ไม่ต้อง JOIN เอง)
-- กำหนด WITH (security_invoker = true) เพื่อเคารพสิทธิ์ RLS ของผู้เรียกใช้งานตามมาตรฐานสากล
-- =============================================================================

-- View 1: ข้อมูลโปรไฟล์นักศึกษาฉบับเต็ม (รวมคณะ สาขา อาจารย์ที่ปรึกษา และอีเมล โดยไม่เปิดเผย password_hash)
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

-- View 2: ตารางเรียนและรายวิชาของนักศึกษาในเทอมปัจจุบัน (ตรงกับหน้า Timetable & Courses)
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

-- View 4: ใบกรอกคะแนนและตัดเกรดสำหรับอาจารย์ (ตรงกับหน้า GradeSubmitScreen)
CREATE OR REPLACE VIEW public.v_teacher_grade_sheet
WITH (security_invoker = true)
AS
SELECT
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
JOIN public.subjects sub ON cs.subject_code = sub.subject_code;

-- View 5: ประวัติการชำระเงินค่าเทอมและใบเสร็จรับเงินของนักศึกษา
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
LEFT JOIN public.payment_receipts rcp ON inv.invoice_no = rcp.invoice_no;
