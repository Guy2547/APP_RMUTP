import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rmutp_campus_app/main.dart';
import 'package:rmutp_campus_app/providers/role_provider.dart';
import 'package:rmutp_campus_app/screens/grades_screen.dart';
import 'package:rmutp_campus_app/screens/home_screen.dart';
import 'package:rmutp_campus_app/screens/timetable_screen.dart';

void main() {
  group('System: login and navigate between screens', () {
    testWidgets('login then navigate to home', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => RoleProvider(),
          child: const RMUTPApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsOneWidget);

      await tester.tap(find.text('เข้าสู่ระบบ').first);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('navigate from home to timetable, courses, grades',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => RoleProvider(),
          child: const RMUTPApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('เข้าสู่ระบบ').first);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('ตารางเรียน').first);
      await tester.pumpAndSettle();
      expect(find.byType(TimetableScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('ผลการเรียน').first);
      await tester.pumpAndSettle();
      expect(find.byType(GradesScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('เช็คชื่อ').first);
      await tester.pumpAndSettle();
    });
  });
}
