import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/localization.dart';
import '../../models.dart';
import '../exercises/exercise_card.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({
    required this.classNumber,
    required this.moduleTitle,
    required this.lesson,
    super.key,
  });

  final int classNumber;
  final String moduleTitle;
  final StemLesson lesson;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  LessonFormat _selectedFormat = LessonFormat.all;

  List<LessonFormat> get _availableFormats {
    return <LessonFormat>{LessonFormat.all, ...widget.lesson.formats}.toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.lesson.exercisesFor(_selectedFormat);
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${AppStrings.get('class')} ${widget.classNumber} '
            '• ${widget.moduleTitle}',
            style: const TextStyle(color: AppTheme.secondaryText),
          ),
          const SizedBox(height: 8),
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
            children: _availableFormats
                .map(
                  (format) => ChoiceChip(
                    label: Text(AppStrings.format(format)),
                    selected: _selectedFormat == format,
                    onSelected: (_) => setState(
                      () => _selectedFormat = format,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          if (exercises.isEmpty)
            Text(AppStrings.get('none'))
          else
            ...exercises.map(
              (exercise) => ExerciseCard(
                lessonId: widget.lesson.id,
                exercise: exercise,
              ),
            ),
        ],
      ),
    );
  }
}
