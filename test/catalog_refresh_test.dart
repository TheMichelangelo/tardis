import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/core/lesson_code.dart';
import 'package:stem_laboratory/data/storage/json_lesson_storage.dart';
import 'package:stem_laboratory/features/auth/auth_controller.dart';
import 'package:stem_laboratory/features/lessons/class_page.dart';
import 'package:stem_laboratory/models.dart';
import 'package:stem_laboratory/repository.dart';

Map<String, dynamic> _legacyCatalog() => {
      'modules': [
        {
          'id': '2',
          'title': 'Людина – людина',
          'themes': [
            {
              'id': 'forces-and-machines',
              'color': '#14B8A6',
              'lessons': [
                {
                  'id': 'simple-machines1',
                  'title': 'Я, мої таланти і захоплення',
                  'topic': 'Engineering',
                  'formats': ['competition', 'quiz'],
                  'exercises': [
                    {
                      'id': 'machines-text',
                      'label': 'Read text and answer',
                      'type': 'text',
                      'text': 'Simple machines',
                    },
                    {
                      'id': 'machines-video',
                      'label': 'Watch simple machines video',
                      'type': 'video',
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
      'lessons': [
        {'title': 'Мій локальний матеріал', 'text': 'Ґрунт, їжак, дослід'},
      ],
    };

Iterable<StemLesson> _lessons(StemClass data) =>
    data.modules.expand((m) => m.themes).expand((t) => t.lessons);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('refreshes a legacy saved catalog and keeps local materials', () async {
    const storage = JsonLessonStorage();
    final legacy = _legacyCatalog();
    await storage.write(6, 'ua', jsonEncode(legacy));

    final repository = LessonRepository(storage: storage);
    final data = await repository.load(6);
    expect(data.modules.map((m) => m.id),
        ['1', '2', 'module-human-nature', 'module-diagnostic']);
    final course = data.modules
        .where((m) => m.id != 'module-diagnostic')
        .expand((m) => m.themes)
        .expand((t) => t.lessons)
        .toList();
    expect(course, hasLength(15));
    for (final lesson in course) {
      expect(lesson.visibleExercises, hasLength(10), reason: lesson.title);
      expect(lesson.topic, 'STEM');
    }
    expect(data.generatedLessons, legacy['lessons']);
    final selected =
        await repository.loadShared(LessonCode.tryParse('6041023')!);
    expect(selected.lesson.title, 'Урок 4. Я, мої таланти і захоплення');
    expect(selected.lesson.visibleExercises, hasLength(10));
    final garden = await repository.loadShared(LessonCode.tryParse('6151023')!);
    expect(garden.lesson.id, 'garden-on-windowsill');
    // Reading the current catalog does not erase the saved snapshot.
    expect(jsonDecode((await storage.read(6, 'ua'))!), legacy);
  });

  test('retains custom lessons within published modules', () async {
    final legacy = _legacyCatalog();
    final module = (legacy['modules'] as List).single as Map;
    final theme = (module['themes'] as List).single as Map;
    (theme['lessons'] as List).add({
      'id': 'custom-class-project',
      'number': 98,
      'title': 'Наш власний проєкт',
      'topic': 'Ґрунт і вода',
      'exercises': [],
    });
    const storage = JsonLessonStorage();
    await storage.write(6, 'ua', jsonEncode(legacy));
    final data = await LessonRepository(storage: storage).load(6);
    final custom = _lessons(data).singleWhere((l) => l.number == 98);
    expect(custom.title, 'Наш власний проєкт');
    expect(custom.topic, 'Ґрунт і вода');
    expect(
        _lessons(data).where((l) => l.id == 'simple-machines1'), hasLength(1));
  });

  test('downloaded legacy JSON cannot override the bundled catalog', () async {
    final directory = await Directory.systemTemp.createTemp('stem-catalog-');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (call) async => call.method == 'getApplicationSupportDirectory'
                ? directory.path
                : null);
    addTearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await directory.delete(recursive: true);
    });
    final path = AppAssets.classLessons(6, AppLanguage.ukrainian);
    final file = File('${directory.path}/materials/$path');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(_legacyCatalog()));
    final data = await LessonRepository().load(6);
    expect(data.modules.any((m) => m.id == 'module-human-nature'), isTrue);
    expect(_lessons(data).singleWhere((l) => l.id == 'simple-machines1').topic,
        'STEM');
  });

  testWidgets('class page shows refreshed modules and ten exercises',
      (tester) async {
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const storage = JsonLessonStorage();
    await storage.write(6, 'ua', jsonEncode(_legacyCatalog()));
    final auth = AuthController();
    addTearDown(auth.dispose);
    await tester.pumpWidget(MaterialApp(
      home: ClassPage(6,
          repository: LessonRepository(storage: storage),
          authController: auth,
          language: AppLanguage.ukrainian),
    ));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('Людина — природа'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Людина – людина'));
    await tester.pumpAndSettle();
    expect(find.text('Урок 4. Я, мої таланти і захоплення'), findsOneWidget);
    expect(find.text('Тема уроку: Engineering'), findsNothing);
    expect(find.text('Вправи: 2'), findsNothing);
    expect(find.text('Вправи: 10'), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'Людина — природа'));
    await tester.pumpAndSettle();
    expect(find.text('Урок 11. Кімнатні рослини. Плануємо сад на підвіконні'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
