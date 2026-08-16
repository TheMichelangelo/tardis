import 'package:flutter_test/flutter_test.dart';
import 'package:stem_laboratory/features/proposals/proposal_page.dart';
import 'package:stem_laboratory/models.dart';

void main() {
  test('proposal draft serializes teacher solution and connect layout', () {
    final draft = ExerciseDraft()
      ..id = 'connect-1'
      ..label = 'Match the pairs'
      ..type = ExerciseType.connect
      ..solution = 'A — 1'
      ..text = 'Connect each item'
      ..leftItems = 'A\nB'
      ..rightItems = '1\n2'
      ..display = 'vertical';

    final json = draft.toJson();

    expect(json['solution'], 'A — 1');
    expect(json['column1Items'], ['A', 'B']);
    expect(json['column2Items'], ['1', '2']);
    expect(json['display'], 'vertical');
  });

  test('proposal draft serializes structured quiz questions', () {
    final draft = ExerciseDraft()
      ..id = 'quiz-1'
      ..label = 'Quiz'
      ..type = ExerciseType.interactiveQuiz;
    draft.quizQuestions.single
      ..question = 'Closest planet?'
      ..singleChoice = 'Mercury\nEarth\nMars'
      ..trueFalse = 'True'
      ..shortText = 'Mercury';

    final questions = draft.toJson()['questions'] as List<dynamic>;
    final answerTypes = (questions.single
        as Map<String, dynamic>)['answerTypes'] as Map<String, dynamic>;

    expect(answerTypes['singleChoice'], ['Mercury', 'Earth', 'Mars']);
    expect(answerTypes['shortText'], 'Mercury');
  });
}
