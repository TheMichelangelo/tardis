enum LessonFormat {
  all,
  quiz,
  story,
  competition;

  String get jsonValue => name;

  static LessonFormat fromJson(Object? value) {
    if (value == 'flashcards') return LessonFormat.competition;
    return LessonFormat.values.firstWhere(
      (format) => format.name == value,
      orElse: () => LessonFormat.all,
    );
  }
}

enum ExerciseType {
  diagram,
  table,
  text,
  rebus,
  video,
  interactiveQuiz,
  homework,
  connect,
  unknown;

  static ExerciseType fromJson(Object? value) {
    if (value == 'interactive_quiz') return ExerciseType.interactiveQuiz;
    return ExerciseType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ExerciseType.unknown,
    );
  }
}

class StemClass {
  const StemClass({required this.modules});
  final List<StemModule> modules;

  factory StemClass.fromJson(Map<String, dynamic> json) {
    return StemClass(
      modules: _mapList(json['modules'], StemModule.fromJson),
    );
  }
}

class StemModule {
  const StemModule({
    required this.id,
    required this.title,
    required this.themes,
  });

  final String id;
  final String title;
  final List<StemTheme> themes;

  factory StemModule.fromJson(Map<String, dynamic> json) {
    return StemModule(
      id: _string(json['id']),
      title: _string(json['title']),
      themes: _mapList(json['themes'], StemTheme.fromJson),
    );
  }
}

class StemTheme {
  const StemTheme({
    required this.id,
    required this.color,
    required this.lessons,
  });

  final String id;
  final String color;
  final List<StemLesson> lessons;

  factory StemTheme.fromJson(Map<String, dynamic> json) {
    return StemTheme(
      id: _string(json['id']),
      color: _string(json['color'], fallback: '#2563eb'),
      lessons: _mapList(json['lessons'], StemLesson.fromJson),
    );
  }
}

class StemLesson {
  const StemLesson({
    required this.id,
    required this.title,
    required this.topic,
    required this.formats,
    required this.exercises,
  });

  final String id;
  final String title;
  final String topic;
  final List<LessonFormat> formats;
  final List<StemExercise> exercises;

  factory StemLesson.fromJson(Map<String, dynamic> json) {
    final exercises = json['exercises'] ?? json['exersices'];
    return StemLesson(
      id: _string(json['id']),
      title: _string(json['title']),
      topic: _string(json['topic']),
      formats: _values(json['formats']).map(LessonFormat.fromJson).toList(),
      exercises: _mapList(exercises, StemExercise.fromJson),
    );
  }

  List<StemExercise> exercisesFor(LessonFormat selected) {
    return exercises
        .where((exercise) => exercise.isVisibleFor(selected))
        .toList();
  }
}

class StemExercise {
  const StemExercise({
    required this.id,
    required this.label,
    required this.type,
    required this.formats,
    required this.data,
  });

  final String id;
  final String label;
  final ExerciseType type;
  final List<LessonFormat> formats;
  final Map<String, dynamic> data;

  factory StemExercise.fromJson(Map<String, dynamic> json) {
    return StemExercise(
      id: _string(json['id']),
      label: _string(json['label']),
      type: ExerciseType.fromJson(json['type']),
      formats: _values(json['formats']).map(LessonFormat.fromJson).toList(),
      data: Map.unmodifiable(json),
    );
  }

  String text(String key, {String fallback = ''}) {
    return _string(data[key], fallback: fallback);
  }

  List<String> stringList(String key) {
    return _values(data[key]).map(_string).toList();
  }

  List<Map<String, dynamic>> objectList(String key) {
    return _values(data[key]).whereType<Map<String, dynamic>>().toList();
  }

  bool isVisibleFor(LessonFormat selected) {
    return selected == LessonFormat.all ||
        type == ExerciseType.homework ||
        formats.isEmpty ||
        formats.contains(LessonFormat.all) ||
        formats.contains(selected);
  }
}

List<Object?> _values(Object? value) => value is List ? value : const [];

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, dynamic>) convert,
) {
  return _values(value).whereType<Map<String, dynamic>>().map(convert).toList();
}

String _string(Object? value, {String fallback = ''}) {
  return value == null ? fallback : '$value';
}
