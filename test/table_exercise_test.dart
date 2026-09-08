import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/core/localization.dart';
import 'package:stem_laboratory/features/exercises/table_exercise.dart';

void main() {
  testWidgets('drag, check, replace and return table answers', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: TableExercise(
      columns: ['Name', 'Answer'],
      rows: ['One', 'Two'],
      values: ['First', 'Second'],
    ))));
    final first = find.byKey(const ValueKey('table-cell-0'));
    final second = find.byKey(const ValueKey('table-cell-1'));
    expect(find.byType(DragTarget<int>), findsNWidgets(2));
    await tester.dragFrom(tester.getCenter(find.text('Second')),
        tester.getCenter(first) - tester.getCenter(find.text('Second')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: first, matching: find.text('Second')),
        findsOneWidget);
    await tester.tap(find.text(AppStrings.get('tableCheck')));
    await tester.pump();
    expect(find.byIcon(Icons.cancel), findsNWidgets(2));
    final wrong = tester
        .widgetList<Container>(
            find.descendant(of: first, matching: find.byType(Container)))
        .where((c) => c.color == const Color(0xfffee2e2));
    expect(wrong, isNotEmpty);
    await tester.tap(find.text('First'));
    await tester.pump();
    await tester.tap(first);
    await tester.pump();
    expect(find.byIcon(Icons.cancel), findsNothing);
    await tester.tap(find.text('Second'));
    await tester.pump();
    await tester.tap(second);
    await tester.pump();
    await tester.tap(find.text(AppStrings.get('tableCheck')));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(
        tester
            .widgetList<Container>(
                find.descendant(of: first, matching: find.byType(Container)))
            .where((c) => c.color == const Color(0xffdcfce7)),
        isNotEmpty);
    await tester.tap(first);
    await tester.pump();
    expect(find.byType(Draggable<int>), findsOneWidget);
  });

  testWidgets('duplicate labels are interchangeable and rows can be generated',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: TableExercise(
      columns: ['A', 'B'],
      rows: [],
      values: ['Same', 'Same'],
    ))));
    await tester.tap(find.text('Same').last);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('table-cell-0')));
    await tester.pump();
    await tester.tap(find.byType(Draggable<int>).first);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('table-cell-1')));
    await tester.pump();
    await tester.tap(find.text(AppStrings.get('tableCheck')));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
  });
}
