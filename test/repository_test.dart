import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final repository = LessonRepository();

  for (final language in AppLanguage.values) {
    for (final classNumber in [5, 6]) {
      test('loads class $classNumber in ${language.code}', () async {
        final stemClass = await repository.load(
          classNumber,
          language: language,
        );

        expect(stemClass.modules, isNotEmpty);
      });
    }
  }

  test('rejects an unsupported class number', () {
    expect(
      () => repository.load(7),
      throwsA(isA<LessonLoadException>()),
    );
  });
}
