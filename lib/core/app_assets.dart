abstract final class AppAssets {
  static const logo = 'src/data/stem_logo.jpeg';
  static const users = 'src/data/users.json';

  static String classLessons(int classNumber, AppLanguage language) {
    return 'src/data/${classNumber}_class_stem_lesson_${language.code}.json';
  }

  static String exerciseImage({
    required String lessonId,
    required String exerciseId,
    required String extension,
  }) {
    return 'src/data/$lessonId/$exerciseId.$extension';
  }
}

enum AppLanguage {
  ukrainian('ua'),
  english('en');

  const AppLanguage(this.code);
  final String code;
}
