import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const RMUTPApp());
}

class RMUTPApp extends StatelessWidget {
  const RMUTPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMUTP Campus App',
      debugShowCheckedModeBanner: false,
      theme: _themeData,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/timetable': (context) => const StubScreen(title: 'ตารางเรียน'),
        '/courses': (context) => const StubScreen(title: 'รายวิชา + ส่งงาน'),
        '/grades': (context) => const StubScreen(title: 'เกรด / GPA'),
        '/attendance': (context) => const StubScreen(title: 'เช็คชื่อ 2 โรล'),
        '/news': (context) => const StubScreen(title: 'ข่าว / ทุน / ฝึกงาน'),
        '/notif': (context) => const StubScreen(title: 'แจ้งเตือน + ปฏิทิน'),
        '/requests': (context) => const StubScreen(title: 'แจ้งซ่อม / ขอเอกสาร'),
        '/help': (context) => const StubScreen(title: 'Q&A + ติดต่อ'),
        '/profile': (context) => const StubScreen(title: 'โปรไฟล์'),
      },
    );
  }

  static ThemeData get _themeData {
    const dark = Color(0xFF420671);
    const main = Color(0xFF4D287B);
    const mid = Color(0xFF652D91);
    const bg = Color(0xFFF5F3FA);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dark,
        primary: dark,
        secondary: main,
        surface: bg,
      ),
      textTheme: GoogleFonts.kanitTextTheme(),
      scaffoldBackgroundColor: bg,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFCBB9E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mid, width: 2),
        ),
        labelStyle: const TextStyle(color: dark, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _role = 'student';
  final _emailCtrl = TextEditingController(text: 's650602xxx@rmutp.ac.th');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF420671);
    const gold = Color(0xFFF6DC04);
    const mid = Color(0xFF652D91);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.network(
                'https://www.rmutp.ac.th/web2561/wp-content/uploads/2018/06/rmutp-logo.png',
                height: 64,
                errorBuilder: (_, __, ___) => Container(
                  height: 64, width: 64,
                  decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.school, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 16),
              Text('ยินดีต้อนรับสู่ RMUTP', style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.w800, color: dark)),
              const SizedBox(height: 4),
              Text('Rajamangala University of Technology Phra Nakhon', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 26),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'อีเมลมหาวิทยาลัย'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: mid),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านแล้ว'))),
                  child: const Text('ลืมรหัสผ่าน?', style: TextStyle(color: mid, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _roleBtn('เข้าใช้: นักศึกษา', 'student', dark, Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(child: _roleBtn('เข้าใช้: อาจารย์', 'teacher', gold, dark)),
                ],
              ),
              const SizedBox(height: 14),
              Text('Demo: กดปุ่มใดก็ได้เพื่อเข้าแอป ไม่ต้องใช้รหัสจริง', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _pill('🎓 นักศึกษา', 'student')),
                  const SizedBox(width: 8),
                  Expanded(child: _pill('👩‍🏫 อาจารย์', 'teacher')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleBtn(String text, String role, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {
        setState(() => _role = role);
        Navigator.pushNamed(context, '/home');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _role == role ? bgColor : Colors.white,
        foregroundColor: _role == role ? textColor : const Color(0xFF9A93AD),
        side: BorderSide(color: _role == role ? bgColor : const Color(0xFFCBB9E6)),
        elevation: 0,
      ),
      child: Text(text),
    );
  }

  Widget _pill(String label, String role) {
    final active = _role == role;
    return GestureDetector(
      onTap: () {
        setState(() => _role = role);
        Navigator.pushNamed(context, '/home');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF6DC04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? const Color(0xFFF6DC04) : const Color(0xFFCBB9E6)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF420671) : const Color(0xFF652D91),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RMUTP Campus'),
        centerTitle: true,
        backgroundColor: const Color(0xFF420671),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.pushNamed(context, '/notif')),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: Color(0xFF652D91)),
            SizedBox(height: 12),
            Text('หน้าแรก Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF420671))),
            SizedBox(height: 8),
            Text('หน้านี้อยู่ระหว่างพัฒนา', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context, int index) {
    const items = [
      ('/home', 'หน้าแรก', Icons.home),
      ('/timetable', 'ตารางเรียน', Icons.calendar_today),
      ('/courses', 'รายวิชา', Icons.book),
      ('/grades', 'เกรด', Icons.grade),
      ('/attendance', 'เช็คชื่อ', Icons.check_circle),
      ('/news', 'ข่าว', Icons.article),
      ('/notif', 'แจ้งเตือน', Icons.notifications),
      ('/requests', 'แจ้งเรื่อง', Icons.build),
      ('/help', 'ช่วยเหลือ', Icons.help),
      ('/profile', 'โปรไฟล์', Icons.person),
    ];

    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF420671),
      unselectedItemColor: Colors.grey.shade500,
      onTap: (i) => Navigator.pushNamed(context, items[i].$1),
      items: items.map((e) => BottomNavigationBarItem(icon: Icon(e.$3), label: e.$2)).toList(),
    );
  }
}

class StubScreen extends StatelessWidget {
  final String title;
  const StubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF420671),
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, size: 64, color: Color(0xFFF6DC04)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF420671))),
            const SizedBox(height: 8),
            Text('หน้านี้อยู่ระหว่างพัฒนา กดปุ่มได้แต่ยังไม่เชื่อมต่อระบบจริง', style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('ย้อนกลับ')),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    const items = [
      ('/home', 'หน้าแรก', Icons.home),
      ('/timetable', 'ตารางเรียน', Icons.calendar_today),
      ('/courses', 'รายวิชา', Icons.book),
      ('/grades', 'เกรด', Icons.grade),
      ('/attendance', 'เช็คชื่อ', Icons.check_circle),
      ('/news', 'ข่าว', Icons.article),
      ('/notif', 'แจ้งเตือน', Icons.notifications),
      ('/requests', 'แจ้งเรื่อง', Icons.build),
      ('/help', 'ช่วยเหลือ', Icons.help),
      ('/profile', 'โปรไฟล์', Icons.person),
    ];
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF420671),
      unselectedItemColor: Colors.grey.shade500,
      onTap: (i) => Navigator.pushNamed(context, items[i].$1),
      items: items.map((e) => BottomNavigationBarItem(icon: Icon(e.$3), label: e.$2)).toList(),
    );
  }
}
