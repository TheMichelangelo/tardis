import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../../models.dart';
import 'quiz_question.dart';

class ExerciseContent extends StatelessWidget {
  const ExerciseContent({
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
    return switch (exercise.type) {
      ExerciseType.diagram || ExerciseType.rebus => _ExerciseImage(
          lessonId: lessonId,
          exercise: exercise,
        ),
      ExerciseType.text => _TextExercise(
          text: exercise.text('text'),
          questions: exercise.stringList('questions'),
        ),
      ExerciseType.homework => _HomeworkExercise(
          lessonId: lessonId,
          exercise: exercise,
          isTeacher: isTeacher,
        ),
      ExerciseType.video => _VideoExercise(
          url: exercise.text('youtubeUrl'),
          questions: exercise.stringList('questions'),
        ),
      ExerciseType.table => _TableExercise(
          columns: exercise.stringList('columns'),
          rows: exercise.stringList('rows'),
          values: exercise.stringList('dataToFill'),
        ),
      ExerciseType.interactiveQuiz => _QuizExercise(
          questions: exercise.objectList('questions'),
        ),
      ExerciseType.connect => _ConnectExercise(exercise: exercise),
      ExerciseType.unknown => const SizedBox.shrink(),
    };
  }
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.lessonId, required this.exercise});
  final String lessonId;
  final StemExercise exercise;

  @override
  Widget build(BuildContext context) {
    final encoded = exercise.text('imageData');
    final image = encoded.isNotEmpty
        ? Image.memory(base64Decode(encoded), fit: BoxFit.contain)
        : Image.asset(
            AppAssets.exerciseImage(
              lessonId: lessonId,
              exerciseId: exercise.id,
              extension: exercise.text('imageExt', fallback: 'png'),
            ),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.image_not_supported, size: 48),
            ),
          );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 520),
      child: Center(child: image),
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
        ...questions.indexed.map((entry) => ListTile(
              leading: CircleAvatar(child: Text('${entry.$1 + 1}')),
              title: Text(entry.$2),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}

class _VideoExercise extends StatelessWidget {
  const _VideoExercise({required this.url, required this.questions});
  final String url;
  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmbeddedYoutubeVideo(url: url),
        ...questions.indexed.map((entry) => ListTile(
              leading: CircleAvatar(child: Text('${entry.$1 + 1}')),
              title: Text(entry.$2),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}

class EmbeddedYoutubeVideo extends StatefulWidget {
  const EmbeddedYoutubeVideo({required this.url, super.key});
  final String url;

  @override
  State<EmbeddedYoutubeVideo> createState() => _EmbeddedYoutubeVideoState();
}

class _EmbeddedYoutubeVideoState extends State<EmbeddedYoutubeVideo> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final id = YoutubePlayerController.convertUrlToId(widget.url);
    if (id != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: id,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return Text(widget.url);
    return YoutubePlayer(controller: controller, aspectRatio: 16 / 9);
  }
}

class _HomeworkExercise extends StatelessWidget {
  const _HomeworkExercise({
    required this.lessonId,
    required this.exercise,
    required this.isTeacher,
  });
  final String lessonId;
  final StemExercise exercise;
  final bool isTeacher;

  Future<void> _download(
    BuildContext context,
    String assetPath,
  ) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final fileName = assetPath.split('/').last;
      final isPdf = fileName.toLowerCase().endsWith('.pdf');
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: isPdf ? 'application/pdf' : 'application/x-tex',
        dialogTitle: AppStrings.get('saveDiagnosticFile'),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('downloadDiagnosticError'))),
      );
    }
  }

  Widget _downloadButton(
    BuildContext context, {
    required String assetPath,
    required String label,
    required IconData icon,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _download(context, assetPath),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = exercise.text('imageData').isNotEmpty ||
        exercise.data.containsKey('imageExt');
    final videoUrl = exercise.text('videoUrl');
    final studentPdf = exercise.text('studentPdf');
    final teacherPdf = exercise.text('teacherPdf');
    final hasDiagnosticFiles = studentPdf.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exercise.text('text')),
        if (hasImage) ...[
          const SizedBox(height: 12),
          _ExerciseImage(lessonId: lessonId, exercise: exercise),
        ],
        if (videoUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          EmbeddedYoutubeVideo(url: videoUrl),
        ],
        if (hasDiagnosticFiles) ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.get('studentVersionNoAnswers'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (studentPdf.isNotEmpty)
                _downloadButton(
                  context,
                  assetPath: studentPdf,
                  label: AppStrings.get('downloadStudentPdf'),
                  icon: Icons.picture_as_pdf,
                ),
            ],
          ),
        ],
        if (isTeacher && teacherPdf.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.get('teacherVersionWithAnswers'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (teacherPdf.isNotEmpty)
                _downloadButton(
                  context,
                  assetPath: teacherPdf,
                  label: AppStrings.get('downloadTeacherPdf'),
                  icon: Icons.lock,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TableExercise extends StatelessWidget {
  const _TableExercise({
    required this.columns,
    required this.rows,
    required this.values,
  });
  final List<String> columns;
  final List<String> rows;
  final List<String> values;

  int get _rowCount {
    if (rows.isNotEmpty) return rows.length;
    if (columns.isEmpty) return 0;
    return (values.length / columns.length).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              if (rows.isNotEmpty) const DataColumn(label: Text('')),
              ...columns.map((column) => DataColumn(label: Text(column))),
            ],
            rows: List.generate(_rowCount, (rowIndex) {
              return DataRow(cells: [
                if (rows.isNotEmpty) DataCell(Text(rows[rowIndex])),
                ...columns.map((_) => const DataCell(
                      SizedBox(width: 110, child: TextField()),
                    )),
              ]);
            }),
          ),
        ),
        if (values.isNotEmpty) ...[
          Text('${AppStrings.get('dataToFill')}:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ...values.indexed
              .map((entry) => Text('${entry.$1 + 1}. ${entry.$2}')),
        ],
      ],
    );
  }
}

