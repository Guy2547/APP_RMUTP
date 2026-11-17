import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedFilter = 'ทั้งหมด';

  void _openCreateAnnouncementDialog(AppDatabaseProvider db) {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    String selectedType = 'กิจกรรม';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '📢 ลงประกาศข่าวใหม่ลงฐานข้อมูล',
          style: AppText.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: kDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: ['ทุน', 'ฝึกงาน', 'กิจกรรม']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) selectedType = v;
                },
                decoration: const InputDecoration(labelText: 'หมวดหมู่ประกาศ'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'หัวข้อประกาศ'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await db.publishTeacherAnnouncement(
                title: titleCtrl.text.trim(),
                type: selectedType,
                detail: detailCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'ลงประกาศใหม่ลงตาราง news_announcements เรียบร้อย ✅',
                    ),
                  ),
                );
              }
            },
            child: const Text('ประกาศ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final filteredNews = _selectedFilter == 'ทั้งหมด'
        ? db.newsList
        : db.newsList.where((n) => n.type == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📢 ข่าว / ทุน / ฝึกงาน'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ทั้งหมด', 'ทุน', 'ฝึกงาน', 'กิจกรรม'].map((cat) {
                  final active = _selectedFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = cat),
                      child: ChipTag(
                        label: cat,
                        backgroundColor: active ? kDark : Colors.white,
                        textColor: active ? Colors.white : kMid,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            ...filteredNews.map((news) {
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
                              backgroundColor: news.type == 'ทุน'
                                  ? Colors.amber.withValues(alpha: 0.1)
                                  : Colors.white,
                              textColor: news.type == 'ทุน'
                                  ? Colors.amber.shade700
                                  : kMid,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          news.title,
                          style: AppText.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          news.detail,
                          style: AppText.kanit(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: news.buttonLabel,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/news-detail'),
                          backgroundColor: kGold,
                          foregroundColor: kDark,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
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
                        'ประกาศทั้งหมดในระบบ: ${db.newsList.length} เรื่อง',
                        style: AppText.kanit(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openCreateAnnouncementDialog(db),
                      child: Text(
                        '+ ลงประกาศใหม่',
                        style: AppText.kanit(fontSize: 11, color: kMid)
                            .copyWith(decoration: TextDecoration.underline),
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
