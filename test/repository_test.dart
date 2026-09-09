import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final repository = LessonRepository();

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
    final exercise = lesson.exercises.single;

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
