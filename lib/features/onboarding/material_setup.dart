import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_assets.dart';
import '../../data/material_cache.dart';

enum AppRole { student, teacher }

class MaterialSetup {
  static const _roleKey = 'app_role_v1';
  static const _classKey = 'student_class_v1';

  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_roleKey);
  }

  static Future<void> install({
    required AppRole role,
    int? classNumber,
    required ValueChanged<double> onProgress,
  }) async {
    final classes = role == AppRole.teacher ? const [5, 6] : [classNumber!];
    final paths = <String>{};
    for (final number in classes) {
      for (final language in AppLanguage.values) {
        final jsonPath = AppAssets.classLessons(number, language);
        await MaterialCache.download(jsonPath);
        paths.add(jsonPath);
        final document = jsonDecode(await MaterialCache.readString(jsonPath));
        _collectPaths(document, paths,
            includeTeacherFiles: role == AppRole.teacher);
      }
    }
    final downloads = paths.where((path) => !path.endsWith('.json')).toList();
    for (var i = 0; i < downloads.length; i++) {
      await MaterialCache.download(downloads[i]);
      onProgress((i + 1) / downloads.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
    if (classNumber != null) await prefs.setInt(_classKey, classNumber);
  }

  static void _collectPaths(Object? value, Set<String> result,
      {required bool includeTeacherFiles}) {
    if (value is Map) {
      final lessonId = value['id'];
      final exercises = value['exercises'] ?? value['exersices'];
      if (lessonId is String && exercises is List) {
        for (final exercise in exercises.whereType<Map>()) {
          final exerciseId = exercise['id'];
          final extension = exercise['imageExt'];
          if (exerciseId is String && extension is String) {
            result.add('src/data/$lessonId/$exerciseId.$extension');
          }
        }
      }
      for (final entry in value.entries) {
        if (entry.value is String &&
            const {'studentPdf', 'teacherPdf', 'planAsset', 'path'}
                .contains(entry.key) &&
            (entry.key != 'teacherPdf' || includeTeacherFiles)) {
          result.add(entry.value as String);
        }
        _collectPaths(entry.value, result,
            includeTeacherFiles: includeTeacherFiles);
      }
    } else if (value is List) {
      for (final item in value) {
        _collectPaths(item, result, includeTeacherFiles: includeTeacherFiles);
      }
    }
  }
}

class MaterialSetupPage extends StatefulWidget {
  const MaterialSetupPage({required this.onComplete, super.key});
  final VoidCallback onComplete;

  @override
  State<MaterialSetupPage> createState() => _MaterialSetupPageState();
}

class _MaterialSetupPageState extends State<MaterialSetupPage> {
  AppRole? _role;
  int _classNumber = 5;
  double? _progress;
  String? _error;

  Future<void> _install() async {
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await MaterialSetup.install(
        role: _role!,
        classNumber: _role == AppRole.student ? _classNumber : null,
        onProgress: (value) {
          if (mounted) {
            setState(() => _progress = value);
          }
        },
      );
      widget.onComplete();
    } catch (_) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error =
              'Не вдалося завантажити матеріали. Перевірте інтернет і спробуйте ще раз.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Початкове налаштування')),
        body: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Хто користуватиметься застосунком?',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SegmentedButton<AppRole>(
                segments: const [
                  ButtonSegment(
                      value: AppRole.student,
                      icon: Icon(Icons.school),
                      label: Text('Учень')),
                  ButtonSegment(
                      value: AppRole.teacher,
                      icon: Icon(Icons.co_present),
                      label: Text('Учитель')),
                ],
                selected: _role == null ? {} : {_role!},
                emptySelectionAllowed: true,
                onSelectionChanged: _progress == null
                    ? (value) => setState(() => _role = value.first)
                    : null,
              ),
              if (_role == AppRole.student) ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  initialValue: _classNumber,
                  decoration: const InputDecoration(
                      labelText: 'Оберіть клас', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 клас')),
                    DropdownMenuItem(value: 6, child: Text('6 клас'))
                  ],
                  onChanged: (value) => setState(() => _classNumber = value!),
                ),
              ],
              const SizedBox(height: 24),
              if (_progress != null) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                const Text('Завантаження матеріалів…')
              ] else
                FilledButton.icon(
                    onPressed: _role == null ? null : _install,
                    icon: const Icon(Icons.download),
                    label: Text(_role == AppRole.teacher
                        ? 'Завантажити всі матеріали'
                        : 'Продовжити')),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center)
              ],
            ]),
          ),
        )),
      );
}
