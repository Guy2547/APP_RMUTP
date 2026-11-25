import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimary = Color(0xFF4A148C);
const Color _kScreenBg = Color(0xFFF7F6FA);
const Color _kTint = Color(0xFFF2ECFA);
const Color _kBorder = Color(0xFFD9D9D9);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kFieldText = Color(0xFF1E1E1E);
const Color _kPlaceholder = Color(0xFFB3B3B3);
const Color _kSubtle = Color(0xFF303030);
const Color _kOnBrand = Color(0xFFF5F5F5);

TextStyle _thai(double size, FontWeight weight, Color color, {double? height}) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านแล้ว', style: _thai(14, FontWeight.w400, Colors.white))),
    );
    Navigator.pop(context);
  }

  void _back() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kScreenBg,
      appBar: AppBar(
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
              onTap: _back,
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
        title: Text('กู้คืนรหัสผ่าน', style: _thai(21, FontWeight.w600, _kInk)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    _buildIntro(),
                    const SizedBox(height: 30),
                    _buildForm(),
                    const SizedBox(height: 34),
                    _buildGuidance(),
                    const Spacer(),
                    const SizedBox(height: 32),
                    _buildReturnToLogin(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kTint,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: _kPrimary, size: 34),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RMUTP',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary,
                    height: 1.5,
                  ),
                ),
                Text(
                  'STUDENT PORTAL',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _kMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('ลืมรหัสผ่าน?', style: _thai(27, FontWeight.w600, _kInk, height: 1.5)),
        const SizedBox(height: 6),
        Text(
          'กรอกอีเมลที่ลงทะเบียนไว้กับมหาวิทยาลัย\nเพื่อรับลิงก์สำหรับตั้งรหัสผ่านใหม่',
          style: _thai(13, FontWeight.w400, _kMuted, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('อีเมลที่ลงทะเบียน', style: _thai(14, FontWeight.w400, _kFieldText, height: 1.4)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _reset(),
            cursorColor: _kPrimary,
            style: _thai(14, FontWeight.w400, _kFieldText),
            decoration: InputDecoration(
              hintText: 'กรอกอีเมลของคุณ',
              hintStyle: _thai(14, FontWeight.w400, _kPlaceholder),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: _fieldBorder(_kBorder),
              enabledBorder: _fieldBorder(_kBorder),
              focusedBorder: _fieldBorder(_kPrimary, width: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _back,
                style: TextButton.styleFrom(
                  foregroundColor: _kSubtle,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('ยกเลิก', style: _thai(14, FontWeight.w500, _kSubtle)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: _kOnBrand,
                  elevation: 0,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('ส่งลิงก์รีเซ็ตรหัสผ่าน', style: _thai(14, FontWeight.w600, _kOnBrand)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _buildGuidance() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: _kTint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.info_outline_rounded, color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ไม่พบอีเมลรีเซ็ตรหัสผ่าน?',
                  style: _thai(13, FontWeight.w600, _kPrimary, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'ตรวจสอบโฟลเดอร์สแปมหรืออีเมลขยะ\nหากเข้าใช้อีเมลไม่ได้ กรุณาติดต่อศูนย์ IT',
                  style: _thai(11, FontWeight.w400, _kMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnToLogin() {
    return Column(
      children: [
        Text('จำรหัสผ่านได้แล้ว?', style: _thai(12, FontWeight.w400, _kMuted, height: 1.5)),
        TextButton(
          onPressed: _back,
          style: TextButton.styleFrom(
            foregroundColor: _kPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text('กลับไปเข้าสู่ระบบ', style: _thai(14, FontWeight.w600, _kPrimary, height: 1.5)),
        ),
      ],
    );
  }
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
