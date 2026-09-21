import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/features/lessons/lesson_page.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<StemLesson>> plans(AppLanguage language, int grade) async {
    final raw =
        await rootBundle.loadString(AppAssets.classLessons(grade, language));
    return StemClass.fromJson(jsonDecode(raw))
        .modules
        .singleWhere((module) => module.id == 'module-diagnostic')
        .themes
        .single
        .lessons
        .where((lesson) => lesson.exercises
            .any((exercise) => exercise.text('planAsset').isNotEmpty))
        .toList();
  }

  test('catalogs bundle reading plans but keep PDFs out of the APK', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(
        manifest.listAssets().where((path) => path.endsWith('.tex')), isEmpty);
    for (final language in AppLanguage.values) {
      for (final grade in [5, 6]) {
        final gradePlans = await plans(language, grade);
        expect(gradePlans.length, 2);
        for (final plan in gradePlans) {
          final exercise = plan.visibleExercises.single;
          final attachment = exercise.objectList('attachments').single;
          final path = attachment['path'] as String;
          expect(path, endsWith('.pdf'));
          expect(manifest.listAssets(), isNot(contains(path)));
          final document = jsonDecode(
            await rootBundle.loadString(exercise.text('planAsset')),
          );
          final sections = document['sections'] as List;
          final is48Hours = plan.id.contains('48-hours');
          final scheduleKey = is48Hours ? 'lessons' : 'weeks';
          final semesters = sections
              .where((section) => section[scheduleKey] != null)
              .toList();
          final schedule = semesters
              .expand((section) => section[scheduleKey] as List)
              .toList();
          expect(
            semesters.map((section) => (section[scheduleKey] as List)
                .map((entry) => entry['week'])
                .toSet()
                .length),
            [15, 17],
          );
          if (is48Hours) {
            expect(semesters.map((s) => (s['lessons'] as List).length),
                [22, 26]);
            expect(schedule.map((entry) => entry['lesson']),
                List.generate(48, (index) => index + 1));
            expect(schedule.map((entry) => entry['topic']).toSet().length, 48);
          } else {
            expect(semesters.map((s) => (s['weeks'] as List).length),
                [15, 17]);
            expect(schedule.map((entry) => entry['week']),
                List.generate(32, (index) => index + 1));
          }
          final total = schedule.fold<double>(
              0,
              (sum, entry) => sum +
                  double.parse(entry['hours'].replaceAll(',', '.')));
          expect(total, is48Hours ? 48 : 32);
          if (grade == 6) {
            expect(schedule.every((entry) => entry['referenceLabel'] == 'Програма'),
                isTrue);
          }
        }
      }
    }
  });

  testWidgets('plans fit a narrow screen with large text and one PDF button',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final grade in [5, 6]) {
      final loadedPlans =
          await tester.runAsync(() => plans(AppLanguage.ukrainian, grade));
      for (final plan in loadedPlans!) {
        await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.7)),
            child: child!,
          ),
          home: LessonPage(
            classNumber: grade,
            moduleTitle: 'Діагностувальні роботи',
            lesson: plan,
            isTeacher: false,
          ),
        ));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        expect(find.text('Завантажити'), findsOneWidget);
        expect(find.text('Пояснювальна записка'), findsOneWidget);
        expect(find.text('Календарно-тематичний план. ІІ семестр'),
            findsOneWidget);
        expect(
            find.text('STEM-фестиваль. Підсумкова рефлексія'), findsOneWidget);
        final expectedLessons = plan.id.contains('48-hours') ? 48 : 32;
        expect(find.textContaining('Тиждень '),
            findsNWidgets(expectedLessons));
        expect(find.textContaining('Урок '), plan.id.contains('48-hours')
            ? findsNWidgets(48)
            : findsNothing);
        expect(find.textContaining(grade == 6 ? 'Програма: с.' : 'Зошит: с.'),
            findsNWidgets(expectedLessons));
        expect(find.textContaining('LaTeX'), findsNothing);
        expect(find.byType(SegmentedButton<ExerciseViewMode>), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
