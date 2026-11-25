import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/grade.dart';
import '../models/news_item.dart';
import '../models/request_item.dart';
import '../models/subject.dart';
import 'database_config.dart';

/// โมเดลข้อมูลผู้ใช้งานที่เข้าสู่ระบบสำเร็จ
class AuthenticatedUserSession {
  final String email;
  final String role; // 'student' | 'teacher' | 'admin'
  final String? studentId;
  final String? teacherId;
  final String displayName;
  final String subtitleInfo;
  final double gpax;
  final double currentTermGpa;
  final int earnedCredits;
  final int totalCreditsRequired;

  AuthenticatedUserSession({
    required this.email,
    required this.role,
    this.studentId,
    this.teacherId,
    required this.displayName,
    required this.subtitleInfo,
    this.gpax = 3.42,
    this.currentTermGpa = 3.55,
    this.earnedCredits = 87,
    this.totalCreditsRequired = 132,
  });

  bool get isTeacher => role == 'teacher';
}

/// โมเดลข้อมูลประวัติเชิงลึกของนักศึกษา (ใช้ PDPA Masking สำหรับ citizenId)
class StudentDeepProfile {
  final String studentId;
  final String fullNameTh;
  final String fullNameEn;
  final String universityEmail;
  final String citizenId;
  final String birthDate;
  final String bloodGroup;
  final String facultyNameTh;
  final String campus;
  final String departmentNameTh;
  final String degreeNameTh;
  final int yearLevel;
  final double gpax;
  final double currentTermGpa;
  final String creditsProgressLabel;
  final String advisorName;
  final String phone;
  final String lineId;
  final String currentAddress;
  final String permanentAddress;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;

  StudentDeepProfile({
    required this.studentId,
    required this.fullNameTh,
    required this.fullNameEn,
    required this.universityEmail,
    required this.citizenId,
    required this.birthDate,
    required this.bloodGroup,
    required this.facultyNameTh,
    required this.campus,
    required this.departmentNameTh,
    required this.degreeNameTh,
    required this.yearLevel,
    required this.gpax,
    required this.currentTermGpa,
    required this.creditsProgressLabel,
    required this.advisorName,
    required this.phone,
    required this.lineId,
    required this.currentAddress,
    required this.permanentAddress,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactPhone,
  });
}

/// โมเดลข้อมูลใบแจ้งหนี้ค่าเทอมและใบเสร็จรับเงินอิเล็กทรอนิกส์ (e-Receipt)
class FinancialReceiptRecord {
  final String invoiceNo;
  final String termLabel;
  final double tuitionFee;
  final double universityFee;
  final double labEquipmentFee;
  final double scholarshipDiscount;
  final double totalAmount;
  final String dueDate;
  final String paymentStatus;
  final String? receiptNo;
  final String? bankName;
  final String? transactionRef;
  final String? paidAt;
  final String? receiptPdfUrl;

  FinancialReceiptRecord({
    required this.invoiceNo,
    required this.termLabel,
    required this.tuitionFee,
    required this.universityFee,
    required this.labEquipmentFee,
    required this.scholarshipDiscount,
    required this.totalAmount,
    required this.dueDate,
    required this.paymentStatus,
    this.receiptNo,
    this.bankName,
    this.transactionRef,
    this.paidAt,
    this.receiptPdfUrl,
  });
}

/// โมเดลรายการเช็กชื่อรายบุคคล
class AttendanceRecordItem {
  final String studentId;
  final String studentName;
  String status; // 'present' | 'late' | 'absent' | 'leave'
  String? checkInTime;
  bool remindedViaLine;

  AttendanceRecordItem({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.checkInTime,
    this.remindedViaLine = false,
  });
}

