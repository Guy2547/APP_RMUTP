// =============================================================================
// lib/services/database_config.dart
// การตั้งค่าการเชื่อมต่อฐานข้อมูล Supabase Cloud (RMUTP Campus App)
// ยึดมาตรฐานความปลอดภัยสากล: ดึงค่าผ่าน Environment Variables (.env)
// ไม่ฝัง API Key ลับไว้ในซอร์สโค้ดที่ส่งขึ้น Public GitHub Repository
// =============================================================================

class DatabaseConfig {
  /// URL ของ Supabase Cloud (ดึงจาก --dart-define-from-file=.env)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yrtufcdjrpzepqozwkqp.supabase.co',
  );

  /// URL สำหรับยิงตรงเข้า PostgREST API
  static const String restApiUrl = String.fromEnvironment(
    'SUPABASE_REST_URL',
    defaultValue: '$supabaseUrl/rest/v1',
  );

  /// Public Anon Key ดึงจากไฟล์ .env (ไม่แสดงคีย์ดิบใน Git เพื่อความปลอดภัยตามมาตรฐานสากล)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// ตรวจสอบว่ามีการตั้งค่า API Key พร้อมใช้งานแล้วหรือไม่
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Headers มาตรฐานสำหรับยิง HTTP Request เข้า Supabase REST API
  static Map<String, String> get defaultHeaders => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  // ---------------------------------------------------------------------------
  // รายชื่อตารางหลัก (Tables) ทั้ง 20 ตารางในฐานข้อมูล
  // ---------------------------------------------------------------------------
  static const String tableFaculties = 'faculties';
  static const String tableDepartments = 'departments';
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
  // รายชื่อ Views สำเร็จรูป (ดึงข้อมูลที่ JOIN ตารางแล้วไปแสดงบนหน้าจอได้ทันที)
  // ---------------------------------------------------------------------------
  static const String viewStudentProfiles = 'v_student_profiles';
  static const String viewStudentTimetable = 'v_student_timetable';
  static const String viewTeacherTimetable = 'v_teacher_timetable';
  static const String viewTeacherGradeSheet = 'v_teacher_grade_sheet';
  static const String viewStudentFinancialRecords = 'v_student_financial_records';
}
