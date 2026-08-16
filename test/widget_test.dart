import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/app.dart';

void main() {
  testWidgets('home shows both supported classes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StemApp());
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Я вчитель'), findsOneWidget);
  });
}
