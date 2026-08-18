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
}
