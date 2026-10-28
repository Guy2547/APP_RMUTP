import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../services/mock_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().role;
    final isTeacher = role == AppRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? '📥 เรื่องที่ต้องอนุมัติ' : '🛠️ แจ้งเรื่อง / ขอเอกสาร'),
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
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
                        _reqBtn('🔧', 'แจ้งซ่อม', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เลือก: แจ้งซ่อม')))),
                        const SizedBox(width: 8),
                        _reqBtn('📄', 'ขอเอกสาร', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เลือก: ขอเอกสาร'))), active: true),
                        const SizedBox(width: 8),
                        _reqBtn('📢', 'ร้องเรียน', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เลือก: ร้องเรียน')))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ชื่อเรื่องคำขอ',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kBorderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'รายละเอียดคำขอ',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kBorderLight),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'ส่งคำขอ',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ส่งคำขอ #RQ-1042 แล้ว ติดตามด้านล่าง ⬇')),
                      ),
                      backgroundColor: kDark,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...MockData.requestsStudent.map((r) {
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
                                style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                              ),
                            ),
                            ChipTag(
                              label: r.status,
                              backgroundColor: r.chipColor.withValues(alpha: 0.1),
                              textColor: r.chipColor,
                            ),
                          ],
                        ),
                        if (r.progress > 0 && r.progress < 1) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: r.progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(r.chipColor),
                          ),
                        ],
                        if (r.status.contains('เสร็จแล้ว')) ...[
                          Text(
                            'โหลด PDF',
                            style: AppText.kanit(fontSize: 11, color: Colors.green).copyWith(decoration: TextDecoration.underline),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ] else ...[
              ...MockData.requestsTeacher.map((r) {
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
                                style: AppText.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
                              ),
                            ),
                            ChipTag(
                              label: r.status,
                              backgroundColor: r.chipColor.withValues(alpha: 0.1),
                              textColor: r.chipColor,
                            ),
                          ],
                        ),
                        if (r.status == 'รออนุมัติ') ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  text: 'อนุมัติ',
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('อนุมัติ #RQ-1042 แล้ว ✅')),
                                  ),
                                  backgroundColor: kDark,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GhostButton(
                                  text: 'ตีกลับ',
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ตีกลับ #RQ-1042 ให้แก้เอกสาร')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade50,
                child: Text(
                  'อนุมัติแล้ว 12 • ตีกลับ 2 • รอคุณ 1 เรื่อง',
                  style: AppText.kanit(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
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

  Widget _reqBtn(String emoji, String label, VoidCallback onPressed, {bool active = false}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? kMid : Colors.white,
          foregroundColor: active ? Colors.white : kMid,
          side: BorderSide(color: active ? kMid : kBorderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: AppText.kanit(fontSize: 10, fontWeight: FontWeight.w600)),
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
