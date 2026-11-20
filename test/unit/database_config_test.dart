import 'package:flutter_test/flutter_test.dart';
import 'package:rmutp_campus_app/services/database_config.dart';

void main() {
  group('DatabaseConfig table names (20 ตาราง)', () {
    test('คงที่ชื่อตารางทุกตัวถูกต้อง', () {
      expect(DatabaseConfig.tableFaculties, 'faculties');
      expect(DatabaseConfig.tableDepartments, 'departments');
      expect(DatabaseConfig.tableAcademicTerms, 'academic_terms');
      expect(DatabaseConfig.tableCalendarEvents, 'academic_calendar_events');
      expect(DatabaseConfig.tableUsers, 'users');
      expect(DatabaseConfig.tableTeachers, 'teachers');
      expect(DatabaseConfig.tableStudents, 'students');
      expect(DatabaseConfig.tableSubjects, 'subjects');
      expect(DatabaseConfig.tableCourseSections, 'course_sections');
      expect(DatabaseConfig.tableEnrollments, 'enrollments');
      expect(DatabaseConfig.tableCourseMaterials, 'course_materials');
      expect(DatabaseConfig.tableAssignments, 'assignments');
      expect(DatabaseConfig.tableAssignmentSubmissions, 'assignment_submissions');
      expect(DatabaseConfig.tableAttendanceSessions, 'attendance_sessions');
      expect(DatabaseConfig.tableAttendanceRecords, 'attendance_records');
      expect(DatabaseConfig.tableTuitionInvoices, 'tuition_invoices');
      expect(DatabaseConfig.tablePaymentReceipts, 'payment_receipts');
      expect(DatabaseConfig.tableServiceRequests, 'service_requests');
      expect(DatabaseConfig.tableNewsAnnouncements, 'news_announcements');
      expect(DatabaseConfig.tableNotifications, 'notifications');
    });
  });

  group('DatabaseConfig view names (5 Views)', () {
    test('คงที่ชื่อ View ทุกตัวถูกต้อง', () {
      expect(DatabaseConfig.viewStudentProfiles, 'v_student_profiles');
      expect(DatabaseConfig.viewStudentTimetable, 'v_student_timetable');
      expect(DatabaseConfig.viewTeacherTimetable, 'v_teacher_timetable');
      expect(DatabaseConfig.viewTeacherGradeSheet, 'v_teacher_grade_sheet');
      expect(DatabaseConfig.viewStudentFinancialRecords,
          'v_student_financial_records');
    });
  });

  group('DatabaseConfig configuration', () {
    test('isConfigured เป็น false เมื่อยังไม่มี SUPABASE_ANON_KEY', () {
      expect(DatabaseConfig.isConfigured, isFalse);
    });

    test('defaultHeaders มี header ที่จำเป็นครบถ้วน', () {
      final headers = DatabaseConfig.defaultHeaders;
      expect(headers.containsKey('apikey'), isTrue);
      expect(headers.containsKey('Authorization'), isTrue);
      expect(headers.containsKey('Content-Type'), isTrue);
      expect(headers.containsKey('Prefer'), isTrue);
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Prefer'], 'return=representation');
    });

    test('restApiUrl สร้างจาก supabaseUrl ต่อท้าย /rest/v1', () {
      expect(DatabaseConfig.restApiUrl,
          '${DatabaseConfig.supabaseUrl}/rest/v1');
    });
  });
}
