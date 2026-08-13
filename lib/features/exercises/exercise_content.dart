import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../../models.dart';
import 'quiz_question.dart';

class ExerciseContent extends StatelessWidget {
  const ExerciseContent({
    required this.lessonId,
    required this.exercise,
    super.key,
  });

  final String lessonId;
  final StemExercise exercise;

  @override
  Widget build(BuildContext context) {
    return switch (exercise.type) {
      ExerciseType.diagram || ExerciseType.rebus => _ExerciseImage(
          path: AppAssets.exerciseImage(
            lessonId: lessonId,
            exerciseId: exercise.id,
            extension: exercise.text('imageExt', fallback: 'png'),
          ),
        ),
      ExerciseType.text || ExerciseType.homework => _TextExercise(
          text: exercise.text('text'),
          questions: exercise.stringList('questions'),
        ),
      ExerciseType.video => _VideoExercise(
          url: exercise.text('youtubeUrl'),
        ),
      ExerciseType.table => _TableExercise(
          columns: exercise.stringList('columns'),
          rows: exercise.stringList('rows'),
          hints: exercise.stringList('dataToFill'),
        ),
      ExerciseType.interactiveQuiz => _QuizExercise(
          questions: exercise.objectList('questions'),
        ),
      ExerciseType.connect => _ConnectExercise(
          left: exercise.stringList('column1Items'),
          right: exercise.stringList('column2Items'),
        ),
      ExerciseType.unknown => const SizedBox.shrink(),
    };
  }
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.image_not_supported, size: 48),
      ),
    );
  }
}

class _TextExercise extends StatelessWidget {
  const _TextExercise({required this.text, required this.questions});

  final String text;
  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        ...questions.map(
          (question) => ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(question),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _VideoExercise extends StatelessWidget {
  const _VideoExercise({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    return FilledButton.icon(
      onPressed: uri == null || !uri.hasScheme
          ? null
          : () => launchUrl(uri, mode: LaunchMode.externalApplication),
      icon: const Icon(Icons.play_arrow),
      label: Text(AppStrings.get('watch')),
    );
  }
}

class _TableExercise extends StatelessWidget {
  const _TableExercise({
    required this.columns,
    required this.rows,
    required this.hints,
  });

  final List<String> columns;
  final List<String> rows;
  final List<String> hints;

  int get _rowCount {
    if (rows.isNotEmpty) return rows.length;
    if (columns.isEmpty) return 0;
    return (hints.length / columns.length).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          if (rows.isNotEmpty) const DataColumn(label: Text('')),
          ...columns.map((column) => DataColumn(label: Text(column))),
        ],
        rows: List.generate(
          _rowCount,
          (rowIndex) => DataRow(
            cells: [
              if (rows.isNotEmpty) DataCell(Text(rows[rowIndex])),
              ...List.generate(
                columns.length,
                (columnIndex) {
                  final hintIndex = rowIndex * columns.length + columnIndex;
                  return DataCell(
                    SizedBox(
                      width: 110,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                              hintIndex < hints.length ? hints[hintIndex] : '',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizExercise extends StatelessWidget {
  const _QuizExercise({required this.questions});

  final List<Map<String, dynamic>> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: questions.map(QuizQuestion.new).toList(),
    );
  }
}

class _ConnectExercise extends StatelessWidget {
  const _ConnectExercise({required this.left, required this.right});

  final List<String> left;
  final List<String> right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ConnectionColumn(items: left)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.compare_arrows),
        ),
        Expanded(child: _ConnectionColumn(items: right)),
      ],
    );
  }
}

class _ConnectionColumn extends StatelessWidget {
  const _ConnectionColumn({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(title: Text(item)),
            ),
          )
          .toList(),
    );
  }
}
