import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/app_assets.dart';
import '../../core/localization.dart';
import '../../core/reading_settings.dart';
import '../../core/responsive_layout.dart';
import '../../core/stem_background.dart';
import '../../models.dart';
import '../../repository.dart';
import '../auth/auth_controller.dart';

enum ProposalTarget { lesson, exercise }

class QuizQuestionDraft {
  QuizQuestionDraft([int index = 1]) : id = 'q$index';

  String id;
  String question = '';
  String singleChoice = '';
  String trueFalse = 'True';
  String shortText = '';

  List<String> get choices => singleChoice
      .split('\n')
      .map((choice) => choice.trim())
      .where((choice) => choice.isNotEmpty)
      .toList();

  Map<String, dynamic> toJson() => {
        'id': id.trim(),
        'question': question.trim(),
        'answerTypes': {
          'singleChoice': choices,
          'trueFalse': trueFalse,
          'shortText': shortText.trim(),
        },
      };
}

class ExerciseDraft {
  String id = '';
  String label = '';
  ExerciseType type = ExerciseType.text;
  final formats = <LessonFormat>{LessonFormat.all};
  String solution = '';
  String text = '';
  String columns = '';
  String rows = '';
  String dataToFill = '';
  String youtubeUrl = '';
  String videoUrl = '';
  String leftItems = '';
  String rightItems = '';
  String display = 'horizontal';
  Uint8List? imageBytes;
  String imageExtension = 'png';
  final quizQuestions = <QuizQuestionDraft>[QuizQuestionDraft()];

  List<String> _lines(String value) => value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id': id.trim(),
      'label': label.trim(),
      'type':
          type == ExerciseType.interactiveQuiz ? 'interactive_quiz' : type.name,
      'formats': formats.map((format) => format.jsonValue).toList(),
      if (solution.trim().isNotEmpty) 'solution': solution.trim(),
    };
    switch (type) {
      case ExerciseType.diagram:
      case ExerciseType.rebus:
        result.addAll(_imagePayload());
      case ExerciseType.table:
        result.addAll({
          'columns': _lines(columns),
          'rows': _lines(rows),
          'dataToFill': _lines(dataToFill),
        });
      case ExerciseType.text:
        result.addAll({'text': text.trim(), 'questions': _lines(dataToFill)});
      case ExerciseType.video:
        result.addAll({
          'youtubeUrl': youtubeUrl.trim(),
          'questions': _lines(dataToFill),
        });
      case ExerciseType.interactiveQuiz:
        result['questions'] =
            quizQuestions.map((question) => question.toJson()).toList();
      case ExerciseType.homework:
        result.addAll({
          'text': text.trim(),
          if (videoUrl.trim().isNotEmpty) 'videoUrl': videoUrl.trim(),
          ..._imagePayload(),
        });
      case ExerciseType.connect:
        result.addAll({
          'text': text.trim(),
          'column1Items': _lines(leftItems),
          'column2Items': _lines(rightItems),
          'display': display,
        });
      case ExerciseType.unknown:
        break;
    }
    return result;
  }

  Map<String, dynamic> _imagePayload() => {
        if (imageBytes != null) 'imageData': base64Encode(imageBytes!),
        'imageExt': imageExtension,
      };
}

class ProposalPage extends StatefulWidget {
  const ProposalPage({
    required this.classNumber,
    required this.repository,
    required this.authController,
    required this.language,
    super.key,
  });

  final int classNumber;
  final LessonRepository repository;
  final AuthController authController;
  final AppLanguage language;

  @override
  State<ProposalPage> createState() => _ProposalPageState();
}

class _ProposalPageState extends State<ProposalPage> {
  late final Future<StemClass> _data = widget.repository.load(
    widget.classNumber,
    language: widget.language,
  );
  ProposalTarget _target = ProposalTarget.lesson;
  String? _themeKey;
  String? _lessonId;
  String _newLessonId = '';
  String _newLessonTitle = '';
  String _newLessonTopic = '';
  final _lessonFormats = <LessonFormat>{LessonFormat.quiz};
  final _singleExerciseDraft = ExerciseDraft();
  final _lessonDrafts = <ExerciseDraft>[ExerciseDraft()];
  String _preview = '';

