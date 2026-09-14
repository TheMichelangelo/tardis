abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';

  static String classPage(int classNumber) => '/class/$classNumber';

  static String lesson({
    required int classNumber,
    required String moduleId,
    required String lessonId,
  }) {
    return '/class/$classNumber/module/${Uri.encodeComponent(moduleId)}'
        '/lesson/${Uri.encodeComponent(lessonId)}';
  }

  static String proposal(int classNumber) => '/propose?class=$classNumber';

  // A query on the site root also works on static hosts without route rewrites.
  static String sharedLesson(String code) =>
      Uri(path: '/', queryParameters: {'lessonCode': code}).toString();

  static Uri sharedLessonLink(String code, {Uri? baseUri}) {
    final base = baseUri ?? Uri.base;
    if (base.scheme != 'https' && base.scheme != 'http') {
      return Uri.parse(const String.fromEnvironment(
        'STEM_PUBLIC_URL',
        defaultValue: 'https://themichelangelo.github.io/tardis/',
      )).replace(queryParameters: {'lessonCode': code}).removeFragment();
    }
    final segments = base.pathSegments.toList();
    final routeIndex = segments.indexWhere((segment) =>
        ['class', 'classes', 'login', 'propose'].contains(segment));
    final prefix = routeIndex >= 0
        ? segments.take(routeIndex).toList()
        : segments
            .where((segment) => segment.isNotEmpty && segment != 'index.html')
            .toList();
    return base.replace(
      path: '/${[...prefix, ''].join('/')}',
      queryParameters: {'lessonCode': code},
    ).removeFragment();
  }
}
