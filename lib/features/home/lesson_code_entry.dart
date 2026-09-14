import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/lesson_code.dart';
import '../../core/localization.dart';

class LessonCodeEntry extends StatefulWidget {
  const LessonCodeEntry({super.key});

  @override
  State<LessonCodeEntry> createState() => _LessonCodeEntryState();
}

class _LessonCodeEntryState extends State<LessonCodeEntry> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    final code = LessonCode.tryParse(_controller.text);
    if (code == null) {
      setState(() => _error = AppStrings.get('invalidLessonCode'));
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(context, AppRoutes.sharedLesson(code.toString()));
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.get('openByCode'),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('lesson-code-input'),
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.go,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: LessonCode.length,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('lessonCode'),
                    hintText: AppStrings.get('lessonCodeHint'),
                    errorText: _error,
                    errorMaxLines: 3,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _open(),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const Key('open-lesson-code'),
                  onPressed: _open,
                  icon: const Icon(Icons.login),
                  label: Text(AppStrings.get('open')),
                ),
              ],
            ),
          ),
        ),
      );
}
