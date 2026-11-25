import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kOnPrimaryMuted = Color(0xFFE5D6F8);
const Color _kStatusPillBg = Color(0xFF69379F);
const Color _kCardBorder = Color(0xFFEEE9F3);
const Color _kTrackBg = Color(0xFFE8E3EE);
const Color _kLateBar = Color(0xFFB79ACF);
const Color _kPresentPillBg = Color(0xFFF2ECFA);
const Color _kLatePillBg = Color(0xFFF4EFF8);
const Color _kLatePillText = Color(0xFF795990);
const Color _kAbsentPillBg = Color(0xFFF2F1F4);
const Color _kAbsentPillText = Color(0xFF645C6E);

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

class _CourseAttendance {
  final String title;
  final int present;
  final int late;
  final int absent;

  const _CourseAttendance({
    required this.title,
    required this.present,
    required this.late,
    required this.absent,
  });

  int get total => present + late + absent;
  int get attended => present + late;
  int get percent => ((attended / total) * 100).round();
}

const List<_CourseAttendance> _attendanceHistory = [
  _CourseAttendance(
    title: 'การเขียนโปรแกรมเชิงวัตถุ',
    present: 12,
    late: 2,
    absent: 1,
  ),
  _CourseAttendance(
    title: 'ระบบฐานข้อมูล',
    present: 13,
    late: 1,
    absent: 1,
  ),
  _CourseAttendance(
    title: 'วิศวกรรมซอฟต์แวร์',
    present: 11,
    late: 1,
    absent: 3,
  ),
];

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _checkedIn = false;

  void _handleScanCheckIn() {
    setState(() => _checkedIn = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'เช็คชื่อเข้าเรียนวิชา 040203201 เรียบร้อยแล้ว',
          style: _thai(13, FontWeight.w400, Colors.white),
        ),
        backgroundColor: _kPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'เช็คชื่อ'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CheckInHeroCard(
                checkedIn: _checkedIn,
                onScanTap: _handleScanCheckIn,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'ประวัติการเข้าเรียน',
                    style: _thai(17, FontWeight.w600, _kInk),
                  ),
                  Text(
                    'ภาคเรียน 1/2569',
                    style: _thai(10, FontWeight.w400, _kMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < _attendanceHistory.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _AttendanceHistoryCard(record: _attendanceHistory[i]),
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

class _CheckInHeroCard extends StatelessWidget {
  final bool checkedIn;
  final VoidCallback onScanTap;

  const _CheckInHeroCard({
    required this.checkedIn,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
                'เช็คชื่อเข้าเรียนตอนนี้',
                style: _thai(18, FontWeight.w600, Colors.white),
              ),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: _kStatusPillBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  checkedIn ? 'เช็คชื่อแล้ว' : 'เปิดเช็คชื่อ',
                  style: _thai(10, FontWeight.w500, Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '09:00 – 12:00',
            style: _inter(12, FontWeight.w500, _kOnPrimaryMuted),
          ),
          const SizedBox(height: 9),
          Text(
            'การเขียนโปรแกรมเชิงวัตถุ',
            style: _thai(17, FontWeight.w600, Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '040203201 · อาคาร 6 ห้อง 604',
            style: _thai(11, FontWeight.w400, _kOnPrimaryMuted),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.where_to_vote_outlined,
                size: 17,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GPS ยืนยันแล้ว · อยู่ในพื้นที่ห้องเรียน',
                  style: _thai(11, FontWeight.w500, Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onScanTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _kPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    checkedIn
                        ? Icons.check_circle_outline_rounded
                        : Icons.qr_code_scanner_rounded,
                    size: 22,
                    color: _kPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    checkedIn
                        ? 'เช็คชื่อเข้าเรียนเรียบร้อยแล้ว'
                        : 'สแกน QR Code เพื่อเช็คชื่อ',
                    style: _thai(14, FontWeight.w600, _kPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  final _CourseAttendance record;

  const _AttendanceHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 11, 15, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.title,
            style: _thai(14, FontWeight.w600, _kInk),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'รวมมาเรียนและสาย ${record.attended}/${record.total} ครั้ง',
                style: _thai(10, FontWeight.w400, _kMuted),
              ),
              Text(
                '${record.percent}%',
                style: _inter(12, FontWeight.w600, _kPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: _kTrackBg,
              borderRadius: BorderRadius.circular(3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                if (record.present > 0)
                  Expanded(
                    flex: record.present,
                    child: Container(color: _kPrimary),
                  ),
                if (record.late > 0)
                  Expanded(
                    flex: record.late,
                    child: Container(color: _kLateBar),
                  ),
                if (record.absent > 0)
                  Expanded(
                    flex: record.absent,
                    child: const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'มาเรียน ${record.present}',
                  bgColor: _kPresentPillBg,
                  textColor: _kPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatPill(
                  label: 'สาย ${record.late}',
                  bgColor: _kLatePillBg,
                  textColor: _kLatePillText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatPill(
                  label: 'ขาดเรียน ${record.absent}',
                  bgColor: _kAbsentPillBg,
                  textColor: _kAbsentPillText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatPill({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: _thai(10, FontWeight.w500, textColor),
      ),
    );
  }
}
