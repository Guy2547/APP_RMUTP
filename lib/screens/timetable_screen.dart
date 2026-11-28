import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kChipBg = Color(0xFFF2ECFA);
const Color _kConnector = Color(0xFFE5DCEC);
const Color _kActiveCardBorder = Color(0xFFD7C3EC);
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

class _ClassSlot {
  final String timeRange;
  final int hours;
  final String code;
  final String title;
  final String location;
  final String instructor;

  const _ClassSlot({
    required this.timeRange,
    required this.hours,
    required this.code,
    required this.title,
    required this.location,
    required this.instructor,
  });
}

class _DaySchedule {
  final String shortEn;
  final String fullTh;
  final List<_ClassSlot> classes;

  const _DaySchedule({
    required this.shortEn,
    required this.fullTh,
    required this.classes,
  });

  int get totalHours => classes.fold<int>(0, (sum, c) => sum + c.hours);
}

const List<_DaySchedule> _weeklySchedule = [
  _DaySchedule(
    shortEn: 'Mon',
    fullTh: 'วันจันทร์',
    classes: [
      _ClassSlot(
        timeRange: '09:00 – 12:00',
        hours: 3,
        code: '040203201',
        title: 'การเขียนโปรแกรมเชิงวัตถุ',
        location: 'อาคาร 6 ห้อง 604',
        instructor: 'อ.ดร. ธนกร วัฒนกุล',
      ),
      _ClassSlot(
        timeRange: '13:00 – 15:00',
        hours: 2,
        code: '040203202',
        title: 'ระบบฐานข้อมูล',
        location: 'อาคาร 6 ห้อง 602',
        instructor: 'อ. ศิริพร ใจดี',
      ),
      _ClassSlot(
        timeRange: '15:00 – 17:00',
        hours: 2,
        code: '040203205',
        title: 'วิศวกรรมซอฟต์แวร์',
        location: 'อาคาร 5 ห้อง 503',
        instructor: 'อ.ดร. กิตติพงษ์ สุขสวัสดิ์',
      ),
    ],
  ),
  _DaySchedule(
    shortEn: 'Tue',
    fullTh: 'วันอังคาร',
    classes: [
      _ClassSlot(
        timeRange: '09:00 – 12:00',
        hours: 3,
        code: '040203203',
        title: 'เครือข่ายคอมพิวเตอร์',
        location: 'อาคาร 6 ห้อง Lab 601',
        instructor: 'ผศ. นภัส พงศ์ไพศาล',
      ),
      _ClassSlot(
        timeRange: '13:00 – 16:00',
        hours: 3,
        code: '040203204',
        title: 'ระบบปฏิบัติการ',
        location: 'อาคาร 6 ห้อง 605',
        instructor: 'อ. วรพล ชัยชนะ',
      ),
    ],
  ),
  _DaySchedule(
    shortEn: 'Wed',
    fullTh: 'วันพุธ',
    classes: [
      _ClassSlot(
        timeRange: '10:00 – 12:00',
        hours: 2,
        code: '040203202',
        title: 'ปฏิบัติการระบบฐานข้อมูล',
        location: 'อาคาร 6 ห้อง Lab 602',
        instructor: 'อ. ศิริพร ใจดี',
      ),
    ],
  ),
  _DaySchedule(
    shortEn: 'Thu',
    fullTh: 'วันพฤหัสบดี',
    classes: [
      _ClassSlot(
        timeRange: '09:00 – 12:00',
        hours: 3,
        code: '040203205',
        title: 'วิศวกรรมซอฟต์แวร์',
        location: 'อาคาร 5 ห้อง 503',
        instructor: 'อ.ดร. กิตติพงษ์ สุขสวัสดิ์',
      ),
      _ClassSlot(
        timeRange: '13:00 – 15:00',
        hours: 2,
        code: '040203201',
        title: 'ปฏิบัติการเขียนโปรแกรมเชิงวัตถุ',
        location: 'อาคาร 6 ห้อง Lab 604',
        instructor: 'อ.ดร. ธนกร วัฒนกุล',
      ),
    ],
  ),
  _DaySchedule(
    shortEn: 'Fri',
    fullTh: 'วันศุกร์',
    classes: [
      _ClassSlot(
        timeRange: '09:00 – 12:00',
        hours: 3,
        code: '040203203',
        title: 'เครือข่ายคอมพิวเตอร์',
        location: 'อาคาร 6 ห้อง 603',
        instructor: 'ผศ. นภัส พงศ์ไพศาล',
      ),
    ],
  ),
  _DaySchedule(
    shortEn: 'Sat',
    fullTh: 'วันเสาร์',
    classes: [],
  ),
];

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final day = _weeklySchedule[_selectedDayIndex];

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ตารางเรียน'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                children: [
                  for (int i = 0; i < _weeklySchedule.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _WeekdayPill(
                        label: _weeklySchedule[i].shortEn,
                        selected: i == _selectedDayIndex,
                        onTap: () =>
                            setState(() => _selectedDayIndex = i),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    day.fullTh,
                    style: _thai(18, FontWeight.w600, _kInk),
                  ),
                  Text(
                    '${day.classes.length} วิชา · ${day.totalHours} ชั่วโมง',
                    style: _thai(11, FontWeight.w400, _kMuted),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (day.classes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _kCardBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_available_outlined,
                        size: 36,
                        color: _kMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ไม่มีตารางเรียนในวันนี้',
                        style: _thai(14, FontWeight.w500, _kMuted),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < day.classes.length; i++)
                      _TimelineClassRow(
                        slot: day.classes[i],
                        isFirst: i == 0,
                        isLast: i == day.classes.length - 1,
                      ),
                  ],
                ),
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

class _WeekdayPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WeekdayPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 64,
        decoration: BoxDecoration(
          color: selected ? _kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: _inter(
                13,
                FontWeight.w600,
                selected ? Colors.white : _kMuted,
              ),
            ),
            if (selected) ...[
              const SizedBox(height: 6),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineClassRow extends StatelessWidget {
  final _ClassSlot slot;
  final bool isFirst;
  final bool isLast;

  const _TimelineClassRow({
    required this.slot,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 20, color: _kConnector)
                else
                  const SizedBox(height: 20),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFirst ? _kPrimary : _kBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kPrimary,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: _kConnector),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isFirst ? _kActiveCardBorder : _kCardBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kChipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            slot.timeRange,
                            style: _inter(11, FontWeight.w600, _kPrimary),
                          ),
                        ),
                        Text(
                          '${slot.hours} ชม.',
                          style: _thai(10, FontWeight.w400, _kMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      slot.code,
                      style: _inter(10, FontWeight.w500, _kMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot.title,
                      style: _thai(15, FontWeight.w600, _kInk),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.apartment_outlined,
                          size: 16,
                          color: _kMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            slot.location,
                            style: _thai(12, FontWeight.w400, _kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: _kMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            slot.instructor,
                            style: _thai(12, FontWeight.w400, _kMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
