import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENGCE302 — ระบบฐานข้อมูล'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ChipTag(label: 'เอกสาร', backgroundColor: kDark, textColor: Colors.white),
                const SizedBox(width: 6),
                ChipTag(label: 'งานที่สั่ง', backgroundColor: Colors.white, textColor: kMid),
                const SizedBox(width: 6),
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
                              'สไลด์ Lec 6 — Normalization',
                              style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                            ),
                            Text(
                              'PDF • 2.4 MB • อัปเดตเมื่อวาน',
                              style: AppText.kanit(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: 'ดาวน์โหลด',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ดาวน์โหลดไฟล์แล้ว')),
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
              border: Border(left: BorderSide(color: Colors.red.shade400, width: 4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📝 ', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'HW6: ออกแบบ ER + Normalization',
                          style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                        ),
                      ),
                      ChipTag(
                        label: 'ส่งใน 2 วัน',
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        textColor: Colors.red.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'แนบ PDF/รูป • ส่งได้ถึง 23 ก.ย. 23:59',
                    style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorderLight, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'แตะเพื่อแนบไฟล์ (demo)',
                            style: AppText.kanit(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ),
                        Icon(Icons.cloud_upload, size: 16, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: 'กดส่งงาน',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ส่งงาน HW6 เรียบร้อย ✅')),
                    ),
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
                                  'มุมอาจารย์: ส่งแล้ว 28/40 คน',
                                  style: AppText.kanit(fontSize: 11, fontWeight: FontWeight.w600, color: kDark),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'ตรวจ+ส่งเกรด',
                                      style: AppText.kanit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: kMid,
                                      ).copyWith(decoration: TextDecoration.underline),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'โหลดรวม',
                                      style: AppText.kanit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: kMid,
                                      ).copyWith(decoration: TextDecoration.underline),
                                    ),
                                  ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คะแนนเก็บ: สอบย่อย 12/15 • Lab 16/25 • เข้าเรียน 92%',
                    style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
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
