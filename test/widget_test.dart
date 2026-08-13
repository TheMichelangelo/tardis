import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/app.dart';

void main() {
  testWidgets('home shows both supported classes', (tester) async {
    await tester.pumpWidget(const StemApp());
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });
}
