import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/localization.dart';
import '../../models.dart';
import 'exercise_content.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.lessonId,
    required this.exercise,
    required this.isTeacher,
    super.key,
  });

  final String lessonId;
  final StemExercise exercise;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.exerciseType(exercise.type),
              style: const TextStyle(
                color: AppTheme.exerciseLabel,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exercise.label,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ExerciseContent(
              lessonId: lessonId,
              exercise: exercise,
              isTeacher: isTeacher,
            ),
            if (isTeacher && exercise.solution.trim().isNotEmpty)
              _ExerciseSolution(solution: exercise.solution),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSolution extends StatefulWidget {
  const _ExerciseSolution({required this.solution});
  final String solution;

  @override
  State<_ExerciseSolution> createState() => _ExerciseSolutionState();
}

class _ExerciseSolutionState extends State<_ExerciseSolution> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.tonal(
            onPressed: () => setState(() => _visible = !_visible),
            child: Text(AppStrings.get(
              _visible ? 'hideSolution' : 'showSolution',
            )),
          ),
          if (_visible)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffecfdf5),
                border: Border.all(color: const Color(0xffa7f3d0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.solution),
            ),
        ],
      ),
    );
  }
}
