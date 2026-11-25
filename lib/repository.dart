import 'dart:convert';

import 'package:flutter/services.dart';

import 'core/app_assets.dart';
import 'core/lesson_code.dart';
import 'data/storage/lesson_storage.dart';
import 'data/storage/storage_factory.dart';
import 'models.dart';

class LessonLoadException implements Exception {
  const LessonLoadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class LessonRepository {
  LessonRepository({LessonStorage? storage})
      : _storage = storage ?? createLessonStorage();

  final LessonStorage _storage;

  Future<StemClass> load(
    int classNumber, {
    AppLanguage language = AppLanguage.ukrainian,
  }) async {
    if (classNumber != 5 && classNumber != 6 && classNumber != 7) {
      throw LessonLoadException('Unsupported class number: $classNumber');
    }

    try {
      final path = AppAssets.classLessons(classNumber, language);
      // Catalogs ship with the app. A previously downloaded copy must not hide
      // new modules or restore demo exercises after an application update.
      final bundledRaw = await rootBundle.loadString(path);
      final bundled = StemClass.fromJson(jsonDecode(bundledRaw));
      final storedRaw = await _storage.read(classNumber, language.code);
      final json = jsonDecode(storedRaw ?? bundledRaw);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Root JSON value must be an object.');
      }
      final data = _refreshCatalog(bundled, StemClass.fromJson(json));
      // Older local catalogs do not yet have stable lesson numbers.
      final numbers = {
        for (final module in bundled.modules)
          for (final theme in module.themes)
            for (final lesson in theme.lessons) lesson.id: lesson.number,
      };
      return data.copyWith(modules: [
        for (final module in data.modules)
          module.copyWith(themes: [
            for (final theme in module.themes)
              theme.copyWith(lessons: [
                for (final lesson in theme.lessons)
                  lesson.copyWith(number: numbers[lesson.id]),
              ]),
          ]),
      ]);
    } on LessonLoadException {
      rethrow;
    } catch (error) {
      throw LessonLoadException(
        'Failed to load lessons for class $classNumber.',
        error,
      );
    }
  }

  /// Refresh published content while retaining locally authored additions.
  /// Legacy storage contains complete snapshots of the published catalog,
  /// including obsolete titles, topics and demonstration exercises.
  static StemClass _refreshCatalog(StemClass bundled, StemClass stored) {
    final moduleIds = bundled.modules.map((m) => m.id).toSet();
    final lessonIds = bundled.modules
        .expand((m) => m.themes)
        .expand((t) => t.lessons)
        .map((l) => l.id)
        .toSet();
    final hasPublishedContent = stored.modules.any((m) =>
        moduleIds.contains(m.id) ||
        m.themes.any((t) => t.lessons.any((l) => lessonIds.contains(l.id))));
    // A standalone local catalog is not an outdated published snapshot.
    if (!hasPublishedContent) return stored;

    List<StemLesson> additions(StemTheme theme) =>
        theme.lessons.where((l) => !lessonIds.contains(l.id)).toList();

    return bundled.copyWith(
      generatedLessons: stored.generatedLessons,
      modules: [
        for (final module in bundled.modules)
          module.copyWith(themes: [
            for (final theme in module.themes)
              theme.copyWith(lessons: [
                ...theme.lessons,
                for (final savedModule in stored.modules)
                  if (savedModule.id == module.id)
                    for (final savedTheme in savedModule.themes)
                      if (savedTheme.id == theme.id) ...additions(savedTheme),
              ]),
            for (final savedModule in stored.modules)
              if (savedModule.id == module.id)
                for (final savedTheme in savedModule.themes)
                  if (!module.themes.any((t) => t.id == savedTheme.id) &&
                      additions(savedTheme).isNotEmpty)
                    savedTheme.copyWith(lessons: additions(savedTheme)),
          ]),
        for (final savedModule in stored.modules)
          if (!moduleIds.contains(savedModule.id))
            savedModule.copyWith(themes: [
              for (final savedTheme in savedModule.themes)
                savedTheme.copyWith(lessons: additions(savedTheme)),
            ]),
      ],
    );
  }

  Future<({StemModule module, StemLesson lesson})> loadShared(
    LessonCode code, {
    AppLanguage language = AppLanguage.ukrainian,
  }) async {
    // Both languages share numbers for translated lessons. A lesson that has
    // no translation is opened in its original language instead of another one.
    for (final candidate in [
      language,
      ...AppLanguage.values.where((value) => value != language),
    ]) {
      final data = await load(code.classNumber, language: candidate);
      final matches = [
        for (final module in data.modules)
          for (final theme in module.themes)
            for (final lesson in theme.lessons)
              if (lesson.number == code.lessonNumber)
                (module: module, lesson: lesson),
      ];
      if (matches.length > 1) {
        throw const FormatException('Ambiguous lesson number.');
      }
      if (matches.isEmpty) continue;
      final selected = code.selectExercises(matches.single.lesson);
      if (selected.visibleExercises.isEmpty) {
        throw const FormatException('No selected exercises are available.');
      }
      return (module: matches.single.module, lesson: selected);
    }
    throw const FormatException('Lesson not found.');
  }

  Future<void> save(
    int classNumber,
    StemClass data, {
    AppLanguage language = AppLanguage.ukrainian,
  }) async {
    await _storage.write(
      classNumber,
      language.code,
      jsonEncode(data.toJson()),
    );
  }

  Future<void> reset(
    int classNumber, {
    AppLanguage language = AppLanguage.ukrainian,
  }) {
    return _storage.clear(classNumber, language.code);
  }
}
