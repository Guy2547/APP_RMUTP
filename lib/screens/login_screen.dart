import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kPrimary = Color(0xFF4F378B);
const Color _kButtonBorder = Color(0xFF2C2C2C);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  TextStyle get _serifBold => GoogleFonts.abhayaLibre(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      );

  TextStyle get _fieldStyle => GoogleFonts.kanit(fontSize: 15, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.network(
                      'https://api.builder.io/api/v1/image/assets/TEMP/5c4c262540af8df43d8ecac948e6eba627f650bf?width=570',
                      width: 285,
                      height: 285,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 180,
                        height: 100,
                        alignment: Alignment.center,
                        color: _kPrimary,
                        child: Text(
                          'RMUTP',
                          style: GoogleFonts.kanit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Log in',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abhayaLibre(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _field(
                    label: 'ชื่อผู้ใช้',
                    hint: 'รหัสนักศึกษา',
                    controller: _usernameCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    label: 'รหัสผ่าน',
                    hint: 'รหัสบัตรประชาชน',
                    controller: _passwordCtrl,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Forget Password', style: _serifBold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 23),
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: const Color(0xFFF5F5F5),
                          elevation: 0,
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: _kButtonBorder),
                          ),
                        ),
                        child: Text(
                          'เข้าสู่ระบบ',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFF5F5F5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Don’t have an Rmutp account?',
                          style: _serifBold.copyWith(color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Create Account', style: _serifBold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          SizedBox(width: 67, child: Text(label, style: _fieldStyle)),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: _fieldStyle,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: _fieldStyle.copyWith(color: Colors.black.withOpacity(0.5)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
