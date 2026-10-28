import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดข่าว'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kDark, kLight],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: const Center(
                      child: ChipTag(
                        label: 'ทุนการศึกษา',
                        backgroundColor: kGold,
                        textColor: kDark,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ทุนเรียนดีคณะวิศวฯ 5,000 บาท',
                          style: AppText.kanit(fontSize: 18, fontWeight: FontWeight.w700, color: kDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'กองพัฒนานักศึกษา • ปิดรับ 30 ก.ย. 2569 • เหลือ 9 วัน',
                          style: AppText.kanit(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          'GPA ≥ 3.00, ไม่ติด F/พักการเรียน',
                          'แนบทรานสคริปต์ + เรียงความ 1 หน้า',
                          'ประกาศผล 15 ต.ค. ที่บอร์ดคณะ',
                        ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 13, color: kMid)),
                              Expanded(
                                child: Text(
                                  item,
                                  style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'สมัครทุนนี้',
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('สมัครทุนเรียบร้อย รอตรวจสอบ 🎉')),
                          ),
                          backgroundColor: kGold,
                          foregroundColor: kDark,
                        ),
                        const SizedBox(height: 8),
                        GhostButton(
                          text: 'แชร์ / บันทึก',
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('แชร์ข่าวไปไลน์กลุ่มแล้ว')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/news',
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

class ChipTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ChipTag({
    super.key,
    required this.label,
    this.backgroundColor = Colors.white,
    this.textColor = kMid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: backgroundColor == Colors.white ? Border.all(color: kBorderLight) : null,
      ),
      child: Text(
        label,
        style: AppText.kanit(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}
