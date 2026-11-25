import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kOnPrimaryMuted = Color(0xFFE5D6F8);
const Color _kAvatarBg = Color(0xFFF2ECFA);
const Color _kBadgeBg = Color(0xFFF1ECF8);
const Color _kDivider = Color(0xFFEEE9F3);

TextStyle _thai(double size, FontWeight weight, Color color) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
    );

TextStyle _inter(
  double size,
  FontWeight weight,
  Color color, {
  double? letterSpacing,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
      letterSpacing: letterSpacing,
    );

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _highBrightness = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildHeader(context, 'บัตรนักศึกษา'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              const _StudentIdCard(),
              const SizedBox(height: 20),
              const _CampusAccessCard(),
              const SizedBox(height: 16),
              _BrightnessControlCard(
                value: _highBrightness,
                onChanged: (v) => setState(() => _highBrightness = v),
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

class _StudentIdCard extends StatelessWidget {
  const _StudentIdCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.09),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 98,
                color: _kPrimary,
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RMUTP',
                          style: _inter(29, FontWeight.w700, Colors.white),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร',
                          style: _thai(10, FontWeight.w400, _kOnPrimaryMuted),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'STUDENT ID',
                        style: _inter(
                          10,
                          FontWeight.w600,
                          _kOnPrimaryMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 27,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: _kBadgeBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: _kPrimary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ใช้งานได้',
                                style: _thai(11, FontWeight.w500, _kPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Theerachut',
                      style: _inter(22, FontWeight.w600, _kInk),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '65012345678-9',
                      style: _inter(15, FontWeight.w500, _kPrimary),
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, thickness: 1, color: _kDivider),
                    const SizedBox(height: 15),
                    Text(
                      'FACULTY',
                      style: _inter(
                        9,
                        FontWeight.w600,
                        _kMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Faculty of Engineering',
                      style: _inter(14, FontWeight.w500, _kInk),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      'MAJOR',
                      style: _inter(
                        9,
                        FontWeight.w600,
                        _kMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Computer Engineering',
                      style: _inter(14, FontWeight.w500, _kInk),
                    ),
                    const SizedBox(height: 11),
                    const Divider(height: 1, thickness: 1, color: _kDivider),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VALID UNTIL',
                          style: _inter(
                            9,
                            FontWeight.w600,
                            _kMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          '31 MAY 2027',
                          style: _inter(11, FontWeight.w600, _kPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 24,
            top: 78,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _kAvatarBg,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 46,
                  color: Color(0xFFB5A4CB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusAccessCard extends StatelessWidget {
  const _CampusAccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 14, 19, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สแกนเพื่อเข้าใช้งาน',
            style: _thai(16, FontWeight.w600, _kInk),
          ),
          const SizedBox(height: 4),
          Text(
            'อาคารเรียน · ห้องสมุด · บริการในมหาวิทยาลัย',
            style: _thai(10.5, FontWeight.w400, _kMuted),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: CustomPaint(painter: _BarcodePainter()),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '65012345678-9',
                      style: _inter(12, FontWeight.w500, _kInk),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BARCODE',
                      style: _inter(
                        9,
                        FontWeight.w500,
                        _kMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 91,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: _kDivider,
              ),
              Column(
                children: [
                  const SizedBox(
                    width: 108,
                    height: 108,
                    child: CustomPaint(painter: _QrCodePainter()),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'QR CODE',
                    style: _inter(
                      9,
                      FontWeight.w500,
                      _kMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrightnessControlCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BrightnessControlCard({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wb_sunny_outlined,
              size: 22,
              color: _kPrimary,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เพิ่มความสว่าง',
                    style: _thai(14, FontWeight.w500, _kInk),
                  ),
                  Text(
                    'ช่วยให้เครื่องอ่านสแกนได้ง่ายขึ้น',
                    style: _thai(10, FontWeight.w400, _kMuted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
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
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
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
          ],
        ),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter();

  // Code 128-style bar/space widths for "65012345678-9"
  static const List<int> _pattern = [
    2, 1, 1, 4, 1, 2, 1, 2, 2, 1, 3, 1, 1, 1, 2, 2,
    3, 1, 2, 1, 1, 3, 1, 2, 2, 2, 1, 1, 2, 1, 3, 1,
    1, 2, 1, 1, 3, 2, 2, 1, 1, 2, 2, 1, 1, 3, 1, 1,
    2, 2, 1, 2, 3, 1, 1, 1, 2, 1, 2, 2, 2, 1, 1, 3,
    1, 2, 1, 2, 2, 1, 3, 1, 1, 2, 2, 3, 1, 1, 1, 2,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF15101D);
    final totalUnits = _pattern.fold<int>(0, (sum, w) => sum + w);
    final unitWidth = size.width / totalUnits;
    double x = 0;
    for (int i = 0; i < _pattern.length; i++) {
      final w = _pattern[i] * unitWidth;
      if (i.isEven) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrCodePainter extends CustomPainter {
  const _QrCodePainter();

  static const int _gridSize = 21;

  static const List<String> _matrix = [
    '111111101011001111111',
    '100000100100101000001',
    '101110101110001011101',
    '101110100010101011101',
    '101110101001001011101',
    '100000100110101000001',
    '111111101010101111111',
    '000000001101000000000',
    '101101110010110110101',
    '010010001101001001010',
    '110111101011101101101',
    '001000010100010010010',
    '101110111010111011011',
    '000000001011001001001',
    '111111100100101011100',
    '100000101110000100111',
    '101110100010111011010',
    '101110101101001000101',
    '101110100110101110011',
    '100000101001000011100',
    '111111101100111010111',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF15101D);
    final cell = size.width / _gridSize;
    for (int r = 0; r < _gridSize; r++) {
      final row = _matrix[r];
      for (int c = 0; c < _gridSize; c++) {
        if (row[c] == '1') {
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell + 0.25, cell + 0.25),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
