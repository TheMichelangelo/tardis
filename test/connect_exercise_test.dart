import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/core/localization.dart';
import 'package:stem_laboratory/features/exercises/exercise_content.dart';
import 'package:stem_laboratory/models.dart';

Widget exercise({String id = 'one', int count = 2}) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ExerciseContent(
            lessonId: 'lesson',
            isTeacher: false,
            exercise: StemExercise.fromJson({
              'id': id,
              'type': 'connect',
              'column1Items': List.generate(count, (i) => 'Question $i'),
              'column2Items': List.generate(count, (i) => 'Answer $i'),
            }),
          ),
        ),
      ),
    );

void main() {
  testWidgets('answers change rows and keep their order during interaction',
      (tester) async {
    for (final count in [0, 1, 2, 5]) {
      await tester.pumpWidget(exercise(id: 'size-$count', count: count));
      List<String> order() => tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((tile) => (tile.title! as Text).data!)
          .where((text) => text.startsWith('Answer'))
          .toList();
      final initial = order();
      expect(initial.toSet().length, count);
      if (count > 1) {
        for (var i = 0; i < count; i++) {
          expect(initial[i], isNot('Answer $i'));
        }
      }
      if (count > 0) {
        await tester.tap(find.byKey(const ValueKey('connect-left-0')));
        await tester.pump();
        expect(order(), initial);
        await tester.tap(find.byKey(const ValueKey('connect-right-0')));
        await tester.pump();
        expect(order(), initial);
        await tester.ensureVisible(find.text(AppStrings.get('connectReset')));
        await tester.tap(find.text(AppStrings.get('connectReset')));
        await tester.pump();
        expect(order(), initial);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('pairs are visible immediately, replaceable, scored and reset',
      (tester) async {
    await tester.pumpWidget(exercise());
    Future<void> tap(String side, int index) async {
      await tester.tap(find.byKey(ValueKey('connect-$side-$index')));
      await tester.pump();
    }

    await tap('right', 0);
    expect(find.byType(CircleAvatar), findsNothing);
    await tap('left', 0);
    await tap('right', 1);
    expect(find.byType(CircleAvatar), findsNWidgets(2));
    expect(find.text('1'), findsNWidgets(2));
    expect(find.byIcon(Icons.cancel), findsNothing);

    // Reusing a right item removes its previous pair.
    await tap('left', 1);
    await tap('right', 1);
    expect(find.byType(CircleAvatar), findsNWidgets(2));
    expect(find.text('2'), findsNWidgets(2));
    await tap('left', 0);
    await tap('right', 0);
    expect(
        find.text('${AppStrings.get('correctPairs')}: 2 / 2'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(4));

    await tester.tap(find.text(AppStrings.get('connectReset')));
    await tester.pump();
    expect(find.byType(CircleAvatar), findsNothing);
    await tap('left', 0);
    await tap('right', 1);
    await tap('left', 1);
    await tap('right', 0);
    expect(
        find.text('${AppStrings.get('correctPairs')}: 0 / 2'), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsNWidgets(4));

    await tester.pumpWidget(exercise(id: 'two'));
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byIcon(Icons.cancel), findsNothing);
  });
}
