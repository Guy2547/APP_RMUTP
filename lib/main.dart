import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/exam_schedule_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/transcript_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/notif_screen.dart';
import 'screens/help_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/language_screen.dart';
import 'screens/appearance_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/grade_submit_screen.dart';
import 'screens/news_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/requests_screen.dart';
import 'providers/role_provider.dart';
import 'providers/app_database_provider.dart';
import 'widgets/app_theme.dart';

final Set<String> _protectedRoutes = {
  '/home',
  '/timetable',
  '/exam-schedule',
  '/grades',
  '/transcript',
  '/attendance',
  '/notif',
  '/privacy',
  '/about',
  '/settings',
  '/change-password',
  '/language',
  '/appearance',
  '/profile',
  '/courses',
  '/course-detail',
  '/grade-submit',
  '/news',
  '/news-detail',
  '/requests',
};

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => AppDatabaseProvider()),
      ],
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
      onGenerateRoute: (settings) {
        final db = context.read<AppDatabaseProvider>();
        final isLoggedIn = db.currentUser != null;

        // เส้นทางที่ต้องล็อกอินก่อน ถ้ายังไม่ได้ล็อกอินให้ส่งไปหน้า login
        if (_protectedRoutes.contains(settings.name) && !isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
            settings: settings,
          );
        }

        final builder = _routeBuilders[settings.name];
        if (builder == null) return null;
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }

  static final Map<String, WidgetBuilder> _routeBuilders = {
    '/login': (context) => const LoginScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/home': (context) => const HomeScreen(),
    '/timetable': (context) => const TimetableScreen(),
    '/exam-schedule': (context) => const ExamScheduleScreen(),
    '/grades': (context) => const GradesScreen(),
    '/transcript': (context) => const TranscriptScreen(),
    '/attendance': (context) => const AttendanceScreen(),
    '/notif': (context) => const NotifScreen(),
    '/help': (context) => const HelpScreen(),
    '/privacy': (context) => const PrivacyScreen(),
    '/about': (context) => const AboutScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/change-password': (context) => const ChangePasswordScreen(),
    '/language': (context) => const LanguageScreen(),
    '/appearance': (context) => const AppearanceScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/courses': (context) => const CoursesScreen(),
    '/course-detail': (context) => const CourseDetailScreen(),
    '/grade-submit': (context) => const GradeSubmitScreen(),
    '/news': (context) => const NewsScreen(),
    '/news-detail': (context) => const NewsDetailScreen(),
    '/requests': (context) => const RequestsScreen(),
  };

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
          borderSide: const BorderSide(color: kMid, width: 2),
        ),
        labelStyle: const TextStyle(color: kDark, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
