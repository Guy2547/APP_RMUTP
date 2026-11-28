import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _CourseResult {
  final String code;
  final String name;
  final int credits;
  final String grade;

  const _CourseResult({
    required this.code,
    required this.name,
    required this.credits,
    required this.grade,
  });
}

class _SemesterData {
  final String label;
  final String gpa;
  final List<_CourseResult> courses;

  const _SemesterData({
    required this.label,
    required this.gpa,
    required this.courses,
  });

  int get totalCredits =>
      courses.fold<int>(0, (sum, item) => sum + item.credits);
}

const List<_SemesterData> _semesters = [
  _SemesterData(
    label: 'ภาคเรียนที่ 1/2569',
    gpa: '4.00',
    courses: [
      _CourseResult(
        code: '040203201',
        name: 'การเขียนโปรแกรมเชิงวัตถุ',
        credits: 3,
        grade: 'A',
      ),
      _CourseResult(
        code: '040203202',
        name: 'ระบบฐานข้อมูล',
        credits: 3,
        grade: 'A',
      ),
      _CourseResult(
        code: '040203203',
        name: 'เครือข่ายคอมพิวเตอร์',
        credits: 3,
        grade: 'A',
      ),
      _CourseResult(
        code: '040203204',
        name: 'ระบบปฏิบัติการ',
        credits: 3,
        grade: 'A',
      ),
      _CourseResult(
        code: '040203205',
        name: 'วิศวกรรมซอฟต์แวร์',
        credits: 3,
        grade: 'A',
      ),
    ],
  ),
  _SemesterData(
    label: 'ภาคเรียนที่ 2/2568',
    gpa: '3.88',
    courses: [
      _CourseResult(
        code: '040203105',
        name: 'โครงสร้างข้อมูลและอัลกอริทึม',
        credits: 3,
        grade: 'A',
      ),
      _CourseResult(
        code: '040203106',
        name: 'สถาปัตยกรรมคอมพิวเตอร์',
        credits: 3,
        grade: 'A',
      ),
      _CourseResult(
        code: '040203107',
        name: 'คณิตศาสตร์ดิสครีต',
        credits: 3,
        grade: 'B+',
      ),
      _CourseResult(
        code: '010101102',
        name: 'ภาษาอังกฤษเพื่อการสื่อสาร',
        credits: 3,
        grade: 'A',
      ),
    ],
  ),
];

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _selectedSemesterIndex = 0;

  void _showSemesterPicker() {
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
                for (int i = 0; i < _semesters.length; i++)
                  ListTile(
                    title: Text(
                      _semesters[i].label,
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
    final semester = _semesters[_selectedSemesterIndex];

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
              _AcademicSummaryCard(semesterGpa: semester.gpa),
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

  const _AcademicSummaryCard({required this.semesterGpa});

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
            '3.90',
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
                          '96',
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
  final _CourseResult course;

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
