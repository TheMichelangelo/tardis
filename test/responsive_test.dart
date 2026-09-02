import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/language_controller.dart';
import 'package:stem_laboratory/core/reading_settings.dart';
import 'package:stem_laboratory/core/responsive_layout.dart';
import 'package:stem_laboratory/features/auth/auth_controller.dart';
import 'package:stem_laboratory/features/exercises/exercise_card.dart';
import 'package:stem_laboratory/features/home/home_page.dart';
import 'package:stem_laboratory/features/lessons/lesson_page.dart';
import 'package:stem_laboratory/features/lessons/widgets/theme_tabs.dart';
import 'package:stem_laboratory/models.dart';

const _screens = [
  Size(320, 740),
  Size(740, 320),
  Size(768, 1024),
  Size(1366, 768),
  Size(1920, 1080),
];

Widget _app(ReadingSettings settings, Widget home, {double deviceScale = 1}) =>
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(deviceScale)),
        child: ReadingSettingsScope(settings: settings, child: child!),
      ),
      home: home,
    );

void _screen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

StemExercise _exercise(String type, Map<String, Object> data) =>
    StemExercise.fromJson({
      'id': type,
      'type': type,
      'label':
          'Досліджуємо світ навколо нас та пояснюємо результати спостережень',
      'formats': ['quiz', 'story', 'competition'],
      ...data,
    });

