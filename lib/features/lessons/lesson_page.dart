import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/localization.dart';
import '../../core/reading_settings.dart';
import '../../core/responsive_layout.dart';
import '../../core/stem_background.dart';
import '../../models.dart';
import '../exercises/exercise_card.dart';
import 'lesson_pdf_service.dart';
import 'teaching_plan_page.dart';

enum ExerciseViewMode { single, all }

class LessonPage extends StatefulWidget {
  const LessonPage({
    required this.classNumber,
    required this.moduleTitle,
    required this.lesson,
    required this.isTeacher,
    super.key,
  });

  final int classNumber;
  final String moduleTitle;
  final StemLesson lesson;
  final bool isTeacher;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  static const _pdf = LessonPdfService();
  LessonFormat _selectedFormat = LessonFormat.all;
  ExerciseViewMode _viewMode = ExerciseViewMode.single;
  int _exerciseIndex = 0;

  List<LessonFormat> get _availableFormats => [
        LessonFormat.all,
        ...widget.lesson.availableFormats,
      ];

  void _selectFormat(LessonFormat format) {
    setState(() {
      _selectedFormat = format;
      _exerciseIndex = 0;
    });
  }

  Future<void> _runPdf(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('pdfError'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.lesson.exercises
        .where((exercise) => exercise.text('planAsset').isNotEmpty)
        .firstOrNull;
    if (plan != null) {
      return TeachingPlanPage(title: widget.lesson.title, exercise: plan);
    }
    final exercises = widget.lesson.exercisesFor(_selectedFormat);
    if (_exerciseIndex >= exercises.length) _exerciseIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          const TextSizeButton(),
          if (widget.isTeacher) ...[
            IconButton(
              tooltip: AppStrings.get('printPdf'),
              onPressed: () => _runPdf(() => _pdf.printLesson(
                    lesson: widget.lesson,
                    moduleTitle: widget.moduleTitle,
                    classNumber: widget.classNumber,
                  )),
              icon: const Icon(Icons.print),
            ),
            IconButton(
              tooltip: AppStrings.get('downloadPdf'),
              onPressed: () => _runPdf(() => _pdf.shareLesson(
                    lesson: widget.lesson,
                    moduleTitle: widget.moduleTitle,
                    classNumber: widget.classNumber,
                  )),
              icon: const Icon(Icons.picture_as_pdf),
            ),
          ],
        ],
      ),
      body: StemBackgroundBody(
        child: ListView(
          padding: pagePadding(context),
          children: [
            Text(
              '${AppStrings.get('class')} ${widget.classNumber} '
              '• ${widget.moduleTitle}',
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              widget.lesson.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (widget.lesson.topic != widget.lesson.title)
              Text(
                widget.lesson.topic,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableFormats.map((format) {
                return ChoiceChip(
                  label: Text(AppStrings.format(format)),
                  selected: _selectedFormat == format,
                  onSelected: (_) => _selectFormat(format),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in ExerciseViewMode.values)
                  ChoiceChip(
                    avatar: Icon(
                        mode == ExerciseViewMode.all
                            ? Icons.view_list
                            : Icons.view_carousel,
                        size: 20),
                    label: Text(AppStrings.get(mode == ExerciseViewMode.all
                        ? 'allExercises'
                        : 'oneByOne')),
                    selected: _viewMode == mode,
                    onSelected: (_) => setState(() {
                      _viewMode = mode;
                      _exerciseIndex = 0;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (exercises.isEmpty)
              Text(AppStrings.get('none'))
            else if (_viewMode == ExerciseViewMode.all)
              ...exercises.map((exercise) => _card(exercise))
            else ...[
              Text(
                '${_exerciseIndex + 1} / ${exercises.length} '
                '${AppStrings.get('exercises').toLowerCase()}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _card(exercises[_exerciseIndex]),
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 12,
                overflowSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _exerciseIndex == 0
                        ? null
                        : () => setState(() => _exerciseIndex--),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppStrings.get('previous')),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _exerciseIndex == exercises.length - 1
                        ? null
                        : () => setState(() => _exerciseIndex++),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(AppStrings.get('next')),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(StemExercise exercise) {
    return ExerciseCard(
      key: ValueKey('${widget.lesson.id}/${exercise.id}'),
      lessonId: widget.lesson.id,
      exercise: exercise,
      isTeacher: widget.isTeacher,
    );
  }
}
