import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/core/app_theme.dart';
import 'package:stem_laboratory/core/localization.dart';
import 'package:stem_laboratory/features/exercises/exercise_card.dart';
import 'package:stem_laboratory/features/exercises/quiz_question.dart';
import 'package:stem_laboratory/features/home/lesson_code_entry.dart';
import 'package:stem_laboratory/models.dart';
import 'package:stem_laboratory/repository.dart';

import 'support/unicode_fixture.dart';

const _captureKey = Key('unicode-golden');
// Pixel rasterization differs between macOS and Ubuntu; keep cross-platform
// semantic/layout assertions mandatory and make pixel goldens opt-in.
const _runPixelGoldens = bool.fromEnvironment('RUN_UNICODE_GOLDENS');

// Ahem (Flutter's default test font) draws boxes, so it cannot verify Cyrillic.
// Load checked-in fonts explicitly and fix the platform, locale and surface.
Future<void> _loadFonts() async {
  final loader = FontLoader('UnicodeTestNotoSans')
    ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
  await loader.load();
  await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
      .load();
}

Future<void> _pumpSurface(WidgetTester tester, Widget child,
    {required double width, double textScale = 1}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final theme = AppTheme.light.copyWith(
    platform: TargetPlatform.android,
    textTheme:
        AppTheme.light.textTheme.apply(fontFamily: 'UnicodeTestNotoSans'),
    primaryTextTheme: AppTheme.light.primaryTextTheme
        .apply(fontFamily: 'UnicodeTestNotoSans'),
  );
  await tester.pumpWidget(MaterialApp(
    theme: theme,
    locale: const Locale('en', 'US'),
    debugShowCheckedModeBanner: false,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _captureKey,
          child: ColoredBox(
            color: AppTheme.pageBackground,
            child: Padding(padding: const EdgeInsets.all(12), child: child),
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void _expectUnclippedText(WidgetTester tester) {
  final capture = find.byKey(_captureKey);
  final bounds = tester.getRect(capture);
  expect(bounds.bottom, lessThanOrEqualTo(1600));
  for (final element in find
      .descendant(of: capture, matching: find.byType(RichText))
      .evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    expect(paragraph.didExceedMaxLines, isFalse,
        reason: paragraph.text.toPlainText());
    final origin = paragraph.localToGlobal(Offset.zero);
    expect(origin.dx, greaterThanOrEqualTo(bounds.left));
    expect(origin.dx + paragraph.size.width, lessThanOrEqualTo(bounds.right));
  }
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppStrings.setLanguage(AppLanguage.ukrainian);
  });
  tearDown(() => AppStrings.setLanguage(AppLanguage.ukrainian));

  for (final scenario in [
    (name: 'student_phone', width: 390.0, scale: 1.0, teacher: false),
    (name: 'teacher_desktop', width: 760.0, scale: 1.0, teacher: true),
    (name: 'teacher_large_phone', width: 390.0, scale: 1.7, teacher: true),
  ]) {
    testWidgets('saved Ukrainian text renders correctly: ${scenario.name}',
        (tester) async {
      final exercise = await tester.runAsync(() async {
        await LessonRepository()
            .save(5, StemClass.fromJson(unicodeCatalog('Текст')));
        final restored = await LessonRepository().load(5);
        return restored
            .modules.single.themes.single.lessons.single.visibleExercises.first;
      });
      await _pumpSurface(
          tester,
          ExerciseCard(
            lessonId: 'unicode-lesson',
            exercise: exercise!,
            isTeacher: scenario.teacher,
          ),
          width: scenario.width,
          textScale: scenario.scale);

      expect(find.text(unicodeLabel), findsOneWidget);
      expect(find.text(unicodeBody), findsOneWidget);
      expect(find.text(unicodeQuestion), findsOneWidget);
      expect(find.text(unicodeSolution), findsNothing);
      if (scenario.teacher) {
        await tester.tap(find.text(AppStrings.get('showSolution')));
        await tester.pumpAndSettle();
        expect(find.text(unicodeSolution), findsOneWidget);
      } else {
        expect(find.text(AppStrings.get('showSolution')), findsNothing);
      }
      _expectUnclippedText(tester);
      if (_runPixelGoldens) {
        await expectLater(find.byKey(_captureKey),
            matchesGoldenFile('goldens/unicode_${scenario.name}.png'));
      }
    });
  }

  testWidgets('Ukrainian code-entry labels fit a small screen with large text',
      (tester) async {
    await _pumpSurface(tester, const LessonCodeEntry(),
        width: 320, textScale: 1.7);
    expect(find.text('Відкрити урок за кодом'), findsOneWidget);
    expect(find.text('Код уроку'), findsOneWidget);
    expect(find.text('Відкрити урок'), findsOneWidget);
    _expectUnclippedText(tester);
    if (_runPixelGoldens) {
      await expectLater(find.byKey(_captureKey),
          matchesGoldenFile('goldens/unicode_code_entry_large_phone.png'));
    }
  });

  testWidgets(
      'typed Ukrainian answers retain exact characters after submission',
      (tester) async {
    const answer = 'Ґанок, Єнот, Іній, Їжак — п’ять / пʼять / п\'ять';
    await _pumpSurface(
        tester,
        const QuizQuestion({
          'question': 'Повторіть українські слова',
          'answerTypes': {'shortText': answer},
        }),
        width: 390);
    await tester.enterText(find.byType(TextField), answer);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final input = tester.widget<EditableText>(find.byType(EditableText));
    expect(input.controller.text.runes, answer.runes);
    expect(
        find.text(
            'Правильно\nПравильна відповідь: $answer\nВаш вибір: $answer'),
        findsOneWidget);
    _expectUnclippedText(tester);
  });
}
