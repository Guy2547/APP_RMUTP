import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);

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

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ศูนย์ช่วยเหลือ'),
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
                    'ให้เราช่วยคุณ',
                    style: _thai(22, FontWeight.w600, _kInk, lineHeight: 35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ทางลัดและคำแนะนำสำหรับการใช้งาน',
                    style: _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _HelpShortcutCard(
                title: 'จัดการรหัสผ่าน',
                subtitle: 'ไปที่หน้าสำหรับเปลี่ยนรหัสผ่าน',
                onTap: () => Navigator.pushNamed(context, '/change-password'),
              ),
              const SizedBox(height: 10),
              _HelpShortcutCard(
                title: 'ดูบัตรนักศึกษา',
                subtitle: 'ตรวจสอบข้อมูลบัญชีและบัตรนักศึกษา',
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              const SizedBox(height: 10),
              _HelpShortcutCard(
                title: 'ดูข้อความแจ้งเตือน',
                subtitle: 'เปิดรายการข้อความแจ้งเตือนทั้งหมด',
                onTap: () => Navigator.pushNamed(context, '/notif'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คำถามที่พบบ่อย',
                      style: _thai(16, FontWeight.w600, _kInk, lineHeight: 26),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ปิดการแจ้งเตือนได้ที่ไหน?',
                      style: _thai(14, FontWeight.w500, _kInk, lineHeight: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'กลับไปหน้าตั้งค่า แล้วแตะสวิตช์ด้านข้าง “การแจ้งเตือน” เพื่อเปิดหรือปิด',
                      style:
                          _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ข้อมูลไม่ถูกต้อง ควรทำอย่างไร?',
                      style: _thai(14, FontWeight.w500, _kInk, lineHeight: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ติดต่อหน่วยงานที่ดูแลข้อมูลนักศึกษาผ่านช่องทางทางการของมหาวิทยาลัย',
                      style:
                          _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
                    ),
                  ],
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

class _HelpShortcutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpShortcutCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: _thai(15, FontWeight.w500, _kPrimary, lineHeight: 24),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: _thai(12, FontWeight.w400, _kMuted, lineHeight: 19),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