class DatabaseService {
  static const Duration _timeout = Duration(seconds: 6);
  static const int maxUploadBytes = 5242880; // 5 MB
  static const List<String> _allowedExtensions = [
    '.pdf',
    '.png',
    '.jpg',
    '.jpeg',
    '.docx',
  ];
  static const Set<String> _allowedMimeTypes = {
    'application/pdf',
    'image/png',
    'image/jpeg',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  /// Secure Storage สำหรับเก็บ Access Token แบบเข้ารหัส (Keystore / Keychain)
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'supabase_access_token';

  /// Dio client พร้อมโครงสร้าง Certificate Pinning
  /// หมายเหตุ: ต้องนำข้อมูล pin ของ SSL certificate จากเซิร์ฟเวอร์จริงมาใส่ใน _certPins
  // ignore: unused_field
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 6),
    receiveTimeout: const Duration(seconds: 6),
    sendTimeout: const Duration(seconds: 6),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // TODO: ใส่ SHA-256 fingerprint ของ SSL certificate ของ Supabase / University API ที่นี่
  // ตัวอย่าง: 'SHA-256=xx:xx:xx:...'
  // ต้องขอข้อมูล pin จากผู้ดูแลระบบเซิร์ฟเวอร์ก่อนจึงจะใช้งานจริงได้
  // ignore: unused_field
  static const List<String> _certPins = [];

  /// สร้าง UUID แบบสุ่ม (เวอร์ชัน 4) ใช้แทน ID ที่เดาได้
  static String _generateUuid() {
    final random = Random.secure();
    return List.generate(36, (i) {
      if (i == 8 || i == 13 || i == 18 || i == 23) return '-';
      if (i == 14) return '4';
      if (i == 19) return '89ab'[random.nextInt(4)];
      return '0123456789abcdef'[random.nextInt(16)];
    }).join();
  }

  /// ปกปิดเลขบัตรประชาชนตามหลัก PDPA: 1-xxxx-xxxxx-xx-x
  static String maskCitizenId(String? rawCid) {
    final clean = (rawCid ?? '').trim();
    if (clean.contains('xxxx')) return clean;
    if (clean.length < 13) return 'x-xxxx-xxxxx-xx-x';
    return '${clean[0]}-xxxx-xxxxx-${clean.substring(10, 12)}-${clean[12]}';
  }

