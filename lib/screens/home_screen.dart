import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../services/database_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart' show CustomBottomNav, kBottomNavHeight;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabaseProvider>();
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final user = db.currentUser;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('RMUTP STUDENT PORTAL',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: kDark),
            onPressed: () => Navigator.pushNamed(context, '/notif'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavHeight + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header (purple card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kDark, kMain],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              user.subtitleInfo,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: kDark, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _statChip(
                          label: 'GPA สะสม',
                          value: user.gpax.toStringAsFixed(2),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statChip(
                          label: 'หน่วยกิต',
                          value: '${user.earnedCredits}/${user.totalCreditsRequired}',
                          color: kGold.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick stats grid
            _buildStatsGrid(db, isTeacher, user),
            const SizedBox(height: 20),

            // Current class card
            _buildCurrentClassCard(context, db, isTeacher),
            const SizedBox(height: 20),

            // Timetable for today
            _buildTodaysTimetable(db, isTeacher),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/home',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppDatabaseProvider db, bool isTeacher,
      AuthenticatedUserSession user) {
    final pendingHw = db.studentTimetable.fold<int>(
      0,
      (sum, item) => sum + item.pendingAssignments,
    );
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _statCard(
          title: isTeacher ? 'วิชาที่สอน' : 'GPA เทอมนี้',
          value: isTeacher
              ? '${db.teacherTimetable.length}'
              : user.currentTermGpa.toStringAsFixed(2),
          icon: Icons.analytics,
          color: kDark,
        ),
        _statCard(
          title: isTeacher ? 'นศ.ในห้องวันนี้' : 'เข้าเรียน',
          value: isTeacher
              ? '${db.attendanceRecords.length} คน'
              : '${db.presentAttendanceCount}/${db.attendanceRecords.length}',
          icon: Icons.check_circle,
          color: kGold,
        ),
        _statCard(
          title: isTeacher ? 'รอส่งเกรด' : 'งานค้างส่ง',
          value: isTeacher
              ? '${db.teacherGradeRows.where((r) => r.status != 'ส่งแล้ว').length}'
              : '$pendingHw',
          icon: Icons.assignment_late,
          color: Colors.orange.shade700,
        ),
        _statCard(
          title: 'ทุน / กิจกรรม',
          value: '3 รายการ',
          icon: Icons.card_membership,
          color: kMid,
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppText.kanit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppText.kanit(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentClassCard(
    BuildContext context,
    AppDatabaseProvider db,
    bool isTeacher,
  ) {
    final firstSub = isTeacher
        ? (db.teacherTimetable.isNotEmpty ? db.teacherTimetable.first : null)
        : (db.studentTimetable.isNotEmpty ? db.studentTimetable.first : null);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AppCard(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTeacher ? '👩‍🏫 กำลังสอนตอนนี้' : '⏰ กำลังเรียนตอนนี้',
                      style: AppText.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kDark,
                      ),
                    ),
                    if (firstSub != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          firstSub.status,
                          style: AppText.kanit(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (firstSub != null) ...[
                  Text(
                    firstSub.displayName,
                    style: AppText.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${firstSub.time} • ${firstSub.room} • ${firstSub.teacher}',
                    style: AppText.kanit(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ] else ...[
                  Text(
                    'ENGCE302 — ระบบฐานข้อมูล (Sec.1)',
                    style: AppText.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '09:00–12:00 • ห้อง 1604 • อ.สุรชัย',
                    style: AppText.kanit(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTeacher ? kGold : kDark,
                      foregroundColor: isTeacher ? kDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isTeacher ? 'เปิดห้องเช็คชื่อ' : 'เช็คชื่อ / สแกน QR',
                      style: AppText.kanit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppCard(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'แจ้งเตือนล่าสุด',
                  style: AppText.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...db.notifications.take(3).map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: n.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: AppText.kanit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                n.subtitle,
                                style: AppText.kanit(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysTimetable(AppDatabaseProvider db, bool isTeacher) {
    final items = isTeacher ? db.teacherTimetable : db.studentTimetable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ตารางเรียนประจำวัน',
              style: AppText.kanit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kDark,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/timetable'),
              child: Text(
                'ดูทั้งหมด',
                style: AppText.kanit(
                  fontSize: 12,
                  color: kMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          AppCard(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ไม่มีวิชาในวันนี้',
                    style: AppText.kanit(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...items.take(3).map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          item.time.split('–').first,
                          style: AppText.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: kDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.displayName,
                            style: AppText.kanit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.room} • ${item.teacher}',
                            style: AppText.kanit(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.progress > 0)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: item.progress / 100,
                              strokeWidth: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(kMid),
                            ),
                            Text(
                              '${item.progress}%',
                              style: AppText.kanit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: kDark,
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
    );
  }
}


