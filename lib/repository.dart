import 'dart:convert';

import 'package:flutter/services.dart';

import 'core/app_assets.dart';
import 'models.dart';

class LessonLoadException implements Exception {
  const LessonLoadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class LessonRepository {
  const LessonRepository();

  Future<StemClass> load(
    int classNumber, {
    AppLanguage language = AppLanguage.ukrainian,
  }) async {
    if (classNumber != 5 && classNumber != 6) {
      throw LessonLoadException('Unsupported class number: $classNumber');
    }

    try {
      final raw = await rootBundle.loadString(
        AppAssets.classLessons(classNumber, language),
      );
      final json = jsonDecode(raw);
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
}
