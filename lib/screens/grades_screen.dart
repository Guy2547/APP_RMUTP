import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 ผลการเรียน'),
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
            if (!isTeacher) ..._buildStudentContent(db),
            if (isTeacher) ..._buildTeacherContent(context, db),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/grades',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  List<Widget> _buildStudentContent(AppDatabaseProvider db) {
    final user = db.currentUser;
    return [
      AppCard(
        padding: const EdgeInsets.all(16),
        color: kDark,
        child: Column(
          children: [
            Text(
              'GPA สะสม (${user.displayName})',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
            const SizedBox(height: 4),
            Text(
              user.gpax.toStringAsFixed(2),
              style: AppText.kanit(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: kGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'เทอมนี้ ${user.currentTermGpa.toStringAsFixed(2)} • หน่วยกิต ${user.earnedCredits}/${user.totalCreditsRequired}',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ...db.studentGrades.map((g) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${g.subjectCode} ${g.subjectName}',
                    style: AppText.kanit(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Text(
                  g.letter,
                  style: AppText.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: g.isWarning ? Colors.amber.shade800 : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.all(12),
        color: Colors.amber.withValues(alpha: 0.05),
        child: Text(
          '💡 เกรดคำนวณอัตโนมัติผ่าน PostgreSQL Trigger (trg_auto_calculate_grade)',
          style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
        ),
      ),
    ];
  }

  List<Widget> _buildTeacherContent(
    BuildContext context,
    AppDatabaseProvider db,
  ) {
    final total = db.teacherGradeRows.length;
    final submitted = db.submittedGradeCount;

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
              '${db.teacherTimetable.length} วิชา • $total คน/กลุ่ม',
              style: AppText.kanit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ส่งเกรดแล้ว $submitted/$total • ปิดรับเกรด 30 ก.ย.',
              style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ...db.teacherTimetable.map((sub) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sub.code} — ${sub.name} (${sub.section})',
                        style: AppText.kanit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sub.room} • ${sub.teacher}',
                        style: AppText.kanit(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/grade-submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: kDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('กรอกเกรด'),
                ),
              ],
            ),
          ),
        );
      }),
    ];
  }
}
