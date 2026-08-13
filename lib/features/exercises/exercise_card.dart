import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/localization.dart';
import '../../models.dart';
import 'exercise_content.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.lessonId,
    required this.exercise,
    super.key,
  });

  final String lessonId;
  final StemExercise exercise;

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
            ExerciseContent(lessonId: lessonId, exercise: exercise),
          ],
        ),
      ),
    );
  }
}
