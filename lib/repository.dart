import 'dart:convert';

import 'package:flutter/services.dart';

import 'core/app_assets.dart';
import 'data/storage/lesson_storage.dart';
import 'data/storage/storage_factory.dart';
import 'data/material_cache.dart';
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
    if (classNumber != 5 && classNumber != 6) {
      throw LessonLoadException('Unsupported class number: $classNumber');
    }

    try {
      final path = AppAssets.classLessons(classNumber, language);
      String bundledRaw;
      try {
        bundledRaw = await MaterialCache.readString(path);
      } catch (_) {
        bundledRaw = await rootBundle.loadString(path);
      }
      final storedRaw = await _storage.read(classNumber, language.code);
      final json = jsonDecode(storedRaw ?? bundledRaw);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Root JSON value must be an object.');
      }
      return StemClass.fromJson(json);
    } on LessonLoadException {
      rethrow;
    } catch (error) {
      throw LessonLoadException(
        'Failed to load lessons for class $classNumber.',
        error,
      );
    }
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
