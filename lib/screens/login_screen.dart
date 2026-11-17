import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../services/database_config.dart';
import '../widgets/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 's650602001@rmutp.ac.th');
  final _passCtrl = TextEditingController(text: 'password123');
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
          content: Text(
            dbProvider.lastError ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
          ),
        ),
      );
      return;
    }

    context.read<RoleProvider>().setRole(
      session.isTeacher ? AppRole.teacher : AppRole.student,
    );
    Navigator.pushNamed(context, '/home');
  }

  void _openDatabaseSettingsDialog() {
    final dbProvider = context.read<AppDatabaseProvider>();
    final supaUrlCtrl = TextEditingController(
      text: DatabaseConfig.customSupabaseUrl,
    );
    final supaKeyCtrl = TextEditingController(
      text: DatabaseConfig.customSupabaseAnonKey,
    );
    final uniUrlCtrl = TextEditingController(
      text: DatabaseConfig.customUniversityApiUrl,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '⚙️ ตั้งค่าการเชื่อมต่อฐานข้อมูล',
          style: AppText.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: kDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ระบบที่ 1: Supabase Cloud API',
                style: AppText.kanit(fontSize: 12, fontWeight: FontWeight.w600, color: kMid),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: supaUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supabase Project URL',
                  hintText: 'https://xxxx.supabase.co',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: supaKeyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supabase Anon Key',
                  hintText: 'eyJhbGciOiJIUzI1NiIs...',
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'ระบบที่ 2: University SQL Server (Express API)',
                style: AppText.kanit(fontSize: 12, fontWeight: FontWeight.w600, color: kMid),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: uniUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'University Express API URL',
                  hintText: 'http://localhost:4000/api',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              await dbProvider.updateConnectionConfig(
                supabaseUrl: supaUrlCtrl.text,
                supabaseAnonKey: supaKeyCtrl.text,
                universityApiUrl: uniUrlCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<AppDatabaseProvider>();
    final isSupaMode =
        dbProvider.backendMode == DatabaseBackendMode.supabaseCloud;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: kDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school, color: kGold, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'ยินดีต้อนรับสู่ RMUTP',
                style: AppText.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rajamangala University of Technology Phra Nakhon',
                style: AppText.kanit(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 18),

              // แถบสลับโหมดฐานข้อมูล 2 ระบบ (Supabase Cloud API <-> University SQL Server)
              AppCard(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🗄️ ระบบฐานข้อมูล: ${dbProvider.backendModeLabel}',
                          style: AppText.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kDark,
                          ),
                        ),
                        InkWell(
                          onTap: _openDatabaseSettingsDialog,
                          child: const Icon(Icons.settings, size: 16, color: kMid),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _modeButton(
                            label: '☁️ Supabase Cloud',
                            selected: isSupaMode,
                            onTap: () => dbProvider.setBackendMode(
                              DatabaseBackendMode.supabaseCloud,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _modeButton(
                            label: '🏛️ University SQL',
                            selected: !isSupaMode,
                            onTap: () => dbProvider.setBackendMode(
                              DatabaseBackendMode.universitySqlServer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'อีเมลมหาวิทยาลัย (@rmutp.ac.th)',
                  prefixIcon: Icon(Icons.alternate_email, size: 18, color: kMid),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18, color: kMid),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: kMid,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ส่งคำขอรีเซ็ตรหัสผ่านไปยังอีเมลมหาวิทยาลัยแล้ว'),
                    ),
                  ),
                  child: const Text(
                    'ลืมรหัสผ่าน?',
                    style: TextStyle(color: kMid, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: dbProvider.isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: dbProvider.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'เข้าสู่ระบบ',
                          style: AppText.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 บัญชีผู้ใช้ในฐานข้อมูล (รหัสผ่าน: password123):',
                      style: AppText.kanit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• นักศึกษา: s650602001@rmutp.ac.th (น.ส.มินตรา ใจดี)\n'
                      '• นักศึกษา: s650602002@rmutp.ac.th (นายภูริ พัฒนากุล)\n'
                      '• อาจารย์: surachai.w@rmutp.ac.th (อ.สุรชัย วงศ์ใหญ่)',
                      style: AppText.kanit(fontSize: 11, color: Colors.grey.shade700),
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

  Widget _modeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? kDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? kDark : kBorderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.kanit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
