import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart' show CustomBottomNav, kBottomNavHeight;

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final stuId = db.currentUser.studentId ?? '650602001';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENGCE302 — ระบบฐานข้อมูล'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavHeight + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ChipTag(label: 'เอกสาร', backgroundColor: kDark, textColor: Colors.white),
                SizedBox(width: 6),
                ChipTag(label: 'งานที่สั่ง', backgroundColor: Colors.white, textColor: kMid),
                SizedBox(width: 6),
                ChipTag(label: 'คะแนน', backgroundColor: Colors.white, textColor: kMid),
              ],
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📄 ', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สไลด์ Lec 6 — Normalization (1NF, 2NF, 3NF)',
                              style: AppText.kanit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kDark,
                              ),
                            ),
                            Text(
                              'PDF • 2.4 MB • Storage Bucket: materials',
                              style: AppText.kanit(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: 'ดาวน์โหลดไฟล์จาก Storage',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ดาวน์โหลด ENGCE302_Lec6_Normalization.pdf แล้ว 📥'),
                      ),
                    ),
                    backgroundColor: kDark,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(14),
              border: Border(
                left: BorderSide(
                  color: db.isHomeworkSubmitted
                      ? Colors.green
                      : Colors.red.shade400,
                  width: 4,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📝 ', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'HW6: ออกแบบ ER + Normalization 3NF',
                          style: AppText.kanit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kDark,
                          ),
                        ),
                      ),
                      ChipTag(
                        label: db.isHomeworkSubmitted ? 'ส่งแล้ว ✓' : 'ส่งใน 2 วัน',
                        backgroundColor: db.isHomeworkSubmitted
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        textColor: db.isHomeworkSubmitted
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'แนบ PDF/รูป • บันทึกลงตาราง assignment_submissions',
                    style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      final fname = '${stuId}_HW6_ER_3NF.pdf';
                      db.attachHomeworkFile(fname);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('แนบไฟล์ $fname แล้ว 📎')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorderLight),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              db.attachedHomeworkFile != null
                                  ? '📎 ไฟล์ที่เลือก: ${db.attachedHomeworkFile}'
                                  : 'แตะเพื่อเลือกไฟล์ส่งงาน (${stuId}_HW6_ER_3NF.pdf)',
                              style: AppText.kanit(
                                fontSize: 11,
                                color: db.attachedHomeworkFile != null
                                    ? kDark
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const Icon(Icons.cloud_upload, size: 18, color: kMid),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: db.isHomeworkSubmitted
                        ? 'ส่งงานอีกครั้ง (อัปเดตฐานข้อมูล)'
                        : 'กดส่งงานเข้าฐานข้อมูล',
                    onPressed: () async {
                      await db.submitHomeworkFile();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'ส่งงาน ${db.attachedHomeworkFile} บันทึกลงฐานข้อมูลเรียบร้อย ✅',
                            ),
                          ),
                        );
                      }
                    },
                    backgroundColor: kGold,
                    foregroundColor: kDark,
                  ),
                  if (isTeacher) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('👩‍🏫 ', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'มุมอาจารย์: ส่งแล้ว 9/12 คน',
                                  style: AppText.kanit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/grade-submit'),
                                  child: Text(
                                    'ไปหน้าตรวจ+ส่งเกรดเข้าระบบทะเบียน →',
                                    style: AppText.kanit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: kMid,
                                    ).copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Text(
                'คะแนนเก็บปัจจุบัน: สอบย่อย 12/15 • Lab 16/25 • เข้าเรียน 92%',
                style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/courses',
        onTap: (route) => Navigator.pushNamed(context, route),
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

class ChipTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ChipTag({
    super.key,
    required this.label,
    this.backgroundColor = Colors.white,
    this.textColor = kMid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: backgroundColor == Colors.white ? Border.all(color: kBorderLight) : null,
      ),
      child: Text(
        label,
        style: AppText.kanit(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}
