import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../../repository.dart';
import '../auth/auth_controller.dart';
import 'lesson_page.dart';

class LessonRoutePage extends StatelessWidget {
  const LessonRoutePage({
    required this.classNumber,
    required this.moduleId,
    required this.lessonId,
    required this.repository,
    required this.authController,
    required this.language,
    super.key,
  });

  final int classNumber;
  final String moduleId;
  final String lessonId;
  final LessonRepository repository;
  final AuthController authController;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.load(classNumber, language: language),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text(AppStrings.get('loadError'))));
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final module = snapshot.requireData.modules
            .where((item) => item.id == moduleId)
            .firstOrNull;
        final lesson = module?.themes
            .expand((theme) => theme.lessons)
            .where((item) => item.id == lessonId)
            .firstOrNull;
        if (module == null || lesson == null) {
          return Scaffold(body: Center(child: Text(AppStrings.get('none'))));
        }
        return LessonPage(
          classNumber: classNumber,
          moduleTitle: module.title,
          lesson: lesson,
          isTeacher: authController.isLoggedIn,
        );
      },
    );
  }
}
