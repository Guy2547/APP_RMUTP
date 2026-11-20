import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart' show CustomBottomNav, kBottomNavHeight;

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String _selectedTerm = 'ภาคเรียนที่ 1/2569';

  final List<String> _terms = [
    'ภาคเรียนที่ 1/2569',
    'ภาคเรียนที่ 2/2568',
    'ภาคเรียนที่ 1/2568',
  ];

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabaseProvider>();
    final user = db.currentUser;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ผลการเรียน',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavHeight + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Term selector
            Row(
              children: [
                Text(
                  'เลือกภาคเรียน',
                  style: AppText.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTerm,
                      items: _terms
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t,
                                  style: AppText.kanit(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedTerm = v!),
                      dropdownColor: kDark,
                      style: AppText.kanit(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // GPA card
            AppCard(
              color: kDark,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'GPA สะสม (${user.displayName})',
                    style: AppText.kanit(
                      fontSize: 12,
                      color: Colors.purple.shade200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.gpax.toStringAsFixed(2),
                        style: const TextStyle(
                          color: kGold,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            'เทอมนี้',
                            style: AppText.kanit(
                              fontSize: 11,
                              color: Colors.purple.shade200,
                            ),
                          ),
                          Text(
                            user.currentTermGpa.toStringAsFixed(2),
                            style: AppText.kanit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'หน่วยกิตสะสม ${user.earnedCredits}/${user.totalCreditsRequired} • เกรดเฉลี่ยภาคเรียน ${user.currentTermGpa.toStringAsFixed(2)}',
                    style: AppText.kanit(
                      fontSize: 11,
                      color: Colors.purple.shade200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Subject grades list
            Text(
              'รายวิชาที่ลงทะเบียน',
              style: AppText.kanit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            ...db.studentGrades.map((g) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _gradeColor(g.score).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            g.letter.split(' ').first,
                            style: TextStyle(
                              color: _gradeColor(g.score),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${g.subjectCode} ${g.subjectName}',
                              style: AppText.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: g.isWarning
                                        ? Colors.amber.withValues(alpha: 0.1)
                                        : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    g.isWarning ? 'ต้องปรับปรุง' : 'ผ่านเกณฑ์',
                                    style: AppText.kanit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: g.isWarning
                                          ? Colors.amber.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${g.score.toStringAsFixed(1)} / 4.00',
                                  style: AppText.kanit(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (g.isWarning) ...[
                        const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            AppCard(
              color: Colors.amber.withValues(alpha: 0.05),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'เกรดคำนวณอัตโนมัติผ่านระบบฐานข้อมูล (PostgreSQL Trigger)',
                      style: AppText.kanit(
                        fontSize: 11,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/grades',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Color _gradeColor(double score) {
    if (score >= 3.5) return Colors.green.shade600;
    if (score >= 3.0) return Colors.green.shade500;
    if (score >= 2.5) return Colors.amber.shade600;
    if (score >= 2.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
