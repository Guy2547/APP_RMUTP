import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_database_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showDeepProfileSheet(BuildContext context, AppDatabaseProvider db) {
    final p = db.studentProfile;
    final u = db.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '👤 ข้อมูลทะเบียนประวัตินักศึกษา (v_student_profiles)',
              style: AppText.kanit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const Divider(height: 24),
            _infoRow('รหัสนักศึกษา', p?.studentId ?? u.studentId ?? '650602001'),
            _infoRow('ชื่อ-นามสกุล (ไทย)', p?.fullNameTh ?? u.displayName),
            _infoRow('ชื่อ-นามสกุล (EN)', p?.fullNameEn ?? 'Mintra Jaidee'),
            _infoRow('อีเมลมหาวิทยาลัย', p?.universityEmail ?? u.email),
            _infoRow('เลขบัตรประชาชน', p?.citizenId ?? '1100501234501'),
            _infoRow(
              'วันเกิด / กรุ๊ปเลือด',
              '${p?.birthDate ?? '2004-05-14'} • กรุ๊ปเลือด ${p?.bloodGroup ?? 'O'}',
            ),
            _infoRow(
              'คณะ / ศูนย์พื้นที่',
              '${p?.facultyNameTh ?? 'คณะวิศวกรรมศาสตร์'} (${p?.campus ?? 'ศูนย์พระนครเหนือ'})',
            ),
            _infoRow(
              'สาขาวิชา / หลักสูตร',
              '${p?.departmentNameTh ?? 'วิศวกรรมคอมพิวเตอร์'} • ${p?.degreeNameTh ?? 'วศ.บ.'}',
            ),
            _infoRow('อาจารย์ที่ปรึกษา', p?.advisorName ?? 'อ.สุรชัย วงศ์ใหญ่'),
            _infoRow(
              'GPAX / หน่วยกิตสะสม',
              '${u.gpax.toStringAsFixed(2)} • ${p?.creditsProgressLabel ?? '${u.earnedCredits}/${u.totalCreditsRequired}'} หน่วยกิต',
            ),
            _infoRow('เบอร์โทรศัพท์ / Line', '${p?.phone ?? '092-345-6789'} • Line: ${p?.lineId ?? 'mintra_ce65'}'),
            _infoRow('ที่อยู่ปัจจุบัน (หอพัก)', p?.currentAddress ?? 'หอพักนักศึกษาเคียงมอ ห้อง 402 ซ.วงศ์สว่าง 11'),
            _infoRow('ที่อยู่ตามทะเบียนบ้าน', p?.permanentAddress ?? '99/12 หมู่ 4 ถ.พิบูลสงคราม บางซื่อ กรุงเทพมหานคร 10800'),
            _infoRow(
              'ผู้ติดต่อฉุกเฉิน',
              '${p?.emergencyContactName ?? 'นางสมศรี ใจดี'} (${p?.emergencyContactRelation ?? 'มารดา'}) • ${p?.emergencyContactPhone ?? '081-999-8877'}',
            ),
          ],
        ),
      ),
    );
  }

  void _showFinancialReceiptsSheet(BuildContext context, AppDatabaseProvider db) {
    final records = db.financialRecords;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '🧾 ใบแจ้งหนี้ค่าเทอมและใบเสร็จรับเงิน (v_student_financial_records)',
              style: AppText.kanit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            ...records.map((rec) {
              final isPaid = rec.paymentStatus == 'paid';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ภาคการศึกษา ${rec.termLabel} (${rec.invoiceNo})',
                            style: AppText.kanit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPaid ? 'ชำระแล้ว ✓' : 'รอตรวจสอบ',
                              style: AppText.kanit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isPaid
                                    ? Colors.green.shade700
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      _infoRow('ค่าหน่วยกิต/เหมาจ่าย', '${rec.tuitionFee.toStringAsFixed(0)} บาท'),
                      _infoRow('ค่าบำรุงมหาวิทยาลัย + ปฏิบัติการ', '${(rec.universityFee + rec.labEquipmentFee).toStringAsFixed(0)} บาท'),
                      if (rec.scholarshipDiscount > 0)
                        _infoRow('ส่วนลดทุนเรียนดี', '-${rec.scholarshipDiscount.toStringAsFixed(0)} บาท'),
                      _infoRow('ยอดชำระสุทธิ', '${rec.totalAmount.toStringAsFixed(2)} บาท'),
                      if (rec.receiptNo != null) ...[
                        _infoRow('เลขที่ใบเสร็จ (e-Receipt)', rec.receiptNo!),
                        _infoRow('ช่องทางชำระ / ธนาคาร', '${rec.bankName ?? '-'} (${rec.transactionRef ?? '-'})'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'ดาวน์โหลดใบเสร็จ ${rec.receiptNo}.pdf จาก Storage แล้ว 📥',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf, size: 16),
                            label: Text('ดาวน์โหลดใบเสร็จ ${rec.receiptNo} (PDF)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: AppText.kanit(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppText.kanit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = context.watch<RoleProvider>().isTeacher;
    final db = context.watch<AppDatabaseProvider>();
    final user = db.currentUser;
    final avatarChar = isTeacher ? 'ส' : 'ม';

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
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
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              color: kDark,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        avatarChar,
                        style: AppText.kanit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName,
                    style: AppText.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.subtitleInfo,
                    style: AppText.kanit(
                      fontSize: 12,
                      color: Colors.purple.shade200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _profileRow(
                    '👤',
                    'ข้อมูลส่วนตัวเชิงลึก (ทะเบียนประวัติ)',
                    () => _showDeepProfileSheet(context, db),
                  ),
                  if (!isTeacher)
                    _profileRow(
                      '🧾',
                      'ประวัติค่าเทอมและใบเสร็จรับเงิน (e-Receipt)',
                      () => _showFinancialReceiptsSheet(context, db),
                    ),
                  _profileRow(
                    '🌐',
                    'ภาษา / Language',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ภาษา: ไทย ✓')),
                    ),
                  ),
                  _profileRow(
                    '🔔',
                    'การแจ้งเตือน',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เปิด/ปิดแจ้งเตือนแล้ว')),
                    ),
                  ),
                  _profileRow(
                    '🚪',
                    'ออกจากระบบ',
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    ),
                    textColor: Colors.red.shade600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'RMUTP Campus App v1.0 • มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร',
              style: AppText.kanit(fontSize: 10, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentRoute: '/profile',
        onTap: (route) => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _profileRow(
    String emoji,
    String label,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: AppText.kanit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? kDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: kMid),
      onTap: onTap,
    );
  }
}
