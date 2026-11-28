import 'package:flutter/material.dart';
import '../models/grade.dart';
import '../models/news_item.dart';
import '../models/notification_item.dart';
import '../models/request_item.dart';
import '../models/subject.dart';
import '../services/database_config.dart';
import '../services/database_service.dart';

class AppDatabaseProvider extends ChangeNotifier {
  bool isLoading = false;
  String? lastError;

  // ข้อมูลผู้ใช้งานที่เข้าสู่ระบบปัจจุบัน (เริ่มต้นเป็น null จนกว่าจะล็อกอินสำเร็จ)
  AuthenticatedUserSession? currentUser;

  StudentDeepProfile? studentProfile;
  List<FinancialReceiptRecord> financialRecords = [];

  List<Subject> studentTimetable = [];
  List<Subject> teacherTimetable = [];

  List<GradeItem> studentGrades = [];
  List<StudentRow> teacherGradeRows = [];

  bool isAttendanceRoomOpen = true;
  String? attachedHomeworkFile;
  bool isHomeworkSubmitted = false;

  // ข้อมูลเช็กชื่อจะถูกโหลดจากฐานข้อมูลเท่านั้น — ไม่เก็บข้อมูลตัวอย่างไว้ในแอป
  List<AttendanceRecordItem> attendanceRecords = [];

  List<RequestItem> allRequests = [];
  List<NewsItem> newsList = [];
  List<NotificationItem> notifications = [];
  List<String> academicCalendar = [];

  DatabaseBackendMode get backendMode => DatabaseConfig.currentMode;

  String get backendModeLabel {
    if (DatabaseConfig.currentMode == DatabaseBackendMode.universitySqlServer) {
      return 'University SQL Server (Express API)';
    }
    return DatabaseConfig.isSupabaseConfigured
        ? 'Supabase Cloud API (Online)'
        : 'Supabase Cloud Mode (Ready for .env Key)';
  }

  /// สลับโหมดฐานข้อมูลระหว่าง Supabase Cloud กับ University SQL Server
  Future<void> setBackendMode(DatabaseBackendMode mode) async {
    DatabaseConfig.currentMode = mode;
    notifyListeners();
    await refreshAllData();
  }

  /// อัปเดตการตั้งค่า URL / Key แบบ Runtime
  Future<void> updateConnectionConfig({
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? universityApiUrl,
  }) async {
    if (supabaseUrl != null) DatabaseConfig.customSupabaseUrl = supabaseUrl.trim();
    if (supabaseAnonKey != null) {
      DatabaseConfig.customSupabaseAnonKey = supabaseAnonKey.trim();
    }
    if (universityApiUrl != null) {
      DatabaseConfig.customUniversityApiUrl = universityApiUrl.trim();
    }
    notifyListeners();
    await refreshAllData();
  }

  // ---------------------------------------------------------------------------
  // เข้าสู่ระบบด้วยอีเมลและรหัสผ่านจริง
  // ---------------------------------------------------------------------------
  Future<AuthenticatedUserSession?> loginWithCredentials(
    String email,
    String password,
  ) async {
    isLoading = true;
    lastError = null;
    notifyListeners();

    final session = await DatabaseService.authenticateUser(email, password);
    if (session == null) {
      isLoading = false;
      lastError = 'อีเมลมหาวิทยาลัย หรือ รหัสผ่านไม่ถูกต้อง';
      notifyListeners();
      return null;
    }

    currentUser = session;
    await refreshAllData();
    isLoading = false;
    notifyListeners();
    return session;
  }

  /// ออกจากระบบ: ล้าง session และข้อมูลทั้งหมดที่โหลดไว้สำหรับผู้ใช้คนก่อน
  /// เพื่อไม่ให้ข้อมูลนักศึกษายังvisibleอยู่หลังกลับไปหน้า login
  void logout() {
    currentUser = null;
    studentProfile = null;
    financialRecords = [];
    studentTimetable = [];
    teacherTimetable = [];
    studentGrades = [];
    teacherGradeRows = [];
    attendanceRecords = [];
    allRequests = [];
    newsList = [];
    notifications = [];
    academicCalendar = [];
    isAttendanceRoomOpen = true;
    attachedHomeworkFile = null;
    isHomeworkSubmitted = false;
    lastError = null;
    isLoading = false;
    notifyListeners();
  }

