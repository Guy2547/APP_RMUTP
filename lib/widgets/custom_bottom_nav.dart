import 'package:flutter/material.dart';
import 'app_theme.dart';

final List<BottomNavItem> kBottomNavItems = [
  BottomNavItem(route: '/home', label: 'หน้าแรก', icon: Icons.home),
  BottomNavItem(route: '/timetable', label: 'ตาราง', icon: Icons.calendar_today),
  BottomNavItem(route: '/courses', label: 'วิชา', icon: Icons.book),
  BottomNavItem(route: '/news', label: 'ข่าว', icon: Icons.article),
  BottomNavItem(route: '/profile', label: 'ฉัน', icon: Icons.person),
];

class CustomBottomNav extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String>? onTap;

  const CustomBottomNav({
    super.key,
    required this.currentRoute,
    this.onTap,
  });

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
            final active = currentRoute == item.route;
            return Expanded(
              child: GestureDetector(
                onTap: onTap != null ? () => onTap!(item.route) : null,
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
