abstract interface class LessonStorage {
  Future<String?> read(int classNumber, String languageCode);
  Future<void> write(int classNumber, String languageCode, String json);
  Future<void> clear(int classNumber, String languageCode);
}
