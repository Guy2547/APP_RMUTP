import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/mock_data.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📢 ข่าว / ทุน / ฝึกงาน'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ChipTag(label: 'ทั้งหมด', backgroundColor: kDark, textColor: Colors.white),
                const SizedBox(width: 6),
                ChipTag(label: 'ทุน', backgroundColor: Colors.white, textColor: kMid),
                const SizedBox(width: 6),
                ChipTag(label: 'ฝึกงาน', backgroundColor: Colors.white, textColor: kMid),
                const SizedBox(width: 6),
                ChipTag(label: 'กิจกรรม', backgroundColor: Colors.white, textColor: kMid),
                if (isTeacher) ...[
                  const SizedBox(width: 6),
                  ChipTag(label: 'ประกาศของฉัน', backgroundColor: Colors.white, textColor: kMid),
                ],
              ],
            ),
            const SizedBox(height: 14),
            ...MockData.newsList.map((news) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  border: Border.all(color: const Color(0xFFE9D27A)),
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/news-detail'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ChipTag(
                              label: news.type,
                              backgroundColor: news.type == 'ทุน' ? Colors.amber.withValues(alpha: 0.1) : Colors.white,
                              textColor: news.type == 'ทุน' ? Colors.amber.shade700 : kMid,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          news.title,
                          style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: kDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          news.detail,
                          style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: news.buttonLabel,
                          onPressed: () => Navigator.pushNamed(context, '/news-detail'),
                          backgroundColor: kGold,
                          foregroundColor: kDark,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            if (isTeacher) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(14),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    const Text('👩‍🏫 ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ประกาศของฉัน: ส่งไปแล้ว 2 • ยอดอ่าน 312',
                        style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('เปิดฟอร์มลงประกาศ (demo)')),
                      ),
                      child: Text(
                        '+ ลงประกาศในวิชา',
                        style: AppText.kanit(fontSize: 11, color: kMid).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