final _examples = [
  _exercise('text', {
    'text':
        'Опишіть природні явища та запропонуйте спосіб перевірити свою гіпотезу.',
    'questions': [
      'Які інструменти знадобляться для дослідження?',
      'Як порівняти результати?'
    ],
  }),
  _exercise('table', {
    'columns': [
      'Властивості досліджуваного матеріалу',
      'Результати спостереження',
      'Висновок'
    ],
    'rows': ['Папір і картон', 'Деревина'],
    'dataToFill': ['Міцність конструкції', 'Пружність'],
  }),
  _exercise('connect', {
    'text': 'Установіть відповідність між професіями та інструментами.',
    'column1Items': ['Інженер-конструктор', 'Учитель природничих наук'],
    'column2Items': [
      'Креслення та інструменти для вимірювання',
      'Обладнання для проведення дослідів'
    ],
  }),
  _exercise('interactive_quiz', {
    'questions': [
      {
        'question': 'Назвіть відомий вам напрям STEM.',
        'answerTypes': {'shortText': 'Наука'}
      },
      {
        'question': 'Що допомагає перевірити гіпотезу?',
        'answerTypes': {
          'singleChoice': [
            'Проведення дослідів та аналіз отриманих результатів',
            'Випадковий вибір відповіді'
          ],
          'shortText': 'Проведення дослідів та аналіз отриманих результатів',
        }
      },
    ],
  }),
  _exercise('homework', {
    'text': 'Підготуйте звіт про дослідження.',
    'studentPdf': 'student.pdf',
    'teacherPdf': 'teacher.pdf',
    'solution': 'Порівняйте отримані результати з початковою гіпотезою.',
  }),
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reading size persists and invalid saved values use the default',
      () async {
    final settings = ReadingSettings();
    await settings.select(ReadingSize.projector);
    final restored = ReadingSettings();
    await restored.initialize();
    expect(restored.size, ReadingSize.projector);
    SharedPreferences.setMockInitialValues({'stem_reading_size_v1': 'unknown'});
    await restored.initialize();
    expect(restored.size, ReadingSize.standard);
  });

  testWidgets(
      'home fits phones, landscape, tablets, laptops and projectors at all sizes',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = ReadingSettings();
    final auth = AuthController();
    final language = LanguageController();
    addTearDown(settings.dispose);
    addTearDown(auth.dispose);
    addTearDown(language.dispose);
    for (final size in _screens) {
      _screen(tester, size);
      for (final textSize in ReadingSize.values) {
        await settings.select(textSize);
        await tester.pumpWidget(_app(
            settings,
            HomePage(
              authController: auth,
              languageController: language,
              showAndroidDownload: true,
            )));
        await tester.pumpAndSettle();
        final apk =
            tester.getRect(find.byKey(const Key('download-android-apk')));
        expect(apk.left, lessThan(24));
        expect(apk.top, lessThan(24));
        expect(apk.right, lessThanOrEqualTo(size.width));
        final image = tester.getRect(find.byKey(const Key('home-stem-image')));
        expect(image.left, greaterThanOrEqualTo(0));
        expect(image.right, lessThanOrEqualTo(size.width));
        expect(image.height, lessThan(size.height));
        expect(tester.takeException(), isNull, reason: '$size / $textSize');
      }
    }
  });

  testWidgets('exercise layouts support each screen and text size',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = ReadingSettings();
    addTearDown(settings.dispose);
    for (final size in _screens) {
      _screen(tester, size);
      for (final textSize in ReadingSize.values) {
        await settings.select(textSize);
        for (final exercise in _examples) {
          await tester.pumpWidget(_app(
              settings,
              Scaffold(
                body: Builder(
                    builder: (context) => SingleChildScrollView(
                          padding: pagePadding(context),
                          child: ExerciseCard(
                              key: ValueKey(exercise.id),
                              lessonId: 'responsive',
                              exercise: exercise,
                              isTeacher: true),
                        )),
              )));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull,
              reason: '$size / $textSize / ${exercise.type}');
        }
      }
    }
  });

  testWidgets(
      'size menu has three choices, preserves answers and respects device scaling',
      (tester) async {
    _screen(tester, const Size(768, 1024));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = ReadingSettings();
    addTearDown(settings.dispose);
    final lesson = StemLesson(
      id: 'responsive',
      title: 'Урок STEM',
      topic: 'Дослідження',
      formats: const [LessonFormat.quiz],
      exercises: [_examples[3]],
    );
    await tester.pumpWidget(_app(
        settings,
        LessonPage(
          classNumber: 5,
          moduleTitle: 'Вступ',
          lesson: lesson,
          isTeacher: false,
        ),
        deviceScale: 1.2));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Наука');
    await tester.tap(find.byType(TextSizeButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<ReadingSize>), findsNWidgets(3));
    await tester.tap(find.text('Для проєктора'));
    await tester.pumpAndSettle();
    expect(settings.size, ReadingSize.projector);
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .controller
            .text,
        'Наука');
    final context = tester.element(find.byType(ExerciseCard));
    expect(MediaQuery.textScalerOf(context).scale(16),
        closeTo(16 * 1.2 * 1.7, .01));
    _screen(tester, const Size(320, 740));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
        find.byType(TextField), find.byType(ListView), const Offset(0, -200));
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .controller
            .text,
        'Наука');
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow module selector can change modules with large text',
      (tester) async {
    _screen(tester, const Size(320, 740));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = ReadingSettings();
    addTearDown(settings.dispose);
    await settings.select(ReadingSize.projector);
    final tabs = [
      for (var i = 1; i <= 2; i++)
        ThemeTab(
          module: StemModule(
              id: '$i',
              title: 'Модуль $i. Дослідження природи',
              themes: const []),
          theme: StemTheme(id: '$i', color: '#2563eb', lessons: const []),
        ),
    ];
    var selected = 0;
    await tester.pumpWidget(_app(
        settings,
        Scaffold(
          body: SingleChildScrollView(
              child: StatefulBuilder(
                  builder: (context, setState) => ThemeTabs(
                        tabs: tabs,
                        selectedIndex: selected,
                        onSelected: (index) => setState(() => selected = index),
                      ))),
        )));
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(tabs[1].module.title));
    await tester.tap(find.text(tabs[1].module.title));
    await tester.pumpAndSettle();
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('table answers survive font and viewport changes',
      (tester) async {
    _screen(tester, const Size(768, 1024));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = ReadingSettings();
    addTearDown(settings.dispose);
    await tester.pumpWidget(_app(
        settings,
        Scaffold(
          body: SingleChildScrollView(
              child: ExerciseCard(
            lessonId: 'table',
            exercise: _examples[1],
            isTeacher: false,
          )),
        )));
    await tester.enterText(find.byType(TextField).first, 'Міцний матеріал');
    await settings.select(ReadingSize.projector);
    _screen(tester, const Size(320, 740));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .controller
            .text,
        'Міцний матеріал');
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise diagrams open fullscreen and support zoom controls',
      (tester) async {
    _screen(tester, const Size(320, 740));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = ReadingSettings();
    addTearDown(settings.dispose);
    await settings.select(ReadingSize.projector);
    const lesson = 'lesson-1-shcho-take-stem-osvita-yaki-buvayut-prof';
    final diagram = StemExercise.fromJson({
      'id': '$lesson-ex-2',
      'label': 'Схема STEM',
      'type': 'diagram',
      'imageExt': 'png',
    });
    await tester.pumpWidget(_app(
        settings,
        Scaffold(
          body: SingleChildScrollView(
              child: ExerciseCard(
                  lessonId: lesson, exercise: diagram, isTeacher: false)),
        )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Збільшити зображення'));
    await tester.tap(find.text('Збільшити зображення'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byTooltip('Збільшити'));
    await tester.pumpAndSettle();
    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1.5);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
