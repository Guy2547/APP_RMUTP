import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kHomeBg = Color(0xFFEDEDED);
const Color _kHeaderBg = Color(0xFFF8F8F8);
const Color _kBadge = Color(0xFF420671);

class _HomeMenuItem {
  final String label;
  final String route;
  final IconData icon;
  final Color iconColor;
  final Color tileColor;

  const _HomeMenuItem(this.label, this.route, this.icon, this.iconColor, this.tileColor);
}

const List<_HomeMenuItem> _menuItems = [
  _HomeMenuItem('บัตรนักศึกษา', '/profile', Icons.badge_outlined, Colors.white, _kBadge),
  _HomeMenuItem('ผลการเรียน', '/grades', Icons.assignment_outlined, Color(0xFF1F3A5F), Colors.white),
  _HomeMenuItem('ตารางเรียน', '/timetable', Icons.calendar_month_outlined, Color(0xFF2C3E50), Colors.white),
  _HomeMenuItem('ตารางสอบ', '/timetable', Icons.edit_calendar_outlined, Color(0xFF1B6B3A), Colors.white),
  _HomeMenuItem('ข้อความ', '/notif', Icons.mail, Color(0xFF2580C4), Colors.white),
  _HomeMenuItem('ทรานสคริปตท์', '/grades', Icons.description_outlined, Colors.white, Color(0xFF3B2A8C)),
  _HomeMenuItem('เช็คชื่อ', '/attendance', Icons.how_to_reg_outlined, Color(0xFF1E88E5), Color(0xFFFFFBD6)),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kHomeBg,
      appBar: AppBar(
        backgroundColor: _kHeaderBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          color: _kBadge,
          child: Text(
            'RMUTP',
            style: GoogleFonts.abhayaLibre(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
                children: [for (final item in _menuItems) _MenuTile(item: item)],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _HomeMenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 75,
            color: item.tileColor,
            child: Icon(item.icon, size: 40, color: item.iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.kanit(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
