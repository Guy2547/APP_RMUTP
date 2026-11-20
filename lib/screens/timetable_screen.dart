import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = 'MON';

  final List<Map<String, String>> _days = [
    {'key': 'MON', 'label': 'จันทร์'},
    {'key': 'TUE', 'label': 'อังคาร'},
    {'key': 'WED', 'label': 'พุธ'},
    {'key': 'THU', 'label': 'พฤหัสบดี'},
    {'key': 'FRI', 'label': 'ศุกร์'},
    {'key': 'SAT', 'label': 'เสาร์'},
  ];

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final items = db.getTimetableForDay(isTeacher, _selectedDay);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isTeacher ? 'ตารางสอน' : 'ตารางเรียน',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Day selector tabs
          Container(
            height: 44,
            margin: const EdgeInsets.all(16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _days.map((d) {
                final active = _selectedDay == d['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = d['key']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: active ? kDark : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: active ? kDark : kBorderLight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        d['label']!,
                        style: AppText.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : kMid,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Timetable list
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ไม่มีวิชาในวันนี้',
                          style: AppText.kanit(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: kDark.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.time.split('–').first,
                                        style: AppText.kanit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: kDark,
                                        ),
                                      ),
                                      Text(
                                        item.time.split('–').last,
                                        style: AppText.kanit(
                                          fontSize: 10,
                                          color: kMid,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.displayName,
                                            style: AppText.kanit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: kDark,
                                            ),
                                          ),
                                        ),
                                        if (item.progress > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green
                                                  .withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(
                                                6,
                                              ),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: AppText.kanit(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${item.room} • ${item.teacher}',
                                      style: AppText.kanit(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'ห้องเรียน ${item.room}',
                                          style: AppText.kanit(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (item.pendingAssignments > 0)
                                          Text(
                                            'งานค้าง ${item.pendingAssignments}',
                                            style: AppText.kanit(
                                              fontSize: 11,
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: item.progress / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        item.progress >= 70 ? kMid : kGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
