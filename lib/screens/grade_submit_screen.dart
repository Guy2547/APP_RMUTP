import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import '../models/grade.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/grade_card.dart';

class GradeSubmitScreen extends StatefulWidget {
  const GradeSubmitScreen({super.key});

  @override
  State<GradeSubmitScreen> createState() => _GradeSubmitScreenState();
}

class _GradeSubmitScreenState extends State<GradeSubmitScreen> {
  final List<StudentRow> _rows = List<StudentRow>.from(MockData.gradeSubmitRows);
  int _submittedCount = 28;
  final int _totalCount = 40;

  void _submitGrades() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันส่งเกรด'),
        content: const Text('ยืนยันส่งเกรด ENGCE302 Sec.1 เข้าระบบทะเบียน?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          PrimaryButton(
            text: 'ยืนยัน',
            onPressed: () {
              setState(() {
                for (var row in _rows) {
                  row.status = 'ส่งแล้ว';
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ส่งเกรดเข้าระบบเรียบร้อย ✅')),
              );
            },
            backgroundColor: kGold,
            foregroundColor: kDark,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👩‍🏫 ตรวจ + ส่งเกรดเข้าระบบ'),
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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'ENGCE302 Sec.1 (40 คน)',
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: ['ENGCE302 Sec.1 (40 คน)', 'ENGCE305 Sec.2 (38 คน)']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 8),
                GhostButton(
                  text: 'CSV',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export CSV แล้ว 📥')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'เทอม 1/2569 • ตัดเกรด: A≥80 B+≥75 B≥70 C+≥65 C≥60 D+≥55 D≥50',
              style: AppText.kanit(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ส่งแล้ว $_submittedCount/$_totalCount',
                        style: AppText.kanit(fontSize: 12, fontWeight: FontWeight.w600, color: kDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _submittedCount / _totalCount,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final row in _rows)
              TeacherGradeRow(
                row: row,
                onMidtermChanged: (v) {
                  setState(() => row.midterm = v);
                },
                onFinalChanged: (v) {
                  setState(() => row.finalExam = v);
                },
                onCourseworkChanged: (v) {
                  setState(() => row.coursework = v);
                },
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    text: 'บันทึกร่าง',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('บันทึกร่างแล้ว 💾')),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    text: 'ส่งเข้าระบบทะเบียน',
                    onPressed: _submitGrades,
                    backgroundColor: kGold,
                    foregroundColor: kDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'เฉพาะอาจารย์ • ส่งแล้วล็อกการแก้ไข ต้องติดต่อทะเบียนเพื่อปลดล็อก',
              style: AppText.kanit(fontSize: 10, color: Colors.grey.shade400),
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
