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
  String _typed = '';
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final rawAnswers = widget.question['answerTypes'];
    final answers = rawAnswers is Map<String, dynamic>
        ? rawAnswers
        : const <String, dynamic>{};
    final options = (answers['singleChoice'] as List? ?? const [])
        .map((option) => '$option')
        .toList();
    final correct = '${answers['shortText'] ?? ''}'.trim();
    final actual = (_selected ?? _typed).trim();
    final isCorrect = actual.toLowerCase() == correct.toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xfff8fafc),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.question['question'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (options.isNotEmpty)
              ...options.map((option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _selected == option
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    title: Text(option),
                    onTap: () => setState(() {
                      _selected = option;
                      _revealed = true;
                    }),
                  ))
            else ...[
              TextField(
                decoration:
                    InputDecoration(labelText: AppStrings.get('answer')),
                onChanged: (value) => _typed = value,
                onSubmitted: (_) => setState(() => _revealed = true),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => setState(() => _revealed = true),
                child: Text(AppStrings.get('correctAnswer')),
              ),
            ],
            if (_revealed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isCorrect ? AppStrings.get('connectCorrect') : AppStrings.get('connectWrong')}\n'
                  '${AppStrings.get('correctAnswer')}: $correct\n'
                  '${AppStrings.get('yourChoice')}: $actual',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
