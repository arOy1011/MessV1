import 'package:flutter_test/flutter_test.dart';
import 'package:mess/main.dart';

void main() {
  testWidgets('app builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MessApp());
    await tester.pumpAndSettle();

    expect(find.text('Mess'), findsWidgets);
  });
}