  /// ล้าง Session Token เมื่อผู้ใช้ออกจากระบบ (ทั้งหน่วยความจำและ Secure Storage)
  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    DatabaseConfig.activeAccessToken = null;
  }

  /// ตรวจสอบว่าสามารถติดต่อ API Server ปัจจุบันได้หรือไม่
  static bool get canCallRemoteApi {
    if (DatabaseConfig.currentMode == DatabaseBackendMode.universitySqlServer) {
      return DatabaseConfig.customUniversityApiUrl.trim().isNotEmpty;
    }
    return DatabaseConfig.isSupabaseConfigured;
  }

  // ---------------------------------------------------------------------------
  // 1. ระบบตรวจสอบการเข้าสู่ระบบจริง (sp_authenticate_user + เก็บ Token)
  // ---------------------------------------------------------------------------
  static Future<AuthenticatedUserSession?> authenticateUser(
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    await clearSession();

    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/rpc/sp_authenticate_user',
        );
        final res = await http
            .post(
              uri,
              headers: DatabaseConfig.defaultHeaders,
              body: jsonEncode({
                'p_email': cleanEmail,
                'p_password': password,
              }),
            )
            .timeout(_timeout);

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final List<dynamic> data = jsonDecode(res.body);
          if (data.isEmpty) return null;
          final row = data.first as Map<String, dynamic>;

          // เก็บ JWT (Express Mode) หรือ Session Token (Supabase RLS Mode)
          final token =
              row['access_token']?.toString() ?? row['session_token']?.toString();
          if (token != null && token.isNotEmpty) {
            DatabaseConfig.activeAccessToken = token;
            await _storage.write(key: _tokenKey, value: token);
          }

          return AuthenticatedUserSession(
            email: row['email']?.toString() ?? cleanEmail,
            role: row['role']?.toString() ?? 'student',
            studentId: row['student_id']?.toString(),
            teacherId: row['teacher_id']?.toString(),
            displayName: row['display_name']?.toString() ?? cleanEmail,
            subtitleInfo: row['subtitle_info']?.toString() ?? '',
            gpax: double.tryParse(row['gpax']?.toString() ?? '3.42') ?? 3.42,
            currentTermGpa:
                double.tryParse(row['current_term_gpa']?.toString() ?? '3.55') ??
                    3.55,
            earnedCredits:
                int.tryParse(row['earned_credits']?.toString() ?? '87') ?? 87,
            totalCreditsRequired: int.tryParse(
                  row['total_credits_required']?.toString() ?? '132',
                ) ??
                132,
          );
        }
        if (res.statusCode == 401 || res.statusCode == 403) {
          return null;
        }
      } catch (_) {
        // Fallback only if offline / before .env configuration
      }
    }

    // ไม่มี fallback รหัสผ่าน hardcoded อีกต่อไป — ต้องยืนยันตัวตนผ่าน API จริงเท่านั้น
    return null;
  }

  // ---------------------------------------------------------------------------
  // 2. ดึงข้อมูลโปรไฟล์เชิงลึกของนักศึกษา (v_student_profiles + PDPA Masking)
  // ---------------------------------------------------------------------------
  static Future<StudentDeepProfile> fetchStudentDeepProfile(
    String studentId,
  ) async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.viewStudentProfiles}?student_id=eq.${Uri.encodeComponent(studentId)}',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            final r = list.first as Map<String, dynamic>;
            return StudentDeepProfile(
              studentId: r['student_id']?.toString() ?? studentId,
              fullNameTh: r['full_name_th']?.toString() ?? '',
              fullNameEn: r['full_name_en']?.toString() ?? '',
              universityEmail: r['university_email']?.toString() ?? '',
              citizenId: maskCitizenId(r['citizen_id']?.toString()),
              birthDate: r['birth_date']?.toString() ?? '-',
              bloodGroup: r['blood_group']?.toString() ?? 'O',
              facultyNameTh: r['faculty_name_th']?.toString() ?? 'คณะวิศวกรรมศาสตร์',
              campus: r['campus']?.toString() ?? 'ศูนย์พระนครเหนือ',
              departmentNameTh:
                  r['department_name_th']?.toString() ?? 'วิศวกรรมคอมพิวเตอร์',
              degreeNameTh:
                  r['degree_name_th']?.toString() ?? 'วิศวกรรมศาสตรบัณฑิต (วศ.บ.)',
              yearLevel: int.tryParse(r['year_level']?.toString() ?? '2') ?? 2,
              gpax: double.tryParse(r['gpax']?.toString() ?? '3.42') ?? 3.42,
              currentTermGpa:
                  double.tryParse(r['current_term_gpa']?.toString() ?? '3.55') ??
                      3.55,
              creditsProgressLabel:
                  r['credits_progress_label']?.toString() ?? '87/132',
              advisorName: r['advisor_name']?.toString() ?? 'อ.สุรชัย วงศ์ใหญ่',
              phone: r['phone']?.toString() ?? '-',
              lineId: r['line_id']?.toString() ?? '-',
              currentAddress: r['current_address']?.toString() ?? '-',
              permanentAddress:
                  '${r['permanent_address'] ?? ''} ${r['subdistrict'] ?? ''} ${r['district'] ?? ''} ${r['province'] ?? ''} ${r['postal_code'] ?? ''}'
                      .trim(),
              emergencyContactName:
                  r['emergency_contact_name']?.toString() ?? '-',
              emergencyContactRelation:
                  r['emergency_contact_relation']?.toString() ?? '-',
              emergencyContactPhone:
                  r['emergency_contact_phone']?.toString() ?? '-',
            );
          }
        }
      } catch (_) {}
    }

    return _defaultDeepProfile(studentId);
  }

  // ---------------------------------------------------------------------------
  // 3. ดึงประวัติค่าเทอมและใบเสร็จรับเงิน (v_student_financial_records)
  // ---------------------------------------------------------------------------
  static Future<List<FinancialReceiptRecord>> fetchFinancialRecords(
    String studentId,
  ) async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.viewStudentFinancialRecords}?student_id=eq.${Uri.encodeComponent(studentId)}',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              return FinancialReceiptRecord(
                invoiceNo: r['invoice_no']?.toString() ?? '',
                termLabel: r['term_label']?.toString() ?? '1/2569',
                tuitionFee:
                    double.tryParse(r['tuition_fee']?.toString() ?? '15000') ??
                        15000,
                universityFee:
                    double.tryParse(r['university_fee']?.toString() ?? '2000') ??
                        2000,
                labEquipmentFee: double.tryParse(
                      r['lab_equipment_fee']?.toString() ?? '1500',
                    ) ??
                    1500,
                scholarshipDiscount: double.tryParse(
                      r['scholarship_discount']?.toString() ?? '0',
                    ) ??
                    0,
                totalAmount:
                    double.tryParse(r['total_amount']?.toString() ?? '18500') ??
                        18500,
                dueDate: r['due_date']?.toString() ?? '2026-06-30',
                paymentStatus: r['payment_status']?.toString() ?? 'paid',
                receiptNo: r['receipt_no']?.toString(),
                bankName: r['bank_name']?.toString(),
                transactionRef: r['transaction_ref']?.toString(),
                paidAt: r['paid_at']?.toString(),
                receiptPdfUrl: r['receipt_pdf_url']?.toString(),
              );
            }).toList();
          }
        }
      } catch (_) {}
    }

    return _defaultFinancialRecords(studentId);
  }

  // ---------------------------------------------------------------------------
  // 4. ดึงตารางเรียนและรายวิชา (v_student_timetable & v_teacher_timetable)
  // ---------------------------------------------------------------------------
  static Future<List<Subject>> fetchStudentTimetable(String studentId) async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.viewStudentTimetable}?student_id=eq.${Uri.encodeComponent(studentId)}',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              return Subject(
                code: r['code']?.toString() ?? '',
                name: r['name']?.toString() ?? '',
                section: r['section']?.toString() ?? 'Sec.1',
                dayOfWeek: r['day_of_week']?.toString() ?? 'MON',
                time: r['time']?.toString() ?? '',
                room: r['room']?.toString() ?? '',
                teacher: r['teacher']?.toString() ?? '-',
                status: r['status']?.toString() ?? '-',
                courseSummary: r['course_summary']?.toString() ?? '',
                progress: int.tryParse(r['progress']?.toString() ?? '0') ?? 0,
                pendingAssignments:
                    int.tryParse(r['pending_assignments']?.toString() ?? '0') ??
                        0,
                isLab: r['is_lab'] == true,
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<List<Subject>> fetchTeacherTimetable(String teacherId) async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.viewTeacherTimetable}?teacher_id=eq.${Uri.encodeComponent(teacherId)}',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              return Subject(
                code: r['code']?.toString() ?? '',
                name: r['course_name']?.toString() ?? '',
                section: r['section']?.toString() ?? 'Sec.1',
                dayOfWeek: r['day_of_week']?.toString() ?? 'MON',
                time: r['time']?.toString() ?? '',
                room: r['room']?.toString() ?? '',
                teacher: r['student_count_label']?.toString() ?? '12 คน',
                status: r['status']?.toString() ?? '+ เปิดเช็คชื่อ',
                courseSummary: r['course_summary']?.toString() ?? '',
                progress: int.tryParse(r['progress']?.toString() ?? '0') ?? 0,
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // 5. ดึงผลการเรียนและใบกรอกคะแนนอาจารย์ + บันทึกเกรดแบบ Transaction
  // ---------------------------------------------------------------------------
  static Future<List<GradeItem>> fetchStudentGrades(String studentId) async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.viewStudentGrades}?student_id=eq.${Uri.encodeComponent(studentId)}',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              return GradeItem(
                subjectCode: r['subject_code']?.toString() ?? '',
                subjectName: r['subject_name']?.toString() ?? '',
                letter: r['letter']?.toString() ?? 'A (4.0)',
                score: double.tryParse(r['score']?.toString() ?? '4.0') ?? 4.0,
                isWarning: r['is_warning'] == true,
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<List<StudentRow>> fetchTeacherGradeSheet(
    String subjectCode,
  ) async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.viewTeacherGradeSheet}?subject_code=eq.${Uri.encodeComponent(subjectCode)}',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              return StudentRow(
                id: r['id']?.toString() ?? '',
                name: r['full_name']?.toString() ?? r['name']?.toString() ?? '',
                midterm: int.tryParse(r['midterm']?.toString() ?? '0') ?? 0,
                finalExam:
                    int.tryParse(r['final_exam']?.toString() ?? '0') ?? 0,
                coursework:
                    int.tryParse(r['coursework']?.toString() ?? '0') ?? 0,
                status: r['status']?.toString() ?? 'ร่าง',
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<bool> saveTeacherGrades(
    String subjectCode,
    List<StudentRow> rows, {
    required bool submitFinal,
    required String teacherId, // ต้องระบุจาก session ของอาจารย์ที่ล็อกอินจริง ไม่มีค่าเริ่มต้น hardcoded
  }) async {
    // Client-side Input Validation ก่อนส่ง
    for (final row in rows) {
      if (row.midterm < 0 ||
          row.midterm > 30 ||
          row.finalExam < 0 ||
          row.finalExam > 40 ||
          row.coursework < 0 ||
          row.coursework > 30) {
        return false;
      }
    }

    if (!canCallRemoteApi) return true;
    try {
      final uri = Uri.parse(
        '${DatabaseConfig.activeRestBaseUrl}/rpc/sp_submit_section_grades',
      );
      final payload = rows
          .map(
            (r) => {
              'student_id': r.id,
              'midterm': r.midterm,
              'final_exam': r.finalExam,
              'coursework': r.coursework,
            },
          )
          .toList();

      final res = await http
          .post(
            uri,
            headers: DatabaseConfig.defaultHeaders,
            body: jsonEncode({
              'p_teacher_id': teacherId,
              'p_subject_code': subjectCode,
              'p_grades': payload,
              'p_submit_final': submitFinal,
            }),
          )
          .timeout(_timeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 6. ระบบเช็กชื่อเข้าเรียน (ใช้เวลาของ Database Server เท่านั้นผ่าน RPC)
  // ---------------------------------------------------------------------------
  static Future<bool> checkInAttendance({
    required String studentId,
    String? checkInTime,
    String? sessionId, // สร้าง UUID สุ่มถ้าไม่ส่งมา
    String method = 'qr_scan',
  }) async {
    if (!canCallRemoteApi) return true;
    try {
      final effectiveSessionId = sessionId ?? _generateUuid();
      final uri = Uri.parse(
        '${DatabaseConfig.activeRestBaseUrl}/rpc/sp_check_in_attendance',
      );
      final res = await http
          .post(
            uri,
            headers: DatabaseConfig.defaultHeaders,
            body: jsonEncode({
              'p_session_id': effectiveSessionId,
              'p_student_id': studentId,
              'p_method': method,
            }),
          )
          .timeout(_timeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> toggleAttendanceSession(bool isOpen, {String? sessionId}) async {
    if (!canCallRemoteApi) return true;
    try {
      final effectiveSessionId = sessionId ?? _generateUuid();
      final uri = Uri.parse(
        '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.tableAttendanceSessions}?id=eq.$effectiveSessionId',
      );
      final res = await http
          .patch(
            uri,
            headers: DatabaseConfig.defaultHeaders,
            body: jsonEncode({'is_open': isOpen}),
          )
          .timeout(_timeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 7. ระบบส่งการบ้าน (ตรวจสอบไฟล์/ขนาด/MIME + เทียบ due_date บน Server)
  // ---------------------------------------------------------------------------
  static bool isValidUploadFile(
    String fileName, {
    int fileSizeBytes = 256000,
    String mimeType = 'application/pdf',
  }) {
    final lower = fileName.trim().toLowerCase();
    if (lower.contains('..') || lower.contains('/') || lower.contains('\\')) {
      return false;
    }
    final hasValidExt = _allowedExtensions.any((ext) => lower.endsWith(ext));
    if (!hasValidExt) return false;
    if (!_allowedMimeTypes.contains(mimeType)) return false;
    if (fileSizeBytes <= 0 || fileSizeBytes > maxUploadBytes) return false;
    return true;
  }

  static Future<bool> submitAssignment({
    required String studentId,
    required String fileName,
    int fileSizeBytes = 256000,
    String mimeType = 'application/pdf',
    String? assignmentId, // สร้าง UUID สุ่มถ้าไม่ส่งมา
  }) async {
    if (!isValidUploadFile(
      fileName,
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
    )) {
      return false;
    }
    if (!canCallRemoteApi) return true;
    try {
      final effectiveAssignmentId = assignmentId ?? _generateUuid();
      final uri = Uri.parse(
        '${DatabaseConfig.activeRestBaseUrl}/rpc/sp_submit_assignment',
      );
      final res = await http
          .post(
            uri,
            headers: DatabaseConfig.defaultHeaders,
            body: jsonEncode({
              'p_assignment_id': effectiveAssignmentId,
              'p_student_id': studentId,
              'p_original_filename': fileName.trim(),
              'p_file_size_bytes': fileSizeBytes,
              'p_mime_type': mimeType,
            }),
          )
          .timeout(_timeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 8. ระบบคำร้องและแจ้งเรื่อง (Service Requests)
  // ---------------------------------------------------------------------------
  static Future<List<RequestItem>> fetchServiceRequests() async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.tableServiceRequests}?order=created_at.desc',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              final hex = r['chip_color_hex']?.toString() ?? '#FFC107';
              return RequestItem(
                id: r['request_code']?.toString() ?? '#RQ-1000',
                title: r['title']?.toString() ?? '',
                description: r['description']?.toString() ?? '',
                category: r['category']?.toString() ?? 'document',
                studentId: r['student_id']?.toString() ?? '650602001',
                status: r['status_student']?.toString() ?? 'รอดำเนินการ',
                statusTeacher: r['status_teacher']?.toString() ?? 'รออนุมัติ',
                chipColor: _parseHexColor(hex),
                progress:
                    double.tryParse(r['progress']?.toString() ?? '0.4') ?? 0.4,
                resultPdfUrl: r['result_pdf_url']?.toString(),
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<RequestItem> createServiceRequest({
    required String studentId,
    required String category,
    required String title,
    required String description,
  }) async {
    final code = '#RQ-${_generateUuid().substring(0, 8).toUpperCase()}';
    final newItem = RequestItem(
      id: code,
      title: title,
      description: description,
      category: category,
      studentId: studentId,
      status: 'รอดำเนินการ',
      statusTeacher: 'รออนุมัติ',
      chipColor: Colors.amber,
      progress: 0.30,
    );

    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.tableServiceRequests}',
        );
        await http
            .post(
              uri,
              headers: DatabaseConfig.defaultHeaders,
              body: jsonEncode({
                'request_code': code,
                'student_id': studentId,
                'category': category,
                'title': title,
                'description': description,
                'status_student': 'รอดำเนินการ',
                'status_teacher': 'รออนุมัติ',
                'chip_color_hex': '#FFC107',
                'progress': 0.30,
                'assigned_teacher_id': 'T-1024',
              }),
            )
            .timeout(_timeout);
      } catch (_) {}
    }

    return newItem;
  }

  static Future<bool> updateServiceRequestStatus({
    required String requestCode,
    required bool approved,
  }) async {
    if (!canCallRemoteApi) return true;
    try {
      final encodedCode = Uri.encodeComponent(requestCode);
      final uri = Uri.parse(
        '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.tableServiceRequests}?request_code=eq.$encodedCode',
      );
      final res = await http
          .patch(
            uri,
            headers: DatabaseConfig.defaultHeaders,
            body: jsonEncode({
              'status_student': approved
                  ? 'เสร็จแล้ว • โหลด PDF'
                  : 'ตีกลับให้แก้ไขเอกสาร',
              'status_teacher': approved ? 'เสร็จสิ้น' : 'ตีกลับ',
              'chip_color_hex': approved ? '#4CAF50' : '#F44336',
              'progress': approved ? 1.0 : 0.2,
            }),
          )
          .timeout(_timeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 9. ข่าวสารและการแจ้งเตือน (News Announcements)
  // ---------------------------------------------------------------------------
  static Future<List<NewsItem>> fetchNewsAnnouncements() async {
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.tableNewsAnnouncements}?order=published_at.desc',
        );
        final res = await http
            .get(uri, headers: DatabaseConfig.defaultHeaders)
            .timeout(_timeout);
        if (res.statusCode == 200) {
          final List<dynamic> list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return list.map((e) {
              final r = e as Map<String, dynamic>;
              return NewsItem(
                title: r['title']?.toString() ?? '',
                subtitle: r['subtitle']?.toString() ?? '',
                type: r['news_type']?.toString() ?? 'ประกาศ',
                detail: r['detail']?.toString() ?? '',
                buttonLabel: r['button_label']?.toString() ?? 'ดูรายละเอียด',
              );
            }).toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<NewsItem> createNewsAnnouncement({
    required String title,
    required String type,
    required String detail,
    required String teacherId,
  }) async {
    final item = NewsItem(
      title: title,
      subtitle: '$type • เพิ่งประกาศ',
      type: type,
      detail: detail,
      buttonLabel: 'ดูรายละเอียด',
    );
    if (canCallRemoteApi) {
      try {
        final uri = Uri.parse(
          '${DatabaseConfig.activeRestBaseUrl}/${DatabaseConfig.tableNewsAnnouncements}',
        );
        await http
            .post(
              uri,
              headers: DatabaseConfig.defaultHeaders,
              body: jsonEncode({
                'title': title,
                'subtitle': '$type • เพิ่งประกาศ',
                'news_type': type,
                'detail': detail,
                'button_label': 'ดูรายละเอียด',
                'author_teacher_id': teacherId,
              }),
            )
            .timeout(_timeout);
      } catch (_) {}
    }
    return item;
  }

  static Color _parseHexColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return Colors.amber;
  }

  // ---------------------------------------------------------------------------
  // Fallback data เมื่อไม่มีการเชื่อมต่อ API (dummy data เท่านั้น — ไม่มีข้อมูลบุคคลจริง)
  // ---------------------------------------------------------------------------
  static StudentDeepProfile _defaultDeepProfile(String studentId) {
    return StudentDeepProfile(
      studentId: studentId,
      fullNameTh: 'ผู้ใช้งานระบบ',
      fullNameEn: 'System User',
      universityEmail: '$studentId@example.ac.th',
      citizenId: 'x-xxxx-xxxxx-xx-x',
      birthDate: '-',
      bloodGroup: '-',
      facultyNameTh: '-',
      campus: '-',
      departmentNameTh: '-',
      degreeNameTh: '-',
      yearLevel: 1,
      gpax: 0.0,
      currentTermGpa: 0.0,
      creditsProgressLabel: '0/0',
      advisorName: '-',
      phone: '-',
      lineId: '-',
      currentAddress: '-',
      permanentAddress: '-',
      emergencyContactName: '-',
      emergencyContactRelation: '-',
      emergencyContactPhone: '-',
    );
  }

  static List<FinancialReceiptRecord> _defaultFinancialRecords(
    String studentId,
  ) {
    return [];
  }
}
