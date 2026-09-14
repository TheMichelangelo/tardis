import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/app_routes.dart';
import '../../core/lesson_code.dart';
import '../../core/localization.dart';
import '../../models.dart';
import '../../repository.dart';
import 'lesson_page.dart';

class SharedLessonPage extends StatefulWidget {
  const SharedLessonPage({
    required this.code,
    required this.repository,
    required this.language,
    super.key,
  });

  final String code;
  final LessonRepository repository;
  final AppLanguage language;

  @override
  State<SharedLessonPage> createState() => _SharedLessonPageState();
}

class _SharedLessonPageState extends State<SharedLessonPage> {
  late var _lesson = _load();

  Future<({StemModule module, StemLesson lesson})> _load() async {
    final code = LessonCode.tryParse(widget.code);
    if (code == null) throw const FormatException('Invalid lesson code.');
    return widget.repository.loadShared(code, language: widget.language);
  }

  @override
  void didUpdateWidget(SharedLessonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != oldWidget.code ||
        widget.language != oldWidget.language ||
        widget.repository != oldWidget.repository) {
      _lesson = _load();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _lesson,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.requireData;
            return LessonPage(
              key: ValueKey(widget.code),
              classNumber: LessonCode.tryParse(widget.code)!.classNumber,
              moduleTitle: data.module.title,
              lesson: data.lesson,
              isTeacher: false,
              sharedCode: widget.code,
            );
          }
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.get('openByCode'))),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              AppStrings.get(snapshot.error is FormatException
                                  ? 'lessonCodeNotFound'
                                  : 'loadError'),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() => _lesson = _load()),
                            child: Text(AppStrings.get('retry')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                                context, AppRoutes.home, (_) => false),
                            child: Text(AppStrings.get('backHome')),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          );
        },
      );
}
