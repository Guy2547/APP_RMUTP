import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBg = Color(0xFFF7F6FA);
const Color _kPrimary = Color(0xFF4A148C);
const Color _kInk = Color(0xFF21172F);
const Color _kMuted = Color(0xFF756B80);
const Color _kUnreadIconBg = Color(0xFFF2ECFA);
const Color _kReadIconBg = Color(0xFFF5F3F7);
const Color _kUnreadBorder = Color(0xFFE2D6F0);
const Color _kReadBorder = Color(0xFFEEE9F3);

TextStyle _thai(double size, FontWeight weight, Color color,
        {double height = 1.4}) =>
    GoogleFonts.notoSansThai(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

enum _MessageCategory { university, personal }

class _InboxMessage {
  final String sender;
  final String title;
  final String preview;
  final String time;
  final IconData icon;
  final _MessageCategory category;
  bool unread;

  _InboxMessage({
    required this.sender,
    required this.title,
    required this.preview,
    required this.time,
    required this.icon,
    required this.category,
    required this.unread,
  });
}

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  int _filterIndex = 0; // 0: ทั้งหมด, 1: ประกาศมหาวิทยาลัย, 2: ข้อความส่วนตัว

  final List<_InboxMessage> _messages = [
    _InboxMessage(
      sender: 'กองพัฒนานักศึกษา',
      title: 'เปิดรับสมัครทุนการศึกษา',
      preview: 'ทุนสนับสนุนการศึกษา ประจำปี 2569\nสมัครได้ถึงวันที่ 30 พฤศจิกายนนี้',
      time: 'วันนี้ · 09:15 น.',
      icon: Icons.account_balance_outlined,
      category: _MessageCategory.university,
      unread: true,
    ),
    _InboxMessage(
      sender: 'สำนักส่งเสริมวิชาการฯ',
      title: 'แจ้งกำหนดลงทะเบียนเรียน',
      preview: 'ตรวจสอบรายวิชาและแผนการเรียน\nก่อนลงทะเบียนภาคเรียนถัดไป',
      time: 'วันนี้ · 08:40 น.',
      icon: Icons.description_outlined,
      category: _MessageCategory.university,
      unread: true,
    ),
    _InboxMessage(
      sender: 'อ.ดร. ธนกร วัฒนกุล',
      title: 'นัดหมายอาจารย์ที่ปรึกษา',
      preview: 'ขอให้นักศึกษาเข้าพบเพื่อวางแผน\nการเรียนในภาคเรียนถัดไป',
      time: 'เมื่อวาน · 16:30 น.',
      icon: Icons.person_outline_rounded,
      category: _MessageCategory.personal,
      unread: true,
    ),
    _InboxMessage(
      sender: 'สำนักวิทยบริการฯ',
      title: 'ขยายเวลาบริการห้องสมุด',
      preview: 'เปิดบริการถึง 20:00 น. ในช่วงสอบ\nพร้อมพื้นที่อ่านหนังสือเพิ่มเติม',
      time: 'เมื่อวาน · 11:00 น.',
      icon: Icons.menu_book_outlined,
      category: _MessageCategory.university,
      unread: false,
    ),
    _InboxMessage(
      sender: 'คณะวิศวกรรมศาสตร์',
      title: 'กิจกรรมพบผู้ประกอบการ',
      preview: 'พบเส้นทางอาชีพและโอกาสฝึกงาน\nสำหรับนักศึกษาคณะวิศวกรรมศาสตร์',
      time: '16 พ.ย. 2569 · 14:20 น.',
      icon: Icons.account_balance_outlined,
      category: _MessageCategory.university,
      unread: false,
    ),
  ];

  int get _unreadCount => _messages.where((m) => m.unread).length;

  List<_InboxMessage> get _filteredMessages {
    if (_filterIndex == 1) {
      return _messages
          .where((m) => m.category == _MessageCategory.university)
          .toList();
    }
    if (_filterIndex == 2) {
      return _messages
          .where((m) => m.category == _MessageCategory.personal)
          .toList();
    }
    return _messages;
  }

  void _markAllAsRead() {
    if (_unreadCount == 0) return;
    setState(() {
      for (final m in _messages) {
        m.unread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ทำเครื่องหมายอ่านแล้วทั้งหมด',
          style: _thai(13, FontWeight.w400, Colors.white),
        ),
        backgroundColor: _kPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredMessages;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
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
        title: Text('ข้อความ', style: _thai(21, FontWeight.w600, _kInk)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _markAllAsRead,
              tooltip: 'อ่านทั้งหมด',
              icon: const Icon(
                Icons.mark_email_read_outlined,
                size: 24,
                color: _kPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterTabs(
                selectedIndex: _filterIndex,
                onChanged: (i) => setState(() => _filterIndex = i),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'ข้อความล่าสุด',
                    style: _thai(17, FontWeight.w600, _kInk),
                  ),
                  Text(
                    _unreadCount > 0
                        ? 'ยังไม่อ่าน $_unreadCount ข้อความ'
                        : 'อ่านครบแล้ว',
                    style: _thai(11, FontWeight.w500, _kPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < visible.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _MessageCard(
                  message: visible[i],
                  onTap: () {
                    if (visible[i].unread) {
                      setState(() => visible[i].unread = false);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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

class _FilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _FilterTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (label: 'ทั้งหมด', flex: 66),
      (label: 'ประกาศมหาวิทยาลัย', flex: 156),
      (label: 'ข้อความส่วนตัว', flex: 116),
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              flex: items[i].flex,
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? _kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    items[i].label,
                    style: _thai(
                      12,
                      i == selectedIndex ? FontWeight.w600 : FontWeight.w500,
                      i == selectedIndex ? Colors.white : _kMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final _InboxMessage message;
  final VoidCallback onTap;

  const _MessageCard({
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = message.unread;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 10, 14, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: unread ? _kUnreadBorder : _kReadBorder,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: unread ? _kUnreadIconBg : _kReadIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    message.icon,
                    size: 20,
                    color: unread ? _kPrimary : _kMuted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.sender,
                            style: _thai(10, FontWeight.w500, _kMuted),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: _kPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.title,
                      style: _thai(
                        14,
                        unread ? FontWeight.w600 : FontWeight.w500,
                        _kInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.preview,
                      style: _thai(11.5, FontWeight.w400, _kMuted, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.time,
                      style: _thai(9.5, FontWeight.w400, _kMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
