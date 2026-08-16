import 'package:flutter/foundation.dart';

import 'json_lesson_storage.dart';
import 'lesson_storage.dart';
import 'sqlite_lesson_storage.dart';

enum LessonStorageMode { json, sqlite }

LessonStorageMode get configuredStorageMode {
  const value = String.fromEnvironment('STEM_STORAGE', defaultValue: 'json');
  return value == 'sqlite' ? LessonStorageMode.sqlite : LessonStorageMode.json;
}

LessonStorage createLessonStorage() {
  if (configuredStorageMode == LessonStorageMode.sqlite && !kIsWeb) {
    return const SqliteLessonStorage();
  }
  return const JsonLessonStorage();
}
