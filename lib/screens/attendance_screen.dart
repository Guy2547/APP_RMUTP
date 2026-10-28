import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ เช็คชื่อเข้าเรียน'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTeacher) ...[
              AppCard(
                padding: const EdgeInsets.all(20),
                color: kDark,
                child: Column(
                  children: [
                    const Text('◧', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      'ENGCE302 • รหัสห้อง DB-0921',
                      style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ห้องเปิด 09:00–09:15 • เหลือ 07:32 นาที',
                      style: AppText.kanit(fontSize: 11, color: Colors.purple.shade200),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: 'กดเช็คชื่อ / สแกน QR',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('เช็คชื่อสำเร็จ 09:03 ✅')),
                      ),
                      backgroundColor: kDark,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'ประวัติสัปดาห์นี้: มา 4 • สาย 1 • ขาด 0 (92%)',
                  style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ] else ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👩‍🏫 เปิดห้องเช็คชื่อ — ENGCE302 Sec.1',
                      style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: '+ เปิดห้อง',
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('เปิดห้องแล้ว รหัส DB-0921')),
                            ),
                            backgroundColor: kGold,
                            foregroundColor: kDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GhostButton(
                            text: 'ปิดห้อง',
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ปิดรับเช็คชื่อแล้ว')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'มาแล้ว 28/40',
                          style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 10),
                    ...[
                      '✅ 650602001 มินตรา 09:03',
                      '✅ 650602002 ภูริ 09:04',
                    ].map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(s, style: AppText.kanit(fontSize: 11, color: Colors.grey.shade700)),
                    )),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '⏳ 650602003 — ยังไม่มา',
                            style: AppText.kanit(fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ส่งเตือนไลน์หานักศึกษาแล้ว')),
                          ),
                          child: Text(
                            'เตือน',
                            style: AppText.kanit(fontSize: 11, color: kMid).copyWith(decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/attendance',
        onTap: (route) => Navigator.pushNamed(context, route),
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
