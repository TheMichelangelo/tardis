import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_storage.dart';

class JsonLessonStorage implements LessonStorage {
  const JsonLessonStorage();

  String _key(int classNumber, String languageCode) {
    return 'lesson_builder_data_v5_class_${classNumber}_$languageCode';
  }

  @override
  Future<String?> read(int classNumber, String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key(classNumber, languageCode));
  }

  @override
  Future<void> write(
    int classNumber,
    String languageCode,
    String json,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(classNumber, languageCode), json);
  }

  @override
  Future<void> clear(int classNumber, String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(classNumber, languageCode));
  }
}
