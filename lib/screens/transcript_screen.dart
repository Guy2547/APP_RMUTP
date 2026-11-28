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
const Color _kChipBg = Color(0xFFF2ECFA);
const Color _kTableHeaderBg = Color(0xFFF5F1F9);
const Color _kCardBorder = Color(0xFFEEE9F3);
const Color _kDocBorder = Color(0xFFE7DFEE);
const Color _kRowDivider = Color(0xFFF0ECF4);

TextStyle _thai(double size, FontWeight weight, Color color,
        {double height = 1.4}) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

TextStyle _inter(double size, FontWeight weight, Color color,
        {double height = 1.4}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

class TranscriptCourse {
  final String code;
  final String name;
  final int credits;
  final String grade;

  const TranscriptCourse({
    required this.code,
    required this.name,
    required this.credits,
    required this.grade,
  });
}

class TranscriptSemester {
  final String title;
  final int totalCredits;
  final String gpa;
  final List<TranscriptCourse> courses;

  const TranscriptSemester({
    required this.title,
    required this.totalCredits,
    required this.gpa,
    required this.courses,
  });
}

/// สร้างระเบียนแสดงผลการเรียนจากผลการเรียนที่โหลดจากฐานข้อมูล
List<TranscriptSemester> buildTranscriptSemesters(List<GradeItem> grades) {
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

    return TranscriptSemester(
      title: entry.key,
      totalCredits: totalCredits,
      gpa: gpa.toStringAsFixed(2),
      courses: items
          .map(
            (g) => TranscriptCourse(
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

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabaseProvider>();
    final user = db.currentUser;
    final semesters = buildTranscriptSemesters(db.studentGrades);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ทรานสคริปต์'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StudentSummaryCard(
                    displayName: user?.displayName ?? '-',
                    studentId: user?.studentId ?? '-',
                    program: user?.subtitleInfo ?? '-',
                    gpax: user?.gpax.toStringAsFixed(2) ?? '-',
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'ตัวอย่างเอกสาร',
                        style: _thai(17, FontWeight.w600, _kInk),
                      ),
                      Text(
                        'เลื่อนเพื่อดูเพิ่มเติม',
                        style: _thai(10, FontWeight.w400, _kMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _DocumentPreviewCard(semesters: semesters)),
                ],
              ),
            ),
          ),
          _PinnedDownloadBar(
            onDownload: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'กำลังดาวน์โหลดไฟล์ทรานสคริปต์ PDF...',
                    style: _thai(13, FontWeight.w400, Colors.white),
                  ),
                  backgroundColor: _kPrimary,
                ),
              );
            },
          ),
        ],
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

class _StudentSummaryCard extends StatelessWidget {
  final String displayName;
  final String studentId;
  final String program;
  final String gpax;

  const _StudentSummaryCard({
    required this.displayName,
    required this.studentId,
    required this.program,
    required this.gpax,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: _inter(19, FontWeight.w600, _kInk),
                ),
                const SizedBox(height: 3),
                Text(
                  studentId,
                  style: _inter(12, FontWeight.w500, _kMuted),
                ),
                const SizedBox(height: 22),
                Text(
                  'หลักสูตร',
                  style: _thai(10, FontWeight.w400, _kMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  program,
                  style: _thai(12, FontWeight.w500, _kInk),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 82,
            height: 118,
            decoration: BoxDecoration(
              color: _kChipBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GPAX',
                  style: _inter(11, FontWeight.w600, _kPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  gpax,
                  style: _inter(29, FontWeight.w700, _kPrimary, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  'เกรดเฉลี่ยสะสม',
                  style: _thai(9, FontWeight.w400, _kPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreviewCard extends StatelessWidget {
  final List<TranscriptSemester> semesters;

  const _DocumentPreviewCard({required this.semesters});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kDocBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          children: [
            Text(
              'RMUTP',
              style: _inter(14, FontWeight.w600, _kPrimary),
            ),
            const SizedBox(height: 3),
            Text(
              'ระเบียนแสดงผลการเรียน',
              style: _thai(10, FontWeight.w500, _kMuted),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Divider(height: 1, thickness: 1, color: _kCardBorder),
            ),
            const SizedBox(height: 13),
            if (semesters.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'ยังไม่มีข้อมูลผลการเรียนในฐานข้อมูล',
                  style: _thai(12, FontWeight.w400, _kMuted),
                ),
              )
            else
              for (int i = 0; i < semesters.length; i++) ...[
                if (i > 0) const SizedBox(height: 24),
                _SemesterTable(semester: semesters[i]),
              ],
            const SizedBox(height: 18),
            Text(
              'แสดงผลการเรียน ${semesters.length} ภาคเรียนล่าสุด',
              style: _thai(9, FontWeight.w400, _kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterTable extends StatelessWidget {
  final TranscriptSemester semester;

  const _SemesterTable({required this.semester});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            semester.title,
            style: _thai(12, FontWeight.w600, _kPrimary),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _kTableHeaderBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'รายวิชา',
                  style: _thai(10, FontWeight.w500, _kMuted),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  'หน่วยกิต',
                  textAlign: TextAlign.center,
                  style: _thai(9.5, FontWeight.w500, _kMuted),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  'เกรด',
                  textAlign: TextAlign.center,
                  style: _thai(9.5, FontWeight.w500, _kMuted),
                ),
              ),
            ],
          ),
        ),
        for (final course in semester.courses) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.code,
                        style: _inter(8.5, FontWeight.w500, _kMuted),
                      ),
                      Text(
                        course.name,
                        style: _thai(10.5, FontWeight.w500, _kInk),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${course.credits}',
                    textAlign: TextAlign.center,
                    style: _inter(11, FontWeight.w500, _kInk),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    course.grade,
                    textAlign: TextAlign.center,
                    style: _inter(11, FontWeight.w600, _kPrimary),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(height: 1, thickness: 1, color: _kRowDivider),
          ),
        ],
        const SizedBox(height: 9),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _kChipBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'รวม ${semester.totalCredits} หน่วยกิต',
                style: _thai(10, FontWeight.w500, _kPrimary),
              ),
              Text(
                'GPA ${semester.gpa}',
                style: _inter(10, FontWeight.w600, _kPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinnedDownloadBar extends StatelessWidget {
  final VoidCallback onDownload;

  const _PinnedDownloadBar({required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.download_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ดาวน์โหลดไฟล์ PDF',
                        style: _thai(15, FontWeight.w600, Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'เอกสาร PDF · สำหรับตรวจสอบข้อมูล',
                style: _thai(9, FontWeight.w400, _kMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
