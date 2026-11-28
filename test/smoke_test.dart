import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rmutp_campus_app/main.dart';
import 'package:rmutp_campus_app/providers/app_database_provider.dart';
import 'package:rmutp_campus_app/providers/role_provider.dart';
import 'package:rmutp_campus_app/screens/login_screen.dart';

Widget _buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RoleProvider()),
      ChangeNotifierProvider(create: (_) => AppDatabaseProvider()),
    ],
    child: const RMUTPApp(),
  );
}

void main() {
  testWidgets('app starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
