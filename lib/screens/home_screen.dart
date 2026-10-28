import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/subject_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RMUTP Campus'),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notif'),
          ),
        ],
      ),
      body: Consumer<RoleProvider>(
        builder: (context, roleProvider, _) {
          final isTeacher = roleProvider.isTeacher;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(isTeacher),
                const SizedBox(height: 16),
                _buildStatsCards(isTeacher),
                const SizedBox(height: 16),
                _buildCurrentClassCard(context, isTeacher),
                const SizedBox(height: 16),
                _buildShortcutMenu(context, isTeacher),
                const SizedBox(height: 16),
                _buildInfoCard(context, isTeacher),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/home',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isTeacher) {
    return AppCard(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTeacher ? 'สวัสดี 👋 อ.สุรชัย (สอน 2 วิชา • ที่ปรึกษาปี 2)' : 'สวัสดี 👋 น.ส.มินตรา (วิศวกรรมคอมพิวเตอร์ ปี 2)',
            style: AppText.kanit(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            isTeacher ? 'วันนี้สอน 2 วิชา • รอตรวจ 12 ชิ้น' : 'วันนี้เรียน 3 วิชา • งานใกล้ส่ง 2 ชิ้น',
            style: AppText.kanit(fontSize: 17, fontWeight: FontWeight.w600, color: kDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isTeacher) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _statItem(
          isTeacher ? '2' : '3.42',
          isTeacher ? 'วิชาที่สอน' : 'GPA รวม',
          kDark,
          Colors.white,
          kDark,
        ),
        _statItem(
          isTeacher ? '28/40' : '92%',
          isTeacher ? 'มาเรียน' : 'เข้าเรียน',
          kGold,
          kDark,
          Colors.transparent,
        ),
        _statItem(
          isTeacher ? '12' : '2',
          isTeacher ? 'รอตรวจ' : 'งานค้างส่ง',
          Colors.white,
          kMid,
          Colors.white,
          border: true,
        ),
      ],
    );
  }

  Widget _statItem(String value, String label, Color bgColor, Color textColor, Color borderColor, {bool border = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: border ? Colors.white : bgColor,
        borderRadius: BorderRadius.circular(20),
        border: border ? Border.all(color: kBorderLight) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppText.kanit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppText.kanit(fontSize: 10, color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentClassCard(BuildContext context, bool isTeacher) {
    return SubjectCard(
      title: isTeacher ? '👩‍🏫 กำลังสอนตอนนี้' : '⏰ กำลังเรียนตอนนี้',
      subtitle: 'ENGCE302 — ระบบฐานข้อมูล (Sec.1)\n09:00–12:00 • ห้อง 1604 • ${isTeacher ? '' : 'อ.สุรชัย'}',
      leftBorderColor: kMid,
      actions: [
        Expanded(
          child: PrimaryButton(
            text: isTeacher ? 'เปิดห้องเช็คชื่อ' : 'เช็คชื่อ / QR',
            onPressed: () => Navigator.pushNamed(context, '/attendance'),
            backgroundColor: isTeacher ? kGold : kDark,
            foregroundColor: isTeacher ? kDark : Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GhostButton(
            text: 'เข้าไฟล์วิชา',
            onPressed: () => Navigator.pushNamed(context, '/course-detail'),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutMenu(BuildContext context, bool isTeacher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เมนูลัด',
          style: AppText.kanit(fontSize: 15, fontWeight: FontWeight.w600, color: kDark),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: isTeacher ? _teacherShortcuts(context) : _studentShortcuts(context),
        ),
      ],
    );
  }

  List<Widget> _studentShortcuts(BuildContext context) {
    return [
      _shortcutBtn(context, '🗓️', 'ตารางเรียน', '/timetable'),
      _shortcutBtn(context, '📚', 'ส่งงาน', '/courses'),
      _shortcutBtn(context, '🎓', 'เกรด', '/grades'),
      _shortcutBtn(context, '📢', 'ทุน/ฝึกงาน', '/news'),
      _shortcutBtn(context, '✅', 'เช็คชื่อ', '/attendance'),
      _shortcutBtn(context, '🔔', 'แจ้งเตือน', '/notif'),
      _shortcutBtn(context, '🛠️', 'แจ้งเรื่อง', '/requests'),
      _shortcutBtn(context, '❓', 'ช่วยเหลือ', '/help'),
    ];
  }

  List<Widget> _teacherShortcuts(BuildContext context) {
    return [
      _shortcutBtn(context, '🗓️', 'ตารางสอน', '/timetable'),
      _shortcutBtn(context, '📝', 'ตรวจงาน', '/grade-submit'),
      _shortcutBtn(context, '🎓', 'ส่งเกรด', '/grade-submit'),
      _shortcutBtn(context, '📢', 'ประกาศ', '/news'),
      _shortcutBtn(context, '✅', 'เช็คชื่อ', '/attendance'),
      _shortcutBtn(context, '🔔', 'แจ้งเตือน', '/notif'),
      _shortcutBtn(context, '📥', 'อนุมัติ', '/requests'),
      _shortcutBtn(context, '❓', 'ช่วยเหลือ', '/help'),
    ];
  }

  Widget _shortcutBtn(BuildContext context, String emoji, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: AppCard(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.kanit(fontSize: 10, fontWeight: FontWeight.w600, color: kDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isTeacher) {
    return AppCard(
      border: Border.all(color: const Color(0xFFE9D27A)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTeacher ? '📝 งานรอตรวจ 12 ชิ้น' : '⭐ ทุนแนะนำสำหรับคุณ',
            style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: kDark),
          ),
          const SizedBox(height: 6),
          Text(
            isTeacher
                ? 'ENGCE302 HW6 รอตรวจ 8 • ENGCE305 Lab6 รอตรวจ 4 — ตัดเกรดภายใน 30 ก.ย.'
                : 'ทุนเรียนดี คณะวิศวฯ 5,000 บาท • ปิดรับ 30 ก.ย. — เกรดคุณผ่านเกณฑ์ กดสมัครในหน้าข่าวได้เลย',
            style: AppText.kanit(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            text: isTeacher ? 'ไปตรวจ+ส่งเกรด' : 'ดูรายละเอียด',
            onPressed: () => Navigator.pushNamed(context, isTeacher ? '/grade-submit' : '/news'),
            backgroundColor: kGold,
            foregroundColor: kDark,
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? kDark,
        foregroundColor: foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(text),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GhostButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: kMid),
        foregroundColor: kMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(text),
    );
  }
}
