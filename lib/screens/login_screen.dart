import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimary = Color(0xFF4A148C);
const Color _kBackground = Color(0xFFF7F6FA);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kFieldBorder = Color(0xFFDED6E8);
const Color _kDivider = Color(0xFFE1DAE8);
const Color _kOutlineButtonBorder = Color(0xFFD6C6E5);
const Color _kButtonBorder = Color(0xFF2C2C2C);
const Color _kOnPrimary = Color(0xFFF5F5F5);

const String _kLogoUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/88755b0baee069ebe2ea06c92a627386d75fcbfa?width=380';

// Design frame: 402 x 874. Header is 258 tall, of which 52 is the status bar.
const double _kHeaderBelowStatusBar = 206;
const double _kLogoSize = 190;
const double _kLogoTop = 2;
const double _kCaptionTop = 176;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  TextStyle _thai(double size, FontWeight weight, Color color, double lineHeight) =>
      GoogleFonts.notoSansThai(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: lineHeight / size,
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBackground,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      color: Colors.white,
      height: topInset + _kHeaderBelowStatusBar,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: topInset + _kLogoTop,
            left: 0,
            right: 0,
            child: Center(
              child: Image.network(
                _kLogoUrl,
                width: _kLogoSize,
                height: _kLogoSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => SizedBox(
                  width: _kLogoSize,
                  height: _kLogoSize,
                  child: Center(
                    child: Text(
                      'RMUTP',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _kPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset + _kCaptionTop,
            left: 0,
            right: 0,
            child: Text(
              'STUDENT PORTAL',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _kMuted,
                height: 13.5 / 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Log in',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 42 / 28,
            color: _kInk,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'เข้าสู่ระบบบริการนักศึกษา RMUTP',
          style: _thai(13, FontWeight.w400, _kMuted, 20),
        ),
        const SizedBox(height: 18),
        _label('ชื่อผู้ใช้'),
        const SizedBox(height: 7),
        _field(
          icon: Icons.badge_outlined,
          hint: 'รหัสนักศึกษา',
          controller: _usernameCtrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 21),
        _label('รหัสผ่าน'),
        const SizedBox(height: 7),
        _field(
          icon: Icons.lock_outline,
          hint: 'รหัสบัตรประชาชน',
          controller: _passwordCtrl,
          obscure: _obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            tooltip: _obscure ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: _kMuted,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 18),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              'ลืมรหัสผ่าน?',
              style: _thai(12, FontWeight.w500, Colors.black, 18),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: _kOnPrimary,
              elevation: 0,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _kButtonBorder),
              ),
            ),
            child: Text(
              'เข้าสู่ระบบ',
              style: _thai(15, FontWeight.w600, _kOnPrimary, 22),
            ),
          ),
        ),
        const SizedBox(height: 17),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Container(height: 1, color: _kDivider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Text('หรือ', style: _thai(11, FontWeight.w400, _kMuted, 17)),
            ),
            Expanded(child: Container(height: 1, color: _kDivider)),
          ],
        ),
        const SizedBox(height: 19),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _kPrimary,
              side: const BorderSide(color: _kOutlineButtonBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'เข้าสู่ระบบด้วย RMUTP',
              style: _thai(14, FontWeight.w600, _kPrimary, 21),
            ),
          ),
        ),
        const SizedBox(height: 42),
        Center(
          child: Text(
            'มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร',
            style: _thai(10, FontWeight.w400, _kMuted, 15),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => SizedBox(
        height: 20,
        child: Text(text, style: _thai(13, FontWeight.w500, _kInk, 19.5)),
      );

  Widget _field({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
  }) {
    final style = _thai(14, FontWeight.w400, _kInk, 21);
    return Container(
      height: 54,
      padding: EdgeInsets.only(left: 15, right: suffix != null ? 5 : 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kFieldBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kMuted),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              autofillHints: autofillHints,
              style: style,
              cursorColor: _kPrimary,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: style.copyWith(color: _kMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }
}
