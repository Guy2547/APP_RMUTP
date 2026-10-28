import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              color: kDark,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        isTeacher ? 'ส' : 'ม',
                        style: AppText.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: kDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isTeacher ? 'อ.สุรชัย วงศ์ใหญ่' : 'น.ส.มินตรา ใจดี',
                    style: AppText.kanit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTeacher ? 'T-1024 • ภาควิชาวิศวกรรมคอมพิวเตอร์' : '650602001 • วิศวกรรมคอมพิวเตอร์ ปี 2',
                    style: AppText.kanit(fontSize: 12, color: Colors.purple.shade200),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _profileRow('👤', 'ข้อมูลส่วนตัว', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เปิดข้อมูลส่วนตัว (demo)')))),
                  _profileRow('🌐', 'ภาษา / Language', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ภาษา: ไทย ✓')))),
                  _profileRow('🔔', 'การแจ้งเตือน', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เปิด/ปิดแจ้งเตือนแล้ว')))),
                  _profileRow('🚪', 'ออกจากระบบ', () => Navigator.pushNamed(context, '/login'), textColor: Colors.red.shade600),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'RMUTP Campus App v0.1 • UI Prototype เพื่อการศึกษา • สีตาม rmutp.ac.th',
              style: AppText.kanit(fontSize: 10, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/profile',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _profileRow(String emoji, String label, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: textColor ?? kDark),
      ),
      trailing: const Icon(Icons.chevron_right, color: kMid),
      onTap: onTap,
    );
  }
}