  /// โหลดข้อมูลทั้งหมดจากฐานข้อมูลตามผู้ใช้งานปัจจุบัน
  Future<void> refreshAllData() async {
    final stuId = currentUser?.studentId ?? '';
    final tchId = currentUser?.teacherId ?? '';

    if (stuId.isEmpty && tchId.isEmpty) {
      lastError = 'ยังไม่ได้ล็อกอิน';
      return;
    }

    studentProfile = await DatabaseService.fetchStudentDeepProfile(stuId);
    financialRecords = await DatabaseService.fetchFinancialRecords(stuId);

    final remoteStudentTimetable =
        await DatabaseService.fetchStudentTimetable(stuId);
    if (remoteStudentTimetable.isNotEmpty) {
      studentTimetable = remoteStudentTimetable;
    }

    final remoteTeacherTimetable =
        await DatabaseService.fetchTeacherTimetable(tchId);
    if (remoteTeacherTimetable.isNotEmpty) {
      teacherTimetable = remoteTeacherTimetable;
    }

    final remoteGrades = await DatabaseService.fetchStudentGrades(stuId);
    if (remoteGrades.isNotEmpty) {
      studentGrades = remoteGrades;
    }

    final remoteGradeSheet =
        await DatabaseService.fetchTeacherGradeSheet('ENGCE302');
    if (remoteGradeSheet.isNotEmpty) {
      teacherGradeRows = remoteGradeSheet;
    }

    final remoteRequests = await DatabaseService.fetchServiceRequests();
    if (remoteRequests.isNotEmpty) {
      allRequests = remoteRequests;
    }

    final remoteNews = await DatabaseService.fetchNewsAnnouncements();
    if (remoteNews.isNotEmpty) {
      newsList = remoteNews;
    }

    notifyListeners();
  }

  /// กรองตารางเรียนตามวัน ('mon' -> 'MON', 'tue' -> 'TUE', ...)
  List<Subject> getTimetableForDay(bool isTeacher, String dayKey) {
    final code = dayKey.toUpperCase();
    final source = isTeacher ? teacherTimetable : studentTimetable;
    return source.where((s) => s.dayOfWeek.toUpperCase() == code).toList();
  }

  /// รายการคำร้องสำหรับนักศึกษาที่ล็อกอินอยู่
  List<RequestItem> get studentRequests {
    final stuId = currentUser?.studentId ?? '';
    final list = allRequests.where((r) => r.studentId == stuId).toList();
    return list.isNotEmpty ? list : allRequests;
  }

  /// จำนวนนักศึกษาที่ส่งเกรดแล้วในหน้าตัดเกรดของอาจารย์
  int get submittedGradeCount =>
      teacherGradeRows.where((r) => r.status == 'ส่งแล้ว').length;

  /// จำนวนนักศึกษาที่มาเรียนหรือมาสายในคาบเช็กชื่อ
  int get presentAttendanceCount =>
      attendanceRecords
          .where((r) => r.status == 'present' || r.status == 'late')
          .length;

  /// บันทึกร่างหรือส่งเกรดเข้าระบบทะเบียนจริง
  Future<void> saveOrSubmitGrades({
    required String subjectCode,
    required bool submitFinal,
  }) async {
    final tchId = currentUser?.teacherId;
    if (tchId == null) {
      lastError = 'เฉพาะอาจารย์ที่ล็อกอินเท่านั้นที่ส่งเกรดได้';
      notifyListeners();
      return;
    }
    if (submitFinal) {
      for (final row in teacherGradeRows) {
        row.status = 'ส่งแล้ว';
      }
    }
    notifyListeners();
    await DatabaseService.saveTeacherGrades(
      subjectCode,
      teacherGradeRows,
      submitFinal: submitFinal,
      teacherId: tchId,
    );
  }

