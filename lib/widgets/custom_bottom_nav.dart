import 'package:flutter/material.dart';
import 'app_theme.dart';

final List<BottomNavItem> kBottomNavItems = [
  BottomNavItem(route: '/home', label: 'หน้าแรก', icon: Icons.home),
  BottomNavItem(route: '/timetable', label: 'ตาราง', icon: Icons.calendar_today),
  BottomNavItem(route: '/grades', label: 'เกรด', icon: Icons.grade),
  BottomNavItem(route: '/requests', label: 'คำร้อง', icon: Icons.description),
  BottomNavItem(route: '/profile', label: 'โปรไฟล์', icon: Icons.person),
];

class CustomBottomNav extends StatefulWidget {
  final String currentRoute;
  final ValueChanged<String>? onTap;

  const CustomBottomNav({
    super.key,
    required this.currentRoute,
    this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  bool _isNavigating = false;

  void _onItemTapped(String route) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    widget.onTap?.call(route);
    // ปลดล็อคหลังจาก 600 มิลลิวินาที เพื่อป้องกันการกดซ้ำเร็วเกินไป
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kBorderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: kBottomNavItems.map((item) {
            final active = widget.currentRoute == item.route;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(item.route),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFEFE7FB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: _isNavigating
                            ? Colors.grey.shade400
                            : (active ? kDark : const Color(0xFF9A93AD)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: AppText.kanit(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: _isNavigating
                              ? Colors.grey.shade400
                              : (active ? kDark : const Color(0xFF9A93AD)),
                        ),
                      ),
                      if (active)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: kGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// ความสูงของแถบนำทางด้านล่าง รวมเซฟเอเรีย สำหรับเว้นพื้นที่ล่างของจอ
const double kBottomNavHeight = 80.0;
