import 'package:flutter/material.dart';
import '../models/grade.dart';
import '../models/news_item.dart';
import '../models/notification_item.dart';
import '../models/request_item.dart';
import '../models/subject.dart';
import '../services/database_config.dart';
import '../services/database_service.dart';
import '../services/mock_data.dart';

class AppDatabaseProvider extends ChangeNotifier {
  bool isLoading = false;
  String? lastError;

  // ข้อมูลผู้ใช้งานที่เข้าสู่ระบบปัจจุบัน (ค่าเริ่มต้นสำหรับการเปิดหน้าจอโดยตรงในการทดสอบ)
  AuthenticatedUserSession currentUser = AuthenticatedUserSession(
    email: 's650602001@rmutp.ac.th',
    role: 'student',
    studentId: '650602001',
    displayName: 'น.ส.มินตรา ใจดี',
    subtitleInfo: '650602001 • วิศวกรรมคอมพิวเตอร์ ปี 2',
    gpax: 3.42,
    currentTermGpa: 3.55,
    earnedCredits: 87,
    totalCreditsRequired: 132,
  );

  StudentDeepProfile? studentProfile;
  List<FinancialReceiptRecord> financialRecords = [];

  List<Subject> studentTimetable = List<Subject>.from(MockData.timetableStudent);
  List<Subject> teacherTimetable = List<Subject>.from(MockData.timetableTeacher);

  List<GradeItem> studentGrades = List<GradeItem>.from(MockData.gradesStudent);
  List<StudentRow> teacherGradeRows = List<StudentRow>.from(
    MockData.gradeSubmitRows.map(
      (r) => StudentRow(
        id: r.id,
        name: r.name,
        midterm: r.midterm,
        finalExam: r.finalExam,
        coursework: r.coursework,
        status: r.status,
      ),
    ),
  );

  bool isAttendanceRoomOpen = true;
  String? attachedHomeworkFile;
  bool isHomeworkSubmitted = false;

  List<AttendanceRecordItem> attendanceRecords = [
    AttendanceRecordItem(studentId: '650602001', studentName: 'น.ส.มินตรา ใจดี', status: 'present', checkInTime: '09:03'),
    AttendanceRecordItem(studentId: '650602002', studentName: 'นายภูริ พัฒนากุล', status: 'present', checkInTime: '09:04'),
    AttendanceRecordItem(studentId: '650602003', studentName: 'น.ส.กันยา รัตนโชติ', status: 'absent'),
    AttendanceRecordItem(studentId: '650602004', studentName: 'นายธนภัทร ศรีสุวรรณ', status: 'present', checkInTime: '09:01'),
    AttendanceRecordItem(studentId: '650602005', studentName: 'น.ส.พิมชนก วงศ์สวัสดิ์', status: 'present', checkInTime: '09:02'),
    AttendanceRecordItem(studentId: '650602006', studentName: 'นายณัฐวุฒิ เจริญสุข', status: 'late', checkInTime: '09:18'),
    AttendanceRecordItem(studentId: '650602007', studentName: 'น.ส.ชลธิชา อภิรักษ์', status: 'present', checkInTime: '09:05'),
    AttendanceRecordItem(studentId: '650602008', studentName: 'นายศุภกร เกียรติคุณ', status: 'absent'),
    AttendanceRecordItem(studentId: '650602009', studentName: 'น.ส.ปภาวรินท์ เลิศสกุล', status: 'present', checkInTime: '09:00'),
    AttendanceRecordItem(studentId: '650602010', studentName: 'นายกิตติพัฒน์ ธนากุล', status: 'absent'),
    AttendanceRecordItem(studentId: '650602011', studentName: 'น.ส.ณัฐณิชา พงศ์ไพบูลย์', status: 'present', checkInTime: '09:06'),
    AttendanceRecordItem(studentId: '650602012', studentName: 'นายภัทรพล อัศวเมธี', status: 'present', checkInTime: '09:07'),
  ];

  List<RequestItem> allRequests = List<RequestItem>.from(MockData.requestsStudent);
  List<NewsItem> newsList = List<NewsItem>.from(MockData.newsList);
  List<NotificationItem> notifications = List<NotificationItem>.from(MockData.notifications);
  List<String> academicCalendar = List<String>.from(MockData.academicCalendar);

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

  /// โหลดข้อมูลทั้งหมดจากฐานข้อมูลตามผู้ใช้งานปัจจุบัน
  Future<void> refreshAllData() async {
    final stuId = currentUser.studentId ?? '650602001';
    final tchId = currentUser.teacherId ?? 'T-1024';

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
    final stuId = currentUser.studentId ?? '650602001';
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
      teacherId: currentUser.teacherId ?? 'T-1024',
    );
  }

  /// นักศึกษากดเช็กชื่อเข้าเรียน
  Future<String> checkInCurrentStudent() async {
    final stuId = currentUser.studentId ?? '650602001';
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
    final stuId = currentUser.studentId ?? '650602001';
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
    final stuId = currentUser.studentId ?? '650602001';
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
    final tchId = currentUser.teacherId ?? 'T-1024';
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
