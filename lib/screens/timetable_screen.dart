import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../services/mock_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _day = 'mon';

  final Map<String, String> dayLabels = {
    'mon': 'จันทร์',
    'tue': 'อังคาร',
    'wed': 'พุธ',
    'thu': 'พฤหัส',
    'fri': 'ศุกร์',
  };

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;
    final items = isTeacher ? MockData.timetableTeacher : MockData.timetableStudent;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? '🗓️ ตารางสอน — เทอม 1/2569' : '🗓️ ตารางเรียน — เทอม 1/2569'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['mon', 'tue', 'wed', 'thu', 'fri'].map((d) {
                final active = _day == d;
                return GestureDetector(
                  onTap: () => setState(() => _day = d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? kDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? kDark : kBorderLight),
                    ),
                    child: Center(
                      child: Text(
                        dayLabels[d]!,
                        style: AppText.kanit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : kMid,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    border: item.leftBorderColor != null
                        ? Border(left: BorderSide(color: item.leftBorderColor!, width: 6))
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.displayName,
                              style: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w600, color: kDark),
                            ),
                            if (item.status.isNotEmpty)
                              ChipTag(
                                label: item.status,
                                backgroundColor: Colors.green.withValues(alpha: 0.1),
                                textColor: Colors.green.shade700,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.time} • ${item.room} • ${item.teacher}',
                          style: AppText.kanit(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        if (item.progress > 0) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: item.progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(kMid),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/timetable',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
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
