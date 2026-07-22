import 'package:flutter_test/flutter_test.dart';
import 'package:talabaty_app/app.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TalabatyApp());

    // Verify the widget tree builds successfully.
    expect(find.byType(TalabatyApp), findsOneWidget);

    // Pump out the splash delay timer so the test can end cleanly
    await tester.pump(const Duration(seconds: 3));
  });
}
