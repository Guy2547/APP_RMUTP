import 'package:flutter/material.dart';
import 'app_theme.dart';

final List<BottomNavItem> kBottomNavItems = [
  BottomNavItem(route: '/home', label: 'หน้าแรก', icon: Icons.home),
  BottomNavItem(route: '/timetable', label: 'ตาราง', icon: Icons.calendar_today),
  BottomNavItem(route: '/grades', label: 'เกรด', icon: Icons.grade),
  BottomNavItem(route: '/requests', label: 'คำร้อง', icon: Icons.description),
  BottomNavItem(route: '/profile', label: 'โปรไฟล์', icon: Icons.person),
];

/// คำนวณ padding ล่างที่เหมาะสมกับ safe area ของอุปกรณ์ (รวม home indicator ของ iPhone)
double bottomPadding(BuildContext context, {double extra = 16.0}) {
  return MediaQuery.of(context).padding.bottom + extra;
}

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
  String? _lastTappedRoute;
  DateTime? _lastTapTime;

  void _onItemTapped(String route) {
    final now = DateTime.now();
    // กันกดซ้ำเร็วเกินไป (ภายใน 500ms) และกันกด route เดิมซ้ำ
    if (_lastTappedRoute == route &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastTappedRoute = route;
    _lastTapTime = now;
    widget.onTap?.call(route);
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
                        color: active ? kDark : const Color(0xFF9A93AD),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: AppText.kanit(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? kDark : const Color(0xFF9A93AD),
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
