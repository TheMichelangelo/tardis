import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/core/app_assets.dart';
import 'package:stem_laboratory/features/exercises/exercise_card.dart';
import 'package:stem_laboratory/features/lessons/lesson_pdf_service.dart';
import 'package:stem_laboratory/models.dart';

const lessonId = 'lesson-12-syla-tertya-shcho-stanetsya-yakshcho-von';

StemLesson frictionLesson(String language) {
  final catalog = StemClass.fromJson(jsonDecode(
      File('src/data/5_class_stem_lesson_$language.json').readAsStringSync()));
  return catalog.modules
      .expand((module) => module.themes)
      .expand((theme) => theme.lessons)
      .singleWhere((lesson) => lesson.id == lessonId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final language in ['ua', 'en']) {
    test('friction $language bundles all images and exports to PDF', () async {
      final lesson = frictionLesson(language);
      expect(lesson.number, 12);
      expect(lesson.exercises, hasLength(10));
      expect(lesson.visibleExercises, hasLength(8));
      expect(lesson.exercises[5].type, ExerciseType.homework);
      expect(lesson.exercises[6].type, ExerciseType.diagram);
      expect(lesson.exercises[7].type, ExerciseType.rebus);
      for (final exercise in lesson.visibleExercises
          .where((exercise) => exercise.data.containsKey('imageExt'))) {
        final path = AppAssets.exerciseImage(
            lessonId: lesson.id,
            exerciseId: exercise.id,
            extension: exercise.text('imageExt'));
        final bytes = (await rootBundle.load(path)).buffer.asUint8List();
        expect(File('public/$path').readAsBytesSync(), bytes);
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(1000));
        expect(exercise.text('imageAlt'), isNotEmpty);
        frame.image.dispose();
        codec.dispose();
      }
      final pdf = await const LessonPdfService()
          .build(lesson: lesson, moduleTitle: 'STEM', classNumber: 5);
      expect(ascii.decode(pdf.take(5).toList()), '%PDF-');
    });
  }

  for (final slot in [0, 1, 6, 7]) {
    testWidgets('friction slot $slot shows image and questions on a phone',
        (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final exercise = frictionLesson('ua').exercises[slot];
      // Inline the same bundled image so file IO does not affect widget timing.
      final path = AppAssets.exerciseImage(
          lessonId: lessonId,
          exerciseId: exercise.id,
          extension: exercise.text('imageExt'));
      final encoded = base64Encode(File(path).readAsBytesSync());
      final illustrated = StemExercise.fromJson({
        ...exercise.toJson(),
        'imageData': encoded,
      });
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.7)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseCard(
                lessonId: lessonId, exercise: illustrated, isTeacher: true),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text(exercise.text('text')), findsOneWidget);
      for (final question in exercise.stringList('questions')) {
        expect(find.text(question), findsOneWidget);
      }
      expect(find.byType(Image), findsOneWidget);
      expect(tester.widget<Image>(find.byType(Image)).semanticLabel,
          exercise.text('imageAlt'));
      await tester.ensureVisible(find.byIcon(Icons.zoom_in));
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
