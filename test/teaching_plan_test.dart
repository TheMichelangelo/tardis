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

  test('both language catalogs bundle PDFs and complete reading plans, no TeX',
      () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(
        manifest.listAssets().where((path) => path.endsWith('.tex')), isEmpty);
    for (final language in AppLanguage.values) {
      for (final grade in [5, 6]) {
        final gradePlans = await plans(language, grade);
        expect(gradePlans.length, 2);
        for (final plan in gradePlans) {
          final exercise = plan.exercises.single;
          final attachment = exercise.objectList('attachments').single;
          final path = attachment['path'] as String;
          expect(path, endsWith('.pdf'));
          final bytes = await rootBundle.load(path);
          expect(ascii.decode(bytes.buffer.asUint8List(0, 5)), '%PDF-');
          final document = jsonDecode(
            await rootBundle.loadString(exercise.text('planAsset')),
          );
          final sections = document['sections'] as List;
          final semesters =
              sections.where((section) => section['weeks'] != null);
          expect(semesters.map((s) => (s['weeks'] as List).length), [15, 17]);
          final weeks = semesters.expand((s) => s['weeks'] as List).toList();
          expect(weeks.map((w) => w['week']), List.generate(32, (i) => i + 1));
          final total = weeks.fold<double>(
              0,
              (sum, week) =>
                  sum + double.parse(week['hours'].replaceAll(',', '.')));
          expect(total, plan.id.contains('32-hours') ? 32 : 48);
          if (grade == 6) {
            expect(weeks.every((week) => week['referenceLabel'] == 'Програма'),
                isTrue);
          }
        }
      }
    }
  });

  testWidgets('plans open for reading with one PDF button on a narrow screen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final grade in [5, 6]) {
      final loadedPlans =
          await tester.runAsync(() => plans(AppLanguage.ukrainian, grade));
      for (final plan in loadedPlans!) {
        await tester.pumpWidget(MaterialApp(
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
        expect(find.textContaining('Тиждень '), findsNWidgets(32));
        expect(find.textContaining(grade == 6 ? 'Програма: с.' : 'Зошит: с.'),
            findsNWidgets(32));
        expect(find.textContaining('LaTeX'), findsNothing);
        expect(find.byType(SegmentedButton<ExerciseViewMode>), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
