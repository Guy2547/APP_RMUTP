import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kInputBg = Color(0xFFF9F8FC);
const Color _kInputBorder = Color(0xFFE3D5EE);
const Color _kNoteBg = Color(0xFFF1EBF9);

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

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleSavePreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'บันทึกรหัสผ่านใหม่เรียบร้อยแล้ว (ตัวอย่าง)',
          style: _thai(13, FontWeight.w400, Colors.white),
        ),
        backgroundColor: _kPrimary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'เปลี่ยนรหัสผ่าน'),
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
                    'ตั้งรหัสผ่านใหม่',
                    style: _thai(22, FontWeight.w600, _kInk, lineHeight: 35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ใช้รหัสผ่านที่คาดเดายากและไม่ซ้ำกับบัญชีอื่น',
                    style: _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
                  ),
                ],
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
                  children: [
                    _PasswordField(
                      label: 'รหัสผ่านปัจจุบัน',
                      hint: 'กรอกรหัสผ่านปัจจุบัน',
                      controller: _currentCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    _PasswordField(
                      label: 'รหัสผ่านใหม่',
                      hint: 'กรอกรหัสผ่านใหม่',
                      controller: _newCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    _PasswordField(
                      label: 'ยืนยันรหัสผ่านใหม่',
                      hint: 'กรอกรหัสผ่านใหม่อีกครั้ง',
                      controller: _confirmCtrl,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'แนะนำให้ใช้อักษร ตัวเลข และสัญลักษณ์ร่วมกัน',
                      style:
                          _thai(12, FontWeight.w400, _kMuted, lineHeight: 19),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleSavePreview,
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
                    'บันทึก (ตัวอย่าง)',
                    style: _thai(15, FontWeight.w600, Colors.white,
                        lineHeight: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kNoteBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'หน้าตัวอย่างสำหรับทดสอบการนำทาง\nยังไม่รับหรือบันทึกรหัสผ่านจริง',
                  style: _thai(12, FontWeight.w400, _kPrimary, lineHeight: 19),
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

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputAction textInputAction;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _thai(14, FontWeight.w500, _kInk, lineHeight: 22),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          textInputAction: textInputAction,
          cursorColor: _kPrimary,
          style: _thai(13, FontWeight.w400, _kInk, lineHeight: 21),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
            filled: true,
            fillColor: _kInputBg,
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kInputBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kInputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
