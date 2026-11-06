import 'package:flutter_test/flutter_test.dart';
import 'package:bank_mini_mobile/main.dart';

void main() {
  testWidgets('Bank Mini app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BankMiniApp());
    expect(find.byType(BankMiniApp), findsOneWidget);
  });
}
