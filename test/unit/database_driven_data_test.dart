import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rmutp_campus_app/models/attendance_summary.dart';
import 'package:rmutp_campus_app/models/exam_event.dart';
import 'package:rmutp_campus_app/models/grade.dart';
import 'package:rmutp_campus_app/models/notification_item.dart';
import 'package:rmutp_campus_app/providers/app_database_provider.dart';
import 'package:rmutp_campus_app/screens/exam_schedule_screen.dart';
import 'package:rmutp_campus_app/screens/grades_screen.dart';
import 'package:rmutp_campus_app/screens/profile_screen.dart';
import 'package:rmutp_campus_app/screens/timetable_screen.dart';
import 'package:rmutp_campus_app/screens/transcript_screen.dart';
import 'package:rmutp_campus_app/services/database_service.dart';

void main() {
  group('GradeItem จาก v_student_grades', () {
    test('เก็บ credits / termLabel / isCurrent ได้', () {
      final item = GradeItem(
        subjectCode: 'ENGCE302',
        subjectName: 'ระบบฐานข้อมูล',
        letter: 'A (4.0)',
        score: 4.0,
        credits: 3,
        termLabel: 'ภาคเรียนที่ 1/2569',
        isCurrent: true,
      );

      expect(item.credits, 3);
      expect(item.termLabel, 'ภาคเรียนที่ 1/2569');
      expect(item.isCurrent, isTrue);
    });

    test('ค่าเริ่มต้นยังใช้ได้กับโค้ดเดิม', () {
      final item = GradeItem(
        subjectCode: 'ENGCE301',
        subjectName: 'การเขียนโปรแกรม',
        letter: 'A',
        score: 4.0,
      );

      expect(item.credits, 3);
      expect(item.termLabel, '');
      expect(item.isCurrent, isFalse);
      expect(item.isWarning, isFalse);
    });
  });

  group('hoursFromTime', () {
    test('แปลงช่วงเวลาแบบ en-dash', () {
      expect(hoursFromTime('09:00–12:00'), 3);
      expect(hoursFromTime('13:00–15:00'), 2);
    });

    test('แปลงช่วงเวลาแบบ hyphen', () {
      expect(hoursFromTime('10:00-12:00'), 2);
    });

    test('รูปแบบผิดปกติคืนค่าเริ่มต้น 3', () {
      expect(hoursFromTime(''), 3);
      expect(hoursFromTime('09:00'), 3);
    });
  });

  group('AttendanceCourseSummary', () {
    test('คำนวณ total / attended / percent', () {
      const item = AttendanceCourseSummary(
        subjectCode: 'ENGCE302',
        subjectName: 'ระบบฐานข้อมูล',
        present: 12,
        late: 2,
        absent: 1,
      );

      expect(item.total, 15);
      expect(item.attended, 14);
      expect(item.percent, 93);
    });

    test('ไม่มีข้อมูลต้องไม่หารด้วยศูนย์', () {
      const item = AttendanceCourseSummary(
        subjectCode: 'X',
        subjectName: '-',
        present: 0,
        late: 0,
        absent: 0,
      );

      expect(item.percent, 0);
    });
  });

  group('AppDatabaseProvider — ข้อมูลหน้าจอที่ดึงจาก DB', () {
    test('เริ่มต้นต้องไม่มี notification / ประวัติเช็กชื่อ', () {
      final db = AppDatabaseProvider();
      expect(db.notifications, isEmpty);
      expect(db.attendanceHistory, isEmpty);
    });

    test('markAllNotificationsRead อัปเดตสถานะโดยไม่ต้องยิง network', () async {
      final db = AppDatabaseProvider();
      db.notifications = [
        NotificationItem(
          title: 'ประกาศทุน',
          subtitle: 'รายละเอียด',
          accentColor: Colors.purple,
          isRead: false,
        ),
        NotificationItem(
          title: 'แจ้งเตือนทั่วไป',
          subtitle: 'รายละเอียด',
          accentColor: Colors.purple,
          isRead: true,
        ),
      ];

      await db.markAllNotificationsRead();

      expect(db.notifications.every((n) => n.isRead), isTrue);
    });

    test('logout ล้าง notification และประวัติเช็กชื่อด้วย', () {
      final db = AppDatabaseProvider();
      db.notifications = [
        NotificationItem(
          title: 'ประกาศ',
          subtitle: '-',
          accentColor: Colors.purple,
        ),
      ];
      db.attendanceHistory = const [
        AttendanceCourseSummary(
          subjectCode: 'X',
          subjectName: '-',
          present: 1,
          late: 0,
          absent: 0,
        ),
      ];
      db.examEvents = const [
        ExamEvent(
          title: 'สอบกลางภาค',
          dateDisplay: '13–17 ต.ค.',
          startDate: '2026-10-13',
        ),
      ];
      db.currentUser = AuthenticatedUserSession(
        email: 's650602001@rmutp.ac.th',
        role: 'student',
        studentId: '650602001',
        displayName: 'นักศึกษา',
        subtitleInfo: '-',
      );

      db.logout();

      expect(db.notifications, isEmpty);
      expect(db.attendanceHistory, isEmpty);
      expect(db.examEvents, isEmpty);
      expect(db.currentUser, isNull);
    });
  });

  group('กำหนดการสอบจาก academic_calendar_events', () {
    const events = [
      ExamEvent(
        title: 'สอบกลางภาค',
        dateDisplay: '13–17 ต.ค.',
        startDate: '2026-10-13',
        description: 'สัปดาห์สอบกลางภาค',
      ),
      ExamEvent(
        title: 'สอบปลายภาค',
        dateDisplay: '14–18 ธ.ค.',
        startDate: '2026-12-14',
      ),
    ];

    test('แยกสอบกลางภาค / ปลายภาคจากชื่อ event', () {
      expect(events.first.isFinal, isFalse);
      expect(events.last.isFinal, isTrue);

      final midterm = buildExamItems(events, false);
      final finalExams = buildExamItems(events, true);

      expect(midterm, hasLength(1));
      expect(midterm.first.title, 'สอบกลางภาค');
      expect(midterm.first.date, '13–17 ต.ค.');
      expect(midterm.first.detail, 'สัปดาห์สอบกลางภาค');
      expect(finalExams, hasLength(1));
      expect(finalExams.first.title, 'สอบปลายภาค');
    });

    test('ไม่มี event คืนรายการว่าง', () {
      expect(buildExamItems([], false), isEmpty);
      expect(buildExamItems([], true), isEmpty);
    });
  });

  group('จัดกลุ่มผลการเรียนจาก v_student_grades', () {
    final grades = [
      GradeItem(
        subjectCode: 'ENGCE301',
        subjectName: 'การเขียนโปรแกรม',
        letter: 'A (4.0)',
        score: 4.0,
        credits: 3,
        termLabel: 'ภาคเรียนที่ 1/2569',
      ),
      GradeItem(
        subjectCode: 'ENGCE302',
        subjectName: 'ระบบฐานข้อมูล',
        letter: 'B+ (3.5)',
        score: 3.5,
        credits: 3,
        termLabel: 'ภาคเรียนที่ 1/2569',
      ),
      GradeItem(
        subjectCode: 'ENGCE303',
        subjectName: 'เครือข่าย',
        letter: 'A (4.0)',
        score: 4.0,
        credits: 3,
        termLabel: 'ภาคเรียนที่ 2/2568',
      ),
    ];

    test('buildSemesters จัดกลุ่มตาม term_label และคำนวณ GPA แบบถ่วงน้ำหนัก', () {
      final semesters = buildSemesters(grades);

      expect(semesters, hasLength(2));
      expect(semesters.first.label, 'ภาคเรียนที่ 1/2569');
      expect(semesters.first.courses, hasLength(2));
      expect(semesters.first.gpa, '3.75');
      expect(semesters.last.label, 'ภาคเรียนที่ 2/2568');
      expect(semesters.last.gpa, '4.00');
    });

    test('ไม่มีผลการเรียนคืนรายการว่าง', () {
      expect(buildSemesters([]), isEmpty);
      expect(buildTranscriptSemesters([]), isEmpty);
    });

    test('buildTranscriptSemesters รวมหน่วยกิตต่อภาคเรียน', () {
      final semesters = buildTranscriptSemesters(grades);

      expect(semesters, hasLength(2));
      expect(semesters.first.title, 'ภาคเรียนที่ 1/2569');
      expect(semesters.first.totalCredits, 6);
      expect(semesters.first.gpa, '3.75');
      expect(semesters.first.courses.first.code, 'ENGCE301');
    });
  });

  group('ข้อมูลบัตรนักศึกษาจาก DB', () {
    StudentDeepProfile makeProfile({
      String studentId = '650602001',
      String fullNameTh = 'มินตรา ใจดี',
      String facultyNameTh = 'คณะวิศวกรรมศาสตร์',
      String departmentNameTh = 'วิศวกรรมคอมพิวเตอร์',
    }) {
      return StudentDeepProfile(
        studentId: studentId,
        fullNameTh: fullNameTh,
        fullNameEn: 'Mintra Jaidee',
        universityEmail: 's650602001@rmutp.ac.th',
        citizenId: '1-xxxx-xxxxx-xx-x',
        birthDate: '14 พ.ค. 2547',
        bloodGroup: 'O',
        facultyNameTh: facultyNameTh,
        campus: 'กรุงเทพมหานคร',
        departmentNameTh: departmentNameTh,
        degreeNameTh: 'วศ.บ.',
        yearLevel: 2,
        gpax: 3.42,
        currentTermGpa: 3.55,
        creditsProgressLabel: '87/132',
        advisorName: 'อ.ดร. ธนกร วัฒนกุล',
        phone: '092-345-6789',
        lineId: 'mintra_ce65',
        currentAddress: '-',
        permanentAddress: '-',
        emergencyContactName: 'นางสมศรี ใจดี',
        emergencyContactRelation: 'มารดา',
        emergencyContactPhone: '081-999-8877',
      );
    }

    test('ชื่อ/รหัสมาจาก session ที่ล็อกอิน คณะ-สาขมาจาก deep profile', () {
      final db = AppDatabaseProvider();
      db.currentUser = AuthenticatedUserSession(
        email: 's650602001@rmutp.ac.th',
        role: 'student',
        studentId: '650602001',
        displayName: 'มินตรา',
        subtitleInfo: 'วศ.บ. วิศวกรรมคอมพิวเตอร์',
      );
      db.studentProfile = makeProfile();

      final info = buildStudentCardInfo(db);

      expect(info.displayName, 'มินตรา');
      expect(info.studentId, '650602001');
      expect(info.faculty, 'คณะวิศวกรรมศาสตร์');
      expect(info.major, 'วิศวกรรมคอมพิวเตอร์');
      expect(info.displayName, isNot('Theerachut'));
      expect(info.studentId, isNot('65012345678-9'));
    });

    test('ไม่มี session ให้ fallback เป็นชื่อ/รหัสจาก deep profile', () {
      final db = AppDatabaseProvider()
        ..studentProfile = makeProfile(studentId: '650602002', fullNameTh: 'ภูริ พัฒนากุล');

      final info = buildStudentCardInfo(db);

      expect(info.displayName, 'ภูริ พัฒนากุล');
      expect(info.studentId, '650602002');
    });

    test('ไม่มีข้อมูลเลยต้องแสดง - ไม่ใช่ค่าที่ฝังไว้', () {
      final info = buildStudentCardInfo(AppDatabaseProvider());

      expect(info.displayName, '-');
      expect(info.studentId, '-');
      expect(info.faculty, '-');
      expect(info.major, '-');
    });

    testWidgets('หน้าบัตรนักศึกษาแสดงชื่อ/รหัสจาก provider', (tester) async {
      final db = AppDatabaseProvider();
      db.currentUser = AuthenticatedUserSession(
        email: 's650602001@rmutp.ac.th',
        role: 'student',
        studentId: '650602001',
        displayName: 'มินตรา',
        subtitleInfo: 'วศ.บ. วิศวกรรมคอมพิวเตอร์',
      );
      db.studentProfile = makeProfile();

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider<AppDatabaseProvider>.value(value: db)],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      expect(find.text('มินตรา'), findsOneWidget);
      expect(find.text('650602001'), findsNWidgets(2));
      expect(find.text('Theerachut'), findsNothing);
      expect(find.text('65012345678-9'), findsNothing);
    });
  });
}
