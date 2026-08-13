import 'package:flutter/material.dart';

import '../../core/localization.dart';

class QuizQuestion extends StatefulWidget {
  const QuizQuestion(this.question, {super.key});

  final Map<String, dynamic> question;

  @override
  State<QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final rawAnswers = widget.question['answerTypes'];
    final answers = rawAnswers is Map<String, dynamic>
        ? rawAnswers
        : const <String, dynamic>{};
    final rawOptions = answers['singleChoice'];
    final options = rawOptions is List
        ? rawOptions.map((option) => '$option').toList()
        : const <String>[];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.question['question'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          ...options.map(
            (option) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _selected == option
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(option),
              onTap: () => setState(() => _selected = option),
            ),
          ),
          if (options.isEmpty)
            TextField(
              decoration: InputDecoration(
                labelText: AppStrings.get('answer'),
              ),
            ),
        ],
      ),
    );
  }
}
