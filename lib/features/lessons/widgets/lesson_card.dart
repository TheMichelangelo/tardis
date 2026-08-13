import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/localization.dart';
import '../../../models.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, required this.onTap, super.key});

  final StemLesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('${AppStrings.get('topic')}: ${lesson.topic}'),
              Text(
                '${AppStrings.get('exercises')}: ${lesson.exercises.length}',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: lesson.formats
                    .map(
                      (format) => Chip(
                        label: Text(AppStrings.format(format)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppStrings.get('open'),
                  style: const TextStyle(
                    color: AppTheme.link,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
