import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kTabBg = Color(0xFFEDE7F3);
const Color _kChipBg = Color(0xFFF2ECFA);
const Color _kCardBorder = Color(0xFFEEE9F3);

TextStyle _thai(double size, FontWeight weight, Color color) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
    );

TextStyle _inter(double size, FontWeight weight, Color color) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
    );

class _ExamItem {
  final String date;
  final String timeRange;
  final String code;
  final String title;
  final String room;
  final String seat;

  const _ExamItem({
    required this.date,
    required this.timeRange,
    required this.code,
    required this.title,
    required this.room,
    required this.seat,
  });
}

const List<_ExamItem> _midtermExams = [
  _ExamItem(
    date: '17 ส.ค. 2569',
    timeRange: '09:00 – 12:00',
    code: '040203201',
    title: 'การเขียนโปรแกรมเชิงวัตถุ',
    room: 'อาคาร 6 ห้อง 604',
    seat: '024',
  ),
  _ExamItem(
    date: '19 ส.ค. 2569',
    timeRange: '13:00 – 16:00',
    code: '040203202',
    title: 'ระบบฐานข้อมูล',
    room: 'อาคาร 6 ห้อง 602',
    seat: '018',
  ),
  _ExamItem(
    date: '21 ส.ค. 2569',
    timeRange: '09:00 – 12:00',
    code: '040203205',
    title: 'วิศวกรรมซอฟต์แวร์',
    room: 'อาคาร 5 ห้อง 503',
    seat: '032',
  ),
];

const List<_ExamItem> _finalExams = [
  _ExamItem(
    date: '12 ต.ค. 2569',
    timeRange: '09:00 – 12:00',
    code: '040203201',
    title: 'การเขียนโปรแกรมเชิงวัตถุ',
    room: 'อาคาร 6 ห้อง 604',
    seat: '024',
  ),
  _ExamItem(
    date: '14 ต.ค. 2569',
    timeRange: '13:00 – 16:00',
    code: '040203202',
    title: 'ระบบฐานข้อมูล',
    room: 'อาคาร 6 ห้อง 602',
    seat: '018',
  ),
  _ExamItem(
    date: '16 ต.ค. 2569',
    timeRange: '09:00 – 12:00',
    code: '040203205',
    title: 'วิศวกรรมซอฟต์แวร์',
    room: 'อาคาร 5 ห้อง 503',
    seat: '032',
  ),
];

class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  int _selectedTab = 0; // 0 = สอบกลางภาค, 1 = สอบปลายภาค

  @override
  Widget build(BuildContext context) {
    final exams = _selectedTab == 0 ? _midtermExams : _finalExams;
    final sectionTitle =
        _selectedTab == 0 ? 'กำหนดการสอบกลางภาค' : 'กำหนดการสอบปลายภาค';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ตารางสอบ'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExamTypeTabs(
                selectedIndex: _selectedTab,
                onChanged: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ภาคเรียนที่ 1/2569',
                    style: _thai(13, FontWeight.w500, _kMuted),
                  ),
                  Text(
                    'RMUTP',
                    style: _inter(10, FontWeight.w600, _kPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    sectionTitle,
                    style: _thai(17, FontWeight.w600, _kInk),
                  ),
                  Text(
                    '${exams.length} รายวิชา',
                    style: _thai(11, FontWeight.w400, _kMuted),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < exams.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _ExamCard(exam: exams[i]),
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

class _ExamTypeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ExamTypeTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['สอบกลางภาค', 'สอบปลายภาค'];
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _kTabBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? _kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: _thai(
                      14,
                      FontWeight.w600,
                      i == selectedIndex ? Colors.white : _kMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final _ExamItem exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                exam.date,
                style: _thai(13, FontWeight.w600, _kPrimary),
              ),
              Container(
                width: 120,
                height: 25,
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  exam.timeRange,
                  style: _inter(11, FontWeight.w600, _kPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            exam.code,
            style: _inter(10, FontWeight.w500, _kMuted),
          ),
          const SizedBox(height: 2),
          Text(
            exam.title,
            style: _thai(15, FontWeight.w600, _kInk),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: _kCardBorder),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ห้องสอบ',
                      style: _thai(10, FontWeight.w400, _kMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.room,
                      style: _thai(13, FontWeight.w500, _kInk),
                    ),
                  ],
                ),
              ),
              Container(
                width: 104,
                height: 49,
                decoration: BoxDecoration(
                  color: _kChipBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'เลขที่นั่งสอบ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: _kPrimary,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      exam.seat,
                      style: GoogleFonts.inter(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                        height: 1.25,
                      ),
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
