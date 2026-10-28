import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../models/grade.dart';

class GradeRow extends StatelessWidget {
  final String subject;
  final String grade;
  final Color gradeColor;

  const GradeRow({
    super.key,
    required this.subject,
    required this.grade,
    this.gradeColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(subject, style: AppText.kanit(fontSize: 13)),
        Text(
          grade,
          style: AppText.kanit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: gradeColor,
          ),
        ),
      ],
    );
  }
}

class TeacherGradeRow extends StatelessWidget {
  final StudentRow row;
  final ValueChanged<int> onMidtermChanged;
  final ValueChanged<int> onFinalChanged;
  final ValueChanged<int> onCourseworkChanged;

  const TeacherGradeRow({
    super.key,
    required this.row,
    required this.onMidtermChanged,
    required this.onFinalChanged,
    required this.onCourseworkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${row.id} ${row.name}',
                style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: kDark),
              ),
              Text(
                'รวม ${row.total}/100',
                style: AppText.kanit(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _inputField('กลางภาค/30', row.midterm, onMidtermChanged, 30),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _inputField('ปลายภาค/40', row.finalExam, onFinalChanged, 40),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _inputField('เก็บ/30', row.coursework, onCourseworkChanged, 30),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เกรด ${row.gradeLetter}',
                style: AppText.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: row.isGreen ? Colors.green : row.isAmber ? Colors.amber : Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: row.status == 'ส่งแล้ว' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  row.status,
                  style: AppText.kanit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: row.status == 'ส่งแล้ว' ? Colors.green : Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, int value, ValueChanged<int> onChanged, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.kanit(fontSize: 10, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 32,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: kBorderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kMid, width: 2),
              ),
            ),
            style: AppText.kanit(fontSize: 12, fontWeight: FontWeight.w600),
            onChanged: (val) {
              final parsed = int.tryParse(val) ?? 0;
              onChanged(parsed.clamp(0, max));
            },
            controller: TextEditingController(text: value.toString()),
          ),
        ),
      ],
    );
  }
}
