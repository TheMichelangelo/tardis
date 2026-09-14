import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/app.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/core/localization.dart';
import 'package:stem_laboratory/features/exercises/exercise_card.dart';
import 'package:stem_laboratory/features/lessons/lesson_page.dart';
import 'package:stem_laboratory/features/lessons/lesson_share_dialog.dart';
import 'package:stem_laboratory/features/lessons/widgets/lesson_card.dart';
import 'package:stem_laboratory/models.dart';
import 'package:stem_laboratory/repository.dart';

final _lesson = StemLesson.fromJson({
  'id': 'selection-test',
  'number': 1,
  'title': 'Тестовий урок',
  'topic': 'Тестовий урок',
  'formats': ['story', 'quiz'],
  'exercises': [
    {
      'id': 'first',
      'label': 'Перша вправа',
      'type': 'text',
      'text': 'Матеріал 1',
      'solution': 'Розв’язок'
    },
    {
      'id': 'homework',
      'label': 'Домашня вправа',
      'type': 'homework',
      'text': 'Матеріал 2'
    },
    {
      'id': 'third',
      'label': 'Третя вправа',
      'type': 'text',
      'text': 'Матеріал 3'
    },
  ],
});

class _Repository extends LessonRepository {
  @override
  Future<StemClass> load(int classNumber,
          {AppLanguage language = AppLanguage.ukrainian}) async =>
      StemClass(modules: [
        StemModule(id: 'module', title: 'Модуль', themes: [
          StemTheme(id: 'theme', color: '#2563eb', lessons: [_lesson]),
        ])
      ]);
}

void main() {
  setUp(() {
    AppStrings.setLanguage(AppLanguage.ukrainian);
    SharedPreferences.setMockInitialValues(
        {'app_role_v1': 'student', 'student_class_v1': 5});
  });

  testWidgets('teacher selects, copies and clears only real exercises',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? clipboard;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = call.arguments['text'];
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(MaterialApp(
        home: LessonPage(
            classNumber: 5,
            moduleTitle: 'Модуль',
            lesson: _lesson,
            isTeacher: true)));
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    expect(find.text('5010007'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('share-exercise-homework')));
    await tester.pumpAndSettle();
    expect(find.text('5010005'), findsOneWidget);
    await tester.tap(find.text('Копіювати код'));
    await tester.pumpAndSettle();
    expect(clipboard, '5010005');
    await tester.tap(find.text('Копіювати посилання'));
    await tester.pumpAndSettle();
    expect(Uri.parse(clipboard!).queryParameters['lessonCode'], '5010005');
    await tester.tap(find.text('Зняти вибір'));
    await tester.pumpAndSettle();
    expect(find.text('Оберіть хоча б одну вправу.'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Копіювати код'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home code entry routes to only selected exercises in every view',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(StemApp(repository: _Repository()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('lesson-code-input')));
    await tester.enterText(
        find.byKey(const Key('lesson-code-input')), '5010000');
    await tester.tap(find.byKey(const Key('open-lesson-code')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.get('invalidLessonCode')), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('lesson-code-input')), '5010005');
    await tester.tap(find.byKey(const Key('open-lesson-code')));
    await tester.pumpAndSettle();
    expect(find.text('Перша вправа'), findsOneWidget);
    expect(find.text('Домашня вправа'), findsNothing);
    expect(find.byIcon(Icons.share), findsNothing);
    expect(find.byIcon(Icons.print), findsNothing);
    expect(find.text('Показати розв’язок'), findsNothing);
    expect(find.textContaining('1 / 2'), findsOneWidget);
    await tester.tap(find.text('Далі'));
    await tester.pumpAndSettle();
    expect(find.text('Третя вправа'), findsOneWidget);
    await tester.tap(find.text('Показати всі вправи'));
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseCard), findsNWidgets(2));
    await tester.tap(find.text('Тест'));
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseCard), findsNWidgets(2));
    expect(find.text('Домашня вправа'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct link restores the selection after a fresh app start',
      (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/?lessonCode=5010004';
    addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
    await tester.pumpWidget(StemApp(repository: _Repository()));
    await tester.pumpAndSettle();
    expect(find.text('Третя вправа'), findsOneWidget);
    expect(find.text('Перша вправа'), findsNothing);
    expect(find.text('Домашня вправа'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid direct link shows recovery actions', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/?lessonCode=invalid';
    addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
    await tester.pumpWidget(StemApp(repository: _Repository()));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.get('lessonCodeNotFound')), findsOneWidget);
    await tester.tap(find.text('На головну'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson-code-input')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('share dialog fits narrow phones with enlarged text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.7)),
          child: child!),
      home: Scaffold(
          body: LessonShareDialog(
              classNumber: 5,
              lesson: _lesson,
              initialMask: 5,
              onSelectionChanged: (_) {})),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'lesson card counts real exercises and placeholder cards are empty',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      LessonCard(lesson: _lesson, onTap: () {}),
      ExerciseCard(
          lessonId: _lesson.id,
          exercise: _lesson.exercises.last,
          isTeacher: true),
    ]))));
    expect(find.text('Вправи: 3'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
