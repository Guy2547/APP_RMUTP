import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../models/news_item.dart';
import '../models/notification_item.dart';
import '../models/request_item.dart';

class MockData {
  // ---------- Timetable (student) - ครบทั้งสัปดาห์ MON-FRI ----------
  static final List<Subject> timetableStudent = [
    Subject(
      code: 'ENGCE302',
      name: 'ระบบฐานข้อมูล',
      section: 'Sec.1',
      dayOfWeek: 'MON',
      time: '09:00–12:00',
      room: 'ห้อง 1604',
      teacher: 'อ.สุรชัย',
      status: 'เช็คชื่อแล้ว',
      courseSummary: 'งานค้าง 1 • คะแนนเก็บ 27/30',
      progress: 70,
      pendingAssignments: 1,
    ),
    Subject(
      code: 'ENGCE305',
      name: 'เครือข่ายคอมพิวเตอร์',
      section: 'Sec.2',
      dayOfWeek: 'MON',
      time: '13:00–16:00',
      room: 'Lab 1502',
      teacher: 'ผศ.นภัส',
      status: 'เริ่มบ่ายนี้',
      courseSummary: 'งานค้าง 1 • Lab สัปดาห์ 6',
      progress: 45,
      pendingAssignments: 1,
      isLab: true,
    ),
    Subject(
      code: 'ENGCE306',
      name: 'วิศวกรรมซอฟต์แวร์',
      section: 'Sec.1',
      dayOfWeek: 'TUE',
      time: '09:00–12:00',
      room: 'ห้อง 1602',
      teacher: 'อ.สุรชัย',
      status: 'ส่ง Sprint 2 แล้ว',
      courseSummary: 'ไม่มีงานค้าง • โปรเจกต์กลุ่ม',
      progress: 60,
      pendingAssignments: 0,
    ),
    Subject(
      code: 'GEN101',
      name: 'ภาษาอังกฤษเพื่ออาชีพ',
      section: 'Sec.1',
      dayOfWeek: 'WED',
      time: '16:30–18:00',
      room: 'ออนไลน์ MS Teams',
      teacher: 'อ.ดร.แพรวพรรณ',
      status: 'เรียนออนไลน์',
      courseSummary: 'ไม่มีงานค้าง • เรียนออนไลน์',
      progress: 55,
      pendingAssignments: 0,
    ),
    Subject(
      code: 'ENGCE307',
      name: 'ไมโครคอนโทรลเลอร์และระบบฝังตัว',
      section: 'Sec.1',
      dayOfWeek: 'THU',
      time: '13:00–16:00',
      room: 'Lab 1504',
      teacher: 'รศ.ดร.กิตติพงศ์',
      status: 'ปฏิบัติการ IoT',
      courseSummary: 'เตรียมบอร์ด ESP32',
      progress: 50,
      pendingAssignments: 0,
      isLab: true,
    ),
    Subject(
      code: 'ENGCE308',
      name: 'ปัญญาประดิษฐ์เบื้องต้น',
      section: 'Sec.1',
      dayOfWeek: 'FRI',
      time: '09:00–12:00',
      room: 'ห้อง 1605',
      teacher: 'รศ.ดร.กิตติพงศ์',
      status: 'บรรยายปกติ',
      courseSummary: 'อ่านบทความ ML ล่วงหน้า',
      progress: 65,
      pendingAssignments: 0,
    ),
  ];

  static final List<Subject> timetableTeacher = [
    Subject(
      code: 'ENGCE302',
      name: 'สอน ระบบฐานข้อมูล',
      section: 'Sec.1',
      dayOfWeek: 'MON',
      time: '09:00–12:00',
      room: 'ห้อง 1604',
      teacher: '12 คน',
      status: '+ เปิดเช็คชื่อ',
      courseSummary: 'ส่งแล้ว 7/12 • รอตรวจ 5 • รอส่งเกรด',
      progress: 70,
    ),
    Subject(
      code: 'ENGCE305',
      name: 'สอน เครือข่ายคอมพิวเตอร์',
      section: 'Sec.2',
      dayOfWeek: 'MON',
      time: '13:00–16:00',
      room: 'Lab 1502',
      teacher: '12 คน',
      status: '+ เปิดเช็คชื่อ',
      courseSummary: 'ยังไม่เริ่มส่งเกรด • 12 คน',
      progress: 45,
    ),
    Subject(
      code: 'ENGCE306',
      name: 'สอน วิศวกรรมซอฟต์แวร์',
      section: 'Sec.1',
      dayOfWeek: 'TUE',
      time: '09:00–12:00',
      room: 'ห้อง 1602',
      teacher: '12 คน',
      status: '+ เปิดเช็คชื่อ',
      courseSummary: 'ตรวจ Sprint 2 แล้ว • 12 คน',
      progress: 60,
    ),
  ];

