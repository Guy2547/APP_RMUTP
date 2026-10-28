import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('❓ ช่วยเหลือ / ติดต่อ'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: [
                _contactCard('📞', 'ทะเบียน', '02-665-3777', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('โทร 02-665-3777 (ทะเบียน)')))),
                _contactCard('💻', 'IT Helpdesk', '02-665-3888', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('โทร 02-665-3888 (IT Helpdesk)')))),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คำถามพบบ่อย',
                    style: AppText.kanit(fontSize: 15, fontWeight: FontWeight.w600, color: kDark),
                  ),
                  const SizedBox(height: 10),
                  _faqItem(
                    'ลืมรหัสผ่าน RMUTP Portal ทำยังไง?',
                    'กดลืมรหัสที่ portal.rmutp.ac.th หรือติดต่อสำนักวิทยบริการพร้อมบัตร นศ.',
                  ),
                  _faqItem(
                    'ขอ transcript นานไหม?',
                    'แบบ PDF 1–2 วันทำการ ฉบับจริง 3–5 วัน รับที่งานทะเบียน',
                  ),
                  _faqItem(
                    'ติดต่ออาจารย์ที่ปรึกษา?',
                    'ดูเบอร์โทรและเวลาพบที่หน้าโปรไฟล์อาจารย์ หรือติดต่อผ่านงานทะเบียนภาควิชา',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: '🗺️ แผนที่ศูนย์เทเวศร์ / โชติเวช / พระนครเหนือ',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เปิดแผนที่ 9 ศูนย์ มทร.พระนคร 🗺')),
              ),
              backgroundColor: Colors.white,
              foregroundColor: kDark,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/help',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _contactCard(String emoji, String title, String phone, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w700, color: kDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              phone,
              style: AppText.kanit(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        ExpansionTile(
          title: Text(
            question,
            style: AppText.kanit(fontSize: 12, fontWeight: FontWeight.w600, color: kDark),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          children: [
            Text(
              answer,
              style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
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
