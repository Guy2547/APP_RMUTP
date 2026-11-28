import 'package:flutter_test/flutter_test.dart';
import 'package:rmutp_campus_app/models/grade.dart';
import 'package:rmutp_campus_app/providers/app_database_provider.dart';
import 'package:rmutp_campus_app/services/database_service.dart';

AuthenticatedUserSession _studentSession() => AuthenticatedUserSession(
      email: 's650602001@rmutp.ac.th',
      role: 'student',
      studentId: '650602001',
      displayName: 'น.ส.มินตรา ใจดี',
      subtitleInfo: '650602001 • วิศวกรรมคอมพิวเตอร์ ปี 2',
    );

void main() {
  group('AppDatabaseProvider — สถานะก่อนล็อกอิน', () {
    test('เริ่มต้นต้องไม่มี session และไม่มีข้อมูลจากฐานข้อมูล', () {
      final db = AppDatabaseProvider();

      expect(db.currentUser, isNull);
      expect(db.lastError, isNull);
      expect(db.isLoading, isFalse);
      expect(db.studentProfile, isNull);
      expect(db.financialRecords, isEmpty);
      expect(db.studentTimetable, isEmpty);
      expect(db.teacherTimetable, isEmpty);
      expect(db.studentGrades, isEmpty);
      expect(db.teacherGradeRows, isEmpty);
      expect(db.attendanceRecords, isEmpty);
      expect(db.allRequests, isEmpty);
      expect(db.newsList, isEmpty);
      expect(db.notifications, isEmpty);
      expect(db.academicCalendar, isEmpty);
    });

    test('refreshAllData โดยยังไม่ล็อกอินต้องไม่ยิง network และแจ้ง error', () async {
      final db = AppDatabaseProvider();

      await db.refreshAllData();

      expect(db.lastError, 'ยังไม่ได้ล็อกอิน');
      expect(db.currentUser, isNull);
      expect(db.studentGrades, isEmpty);
      expect(db.newsList, isEmpty);
    });
  });

  group('AppDatabaseProvider — หลังมี session', () {
    test('currentUser ที่ตั้งไว้ต้องถูกใช้โดยตัวคำนวณที่เกี่ยวข้อง', () {
      final db = AppDatabaseProvider();
      db.currentUser = _studentSession();

      expect(db.currentUser, isNotNull);
      expect(db.currentUser!.studentId, '650602001');
      expect(db.currentUser!.isTeacher, isFalse);

      db.teacherGradeRows = [
        StudentRow(
          id: '650602001',
          name: 'น.ส.มินตรา ใจดี',
          midterm: 25,
          finalExam: 35,
          coursework: 25,
          status: 'ส่งแล้ว',
        ),
        StudentRow(
          id: '650602002',
          name: 'นายภูริ พัฒนากุล',
          midterm: 20,
          finalExam: 30,
          coursework: 20,
        ),
      ];

      expect(db.submittedGradeCount, 1);
    });

    test('logout ต้องล้าง session และข้อมูลทั้งหมด', () async {
      final db = AppDatabaseProvider();
      var notified = 0;
      db.addListener(() => notified++);

      db.currentUser = _studentSession();
      db.teacherGradeRows.add(
        StudentRow(
          id: '650602001',
          name: 'น.ส.มินตรา ใจดี',
          midterm: 25,
          finalExam: 35,
          coursework: 25,
          status: 'ส่งแล้ว',
        ),
      );
      db.attachedHomeworkFile = 'HW.pdf';
      db.isHomeworkSubmitted = true;

      db.logout();

      expect(db.currentUser, isNull);
      expect(db.lastError, isNull);
      expect(db.isLoading, isFalse);
      expect(db.teacherGradeRows, isEmpty);
      expect(db.attendanceRecords, isEmpty);
      expect(db.attachedHomeworkFile, isNull);
      expect(db.isHomeworkSubmitted, isFalse);
      expect(notified, greaterThan(0));

      // หลังออกจากระบบต้องกลับเข้าสู่สถานะ "ยังไม่ล็อกอิน" เหมือนตอนเริ่มต้น
      await db.refreshAllData();
      expect(db.lastError, 'ยังไม่ได้ล็อกอิน');
    });
  });
}
