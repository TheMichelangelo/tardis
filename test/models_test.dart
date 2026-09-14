import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  group('StemLesson parsing', () {
    test('pads empty slots and hides them from every format', () {
      final lesson = StemLesson.fromJson({
        'id': 'padded',
        'number': 27,
        'exercises': [
          {'id': 'first', 'type': 'text', 'text': 'Visible'},
        ],
      });
      expect(lesson.exercises, hasLength(10));
      expect(lesson.exercises.map((e) => e.id).toSet(), hasLength(10));
      expect(lesson.visibleExercises.single.id, 'first');
      for (final format in LessonFormat.values) {
        expect(lesson.exercisesFor(format).single.id, 'first');
      }
      final restored = StemLesson.fromJson(lesson.toJson());
      expect(restored.exercises, hasLength(10));
      expect(restored.exercises.where((e) => e.isPlaceholder), hasLength(9));
      expect(restored.number, 27);
      expect(StemLesson.fromJson({'id': 'empty'}).visibleExercises, isEmpty);
    });

    test('rejects an eleventh exercise without silently losing content', () {
      expect(
        () => StemLesson.fromJson({
          'exercises': List.generate(11, (i) => {'id': '$i', 'type': 'text'}),
        }),
        throwsFormatException,
      );
    });

    test('supports legacy exersices key and normalizes flashcards', () {
      final lesson = StemLesson.fromJson({
        'id': 'lesson-1',
        'title': 'Lesson',
        'topic': 'Topic',
        'formats': ['flashcards'],
        'exersices': [
          {
            'id': 'exercise-1',
            'label': 'Quiz',
            'type': 'interactive_quiz',
            'formats': ['flashcards'],
          },
        ],
      });

      expect(lesson.formats, [LessonFormat.competition]);
      expect(lesson.visibleExercises.single.type, ExerciseType.interactiveQuiz);
      expect(
        lesson.exercisesFor(LessonFormat.competition),
        hasLength(1),
      );
    });

    test('always includes homework in a filtered lesson', () {
      final lesson = StemLesson.fromJson({
        'id': 'lesson-1',
        'title': 'Lesson',
        'topic': 'Topic',
        'formats': ['quiz'],
        'exercises': [
          {
            'id': 'homework-1',
            'label': 'Homework',
            'type': 'homework',
            'formats': ['story'],
          },
        ],
      });

      expect(lesson.exercisesFor(LessonFormat.quiz), hasLength(1));
    });

    test('always displays homework after the other visible exercises', () {
      final lesson = StemLesson.fromJson({
        'id': 'lesson-1',
        'title': 'Lesson',
        'topic': 'Topic',
        'formats': ['story'],
        'exercises': [
          {
            'id': 'homework-1',
            'label': 'Homework 1',
            'type': 'homework',
            'formats': ['story'],
          },
          {
            'id': 'text-1',
            'label': 'Text',
            'type': 'text',
            'formats': ['story'],
          },
          {
            'id': 'homework-2',
            'label': 'Homework 2',
            'type': 'homework',
            'formats': ['story'],
          },
          {
            'id': 'quiz-1',
            'label': 'Quiz',
            'type': 'interactive_quiz',
            'formats': ['story'],
          },
        ],
      });

      expect(
        lesson.exercisesFor(LessonFormat.story).map((exercise) => exercise.id),
        ['text-1', 'quiz-1', 'homework-1', 'homework-2'],
      );
    });

    test('round trip preserves teacher solution and exercise formats', () {
      final lesson = StemLesson.fromJson({
        'id': 'lesson-1',
        'title': 'Lesson',
        'topic': 'Topic',
        'formats': ['story'],
        'exercises': [
          {
            'id': 'exercise-1',
            'label': 'Question',
            'type': 'text',
            'formats': ['story'],
            'text': 'Read me',
            'solution': 'Teacher answer',
          },
        ],
      });

      final restored = StemLesson.fromJson(lesson.toJson());

      expect(restored.visibleExercises.single.solution, 'Teacher answer');
      expect(restored.visibleExercises.single.formats, [LessonFormat.story]);
    });
  });
}
