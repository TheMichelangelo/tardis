import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/lesson_code.dart';
import '../../core/localization.dart';

class LessonCodeEntry extends StatefulWidget {
  const LessonCodeEntry({this.onOpenLesson, super.key});

  /// Lets a dialog close itself before the app navigates to the lesson.
  final ValueChanged<String>? onOpenLesson;

  @override
  State<LessonCodeEntry> createState() => _LessonCodeEntryState();
}

class _LessonCodeEntryState extends State<LessonCodeEntry> {
  late final List<TextEditingController> _controllers = List.generate(
    LessonCode.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    LessonCode.length,
    (index) => FocusNode(
      onKeyEvent: (_, event) => _handleKeyEvent(index, event),
    ),
  );
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onDigitChanged(int index, String value) {
    if (_error != null) setState(() => _error = null);
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var offset = 0;
          offset < digits.length && index + offset < LessonCode.length;
          offset++) {
        _controllers[index + offset].text = digits[offset];
      }
      if (digits.length < LessonCode.length - index) {
        _focusNodes[index + digits.length].requestFocus();
      } else {
        _focusNodes.last.unfocus();
      }
      return;
    }
    if (value.isNotEmpty && index < LessonCode.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _open() {
    final code = LessonCode.tryParse(_code);
    if (code == null) {
      setState(() => _error = AppStrings.get('invalidLessonCode'));
      return;
    }
    FocusScope.of(context).unfocus();
    if (widget.onOpenLesson != null) {
      widget.onOpenLesson!(code.toString());
      return;
    }
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
                Text(
                  AppStrings.get('lessonCode'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) => Row(
                    key: const Key('lesson-code-input'),
                    children: [
                      for (var index = 0; index < LessonCode.length; index++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == LessonCode.length - 1 ? 0 : 4,
                            ),
                            child: Semantics(
                              label:
                                  '${AppStrings.get('lessonCode')}, ${index + 1}',
                              textField: true,
                              child: TextField(
                                key: Key('lesson-code-digit-$index'),
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                autofocus: index == 0,
                                keyboardType: TextInputType.number,
                                textInputAction: index == LessonCode.length - 1
                                    ? TextInputAction.go
                                    : TextInputAction.next,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  counterText: '',
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                ),
                                onChanged: (value) =>
                                    _onDigitChanged(index, value),
                                onSubmitted: (_) =>
                                    index == LessonCode.length - 1
                                        ? _open()
                                        : _focusNodes[index + 1].requestFocus(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
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
