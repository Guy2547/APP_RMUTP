import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/grade.dart';
import '../providers/app_database_provider.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kOnPrimaryMuted = Color(0xFFE5D6F8);
const Color _kSummaryDivider = Color(0xFF703DA6);
const Color _kSelectorBorder = Color(0xFFE7DFEE);

TextStyle _thai(double size, FontWeight weight, Color color) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );

TextStyle _inter(double size, FontWeight weight, Color color) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );

class CourseResult {
  final String code;
  final String name;
  final int credits;
  final String grade;

  const CourseResult({
    required this.code,
    required this.name,
    required this.credits,
    required this.grade,
  });
}

class SemesterData {
  final String label;
  final String gpa;
  final List<CourseResult> courses;

  const SemesterData({
    required this.label,
    required this.gpa,
    required this.courses,
  });

  int get totalCredits =>
      courses.fold<int>(0, (sum, item) => sum + item.credits);
}

/// จัดกลุ่มผลการเรียนจาก v_student_grades ตามภาคเรียน และคำนวณ GPA
List<SemesterData> buildSemesters(List<GradeItem> grades) {
  final byTerm = <String, List<GradeItem>>{};
  for (final grade in grades) {
    final term = grade.termLabel.isEmpty ? 'ไม่ระบุภาคเรียน' : grade.termLabel;
    byTerm.putIfAbsent(term, () => []).add(grade);
  }

  return byTerm.entries.map((entry) {
    final items = entry.value;
    final totalCredits = items.fold<int>(0, (sum, g) => sum + g.credits);
    final weighted = items.fold<double>(
      0,
      (sum, g) => sum + g.score * g.credits,
    );
    final gpa = totalCredits == 0 ? 0.0 : weighted / totalCredits;

    return SemesterData(
      label: entry.key,
      gpa: gpa.toStringAsFixed(2),
      courses: items
          .map(
            (g) => CourseResult(
              code: g.subjectCode,
              name: g.subjectName,
              credits: g.credits,
              grade: g.letter,
            ),
          )
          .toList(),
    );
  }).toList();
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _selectedSemesterIndex = 0;

  void _showSemesterPicker() {
    final semesters = buildSemesters(
      context.read<AppDatabaseProvider>().studentGrades,
    );
    if (semesters.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < semesters.length; i++)
                  ListTile(
                    title: Text(
                      semesters[i].label,
                      style: _thai(
                        15,
                        i == _selectedSemesterIndex
                            ? FontWeight.w600
                            : FontWeight.w400,
                        i == _selectedSemesterIndex ? _kPrimary : _kInk,
                      ),
                    ),
                    trailing: i == _selectedSemesterIndex
                        ? const Icon(Icons.check_rounded, color: _kPrimary)
                        : null,
                    onTap: () {
                      setState(() => _selectedSemesterIndex = i);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabaseProvider>();
    final semesters = buildSemesters(db.studentGrades);

    if (semesters.isEmpty) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: _buildHeader(context, 'ผลการเรียน'),
        body: Center(
          child: Text(
            'ยังไม่มีข้อมูลผลการเรียนในฐานข้อมูล',
            style: _thai(14, FontWeight.w400, _kMuted),
          ),
        ),
      );
    }

    final selectedIndex = _selectedSemesterIndex.clamp(0, semesters.length - 1);
    final semester = semesters[selectedIndex];
    final user = db.currentUser;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ผลการเรียน'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AcademicSummaryCard(
                semesterGpa: semester.gpa,
                gpax: user?.gpax.toStringAsFixed(2) ?? '-',
                earnedCredits: user?.earnedCredits.toString() ?? '-',
              ),
              const SizedBox(height: 20),
              _SemesterSelector(
                label: semester.label,
                onTap: _showSemesterPicker,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'รายวิชา',
                    style: _thai(17, FontWeight.w600, _kInk),
                  ),
                  Text(
                    '${semester.courses.length} วิชา · ${semester.totalCredits} หน่วยกิต',
                    style: _thai(11, FontWeight.w400, _kMuted),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < semester.courses.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _CourseGradeCard(course: semester.courses[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildHeader(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: 50,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    leadingWidth: 64,
    leading: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(painter: _BackChevronPainter()),
            ),
          ),
        ),
      ),
    ),
    title: Text(title, style: _thai(21, FontWeight.w600, _kInk)),
  );
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 28, size.height / 28);
    final paint = Paint()
      ..color = _kPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(17, 6)
      ..lineTo(9, 14)
      ..lineTo(17, 22);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AcademicSummaryCard extends StatelessWidget {
  final String semesterGpa;
  final String gpax;
  final String earnedCredits;

  const _AcademicSummaryCard({
    required this.semesterGpa,
    required this.gpax,
    required this.earnedCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'เกรดเฉลี่ยสะสม (GPAX)',
                style: _thai(13, FontWeight.w500, _kOnPrimaryMuted),
              ),
              Text(
                'RMUTP',
                style: _inter(11, FontWeight.w600, _kOnPrimaryMuted),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            gpax,
            style: GoogleFonts.inter(
              fontSize: 44,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: _kSummaryDivider),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เกรดเฉลี่ยภาคเรียน (GPA)',
                      style: _thai(10.5, FontWeight.w400, _kOnPrimaryMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      semesterGpa,
                      style: _inter(22, FontWeight.w600, Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: _kSummaryDivider,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'หน่วยกิตสะสม',
                      style: _thai(10.5, FontWeight.w400, _kOnPrimaryMuted),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          earnedCredits,
                          style: _inter(22, FontWeight.w600, Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'หน่วยกิต',
                          style: _thai(11, FontWeight.w400, _kOnPrimaryMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SemesterSelector extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SemesterSelector({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kSelectorBorder, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: _thai(15, FontWeight.w500, _kInk)),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: _kPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseGradeCard extends StatelessWidget {
  final CourseResult course;

  const _CourseGradeCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: _inter(10, FontWeight.w500, _kMuted),
                ),
                Text(
                  course.name,
                  style: _thai(14, FontWeight.w500, _kInk),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${course.credits} หน่วยกิต',
                  style: _thai(10, FontWeight.w400, _kMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              course.grade,
              style: GoogleFonts.inter(
                fontSize: course.grade.length > 1 ? 16 : 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
