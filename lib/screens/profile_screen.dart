import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../services/database_service.dart';
import '../widgets/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['ข้อมูลส่วนตัว', 'เกรดสะสม'];

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final user = db.currentUser;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('โปรไฟล์',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Profile header (purple card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kDark, kMain],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(44),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTeacher
                      ? '${user.subtitleInfo} • อาจารย์ประจำภาควิชา'
                      : '${user.subtitleInfo} • ปี ${_yearLevel(user.studentId)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _profileStat(
                        label: 'รหัสนักศึกษา',
                        value: user.studentId ?? 'T-1024',
                      ),
                    ),
                    Expanded(
                      child: _profileStat(
                        label: 'GPA สะสม',
                        value: user.gpax.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/grades'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: kGold),
                      foregroundColor: kGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'ดูรายละเอียดเกรด',
                      style: AppText.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final active = _selectedTab == e.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? kDark : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? kDark : kBorderLight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          e.value,
                          style: AppText.kanit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : kMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: _selectedTab == 0
                ? _buildInfoTab(user, isTeacher, db)
                : _buildGradesTab(db),
          ),
        ],
      ),
    );
  }

  Widget _profileStat({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(AuthenticatedUserSession user,
      bool isTeacher, AppDatabaseProvider db) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ข้อมูลส่วนตัว',
            style: AppText.kanit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kDark,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow('ชื่อ - สกุล', user.displayName),
          _infoRow('รหัสนักศึกษา', user.studentId ?? 'T-1024'),
          _infoRow('อีเมลมหาวิทยาลัย', db.currentUser.email),
          _infoRow('คณะ', 'คณะวิศวกรรมศาสตร์'),
          _infoRow('สาขา', 'วิศวกรรมคอมพิวเตอร์'),
          _infoRow('ปีการศึกษา', _yearLevel(user.studentId)),
          _infoRow('เกรดเฉลี่ยสะสม', user.gpax.toStringAsFixed(2)),
          _infoRow('หน่วยกิตสะสม', '${user.earnedCredits} / ${user.totalCreditsRequired}'),
          const SizedBox(height: 20),
          AppCard(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'การตั้งค่า',
                  style: AppText.kanit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                ),
                const SizedBox(height: 12),
                _settingRow('ภาษา', 'ไทย 🇹🇭', () {}),
                _settingRow('การแจ้งเตือน', 'เปิดใช้งาน', () {
                  Navigator.pushNamed(context, '/notif');
                }),
                _settingRow('ความปลอดภัย', 'เปลี่ยนรหัสผ่าน', () {
                  Navigator.pushNamed(context, '/forgot-password');
                }),
                _settingRow('ออกจากระบบ', '', () async {
                  await DatabaseService.clearSession();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                }, isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppText.kanit(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppText.kanit(
                fontSize: 12,
                color: kDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(String title, String subtitle, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppText.kanit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red.shade700 : kDark,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: AppText.kanit(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: kMid,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildGradesTab(AppDatabaseProvider db) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ประวัติเกรดทั้งหมด',
            style: AppText.kanit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kDark,
            ),
          ),
          const SizedBox(height: 16),
          ...db.studentGrades.map((g) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _gradeColor(g.score).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          g.letter.split(' ').first,
                          style: TextStyle(
                            color: _gradeColor(g.score),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${g.subjectCode} ${g.subjectName}',
                            style: AppText.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'คะแนน ${g.score.toStringAsFixed(1)} / 4.00',
                            style: AppText.kanit(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _gradeColor(double score) {
    if (score >= 3.5) return Colors.green.shade600;
    if (score >= 3.0) return Colors.green.shade500;
    if (score >= 2.5) return Colors.amber.shade600;
    if (score >= 2.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _yearLevel(String? studentId) {
    if (studentId == null || studentId.isEmpty) return '-';
    final year = int.tryParse(studentId.substring(1, 3)) ?? 25;
    final currentYear = 2569; // พ.ศ. ปัจจุบัน
    final entered = 2500 + year;
    final level = currentYear - entered + 1;
    return 'ปี $level';
  }
}


