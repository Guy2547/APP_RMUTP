import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class NotifScreen extends StatelessWidget {
  const NotifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 แจ้งเตือน + ปฏิทิน'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...MockData.notifications.map((n) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  border: Border(left: BorderSide(color: n.accentColor, width: 4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: kDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.subtitle,
                        style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Text(
              '📅 ปฏิทินวิชาการ',
              style: AppText.kanit(fontSize: 15, fontWeight: FontWeight.w600, color: kDark),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: MockData.academicCalendar.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(item, style: AppText.kanit(fontSize: 12, color: Colors.grey.shade700)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/notif',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }
}
