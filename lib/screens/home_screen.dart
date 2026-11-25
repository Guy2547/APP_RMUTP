import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';

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
        title: const Text(
          'RMUTP STUDENT PORTAL',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: kDark),
            onPressed: () => Navigator.pushNamed(context, '/notif'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== Purple Header Card ====================
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
                          value:
                              '${user.earnedCredits}/${user.totalCreditsRequired}',
                          color: kGold.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================== Menu Grid (3 columns x 2 rows) ====================
            _buildMenuGrid(isTeacher),

            const SizedBox(height: 24),

            // ==================== Notifications Section ====================
            _buildNotifications(db),
          ],
        ),
      ),
      // แถบนำทางด้านล่างถูกลบออกแล้วตามที่ร้องขอ
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

  // -------------------- กริดเมนู 3 คอลัมน์ × 2 แถว --------------------
  Widget _buildMenuGrid(bool isTeacher) {
    final List<MenuItem> menus = [
      MenuItem(
        icon: Icons.schedule,
        label: 'ตารางเรียน',
        route: '/timetable',
        color: kDark,
      ),
      MenuItem(
        icon: Icons.grade,
        label: 'เกรด',
        route: '/grades',
        color: kGold,
      ),
      MenuItem(
        icon: Icons.payment,
        label: 'การเงิน',
        route: '/profile',
        color: kMid,
      ),
      MenuItem(
        icon: Icons.article,
        label: 'ข่าวสาร',
        route: '/news',
        color: Colors.blue.shade700,
      ),
      MenuItem(
        icon: Icons.description,
        label: 'คำร้อง',
        route: '/requests',
        color: Colors.green.shade700,
      ),
      MenuItem(
        icon: Icons.person,
        label: 'โปรไฟล์',
        route: '/profile',
        color: Colors.purple.shade700,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เมนูลัด',
          style: AppText.kanit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final menu = menus[index];
            return _menuCard(menu);
          },
        ),
      ],
    );
  }

  Widget _menuCard(MenuItem menu) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, menu.route),
      child: AppCard(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: menu.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(menu.icon, color: menu.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              menu.label,
              style: AppText.kanit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- ส่วนแจ้งเตือน --------------------
  Widget _buildNotifications(AppDatabaseProvider db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'แจ้งเตือน',
              style: AppText.kanit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kDark,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/notif'),
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
        ...db.notifications.take(3).map((n) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: n.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: AppText.kanit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          n.subtitle,
                          style: AppText.kanit(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: kBorderLight,
                    size: 20,
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

class MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}
