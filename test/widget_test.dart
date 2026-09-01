import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stem_laboratory/app.dart';
import 'package:stem_laboratory/features/exercises/exercise_card.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  testWidgets('home shows both supported classes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StemApp());
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Я вчитель'), findsOneWidget);
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
      'studentTex': 'src/data/6_diagnostic/student.tex',
      'teacherPdf': 'src/data/6_diagnostic/teacher.pdf',
      'teacherTex': 'src/data/6_diagnostic/teacher.tex',
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
    expect(find.text('Завантажити PDF без відповідей'), findsOneWidget);
    expect(find.text('Завантажити TeX без відповідей'), findsOneWidget);
    expect(find.text('Завантажити PDF з відповідями'), findsNothing);
    expect(find.text('Завантажити TeX з відповідями'), findsNothing);

    await pumpCard(isTeacher: true);
    expect(find.text('Завантажити PDF без відповідей'), findsOneWidget);
    expect(find.text('Завантажити TeX без відповідей'), findsOneWidget);
    expect(find.text('Завантажити PDF з відповідями'), findsOneWidget);
    expect(find.text('Завантажити TeX з відповідями'), findsOneWidget);
  });
}
