import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _handleSignIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลมหาวิทยาลัยและรหัสผ่าน')),
      );
      return;
    }

    final dbProvider = context.read<AppDatabaseProvider>();
    final session = await dbProvider.loginWithCredentials(email, pass);

    if (!mounted) return;

    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(dbProvider.lastError ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'),
        ),
      );
      return;
    }

    context.read<RoleProvider>().setRole(
      session.isTeacher ? AppRole.teacher : AppRole.student,
    );
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<AppDatabaseProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // โลโก้ RMUTP + หัวข้อ (อยู่กลางด้านบน)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'lib/assets/images/rmutp_logo.jpg',
                      height: 56,
                      errorBuilder: (_, __, ___) => Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: kDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'RMUTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'STUDENT PORTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เข้าสู่มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร RMUTP',
                      style: AppText.kanit(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // อีเมล
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'อีเมล',
                  style: AppText.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 's650602xxx@rmutp.ac.th',
                  prefixIcon: const Icon(Icons.email_outlined, color: kMid, size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: kDark, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // รหัสผ่าน
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'รหัสผ่าน',
                  style: AppText.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'กรุณากรอกรหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock_outline, color: kMid, size: 22),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: kMid,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kDark, width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: Text(
                          'ลืมรหัสผ่าน?',
                          style: AppText.kanit(
                            fontSize: 12,
                            color: kMid,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ปุ่มเข้าสู่ระบบ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: dbProvider.isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: dbProvider.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'เข้าสู่ระบบ',
                          style: AppText.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // ลืมรหัสผ่าน + เข้าสู่บัญชี RMUTP (แถวเดียว)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ลืมรหัสผ่าน? ',
                    style: AppText.kanit(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text(
                      'เข้าสู่บัญชี RMUTP',
                      style: AppText.kanit(
                        fontSize: 13,
                        color: kDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ข้อความล่าง
              Text(
                'ไม่มีบัญชีผู้ใช้งานในระบบของมหาวิทยาลัย',
                style: AppText.kanit(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
