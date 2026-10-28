import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/grade_submit_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/news_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/notif_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/help_screen.dart';
import 'providers/role_provider.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RoleProvider(),
      child: const RMUTPApp(),
    ),
  );
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
        '/timetable': (context) => const TimetableScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/course-detail': (context) => const CourseDetailScreen(),
        '/grades': (context) => const GradesScreen(),
        '/grade-submit': (context) => const GradeSubmitScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/news': (context) => const NewsScreen(),
        '/news-detail': (context) => const NewsDetailScreen(),
        '/notif': (context) => const NotifScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/help': (context) => const HelpScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }

  static ThemeData get _themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kDark,
        primary: kDark,
        secondary: kMain,
        surface: kBg,
      ),
      textTheme: GoogleFonts.kanitTextTheme(),
      scaffoldBackgroundColor: kBg,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDark,
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
          borderSide: BorderSide(color: kBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kMid, width: 2),
        ),
        labelStyle: const TextStyle(color: kDark, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
