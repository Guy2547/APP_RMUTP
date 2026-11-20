import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart' show CustomBottomNav, bottomPadding;

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedCategory = 'all'; // all, repair, document, complaint

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'label': 'ทั้งหมด'},
    {'key': 'repair', 'label': 'แจ้งซ่อม'},
    {'key': 'document', 'label': 'ขอเอกสาร'},
    {'key': 'complaint', 'label': 'ร้องเรียน'},
  ];

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final requests = isTeacher ? db.allRequests : db.studentRequests;

    final filtered = requests.where((r) {
      if (_selectedCategory == 'all') return true;
      return r.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isTeacher ? 'เรื่องที่ต้องอนุมัติ' : 'แจ้งเรื่อง / ขอเอกสาร',
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
          // Category tabs
          Container(
            height: 44,
            margin: const EdgeInsets.all(16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((c) {
                final active = _selectedCategory == c['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c['key']!),
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
                        c['label']!,
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

          // Request form (student only)
          if (!isTeacher) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สร้างคำร้องใหม่',
                    style: AppText.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory == 'all'
                              ? 'document'
                              : _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'หมวดหมู่',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: kBorderLight),
                            ),
                          ),
                          items: [
                            {'key': 'repair', 'label': 'แจ้งซ่อม'},
                            {'key': 'document', 'label': 'ขอเอกสาร'},
                            {'key': 'complaint', 'label': 'ร้องเรียน'},
                          ].map((c) => DropdownMenuItem(
                                value: c['key'],
                                child: Text(
                                  c['label']!,
                                  style: AppText.kanit(fontSize: 12),
                                ),
                              )).toList(),
                          onChanged: (v) => setState(() {
                            _selectedCategory = v!;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'ชื่อเรื่องคำขอ',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: kBorderLight),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'รายละเอียดคำขอ',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: kBorderLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text('สร้างคำร้องเรียบร้อยแล้ว'),
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'ส่งคำขอ',
                        style: AppText.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Request list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ไม่มีคำร้องในหมวดนี้',
                          style: AppText.kanit(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding(context)),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.title,
                                      style: AppText.kanit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: kDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: r.chipColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isTeacher
                                          ? r.statusTeacher
                                          : r.status,
                                      style: AppText.kanit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: r.chipColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    r.category == 'repair'
                                        ? Icons.build
                                        : r.category == 'document'
                                            ? Icons.description
                                            : Icons.report,
                                    size: 16,
                                    color: kMid,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _categoryLabel(r.category),
                                    style: AppText.kanit(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    r.id,
                                    style: AppText.kanit(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (r.progress > 0 && r.progress < 1) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: r.progress,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                        r.chipColor,
                                      ),
                                ),
                              ],
                              if (r.status.contains('เสร็จแล้ว')) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                      content:
                                          Text('ดาวน์โหลดเอกสาร PDF แล้ว 📥'),
                                    )),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: kMid),
                                      foregroundColor: kMid,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '📄 ดาวน์โหลด PDF',
                                      style: AppText.kanit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
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
        currentRoute: '/requests',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'repair':
        return 'แจ้งซ่อม';
      case 'document':
        return 'ขอเอกสาร';
      case 'complaint':
        return 'ร้องเรียน';
      default:
        return 'คำร้อง';
    }
  }
}
