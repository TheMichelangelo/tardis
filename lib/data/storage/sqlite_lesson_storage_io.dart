import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'lesson_storage.dart';

class SqliteLessonStorage implements LessonStorage {
  const SqliteLessonStorage();

  static Future<Database>? _database;

  Future<Database> _open() {
    return _database ??= _createDatabase();
  }

  Future<Database> _createDatabase() async {
    final databasePath = path.join(
      await getDatabasesPath(),
      'stem_lesson_builder.db',
    );
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE class_lessons (
            class_number INTEGER NOT NULL,
            language TEXT NOT NULL,
            data_json TEXT NOT NULL,
            PRIMARY KEY (class_number, language)
          )
        ''');
      },
    );
  }

  @override
  Future<String?> read(int classNumber, String languageCode) async {
    final database = await _open();
    final rows = await database.query(
      'class_lessons',
      columns: ['data_json'],
      where: 'class_number = ? AND language = ?',
      whereArgs: [classNumber, languageCode],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single['data_json'] as String?;
  }

  @override
  Future<void> write(
    int classNumber,
    String languageCode,
    String json,
  ) async {
    final database = await _open();
    await database.insert(
      'class_lessons',
      {
        'class_number': classNumber,
        'language': languageCode,
        'data_json': json,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clear(int classNumber, String languageCode) async {
    final database = await _open();
    await database.delete(
      'class_lessons',
      where: 'class_number = ? AND language = ?',
      whereArgs: [classNumber, languageCode],
    );
  }
}
