import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../../models.dart';

class LessonPdfService {
  const LessonPdfService();

  Future<Uint8List> build({
    required StemLesson lesson,
    required String moduleTitle,
    required int classNumber,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    final sections = <pw.Widget>[];
    for (final exercise in lesson.exercises) {
      sections.add(await _exercise(lesson.id, exercise));
    }
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Text(lesson.title, style: pw.TextStyle(font: bold, fontSize: 22)),
          pw.SizedBox(height: 4),
          pw.Text('${AppStrings.get('class')} $classNumber • $moduleTitle'),
          pw.Text(lesson.topic),
          pw.SizedBox(height: 16),
          ...sections,
        ],
      ),
    );
    return document.save();
  }

  Future<pw.Widget> _exercise(String lessonId, StemExercise exercise) async {
    final children = <pw.Widget>[
      pw.Text(exercise.label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
      pw.SizedBox(height: 6),
    ];
    switch (exercise.type) {
      case ExerciseType.diagram:
      case ExerciseType.rebus:
        final image = await _image(lessonId, exercise);
        if (image != null) children.add(pw.Image(image, height: 240));
      case ExerciseType.text:
        children.add(pw.Text(exercise.text('text')));
        children.addAll(_list(exercise.stringList('questions')));
      case ExerciseType.video:
        final url = exercise.text('youtubeUrl');
        children.addAll([
          pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(), data: url, width: 100, height: 100),
          pw.Text(url)
        ]);
        children.addAll(_list(exercise.stringList('questions')));
      case ExerciseType.table:
        final columns = exercise.stringList('columns');
        final rows = exercise.stringList('rows');
        if (columns.isNotEmpty) {
          children.add(pw.TableHelper.fromTextArray(
            headers: [if (rows.isNotEmpty) '', ...columns],
            data: List.generate(
              rows.isNotEmpty
                  ? rows.length
                  : (exercise.stringList('dataToFill').length / columns.length)
                      .ceil(),
              (index) =>
                  [if (rows.isNotEmpty) rows[index], ...columns.map((_) => '')],
            ),
          ));
          children.addAll(_list(exercise.stringList('dataToFill')));
        }
      case ExerciseType.interactiveQuiz:
        for (final question in exercise.objectList('questions')) {
          final answers =
              question['answerTypes'] as Map<String, dynamic>? ?? {};
          children.add(pw.Text('• ${question['question'] ?? ''}'));
          children.add(pw.Text(
            (answers['singleChoice'] as List? ?? const []).join(' | '),
          ));
        }
      case ExerciseType.homework:
        children.add(pw.Text(exercise.text('text')));
        final image = await _image(lessonId, exercise);
        if (image != null) children.add(pw.Image(image, height: 200));
        final url = exercise.text('videoUrl');
        if (url.isNotEmpty) {
          children.add(pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: url,
              width: 100,
              height: 100));
        }
      case ExerciseType.connect:
        children.add(pw.Text(exercise.text('text')));
        final left = exercise.stringList('column1Items');
        final right = exercise.stringList('column2Items');
        children.addAll(List.generate(left.length, (index) {
          return pw.Text(
              '${left[index]} — ${index < right.length ? right[index] : ''}');
        }));
      case ExerciseType.unknown:
        break;
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, children: children),
    );
  }

  List<pw.Widget> _list(List<String> values) {
    return values.indexed
        .map((entry) => pw.Text('${entry.$1 + 1}. ${entry.$2}'))
        .toList();
  }

  Future<pw.MemoryImage?> _image(
    String lessonId,
    StemExercise exercise,
  ) async {
    final encoded = exercise.text('imageData');
    if (encoded.isNotEmpty) {
      return pw.MemoryImage(base64Decode(encoded));
    }
    if (!exercise.data.containsKey('imageExt') &&
        exercise.type == ExerciseType.homework) {
      return null;
    }
    try {
      final data = await rootBundle.load(AppAssets.exerciseImage(
        lessonId: lessonId,
        exerciseId: exercise.id,
        extension: exercise.text('imageExt', fallback: 'png'),
      ));
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  Future<void> printLesson({
    required StemLesson lesson,
    required String moduleTitle,
    required int classNumber,
  }) async {
    await Printing.layoutPdf(
      name: '${lesson.id}.pdf',
      onLayout: (_) => build(
        lesson: lesson,
        moduleTitle: moduleTitle,
        classNumber: classNumber,
      ),
    );
  }

  Future<void> shareLesson({
    required StemLesson lesson,
    required String moduleTitle,
    required int classNumber,
  }) async {
    final bytes = await build(
      lesson: lesson,
      moduleTitle: moduleTitle,
      classNumber: classNumber,
    );
    await Printing.sharePdf(bytes: bytes, filename: '${lesson.id}.pdf');
  }
}
