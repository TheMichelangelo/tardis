import '../models.dart';

/// Grade, two-digit lesson number, and a four-digit decimal bit mask.
/// Slot 1 is the least significant bit; slots never change with display order.
class LessonCode {
  const LessonCode._(this.classNumber, this.lessonNumber, this.exerciseMask);

  static const length = 7;
  static const maxMask = (1 << StemLesson.maxExercises) - 1;

  final int classNumber;
  final int lessonNumber;
  final int exerciseMask;

  factory LessonCode({
    required int classNumber,
    required int lessonNumber,
    required int exerciseMask,
  }) {
    if (![5, 6, 7].contains(classNumber) ||
        lessonNumber < 1 ||
        lessonNumber > 99 ||
        exerciseMask < 1 ||
        exerciseMask > maxMask) {
      throw const FormatException('Invalid lesson code.');
    }
    return LessonCode._(classNumber, lessonNumber, exerciseMask);
  }

  static LessonCode? tryParse(String value) {
    final code = value.trim();
    if (!RegExp(r'^[5-7][0-9]{6}$').hasMatch(code)) return null;
    try {
      return LessonCode(
        classNumber: int.parse(code[0]),
        lessonNumber: int.parse(code.substring(1, 3)),
        exerciseMask: int.parse(code.substring(3)),
      );
    } on FormatException {
      return null;
    }
  }

  static int availableMask(StemLesson lesson) {
    if (lesson.exercises.length > StemLesson.maxExercises) {
      throw const FormatException('Too many exercises.');
    }
    return lesson.exercises.indexed.fold(
        0,
        (mask, entry) =>
            entry.$2.isPlaceholder ? mask : mask | (1 << entry.$1));
  }

  StemLesson selectExercises(StemLesson lesson) => lesson.copyWith(exercises: [
        for (final (index, exercise) in lesson.exercises.indexed)
          if ((exerciseMask & (1 << index)) != 0)
            exercise
          else
            StemExercise.placeholder(lesson.id, index),
      ]);

  @override
  String toString() => '$classNumber${lessonNumber.toString().padLeft(2, '0')}'
      '${exerciseMask.toString().padLeft(4, '0')}';
}
