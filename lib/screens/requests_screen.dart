import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedCategory = 'document';
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final studentRequests = db.studentRequests;
    final teacherRequests = db.allRequests;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTeacher ? '📥 เรื่องที่ต้องอนุมัติ' : '🛠️ แจ้งเรื่อง / ขอเอกสาร',
        ),
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
            if (!isTeacher) ...[
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _reqBtn(
                          '🔧',
                          'แจ้งซ่อม',
                          () => setState(() => _selectedCategory = 'repair'),
                          active: _selectedCategory == 'repair',
                        ),
                        const SizedBox(width: 8),
                        _reqBtn(
                          '📄',
                          'ขอเอกสาร',
                          () => setState(() => _selectedCategory = 'document'),
                          active: _selectedCategory == 'document',
                        ),
                        const SizedBox(width: 8),
                        _reqBtn(
                          '📢',
                          'ร้องเรียน',
                          () => setState(() => _selectedCategory = 'complaint'),
                          active: _selectedCategory == 'complaint',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        hintText: 'ชื่อเรื่องคำขอ (เช่น ขอใบรับรอง / แจ้งซ่อมโปรเจกเตอร์)',
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
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descCtrl,
                      decoration: InputDecoration(
                        hintText: 'รายละเอียดคำขอ',
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
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'ส่งคำขอเข้าฐานข้อมูล',
                      onPressed: () async {
                        final title = _titleCtrl.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กรุณากรอกชื่อเรื่องคำขอ'),
                            ),
                          );
                          return;
                        }
                        final created = await db.submitNewServiceRequest(
                          category: _selectedCategory,
                          title: title,
                          description: _descCtrl.text.trim(),
                        );
                        _titleCtrl.clear();
                        _descCtrl.clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'บันทึกคำขอ ${created.id} ลงตาราง service_requests แล้ว ✅',
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: kDark,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...studentRequests.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${r.id} ${r.title}',
                                style: AppText.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kDark,
                                ),
                              ),
                            ),
                            ChipTag(
                              label: r.status,
                              backgroundColor:
                                  r.chipColor.withValues(alpha: 0.1),
                              textColor: r.chipColor,
                            ),
                          ],
                        ),
                        if (r.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            r.description,
                            style: AppText.kanit(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (r.progress > 0 && r.progress < 1) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: r.progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(r.chipColor),
                          ),
                        ],
                        if (r.status.contains('เสร็จแล้ว')) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'ดาวน์โหลดเอกสาร PDF ของ ${r.id} จาก Storage แล้ว 📥',
                                ),
                              ),
                            ),
                            child: Text(
                              '📄 ดาวน์โหลดเอกสาร PDF จาก Storage',
                              style: AppText.kanit(
                                fontSize: 11,
                                color: Colors.green.shade700,
                              ).copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ] else ...[
              ...teacherRequests.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${r.id} ${r.title} (${r.studentId})',
                                style: AppText.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kDark,
                                ),
                              ),
                            ),
                            ChipTag(
                              label: r.statusTeacher,
                              backgroundColor:
                                  r.chipColor.withValues(alpha: 0.1),
                              textColor: r.chipColor,
                            ),
                          ],
                        ),
                        if (r.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            r.description,
                            style: AppText.kanit(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (r.statusTeacher == 'รออนุมัติ') ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  text: 'อนุมัติ',
                                  onPressed: () async {
                                    await db.reviewServiceRequest(
                                      requestCode: r.id,
                                      approved: true,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'อนุมัติคำขอ ${r.id} บันทึกลงฐานข้อมูลแล้ว ✅',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: kDark,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GhostButton(
                                  text: 'ตีกลับ',
                                  onPressed: () async {
                                    await db.reviewServiceRequest(
                                      requestCode: r.id,
                                      approved: false,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'ตีกลับคำขอ ${r.id} ในฐานข้อมูลแล้ว',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/requests',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _reqBtn(
    String emoji,
    String label,
    VoidCallback onPressed, {
    bool active = false,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? kMid : Colors.white,
          foregroundColor: active ? Colors.white : kMid,
          side: BorderSide(color: active ? kMid : kBorderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.kanit(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
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