  // ---------- Courses (student & teacher) ----------
  static List<Subject> get coursesStudent => timetableStudent;
  static List<Subject> get coursesTeacher => timetableTeacher;

  // ---------- Grades (student) ----------
  static final List<GradeItem> gradesStudent = [
    GradeItem(
      subjectCode: 'ENGCE301',
      subjectName: 'โครงสร้างข้อมูล',
      letter: 'A (4.0)',
      score: 4.0,
    ),
    GradeItem(
      subjectCode: 'ENGCE303',
      subjectName: 'ระบบปฏิบัติการ',
      letter: 'B+ (3.5)',
      score: 3.5,
    ),
    GradeItem(
      subjectCode: 'GEN101',
      subjectName: 'ภาษาอังกฤษเพื่ออาชีพ',
      letter: 'B (3.0)',
      score: 3.0,
    ),
    GradeItem(
      subjectCode: 'MATH201',
      subjectName: 'สถิติวิศวะ',
      letter: 'C+ (2.5) ⚠️',
      score: 2.5,
      isWarning: true,
    ),
  ];

  // ---------- Grade submit (teacher - รายชื่อนักศึกษาทั้ง 12 คน) ----------
  static final List<StudentRow> gradeSubmitRows = [
    StudentRow(id: '650602001', name: 'น.ส.มินตรา ใจดี', midterm: 26, finalExam: 33, coursework: 27, status: 'ส่งแล้ว'),
    StudentRow(id: '650602002', name: 'นายภูริ พัฒนากุล', midterm: 22, finalExam: 28, coursework: 24, status: 'ร่าง'),
    StudentRow(id: '650602003', name: 'น.ส.กันยา รัตนโชติ', midterm: 15, finalExam: 22, coursework: 20, status: 'ร่าง'),
    StudentRow(id: '650602004', name: 'นายธนภัทร ศรีสุวรรณ', midterm: 28, finalExam: 36, coursework: 29, status: 'ส่งแล้ว'),
    StudentRow(id: '650602005', name: 'น.ส.พิมชนก วงศ์สวัสดิ์', midterm: 25, finalExam: 31, coursework: 26, status: 'ส่งแล้ว'),
    StudentRow(id: '650602006', name: 'นายณัฐวุฒิ เจริญสุข', midterm: 20, finalExam: 26, coursework: 23, status: 'ร่าง'),
    StudentRow(id: '650602007', name: 'น.ส.ชลธิชา อภิรักษ์', midterm: 24, finalExam: 29, coursework: 25, status: 'ส่งแล้ว'),
    StudentRow(id: '650602008', name: 'นายศุภกร เกียรติคุณ', midterm: 19, finalExam: 24, coursework: 21, status: 'ร่าง'),
    StudentRow(id: '650602009', name: 'น.ส.ปภาวรินท์ เลิศสกุล', midterm: 29, finalExam: 37, coursework: 29, status: 'ส่งแล้ว'),
    StudentRow(id: '650602010', name: 'นายกิตติพัฒน์ ธนากุล', midterm: 14, finalExam: 19, coursework: 18, status: 'ร่าง'),
    StudentRow(id: '650602011', name: 'น.ส.ณัฐณิชา พงศ์ไพบูลย์', midterm: 23, finalExam: 29, coursework: 26, status: 'ส่งแล้ว'),
    StudentRow(id: '650602012', name: 'นายภัทรพล อัศวเมธี', midterm: 21, finalExam: 27, coursework: 24, status: 'ส่งแล้ว'),
  ];

