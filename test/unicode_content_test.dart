import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/core/lesson_code.dart';
import 'package:stem_laboratory/data/material_cache.dart';
import 'package:stem_laboratory/data/storage/json_lesson_storage.dart';
import 'package:stem_laboratory/models.dart';
import 'package:stem_laboratory/repository.dart';

import 'support/unicode_fixture.dart';

// Include JSON object keys and every nested string, including quiz answers,
// table cells, teacher solutions and attachment labels, with useful failures.
Iterable<({String path, String text})> _strings(Object? value,
    [String path = r'$']) sync* {
  if (value is String) {
    yield (path: path, text: value);
  } else if (value is Map) {
    for (final entry in value.entries) {
      yield (path: '$path.<key>', text: '${entry.key}');
      yield* _strings(entry.value, '$path.${entry.key}');
    }
  } else if (value is List) {
    for (final (index, item) in value.indexed) {
      yield* _strings(item, '$path[$index]');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Discover materials so future catalogs and teaching plans are checked too.
  // users.json contains authentication hashes, not learning materials.
  final materials = Directory('src/data')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) =>
          file.path.endsWith('.json') && !file.path.endsWith('/users.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('material discovery includes all six class and four plan catalogs', () {
    expect(materials.length, greaterThanOrEqualTo(10));
    for (final grade in [5, 6, 7]) {
      for (final language in AppLanguage.values) {
        expect(materials.map((file) => file.path),
            contains(AppAssets.classLessons(grade, language)));
      }
    }
  });

  for (final file in materials) {
    test(
        '${file.path}: strict UTF-8, clean nested text and matching public copy',
        () async {
      final bytes = await file.readAsBytes();
      final raw = utf8.decode(bytes, allowMalformed: false);
      // Also detects a BOM silently consumed by the decoder.
      expect(utf8.encode(raw), bytes,
          reason: '${file.path}: UTF-8 bytes changed');
      final data = jsonDecode(raw);
      for (final entry in _strings(data)) {
        expect(
            entry.text,
            isNot(contains(RegExp(
              r'[\uFFFD\uFEFF\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F]|[ÐÑÃÂ][\u0080-\u00BF\u0100-\u024F\u2000-\u206F]|â€',
            ))),
            reason: '${file.path} ${entry.path}: damaged text');
      }
      final publicFile = File('public/${file.path}');
      expect(await publicFile.readAsBytes(), bytes,
          reason: '${file.path}: downloadable material differs from source');
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (manifest.listAssets().contains(file.path)) {
        expect(await rootBundle.loadString(file.path), raw);
        expect(await MaterialCache.readString(file.path), raw);
      }
    });
  }

  for (final grade in [5, 6, 7]) {
    for (final language in AppLanguage.values) {
      test(
          'grade $grade ${language.code}: every catalog field survives storage',
          () async {
        final raw = jsonDecode(await rootBundle.loadString(
            AppAssets.classLessons(grade, language))) as Map<String, dynamic>;
        final original = StemClass.fromJson(raw);
        // Check against the source too: a broken parser must not become its own
        // expected result. Only schema metadata may be normalized.
        Map<String, String> content(Object? value) => {
              for (final entry in _strings(value))
                if (!entry.path.endsWith('.<key>') &&
                    !entry.path.contains('.formats[') &&
                    !entry.path.endsWith('.type'))
                  entry.path.replaceAll('.exersices', '.exercises'): entry.text,
            };
        expect(content(original.toJson()), content(raw));
        await LessonRepository().save(grade, original, language: language);
        final stored =
            await const JsonLessonStorage().read(grade, language.code);
        expect(stored, isNotNull);
        expect(jsonDecode(stored!), original.toJson());
        final restored =
            await LessonRepository().load(grade, language: language);
        expect(restored.toJson(), original.toJson());
      });
    }
  }

  test('all Unicode code points survive saving, overwriting and a new session',
      () async {
    const storage = JsonLessonStorage();
    final expected = <(int, AppLanguage), StemClass>{};
    // Keep all grades/languages together to also catch storage-key collisions.
    for (final grade in [5, 6, 7]) {
      for (final language in AppLanguage.values) {
        final data =
            StemClass.fromJson(unicodeCatalog('$grade/${language.code}'));
        expected[(grade, language)] = data;
        await LessonRepository(storage: storage)
            .save(grade, data, language: language);
        final raw = await storage.read(grade, language.code);
        expect(raw, contains('Ґ'));
        expect(jsonDecode(raw!), data.toJson());
      }
    }
    final replacement =
        StemClass.fromJson(unicodeCatalog('Оновлено: Ґ, Ї, 🧪'));
    expected[(5, AppLanguage.ukrainian)] = replacement;
    await LessonRepository(storage: storage).save(5, replacement);

    // Recreate the preferences mock from its stored values, not the model.
    final preferences = await SharedPreferences.getInstance();
    SharedPreferences.setMockInitialValues({
      for (final key in preferences.getKeys()) key: preferences.get(key)!,
    });
    for (final entry in expected.entries) {
      final restored =
          await LessonRepository(storage: const JsonLessonStorage())
              .load(entry.key.$1, language: entry.key.$2);
      expect(restored.toJson(), entry.value.toJson());
      expect(restored.modules.single.themes.single.lessons.single.topic.runes,
          unicodeSample.runes);
    }
    final shared =
        await LessonRepository().loadShared(LessonCode.tryParse('5990001')!);
    expect(shared.lesson.visibleExercises.single.text('text'), unicodeBody);
    expect(shared.lesson.visibleExercises.single.solution, unicodeSolution);
  });

  group('native material cache', () {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('stem-unicode-test-');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getApplicationSupportDirectory') {
          return directory.path;
        }
        return null;
      });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await directory.delete(recursive: true);
    });

    test('reads real cached UTF-8 bytes without changing Unicode', () async {
      final file = File('${directory.path}/materials/тести/їжак.json');
      await file.parent.create(recursive: true);
      final raw = jsonEncode(unicodeCatalog('Кеш'));
      await file.writeAsBytes(utf8.encode(raw), flush: true);
      expect(await MaterialCache.readString('тести/їжак.json'), raw);
    });

    test('rejects invalid UTF-8 instead of replacing it with broken characters',
        () async {
      final file = File('${directory.path}/materials/invalid.json');
      await file.parent.create(recursive: true);
      await file.writeAsBytes([0xc3, 0x28], flush: true);
      await expectLater(
          MaterialCache.readString('invalid.json'), throwsFormatException);
    });
  });
}
