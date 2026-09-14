import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/core/lesson_code.dart';
import 'package:stem_laboratory/data/storage/json_lesson_storage.dart';
import 'package:stem_laboratory/models.dart';
import 'package:stem_laboratory/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final repository = LessonRepository();

  test('old saved catalogs recover stable numbers and hidden slots', () async {
    final json = jsonDecode(await rootBundle
        .loadString(AppAssets.classLessons(5, AppLanguage.ukrainian)));
    for (final module in json['modules']) {
      for (final theme in module['themes']) {
        for (final lesson in theme['lessons']) {
          lesson.remove('number');
          final key =
              lesson.containsKey('exercises') ? 'exercises' : 'exersices';
          lesson[key]
              .removeWhere((exercise) => exercise['isPlaceholder'] == true);
        }
      }
    }
    final storage = JsonLessonStorage();
    await storage.write(5, 'ua', jsonEncode(json));
    final shared = await LessonRepository(storage: storage)
        .loadShared(LessonCode.tryParse('5010005')!);
    expect(shared.lesson.number, 1);
    expect(shared.lesson.exercises, hasLength(10));
    expect(shared.lesson.visibleExercises, hasLength(2));
  });

  test('every catalog has ten slots and stable numbers across translations',
      () async {
    for (final grade in [5, 6, 7]) {
      final idsByNumber = <int, String>{};
      for (final language in AppLanguage.values) {
        final data = await repository.load(grade, language: language);
        final numbers = <int>{};
        for (final lesson
            in data.modules.expand((m) => m.themes).expand((t) => t.lessons)) {
          expect(lesson.exercises, hasLength(10), reason: lesson.id);
          expect(lesson.number, inInclusiveRange(1, 99));
          expect(numbers.add(lesson.number!), isTrue);
          expect(idsByNumber.putIfAbsent(lesson.number!, () => lesson.id),
              lesson.id);
          for (final format in LessonFormat.values) {
            expect(lesson.exercisesFor(format).any((e) => e.isPlaceholder),
                isFalse);
          }
        }
      }
    }
  });

  test('a shared Ukrainian lesson opens from an English interface', () async {
    final shared = await repository.loadShared(LessonCode.tryParse('5010005')!,
        language: AppLanguage.english);
    expect(shared.lesson.number, 1);
    expect(
        shared.lesson.id, 'lesson-1-shcho-take-stem-osvita-yaki-buvayut-prof');
    expect(shared.lesson.visibleExercises.map((e) => e.id), [
      '${shared.lesson.id}-ex-1',
      '${shared.lesson.id}-ex-3',
    ]);
  });

  test('unknown lessons and selections containing only placeholders fail',
      () async {
    for (final code in ['5990001', '7010001', '5040512']) {
      await expectLater(repository.loadShared(LessonCode.tryParse(code)!),
          throwsFormatException);
    }
  });

  for (final language in AppLanguage.values) {
    for (final classNumber in [5, 6]) {
      test('loads class $classNumber in ${language.code}', () async {
        final stemClass = await repository.load(
          classNumber,
          language: language,
        );

        expect(stemClass.modules, isNotEmpty);
      });
    }
  }

  for (final language in AppLanguage.values) {
    test('class 7 has an empty template in ${language.code}', () async {
      final data = await repository.load(7, language: language);
      expect(data.modules, isEmpty);
      expect(data.generatedLessons, isEmpty);
    });
  }

  test('rejects an unsupported class number', () {
    expect(
      () => repository.load(8),
      throwsA(isA<LessonLoadException>()),
    );
  });

  test('Ukrainian classes include the diagnostic works theme', () async {
    final class5 = await repository.load(5);
    final class6 = await repository.load(6);

    expect(
      class5.modules.any((module) => module.id == 'module-diagnostic'),
      isTrue,
    );

    final diagnosticModule = class6.modules.singleWhere(
      (module) => module.id == 'module-diagnostic',
    );
    final lesson = diagnosticModule.themes.single.lessons.singleWhere(
      (lesson) => lesson.id == 'diagnostic-5-residual-knowledge',
    );
    final exercise = lesson.visibleExercises.single;

    expect(lesson.id, 'diagnostic-5-residual-knowledge');
    expect(exercise.text('studentPdf'), endsWith('.pdf'));
    expect(exercise.text('teacherPdf'), endsWith('_answers.pdf'));
  });

  test('Ukrainian lesson text is decoded as UTF-8', () async {
    final stemClass = await repository.load(5);
    final text = stemClass.modules
        .expand((module) => module.themes)
        .expand((theme) => theme.lessons)
        .map((lesson) => '${lesson.title} ${lesson.topic}')
        .join(' ');

    expect(text, contains(RegExp(r'[іїєґІЇЄҐ]')));
    expect(text, isNot(contains('Ð')));
  });
}
