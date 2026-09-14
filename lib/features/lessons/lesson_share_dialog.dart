import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/lesson_code.dart';
import '../../core/localization.dart';
import '../../models.dart';

class LessonShareDialog extends StatefulWidget {
  const LessonShareDialog({
    required this.classNumber,
    required this.lesson,
    required this.initialMask,
    required this.onSelectionChanged,
    super.key,
  });

  final int classNumber;
  final StemLesson lesson;
  final int initialMask;
  final ValueChanged<int> onSelectionChanged;

  @override
  State<LessonShareDialog> createState() => _LessonShareDialogState();
}

class _LessonShareDialogState extends State<LessonShareDialog> {
  late int _mask = widget.initialMask & LessonCode.availableMask(widget.lesson);

  void _select(int mask) {
    setState(() => _mask = mask);
    widget.onSelectionChanged(mask);
  }

  Future<void> _copy(String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('copied'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('copyError'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _mask == 0
        ? null
        : LessonCode(
            classNumber: widget.classNumber,
            lessonNumber: widget.lesson.number!,
            exerciseMask: _mask,
          ).toString();
    final link =
        code == null ? null : AppRoutes.sharedLessonLink(code).toString();
    return AlertDialog(
      title: Text(AppStrings.get('shareLesson')),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.get('selectExercisesToShare')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () =>
                        _select(LessonCode.availableMask(widget.lesson)),
                    child: Text(AppStrings.get('selectAllExercises')),
                  ),
                  TextButton(
                    onPressed: () => _select(0),
                    child: Text(AppStrings.get('clearExerciseSelection')),
                  ),
                ],
              ),
              for (final exercise
                  in widget.lesson.exercisesFor(LessonFormat.all))
                CheckboxListTile(
                  key: ValueKey('share-exercise-${exercise.id}'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(exercise.label),
                  subtitle: Text(AppStrings.exerciseType(exercise.type)),
                  value: (_mask &
                          (1 << widget.lesson.exercises.indexOf(exercise))) !=
                      0,
                  onChanged: (_) => _select(
                      _mask ^ (1 << widget.lesson.exercises.indexOf(exercise))),
                ),
              const Divider(),
              if (code == null)
                Text(AppStrings.get('chooseAtLeastOneExercise'))
              else ...[
                Text(AppStrings.get('lessonCode')),
                SelectableText(
                  code,
                  key: const Key('shared-lesson-code'),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SelectableText(link!, key: const Key('shared-lesson-link')),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: code == null ? null : () => _copy(code),
                    icon: const Icon(Icons.pin_outlined),
                    label: Text(AppStrings.get('copyLessonCode')),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: link == null ? null : () => _copy(link),
                    icon: const Icon(Icons.link),
                    label: Text(AppStrings.get('copyLessonLink')),
                  ),
                  OutlinedButton.icon(
                    onPressed: code == null
                        ? null
                        : () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            navigator.pushNamed(AppRoutes.sharedLesson(code));
                          },
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(AppStrings.get('previewStudentLesson')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.get('close')),
        ),
      ],
    );
  }
}
