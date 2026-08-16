import 'lesson_storage.dart';

class SqliteLessonStorage implements LessonStorage {
  const SqliteLessonStorage();

  UnsupportedError _unsupported() {
    return UnsupportedError('SQLite lesson storage is unavailable on web.');
  }

  @override
  Future<void> clear(int classNumber, String languageCode) {
    throw _unsupported();
  }

  @override
  Future<String?> read(int classNumber, String languageCode) {
    throw _unsupported();
  }

  @override
  Future<void> write(int classNumber, String languageCode, String json) {
    throw _unsupported();
  }
}
