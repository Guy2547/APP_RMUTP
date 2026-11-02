-- =============================================================================
-- 03_seed_mock_data.sql
-- ข้อมูลจำลองเริ่มต้น (Mock Data) ของ มทร.พระนคร (RMUTP Campus App)
-- ครอบคลุมทุกหน้าจอของแอป Flutter และข้อมูลจริงระดับมหาวิทยาลัย
-- =============================================================================

-- 1. ข้อมูลคณะวิชา (Faculties)
INSERT INTO public.faculties (id, code, name_th, name_en, campus, building, phone, website_url)
VALUES
    ('11111111-1111-1111-1111-111111111101', 'ENG', 'คณะวิศวกรรมศาสตร์', 'Faculty of Engineering', 'ศูนย์พระนครเหนือ', 'อาคาร 16 (ตึกวิศวกรรมศาสตร์)', '02-665-3777 ต่อ 7000', 'https://eng.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111102', 'BUS', 'คณะบริหารธุรกิจ', 'Faculty of Business Administration', 'ศูนย์พณิชยการพระนคร', 'อาคาร 1', '02-665-3555', 'https://bus.rmutp.ac.th'),
    ('11111111-1111-1111-1111-111111111103', 'SCI', 'คณะวิทยาศาสตร์และเทคโนโลยี', 'Faculty of Science and Technology', 'ศูนย์พระนครเหนือ', 'อาคารเอนกประสงค์', '02-665-3777 ต่อ 6500', 'https://sci.rmutp.ac.th')
ON CONFLICT (code) DO NOTHING;

-- 2. ข้อมูลภาควิชา / สาขาวิชา (Departments)
INSERT INTO public.departments (id, faculty_id, code, name_th, name_en, degree_name_th, total_credits_required)
VALUES
    ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'ENGCE', 'วิศวกรรมคอมพิวเตอร์', 'Computer Engineering', 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)', 132),
    ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111101', 'ENGEE', 'วิศวกรรมไฟฟ้า', 'Electrical Engineering', 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)', 135),
    ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111103', 'SCICS', 'วิทยาการคอมพิวเตอร์', 'Computer Science', 'วิทยาศาสตรบัณฑิต (วท.บ.)', 128)
ON CONFLICT (code) DO NOTHING;

-- 3. ข้อมูลปีการศึกษาและภาคเรียน (Academic Terms)
INSERT INTO public.academic_terms (id, academic_year, semester, term_label, start_date, end_date, midterm_start_date, midterm_end_date, final_start_date, final_end_date, grade_submit_deadline, is_current)
VALUES
    ('33333333-3333-3333-3333-333333333301', 2568, 2, '2/2568', '2025-11-15', '2026-03-31', '2026-01-12', '2026-01-16', '2026-03-16', '2026-03-27', '2026-04-05', FALSE),
    ('33333333-3333-3333-3333-333333333302', 2569, 1, '1/2569', '2026-06-15', '2026-10-31', '2026-10-13', '2026-10-17', '2026-10-26', '2026-10-30', '2026-09-30', TRUE)
ON CONFLICT (academic_year, semester) DO NOTHING;

-- 4. ปฏิทินการศึกษา (Academic Calendar Events - ตรงกับ MockData.academicCalendar)
INSERT INTO public.academic_calendar_events (term_id, title, date_display, event_type, start_date, end_date, description)
VALUES
    ('33333333-3333-3333-3333-333333333302', 'หมดเขตส่ง HW6', '23 ก.ย.', 'deadline', '2026-09-23', '2026-09-23', 'กำหนดส่งการบ้าน HW6 วิชา ENGCE302 ระบบฐานข้อมูล ภายในเวลา 23:59 น.'),
    ('33333333-3333-3333-3333-333333333302', 'ปิดรับทุน / ถอนรายวิชา', '30 ก.ย.', 'scholarship', '2026-09-30', '2026-09-30', 'วันสุดท้ายของการยื่นขอทุนเรียนดีคณะวิศวฯ และการถอนรายวิชาติด W'),
    ('33333333-3333-3333-3333-333333333302', 'สัมภาษณ์สหกิจ', '5 ต.ค.', 'coop', '2026-10-05', '2026-10-05', 'สัมภาษณ์นักศึกษาสหกิจศึกษา ณ ศูนย์สหกิจศึกษาและพัฒนาอาชีพ'),
    ('33333333-3333-3333-3333-333333333302', 'สอบกลางภาค', '13–17 ต.ค.', 'exam', '2026-10-13', '2026-10-17', 'สัปดาห์การสอบกลางภาคเรียนที่ 1 ปีการศึกษา 2569');

