import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimary = Color(0xFF4A148C);
const Color _kBackground = Color(0xFFF7F6FA);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kFieldBorder = Color(0xFFDED6E8);
const Color _kDivider = Color(0xFFE1DAE8);
const Color _kOutlineButtonBorder = Color(0xFFD6C6E5);
const Color _kButtonBorder = Color(0xFF2C2C2C);

const String _kLogoUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/88755b0baee069ebe2ea06c92a627386d75fcbfa?width=380';

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

  TextStyle _thai(double size, FontWeight weight, Color color) =>
      GoogleFonts.notoSansThai(fontSize: size, fontWeight: weight, color: color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _buildForm(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                _kLogoUrl,
                width: 190,
                height: 190,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 190,
                  height: 190,
                  alignment: Alignment.center,
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
              Text(
                'STUDENT PORTAL',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _kMuted,
                ),
              ),
            ],
          ),
        ),
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
            height: 1.5,
            color: _kInk,
          ),
        ),
        Text(
          'เข้าสู่ระบบบริการนักศึกษา RMUTP',
          style: _thai(13, FontWeight.w400, _kMuted).copyWith(height: 1.5),
        ),
        const SizedBox(height: 18),
        Text('ชื่อผู้ใช้', style: _thai(13, FontWeight.w500, _kInk)),
        const SizedBox(height: 7),
        _field(
          icon: Icons.badge_outlined,
          hint: 'รหัสนักศึกษา',
          controller: _usernameCtrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 22),
        Text('รหัสผ่าน', style: _thai(13, FontWeight.w500, _kInk)),
        const SizedBox(height: 7),
        _field(
          icon: Icons.lock_outline,
          hint: 'รหัสบัตรประชาชน',
          controller: _passwordCtrl,
          obscure: _obscure,
          textInputAction: TextInputAction.done,
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: _kMuted,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('ลืมรหัสผ่าน?', style: _thai(12, FontWeight.w500, Colors.black)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: const Color(0xFFF5F5F5),
              elevation: 0,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _kButtonBorder),
              ),
            ),
            child: Text(
              'เข้าสู่ระบบ',
              style: _thai(15, FontWeight.w600, const Color(0xFFF5F5F5)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider(height: 1, thickness: 1, color: _kDivider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Text('หรือ', style: _thai(11, FontWeight.w400, _kMuted)),
            ),
            const Expanded(child: Divider(height: 1, thickness: 1, color: _kDivider)),
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
              style: _thai(14, FontWeight.w600, _kPrimary),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            'มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร',
            style: _thai(10, FontWeight.w400, _kMuted),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    final style = _thai(14, FontWeight.w400, _kInk);
    return Container(
      height: 54,
      padding: const EdgeInsets.only(left: 16, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kFieldBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
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
          if (suffix != null) suffix else const SizedBox(width: 12),
        ],
      ),
    );
  }
}
