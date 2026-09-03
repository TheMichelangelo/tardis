import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/app.dart';
import 'package:stem_laboratory/features/exercises/exercise_card.dart';
import 'package:stem_laboratory/features/lessons/lesson_page.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  testWidgets('home shows both supported classes', (tester) async {
    SharedPreferences.setMockInitialValues({
      'app_role_v1': 'student',
      'student_class_v1': 5,
    });
    await tester.pumpWidget(const StemApp());
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Я вчитель'), findsOneWidget);
  });

  testWidgets('students cannot print or export lessons', (tester) async {
    final lesson = StemLesson.fromJson({
      'id': 'lesson',
      'title': 'Урок',
      'topic': 'Тема',
      'formats': ['story'],
      'exercises': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: LessonPage(
        classNumber: 5,
        moduleTitle: 'Модуль',
        lesson: lesson,
        isTeacher: false,
      ),
    ));
    expect(find.byIcon(Icons.print), findsNothing);
    expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
  });

  testWidgets('diagnostic answer files are visible only to teachers',
      (tester) async {
    final exercise = StemExercise.fromJson({
      'id': 'diagnostic-download',
      'label': 'Діагностувальна робота',
      'type': 'homework',
      'formats': ['story'],
      'text': 'Завантажте потрібну версію.',
      'studentPdf': 'src/data/6_diagnostic/student.pdf',
      'teacherPdf': 'src/data/6_diagnostic/teacher.pdf',
    });

    Future<void> pumpCard({required bool isTeacher}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExerciseCard(
            lessonId: 'diagnostic-lesson',
            exercise: exercise,
            isTeacher: isTeacher,
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    await pumpCard(isTeacher: false);
    expect(find.text('Завантажити PDF'), findsOneWidget);
    expect(find.text('Завантажити PDF з відповідями'), findsNothing);

    await pumpCard(isTeacher: true);
    expect(find.text('Завантажити PDF'), findsOneWidget);
    expect(find.text('Завантажити PDF з відповідями'), findsOneWidget);
  });
}