-- 5. ข้อมูลบัญชีผู้ใช้ (Users)
INSERT INTO public.users (id, email, password_hash, role, preferred_language, notification_enabled)
VALUES
    -- อาจารย์
    ('44444444-4444-4444-4444-444444444401', 'surachai.w@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'teacher', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444402', 'naphat.c@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'teacher', 'th', TRUE),
    -- นักศึกษา
    ('44444444-4444-4444-4444-444444444411', 's650602001@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444412', 's650602002@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE),
    ('44444444-4444-4444-4444-444444444413', 's650602003@rmutp.ac.th', crypt('password123', gen_salt('bf')), 'student', 'th', TRUE)
ON CONFLICT (email) DO NOTHING;

-- 6. ข้อมูลอาจารย์ (Teachers)
INSERT INTO public.teachers (teacher_id, user_id, academic_rank, first_name_th, last_name_th, first_name_en, last_name_en, face_photo_url, faculty_id, department_id, office_room, phone, line_id)
VALUES
    ('T-1024', '44444444-4444-4444-4444-444444444401', 'อ.', 'สุรชัย', 'วงศ์ใหญ่', 'Surachai', 'Wongyai', 'https://ui-avatars.com/api/?name=Surachai+W&background=652D91&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'ห้องพักอาจารย์ 1608', '081-234-5678', '@aj_surachai'),
    ('T-1025', '44444444-4444-4444-4444-444444444402', 'ผศ.', 'นภัส', 'เจริญผล', 'Naphat', 'Charoenphon', 'https://ui-avatars.com/api/?name=Naphat+C&background=652D91&color=fff&size=256', '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'ห้องพักอาจารย์ 1504', '089-876-5432', '@aj_naphat')
ON CONFLICT (teacher_id) DO NOTHING;

-- 7. ข้อมูลประวัตินักศึกษาเชิงลึก (Students - ครบทั้งรูปหน้า ที่อยู่ ผู้ปกครอง เกรด หน่วยกิต)
INSERT INTO public.students (
    student_id, user_id, prefix_th, first_name_th, last_name_th, first_name_en, last_name_en,
    citizen_id, birth_date, gender, blood_group, face_photo_url, student_card_url,
    faculty_id, department_id, advisor_id, enrollment_year, year_level, education_status,
    gpax, current_term_gpa, earned_credits,
    phone, personal_email, line_id, current_address, permanent_address,
    subdistrict, district, province, postal_code,
    emergency_contact_name, emergency_contact_relation, emergency_contact_phone
)
VALUES
    (
        '650602001', '44444444-4444-4444-4444-444444444411',
        'น.ส.', 'มินตรา', 'ใจดี', 'Mintra', 'Jaidee',
        '1100501234567', '2004-05-14', 'female', 'O',
        'https://ui-avatars.com/api/?name=Mintra+Jaidee&background=F6DC04&color=2A114B&size=256',
        'https://rmutp.ac.th/mock-storage/cards/card_650602001.png',
        '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'T-1024',
        2565, 2, 'studying', 3.42, 3.55, 87,
        '092-345-6789', 'mintra.jaidee@gmail.com', 'mintra_ce65',
        'หอพักนักศึกษาเคียงมอ ห้อง 402 ซ.วงศ์สว่าง 11', '99/12 หมู่ 4 ถ.พิบูลสงคราม',
        'วงศ์สว่าง', 'บางซื่อ', 'กรุงเทพมหานคร', '10800',
        'นางสมศรี ใจดี', 'มารดา', '081-999-8877'
    ),
    (
        '650602002', '44444444-4444-4444-4444-444444444412',
        'นาย', 'ภูริ', 'พัฒนากุล', 'Phuri', 'Phattanakul',
        '1100502345678', '2004-08-21', 'male', 'A',
        'https://ui-avatars.com/api/?name=Phuri+P&background=652D91&color=fff&size=256',
        'https://rmutp.ac.th/mock-storage/cards/card_650602002.png',
        '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'T-1024',
        2565, 2, 'studying', 3.15, 3.20, 87,
        '095-111-2233', 'phuri.dev@gmail.com', 'phuri_ce65',
        'คอนโดเดอะทรี อินเตอร์เชนจ์ ชั้น 12', '45/8 ถ.ประชาราษฎร์สาย 1',
        'บางซื่อ', 'บางซื่อ', 'กรุงเทพมหานคร', '10800',
        'นายวิชัย พัฒนากุล', 'บิดา', '086-555-4433'
    ),
    (
        '650602003', '44444444-4444-4444-4444-444444444413',
        'น.ส.', 'กันยา', 'รัตนโชติ', 'Kanya', 'Rattanachot',
        '1100503456789', '2004-11-03', 'female', 'B',
        'https://ui-avatars.com/api/?name=Kanya+R&background=E91E63&color=fff&size=256',
        'https://rmutp.ac.th/mock-storage/cards/card_650602003.png',
        '11111111-1111-1111-1111-111111111101', '22222222-2222-2222-2222-222222222201', 'T-1025',
        2565, 2, 'studying', 2.65, 2.75, 84,
        '098-765-4321', 'kanya.rat@gmail.com', 'kanya_ce65',
        '120/5 ซ.จรัญสนิทวงศ์ 96/1', '120/5 ซ.จรัญสนิทวงศ์ 96/1',
        'บางอ้อ', 'บางพลัด', 'กรุงเทพมหานคร', '10700',
        'นางกัลยา รัตนโชติ', 'มารดา', '089-123-4567'
    )
ON CONFLICT (student_id) DO NOTHING;

-- 8. ข้อมูลรายวิชา (Subjects)
INSERT INTO public.subjects (subject_code, department_id, name_th, name_en, credits, lecture_hours, lab_hours, self_study_hours, is_lab, description)
VALUES
    ('ENGCE302', '22222222-2222-2222-2222-222222222201', 'ระบบฐานข้อมูล', 'Database Systems', 3, 2, 2, 5, FALSE, 'การออกแบบฐานข้อมูลเชิงสัมพันธ์ ER Diagram, Normalization, SQL และการจัดการธุรกรรม'),
    ('ENGCE305', '22222222-2222-2222-2222-222222222201', 'เครือข่ายคอมพิวเตอร์', 'Computer Networks', 3, 2, 2, 5, TRUE, 'สถาปัตยกรรมเครือข่าย OSI Model, TCP/IP, Routing, Switching และความปลอดภัยเครือข่าย'),
    ('GEN101', NULL, 'ภาษาอังกฤษเพื่ออาชีพ', 'English for Careers', 3, 3, 0, 6, FALSE, 'ทักษะการสื่อสารภาษาอังกฤษในการทำงาน การเขียนเรซูเม่ และการสัมภาษณ์งาน'),
    ('ENGCE301', '22222222-2222-2222-2222-222222222201', 'โครงสร้างข้อมูล', 'Data Structures', 3, 2, 2, 5, FALSE, 'โครงสร้างข้อมูลพื้นฐาน Array, Linked List, Stack, Queue, Tree, Graph และอัลกอริทึม'),
    ('ENGCE303', '22222222-2222-2222-2222-222222222201', 'ระบบปฏิบัติการ', 'Operating Systems', 3, 3, 0, 6, FALSE, 'การจัดการโปรเซส เธรด หน่วยความจำ ระบบไฟล์ และ Deadlock'),
    ('MATH201', NULL, 'สถิติวิศวะ', 'Engineering Statistics', 3, 3, 0, 6, FALSE, 'ความน่าจะเป็น ตัวแปรสุ่ม การแจกแจงความน่าจะเป็น และการทดสอบสมมติฐานทางวิศวกรรม')
ON CONFLICT (subject_code) DO NOTHING;

-- 9. ข้อมูลกลุ่มเรียนที่เปิดสอน (Course Sections)
INSERT INTO public.course_sections (
    id, subject_code, term_id, section_number, teacher_id, day_of_week,
    start_time, end_time, time_display, room, max_students, enrolled_count,
    course_progress, status_student_badge, status_teacher_badge,
    course_summary_student, course_summary_teacher
)
VALUES
    -- รายวิชาเทอมปัจจุบัน (1/2569)
    (
        '55555555-5555-5555-5555-555555555501', 'ENGCE302', '33333333-3333-3333-3333-333333333302',
        'Sec.1', 'T-1024', 'MON', '09:00', '12:00', '09:00–12:00', 'ห้อง 1604',
        40, 40, 70, 'เช็คชื่อแล้ว', '+ เปิดเช็คชื่อ',
        'งานค้าง 1 • คะแนนเก็บ 28/40', 'ส่งแล้ว 28/40 • รอตรวจ 8 • รอส่งเกรด'
    ),
    (
        '55555555-5555-5555-5555-555555555502', 'ENGCE305', '33333333-3333-3333-3333-333333333302',
        'Sec.2', 'T-1025', 'MON', '13:00', '16:00', '13:00–16:00', 'Lab 1502',
        40, 38, 45, 'เริ่มบ่ายนี้', '+ เปิดเช็คชื่อ',
        'งานค้าง 1 • Lab สัปดาห์ 6', 'ยังไม่เริ่มส่งเกรด • 38 คน'
    ),
    (
        '55555555-5555-5555-5555-555555555503', 'GEN101', '33333333-3333-3333-3333-333333333302',
        'Sec.1', NULL, 'WED', '16:30', '18:00', '16:30–18:00', 'ออนไลน์ MS Teams',
        60, 55, 0, '-', '-',
        'ไม่มีงานค้าง • เรียนออนไลน์', 'เรียนออนไลน์รวม'
    ),
    -- รายวิชาเทอมที่ผ่านมา (2/2568 สำหรับแสดงผลการเรียนในหน้า GradesScreen)
    (
        '55555555-5555-5555-5555-555555555511', 'ENGCE301', '33333333-3333-3333-3333-333333333301',
        'Sec.1', 'T-1024', 'TUE', '09:00', '12:00', '09:00–12:00', 'ห้อง 1602',
        40, 40, 100, 'จบรายวิชา', 'ส่งเกรดแล้ว', 'เกรด A', 'ส่งเกรดแล้ว'
    ),
    (
        '55555555-5555-5555-5555-555555555512', 'ENGCE303', '33333333-3333-3333-3333-333333333301',
        'Sec.1', 'T-1025', 'THU', '13:00', '16:00', '13:00–16:00', 'ห้อง 1605',
        40, 40, 100, 'จบรายวิชา', 'ส่งเกรดแล้ว', 'เกรด B+', 'ส่งเกรดแล้ว'
    ),
    (
        '55555555-5555-5555-5555-555555555513', 'MATH201', '33333333-3333-3333-3333-333333333301',
        'Sec.1', NULL, 'FRI', '09:00', '12:00', '09:00–12:00', 'ห้อง 1201',
        50, 48, 100, 'จบรายวิชา', 'ส่งเกรดแล้ว', 'เกรด C+', 'ส่งเกรดแล้ว'
    )
ON CONFLICT (subject_code, term_id, section_number) DO NOTHING;

-- 10. ข้อมูลการลงทะเบียนเรียนและคะแนน (Enrollments & Grades)
INSERT INTO public.enrollments (
    student_id, section_id, term_id, subject_code, enrollment_status,
    quiz_score, lab_score, coursework_score, midterm_score, final_score,
    grade_submit_status, attendance_rate, pending_assignments
)
VALUES
    -- เทอมปัจจุบัน (1/2569) ของวิชา ENGCE302 (ตรงกับหน้าส่งเกรดอาจารย์ GradeSubmitScreen)
    ('650602001', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 12.0, 16.0, 27, 26, 33, 'ส่งแล้ว', 92.00, 1),
    ('650602002', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 11.0, 14.0, 24, 22, 28, 'ร่าง', 88.00, 1),
    ('650602003', '55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333302', 'ENGCE302', 'enrolled', 9.0, 11.0, 20, 15, 22, 'ร่าง', 75.00, 2),

    -- เทอมปัจจุบัน (1/2569) วิชาอื่นๆ ของ น.ส.มินตรา (650602001)
    ('650602001', '55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333302', 'ENGCE305', 'enrolled', 13.0, 18.0, 25, 24, 26, 'ร่าง', 95.00, 1),
    ('650602001', '55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333302', 'GEN101', 'enrolled', 14.0, 0.0, 25, 22, 25, 'ประกาศผลแล้ว', 100.00, 0),

    -- เทอมที่ผ่านมา (2/2568) ของ น.ส.มินตรา (ตรงกับหน้า GradesScreen: A, B+, B, C+ ⚠️)
    ('650602001', '55555555-5555-5555-5555-555555555511', '33333333-3333-3333-3333-333333333301', 'ENGCE301', 'completed', 14.0, 22.0, 28, 27, 34, 'ประกาศผลแล้ว', 96.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555512', '33333333-3333-3333-3333-333333333301', 'ENGCE303', 'completed', 12.5, 20.0, 25, 23, 29, 'ประกาศผลแล้ว', 90.00, 0),
    ('650602001', '55555555-5555-5555-5555-555555555513', '33333333-3333-3333-3333-333333333301', 'MATH201', 'completed', 10.0, 0.0, 21, 19, 26, 'ประกาศผลแล้ว', 85.00, 0)
ON CONFLICT (student_id, section_id) DO NOTHING;

-- 11. เอกสารประกอบการสอน (Course Materials - ตรงกับหน้า CourseDetailScreen)
INSERT INTO public.course_materials (section_id, title, file_type, file_size_label, file_url, updated_label)
VALUES
    ('55555555-5555-5555-5555-555555555501', 'สไลด์ Lec 6 — Normalization', 'PDF', '2.4 MB', 'https://rmutp.ac.th/mock-storage/materials/ENGCE302_Lec6_Normalization.pdf', 'อัปเดตเมื่อวาน'),
    ('55555555-5555-5555-5555-555555555501', 'สไลด์ Lec 5 — ER Diagram & Relational Model', 'PDF', '3.1 MB', 'https://rmutp.ac.th/mock-storage/materials/ENGCE302_Lec5_ERD.pdf', 'สัปดาห์ที่แล้ว'),
    ('55555555-5555-5555-5555-555555555502', 'Lab 6 — การตั้งค่า VLAN & Routing เบื้องต้น', 'PDF', '1.8 MB', 'https://rmutp.ac.th/mock-storage/materials/ENGCE305_Lab6_VLAN.pdf', '2 วันที่แล้ว');

-- 12. การบ้าน / งานที่สั่ง (Assignments - ตรงกับหน้า CourseDetailScreen)
INSERT INTO public.assignments (id, section_id, title, description, due_badge, due_date, max_score, submitted_count, total_students)
VALUES
    (
        '66666666-6666-6666-6666-666666666601',
        '55555555-5555-5555-5555-555555555501',
        'HW6: ออกแบบ ER + Normalization',
        'แนบ PDF/รูป • ส่งได้ถึง 23 ก.ย. 23:59',
        'ส่งใน 2 วัน',
        '2026-09-23 23:59:00+07',
        10.00, 28, 40
    ),
    (
        '66666666-6666-6666-6666-666666666602',
        '55555555-5555-5555-5555-555555555502',
        'Lab 6 Report: Packet Tracer Topology',
        'แนบไฟล์ .pkt และรายงาน PDF',
        'ส่งใน 5 วัน',
        '2026-09-26 23:59:00+07',
        15.00, 15, 38
    )
ON CONFLICT (id) DO NOTHING;

-- 13. ประวัติการส่งงานของนักศึกษา (Assignment Submissions)
INSERT INTO public.assignment_submissions (assignment_id, student_id, file_url, file_name, status, score, teacher_feedback)
VALUES
    ('66666666-6666-6666-6666-666666666601', '650602001', 'https://rmutp.ac.th/mock-storage/submissions/650602001_HW6.pdf', '650602001_HW6_ER_Normalization.pdf', 'submitted', 9.50, 'ออกแบบตาราง 3NF ได้ครบถ้วนดีมาก')
ON CONFLICT (assignment_id, student_id) DO NOTHING;

-- 14. การเปิดห้องเช็กชื่อ (Attendance Sessions - ตรงกับหน้า AttendanceScreen)
INSERT INTO public.attendance_sessions (id, section_id, session_date, week_number, room_code, qr_code_payload, open_time_label, is_open, present_count, total_students)
VALUES
    (
        '77777777-7777-7777-7777-777777777701',
        '55555555-5555-5555-5555-555555555501',
        CURRENT_DATE, 6, 'DB-0921',
        'RMUTP-ATTENDANCE|ENGCE302|SEC1|DB-0921',
        '09:00–09:15', TRUE, 28, 40
    )
ON CONFLICT (id) DO NOTHING;

-- 15. บันทึกการเช็กชื่อรายบุคคล (Attendance Records)
INSERT INTO public.attendance_records (session_id, student_id, status, check_in_time, check_in_method, reminded_via_line, note)
VALUES
    ('77777777-7777-7777-7777-777777777701', '650602001', 'present', '09:03', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602002', 'present', '09:04', 'qr_scan', FALSE, 'เช็คชื่อตรงเวลา'),
    ('77777777-7777-7777-7777-777777777701', '650602003', 'absent', NULL, 'teacher_manual', TRUE, 'ยังไม่มาเรียน')
ON CONFLICT (session_id, student_id) DO NOTHING;

-- 16. ข้อมูลใบแจ้งหนี้ค่าเทอม (Tuition Invoices)
INSERT INTO public.tuition_invoices (
    invoice_no, student_id, term_id, tuition_fee, university_fee, lab_equipment_fee,
    scholarship_discount, total_amount, due_date, payment_status, invoice_pdf_url
)
VALUES
    (
        'INV-2569-1-650602001', '650602001', '33333333-3333-3333-3333-333333333302',
        15000.00, 2000.00, 1500.00, 0.00, 18500.00,
        '2026-06-30', 'paid',
        'https://rmutp.ac.th/mock-storage/invoices/INV-2569-1-650602001.pdf'
    ),
    (
        'INV-2568-2-650602001', '650602001', '33333333-3333-3333-3333-333333333301',
        15000.00, 2000.00, 1500.00, 5000.00, 13500.00,
        '2025-11-30', 'paid',
        'https://rmutp.ac.th/mock-storage/invoices/INV-2568-2-650602001.pdf'
    ),
    (
        'INV-2569-1-650602002', '650602002', '33333333-3333-3333-3333-333333333302',
        15000.00, 2000.00, 1500.00, 0.00, 18500.00,
        '2026-06-30', 'paid',
        'https://rmutp.ac.th/mock-storage/invoices/INV-2569-1-650602002.pdf'
    ),
    (
        'INV-2569-1-650602003', '650602003', '33333333-3333-3333-3333-333333333302',
        15000.00, 2000.00, 1500.00, 0.00, 18500.00,
        '2026-06-30', 'verifying',
        'https://rmutp.ac.th/mock-storage/invoices/INV-2569-1-650602003.pdf'
    )
ON CONFLICT (invoice_no) DO NOTHING;

-- 17. ข้อมูลใบเสร็จรับเงินและสลิปโอนเงิน (Payment Receipts)
INSERT INTO public.payment_receipts (
    receipt_no, invoice_no, student_id, payment_method, bank_name,
    transaction_ref, amount_paid, paid_at, slip_image_url, receipt_pdf_url, finance_officer_name, is_verified
)
VALUES
    (
        'RCP-2569-00891', 'INV-2569-1-650602001', '650602001',
        'qr_promptpay', 'ธนาคารกรุงไทย (KTB)', 'KTB2026062009154421',
        18500.00, '2026-06-20 09:15:44+07',
        'https://rmutp.ac.th/mock-storage/slips/slip_650602001_2569_1.jpg',
        'https://rmutp.ac.th/mock-storage/receipts/RCP-2569-00891.pdf',
        'กองคลัง สำนักงานอธิการบดี มทร.พระนคร', TRUE
    ),
    (
        'RCP-2568-04512', 'INV-2568-2-650602001', '650602001',
        'mobile_banking', 'ธนาคารกสิกรไทย (KBANK)', 'KBANK2025111814221099',
        13500.00, '2025-11-18 14:22:10+07',
        'https://rmutp.ac.th/mock-storage/slips/slip_650602001_2568_2.jpg',
        'https://rmutp.ac.th/mock-storage/receipts/RCP-2568-04512.pdf',
        'กองคลัง สำนักงานอธิการบดี มทร.พระนคร', TRUE
    ),
    (
        'RCP-2569-00945', 'INV-2569-1-650602002', '650602002',
        'qr_promptpay', 'ธนาคารไทยพาณิชย์ (SCB)', 'SCB2026062211053310',
        18500.00, '2026-06-22 11:05:33+07',
        'https://rmutp.ac.th/mock-storage/slips/slip_650602002_2569_1.jpg',
        'https://rmutp.ac.th/mock-storage/receipts/RCP-2569-00945.pdf',
        'กองคลัง สำนักงานอธิการบดี มทร.พระนคร', TRUE
    )
ON CONFLICT (receipt_no) DO NOTHING;

-- 18. ข้อมูลคำร้องและแจ้งเรื่อง (Service Requests - ตรงกับหน้า RequestsScreen)
INSERT INTO public.service_requests (
    request_code, student_id, category, title, description, room_location,
    attachment_image_url, result_pdf_url, status_student, status_teacher,
    chip_color_hex, progress, assigned_teacher_id
)
VALUES
    (
        '#RQ-1042', '650602001', 'document',
        'ขอใบรับรอง ENG',
        'ขอใบรับรองการเป็นนักศึกษาฉบับภาษาอังกฤษ เพื่อใช้ยื่นสมัครโครงการแลกเปลี่ยนและทุนการศึกษา',
        NULL,
        'https://rmutp.ac.th/mock-storage/requests/fee_slip_1042.jpg',
        NULL,
        'รอดำเนินการ', 'รออนุมัติ', '#FFC107', 0.40, 'T-1024'
    ),
    (
        '#RQ-1039', '650602001', 'repair',
        'แอร์ห้อง 1604 ไม่เย็น',
        'เครื่องปรับอากาศตัวริมหน้าต่างในห้องเรียน 1604 มีแต่ลมออกและมีน้ำหยดระหว่างเรียนวิชาฐานข้อมูล',
        'ห้อง 1604 อาคารคณะวิศวกรรมศาสตร์',
        'https://rmutp.ac.th/mock-storage/requests/ac_room1604.jpg',
        NULL,
        'ช่างรับเรื่อง', 'ส่งต่อช่างแล้ว', '#2196F3', 0.70, 'T-1024'
    ),
    (
        '#RQ-1031', '650602001', 'document',
        'ขอ transcript',
        'ขอใบแสดงผลการศึกษา (Transcript) ฉบับไม่เป็นทางการ ตั้งแต่ชั้นปีที่ 1 ถึงปัจจุบัน',
        NULL,
        NULL,
        'https://rmutp.ac.th/mock-storage/transcripts/Transcript_650602001.pdf',
        'เสร็จแล้ว • โหลด PDF', 'เสร็จสิ้น', '#4CAF50', 1.00, 'T-1024'
    )
ON CONFLICT (request_code) DO NOTHING;

-- 19. ข้อมูลข่าวสารและประกาศ (News Announcements - ตรงกับหน้า NewsScreen)
INSERT INTO public.news_announcements (title, subtitle, news_type, detail, banner_image_url, button_label, min_gpa_required, expire_date)
VALUES
    (
        'ทุนเรียนดีคณะวิศวฯ 5,000 บาท (20 ทุน)',
        'ทุน • ปิดรับ 30 ก.ย.',
        'ทุน',
        'GPA ≥ 3.00 • แนบทรานสคริปต์ • สมัครออนไลน์ผ่านระบบกิจการนักศึกษา คณะวิศวกรรมศาสตร์ มทร.พระนคร',
        'https://rmutp.ac.th/mock-storage/news/scholarship_eng_2569.jpg',
        'ดูรายละเอียด', 3.00, '2026-09-30'
    ),
    (
        'ฝึกงาน/สหกิจ Toyota Tsusho — รับสหกิจ IT 10 อัตรา',
        'ฝึกงาน/สหกิจ • สมัครด่วน',
        'ฝึกงาน',
        'สัมภาษณ์ 5 ต.ค. ที่ศูนย์สหกิจ • รับนักศึกษาสาขาวิศวกรรมคอมพิวเตอร์และ IT มีเบี้ยเลี้ยงตลอดโครงการ',
        'https://rmutp.ac.th/mock-storage/news/coop_toyota_tsusho.jpg',
        'ดูรายละเอียด', 2.50, '2026-10-05'
    ),
    (
        'RMUTP Freshmen Day + ชมรมหุ่นยนต์',
        'กิจกรรม • 27 ก.ย.',
        'กิจกรรม',
        'เปิดรายละเอียดกิจกรรมต้อนรับน้องใหม่และบูธแสดงผลงานชมรมหุ่นยนต์ คณะวิศวกรรมศาสตร์ รับชั่วโมงกิจกรรม 6 ชม.',
        'https://rmutp.ac.th/mock-storage/news/freshmen_robotics.jpg',
        'ดูรายละเอียด', NULL, '2026-09-27'
    );

-- 20. ข้อมูลการแจ้งเตือน (Notifications - ตรงกับหน้า NotifScreen)
INSERT INTO public.notifications (user_id, title, subtitle, accent_color_hex, is_read)
VALUES
    (
        '44444444-4444-4444-4444-444444444411',
        'HW6 ใกล้ครบกำหนด',
        'ENGCE302 — ส่งใน 2 วัน (23 ก.ย. 23:59)',
        '#F44336', FALSE
    ),
    (
        '44444444-4444-4444-4444-444444444411',
        'ทุนคณะวิศวฯ ปิดรับ 30 ก.ย.',
        'คุณสมบัติผ่าน กดสมัครได้เลย',
        '#F6DC04', FALSE
    ),
    (
        '44444444-4444-4444-4444-444444444411',
        'เลื่อนห้อง ENGCE305 → Lab 1502',
        'จาก อ.นภัส เมื่อ 1 ชม.ก่อน',
        '#652D91', FALSE
    );

