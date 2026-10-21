import 'package:flutter_test/flutter_test.dart';
import 'package:rmutp_campus_app/main.dart';

void main() {
  testWidgets('app starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RMUTPApp());
    await tester.pumpAndSettle();

    expect(find.byType(RMUTPApp), findsOneWidget);
  });
}
