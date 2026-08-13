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
  });
}
