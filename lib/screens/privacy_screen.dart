import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kNoticeBg = Color(0xFFF1EBF9);

TextStyle _thai(
  double size,
  FontWeight weight,
  Color color, {
  double? lineHeight,
}) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: lineHeight != null ? lineHeight / size : 1.45,
    );

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ความเป็นส่วนตัว'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข้อมูลของคุณสำคัญ',
                    style: _thai(22, FontWeight.w600, _kInk, lineHeight: 35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'แนวทางความเป็นส่วนตัวของ Student Portal',
                    style: _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kNoticeBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เนื้อหาตัวอย่างสำหรับต้นแบบ',
                      style:
                          _thai(14, FontWeight.w600, _kPrimary, lineHeight: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'หน้านี้ไม่ใช่นโยบายฉบับทางการ โปรดตรวจสอบประกาศของมหาวิทยาลัยก่อนใช้งานจริง',
                      style:
                          _thai(13, FontWeight.w400, _kPrimary, lineHeight: 21),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _PrivacyItem(
                      title: 'ข้อมูลที่เกี่ยวข้อง',
                      description:
                          'ข้อมูลบัญชีนักศึกษา ข้อมูลการเรียน และการตั้งค่าการใช้งาน',
                    ),
                    SizedBox(height: 18),
                    _PrivacyItem(
                      title: 'วัตถุประสงค์การใช้งาน',
                      description:
                          'เพื่อแสดงบริการนักศึกษาและอำนวยความสะดวกในการใช้งานพอร์ทัล',
                    ),
                    SizedBox(height: 18),
                    _PrivacyItem(
                      title: 'การดูแลข้อมูลของคุณ',
                      description:
                          'ไม่เปิดเผยรหัสผ่าน และออกจากระบบเมื่อใช้งานอุปกรณ์ส่วนรวม',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/help'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'ไปที่ศูนย์ช่วยเหลือ',
                    style: _thai(15, FontWeight.w600, Colors.white,
                        lineHeight: 24),
                  ),
                ),
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

class _PrivacyItem extends StatelessWidget {
  final String title;
  final String description;

  const _PrivacyItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _thai(15, FontWeight.w600, _kInk, lineHeight: 24),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
        ),
      ],
    );
  }
}
