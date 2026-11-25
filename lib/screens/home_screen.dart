import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/role_provider.dart';

const Color _kBg = Color(0xFFEDEDED);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kOnPrimaryMuted = Color(0xFFE5D6F8);
const Color _kChipBg = Color(0xFFF2ECFA);

TextStyle _thai(double size, FontWeight weight, Color color) => GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );

TextStyle _inter(double size, FontWeight weight, Color color) => GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );

class _Shortcut {
  final String label;
  final String route;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final int badge;

  const _Shortcut(
    this.label,
    this.route,
    this.icon,
    this.iconColor, {
    this.iconBg,
    this.badge = 0,
  });
}

const List<_Shortcut> _shortcuts = [
  _Shortcut('ผลการเรียน', '/grades', Icons.fact_check_outlined, Color(0xFF1F3A5F)),
  _Shortcut('ตารางเรียน', '/timetable', Icons.calendar_month_outlined, Color(0xFF2C3E50)),
  _Shortcut('ตารางสอบ', '/exam-schedule', Icons.school_outlined, Color(0xFF1B6B3A)),
  _Shortcut('ข้อความ', '/notif', Icons.mail, Color(0xFF2580C4), badge: 3),
  _Shortcut('ทรานสคริปต์', '/transcript', Icons.description_outlined, Colors.white,
      iconBg: Color(0xFF3B2A8C)),
  _Shortcut('เช็คชื่อ', '/attendance', Icons.how_to_reg_outlined, Color(0xFF1E88E5),
      iconBg: Color(0xFFFFFBD6)),
];

BoxDecoration _cardDecoration(double radius) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    );

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<RoleProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StudentCardShortcut(),
                    const SizedBox(height: 22),
                    Text('บริการนักศึกษา', style: _thai(17, FontWeight.w600, _kInk)),
                    const SizedBox(height: 16),
                    const _ServicesGrid(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('วันนี้ของคุณ', style: _thai(17, FontWeight.w600, _kInk)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pushNamed(context, '/timetable'),
                          child: Text('ดูตารางเรียน', style: _thai(11, FontWeight.w500, _kPrimary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _TodayClassCard(),
                    const SizedBox(height: 20),
                    const _AnnouncementCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('RMUTP', style: _inter(25, FontWeight.w700, _kPrimary)),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('STUDENT PORTAL', style: _inter(8, FontWeight.w600, _kMuted)),
              ),
              const Spacer(),
              Material(
                color: const Color(0xFFF3EDFA),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: SizedBox(
                    width: 80,
                    height: 44,
                    child: Center(
                      child: Text(
                        'ตั้งค่า',
                        style: _thai(14, FontWeight.w600, _kPrimary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 44,
                height: 44,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pushNamed(context, '/notif'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 24, color: _kPrimary),
                      Positioned(
                        left: 28,
                        top: 8,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCardShortcut extends StatelessWidget {
  const _StudentCardShortcut();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 18,
                child: Text('สวัสดี, Theerachut', style: _thai(19, FontWeight.w600, Colors.white)),
              ),
              Positioned(
                left: 20,
                top: 50,
                child: Text('65012345678-9', style: _inter(12, FontWeight.w500, _kOnPrimaryMuted)),
              ),
              Positioned(
                left: 20,
                top: 101,
                child: Row(
                  children: [
                    Text('บัตรนักศึกษา', style: _thai(12, FontWeight.w500, Colors.white)),
                    const SizedBox(width: 21),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.white),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                top: 34,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.badge_outlined, size: 34, color: _kMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < _shortcuts.length; r += 3) ...[
          if (r > 0) const SizedBox(height: 12),
          Row(
            children: [
              for (var c = 0; c < 3; c++) ...[
                if (c > 0) const SizedBox(width: 12),
                Expanded(child: _ServiceTile(item: _shortcuts[r + c])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _Shortcut item;

  const _ServiceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: _cardDecoration(17),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(17),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, item.route),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 15,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(item.icon, size: 26, color: item.iconColor),
                  ),
                ),
              ),
              Positioned(
                left: 4,
                right: 4,
                top: 66,
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _thai(12, FontWeight.w500, _kInk),
                ),
              ),
              if (item.badge > 0)
                Positioned(
                  left: 76,
                  top: 9,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 19),
                    height: 19,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${item.badge}', style: _inter(9, FontWeight.w600, Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayClassCard extends StatelessWidget {
  const _TodayClassCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(18),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/timetable'),
          child: SizedBox(
            height: 106,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 74,
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('09:00 – 12:00',
                                style: _inter(12, FontWeight.w600, _kPrimary)),
                            Container(
                              height: 23,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _kChipBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('กำลังเรียน',
                                  style: _thai(9, FontWeight.w500, _kPrimary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('การเขียนโปรแกรมเชิงวัตถุ',
                            style: _thai(14, FontWeight.w600, _kInk)),
                        const SizedBox(height: 6),
                        Text(
                          'อาคาร 6 ห้อง 604 · อ.ดร. ธนกร วัฒนกุล',
                          style: _thai(10, FontWeight.w400, _kMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: _cardDecoration(18),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/notif'),
          child: Stack(
            children: [
              const Positioned(
                left: 16,
                top: 18,
                child: Icon(Icons.campaign_outlined, size: 20, color: _kPrimary),
              ),
              Positioned(
                left: 48,
                top: 14,
                child: Text('ประกาศล่าสุด', style: _thai(10, FontWeight.w500, _kMuted)),
              ),
              Positioned(
                left: 48,
                top: 34,
                child: Text('เปิดรับสมัครทุนการศึกษา', style: _thai(14, FontWeight.w600, _kInk)),
              ),
              Positioned(
                left: 48,
                top: 60,
                child: Text(
                  'สมัครได้ถึงวันที่ 30 พฤศจิกายนนี้',
                  style: _thai(10, FontWeight.w400, _kMuted),
                ),
              ),
              const Positioned(
                right: 16,
                top: 35,
                child: Icon(Icons.chevron_right, size: 16, color: _kPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
