import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kRadioOutline = Color(0xFFC4B3D8);
const Color _kNoteBg = Color(0xFFF1EBF9);

TextStyle _thai(
  double size,
  FontWeight weight,
  Color color, {
  double? lineHeight,
}) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: lineHeight != null ? lineHeight / size : 1.45,
    );

class _LanguageOption {
  final String value;
  final String subtitle;

  const _LanguageOption({required this.value, required this.subtitle});
}

const List<_LanguageOption> _languageOptions = [
  _LanguageOption(value: 'ไทย', subtitle: 'ภาษาไทย'),
  _LanguageOption(value: 'English', subtitle: 'ภาษาอังกฤษ'),
];

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'ไทย';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String &&
          _languageOptions.any((option) => option.value == arg)) {
        _selected = arg;
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _selected);
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: _buildHeader(
          context,
          'ภาษา',
          onBack: () => Navigator.pop(context, _selected),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลือกภาษาที่ต้องการ',
                      style: _thai(22, FontWeight.w600, _kInk, lineHeight: 35),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'เลือกภาษาเพื่อบันทึกเป็นค่าที่ต้องการ',
                      style:
                          _thai(13, FontWeight.w400, _kMuted, lineHeight: 21),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final option in _languageOptions)
                        _RadioOptionTile(
                          title: option.value,
                          subtitle: option.subtitle,
                          selected: _selected == option.value,
                          onTap: () => setState(() => _selected = option.value),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kNoteBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'ต้นแบบนี้บันทึกตัวเลือกภาษา\nเนื้อหาหน้าจอยังคงแสดงเป็นภาษาไทย',
                    style:
                        _thai(12, FontWeight.w400, _kPrimary, lineHeight: 19),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildHeader(
  BuildContext context,
  String title, {
  required VoidCallback onBack,
}) {
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
          onTap: onBack,
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

class _RadioOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 22, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _thai(16, FontWeight.w500, _kInk, lineHeight: 26),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style:
                          _thai(12, FontWeight.w400, _kMuted, lineHeight: 19),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kRadioOutline,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: _kPrimary,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
