import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rmutp_campus_app/main.dart';
import 'package:rmutp_campus_app/providers/app_database_provider.dart';
import 'package:rmutp_campus_app/providers/role_provider.dart';
import 'package:rmutp_campus_app/screens/grades_screen.dart';
import 'package:rmutp_campus_app/screens/home_screen.dart';
import 'package:rmutp_campus_app/screens/login_screen.dart';
import 'package:rmutp_campus_app/screens/timetable_screen.dart';
import 'package:rmutp_campus_app/services/database_service.dart';

AppDatabaseProvider _makeProvider() => AppDatabaseProvider();

Widget _buildTestApp(AppDatabaseProvider db) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RoleProvider()),
      ChangeNotifierProvider<AppDatabaseProvider>.value(value: db),
    ],
    child: const RMUTPApp(),
  );
}

AuthenticatedUserSession _studentSession() => AuthenticatedUserSession(
      email: 's650602001@rmutp.ac.th',
      role: 'student',
      studentId: '650602001',
      displayName: 'น.ส.มินตรา ใจดี',
      subtitleInfo: '650602001 • วิศวกรรมคอมพิวเตอร์ ปี 2',
    );

void main() {
  group('Auth guard: ต้องล็อกอินก่อนเข้าแอป', () {
    testWidgets('ยังไม่ล็อกอิน แม้ pushNamed /home ก็ยังอยู่หน้า login',
        (WidgetTester tester) async {
      final db = _makeProvider();
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(db.currentUser, isNull);

      // พยายามข้ามไปหน้า home โดยตรง ต้องถูกกันกลับมา login
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/home');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('ล็อกอินแล้ว navigate ไป home และหน้าอื่นได้',
        (WidgetTester tester) async {
      final db = _makeProvider();
      await tester.pumpWidget(_buildTestApp(db));
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsOneWidget);

      // จำลอง session หลังล็อกอินสำเร็จ (ไม่ยิง network ในเทส)
      db.currentUser = _studentSession();
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushReplacementNamed('/home');
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('ตารางเรียน').first);
      await tester.pumpAndSettle();
      expect(find.byType(TimetableScreen), findsOneWidget);

      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('ผลการเรียน').first);
      await tester.pumpAndSettle();
      expect(find.byType(GradesScreen), findsOneWidget);
    });
  });
}