  /// นักศึกษากดเช็กชื่อเข้าเรียน
  Future<String> checkInCurrentStudent() async {
    final stuId = currentUser?.studentId ?? '';
    if (stuId.isEmpty) {
      lastError = 'ยังไม่ได้ล็อกอิน';
      return '';
    }
    final now = TimeOfDay.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final rec in attendanceRecords) {
      if (rec.studentId == stuId) {
        rec.status = 'present';
        rec.checkInTime = formattedTime;
      }
    }
    notifyListeners();
    await DatabaseService.checkInAttendance(
      studentId: stuId,
      checkInTime: formattedTime,
    );
    return formattedTime;
  }

  /// อาจารย์เปิด/ปิดห้องเช็กชื่อ
  Future<void> toggleAttendanceRoom(bool open) async {
    isAttendanceRoomOpen = open;
    notifyListeners();
    await DatabaseService.toggleAttendanceSession(open);
  }

  /// อาจารย์กดส่งแจ้งเตือนไลน์หานักศึกษาที่ยังไม่มาเรียน
  void remindStudentViaLine(String studentId) {
    for (final rec in attendanceRecords) {
      if (rec.studentId == studentId) {
        rec.remindedViaLine = true;
      }
    }
    notifyListeners();
  }

  /// นักศึกษาแนบไฟล์และกดส่งการบ้าน
  void attachHomeworkFile(String fileName) {
    attachedHomeworkFile = fileName;
    notifyListeners();
  }

  Future<void> submitHomeworkFile() async {
    final stuId = currentUser?.studentId ?? '';
    if (stuId.isEmpty) {
      lastError = 'ยังไม่ได้ล็อกอิน';
      return;
    }
    final file = attachedHomeworkFile ?? '${stuId}_HW6_ER_3NF.pdf';
    attachedHomeworkFile = file;
    isHomeworkSubmitted = true;
    notifyListeners();
    await DatabaseService.submitAssignment(studentId: stuId, fileName: file);
  }

  /// นักศึกษาสร้างคำร้องใหม่
  Future<RequestItem> submitNewServiceRequest({
    required String category,
    required String title,
    required String description,
  }) async {
    final stuId = currentUser?.studentId ?? '';
    if (stuId.isEmpty) {
      lastError = 'ยังไม่ได้ล็อกอิน';
      throw Exception('ยังไม่ได้ล็อกอิน');
    }
    final created = await DatabaseService.createServiceRequest(
      studentId: stuId,
      category: category,
      title: title,
      description: description,
    );
    allRequests.insert(0, created);
    notifyListeners();
    return created;
  }

  /// อาจารย์กดอนุมัติหรือตีกลับคำร้อง
  Future<void> reviewServiceRequest({
    required String requestCode,
    required bool approved,
  }) async {
    for (final req in allRequests) {
      if (req.id == requestCode) {
        req.status = approved ? 'เสร็จแล้ว • โหลด PDF' : 'ตีกลับให้แก้ไขเอกสาร';
        req.statusTeacher = approved ? 'เสร็จสิ้น' : 'ตีกลับ';
        req.chipColor = approved ? Colors.green : Colors.red;
        req.progress = approved ? 1.0 : 0.2;
      }
    }
    notifyListeners();
    await DatabaseService.updateServiceRequestStatus(
      requestCode: requestCode,
      approved: approved,
    );
  }

  /// อาจารย์ลงประกาศข่าวสารใหม่
  Future<void> publishTeacherAnnouncement({
    required String title,
    required String type,
    required String detail,
  }) async {
    final tchId = currentUser?.teacherId ?? '';
    if (tchId.isEmpty) {
      lastError = 'ยังไม่ได้ล็อกอินในฐานะอาจารย์';
      return;
    }
    final created = await DatabaseService.createNewsAnnouncement(
      title: title,
      type: type,
      detail: detail,
      teacherId: tchId,
    );
    newsList.insert(0, created);
    notifyListeners();
  }
}
