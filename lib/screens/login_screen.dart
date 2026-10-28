import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/role_pill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 's650602xxx@rmutp.ac.th');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.network(
                'https://www.rmutp.ac.th/web2561/wp-content/uploads/2018/06/rmutp-logo.png',
                height: 64,
                errorBuilder: (_, __, ___) => Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: kDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ยินดีต้อนรับสู่ RMUTP',
                style: AppText.kanit(fontSize: 22, fontWeight: FontWeight.w800, color: kDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Rajamangala University of Technology Phra Nakhon',
                style: AppText.kanit(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'อีเมลมหาวิทยาลัย'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: kMid),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านแล้ว')),
                  ),
                  child: const Text(
                    'ลืมรหัสผ่าน?',
                    style: TextStyle(color: kMid, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _roleBtn('เข้าใช้: นักศึกษา', AppRole.student, kDark, Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _roleBtn('เข้าใช้: อาจารย์', AppRole.teacher, kGold, kDark),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Demo: กดปุ่มใดก็ได้เพื่อเข้าแอป ไม่ต้องใช้รหัสจริง',
                style: AppText.kanit(fontSize: 11, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RolePill(
                      label: '🎓 นักศึกษา',
                      active: context.watch<RoleProvider>().isStudent,
                      onTap: () {
                        context.read<RoleProvider>().setRole(AppRole.student);
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RolePill(
                      label: '👩‍🏫 อาจารย์',
                      active: context.watch<RoleProvider>().isTeacher,
                      onTap: () {
                        context.read<RoleProvider>().setRole(AppRole.teacher);
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleBtn(String text, AppRole role, Color bgColor, Color textColor) {
    final isActive = context.watch<RoleProvider>().role == role;
    return ElevatedButton(
      onPressed: () {
        context.read<RoleProvider>().setRole(role);
        Navigator.pushNamed(context, '/home');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? bgColor : Colors.white,
        foregroundColor: isActive ? textColor : const Color(0xFF9A93AD),
        side: BorderSide(color: isActive ? bgColor : kBorderLight),
        elevation: 0,
      ),
      child: Text(text),
    );
  }
}
