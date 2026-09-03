import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  group('StemLesson parsing', () {
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
      expect(lesson.exercises.single.type, ExerciseType.interactiveQuiz);
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

      expect(restored.exercises.single.solution, 'Teacher answer');
      expect(restored.exercises.single.formats, [LessonFormat.story]);
    });
  });
}