class _QuizExercise extends StatelessWidget {
  const _QuizExercise({required this.questions});
  final List<Map<String, dynamic>> questions;

  @override
  Widget build(BuildContext context) {
    return Column(children: questions.map(QuizQuestion.new).toList());
  }
}

class _ConnectExercise extends StatefulWidget {
  const _ConnectExercise({required this.exercise});
  final StemExercise exercise;

  @override
  State<_ConnectExercise> createState() => _ConnectExerciseState();
}

class _ConnectExerciseState extends State<_ConnectExercise> {
  int? _selectedLeft;
  final _connections = <int, int>{};

  @override
  Widget build(BuildContext context) {
    final left = widget.exercise.stringList('column1Items');
    final right = widget.exercise.stringList('column2Items');
    final complete = _connections.length == left.length && left.isNotEmpty;
    final correct =
        _connections.entries.where((entry) => entry.key == entry.value).length;
    final columns = [
      _column(left, true, complete),
      const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.compare_arrows),
      ),
      _column(right, false, complete),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.exercise.text('text')),
        Text(AppStrings.get(
          _selectedLeft == null ? 'connectChooseFirst' : 'connectChooseSecond',
        )),
        const SizedBox(height: 8),
        if (widget.exercise.text('display') == 'vertical')
          Column(children: columns)
        else
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: columns[0]),
            columns[1],
            Expanded(child: columns[2]),
          ]),
        if (complete)
          Text('${AppStrings.get('correctPairs')}: $correct / ${left.length}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _column(List<String> items, bool isLeft, bool complete) {
    return Column(
      children: items.indexed.map((entry) {
        final connectedLeft = isLeft
            ? entry.$1
            : _connections.entries
                .where((connection) => connection.value == entry.$1)
                .firstOrNull
                ?.key;
        final connected =
            connectedLeft == null ? null : _connections[connectedLeft];
        final isCorrect = complete && connectedLeft == connected;
        final isWrong = complete && connected != null && !isCorrect;
        return Card(
          color: isCorrect
              ? Colors.green.shade100
              : isWrong
                  ? Colors.red.shade100
                  : isLeft && _selectedLeft == entry.$1
                      ? Colors.blue.shade100
                      : null,
          child: ListTile(
            title: Text(entry.$2),
            onTap: () => setState(() {
              if (isLeft) {
                _selectedLeft = entry.$1;
              } else if (_selectedLeft != null) {
                _connections.removeWhere((_, value) => value == entry.$1);
                _connections[_selectedLeft!] = entry.$1;
                _selectedLeft = null;
              }
            }),
          ),
        );
      }).toList(),
    );
  }
}
