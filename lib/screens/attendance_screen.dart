import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final stuId = db.currentUser.studentId ?? '650602001';
    final myRecord = db.attendanceRecords.firstWhere(
      (r) => r.studentId == stuId,
      orElse: () => db.attendanceRecords.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ เช็คชื่อเข้าเรียน'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTeacher) ...[
              AppCard(
                padding: const EdgeInsets.all(20),
                color: kDark,
                child: Column(
                  children: [
                    const Text('◧', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      'ENGCE302 • รหัสห้อง DB-0921',
                      style: AppText.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      db.isAttendanceRoomOpen
                          ? 'สถานะห้อง: เปิดรับเช็คชื่อ (09:00–09:15)'
                          : 'สถานะห้อง: ปิดรับเช็คชื่อแล้ว',
                      style: AppText.kanit(
                        fontSize: 11,
                        color: Colors.purple.shade200,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: myRecord.status == 'present'
                          ? 'เช็คชื่อแล้วเมื่อ ${myRecord.checkInTime} ✅'
                          : 'กดเช็คชื่อ / สแกน QR',
                      onPressed: () async {
                        if (!db.isAttendanceRoomOpen) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('อาจารย์ปิดรับเช็คชื่อแล้ว'),
                            ),
                          );
                          return;
                        }
                        final time = await db.checkInCurrentStudent();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'บันทึกการเช็คชื่อเวลา $time ลงฐานข้อมูลสำเร็จ ✅',
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: kDark,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'ผู้ใช้งาน: ${db.currentUser.displayName} • สถานะคาบนี้: ${myRecord.status == 'present' ? 'มาเรียน (${myRecord.checkInTime})' : 'ยังไม่เช็คชื่อ'}',
                  style: AppText.kanit(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ] else ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👩‍🏫 เปิดห้องเช็คชื่อ — ENGCE302 Sec.1 (รหัส DB-0921)',
                      style: AppText.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: db.isAttendanceRoomOpen
                                ? 'กำลังเปิดรับเช็คชื่อ ✓'
                                : '+ เปิดห้องเช็คชื่อ',
                            onPressed: () async {
                              await db.toggleAttendanceRoom(true);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'เปิดห้องเช็คชื่อ รหัส DB-0921 ในฐานข้อมูลแล้ว',
                                    ),
                                  ),
                                );
                              }
                            },
                            backgroundColor: kGold,
                            foregroundColor: kDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GhostButton(
                            text: 'ปิดห้อง',
                            onPressed: () async {
                              await db.toggleAttendanceRoom(false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ปิดรับเช็คชื่อแล้ว'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เข้าเรียนแล้ว ${db.presentAttendanceCount}/${db.attendanceRecords.length} คน',
                      style: AppText.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: db.presentAttendanceCount /
                          db.attendanceRecords.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...db.attendanceRecords.map((rec) {
                      final isPresent =
                          rec.status == 'present' || rec.status == 'late';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isPresent
                                    ? '${rec.status == 'late' ? '⚠️' : '✅'} ${rec.studentId} ${rec.studentName} (${rec.checkInTime ?? '-'})'
                                    : '⏳ ${rec.studentId} ${rec.studentName} — ยังไม่มาเรียน',
                                style: AppText.kanit(
                                  fontSize: 11,
                                  color: isPresent
                                      ? Colors.grey.shade800
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                            if (!isPresent)
                              TextButton(
                                onPressed: () {
                                  db.remindStudentViaLine(rec.studentId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'ส่งแจ้งเตือนไลน์หา ${rec.studentName} แล้ว',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  rec.remindedViaLine ? 'เตือนแล้ว ✓' : 'เตือนไลน์',
                                  style: AppText.kanit(
                                    fontSize: 11,
                                    color: kMid,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? kDark,
        foregroundColor: foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(text),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GhostButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: kMid),
        foregroundColor: kMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(text),
    );
  }
}