  // ---------- News ----------
  static final List<NewsItem> newsList = [
    NewsItem(
      title: 'ทุนเรียนดีคณะวิศวฯ 5,000 บาท (20 ทุน)',
      subtitle: 'ทุน • ปิดรับ 30 ก.ย.',
      type: 'ทุน',
      detail: 'GPA ≥ 3.00 • แนบทรานสคริปต์ • สมัครออนไลน์ผ่านระบบกิจการนักศึกษา คณะวิศวกรรมศาสตร์ มทร.พระนคร',
      buttonLabel: 'ดูรายละเอียด',
    ),
    NewsItem(
      title: 'ฝึกงาน/สหกิจ Toyota Tsusho — รับสหกิจ IT 10 อัตรา',
      subtitle: 'ฝึกงาน/สหกิจ • สมัครด่วน',
      type: 'ฝึกงาน',
      detail: 'สัมภาษณ์ 5 ต.ค. ที่ศูนย์สหกิจ • รับนักศึกษาสาขาวิศวกรรมคอมพิวเตอร์และ IT มีเบี้ยเลี้ยงตลอดโครงการ',
      buttonLabel: 'ดูรายละเอียด',
    ),
    NewsItem(
      title: 'RMUTP Freshmen Day + ชมรมหุ่นยนต์',
      subtitle: 'กิจกรรม • 27 ก.ย.',
      type: 'กิจกรรม',
      detail: 'เปิดรายละเอียดกิจกรรมต้อนรับน้องใหม่และบูธแสดงผลงานชมรมหุ่นยนต์ คณะวิศวกรรมศาสตร์ รับชั่วโมงกิจกรรม 6 ชม.',
      buttonLabel: 'ดูรายละเอียด',
    ),
  ];

  // ---------- Notifications ----------
  static final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'HW6 ใกล้ครบกำหนด',
      subtitle: 'ENGCE302 — ส่งใน 2 วัน (23 ก.ย. 23:59)',
      accentColor: Colors.red,
    ),
    NotificationItem(
      title: 'ทุนคณะวิศวฯ ปิดรับ 30 ก.ย.',
      subtitle: 'คุณสมบัติผ่าน กดสมัครได้เลย',
      accentColor: const Color(0xFFF6DC04),
    ),
    NotificationItem(
      title: 'เลื่อนห้อง ENGCE305 → Lab 1502',
      subtitle: 'จาก อ.นภัส เมื่อ 1 ชม.ก่อน',
      accentColor: const Color(0xFF652D91),
    ),
  ];

  static final List<String> academicCalendar = [
    '23 ก.ย. — หมดเขตส่ง HW6',
    '30 ก.ย. — ปิดรับทุน / ถอนรายวิชา',
    '5 ต.ค. — สัมภาษณ์สหกิจ',
    '13–17 ต.ค. — สอบกลางภาค',
  ];

  // ---------- Requests (student & teacher) ----------
  static final List<RequestItem> requestsStudent = [
    RequestItem(
      id: '#RQ-1042',
      title: 'ขอใบรับรอง ENG',
      description: 'ขอใบรับรองการเป็นนักศึกษาฉบับภาษาอังกฤษ เพื่อใช้ยื่นสมัครทุนการศึกษา',
      category: 'document',
      studentId: '650602001',
      status: 'รอดำเนินการ',
      statusTeacher: 'รออนุมัติ',
      chipColor: Colors.amber,
      progress: 0.4,
    ),
    RequestItem(
      id: '#RQ-1039',
      title: 'แอร์ห้อง 1604 ไม่เย็น',
      description: 'เครื่องปรับอากาศริมหน้าต่างห้อง 1604 มีน้ำหยดระหว่างเรียน',
      category: 'repair',
      studentId: '650602001',
      status: 'ช่างรับเรื่อง',
      statusTeacher: 'ส่งต่อช่างแล้ว',
      chipColor: Colors.blue,
      progress: 0.7,
    ),
    RequestItem(
      id: '#RQ-1031',
      title: 'ขอ transcript',
      description: 'ขอใบแสดงผลการศึกษาตั้งแต่ชั้นปีที่ 1 ถึงปัจจุบัน',
      category: 'document',
      studentId: '650602001',
      status: 'เสร็จแล้ว • โหลด PDF',
      statusTeacher: 'เสร็จสิ้น',
      chipColor: Colors.green,
      progress: 1.0,
      resultPdfUrl: 'https://rmutp.ac.th/storage/v1/object/public/receipts/Transcript_650602001.pdf',
    ),
  ];

  static List<RequestItem> get requestsTeacher => requestsStudent;
}
