// =============================================================================
// lib/services/database_config.dart
// การตั้งค่าการเชื่อมต่อฐานข้อมูล 2 ระบบควบคู่กัน (Dual-Database Architecture):
//   1. ระบบที่ 1: Supabase Cloud API (PostgREST / RPC)
//   2. ระบบที่ 2: Standard University SQL Server (ผ่าน Node.js/Express Middleware)
// =============================================================================

enum DatabaseBackendMode {
  supabaseCloud,
  universitySqlServer,
}

class DatabaseConfig {
  /// โหมดเริ่มต้นจาก Environment Variable (DB_BACKEND_MODE)
  static const String _envMode = String.fromEnvironment(
    'DB_BACKEND_MODE',
    defaultValue: 'supabase',
  );

  /// URL ของ Supabase Cloud (ดึงจาก --dart-define-from-file=.env)
  static const String envSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Public Anon Key ของ Supabase Cloud (ดึงจาก --dart-define-from-file=.env)
  static const String envSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// URL ของ Node.js + Express REST API Middleware สำหรับเซิร์ฟเวอร์ SQL ของมหาวิทยาลัย
  static const String envUniversityApiUrl = String.fromEnvironment(
    'UNIVERSITY_API_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  // Runtime mutable state (รองรับการสลับโหมดสดๆ ในหน้า Login / Profile)
  static DatabaseBackendMode currentMode =
      _envMode == 'university_sql'
          ? DatabaseBackendMode.universitySqlServer
          : DatabaseBackendMode.supabaseCloud;

  static String customSupabaseUrl = envSupabaseUrl;
  static String customSupabaseAnonKey = envSupabaseAnonKey;
  static String customUniversityApiUrl = envUniversityApiUrl;

  /// ตรวจสอบว่า Supabase Cloud มีการใส่ URL และ Key แล้วหรือยัง
  static bool get isSupabaseConfigured =>
      customSupabaseUrl.trim().isNotEmpty &&
      customSupabaseAnonKey.trim().isNotEmpty;

  /// Base URL ปัจจุบันตามโหมดที่เลือก (ตัด /rest/v1 ซ้ำซ้อนให้อัตโนมัติหากมีการใส่มาเกิน)
  static String get activeRestBaseUrl {
    if (currentMode == DatabaseBackendMode.universitySqlServer) {
      return customUniversityApiUrl.trim().replaceAll(RegExp(r'/$'), '');
    }
    var cleanUrl = customSupabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    cleanUrl = cleanUrl.replaceAll(RegExp(r'/rest/v1$'), '');
    return '$cleanUrl/rest/v1';
  }

  /// Headers มาตรฐานสำหรับการเรียก API
  static Map<String, String> get defaultHeaders {
    if (currentMode == DatabaseBackendMode.universitySqlServer) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return {
      'apikey': customSupabaseAnonKey,
      'Authorization': 'Bearer $customSupabaseAnonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
  }

  // ---------------------------------------------------------------------------
  // รายชื่อตารางหลัก (Tables) ทั้ง 22 ตารางในฐานข้อมูล
  // ---------------------------------------------------------------------------
  static const String tableFaculties = 'faculties';
  static const String tableDepartments = 'departments';
  static const String tableCurriculums = 'curriculums';
  static const String tableBuildingsRooms = 'buildings_rooms';
  static const String tableAcademicTerms = 'academic_terms';
  static const String tableCalendarEvents = 'academic_calendar_events';
  static const String tableUsers = 'users';
  static const String tableTeachers = 'teachers';
  static const String tableStudents = 'students';
  static const String tableSubjects = 'subjects';
  static const String tableCourseSections = 'course_sections';
  static const String tableEnrollments = 'enrollments';
  static const String tableCourseMaterials = 'course_materials';
  static const String tableAssignments = 'assignments';
  static const String tableAssignmentSubmissions = 'assignment_submissions';
  static const String tableAttendanceSessions = 'attendance_sessions';
  static const String tableAttendanceRecords = 'attendance_records';
  static const String tableTuitionInvoices = 'tuition_invoices';
  static const String tablePaymentReceipts = 'payment_receipts';
  static const String tableServiceRequests = 'service_requests';
  static const String tableNewsAnnouncements = 'news_announcements';
  static const String tableNotifications = 'notifications';

  // ---------------------------------------------------------------------------
  // รายชื่อ Views สำเร็จรูปทั้ง 6 Views
  // ---------------------------------------------------------------------------
  static const String viewStudentProfiles = 'v_student_profiles';
  static const String viewStudentTimetable = 'v_student_timetable';
  static const String viewTeacherTimetable = 'v_teacher_timetable';
  static const String viewTeacherGradeSheet = 'v_teacher_grade_sheet';
  static const String viewStudentGrades = 'v_student_grades';
  static const String viewStudentFinancialRecords = 'v_student_financial_records';
}
