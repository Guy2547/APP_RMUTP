import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kIconTileBg = Color(0xFFF1ECF8);
const Color _kDivider = Color(0xFFEEE9F3);
const Color _kSignOutBorder = Color(0xFFE3D5EE);
const Color _kDanger = Color(0xFFB32635);

TextStyle _thai(double size, FontWeight weight, Color color) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
    );

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'ไทย';
  String _appearance = 'ตามระบบ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'ตั้งค่า'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('บัญชีผู้ใช้', style: _thai(16, FontWeight.w600, _kInk)),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline_rounded,
                    label: 'ข้อมูลส่วนตัว',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'เปลี่ยนรหัสผ่าน',
                    onTap: () =>
                        Navigator.pushNamed(context, '/change-password'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('การใช้งาน', style: _thai(16, FontWeight.w600, _kInk)),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'การแจ้งเตือน',
                    trailing: _PillSwitch(
                      value: _notificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                    ),
                    onTap: () => setState(
                      () => _notificationsEnabled = !_notificationsEnabled,
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    label: 'ภาษา',
                    valueText: _language,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/language',
                        arguments: _language,
                      );
                      if (result is String && mounted) {
                        setState(() => _language = result);
                      }
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.wb_sunny_outlined,
                    label: 'การแสดงผล',
                    valueText: _appearance,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/appearance',
                        arguments: _appearance,
                      );
                      if (result is String && mounted) {
                        setState(() => _appearance = result);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'ความเป็นส่วนตัวและช่วยเหลือ',
                style: _thai(16, FontWeight.w600, _kInk),
              ),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    icon: Icons.verified_user_outlined,
                    label: 'นโยบายความเป็นส่วนตัว',
                    onTap: () => Navigator.pushNamed(context, '/privacy'),
                  ),
                  _SettingsRow(
                    icon: Icons.help_outline_rounded,
                    label: 'ศูนย์ช่วยเหลือ',
                    onTap: () => Navigator.pushNamed(context, '/help'),
                  ),
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    label: 'เกี่ยวกับแอป',
                    onTap: () => Navigator.pushNamed(context, '/about'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _kSignOutBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 22,
                          color: _kDanger,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'ออกจากระบบ',
                          style: _thai(16, FontWeight.w600, _kDanger),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 21),
              Center(
                child: Text(
                  'RMUTP Student Portal · เวอร์ชัน 1.0.0',
                  style: _thai(11, FontWeight.w400, _kMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildHeader(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: 50,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    leadingWidth: 64,
    leading: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(painter: _BackChevronPainter()),
            ),
          ),
        ),
      ),
    ),
    title: Text(title, style: _thai(21, FontWeight.w600, _kInk)),
  );
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 28, size.height / 28);
    final paint = Paint()
      ..color = _kPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(17, 6)
      ..lineTo(9, 14)
      ..lineTo(17, 22);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: 60, right: 16),
                child: Divider(height: 1, thickness: 1, color: _kDivider),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? valueText;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.valueText,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _kIconTileBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: _kPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: _thai(15, FontWeight.w500, _kInk),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else ...[
                  if (valueText != null) ...[
                    Text(
                      valueText!,
                      style: _thai(13, FontWeight.w400, _kMuted),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _kMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PillSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? _kPrimary : const Color(0xFFD8D1E2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
