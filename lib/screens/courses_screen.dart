import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final items = isTeacher ? db.teacherTimetable : db.studentTimetable;
    final filtered = items.where((item) {
      return item.code.toLowerCase().contains(_query.toLowerCase()) ||
          item.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTeacher
              ? '📚 รายวิชาที่สอน (${items.length})'
              : '📚 รายวิชาของฉัน (${items.length})',
        ),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'ค้นหาวิชา / รหัสวิชา...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kBorderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kMid, width: 2),
                ),
                hintStyle: AppText.kanit(fontSize: 13, color: Colors.grey.shade500),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final summaryText = item.courseSummary.isNotEmpty
                    ? item.courseSummary
                    : '${item.time} • ${item.room} • ${item.teacher}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    border: const Border(
                      left: BorderSide(color: kMid, width: 6),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/course-detail'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.displayName,
                                  style: AppText.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kDark,
                                  ),
                                ),
                              ),
                              if (item.pendingAssignments > 0)
                                ChipTag(
                                  label: 'งานค้าง ${item.pendingAssignments}',
                                  backgroundColor:
                                      Colors.red.withValues(alpha: 0.1),
                                  textColor: Colors.red.shade700,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            summaryText,
                            style: AppText.kanit(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: item.progress / 100,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              item.progress >= 70 ? kMid : kGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/courses',
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
