import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../services/mock_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 ผลการเรียน'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTeacher) ..._buildStudentContent(),
            if (isTeacher) ..._buildTeacherContent(context),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/grades',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  List<Widget> _buildStudentContent() {
    return [
      AppCard(
        padding: const EdgeInsets.all(16),
        color: kDark,
        child: Column(
          children: [
            Text(
              'GPA สะสม',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
            const SizedBox(height: 4),
            Text(
              '3.42',
              style: AppText.kanit(fontSize: 40, fontWeight: FontWeight.bold, color: kGold),
            ),
            const SizedBox(height: 4),
            Text(
              'เทอมนี้ 3.55 • หน่วยกิต 87/132',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ...MockData.gradesStudent.map((g) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${g.subjectCode} ${g.subjectName}',
                  style: AppText.kanit(fontSize: 13, color: Colors.grey.shade800),
                ),
              ),
              Text(
                g.letter,
                style: AppText.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: g.isWarning ? Colors.amber : Colors.green,
                ),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(12),
        color: Colors.amber.withValues(alpha: 0.05),
        child: Text(
          '💡 เกรด C+ วิชาสถิติฉุด GPA — แนะนำลงติวเสริมที่คณะ (ดูในข่าวกิจกรรม)',
          style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
        ),
      ),
    ];
  }

  List<Widget> _buildTeacherContent(BuildContext context) {
    return [
      AppCard(
        padding: const EdgeInsets.all(16),
        color: kDark,
        child: Column(
          children: [
            Text(
              'วิชาที่สอนเทอมนี้',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
            const SizedBox(height: 4),
            Text(
              '2 วิชา • 78 คน',
              style: AppText.kanit(fontSize: 28, fontWeight: FontWeight.bold, color: kGold),
            ),
            const SizedBox(height: 4),
            Text(
              'ส่งเกรดแล้ว 28/78 • เหลือ 5 วัน (ปิด 30 ก.ย.)',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      for (final c in MockData.coursesTeacher)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.displayName,
                            style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                          ),
                          Text(
                            c.status,
                            style: AppText.kanit(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    PrimaryButton(
                      text: 'ตรวจ+ส่งเกรด',
                      onPressed: () => Navigator.pushNamed(context, '/grade-submit'),
                      backgroundColor: kGold,
                      foregroundColor: kDark,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: c.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(12),
        color: Colors.grey.shade50,
        child: Text(
          '⏰ เดดไลน์ส่งเกรด 30 ก.ย. • ส่งแล้วล็อกแก้ไข ติดต่อทะเบียนเพื่อปลดล็อก',
          style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
        ),
      ),
    ];
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
