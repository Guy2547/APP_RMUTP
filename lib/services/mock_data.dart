import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../models/news_item.dart';
import '../models/notification_item.dart';
import '../models/request_item.dart';

class MockData {
  // ---------- Timetable (student) ----------
  static final List<Subject> timetableStudent = [
    Subject(
      code: 'ENGCE302',
      name: 'ระบบฐานข้อมูล',
      section: ' (Sec.1)',
      time: '09:00–12:00',
      room: 'ห้อง 1604',
      teacher: 'อ.สุรชัย',
      status: 'เช็คชื่อแล้ว',
      progress: 70,
      pendingAssignments: 1,
    ),
    Subject(
      code: 'ENGCE305',
      name: 'เครือข่ายคอมพิวเตอร์',
      section: '',
      time: '13:00–16:00',
      room: 'Lab 1502',
      teacher: 'ผศ.นภัส',
      status: 'เริ่มบ่ายนี้',
      progress: 45,
      pendingAssignments: 1,
    ),
    Subject(
      code: 'GEN101',
      name: 'ภาษาอังกฤษเพื่ออาชีพ',
      section: '',
      time: '16:30–18:00',
      room: 'ออนไลน์ MS Teams',
      teacher: '-',
      status: '-',
      progress: 0,
      pendingAssignments: 0,
    ),
  ];

  static final List<Subject> timetableTeacher = [
    Subject(
      code: 'ENGCE302',
      name: 'สอน ระบบฐานข้อมูล',
      section: ' Sec.1',
      time: '09:00–12:00',
      room: 'ห้อง 1604',
      teacher: '40 คน',
      status: '+ เปิดเช็คชื่อ',
      progress: 70,
    ),
    Subject(
      code: 'ENGCE305',
      name: 'สอน เครือข่ายคอมพิวเตอร์',
      section: ' Sec.2',
      time: '13:00–16:00',
      room: 'Lab 1502',
      teacher: '38 คน',
      status: '+ เปิดเช็คชื่อ',
      progress: 10,
    ),
  ];

  // ---------- Courses (student) ----------
  static final List<Subject> coursesStudent = [
    Subject(
      code: 'ENGCE302',
      name: 'ระบบฐานข้อมูล',
      section: '',
      time: '',
      room: '',
      teacher: 'อ.สุรชัย',
      status: 'งานค้าง 1 • คะแนนเก็บ 28/40',
      progress: 70,
      pendingAssignments: 1,
    ),
    Subject(
      code: 'ENGCE305',
      name: 'เครือข่ายคอมพิวเตอร์',
      section: '',
      time: '',
      room: '',
      teacher: 'ผศ.นภัส',
      status: 'งานค้าง 1 • Lab สัปดาห์ 6',
      progress: 45,
      pendingAssignments: 1,
    ),
    Subject(
      code: 'GEN101',
      name: 'ภาษาอังกฤษเพื่ออาชีพ',
      section: '',
      time: '',
      room: '',
      teacher: '-',
      status: 'ไม่มีงานค้าง • เรียนออนไลน์',
      progress: 0,
      pendingAssignments: 0,
    ),
  ];

  static final List<Subject> coursesTeacher = [
    Subject(
      code: 'ENGCE302',
      name: 'ระบบฐานข้อมูล',
      section: ' Sec.1',
      time: '',
      room: '',
      teacher: '',
      status: 'ส่งแล้ว 28/40 • รอตรวจ 8 • รอส่งเกรด',
      progress: 70,
    ),
    Subject(
      code: 'ENGCE305',
      name: 'เครือข่ายคอมพิวเตอร์',
      section: ' Sec.2',
      time: '',
      room: '',
      teacher: '',
      status: 'ยังไม่เริ่มส่งเกรด • 38 คน',
      progress: 10,
    ),
  ];

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
      subjectName: 'อังกฤษเพื่ออาชีพ',
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

  // ---------- Grade submit (teacher) ----------
  static final List<StudentRow> gradeSubmitRows = [
    StudentRow(id: '650602001', name: 'มินตรา', midterm: 26, finalExam: 33, coursework: 27, status: 'ส่งแล้ว'),
    StudentRow(id: '650602002', name: 'ภูริ', midterm: 22, finalExam: 28, coursework: 24, status: 'ร่าง'),
    StudentRow(id: '650602003', name: 'กันยา', midterm: 15, finalExam: 22, coursework: 20, status: 'ร่าง'),
  ];

  // ---------- News ----------
  static final List<NewsItem> newsList = [
    NewsItem(
      title: 'ทุนเรียนดีคณะวิศวฯ 5,000 บาท (20 ทุน)',
      subtitle: 'ทุน • ปิดรับ 30 ก.ย.',
      type: 'ทุน',
      detail: 'GPA ≥ 3.00 • แนบทรานสคริปต์ • สมัครออนไลน์',
      buttonLabel: 'ดูรายละเอียด',
    ),
    NewsItem(
      title: 'ฝึกงาน/สหกิจ Toyota Tsusho — รับสหกิจ IT 10 อัตรา',
      subtitle: 'ฝึกงาน/สหกิจ • สมัครด่วน',
      type: 'ฝึกงาน',
      detail: 'สัมภาษณ์ 5 ต.ค. ที่ศูนย์สหกิจ',
      buttonLabel: 'ดูรายละเอียด',
    ),
    NewsItem(
      title: 'RMUTP Freshmen Day + ชมรมหุ่นยนต์',
      subtitle: 'กิจกรรม • 27 ก.ย.',
      type: 'กิจกรรม',
      detail: 'เปิดรายละเอียดกิจกรรม',
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
      accentColor: Color(0xFFF6DC04),
    ),
    NotificationItem(
      title: 'เลื่อนห้อง ENGCE305 → Lab 1502',
      subtitle: 'จาก อ.นภัส เมื่อ 1 ชม.ก่อน',
      accentColor: Color(0xFF652D91),
    ),
  ];

  static final List<String> academicCalendar = [
    '23 ก.ย. — หมดเขตส่ง HW6',
    '30 ก.ย. — ปิดรับทุน / ถอนรายวิชา',
    '5 ต.ค. — สัมภาษณ์สหกิจ',
    '13–17 ต.ค. — สอบกลางภาค',
  ];

  // ---------- Requests (student) ----------
  static final List<RequestItem> requestsStudent = [
    RequestItem(
      id: '#RQ-1042',
      title: 'ขอใบรับรอง ENG',
      status: 'รอดำเนินการ',
      chipColor: Colors.amber,
      progress: 0.4,
    ),
    RequestItem(
      id: '#RQ-1039',
      title: 'แอร์ห้อง 1604 ไม่เย็น',
      status: 'ช่างรับเรื่อง',
      chipColor: Colors.blue,
      progress: 0.7,
    ),
    RequestItem(
      id: '#RQ-1031',
      title: 'ขอ transcript',
      status: 'เสร็จแล้ว • โหลด PDF',
      chipColor: Colors.green,
      progress: 1.0,
    ),
  ];

  static final List<RequestItem> requestsTeacher = [
    RequestItem(
      id: '#RQ-1042',
      title: 'ขอใบรับรอง ENG',
      status: 'รออนุมัติ',
      chipColor: Colors.amber,
      progress: 0.4,
    ),
    RequestItem(
      id: '#RQ-1039',
      title: 'แอร์ห้อง 1604 ไม่เย็น',
      status: 'ส่งต่อช่างแล้ว',
      chipColor: Colors.blue,
      progress: 0.7,
    ),
  ];
}
