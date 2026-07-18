import 'package:flutter_test/flutter_test.dart';
import 'package:talabaty_app/app.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TalabatyApp());

    // Verify the widget tree builds successfully.
    expect(find.byType(TalabatyApp), findsOneWidget);
  });
}