  void _createProposal(StemClass data) {
    final themeKey = _themeKey;
    if (themeKey == null) return;
    final parts = themeKey.split(':');
    final moduleId = parts.first;
    final themeId = parts.last;
    final themeName = data.modules
        .where((module) => module.id == moduleId)
        .firstOrNull
        ?.title;

    final proposal = {
      'classNumber': widget.classNumber,
      'moduleId': moduleId,
      'themeId': themeId,
      'themeName': themeName,
      'proposalType': _target.name,
      if (_target == ProposalTarget.lesson)
        'lesson': {
          'id': _newLessonId.trim(),
          'title': _newLessonTitle.trim(),
          'topic': _newLessonTopic.trim(),
          'formats': _lessonFormats.map((format) => format.jsonValue).toList(),
          'exercises': _lessonDrafts.map((draft) => draft.toJson()).toList(),
        }
      else ...{
        'lessonId': _lessonId,
        'exercise': _singleExerciseDraft.toJson(),
      },
    };
    setState(() {
      _preview = const JsonEncoder.withIndent('  ').convert(proposal);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('proposalSaved'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.authController.isLoggedIn) {
      return Scaffold(
          body: Center(child: Text(AppStrings.get('invalidCredentials'))));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('createProposal'),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: const [TextSizeButton()],
      ),
      body: StemBackgroundBody(
        child: FutureBuilder<StemClass>(
          future: _data,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.requireData;
            final themes = data.modules
                .expand(
                    (module) => module.themes.map((theme) => (module, theme)))
                .toList();
            _themeKey ??= themes.isEmpty
                ? null
                : '${themes.first.$1.id}:${themes.first.$2.id}';
            final selected = themes.where((entry) {
              return '${entry.$1.id}:${entry.$2.id}' == _themeKey;
            }).firstOrNull;
            _lessonId ??= selected?.$2.lessons.firstOrNull?.id;
            return ListView(
              padding: pagePadding(context),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final target in ProposalTarget.values)
                      ChoiceChip(
                        label: Text(AppStrings.get(
                            target == ProposalTarget.lesson
                                ? 'newLesson'
                                : 'newExercise')),
                        selected: _target == target,
                        onSelected: (_) => setState(() => _target = target),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  isDense: false,
                  itemHeight: null,
                  initialValue: _themeKey,
                  decoration:
                      InputDecoration(labelText: AppStrings.get('selectTheme')),
                  items: themes.map((entry) {
                    final key = '${entry.$1.id}:${entry.$2.id}';
                    return DropdownMenuItem(
                        value: key, child: Text(entry.$1.title));
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _themeKey = value;
                    final next = themes
                        .where(
                            (entry) => '${entry.$1.id}:${entry.$2.id}' == value)
                        .firstOrNull;
                    _lessonId = next?.$2.lessons.firstOrNull?.id;
                  }),
                ),
                const SizedBox(height: 12),
                if (_target == ProposalTarget.exercise && selected != null)
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    isDense: false,
                    itemHeight: null,
                    initialValue: _lessonId,
                    decoration: InputDecoration(
                        labelText: AppStrings.get('selectLesson')),
                    items: selected.$2.lessons
                        .map((lesson) => DropdownMenuItem(
                              value: lesson.id,
                              child: Text(lesson.title),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _lessonId = value),
                  ),
                if (_target == ProposalTarget.lesson) ...[
                  const SizedBox(height: 12),
                  _field(AppStrings.get('id'), (value) => _newLessonId = value),
                  _field(AppStrings.get('title'),
                      (value) => _newLessonTitle = value),
                  _field(AppStrings.get('topic'),
                      (value) => _newLessonTopic = value),
                  _FormatSelector(
                      selected: _lessonFormats,
                      onChanged: () => setState(() {})),
                ],
                const SizedBox(height: 16),
                ...(_target == ProposalTarget.lesson
                        ? _lessonDrafts
                        : [_singleExerciseDraft])
                    .indexed
                    .map((entry) => ExerciseDraftEditor(
                          key: ValueKey(entry.$1),
                          index: entry.$1,
                          draft: entry.$2,
                          onChanged: () => setState(() {}),
                        )),
                if (_target == ProposalTarget.lesson)
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _lessonDrafts.add(ExerciseDraft())),
                    icon: const Icon(Icons.add),
                    label: Text(AppStrings.get('addExercise')),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _createProposal(data),
                  icon: const Icon(Icons.description),
                  label: Text(AppStrings.get('submitProposal')),
                ),
                if (_preview.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(AppStrings.get('preview'),
                      style: Theme.of(context).textTheme.titleLarge),
                  SelectableText(_preview),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _field(String label, ValueChanged<String> changed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
          decoration: InputDecoration(labelText: label), onChanged: changed),
    );
  }
}

class ExerciseDraftEditor extends StatelessWidget {
  const ExerciseDraftEditor({
    required this.index,
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final int index;
  final ExerciseDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${AppStrings.get('newExercise')} ${index + 1}',
                style: Theme.of(context).textTheme.titleLarge),
            _field(AppStrings.get('id'), (value) => draft.id = value),
            _field(AppStrings.get('title'), (value) => draft.label = value),
            DropdownButtonFormField<ExerciseType>(
              isExpanded: true,
              isDense: false,
              itemHeight: null,
              initialValue: draft.type,
              decoration: InputDecoration(labelText: AppStrings.get('type')),
              items: ExerciseType.values
                  .where((type) => type != ExerciseType.unknown)
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(AppStrings.exerciseType(type)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  draft.type = value;
                  onChanged();
                }
              },
            ),
            const SizedBox(height: 12),
            _FormatSelector(selected: draft.formats, onChanged: onChanged),
            _field(
                AppStrings.get('solution'), (value) => draft.solution = value,
                lines: 3),
            ..._typeFields(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _typeFields(BuildContext context) {
    final fields = <Widget>[];
    if ({ExerciseType.text, ExerciseType.homework, ExerciseType.connect}
        .contains(draft.type)) {
      fields.add(_field(
          AppStrings.get('content'), (value) => draft.text = value,
          lines: 4));
    }
    if (draft.type == ExerciseType.table) {
      fields.addAll([
        _field(AppStrings.get('columns'), (value) => draft.columns = value,
            lines: 3),
        _field(AppStrings.get('rows'), (value) => draft.rows = value, lines: 3),
        _field(
            AppStrings.get('dataToFill'), (value) => draft.dataToFill = value,
            lines: 4),
      ]);
    }
    if ({ExerciseType.text, ExerciseType.video}.contains(draft.type)) {
      fields.add(_field(
          AppStrings.get('questions'), (value) => draft.dataToFill = value,
          lines: 4));
    }
    if (draft.type == ExerciseType.video) {
      fields.add(_field(
          AppStrings.get('youtubeUrl'), (value) => draft.youtubeUrl = value));
    }
    if (draft.type == ExerciseType.homework) {
      fields.add(_field(
          AppStrings.get('youtubeUrl'), (value) => draft.videoUrl = value));
    }
    if (draft.type == ExerciseType.connect) {
      fields.addAll([
        _field(AppStrings.get('leftItems'), (value) => draft.leftItems = value,
            lines: 4),
        _field(
            AppStrings.get('rightItems'), (value) => draft.rightItems = value,
            lines: 4),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final display in ['horizontal', 'vertical'])
              ChoiceChip(
                label: Text(AppStrings.get(display)),
                selected: draft.display == display,
                onSelected: (_) {
                  draft.display = display;
                  onChanged();
                },
              ),
          ],
        ),
      ]);
    }
    if (draft.type == ExerciseType.interactiveQuiz) {
      fields.addAll([
        ...draft.quizQuestions.indexed.map((entry) => Card.outlined(
              margin: const EdgeInsets.only(top: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${AppStrings.get('questions')} ${entry.$1 + 1}'),
                    _field(
                        AppStrings.get('id'), (value) => entry.$2.id = value),
                    _field(AppStrings.get('questions'),
                        (value) => entry.$2.question = value,
                        lines: 3),
                    _field(AppStrings.get('singleChoiceOptions'),
                        (value) => entry.$2.singleChoice = value,
                        lines: 4),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      isDense: false,
                      itemHeight: null,
                      initialValue: entry.$2.trueFalse,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('trueFalse'),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'True', child: Text('True')),
                        DropdownMenuItem(value: 'False', child: Text('False')),
                      ],
                      onChanged: (value) =>
                          entry.$2.trueFalse = value ?? 'True',
                    ),
                    _field(AppStrings.get('correctAnswer'),
                        (value) => entry.$2.shortText = value),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            draft.quizQuestions
                .add(QuizQuestionDraft(draft.quizQuestions.length + 1));
            onChanged();
          },
          icon: const Icon(Icons.add),
          label: Text(AppStrings.get('addQuestion')),
        ),
      ]);
    }
    if ({ExerciseType.diagram, ExerciseType.rebus, ExerciseType.homework}
        .contains(draft.type)) {
      fields.add(OutlinedButton.icon(
        onPressed: () async {
          final file = await FilePicker.pickFile(
            type: FileType.image,
          );
          if (file != null) {
            draft.imageBytes = await file.readAsBytes();
            final extension = file.name.contains('.')
                ? file.name.split('.').last.toLowerCase()
                : 'png';
            draft.imageExtension = extension;
            onChanged();
          }
        },
        icon: const Icon(Icons.image),
        label: Text(draft.imageBytes == null
            ? AppStrings.get('chooseImage')
            : '${AppStrings.get('image')} ✓'),
      ));
    }
    return fields;
  }

  Widget _field(String label, ValueChanged<String> changed, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        maxLines: lines,
        onChanged: changed,
      ),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.selected, required this.onChanged});
  final Set<LessonFormat> selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: LessonFormat.values.map((format) {
        return FilterChip(
          label: Text(AppStrings.format(format)),
          selected: selected.contains(format),
          onSelected: (enabled) {
            if (format == LessonFormat.all && enabled) {
              selected
                ..clear()
                ..add(LessonFormat.all);
            } else if (enabled) {
              selected.remove(LessonFormat.all);
              selected.add(format);
            } else {
              selected.remove(format);
              if (selected.isEmpty) selected.add(LessonFormat.all);
            }
            onChanged();
          },
        );
      }).toList(),
    );
  }
}
