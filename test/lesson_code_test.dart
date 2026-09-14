import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/core/app_routes.dart';
import 'package:stem_laboratory/core/lesson_code.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  final lesson = StemLesson.fromJson({
    'id': 'ten',
    'number': 1,
    'exercises': [
      for (var i = 0; i < 10; i++)
        {'id': 'exercise-$i', 'type': i == 1 ? 'homework' : 'text'},
    ],
  });

  test('all 1023 nonempty selections round trip with stable slot positions',
      () {
    final codes = <String>{};
    for (var mask = 1; mask <= 1023; mask++) {
      final code =
          LessonCode(classNumber: 5, lessonNumber: 1, exerciseMask: mask);
      expect(code.toString().length, 7);
      expect(codes.add(code.toString()), isTrue);
      final parsed = LessonCode.tryParse(code.toString())!;
      expect(parsed.classNumber, 5);
      expect(parsed.lessonNumber, 1);
      expect(parsed.exerciseMask, mask);
      final selected = parsed.selectExercises(lesson);
      final ids = {
        for (var slot = 0; slot < 10; slot++)
          if ((mask & (1 << slot)) != 0) 'exercise-$slot',
      };
      expect(selected.exercises, hasLength(10));
      for (final format in LessonFormat.values) {
        expect(selected.exercisesFor(format).map((e) => e.id).toSet(), ids);
      }
    }
  });

  test('uses leading zeroes and supports exercise 10 and the full lesson', () {
    expect(
        LessonCode(classNumber: 6, lessonNumber: 2, exerciseMask: 5).toString(),
        '6020005');
    expect(
        LessonCode.tryParse(' 5990512 ')!
            .selectExercises(lesson)
            .visibleExercises
            .single
            .id,
        'exercise-9');
    expect(
        LessonCode.tryParse('5011023')!
            .selectExercises(lesson)
            .visibleExercises,
        hasLength(10));
  });

  test('rejects malformed codes, empty masks and masks beyond ten bits', () {
    for (final value in [
      '',
      '501005',
      '50100000',
      '50100a5',
      '501 005',
      '8010001',
      '5000001',
      '5010000',
      '5011024',
      '5019999',
      '５０１０００５'
    ]) {
      expect(LessonCode.tryParse(value), isNull, reason: value);
    }
  });

  test('placeholder positions never enter generated masks', () {
    final padded = StemLesson.fromJson({
      'id': 'padded',
      'exercises': [
        {'id': 'first', 'type': 'text'},
        {'id': 'placeholder', 'type': 'text', 'isPlaceholder': true},
        {'id': 'third', 'type': 'text'},
      ],
    });
    expect(LessonCode.availableMask(padded), 5);
    final selected = LessonCode.tryParse('5011023')!.selectExercises(padded);
    expect(selected.visibleExercises.map((e) => e.id), ['first', 'third']);
  });

  test('shared links preserve the host base path and load from the site root',
      () {
    final cases = {
      'https://example.com/': 'https://example.com/?lessonCode=5010005',
      'https://example.com/class/5/module/a/lesson/b':
          'https://example.com/?lessonCode=5010005',
      'https://example.com/tardis/class/5/module/a/lesson/b?old=1#test':
          'https://example.com/tardis/?lessonCode=5010005',
      'https://example.com/tardis/':
          'https://example.com/tardis/?lessonCode=5010005',
      'https://example.com/tardis/index.html':
          'https://example.com/tardis/?lessonCode=5010005',
    };
    for (final entry in cases.entries) {
      expect(
          AppRoutes.sharedLessonLink('5010005', baseUri: Uri.parse(entry.key))
              .toString(),
          entry.value);
    }
    expect(AppRoutes.sharedLesson('5010005'), '/?lessonCode=5010005');
  });
}
